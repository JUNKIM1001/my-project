// sim/model.js — IDM + 反応遅れ + 周回路の数値的性質テスト
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createSim, MIN_GAP, LIMITS, equilibriumSpeed } from '../src/sim/model.js';
import { createMetrics } from '../src/sim/metrics.js';
import { LENGTH, CAR_LENGTH, forwardDistance } from '../src/shared/track.js';

const DT = 0.05;
function run(sim, seconds, onStep) {
  const steps = Math.round(seconds / DT);
  for (let i = 0; i < steps; i++) { sim.step(DT); if (onStep) onStep(sim); }
}
/** 全車の gap >= 0、v >= 0、巡回順序不変（cars[i] の先行車は cars[(i+1)%N]。またぎ距離の総和がちょうど LENGTH）を検査 */
function assertSane(sim, label = '') {
  const n = sim.carCount;
  let total = 0;
  for (let i = 0; i < n; i++) {
    const c = sim.cars[i];
    assert.ok(c.v >= 0, `${label} v<0: car ${i} v=${c.v}`);
    assert.ok(Number.isFinite(c.s) && c.s >= 0 && c.s < LENGTH, `${label} s 範囲外: ${c.s}`);
    const gap = sim.gapOf(i);
    assert.ok(gap >= -1e-9, `${label} gap<0: car ${i} gap=${gap}`);
    total += forwardDistance(c.s, sim.cars[(i + 1) % n].s);
  }
  assert.ok(Math.abs(total - LENGTH) < 1e-6, `${label} 巡回順序が崩れた: 周長 ${total}`);
}
/** 全車の gap >= MIN_GAP（丸め誤差 1e-9 許容）と NaN なしを検査 */
function assertMinGap(sim, label = '') {
  for (let i = 0; i < sim.carCount; i++) {
    const c = sim.cars[i];
    assert.ok(Number.isFinite(c.s) && Number.isFinite(c.v) && Number.isFinite(c.a), `${label} NaN: car ${i} s=${c.s} v=${c.v} a=${c.a}`);
    const gap = sim.gapOf(i);
    assert.ok(gap >= MIN_GAP - 1e-9, `${label} gap<MIN_GAP: car ${i} gap=${gap}`);
  }
}

test('(1) 同じ seed・同じ入力列で結果が一致する（ノイズあり）', () => {
  const cfg = { carCount: 48, noise: 0.3, seed: 123 };
  const a = createSim(cfg);
  const b = createSim(cfg);
  run(a, 20); run(b, 20);
  for (let i = 0; i < 48; i++) {
    assert.equal(a.cars[i].s, b.cars[i].s);
    assert.equal(a.cars[i].v, b.cars[i].v);
  }
  const c = createSim({ ...cfg, seed: 124 });
  run(c, 20);
  assert.notEqual(a.cars[5].v, c.cars[5].v, '別 seed なら異なる');
});

test('(2) 均等配置・定常速度から始めると 60 秒間均一のまま（noise 0）', () => {
  const sim = createSim({ carCount: 48, noise: 0 });
  run(sim, 60);
  let min = Infinity, max = -Infinity;
  for (const c of sim.cars) { min = Math.min(min, c.v); max = Math.max(max, c.v); }
  assert.ok(max - min < 0.05, `速度ばらつき ${max - min}`);
  assert.ok(Math.abs(sim.cars[0].v - sim.equilibriumSpeed) < 0.05, '定常速度を維持');
  assertSane(sim);
});

test('(3) pulseBrake で後方へ伝わる渋滞波（48 台 / T 1.05 / tau 0.65）', () => {
  const sim = createSim({ carCount: 48, T: 1.05, tau: 0.65, noise: 0 });
  const m = createMetrics(sim, { freeFlowSpeed: sim.params.v0 });
  run(sim, 5, (s) => m.update(s));
  sim.pulseBrake({ decel: 2.0, duration: 2.0 });
  m.markEvent();
  // パルス中はプレイヤーの a が強制値になっている
  sim.step(DT); m.update(sim);
  assert.ok(Math.abs(sim.player.a + 2.0) < 1e-9, `強制減速 a=${sim.player.a}`);
  assert.equal(sim.player.braking, true);
  run(sim, 85, (s) => m.update(s));
  const sum = m.summary();
  console.log(`  waveSpeed=${sum.waveSpeed?.toFixed(2)} km/h affectedCount=${sum.affectedCount} samples=${m.waveSamples.length}`);
  assert.notEqual(sum.waveSpeed, null);
  assert.ok(sum.waveSpeed < -5 && sum.waveSpeed > -30, `waveSpeed ${sum.waveSpeed}`);
  assert.ok(sum.affectedCount > 5, `affectedCount ${sum.affectedCount}`);
  assertSane(sim);
});

