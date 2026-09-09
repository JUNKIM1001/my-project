// レベル定義 — シナリオ・シムパラメータ・時刻発火スクリプト・目標・星判定・解説カード。
// 全レベル共通のテーマは「ブレーキを踏んでいた長さ → 起こる渋滞の大きさ」。プレイヤーの操作は
// ブレーキだけで（強さは固定 PLAYER_BRAKE_DECEL）、車は常に自動運転（IDM）で走る。
//
// 星判定 stars(summary, ctx) は純粋関数（同じ入力で同じ出力）。各レベルは criteria(summary, ctx) で
// 「星 1 つ分の条件」を 3 件返し（{ ok, label, gate? }）、stars はその達成数。gate: true の条件を
// 満たさなければ 0（例: 01 はブレーキを踏んで波を計測しなければ星なし）。evaluate はこの label を
// 「★ / ☆ 理由」の行としてリザルトに出す（何をすれば星が増えるかを操作と結びつける）。
//
// ctx（game.js が組み立てる）:
//   attempts: [{ sec, affected, timeLoss, stopped, waveSpeed, carCount, tau }]
//             ブレーキ 1 回 = 1 試行。踏んでから OBSERVE_SEC 秒観察した結果が 1 要素になる。
//   brakeCount / totalBrakeSec / longestSec / shortestSec  — 試行の集計
//   completed, quizCorrect, playerSagMinSpeedRatio, carCount, tau, eventTime,
//   densitiesTried, densityRuns  — 既存フィールド
// summary は metrics.summary()（レベル全体の累積）。density = 台数（周回路 1 km）。
//
// script の action: 'pulseBrake' | 'leaderBrake' | 'hint' | 'markEvent'
//   'markEvent' はレベル全体の累積計測を開始する打刻（全レベルで at: 0）。
//
// しきい値はすべて headless シミュレーション（20 秒観察）の実測値から決めている。実測の要点:
//   48 台 / tau 0.65: 1.0 秒 → 影響 0 台・損失 12.5 秒、1.5 秒 → 15 台・30.6 秒、
//                     2.0 秒 → 17 台・51.4 秒、3.0 秒 → 18 台・95.3 秒、5.0 秒 → 20 台・180.5 秒（停止 16 台）
//   noise 0.25 の 1 秒: 40 台 → 0 台・9.1 秒、60 台 → 14 台・38.1 秒、72 台 → 15 台・64.7 秒、90 台 → 23 台・132.3 秒
//   26 台 / tau 1.5 の 2 秒 → 9 台（tau 0.65 なら 0 台）。26 台は無操作なら 180 秒走っても渋滞しない
//   サグ 32 台: 踏まなければサグ上りの速度比 0.86、0.5 秒 → 0.78、1.0 秒 → 0.70、2.0 秒 → 0.52

const km = (v) => (v * 3.6).toFixed(0);

/** プレイヤー以外 1 台あたりの総時間損失 [s] */
export function lossPerCar(summary) {
  const others = Math.max(1, Math.round(summary.density) - 1);
  return summary.totalTimeLoss / others;
}

// ---- しきい値（すべて実測ベース。上のコメントの表を参照） -------------------

/** 01: 波が「伝わった」とみなす影響台数（48 台では 1.4 秒以上の踏み込みで 15 台前後に届く） */
const WAVE_SPREAD_CARS = 5;
/** 02: 「短く踏んだ」とみなす秒数の上限 / 「長く踏んだ」の下限 */
const SHORT_MAX_SEC = 1.2;
const LONG_MIN_SEC = 3.0;
/** 02: 長い踏み込みが短い踏み込みの何倍の渋滞を起こせば「差を作れた」か（実測は 5 倍前後） */
const LENGTH_CONTRAST_RATIO = 1.8;
/** 03: 高密度側 / 低密度側の比（実測 40 台 → 72 台で損失 7 倍） */
const DENSITY_CONTRAST_RATIO = 1.5;
/** 03: 「約 1 秒」とみなす踏み込み時間の範囲 [s] */
const ONE_SEC_RANGE = [0.6, 1.5];
/** 03: すいている側 / 混んでいる側の影響台数（実測 40 台 → 0 台、72 台 → 15 台） */
/** 03 の「約 1 秒でほとんど響かない / 大きく響く」を分ける遅れ [秒]。
 *  実測: 42 台で 10 秒、72 台で 55 秒（同じ 1 秒の踏み込み） */
const QUIET_LOSS_SEC = 20;
const BUSY_LOSS_SEC = 45;
/** 04: 反応の遅れによる増幅が読み取れる影響台数（26 台 tau 1.5 の 2 秒踏みで 9 台、tau 0.65 なら 0 台） */
const REACTION_AMPLIFIED_CARS = 8;
/** 05: 我慢できたとみなすブレーキ合計時間 [s] と、サグ上りで保ちたい速度比（32 台の実測から） */
const SAG_MAX_BRAKE_SEC = 1.0;
/** サグ部レベルで ★3 とする「車列全体の遅れ」の上限 [秒]。
 *  実測（32 台・120 秒）: 踏まない 116 / 2 秒 129 / 3 秒 211 / 5 秒 753。
 *  サグ自体で誰でも最低速度比 0.68 まで落ちるため、速度比では差がつかない。 */
