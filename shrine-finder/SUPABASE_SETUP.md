# Supabase 切り替え手順

おまいりナビの Web版（と将来の iOS版）のデータソースを、同梱 `appdata.json` から
Supabase（クラウドDB）に切り替えるための手順です。**認証情報が無い間は自動で
`appdata.json` にフォールバック**するため、切り替え前でもアプリは動きます。

## 1. Supabaseプロジェクトを作成（ユーザー作業）

1. https://supabase.com にサインアップ（無料枠でOK）
2. 「New project」でプロジェクトを作成（リージョンは `Northeast Asia (Tokyo)` 推奨）
3. 作成後、**Project Settings → API** で以下をコピー：
   - `Project URL`（例 `https://abcd1234.supabase.co`）
   - `anon public` キー（公開可・RLSで保護）
   - `service_role` キー（**秘密**・投入スクリプトでのみ使用）

## 2. スキーマ作成

Supabaseダッシュボードの **SQL Editor** で
`supabase/migrations/2000_app_schema.sql` の内容を貼り付けて実行。
（goriyaku / deities / shrines の3テーブル＋公開SELECTのRLSが作られます）

## 3. データ投入（appdata.json → Supabase）

ターミナルで（service_roleキーを使用。履歴に残したくない場合は先頭にスペース）：

```bash
cd "shrine-finder"
SUPABASE_URL="https://<project>.supabase.co" \
SUPABASE_SERVICE_KEY="<service_role_key>" \
node scripts/load_supabase.mjs
```

`✅ 全データ投入完了` が出れば成功（goriyaku/deities/shrines 全件がupsertされます）。

## 4. Web版をSupabaseに接続

```bash
cd "shrine-finder-web"
cp .env.example .env
# .env を編集：
#   VITE_SUPABASE_URL=https://<project>.supabase.co
#   VITE_SUPABASE_ANON_KEY=<anon_public_key>
npm run dev
```

起動後、ブラウザのコンソールに「フォールバック」警告が出なければ Supabase から
読めています。`.env` は `.gitignore` 済み（コミットされません）。

## セキュリティ方針

- **anon キー**のみアプリに埋め込む（公開前提。RLSで SELECT だけ許可、書込不可）。
- **service_role キー**は投入スクリプトのCLIでのみ使用し、リポジトリやアプリに残さない。
- 未設定・取得失敗時は自動で同梱 `appdata.json` に切り替わるため、可用性は維持。
