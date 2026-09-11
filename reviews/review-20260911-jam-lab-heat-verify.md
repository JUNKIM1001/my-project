1. ✅解消: `game.js` / `scene.js` / `charts.js` とも `ref = Math.min(valid equilibriumSpeed, v0)` で上限丸め済み。

2. ✅解消: `scene.js` は `nSeg` 以降 `col.count/2` まで先頭区間の RGBA 8 要素をコピーしており、終端頂点の保険あり。

3. ✅解消: `mmCache` は canvas ごとの `Map`。復元時に `mmPath/mmSagPath/mmStartX/Y` と `mmScale/mmCx/mmCy` を同じ cache から戻しており、`projX/projY` と整合。`h < 0.05` は `heatCss` 前に skip なので index 1 着色問題もなし。

4. ⚠️不完全: 読み上げ文は指定文面に変更済み。ただし `aria-live` は許可ファイル外のため未確認。

## 新たな問題
なし。
