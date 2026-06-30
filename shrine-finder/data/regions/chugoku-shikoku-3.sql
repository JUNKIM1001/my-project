-- 中国・四国 観光著名社寺 第3弾
-- 担当県: 鳥取,島根,岡山,広島,山口,徳島,香川,愛媛,高知
-- 出典: ja.wikipedia.org のinfobox座標を確認したもののみ。

-- ① 新規神仏（既存に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ame_no_tokotachi','天之常立神','あめのとことたちのかみ','kami','天津神','{}','記紀','天地開闢の際に現れた別天津神の一柱。','https://ja.wikipedia.org/wiki/アメノトコタチ','Wikipedia',true,now()),
('yatsukamizuomitsuno','八束水臣津野命','やつかみずおみつぬのみこと','kami','国津神','{}','風土記','出雲国風土記の国引き神話の主神。','https://ja.wikipedia.org/wiki/ヤツカミズオミツヌ','Wikipedia',true,now()),
('omizunu','淤美豆奴神','おみづぬのかみ','kami','国津神','{}','記紀','大国主の祖先神。','https://ja.wikipedia.org/wiki/淤美豆奴神','Wikipedia',true,now()),
('susanoo','須佐之男命','すさのおのみこと','kami','天津神','{建速須佐之男命}','記紀','天照大神の弟。八岐大蛇退治の英雄神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kushinadahime','稲田比売命','くしなだひめのみこと','kami','国津神','{奇稲田姫}','記紀','スサノオの妻。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方浄瑠璃世界の教主。病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{十一面観世音菩薩}','仏教','十一の顔を持つ観音菩薩。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{千手観世音菩薩}','仏教','千の手で衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖、ゴータマ・ブッダ。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('ukemochi','保食神','うけもちのかみ','kami','国津神','{}','記紀','食物を司る神。','https://ja.wikipedia.org/wiki/ウケモチ','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('chuai','仲哀天皇','ちゅうあいてんのう','kami','人神','{足仲彦尊}','記紀','第14代天皇。神功皇后の夫。','https://ja.wikipedia.org/wiki/仲哀天皇','Wikipedia',true,now()),
('hitokotonushi','一言主大神','ひとことぬしのおおかみ','kami','国津神','{一言主命}','記紀','一言の願いを叶えるとされる葛城の神。','https://ja.wikipedia.org/wiki/ヒトコトヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ame_no_tokotachi' and g.slug in ('kaiun','jouju')) or
   (d.slug='yatsukamizuomitsuno' and g.slug in ('shobu','kaiun')) or
   (d.slug='omizunu' and g.slug in ('kaiun','kinun')) or
   (d.slug='susanoo' and g.slug in ('yakubarai','enmusubi','shobu')) or
   (d.slug='kushinadahime' and g.slug in ('enmusubi','anzan','kanai_anzen')) or
   (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju')) or
   (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','kaiun','yakubarai')) or
   (d.slug='senju_kannon' and g.slug in ('kaiun','byoki_heyu','jouju')) or
   (d.slug='shaka_nyorai' and g.slug in ('kaiun','byoki_heyu')) or
   (d.slug='ukemochi' and g.slug in ('shobai','suisan_noko')) or
   (d.slug='amida_nyorai' and g.slug in ('kaiun','jouju','byoki_heyu')) or
   (d.slug='chuai' and g.slug in ('kaiun','shobu')) or
   (d.slug='hitokotonushi' and g.slug in ('jouju','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanemochi-jinja','金持神社','かねもちじんじゃ','shrine','金持神社','鳥取県','日野郡日野町','鳥取県日野郡日野町金持1490',35.215194,133.459167,810,null,'http://www.kanemochi-jinja.net/','「金持」の名から金運・開運の社として全国から参拝者が訪れる。','https://ja.wikipedia.org/wiki/金持神社','Wikipedia',true,now()),
('suga-jinja-unnan','須我神社','すがじんじゃ','shrine','須我神社','島根県','雲南市','島根県雲南市大東町須賀260',35.35389,133.03139,null,null,'https://suga-jinja.or.jp/','スサノオが八岐大蛇退治後に宮を造ったとされ「日本初之宮」と称される。','https://ja.wikipedia.org/wiki/須我神社','Wikipedia',true,now()),
('kiyomizudera-yasugi','清水寺','きよみずでら','temple','天台宗','島根県','安来市','島根県安来市清水町528',35.40225,133.281889,587,'十一面観世音菩薩','http://www.kiyomizudera.jp/','用明天皇の時代の創建と伝わる山陰の古刹。三重塔で知られる。','https://ja.wikipedia.org/wiki/清水寺_(安来市)','Wikipedia',true,now()),
('yokeiji-setouchi','餘慶寺','よけいじ','temple','天台宗','岡山県','瀬戸内市','岡山県瀬戸内市邑久町北島1187',34.654417,134.061389,749,'千手観世音菩薩','http://www.yokeiji.jp/','中国三十三観音第2番。本堂は国の重要文化財。','https://ja.wikipedia.org/wiki/餘慶寺','Wikipedia',true,now()),
('mitakidera-hiroshima','三瀧寺','みたきでら','temple','高野山真言宗','広島県','広島市','広島県広島市西区三滝山411',34.420306,132.437611,809,'聖観世音菩薩','http://www.mitakidera.com/','三本の滝で知られる広島市西区の名刹。多宝塔は原爆犠牲者の供養塔。','https://ja.wikipedia.org/wiki/三瀧寺','Wikipedia',true,now()),
('myooin-fukuyama','明王院','みょうおういん','temple','真言宗大覚寺派','広島県','福山市','広島県福山市草戸町1473',34.478722,133.345972,807,'十一面観世音菩薩','http://www.chisan.net/myooin/','本堂・五重塔ともに国宝を有する中世寺院。','https://ja.wikipedia.org/wiki/明王院_(福山市)','Wikipedia',true,now()),
('kusado-inari-jinja','草戸稲荷神社','くさどいなりじんじゃ','shrine','草戸稲荷神社','広島県','福山市','広島県福山市草戸町1467',34.479472,133.346361,807,null,'https://kusadoinari.com/','日本五大稲荷の一つに数えられ、初詣に約40万人が参拝する。','https://ja.wikipedia.org/wiki/草戸稲荷神社','Wikipedia',true,now()),
('kanyoji-shunan','漢陽寺','かんようじ','temple','臨済宗南禅寺派','山口県','周南市','山口県周南市鹿野上2872',34.2355,131.815083,1374,'聖観世音菩薩','http://kanyouji.or.jp/','重森三玲作庭の名園で知られる臨済宗の別格地。','https://ja.wikipedia.org/wiki/漢陽寺','Wikipedia',true,now()),
('yakuoji-minami','薬王寺','やくおうじ','temple','高野山真言宗','徳島県','海部郡美波町','徳島県海部郡美波町奥河内字寺前285-1',33.732306,134.527583,726,'薬師如来','https://yakuouji.net/','四国八十八ヶ所第23番。厄除けの寺として広く信仰される。','https://ja.wikipedia.org/wiki/薬王寺_(徳島県美波町)','Wikipedia',true,now()),
('jorokuji-tokushima','丈六寺','じょうろくじ','temple','曹洞宗','徳島県','徳島市','徳島県徳島市丈六町丈領32',34.005222,134.550944,650,'釈迦如来','https://ja.wikipedia.org/wiki/丈六寺','Wikipedia','「阿波の法隆寺」と称される古刹。三門・観音堂などが重要文化財。','https://ja.wikipedia.org/wiki/丈六寺','Wikipedia',true,now()),
('takinomiya-tenmangu','滝宮天満宮','たきのみやてんまんぐう','shrine','滝宮天満宮','香川県','綾歌郡綾川町','香川県綾歌郡綾川町滝宮1314',34.2496417,133.919111,948,null,'http://www.takinomiyatenmangu.com/','菅原道真を祀る讃岐の天神。雨乞いの滝宮念仏踊で知られる。','https://ja.wikipedia.org/wiki/滝宮天満宮','Wikipedia',true,now()),
('goshoji-utazu','郷照寺','ごうしょうじ','temple','時宗','香川県','綾歌郡宇多津町','香川県綾歌郡宇多津町字山下1435',34.306694,133.824583,725,'阿弥陀如来','https://yakuyoke.org/','四国八十八ヶ所第78番。時宗と真言宗を兼ねる「厄除うたづ大師」。','https://ja.wikipedia.org/wiki/郷照寺','Wikipedia',true,now()),
('isaniwa-jinja','伊佐爾波神社','いさにわじんじゃ','shrine','伊佐爾波神社','愛媛県','松山市','愛媛県松山市桜谷町173',33.850694,132.788694,null,null,'https://isaniwa.official.jp/','道後の丘に建つ八幡造の社殿は国の重要文化財。','https://ja.wikipedia.org/wiki/伊佐爾波神社','Wikipedia',true,now()),
('eifukuji-imabari','栄福寺','えいふくじ','temple','高野山真言宗','愛媛県','今治市','愛媛県今治市玉川町八幡甲200',34.029472,132.978472,810,'阿弥陀如来','https://www.eifukuji.jp/','四国八十八ヶ所第57番。空海開創と伝わる。','https://ja.wikipedia.org/wiki/栄福寺_(今治市)','Wikipedia',true,now()),
('otonashi-jinja','鳴無神社','おとなしじんじゃ','shrine','鳴無神社','高知県','須崎市','高知県須崎市浦ノ内東分3579',33.414306,133.3687889,null,null,null,'海に向かって参道が延びる「土佐の宮島」。社殿は重要文化財。','https://ja.wikipedia.org/wiki/鳴無神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanemochi-jinja' and d.slug in ('ame_no_tokotachi','yatsukamizuomitsuno','omizunu')) or
   (t.slug='suga-jinja-unnan' and d.slug in ('susanoo','kushinadahime')) or
   (t.slug='kiyomizudera-yasugi' and d.slug in ('juichimen_kannon')) or
   (t.slug='yokeiji-setouchi' and d.slug in ('senju_kannon')) or
   (t.slug='mitakidera-hiroshima' and d.slug in ('sho_kannon')) or
   (t.slug='myooin-fukuyama' and d.slug in ('juichimen_kannon')) or
   (t.slug='kusado-inari-jinja' and d.slug in ('ukanomitama','ukemochi','okuninushi')) or
   (t.slug='kanyoji-shunan' and d.slug in ('sho_kannon')) or
   (t.slug='yakuoji-minami' and d.slug in ('yakushi_nyorai')) or
   (t.slug='jorokuji-tokushima' and d.slug in ('shaka_nyorai')) or
   (t.slug='takinomiya-tenmangu' and d.slug in ('michizane')) or
   (t.slug='goshoji-utazu' and d.slug in ('amida_nyorai')) or
   (t.slug='isaniwa-jinja' and d.slug in ('hachiman','chuai','jingu_kogo','ichikishima')) or
   (t.slug='eifukuji-imabari' and d.slug in ('amida_nyorai')) or
   (t.slug='otonashi-jinja' and d.slug in ('hitokotonushi'))
on conflict do nothing;
