1. ✅解消: `startLevel()` は `recordDensityRun()` 直後、`buildSim()` 前に `releaseInputs()` を呼んでおり、`trial = null` と入力解除が先に走る。`ctx.attempts` は `attemptLog.attempts` 共有で残る。

2. ✅解消: `criteria02` の差分判定は `timeLoss` 比のみ。`criteria03` も混雑側比較は `timeLoss` 比、静/動判定は `QUIET_LOSS_SEC=20` / `BUSY_LOSS_SEC=45` の遅れ秒で、実測 10 秒/55 秒や 13 秒/95 秒に対して達成可能かつ閾値差も残る。

3. ✅解消: `evaluate()` は星 0 かつ達成項目ありなら先に「※ …評価の対象外です」を出し、達成済み項目を `・`、未達を `☆` にしているため、星 0 の理由は伝わる。

## 新たな問題
なし