const SAG_MAX_LOSS_SEC = 140;

// ---- 試行（attempts）のユーティリティ ---------------------------------------

/** ctx.attempts を正規化（sec が有限な要素だけ。数値欠損は 0 / null 扱い） */
function attemptsOf(ctx = {}) {
  const raw = Array.isArray(ctx.attempts) ? ctx.attempts : [];
  return raw
    .filter((a) => a && Number.isFinite(a.sec))
    .map((a) => ({
      sec: a.sec,
      affected: Number.isFinite(a.affected) ? a.affected : 0,
      timeLoss: Number.isFinite(a.timeLoss) ? a.timeLoss : 0,
      stopped: Number.isFinite(a.stopped) ? a.stopped : 0,
      waveSpeed: Number.isFinite(a.waveSpeed) ? a.waveSpeed : null,
      carCount: Number.isFinite(a.carCount) ? Math.round(a.carCount) : null,
      tau: Number.isFinite(a.tau) ? a.tau : null,
    }));
}

/** 比較用。0 台どうしの比較で 0 除算にならないよう分母は 1 以上に丸める */
const ratio = (hi, lo) => hi / Math.max(1, lo);

/** list の中で key が最大 / 最小の要素 */
const maxBy = (list, key) => list.reduce((best, a) => (best === null || a[key] > best[key] ? a : best), null);
const minBy = (list, key) => list.reduce((best, a) => (best === null || a[key] < best[key] ? a : best), null);

/** 「1.0 秒 → 12 台」の 1 点表記 */
const dosePoint = (a) => `${a.sec.toFixed(1)} 秒 → ${a.affected} 台`;
/** 用量反応を「遅れ秒」で言うときの 1 点 */
const doseLoss = (a) => `${a.sec.toFixed(1)} 秒 → 遅れ ${Math.round(a.timeLoss)} 秒`;

/** criteria の達成数を星にする。未完走なら 0、gate 条件を満たさなければ 0 */
function starsOf(criteria, ctx = {}) {
  if (ctx.completed === false) return 0;
  if (criteria.some((c) => c.gate && !c.ok)) return 0;
  return Math.min(3, criteria.filter((c) => c.ok).length);
}

/** 共通の「完了」条件（途中終了は game 側で観察完了とみなした場合だけ completed=true になる） */
function completedCriterion(ctx) {
  return { ok: ctx.completed !== false, label: ctx.completed !== false ? '実験を最後まで行った' : '実験を途中で終了した' };
}

/** 数値行のフォーマット（リザルト表示用） */
function statLines(summary) {
  const lines = [];
  lines.push(`影響を受けた後続車: ${summary.affectedCount} 台`);
  lines.push(`後続車の総時間損失: ${summary.totalTimeLoss.toFixed(0)} 秒（1 台あたり ${lossPerCar(summary).toFixed(1)} 秒）`);
  lines.push(`停止した車: ${summary.stoppedCount} 台`);
  lines.push(summary.waveSpeed === null
    ? '渋滞波の速度: 計測不足（波が十分に広がりませんでした）'
    : `渋滞波の速度: ${summary.waveSpeed.toFixed(1)} km/h（負 = 後方へ）`);
  lines.push(`平均速度: ${km(summary.meanSpeed)} km/h ／ 交通流率: ${summary.flow.toFixed(0)} 台/h`);
  if (summary.playerMinGapTime !== null) {
    lines.push(`あなたの最小車間時間: ${summary.playerMinGapTime.toFixed(2)} 秒`);
  }
  return lines;
}

/** 全レベル共通の操作説明（アクセルは無い） */
const HOW_TO_BRAKE = 'S / ↓ を押している間ブレーキ。離すと自動で戻ります。';

// ---- 01 ----------------------------------------------------------------------

function criteria01(summary, ctx = {}) {
  const list = attemptsOf(ctx);
  const waved = list.filter((a) => a.waveSpeed !== null && a.waveSpeed < 0);
  const measured = waved.length > 0;
  const best = maxBy(list, 'affected');
  const n = best ? best.affected : 0;
  return [
    {
      ok: list.length >= 1 && measured,
      gate: true,
      label: list.length === 0
        ? 'ブレーキを踏まなかったので波は起きなかった（S / ↓ を 1〜2 秒押す）'
        : (measured
          ? `ブレーキで波を起こし、後ろへ進む速度（${waved[0].waveSpeed.toFixed(1)} km/h）を計測した`
          : '波の速度を計測できなかった（一瞬の踏み込みでは波にならない。1〜2 秒しっかり踏む）'),
    },
    {
      ok: n >= WAVE_SPREAD_CARS,
      label: n >= WAVE_SPREAD_CARS
        ? `1 回の踏み込みが ${n} 台に伝わった（${WAVE_SPREAD_CARS} 台以上）`
        : `伝わったのは ${n} 台（${WAVE_SPREAD_CARS} 台以上で ★。もう少し長く踏んでみる）`,
    },
    { ok: !!ctx.quizCorrect, label: ctx.quizCorrect ? 'クイズ正解' : 'クイズ不正解' },
  ];
}

