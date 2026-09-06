# JAM LAB — 渋滞のしくみを、RX-7 (FD3S) で走って学ぶ

ブラウザ完結型の 3D 渋滞学習ゲーム。プレイヤーはマツダ RX-7（FD3S）に乗り、
海沿いの 1 km 周回路を数十台の車列の中で走る。ブレーキ・車間・密度・反応時間・サグ部が
渋滞波（自然渋滞）をどう生むかを、自分の運転の結果として体験・計測し、レベルごとの評価と解説で学ぶ。

参照: 泉水亮介氏の Facebook リール（AFTERFLOW）。環状 1 車線に 48 / 72 台、
「01 小さなブレーキ / 02 先を読む運転 / 03 高密度の道路」の 3 実験、追従・上空カメラ、
「影響を受けた後続車」「総時間損失」「渋滞波の速度」の計測、時空間図。本作はこれを
**ゲーム化（レベル・目標・星評価・解説カード）**し、車を RX-7 (FD3S) に固定した独自実装（初版は GT-R R34。2026-09-06 にユーザー提供のイラストを基準に RX-7 へ変更）。

## 完了条件（(0) 要件確認）

1. `python3 -m http.server` で配信した `index.html` が単独で動き、5 レベル + フリーラボが最後まで遊べる
2. 車列シミュレーション（IDM + 反応遅れ）が単体テストで検証されている（`node --test`）
3. Codex 独立レビュー（デザイン / コード / システムの 3 観点）で P0/P1 ゼロに収束

## スタック / 構成

- 静的サイト・ビルド無し・ES Modules。three.js r185 は `vendor/` に同梱（MIT、`vendor/THREE-LICENSE`）
- 外部通信ゼロ。フォントはシステムフォント
- テストは `node --test tests/*.test.mjs`（sim / shared のみ。render / ui は DOM 依存なのでブラウザで確認）

```
jam-lab/
  index.html              UI シェル（CSS 込み）+ <canvas id="scene">
  vendor/three.module.js  three.js r185（three.core.js と併せて同梱）
  src/
    shared/track.js       周回路の共通定義（全長・車長・座標変換・サグ勾配）※完成済み・変更禁止
    sim/model.js          車列シミュレーション（純粋 JS、DOM 非依存）
    sim/metrics.js        計測（影響台数・総時間損失・渋滞波速度・時空間バッファ・基本図）
    sim/levels.js         レベル定義（シナリオ・パラメータ・目標・星判定・解説）
    render/scene.js       three.js シーン（海・空・道路・ガードレール・照明・朝/夕）
    render/carkit.js      車の共通キット（マテリアル・断面ロフト・一般車・ブレーキ切替）
    render/rx7.js         RX-7 (FD3S) のプロシージャルモデル
    render/camera.js      カメラ（追従 / 上空追従 / 全景 / 運転席）
    ui/hud.js             パネル描画（左: 実験 / 右: 影響 / 下: 観察ログ / 中央下: 車情報）
    ui/charts.js          Canvas 2D チャート（平均速度の時系列、時空間図、ミニマップ）
    game.js               状態機械（タイトル → ブリーフィング → プレイ → リザルト）・採点
    main.js               起点。sim / render / ui を結線
  tests/*.test.mjs
  README.md
```

## 座標・単位（全モジュール共通）

- 位置 `s` [m]: 周回路に沿った 1D 座標、`0 <= s < LENGTH(1000)`。進行方向は s 増加。
- 速度 `v` [m/s]、加速度 `a` [m/s²]。表示時のみ km/h に変換（×3.6）。
- 車配列 `cars[i]` は **s 昇順にソート済み**で、`cars[i]` の先行車は `cars[(i+1) % N]`。
  周回路なので最後尾 `cars[N-1]` の先行車は `cars[0]`（1 周またぎ）。
- 車間 `gap = forwardDistance(s_i, s_leader) - CAR_LENGTH`（バンパー間、m）。
- プレイヤー車は `cars[playerIndex]`。初期は `playerIndex = 0`。ソートは維持するので
  `playerIndex` は不変（車は追い越さない）。
- 3D 座標は `shared/track.js` の `pointAt(s)` と `elevationAt(s, sag)` から導く。

## モジュール API 契約

### `src/sim/model.js`

