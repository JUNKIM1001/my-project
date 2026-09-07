// 画像→3D 生成モデルの「車体が傾いて見える」不具合の補正。
//
// 調べた結果、車体は回転しておらず（ホイールアーチ・サイドシルの左右高さ差は 0.2°未満）、
// 車体中心線が高さとともに横へずれる「せん断」が入っていた（0.074 m/m ≒ 見かけ 4.2°）。
// 生成元のイラストが斜め 3/4 視点だったため、上部ほど横にずれて復元されたと思われる。
// 回転で直すとシルやアーチが逆に傾くので、逆せん断（z を y の一次式で戻す）で補正する。
//
// 使い方: node tools/level-body.mjs [glb] [--apply]
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

/** 高さ帯ごとの左右端の中点を集めて、ずれを y の一次式 (k, b) で近似する */
function measureShear(P) {
  const rows = [];
  for (let y0 = 0.05; y0 < 1.15; y0 += 0.1) {
    let zmin = 1e9, zmax = -1e9, c = 0;
    for (let i = 0; i < n; i++) {
      const x = P[i*3], y = P[i*3+1], z = P[i*3+2];
      if (y >= y0 && y < y0 + 0.1 && x > -1.6 && x < 1.6) { c++; if (z < zmin) zmin = z; if (z > zmax) zmax = z; }
    }
    if (c >= 200) rows.push([y0 + 0.05, (zmin + zmax) / 2]);
  }
  let sy = 0, sm = 0, syy = 0, sym = 0;
  for (const [y, m] of rows) { sy += y; sm += m; syy += y * y; sym += y * m; }
  const N = rows.length;
  const k = (N * sym - sy * sm) / (N * syy - sy * sy);
  return { k, b: (sm - k * sy) / N, rows };
}

const before = measureShear(pos);
console.log(`補正前: 中心ずれ = ${before.k.toFixed(4)} * y + ${before.b.toFixed(4)}  (見かけ ${(Math.atan(before.k)*180/Math.PI).toFixed(2)}°)`);
if (!APPLY) { console.log('（--apply を付けると書き込みます）'); process.exit(0); }

// z' = z - (k*y + b)。法線は逆転置行列で n' = (nx, ny + k*nz, nz)
const k = before.k, b = before.b;
for (let i = 0; i < n; i++) {
  pos[i*3+2] -= k * pos[i*3+1] + b;
  const nx = nor[i*3], ny = nor[i*3+1] + k * nor[i*3+2], nz = nor[i*3+2];
  const len = Math.hypot(nx, ny, nz) || 1;
  nor[i*3] = nx / len; nor[i*3+1] = ny / len; nor[i*3+2] = nz / len;
}
const after = measureShear(pos);
console.log(`補正後: 中心ずれ = ${after.k.toFixed(4)} * y + ${after.b.toFixed(4)}  (見かけ ${(Math.atan(after.k)*180/Math.PI).toFixed(2)}°)`);

// --- BIN の該当バイト列だけ差し替え、コンテナを組み直す（他メッシュ・画像はそのまま） ---
const writeInto = (accIdx, arr) => {
  const acc = json.accessors[accIdx];
  const bv = json.bufferViews[acc.bufferView];
  Buffer.from(arr.buffer, arr.byteOffset, arr.byteLength)
    .copy(buf, bin.byteOffset + (bv.byteOffset || 0) + (acc.byteOffset || 0));
};
writeInto(prim.attributes.POSITION, pos);
writeInto(prim.attributes.NORMAL, nor);
const mn = [1e9, 1e9, 1e9], mx = [-1e9, -1e9, -1e9];
for (let i = 0; i < n; i++) for (let d = 0; d < 3; d++) { const v = pos[i*3+d];
  if (v < mn[d]) mn[d] = v; if (v > mx[d]) mx[d] = v; }
const acc = json.accessors[prim.attributes.POSITION];
acc.min = mn.map((v) => +v.toFixed(6));
acc.max = mx.map((v) => +v.toFixed(6));

let jsonStr = JSON.stringify(json);
while (jsonStr.length % 4 !== 0) jsonStr += ' ';
const jsonBuf = Buffer.from(jsonStr, 'utf8');
const header = Buffer.alloc(12);
header.write('glTF', 0, 'ascii');
header.writeUInt32LE(2, 4);
header.writeUInt32LE(12 + 8 + jsonBuf.length + 8 + bin.length, 8);
const jc = Buffer.alloc(8); jc.writeUInt32LE(jsonBuf.length, 0); jc.write('JSON', 4, 'ascii');
const bc = Buffer.alloc(8); bc.writeUInt32LE(bin.length, 0); bc.write('BIN\0', 4, 'ascii');
fs.writeFileSync(PATH, Buffer.concat([header, jc, jsonBuf, bc, bin]));
console.log(`書き戻し完了 ${PATH}  車体幅 ${(mx[2]-mn[2]).toFixed(3)} m / 高さ ${mx[1].toFixed(3)} m`);
