// レベル定義 — シナリオ・シムパラメータ・時刻発火スクリプト・目標・星判定・解説カード。
// 星判定 stars(summary, ctx) は純粋関数（同じ入力で同じ出力）。各レベルは criteria(summary, ctx) で
// 「星 1 つ分の条件」を最大 3 件返し（{ ok, label, gate? }）、stars はその達成数。gate: true の条件を
// 満たさなければ 0（例: 01 はブレーキを踏んで波を計測しなければ星なし）。evaluate はこの label を
// 「★ / ☆ 理由」の行としてリザルトに出す（何をすれば星が増えるかを操作と結びつける）。
// ctx = { completed, quizCorrect, playerSagMinSpeedRatio, playerPulses, densitiesTried, densityRuns }
//   playerPulses:   プレイヤーが B（pulseBrake）を押した回数（01）
//   densitiesTried: このレベルで試した台数の配列（初期値を含む・重複なし）（03）
//   densityRuns:    再スタート前の各走行 { carCount, sec, stoppedCount, totalTimeLoss, density }（03）
// script の action: 'pulseBrake' | 'leaderBrake' | 'hint' | 'markEvent'
//   'markEvent' はイベントの無いレベル（03 / 05）で計測開始を打刻するための追加アクション。
// summary は metrics.summary()。density = 台数（周回路 1 km）なので 1 台あたりの損失に正規化できる。

const km = (v) => (v * 3.6).toFixed(0);

/** プレイヤー以外 1 台あたりの総時間損失 [s] */
export function lossPerCar(summary) {
  const others = Math.max(1, Math.round(summary.density) - 1);
  return summary.totalTimeLoss / others;
}

/** 03: 「渋滞が出ない密度」の証拠として数える走行の最低時間 [s]（数秒で再スタートした走行は数えない） */
const DENSITY_RUN_MIN_SEC = 20;
/** 臨界を挟んだと判定するための、自由流走行と渋滞走行の最小密度差 [台/km] */
const DENSITY_BRACKET_MIN_DIFF = 10;
/** 03: ★（損失）のしきい値 [s/台] */
const DENSITY_GOOD_LOSS = 15;
/** 01: 波が「伝わった」とみなす影響台数 */
const WAVE_SPREAD_CARS = 5;

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

// ---- 01 ----------------------------------------------------------------------

function criteria01(summary, ctx = {}) {
  const pulsed = (ctx.playerPulses | 0) >= 1;
  const waveMeasured = Number.isFinite(summary.waveSpeed) && summary.waveSpeed < 0;
  const n = summary.affectedCount | 0;
  return [
    {
      ok: pulsed && waveMeasured,
      gate: true,
      label: pulsed && waveMeasured
        ? `ブレーキで波を起こし、後ろへ進む速度（${summary.waveSpeed.toFixed(1)} km/h）を計測した`
        : (!pulsed
          ? 'ブレーキを踏まなかったので波は起きなかった（B キーで 1 回踏む）'
          : '波の速度を計測できなかった（踏んだあと 30 秒以上、波が広がるまで観察する）'),
    },
    {
      ok: n >= WAVE_SPREAD_CARS,
      label: n >= WAVE_SPREAD_CARS ? `波が ${n} 台に伝わった（${WAVE_SPREAD_CARS} 台以上）` : `波が伝わったのは ${n} 台（${WAVE_SPREAD_CARS} 台以上で ★）`,
    },
    { ok: !!ctx.quizCorrect, label: ctx.quizCorrect ? 'クイズ正解' : 'クイズ不正解' },
  ];
}

