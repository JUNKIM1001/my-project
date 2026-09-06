// rx7-aligned.glb → ゲーム用 GLB（ホイール分離・頂点クラスタリングで軽量化・テール発光テクスチャ）
import fs from 'node:fs';
import { readGLB, readAccessor, writeGLB } from './glb.mjs';

const { json, bin } = readGLB('rx7-aligned.glb');
const prim = json.meshes[0].primitives[0];
const POS = readAccessor(json, bin, prim.attributes.POSITION);
const UV  = readAccessor(json, bin, prim.attributes.TEXCOORD_0);
const NOR = readAccessor(json, bin, prim.attributes.NORMAL);
const IDX = readAccessor(json, bin, prim.indices);
const nt = IDX.length / 3;

const HUB = 2.425 / 2, TRACK = 1.5226, RY = 0.315;
const WHEELS = [
  { name: 'wheel_FL', x: HUB, z: TRACK / 2 }, { name: 'wheel_FR', x: HUB, z: -TRACK / 2 },
  { name: 'wheel_RL', x: -HUB, z: TRACK / 2 }, { name: 'wheel_RR', x: -HUB, z: -TRACK / 2 },
];
const R_CUT = Number(process.env.R_CUT || 0.325), Z_HALF = Number(process.env.Z_HALF || 0.21);

// --- 三角形の振り分け ---
const groupOf = new Int8Array(nt).fill(-1); // -1: body, 0..3: wheel
const cen = new Float32Array(nt * 3);
for (let t = 0; t < nt; t++) {
  let cx = 0, cy = 0, cz = 0;
  for (let k = 0; k < 3; k++) { const v = IDX[t*3+k]; cx += POS[v*3]/3; cy += POS[v*3+1]/3; cz += POS[v*3+2]/3; }
  cen[t*3] = cx; cen[t*3+1] = cy; cen[t*3+2] = cz;
  for (let w = 0; w < 4; w++) {
    const W = WHEELS[w];
    if (Math.abs(cz - W.z) < Z_HALF && Math.hypot(cx - W.x, cy - RY) < R_CUT) { groupOf[t] = w; break; }
  }
}
const counts = [0,0,0,0,0];
for (let t = 0; t < nt; t++) counts[groupOf[t] < 0 ? 4 : groupOf[t]]++;
console.log('tris: wheels', counts.slice(0,4).join('/'), 'body', counts[4]);

// --- 頂点クラスタリングによる簡略化 ---
function build(tris, origin, cell, uvq) {
  // 位置セル単位で代表位置を決め、UV セルはクラスタだけ分ける。
  // （位置をクラスタごとに平均すると UV 継ぎ目で位置がずれて隙間が開くため）
  const cellSum = new Map();   // 位置セル → {x,y,z,n}
  const cellKey = (v) => {
    const x = POS[v*3] - origin[0], y = POS[v*3+1] - origin[1], z = POS[v*3+2] - origin[2];
    return `${Math.round(x/cell)},${Math.round(y/cell)},${Math.round(z/cell)}`;
  };
  for (const t of tris) for (let k = 0; k < 3; k++) {
    const v = IDX[t*3+k], ck = cellKey(v);
    let c = cellSum.get(ck);
    if (!c) { c = { x: 0, y: 0, z: 0, n: 0 }; cellSum.set(ck, c); }
    c.x += POS[v*3] - origin[0]; c.y += POS[v*3+1] - origin[1]; c.z += POS[v*3+2] - origin[2]; c.n++;
  }
  const map = new Map(), P = [], U = [], N = [], W = [], ids = [];
  for (const t of tris) {
    const tri = [];
    for (let k = 0; k < 3; k++) {
      const v = IDX[t*3+k], ck = cellKey(v);
      const kk = `${ck}|${Math.round(UV[v*2]*uvq)},${Math.round(UV[v*2+1]*uvq)}`;
      let ni = map.get(kk);
      if (ni === undefined) {
        ni = W.length; map.set(kk, ni);
        const c = cellSum.get(ck);
        P.push(c.x / c.n, c.y / c.n, c.z / c.n);   // 位置はセル代表（クラスタ間で共通）
        U.push(UV[v*2], UV[v*2+1]); N.push(NOR[v*3], NOR[v*3+1], NOR[v*3+2]); W.push(1);
      } else {
        U[ni*2] += UV[v*2]; U[ni*2+1] += UV[v*2+1];
        N[ni*3] += NOR[v*3]; N[ni*3+1] += NOR[v*3+1]; N[ni*3+2] += NOR[v*3+2]; W[ni]++;
      }
      tri.push(ni);
    }
    if (tri[0] !== tri[1] && tri[1] !== tri[2] && tri[0] !== tri[2]) ids.push(...tri);
  }
  const nv = W.length;
  const Pa = new Float32Array(P), Ua = new Float32Array(nv*2), Na = new Float32Array(nv*3);
  for (let i = 0; i < nv; i++) {
    const w = W[i];
    Ua[i*2] = U[i*2]/w; Ua[i*2+1] = U[i*2+1]/w;
    const nx = N[i*3]/w, ny = N[i*3+1]/w, nz = N[i*3+2]/w, l = Math.hypot(nx, ny, nz) || 1;
    Na[i*3] = nx/l; Na[i*3+1] = ny/l; Na[i*3+2] = nz/l;
  }
  return { P: Pa, U: Ua, N: Na, I: new Uint32Array(ids) };
}

