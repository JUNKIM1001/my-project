# Startup Finder — 国内スタートアップDB（CVC向けソーシング支援）

CVC担当者が自分の投資テーマに合った国内スタートアップを探したり、
自社アセットとのシナジーを意識して検索できるローカルWebアプリ。
スピーダ（INITIAL）ライクな検索体験を、公開情報ベースの自前DBで提供する。

## データポリシー（事実準拠）

- 収録データはすべて**公開情報**（報道記事・PR TIMES・公式サイト・信用調査会社の公表情報）に基づく
- 全社に**出典URL**を付与。検索で確認できなかった項目は null（空欄）のまま
- **評価額（バリュエーション）は公表・報道ベースの値のみ**。出典を `valuation_source` に保持
- 倒産・解散・M&A・IPO を `status` で区別し、存続していない企業が商談先に混ざらないようにする
  （シナジー検索はデフォルトで倒産・解散企業を除外）

## 収録対象

日本国内のスタートアップのうち、以下のいずれかを満たす企業を中心に収録:
- VC・CVC・事業会社からの資金調達実績がある
- 主要ピッチイベント（IVS LaunchPad / ICCカタパルト / B Dash Camp / TechCrunch Tokyo / SusHi Tech 等）で受賞歴がある

収集テーマ: 生成AI / SaaS・業務DX / フィンテック / ヘルスケア・バイオ / ディープテック（宇宙・核融合・素材）/
ロボティクス・モビリティ / 気候テック / フード・アグリ・消費者向け / ピッチ受賞企業 / ユニコーン級 / 倒産・解散企業

## 主な機能

- **検索**: キーワード（社名・事業内容・株主・所在地）× 分野 × ステージ × ステータス × 調達額レンジ。
  評価額・累計調達額でソート
- **シナジー検索**: 自社のアセット・注力テーマをキーワードで入力すると、
  分野一致(3点)・事業内容一致(2点)・提携先/株主一致(1点)で採点したシナジー候補リストを表示
- **企業詳細**: 累計調達額 / 評価額（出典付き）/ 直近ラウンドと引受先 / 主要株主・投資家 /
  提携事業会社 / 受賞歴 / 従業員数 / 存続ステータス / 出典URL
- **CSVエクスポート**: 全項目をCSV出力（Excelで開ける BOM 付きUTF-8）

## セットアップ

```bash
cd startup-finder
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# リサーチ結果(data/raw/*.json)をDBに取り込み
.venv/bin/python3 -m app.scripts.import_json

# ユーザー作成（初回。--password 省略で対話入力）
.venv/bin/python3 -m app.scripts.create_user <username> --name <表示名>

# 起動
.venv/bin/uvicorn app.main:app --port 8430
# → http://localhost:8430 （ログイン画面が表示される）
```

## ログイン・ユーザー管理

- 全ページ・全APIはログイン必須（セッションクッキー、有効期間30日）
- パスワードは PBKDF2-SHA256 でハッシュ化して保存
- ユーザー追加・パスワード変更はどちらも `create_user` スクリプトで:
  `.venv/bin/python3 -m app.scripts.create_user tanaka --name 田中`（既存ユーザー名なら更新）
- ログイン中のユーザー名が面談記録の「担当者」欄に自動でプリセットされる

## 構成

| パス | 役割 |
|---|---|
| `app/main.py` | FastAPI（認証 / 検索 / シナジー / 詳細 / 面談記録 / meta / CSV API） |
| `app/models.py` | DBスキーマ（companies, users, auth_sessions） |
| `app/auth.py` | パスワードハッシュ・セッション管理 |
| `app/scripts/import_json.py` | data/raw/*.json の取り込み・名寄せマージ |
| `app/scripts/create_user.py` | ユーザー作成・パスワード変更 |
| `app/static/index.html` | 検索UI（検索タブ + シナジー検索タブ + 面談記録） |
| `app/static/login.html` | ログイン画面 |
| `data/raw/*.json` | テーマ別リサーチ結果（出典付き・再取り込み可能） |
| `data/startup.db` | SQLite |

## データ更新

`data/raw/` に同スキーマのJSONを追加して `import_json` を再実行すると、
同名企業は名寄せマージ（空欄のみ補完、出典・分野は結合）、新規企業は追加される。

## 注意

- 評価額・調達額は報道時点の値であり、最新の実態と異なる場合がある。投資判断は必ず一次情報で確認すること
- 本データは社内のソーシング目的にのみ利用すること
