### [P1] FREE が直接開ける
該当行: `game.js:693-694`  
問題: `titleStart` は `firstLevelToPlay()` 経由だが、`titleFree` は `openBriefing(FREE_LEVEL)` を無条件実行。01 未クリアでも HUD 側イベント経由で FREE に入れる経路が残る。  
修正案: `titleFree` でも `unlockedIds().has(FREE_LEVEL.id)` を確認し、未解放なら lockedTap 相当のトーストへ。

### [P2] レベル03の目標文と判定対象がずれる
該当行: `levels.js:284-303`, `327-330`  
問題: goal は「影響」を `1.5 倍以上` と説明するが、criteria は主に `timeLoss` の比で判定し、代替条件も「遅れ秒」。プレイ中チェックリストで文と ok の意味が食い違う。  
修正案: goal を「混んだ側の遅れを、すいた側の 1.5 倍以上にする」に寄せる。

### [P2] 複数指でブレーキ解除が壊れる
該当行: `hud.js:188-207`  
問題: `pointerId` を保持していないため、1本目で押下中に2本目の `pointerup/cancel/leave` が来ると、1本目を押したままでも `brakeUp` され得る。  
修正案: 押下した `pointerId` だけを release 対象にし、`setPointerCapture/releasePointerCapture` も使う。

### [P2] 10Hzで非表示側もDOM更新
該当行: `game.js:642-644`, `hud.js:346-352`  
問題: 毎回 criteria 評価に加えて simple/detail 両方のリストへ text 更新。3件なので軽いが、不要な DOM 書き換えが常時発生する。  
修正案: 前回 items と差分比較し、表示中モード側だけ更新する。

## 総評
解放の基本、星0旧進捗、星低下時の再ロック抑止、resultNext ガードは概ね妥当です。  
主な残りは FREE 直行ガード、03の文言整合、タッチの pointerId 管理です。
