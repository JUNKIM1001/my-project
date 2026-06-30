-- ============================================================
-- 地域: 関西-A（担当県: 三重県・滋賀県・京都府）
-- データ拡張エージェント w6-kansai-a
-- すべて ja.wikipedia.org の infobox 十進座標で裏取り済み
-- 既存 _have_kansai.txt と重複しない著名社寺のみ
-- ============================================================

-- ===== バッチ1 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sakanoue_tamuramaro','坂上田村麻呂','さかのうえのたむらまろ','kami','御霊','{"田村大明神"}','史実','平安初期の征夷大将軍。武運・厄除の神として祀られる。','https://ja.wikipedia.org/wiki/田村神社_(甲賀市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('minamoto_tsunemoto','源経基','みなもとのつねもと','kami','御霊','{"六孫王大神"}','史実','清和源氏の祖。六孫王として祀られる。','https://ja.wikipedia.org/wiki/六孫王神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sekizan_myojin','赤山大明神','せきざんだいみょうじん','kami','天部','{"泰山府君"}','道教・天台','陰陽道・延暦寺の鎮守神。方除け・商売繁盛の神。','https://ja.wikipedia.org/wiki/赤山禅院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sakanoue_tamuramaro' and g.slug in ('yakubarai','shobu','kaiun'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='minamoto_tsunemoto' and g.slug in ('shusse','kaiun','kanai_anzen'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sekizan_myojin' and g.slug in ('shobai','majo_kekkai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ueno-tenmangu-sugawara','菅原神社（上野天神宮）','すがわらじんじゃ','shrine','菅原神社（旧県社）','三重県','伊賀市','三重県伊賀市上野東町2929',34.766417,136.133194,null,null,null,'伊賀上野の総鎮守。上野天神祭（重要無形民俗文化財）で知られ、松尾芭蕉ゆかりの天満宮。','https://ja.wikipedia.org/wiki/菅原神社_(伊賀市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tamura-jinja-koka','田村神社','たむらじんじゃ','shrine','田村神社（旧県社）','滋賀県','甲賀市','滋賀県甲賀市土山町北土山469',34.9305611,136.2983306,812,null,'https://tamura-jinja.com/','坂上田村麻呂を祀る厄除の名社。土山の厄除大祭で知られる。','https://ja.wikipedia.org/wiki/田村神社_(甲賀市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nagahama-hachimangu','長浜八幡宮','ながはまはちまんぐう','shrine','八幡宮（旧県社・別表神社）','滋賀県','長浜市','滋賀県長浜市宮前町13-55',35.382639,136.274333,1069,null,null,'源義家ゆかりの八幡宮。長浜曳山祭（ユネスコ無形文化遺産）で知られる。','https://ja.wikipedia.org/wiki/長浜八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('rokusonno-jinja','六孫王神社','ろくそんのうじんじゃ','shrine','六孫王神社','京都府','京都市','京都府京都市南区壬生通八条角',34.9846194,135.7449500,963,null,'http://www.rokunomiya.com/','清和源氏の祖・源経基を祀る。源氏発祥の宮として知られる。','https://ja.wikipedia.org/wiki/六孫王神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sekizan-zenin','赤山禅院','せきざんぜんいん','temple','天台宗','京都府','京都市','京都府京都市左京区修学院開根坊町18',35.055861,135.801333,888,'赤山大明神','https://rakuhoku-sekizanzenin.org/','延暦寺の塔頭で皇城表鬼門の鎮守。都七福神の福禄寿、紅葉の名所。','https://ja.wikipedia.org/wiki/赤山禅院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ueno-tenmangu-sugawara' and d.slug in ('michizane'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tamura-jinja-koka' and d.slug in ('sakanoue_tamuramaro'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nagahama-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='rokusonno-jinja' and d.slug in ('minamoto_tsunemoto'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='rokusonno-jinja' and d.slug in ('amaterasu','hachiman'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sekizan-zenin' and d.slug in ('sekizan_myojin'))
on conflict do nothing;

