// 生成モデルの車体だけが進行方向に対して斜め（ヨー）を向いていたのを補正する。
// 車体の中心線（x スライスごとの左右端の中点 z）を x で回帰し、その傾きぶん Y 軸まわりに回して
// 横ずれも 0 に寄せる。ホイールは assemble 時に固定位置へ置いてあるので body メッシュだけを回す。
// 使い方: node tools/yaw-body.mjs [glb] [--apply]
import fs from 'node:fs';
import { readGLB, readAccessor } from './glb.mjs';

const PATH = process.argv.find((a) => a.endsWith('.glb')) || 'assets/rx7-fd3s.glb';
const APPLY = process.argv.includes('--apply');
const { json, bin, buf } = readGLB(PATH);
const bi = json.meshes.findIndex((m) => m.name === 'body');
if (bi < 0) throw new Error('body メッシュが見つからない');
const prim = json.meshes[bi].primitives[0];
const pos = new Float32Array(readAccessor(json, bin, prim.attributes.POSITION));
const nor = new Float32Array(readAccessor(json, bin, prim.attributes.NORMAL));
const n = pos.length / 3;

/** 中心線 z = k*x + b（ベルトライン付近 y 0.3〜0.9 の点だけ使う。ウィングやミラーの影響を避ける） */
function measureYaw(P) {
  const rows = [];
  for (let x0 = -1.9; x0 < 1.9; x0 += 0.2) {
    let zmin = 1e9, zmax = -1e9, c = 0;
    for (let i = 0; i < n; i++) {
      const x = P[i*3], y = P[i*3+1], z = P[i*3+2];
      if (x >= x0 && x < x0 + 0.2 && y > 0.3 && y < 0.9) { c++; if (z < zmin) zmin = z; if (z > zmax) zmax = z; }
    }
    if (c > 100) rows.push([x0 + 0.1, (zmin + zmax) / 2]);
  }
  let sx = 0, sm = 0, sxx = 0, sxm = 0;
  for (const [x, m] of rows) { sx += x; sm += m; sxx += x * x; sxm += x * m; }
  const N = rows.length, k = (N * sxm - sx * sm) / (N * sxx - sx * sx);
  return { k, b: (sm - k * sx) / N };
}
const before = measureYaw(pos);
console.log(`補正前: ヨー ${(Math.atan(before.k) * 180 / Math.PI).toFixed(2)}° 横ずれ ${before.b.toFixed(3)} m`);
if (!APPLY) { console.log('（--apply を付けると書き込みます）'); process.exit(0); }

// Y 軸まわりに回して z = k x を z = 0 に寝かせる。x' = c x + s z, z' = -s x + c z なので、
// 点 (x, kx) を z' = 0 にするには -s + c k = 0 → th = atan(k)
const th = Math.atan(before.k), c = Math.cos(th), s = Math.sin(th);
for (let i = 0; i < n; i++) {
  const x = pos[i*3], z = pos[i*3+2] - before.b;
  pos[i*3] = c * x + s * z; pos[i*3+2] = -s * x + c * z;
  const nx = nor[i*3], nz = nor[i*3+2];
  nor[i*3] = c * nx + s * nz; nor[i*3+2] = -s * nx + c * nz;
}
const after = measureYaw(pos);
console.log(`補正後: ヨー ${(Math.atan(after.k) * 180 / Math.PI).toFixed(2)}° 横ずれ ${after.b.toFixed(3)} m`);

const writeInto = (accIdx, arr) => {
  const acc = json.accessors[accIdx], bv = json.bufferViews[acc.bufferView];
  Buffer.from(arr.buffer, arr.byteOffset, arr.byteLength).copy(buf, bin.byteOffset + (bv.byteOffset || 0) + (acc.byteOffset || 0));
};
writeInto(prim.attributes.POSITION, pos);
writeInto(prim.attributes.NORMAL, nor);
const mn = [1e9,1e9,1e9], mx = [-1e9,-1e9,-1e9];
for (let i = 0; i < n; i++) for (let d = 0; d < 3; d++) { const v = pos[i*3+d]; if (v < mn[d]) mn[d] = v; if (v > mx[d]) mx[d] = v; }
const acc = json.accessors[prim.attributes.POSITION];
acc.min = mn.map((v) => +v.toFixed(6)); acc.max = mx.map((v) => +v.toFixed(6));
let jsonStr = JSON.stringify(json); while (jsonStr.length % 4 !== 0) jsonStr += ' ';
const jsonBuf = Buffer.from(jsonStr, 'utf8');
const header = Buffer.alloc(12); header.write('glTF', 0, 'ascii'); header.writeUInt32LE(2, 4);
header.writeUInt32LE(12 + 8 + jsonBuf.length + 8 + bin.length, 8);
const jc = Buffer.alloc(8); jc.writeUInt32LE(jsonBuf.length, 0); jc.write('JSON', 4, 'ascii');
const bc = Buffer.alloc(8); bc.writeUInt32LE(bin.length, 0); bc.write('BIN\0', 4, 'ascii');
fs.writeFileSync(PATH, Buffer.concat([header, jc, jsonBuf, bc, bin]));
console.log(`書き戻し完了 ${PATH}  長さ ${(mx[0]-mn[0]).toFixed(3)} 幅 ${(mx[2]-mn[2]).toFixed(3)} 高さ ${mx[1].toFixed(3)}`);
