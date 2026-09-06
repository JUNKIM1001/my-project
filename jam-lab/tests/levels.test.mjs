// sim/levels.js — レベル定義の必須フィールド・星判定・evaluate の出力
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LEVELS, PLAY_LEVELS, getLevel, evaluate } from '../src/sim/levels.js';

const baseSummary = {
  affectedCount: 0, totalTimeLoss: 0, stoppedCount: 0, waveSpeed: null,
  meanSpeed: 12, flow: 2000, density: 48, playerMinGapTime: 1.8, playerBrakeEvents: 0, eventTime: 5,
};

test('全レベルに必須フィールドがある', () => {
  assert.equal(LEVELS.length, 6);
  assert.equal(PLAY_LEVELS.length, 5);
  assert.deepEqual(LEVELS.map((l) => l.id), ['brake-once', 'absorb-wave', 'density', 'reaction', 'sag', 'free']);
  assert.deepEqual(PLAY_LEVELS.map((l) => l.no), ['01', '02', '03', '04', '05']);
  for (const l of LEVELS) {
    assert.ok(typeof l.title === 'string' && l.title.length > 0, `${l.id} title`);
    assert.ok(typeof l.question === 'string' && l.question.length > 0);
    assert.ok(Array.isArray(l.briefing) && l.briefing.length >= 2 && l.briefing.length <= 3);
    assert.ok(typeof l.howTo === 'string');
    assert.ok(l.simConfig && Number.isFinite(l.simConfig.carCount));
    assert.ok(l.playerMode === 'auto' || l.playerMode === 'manual');
    assert.ok(Number.isFinite(l.durationSec) && l.durationSec > 0);
    assert.ok(Array.isArray(l.script));
    for (const ev of l.script) {
      assert.ok(Number.isFinite(ev.at));
      assert.ok(['pulseBrake', 'leaderBrake', 'hint', 'markEvent'].includes(ev.action), `${l.id} action ${ev.action}`);
      assert.ok(typeof ev.args === 'object');
    }
    assert.ok(Array.isArray(l.goals));
    assert.ok(l.lesson && typeof l.lesson.title === 'string' && Array.isArray(l.lesson.body) && typeof l.lesson.fact === 'string');
    assert.equal(typeof l.stars, 'function');
    if (l.quiz) {
      assert.ok(Array.isArray(l.quiz.choices) && l.quiz.choices.length >= 2);
      assert.ok(l.quiz.answer >= 0 && l.quiz.answer < l.quiz.choices.length);
    }
  }
  assert.equal(getLevel('sag').no, '05');
  assert.equal(getLevel('sag').simConfig.sag, true);
  assert.equal(getLevel('reaction').simConfig.tau, 1.5);
  assert.equal(getLevel('reaction').simConfig.carCount, 22);
  assert.equal(getLevel('density').simConfig.carCount, 72);
  assert.deepEqual(getLevel('density').densityRange, [40, 90]);
  assert.ok(getLevel('absorb-wave').script.some((e) => e.action === 'leaderBrake' && e.at === 15));
  assert.ok(getLevel('density').script.some((e) => e.action === 'markEvent' && e.at === 0), '03 は開始時に計測開始');
  assert.ok(getLevel('sag').script.some((e) => e.action === 'markEvent' && e.at === 0), '05 は開始時に計測開始');
  assert.equal(getLevel('nope'), null);
});

test('stars は 0..3 の整数で決定論的', () => {
  const ctxs = [
    { completed: true, quizCorrect: true, playerSagMinSpeedRatio: 0.95, playerPulses: 1, densitiesTried: [72, 40] },
    { completed: true, quizCorrect: false, playerSagMinSpeedRatio: 0.5 },
    { completed: false },
    {},
    { densitiesTried: 'garbage', densityRuns: [null, { stoppedCount: 'x' }] },
  ];
  const summaries = [
    baseSummary,
    { ...baseSummary, affectedCount: 47, stoppedCount: 30, totalTimeLoss: 3000 },
    { ...baseSummary, affectedCount: 8, stoppedCount: 2, totalTimeLoss: 600, density: 72 },
  ];
  for (const l of LEVELS) for (const c of ctxs) for (const s of summaries) {
    const a = l.stars(s, c);
    const b = l.stars(s, c);
    assert.equal(a, b);
    assert.ok(Number.isInteger(a) && a >= 0 && a <= 3, `${l.id} stars=${a}`);
  }
});

