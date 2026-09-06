// 車のプロシージャル生成キット（共通部分）。
// 規約: 進行方向 = +X、Y が上、+Z = 進行方向の右手、原点 = 車体中心直下の地面。
// 内容: 共有マテリアル / パーツ結合 / 押し出し・回転体ユーティリティ / 断面ロフト（loftHull, hullBands）/
//       一般車（簡易セダン）/ ブレーキランプ切替 / リソース解放。
// プレイヤー車（RX-7 FD3S）は rx7.js が本モジュールを使って組み立てる。
import * as THREE from '../../vendor/three.module.js';

/** 一般車の塗色（落ち着いた 5 色: 白 / シルバー / ダークグレー / ダークレッド / ネイビー） */
export const CAR_COLORS = [0xe4e4df, 0xb4b8be, 0x45484d, 0x6b1d20, 0x1e2946];

// ---------------------------------------------------------------------------
// マテリアル（車間で共有できるものはモジュール内で 1 つだけ作る）
// ---------------------------------------------------------------------------
const shared = {};
export function sharedMaterials() {
  if (shared.dark) return shared;
  const std = (o) => new THREE.MeshStandardMaterial(o);
  shared.dark = std({ color: 0x15171a, roughness: 0.85, metalness: 0.1 });      // 樹脂・トリム
  shared.black = std({ color: 0x050607, roughness: 0.95 });                     // 開口部の奥・ホイールハウス
  shared.tire = std({ color: 0x14151a, roughness: 0.95 });
  shared.rim = std({ color: 0x8d9198, roughness: 0.32, metalness: 0.85 });      // ガンメタリック
  shared.chrome = std({ color: 0xf2f2f2, roughness: 0.15, metalness: 1.0 });
  shared.steel = std({ color: 0x6f7378, roughness: 0.5, metalness: 0.9 });      // ブレーキディスク・インタークーラー
  shared.carbon = std({ color: 0x2a2c30, roughness: 0.5, metalness: 0.3 });     // ウィングブレード
  shared.caliper = std({ color: 0xc9a23c, roughness: 0.35, metalness: 0.7 });   // ゴールドキャリパー
  shared.plate = std({ color: 0xe6e6e2, roughness: 0.6 });                      // 無地のナンバープレート
  shared.amber = std({ color: 0xd9861c, emissive: 0xff9a20, emissiveIntensity: 0.35, roughness: 0.4 }); // ウインカー
  shared.head = std({ color: 0xe6eef6, emissive: 0xc8dcf0, emissiveIntensity: 0.35, roughness: 0.2, metalness: 0.3 });
  shared.glass = new THREE.MeshPhysicalMaterial({
    color: 0x0a0c10, roughness: 0.05, metalness: 0.0, transparent: true, opacity: 0.92,
  });
  shared.lampGlass = new THREE.MeshPhysicalMaterial({
    color: 0xbcd4f0, roughness: 0.05, metalness: 0.0, transparent: true, opacity: 0.35, depthWrite: false,
  });
  shared.paints = new Map(); // 一般車の色ごとに 1 つ
  return shared;
}

function trafficPaint(colorHex) {
  const s = sharedMaterials();
  if (!s.paints.has(colorHex)) {
    s.paints.set(colorHex, new THREE.MeshStandardMaterial({ color: colorHex, roughness: 0.4, metalness: 0.45 }));
  }
  return s.paints.get(colorHex);
}

/** テールランプ材（ブレーキで emissive を切り替えるので 1 台に 1 つ） */
export function makeTailMaterial() {
  return new THREE.MeshStandardMaterial({
    color: 0x5a0a0a, emissive: 0xff2a14, emissiveIntensity: 0.3, roughness: 0.3, metalness: 0.1,
  });
}
/** テールランプ中心の発光部（プレイヤー車のみ。レンズより明るく光る） */
export function makeTailInnerMaterial() {
  return new THREE.MeshStandardMaterial({
    color: 0x7a1010, emissive: 0xff3a1a, emissiveIntensity: 0.9, roughness: 0.4, metalness: 0.0,
  });
}

// ---------------------------------------------------------------------------
// 幾何ユーティリティ
// ---------------------------------------------------------------------------
/** パーツ記述子。geometry を position / rotation(Euler XYZ) で配置してマージする */
export function part(geometry, position = [0, 0, 0], rotation = [0, 0, 0]) {
  return { geometry, position, rotation };
}

