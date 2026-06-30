-- ============================================================
-- w10-chugoku-shikoku.sql
-- 担当: 中国・四国 9県 (鳥取/島根/岡山/広島/山口/徳島/香川/愛媛/高知)
-- ja.wikipedia.org の infobox 十進座標で裏取り。座標なしは除外。
-- _have_chugoku-shikoku.txt と重複しないものを収録。
-- 5件ごとに逐次保存。
-- ============================================================

-- ① 新規神仏 ------------------------------------------------
-- (batch1: 既存神仏のみ使用、新規なし)

-- ③ 社寺 ----------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fukuzenji-tomonoura','福禅寺','ふくぜんじ','temple','真言宗大覚寺派','広島県','福山市','広島県福山市鞆町鞆2',34.383078,133.383361,950,'千手観音',null,'鞆の浦の対潮楼で知られる名刹。朝鮮通信使も賞讃した瀬戸内の景勝。','https://ja.wikipedia.org/wiki/福禅寺_(福山市)','Wikipedia',true,now()),
('kozaiji-takamatsu','香西寺','こうざいじ','temple','真言宗大覚寺派','香川県','高松市','香川県高松市香西西町211',34.347417,133.993972,739,'延命地蔵菩薩',null,'四国別格二十霊場第19番。平安期の木造毘沙門天立像が国重文。','https://ja.wikipedia.org/wiki/香西寺','Wikipedia',true,now()),
('shusshakaji','出釈迦寺','しゅっしゃかじ','temple','真言宗御室派','香川県','善通寺市','香川県善通寺市吉原町1091',34.219389,133.750280,null,'釈迦如来',null,'四国八十八ヶ所第73番札所。空海捨身ヶ嶽の伝承で知られる。','https://ja.wikipedia.org/wiki/出釈迦寺','Wikipedia',true,now()),
('mandaraji-zentsuji','曼荼羅寺','まんだらじ','temple','真言宗善通寺派','香川県','善通寺市','香川県善通寺市吉原町1380-1',34.223306,133.750219,596,'大日如来',null,'四国八十八ヶ所第72番札所。佐伯氏の氏寺を空海が改号した古刹。','https://ja.wikipedia.org/wiki/曼荼羅寺_(善通寺市)','Wikipedia',true,now()),
('koyamaji-zentsuji','甲山寺','こうやまじ','temple','真言宗善通寺派','香川県','善通寺市','香川県善通寺市弘田町1765-1',34.233194,133.765764,821,'薬師如来',null,'四国八十八ヶ所第74番札所。空海が満濃池修築の際に建立したと伝わる。','https://ja.wikipedia.org/wiki/甲山寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け ------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fukuzenji-tomonoura' and d.slug in ('senju_kannon'))
   or (t.slug='kozaiji-takamatsu' and d.slug in ('jizo_bosatsu'))
   or (t.slug='shusshakaji' and d.slug in ('shaka_nyorai'))
   or (t.slug='mandaraji-zentsuji' and d.slug in ('dainichi_nyorai'))
   or (t.slug='koyamaji-zentsuji' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- === batch2 ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ryufukuji-yamaguchi','龍福寺','りゅうふくじ','temple','曹洞宗','山口県','山口市','山口県山口市大殿大路119',34.184444,131.479833,1206,'釈迦如来',null,'大内義隆の菩提寺。大内氏館跡に建つ曹洞宗の名刹。','https://ja.wikipedia.org/wiki/龍福寺_(山口市)','Wikipedia',true,now()),
('daikoji-mitoyo','大興寺','だいこうじ','temple','真言宗善通寺派','香川県','三豊市','香川県三豊市山本町辻4209',34.102194,133.719170,822,'薬師如来',null,'四国八十八ヶ所第67番札所。小松尾山と号す。','https://ja.wikipedia.org/wiki/大興寺_(三豊市)','Wikipedia',true,now()),
('jinnein-kanonji','神恵院','じんねいん','temple','真言宗大覚寺派','香川県','観音寺市','香川県観音寺市八幡町1-2-7',34.133986,133.647333,703,'阿弥陀如来',null,'四国八十八ヶ所第68番札所。観音寺と同一境内に並ぶ珍しい札所。','https://ja.wikipedia.org/wiki/神恵院','Wikipedia',true,now()),
('doryuji-tadotsu','道隆寺','どうりゅうじ','temple','真言宗醍醐派','香川県','仲多度郡多度津町','香川県仲多度郡多度津町北鴨1-3-30',34.276750,133.762694,749,'薬師如来',null,'四国八十八ヶ所第77番札所。眼病平癒の信仰で知られる。','https://ja.wikipedia.org/wiki/道隆寺','Wikipedia',true,now()),
('tennoji-sakaide','天皇寺','てんのうじ','temple','真言宗御室派','香川県','坂出市','香川県坂出市西庄町八十場1713-2',34.311472,133.882861,810,'十一面観音',null,'四国八十八ヶ所第79番札所。崇徳上皇ゆかりの白峰宮に隣接。','https://ja.wikipedia.org/wiki/天皇寺_(坂出市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ryufukuji-yamaguchi' and d.slug in ('shaka_nyorai'))
   or (t.slug='daikoji-mitoyo' and d.slug in ('yakushi_nyorai'))
   or (t.slug='jinnein-kanonji' and d.slug in ('amida_nyorai'))
   or (t.slug='doryuji-tadotsu' and d.slug in ('yakushi_nyorai'))
   or (t.slug='tennoji-sakaide' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- === batch3 ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ichinomiyaji-takamatsu','一宮寺','いちのみやじ','temple','真言宗御室派','香川県','高松市','香川県高松市一宮町宮西607',34.286611,134.026583,701,'聖観音',null,'四国八十八ヶ所第83番札所。讃岐一宮田村神社の別当寺であった。','https://ja.wikipedia.org/wiki/一宮寺','Wikipedia',true,now()),
('enmeiji-imabari','延命寺','えんめいじ','temple','真言宗豊山派','愛媛県','今治市','愛媛県今治市阿方甲636',34.066833,132.964000,720,'不動明王',null,'四国八十八ヶ所第54番札所。近見山と号す。','https://ja.wikipedia.org/wiki/延命寺_(今治市)','Wikipedia',true,now()),
('taisanji-imabari','泰山寺','たいさんじ','temple','真言宗醍醐派','愛媛県','今治市','愛媛県今治市小泉1-9-18',34.050111,132.974583,815,'地蔵菩薩',null,'四国八十八ヶ所第56番札所。白い漆喰塀で知られる。','https://ja.wikipedia.org/wiki/泰山寺','Wikipedia',true,now()),
('senryuji-shikokuchuo','仙龍寺','せんりゅうじ','temple','真言宗醍醐派','愛媛県','四国中央市','愛媛県四国中央市新宮町馬立1200',33.950667,133.606258,815,'弘法大師',null,'四国別格二十霊場第13番。三角寺奥の院。厄除け・虫除け大師。','https://ja.wikipedia.org/wiki/仙龍寺','Wikipedia',true,now()),
('jofukuji-tsubakido','常福寺(椿堂)','じょうふくじ','temple','高野山真言宗','愛媛県','四国中央市','愛媛県四国中央市川滝町下山1894',33.989828,133.635075,815,'延命地蔵菩薩・不動明王',null,'椿堂の名で知られる四国別格二十霊場第14番。','https://ja.wikipedia.org/wiki/常福寺_(四国中央市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ichinomiyaji-takamatsu' and d.slug in ('sho_kannon'))
   or (t.slug='enmeiji-imabari' and d.slug in ('fudo_myoo'))
   or (t.slug='taisanji-imabari' and d.slug in ('jizo_bosatsu'))
   or (t.slug='senryuji-shikokuchuo' and d.slug in ('kobo_daishi'))
   or (t.slug='jofukuji-tsubakido' and d.slug in ('jizo_bosatsu','fudo_myoo'))
on conflict do nothing;

-- === batch4 ===
-- 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nihotsuhime','爾保都比売神','にほつひめのかみ','kami','国津神','{}','史実','丹生(辰砂)・水の女神。安芸の地名「仁保」の由来。','https://ja.wikipedia.org/wiki/邇保姫神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nihotsuhime' and g.slug in ('kaiun','byoki_heyu','kanai_anzen'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('anumi-jinja-misake','阿沼美神社','あぬみじんじゃ','shrine','阿沼美神社','愛媛県','松山市','愛媛県松山市味酒町3-1-1',33.846028,132.756390,664,null,null,'松山城下の式内社。味酒の地に鎮座し大山積命を祀る。','https://ja.wikipedia.org/wiki/阿沼美神社','Wikipedia',true,now()),
('susanoo-jinja-fukuyama','素盞嗚神社','すさのおじんじゃ','shrine','素盞嗚神社','広島県','福山市','広島県福山市新市町戸手1-1',34.552667,133.279333,679,null,null,'蘇民将来伝承と祇園信仰の発祥に関わる備後の古社。','https://ja.wikipedia.org/wiki/素盞嗚神社_(福山市)','Wikipedia',true,now()),
('onaga-tenmangu','尾長天満宮','おながてんまんぐう','shrine','尾長天満宮','広島県','広島市','広島県広島市東区山根町33-16',34.404361,132.480028,901,null,null,'菅原道真が立ち寄った尾長山麓に建つ天満宮。広島の学問の神。','https://ja.wikipedia.org/wiki/尾長天満宮','Wikipedia',true,now()),
('nihohime-jinja','邇保姫神社','にほひめじんじゃ','shrine','邇保姫神社','広島県','広島市','広島県広島市南区西本浦町12-13',34.376083,132.487306,null,null,null,'神功皇后が爾保都比売神を鎮祭したと伝わる安芸の古社。','https://ja.wikipedia.org/wiki/邇保姫神社','Wikipedia',true,now()),
('fukujoji-higashihiroshima','福成寺','ふくじょうじ','temple','真言宗御室派','広島県','東広島市','広島県東広島市西条町下三永3641',34.378060,132.775000,726,'千手観音',null,'奈良期創建の古刹。大内氏寄進の宮殿が国重文。','https://ja.wikipedia.org/wiki/福成寺_(東広島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='anumi-jinja-misake' and d.slug in ('oyamatsumi','takaokami','ikazuchi'))
   or (t.slug='susanoo-jinja-fukuyama' and d.slug in ('susanoo'))
   or (t.slug='onaga-tenmangu' and d.slug in ('michizane'))
   or (t.slug='nihohime-jinja' and d.slug in ('nihotsuhime'))
   or (t.slug='fukujoji-higashihiroshima' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- === batch5 ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('konomineji-yasuda','神峯寺','こうのみねじ','temple','真言宗豊山派','高知県','安芸郡安田町','高知県安芸郡安田町唐浜2594',33.467611,133.974778,730,'十一面観音',null,'四国八十八ヶ所第27番札所。難所として知られる山岳霊場。','https://ja.wikipedia.org/wiki/神峯寺','Wikipedia',true,now()),
('byodoji-anan','平等寺','びょうどうじ','temple','高野山真言宗','徳島県','阿南市','徳島県阿南市新野町秋山177',33.851833,134.582780,814,'薬師如来',null,'四国八十八ヶ所第22番札所。白水山と号す。','https://ja.wikipedia.org/wiki/平等寺_(阿南市)','Wikipedia',true,now()),
('maniji-tottori','摩尼寺','まにじ','temple','天台宗','鳥取県','鳥取市','鳥取県鳥取市覚寺624',35.529944,134.263222,834,'帝釈天',null,'摩尼山に建つ天台の古刹。帝釈天降臨の伝承で知られる。','https://ja.wikipedia.org/wiki/摩尼寺','Wikipedia',true,now()),
('kozenji-tottori','興禅寺','こうぜんじ','temple','黄檗宗','鳥取県','鳥取市','鳥取県鳥取市栗谷町10',35.504408,134.241408,1632,null,null,'鳥取藩主池田家の菩提寺。','https://ja.wikipedia.org/wiki/興禅寺_(鳥取市)','Wikipedia',true,now()),
('henjoin-kurashiki','遍照院','へんじょういん','temple','真言宗御室派','岡山県','倉敷市','岡山県倉敷市西阿知町464',34.592417,133.735806,985,'十一面観音',null,'室町期の三重塔(国重文)で知られる厄除けの寺。','https://ja.wikipedia.org/wiki/遍照院_(倉敷市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='konomineji-yasuda' and d.slug in ('juichimen_kannon'))
   or (t.slug='byodoji-anan' and d.slug in ('yakushi_nyorai'))
   or (t.slug='maniji-tottori' and d.slug in ('taishakuten'))
   or (t.slug='henjoin-kurashiki' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- === batch6 ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('enkoji-sukumo','延光寺','えんこうじ','temple','真言宗智山派','高知県','宿毛市','高知県宿毛市平田町中山390',32.961306,132.774056,724,'薬師如来',null,'四国八十八ヶ所第39番札所。赤亀山と号し、銅の梵鐘伝説で知られる。','https://ja.wikipedia.org/wiki/延光寺','Wikipedia',true,now()),
('kumadaniji-awa','熊谷寺','くまだにじ','temple','高野山真言宗','徳島県','阿波市','徳島県阿波市土成町土成字前田185',34.122758,134.340039,815,'千手観音',null,'四国八十八ヶ所第8番札所。壮麗な二王門で知られる。','https://ja.wikipedia.org/wiki/熊谷寺_(徳島県)','Wikipedia',true,now()),
('kiyotakiji-tosa','清瀧寺','きよたきじ','temple','真言宗豊山派','高知県','土佐市','高知県土佐市高岡町丁568-1',33.512500,133.409500,723,'薬師如来',null,'四国八十八ヶ所第35番札所。厄除け薬師の巨像で知られる。','https://ja.wikipedia.org/wiki/清瀧寺_(土佐市)','Wikipedia',true,now()),
('fujiidera-yoshinogawa','藤井寺','ふじいでら','temple','臨済宗妙心寺派','徳島県','吉野川市','徳島県吉野川市鴨島町飯尾1525',34.051670,134.348500,815,'薬師如来',null,'四国八十八ヶ所第11番札所。「寺」を「てら」と読む唯一の札所。','https://ja.wikipedia.org/wiki/藤井寺_(吉野川市)','Wikipedia',true,now()),
('jurakuji-awa','十楽寺','じゅうらくじ','temple','高野山真言宗','徳島県','阿波市','徳島県阿波市土成町高尾字法教田58',34.120750,134.377925,806,'阿弥陀如来',null,'四国八十八ヶ所第7番札所。光明山十楽寺と号す。','https://ja.wikipedia.org/wiki/十楽寺_(阿波市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='enkoji-sukumo' and d.slug in ('yakushi_nyorai'))
   or (t.slug='kumadaniji-awa' and d.slug in ('senju_kannon'))
   or (t.slug='kiyotakiji-tosa' and d.slug in ('yakushi_nyorai'))
   or (t.slug='fujiidera-yoshinogawa' and d.slug in ('yakushi_nyorai'))
   or (t.slug='jurakuji-awa' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- === batch7 ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('horinji-awa','法輪寺','ほうりんじ','temple','高野山真言宗','徳島県','阿波市','徳島県阿波市土成町土成字田中198-2',34.104378,134.333814,815,'釈迦如来(涅槃像)',null,'四国八十八ヶ所第9番札所。涅槃釈迦像を本尊とする珍しい札所。','https://ja.wikipedia.org/wiki/法輪寺_(阿波市)','Wikipedia',true,now()),
('nishiyama-koryuji','西山興隆寺','にしやまこうりゅうじ','temple','真言宗醍醐派','愛媛県','西条市','愛媛県西条市丹原町古田1657',33.905667,133.025333,642,'千手観音',null,'紅葉の名所として知られる古刹。本堂は国宝。','https://ja.wikipedia.org/wiki/西山興隆寺','Wikipedia',true,now()),
('dogakuji-ishii','童学寺','どうがくじ','temple','真言宗善通寺派','徳島県','名西郡石井町','徳島県名西郡石井町城ノ内605',34.058583,134.427694,null,'薬師如来',null,'空海が幼少期に学んだと伝わる学業成就の寺。','https://ja.wikipedia.org/wiki/童学寺','Wikipedia',true,now()),
('otakiji-mima','大瀧寺','おおたきじ','temple','真言宗御室派','徳島県','美馬市','徳島県美馬市脇町西大谷674',34.121903,134.127131,726,'西照大権現',null,'四国別格二十霊場第20番。標高約910mの最高所霊場。','https://ja.wikipedia.org/wiki/大瀧寺','Wikipedia',true,now()),
('jigenji-kamikatsu','慈眼寺','じげんじ','temple','高野山真言宗','徳島県','勝浦郡上勝町','徳島県勝浦郡上勝町正木',33.940203,134.430744,782,'十一面観音',null,'四国別格三番。穴禅定の修行で知られる鍾乳洞の霊場。','https://ja.wikipedia.org/wiki/慈眼寺_(徳島県上勝町)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='horinji-awa' and d.slug in ('shaka_nyorai'))
   or (t.slug='nishiyama-koryuji' and d.slug in ('senju_kannon'))
   or (t.slug='dogakuji-ishii' and d.slug in ('yakushi_nyorai'))
   or (t.slug='jigenji-kamikatsu' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- === batch8 ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanjizaiji-ainan','観自在寺','かんじざいじ','temple','真言宗大覚寺派','愛媛県','南宇和郡愛南町','愛媛県南宇和郡愛南町御荘平城2253-1',32.964611,132.564056,807,'薬師如来',null,'四国八十八ヶ所第40番札所。一番霊山寺から最も遠く「四国霊場の裏関所」と称される。','https://ja.wikipedia.org/wiki/観自在寺','Wikipedia',true,now()),
('ryukoji-uwajima','龍光寺','りゅうこうじ','temple','真言宗御室派','愛媛県','宇和島市','愛媛県宇和島市三間町戸雁173',33.295194,132.598500,807,'十一面観音',null,'四国八十八ヶ所第41番札所。稲荷信仰と習合した三間のお稲荷さん。','https://ja.wikipedia.org/wiki/龍光寺_(宇和島市)','Wikipedia',true,now()),
('butsumokuji-uwajima','仏木寺','ぶつもくじ','temple','真言宗御室派','愛媛県','宇和島市','愛媛県宇和島市三間町則1683',33.310583,132.581472,807,'大日如来',null,'四国八十八ヶ所第42番札所。家畜の守り仏として信仰される。','https://ja.wikipedia.org/wiki/仏木寺','Wikipedia',true,now()),
('meisekiji-seiyo','明石寺','めいせきじ','temple','天台寺門宗','愛媛県','西予市','愛媛県西予市宇和町明石205',33.369222,132.518972,550,'千手観音',null,'四国八十八ヶ所第43番札所。白王権現の伝説を伝える古刹。','https://ja.wikipedia.org/wiki/明石寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanjizaiji-ainan' and d.slug in ('yakushi_nyorai'))
   or (t.slug='ryukoji-uwajima' and d.slug in ('juichimen_kannon'))
   or (t.slug='butsumokuji-uwajima' and d.slug in ('dainichi_nyorai'))
   or (t.slug='meisekiji-seiyo' and d.slug in ('senju_kannon'))
on conflict do nothing;
