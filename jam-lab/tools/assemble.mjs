// パーツ + 縮小テクスチャ → ゲーム用 rx7.glb
import fs from 'node:fs';
import { writeGLB } from './glb.mjs';

const meta = JSON.parse(fs.readFileSync('parts.json', 'utf8'));
const bufs = [], views = [], accessors = [], meshes = [], nodes = [];
let off = 0;
const addView = (b) => { views.push({ buffer: 0, byteOffset: off, byteLength: b.length }); bufs.push(b); off += b.length + ((4 - b.length % 4) % 4); return views.length - 1; };
const mm = (a, n) => { const mn = new Array(n).fill(Infinity), mx = new Array(n).fill(-Infinity);
  for (let i = 0; i < a.length; i += n) for (let d = 0; d < n; d++) { if (a[i+d] < mn[d]) mn[d] = a[i+d]; if (a[i+d] > mx[d]) mx[d] = a[i+d]; } return [mn, mx]; };

for (const p of meta) {
  const raw = fs.readFileSync(`part-${p.name}.bin`);
  const nv = p.verts, ni = p.tris * 3;
  let o = 0;
  const P = new Float32Array(raw.buffer, raw.byteOffset + o, nv*3); o += nv*3*4;
  const U = new Float32Array(raw.buffer, raw.byteOffset + o, nv*2); o += nv*2*4;
  const N = new Float32Array(raw.buffer, raw.byteOffset + o, nv*3); o += nv*3*4;
  const I = new Uint32Array(raw.buffer, raw.byteOffset + o, ni);
  const vp = addView(Buffer.from(new Float32Array(P).buffer));
  const vu = addView(Buffer.from(new Float32Array(U).buffer));
  const vn = addView(Buffer.from(new Float32Array(N).buffer));
  const vi = addView(Buffer.from(new Uint32Array(I).buffer));
  const [pmin, pmax] = mm(P, 3);
  const a0 = accessors.length;
  accessors.push({ bufferView: vp, componentType: 5126, count: nv, type: 'VEC3', min: pmin, max: pmax });
  accessors.push({ bufferView: vu, componentType: 5126, count: nv, type: 'VEC2' });
  accessors.push({ bufferView: vn, componentType: 5126, count: nv, type: 'VEC3' });
  accessors.push({ bufferView: vi, componentType: 5125, count: ni, type: 'SCALAR' });
  meshes.push({ name: p.name, primitives: [{ mode: 4, attributes: { POSITION: a0, TEXCOORD_0: a0+1, NORMAL: a0+2 }, indices: a0+3, material: 0 }] });
  nodes.push({ name: p.name, mesh: meshes.length - 1, translation: p.origin });
}
const texBase = addView(fs.readFileSync('basecolor-2048.jpg'));
const texMR   = addView(fs.readFileSync('mr-512.jpg'));
const texEm   = addView(fs.readFileSync('emissive-2048.jpg'));

const json = {
  asset: { version: '2.0', generator: 'jam-lab rx7 build' },
  scene: 0, scenes: [{ nodes: nodes.map((_, i) => i) }], nodes, meshes, accessors, bufferViews: views,
  samplers: [{ magFilter: 9729, minFilter: 9987, wrapS: 10497, wrapT: 10497 }],
  images: [{ mimeType: 'image/jpeg', bufferView: texBase }, { mimeType: 'image/jpeg', bufferView: texMR }, { mimeType: 'image/jpeg', bufferView: texEm }],
  textures: [{ sampler: 0, source: 0 }, { sampler: 0, source: 1 }, { sampler: 0, source: 2 }],
  materials: [{ name: 'rx7_body',
    pbrMetallicRoughness: { baseColorTexture: { index: 0 }, metallicRoughnessTexture: { index: 1 }, metallicFactor: 1, roughnessFactor: 1 },
    emissiveTexture: { index: 2 }, emissiveFactor: [1, 1, 1] }],
};
const bytes = writeGLB('rx7.glb', json, bufs);
console.log('wrote rx7.glb', (bytes/1e6).toFixed(2) + 'MB', 'nodes', nodes.map(n=>n.name).join(','));