test('(4) 90 台 / noise 0.3 / tau 1.5 で 120 秒: 追い越し・負速度なし、巡回順序不変、毎ステップ全ギャップ >= MIN_GAP', () => {
  const sim = createSim({ carCount: 90, noise: 0.3, tau: 1.5, seed: 7 });
  let stepNo = 0;
  run(sim, 120, (s) => {
    stepNo++;
    assertMinGap(s, `t=${s.time.toFixed(2)}`);
    if (stepNo % 5 === 0) assertSane(s, `t=${s.time.toFixed(2)}`);
  });
  assertSane(sim, 'final');
  assert.equal(sim.playerIndex, 0);
  assert.equal(sim.cars[0].isPlayer, true);
  for (let i = 0; i < 90; i++) assert.equal(sim.cars[i].id, i, '配列順（巡回順序）は不変');
});

test('(4b) 衝突ガードは 1 周またぎを含む連鎖押し戻しでも MIN_GAP を維持する（90 台・cars[0] が急停止）', () => {
  // cars[0]（s=0 付近）を 30 秒間フル減速で止める → 後続 89 台が cars[n-1]→cars[0] のまたぎを含めて連鎖的に詰まる
  const sim = createSim({ carCount: 90, noise: 0.3, tau: 1.5, seed: 9 });
  sim.pulseBrake({ decel: 9, duration: 30 });
  run(sim, 60, (s) => { assertMinGap(s, `t=${s.time.toFixed(2)}`); assertSane(s, `t=${s.time.toFixed(2)}`); });
  assert.ok(sim.gapOf(sim.carCount - 1) >= MIN_GAP - 1e-9, 'またぎ位置（最後尾→cars[0]）のギャップ');
  // 極端ケース: 全車を停止した先行車の直後（MIN_GAP 未満）に詰めて置く → 1 ステップで全違反が解消され、
  // 押し戻しの連鎖で先行車が後続車を「逆向きに追い越す」ことも起きない（巡回順序が保たれる）
  const dense = createSim({ carCount: 40, noise: 0 });
  dense.cars.forEach((c, i) => { c.s = i * (CAR_LENGTH + 0.05); c.v = i === 0 ? 0 : 10; });
  dense.pulseBrake({ decel: 9, duration: 10 });
  dense.step(DT);
  assertMinGap(dense, 'dense');
  assertSane(dense, 'dense');
  run(dense, 5, (s) => { assertMinGap(s, 'dense'); assertSane(s, 'dense'); });
});

test('(5) 最後尾の先行車は cars[0]（1 周またぎのギャップ）', () => {
  const sim = createSim({ carCount: 10 });
  const last = sim.carCount - 1;
  assert.equal(sim.leaderIndex(last), 0);
  sim.cars[last].s = 998;
  sim.cars[0].s = 5;
  assert.ok(Math.abs(sim.gapOf(last) - (7 - CAR_LENGTH)) < 1e-9);
  // 前が止まっていても またぎ位置で衝突しない
  sim.cars[0].v = 0;
  sim.cars[last].v = 15;
  run(sim, 5);
  assert.ok(sim.gapOf(last) >= MIN_GAP - 1e-9);
  assertSane(sim);
});

