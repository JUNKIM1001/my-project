### [P1] 0 星でも高スコアになり得る
該当行: `levels.js:570-581`  
問題: `completed === false` や gate 未達でも、探究度とクイズ点は入るため、星 0 で最大 40 点が出ます。「星と矛盾しない」要件と逆転します。  
修正案: `gateOk` が false の場合は `critPts` だけでなく、少なくとも quiz/explore の上限も抑えるか、星 0 時の最大点を明示的に制限する。

### [P1] リザルト直前に liveScore が確定結果と食い違う
該当行: `game.js:58-60`, `593-603`  
問題: `liveScore()` が常に `{ completed: true }` で上書きします。`finish(false)` 後から `showFinal()` まで、HUD は完走扱いの暫定点を表示し得ます。  
修正案: `g.phase === 'result'` では `ctx.completed` を尊重するか、リザルト遷移時に live score 更新を止める。

### [P1] 進捗の壊れた値が残る
該当行: `game.js:35-39`, `312-316`, `636-640`  
問題: 旧数値は読めますが、`{ stars: "3", score: "100" }` や範囲外数値を正規化していません。`hud.setLevels(allLevels, progress)` に壊れた型が渡る可能性もあります。  
修正案: `loadProgress()` で `{ stars: clampInt(0..3), score: finite 0..100 or null }` に正規化する。

### [P2] simple で一時停止 UI が見えない可能性
該当行: `index.html:123-124`, `145`, `488-505`, `game.js:653`  
問題: simple は `.side` と `.sheet-toggle` を隠し、トップバーには pause ボタンがありません。タッチ利用者は一時停止に到達できない恐れがあります。  
修正案: simple トップバーにも pause アイコンを置くか、pause だけは隠さない。

### [P2] リザルト演出の後始末が showResult 内で閉じていない
該当行: `hud.js:676-705`  
問題: `setTimeout` と `countUp` を開始しますが、この関数内にはキャンセル責務が見えません。モーダルを閉じた後に `onTick/onDone` が走るリスクがあります。  
修正案: `showResult` 開始時とモーダル close 時にタイマー/rAFを必ず cancel する。

### [P2] スコア読み上げが不安定
該当行: `index.html:599-601`, `710-712`, `hud.js:295-301`, `699-705`  
問題: live score は頻繁更新、result score はカウントアップですが、読み上げ方の指定がありません。支援技術で過剰通知または無通知になり得ます。  
修正案: live は `aria-hidden`、result の確定値だけ `aria-live="polite"` にする。

## 総評
主要機能は仕様に沿っていますが、スコア整合と進捗正規化は先に固めたいです。  
音は概ね堅実ですが、リザルト演出のキャンセル境界は明確化が必要です。
