1. ✅解消: `disposed` は `disposeCar` で立ち、`rx7` の loader callback と `finish()` 冒頭の両方で中断。2台目は `cached.clone(true)` 経由でも `finish()` 判定を通る。

2. ⚠️不完全: キャッシュ元 material は触らず複製だけを割当済み。ただし `tailMaterial` と `tailMaterials[0]` が同一で、`disposeCar` が同じ material を2回 `dispose()` する。

3. ✅解消: placeholder の `tailMaterial` を親 `group.userData` に委譲しており、GLB 到着前も `setBrake(gtr, ...)` が効く。到着時は placeholder 材を破棄して GLB 材へ差し替え。

4. ⚠️不完全: `setCarCount()` では `prevPlayerS = null`。`update()` も 60m 超ジャンプ時は wheel 回転をスキップ。ただし台数同一のレベル切替で呼び出し側が `setCarCount()` を呼ばない場合、60m 以下の位置差は残る可能性あり。

## 新たな問題
[P2] `disposeCar` が `tailMaterial` と `tailMaterials` 内の同一 material を重複 dispose する。テクスチャ自体は dispose していないため二重解放ではないが、dispose event は重複し得ます。
