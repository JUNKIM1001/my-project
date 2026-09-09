1. ✅解消: `fit-wheels.mjs` は body の bufferView を丸ごとコピーし、accessor は spread で `byteOffset` を保持、`byteStride` も `views[nv2]` に継承。`viewMap` で共有 bufferView も 1 回だけコピー。

2. ✅解消: `releaseInputs` が observe 中なら `observeReturnCam` または `chase` に `setCamera` 後、`observeReturnCam = null`。`setCamera` は `g.sim` 無しなら HUD 車両更新を省く。

3. ✅解消: `images` は `bufferView != null` の画像だけ差し替え、`{ ...im }` / `{ ...im, bufferView: ... }` で他プロパティを保持。

4. ❌未対応: yaw 回帰の外れ値対策は今回据え置き。

5. ❌未対応: 後輪トラック調整は今回据え置き。

## 新たな問題
なし。`applyMode` / `showTitle` / `openBriefing` 経由の `releaseInputs → setCamera` は `scene` 存在前提なら問題なし。observe 中に `C` を押すと `cycleCamera` が `observeReturnCam` を破棄し、`observe` が cycle 配列外なので `chase` へ遷移する。
