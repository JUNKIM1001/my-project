// sim/metrics.js — 計測の定義・重複計上なし・イベント前の非混入・バッファ長
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createSim } from '../src/sim/model.js';
import { createMetrics } from '../src/sim/metrics.js';

const DT = 0.05;
function run(sim, m, seconds) {
  const steps = Math.round(seconds / DT);
  for (let i = 0; i < steps; i++) { sim.step(DT); m.update(sim); }
}

test('markEvent 前は累積値が 0 のまま、eventTime は null', () => {
  const sim = createSim({ carCount: 72, noise: 0.3, seed: 5 });
  const m = createMetrics(sim, { freeFlowSpeed: sim.params.v0 });
  run(sim, m, 30);
  const s = m.summary();
  assert.equal(m.eventTime, null);
  assert.equal(s.eventTime, null);
  assert.equal(s.affectedCount, 0);
  assert.equal(s.totalTimeLoss, 0);
  assert.equal(s.stoppedCount, 0);
  assert.equal(s.waveSpeed, null);
  assert.equal(s.density, 72);
  assert.ok(Math.abs(s.flow - 72 * s.meanSpeed * 3.6) < 1e-9);
  assert.ok(s.playerMinGapTime > 0, 'プレイヤー指標はイベント前でも計測');
});

test('基準速度は v0 と定常速度の小さい方（高密度で全車が影響ありにならない）', () => {
  const sim = createSim({ carCount: 48 });
  const m = createMetrics(sim, { freeFlowSpeed: sim.params.v0 });
  assert.ok(Math.abs(m.refSpeed - sim.equilibriumSpeed) < 1e-12);
  m.markEvent();
  run(sim, m, 20);
  assert.equal(m.summary().affectedCount, 0, '定常走行中は影響台数 0');
  assert.ok(m.summary().totalTimeLoss < 1e-6);
});

test('走行中に T を変えると equilibriumSpeed が変わり、update 後の refSpeed / summary.refSpeed が追従する', () => {
  const sim = createSim({ carCount: 48 });
  const m = createMetrics(sim, { freeFlowSpeed: sim.params.v0 });
  m.markEvent();
  run(sim, m, 10);
  const ref0 = m.refSpeed;
  assert.ok(Math.abs(ref0 - sim.equilibriumSpeed) < 1e-12);
  assert.equal(m.summary().affectedCount, 0);
  sim.setParams({ T: 2.0 });
  const eq1 = sim.equilibriumSpeed;
  assert.ok(eq1 < ref0, '定常速度が下がる');
  sim.step(DT); m.update(sim);
  assert.ok(Math.abs(m.refSpeed - eq1) < 1e-12, `refSpeed=${m.refSpeed} eq=${eq1}`);
  assert.ok(Math.abs(m.summary().refSpeed - eq1) < 1e-12);
  // 車列が新しい定常速度へ落ち着く過程で、基準が旧条件のままなら全車「影響あり」になるが、追従していれば 0 のまま
  run(sim, m, 60);
  assert.equal(m.summary().affectedCount, 0, '基準速度が追従しているので定常減速は影響と数えない');
  // v0 を上げても基準は freeFlowSpeed（作成時の v0）と新しい定常速度の小さい方
  sim.setParams({ T: 0.5, v0: 40 });
  sim.step(DT); m.update(sim);
  assert.ok(Math.abs(m.refSpeed - Math.min(22.2, sim.equilibriumSpeed)) < 1e-12);
});

test('波の到達標本: 同時刻の複数標本は後退距離の昇順、50 m 以上の後戻り標本は捨てる', () => {
  const sim = createSim({ carCount: 48 });
  const m = createMetrics(sim);
  run(sim, m, 2);
  m.markEvent();
  sim.pulseBrake({ decel: 2, duration: 2 });
  run(sim, m, 60);
  const samples = m.waveSamples;
  assert.ok(samples.length >= 4);
  for (let i = 1; i < samples.length; i++) {
    assert.ok(samples[i].t >= samples[i - 1].t, '時刻は非減少');
    assert.ok(samples[i].d >= samples[i - 1].d - 50 - 1e-6, `50 m 以上の後戻り: ${samples[i - 1].d} → ${samples[i].d}`);
    if (samples[i].t === samples[i - 1].t) assert.ok(samples[i].d >= samples[i - 1].d, '同時刻の標本は昇順');
  }
  // 高密度・ノイズありで複数の波が同時に立つ場合でも、回帰は有限値か null で、標本は後戻り 50 m 以内
  const noisy = createSim({ carCount: 80, noise: 0.3, seed: 21 });
  const mn = createMetrics(noisy);
  mn.markEvent();
  run(noisy, mn, 90);
  const ns = mn.waveSamples;
  for (let i = 1; i < ns.length; i++) assert.ok(ns[i].d >= ns[i - 1].d - 50 - 1e-6);
  const w = mn.summary().waveSpeed;
  assert.ok(w === null || Number.isFinite(w));
});