test('01: ブレーキを踏んで波速を計測しなければ 0、観察で 1、5 台以上に伝わって +1、クイズ正解で +1', () => {
  const l = getLevel('brake-once');
  assert.equal(l.quiz.q, '渋滞の波はどちらへ進んだ？');
  assert.deepEqual(l.quiz.choices, ['前へ', '後ろへ', 'その場にとどまる']);
  assert.equal(l.quiz.choices[l.quiz.answer], '後ろへ');
  const wave = { ...baseSummary, waveSpeed: -17.2, affectedCount: 12 };
  assert.equal(l.stars(baseSummary, { completed: true, quizCorrect: true, playerPulses: 1 }), 0, '波速未計測（null）なら 0');
  assert.equal(l.stars(wave, { completed: true, quizCorrect: true, playerPulses: 0 }), 0, 'ブレーキを踏んでいなければ 0');
  assert.equal(l.stars(wave, { completed: true, quizCorrect: true }), 0, 'playerPulses 未指定は踏んでいない扱い');
  assert.equal(l.stars({ ...wave, waveSpeed: 12 }, { completed: true, quizCorrect: true, playerPulses: 1 }), 0, '波速が正（前方）なら 0');
  assert.equal(l.stars({ ...wave, affectedCount: 3 }, { completed: true, quizCorrect: false, playerPulses: 1 }), 1, '観察だけで 1');
  assert.equal(l.stars({ ...wave, affectedCount: 4 }, { completed: true, quizCorrect: true, playerPulses: 1 }), 2, '4 台では伝播の星なし');
  assert.equal(l.stars({ ...wave, affectedCount: 5 }, { completed: true, quizCorrect: false, playerPulses: 1 }), 2, '5 台以上で +1');
  assert.equal(l.stars(wave, { completed: true, quizCorrect: true, playerPulses: 2 }), 3);
  assert.equal(l.stars(wave, { completed: false, quizCorrect: true, playerPulses: 1 }), 0, '未完走は 0');
  const r = evaluate(l, wave, { completed: true, quizCorrect: true, playerPulses: 1 });
  assert.equal(r.stars, 3);
  assert.ok(r.lines.some((s) => s.startsWith('★') && s.includes('ブレーキで波を起こし')));
  assert.ok(r.lines.some((s) => s.startsWith('★') && s.includes('12 台に伝わった')));
  assert.ok(r.lines.some((s) => s.startsWith('★') && s.includes('クイズ正解')));
  const r0 = evaluate(l, baseSummary, { completed: true, quizCorrect: true, playerPulses: 0 });
  assert.equal(r0.stars, 0);
  assert.ok(r0.lines.some((s) => s.startsWith('☆') && s.includes('ブレーキを踏まなかった')));
});