const _m4 = new THREE.Matrix4();
const _q = new THREE.Quaternion();
const _e = new THREE.Euler();
const _v = new THREE.Vector3();
const _one = new THREE.Vector3(1, 1, 1);

/** 複数パーツを非インデックスの 1 ジオメトリに結合（examples の BufferGeometryUtils 非依存） */
export function mergeParts(parts) {
  const chunks = parts.map(({ geometry, position, rotation }) => {
    const g = geometry.index ? geometry.toNonIndexed() : geometry.clone();
    geometry.dispose();
    if (!g.attributes.uv) {
      g.setAttribute('uv', new THREE.BufferAttribute(new Float32Array(g.attributes.position.count * 2), 2));
    }
    _m4.compose(_v.set(...position), _q.setFromEuler(_e.set(...rotation)), _one);
    g.applyMatrix4(_m4); // 法線も正しく変換される
    return g;
  });
  let n = 0;
  for (const g of chunks) n += g.attributes.position.count;
  const pos = new Float32Array(n * 3);
  const nor = new Float32Array(n * 3);
  const uv = new Float32Array(n * 2);
  let o = 0;
  for (const g of chunks) {
    pos.set(g.attributes.position.array, o * 3);
    nor.set(g.attributes.normal.array, o * 3);
    uv.set(g.attributes.uv.array, o * 2);
    o += g.attributes.position.count;
    g.dispose();
  }
  const out = new THREE.BufferGeometry();
  out.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  out.setAttribute('normal', new THREE.BufferAttribute(nor, 3));
  out.setAttribute('uv', new THREE.BufferAttribute(uv, 2));
  out.computeBoundingSphere();
  return out;
}

export function shapeFrom(points, holes = []) {
  const shape = new THREE.Shape();
  points.forEach(([x, y], i) => (i === 0 ? shape.moveTo(x, y) : shape.lineTo(x, y)));
  shape.closePath();
  for (const h of holes) {
    const p = new THREE.Path();
    h.forEach(([x, y], i) => (i === 0 ? p.moveTo(x, y) : p.lineTo(x, y)));
    p.closePath();
    shape.holes.push(p);
  }
  return shape;
}

/**
 * XY 平面のプロファイルを Z 方向に押し出し、Z 中心に寄せる（全幅 = width）。
 * bevelOffset = -bevel にすることで、中央断面が描いた輪郭そのもの、両端面が bevel 分だけ内側に
 * 丸まる（輪郭が外へ膨らまないので寸法がそのまま使える）。
 */
export function profileExtrude(points, width, bevel = 0.04, segments = 3, holes = []) {
  const depth = Math.max(0.01, width - 2 * bevel);
  const g = new THREE.ExtrudeGeometry(shapeFrom(points, holes), {
    depth, steps: 1, bevelEnabled: bevel > 0,
    bevelThickness: bevel, bevelSize: bevel, bevelOffset: -bevel, bevelSegments: segments,
  });
  g.translate(0, 0, -depth / 2);
  return g;
}

/** 薄い板の押し出し（ベベル無し・Z 中心） */
export function slabExtrude(points, thickness) {
  const g = new THREE.ExtrudeGeometry(shapeFrom(points), { depth: thickness, bevelEnabled: false });
  g.translate(0, 0, -thickness / 2);
  return g;
}

/** 円弧点列（中心 (cx,cy)・半径 r・角 a0→a1、n 分割） */
export function arcPoints(cx, cy, r, a0, a1, n) {
  const out = [];
  for (let i = 0; i <= n; i++) {
    const a = a0 + ((a1 - a0) * i) / n;
    out.push([cx + r * Math.cos(a), cy + r * Math.sin(a)]);
  }
  return out;
}

export const box = (w, h, d) => new THREE.BoxGeometry(w, h, d);
/** 軸が X 方向の円柱（ランプ・マフラー用） */
export const cylX = (r, len, seg = 18) => new THREE.CylinderGeometry(r, r, len, seg).rotateZ(Math.PI / 2);
/** 軸が Z 方向の円柱（ホイール用） */
export const cylZ = (r, len, seg = 16) => new THREE.CylinderGeometry(r, r, len, seg).rotateX(Math.PI / 2);
/** 軸が X 方向のトーラス（ランプのベゼル） */
export const torusX = (R, tube, seg = 24) => new THREE.TorusGeometry(R, tube, 5, seg).rotateY(Math.PI / 2);

