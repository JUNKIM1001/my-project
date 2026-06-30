-- ============================================================
-- w9-chugoku-shikoku.sql
-- 担当: 中国・四国 9県 (鳥取/島根/岡山/広島/山口/徳島/香川/愛媛/高知)
-- ja.wikipedia.org の infobox 十進座標で裏取り。座標なしは除外。
-- _have_chugoku-shikoku.txt と重複しないものを収録。
-- ============================================================

-- ① 新規神仏 ------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kakinomoto_hitomaro','柿本人麻呂','かきのもとのひとまろ','kami','御霊','{}','記紀','飛鳥時代の歌人。歌聖として学問・和歌の神に祀られる。','https://ja.wikipedia.org/wiki/高津柿本神社','Wikipedia',true,now()),
('ogetsuhime','大宜都比売','おおげつひめ','kami','国津神','{}','記紀','食物・五穀をつかさどる女神。阿波国の総鎮守。','https://ja.wikipedia.org/wiki/上一宮大粟神社','Wikipedia',true,now()),
('tsukuyomi','月読尊','つくよみのみこと','kami','天津神','{}','記紀','月をつかさどる神。夜の食国を統治する。','https://ja.wikipedia.org/wiki/西照神社','Wikipedia',true,now()),
('oyamatsumi','大山祇神','おおやまつみのかみ','kami','国津神','{}','記紀','山をつかさどる神。山林・鉱山・酒造の守護神。','https://ja.wikipedia.org/wiki/神峯神社','Wikipedia',true,now()),
('sutoku_tenno','崇徳天皇','すとくてんのう','kami','御霊','{}','史実','第75代天皇。保元の乱で讃岐に配流。日本三大怨霊の一柱として祀られる。','https://ja.wikipedia.org/wiki/白峰宮','Wikipedia',true,now()),
('ninigi','邇邇芸命','ににぎのみこと','kami','天津神','{}','記紀','天照大神の孫。天孫降臨の主神。','https://ja.wikipedia.org/wiki/高屋神社_(観音寺市)','Wikipedia',true,now()),
('susanoo','須佐之男命','すさのおのみこと','kami','天津神','{}','記紀','嵐・厄除けの神。八岐大蛇退治で知られる。','https://ja.wikipedia.org/wiki/野間神社_(今治市)','Wikipedia',true,now()),
('hikosashima','彦狭島命','ひこさしまのみこと','kami','国津神','{}','記紀','伊予国を治めたと伝わる皇族神。伊予神社の祭神。','https://ja.wikipedia.org/wiki/伊予神社','Wikipedia',true,now()),
('godaigo_tenno','後醍醐天皇','ごだいごてんのう','kami','御霊','{}','史実','第96代天皇。建武の新政を行った。','https://ja.wikipedia.org/wiki/作楽神社','Wikipedia',true,now()),
('toyotamahime','豊玉姫命','とよたまひめのみこと','kami','国津神','{}','記紀','海神の娘。安産・縁結びの女神。','https://ja.wikipedia.org/wiki/天別豊姫神社','Wikipedia',true,now()),
('okunitama','大国魂命','おおくにたまのみこと','kami','国津神','{}','記紀','国土の御霊。国造りと開拓の神。','https://ja.wikipedia.org/wiki/倭大国魂神社','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','大国主の子。託宣・恵比寿信仰の神。','https://ja.wikipedia.org/wiki/天別豊姫神社','Wikipedia',true,now()),
('kunitokotachi','国之常立神','くにのとこたちのかみ','kami','天津神','{}','記紀','天地開闢に現れた根源神。','https://ja.wikipedia.org/wiki/若桜神社','Wikipedia',true,now()),
('komatanokami','木俣神','このまたのかみ','kami','国津神','{}','記紀','大国主の子。井戸・水・安産の神(御井神)。','https://ja.wikipedia.org/wiki/御井神社_(出雲市)','Wikipedia',true,now()),
('kushinadahime','奇稲田姫命','くしなだひめのみこと','kami','国津神','{}','記紀','八岐大蛇神話のヒロイン。素盞嗚命の妃。','https://ja.wikipedia.org/wiki/稲田神社_(奥出雲町)','Wikipedia',true,now()),
('konohanasakuyahime','木花咲耶姫命','このはなさくやひめのみこと','kami','天津神','{}','記紀','富士・桜の女神。安産・縁結びの神。','https://ja.wikipedia.org/wiki/朝峯神社','Wikipedia',true,now()),
('otataneko','大田田根子','おおたたねこ','kami','国津神','{}','記紀','大物主神を祀った神主の祖。','https://ja.wikipedia.org/wiki/大川上美良布神社','Wikipedia',true,now()),
('umukahihime','宇武加比比売命','うむかひひめのみこと','kami','国津神','{}','記紀','出雲国風土記に登場する女神。法吉鳥に化したと伝わる。','https://ja.wikipedia.org/wiki/法吉神社','Wikipedia',true,now()),
('suseribime','須勢理姫命','すせりびめのみこと','kami','国津神','{}','記紀','須佐之男の娘で大国主の正妻。','https://ja.wikipedia.org/wiki/那売佐神社','Wikipedia',true,now()),
('tamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{}','記紀','海神の娘。神武天皇の母。','https://ja.wikipedia.org/wiki/鶴山八幡宮','Wikipedia',true,now()),
('amenohohi','天穂日命','あめのほひのみこと','kami','天津神','{}','記紀','天照大神の子。出雲国造の祖神。','https://ja.wikipedia.org/wiki/天穂日命神社','Wikipedia',true,now()),
('nogi_maresuke','乃木希典','のぎまれすけ','kami','御霊','{}','史実','明治期の陸軍大将。学問の守護神として祀られる。','https://ja.wikipedia.org/wiki/乃木神社_(下関市)','Wikipedia',true,now()),
('hikohohodemi','彦火火出見尊','ひこほほでみのみこと','kami','天津神','{}','記紀','山幸彦。海神の助けを得た神。','https://ja.wikipedia.org/wiki/知波夜比古神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益 ------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kakinomoto_hitomaro' and g.slug in ('gakumon','gakugyo','geino'))
   or (d.slug='ogetsuhime' and g.slug in ('suisan_noko','shobai','kaiun'))
   or (d.slug='tsukuyomi' and g.slug in ('kaiun','yakubarai','kaijo_anzen'))
   or (d.slug='oyamatsumi' and g.slug in ('shobai','kaiun','yakubarai'))
   or (d.slug='sutoku_tenno' and g.slug in ('yakubarai','majo_kekkai','kaiun'))
   or (d.slug='ninigi' and g.slug in ('kaiun','shobu','shusse'))
   or (d.slug='susanoo' and g.slug in ('yakubarai','enmusubi','shobu'))
   or (d.slug='hikosashima' and g.slug in ('kaiun','shobu','yakubarai'))
   or (d.slug='godaigo_tenno' and g.slug in ('shusse','kaiun','gakumon'))
   or (d.slug='toyotamahime' and g.slug in ('anzan','enmusubi','kosodate'))
   or (d.slug='okunitama' and g.slug in ('kaiun','shobai','kanai_anzen'))
   or (d.slug='kotoshironushi' and g.slug in ('shobai','kinun','kaiun'))
   or (d.slug='kunitokotachi' and g.slug in ('kaiun','yakubarai','jouju'))
   or (d.slug='komatanokami' and g.slug in ('anzan','kosodate','mizu_amagoi'))
   or (d.slug='kushinadahime' and g.slug in ('enmusubi','renai','anzan'))
   or (d.slug='konohanasakuyahime' and g.slug in ('anzan','enmusubi','bigan'))
   or (d.slug='otataneko' and g.slug in ('yakubarai','kaiun','byoki_heyu'))
   or (d.slug='umukahihime' and g.slug in ('kosodate','byoki_heyu','kaiun'))
   or (d.slug='suseribime' and g.slug in ('enmusubi','renai','kanai_anzen'))
   or (d.slug='tamayorihime' and g.slug in ('anzan','kosodate','enmusubi'))
   or (d.slug='amenohohi' and g.slug in ('shobai','kaiun','gakumon'))
   or (d.slug='nogi_maresuke' and g.slug in ('gakugyo','gakumon','shobu'))
   or (d.slug='hikohohodemi' and g.slug in ('kaijo_anzen','suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺 + ④ 紐付け ----------------------------------------

-- 高津柿本神社 (島根県益田市) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takatsu-kakinomoto-jinja','高津柿本神社','たかつかきのもとじんじゃ','shrine','旧県社','島根県','益田市','島根県益田市高津町上市イ2616-1',34.677806,131.820194,724,null,null,'歌聖・柿本人麻呂を祀る全国の柿本神社の本社を称する古社。','https://ja.wikipedia.org/wiki/高津柿本神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takatsu-kakinomoto-jinja' and d.slug in ('kakinomoto_hitomaro'))
on conflict do nothing;

-- 焼火神社 (島根県隠岐) -------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takuhi-jinja','焼火神社','たくひじんじゃ','shrine','旧県社','島根県','隠岐郡西ノ島町','島根県隠岐郡西ノ島町美田1294',36.073389,133.028583,null,null,'http://takuhi-shrine.com/','隠岐・焼火山に鎮座する海上安全の守護神。本殿等は重要文化財。','https://ja.wikipedia.org/wiki/焼火神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takuhi-jinja' and d.slug in ('amaterasu'))
on conflict do nothing;

-- 上一宮大粟神社 (徳島県神山町) -----------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kamiichinomiya-oawa-jinja','上一宮大粟神社','かみいちのみやおおあわじんじゃ','shrine','旧郷社','徳島県','名西郡神山町','徳島県名西郡神山町神領字西上角330',33.971000,134.366940,728,null,null,'阿波国の総鎮守。大宜都比売命を祀る式内社論社。','https://ja.wikipedia.org/wiki/上一宮大粟神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kamiichinomiya-oawa-jinja' and d.slug in ('ogetsuhime'))
on conflict do nothing;

-- 西照神社 (徳島県美馬市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nishiteru-jinja','西照神社','にしてるじんじゃ','shrine','旧郷社','徳島県','美馬市','徳島県美馬市脇町西大谷672',34.123167,134.127333,null,null,'http://nisiteru-jinja.com/','大滝山頂直下に鎮座する月神の宮。空海修行の地。','https://ja.wikipedia.org/wiki/西照神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nishiteru-jinja' and d.slug in ('tsukuyomi'))
on conflict do nothing;

-- 久礼八幡宮 (高知県中土佐町) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kure-hachimangu','久礼八幡宮','くれはちまんぐう','shrine','旧県社','高知県','高岡郡中土佐町','高知県高岡郡中土佐町久礼',33.327500,133.230000,1392,null,null,'海の守護神として漁業関係者に崇敬される古社。大祭の大松明で知られる。','https://ja.wikipedia.org/wiki/久礼八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kure-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;

-- 神峯神社 (高知県安田町) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('konomine-jinja','神峯神社','こうのみねじんじゃ','shrine','旧郷社','高知県','安芸郡安田町','高知県安芸郡安田町唐浜',33.468789,133.975181,null,null,'https://www.town.yasuda.kochi.jp/','神峯山上に鎮座。四国霊場27番神峯寺の奥の院。大山祇命を祀る。','https://ja.wikipedia.org/wiki/神峯神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='konomine-jinja' and d.slug in ('oyamatsumi'))
on conflict do nothing;

-- 伊予神社 (愛媛県松前町) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iyo-jinja','伊予神社','いよじんじゃ','shrine','旧県社','愛媛県','伊予郡松前町','愛媛県伊予郡松前町神崎193',33.784170,132.743060,null,null,null,'伊予国の名神大社論社。彦狭島命を祀る古社。','https://ja.wikipedia.org/wiki/伊予神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iyo-jinja' and d.slug in ('hikosashima'))
on conflict do nothing;

-- 野間神社 (愛媛県今治市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('noma-jinja-imabari','野間神社','のまじんじゃ','shrine','旧郷社','愛媛県','今治市','愛媛県今治市神宮699',34.051000,132.957139,null,null,null,'伊予国の名神大社。石造五重塔(重文)を有する式内社。','https://ja.wikipedia.org/wiki/野間神社_(今治市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='noma-jinja-imabari' and d.slug in ('susanoo'))
on conflict do nothing;

-- 飯積神社 (愛媛県西条市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iizumi-jinja','飯積神社','いいづみじんじゃ','shrine','旧郷社','愛媛県','西条市','愛媛県西条市下島山1883',33.927694,133.209944,null,null,null,'宇迦之御魂神を祀る古社。西条まつりの太鼓台「寄せ太鼓」発祥地。','https://ja.wikipedia.org/wiki/飯積神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iizumi-jinja' and d.slug in ('ukanomitama'))
on conflict do nothing;

-- 白峰宮 (香川県坂出市) -------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shiromine-gu','白峰宮','しろみねぐう','shrine','旧県社','香川県','坂出市','香川県坂出市西庄町1719',34.311056,133.882444,1164,null,null,'崇徳天皇崩御の地に建つ社。明王(あかり)の宮とも称される。','https://ja.wikipedia.org/wiki/白峰宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shiromine-gu' and d.slug in ('sutoku_tenno'))
on conflict do nothing;

-- 高屋神社 (香川県観音寺市) ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takaya-jinja-kanonji','高屋神社','たかやじんじゃ','shrine','旧郷社','香川県','観音寺市','香川県観音寺市高屋町2800',34.160830,133.654861,null,null,null,'稲積山頂に鎮座。瀬戸内海を望む「天空の鳥居」で知られる。','https://ja.wikipedia.org/wiki/高屋神社_(観音寺市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takaya-jinja-kanonji' and d.slug in ('ninigi'))
on conflict do nothing;

-- 作楽神社 (岡山県津山市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sakura-jinja','作楽神社','さくらじんじゃ','shrine','旧県社','岡山県','津山市','岡山県津山市神戸433',35.062220,133.943060,1869,null,null,'院庄館跡に建つ。後醍醐天皇と児島高徳を祀る。桜の名所で国史跡。','https://ja.wikipedia.org/wiki/作楽神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sakura-jinja' and d.slug in ('godaigo_tenno'))
on conflict do nothing;

-- 吉川八幡宮 (岡山県吉備中央町) -----------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yoshikawa-hachimangu','吉川八幡宮','よしかわはちまんぐう','shrine','旧郷社','岡山県','加賀郡吉備中央町','岡山県加賀郡吉備中央町吉川3932',34.819583,133.751639,1096,null,null,'石清水八幡宮の別宮として創建。本殿は室町期の重要文化財。','https://ja.wikipedia.org/wiki/吉川八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yoshikawa-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;

-- 佐波神社 (山口県防府市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saba-jinja','佐波神社','さばじんじゃ','shrine','旧県社','山口県','防府市','山口県防府市惣社町6-2',34.061250,131.582556,null,null,null,'周防国の総社。天照大神・素盞嗚尊ほか十四柱を祀る。','https://ja.wikipedia.org/wiki/佐波神社_(防府市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saba-jinja' and d.slug in ('amaterasu','susanoo'))
on conflict do nothing;

-- 石城神社 (山口県光市) -------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iwaki-jinja-hikari','石城神社','いわきじんじゃ','shrine','旧郷社','山口県','光市','山口県光市塩田2233',33.987444,132.035667,574,null,null,'石城山頂に鎮座。本殿は室町期(1469年)の重要文化財。','https://ja.wikipedia.org/wiki/石城神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iwaki-jinja-hikari' and d.slug in ('oyamatsumi'))
on conflict do nothing;

-- 地御前神社 (広島県廿日市市) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jigozen-jinja','地御前神社','じごぜんじんじゃ','shrine','旧県社','広島県','廿日市市','広島県廿日市市地御前5-17',34.336239,132.319014,593,null,null,'厳島神社の外宮(地御前)。宗像三女神を祀る。','https://ja.wikipedia.org/wiki/地御前神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jigozen-jinja' and d.slug in ('ichikishima'))
on conflict do nothing;

-- 天別豊姫神社 (広島県福山市) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('amawaketoyohime-jinja','天別豊姫神社','あまわけとよひめじんじゃ','shrine','旧県社','広島県','福山市','広島県福山市神辺町川北142-2',34.538889,133.384000,null,null,null,'備後の式内社。神辺の総鎮守。豊玉姫命ほかを祀る。','https://ja.wikipedia.org/wiki/天別豊姫神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='amawaketoyohime-jinja' and d.slug in ('toyotamahime','kotoshironushi'))
on conflict do nothing;

-- 倭大国魂神社 (徳島県美馬市) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yamato-okunitama-jinja','倭大国魂神社','やまとおおくにたまじんじゃ','shrine','式内社','徳島県','美馬市','徳島県美馬市美馬町重清字東宮上3',34.049139,134.017083,null,null,null,'阿波国美馬郡の式内社。大国魂命・大己貴命を祀る。','https://ja.wikipedia.org/wiki/倭大国魂神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yamato-okunitama-jinja' and d.slug in ('okunitama','okuninushi'))
on conflict do nothing;

-- 日峰神社 (徳島県小松島市) ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hinomine-jinja','日峰神社','ひのみねじんじゃ','shrine','旧郷社','徳島県','小松島市','徳島県小松島市中田町西山92',34.022008,134.581683,751,null,'http://hinomine-jinja.sakura.ne.jp/','日峰山頂に鎮座する阿波三峰の一。蟹の絵馬で知られる。','https://ja.wikipedia.org/wiki/日峰神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hinomine-jinja' and d.slug in ('amaterasu'))
on conflict do nothing;

-- 若桜神社 (鳥取県若桜町) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('wakasa-jinja-tottori','若桜神社','わかさじんじゃ','shrine','旧郷社','鳥取県','八頭郡若桜町','鳥取県八頭郡若桜町若桜534',35.343028,134.391750,null,null,null,'若桜鬼ヶ城主矢部氏の創建と伝わる古社。社叢は県天然記念物。','https://ja.wikipedia.org/wiki/若桜神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='wakasa-jinja-tottori' and d.slug in ('kunitokotachi'))
on conflict do nothing;

-- 斐伊神社 (島根県雲南市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hii-jinja','斐伊神社','ひいじんじゃ','shrine','式内社','島根県','雲南市','島根県雲南市木次町里方',35.304889,132.903389,null,null,null,'出雲国の式内社。素盞嗚命・稲田姫命を祀る。八岐大蛇退治伝承の地。','https://ja.wikipedia.org/wiki/斐伊神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hii-jinja' and d.slug in ('susanoo','kushinadahime'))
on conflict do nothing;

-- 御井神社 (島根県出雲市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mii-jinja-izumo','御井神社','みいじんじゃ','shrine','式内社','島根県','出雲市','島根県出雲市斐川町直江2518',35.379861,132.828061,null,null,null,'出雲国の式内社。木俣神を祀り安産信仰で知られる古社。','https://ja.wikipedia.org/wiki/御井神社_(出雲市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mii-jinja-izumo' and d.slug in ('komatanokami'))
on conflict do nothing;

-- 稲田神社 (島根県奥出雲町) ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('inada-jinja-okuizumo','稲田神社','いなたじんじゃ','shrine','旧郷社','島根県','仁多郡奥出雲町','島根県仁多郡奥出雲町稲原2128-1',35.170236,133.105767,null,null,null,'奇稲田姫命を祀る。八岐大蛇神話ゆかりの社。','https://ja.wikipedia.org/wiki/稲田神社_(奥出雲町)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='inada-jinja-okuizumo' and d.slug in ('kushinadahime'))
on conflict do nothing;

-- 朝峯神社 (高知県高知市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('asamine-jinja','朝峯神社','あさみねじんじゃ','shrine','式内社','高知県','高知市','高知県高知市介良',33.558550,133.610719,null,null,null,'介良山を神体とする式内社。木花咲耶姫命を祀る。','https://ja.wikipedia.org/wiki/朝峯神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='asamine-jinja' and d.slug in ('konohanasakuyahime'))
on conflict do nothing;

-- 大川上美良布神社 (高知県香美市) ---------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('okawakami-mirafu-jinja','大川上美良布神社','おおかわかみみらふじんじゃ','shrine','式内社','高知県','香美市','高知県香美市香北町韮生野243-イ',33.650000,133.783611,null,null,'https://www.city.kami.lg.jp/','「土佐日光」と称される精緻な彫刻で知られる式内社。','https://ja.wikipedia.org/wiki/大川上美良布神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='okawakami-mirafu-jinja' and d.slug in ('otataneko'))
on conflict do nothing;

-- 津嶋神社 (香川県三豊市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tsushima-jinja-mitoyo','津嶋神社','つしまじんじゃ','shrine','旧村社','香川県','三豊市','香川県三豊市三野町大見6816-2',34.241639,133.702833,1706,null,'http://www.tsushima-jinja.com/','沖の島に鎮座する子供の守り神。夏季大祭のみ渡橋可能。','https://ja.wikipedia.org/wiki/津嶋神社_(三豊市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tsushima-jinja-mitoyo' and d.slug in ('susanoo'))
on conflict do nothing;

-- 法吉神社 (島根県松江市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hokki-jinja','法吉神社','ほっきじんじゃ','shrine','式内社','島根県','松江市','島根県松江市法吉町583',35.488056,133.045139,null,null,null,'出雲国風土記所載の式内社。大社造の本殿を持つ。','https://ja.wikipedia.org/wiki/法吉神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hokki-jinja' and d.slug in ('umukahihime'))
on conflict do nothing;

-- 那売佐神社 (島根県出雲市) ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('namesa-jinja','那売佐神社','なめさじんじゃ','shrine','式内社','島根県','出雲市','島根県出雲市東神西町',35.314389,132.699806,null,null,null,'出雲国風土記所載の式内社。大国主と須勢理姫を祀る。','https://ja.wikipedia.org/wiki/那売佐神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='namesa-jinja' and d.slug in ('okuninushi','suseribime'))
on conflict do nothing;

-- 鶴山八幡宮 (岡山県津山市) ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tsuruyama-hachimangu','鶴山八幡宮','つるやまはちまんぐう','shrine','旧県社','岡山県','津山市','岡山県津山市山北',35.069222,133.998500,1608,null,null,'津山城築城に伴い遷座。本殿は中山造の重要文化財。','https://ja.wikipedia.org/wiki/鶴山八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tsuruyama-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
on conflict do nothing;

-- 天穂日命神社 (鳥取県鳥取市) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('amenohohi-jinja','天穂日命神社','あめのほひのみことじんじゃ','shrine','式内社','鳥取県','鳥取市','鳥取県鳥取市福井',35.504306,134.125306,null,null,null,'因幡国造の祖神を祀る式内社。古代因幡の有力社。','https://ja.wikipedia.org/wiki/天穂日命神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='amenohohi-jinja' and d.slug in ('amenohohi'))
on conflict do nothing;

-- 琴弾八幡宮 (香川県観音寺市) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kotohiki-hachimangu','琴弾八幡宮','ことひきはちまんぐう','shrine','旧県社','香川県','観音寺市','香川県観音寺市八幡町1-1-1',34.132981,133.646581,703,null,null,'琴弾山に鎮座。寛永通宝の銭形砂絵で知られる古社。','https://ja.wikipedia.org/wiki/琴弾八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kotohiki-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
on conflict do nothing;

-- 乃木神社 (山口県下関市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nogi-jinja-shimonoseki','乃木神社','のぎじんじゃ','shrine','旧県社','山口県','下関市','山口県下関市長府宮の内町3-8',33.999720,130.985830,1920,null,null,'乃木希典を祀る。学問の守護神として崇敬される。','https://ja.wikipedia.org/wiki/乃木神社_(下関市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nogi-jinja-shimonoseki' and d.slug in ('nogi_maresuke'))
on conflict do nothing;

-- 赤田神社 (山口県山口市) -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('akada-jinja-yamaguchi','赤田神社','あかだじんじゃ','shrine','旧県社','山口県','山口市','山口県山口市吉敷赤田5-3-1',34.180925,131.431494,717,null,'https://akadajinja.or.jp/','周防五社の一(四の宮)。大己貴命ほかを祀る古社。','https://ja.wikipedia.org/wiki/赤田神社_(山口市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='akada-jinja-yamaguchi' and d.slug in ('okuninushi'))
on conflict do nothing;

-- 知波夜比古神社 (広島県三次市) -----------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chihayahiko-jinja','知波夜比古神社','ちはやひこじんじゃ','shrine','式内社','広島県','三次市','広島県三次市高杉町383',34.777272,132.899217,null,null,null,'備後の式内社。本殿は三次市重要文化財。','https://ja.wikipedia.org/wiki/知波夜比古神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chihayahiko-jinja' and d.slug in ('hikohohodemi'))
on conflict do nothing;

-- 高知坐神社 (高知県宿毛市) ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takochiniimasu-jinja','高知坐神社','たかちにいますじんじゃ','shrine','式内社','高知県','宿毛市','高知県宿毛市平田町',32.951194,132.800111,null,null,null,'土佐の式内社。事代主神を祀る。本殿は県保護有形文化財。','https://ja.wikipedia.org/wiki/高知坐神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takochiniimasu-jinja' and d.slug in ('kotoshironushi'))
on conflict do nothing;
