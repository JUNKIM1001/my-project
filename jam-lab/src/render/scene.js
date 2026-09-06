// three.js シーン: 海沿いの 1 km 周回路（スタジアム形）・空・照明・車列の配置。
// sim からは cars[i].{s, v, a, isPlayer, braking} と playerIndex だけを読む。
// ジオメトリは起動時 / setSag 時にだけ構築し、毎フレームは行列更新と描画のみ。
import * as THREE from '../../vendor/three.module.js';
import { LENGTH, CAR_LENGTH, pointAt, elevationAt, wrap } from '../shared/track.js';
import { createTrafficCar, setBrake, disposeCar, disposeCarAssets, CAR_COLORS } from './carkit.js';
import { createRX7, WHEEL_R } from './rx7.js';
import { createCameraRig, CAMERA_MODES } from './camera.js';

const ROAD_HALF = 3.5;     // 道路幅 7 m（1 車線 + 路肩）
const SAMPLE_STEP = 2;     // リボンのサンプリング間隔 [m]
const RAIL_D = 4.1;        // ガードレールの横位置（外側 = 右手 = +d）
const POLE_SPACING = 60;   // 照明ポール間隔（周長で割り切れるよう丸める）
const SNAP_JUMP_M = 60;    // 1 フレームでこれ以上プレイヤーが動いたらカメラをスナップ [m]
const box = (w, h, d) => new THREE.BoxGeometry(w, h, d);

// 朝 / 夕のプリセット（色は sRGB 16 進）
const PRESETS = {
  morning: {
    skyTop: 0x5f9bd6, skyHorizon: 0xe6eef5, sunColor: 0xfff2dc, sunIntensity: 2.4,
    sunDir: [0.55, 0.42, 0.72], hemiSky: 0xcfe1f3, hemiGround: 0x6d7b66, hemiIntensity: 0.7,
    fogNear: 300, fogFar: 1800, sea: 0x2f6f96, exposure: 1.0, lampOn: 0.0, envIntensity: 0.8,
  },
  dusk: {
    skyTop: 0x34306e, skyHorizon: 0xf2a668, sunColor: 0xffa055, sunIntensity: 2.3,
    sunDir: [-0.86, 0.18, 0.48], hemiSky: 0x7d6fae, hemiGround: 0x5a4640, hemiIntensity: 0.8,
    fogNear: 220, fogFar: 1500, sea: 0x3f4d7a, exposure: 1.0, lampOn: 1.6, envIntensity: 0.75,
  },
};

// ---------------------------------------------------------------------------
// プロシージャルテクスチャ
// ---------------------------------------------------------------------------
/** 微細ノイズ（アスファルト・地面用）。base に ±amp のグレー揺らぎ */
function noiseTexture(size, base, amp, tint = [1, 1, 1]) {
  const c = document.createElement('canvas');
  c.width = c.height = size;
  const ctx = c.getContext('2d');
  const img = ctx.createImageData(size, size);
  let seed = 12345;
  const rnd = () => ((seed = (seed * 1664525 + 1013904223) >>> 0) / 4294967296);
  for (let i = 0; i < img.data.length; i += 4) {
    const v = base + (rnd() - 0.5) * 2 * amp;
    img.data[i] = v * tint[0];
    img.data[i + 1] = v * tint[1];
    img.data[i + 2] = v * tint[2];
    img.data[i + 3] = 255;
  }
  ctx.putImageData(img, 0, 0);
  const t = new THREE.CanvasTexture(c);
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  t.colorSpace = THREE.SRGBColorSpace;
  return t;
}

