// shared/heat.js — 渋滞の重さの区間化
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { jamHeat, heatColor, heatSummary, HEAT_SEGMENTS } from '../src/shared/heat.js';

test('全車が基準速度なら重さは 0', () => {
  const cars = Array.from({ length: 10 }, (_, i) => ({ s: i * 100, v: 12 }));
  const h = jamHeat(cars, 12);
  assert.equal(h.length, HEAT_SEGMENTS);
  assert.ok(h.every((x) => x === 0));
});

test('止まった車の周りだけ重くなり、周回路の端をまたいでも巻く', () => {
  const h = jamHeat([{ s: 999, v: 0 }], 12);
  const seg = (s) => h[Math.floor(s / 2) % HEAT_SEGMENTS];
  assert.ok(seg(999) > 0.8, `stopped ${seg(999)}`);
  assert.ok(seg(1) > 0.3, `wrapped ${seg(1)}`);      // 0 m 付近へ巻く
  assert.equal(seg(500), 0);
  assert.ok(heatSummary(h).jammedRatio > 0 && heatSummary(h).jammedRatio < 0.05);
});

test('heatColor は 0 で青緑、1 で赤、範囲外はクランプ', () => {
  const [r0, g0] = heatColor(0);
  const [r1, g1] = heatColor(1);
  assert.ok(g0 > r0, 'teal');
  assert.ok(r1 > g1, 'red');
  assert.deepEqual(heatColor(-5), heatColor(0));
  assert.deepEqual(heatColor(9), heatColor(1));
});

test('出力配列を再利用でき、基準速度が不正なら 0 で返す', () => {
  const out = new Float32Array(HEAT_SEGMENTS);
  const h = jamHeat([{ s: 10, v: 0 }], 12, out);
  assert.equal(h, out);
  assert.ok(jamHeat([{ s: 10, v: 0 }], 0).every((x) => x === 0));
});
