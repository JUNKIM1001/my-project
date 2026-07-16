-- 既存のshrinesテーブルに「御朱印」「テレビ放映」列を追加。
-- 既にSupabaseへ2000_app_schemaを適用済みの環境で、この差分だけ実行する。
alter table shrines add column if not exists goshuin boolean default false;
alter table shrines add column if not exists tv jsonb;
