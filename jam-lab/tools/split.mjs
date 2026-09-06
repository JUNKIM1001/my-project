// 連結成分に分割して、各塊のサイズ・バウンディングボックスを報告する
import { readGLB, readAccessor } from './glb.mjs';
const { json, bin } = readGLB('/Users/thisiskj/Downloads/Hi3D_Untitled_allparts_20260906_233322.glb');
const prim = json.meshes[0].primitives[0];
const pos = readAccessor(json, bin, prim.attributes.POSITION);
const idx = readAccessor(json, bin, prim.indices);
const nv = pos.length / 3, nt = idx.length / 3;
console.log('vertices', nv, 'triangles', nt);

// 同一座標の頂点をグリッド量子化でまとめてから union-find（分割された頂点が別成分にならないように）
const q = 1e-5;
const key = new Map();
const rep = new Int32Array(nv);
for (let i = 0; i < nv; i++) {
  const k = `${Math.round(pos[i*3]/q)},${Math.round(pos[i*3+1]/q)},${Math.round(pos[i*3+2]/q)}`;
  const e = key.get(k);
  if (e === undefined) { key.set(k, i); rep[i] = i; } else rep[i] = e;
}
const parent = new Int32Array(nv);
for (let i = 0; i < nv; i++) parent[i] = rep[i];
function find(x) { while (parent[x] !== x) { parent[x] = parent[parent[x]]; x = parent[x]; } return x; }
function uni(a, b) { a = find(a); b = find(b); if (a !== b) parent[b] = a; }
for (let t = 0; t < nt; t++) { const a = idx[t*3], b = idx[t*3+1], c = idx[t*3+2]; uni(a, b); uni(b, c); }

const comps = new Map();
for (let t = 0; t < nt; t++) {
  const r = find(idx[t*3]);
  let c = comps.get(r);
  if (!c) { c = { tris: 0, min: [1e9,1e9,1e9], max: [-1e9,-1e9,-1e9], verts: new Set() }; comps.set(r, c); }
  c.tris++;
  for (let k = 0; k < 3; k++) {
    const v = idx[t*3+k];
    c.verts.add(v);
    for (let d = 0; d < 3; d++) { const p = pos[v*3+d]; if (p < c.min[d]) c.min[d] = p; if (p > c.max[d]) c.max[d] = p; }
  }
}
const list = [...comps.entries()].map(([r, c]) => ({ root: r, tris: c.tris, verts: c.verts.size, min: c.min, max: c.max,
  size: c.max.map((v,i)=>v-c.min[i]), center: c.max.map((v,i)=>(v+c.min[i])/2) })).sort((a,b)=>b.tris-a.tris);
console.log('components', list.length);
for (const c of list.slice(0, 15)) {
  console.log(`tris=${c.tris} verts=${c.verts} size=[${c.size.map(v=>v.toFixed(3))}] center=[${c.center.map(v=>v.toFixed(3))}] min=[${c.min.map(v=>v.toFixed(3))}]`);
}
const small = list.slice(15);
if (small.length) console.log('...他', small.length, '個, 合計tris', small.reduce((s,c)=>s+c.tris,0));
