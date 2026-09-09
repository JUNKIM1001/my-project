### [P1] body accessor offset 破損
`fit-wheels.mjs:74-76`  
bufferView 全体をコピーしつつ accessor.byteOffset を 0 に潰しています。元 body の POSITION/NORMAL/indices に byteOffset がある、または同一 bufferView 共有・byteStride がある場合、別データ先頭を読んで GLB が壊れます。  
修正案: accessor の実バイト範囲だけを切り出すか、コピー後も accessor.byteOffset / bufferView.byteStride を保存する。

### [P1] 観察視点からの復帰漏れ
`game.js:133-135, 269-275, 330, 562`  
releaseInputs が observeReturnCam を消すだけでカメラを戻しません。観察中に一時停止、やり直し、レベル終了へ入ると `g.cameraMode === 'observe'` のまま残り得ます。  
修正案: releaseInputs 内で `observeReturnCam` があれば先に `setCamera(observeReturnCam)`、なければ遷移側で明示的に通常視点へ戻す。

### [P2] 画像 accessor 継承が bufferView 前提
`fit-wheels.mjs:94-96`  
images は `mimeType` と `bufferView` だけ再構築しており、URI 画像、name/extras/extensions を落とします。現 GLB が全画像埋め込みなら動きますが、汎用ツールとしては取りこぼします。  
修正案: `bufferView` がある画像だけ差し替え、その他プロパティは spread で保持する。

### [P2] yaw 回帰が外れ値に弱い
`yaw-body.mjs:18-31`  
y 0.3〜0.9 の帯はウィング回避として妥当ですが、各 x スライスの zmin/zmax 極値なのでミラーや局所突起で中心線が寄ります。  
修正案: 左右端を percentile で取る、ミラー範囲を除外する、点数重み付き回帰にする。

### [P2] 後輪の奥まりが目立つ可能性
`fit-wheels.mjs:31-32,81-92`  
後輪中心 ±0.637 は実測フェンダー基準として整合しますが、前後トラック差が視覚的に大きく、リアが細く見えます。  
修正案: 見た目優先モードで後輪を数 cm 外へ出す、またはリアフェンダー側を補正する。

## 総評
z 反転、巻き順反転、法線の逆転置、`rotation.z` の軸整合は問題なさそうです。  
最大リスクは GLB 再構築時の accessor offset と、観察視点の状態遷移漏れです。