/** 海面の法線マップ（周期的な正弦波の合成 → 継ぎ目なくタイル可能） */
function seaNormalTexture(size = 256) {
  const waves = [
    [3, 1, 0.9, 0.4], [1, 4, 0.7, 2.1], [5, -3, 0.45, 1.2], [-2, 6, 0.4, 0.6], [7, 5, 0.3, 3.0],
    [11, -4, 0.22, 1.7], [-9, 9, 0.18, 0.9], [13, 2, 0.14, 2.6], [4, -13, 0.12, 0.2],
  ]; // [fx, fy, amp, phase]（fx, fy は整数 → タイル周期に一致）
  const h = (u, v) => waves.reduce((acc, [fx, fy, a, p]) => acc + a * Math.sin(2 * Math.PI * (fx * u + fy * v) + p), 0);
  const c = document.createElement('canvas');
  c.width = c.height = size;
  const ctx = c.getContext('2d');
  const img = ctx.createImageData(size, size);
  const eps = 1 / size;
  const strength = 0.035;
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const u = x / size, v = y / size;
      const dx = (h(u + eps, v) - h(u - eps, v)) / (2 * eps) * strength;
      const dy = (h(u, v + eps) - h(u, v - eps)) / (2 * eps) * strength;
      const len = Math.hypot(dx, dy, 1);
      const i = (y * size + x) * 4;
      img.data[i] = (-dx / len * 0.5 + 0.5) * 255;
      img.data[i + 1] = (-dy / len * 0.5 + 0.5) * 255;
      img.data[i + 2] = (1 / len * 0.5 + 0.5) * 255;
      img.data[i + 3] = 255;
    }
  }
  ctx.putImageData(img, 0, 0);
  const t = new THREE.CanvasTexture(c);
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  return t;
}

// ---------------------------------------------------------------------------
// 空（グラデーション + 太陽の光芒）。フォグの影響を受けない BackSide の球
// ---------------------------------------------------------------------------
function makeSkyMaterial() {
  return new THREE.ShaderMaterial({
    uniforms: {
      topColor: { value: new THREE.Color() },
      horizonColor: { value: new THREE.Color() },
      sunColor: { value: new THREE.Color() },
      sunDir: { value: new THREE.Vector3(0, 1, 0) },
    },
    vertexShader: /* glsl */ `
      varying vec3 vDir;
      void main() {
        vec4 wp = modelMatrix * vec4(position, 1.0);
        vDir = normalize(wp.xyz - cameraPosition);
        gl_Position = projectionMatrix * viewMatrix * wp;
      }`,
    fragmentShader: /* glsl */ `
      uniform vec3 topColor, horizonColor, sunColor, sunDir;
      varying vec3 vDir;
      void main() {
        vec3 d = normalize(vDir);
        float h = clamp(d.y, 0.0, 1.0);
        vec3 col = mix(horizonColor, topColor, pow(h, 0.5));
        if (d.y < 0.0) col = horizonColor * 0.92;
        float sd = max(dot(d, sunDir), 0.0);
        col += sunColor * (pow(sd, 600.0) * 1.5 + pow(sd, 10.0) * 0.28);
        gl_FragColor = vec4(col, 1.0);
        #include <tonemapping_fragment>
        #include <colorspace_fragment>
      }`,
    side: THREE.BackSide,
    depthWrite: false,
    fog: false,
  });
}

// ---------------------------------------------------------------------------
// 道路リボン系の構築（pointAt を 2 m 刻みでサンプリング）
// ---------------------------------------------------------------------------
/** 横方向オフセット d [m]（+ = 進行方向の右手 = 外側）の点を返す */
function lateral(p, d, y) {
  return [p.x - p.fz * d, y, p.z + p.fx * d];
}

/**
 * 周回路に沿った閉じた帯。a / b は帯の両縁 { d, h }（横オフセットと高さオフセット）。
 * uv.u は s [m] / uScale、uv.v は 0..1。
 */
function buildStrip(a, b, sag, uScale = 4) {
  const n = Math.round(LENGTH / SAMPLE_STEP);
  const pos = new Float32Array(n * 2 * 3);
  const uv = new Float32Array(n * 2 * 2);
  const idx = new Uint32Array(n * 6);
  for (let i = 0; i < n; i++) {
    const s = i * SAMPLE_STEP;
    const p = pointAt(s);
    const y = elevationAt(s, sag);
    pos.set(lateral(p, a.d, y + a.h), i * 6);
    pos.set(lateral(p, b.d, y + b.h), i * 6 + 3);
    uv.set([s / uScale, 0, s / uScale, 1], i * 4);
    const j = (i + 1) % n;
    // 巻き順は上から見て反時計回り（法線が +Y 側）
    idx.set([i * 2, i * 2 + 1, j * 2, j * 2, i * 2 + 1, j * 2 + 1], i * 6);
  }
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  g.setAttribute('uv', new THREE.BufferAttribute(uv, 2));
  g.setIndex(new THREE.BufferAttribute(idx, 1));
  g.computeVertexNormals();
  return g;
}

