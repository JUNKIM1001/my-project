1. ✅解消: `scoreOf` は `!gateOk` で `min(ZERO_STAR_MAX, explore + quiz)`、`ZERO_STAR_MAX = 25`。テストも星0上限25 < 星1最低点を確認。

2. ✅解消: `refreshHud` の `hud.setScore` が `g.phase === 'playing'` 条件内に限定済み。

3. ⚠️不完全: `stars` 不正は削除されるが、`score` の不正値は削除ではなく `null`、範囲外数値は clamp される実装。要件の「不正なら削除」とは完全一致しない可能性あり。

4. 誤検知: `.hud.mode-simple` は `.side` 等を隠すが、`panel-log` は `grid-area: "log"` で残り、`btn-pause` は観察記録内に存在。

5. 誤検知: `hideModals()` 冒頭で `cancelResultFx()`、`showResult()` 冒頭でも `hideModals()`。rAF、timeout、紙吹雪停止も確認。

6. ✅解消: `score-block` は `aria-hidden="true"`、`res-score` は `role="img"`。`showResult` で確定スコアの `aria-label` を設定済み。

## 新たな問題
なし