/**
 * 回転体（軸 = Z）。pts は [半径, z] の列で z が増える向きに並べる（法線が外向きになる）。
 * outerSign < 0 のときは Z を反転して鏡像にする（向きも保つ）。
 */
export function latheZ(pts, seg, outerSign = 1) {
  let p = pts.map(([r, z]) => new THREE.Vector2(r, z * outerSign));
  if (outerSign < 0) p = p.reverse();
  return new THREE.LatheGeometry(p, seg).rotateX(Math.PI / 2);
}

export function mesh(geometry, material, name, shadow = true) {
  const m = new THREE.Mesh(geometry, material);
  m.name = name;
  m.castShadow = shadow;
  return m;
}

// ---------------------------------------------------------------------------
// プレイヤー車の寸法は rx7.js 側で定義する
// ---------------------------------------------------------------------------
/** 面の 2 点 (a→b) に貼る板の配置（中心・回転）。板のローカル +X が外向き法線 */
export function paneOn(a, b, proud) {
  const dx = b[0] - a[0], dy = b[1] - a[1];
  const len = Math.hypot(dx, dy);
  const nx = dy / len, ny = -dx / len; // a→b を時計回りに 90° 回した法線
  const cx = (a[0] + b[0]) / 2 + nx * proud, cy = (a[1] + b[1]) / 2 + ny * proud;
  return { center: [cx, cy], angle: Math.atan2(ny, nx), length: len };
}


// ---------------------------------------------------------------------------
// 断面ロフト: 前後方向に並べた断面（右半分の制御点列）をスプラインで繋いで滑らかな一体ハルを作る
// ---------------------------------------------------------------------------
/** 一様パラメータの Catmull-Rom（端はクランプ）。vals[i] は制御点、u は [0, n-1] */
export function catmull(vals, u) {
  const n = vals.length;
  const i1 = Math.min(n - 2, Math.max(0, Math.floor(u)));
  const t = Math.min(1, Math.max(0, u - i1));
  const p0 = vals[Math.max(0, i1 - 1)], p1 = vals[i1], p2 = vals[i1 + 1], p3 = vals[Math.min(n - 1, i1 + 2)];
  const t2 = t * t, t3 = t2 * t;
  return 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3);
}

/**
 * 断面 stations: [{ x, pts: [[y, z], ...K 点] }]。pts は右半分（z >= 0）を「上面中央 → 側面 → 床中央」の順に並べ、
 * 先頭と末尾は z = 0（中心線上）。各断面は同じ点数 K で、同じ意味の点が同じ添字に来る（点ごとに X 方向へ補間する）。
 * 断面内は閉じた一様 Catmull-Rom で nRing 点に補間し、X 方向は nX 区間に補間。両端は扇形で蓋をする。
 * creaseIndex を指定すると、その添字の点で断面スプラインを鋭くする（制御点を二重化）。
 * 戻り値 { geometry, rings, nRing, nCtrl, ctrlIndex(k, side) }:
 *   ctrlIndex は制御点 k（右 side=+1 / 左 side=-1）が閉曲線上で何番目かを返す。輪郭上の標本 j は
 *   制御点座標 c = j * nCtrl / nRing に対応する（一様パラメータなので）。ガラス帯の切り出しに使う。
 */