/** センターラインの破線（長さ dash、間隔 gap）を 1 ジオメトリに */
function buildDashes(sag, halfW = 0.08, dash = 3, gap = 6, lift = 0.02) {
  const count = Math.floor(LENGTH / (dash + gap));
  const pos = new Float32Array(count * 4 * 3);
  const idx = new Uint32Array(count * 6);
  for (let i = 0; i < count; i++) {
    const s0 = i * (dash + gap);
    const p0 = pointAt(s0), p1 = pointAt(s0 + dash);
    const y0 = elevationAt(s0, sag) + lift, y1 = elevationAt(s0 + dash, sag) + lift;
    pos.set(lateral(p0, -halfW, y0), i * 12);
    pos.set(lateral(p0, halfW, y0), i * 12 + 3);
    pos.set(lateral(p1, -halfW, y1), i * 12 + 6);
    pos.set(lateral(p1, halfW, y1), i * 12 + 9);
    const v = i * 4;
    idx.set([v, v + 1, v + 2, v + 2, v + 1, v + 3], i * 6);
  }
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  g.setIndex(new THREE.BufferAttribute(idx, 1));
  g.computeVertexNormals();
  return g;
}

/** 進行方向に向けたインスタンス行列（ローカル +X = 進行、+Z = 右手） */
const _im = new THREE.Matrix4();
const _iq = new THREE.Quaternion();
const _ip = new THREE.Vector3();
const _ie = new THREE.Euler();
const _is = new THREE.Vector3(1, 1, 1);
function instanceAlong(mesh, i, s, sag) {
  const p = pointAt(s);
  _ip.set(p.x, elevationAt(s, sag), p.z);
  _iq.setFromEuler(_ie.set(0, -p.heading, 0));
  mesh.setMatrixAt(i, _im.compose(_ip, _iq, _is));
}

/** 道路・路肩・ガードレール・照明ポール・陸地をまとめた Group を構築 */
function buildTrack(sag, textures, lampMaterial) {
  const g = new THREE.Group();
  g.name = 'track';
  const add = (geo, mat, opts = {}) => {
    const m = new THREE.Mesh(geo, mat);
    m.receiveShadow = true;
    Object.assign(m, opts);
    g.add(m);
    return m;
  };

  // 陸地: 路肩の草地 → 砂浜が海面下まで下る（周回路の内外どちらも海）
  const grass = new THREE.MeshStandardMaterial({ color: 0x8c9472, roughness: 1, map: textures.ground });
  const sand = new THREE.MeshStandardMaterial({ color: 0xc9bea3, roughness: 1 });
  add(buildStrip({ d: -9, h: -0.03 }, { d: -3.3, h: -0.03 }, sag, 6), grass);
  add(buildStrip({ d: 3.3, h: -0.03 }, { d: 9, h: -0.03 }, sag, 6), grass);
  add(buildStrip({ d: -21, h: -2.2 }, { d: -9, h: -0.04 }, sag, 6), sand);
  add(buildStrip({ d: 9, h: -0.04 }, { d: 21, h: -2.2 }, sag, 6), sand);

  // 道路面
  const asphalt = new THREE.MeshStandardMaterial({ color: 0x4a4d52, roughness: 0.95, map: textures.asphalt });
  add(buildStrip({ d: -ROAD_HALF, h: 0 }, { d: ROAD_HALF, h: 0 }, sag), asphalt);

  // 白線（外縁 2 本 + センター破線）。polygonOffset で遠景の z ファイトを避ける
  const line = new THREE.MeshStandardMaterial({
    color: 0xe8e8e2, roughness: 0.7, polygonOffset: true, polygonOffsetFactor: -2, polygonOffsetUnits: -2,
  });
  add(buildStrip({ d: -3.35, h: 0.02 }, { d: -3.2, h: 0.02 }, sag), line);
  add(buildStrip({ d: 3.2, h: 0.02 }, { d: 3.35, h: 0.02 }, sag), line);
  add(buildDashes(sag), line);

  // ガードレール（外側）: 帯 + 支柱
  const steel = new THREE.MeshStandardMaterial({ color: 0xb9bec4, roughness: 0.45, metalness: 0.7, side: THREE.DoubleSide });
  add(buildStrip({ d: RAIL_D, h: 0.55 }, { d: RAIL_D, h: 0.82 }, sag), steel, { castShadow: true });
  const postCount = Math.round(LENGTH / 4);
  const posts = new THREE.InstancedMesh(box(0.08, 0.8, 0.12).translate(0, 0.4, RAIL_D + 0.05), steel, postCount);
  for (let i = 0; i < postCount; i++) instanceAlong(posts, i, i * 4, sag);
  posts.instanceMatrix.needsUpdate = true;
  g.add(posts);

  // 照明ポール（約 60 m 間隔・外側）: 柱 + アーム + 灯具
  const poleCount = Math.round(LENGTH / POLE_SPACING);
  const spacing = LENGTH / poleCount;
  const poleMat = new THREE.MeshStandardMaterial({ color: 0x8e949a, roughness: 0.5, metalness: 0.6 });
  const poleGeo = new THREE.CylinderGeometry(0.09, 0.13, 9, 8).translate(0, 4.5, RAIL_D + 1.3);
  const armGeo = box(0.1, 0.1, 2.4).translate(0, 8.95, RAIL_D + 0.1);
  const headGeo = box(0.55, 0.14, 0.9).translate(0, 8.85, RAIL_D - 1.0);
  const poles = new THREE.InstancedMesh(poleGeo, poleMat, poleCount);
  const arms = new THREE.InstancedMesh(armGeo, poleMat, poleCount);
  const heads = new THREE.InstancedMesh(headGeo, lampMaterial, poleCount);
  for (let i = 0; i < poleCount; i++) {
    instanceAlong(poles, i, i * spacing, sag);
    instanceAlong(arms, i, i * spacing, sag);
    instanceAlong(heads, i, i * spacing, sag);
  }
  poles.castShadow = true;
  g.add(poles, arms, heads);
  return g;
}

