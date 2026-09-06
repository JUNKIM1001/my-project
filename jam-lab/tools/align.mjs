// car0 を「前方 = +X / 上 = +Y / 原点 = 車体中心の接地点 / 実寸」に整列して書き出す
import fs from 'node:fs';
import { readGLB, readAccessor, writeGLB } from './glb.mjs';

const { json, bin } = readGLB('car0.glb');
const prim = json.meshes[0].primitives[0];
const pos = new Float32Array(readAccessor(json, bin, prim.attributes.POSITION));
const uv  = new Float32Array(readAccessor(json, bin, prim.attributes.TEXCOORD_0));
const nor = new Float32Array(readAccessor(json, bin, prim.attributes.NORMAL));
const idx = new Uint32Array(readAccessor(json, bin, prim.indices));

// ホイール中心（analyze0 の結果）: 前軸の左右 A/B と、後輪 C
const A = [0.3507, 0.0990], B = [0.1892, 0.0165], C = [0.3170, -0.2426];
const ax = [(A[0]+B[0])/2, (A[1]+B[1])/2];                 // 前軸中心
const dir = [A[0]-B[0], A[1]-B[1]];                        // 車軸方向
const dl = Math.hypot(...dir); const u = [dir[0]/dl, dir[1]/dl];
const nrm = [-u[1], u[0]];                                 // 軸に直交 = 前後方向
const toC = [C[0]-ax[0], C[1]-ax[1]];
let along = toC[0]*nrm[0] + toC[1]*nrm[1];                 // 後輪は前軸から見て後ろ
const fwd = along < 0 ? nrm : [-nrm[0], -nrm[1]];          // 前方向（後輪 → 前軸）
const wheelbase = Math.abs(along);
const track = dl;
const rearAxleCenter = [ax[0] + (along < 0 ? -1 : 1) * wheelbase * -fwd[0] * -1, 0]; // 使わない
const theta = Math.atan2(fwd[1], fwd[0]);                  // Y 回転でこの角を +X に向ける
console.log('wheelbase(raw)', wheelbase.toFixed(4), 'track(raw)', track.toFixed(4), 'ratio', (track/wheelbase).toFixed(3), 'yaw(deg)', (theta*180/Math.PI).toFixed(1));

const REAL_WHEELBASE = 2.425;                              // FD3S 実寸 [m]
const scale = REAL_WHEELBASE / wheelbase;
const c = Math.cos(theta), s = Math.sin(theta);
// 回転（Y 軸）: x' = c*x + s*z, z' = -s*x + c*z
const nv = pos.length / 3;
let minY = Infinity, minX = Infinity, maxX = -Infinity, minZ = Infinity, maxZ = -Infinity;
for (let i = 0; i < nv; i++) {
  const x = pos[i*3], y = pos[i*3+1], z = pos[i*3+2];
  const X = (c*x + s*z) * scale, Y = y * scale, Z = (-s*x + c*z) * scale;
  pos[i*3] = X; pos[i*3+1] = Y; pos[i*3+2] = Z;
  const nx = nor[i*3], ny = nor[i*3+1], nz = nor[i*3+2];
  nor[i*3] = c*nx + s*nz; nor[i*3+1] = ny; nor[i*3+2] = -s*nx + c*nz;
  if (Y < minY) minY = Y; if (X < minX) minX = X; if (X > maxX) maxX = X;
  if (Z < minZ) minZ = Z; if (Z > maxZ) maxZ = Z;
}
// 原点: X/Z はホイールベース中心、Y は接地
const axR = [(c*ax[0] + s*ax[1]) * scale, (-s*ax[0] + c*ax[1]) * scale];
const cRear = [(c*C[0] + s*C[1]) * scale, (-s*C[0] + c*C[1]) * scale];
const ox = (axR[0] + cRear[0]) / 2, oz = axR[1];  // Z は前軸の中心（左右対称の中心）
let minY2 = Infinity, maxY2 = -Infinity;
for (let i = 0; i < nv; i++) { pos[i*3] -= ox; pos[i*3+1] -= minY; pos[i*3+2] -= oz;
  if (pos[i*3+1] < minY2) minY2 = pos[i*3+1]; if (pos[i*3+1] > maxY2) maxY2 = pos[i*3+1]; }
let bx=[1e9,-1e9], bz=[1e9,-1e9];
for (let i = 0; i < nv; i++) { const X=pos[i*3],Z=pos[i*3+2];
  if(X<bx[0])bx[0]=X; if(X>bx[1])bx[1]=X; if(Z<bz[0])bz[0]=Z; if(Z>bz[1])bz[1]=Z; }
console.log('after: length(X)', (bx[1]-bx[0]).toFixed(3), 'width(Z)', (bz[1]-bz[0]).toFixed(3), 'height(Y)', maxY2.toFixed(3),
  'X range', bx.map(v=>v.toFixed(3)), 'Z range', bz.map(v=>v.toFixed(3)));

// 書き出し（テクスチャはそのままコピー）
const imgBufs = json.images.map((im) => { const bv = json.bufferViews[im.bufferView];
  return Buffer.from(bin.subarray(bv.byteOffset||0, (bv.byteOffset||0)+bv.byteLength)); });
console.log('images bytes', imgBufs.map(b=>(b.length/1e6).toFixed(2)+'MB').join(' '));
const bufs = [Buffer.from(pos.buffer), Buffer.from(uv.buffer), Buffer.from(nor.buffer), Buffer.from(idx.buffer), ...imgBufs];
let off = 0; const views = [];
for (const b of bufs) { views.push({ buffer: 0, byteOffset: off, byteLength: b.length }); off += b.length + ((4 - b.length % 4) % 4); }
const mm = (a, n) => { const mn = new Array(n).fill(1e9), mx = new Array(n).fill(-1e9);
  for (let i = 0; i < a.length; i += n) for (let d = 0; d < n; d++) { mn[d] = Math.min(mn[d], a[i+d]); mx[d] = Math.max(mx[d], a[i+d]); } return [mn, mx]; };
const [pmin, pmax] = mm(pos, 3);
const out = { asset: { version: '2.0', generator: 'jam-lab align' }, scene: 0, scenes: [{ nodes: [0] }], nodes: [{ mesh: 0 }],
  meshes: [{ primitives: [{ mode: 4, attributes: { POSITION: 0, TEXCOORD_0: 1, NORMAL: 2 }, indices: 3, material: 0 }] }],
  accessors: [
    { bufferView: 0, componentType: 5126, count: nv, type: 'VEC3', min: pmin, max: pmax },
    { bufferView: 1, componentType: 5126, count: uv.length/2, type: 'VEC2' },
    { bufferView: 2, componentType: 5126, count: nv, type: 'VEC3' },
    { bufferView: 3, componentType: 5125, count: idx.length, type: 'SCALAR' }],
  bufferViews: views, materials: json.materials, textures: json.textures,
  images: [{ mimeType: 'image/jpeg', bufferView: 4 }, { mimeType: 'image/jpeg', bufferView: 5 }] };
const bytes = writeGLB('rx7-aligned.glb', out, bufs);
console.log('wrote rx7-aligned.glb', (bytes/1e6).toFixed(1)+'MB');
