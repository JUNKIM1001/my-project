// ホイール領域とテールランプ領域の当たりをつける
import fs from 'node:fs';
import { readGLB, readAccessor } from './glb.mjs';
const { json, bin } = readGLB('rx7-aligned.glb');
const prim = json.meshes[0].primitives[0];
const pos = readAccessor(json, bin, prim.attributes.POSITION);
const uv  = readAccessor(json, bin, prim.attributes.TEXCOORD_0);
const idx = readAccessor(json, bin, prim.indices);
const nt = idx.length / 3;

const HUB = 2.425 / 2, TRACK = 1.5226;
const wheels = [[HUB, TRACK/2], [HUB, -TRACK/2], [-HUB, TRACK/2], [-HUB, -TRACK/2]];
const RY = 0.315;
for (const [wx, wz] of wheels) {
  let n = 0, minR = 9, maxR = 0, zmin = 9, zmax = -9, ymin = 9, ymax = -9;
  for (let t = 0; t < nt; t++) {
    let cx = 0, cy = 0, cz = 0;
    for (let k = 0; k < 3; k++) { const v = idx[t*3+k]; cx += pos[v*3]/3; cy += pos[v*3+1]/3; cz += pos[v*3+2]/3; }
    const r = Math.hypot(cx - wx, cy - RY);
    if (r < 0.36 && Math.abs(cz - wz) < 0.30) { n++; if (r < minR) minR = r; if (r > maxR) maxR = r;
      zmin = Math.min(zmin, cz); zmax = Math.max(zmax, cz); ymin = Math.min(ymin, cy); ymax = Math.max(ymax, cy); }
  }
  console.log(`wheel [${wx.toFixed(2)},${wz.toFixed(2)}] tris=${n} r=[${minR.toFixed(3)},${maxR.toFixed(3)}] z=[${zmin.toFixed(3)},${zmax.toFixed(3)}] y=[${ymin.toFixed(3)},${ymax.toFixed(3)}]`);
}

// 赤マスク（BMP 1024, 24bpp, top-down）
const bmp = fs.readFileSync('mask.bmp');
const off = bmp.readUInt32LE(10), W = 1024, H = 1024, rowSize = ((24 * W + 31) >> 5) << 2;
const isRed = (u, v) => {
  let x = Math.floor(((u % 1) + 1) % 1 * W), y = Math.floor((1 - ((v % 1) + 1) % 1) * H); // glTF の v は下から
  x = Math.min(W-1, Math.max(0, x)); y = Math.min(H-1, Math.max(0, y));
  const p = off + y * rowSize + x * 3;
  const b = bmp[p], g = bmp[p+1], r = bmp[p+2];
  return r > 90 && r > g * 1.6 && r > b * 1.6;
};
// 後方（X < -1.6）の赤い三角形を数え、その範囲を出す
let n = 0, xr=[9,-9], yr=[9,-9], zr=[9,-9];
for (let t = 0; t < nt; t++) {
  let cx=0, cy=0, cz=0, cu=0, cv=0;
  for (let k = 0; k < 3; k++) { const v = idx[t*3+k]; cx += pos[v*3]/3; cy += pos[v*3+1]/3; cz += pos[v*3+2]/3; cu += uv[v*2]/3; cv += uv[v*2+1]/3; }
  if (cx > -1.6) continue;
  if (!isRed(cu, cv)) continue;
  n++; xr=[Math.min(xr[0],cx),Math.max(xr[1],cx)]; yr=[Math.min(yr[0],cy),Math.max(yr[1],cy)]; zr=[Math.min(zr[0],cz),Math.max(zr[1],cz)];
}
console.log(`rear red tris=${n} x=[${xr.map(v=>v.toFixed(2))}] y=[${yr.map(v=>v.toFixed(2))}] z=[${zr.map(v=>v.toFixed(2))}]`);
// 全体の赤も参考に
let nAll = 0; for (let t = 0; t < nt; t++) { let cu=0,cv=0; for(let k=0;k<3;k++){const v=idx[t*3+k];cu+=uv[v*2]/3;cv+=uv[v*2+1]/3;} if(isRed(cu,cv)) nAll++; }
console.log('red tris total', nAll);