const CELL_BODY = Number(process.env.CELL_BODY || 0.022), CELL_WHEEL = Number(process.env.CELL_WHEEL || 0.014);
const bodyTris = [], wheelTris = [[],[],[],[]];
for (let t = 0; t < nt; t++) (groupOf[t] < 0 ? bodyTris : wheelTris[groupOf[t]]).push(t);
const parts = [];
parts.push({ name: 'body', origin: [0,0,0], ...build(bodyTris, [0,0,0], CELL_BODY, 48) });
WHEELS.forEach((W, i) => {
  const o = [W.x, RY, W.z];
  parts.push({ name: W.name, origin: o, ...build(wheelTris[i], o, CELL_WHEEL, 48) });
});
for (const p of parts) console.log(p.name, 'verts', p.P.length/3, 'tris', p.I.length/3);
const totalTris = parts.reduce((s,p)=>s+p.I.length/3, 0);
console.log('total tris', totalTris, '(元', nt, ')');

// --- テール発光テクスチャ（UV ラスタライズでマスクを作り、赤い画素だけ残す）---
const bmp = fs.readFileSync('mask.bmp');
const bOff = bmp.readUInt32LE(10), MW = 1024, MH = 1024, rowSize = ((24*MW+31)>>5)<<2;
const px = (x, y) => { const p = bOff + y*rowSize + x*3; return [bmp[p+2], bmp[p+1], bmp[p]]; };
const isRed = (r,g,b) => r > 90 && r > g*1.6 && r > b*1.6;
const mask = new Uint8Array(MW*MH);
const toPix = (u, v) => [Math.min(MW-1, Math.max(0, Math.floor(((u%1)+1)%1*MW))), Math.min(MH-1, Math.max(0, Math.floor((1-((v%1)+1)%1)*MH)))];
let lampTris = 0;
for (let t = 0; t < nt; t++) {
  const cx = cen[t*3], cy = cen[t*3+1];
  if (cx > -2.02 || cy < 0.55 || cy > 1.0) continue;          // 尾端の灯火帯だけ
  const a = IDX[t*3], b2 = IDX[t*3+1], c = IDX[t*3+2];
  const [ax, ay] = toPix(UV[a*2], UV[a*2+1]), [bx, by] = toPix(UV[b2*2], UV[b2*2+1]), [cx2, cy2] = toPix(UV[c*2], UV[c*2+1]);
  const x0 = Math.max(0, Math.min(ax,bx,cx2)-1), x1 = Math.min(MW-1, Math.max(ax,bx,cx2)+1);
  const y0 = Math.max(0, Math.min(ay,by,cy2)-1), y1 = Math.min(MH-1, Math.max(ay,by,cy2)+1);
  if ((x1-x0) > 200 || (y1-y0) > 200) continue;               // UV が飛んでいる三角形は無視
  let any = false;
  for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) {
    const [r,g,bb] = px(x,y);
    if (isRed(r,g,bb)) { mask[y*MW+x] = 1; any = true; }
  }
  if (any) lampTris++;
}
let maskPx = 0; for (let i = 0; i < mask.length; i++) maskPx += mask[i];
console.log('lamp tris', lampTris, 'mask px', maskPx);
// 発光 BMP を書く（マスク外は黒）
const outBmp = Buffer.from(bmp);
for (let y = 0; y < MH; y++) for (let x = 0; x < MW; x++) {
  if (mask[y*MW+x]) continue;
  const p = bOff + y*rowSize + x*3; outBmp[p] = outBmp[p+1] = outBmp[p+2] = 0;
}
fs.writeFileSync('emissive.bmp', outBmp);
fs.writeFileSync('parts.json', JSON.stringify(parts.map(p=>({name:p.name, origin:p.origin, verts:p.P.length/3, tris:p.I.length/3}))));
// パーツを一時ファイルに保存（GLB 組み立ては次段で）
for (const p of parts) {
  fs.writeFileSync(`part-${p.name}.bin`, Buffer.concat([Buffer.from(p.P.buffer), Buffer.from(p.U.buffer), Buffer.from(p.N.buffer), Buffer.from(p.I.buffer)]));
}
console.log('parts written');
