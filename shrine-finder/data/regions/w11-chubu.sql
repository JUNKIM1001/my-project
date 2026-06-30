-- =====================================================================
-- 中部地方 社寺データ (w11-chubu)
-- 出典: ja.wikipedia.org の infobox 十進座標で裏取り（座標無しは除外）
-- 対象県: 愛知・岐阜・静岡・長野・山梨・新潟・富山・石川・福井
-- 既存 _have_chubu.txt 収録分・既出 slug とは重複させない
-- =====================================================================

-- =========================== バッチ1 ===========================
-- ① 新規神仏（既存に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','仏教','無限の知恵と福徳を蔵する菩薩。記憶力・智慧の仏。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{千手千眼観音}','仏教','千の手で衆生を救う変化観音。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kokuzo_bosatsu' and g.slug in ('gakugyo','gakumon','kaiun'))
or (d.slug='senju_kannon' and g.slug in ('byoki_heyu','yakubarai','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('myojorin-ji-ogaki','明星輪寺','みょうじょうりんじ','temple','真言宗','岐阜県','大垣市','岐阜県大垣市赤坂4610',35.4005722,136.5785611,686,'虚空蔵菩薩','http://www.mirai.ne.jp/~kinsyou3/','赤坂虚空蔵の名で親しまれる岩屋本尊の古刹。','https://ja.wikipedia.org/wiki/明星輪寺','Wikipedia',true,now()),
('enkyo-ji-kitagata','円鏡寺','えんきょうじ','temple','高野山真言宗','岐阜県','本巣郡北方町','岐阜県本巣郡北方町北方1345',35.4361028,136.6867083,811,'聖観音','https://ja.wikipedia.org/wiki/円鏡寺','「美濃の正倉院」と称される文化財の宝庫。楼門は重文。','https://ja.wikipedia.org/wiki/円鏡寺','Wikipedia',true,now()),
('zuinen-ji-okazaki','隨念寺','ずいねんじ','temple','浄土宗','愛知県','岡崎市','愛知県岡崎市門前町91',34.9594111,137.1727917,1562,'阿弥陀如来','https://ja.wikipedia.org/wiki/随念寺','徳川家康が祖父清康を弔うため創建した松平家ゆかりの寺。','https://ja.wikipedia.org/wiki/随念寺','Wikipedia',true,now()),
('tokugan-ji-shizuoka','徳願寺','とくがんじ','temple','曹洞宗','静岡県','静岡市','静岡県静岡市駿河区向敷地689',34.958944,138.351694,1476,'千手観音','https://ja.wikipedia.org/wiki/徳願寺_(静岡市)','駿河三十三観音第12番。今川・徳川ゆかりの古刹。','https://ja.wikipedia.org/wiki/徳願寺_(静岡市)','Wikipedia',true,now()),
('dairin-ji-okazaki','大林寺','だいりんじ','temple','浄土宗西山深草派','愛知県','岡崎市','愛知県岡崎市魚町1-6',34.96064389,137.15969694,1493,'阿弥陀如来','https://ja.wikipedia.org/wiki/大林寺_(岡崎市)','松平光重が創建した松平・徳川家ゆかりの寺。','https://ja.wikipedia.org/wiki/大林寺_(岡崎市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='myojorin-ji-ogaki' and d.slug in ('kokuzo_bosatsu'))
or (t.slug='enkyo-ji-kitagata' and d.slug in ('sho_kannon'))
or (t.slug='zuinen-ji-okazaki' and d.slug in ('amida_nyorai'))
or (t.slug='tokugan-ji-shizuoka' and d.slug in ('senju_kannon'))
or (t.slug='dairin-ji-okazaki' and d.slug in ('amida_nyorai'))
on conflict do nothing;
