// テール発光テクスチャ生成（2048）。尾端の灯火帯にある三角形の UV 領域のうち、赤い画素だけを残す
import fs from 'node:fs';
import { readGLB, readAccessor } from './glb.mjs';
const { json, bin } = readGLB('rx7-aligned.glb');
const prim = json.meshes[0].primitives[0];
const POS = readAccessor(json, bin, prim.attributes.POSITION);
const UV = readAccessor(json, bin, prim.attributes.TEXCOORD_0);
const IDX = readAccessor(json, bin, prim.indices);
const nt = IDX.length / 3;
const bmp = fs.readFileSync('mask2048.bmp');
const off = bmp.readUInt32LE(10), S = 2048, row = ((24*S+31)>>5)<<2;
const at = (x,y) => off + y*row + x*3;
const isRed = (p) => { const r = bmp[p+2], g = bmp[p+1], b = bmp[p]; return r > 80 && r > g*1.35 && r > b*1.35; };
const toPix = (u,v) => [Math.min(S-1,Math.max(0,Math.floor(((u%1)+1)%1*S))), Math.min(S-1,Math.max(0,Math.floor((1-((v%1)+1)%1)*S)))];

const mask = new Uint8Array(S*S);
let lampTris = 0;
const Y0 = 0.80, Y1 = 1.00, X0 = -2.02;   // 尾端の灯火帯
for (let t = 0; t < nt; t++) {
  let cx=0, cy=0;
  for (let k=0;k<3;k++){ const v=IDX[t*3+k]; cx+=POS[v*3]/3; cy+=POS[v*3+1]/3; }
  if (cx > X0 || cy < Y0 || cy > Y1) continue;
  const P = [0,1,2].map(k => toPix(UV[IDX[t*3+k]*2], UV[IDX[t*3+k]*2+1]));
  const x0 = Math.max(0, Math.min(...P.map(p=>p[0]))), x1 = Math.min(S-1, Math.max(...P.map(p=>p[0])));
  const y0 = Math.max(0, Math.min(...P.map(p=>p[1]))), y1 = Math.min(S-1, Math.max(...P.map(p=>p[1])));
  if (x1-x0 > 300 || y1-y0 > 300) continue;
  let hit = false;
  for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) { const p = at(x,y); if (isRed(p)) { mask[y*S+x] = 1; hit = true; } }
  if (hit) lampTris++;
}
let n = 0; for (let i = 0; i < mask.length; i++) n += mask[i];
console.log('lamp tris', lampTris, 'mask px', n);
// 3 px 膨張（JPEG 圧縮でにじんでも欠けないように）
const grow = new Uint8Array(mask);
for (let it = 0; it < 3; it++) {
  const src = new Uint8Array(grow);
  for (let y = 1; y < S-1; y++) for (let x = 1; x < S-1; x++) {
    if (src[y*S+x]) continue;
    if (src[(y-1)*S+x] || src[(y+1)*S+x] || src[y*S+x-1] || src[y*S+x+1]) grow[y*S+x] = 1;
  }
}
let n2 = 0; for (let i = 0; i < grow.length; i++) n2 += grow[i];
console.log('after grow', n2);
const out = Buffer.from(bmp);
for (let y = 0; y < S; y++) for (let x = 0; x < S; x++) {
  const p = at(x,y);
  if (!grow[y*S+x]) { out[p] = out[p+1] = out[p+2] = 0; }
}
fs.writeFileSync('emissive2048.bmp', out);
console.log('wrote emissive2048.bmp');