```js
import { createSim } from './sim/model.js';

const sim = createSim({
  carCount: 48,          // 台数（周回路 1 km なので = 密度 台/km）
  v0: 22.2,              // 希望速度 m/s（80 km/h）
  T: 1.05,               // 目標車間時間 s（IDM）
  tau: 0.65,             // 反応遅れ s（先行車の gap / 速度差を tau 秒前の値で見る）
  a: 1.0, b: 1.6,        // IDM 最大加速 / 快適減速 m/s²
  s0: 2.0,               // 停止時最小車間 m
  noise: 0.0,            // 加速度ノイズの標準偏差 m/s²（0 で決定論的。高密度レベルで 0.2〜0.3）
  sag: false,            // true でサグ勾配を有効化（shared/track.js の gradeAt を使う）
  playerIndex: 0,
  seed: 1,               // 乱数シード（決定論的テストのため。xorshift 等の自前 PRNG）
  initialSpeedRatio: 1,  // 初期速度 = v0 × この比率（均等配置・定常状態から開始）
});

sim.params        // 現在のパラメータ（読み取り専用ビュー）
sim.setParams({ T, tau, v0, noise })   // 走行中に変更可（carCount / sag は reset 時のみ）
sim.reset(overrides?)                  // 初期化（均等配置、全車 v0×initialSpeedRatio）

sim.setPlayerControl({ mode: 'auto' | 'manual', throttle: 0..1, brake: 0..1 })
  // auto: プレイヤー車も IDM で走る（レベル 1 の「ボタンでブレーキ」用）
  // manual: a = throttle*A_MAX - brake*B_MAX、ただし前方衝突は物理的に防ぐ（gap<0.3m で v=leader.v に飽和）
  // A_MAX = 3.0, B_MAX = 6.0（スポーツカーらしく強めだが、衝突は起こさない）
sim.pulseBrake({ decel: 2.0, duration: 2.0 })
  // 「ブレーキを踏む」ボタン。auto モードでもプレイヤー車に duration 秒間 -decel を強制
sim.triggerLeaderBrake({ aheadIndex: 3, decel: 3.0, duration: 2.5 })
  // プレイヤーの aheadIndex 台前の車に強制ブレーキ（レベル 2/4 のイベント）

sim.step(dt)      // dt は 0.05 固定を推奨（main が実時間×倍速をサブステップに分割して呼ぶ）
sim.time          // 経過秒
sim.cars          // Float64Array ではなく通常配列 [{ s, v, a, id, isPlayer, braking }]
                  // braking: a < -0.5 のとき true（ブレーキランプ表示用）
sim.playerIndex
```

数値モデル: IDM（Treiber 2000）。
`a = a_max * (1 - (v/v0)^4 - (s*/gap)^2)`, `s* = s0 + v*T + v*Δv / (2*sqrt(a_max*b))`。
反応遅れ tau は、各車が保持する「先行車の gap / Δv の履歴」を tau 秒遡って参照する（履歴長は
tau/dt 個のリングバッファ）。勾配は `a -= 9.81 * gradeAt(s, sag)`。ノイズは `a += N(0, noise)`。
数値安定化: a を [-9, +4] にクランプ、v を 0 以上にクランプ、gap < 0.3 m なら v = min(v, leader.v)。
車は追い越さない（順序不変）。決定論: 同じ seed・同じ入力列で同じ結果。

### `src/sim/metrics.js`

```js
import { createMetrics } from './sim/metrics.js';
const m = createMetrics(sim, { freeFlowSpeed: sim.params.v0 });

m.markEvent()          // 「イベント開始」時刻を打刻（ブレーキ操作・強制イベント時に game が呼ぶ）
m.update(sim)          // 毎 sim.step 後に呼ぶ
m.summary()            // 下記
{
  affectedCount,       // イベント後、速度が v0×0.7 未満に落ちた「プレイヤー以外の」車の台数（累計、重複なし）
  totalTimeLoss,       // Σ_{i≠player} ∫ max(0, 1 - v_i/v0) dt  [秒]（イベント後累計）
  stoppedCount,        // イベント後に v < 1 m/s を経験した車の台数
  waveSpeed,           // 渋滞波の伝播速度 [km/h]（後方へ進むので負。データ不足時は null）
                       // 算出: 各車が「初めて v < v0×0.5 になった (t, s)」を集め、s の後退距離と t で線形回帰
  meanSpeed,           // 現在の平均速度 m/s
  flow,                // 交通流率 台/h = density × meanSpeed × 3.6（density = N / 1 km）
  density,             // 台/km
  playerMinGapTime,    // プレイヤーの車間時間の最小値 [s]（安全運転評価）
  playerBrakeEvents,   // プレイヤーの a < -1.5 の回数
}
m.history            // { t: number[], meanSpeed: number[] }（1 秒ごとに間引き、最大 600 点）
m.spaceTime          // 時空間図用。{ times: number[], rows: Array<Float32Array(N)> }
                     // 0.5 秒ごとに全車の v/v0 (0..1) を記録、最大 240 行（120 秒分）。古い行は捨てる
```

