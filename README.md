# Clode code — 個人プロジェクト・モノレポ

複数の独立したアプリを1リポジトリで管理している。プロジェクト間にコード依存はない
（例外: shrine-finder系はデータを共有。下記参照）。

## プロジェクト一覧

| ディレクトリ | 内容 | スタック | 状態 |
|---|---|---|---|
| `startup-finder/` | CVC向け国内スタートアップDB（1,846社・出典付き） | FastAPI + SQLAlchemy。本番=Vercel(hnd1)+Supabase Postgres、ローカル=SQLite | **本番公開中** https://startup-finder-iota.vercel.app |
| `vc-finder/` | スタートアップがVCを探す逆方向ツール | FastAPI + SQLite + Gemini | ローカル運用 |
| `shrine-finder/` | おまいりナビ iOSアプリ（神社仏閣2,086件） | SwiftUI | App Store申請準備 |
| `shrine-finder-web/` | おまいりナビ Web版 | React + Vite + Leaflet + Supabase | Vercel公開中 |
| `shrine-finder-api/` | おまいりナビ API | Node.js | shrine-finder(iOS)のデータからビルド |
| `ridge-runner/` | チャリ縦走（山脈縦断ランナーゲーム） | Canvas試作 | プロトタイプ |
| `location-rpg/` `location-rpg-app/` | 位置情報RPG試作 | — | プロトタイプ |
| `omoide-puzzle/` | 思い出パズル試作 | — | プロトタイプ |
| `jam-lab/` | 渋滞のしくみを RX-7 (FD3S) で走って学ぶ 3D 学習ゲーム（IDM 車列シム・5 レベル + フリーラボ） | 静的サイト + three.js 同梱（ビルド無し） | ローカル（port 8480） |
| `reviews/` | Codexレビュー結果の保存先 | — | — |

## 各プロジェクトの起動

それぞれのディレクトリの README を参照。Python系は各ディレクトリの `.venv` を使う
（例: `cd startup-finder && .venv/bin/uvicorn app.main:app --port 8430`）。

## 環境変数

各プロジェクト直下の `.env.example` を参照（実際の値は `.env` に置く。`.env` はコミットしない）。

## 開発の進め方

開発依頼は [LOOP_ENGINEERING.md](LOOP_ENGINEERING.md)（ループエンジニアリング規約）に従って進める。
実装 → Codex独立レビュー → 修正 → 再検証のループを回し、P0/P1ゼロで収束（最大3周）。

## 注意

- shrine-finder系3プロジェクトはデータソースを共有する（iOS版のデータが原本）
- 本番公開中のプロジェクト（startup-finder / shrine-finder-web）に触れる際は、
  デプロイ前にテストを実行すること