export function loftHull(stations, { nX = 72, nRing = 56, creaseIndex = -1 } = {}) {
  const K = stations[0].pts.length;
  const xs = stations.map((s) => s.x);
  const ys = Array.from({ length: K }, (_, k) => stations.map((s) => s.pts[k][0]));
  const zs = Array.from({ length: K }, (_, k) => stations.map((s) => s.pts[k][1]));
  const hasCrease = creaseIndex > 0 && creaseIndex < K - 1;
  const nCtrl = 2 * (K - 1) + (hasCrease ? 2 : 0);
  const ctrlIndex = (k, side = 1) => {
    if (side > 0) return k + (hasCrease && k > creaseIndex ? 1 : 0);
    if (k === 0) return 0;
    if (k === K - 1) return K - 1 + (hasCrease ? 1 : 0);
    return nCtrl - k - (hasCrease && k > creaseIndex ? 1 : 0);
  };
  const rings = [];
  for (let i = 0; i <= nX; i++) {
    const u = (i / nX) * (stations.length - 1);
    const x = catmull(xs, u);
    const ctrl = [];
    for (let k = 0; k < K; k++) {
      const y = catmull(ys[k], u), z = Math.max(0, catmull(zs[k], u));
      ctrl.push(new THREE.Vector3(x, y, z));
      if (hasCrease && k === creaseIndex) ctrl.push(new THREE.Vector3(x, y - 0.004, z));
    }
    for (let k = K - 2; k >= 1; k--) {
      const y = catmull(ys[k], u), z = Math.max(0, catmull(zs[k], u));
      if (hasCrease && k === creaseIndex) ctrl.push(new THREE.Vector3(x, y - 0.004, -z));
      ctrl.push(new THREE.Vector3(x, y, -z));
    }
    const curve = new THREE.CatmullRomCurve3(ctrl, true, 'catmullrom', 0.5);
    rings.push(curve.getPoints(nRing).slice(0, nRing));
  }
  const pos = [];
  for (const ring of rings) for (const p of ring) pos.push(p.x, p.y, p.z);
  const idx = [];
  const at = (i, j) => i * nRing + (j % nRing);
  for (let i = 0; i < nX; i++) {
    for (let j = 0; j < nRing; j++) {
      const a = at(i, j), b = at(i + 1, j), c = at(i + 1, j + 1), d = at(i, j + 1);
      idx.push(a, b, c, a, c, d);
    }
  }
  const capCenter = (ring) => {
    const c = new THREE.Vector3();
    for (const p of ring) c.add(p);
    return c.multiplyScalar(1 / ring.length);
  };
  for (const [ri, front] of [[0, true], [nX, false]]) {
    const c = capCenter(rings[ri]);
    const ci = pos.length / 3;
    pos.push(c.x, c.y, c.z);
    for (let j = 0; j < nRing; j++) {
      const a = at(ri, j), b = at(ri, j + 1);
      if (front) idx.push(ci, b, a); else idx.push(ci, a, b);
    }
  }
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
  geometry.setIndex(idx);
  geometry.computeVertexNormals();
  return { geometry, rings, nRing, nCtrl, ctrlIndex };
}

/**
 * ハル表面の帯を切り出して法線方向に offset だけ浮かせた面を作る（ガラス用）。
 * bands: [{ c: [c0, c1], x: [xMin, xMax] }] — c は制御点座標（閉曲線上の位置、ctrlIndex で得る）、x は車体座標の範囲。
 * 4 頂点すべてが帯に入る四角形だけを出力する。
 */
