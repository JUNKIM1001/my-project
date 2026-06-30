-- 御朱印ナビ（仮）— スキーマ定義
-- Supabase / PostgreSQL。神仏 ↔ ご利益 ↔ 社寺 の多対多。
-- すべてのレコードは実在・訪問可能・出典付きで裏取りしたものだけを格納する方針。

create extension if not exists postgis;

-- ───────────────────────── マスタ ─────────────────────────

-- ご利益カテゴリ
create table if not exists goriyaku (
  id          bigint generated always as identity primary key,
  slug        text not null unique,
  name        text not null,
  name_kana   text,
  icon        text,                 -- SF Symbols 名
  description text,
  sort_order  int  not null default 0,
  created_at  timestamptz not null default now()
);

-- 神様(kami) / 仏様(buddha) 統合
create table if not exists deity (
  id               bigint generated always as identity primary key,
  slug             text not null unique,
  name             text not null,
  name_kana        text,
  kind             text not null check (kind in ('kami','buddha')),
  category         text,            -- 天津神/国津神/如来/菩薩/明王/天部 …
  aliases          text[] default '{}',
  mythology_source text,            -- 記/紀/その他 出典系統
  description      text,
  image_url        text,
  -- 出典・検証
  source_url       text,            -- 一次/信頼ソースURL（Wikipedia/公式等）
  source_name      text,
  verified         boolean not null default false,
  verified_at      timestamptz,
  created_at       timestamptz not null default now()
);

-- 社寺
create table if not exists temple_shrine (
  id            bigint generated always as identity primary key,
  slug          text not null unique,
  name          text not null,
  name_kana     text,
  type          text not null check (type in ('shrine','temple')),
  sect          text,              -- 宗派/系統（稲荷系/八幡系/天台宗 …）
  prefecture    text,
  city          text,
  address       text,
  lat           double precision,
  lng           double precision,
  -- 緯度経度から自動生成する地理列（近隣検索用・空間インデックス対象）
  geo           geography(Point, 4326)
                  generated always as (
                    case when lat is not null and lng is not null
                      then st_setsrid(st_makepoint(lng, lat), 4326)::geography
                    end
                  ) stored,
  founded_year  int,
  honzon_note   text,              -- 本尊メモ（寺）
  website       text,              -- 公式サイト
  phone         text,
  description   text,
  image_url     text,
  -- 出典・検証
  source_url    text,
  source_name   text,
  verified      boolean not null default false,
  verified_at   timestamptz,
  created_at    timestamptz not null default now()
);

create index if not exists temple_shrine_geo_idx on temple_shrine using gist (geo);
create index if not exists temple_shrine_type_idx on temple_shrine (type);
create index if not exists temple_shrine_pref_idx on temple_shrine (prefecture);

-- ───────────────────────── 関連（多対多） ─────────────────────────

-- 神仏が司るご利益
create table if not exists deity_goriyaku (
  deity_id    bigint not null references deity(id) on delete cascade,
  goriyaku_id bigint not null references goriyaku(id) on delete cascade,
  primary key (deity_id, goriyaku_id)
);

-- 社寺の御祭神/本尊
create table if not exists temple_shrine_deity (
  temple_shrine_id bigint not null references temple_shrine(id) on delete cascade,
  deity_id         bigint not null references deity(id) on delete cascade,
  role             text not null default 'main' check (role in ('main','sub')),
  primary key (temple_shrine_id, deity_id)
);

-- 社寺のご利益（神仏経由で導出＋個別上書き）
create table if not exists temple_shrine_goriyaku (
  temple_shrine_id bigint not null references temple_shrine(id) on delete cascade,
  goriyaku_id      bigint not null references goriyaku(id) on delete cascade,
  primary key (temple_shrine_id, goriyaku_id)
);

-- お気に入り（匿名Authユーザー単位）
create table if not exists favorite (
  user_id          uuid   not null references auth.users(id) on delete cascade,
  temple_shrine_id bigint not null references temple_shrine(id) on delete cascade,
  created_at       timestamptz not null default now(),
  primary key (user_id, temple_shrine_id)
);

-- ───────────────────────── 近隣検索 RPC ─────────────────────────
-- 指定座標から radius_km 圏内の社寺を距離(m)付きで近い順に返す。
-- p_type / p_goriyaku_slug は任意の絞り込み（NULLで無効）。
create or replace function nearby_temple_shrines(
  p_lat double precision,
  p_lng double precision,
  p_radius_km double precision default 10,
  p_type text default null,
  p_goriyaku_slug text default null,
  p_limit int default 50
)
returns table (
  id bigint, slug text, name text, type text, sect text,
  prefecture text, city text, address text,
  lat double precision, lng double precision,
  distance_m double precision, website text, image_url text
)
language sql stable
as $$
  with origin as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g
  )
  select ts.id, ts.slug, ts.name, ts.type, ts.sect,
         ts.prefecture, ts.city, ts.address, ts.lat, ts.lng,
         st_distance(ts.geo, o.g) as distance_m,
         ts.website, ts.image_url
  from temple_shrine ts, origin o
  where ts.geo is not null
    and st_dwithin(ts.geo, o.g, p_radius_km * 1000)
    and (p_type is null or ts.type = p_type)
    and (p_goriyaku_slug is null or exists (
      select 1 from temple_shrine_goriyaku tg
      join goriyaku g on g.id = tg.goriyaku_id
      where tg.temple_shrine_id = ts.id and g.slug = p_goriyaku_slug))
  order by distance_m asc
  limit p_limit;
$$;

-- ───────────────────────── RLS ─────────────────────────
-- マスタ系は誰でも read。書き込みは service_role のみ（シード投入）。
alter table goriyaku               enable row level security;
alter table deity                  enable row level security;
alter table temple_shrine          enable row level security;
alter table deity_goriyaku         enable row level security;
alter table temple_shrine_deity    enable row level security;
alter table temple_shrine_goriyaku enable row level security;
alter table favorite               enable row level security;

do $$
declare t text;
begin
  foreach t in array array['goriyaku','deity','temple_shrine','deity_goriyaku','temple_shrine_deity','temple_shrine_goriyaku']
  loop
    execute format('drop policy if exists %I_read on %I;', t, t);
    execute format('create policy %I_read on %I for select using (true);', t, t);
  end loop;
end $$;

-- favorite は本人のみ
drop policy if exists favorite_select on favorite;
drop policy if exists favorite_insert on favorite;
drop policy if exists favorite_delete on favorite;
create policy favorite_select on favorite for select using (auth.uid() = user_id);
create policy favorite_insert on favorite for insert with check (auth.uid() = user_id);
create policy favorite_delete on favorite for delete using (auth.uid() = user_id);