-- ===== バッチ2 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{"摩訶毘盧遮那"}','密教','真言密教の根本仏。宇宙の真理を体現する。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{"武甕槌命"}','記紀','春日大社系の雷と剣の武神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('futsunushi','経津主神','ふつぬしのかみ','kami','天津神','{"斎主神"}','記紀','刀剣を神格化した武神。春日四神の一柱。','https://ja.wikipedia.org/wiki/フツヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenokoyane','天児屋根命','あめのこやねのみこと','kami','天津神','{"天児屋命"}','記紀','藤原氏（中臣氏）の祖神。祝詞の神。','https://ja.wikipedia.org/wiki/アメノコヤネ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('himegami','比売神','ひめがみ','kami','天津神','{"比咩大神"}','記紀','春日大社等に祀られる女神の総称。','https://ja.wikipedia.org/wiki/比売神','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ominakuchi','大水口宿禰命','おおみなくちのすくねのみこと','kami','国津神','{}','記紀','穂積氏の祖神。水口神社の主祭神。','https://ja.wikipedia.org/wiki/水口神社_(甲賀市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='dainichi_nyorai' and g.slug in ('kaiun','majo_kekkai','jouju'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='futsunushi' and g.slug in ('shobu','yakubarai','kotsu_anzen'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenokoyane' and g.slug in ('gakumon','shusse','kaiun'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='himegami' and g.slug in ('enmusubi','renai','kanai_anzen'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ominakuchi' and g.slug in ('suisan_noko','mizu_amagoi','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jojakko-ji','常寂光寺','じょうじゃっこうじ','temple','日蓮宗','京都府','京都市','京都府京都市右京区嵯峨小倉山小倉町3',35.0196389,135.6686750,1596,'十界大曼荼羅','https://jojakko-ji.or.jp/','小倉山の中腹に建つ日蓮宗の名刹。嵯峨野屈指の紅葉の名所。','https://ja.wikipedia.org/wiki/常寂光寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('gio-ji','祇王寺','ぎおうじ','temple','真言宗大覚寺派','京都府','京都市','京都府京都市右京区嵯峨鳥居本小坂町32',35.023389,135.666750,null,'大日如来','https://www.giouji.or.jp/','平家物語ゆかりの尼寺。苔の庭と紅葉で知られる。','https://ja.wikipedia.org/wiki/祇王寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oharano-jinja','大原野神社','おおはらのじんじゃ','shrine','大原野神社（旧官幣中社・二十二社）','京都府','京都市','京都府京都市西京区大原野南春日町1152',34.9603583,135.6561833,784,null,'https://oharano-jinja.jp/','京春日と称される藤原氏の氏神。二十二社の一社。','https://ja.wikipedia.org/wiki/大原野神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saiin-kasuga-jinja','西院春日神社','さいいんかすがじんじゃ','shrine','春日神社（旧郷社）','京都府','京都市','京都府京都市右京区西院春日町61',35.005000,135.729440,833,null,'https://kasuga.or.jp/','淳和天皇の西院（淳和院）の鎮守。疱瘡・病気平癒の信仰で知られる。','https://ja.wikipedia.org/wiki/西院春日神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('minakuchi-jinja','水口神社','みなくちじんじゃ','shrine','水口神社（式内社・旧県社）','滋賀県','甲賀市','滋賀県甲賀市水口町宮の前3-14',34.967500,136.167500,null,null,null,'近江水口の総鎮守。水口曳山祭で知られる式内社。','https://ja.wikipedia.org/wiki/水口神社_(甲賀市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='gio-ji' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oharano-jinja' and d.slug in ('takemikazuchi','futsunushi','amenokoyane','himegami'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saiin-kasuga-jinja' and d.slug in ('takemikazuchi','futsunushi','amenokoyane','himegami'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='minakuchi-jinja' and d.slug in ('ominakuchi'))
on conflict do nothing;

-- ===== バッチ3 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{"無量寿仏","無量光仏"}','浄土教','西方極楽浄土の教主。念仏により極楽往生を導く。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{"薬師瑠璃光如来"}','大乗仏教','東方瑠璃光浄土の教主。病気平癒・現世利益の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{"千手千眼観自在菩薩"}','大乗仏教','千の手で衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amida_nyorai' and g.slug in ('jouju','kaiun','choju'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kanai_anzen'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='senju_kannon' and g.slug in ('byoki_heyu','kaiun','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shorin-in-ohara','勝林院','しょうりんいん','temple','天台宗','京都府','京都市','京都府京都市左京区大原勝林院町187',35.121222,135.834528,835,'阿弥陀如来','https://shorinin187.wixsite.com/home','大原問答の舞台。声明（仏教音楽）の根本道場。','https://ja.wikipedia.org/wiki/勝林院','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hosen-in','宝泉院','ほうせんいん','temple','天台宗','京都府','京都市','京都府京都市左京区大原勝林院町187',35.1213472,135.8340056,null,'阿弥陀如来',null,'勝林院の僧坊。柱を額縁に見立てた額縁庭園と樹齢700年の五葉松で知られる。','https://ja.wikipedia.org/wiki/宝泉院','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('raigo-in-ohara','来迎院','らいごういん','temple','天台宗','京都府','京都市','京都府京都市左京区大原来迎院町537',35.124500,135.838000,null,'薬師如来',null,'融通念仏の祖・良忍ゆかりの寺。魚山大原寺の本堂。','https://ja.wikipedia.org/wiki/来迎院_(京都市左京区)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nonomiya-jinja','野宮神社','ののみやじんじゃ','shrine','野宮神社','京都府','京都市','京都府京都市右京区嵯峨野宮町1',35.017780,135.674170,809,null,'https://www.nonomiya.com/','斎宮が伊勢へ向かう前に潔斎した社。源氏物語の舞台。縁結びで知られる。','https://ja.wikipedia.org/wiki/野宮神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('otagi-nenbutsuji','愛宕念仏寺','おたぎねんぶつじ','temple','天台宗','京都府','京都市','京都府京都市右京区嵯峨鳥居本深谷町2-5',35.0313750,135.6611222,766,'千手観音','https://www.otagiji.com/','愛宕山麓の寺。千二百体の石造羅漢で知られる。','https://ja.wikipedia.org/wiki/愛宕念仏寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shorin-in-ohara' and d.slug in ('amida_nyorai'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hosen-in' and d.slug in ('amida_nyorai'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='raigo-in-ohara' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nonomiya-jinja' and d.slug in ('amaterasu'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='otagi-nenbutsuji' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- ===== バッチ4 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{"建速須佐之男命","牛頭天王"}','記紀','天照大神の弟。厄除け・疫病退散の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yamato_takeru','日本武尊','やまとたけるのみこと','kami','御霊','{"倭建命"}','記紀','景行天皇の皇子。武勇の英雄神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nogi_maresuke','乃木希典','のぎまれすけ','kami','御霊','{}','史実','日露戦争の陸軍大将。学問・勝運・忠節の神として祀られる。','https://ja.wikipedia.org/wiki/乃木希典','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('motoori_norinaga','本居宣長','もとおりのりなが','kami','御霊','{}','史実','江戸期の国学者。学業成就の神として祀られる。','https://ja.wikipedia.org/wiki/本居宣長','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{"地蔵尊"}','大乗仏教','六道で衆生を救う菩薩。子供・旅人の守り仏。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','shobu'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yamato_takeru' and g.slug in ('shobu','shusse','kotsu_anzen'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nogi_maresuke' and g.slug in ('gakugyo','shobu','shusse'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='motoori_norinaga' and g.slug in ('gakugyo','gakumon','shusse'))
on conflict do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='jizo_bosatsu' and g.slug in ('kosodate','anchin','tabi_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fujinomori-jinja','藤森神社','ふじのもりじんじゃ','shrine','藤森神社（旧府社）','京都府','京都市','京都府京都市伏見区深草鳥居崎町609',34.951361,135.771694,203,null,'http://www.fujinomorijinjya.or.jp/','勝運と馬の神社。駈馬神事と紫陽花で知られる。','https://ja.wikipedia.org/wiki/藤森神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nogi-jinja-kyoto','乃木神社','のぎじんじゃ','shrine','乃木神社（旧府社）','京都府','京都市','京都府京都市伏見区桃山町板倉周防32-2',34.932250,135.776472,1916,null,'http://nogi-jinja.jp/','明治天皇陵に近い桃山に鎮座。乃木希典夫妻を祀る。','https://ja.wikipedia.org/wiki/乃木神社_(京都市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('matsusaka-jinja','松阪神社','まつさかじんじゃ','shrine','松阪神社（旧県社）','三重県','松阪市','三重県松阪市殿町1445',34.573722,136.524778,null,null,'http://www.matsusakajinjya.com/','蒲生氏郷が松坂城築城時に城の鎮守とした古社。','https://ja.wikipedia.org/wiki/松阪神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('motoori-norinaga-no-miya','本居宣長ノ宮','もとおりのりながのみや','shrine','本居宣長ノ宮','三重県','松阪市','三重県松阪市殿町1533-2',34.574056,136.524944,1875,null,'https://motoorinorinaga.org/','国学者・本居宣長を学問の神として祀る。','https://ja.wikipedia.org/wiki/本居宣長ノ宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('choju-ji-konan','長寿寺','ちょうじゅじ','temple','天台宗','滋賀県','湖南市','滋賀県湖南市東寺5-1-11',34.9853250,136.0598944,null,'地蔵菩薩','https://chojyuji.jp/','湖南三山の一。国宝の本堂で知られる古刹。','https://ja.wikipedia.org/wiki/長寿寺_(湖南市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fujinomori-jinja' and d.slug in ('susanoo','yamato_takeru'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nogi-jinja-kyoto' and d.slug in ('nogi_maresuke'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='matsusaka-jinja' and d.slug in ('hachiman','ukanomitama'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='motoori-norinaga-no-miya' and d.slug in ('motoori_norinaga'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='choju-ji-konan' and d.slug in ('jizo_bosatsu'))
on conflict do nothing;
