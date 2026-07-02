# VC Finder — スタートアップ向け VC/CVC リストアップツール

スタートアップが自社の事業条件を入力すると、AI（Gemini + Google検索）が
**事業アセットのシナジー**を軸に国内のVC/CVC候補を探索し、商談先リストとして出力するローカルWebアプリ。

## 主な機能

- **ピッチ資料の読み込み (Step0)**: 自社のピッチ資料（PDF/PPTX）をアップロードすると、
  AIが会社名・事業内容・保有アセット・調達ステージ等を抽出し「自社事業情報」として保存
- **商談ニーズ入力 (Step1)**: 求める出資・協業の内容を入力。Step0の自社事業情報と組み合わせてAIが探索
- **AI候補探索**: 親会社の事業アセット（設備・拠点・チャネル・顧客基盤など）との
  シナジーを重視して実在のVC/CVCを探索。出資機能が現在も稼働しているかも根拠付きで確認
- **適合度スコア**: 各候補を0〜100で採点（アセットシナジー50点＋ステージ/領域一致30点＋出資活発度20点）
- **商談提案ポイント**: 商談の場で提案できるシナジー仮説をAIが生成
- **検証用マスタとの突合**: 手持ちのVCリスト（Excel 2,740件）をDB化し、AI候補と名寄せ・重複統合
- **承認/却下ワークフロー**: AI候補を選別し、承認済みだけを商談リストとして絞り込み
- **有効リード管理 (Googleスプレッドシート連携)**: 「リード化」した候補を管理台帳シートへ同期。
  対応ステータス・担当者・次アクション・メモはシート側で編集し、アプリへ取り込み（双方向同期）。
  詳細: [docs/sheets-lead-management.md](docs/sheets-lead-management.md)
- **CSVエクスポート**: テンプレート形式（＃/企業名/設立年/主な投資ステージ/Webサイト/最近の出資・協業ニュース/リレーション有無/適合度/商談提案ポイント/問い合わせ先）
- **検索履歴**: 過去のAI検索条件と結果を保存・再利用

## セットアップ

```bash
cd vc-finder
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
# .env に GEMINI_API_KEY=... を設定
.venv/bin/uvicorn app.main:app --port 8420
# → http://localhost:8420
```

## データ投入

```bash
# 手持ちのVCリスト（Excel）を取り込み
.venv/bin/python3 -m app.scraper.import_xlsx "/path/to/VCリスト.xlsx"
# 投資領域の表記ゆれを正規化
.venv/bin/python3 -m app.scraper.normalize_sectors
```

## 構成

| パス | 役割 |
|---|---|
| `app/main.py` | FastAPI（検索/CSV/AI検索/承認/履歴 API） |
| `app/models.py` | DBスキーマ（vcs, search_history） |
| `app/scraper/ai_search.py` | Gemini + Google検索による候補探索 |
| `app/scraper/pitch_reader.py` | ピッチ資料(PDF/PPTX)のテキスト抽出・自社事業情報の要約 |
| `app/scraper/import_xlsx.py` | ExcelのVCリスト取り込み |
| `app/scraper/dedupe.py` | 法人名の正規化・名寄せ |
| `app/scraper/normalize_sectors.py` | 投資領域の表記ゆれ統一 |
| `app/scraper/crawler.py` | 個別サイト/一覧ページのクロール（補助） |
| `app/sheets/client.py` | Googleスプレッドシート接続（サービスアカウント認証） |
| `app/sheets/sync.py` | 有効リードの双方向同期（push/pull/setup、CLIあり） |
| `app/static/index.html` | 検索UI |
| `data/vc.db` | SQLite（gitignore対象） |

## 注意

- AI検索は1回あたり3〜4分かかる（Google検索を多段で行うため）
- 元リストのディスクレーマに従い、本データは自社の投資家探し目的にのみ利用すること
