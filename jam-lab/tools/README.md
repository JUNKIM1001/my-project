# tools — RX-7 (FD3S) モデルの生成パイプライン

`assets/rx7-fd3s.glb` を作った手順を再現するためのスクリプト群。通常の開発では使わない。
元データは、ユーザー提供の FD3S マルチビューイラストを画像→3D 生成サービス
（Hi3D）にかけて得た GLB（66 MB・8K テクスチャ 2 枚・約 199 万三角形）。
その GLB にはイラストの 5 ビューがそれぞれ 1 台ずつ、計 5 台分が 1 メッシュに混在していた。

## 実行順（元 GLB のパスは各スクリプト冒頭で指定）

| # | スクリプト | 役割 |
|---|---|---|
| 1 | `split.mjs` | 連結成分に分解し、5 台 + ホイールの塊を一覧表示（下調べ） |
| 2 | `extract.mjs` | 成分を車ごとにグループ化して `car0..car4.glb` に切り出す |
| 3 | `analyze0.mjs` | 採用した car0（3/4 前方ビュー由来）の成分・ホイール位置を確認 |
| 4 | `align.mjs` | ホイール中心から車体の向き・ホイールベースを割り出し、**前方 = +X / 上 = +Y / 原点 = 車体中心の接地点 / 実寸**へ整列（`rx7-aligned.glb`） |
| 5 | `probe.mjs` | ホイール切り出し半径とテール灯火帯の当たりを確認 |
| 6 | `build.mjs` | ホイール 4 輪を円筒判定で分離し、頂点クラスタリングで軽量化（509k → 130k 三角形）。パーツを `part-*.bin` に出力 |
| 7 | `emissive.mjs` | 尾端の灯火帯にある三角形の UV 領域から赤い画素だけを抜き、テール発光テクスチャの元 BMP を作る |
| 8 | `assemble.mjs` | パーツ + 縮小テクスチャを 1 つの GLB（`rx7.glb`）に組み立てる |

テクスチャの縮小と BMP 変換は macOS の `sips` を使った（外部ライブラリ不要）:

```bash
sips -Z 2048 -s formatOptions 88 basecolor-2048.jpg   # baseColor 8192 → 2048
sips -Z 512  -s formatOptions 80 mr-512.jpg           # metallicRoughness 8192 → 512
sips -s format bmp m2.jpg --out mask2048.bmp          # 画素を Node から読むため BMP 化
sips -s format jpeg -s formatOptions 75 emissive2048.bmp --out emissive-2048.jpg
```

## 成果物

`assets/rx7-fd3s.glb`（5.3 MB）

- ノード: `body` / `wheel_FL` / `wheel_FR` / `wheel_RL` / `wheel_RR`
  （ホイールはノード原点が車軸なので `rotation.z` で転がせる）
- マテリアル 1 種: baseColor 2048、metallicRoughness 512、emissive 2048（テールランプ以外は黒）
- 寸法: 全長 4.48 / 全幅 1.88 / 全高 1.17 m、ホイールベース 2.425 m、タイヤ半径 0.315 m
