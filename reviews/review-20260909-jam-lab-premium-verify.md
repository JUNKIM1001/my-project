1. ✅解消: `titleFree` は `unlockedIds().has(FREE_LEVEL.id)` で未解放時に toast、`openBriefing` も `LEVELS[0]` 以外のロック中を `showTitle()` に戻し、`resultNext` も同ガードあり。

2. ✅解消: `LEVEL_03.goals[2]` は「混んだ側の遅れを、すいた側の 1.5 倍以上にする」で、`criteria03` も `ratio(hi.timeLoss, lo.timeLoss)` 判定。

3. ⚠️不完全: `pointerId` 保持と capture 対応は入ったが、`setPointerCapture` 非対応時にボタン外で離すと `pointerup` を拾えず、通常の画面内操作では `blur` も発火しない可能性が残る。

4. ✅解消: `lastGoalsKey` 比較で同一 items の `setGoals` を抑止し、`startLevel` 冒頭側で `lastGoalsKey = ''` 後に初回 `setGoals` するため、切替・やり直し・密度再スタート経路も抜けない。

## 新たな問題
[P2] `hud.js:209-213`: pointer capture 非対応環境向けに `window`/`document` の `pointerup`/`pointercancel` fallback がなく、踏みっぱなし状態が残り得ます。
