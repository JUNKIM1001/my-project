# カジュアルゲーム仕上げ 仕様（2026-09-09）

ユーザー決定: (1) プレイ中はシンプル表示に切替 (2) 効果音あり・BGM なし・ミュート可 (3) 星＋スコア（0〜100）。
外部ファイル・外部通信は引き続きゼロ（音は Web Audio で合成）。

## 1. 表示モード（hud.js / index.html / game.js）

- `hud.setViewMode('simple' | 'detail')`。**プレイ中の既定は simple**。トップバー右に「詳細 / シンプル」切替ボタン。
  選択は `localStorage['jamlab.viewMode']` に保存。タイトル・ブリーフィング・リザルトはモードに関係なく従来どおり。
- **simple で見せるもの**
  - トップバー: ロゴ、レベルタブ、残り時間、ミュート、詳細切替
  - ミッションバナー（上部中央・1 行）: 「実験 02 長く踏むと、どうなる？ ─ S / ↓ を押している間ブレーキ」
  - 中央下の車パネル: 速度（大）、ブレーキ計（大・現状より 1.3 倍）、**スコア**（現在値、右肩に「ベスト」）
  - 下: **散布図だけ**を横幅いっぱいに（平均速度グラフ・時空間図は非表示）
  - 密度を変えられるレベル（`level.densityRange`）だけ、バナー下に台数スライダーを 1 本
  - タッチ端末: 画面下の大きなブレーキボタン（現状どおり）
- **simple で隠すもの**: 左の実験パネル（説明・T/τ スライダー・やり直し/結果ボタン → 結果ボタンはトップバーへ移す）、
  右の「周回路のいま」「あなたが起こした波」、観察記録の平均速度・時空間図。
- detail は現状の研究機器風 HUD をそのまま出す。

## 2. スコア（levels.js / game.js）

`scoreOf(level, summary, ctx) → 0..100 の整数`。「実験の達成度」で、星と矛盾しない。
- 60 点: criteria 3 件 × 20 点（gate 未達・未完走なら criteria 分は 0）
- 20 点: 探究度 = min(試行回数, 3) / 3 × 20（05 dont-brake だけは逆で、踏んだ合計が 0 秒で 20、1 秒で 10、2 秒以上で 0）
- 20 点: クイズ正解で 20（クイズの無いレベルは、criteria を 30 点 × 3 = 90 とし探究度 10）
- FREE はスコアなし（null）。
- `progress[level.id]` は `{ stars, score }` に拡張（旧形式の数値だけなら stars とみなし score は null）。
- HUD: プレイ中は暫定スコアをリアルタイム表示（試行が増えるたび更新）。リザルトで確定値をカウントアップ、
  ベスト更新なら「NEW BEST」バッジ。

game.js → hud: `hud.setScore({ current, best, isNewBest })`。`hud.showResult(r)` の r に `score, bestScore, isNewBest` を追加。

## 3. 効果音（src/ui/sound.js、新規）

```js
import { createSound } from './ui/sound.js';
const sound = createSound();          // AudioContext は遅延生成
sound.unlock();                        // 最初の pointerdown / keydown で呼ぶ（自動再生制限の解除）
sound.setMuted(bool); sound.muted;     // localStorage['jamlab.muted'] に保存
sound.play('click');                   // 単発
sound.brake(true / false);             // ブレーキ中の持続音（開始 / 停止）
```
単発の名前: `click`（ボタン）, `start`（レベル開始のウーッシュ）, `trial`（試行が 1 点記録された時のポン）,
`tick`（カウントアップ 1 刻み・短く軽い）, `star`（星 1 つ・音程を 1 つずつ上げる: star1/star2/star3）,
`fanfare`（3 星）, `newBest`（ベスト更新）, `hint`（トースト表示・控えめ）。
すべて 0.05〜0.6 秒のオシレータ／ノイズ合成。音量は控えめ（マスター -12 dB 相当）。ミュート中は無音・例外なし。
AudioContext が作れない環境では全メソッドが no-op。

## 4. 演出（hud.js / charts.js / index.html）

- ブレーキ中: 画面端に赤いビネット（CSS、opacity をブレーキ計と同期）。速度の数字を赤く。
- 試行記録時: 散布図の新しい点が「ポン」と拡大→収束するアニメ（0.4 秒）、
  ブレーキ計の結果行がスライドイン。
- リザルト: 星を 1 つずつ 0.25 秒間隔でポップ、スコアを 0 → 確定値へ 0.8 秒でカウントアップ（tick 音を間引いて）、
  3 星なら紙吹雪（Canvas オーバーレイ、1.5 秒、prefers-reduced-motion では省略）。
- タイトル: ロゴがゆっくり浮遊、主ボタンが呼吸するように明滅（reduced-motion では静止）。
- 初回だけのオンボーディング: 最初のレベル開始時に「S / ↓ を押している間ブレーキ」の吹き出しをブレーキ計の上に出し、
  最初のブレーキで消す。`localStorage['jamlab.onboarded']`。

## 5. hud のイベント（追加）

`toggleView`（詳細/シンプル）, `toggleMute`。既存イベントは維持。
game.js は `hud.setMuted(bool)` / `hud.setViewMode(mode)` で表示を同期する。
