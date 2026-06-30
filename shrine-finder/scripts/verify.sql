-- 動作確認用クエリ集（psql "$SUPABASE_DB_URL" -f scripts/verify.sql）

\echo '── 願い事「縁結び」で参拝できる社寺 ──'
select ts.name, ts.prefecture, ts.city
from temple_shrine ts
join temple_shrine_goriyaku tg on tg.temple_shrine_id = ts.id
join goriyaku g on g.id = tg.goriyaku_id
where g.slug = 'enmusubi'
order by ts.prefecture;

\echo '── 願い事「厄除け」で参拝できる社寺 ──'
select ts.name, ts.prefecture
from temple_shrine ts
join temple_shrine_goriyaku tg on tg.temple_shrine_id = ts.id
join goriyaku g on g.id = tg.goriyaku_id
where g.slug = 'yakubarai'
order by ts.prefecture;

\echo '── 近隣検索: 東京駅(35.681,139.767)から半径15km・神社のみ ──'
select name, prefecture, round(distance_m)::int as m
from nearby_temple_shrines(35.681236, 139.767125, 15, 'shrine', null, 20);

\echo '── 出典が未設定/未検証のレコード（あってはならない） ──'
select count(*) as 未検証社寺 from temple_shrine where verified is not true or source_url is null;