const LEVEL_01 = {
  id: 'first-tap',
  no: '01',
  title: 'はじめの一踏み',
  question: '1 台のブレーキは、どこまで届く？',
  briefing: [
    '48 台が 1 km の周回路を同じ速度で走っています。誰も止まっていません。運転は自動です。',
    'あなたがすることはひとつだけ。ブレーキを 1〜2 秒だけ踏んで、離す。あとは後ろの車列を見ます。',
    '上空カメラ（C キー）と時空間図で、減速の「波」がどちらへ進むかを確かめましょう。',
  ],
  howTo: HOW_TO_BRAKE,
  simConfig: { carCount: 48, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: false, seed: 1 },
  playerMode: 'auto',
  durationSec: 90,
  script: [
    { at: 0, action: 'markEvent', args: {} },
    { at: 3, action: 'hint', args: { text: '準備ができたら S / ↓ を 1〜2 秒押して、離す。' } },
    { at: 40, action: 'hint', args: { text: '上空カメラ（C）で後ろの車列を見てみましょう。' } },
  ],
  goals: [
    'ブレーキを 1〜2 秒踏み、後ろへ進む波の速度を計測する',
    `1 回の踏み込みを ${WAVE_SPREAD_CARS} 台以上に届かせる`,
    'クイズに正解する',
  ],
  lesson: {
    title: '一踏みは、後ろへ進む波になる',
    body: [
      'あなたが減速すると、後ろの車は少し遅れて、少し強く減速します。これが後ろへ連鎖して「渋滞の波」になります。',
      '波は車の進行方向と逆に、時速 15〜20 km ほどで後ろへ進みます。事故も工事もないのに渋滞ができる「自然渋滞」の正体です。',
      'ごく短い踏み込み（1 秒未満）は波にならずに消えます。波が立つかどうかの境目は、意外なほど短い時間にあります。',
    ],
    fact: '高速道路の渋滞の波は、多くの観測で時速 15〜20 km 程度で後ろへ進むことが知られています。',
  },
  quiz: {
    q: '渋滞の波はどちらへ進んだ？',
    choices: ['前へ', '後ろへ', 'その場にとどまる'],
    answer: 1,
    explain: '各車が「前の車の減速に遅れて反応する」ため、減速の起点は車列を後ろへさかのぼっていきます。',
  },
  criteria: criteria01,
  stars: (summary, ctx = {}) => starsOf(criteria01(summary, ctx), ctx),
};

// ---- 02 ----------------------------------------------------------------------

/** 02: 短い試行（最短のもの）と長い試行（最長のもの）を取り出す */
function shortLongOf(list) {
  return {
    short: minBy(list.filter((a) => a.sec <= SHORT_MAX_SEC), 'sec'),
    long: maxBy(list.filter((a) => a.sec >= LONG_MIN_SEC), 'sec'),
  };
}

function criteria02(summary, ctx = {}) {
  const list = attemptsOf(ctx);
  const { short, long } = shortLongOf(list);
  const both = !!(short && long);
  // 比べるのは損失秒だけにする。影響台数は 17〜20 台で頭打ちになるうえ、短い側が 0 台だと
  // 比の分母が 1 になって「2 台でも 1.8 倍達成」になってしまう（BRAKE_REDESIGN.md の実測）
  const grew = both && ratio(long.timeLoss, short.timeLoss) >= LENGTH_CONTRAST_RATIO;
  let secondLabel;
  if (both) secondLabel = `短い踏み込み（${short.sec.toFixed(1)} 秒）と長い踏み込み（${long.sec.toFixed(1)} 秒）を両方試した`;
  else if (short) secondLabel = `${LONG_MIN_SEC.toFixed(1)} 秒以上の長い踏み込みも試すと ★`;
  else if (long) secondLabel = `${SHORT_MAX_SEC.toFixed(1)} 秒以下の短い踏み込みも試すと ★`;
  else secondLabel = `短い踏み込み（${SHORT_MAX_SEC.toFixed(1)} 秒以下）と長い踏み込み（${LONG_MIN_SEC.toFixed(1)} 秒以上）を試すと ★`;
  return [
    {
      ok: list.length >= 2,
      label: list.length >= 2 ? `${list.length} 回の踏み込みを記録した` : `記録した踏み込みは ${list.length} 回（2 回以上で ★）`,
    },
    { ok: both, label: secondLabel },
    {
      ok: grew,
      label: grew
        ? `長く踏んだほうが遅れが大きくなった（${doseLoss(short)} ／ ${doseLoss(long)}）`
        : `長短の遅れの差が ${LENGTH_CONTRAST_RATIO} 倍に届いていない（もっとはっきり長く踏むと ★）`,
    },
  ];
}

