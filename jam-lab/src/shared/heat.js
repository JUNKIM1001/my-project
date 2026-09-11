// 周回路上の「渋滞の重さ」を区間ごとに数値化する（ミニマップと 3D の道路帯が同じ値を使う）。
// 純粋モジュール（DOM / three.js 非依存、node --test で検証できる）。
//
// 重さ heat[k] ∈ 0..1: 0 = 流れている、1 = 止まっている。
//   各車について、その車の速度比 r = v / ref から「遅れ」1 - r を出し、車の前後 ±HALF_SPAN m の区間に
//   書き込む（重なる場合は大きい方）。最後に隣接区間で軽くならして帯にする。
//   ref は「その密度で本来出るはずの速度」（IDM の平衡速度）。v0 ではなく平衡速度を使うのは、
//   混雑時は全員が遅いのが正常で、そこからの落ち込みだけを渋滞として色付けしたいため。
import { LENGTH, CAR_LENGTH, wrap } from './track.js';

/** 区間数（2 m 刻み） */
export const HEAT_SEGMENTS = 500;
/** 1 台の影響を書き込む前後の長さ [m]（車長の半分 + 少し） */
const HALF_SPAN = CAR_LENGTH / 2 + 1.5;

/**
 * @param {Array<{s:number, v:number}>} cars
 * @param {number} ref 基準速度 [m/s]（> 0）
 * @param {Float32Array} [out] 再利用用の出力配列（長さ HEAT_SEGMENTS）
 * @returns {Float32Array} heat（長さ HEAT_SEGMENTS、区間 k は s ∈ [k*2, k*2+2)）
 */
export function jamHeat(cars, ref, out) {
  const n = HEAT_SEGMENTS;
  const segLen = LENGTH / n;
  const heat = out && out.length === n ? out : new Float32Array(n);
  heat.fill(0);
  if (!cars || !cars.length || !(ref > 0)) return heat;
  const span = Math.ceil(HALF_SPAN / segLen);
  for (const c of cars) {
    const r = Math.min(1, Math.max(0, c.v / ref));
    const w = 1 - r;
    if (w <= 0.02) continue;                     // ほぼ平衡速度なら何も描かない
    const k0 = Math.floor(wrap(c.s) / segLen);
    for (let d = -span; d <= span; d++) {
      const k = (k0 + d + n) % n;
      if (w > heat[k]) heat[k] = w;
    }
  }
  // 3 区間の移動平均で帯の端をなだらかに（周回路なので端は巻く）
  const tmp = new Float32Array(n);
  for (let k = 0; k < n; k++) tmp[k] = (heat[(k - 1 + n) % n] + heat[k] + heat[(k + 1) % n]) / 3;
  heat.set(tmp);
  return heat;
}

/**
 * 重さ → 色（RGB 0..1）。0 = 青緑（流れている）… 0.5 = 橙 … 1 = 赤。
 * ミニマップの車の点と同じ配色（流れている / 減速 / 停止）に合わせる。
 */
export function heatColor(h, out = [0, 0, 0]) {
  const t = Math.min(1, Math.max(0, h));
  // 青緑 #2dd4bf → 橙 #f5a524 → 赤 #e5484d
  const a = [0x2d / 255, 0xd4 / 255, 0xbf / 255], b = [0xf5 / 255, 0xa5 / 255, 0x24 / 255], c = [0xe5 / 255, 0x48 / 255, 0x4d / 255];
  const mix = (p, q, u) => { out[0] = p[0] + (q[0] - p[0]) * u; out[1] = p[1] + (q[1] - p[1]) * u; out[2] = p[2] + (q[2] - p[2]) * u; return out; };
  return t < 0.5 ? mix(a, b, t / 0.5) : mix(b, c, (t - 0.5) / 0.5);
}

/** 渋滞の要約: 重さ 0.3 以上の区間の割合と、最も重い区間の位置 [m] */
export function heatSummary(heat) {
  let jammed = 0, maxH = 0, maxK = 0;
  for (let k = 0; k < heat.length; k++) {
    if (heat[k] >= 0.3) jammed++;
    if (heat[k] > maxH) { maxH = heat[k]; maxK = k; }
  }
  return { jammedRatio: jammed / heat.length, maxHeat: maxH, maxAt: maxK * (LENGTH / heat.length) };
}