export function hullBands(hull, bands, offset = 0.006) {
  const { geometry, rings, nRing, nCtrl } = hull;
  const nrm = geometry.attributes.normal;
  const inBand = (i, j) => {
    const p = rings[i][j % nRing];
    const c = ((j % nRing) * nCtrl) / nRing;
    return bands.some((b) => c >= b.c[0] && c <= b.c[1] && p.x >= b.x[0] && p.x <= b.x[1]);
  };
  const pos = [];
  const push = (i, j) => {
    const vi = i * nRing + (j % nRing);
    const p = rings[i][j % nRing];
    pos.push(p.x + nrm.getX(vi) * offset, p.y + nrm.getY(vi) * offset, p.z + nrm.getZ(vi) * offset);
  };
  for (let i = 0; i < rings.length - 1; i++) {
    for (let j = 0; j < nRing; j++) {
      if (!(inBand(i, j) && inBand(i + 1, j) && inBand(i + 1, j + 1) && inBand(i, j + 1))) continue;
      push(i, j); push(i + 1, j); push(i + 1, j + 1);
      push(i, j); push(i + 1, j + 1); push(i, j + 1);
    }
  }
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
  g.computeVertexNormals();
  return g;
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// 一般車（簡易セダン）。ジオメトリは全車で共有し、色ごとの塗装材とテール材だけ個別
// ---------------------------------------------------------------------------
let trafficGeo = null;
function trafficGeometries() {
  if (trafficGeo) return trafficGeo;
  const WB = 2.70, TRACK = 1.46, R = 0.31;
  const paint = mergeParts([
    part(profileExtrude([
      [2.22, 0.30], [2.22, 0.62], [2.05, 0.74], [0.75, 0.86],
      [-1.30, 0.90], [-2.18, 0.86], [-2.22, 0.72], [-2.22, 0.30],
    ], 1.70)),
    part(box(1.00, 0.03, 1.40), [-0.42, 1.385, 0]),          // ルーフ
    part(box(0.09, 0.07, 0.20), [0.50, 0.98, 0.92]),         // ミラー
    part(box(0.09, 0.07, 0.20), [0.50, 0.98, -0.92]),
  ]);
  const darkParts = [
    part(profileExtrude([[0.75, 0.88], [0.10, 1.34], [-0.95, 1.36], [-1.35, 0.92]], 1.50, 0.02)), // ガラス帯
    part(box(0.04, 0.16, 1.00), [2.24, 0.42, 0]),           // バンパー開口
    part(box(2.60, 0.08, 1.72), [0, 0.26, 0]),               // サイドスカート
    part(box(0.04, 0.12, 1.66), [-2.24, 0.34, 0]),           // リアバンパー下部
  ];
  const rimParts = [];
  for (const sx of [1, -1]) {
    for (const sz of [1, -1]) {
      darkParts.push(part(cylZ(R, 0.20, 14), [sx * WB / 2, R, sz * TRACK / 2]));
      rimParts.push(part(cylZ(0.19, 0.22, 10), [sx * WB / 2, R, sz * TRACK / 2]));
    }
  }
  const tail = mergeParts([
    part(box(0.03, 0.10, 0.40), [-2.24, 0.70, 0.55]),
    part(box(0.03, 0.10, 0.40), [-2.24, 0.70, -0.55]),
  ]);
  const head = mergeParts([
    part(box(0.04, 0.12, 0.40), [2.22, 0.66, 0.55]),
    part(box(0.04, 0.12, 0.40), [2.22, 0.66, -0.55]),
  ]);
  trafficGeo = { paint, dark: mergeParts(darkParts), rim: mergeParts(rimParts), tail, head };
  return trafficGeo;
}

/** 一般車を生成（プレイヤー車と同じ向き・寸法規約、テール 2 灯）。userData.kind = 'traffic' */
export function createTrafficCar(colorHex = CAR_COLORS[0]) {
  const s = sharedMaterials();
  const g = trafficGeometries();
  const tail = makeTailMaterial();
  const group = new THREE.Group();
  group.name = 'traffic';
  group.add(mesh(g.paint, trafficPaint(colorHex), 'paint'));
  group.add(mesh(g.dark, s.dark, 'dark'));
  group.add(mesh(g.rim, s.rim, 'rim', false));
  group.add(mesh(g.tail, tail, 'tail', false));
  group.add(mesh(g.head, s.head, 'head', false));
  group.userData = { kind: 'traffic', tailMaterial: tail, brakeOn: false };
  return group;
}

/** ブレーキランプ切替（プレイヤー車は 4 灯すべて、一般車は 2 灯）。変化がなければ何もしない */
export function setBrake(group, on) {
  const u = group.userData;
  on = !!on;
  if (!u || !u.tailMaterial || u.brakeOn === on) return;
  u.brakeOn = on;
  // 発光強度は車ごとに変えられる（GLB のプレイヤー車はテールだけを光らせる emissiveMap を使うため強め）
  const lv = u.emissiveLevels || { idle: 0.3, brake: 2.0, innerIdle: 0.9, innerBrake: 3.5 };
  u.tailMaterial.emissiveIntensity = on ? lv.brake : lv.idle;
  if (u.tailMaterials) for (const m of u.tailMaterials) if (m !== u.tailMaterial) m.emissiveIntensity = on ? (lv.innerBrake ?? lv.brake) : (lv.innerIdle ?? lv.idle);
}

/** 1 台分の個別リソース（テール材・プレイヤー車の塗装材 / 追加材と専用ジオメトリ）を解放 */
export function disposeCar(group) {
  const u = group.userData || {};
  u.tailMaterial?.dispose();
  u.tailMaterials?.forEach((m) => m.dispose());
  u.paintMaterial?.dispose();
  u.extraMaterials?.forEach((m) => m.dispose());
  // sharedGeometry: GLB から複製した車は元のジオメトリを共有しているので解放しない
  if (u.kind !== 'traffic' && !u.sharedGeometry) group.traverse((o) => o.geometry?.dispose());
  group.removeFromParent();
}

/** 共有マテリアル・一般車の共有ジオメトリを解放（シーン破棄時に 1 回） */
export function disposeCarAssets() {
  if (trafficGeo) {
    Object.values(trafficGeo).forEach((g) => g.dispose());
    trafficGeo = null;
  }
  if (shared.dark) {
    for (const v of Object.values(shared)) if (v && typeof v.dispose === 'function') v.dispose();
    shared.paints.forEach((m) => m.dispose());
    for (const k of Object.keys(shared)) delete shared[k];
  }
}