test('(6a) setParams の値域: 不正値は clamp / 無視され、10 秒走っても NaN が出ない', () => {
  const garbage = { v0: -5, a: 0, b: NaN, T: -1, s0: -3, tau: 99, noise: Infinity };
  // createSim にゴミを渡した場合
  const fromCtor = createSim({ carCount: 48, ...garbage, seed: 'x', initialSpeedRatio: 'abc' });
  assert.equal(fromCtor.params.v0, LIMITS.v0[0]);
  assert.equal(fromCtor.params.a, LIMITS.a[0]);
  assert.equal(fromCtor.params.b, 1.6, '非有限値は既定値を維持');
  assert.equal(fromCtor.params.T, 0);
  assert.equal(fromCtor.params.s0, 0);
  assert.equal(fromCtor.params.tau, LIMITS.tau[1]);
  assert.equal(fromCtor.params.noise, 0, 'Infinity は非有限値なので無視 → 既定値');
  assert.equal(fromCtor.params.seed, 1);
  assert.equal(fromCtor.params.initialSpeedRatio, 1);
  assert.ok(Number.isFinite(fromCtor.equilibriumSpeed));
  run(fromCtor, 10, (s) => assertMinGap(s));
  // 走行中の setParams にゴミを渡した場合（直前の値を維持または clamp）
  const sim = createSim({ carCount: 60, noise: 0.2, seed: 3 });
  run(sim, 5);
  sim.setParams({ ...garbage, carCount: NaN });
  assert.equal(sim.params.v0, 1);
  assert.equal(sim.params.a, 0.1);
  assert.equal(sim.params.b, 1.6, 'NaN は無視して直前の値');
  assert.equal(sim.params.T, 0);
  assert.equal(sim.params.s0, 0);
  assert.equal(sim.params.tau, 5);
  assert.equal(sim.params.noise, 0.2, 'Infinity は無視して直前の値');
  sim.setParams({ noise: 7 });
  assert.equal(sim.params.noise, LIMITS.noise[1], '範囲外は clamp');
  assert.equal(sim.carCount, 60);
  run(sim, 10, (s) => assertMinGap(s));
  assert.ok(Number.isFinite(sim.equilibriumSpeed));
  // 手動モードでも NaN なし。非数値は無視
  sim.setPlayerControl({ mode: 'manual', throttle: 1, brake: 0 });
  assert.doesNotThrow(() => sim.setParams({ v0: '30', T: null, tau: undefined }));
  assert.doesNotThrow(() => sim.setParams(null));
  assert.equal(sim.params.v0, 1);
  run(sim, 5, (s) => assertMinGap(s));
  // reset のオーバーライドも同じ検証
  sim.reset({ carCount: 30, v0: 0, a: -1, tau: -2, noise: -1 });
  assert.equal(sim.carCount, 30);
  assert.equal(sim.params.v0, 1);
  assert.equal(sim.params.a, 0.1);
  assert.equal(sim.params.tau, 0);
  assert.equal(sim.params.noise, 0);
  run(sim, 5, (s) => assertMinGap(s));
});

test('(6b) setParams で T / v0 / s0 を変えると定常速度 equilibriumSpeed が再計算される', () => {
  const sim = createSim({ carCount: 48 });
  const spacing = LENGTH / 48;
  const eq0 = sim.equilibriumSpeed;
  run(sim, 5);
  sim.setParams({ T: 2.0 });
  assert.ok(sim.equilibriumSpeed < eq0, `T を増やすと定常速度が下がる: ${eq0} → ${sim.equilibriumSpeed}`);
  assert.ok(Math.abs(sim.equilibriumSpeed - equilibriumSpeed(sim.params, spacing - CAR_LENGTH)) < 1e-12);
  sim.setParams({ v0: 30, s0: 1 });
  assert.ok(Math.abs(sim.equilibriumSpeed - equilibriumSpeed(sim.params, spacing - CAR_LENGTH)) < 1e-12);
  const eq1 = sim.equilibriumSpeed;
  sim.setParams({ noise: 0.3, tau: 1.0 }); // vEq に無関係なキーでは変わらない
  assert.equal(sim.equilibriumSpeed, eq1);
});

test('(6) 走行中の setParams（tau 変更）で例外なし・ギャップ維持', () => {
  const sim = createSim({ carCount: 60, noise: 0.2, seed: 11 });
  run(sim, 10);
  sim.pulseBrake({ decel: 3, duration: 2 });
  run(sim, 5, (s) => assertSane(s));
  assert.doesNotThrow(() => sim.setParams({ tau: 2.0 }));
  assert.equal(sim.params.tau, 2.0);
  run(sim, 15, (s) => assertSane(s));
  assert.doesNotThrow(() => sim.setParams({ tau: 0, T: 1.5, v0: 25, noise: 0 }));
  run(sim, 15, (s) => assertSane(s));
  assert.doesNotThrow(() => sim.setParams({ tau: 0.8 }));
  run(sim, 5, (s) => assertSane(s));
  // carCount は走行中には変わらない
  sim.setParams({ carCount: 10 });
  assert.equal(sim.carCount, 60);
  assert.equal(sim.params.carCount, 60);
});