const LEVEL_02 = {
  id: 'how-long',
  no: '02',
  title: '長く踏むと、どうなる？',
  question: '踏む長さで、渋滞はどれだけ変わる？',
  briefing: [
    '同じ 48 台の周回路です。今度は「踏んでいた長さ」だけを変えて、2 回以上ためします。',
    `まず短く（${SHORT_MAX_SEC.toFixed(1)} 秒以下）、次に長く（${LONG_MIN_SEC.toFixed(1)} 秒以上）。1 回踏むごとに 20 秒観察して結果が 1 点として記録されます。`,
    '散布図に点が並んだら、横軸（秒）と縦軸（台数）の関係を自分の目で確かめてください。',
  ],
  howTo: HOW_TO_BRAKE,
  simConfig: { carCount: 48, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: false, seed: 2 },
  playerMode: 'auto',
  durationSec: 150,
  script: [
    { at: 0, action: 'markEvent', args: {} },
    { at: 3, action: 'hint', args: { text: `まずは短く。${SHORT_MAX_SEC.toFixed(1)} 秒以下でパッと離す。` } },
    { at: 45, action: 'hint', args: { text: `次は長く。${LONG_MIN_SEC.toFixed(1)} 秒以上、じっくり踏んでみる。` } },
  ],
  goals: [
    '踏み込みを 2 回以上記録する',
    `短い踏み込みと長い踏み込みを両方試す`,
    `長いほうの遅れを短いほうの ${LENGTH_CONTRAST_RATIO} 倍以上にする`,
  ],
  lesson: {
    title: '踏んだ長さは、比例では効かない',
    body: [
      '1 秒の踏み込みは後ろで消えることがあります。しかし 2 秒、3 秒と延びると、波は消えずに後ろへ伝わり始めます。',
      'このシミュレータでは、48 台の車列で 1 秒の踏み込みは影響 0 台・損失 12 秒程度でしたが、3 秒では 18 台・95 秒程度になりました。時間は 3 倍でも、損失は 7 倍以上です。',
      '「波が立つかどうか」の境目を越えると、その先は一気に大きくなります。だから、少しでも短く済ませることに意味があります。',
    ],
    fact: '目安として、渋滞の損失は減速の大きさと長さに対して比例よりも急に増えるとされ、わずかな減速の抑制が全体の遅れを大きく減らすと報告されています。',
  },
  quiz: {
    q: 'ブレーキを踏む時間を 2 倍にすると、渋滞の大きさは？',
    choices: ['ほぼ変わらない', 'だいたい 2 倍になる', '2 倍以上に増える'],
    answer: 2,
    explain: '波が立つ境目を越えると連鎖が始まるため、損失は踏んだ時間に比例するのではなく、それより急に増えます。',
  },
  criteria: criteria02,
  stars: (summary, ctx = {}) => starsOf(criteria02(summary, ctx), ctx),
};

// ---- 03 ----------------------------------------------------------------------

function criteria03(summary, ctx = {}) {
  const list = attemptsOf(ctx);
  const withCount = list.filter((a) => a.carCount !== null);
  const counts = [...new Set(withCount.map((a) => a.carCount))].sort((a, b) => a - b);
  const lo = minBy(withCount, 'carCount');
  const hi = maxBy(withCount, 'carCount');
  const compared = counts.length >= 2;
  const bigger = compared && ratio(hi.timeLoss, lo.timeLoss) >= DENSITY_CONTRAST_RATIO;
  // 「約 1 秒」の踏み込みで、影響がほぼ出ない密度と大きく出る密度の両方を見つけた
  const oneSec = list.filter((a) => a.sec >= ONE_SEC_RANGE[0] && a.sec <= ONE_SEC_RANGE[1]);
  const bracketed = oneSec.some((a) => a.timeLoss <= QUIET_LOSS_SEC) && oneSec.some((a) => a.timeLoss >= BUSY_LOSS_SEC);
  let thirdLabel;
  if (bigger) thirdLabel = `混んだ側のほうが遅れが大きかった（${hi.carCount} 台: ${Math.round(hi.timeLoss)} 秒 ／ ${lo.carCount} 台: ${Math.round(lo.timeLoss)} 秒）`;
  else if (bracketed) thirdLabel = `同じ約 1 秒でも、ほとんど響かない密度（遅れ ${QUIET_LOSS_SEC} 秒以下）と大きく響く密度（${BUSY_LOSS_SEC} 秒以上）を見つけた`;
  else thirdLabel = `混んだ側の遅れを、すいた側の ${DENSITY_CONTRAST_RATIO} 倍以上にすると ★（台数の差を大きくとる）`;
  return [
    {
      ok: list.length >= 2,
      label: list.length >= 2 ? `${list.length} 回の踏み込みを記録した` : `記録した踏み込みは ${list.length} 回（2 回以上で ★）`,
    },
    {
      ok: compared,
      label: compared
        ? `${counts.length} 通りの台数で踏んだ（${counts.join(' / ')} 台）`
        : '同じ台数でしか踏んでいない（スライダーで台数を変えて、同じ長さで踏むと ★）',
    },
    { ok: bigger || bracketed, label: thirdLabel },
  ];
}

