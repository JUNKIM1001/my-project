# Lead Finder — 事業会社向け 営業リード管理ツール

自社の商材情報をもとに、AI（Gemini + Google検索）が**導入ニーズのありそうな事業会社**を探索し、
有効リードをGoogleスプレッドシートの営業台帳で管理するローカルWebアプリ。
（vc-finder と同じ構成を営業活動向けに転用したもの）

## 主な機能

- **営業資料の読み込み (Step0)**: 自社の営業資料・サービス資料（PDF/PPTX/URL）をアップロードすると、
  AIが商材内容・解決できる課題・想定顧客等を抽出し「自社商材情報」として保存
- **ターゲット条件入力 (Step1)**: 売りたい業界・規模・地域・除外条件を入力。Step0の商材情報と組み合わせてAIが探索
- **AI候補探索**: プレスリリース・中期経営計画・新店舗ニュースなどの公開情報から
  **ニーズの兆候**を見つけ、根拠付きで実在の事業会社をリストアップ
- **有望度スコア**: 各候補を0〜100で採点（ニーズ適合50点＋導入体力30点＋接点の作りやすさ20点）
- **営業提案ポイント**: 商談の場で提案できるトークをAIが生成、想定キーパーソン部署も提示
- **リード化ワークフロー**: 候補を選別し、承認した先だけを「有効リード」として管理
- **手動リード登録**: 展示会・紹介などで得たリードも登録可能
- **Googleスプレッドシート連携**: 有効リードを営業台帳シートへ同期（push）。
  商談ステージ・担当者・次アクション・メモはシート側で編集し、アプリへ取り込み（pull）。
  詳細: [docs/sheets-lead-management.md](docs/sheets-lead-management.md)
- **CSVエクスポート** / **検索履歴の再利用**

## セットアップ

```bash
cd lead-finder
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
# .env に GEMINI_API_KEY=... を設定（シート連携する場合は Google 関連も。.env.example 参照）
.venv/bin/uvicorn app.main:app --port 8430
# → http://localhost:8430
```

## 構成

| パス | 役割 |
|---|---|
| `app/main.py` | FastAPI（候補検索/CSV/AI検索/リード化/シート同期 API） |
| `app/models.py` | DBスキーマ（companies, search_history, company_profile） |
| `app/scraper/ai_search.py` | Gemini + Google検索による営業先候補の探索 |
| `app/scraper/pitch_reader.py` | 営業資料(PDF/PPTX/URL)のテキスト抽出・自社商材情報の要約 |
| `app/scraper/dedupe.py` | 法人名の正規化・名寄せ |
| `app/sheets/client.py` | Googleスプレッドシート接続（サービスアカウント認証） |
| `app/sheets/sync.py` | 有効リードの双方向同期（push/pull/setup、CLIあり） |
| `app/static/index.html` | 画面UI |
| `data/leads.db` | SQLite（gitignore対象） |

## 注意

- AI検索は1回あたり3〜4分かかる（Google検索を多段で行うため）
- AIが提示するニーズ・キーパーソン情報は公開情報に基づく仮説。営業前に必ず一次情報を確認すること