/** 遠景の低い丘（フォグで溶ける程度の距離に置く） */
function buildHills() {
  const g = new THREE.Group();
  const mat = new THREE.MeshStandardMaterial({ color: 0x5c7482, roughness: 1 });
  const geo = new THREE.ConeGeometry(1, 1, 14, 1).translate(0, 0.5, 0); // 底面を y=0 に
  const specs = [
    [-0.55, 1400, 620, 90], [-0.75, 1330, 480, 60], [-0.95, 1450, 760, 120], [-1.2, 1380, 540, 70],
    [-1.45, 1500, 680, 100], [-1.7, 1400, 500, 55], [-0.3, 1480, 580, 80], [0.0, 1420, 820, 130],
    [0.3, 1500, 620, 85], [2.9, 1450, 720, 105], [3.2, 1400, 520, 70],
  ]; // [方位角, 距離, 底面半径, 高さ]
  for (const [a, dist, r, h] of specs) {
    const m = new THREE.Mesh(geo, mat);
    m.position.set(Math.sin(a) * dist, -5, -Math.cos(a) * dist);
    m.scale.set(r, h, r);
    g.add(m);
  }
  return g;
}

// ---------------------------------------------------------------------------
// createScene
// ---------------------------------------------------------------------------
/**
 * WebGL が使えないときの代替。createScene と同じ API を持ち、すべて no-op。
 * 呼び出し側は `scene.unavailable` を見て静的メッセージを出す（sim / HUD / チャートは動き続ける）。
 */
function createUnavailableScene(error) {
  const noop = () => {};
  return {
    unavailable: true,
    error,
    update: noop, setCameraMode: noop, setTimeOfDay: noop, setSag: noop, setCarCount: noop, resize: noop, dispose: noop,
    get cameraMode() { return 'chase'; },
    get renderer() { return null; },
    CAMERA_MODES,
  };
}