test('03: 完了で 1、密度を 2 通り以上試して +1、損失 15 秒/台以下 または 臨界を挟んで +1', () => {
  const d = getLevel('density');
  const s72 = (loss, stopped = 0) => ({ ...baseSummary, density: 72, totalTimeLoss: 71 * loss, stoppedCount: stopped });
  assert.equal(d.stars(s72(5), { completed: true }), 2, '損失は小さいが密度は 1 通り');
  assert.equal(d.stars(s72(5), { completed: true, densitiesTried: [72] }), 2, '初期値だけ');
  assert.equal(d.stars(s72(5), { completed: true, densitiesTried: [72, 50] }), 3);
  assert.equal(d.stars(s72(15), { completed: true, densitiesTried: [50, 72] }), 3, '境界値 15');
  assert.equal(d.stars(s72(20), { completed: true, densitiesTried: [72, 50] }), 2, '損失 20 で臨界も挟んでいない');
  assert.equal(d.stars(s72(40), { completed: true }), 1);
  assert.equal(d.stars(s72(5), { completed: false, densitiesTried: [72, 50] }), 0);
  // 臨界を挟む: 50 台で 60 秒走って停止 0（densityRuns）+ 最終 72 台で停止あり
  const runs = [{ carCount: 50, sec: 60, stoppedCount: 0, totalTimeLoss: 100, density: 50 }];
  assert.equal(d.stars(s72(30, 6), { completed: true, densitiesTried: [72, 50], densityRuns: runs }), 3, '臨界を挟んだ');
  assert.equal(d.stars(s72(30, 0), { completed: true, densitiesTried: [72, 50], densityRuns: runs }), 2, '両方とも停止なしでは挟んでいない');
  const shortRun = [{ carCount: 50, sec: 5, stoppedCount: 0, totalTimeLoss: 0, density: 50 }];
  assert.equal(d.stars(s72(30, 6), { completed: true, densitiesTried: [72, 50], densityRuns: shortRun }), 2, '5 秒で再スタートした走行は「渋滞なし」の証拠にならない');
  // 最終走行が停止 0 で、以前の走行（90 台）で停止あり → 挟んだ
  const jam = [{ carCount: 90, sec: 40, stoppedCount: 20, totalTimeLoss: 2000, density: 90 }];
  assert.equal(d.stars({ ...baseSummary, density: 50, totalTimeLoss: 49 * 30, stoppedCount: 0 }, { completed: true, densitiesTried: [72, 90, 50], densityRuns: jam }), 3);
  const r = evaluate(d, s72(30, 6), { completed: true, densitiesTried: [72, 50], densityRuns: runs });
  assert.ok(r.lines.some((s) => s.startsWith('★') && s.includes('2 通り試した') && s.includes('50 / 72')));
  assert.ok(r.lines.some((s) => s.startsWith('★') && s.includes('臨界密度を挟んだ')));
  const r1 = evaluate(d, s72(40), { completed: true });
  assert.ok(r1.lines.some((s) => s.startsWith('☆') && s.includes('1 通りだけ')));
});

test('02: 停止 0 台で 3、3 台以下で 2、それ以上で 1', () => {
  const l = getLevel('absorb-wave');
  assert.equal(l.stars({ ...baseSummary, stoppedCount: 0 }, { completed: true }), 3);
  assert.equal(l.stars({ ...baseSummary, stoppedCount: 3 }, { completed: true }), 2);
  assert.equal(l.stars({ ...baseSummary, stoppedCount: 4 }, { completed: true }), 1);
  assert.equal(l.stars({ ...baseSummary, stoppedCount: 0 }, { completed: false }), 0);
});

