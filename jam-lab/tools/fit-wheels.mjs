// ホイールの作り直し。生成モデルから切り出した 4 輪は幅も中心もばらばらで、フェンダーから最大 30 cm
// はみ出していた。前左（最も形が良い）を型にして 4 輪を同じ形で作り直し、車体側のフェンダー外端を
// 実測して「外面がフェンダーの 2 cm 内側」に来る位置へ置く。右側は z を反転（面の向きも反転）。
// 使い方: node tools/fit-wheels.mjs [--apply]   （assets/rx7-fd3s.glb を書き換える）
import fs from 'node:fs';
import { readGLB, readAccessor, writeGLB } from './glb.mjs';

const PATH = 'assets/rx7-fd3s.glb';
const APPLY = process.argv.includes('--apply');
const TIRE_W = 0.245;       // タイヤ幅 [m]（FD3S 標準 235〜255 相当）
const INSET = 0.02;         // フェンダー外端からタイヤ外面までの引っ込み [m]
const AXLE_X = 1.2125;      // ホイールベース 2.425 の半分

const { json, bin } = readGLB(PATH);
const meshOf = (name) => json.meshes.find((m) => m.name === name);
const prim = (m) => m.primitives[0];
const body = prim(meshOf('body'));
const BP = readAccessor(json, bin, body.attributes.POSITION);
const nb = BP.length / 3;

/** 車軸 x 付近のフェンダー外端 |z|（左右の平均）。アーチの縁は y 0.40〜0.72 にある */
function fenderOuter(ax) {
  let l = 0, r = 0;
  for (let i = 0; i < nb; i++) {
    const x = BP[i*3], y = BP[i*3+1], z = BP[i*3+2];
    if (Math.abs(x - ax) > 0.30 || y < 0.40 || y > 0.72 || Math.abs(z) < 0.5) continue;
    if (z > 0) { if (z > l) l = z; } else if (-z > r) r = -z;
  }
  return (l + r) / 2;
}
const fenderF = fenderOuter(AXLE_X), fenderR = fenderOuter(-AXLE_X);
const zF = fenderF - INSET - TIRE_W / 2, zR = fenderR - INSET - TIRE_W / 2;
console.log(`フェンダー外端: 前 ${fenderF.toFixed(3)} / 後 ${fenderR.toFixed(3)} → ホイール中心 |z|: 前 ${zF.toFixed(3)} / 後 ${zR.toFixed(3)}`);

// --- 型となる前左ホイールを取り出し、中心を原点に寄せ、幅を TIRE_W に揃える ---
const tp = prim(meshOf('wheel_FL'));
const P0 = readAccessor(json, bin, tp.attributes.POSITION), U0 = readAccessor(json, bin, tp.attributes.TEXCOORD_0);
const N0 = readAccessor(json, bin, tp.attributes.NORMAL), I0 = readAccessor(json, bin, tp.indices);
const nv = P0.length / 3;
const mn = [1e9,1e9,1e9], mx = [-1e9,-1e9,-1e9];
for (let i = 0; i < nv; i++) for (let d = 0; d < 3; d++) { const v = P0[i*3+d]; if (v < mn[d]) mn[d] = v; if (v > mx[d]) mx[d] = v; }
const cx = (mn[0]+mx[0])/2, cy = (mn[1]+mx[1])/2, cz = (mn[2]+mx[2])/2;
const width = mx[2]-mn[2], radius = (mx[1]-mn[1])/2;
const zScale = TIRE_W / width;
console.log(`型（前左）: 幅 ${width.toFixed(3)} → ${TIRE_W}（×${zScale.toFixed(2)}）、半径 ${radius.toFixed(3)}、中心 (${cx.toFixed(3)}, ${cy.toFixed(3)}, ${cz.toFixed(3)})`);
if (!APPLY) { console.log('（--apply を付けると書き込みます）'); process.exit(0); }

/** 型から 1 輪分のジオメトリを作る。mirror=true で右側（z 反転・面の向きも反転） */
function makeWheel(mirror) {
  const P = new Float32Array(nv*3), N = new Float32Array(nv*3), U = new Float32Array(U0);
  const s = mirror ? -1 : 1;
  for (let i = 0; i < nv; i++) {
    P[i*3] = P0[i*3] - cx; P[i*3+1] = P0[i*3+1] - cy; P[i*3+2] = s * (P0[i*3+2] - cz) * zScale;
    // 法線: z だけ zScale で伸縮した逆転置 → nz / zScale、その後正規化
    const nx = N0[i*3], ny = N0[i*3+1], nz = s * N0[i*3+2] / zScale;
    const len = Math.hypot(nx, ny, nz) || 1;
    N[i*3] = nx/len; N[i*3+1] = ny/len; N[i*3+2] = nz/len;
  }
  const I = new Uint32Array(I0);
  if (mirror) for (let t = 0; t < I.length; t += 3) { const a = I[t+1]; I[t+1] = I[t+2]; I[t+2] = a; }
  return { P, U, N, I };
}