### `src/sim/levels.js`

```js
import { LEVELS, evaluate } from './sim/levels.js';
LEVELS: Array<{
  id: 'brake-once' | 'absorb-wave' | 'density' | 'reaction' | 'sag',
  no: '01'..'05', title, question,        // 例: '01', '小さなブレーキ', '1台の減速は、どこまで届く？'
  briefing: string[],                     // ブリーフィングの箇条書き（2〜3 行）
  howTo: string,                          // 操作説明 1 行
  simConfig: {...createSim の引数},
  playerMode: 'auto' | 'manual',
  durationSec: number,                    // 制限時間（シム秒）。経過で自動リザルト
  script: Array<{ at: number, action: 'pulseBrake' | 'leaderBrake' | 'hint', args }>,  // 時刻発火イベント
  goals: string[],                        // リザルトに出す目標文
  lesson: { title, body: string[], fact: string }, // 解説カード（渋滞学の知見）
  stars(summary, ctx) => 0..3,            // 星判定（純粋関数）
  quiz?: { q, choices: string[], answer: number, explain }  // 任意
}>
evaluate(level, summary, ctx) => { stars, lines: string[] }
  // ctx = { completed, quizCorrect, playerPulses, pulseDuration, leaderAhead, eventTime, carCount, tau,
  //         playerSagMinSpeedRatio, densitiesTried: number[], densityRuns: [{carCount, sec, stoppedCount, totalTimeLoss}] }
  // 各レベルは criteria(summary, ctx) → 3 件の {ok, label, gate?} を返し、stars = ok の数（gate 不成立なら 0）
```

レベル案（実装時に微調整可）:

| # | id | 学ぶこと | 設定 | 星 |
|---|---|---|---|---|
| 01 | brake-once | 1 台の 2 秒ブレーキが後方へ波として伝わる。波は後ろへ約 15〜20 km/h で進む | 48 台、auto、B キーで pulseBrake、90 秒 | 観察完了 + クイズ正解で 3 |
| 02 | absorb-wave | 車間を空けて「波を吸収する」運転。前方 3 台目が急ブレーキ→自分の後ろの車を止めない | 48 台、manual、t=15 で leaderBrake、120 秒 | 後続の stoppedCount 0 / 3 以下 / それ以上 |
| 03 | density | 密度が臨界を超えると、誰も悪くないのに自然渋滞が生まれる | 72 台、noise 0.25、auto→manual、120 秒。密度スライダー 40〜90 で再スタート可 | 走行中の totalTimeLoss を抑える |
| 04 | reaction | 反応遅れが長いほど波が増幅する。スマホ見ながら運転 = tau 1.5 s | 48 台、tau 1.5、manual、t=15 leaderBrake、120 秒 | 後続 affectedCount を抑える |
| 05 | sag | サグ部（下り→上り）で無自覚に速度が落ち、渋滞の起点になる | 60 台、sag: true、manual、120 秒 | サグ通過時のプレイヤー速度維持 + totalTimeLoss |
| — | free | フリーラボ: 全パラメータをスライダーで触れる | 任意 | 星なし |

### `src/render/scene.js`

```js
import { createScene } from './render/scene.js';
const scene = createScene(canvas, { sag: false });
scene.update(sim, dtReal, { cameraMode, playerIndex })  // 毎フレーム。sim.cars から位置更新
scene.setCameraMode('chase' | 'overhead' | 'overview' | 'cockpit')
scene.setTimeOfDay('morning' | 'dusk')
scene.setSag(bool)        // 道路メッシュを再構築（レベル切替時）
scene.setCarCount(n)      // インスタンス数の変更（レベル切替時）
scene.resize()
scene.dispose()
```

- 道路: `pointAt(s)` を 2 m 刻みでサンプリングしたリボン（幅 7 m、1 車線 + 路肩）。センターライン、外側ガードレール、
  照明ポール（60 m 間隔）。高さは `elevationAt(s, sag)`。
- 海: 大きな平面（反射風の淡いグラデ・簡易波アニメでよい）。空: `THREE.Fog` + 背景色グラデ（Sky シェーダ不要）。
  朝 / 夕で光源色・背景色を切替。
- 車: プレイヤーは `rx7.js` の RX-7 (FD3S)。他車は 3〜4 色の一般車（セダン風の簡易形状）。`InstancedMesh` は必須ではないが
  72 台 × 60fps を維持。ブレーキランプ: `car.braking` で赤く発光（emissive）。