test('(7) 手動: フルブレーキで停止 → フルスロットルでも先行車に衝突しない', () => {
  const sim = createSim({ carCount: 48 });
  sim.setPlayerControl({ mode: 'manual', throttle: 0, brake: 1 });
  run(sim, 10, (s) => assertSane(s));
  assert.equal(sim.player.v, 0, '停止している');
  sim.setPlayerControl({ throttle: 1, brake: 0 });
  let minGap = Infinity, maxV = 0;
  run(sim, 40, (s) => {
    assertSane(s);
    minGap = Math.min(minGap, s.gapOf(s.playerIndex));
    maxV = Math.max(maxV, s.player.v);
  });
  assert.ok(minGap >= MIN_GAP - 1e-9, `最小ギャップ ${minGap}`);
  assert.ok(maxV > sim.equilibriumSpeed, 'アクセルで加速はできる');
  assert.ok(sim.player.v <= sim.params.v0 * 1.5 + 1e-9, '手動の上限速度');
});

test('手動モードは遠くでは介入しない（自由にアクセル / 減速できる）', () => {
  const sim = createSim({ carCount: 12 }); // 車間 約 79 m
  sim.setPlayerControl({ mode: 'manual', throttle: 1, brake: 0 });
  sim.step(DT);
  assert.ok(Math.abs(sim.player.a - 3.0) < 1e-9, `throttle a=${sim.player.a}`);
  sim.setPlayerControl({ throttle: 0, brake: 1 });
  sim.step(DT);
  assert.ok(Math.abs(sim.player.a + 6.0) < 1e-9, `brake a=${sim.player.a}`);
  sim.setPlayerControl({ throttle: 0, brake: 0 });
  sim.step(DT);
  assert.equal(sim.player.a, 0, '惰行');
});

test('triggerLeaderBrake は指定台数前の車を強制減速させる', () => {
  const sim = createSim({ carCount: 48 });
  const idx = sim.triggerLeaderBrake({ aheadIndex: 3, decel: 3.0, duration: 2.5 });
  assert.equal(idx, 3);
  sim.step(DT);
  assert.ok(Math.abs(sim.cars[3].a + 3.0) < 1e-9);
  assert.ok(sim.cars[3].braking);
  assert.ok(!sim.cars[10].braking);
  run(sim, 3);
  assert.ok(sim.cars[3].a > -3.0 + 1e-9, '期間終了後は IDM に戻る');
});

test('reset で均等配置・定常速度に戻り、params は読み取り専用ビュー', () => {
  const sim = createSim({ carCount: 48 });
  run(sim, 5);
  sim.reset({ carCount: 72, sag: true });
  assert.equal(sim.carCount, 72);
  assert.equal(sim.time, 0);
  assert.equal(sim.params.sag, true);
  const spacing = LENGTH / 72;
  for (let i = 0; i < 72; i++) assert.ok(Math.abs(sim.cars[i].s - i * spacing) < 1e-9);
  assert.ok(Math.abs(sim.equilibriumSpeed - equilibriumSpeed(sim.params, spacing - CAR_LENGTH)) < 1e-12);
  assert.throws(() => { sim.params.T = 9; }, '凍結されたビュー');
  assert.equal(sim.params.T, 1.05);
});

test('サグ有効時は勾配抵抗が加速度に入る', () => {
  const sim = createSim({ carCount: 4, sag: true, tau: 0 });
  // 4 台なら車間が広く IDM 項はほぼ 0 → 上り区間の車は a ≈ -0.147 だけ下がる
  sim.cars.forEach((c, i) => { c.s = 100 + i * 200; c.v = sim.params.v0; });
  // cars[2] は s=500（上り +1.5%）
  sim.step(DT);
  assert.ok(sim.cars[2].a < -0.1 && sim.cars[2].a > -0.2, `上りの a=${sim.cars[2].a}`);
  assert.ok(Math.abs(sim.cars[0].a) < 0.02, `平坦の a=${sim.cars[0].a}`);
});