// --- GLB を組み直す: body と画像は元の bufferView のバイト列をそのまま移し、ホイール 4 輪は新規 ---
const bufs = [], views = [];
let off = 0;
const addView = (b) => { views.push({ buffer: 0, byteOffset: off, byteLength: b.length }); bufs.push(b); off += b.length + ((4 - b.length % 4) % 4); return views.length - 1; };
const copyView = (idx) => { const bv = json.bufferViews[idx]; return addView(Buffer.from(bin.subarray(bv.byteOffset || 0, (bv.byteOffset || 0) + bv.byteLength))); };
const accessors = [], meshes = [], nodes = [];
// body
{
  const a = json.accessors;
  const map = {};
  // bufferView は丸ごと写すので、accessor の byteOffset と bufferView の byteStride はそのまま引き継ぐ
  // （同じ bufferView を複数の accessor が共有していても 1 回だけコピーする）
  const viewMap = new Map();
  const copyKeep = (idx) => {
    if (!viewMap.has(idx)) { const nv2 = copyView(idx); const bs = json.bufferViews[idx].byteStride; if (bs) views[nv2].byteStride = bs; viewMap.set(idx, nv2); }
    return viewMap.get(idx);
  };
  for (const [k, ai] of Object.entries(body.attributes)) { const src = a[ai]; map[k] = accessors.push({ ...src, bufferView: copyKeep(src.bufferView) }) - 1; }
  const srcI = a[body.indices];
  const ii = accessors.push({ ...srcI, bufferView: copyKeep(srcI.bufferView) }) - 1;
  meshes.push({ name: 'body', primitives: [{ mode: 4, attributes: map, indices: ii, material: 0 }] });
  nodes.push({ name: 'body', mesh: 0, translation: [0, 0, 0] });
}
const mm = (arr, n) => { const lo = new Array(n).fill(1e9), hi = new Array(n).fill(-1e9); for (let i = 0; i < arr.length; i += n) for (let d = 0; d < n; d++) { if (arr[i+d] < lo[d]) lo[d] = arr[i+d]; if (arr[i+d] > hi[d]) hi[d] = arr[i+d]; } return [lo, hi]; };
const WHEELS = [['wheel_FL', AXLE_X, zF, false], ['wheel_FR', AXLE_X, -zF, true], ['wheel_RL', -AXLE_X, zR, false], ['wheel_RR', -AXLE_X, -zR, true]];
for (const [name, x, z, mirror] of WHEELS) {
  const w = makeWheel(mirror);
  const vp = addView(Buffer.from(w.P.buffer)), vu = addView(Buffer.from(w.U.buffer)), vn = addView(Buffer.from(w.N.buffer)), vi = addView(Buffer.from(w.I.buffer));
  const [lo, hi] = mm(w.P, 3);
  const a0 = accessors.length;
  accessors.push({ bufferView: vp, componentType: 5126, count: nv, type: 'VEC3', min: lo, max: hi });
  accessors.push({ bufferView: vu, componentType: 5126, count: nv, type: 'VEC2' });
  accessors.push({ bufferView: vn, componentType: 5126, count: nv, type: 'VEC3' });
  accessors.push({ bufferView: vi, componentType: 5125, count: w.I.length, type: 'SCALAR' });
  meshes.push({ name, primitives: [{ mode: 4, attributes: { POSITION: a0, TEXCOORD_0: a0+1, NORMAL: a0+2 }, indices: a0+3, material: 0 }] });
  nodes.push({ name, mesh: meshes.length - 1, translation: [x, radius, z] });
}
// 埋め込み画像は bufferView を写し替え、それ以外（uri / name / extras 等）は保持する
const images = json.images.map((im) => (im.bufferView != null ? { ...im, bufferView: copyView(im.bufferView) } : { ...im }));
const out = { asset: json.asset, scene: 0, scenes: [{ nodes: nodes.map((_, i) => i) }], nodes, meshes, accessors, bufferViews: views,
  samplers: json.samplers, images, textures: json.textures, materials: json.materials };
const bytes = writeGLB(PATH, out, bufs);
console.log(`書き戻し完了 ${PATH} ${(bytes/1e6).toFixed(2)}MB / ホイール位置: 前 z=±${zF.toFixed(3)} 後 z=±${zR.toFixed(3)} y=${radius.toFixed(3)}`);
