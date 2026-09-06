import { readGLB, readAccessor } from './glb.mjs';
const { json, bin } = readGLB('car0.glb');
const prim = json.meshes[0].primitives[0];
const pos = readAccessor(json, bin, prim.attributes.POSITION);
const idx = readAccessor(json, bin, prim.indices);
const nv = pos.length/3, nt = idx.length/3;
const q = 1e-5, key = new Map(), parent = new Int32Array(nv);
for (let i = 0; i < nv; i++) { const k = `${Math.round(pos[i*3]/q)},${Math.round(pos[i*3+1]/q)},${Math.round(pos[i*3+2]/q)}`;
  const e = key.get(k); parent[i] = e === undefined ? (key.set(k,i), i) : e; }
const find = (x)=>{ while(parent[x]!==x){parent[x]=parent[parent[x]];x=parent[x];} return x; };
const uni = (a,b)=>{a=find(a);b=find(b);if(a!==b)parent[b]=a;};
for (let t=0;t<nt;t++){uni(idx[t*3],idx[t*3+1]);uni(idx[t*3+1],idx[t*3+2]);}
const comps=new Map();
for (let t=0;t<nt;t++){ const r=find(idx[t*3]); let c=comps.get(r);
  if(!c){c={n:0,min:[1e9,1e9,1e9],max:[-1e9,-1e9,-1e9]};comps.set(r,c);} c.n++;
  for(let k=0;k<3;k++){const v=idx[t*3+k];for(let d=0;d<3;d++){const p=pos[v*3+d];if(p<c.min[d])c.min[d]=p;if(p>c.max[d])c.max[d]=p;}}}
const list=[...comps.values()].map(c=>({...c,size:c.max.map((v,i)=>v-c.min[i]),center:c.max.map((v,i)=>(v+c.min[i])/2)})).sort((a,b)=>b.n-a.n);
console.log('components', list.length);
list.forEach((c,i)=>console.log(`#${i} tris=${c.n} size=[${c.size.map(v=>v.toFixed(4))}] center=[${c.center.map(v=>v.toFixed(4))}] minY=${c.min[1].toFixed(4)}`));