test('03 / 04 / 05 のしきい値は単調（悪い結果ほど星が減る）', () => {
  const d = getLevel('density');
  const tried = { completed: true, densitiesTried: [72, 50] };
  assert.equal(d.stars({ ...baseSummary, density: 72, totalTimeLoss: 71 * 5 }, tried), 3);
  assert.equal(d.stars({ ...baseSummary, density: 72, totalTimeLoss: 71 * 15 }, tried), 3, '境界値');
  assert.equal(d.stars({ ...baseSummary, density: 72, totalTimeLoss: 71 * 20 }, tried), 2);
  assert.equal(d.stars({ ...baseSummary, density: 72, totalTimeLoss: 71 * 40 }, { completed: true }), 1);
  const r = getLevel('reaction');
  assert.equal(r.stars({ ...baseSummary, affectedCount: 3 }, { completed: true }), 3);
  assert.equal(r.stars({ ...baseSummary, affectedCount: 5 }, { completed: true }), 2);
  assert.equal(r.stars({ ...baseSummary, affectedCount: 10 }, { completed: true }), 2);
  assert.equal(r.stars({ ...baseSummary, affectedCount: 21 }, { completed: true }), 1);
  const s = getLevel('sag');
  assert.equal(s.stars({ ...baseSummary, density: 36, totalTimeLoss: 35 * 6 }, { completed: true, playerSagMinSpeedRatio: 0.7 }), 3);
  assert.equal(s.stars({ ...baseSummary, density: 36, totalTimeLoss: 35 * 6 }, { completed: true, playerSagMinSpeedRatio: 0.5 }), 2, '速度を落とすと 3 は取れない');
  assert.equal(s.stars({ ...baseSummary, density: 36, totalTimeLoss: 35 * 12 }, { completed: true, playerSagMinSpeedRatio: 0.8 }), 2);
  assert.equal(s.stars({ ...baseSummary, density: 36, totalTimeLoss: 35 * 30 }, { completed: true, playerSagMinSpeedRatio: 0.9 }), 1);
  assert.equal(s.stars({ ...baseSummary, density: 36, totalTimeLoss: 35 * 6, playerSagMinSpeedRatio: 0.7 }, { completed: true }), 3, 'ctx 未指定なら summary の値を使う');
  assert.equal(s.stars({ ...baseSummary, density: 36, totalTimeLoss: 0 }, { completed: true }), 2, 'ratio 不明でも損失が小さければ 2');
  assert.equal(getLevel('free').stars(baseSummary, { completed: true }), 0);
});

test('evaluate は stars と表示行を返す', () => {
  for (const l of LEVELS) {
    const r = evaluate(l, { ...baseSummary, waveSpeed: -17.2 }, { completed: true, quizCorrect: true, playerSagMinSpeedRatio: 0.9, playerPulses: 1 });
    assert.ok(Number.isInteger(r.stars) && r.stars >= 0 && r.stars <= 3);
    assert.ok(Array.isArray(r.lines) && r.lines.length >= 4);
    assert.ok(r.lines.every((s) => typeof s === 'string' && s.length > 0));
    assert.ok(r.lines.some((s) => s.includes('-17.2')), '波速度の表示');
    if (l.id !== 'free') {
      const reasons = r.lines.filter((s) => s.startsWith('★ ') || s.startsWith('☆ '));
      assert.equal(reasons.length, 3, `${l.id}: 星 3 つぶんの理由行`);
      assert.equal(reasons.filter((s) => s.startsWith('★')).length, r.stars, `${l.id}: ★ の理由行数 = 星数`);
    }
  }
  // 02 / 04 / 05 の星ごとの理由行
  const r2 = evaluate(getLevel('absorb-wave'), { ...baseSummary, stoppedCount: 2 }, { completed: true });
  assert.equal(r2.stars, 2);
  assert.ok(r2.lines.some((s) => s.startsWith('★') && s.includes('2 台（3 台以下）')));
  assert.ok(r2.lines.some((s) => s.startsWith('☆') && s.includes('1 台も止めない')));
  const r4 = evaluate(getLevel('reaction'), { ...baseSummary, affectedCount: 3 }, { completed: true });
  assert.equal(r4.stars, 3);
  assert.ok(r4.lines.some((s) => s.startsWith('★') && s.includes('4 台以下')));
  const r5 = evaluate(getLevel('sag'), { ...baseSummary, density: 36, totalTimeLoss: 35 * 10 }, { completed: true, playerSagMinSpeedRatio: 0.5 });
  assert.equal(r5.stars, 2);
  assert.ok(r5.lines.some((s) => s.startsWith('☆') && s.includes('50%')));
  const r = evaluate(getLevel('brake-once'), baseSummary, { completed: false, quizCorrect: false });
  assert.equal(r.stars, 0);
  assert.ok(r.lines[0].includes('最後まで'));
  assert.ok(r.lines.some((s) => s.includes('計測不足')));
  assert.ok(r.lines.some((s) => s.includes('不正解') && s.includes('後ろへ')));
});
