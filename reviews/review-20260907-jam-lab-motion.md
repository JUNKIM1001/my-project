### [P1] RX-7 の dispose 後にロード完了で再追加される
該当行: `rx7.js:69-79`, `carkit.js:377-385`  
問題: `disposeCar(gtr)` 後も `GLTFLoader.load` の成功コールバックが生きており、`finish()` が外れた group に GLB を追加します。scene には戻らない可能性が高いですが、GPU/メモリ上の orphan を作ります。  
修正案: `group.userData.disposed` を立て、`finish` 冒頭で中断。必要なら placeholder も dispose。

### [P1] GLB clone が material を共有している
該当行: `rx7.js:73-78`, `carkit.js:379-381`  
問題: `cached.clone(true)` は geometry だけでなく material も共有します。`disposeCar` は `sharedGeometry` でも material を dispose するため、複数 RX-7 や再生成時に共有 material を壊す経路があります。  
修正案: clone 後に mesh material を clone するか、共有 material は dispose 対象外にする。

### [P2] フォールバック車のブレーキランプが点かない
該当行: `rx7.js:61-67`, `carkit.js:365-369`  
問題: placeholder は子 group に tailMaterial を持つ一方、`setBrake(gtr, braking)` は親を見るため早期 return します。GLB 到着前の簡易セダンは braking を反映しません。  
修正案: 親 `userData.tailMaterial` を placeholder へ委譲するか、`setBrake` が子も探索する。

### [P2] レベル切替直後にホイールだけ大回転し得る
該当行: `game.js:97-106`, `scene.js:487-490`  
問題: `interp` は初期化されますが `prevPlayerS` は scene 側に残ります。新旧レベルの player 位置差が 60m 超かつ半周未満だと、`rig.snap()` しつつホイールに巨大 `ds/WHEEL_R` が入ります。  
修正案: `setCarCount`/level reset 時に `prevPlayerS=null`、または jump 判定をホイール回転より先に行う。

## 総評
補間本体は `alpha` clamp、停止時 reset、複数 substep の prev/cur 更新とも妥当で、二重進行や巻き戻りは見当たりません。  
`lerpAlong` は「同一 index の車が 1 step で半周未満前進」という前提依存で、現行 20Hz/速度域なら実用上問題は小さいです。