const LEVEL_01 = {
  id: 'brake-once',
  no: '01',
  title: '小さなブレーキ',
  question: '1 台の減速は、どこまで届く？',
  briefing: [
    '48 台が 1 km の周回路を同じ速度で走っています。誰も止まっていません。',
    'あなたの RX-7 だけが 2 秒間ブレーキを踏みます。後ろの車列に何が起きるか観察してください。',
    '上空カメラ（C キー）と時空間図を見ながら、減速の「波」がどちらへ進むかを確かめましょう。',
  ],
  howTo: 'B キー（またはボタン）でブレーキを 2 秒間踏む。運転はオートです。',
  simConfig: { carCount: 48, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: false, seed: 1 },
  playerMode: 'auto',
  durationSec: 90,
  script: [
    { at: 3, action: 'hint', args: { text: '準備ができたら B キーでブレーキ。1 回で十分です。' } },
    { at: 40, action: 'hint', args: { text: '上空カメラ（C）で後ろの車列を見てみましょう。' } },
  ],
  goals: [
    'B キーでブレーキを踏み、後ろへ進む減速の波の速度を計測する（★1）',
    `波を ${WAVE_SPREAD_CARS} 台以上に伝える（★2）`,
    'クイズに正解する（★3）',
  ],
  lesson: {
    title: '自然渋滞は「後ろへ進む波」',
    body: [
      'あなたが減速すると、後ろの車は少し遅れて、少し強く減速します。これが後ろへ連鎖して「渋滞の波」になります。',
      '波は車の進行方向と逆に、時速 15〜20 km ほどで後ろへ進みます。事故も工事もないのに渋滞ができる「自然渋滞」の正体です。',
      '車列が密で、1 台 1 台の反応が遅いほど、波は消えずに増幅します。',
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

function criteria02(summary, ctx = {}) {
  const stopped = summary.stoppedCount | 0;
  return [
    completedCriterion(ctx),
    { ok: stopped <= 3, label: stopped <= 3 ? `後ろで止まった車は ${stopped} 台（3 台以下）` : `後ろで ${stopped} 台が止まった（3 台以下で ★）` },
    { ok: stopped === 0, label: stopped === 0 ? '後ろの車を 1 台も止めなかった（波を吸収した）' : '後ろの車を 1 台も止めないと ★（車間を広めに、ゆるく減速）' },
  ];
}

const LEVEL_02 = {
  id: 'absorb-wave',
  no: '02',
  title: '先を読む運転',
  question: '前の急ブレーキを、後ろに伝えないためには？',
  briefing: [
    '15 秒後、あなたの 3 台前の車が急ブレーキを踏みます。',
    '車間を空けておけば、あなたは強く踏まずに済み、後ろの車を止めずにすみます。',
    '目標は「後ろの車を 1 台も止めないこと」。波を吸収するクッションになりましょう。',
  ],
  howTo: 'W/↑ アクセル、S/↓ ブレーキ。車間を広めに保ち、ゆるやかに減速する。',
  simConfig: { carCount: 48, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: false, seed: 2 },
  playerMode: 'manual',
  durationSec: 120,
  script: [
    { at: 3, action: 'hint', args: { text: '前の車と少し距離を取っておきましょう。' } },
    { at: 15, action: 'leaderBrake', args: { aheadIndex: 3, decel: 3.0, duration: 2.5 } },
    { at: 16, action: 'hint', args: { text: '前が減速！ 強く踏まず、車間で吸収。' } },
  ],
  goals: ['後ろの車を 1 台も止めない（停止 0 台で ★3、3 台以下で ★2）', '急ブレーキ（-1.5 m/s² 未満）を避ける'],
  lesson: {
    title: '車間は「波を吸収するクッション」',
    body: [
      '前の車が急に減速しても、車間が広ければあなたは軽く減速するだけで済みます。あなたの減速が小さければ、後ろの車の減速はさらに小さくなり、波は消えていきます。',
      '逆に車間が詰まっていると、あなたは前より強く踏むことになり、波は増幅して後ろへ広がります。',
      '車間時間 2 秒（時速 60 km で約 33 m）が、波を吸収できる目安です。',
    ],
    fact: '渋滞学（西成活裕氏ら）の実験では、数台のドライバーが車間を空けて走るだけで渋滞の発生を遅らせ、解消を早められることが示されています。',
  },
  criteria: criteria02,
  stars: (summary, ctx = {}) => starsOf(criteria02(summary, ctx), ctx),
};

// ---- 03 ----------------------------------------------------------------------

/** 03: 試した台数（ctx.densitiesTried + 最終走行の密度）を重複なし・昇順で */
function densitiesTried(summary, ctx) {
  const set = new Set();
  if (Array.isArray(ctx.densitiesTried)) for (const d of ctx.densitiesTried) if (Number.isFinite(d)) set.add(Math.round(d));
  if (Number.isFinite(summary.density)) set.add(Math.round(summary.density));
  return [...set].sort((a, b) => a - b);
}

function criteria03(summary, ctx = {}) {
  const tried = densitiesTried(summary, ctx);
  const loss = lossPerCar(summary);
  // 再スタート前の走行 + 最終走行。「止まらなかった」証拠は十分な時間走った走行だけ、「止まった」証拠は時間を問わない
  const runs = Array.isArray(ctx.densityRuns) ? ctx.densityRuns.filter((r) => r && Number.isFinite(r.stoppedCount)) : [];
  const finalRun = { stoppedCount: summary.stoppedCount | 0, sec: Infinity };
  const all = [...runs, finalRun];
  // 「臨界を挟んだ」= 停止なしで DENSITY_RUN_MIN_SEC 以上走れた密度と、停止が出た密度の両方を経験し、
  // かつ両者の密度差が DENSITY_BRACKET_MIN_DIFF 以上（同じ密度の再走行では成立しない）
  const freeRuns = all.filter((r) => r.stoppedCount === 0 && (Number.isFinite(r.sec) ? r.sec : Infinity) >= DENSITY_RUN_MIN_SEC);
  const jamRuns = all.filter((r) => r.stoppedCount > 0);
  const bracketed = freeRuns.some((f) => jamRuns.some((j) => Math.abs((j.carCount ?? 0) - (f.carCount ?? 0)) >= DENSITY_BRACKET_MIN_DIFF));
  const good = loss <= DENSITY_GOOD_LOSS;
  let third;
  if (good) third = `1 台あたりの時間損失 ${loss.toFixed(1)} 秒（${DENSITY_GOOD_LOSS} 秒以下に抑えた）`;
  else if (bracketed) third = '渋滞が出ない密度と出る密度の両方を見つけた（臨界密度を挟んだ）';
  else third = `1 台あたりの損失 ${loss.toFixed(1)} 秒。${DENSITY_GOOD_LOSS} 秒以下に抑えるか、渋滞が出る密度と出ない密度の両方を見つけると ★`;
  return [
    completedCriterion(ctx),
    {
      ok: tried.length >= 2,
      label: tried.length >= 2
        ? `密度を ${tried.length} 通り試した（${tried.join(' / ')} 台）`
        : '密度は 1 通りだけ（スライダーで台数を変えて比べると ★）',
    },
    { ok: good || bracketed, label: third },
  ];
}

const LEVEL_03 = {
  id: 'density',
  no: '03',
  title: '高密度の道路',
  question: '誰も悪くないのに、なぜ渋滞は生まれる？',
  briefing: [
    '72 台（1 km に 72 台）の車列。誰も急ブレーキは踏みません。',
    'それでも、わずかな速度のゆらぎが増幅して、あちこちで渋滞の波が生まれます。',
    'あなたは車間を保ち、車列の損失を最小にしてください。密度スライダーで台数を変えて再スタートもできます。',
  ],
  howTo: 'W/↑ アクセル、S/↓ ブレーキ。加減速を最小にして、なめらかに走る。',
  simConfig: { carCount: 72, v0: 22.2, T: 1.05, tau: 0.65, noise: 0.25, sag: false, seed: 3 },
  playerMode: 'manual',
  durationSec: 120,
  densityRange: [40, 90],
  script: [
    { at: 0, action: 'markEvent', args: {} },
    { at: 3, action: 'hint', args: { text: '速度を一定に。前が詰まったら早めに、ゆるく減速。' } },
    { at: 60, action: 'hint', args: { text: '時空間図に斜めの赤い帯が出ていませんか？ それが渋滞の波です。' } },
  ],
  goals: [
    '密度スライダーで台数を変え、2 通り以上の密度を試す（★）',
    `1 台あたりの時間損失を ${DENSITY_GOOD_LOSS} 秒以下に抑える、または渋滞が生まれる境目（臨界密度）を挟んで両側を見つける（★）`,
  ],
  lesson: {
    title: '臨界密度を超えると、渋滞は「自然に」生まれる',
    body: [
      '交通量（台/h）は密度が上がるにつれて増えますが、ある密度（臨界密度、1 車線あたり約 25〜30 台/km）を超えると、速度が急に落ちて交通量は減り始めます。',
      '臨界密度を超えた車列では、誰かの小さなゆらぎが減速の波として増幅します。原因は個人ではなく「密度」そのものです。',
      'これを描いたのが「基本図（交通量－密度）」。渋滞学の最も基本的なグラフです。',
    ],
    fact: '日本の高速道路では、1 車線 1 km あたり 25 台前後を超えると自然渋滞が発生しやすくなるとされています（目安）。',
  },
  quiz: {
    q: '密度を上げていくと、交通量（1 時間に通る台数）はどうなる？',
    choices: ['ずっと増え続ける', 'ある密度までは増え、それを超えると減る', '密度に関係なく一定'],
    answer: 1,
    explain: '密度が臨界を超えると速度が大きく落ち、「密度 × 速度」である交通量は減ります。',
  },
  criteria: criteria03,
  stars: (summary, ctx = {}) => starsOf(criteria03(summary, ctx), ctx),
};

// ---- 04 ----------------------------------------------------------------------

function criteria04(summary, ctx = {}) {
  const n = summary.affectedCount | 0;
  // 急ブレーキした車と間の 2 台は必ず影響を受けるので最小 3。遅れなく反応すれば 3〜5、遅れると全車停止
  return [
    completedCriterion(ctx),
    { ok: n <= 12, label: n <= 12 ? `影響を受けた車は ${n} 台（12 台以下）` : `影響を受けた車が ${n} 台（12 台以下で ★）` },
    { ok: n <= 4, label: n <= 4 ? `波をあなたのところで止めた（影響 ${n} 台、4 台以下）` : '影響を 4 台以下に抑えると ★（前を見て、早めに、ゆるく減速）' },
  ];
}

const LEVEL_04 = {
  id: 'reaction',
  no: '04',
  title: '反応の遅れ',
  question: '「ちょっとスマホ」は、車列に何をする？',
  briefing: [
    'この車列のドライバーは反応が 1.5 秒遅れます（前を見ていない状態）。台数は 22 台と少なめです。',
    '15 秒後、3 台前の車が急ブレーキ。反応の遅れが 1 回の減速をどれだけ増幅するか体験します。',
    'あなただけは前を見ています。前の動きにすぐ反応して、あなたのところで波を止めてください。',
  ],
  howTo: 'W/↑ アクセル、S/↓ ブレーキ。前方の動きを先読みして、早めにゆるく減速する。',
  // 48 台では誰が運転しても全車停止になるため 22 台に調整（反応遅れ 1.5 s の車列は 22 台でも準安定）。
  // この密度では、プレイヤーも 1.5 s 遅れ（auto）だと全車停止、遅れなく反応する手動運転なら波は 3〜5 台で消える
  simConfig: { carCount: 22, v0: 22.2, T: 1.05, tau: 1.5, noise: 0, sag: false, seed: 4 },
  playerMode: 'manual',
  durationSec: 120,
  script: [
    { at: 3, action: 'hint', args: { text: '周りの車の反応は 1.5 秒遅れ。あなたは早めに動く。' } },
    { at: 15, action: 'leaderBrake', args: { aheadIndex: 3, decel: 3.0, duration: 2.5 } },
    { at: 16, action: 'hint', args: { text: '前が減速！ すぐに、しかし前の車より弱く。波はここで消せる。' } },
  ],
  goals: ['影響を受けた車を 4 台以下に抑える（★3）／ 12 台以下（★2）', '遅れずに、しかし前の車より弱く減速して波を吸収する'],
  lesson: {
    title: '反応の遅れは、波の「増幅器」',
    body: [
      '前の車の減速に気づくのが遅れると、同じだけ止まるためにより強いブレーキが必要になります。後ろの車も同じことを繰り返し、波は 1 台ごとに大きくなります。',
      '反応時間が 0.65 秒から 1.5 秒になるだけで、同じ密度・同じブレーキでも「波が消える車列」が「全車が止まる車列」に変わります。',
      '「前を見て、早めに、ゆるく」が、車列全体の損失を減らします。',
    ],
    fact: '人間のブレーキ反応時間は通常 0.7〜1.0 秒程度とされます。スマートフォン操作中は 1.5 秒程度まで延びるとされます（目安）。',
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

function criteria05(summary, ctx = {}) {
  // ratio = サグ上り区間でのプレイヤー最低速度 / 基準速度。前の車が減速するので 1.0 には届かず、0.7 前後が上限になる
  const ratio = sagRatioOf(summary, ctx);
  const loss = lossPerCar(summary);
  const pct = (ratio * 100).toFixed(0);
  return [
    completedCriterion(ctx),
    { ok: loss <= 13, label: loss <= 13 ? `1 台あたりの時間損失 ${loss.toFixed(1)} 秒（13 秒以下）` : `1 台あたりの時間損失 ${loss.toFixed(1)} 秒（13 秒以下で ★）` },
    {
      ok: loss <= 9 && ratio >= 0.65,
      label: loss <= 9 && ratio >= 0.65
        ? `サグの上りで速度を維持し（基準の ${pct}%）、損失を 9 秒/台以下に抑えた`
        : (ratio < 0.65
          ? `サグの上りで速度が基準の ${pct}% まで落ちた（65% 以上を維持し、損失 9 秒/台以下で ★）`
          : `損失 ${loss.toFixed(1)} 秒/台（9 秒以下で ★）`),
    },
  ];
}

const LEVEL_05 = {
  id: 'sag',
  no: '05',
  title: 'サグ部の罠',
  question: '下り坂のあとの上り坂で、なぜ速度は落ちる？',
  briefing: [
    'この周回路には「サグ部」（下り→上りの谷。250〜650 m 区間）があります。36 台の車列です。',
    '上り坂ではアクセルを踏み増さないと、気づかないうちに速度が落ちます。それが渋滞の起点になります。',
    'サグの上り（400〜650 m）で速度を維持し、あなたの後ろに波を作らないでください。',
  ],
  howTo: 'W/↑ アクセル、S/↓ ブレーキ。上り坂に入ったらアクセルを踏み増して速度を維持する。',
  // 60 台ではサグを起点に全車が停止してプレイヤーの運転が結果に影響しないため 36 台に調整。
  // 36 台: 何もしないと上りで 13% 減速して損失が約 2 倍（15 秒/台）、速度維持なら約 7 秒/台
  simConfig: { carCount: 36, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: true, seed: 5 },
  playerMode: 'manual',
  durationSec: 120,
  script: [
    { at: 0, action: 'markEvent', args: {} },
    { at: 3, action: 'hint', args: { text: '400 m 地点から上り坂。速度計を見て、落ちる前に踏み増す。' } },
    { at: 45, action: 'hint', args: { text: '上りで速度が落ちた車の後ろに波が出ています。' } },
  ],
  goals: ['サグの上りで速度を落とさない（基準の 65% 以上を維持）', '1 台あたりの時間損失を 9 秒以下に抑える（★3）／ 13 秒以下（★2）'],
  lesson: {
    title: 'サグ部は日本の高速道路渋滞の代表的な原因のひとつ',
    body: [
      'サグ部では下り坂で軽くなったアクセルのまま上りに入るため、ドライバーは無自覚に減速します。後続はそれに遅れて反応し、渋滞の波が発生します。',
      '見た目にはほとんど平坦に見える 1〜2% の勾配でも、車列が密なら十分に渋滞の起点になります。',
      '対策は「上りでアクセルを踏み増す」「車間を保つ」。道路側では速度回復を促す標識や LED 表示が設置されています。',
    ],
    fact: '日本の高速道路では、渋滞の発生原因として目安として過半がサグ部・上り坂によるものとされ、事故や工事による渋滞より多いといわれています。',
  },
  criteria: criteria05,
  stars: (summary, ctx = {}) => starsOf(criteria05(summary, ctx), ctx),
};

// ---- FREE --------------------------------------------------------------------

const FREE = {
  id: 'free',
  no: 'FREE',
  title: 'フリーラボ',
  question: '渋滞が生まれる条件を、パラメータを動かして自分で探そう',
  briefing: [
    '台数・車間時間・反応の遅れ・希望速度・運転のばらつき・サグ部をスライダーで変えられます。',
    '台数とサグ部の変更は車列をリセットします。ほかは走行中に効きます。',
    '時間制限も採点もありません。気になったら「ブレーキを踏む」で波を起こしてみましょう。',
  ],
  howTo: 'W/↑ アクセル、S/↓ ブレーキ。「自動運転」を入れると RX-7 も車列に従って走ります。',
  simConfig: { carCount: 48, v0: 22.2, T: 1.05, tau: 0.65, noise: 0, sag: false, seed: 42 },
  playerMode: 'auto',
  durationSec: 600,
  densityRange: [20, 100],
  script: [],
  goals: [],
  lesson: {
    title: '渋滞学の 4 つのつまみ',
    body: [
      '密度（台数）: 臨界を超えると自然渋滞が生まれる。',
      '車間時間 T: 大きいほど波を吸収できるが、交通量は減る。',
      '反応の遅れ tau: 長いほど波が増幅する。',
      'サグ部: 無自覚な減速の起点になる。',
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

/**
 * リザルト用。stars と表示行を返す。
 * ctx = { completed, quizCorrect, playerSagMinSpeedRatio, playerPulses, densitiesTried, densityRuns }
 * 表示行: 途中終了の注記 → 数値行 → クイズ → サグ速度比 → 星ごとの理由（★ 達成 / ☆ 未達成と条件）→ 評価
 */
export function evaluate(level, summary, ctx = {}) {
  const stars = Math.max(0, Math.min(3, level.stars(summary, ctx) | 0));
  const lines = [];
  if (ctx.completed === false) lines.push('レベルを最後まで走りませんでした。');
  lines.push(...statLines(summary));
  if (level.quiz && ctx.quizCorrect !== undefined) {
    lines.push(ctx.quizCorrect ? 'クイズ: 正解' : `クイズ: 不正解（正解は「${level.quiz.choices[level.quiz.answer]}」）`);
  }
  const sagRatio = Number.isFinite(ctx.playerSagMinSpeedRatio) ? ctx.playerSagMinSpeedRatio : summary.playerSagMinSpeedRatio;
  if (level.id === 'sag' && Number.isFinite(sagRatio)) {
    lines.push(`サグの上りでの最低速度: 基準の ${(sagRatio * 100).toFixed(0)}%`);
  }
  if (typeof level.criteria === 'function') {
    for (const c of level.criteria(summary, ctx)) lines.push(`${c.ok ? '★' : '☆'} ${c.label}`);
  }
  if (level.id !== 'free') lines.push(`評価: ${'★'.repeat(stars)}${'☆'.repeat(3 - stars)}`);
  return { stars, lines };
}