const LEVEL_03 = {
  id: 'crowded',
  no: '03',
  title: '混んでいる道路では',
  question: '同じ 1 秒でも、混雑時は何倍効く？',
  briefing: [
    '72 台の車列です。運転のばらつき（ノイズ）もあり、車間には少し余裕がありません。',
    'やることは 1 つ。「だいたい同じ長さ」で踏み、台数スライダーを変えて、もう一度同じ長さで踏みます。',
    '踏んだ長さが同じなのに結果が変わるなら、変わったのは道路の混み具合のほうです。',
  ],
  howTo: `${HOW_TO_BRAKE} 台数スライダーで混雑を変えられます。`,
  simConfig: { carCount: 72, v0: 22.2, T: 1.05, tau: 0.65, noise: 0.25, sag: false, seed: 3 },
  playerMode: 'auto',
  durationSec: 180,
  densityRange: [40, 90],
  script: [
    { at: 0, action: 'markEvent', args: {} },
    { at: 3, action: 'hint', args: { text: 'まず今の台数で 1 秒ほど踏んでみる。' } },
    { at: 60, action: 'hint', args: { text: '台数スライダーを動かして、同じ長さでもう一度踏む。' } },
  ],
  goals: [
    '踏み込みを 2 回以上記録する',
    '2 通り以上の台数で踏む',
    `混んだ側の遅れを、すいた側の ${DENSITY_CONTRAST_RATIO} 倍以上にする`,
  ],
  lesson: {
    title: '同じ一踏みでも、密度が結果を決める',
    body: [
      '車列がすいていれば、あなたの減速は前後の車間に吸収されて消えます。混んでいると吸収する余地がなく、後ろへそのまま伝わって増幅します。',
      'このシミュレータでは、同じ 1 秒の踏み込みが 40 台では影響 0 台、72 台では 15 台前後、90 台では 20 台以上になりました。あなたの操作は変えていません。',
      '交通量は密度を上げると増えますが、ある密度（臨界密度）を超えると速度が急に落ちて逆に減り始めます。混雑時の一踏みが重いのはこのためです。',
    ],
    fact: '日本の高速道路では、目安として 1 車線 1 km あたり 25 台前後を超えると自然渋滞が発生しやすくなるとされています。',
  },
  quiz: {
    q: '同じ 1 秒のブレーキでも、混んでいるほど影響が大きくなるのはなぜ？',
    choices: ['車が速く走っているから', '車間に吸収する余地がなく、後ろへ伝わるから', '混雑時はブレーキが強くなるから'],
    answer: 1,
    explain: '密度が高いと減速を吸収するすき間がなく、後続は前より強く踏まざるを得ないため、波が増幅します。',
  },
  criteria: criteria03,
  stars: (summary, ctx = {}) => starsOf(criteria03(summary, ctx), ctx),
};

// ---- 04 ----------------------------------------------------------------------

function criteria04(summary, ctx = {}) {
  const list = attemptsOf(ctx);
  const taus = [...new Set(list.filter((a) => a.tau !== null).map((a) => Math.round(a.tau * 100) / 100))].sort((a, b) => a - b);
  const best = maxBy(list, 'affected');
  const n = best ? best.affected : 0;
  const comparedTau = taus.length >= 2;
  const amplified = n >= REACTION_AMPLIFIED_CARS;
  let secondLabel;
  if (comparedTau) secondLabel = `反応の遅れを ${taus.length} 通りにして比べた（τ = ${taus.map((t) => t.toFixed(2)).join(' / ')} s）`;
  else if (amplified) secondLabel = `1 回の踏み込みが ${n} 台まで増幅した（遅れのある車列の増幅を確認）`;
  else secondLabel = `もう少し長く踏んで ${REACTION_AMPLIFIED_CARS} 台以上に広げるか、τ スライダーで遅れを変えて比べると ★`;
  return [
    {
      ok: list.length >= 1,
      label: list.length >= 1 ? `${list.length} 回の踏み込みを記録した` : 'まだ踏んでいない（S / ↓ を 2 秒ほど押す）',
    },
    { ok: comparedTau || amplified, label: secondLabel },
    { ok: !!ctx.quizCorrect, label: ctx.quizCorrect ? 'クイズ正解' : 'クイズ不正解' },
  ];
}

