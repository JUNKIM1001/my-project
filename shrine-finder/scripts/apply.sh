#!/usr/bin/env bash
# Supabase へスキーマ＋シード＋地域データを順に投入する。
# 使い方: scripts/.env に SUPABASE_DB_URL を設定してから  bash scripts/apply.sh
set -euo pipefail
cd "$(dirname "$0")/.."

[ -f scripts/.env ] && set -a && . scripts/.env && set +a
: "${SUPABASE_DB_URL:?scripts/.env に SUPABASE_DB_URL を設定してください}"

PSQL=(psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1)

echo "▶ スキーマ・基本シードを適用"
for f in supabase/migrations/0001_schema.sql \
         supabase/migrations/0002_goriyaku_seed.sql \
         supabase/migrations/0003_deity_seed_pilot.sql \
         supabase/migrations/0004_temple_shrine_seed_pilot.sql; do
  echo "  - $f"; "${PSQL[@]}" -f "$f"
done

echo "▶ 地域データを適用（data/regions/*.sql）"
shopt -s nullglob
for f in data/regions/*.sql; do
  echo "  - $f"; "${PSQL[@]}" -f "$f"
done

echo "▶ ご利益を一括導出"
"${PSQL[@]}" -f supabase/migrations/0099_derive_goriyaku.sql

echo "▶ 件数サマリ"
"${PSQL[@]}" -c "select
  (select count(*) from temple_shrine) as 社寺,
  (select count(*) from deity) as 神仏,
  (select count(*) from goriyaku) as ご利益,
  (select count(*) from temple_shrine_deity) as 御祭神紐付,
  (select count(*) from temple_shrine_goriyaku) as 社寺ご利益;"
echo "✅ 完了"
