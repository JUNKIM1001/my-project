-- =====================================================================
-- 御朱印ナビ 社寺データ拡張: 中部地方（3巡目 / 観光著名社寺ティア）
-- 対象県: 新潟,富山,石川,福井,山梨,長野,岐阜,静岡,愛知
-- 出典: ja.wikipedia.org（各社寺記事の infobox から所在地・十進座標・
--        御祭神/本尊・創建・公式サイトを WebFetch で裏取り）
-- 1巡目 chubu.sql / 2巡目 chubu-2.sql 収録分とは重複させていない
-- 全 50 件（新潟4/富山5/石川4/福井4/山梨6/長野4/岐阜8/静岡4/愛知11）
-- 座標が infobox に無い社寺は除外
-- =====================================================================

-- ---------------------------------------------------------------------
-- ① 新規神仏（既存柱・1巡目/2巡目で定義済みの柱に無いものだけ）
-- ---------------------------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('omoikane','八意思兼神','やごころおもいかねのかみ','kami','天津神','{思兼神,常世思金神,八意兼大神}','記紀','高天原の知恵を司る神。思慮分別・学業・開運の神。','https://ja.wikipedia.org/wiki/オモイカネ','Wikipedia',true,now()),
('maeda_toshinaga','前田利長','まえだとしなが','kami','御霊','{}','歴史','加賀前田家2代・加賀藩初代藩主。高岡城を築き高岡開祖と仰がれる。','https://ja.wikipedia.org/wiki/前田利長','Wikipedia',true,now()),
('mizuhanome','弥都波能売神','みづはのめのかみ','kami','国津神','{罔象女神,水波能売命}','記紀','水を司る女神。灌漑・治水・井戸の守護神。','https://ja.wikipedia.org/wiki/ミズハノメ','Wikipedia',true,now()),
('oagata_okami','大縣大神','おおあがたのおおかみ','kami','国津神','{国狭槌尊}','記紀','尾張二宮・大縣神社の主祭神。尾張開拓の祖神とされる。','https://ja.wikipedia.org/wiki/大縣神社','Wikipedia',true,now())
on conflict (slug) do nothing;
-- 注: amida_nyorai / shaka_nyorai / juichimen_kannon / fudo_myoo / ukanomitama / amaterasu /
--      izanami / kunitokotachi / michizane / takaokami / kuraokami / keitai_tenno /
--      susanoo / okuninushi / sukunabikona / yamatotakeru 等は既存定義を参照（再定義しない）。

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ1: 新潟・富山・石川・福井・山梨）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hotokusan-inari-taisha','宝徳山稲荷大社','ほうとくさんいなりたいしゃ','shrine','宝徳山稲荷大社（単立）','新潟県','長岡市','新潟県長岡市飯塚859',37.3849750,138.7591806,null,null,'https://www.houtoku.or.jp/','越国総鎮守と伝わる稲荷大社。11月の夜祭神事が有名。','https://ja.wikipedia.org/wiki/宝徳山稲荷大社','Wikipedia',true,now()),
('nisseki-ji','日石寺','にっせきじ','temple','真言密宗大本山','富山県','中新川郡上市町','富山県中新川郡上市町大岩163',36.662139,137.391083,725,'不動明王（磨崖仏・重要文化財）','http://ooiwasan.com/','大岩山。岩壁に刻まれた不動明王磨崖仏で知られる真言密宗大本山。','https://ja.wikipedia.org/wiki/日石寺','Wikipedia',true,now()),
('takaoka-sekino-jinja','高岡関野神社','たかおかせきのじんじゃ','shrine','高岡関野神社','富山県','高岡市','富山県高岡市末広町9-56',36.743528,137.011417,1604,null,'https://www.takaokasekinojinjya.com/','関野・高岡・稲荷の三社を合祀。高岡御車山祭で知られる。','https://ja.wikipedia.org/wiki/高岡関野神社','Wikipedia',true,now()),
('kokutai-ji','国泰寺','こくたいじ','temple','臨済宗国泰寺派大本山','富山県','高岡市','富山県高岡市太田184',36.810787,137.010735,1304,'釈迦如来','https://www.kokutaiji.jp/','臨済宗国泰寺派の大本山。山岡鉄舟・鈴木大拙ゆかりの古刹。','https://ja.wikipedia.org/wiki/国泰寺_(高岡市)','Wikipedia',true,now()),
('myojo-ji','妙成寺','みょうじょうじ','temple','日蓮宗本山','石川県','羽咋市','石川県羽咋市滝谷町ヨ1',36.9544944,136.7760139,1294,'三宝尊','http://myojoji-noto.jp/','前田家ゆかりの日蓮宗本山。五重塔など重要文化財を多数有する。','https://ja.wikipedia.org/wiki/妙成寺','Wikipedia',true,now()),
('daijo-ji-kanazawa','大乗寺','だいじょうじ','temple','曹洞宗','石川県','金沢市','石川県金沢市長坂町ル10',36.532556,136.658944,1263,'釈迦如来','https://daijoji.or.jp/','加賀の曹洞宗の名刹。徹通義介開山、加賀藩本多家の菩提寺。','https://ja.wikipedia.org/wiki/大乗寺_(金沢市)','Wikipedia',true,now()),
('keya-kurotatsu-jinja-fukui','毛谷黒龍神社','けやくろたつじんじゃ','shrine','毛谷黒龍神社','福井県','福井市','福井県福井市毛矢3-8-1',36.0568361,136.2118861,477,null,'https://www.kurotatu-jinja.jp/','足羽山麓に鎮座する越前の黒龍。水神・開運の社。','https://ja.wikipedia.org/wiki/毛谷黒龍神社','Wikipedia',true,now()),
('kai-zenkoji','甲斐善光寺','かいぜんこうじ','temple','浄土宗','山梨県','甲府市','山梨県甲府市善光寺3-36-1',35.666000,138.592917,1558,'善光寺如来（銅造阿弥陀三尊像）','http://www.kai-zenkoji.or.jp/','武田信玄が信濃善光寺の本尊を移して創建した浄土宗の名刹。','https://ja.wikipedia.org/wiki/甲斐善光寺','Wikipedia',true,now()),
('unpo-ji','雲峰寺','うんぽうじ','temple','臨済宗妙心寺派','山梨県','甲州市','山梨県甲州市塩山上萩原2678',35.739472,138.804444,745,'十一面観音','http://unpoji.ko-shu.jp/','行基開創と伝わる古刹。武田家の軍旗「孫子の旗」を所蔵。','https://ja.wikipedia.org/wiki/雲峰寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ1）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hotokusan-inari-taisha' and d.slug in ('ukanomitama','omoikane'))
or (t.slug='nisseki-ji' and d.slug='fudo_myoo')
or (t.slug='takaoka-sekino-jinja' and d.slug in ('kunitokotachi','amaterasu','izanami'))
or (t.slug='kokutai-ji' and d.slug='shaka_nyorai')
or (t.slug='myojo-ji' and d.slug='shaka_nyorai')
or (t.slug='daijo-ji-kanazawa' and d.slug='shaka_nyorai')
or (t.slug='keya-kurotatsu-jinja-fukui' and d.slug in ('takaokami','kuraokami','keitai_tenno'))
or (t.slug='kai-zenkoji' and d.slug='amida_nyorai')
or (t.slug='unpo-ji' and d.slug='juichimen_kannon')
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='takaoka-sekino-jinja' and d.slug in ('ukanomitama','michizane','maeda_toshinaga'))
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ2: 長野・岐阜・静岡）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('joraku-ji-ueda','常楽寺','じょうらくじ','temple','天台宗別格本山','長野県','上田市','長野県上田市別所温泉2347',36.186833,138.154750,825,'妙観察智弥陀如来','https://www.kitamuki-kannon.com/','別所温泉の天台宗別格本山。鎌倉期の石造多宝塔(重文)で知られ、北向観音を管理する。','https://ja.wikipedia.org/wiki/常楽寺_(上田市)','Wikipedia',true,now()),
('hida-kokubun-ji','飛騨国分寺','ひだこくぶんじ','temple','高野山真言宗','岐阜県','高山市','岐阜県高山市総和町1-83',36.1433500,137.253694,746,'薬師如来','http://hidakokubunji.jp/','聖武天皇の詔で建立された飛騨の国分寺。三重塔と大イチョウが名物。','https://ja.wikipedia.org/wiki/飛騨国分寺','Wikipedia',true,now()),
('senko-ji-takayama','千光寺','せんこうじ','temple','高野山真言宗','岐阜県','高山市','岐阜県高山市丹生川町下保1553',36.19000,137.28861,808,'千手観世音菩薩','https://senkouji.com/','円空仏約63体を所蔵する袈裟山の古刹。「円空仏の寺」として名高い。','https://ja.wikipedia.org/wiki/千光寺_(高山市)','Wikipedia',true,now()),
('shinzen-in','真禅院','しんぜんいん','temple','天台宗','岐阜県','不破郡垂井町','岐阜県不破郡垂井町宮代2006',35.362278,136.515889,739,'無量寿如来（阿弥陀如来）','https://www.shinzenin.com/','南宮大社の旧神宮寺。三重塔・本地堂(重文)を有する朝倉山の天台寺院。','https://ja.wikipedia.org/wiki/真禅院','Wikipedia',true,now()),
('shuzen-ji','修禅寺','しゅぜんじ','temple','曹洞宗','静岡県','伊豆市','静岡県伊豆市修善寺964',34.971500,138.927556,807,'大日如来（重要文化財）','https://www.shuzenji-temple.jp/','修善寺温泉の名刹。源範頼・頼家ゆかりの曹洞宗寺院。','https://ja.wikipedia.org/wiki/修禅寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ2）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='joraku-ji-ueda' and d.slug='amida_nyorai')
or (t.slug='hida-kokubun-ji' and d.slug='yakushi_nyorai')
or (t.slug='senko-ji-takayama' and d.slug='senju_kannon')
or (t.slug='shinzen-in' and d.slug='amida_nyorai')
or (t.slug='shuzen-ji' and d.slug='dainichi_nyorai')
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ3: 愛知）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takisan-ji','滝山寺','たきさんじ','temple','天台宗','愛知県','岡崎市','愛知県岡崎市滝町山籠107',34.9881583,137.2056278,686,'薬師如来','http://takisanji.net/','運慶・湛慶作の聖観音像を伝える天台宗の古刹。鬼祭りで知られる。','https://ja.wikipedia.org/wiki/瀧山寺','Wikipedia',true,now()),
('horai-ji','鳳来寺','ほうらいじ','temple','真言宗五智教団','愛知県','新城市','愛知県新城市門谷字鳳来寺1',34.9787389,137.5861889,702,'薬師如来','http://www.horaisan-houraiji.or.jp/','利修仙人開山と伝わる鳳来寺山の山岳寺院。家康出生祈願の地。','https://ja.wikipedia.org/wiki/鳳来寺','Wikipedia',true,now()),
('sanko-inari-jinja-inuyama','三光稲荷神社','さんこういなりじんじゃ','shrine','三光稲荷神社','愛知県','犬山市','愛知県犬山市北古券65-18',35.3868944,136.9391306,null,null,null,'犬山城の麓に鎮座する稲荷社。縁結び・銭洗いで人気の参拝地。','https://ja.wikipedia.org/wiki/三光稲荷神社_(犬山市)','Wikipedia',true,now()),
('toga-jinja-toyokawa','砥鹿神社','とがじんじゃ','shrine','三河国一宮（国幣小社）','愛知県','豊川市','愛知県豊川市一宮町西垣内2',34.847639,137.421194,701,null,'http://www.togajinja.or.jp/','三河国一宮。大己貴命を祀る本茂山信仰の古社。','https://ja.wikipedia.org/wiki/砥鹿神社','Wikipedia',true,now()),
('horaisan-toshogu','鳳来山東照宮','ほうらいさんとうしょうぐう','shrine','東照宮','愛知県','新城市','愛知県新城市門谷字鳳来寺4',34.978833,137.587472,1651,null,'http://www.tees.ne.jp/~horaitosyogu/','鳳来寺山中に鎮座。家光・家綱が造営した日本三大東照宮の一。','https://ja.wikipedia.org/wiki/鳳来山東照宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ3）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takisan-ji' and d.slug='yakushi_nyorai')
or (t.slug='horai-ji' and d.slug='yakushi_nyorai')
or (t.slug='sanko-inari-jinja-inuyama' and d.slug='ukanomitama')
or (t.slug='toga-jinja-toyokawa' and d.slug='okuninushi')
or (t.slug='horaisan-toshogu' and d.slug='ieyasu')
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='sanko-inari-jinja-inuyama' and d.slug='sarutahiko')
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ4: 愛知・新潟・石川）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('wakeoe-jinja-nagoya','別小江神社','わけおえじんじゃ','shrine','別小江神社（式内社）','愛知県','名古屋市','愛知県名古屋市北区安井4-14-4',35.210389,136.921000,null,null,'http://wakeoe.com/','名古屋・安井に鎮座する式内社。季節の御朱印で知られる。','https://ja.wikipedia.org/wiki/別小江神社','Wikipedia',true,now()),
('tatsuki-jinja-okazaki','龍城神社','たつきじんじゃ','shrine','龍城神社','愛知県','岡崎市','愛知県岡崎市康生町561',34.95611,137.15917,1876,null,'http://home1.catvmics.ne.jp/~tatuki/','岡崎城内に鎮座。徳川家康・本多忠勝を祀る勝運の社。','https://ja.wikipedia.org/wiki/龍城神社','Wikipedia',true,now()),
('kota-jinja-joetsu','居多神社','こたじんじゃ','shrine','越後国一宮（県社）','新潟県','上越市','新潟県上越市五智6-1-11',37.1664389,138.2231694,null,null,null,'越後国一宮の一。親鸞ゆかりの大国主を祀る古社。','https://ja.wikipedia.org/wiki/居多神社','Wikipedia',true,now()),
('ishiura-jinja','石浦神社','いしうらじんじゃ','shrine','石浦神社','石川県','金沢市','石川県金沢市本多町3-1-30',36.561194,136.659833,729,null,'https://www.ishiura.jp/','金沢最古と伝わる古社。兼六園に隣接し縁結びで人気。','https://ja.wikipedia.org/wiki/石浦神社','Wikipedia',true,now()),
('ataka-sumiyoshi-jinja','安宅住吉神社','あたかすみよしじんじゃ','shrine','安宅住吉神社（県社）','石川県','小松市','石川県小松市安宅町タ17',36.41917,136.41806,782,null,'https://www.ataka.or.jp/','安宅の関の地に鎮座。難関突破の守護神として知られる。','https://ja.wikipedia.org/wiki/安宅住吉神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ4）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='wakeoe-jinja-nagoya' and d.slug in ('izanagi','izanami'))
or (t.slug='tatsuki-jinja-okazaki' and d.slug in ('ieyasu','honda_tadakatsu'))
or (t.slug='kota-jinja-joetsu' and d.slug='okuninushi')
or (t.slug='ishiura-jinja' and d.slug='omononushi')
or (t.slug='ataka-sumiyoshi-jinja' and d.slug='sumiyoshi')
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='wakeoe-jinja-nagoya' and d.slug in ('amaterasu','susanoo','tsukuyomi'))
or (t.slug='kota-jinja-joetsu' and d.slug in ('nunakawahime','takeminakata','kotoshironushi'))
or (t.slug='ishiura-jinja' and d.slug in ('oyamakui','kukurihime','amaterasu'))
or (t.slug='ataka-sumiyoshi-jinja' and d.slug='sukunabikona')
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ5: 福井・愛知・静岡・岐阜）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('otaki-okoto-jinja-echizen','大瀧神社・岡太神社','おおたきおかもとじんじゃ','shrine','大瀧神社・岡太神社（県社）','福井県','越前市','福井県越前市大滝町23-10',35.90611,136.252972,719,null,'https://www.echizenwashi.jp/','紙祖神・川上御前を祀る和紙の里の社。複雑な権現造の社殿が国重文。','https://ja.wikipedia.org/wiki/大瀧神社・岡太神社','Wikipedia',true,now()),
('ooagata-jinja','大縣神社','おおあがたじんじゃ','shrine','尾張国二宮（国幣中社）','愛知県','犬山市','愛知県犬山市宮山3',35.330139,136.966222,null,null,'http://ooagata.urdr.weblife.me/','尾張国二宮。姫の宮があり安産・縁結びの信仰を集める。','https://ja.wikipedia.org/wiki/大縣神社','Wikipedia',true,now()),
('oi-jinja-shimada','大井神社','おおいじんじゃ','shrine','大井神社（県社）','静岡県','島田市','静岡県島田市大井町2316',34.8336611,138.1717778,865,null,'http://www.ooijinjya.org/','大井川の水神を祀る。日本三奇祭の一「帯祭り」で知られる。','https://ja.wikipedia.org/wiki/大井神社_(島田市)','Wikipedia',true,now()),
('mieji-gifu','美江寺','みえじ','temple','天台宗','岐阜県','岐阜市','岐阜県岐阜市美江寺町2-3',35.426389,136.758417,717,'十一面観音','http://www.mieji.jp/','岐阜の名刹。乾漆造の十一面観音(重文)を本尊とする天台宗寺院。','https://ja.wikipedia.org/wiki/美江寺','Wikipedia',true,now()),
('yokokura-ji','横蔵寺','よこくらじ','temple','天台宗','岐阜県','揖斐郡揖斐川町','岐阜県揖斐郡揖斐川町谷汲神原1160',35.5532556,136.5610139,801,'薬師如来（重要文化財）','https://yokokura-ji.or.jp/','「美濃の正倉院」と称される天台宗の古刹。舎利仏(ミイラ)で有名。','https://ja.wikipedia.org/wiki/横蔵寺_(岐阜県揖斐川町)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ5）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='otaki-okoto-jinja-echizen' and d.slug in ('kunitokotachi','izanagi','kawakami_gozen'))
or (t.slug='ooagata-jinja' and d.slug='oagata_okami')
or (t.slug='oi-jinja-shimada' and d.slug in ('mizuhanome','haniyasuhime','amaterasu'))
or (t.slug='mieji-gifu' and d.slug='juichimen_kannon')
or (t.slug='yokokura-ji' and d.slug='yakushi_nyorai')
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ6: 新潟・静岡・愛知）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oppo-ji','乙宝寺','おっぽうじ','temple','真言宗智山派','新潟県','胎内市','新潟県胎内市乙1112',38.1199528,139.4030361,736,'金剛界大日如来','http://oppouji.info/','聖武天皇勅願と伝わる越後屈指の古刹。三重塔(重文)を有する。','https://ja.wikipedia.org/wiki/乙宝寺','Wikipedia',true,now()),
('hoko-ji-hamamatsu','方広寺','ほうこうじ','temple','臨済宗方広寺派大本山','静岡県','浜松市','静岡県浜松市浜名区引佐町奥山1577-1',34.848472,137.613972,1371,'釈迦如来','http://www.houkouji.or.jp/','奥山半僧坊で知られる臨済宗方広寺派の大本山。五百羅漢が名物。','https://ja.wikipedia.org/wiki/方広寺_(浜松市)','Wikipedia',true,now()),
('daiju-ji','大樹寺','だいじゅじ','temple','浄土宗','愛知県','岡崎市','愛知県岡崎市鴨田町広元5-1',34.9844056,137.1653028,1475,'一光千体阿弥陀如来','https://daijuji.jp/','松平・徳川家の菩提寺。本堂から岡崎城を望む「ビスタライン」で有名。','https://ja.wikipedia.org/wiki/大樹寺','Wikipedia',true,now()),
('zaika-ji','財賀寺','ざいかじ','temple','高野山真言宗','愛知県','豊川市','愛知県豊川市財賀町観音山3',34.8747167,137.3568389,724,'千手観音（秘仏）','http://www.ccnet-ai.ne.jp/zaikaji/','行基開創と伝わる古刹。仁王門の金剛力士像(重文)で知られる。','https://ja.wikipedia.org/wiki/財賀寺','Wikipedia',true,now()),
('sanmyo-ji-toyokawa','三明寺','さんみょうじ','temple','曹洞宗','愛知県','豊川市','愛知県豊川市豊川町波通37',34.820944,137.399306,702,'千手観音','https://www.toyokawa-sanmyouji.com/','「豊川弁財天」として親しまれる。室町期の三重塔(重文)を有する。','https://ja.wikipedia.org/wiki/三明寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ6）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oppo-ji' and d.slug='dainichi_nyorai')
or (t.slug='hoko-ji-hamamatsu' and d.slug='shaka_nyorai')
or (t.slug='daiju-ji' and d.slug='amida_nyorai')
or (t.slug='zaika-ji' and d.slug='senju_kannon')
or (t.slug='sanmyo-ji-toyokawa' and d.slug='senju_kannon')
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ7: 岐阜・富山・静岡）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sakurayama-hachimangu','桜山八幡宮','さくらやまはちまんぐう','shrine','桜山八幡宮（県社）','岐阜県','高山市','岐阜県高山市桜町178',36.148194,137.260889,null,null,'http://www.sakurayamahachiman.jimdo.com/','高山祭(秋の八幡祭)の舞台。屋台会館を併設する高山の総鎮守。','https://ja.wikipedia.org/wiki/桜山八幡宮','Wikipedia',true,now()),
('tejikarao-jinja-kakamigahara','手力雄神社','てぢからおじんじゃ','shrine','手力雄神社（郷社）','岐阜県','各務原市','岐阜県各務原市那加手力町4',35.4086889,136.8219861,null,null,'https://www.tezikarao.org/','各務原の手力雄神社。勇壮な火祭りで知られる古社。','https://ja.wikipedia.org/wiki/手力雄神社_(各務原市)','Wikipedia',true,now()),
('zuisen-ji-nanto','瑞泉寺','ずいせんじ','temple','真宗大谷派','富山県','南砺市','富山県南砺市井波3050',36.5584861,136.9722000,1390,'阿弥陀如来','https://inamibetuin-zuisen-ji.amebaownd.com/','井波別院。井波彫刻発祥の地として名高い真宗大谷派の大寺。','https://ja.wikipedia.org/wiki/瑞泉寺_(南砺市)','Wikipedia',true,now()),
('shoko-ji-takaoka','勝興寺','しょうこうじ','temple','浄土真宗本願寺派','富山県','高岡市','富山県高岡市伏木古国府17-1',36.792348,137.052713,1471,'阿弥陀如来','https://www.shoukouji.jp/','越中国府跡に建つ浄土真宗の大伽藍。本堂・大広間が国宝。','https://ja.wikipedia.org/wiki/勝興寺','Wikipedia',true,now()),
('suyama-sengen-jinja','須山浅間神社','すやませんげんじんじゃ','shrine','須山浅間神社（村社）','静岡県','裾野市','静岡県裾野市須山柳沢722',35.254583,138.848944,110,null,null,'富士山須山口登山道の起点に鎮座。世界遺産富士山の構成資産。','https://ja.wikipedia.org/wiki/須山浅間神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ7）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sakurayama-hachimangu' and d.slug='hachiman')
or (t.slug='tejikarao-jinja-kakamigahara' and d.slug='amenotajikarao')
or (t.slug='zuisen-ji-nanto' and d.slug='amida_nyorai')
or (t.slug='shoko-ji-takaoka' and d.slug='amida_nyorai')
or (t.slug='suyama-sengen-jinja' and d.slug='konohanasakuya')
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='sakurayama-hachimangu' and d.slug in ('yamatotakeru','jingu_kogo'))
or (t.slug='suyama-sengen-jinja' and d.slug in ('ninigi','oyamatsumi'))
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ8: 岐阜・山梨）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hakusan-chukyo-jinja','白山中居神社','はくさんちゅうきょじんじゃ','shrine','白山中居神社（郷社）','岐阜県','郡上市','岐阜県郡上市白鳥町石徹白3-48',35.992083,136.768639,82,null,null,'石徹白(いとしろ)の白山信仰の中心。美濃禅定道の拠点となった古社。','https://ja.wikipedia.org/wiki/白山中居神社','Wikipedia',true,now()),
('hoko-ji-koshu','放光寺','ほうこうじ','temple','真言宗智山派','山梨県','甲州市','山梨県甲州市塩山藤木2438',35.734417,138.713667,1184,'金剛界大日如来','http://www.hokoji.org/','安田義定建立の真言宗寺院。平安期の仏像群(重文)で知られる。','https://ja.wikipedia.org/wiki/放光寺_(甲州市)','Wikipedia',true,now()),
('kawaguchi-asama-jinja','河口浅間神社','かわぐちあさまじんじゃ','shrine','河口浅間神社（県社）','山梨県','南都留郡富士河口湖町','山梨県南都留郡富士河口湖町河口1',35.531056,138.774944,865,null,null,'貞観の噴火を機に創建された名神大社論社。世界遺産富士山の構成資産。','https://ja.wikipedia.org/wiki/河口浅間神社','Wikipedia',true,now()),
('fuji-omuro-sengen-jinja','冨士御室浅間神社','ふじおむろせんげんじんじゃ','shrine','冨士御室浅間神社（県社）','山梨県','南都留郡富士河口湖町','山梨県南都留郡富士河口湖町勝山3951',35.5105972,138.7459944,699,null,'https://www.fujiomurosengenjinja.com/','富士山中最古と伝わる浅間社。世界遺産富士山の構成資産。','https://ja.wikipedia.org/wiki/冨士御室浅間神社','Wikipedia',true,now()),
('jiun-ji-koshu','慈雲寺','じうんじ','temple','臨済宗妙心寺派','山梨県','甲州市','山梨県甲州市塩山中萩原3528',35.718417,138.756139,1338,'聖観世音菩薩','http://www.sky.hi-ho.ne.jp/jiunji/','樋口一葉の両親ゆかりの寺。イトザクラの名所として知られる。','https://ja.wikipedia.org/wiki/慈雲寺_(甲州市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ8）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hakusan-chukyo-jinja' and d.slug in ('kukurihime','izanagi','izanami'))
or (t.slug='hoko-ji-koshu' and d.slug='dainichi_nyorai')
or (t.slug='kawaguchi-asama-jinja' and d.slug='konohanasakuya')
or (t.slug='fuji-omuro-sengen-jinja' and d.slug='konohanasakuya')
or (t.slug='jiun-ji-koshu' and d.slug='sho_kannon')
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ9: 長野）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daiho-ji-aoki','大法寺','だいほうじ','temple','天台宗','長野県','小県郡青木村','長野県小県郡青木村当郷2052',36.381389,138.148889,701,'釈迦如来','https://www.daihoujitemple.com/','「見返りの塔」と称される国宝三重塔で名高い天台宗の古刹。','https://ja.wikipedia.org/wiki/大法寺','Wikipedia',true,now()),
('tsugane-ji','津金寺','つがねじ','temple','天台宗','長野県','北佐久郡立科町','長野県北佐久郡立科町山部279',36.277056,138.306528,702,'聖観音','https://tuganeji.com/','行基開創と伝わる天台談義所。佐久三十三観音の札所。','https://ja.wikipedia.org/wiki/津金寺','Wikipedia',true,now()),
('zensan-ji','前山寺','ぜんさんじ','temple','真言宗智山派','長野県','上田市','長野県上田市前山300',36.341139,138.197444,812,'大日如来','https://www.zensanji.info/','「未完成の完成塔」と呼ばれる三重塔(重文)を有する塩田平の古刹。','https://ja.wikipedia.org/wiki/前山寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ9）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daiho-ji-aoki' and d.slug='shaka_nyorai')
or (t.slug='tsugane-ji' and d.slug='sho_kannon')
or (t.slug='zensan-ji' and d.slug='dainichi_nyorai')
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺（バッチ10: 福井・新潟）
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takidani-ji-mikuni','瀧谷寺','たきだんじ','temple','真言宗智山派','福井県','坂井市','福井県坂井市三国町滝谷1-7-15',36.221889,136.146111,1377,'薬師如来','http://www.takidanji.or.jp/','三国湊の名刹。庭園・国宝金銅毛彫宝相華文磬で知られる真言寺院。','https://ja.wikipedia.org/wiki/瀧谷寺','Wikipedia',true,now()),
('mikuni-jinja','三國神社','みくにじんじゃ','shrine','三國神社（県社）','福井県','坂井市','福井県坂井市三国町山王6-2-80',36.2090472,136.1578194,1564,null,'http://www.mikunijinja.jp/','三国湊の総鎮守。日本三大祭の一つ三国祭で知られる。','https://ja.wikipedia.org/wiki/三國神社','Wikipedia',true,now()),
('shugetsu-ji','種月寺','しゅげつじ','temple','曹洞宗','新潟県','新潟市','新潟県新潟市西蒲区石瀬3356',37.72722,138.83472,1446,'釈迦牟尼仏','https://shugetsuji.com/','越後四ヶ道場の一。江戸期の本堂(重文)を有する曹洞宗の古刹。','https://ja.wikipedia.org/wiki/種月寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ10）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takidani-ji-mikuni' and d.slug='yakushi_nyorai')
or (t.slug='mikuni-jinja' and d.slug in ('oyamakui','keitai_tenno'))
or (t.slug='shugetsu-ji' and d.slug='shaka_nyorai')
on conflict do nothing;