const LEVEL_04 = {
  id: 'slow-reaction',
  no: '04',
  title: '反応が遅い車列',
  question: 'みんなの反応が遅いと、同じ踏み方でも？',
  briefing: [
    'この車列のドライバーは反応が 1.5 秒遅れます（前を見ていない状態）。26 台と、けっして混んではいません。',
    'この車列は放っておけば 3 分走っても渋滞しません。そこであなたが 2 秒だけ踏むと、何が起きるでしょう。',
    'τ（反応の遅れ）スライダーを 0.65 s に戻して同じ長さで踏み比べると、遅れの効果がはっきり見えます。',
  ],
  howTo: `${HOW_TO_BRAKE} τ スライダーで反応の遅れを変えられます。`,
  // 26 台 tau 1.5: 無操作なら 180 秒走っても停止 0・損失 0（自然渋滞しない）。
  // そこへ 2 秒踏むと影響 9 台・停止 3 台。tau 0.65 の同条件では 2 秒でも影響 0 台。
  simConfig: { carCount: 26, v0: 22.2, T: 1.05, tau: 1.5, noise: 0, sag: false, seed: 4 },
  playerMode: 'auto',
  durationSec: 180,
  script: [
    { at: 0, action: 'markEvent', args: {} },
    { at: 3, action: 'hint', args: { text: '周りの車の反応は 1.5 秒遅れ。まずは 2 秒ほど踏んでみる。' } },
    { at: 60, action: 'hint', args: { text: 'τ を 0.65 s に下げて、同じ長さでもう一度踏んでみる。' } },
  ],
  goals: [
    '踏み込みを 1 回以上記録する',
    `τ を変えて比べる、または 1 回の踏み込みを ${REACTION_AMPLIFIED_CARS} 台以上に広げる`,
    'クイズに正解する',
  ],
  lesson: {
    title: '反応の遅れは、一踏みの「増幅器」',
    body: [
      '前の車の減速に気づくのが遅れると、同じだけ止まるためにより強いブレーキが必要になります。後ろの車も同じことを繰り返し、波は 1 台ごとに大きくなります。',
      'このシミュレータでは、26 台・遅れ 0.65 秒なら 2 秒の踏み込みは影響 0 台でしたが、遅れ 1.5 秒では 9 台に広がり、数台が停止しました。踏んだ長さは同じです。',
      'つまり「どれだけ踏んだか」の重みは、まわりのドライバーの状態で変わります。前をよく見ている車列ほど、同じ一踏みが軽く済みます。',
    ],
    fact: '人間のブレーキ反応時間は通常 0.7〜1.0 秒程度とされ、スマートフォン操作中は目安として 1.5 秒程度まで延びるとされます。',
  },
  quiz: {
    q: '同じ長さのブレーキでも、車列全体の反応が遅いとどうなる？',
    choices: ['影響は変わらない', '波が増幅して、より多くの車に広がる', '遅れる分だけ波は弱まる'],
    answer: 1,
    explain: '気づくのが遅いほど強く踏む必要があり、その強い減速がさらに後ろへ受け継がれて増幅します。',
  },
  criteria: criteria04,
  stars: (summary, ctx = {}) => starsOf(criteria04(summary, ctx), ctx),
};

// ---- 05 ----------------------------------------------------------------------

/** 05: サグ上り区間でのプレイヤー最低速度 / 基準速度。ctx 優先、無ければ summary、どちらも無ければ 0 */
function sagRatioOf(summary, ctx) {
  if (Number.isFinite(ctx.playerSagMinSpeedRatio)) return ctx.playerSagMinSpeedRatio;
  if (Number.isFinite(summary.playerSagMinSpeedRatio)) return summary.playerSagMinSpeedRatio;
  return 0;
}

/** 05: 踏んだ合計秒数。ctx.totalBrakeSec 優先、無ければ attempts の合計 */
function totalBrakeSecOf(ctx) {
  if (Number.isFinite(ctx.totalBrakeSec)) return ctx.totalBrakeSec;
  return attemptsOf(ctx).reduce((sum, a) => sum + a.sec, 0);
}

function criteria05(summary, ctx = {}) {
  const ratioSag = sagRatioOf(summary, ctx);
  const sec = totalBrakeSecOf(ctx);
  const pct = (ratioSag * 100).toFixed(0);
  const held = sec <= SAG_MAX_BRAKE_SEC;
  const loss = Number.isFinite(summary?.totalTimeLoss) ? summary.totalTimeLoss : Infinity;
  const calm = loss < SAG_MAX_LOSS_SEC;
  return [
    completedCriterion(ctx),
    {
      ok: held,
      label: held
        ? `ブレーキの合計は ${sec.toFixed(1)} 秒（${SAG_MAX_BRAKE_SEC.toFixed(1)} 秒以下に我慢できた）`
        : `ブレーキの合計が ${sec.toFixed(1)} 秒（${SAG_MAX_BRAKE_SEC.toFixed(1)} 秒以下で ★）`,
    },
    {
      ok: calm,
      label: calm
        ? `車列全体の遅れを ${Math.round(loss)} 秒に抑えた（サグでの最低速度は基準の ${pct}%）`
        : `車列全体の遅れが ${Math.round(loss)} 秒（${SAG_MAX_LOSS_SEC} 秒未満で ★。サグでの最低速度は基準の ${pct}%）`,
    },
  ];
}

