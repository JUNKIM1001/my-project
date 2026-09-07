// sim/levels.js — レベル定義の必須フィールド・星判定（ctx.attempts ベース）・evaluate の出力
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LEVELS, PLAY_LEVELS, FREE_LEVEL, getLevel, evaluate, lossPerCar } from '../src/sim/levels.js';

const baseSummary = {
  affectedCount: 0, totalTimeLoss: 0, stoppedCount: 0, waveSpeed: null,
  meanSpeed: 12, flow: 2000, density: 48, playerMinGapTime: 1.8, playerBrakeEvents: 0, eventTime: 0,
  playerSagMinSpeedRatio: null,
};

/** 試行 1 件（実測値をそのまま使う） */
const at = (sec, affected, timeLoss, extra = {}) => ({
  sec, affected, timeLoss, stopped: 0, waveSpeed: null, carCount: 48, tau: 0.65, ...extra,
});

// 実測（20 秒観察）: 48 台 tau0.65 → 1.0 秒: 0 台 / 12.5 秒、1.5 秒: 15 台 / 30.6 秒、3.0 秒: 18 台 / 95.3 秒
const A_SHORT = at(1.2, 0, 18.9);
const A_LONG = at(3.0, 18, 95.3, { waveSpeed: -18.0 });
const A_TAP = at(1.5, 15, 30.6, { waveSpeed: -13.3 });

