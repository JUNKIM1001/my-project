-- おまいりナビ アプリ用スキーマ（appdata.json と同一構造）。Web/iOSが直接読み取る。
-- 公開データのため RLS は「誰でも SELECT 可・書込は service_role のみ」。

create table if not exists goriyaku (
  slug        text primary key,
  name        text not null,
  icon        text,
  sort_order  int default 0
);

create table if not exists deities (
  slug        text primary key,
  name        text,
  kana        text,
  kind        text,          -- 'kami' | 'buddha'
  category    text,
  description text,
  goriyaku    text[] default '{}'
);

create table if not exists shrines (
  slug            text primary key,
  name            text,
  kana            text,
  type            text,       -- 'shrine' | 'temple'
  sect            text,
  pref            text,
  city            text,
  address         text,
  lat             double precision,
  lng             double precision,
  deities         text[] default '{}',
  website         text,
  description     text,
  source          text,
  nt              boolean default false,
  image_url       text,
  image_license   text,
  image_author    text,
  long_description text,
  goshuin         boolean default false,  -- 御朱印の授与あり
  tv              jsonb                    -- 直近のテレビ放映 {date, program, source}
);
create index if not exists shrines_pref_idx on shrines(pref);
create index if not exists shrines_type_idx on shrines(type);
create index if not exists shrines_nt_idx   on shrines(nt);

-- RLS：公開読み取り
alter table goriyaku enable row level security;
alter table deities  enable row level security;
alter table shrines  enable row level security;

drop policy if exists pub_read_goriyaku on goriyaku;
drop policy if exists pub_read_deities  on deities;
drop policy if exists pub_read_shrines  on shrines;
create policy pub_read_goriyaku on goriyaku for select using (true);
create policy pub_read_deities  on deities  for select using (true);
create policy pub_read_shrines  on shrines  for select using (true);
