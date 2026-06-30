-- w7 北海道・東北 社寺データ（御朱印ナビ）
-- 出典: ja.wikipedia.org（infobox 十進座標で裏取り）
-- 担当県: 北海道・青森・岩手・宮城・秋田・山形・福島
-- 仕様: AGENT_SPEC.md 準拠 / _have_hokkaido-tohoku.txt と重複なし

-- =========================================================
-- ① 新規神仏（既存14柱に無いものだけ）
-- =========================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('izanagi','伊邪那岐命','いざなぎのみこと','kami','天津神','{}','記紀','国生み・神生みを行った男神。多くの神々の父。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('izanami','伊邪那美命','いざなみのみこと','kami','天津神','{}','記紀','イザナギとともに国生みを行った女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','アマテラスの弟。八岐大蛇退治で知られる荒ぶる神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kushinada','櫛名田比売','くしなだひめ','kami','国津神','{}','記紀','スサノオの妻。稲田の女神。稲田姫命とも。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('yamato_takeru','日本武尊','やまとたけるのみこと','kami','天津神','{}','記紀','景行天皇の皇子。東征・西征の英雄神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('sukunahikona','少彦名命','すくなひこなのみこと','kami','国津神','{}','記紀','オオクニヌシと国造りを行った小柄な医薬・酒造の神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('gokoku_eirei','護国の英霊','ごこくのえいれい','kami','御霊','{}','近代','国難に殉じた郷土出身の戦没者の御霊を祀る。','https://ja.wikipedia.org/wiki/護国神社','Wikipedia',true,now()),
('toyouke','豊受大神','とようけのおおかみ','kami','天津神','{}','記紀','食物・穀物を司る神。伊勢神宮外宮の祭神。','https://ja.wikipedia.org/wiki/トヨウケビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- =========================================================
-- ② 新規神仏の司るご利益
-- =========================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','yakubarai'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','shobu'))
or (d.slug='kushinada' and g.slug in ('enmusubi','kanai_anzen','anzan'))
or (d.slug='yamato_takeru' and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='sukunahikona' and g.slug in ('byoki_heyu','shobai','kanai_anzen'))
or (d.slug='gokoku_eirei' and g.slug in ('shobu','kaiun','yakubarai'))
or (d.slug='toyouke' and g.slug in ('shobai','suisan_noko','kanai_anzen'))
on conflict do nothing;

-- =========================================================
-- ③ 社寺 ＋ ④ 御祭神/本尊の紐付け
-- =========================================================

-- 1. 青森県護国神社（青森県弘前市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('aomori-gokoku-jinja','青森県護国神社','あおもりけんごこくじんじゃ','shrine','護国神社','青森県','弘前市','青森県弘前市下白銀町1-3',40.611083,140.465806,1869,null,'https://aomorigokoku-housankai.com/','弘前公園内に鎮座する青森県の護国神社。戊辰戦争以降の県出身戦没者を祀る。','https://ja.wikipedia.org/wiki/青森県護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 2. 住吉神社（北海道小樽市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('otaru-sumiyoshi-jinja','住吉神社','すみよしじんじゃ','shrine','旧県社・別表神社','北海道','小樽市','北海道小樽市住ノ江2-5-1',43.182944,141.003222,1868,null,'https://otarusumiyoshijinja.or.jp/','住吉三神と神功皇后を祀る小樽総鎮守。例大祭は北海道三大祭の一つ。','https://ja.wikipedia.org/wiki/住吉神社_(小樽市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 3. 大國神社（岩手県盛岡市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('morioka-okuni-jinja','大國神社','おおくにじんじゃ','shrine','旧村社','岩手県','盛岡市','岩手県盛岡市津志田中央1-1-17',39.662556,141.159528,1810,null,'https://sites.google.com/view/daikoku-jinja/','盛岡藩10代藩主が津志田町の鎮守として創建。大穴牟遅之命（大黒）を祀る。','https://ja.wikipedia.org/wiki/大國神社_(盛岡市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 4. 秋田県護国神社（秋田県秋田市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('akita-gokoku-jinja','秋田県護国神社','あきたけんごこくじんじゃ','shrine','護国神社','秋田県','秋田市','秋田県秋田市寺内大畑5-3',39.740830,140.078890,1869,null,null,'旧久保田城跡（千秋公園）の高清水丘に鎮座する秋田県の護国神社。','https://ja.wikipedia.org/wiki/秋田県護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 5. 黒森神社（岩手県宮古市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kuromori-jinja-miyako','黒森神社','くろもりじんじゃ','shrine','旧郷社','岩手県','宮古市','岩手県宮古市大字山口第4地割132',39.660806,141.940560,null,null,null,'黒森山に鎮座。重要無形民俗文化財「黒森神楽」を伝承する宮古の古社。','https://ja.wikipedia.org/wiki/黒森神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='aomori-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='otaru-sumiyoshi-jinja' and d.slug in ('sumiyoshi','jingu_kogo'))
or (t.slug='morioka-okuni-jinja' and d.slug in ('okuninushi'))
or (t.slug='akita-gokoku-jinja' and d.slug in ('gokoku_eirei','izanagi','izanami'))
or (t.slug='kuromori-jinja-miyako' and d.slug in ('susanoo','okuninushi','kushinada'))
on conflict do nothing;

-- =========================================================
-- 追加バッチ2: 神仏（明命=用明天皇, 阿弥陀如来）
-- =========================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yomei_tenno','用明天皇','ようめいてんのう','kami','御霊','{}','記紀','聖徳太子の父。橘豊日尊。大高山神社などに祀られる。','https://ja.wikipedia.org/wiki/用明天皇','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。念仏により極楽往生を約す。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yomei_tenno' and g.slug in ('kaiun','kanai_anzen'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','byoki_heyu','kaiun'))
on conflict do nothing;

-- 6. 大高山神社（宮城県大河原町）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('otakayama-jinja','大高山神社','おおたかやまじんじゃ','shrine','名神大社・旧郷社','宮城県','柴田郡大河原町','宮城県柴田郡大河原町金ケ瀬上谷地45',38.038447,140.699597,572,null,'http://www.ohtakayama.org/','日本武尊と橘豊日尊を祀る式内名神大社。白鳥信仰で「白鳥大明神」とも。','https://ja.wikipedia.org/wiki/大高山神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 7. 福島縣護國神社（福島県福島市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fukushima-gokoku-jinja','福島縣護國神社','ふくしまけんごこくじんじゃ','shrine','護国神社','福島県','福島市','福島県福島市駒山1',37.767722,140.468167,1879,null,'http://www.gokoku559.info/','信夫山に鎮座。戊辰戦争以降の福島県出身戦没者68,500余柱を祀る。','https://ja.wikipedia.org/wiki/福島縣護國神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 8. 長谷寺（赤田大仏／秋田県由利本荘市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('akata-chokokuji','長谷寺','ちょうこくじ','temple','曹洞宗','秋田県','由利本荘市','秋田県由利本荘市赤田上田表115',39.428111,140.103000,1775,'十一面観音（赤田大仏）','https://ja.wikipedia.org/wiki/長谷寺_(由利本荘市)','高さ約9mの十一面観音「赤田大仏」で知られる日本三大長谷観音の一つ。','https://ja.wikipedia.org/wiki/長谷寺_(由利本荘市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 9. 北海道東照宮（北海道函館市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hokkaido-toshogu','北海道東照宮','ほっかいどうとうしょうぐう','shrine','旧県社','北海道','函館市','北海道函館市陣川町82-153',41.838667,140.785306,1864,null,'https://www.toshogu24.com/','五稜郭築造に伴い創建された蝦夷地の東照宮。徳川家康を祀る。','https://ja.wikipedia.org/wiki/北海道東照宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 10. 専称寺（山形県山形市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yamagata-senshoji','専称寺','せんしょうじ','temple','真宗大谷派','山形県','山形市','山形県山形市緑町3-7-67',38.251778,140.346472,1483,'阿弥陀如来',null,'東北一の規模を誇る本堂をもつ真宗大谷派の名刹。最上義光ゆかり。','https://ja.wikipedia.org/wiki/専称寺_(山形市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='otakayama-jinja' and d.slug in ('yamato_takeru','yomei_tenno'))
or (t.slug='fukushima-gokoku-jinja' and d.slug in ('gokoku_eirei','amaterasu'))
or (t.slug='akata-chokokuji' and d.slug in ('sho_kannon'))
or (t.slug='hokkaido-toshogu' and d.slug in ('ieyasu','amaterasu'))
or (t.slug='yamagata-senshoji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- =========================================================
-- 追加バッチ3: 神仏（釈迦如来, 文殊菩薩, 速玉男命）
-- =========================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖・釈尊。悟りを開いた如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('hayatama','速玉男命','はやたまのおのみこと','kami','国津神','{}','記紀','熊野三山・熊野速玉大社の主祭神。','https://ja.wikipedia.org/wiki/クマノハヤタマノオオカミ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shaka_nyorai' and g.slug in ('byoki_heyu','kaiun','jouju'))
or (d.slug='hayatama' and g.slug in ('kaiun','yakubarai','choju'))
on conflict do nothing;

-- 11. 瑞鳳寺（宮城県仙台市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zuihoji-sendai','瑞鳳寺','ずいほうじ','temple','臨済宗妙心寺派','宮城県','仙台市','宮城県仙台市青葉区霊屋下23-5',38.251472,140.866611,1637,'釈迦三尊','https://ja.wikipedia.org/wiki/瑞鳳寺','伊達政宗の菩提寺。瑞鳳殿の麓に2代藩主忠宗が創建した臨済宗寺院。','https://ja.wikipedia.org/wiki/瑞鳳寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 12. 林泉寺（山形県米沢市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yonezawa-rinsenji','林泉寺','りんせんじ','temple','曹洞宗','山形県','米沢市','山形県米沢市林泉寺1-2-3',37.901390,140.101500,1617,'釈迦如来','http://yone-rinsenji.com/','上杉家の菩提寺。仙桃院が米沢に建立。直江兼続らの墓所がある。','https://ja.wikipedia.org/wiki/林泉寺_(米沢市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 13. 願成寺（会津大仏／福島県喜多方市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kitakata-ganjoji','願成寺','がんじょうじ','temple','浄土宗','福島県','喜多方市','福島県喜多方市上三宮町上三宮字籬山833',37.688060,139.863330,1227,'阿弥陀如来（会津大仏）','https://aizudaibutsu.com/','国指定重要文化財「会津大仏」を本尊とする浄土宗の名刹。','https://ja.wikipedia.org/wiki/願成寺_(喜多方市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 14. 如法寺（鳥追観音／福島県西会津町）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nishiaizu-nyohoji','如法寺','にょほうじ','temple','真言宗','福島県','耶麻郡西会津町','福島県耶麻郡西会津町野沢字如法寺乙3533',37.575722,139.641333,807,'聖観世音菩薩（鳥追観音）','http://www.torioi.com/','徳一開基と伝わる会津ころり三観音の一つ。鳥追観音で知られる。','https://ja.wikipedia.org/wiki/如法寺_(福島県西会津町)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 15. 三熊野神社（成島毘沙門堂／岩手県花巻市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hanamaki-mikumano-jinja','三熊野神社','みくまのじんじゃ','shrine','旧村社','岩手県','花巻市','岩手県花巻市東和町北成島5区1',39.365639,141.197500,802,null,'http://www.ganshinsei.jp/hanamakishi/272kumanojinja.html','熊野三山を勧請した古社。隣接の成島毘沙門堂に国重文の毘沙門天像。泣き相撲で有名。','https://ja.wikipedia.org/wiki/三熊野神社_(花巻市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zuihoji-sendai' and d.slug in ('shaka_nyorai'))
or (t.slug='yonezawa-rinsenji' and d.slug in ('shaka_nyorai'))
or (t.slug='kitakata-ganjoji' and d.slug in ('amida_nyorai'))
or (t.slug='nishiaizu-nyohoji' and d.slug in ('sho_kannon'))
or (t.slug='hanamaki-mikumano-jinja' and d.slug in ('izanami','hayatama'))
on conflict do nothing;

-- =========================================================
-- 追加バッチ4: 神仏（建御雷神, 経津主神, 天之御中主神, 後村上天皇）
-- =========================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{}','記紀','雷と剣の武神。国譲りで活躍。武甕槌神とも。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now()),
('futsunushi','経津主神','ふつぬしのかみ','kami','天津神','{}','記紀','刀剣の威力を神格化した武神。香取神宮の祭神。','https://ja.wikipedia.org/wiki/フツヌシ','Wikipedia',true,now()),
('amenominakanushi','天之御中主神','あめのみなかぬしのかみ','kami','天津神','{}','記紀','造化三神の首座。宇宙の根源神。妙見信仰と習合。','https://ja.wikipedia.org/wiki/アメノミナカヌシ','Wikipedia',true,now()),
('gomurakami_tenno','後村上天皇','ごむらかみてんのう','kami','御霊','{}','史実','南朝第2代天皇。南朝忠臣とともに祀られる。','https://ja.wikipedia.org/wiki/後村上天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','kaiun'))
or (d.slug='futsunushi' and g.slug in ('shobu','shusse','yakubarai'))
or (d.slug='amenominakanushi' and g.slug in ('kaiun','yakubarai','choju'))
or (d.slug='gomurakami_tenno' and g.slug in ('kaiun','shobu'))
on conflict do nothing;

-- 16. 龍泉寺（秋田県羽後町）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ugo-ryusenji','龍泉寺','りゅうせんじ','temple','曹洞宗','秋田県','雄勝郡羽後町','秋田県雄勝郡羽後町新町上田子99',39.245667,140.376306,null,'聖観世音菩薩',null,'江戸期の堂宇がほぼ完存する曹洞宗寺院。高寺城・七高山信仰にゆかり。','https://ja.wikipedia.org/wiki/龍泉寺_(秋田県羽後町)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 17. 多賀城神社（宮城県多賀城市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tagajo-jinja','多賀城神社','たがじょうじんじゃ','shrine','旧社格なし','宮城県','多賀城市','宮城県多賀城市市川字大畑13',38.307250,140.987639,1952,null,null,'多賀城跡近くに鎮座し、後村上天皇ら南朝の忠臣を祀る神社。','https://ja.wikipedia.org/wiki/多賀城神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 18. 香積寺（宮城県石巻市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ishinomaki-koshakuji','香積寺','こうしゃくじ','temple','曹洞宗','宮城県','石巻市','宮城県石巻市桃生町城内西嶺122',38.562306,141.257833,1342,'釈迦如来','https://www.kosyakuji.com/','仙台四大画家・菊田伊洲の花鳥天井で知られる曹洞宗寺院。','https://ja.wikipedia.org/wiki/香積寺_(石巻市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 19. 相馬小高神社（福島県南相馬市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('soma-odaka-jinja','相馬小高神社','そうまおだかじんじゃ','shrine','旧県社','福島県','南相馬市','福島県南相馬市小高区小高字古城13',37.568333,140.990556,null,null,'https://odakajinja.jp/','小高城跡に鎮座する相馬氏ゆかりの古社。相馬野馬追の三妙見社の一つ。','https://ja.wikipedia.org/wiki/小高城','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 20. 伊達神社（宮城県色麻町）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shikama-date-jinja','伊達神社','だてじんじゃ','shrine','名神大社・式内社','宮城県','加美郡色麻町','宮城県加美郡色麻町四竃字町3',38.545306,140.851111,800,null,null,'坂上田村麻呂の創建と伝わる式内名神大社。色麻古社三社の一つ。','https://ja.wikipedia.org/wiki/伊達神社_(色麻町)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ugo-ryusenji' and d.slug in ('sho_kannon'))
or (t.slug='tagajo-jinja' and d.slug in ('gomurakami_tenno'))
or (t.slug='ishinomaki-koshakuji' and d.slug in ('shaka_nyorai'))
or (t.slug='soma-odaka-jinja' and d.slug in ('amenominakanushi'))
or (t.slug='shikama-date-jinja' and d.slug in ('futsunushi','takemikazuchi'))
on conflict do nothing;