test('全レベルに必須フィールドがある（全レベル自動運転 + ブレーキのみ）', () => {
  assert.equal(LEVELS.length, 6);
  assert.equal(PLAY_LEVELS.length, 5);
  assert.deepEqual(LEVELS.map((l) => l.id), ['first-tap', 'how-long', 'crowded', 'slow-reaction', 'dont-brake', 'free']);
  assert.deepEqual(PLAY_LEVELS.map((l) => l.no), ['01', '02', '03', '04', '05']);
  assert.equal(FREE_LEVEL.id, 'free');
  for (const l of LEVELS) {
    assert.ok(typeof l.title === 'string' && l.title.length > 0, `${l.id} title`);
    assert.ok(typeof l.question === 'string' && l.question.length > 0);
    assert.ok(Array.isArray(l.briefing) && l.briefing.length >= 2 && l.briefing.length <= 3);
    assert.ok(typeof l.howTo === 'string');
    assert.ok(l.simConfig && Number.isFinite(l.simConfig.carCount));
    assert.equal(l.playerMode, 'auto', `${l.id}: 操作はブレーキのみ`);
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
  // 星のある 5 レベルはすべて criteria を 3 件返す
  for (const l of PLAY_LEVELS) {
    assert.equal(typeof l.criteria, 'function', `${l.id} criteria`);
    const cs = l.criteria(baseSummary, {});
    assert.equal(cs.length, 3, `${l.id}: criteria は 3 件`);
    for (const c of cs) {
      assert.equal(typeof c.ok, 'boolean');
      assert.ok(typeof c.label === 'string' && c.label.length > 0);
    }
  }
  assert.equal(getLevel('nope'), null);
});

test('プレイヤー向けテキストにアクセル操作が残っていない', () => {
  for (const l of LEVELS) {
    const text = [l.title, l.question, l.howTo, ...l.briefing, ...l.goals, l.lesson.title, ...l.lesson.body, l.lesson.fact,
      ...(l.quiz ? [l.quiz.q, ...l.quiz.choices, l.quiz.explain] : []),
      ...l.script.map((e) => (e.args && e.args.text) || '')].join('\n');
    assert.ok(!text.includes('アクセル'), `${l.id}: アクセルの記述が残っている`);
    assert.ok(!text.includes('↑'), `${l.id}: ↑ の記述が残っている`);
    assert.ok(!/\bW\b/.test(text), `${l.id}: W キーの記述が残っている`);
    assert.ok(l.howTo.includes('S / ↓'), `${l.id}: howTo にブレーキ操作`);
  }
});

test('シム設定は実測でキャリブレーションした値', () => {
  assert.equal(getLevel('first-tap').simConfig.carCount, 48);
  assert.equal(getLevel('how-long').simConfig.carCount, 48);
  assert.equal(getLevel('crowded').simConfig.carCount, 72);
  assert.equal(getLevel('crowded').simConfig.noise, 0.25);
  assert.deepEqual(getLevel('crowded').densityRange, [40, 90]);
  // 26 台 tau1.5: 無操作なら 180 秒渋滞しないが、2 秒踏むと影響 9 台
  assert.equal(getLevel('slow-reaction').simConfig.tau, 1.5);
  assert.equal(getLevel('slow-reaction').simConfig.carCount, 26);
  // 32 台: 踏まなければサグ上りの速度比 0.86、1 秒踏むと 0.70
  assert.equal(getLevel('dont-brake').simConfig.sag, true);
  assert.equal(getLevel('dont-brake').simConfig.carCount, 32);
  assert.deepEqual(FREE_LEVEL.densityRange, [20, 100]);
  for (const l of PLAY_LEVELS) {
    assert.ok(l.script.some((e) => e.action === 'markEvent' && e.at === 0), `${l.id}: 開始時に計測開始`);
  }
});

test('stars は 0..3 の整数で決定論的（壊れた ctx でも例外を出さない）', () => {
  const ctxs = [
    { completed: true, quizCorrect: true, playerSagMinSpeedRatio: 0.95, attempts: [A_SHORT, A_LONG], totalBrakeSec: 4.2 },
    { completed: true, quizCorrect: false, playerSagMinSpeedRatio: 0.5, attempts: [A_TAP] },
    { completed: false },
    {},
    { attempts: 'garbage', totalBrakeSec: 'x' },
    { attempts: [null, { sec: 'x' }, { sec: 2 }] },
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

test('01 first-tap: 波を計測できなければ 0、5 台以上に伝えて +1、クイズ正解で +1', () => {
  const l = getLevel('first-tap');
  assert.equal(l.quiz.choices[l.quiz.answer], '後ろへ');
  const ok = (attempts, quiz) => l.stars(baseSummary, { completed: true, quizCorrect: quiz, attempts });
  assert.equal(ok([], true), 0, '踏んでいなければ 0');
  assert.equal(ok([at(0.5, 0, 3.8)], true), 0, '波速が計測できなければ 0（0.5 秒は波にならない）');
  assert.equal(ok([at(2, 17, 51.4, { waveSpeed: 16.3 })], true), 0, '波速が正（前方）なら 0');
  assert.equal(ok([at(1.3, 3, 22, { waveSpeed: -12 })], false), 1, '波は測ったが 3 台どまり');
  assert.equal(ok([at(1.3, 4, 22, { waveSpeed: -12 })], true), 2, '4 台では伝播の星なし');
  assert.equal(ok([at(1.3, 5, 22, { waveSpeed: -12 })], false), 2, '5 台以上で +1');
  assert.equal(ok([A_TAP], true), 3, '1.5 秒 = 15 台 + クイズ正解');
  assert.equal(ok([at(1.0, 0, 12.5), A_TAP], true), 3, '波の出なかった試行が混ざっても最良の試行で判定');
  assert.equal(l.stars(baseSummary, { completed: false, quizCorrect: true, attempts: [A_TAP] }), 0, '未完走は 0');
  const r = evaluate(l, { ...baseSummary, waveSpeed: -13.3, affectedCount: 15 }, { completed: true, quizCorrect: true, attempts: [A_TAP], totalBrakeSec: 1.5 });
  assert.equal(r.stars, 3);
  assert.ok(r.lines.some((s) => s.startsWith('★') && s.includes('波を起こし')));
  assert.ok(r.lines.some((s) => s.startsWith('★') && s.includes('15 台に伝わった')));
  const r0 = evaluate(l, baseSummary, { completed: true, quizCorrect: true, attempts: [] });
  assert.equal(r0.stars, 0);
  assert.ok(r0.lines.some((s) => s.startsWith('☆') && s.includes('ブレーキを踏まなかった')));
  // ゲート未達で星 0 のときは、達成した項目を ★ ではなく「・」にして誤解を防ぐ
  assert.ok(r0.lines.some((s) => s.startsWith('※') && s.includes('評価の対象外')));
  assert.ok(r0.lines.some((s) => s.startsWith('・') && s.includes('クイズ')));
  assert.ok(!r0.lines.some((s) => s.startsWith('★')));
});

test('02 how-long: 2 回で +1、長短の両方で +1、1.8 倍の差で +1', () => {
  const l = getLevel('how-long');
  assert.equal(l.quiz.choices[l.quiz.answer], '2 倍以上に増える');
  const s = (attempts) => l.stars(baseSummary, { completed: true, attempts });
  assert.equal(s([]), 0, '踏んでいない');
  assert.equal(s([A_LONG]), 0, '1 回だけ（長いだけ）');
  assert.equal(s([A_SHORT, at(0.8, 0, 7.8)]), 1, '短い踏み込みばかりでは 1');
  assert.equal(s([at(2.0, 17, 51.4), at(2.5, 17, 73)]), 1, '中くらいばかりでは 1');
  assert.equal(s([A_SHORT, A_LONG]), 3, '1.2 秒（0 台 / 18.9 秒）と 3.0 秒（18 台 / 95.3 秒）');
  // 長短はそろっているが差が 1.8 倍に届かないケース
  assert.equal(s([at(1.2, 18, 95), at(3.0, 18, 95)]), 2, '差が出ていなければ 2');
  // 影響台数が両方 0 でも損失で 1.8 倍あれば ★
  assert.equal(s([at(1.0, 0, 12.5), at(3.0, 0, 95.3)]), 3, '損失比で判定できる');
  const r = evaluate(l, baseSummary, { completed: true, attempts: [A_SHORT, A_LONG], totalBrakeSec: 4.2 });
  assert.equal(r.stars, 3);
  assert.ok(r.lines.some((s2) => s2.startsWith('あなたの記録:') && s2.includes('1.2 秒 → 0 台') && s2.includes('3.0 秒 → 18 台')));
  const r1 = evaluate(l, baseSummary, { completed: true, attempts: [A_SHORT] });
  assert.equal(r1.stars, 0);
  assert.ok(!r1.lines.some((s2) => s2.startsWith('あなたの記録:')), '1 回だけなら記録行は出ない');
});

test('03 crowded: 2 回で +1、2 通りの台数で +1、混雑側が 1.5 倍で +1', () => {
  const l = getLevel('crowded');
  const s = (attempts) => l.stars(baseSummary, { completed: true, attempts });
  // 実測（noise 0.25 / 1 秒）: 40 台 → 0 台・9.1 秒、72 台 → 15 台・64.7 秒
  const quiet = at(1.0, 0, 9.1, { carCount: 40 });
  const busy = at(1.0, 15, 64.7, { carCount: 72 });
  assert.equal(s([]), 0);
  assert.equal(s([busy]), 0, '1 回だけ');
  assert.equal(s([busy, at(1.0, 15, 64.7, { carCount: 72 })]), 1, '同じ台数で 2 回では比較になっていない');
  assert.equal(s([quiet, busy]), 3);
  // 台数差はあるが遅れが 1.5 倍未満で、静と動の両側にも当てはまらない
  assert.equal(s([at(1.0, 10, 40, { carCount: 60 }), at(1.0, 12, 44, { carCount: 72 })]), 2);
  // 台数比では届かないが「約 1 秒で遅れ 20 秒以下 / 45 秒以上」の両方を見つけた
  assert.equal(s([at(1.0, 0, 12, { carCount: 40 }), at(1.0, 4, 50, { carCount: 50 })]), 3, '静と動の両方を見つけた');
  const r = evaluate(l, { ...baseSummary, density: 72 }, { completed: true, attempts: [quiet, busy], totalBrakeSec: 2.0 });
  assert.equal(r.stars, 3);
  assert.ok(r.lines.some((x) => x.startsWith('★') && x.includes('40 / 72 台')));
  const r1 = evaluate(l, baseSummary, { completed: true, attempts: [busy] });
  assert.ok(r1.lines.some((x) => x.startsWith('☆') && x.includes('同じ台数')));
});

test('04 slow-reaction: 1 回で +1、tau 比較 または 8 台以上の増幅で +1、クイズで +1', () => {
  const l = getLevel('slow-reaction');
  const s = (attempts, quiz = false) => l.stars(baseSummary, { completed: true, quizCorrect: quiz, attempts });
  // 実測: 26 台 tau1.5 の 2 秒 → 9 台、tau0.65 の 2 秒 → 0 台
  const slow = at(2.0, 9, 27.6, { carCount: 26, tau: 1.5, stopped: 3 });
  const quick = at(2.0, 0, 8.3, { carCount: 26, tau: 0.65 });
  assert.equal(s([]), 0, '踏んでいない');
  assert.equal(s([at(1.0, 0, 3.1, { carCount: 26, tau: 1.5 })]), 1, '1 秒では増幅が見えない');
  assert.equal(s([slow]), 2, '2 秒で 9 台まで増幅（8 台以上）');
  assert.equal(s([slow], true), 3);
  assert.equal(s([quick, slow]), 2, 'tau 2 通り（クイズ未正解）');
  assert.equal(s([quick, at(1.0, 0, 3.1, { carCount: 26, tau: 1.5 })], true), 3, '増幅が小さくても tau を比べれば ★');
  assert.equal(l.stars(baseSummary, { completed: false, quizCorrect: true, attempts: [slow] }), 0);
  const r = evaluate(l, baseSummary, { completed: true, quizCorrect: true, attempts: [quick, slow], totalBrakeSec: 4.0 });
  assert.equal(r.stars, 3);
  assert.ok(r.lines.some((x) => x.startsWith('★') && x.includes('0.65') && x.includes('1.50')));
});

test('05 dont-brake: 完走で +1、ブレーキ合計 1.0 秒以下で +1、車列全体の遅れ 140 秒未満で +1', () => {
  const l = getLevel('dont-brake');
  // 実測（32 台・120 秒・サグ）: 踏まない 116 秒 / 2 秒 129 / 3 秒 211 / 5 秒 753。
  // サグ自体で誰でも最低速度比 0.68 まで落ちるため、★3 は速度比ではなく遅れの総量で判定する。
  const sum = (totalTimeLoss, ratio = 0.68) => ({ ...baseSummary, totalTimeLoss, playerSagMinSpeedRatio: ratio });
  const s = (totalBrakeSec, totalTimeLoss, completed = true) =>
    l.stars(sum(totalTimeLoss), { completed, totalBrakeSec, attempts: [] });
  assert.equal(s(0, 116), 3, '一度も踏まなければ 3');
  assert.equal(s(1.0, 116), 3, '1.0 秒までなら 3');
  assert.equal(s(2.0, 129), 2, '2 秒踏むと合計秒数の条件を落とす');
  assert.equal(s(3.0, 211), 1, '3 秒では遅れも 140 秒を超える');
  assert.equal(s(5.0, 753), 1);
  assert.equal(s(0, 116, false), 0, '未完走は 0');
  // ctx に totalBrakeSec が無ければ attempts の合計を使う
  assert.equal(l.stars(sum(116), { completed: true, attempts: [at(0.4, 0, 5)] }), 3);
  assert.equal(l.stars(sum(129), { completed: true, attempts: [at(0.8, 0, 9), at(0.8, 0, 9)] }), 2, '合計 1.6 秒');
  const r = evaluate(l, sum(211, 0.498), { completed: true, totalBrakeSec: 3.0 });
  assert.equal(r.stars, 1);
  assert.ok(r.lines.some((x) => x.includes('サグの上りでの最低速度') && x.includes('50%')));
  assert.ok(r.lines.some((x) => x.startsWith('☆') && x.includes('140 秒未満で ★')));
});

test('しきい値は単調（悪い結果ほど星が減る）', () => {
  const c = (attempts, extra = {}) => ({ completed: true, quizCorrect: true, attempts, ...extra });
  const l1 = getLevel('first-tap');
  assert.ok(l1.stars(baseSummary, c([A_TAP])) >= l1.stars(baseSummary, c([at(1.3, 4, 20, { waveSpeed: -12 })])));
  assert.ok(l1.stars(baseSummary, c([at(1.3, 4, 20, { waveSpeed: -12 })])) >= l1.stars(baseSummary, c([])));
  const l2 = getLevel('how-long');
  assert.ok(l2.stars(baseSummary, c([A_SHORT, A_LONG])) > l2.stars(baseSummary, c([A_SHORT, A_SHORT])));
  const l5 = getLevel('dont-brake');
  // 実測どおり「踏むほど遅れが増える」組で単調性を見る
  const sag = (sec, loss) => l5.stars({ ...baseSummary, totalTimeLoss: loss }, c([], { totalBrakeSec: sec }));
  assert.ok(sag(0, 116) > sag(2.0, 129));
  assert.ok(sag(2.0, 129) > sag(3.0, 211));
  assert.equal(getLevel('free').stars(baseSummary, { completed: true }), 0);
});

test('lossPerCar は密度から 1 台あたりの損失を出す', () => {
  assert.equal(lossPerCar({ density: 48, totalTimeLoss: 47 * 10 }), 10);
  assert.equal(lossPerCar({ density: 1, totalTimeLoss: 5 }), 5, '密度 1 でも 0 除算しない');
});

test('evaluate は stars と 3 本の理由行・数値行を返す', () => {
  const ctx = {
    completed: true, quizCorrect: true, playerSagMinSpeedRatio: 0.9,
    attempts: [A_SHORT, A_LONG], totalBrakeSec: 4.2,
  };
  for (const l of LEVELS) {
    const r = evaluate(l, { ...baseSummary, waveSpeed: -17.2 }, ctx);
    assert.ok(Number.isInteger(r.stars) && r.stars >= 0 && r.stars <= 3);
    assert.ok(Array.isArray(r.lines) && r.lines.length >= 4);
    assert.ok(r.lines.every((s) => typeof s === 'string' && s.length > 0));
    assert.ok(r.lines.some((s) => s.includes('-17.2')), '波速度の表示');
    assert.ok(r.lines.some((s) => s.startsWith('あなたの記録:')), `${l.id}: 踏んだ長さ → 台数の行`);
    assert.ok(r.lines.some((s) => s.startsWith('ブレーキ: 2 回')), `${l.id}: 試行回数の行`);
    if (l.id !== 'free') {
      const reasons = r.lines.filter((s) => s.startsWith('★ ') || s.startsWith('☆ '));
      assert.equal(reasons.length, 3, `${l.id}: 星 3 つぶんの理由行`);
      assert.equal(reasons.filter((s) => s.startsWith('★')).length, r.stars, `${l.id}: ★ の理由行数 = 星数`);
      assert.ok(r.lines.some((s) => s.startsWith('評価: ')));
    } else {
      assert.ok(!r.lines.some((s) => s.startsWith('評価: ')), 'FREE に評価行は出ない');
    }
  }
  const r = evaluate(getLevel('first-tap'), baseSummary, { completed: false, quizCorrect: false, attempts: [] });
  assert.equal(r.stars, 0);
  assert.ok(r.lines[0].includes('最後まで'));
  assert.ok(r.lines.some((s) => s.includes('計測不足')));
  assert.ok(r.lines.some((s) => s.includes('不正解') && s.includes('後ろへ')));
});