export function createScene(canvas, { sag = false, shadows = true, timeOfDay = 'morning' } = {}) {
  let curSag = !!sag;

  // WebGL 非対応・ブロック環境では WebGLRenderer が throw する → no-op シーンで起動を継続
  let renderer;
  try {
    renderer = new THREE.WebGLRenderer({ canvas, antialias: true, powerPreference: 'high-performance' });
    if (!renderer.getContext()) throw new Error('WebGL context unavailable');
  } catch (e) {
    console.warn('[jam-lab] WebGL を初期化できません。3D 描画なしで続行します。', e);
    return createUnavailableScene(e);
  }
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  renderer.shadowMap.enabled = !!shadows;
  renderer.shadowMap.type = THREE.PCFShadowMap;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;

  let contextLost = false; // webglcontextlost 〜 restored の間は描画しない（リスナーは環境マップ定義の後で登録）

  const scene = new THREE.Scene();
  scene.fog = new THREE.Fog(0xffffff, 300, 2000);
  const camera = new THREE.PerspectiveCamera(55, 1, 0.3, 3200);
  const rig = createCameraRig(camera);

  // 空
  const skyMat = makeSkyMaterial();
  const sky = new THREE.Mesh(new THREE.SphereGeometry(2600, 32, 16), skyMat);
  sky.renderOrder = -1;
  sky.frustumCulled = false;
  scene.add(sky);

  // 照明: 半球 + 太陽（影は 1 枚 1024、プレイヤー周辺 ±45 m に追従）
  const hemi = new THREE.HemisphereLight(0xffffff, 0x444444, 0.6);
  const sun = new THREE.DirectionalLight(0xffffff, 2);
  sun.castShadow = !!shadows;
  sun.shadow.mapSize.set(1024, 1024);
  sun.shadow.camera.left = sun.shadow.camera.bottom = -45;
  sun.shadow.camera.right = sun.shadow.camera.top = 45;
  sun.shadow.camera.near = 10;
  sun.shadow.camera.far = 400;
  sun.shadow.bias = -0.0004;
  sun.shadow.normalBias = 0.03;
  scene.add(hemi, sun, sun.target);
  const sunDir = new THREE.Vector3(0, 1, 0);

  // 海: 大平面 + 法線マップのスクロールで簡易波
  const textures = {
    asphalt: noiseTexture(128, 110, 14),
    ground: noiseTexture(128, 150, 22, [0.95, 1, 0.85]),
    seaNormal: seaNormalTexture(256),
  };
  textures.seaNormal.repeat.set(420, 420); // 約 17 m タイル
  // 遠景の斜め視でタイルのモアレが出るので異方性フィルタを効かせる
  const aniso = renderer.capabilities.getMaxAnisotropy();
  textures.seaNormal.anisotropy = aniso;
  textures.asphalt.anisotropy = aniso;
  const seaMat = new THREE.MeshStandardMaterial({
    color: 0x2f6f96, roughness: 0.42, metalness: 0.05,
    normalMap: textures.seaNormal, normalScale: new THREE.Vector2(0.22, 0.22),
  });
  const sea = new THREE.Mesh(new THREE.PlaneGeometry(7000, 7000).rotateX(-Math.PI / 2), seaMat);
  sea.position.y = -1.5;
  sea.receiveShadow = true;
  scene.add(sea);

  const hills = buildHills();
  scene.add(hills);

  // 照明ポールの灯具（夕方だけ発光）
  const lampMat = new THREE.MeshStandardMaterial({ color: 0xf4f0e6, emissive: 0xffd9a0, emissiveIntensity: 0, roughness: 0.4 });
  let track = buildTrack(curSag, textures, lampMat);
  scene.add(track);

  // 車: プレイヤー RX-7（GLB を非同期読み込み）+ 一般車プール（index = sim.cars の添字、プレイヤー位置は非表示）
  const gtr = createRX7();
  scene.add(gtr);
  const traffic = [];
  let activeCount = 0;
  function ensurePool(n) {
    activeCount = n;
    while (traffic.length < n) {
      const car = createTrafficCar(CAR_COLORS[traffic.length % CAR_COLORS.length]);
      car.visible = false;
      scene.add(car);
      traffic.push(car);
    }
    for (let i = 0; i < traffic.length; i++) traffic[i].visible = i < n;
  }

  // 環境マップ: 空のグラデーションから PMREM を生成し、メタリック塗装と海の反射に使う
  const pmrem = new THREE.PMREMGenerator(renderer);
  const envScene = new THREE.Scene();
  const envSky = new THREE.Mesh(new THREE.SphereGeometry(100, 24, 12), skyMat);
  const envGround = new THREE.Mesh(
    new THREE.PlaneGeometry(400, 400).rotateX(-Math.PI / 2),
    new THREE.MeshBasicMaterial({ color: 0x2b4a5e }),
  );
  envGround.position.y = -1;
  envScene.add(envSky, envGround);
  // プリセットごとに PMREM をキャッシュ（初回使用時に遅延生成・以後は切替えても再生成しない）
  const envCache = { morning: null, dusk: null };
  let curPreset = 'morning';
  function rebuildEnvironment() {
    if (contextLost) return;
    try {
      if (!envCache[curPreset]) envCache[curPreset] = pmrem.fromScene(envScene, 0.04, 1, 500).texture;
      scene.environment = envCache[curPreset];
    } catch (e) {
      scene.environment = null; // 環境マップ無しでも動作は継続
    }
  }
  function disposeEnvCache() {
    for (const k of Object.keys(envCache)) { envCache[k]?.dispose(); envCache[k] = null; }
  }

  // コンテキスト消失: preventDefault で復帰を許可し、復帰まで描画を止める（GPU リセット・タブ大量時など）。
  // 復帰後は GPU 上にしかない PMREM が失われているのでキャッシュを捨てて再生成する
  const onContextLost = (ev) => { ev.preventDefault(); contextLost = true; };
  const onContextRestored = () => { contextLost = false; disposeEnvCache(); rebuildEnvironment(); };
  canvas.addEventListener('webglcontextlost', onContextLost, false);
  canvas.addEventListener('webglcontextrestored', onContextRestored, false);

  function applyPreset(name) {
    curPreset = PRESETS[name] ? name : 'morning';
    const p = PRESETS[curPreset];
    skyMat.uniforms.topColor.value.setHex(p.skyTop);
    skyMat.uniforms.horizonColor.value.setHex(p.skyHorizon);
    skyMat.uniforms.sunColor.value.setHex(p.sunColor);
    sunDir.set(...p.sunDir).normalize();
    skyMat.uniforms.sunDir.value.copy(sunDir);
    sun.color.setHex(p.sunColor);
    sun.intensity = p.sunIntensity;
    hemi.color.setHex(p.hemiSky);
    hemi.groundColor.setHex(p.hemiGround);
    hemi.intensity = p.hemiIntensity;
    scene.fog.color.setHex(p.skyHorizon);
    scene.fog.near = p.fogNear;
    scene.fog.far = p.fogFar;
    scene.background = scene.fog.color;
    seaMat.color.setHex(p.sea);
    lampMat.emissiveIntensity = p.lampOn;
    renderer.toneMappingExposure = p.exposure;
    scene.environmentIntensity = p.envIntensity;
    rebuildEnvironment();
  }
  applyPreset(timeOfDay);

  // --- 車の配置 ---
  const pose = { x: 0, y: 0, z: 0, fx: 0, fz: -1 };
  let prevPlayerS = null;
  const _p = new THREE.Vector3();

  /** s と勾配から車を置く。ピッチは車長分の標高差から取り、勾配の折れ目で滑らかに変わる */
  function placeCar(group, s, braking) {
    const p = pointAt(s);
    const y = elevationAt(s, curSag);
    const half = CAR_LENGTH / 2;
    const pitch = Math.atan2(elevationAt(s + half, curSag) - elevationAt(s - half, curSag), CAR_LENGTH);
    group.position.set(p.x, y, p.z);
    // Euler XYZ: ローカル Z 回り（ピッチ）→ Y 回り（ヨー）の順に適用。モデル +X を (fx, fz) に向けるには -heading
    group.rotation.set(0, -p.heading, pitch);
    setBrake(group, braking);
    return p;
  }

  function update(sim, dtReal, opts = {}) {
    const dt = Math.min(Math.max(dtReal || 0, 0), 0.25);
    // カメラ平滑化はゲーム速度でスケール（×2/×4 でも追従距離が伸びない）
    const speed = Number.isFinite(opts.speed) && opts.speed > 0 ? opts.speed : 1;
    if (opts.cameraMode) rig.setMode(opts.cameraMode);
    const cars = sim?.cars || [];
    const playerIndex = opts.playerIndex ?? sim?.playerIndex ?? 0;
    if (cars.length !== activeCount) ensurePool(cars.length);

    let playerFound = false;
    for (let i = 0; i < cars.length; i++) {
      const car = cars[i];
      if (i === playerIndex) {
        const p = placeCar(gtr, car.s, car.braking);
        pose.x = p.x; pose.y = gtr.position.y; pose.z = p.z; pose.fx = p.fx; pose.fz = p.fz;
        traffic[i].visible = false;
        // ホイールは s の増分から転がす（倍速・一時停止にそのまま追従）
        if (prevPlayerS != null) {
          const ds = wrap(car.s - prevPlayerS);
          if (ds < LENGTH / 2) for (const w of gtr.userData.wheels) w.rotation.z -= ds / WHEEL_R;
          // 1 フレームで 60 m 超のジャンプ（レベルリセット等）はカメラを補間せずスナップ
          if (Math.min(ds, LENGTH - ds) > SNAP_JUMP_M) rig.snap();
        }
        prevPlayerS = car.s;
        playerFound = true;
      } else {
        traffic[i].visible = true;
        placeCar(traffic[i], car.s, car.braking);
      }
    }
    gtr.visible = playerFound;

    // 太陽（影カメラ）をプレイヤーに追従させる
    _p.set(pose.x, pose.y, pose.z);
    sun.target.position.copy(_p);
    sun.position.copy(_p).addScaledVector(sunDir, 160);
    sun.target.updateMatrixWorld();

    // 空はカメラ中心に固定、海はゆっくり流す
    rig.update(pose, dt * speed);
    sky.position.copy(camera.position);
    textures.seaNormal.offset.x += dt * 0.010;
    textures.seaNormal.offset.y += dt * 0.006;

    if (!contextLost) renderer.render(scene, camera);
  }

  function setCameraMode(mode) { rig.setMode(mode); }
  function setTimeOfDay(name) { applyPreset(name); }

  function setSag(flag) {
    flag = !!flag;
    if (flag === curSag) return;
    curSag = flag;
    disposeObject(track);
    scene.remove(track);
    track = buildTrack(curSag, textures, lampMat);
    scene.add(track);
  }

  function setCarCount(n) {
    ensurePool(Math.max(0, n | 0));
  }

  function resize() {
    const w = canvas.clientWidth || window.innerWidth;
    const h = canvas.clientHeight || window.innerHeight;
    if (!(w > 0) || !(h > 0)) return; // 非表示・折りたたみ時の 0 サイズは無視（aspect = Infinity 防止）
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  resize();
  window.addEventListener('resize', resize);

  /** Group 配下のジオメトリ・（共有でない）マテリアルを解放 */
  function disposeObject(root) {
    root.traverse((o) => {
      o.geometry?.dispose();
      const mats = Array.isArray(o.material) ? o.material : o.material ? [o.material] : [];
      for (const m of mats) if (m !== lampMat) m.dispose();
    });
  }

  function dispose() {
    window.removeEventListener('resize', resize);
    canvas.removeEventListener('webglcontextlost', onContextLost, false);
    canvas.removeEventListener('webglcontextrestored', onContextRestored, false);
    disposeObject(track);
    disposeObject(hills);
    sea.geometry.dispose(); seaMat.dispose();
    sky.geometry.dispose(); skyMat.dispose();
    envSky.geometry.dispose(); envGround.geometry.dispose(); envGround.material.dispose();
    lampMat.dispose();
    Object.values(textures).forEach((t) => t.dispose());
    disposeEnvCache();
    pmrem.dispose();
    disposeCar(gtr);
    traffic.forEach(disposeCar);
    traffic.length = 0;
    disposeCarAssets();
    scene.clear();
    renderer.dispose();
  }

  return {
    unavailable: false,
    error: null,
    update, setCameraMode, setTimeOfDay, setSag, setCarCount, resize, dispose,
    // デバッグ・拡張用（契約外だが読み取りのみ）
    get cameraMode() { return rig.mode; },
    get contextLost() { return contextLost; },
    get renderer() { return renderer; },
    CAMERA_MODES,
  };
}
