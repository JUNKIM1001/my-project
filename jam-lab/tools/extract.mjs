// 連結成分をグループ化して「1 台分」を GLB に切り出す
import fs from 'node:fs';
import { readGLB, readAccessor, writeGLB } from './glb.mjs';

const SRC = '/Users/thisiskj/Downloads/Hi3D_Untitled_allparts_20260906_233322.glb';
const { json, bin } = readGLB(SRC);
const prim = json.meshes[0].primitives[0];
const pos = readAccessor(json, bin, prim.attributes.POSITION);
const uv  = readAccessor(json, bin, prim.attributes.TEXCOORD_0);
const nor = readAccessor(json, bin, prim.attributes.NORMAL);
const idx = readAccessor(json, bin, prim.indices);
const nv = pos.length / 3, nt = idx.length / 3;

// --- 連結成分 ---
const q = 1e-5, key = new Map(), parent = new Int32Array(nv);
for (let i = 0; i < nv; i++) {
  const k = `${Math.round(pos[i*3]/q)},${Math.round(pos[i*3+1]/q)},${Math.round(pos[i*3+2]/q)}`;
  const e = key.get(k);
  parent[i] = e === undefined ? (key.set(k, i), i) : e;
}
const find = (x) => { while (parent[x] !== x) { parent[x] = parent[parent[x]]; x = parent[x]; } return x; };
const uni = (a, b) => { a = find(a); b = find(b); if (a !== b) parent[b] = a; };
for (let t = 0; t < nt; t++) { uni(idx[t*3], idx[t*3+1]); uni(idx[t*3+1], idx[t*3+2]); }

const comps = new Map();
for (let t = 0; t < nt; t++) {
  const r = find(idx[t*3]);
  let c = comps.get(r);
  if (!c) { c = { tris: [], min: [1e9,1e9,1e9], max: [-1e9,-1e9,-1e9] }; comps.set(r, c); }
  c.tris.push(t);
  for (let k = 0; k < 3; k++) { const v = idx[t*3+k];
    for (let d = 0; d < 3; d++) { const p = pos[v*3+d]; if (p < c.min[d]) c.min[d] = p; if (p > c.max[d]) c.max[d] = p; } }
}
const list = [...comps.values()].map((c) => ({ ...c, n: c.tris.length,
  center: c.max.map((v,i)=>(v+c.min[i])/2), size: c.max.map((v,i)=>v-c.min[i]) })).sort((a,b)=>b.n-a.n);

// 大きい 5 つを車体とし、残りは最も近い車体に割り当てる（bbox 中心距離）
const bodies = list.slice(0, 5);
const groups = bodies.map((b) => ({ body: b, parts: [b] }));
for (const c of list.slice(5)) {
  let best = 0, bd = Infinity;
  for (let i = 0; i < bodies.length; i++) {
    const b = bodies[i];
    // bbox までの距離（内側なら 0）
    let d2 = 0;
    for (let k = 0; k < 3; k++) { const v = c.center[k]; const lo = b.min[k], hi = b.max[k];
      const e = v < lo ? lo - v : v > hi ? v - hi : 0; d2 += e * e; }
    if (d2 < bd) { bd = d2; best = i; }
  }
  groups[best].parts.push(c);
}

const LABEL = ['A-perspective?', 'B', 'C', 'D', 'E'];
groups.forEach((g, i) => {
  const tris = g.parts.reduce((s, p) => s + p.n, 0);
  const min = [0,1,2].map((d) => Math.min(...g.parts.map((p) => p.min[d])));
  const max = [0,1,2].map((d) => Math.max(...g.parts.map((p) => p.max[d])));
  console.log(`group${i}: parts=${g.parts.length} tris=${tris} size=[${max.map((v,d)=>(v-min[d]).toFixed(3))}] center=[${max.map((v,d)=>((v+min[d])/2).toFixed(3))}]`);
});

// --- GLB 書き出し（頂点を詰め直す） ---
function exportGroup(g, outPath) {
  const tris = g.parts.flatMap((p) => p.tris);
  const map = new Map();
  const P = [], U = [], N = [], I = [];
  for (const t of tris) for (let k = 0; k < 3; k++) {
    const v = idx[t*3+k];
    let ni = map.get(v);
    if (ni === undefined) {
      ni = P.length / 3; map.set(v, ni);
      P.push(pos[v*3], pos[v*3+1], pos[v*3+2]);
      U.push(uv[v*2], uv[v*2+1]);
      N.push(nor[v*3], nor[v*3+1], nor[v*3+2]);
    }
    I.push(ni);
  }
  const Pa = new Float32Array(P), Ua = new Float32Array(U), Na = new Float32Array(N), Ia = new Uint32Array(I);
  const bufs = [Buffer.from(Pa.buffer), Buffer.from(Ua.buffer), Buffer.from(Na.buffer), Buffer.from(Ia.buffer)];
  // 画像 2 枚もコピー
  const imgBufs = json.images.map((im) => {
    const bv = json.bufferViews[im.bufferView];
    return Buffer.from(bin.subarray(bv.byteOffset || 0, (bv.byteOffset || 0) + bv.byteLength));
  });
  bufs.push(...imgBufs);
  let off = 0; const views = [];
  for (const b of bufs) { views.push({ buffer: 0, byteOffset: off, byteLength: b.length }); off += b.length + ((4 - b.length % 4) % 4); }
  const min3 = (a, n) => { const m = [1e9,1e9,1e9]; for (let i = 0; i < a.length; i += n) for (let d = 0; d < n; d++) m[d] = Math.min(m[d], a[i+d]); return m.slice(0, n); };
  const max3 = (a, n) => { const m = [-1e9,-1e9,-1e9]; for (let i = 0; i < a.length; i += n) for (let d = 0; d < n; d++) m[d] = Math.max(m[d], a[i+d]); return m.slice(0, n); };
  const out = {
    asset: { version: '2.0', generator: 'jam-lab extract' },
    scene: 0, scenes: [{ nodes: [0] }], nodes: [{ mesh: 0 }],
    meshes: [{ primitives: [{ mode: 4, attributes: { POSITION: 0, TEXCOORD_0: 1, NORMAL: 2 }, indices: 3, material: 0 }] }],
    accessors: [
      { bufferView: 0, componentType: 5126, count: Pa.length/3, type: 'VEC3', min: min3(Pa,3), max: max3(Pa,3) },
      { bufferView: 1, componentType: 5126, count: Ua.length/2, type: 'VEC2' },
      { bufferView: 2, componentType: 5126, count: Na.length/3, type: 'VEC3' },
      { bufferView: 3, componentType: 5125, count: Ia.length, type: 'SCALAR' },
    ],
    bufferViews: views,
    materials: json.materials,
    textures: json.textures,
    samplers: json.samplers,
    images: [{ mimeType: 'image/jpeg', bufferView: 4 }, { mimeType: 'image/jpeg', bufferView: 5 }],
  };
  if (!out.samplers) delete out.samplers;
  const bytes = writeGLB(outPath, out, bufs);
  console.log(outPath, 'tris', Ia.length/3, 'verts', Pa.length/3, 'bytes', (bytes/1e6).toFixed(1)+'MB');
}
groups.forEach((g, i) => exportGroup(g, `car${i}.glb`));