- カメラ: chase = 後方 9 m・高さ 3.5 m からプレイヤーを追う（ラグ付き）。overhead = 上空 60 m から追従。
  overview = 周回路全体を見下ろす固定。cockpit = 運転席。

### `src/render/rx7.js` / `src/render/carkit.js`

- `createRX7(): THREE.Group`（進行方向 = **+X**、全長 4.48 m、全幅 1.88 m、全高 1.17 m、原点 = 車体中心の地面）。
  2026-09-06 にプロシージャル生成をやめ、`assets/rx7-fd3s.glb` の読み込みに変更（生成手順は `tools/README.md`）。
  読み込みは非同期。到着までは carkit の簡易セダンを白で表示する。
- プロシージャル（BoxGeometry / ExtrudeGeometry / Cylinder の組み合わせ）。R34 らしさの要素:
  ベイサイドブルー（#3F5AA6 系のメタリック風）、角張ったボディ、張り出したフェンダー、ボンネットの盛り上がり、
  4 灯の丸型テールランプ（左右 2 個ずつ）、大型リアウィング、深いフロントバンパー開口、5 本スポーク風のホイール。
- `createTrafficCar(colorHex): THREE.Group` 同じ向き・寸法規約の簡易セダン。
- `setBrake(group, on)` テールの emissive 切替（RX-7 は 4 灯すべて）。
- 依存: `../../vendor/three.module.js` のみ。

### `src/render/camera.js`

- `createCameraRig(camera) → { setMode(mode), update(playerPose, dtReal) }`。`playerPose = { x, y, z, fx, fz }`。
- chase / cockpit はプレイヤー基準、overhead は上空追従、overview は固定俯瞰。モード切替は 0.6 秒補間。

### `src/ui/*` / `src/game.js` / `src/main.js`

- 画面構成（AFTERFLOW を参照しつつ独自デザイン）: 全画面 canvas の上にガラス風の暗いパネルを重ねる。
  - 上: ロゴ「JAM LAB」+ レベルタブ 01〜05 + FREE、右上にレベル経過時間
  - 左: 実験パネル（問い・説明・主操作ボタン・スライダー: 目標車間時間 T / 反応の遅れ tau）
  - 右上: 周回路のいま / RING STATUS（周回路ミニマップ、車を点で描く。速度で色: 青緑=流れている / 赤=停止）
  - 右下: あなたが起こした波 / WAVE IMPACT（影響を受けた後続車、後続車の総時間損失、渋滞波速度）
    ※ 初版は参照アプリと同じ英語ラベル・配置だったが、Codex デザインレビュー（P1: 構造名が類似）を受けて日本語主導のラベルと配置に変更
  - 中央下: あなたの車（「RX-7 FD3S」、速度 km/h 大表示、視点切替 C、朝/夕。ガレージ機能は持たない）
  - 下: 観察記録 / TIMELINE（一時停止 Space、×1/×2/×4、平均速度チャート、時空間図。モバイルでも時空間図は縮小表示で残す）
  - モーダル: タイトル、ブリーフィング、リザルト（星・数値・解説カード・クイズ）
- キー: W/↑ アクセル、S/↓ ブレーキ、B ブレーキパルス（レベル 1）、C カメラ、Space 一時停止、1/2/3 倍速。
  モバイルは画面下にアクセル / ブレーキの大ボタン（タッチ）。
- 「ブレーキを踏む」はレベル 1 では B キー or ボタン。manual レベルではアクセル / ブレーキを押し続ける方式。
- ゲームループ: `requestAnimationFrame` の実時間 dt を倍速で掛け、0.05 s のサブステップで `sim.step`。
  上限は 1 フレーム 0.25 s（タブ復帰時の暴走防止）。

## レビュー観点（実装時に登録）

1. IDM の数値安定性（dt=0.05、高密度・tau 大で振動発散しないか、負速度・追い越しの禁止）
2. 反応遅れバッファの境界（tau 変更時、reset 時、履歴不足時の挙動）
3. 周回路またぎ（s の wrap、最後尾→先頭のギャップ、時空間図の描画）
4. 計測の定義と再現性（affectedCount の重複計上、waveSpeed の回帰に外れ値、イベント前のデータ混入）
5. ゲームループの時間管理（倍速、タブ非アクティブ、一時停止中の metrics 更新）
6. 描画パフォーマンス（72 台、毎フレームの Geometry 再生成禁止、dispose 漏れ）
7. UI/UX（学習体験として問い→操作→結果→解説が成立しているか、AFTERFLOW の丸写しになっていないか、モバイル）
8. 依存・ライセンス（three.js MIT 表記、外部通信ゼロ、車の商標は「マツダ RX-7 (FD3S)」の名称表記のみでロゴ等は使わない）