const LEVEL_05 = {
  id: 'dont-brake',
  no: '05',
  title: '踏まずに通る',
  question: 'サグ部を、ブレーキを使わずに越えられる？',
  briefing: [
    'この周回路には「サグ部」（下り→上りの谷。250〜650 m 区間）があります。32 台の車列です。',
    '上り坂に入ると、前の車がなんとなく遅くなります。つられて踏みたくなりますが、そこを我慢してください。',
    '目標はシンプル。最後までブレーキをほとんど使わず、サグの上りで速度を落とさないこと。',
  ],
  howTo: `${HOW_TO_BRAKE} このレベルは「踏まない」のが正解です。`,
  // 32 台: 一度も踏まなければサグ上りの速度比 0.86。0.5 秒踏むと 0.78、1.0 秒で 0.70、2.0 秒で 0.52 まで落ちる。
  // 36 台以上だと踏まなくても 0.69 まで落ちてプレイヤーの我慢が結果に出ないため 32 台に調整。
  simConfig: { carCount: 32, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: true, seed: 5 },
  playerMode: 'auto',
  durationSec: 120,
  script: [
    { at: 0, action: 'markEvent', args: {} },
    { at: 3, action: 'hint', args: { text: '400 m 地点から上り坂。速度が少し落ちても、踏まずに待つ。' } },
    { at: 50, action: 'hint', args: { text: '上りで誰かが踏むと、その後ろに波が生まれます。' } },
  ],
  goals: [
    '実験を最後まで行う',
    `ブレーキの合計を ${SAG_MAX_BRAKE_SEC.toFixed(1)} 秒以下に抑える`,
    `車列全体の遅れを ${SAG_MAX_LOSS_SEC} 秒未満に抑える`,
  ],
  lesson: {
    title: 'サグ部の一踏みは、日本の渋滞の代表的な原因のひとつ',
    body: [
      'サグ部では下り坂の勢いのまま上りに入るため、ドライバーは自分では気づかないうちに減速します。見た目はほぼ平坦な 1〜2% の勾配でも起点になります。',
      'そこで前がわずかに遅くなり、つられてブレーキを踏むと、その一踏みが後ろへ伝わって渋滞の起点になります。このシミュレータでも、1 回 1 秒踏むだけでサグ上りの速度比が 0.86 から 0.70 へ落ちました。',
      '対策は「上りで速度が落ちたことに早く気づく」「車間を保って、踏まずに済ませる」。道路側でも速度回復を促す標識や LED 表示が設置されています。',
    ],
    fact: '日本の高速道路では、渋滞の発生原因として目安として過半がサグ部・上り坂によるものとされ、代表的な原因のひとつに挙げられています。',
  },
  quiz: {
    q: 'サグ部（下りから上りに変わる谷）で渋滞が起きやすいのはなぜ？',
    choices: ['上りで無意識に速度が落ち、後ろが次々ブレーキを踏むから', '上りでは道路が狭くなるから', '下りでスピードを出しすぎるから'],
    answer: 0,
    explain: '勾配の変化に気づきにくく、無自覚な減速が起点になります。そこへ後続のブレーキが重なって波になります。',
  },
  criteria: criteria05,
  stars: (summary, ctx = {}) => starsOf(criteria05(summary, ctx), ctx),
};

// ---- FREE --------------------------------------------------------------------

const FREE = {
  id: 'free',
  no: 'FREE',
  title: 'フリーラボ',
  question: '「踏んだ長さ → 渋滞の大きさ」を、自分の条件で描いてみよう',
  briefing: [
    '台数・車間時間・反応の遅れ・希望速度・運転のばらつき・サグ部をスライダーで変えられます。',
    '台数とサグ部の変更は車列をリセットします。ほかは走行中に効きます。',
    '時間制限も採点もありません。いろいろな長さで踏んで、散布図に点を貯めてください。',
  ],
  howTo: `${HOW_TO_BRAKE} 踏むたびに 1 点が散布図に増えます。`,
  simConfig: { carCount: 48, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: false, seed: 42 },
  playerMode: 'auto',
  durationSec: 600,
  densityRange: [20, 100],
  script: [],
  goals: [],
  lesson: {
    title: '一踏みの重さを決める 4 つのつまみ',
    body: [
      '踏んだ長さ: 短いうちは消え、境目を越えると急に大きくなる。',
      '密度（台数）: 高いほど、同じ長さの一踏みが重くなる。',
      '反応の遅れ τ: 長いほど波が増幅する。',
      'サグ部: 無自覚な減速が、踏んでいなくても起点になる。',
    ],
    fact: '渋滞の波の速さ（約 -15〜-20 km/h）は、多くの観測で条件が変わってもあまり変わらないとされています。試してみてください。',
  },
  stars() { return 0; },
};

export const LEVELS = [LEVEL_01, LEVEL_02, LEVEL_03, LEVEL_04, LEVEL_05, FREE];
/** 星評価のある 5 レベルだけ（タブ表示などに） */
export const PLAY_LEVELS = LEVELS.slice(0, 5);
export const FREE_LEVEL = FREE;

export function getLevel(id) {
  return LEVELS.find((l) => l.id === id) || null;
}

/** 2 回以上踏んでいれば「1.0 秒 → 12 台 / 3.2 秒 → 31 台」の 1 行を返す（秒の短い順・最大 6 点） */
function doseLine(ctx) {
  const list = attemptsOf(ctx).slice().sort((a, b) => a.sec - b.sec);
  if (list.length < 2) return null;
  const shown = list.length <= 6 ? list : [list[0], ...list.slice(-5)];
  return `あなたの記録: ${shown.map(dosePoint).join(' / ')}`;
}