test('affectedCount は重複計上しない・プレイヤーを除く・上限は N-1', () => {
  const sim = createSim({ carCount: 48 });
  const m = createMetrics(sim);
  run(sim, m, 5);
  sim.pulseBrake({ decel: 2, duration: 2 });
  m.markEvent();
  let prev = 0;
  for (let k = 0; k < 20; k++) {
    run(sim, m, 4);
    const c = m.summary().affectedCount;
    assert.ok(c >= prev, '単調非減少');
    assert.ok(c <= 47);
    prev = c;
  }
  assert.ok(prev > 0);
  // パルスで 1 回。周回路なので後で自分の作った渋滞に追いつき再ブレーキすることはある
  assert.ok(m.summary().playerBrakeEvents >= 1, 'パルスは 1 回以上のブレーキとして数える');
});

test('waveSpeed は標本 4 未満で null、負の値は後方への伝播', () => {
  const sim = createSim({ carCount: 48 });
  const m = createMetrics(sim);
  m.markEvent();
  sim.pulseBrake({ decel: 2, duration: 2 });
  run(sim, m, 3);
  assert.ok(m.waveSamples.length < 4);
  assert.equal(m.summary().waveSpeed, null);
  run(sim, m, 80);
  const w = m.summary().waveSpeed;
  assert.ok(w !== null && w < 0, `waveSpeed=${w}`);
  // 標本の後退距離: 直後の車はイベント地点を少し通り過ぎてから減速する（僅かに負を許容）が、
  // 波は後方へ進むので単調増加し、最後の標本は最初より十分後ろ
  const samples = m.waveSamples;
  assert.ok(samples.every((p) => p.d >= -60), JSON.stringify(samples.slice(0, 3)));
  for (let i = 1; i < samples.length; i++) assert.ok(samples[i].d >= samples[i - 1].d - 1e-6);
  assert.ok(samples[samples.length - 1].d > samples[0].d + 100);
  assert.ok(w > -30 && w < -5, `waveSpeed=${w}`);
});

test('history は 1 秒間引き・最大 600 点、spaceTime は 0.5 秒・最大 240 行', () => {
  const sim = createSim({ carCount: 30 });
  const m = createMetrics(sim);
  run(sim, m, 150);
  assert.ok(m.history.t.length <= 600);
  assert.equal(m.history.t.length, 151, '0..150 秒で 151 点');
  for (let i = 1; i < m.history.t.length; i++) {
    assert.ok(Math.abs(m.history.t[i] - m.history.t[i - 1] - 1) < 1e-6);
  }
  assert.equal(m.spaceTime.rows.length, 240);
  assert.equal(m.spaceTime.times.length, 240);
  assert.ok(m.spaceTime.rows[0] instanceof Float32Array);
  assert.equal(m.spaceTime.rows[0].length, 30);
  assert.ok(Math.abs(m.spaceTime.times[1] - m.spaceTime.times[0] - 0.5) < 1e-6);
  // 古い行から捨てる: 最新行の時刻は 150 に近い
  assert.ok(m.spaceTime.times[239] > 149);
  for (const v of m.spaceTime.rows[239]) assert.ok(v >= 0 && v <= 1);
});

test('stoppedCount と totalTimeLoss（強い先行車ブレーキ）', () => {
  const sim = createSim({ carCount: 48, tau: 1.5 });
  const m = createMetrics(sim);
  run(sim, m, 5);
  const idx = sim.triggerLeaderBrake({ aheadIndex: 3, decel: 3, duration: 2.5 });
  m.markEvent({ s: sim.cars[idx].s });
  run(sim, m, 60);
  const s = m.summary();
  assert.ok(s.stoppedCount > 0);
  assert.ok(s.totalTimeLoss > 0);
  assert.ok(s.stoppedCount <= 47);
});

test('playerSagMinSpeedRatio はサグ有効時だけ、上り区間通過後に値を持つ', () => {
  const flat = createSim({ carCount: 36 });
  const mf = createMetrics(flat);
  run(flat, mf, 60);
  assert.equal(mf.summary().playerSagMinSpeedRatio, null);
  const sim = createSim({ carCount: 36, sag: true });
  const m = createMetrics(sim);
  run(sim, m, 10); // まだ 400 m に届かない（約 17 m/s）
  assert.equal(m.summary().playerSagMinSpeedRatio, null);
  run(sim, m, 50);
  const r = m.summary().playerSagMinSpeedRatio;
  assert.ok(r !== null && r > 0 && r < 1, `ratio=${r}`);
});

test('reset で全累積とバッファがクリアされる', () => {
  const sim = createSim({ carCount: 48 });
  const m = createMetrics(sim);
  m.markEvent();
  sim.pulseBrake({ decel: 2, duration: 2 });
  run(sim, m, 30);
  assert.ok(m.summary().affectedCount > 0);
  sim.reset({ carCount: 60 });
  m.reset();
  assert.equal(m.eventTime, null);
  assert.equal(m.summary().affectedCount, 0);
  assert.equal(m.history.t.length, 1, 't=0 の初期標本だけ');
  assert.equal(m.spaceTime.rows.length, 1);
  assert.equal(m.spaceTime.rows[0].length, 60);
  assert.ok(Math.abs(m.refSpeed - sim.equilibriumSpeed) < 1e-12, '基準速度は新しい台数で再計算');
});
