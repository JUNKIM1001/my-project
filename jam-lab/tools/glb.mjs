// GLB の読み書きユーティリティ（外部依存なし）
import fs from 'node:fs';

export function readGLB(path) {
  const buf = fs.readFileSync(path);
  let off = 12; const chunks = [];
  while (off < buf.length) {
    const len = buf.readUInt32LE(off), type = buf.toString('ascii', off + 4, off + 8);
    chunks.push({ type, len, start: off + 8 }); off += 8 + len;
  }
  const json = JSON.parse(buf.toString('utf8', chunks[0].start, chunks[0].start + chunks[0].len));
  const binChunk = chunks.find((c) => c.type.startsWith('BIN'));
  const bin = buf.subarray(binChunk.start, binChunk.start + binChunk.len);
  return { json, bin, buf };
}

const CT = { 5120: Int8Array, 5121: Uint8Array, 5122: Int16Array, 5123: Uint16Array, 5125: Uint32Array, 5126: Float32Array };
const NC = { SCALAR: 1, VEC2: 2, VEC3: 3, VEC4: 4, MAT4: 16 };

export function readAccessor(json, bin, idx) {
  const acc = json.accessors[idx];
  const bv = json.bufferViews[acc.bufferView];
  const TA = CT[acc.componentType];
  const n = NC[acc.type];
  const byteOffset = (bv.byteOffset || 0) + (acc.byteOffset || 0);
  // bin は buf の subarray なので byteOffset を足して参照
  return new TA(bin.buffer, bin.byteOffset + byteOffset, acc.count * n);
}

export function writeGLB(path, json, binParts) {
  // binParts: [Buffer]、それぞれ 4 バイト境界に整列させて連結
  const aligned = [];
  let total = 0;
  for (const p of binParts) {
    aligned.push(p);
    total += p.length;
    const pad = (4 - (total % 4)) % 4;
    if (pad) { aligned.push(Buffer.alloc(pad)); total += pad; }
  }
  const bin = Buffer.concat(aligned);
  json.buffers = [{ byteLength: bin.length }];
  let jsonStr = JSON.stringify(json);
  while (jsonStr.length % 4 !== 0) jsonStr += ' ';
  const jsonBuf = Buffer.from(jsonStr, 'utf8');
  const header = Buffer.alloc(12);
  header.write('glTF', 0, 'ascii');
  header.writeUInt32LE(2, 4);
  header.writeUInt32LE(12 + 8 + jsonBuf.length + 8 + bin.length, 8);
  const jc = Buffer.alloc(8); jc.writeUInt32LE(jsonBuf.length, 0); jc.write('JSON', 4, 'ascii');
  const bc = Buffer.alloc(8); bc.writeUInt32LE(bin.length, 0); bc.write('BIN\0', 4, 'ascii');
  fs.writeFileSync(path, Buffer.concat([header, jc, jsonBuf, bc, bin]));
  return 12 + 8 + jsonBuf.length + 8 + bin.length;
}
