### [P1] sim 再作成時に trial が古いまま残る
[jam-lab/src/game.js:210](/Users/thisiskj/Library/Mobile%20Documents/com~apple~CloudDocs/Clode%20code/jam-lab/src/game.js:210), [404](/Users/thisiskj/Library/Mobile%20Documents/com~apple~CloudDocs/Clode%20code/jam-lab/src/game.js:404), [572](/Users/thisiskj/Library/Mobile%20Documents/com~apple~CloudDocs/Clode%20code/jam-lab/src/game.js:572)  
`startLevel()` が `releaseInputs()` せず `buildSim()` するため、密度スライダー再スタート/リトライ時に `trial` が旧 sim の時刻・metrics を保持します。`braking` 中なら新 sim にブレーキが踏みっぱなしで入ります。`observing` 中なら旧試行が新 sim 時刻で完了判定されます。修正案: `recordDensityRun()` 後、`buildSim()` 前に `releaseInputs()`。観察中の再スタートは点を捨てる/確定しない方針を明示。

### [P1] 02/03 の星判定が損失秒基準に移行しきれていない
[jam-lab/src/sim/levels.js:205](/Users/thisiskj/Library/Mobile%20Documents/com~apple~CloudDocs/Clode%20code/jam-lab/src/sim/levels.js:205), [281](/Users/thisiskj/Library/Mobile%20Documents/com~apple~CloudDocs/Clode%20code/jam-lab/src/sim/levels.js:281)  
仕様は「影響台数は頭打ちなので損失秒基準」ですが、`affected || timeLoss` で達成できます。短い側が 0 台だと分母が 1 になり、影響 2 台でも 1.8 倍達成扱いです。03 も台数主導の `bracketed` で通ります。修正案: ★3 は `timeLoss` のみで判定し、表示文も「台」ではなく「損失秒」を主語にする。

### [P2] result 表示が星 0 と達成行を同時に見せる
[jam-lab/src/sim/levels.js:557](/Users/thisiskj/Library/Mobile%20Documents/com~apple~CloudDocs/Clode%20code/jam-lab/src/sim/levels.js:557)  
未完走/ゲート未達で星 0 でも各条件行は `★` 表示され、その後に注記が出ます。採点上は正しいが、ユーザーには「★があるのに評価 0」に見えます。修正案: gate 失敗/未完走時は条件行の記号を `✓/・` に変えるか、先頭に「評価対象外」を出す。

## 総評
中核の固定ブレーキ化は概ね入っていますが、sim 再作成時の trial/input 整合が一番危険です。  
仕様の主軸である「損失秒」への移行は、判定文と一部条件にまだ影響台数の前提が残っています。
