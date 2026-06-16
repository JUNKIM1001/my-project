# VC Finder 導入手順書

スタートアップが「自社のピッチ＋商談ニーズ」を入力すると、AI（Gemini＋Google検索）が
事業アセットのシナジーを軸に国内VC/CVCの商談先候補をリストアップするローカルWebアプリです。

> このツールは各自のPC上（ローカル）で動きます。データもAPIキーも自分の手元だけに保存され、外部には公開されません。

---

## 0. 必要なもの

| 項目 | 内容 |
|---|---|
| Python | 3.9 以上 |
| Git | リポジトリの取得に使用 |
| Gemini APIキー | Google AI Studio で発行。**課金（請求先）を有効にしておくこと**（無料枠だと検索が動きません） |

Gemini APIキーの取得:
1. https://aistudio.google.com/ にアクセス
2. 「Get API key」→ プロジェクトを作成し、**Billing（課金）を有効化**
3. 発行されたキー（`AIza...`）を控えておく

---

## 1. リポジトリを取得

```bash
git clone <このリポジトリのURL> vc-finder
cd vc-finder
```

> Claude Code を使う場合は、このフォルダを開いて「READMEとSETUP.mdに従ってセットアップして」と頼めば、以降の手順を代行してもらえます。

---

## 2. 仮想環境を作り、依存をインストール

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

---

## 3. APIキーを設定

`vc-finder` 直下に `.env` ファイルを作成し、自分のGeminiキーを書きます。

```bash
echo "GEMINI_API_KEY=ここに自分のキー" > .env
```

`.env` は `.gitignore` 済みなので、Gitには絶対に上がりません（キーが流出しません）。

---

## 4. 起動

```bash
.venv/bin/uvicorn app.main:app --port 8420
```

ブラウザで **http://localhost:8420** を開きます。

---

## 5. 使い方（3ステップ）

1. **STEP0 自社のピッチ資料を読み込む**
   - ファイル（PDF / PPTX）をアップロード、または共有URL（Google Slides / PDF / Webページ）を貼り付け
   - 画像だけのスライドでもAIが画像認識で読み取ります
2. **STEP1 商談ニーズを入力して候補を探す**
   - 「どんな出資・協業を求めているか」「どんなアセットを持つ相手と組みたいか」を記入 →「候補を探す」
   - Web検索を行うため **1回あたり3〜4分**かかります
3. **STEP2 商談先リスト**
   - 適合度スコア順に候補が表示（商談提案ポイント・最近の出資ニュース・代表者/SNS付き）
   - 「この結果を商談先リストとして出力（CSV）」で、面談相手に渡せるCSVをダウンロード

---

## 6. 自分のVCリストを取り込む（任意）

このリポジトリには参照用のVCマスタは含まれていません（AI検索だけでも動きます）。
手元にVC一覧のExcelがあれば、列を合わせて取り込めます。

```bash
.venv/bin/python3 -m app.scraper.import_xlsx "/path/to/あなたのVCリスト.xlsx"
.venv/bin/python3 -m app.scraper.normalize_sectors   # 投資領域の表記ゆれを統一
```

期待する列: `VC名 / VC種別 / 設立年 / 投資ステージ(~シード〜) / 投資分野 / URL` 等
（詳細は `app/scraper/import_xlsx.py` を参照。フォーマットが違う場合は Claude Code に調整を頼んでください）

---

## トラブルシュート

| 症状 | 対処 |
|---|---|
| `GEMINI_API_KEY が設定されていません` | `.env` のキーを確認。起動し直す |
| `429 RESOURCE_EXHAUSTED` / quota 0 | Google AI Studioで課金が有効か確認 |
| `503 UNAVAILABLE` | モデル混雑。自動リトライしますが、時間をおいて再実行 |
| Google Slidesが取得できない | 共有設定を「リンクを知っている全員（閲覧可）」にする |

---

## 補足

- 1回のAI検索は3〜4分かかります（Google検索を多段で行うため）
- データ（`data/vc.db`）・APIキー（`.env`）はローカルのみ。Gitには含まれません
- 代表者のSNS等は、AIが本人と断定できない場合は「未確認」と表示されます（推測でURLは作りません）