/**
 * リザルト用。stars と表示行を返す。
 * 表示行: 途中終了の注記 → 数値行 → 踏んだ長さの記録 → クイズ → サグ速度比 →
 *         星ごとの理由（★ 達成 / ☆ 未達成と条件）→ 評価
 */
/**
 * スコア（0〜100）。「実験の達成度」で、星と矛盾しないように criteria をそのまま点数化する
 * （CASUAL_POLISH.md §2）。FREE は null。
 *  - criteria 3 件: クイズありレベルは 20 点 × 3、なしは 30 点 × 3（未完走 / ゲート未達は 0）
 *  - 探究度: 試行回数 min(n, 3) / 3 × 満点（クイズあり 20 / なし 10）。
 *    05 dont-brake だけは逆で、踏んだ合計 0 秒で満点・1 秒以下で半分・それ以上で 0
 *  - クイズ: 正解で 20
 */
export function scoreOf(level, summary, ctx = {}) {
  if (!level || level.id === 'free' || typeof level.criteria !== 'function') return null;
  let cs;
  try { cs = level.criteria(summary, ctx) || []; } catch { cs = []; }
  const hasQuiz = !!level.quiz;
  const gateOk = ctx.completed !== false && !cs.some((c) => c.gate && !c.ok);
  const critPts = gateOk ? cs.filter((c) => c.ok).length * (hasQuiz ? 20 : 30) : 0;
  const exploreMax = hasQuiz ? 20 : 10;
  let explore;
  if (level.id === 'dont-brake') {
    const sec = Number.isFinite(ctx.totalBrakeSec) ? ctx.totalBrakeSec : attemptsOf(ctx).reduce((t, a) => t + a.sec, 0);
    explore = sec <= 0.05 ? exploreMax : sec <= 1.0 ? exploreMax / 2 : 0;
  } else {
    explore = Math.min(attemptsOf(ctx).length, 3) / 3 * exploreMax;
  }
  const quiz = hasQuiz && ctx.quizCorrect === true ? 20 : 0;
  // 未完走 / ゲート未達（= 星 0）のときは、探究度とクイズだけで高得点にならないよう上限を置く。
  // 星 1 の最低点（criteria 20 + 試行 1 回 ≒ 27）を下回る 25 にして、星とスコアの順序を保つ
  if (!gateOk) return Math.min(ZERO_STAR_MAX, Math.round(explore + quiz));
  return Math.max(0, Math.min(100, Math.round(critPts + explore + quiz)));
}
/** 星 0 のときのスコア上限 */
const ZERO_STAR_MAX = 25;

export function evaluate(level, summary, ctx = {}) {
  const stars = Math.max(0, Math.min(3, level.stars(summary, ctx) | 0));
  const lines = [];
  if (ctx.completed === false) lines.push('レベルを最後まで走りませんでした。');
  lines.push(...statLines(summary));
  const brakeSec = Number.isFinite(ctx.totalBrakeSec) ? ctx.totalBrakeSec : null;
  const count = attemptsOf(ctx).length;
  if (count > 0 || brakeSec !== null) {
    lines.push(`ブレーキ: ${count} 回${brakeSec !== null ? `／合計 ${brakeSec.toFixed(1)} 秒` : ''}`);
  }
  const dose = doseLine(ctx);
  if (dose) lines.push(dose);
  if (level.quiz && ctx.quizCorrect !== undefined) {
    lines.push(ctx.quizCorrect ? 'クイズ: 正解' : `クイズ: 不正解（正解は「${level.quiz.choices[level.quiz.answer]}」）`);
  }
  const sagRatio = Number.isFinite(ctx.playerSagMinSpeedRatio) ? ctx.playerSagMinSpeedRatio : summary.playerSagMinSpeedRatio;
  if (level.id === 'dont-brake' && Number.isFinite(sagRatio)) {
    lines.push(`サグの上りでの最低速度: 基準の ${(sagRatio * 100).toFixed(0)}%`);
  }
  if (typeof level.criteria === 'function') {
    const cs = level.criteria(summary, ctx);
    // 未完走 / ゲート未達なら星は 0。条件を満たした行を ★ で並べると「★ があるのに評価 0」に
    // 見えるので、そのときは記号を「・」にして、先に理由を 1 行出す
    const voided = stars === 0 && cs.some((c) => c.ok);
    if (voided) {
      lines.push(ctx.completed === false
        ? '※ 途中で終了したため、今回は評価の対象外です（下の達成状況は参考）。'
        : '※ 必須条件（いちばん上の項目）が未達のため、今回は評価の対象外です。');
    }
    // 達成した項目だけ「・」にする（★ に見せない）。未達は ☆ のままにして可否は伝える
    for (const c of cs) lines.push(`${c.ok ? (voided ? '・' : '★') : '☆'} ${c.label}`);
  }
  if (level.id !== 'free') lines.push(`評価: ${'★'.repeat(stars)}${'☆'.repeat(3 - stars)}`);
  return { stars, lines };
}
