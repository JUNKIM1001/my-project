-- 御朱印ナビ 社寺データ：中国・四国地方（2巡目 / 次のティア）
-- 担当県: 鳥取・島根・岡山・広島・山口・徳島・香川・愛媛・高知
-- 全件 ja.wikipedia.org の infobox で裏取り（住所・十進座標・御祭神/本尊・創建・公式URL）。
-- 座標が infobox に無い社寺は不採用。
-- 1巡目（chugoku-shikoku.sql）収録分とは重複させない。
--   既出例: izumo-taisha, itsukushima-jinja, kotohira-gu, hakuto-jinja, mitokusan-sanbutsuji,
--   kumano-taisha-shimane, miho-jinja, yaegaki-jinja, susa-jinja-izumo, kibitsu-jinja(備中),
--   saijo-inari, yugasan-jinja-honguu, daishoin-miyajima, hofu-tenmangu, rurikoji,
--   oasahiko-jinja, ryozenji, unpenji, zentsuji, oyamazumi-jinja, ishizuchi-jinja,
--   tosa-jinja, chikurinji-kochi, hotsumisakiji, shitori-jinja-yurihama 等。
-- 仕様書 ①〜④ の順で追記。temple_shrine_goriyaku は親側で導出するため作成しない。

-- ============================================================
-- ① 新規神仏（既存に無いものだけ）
-- ============================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sada_okami','佐太御子大神','さだみこのおおかみ','kami','国津神','{猿田彦大神}','記紀','佐太神社の主祭神。導きの神・猿田彦大神と同一視される。','https://ja.wikipedia.org/wiki/佐太神社','Wikipedia',true,now()),
('kushiakarutama','櫛明玉命','くしあかるたまのみこと','kami','国津神','{玉祖神}','記紀','玉造の祖神。勾玉づくりの神で、玉作湯神社に祀られる。','https://ja.wikipedia.org/wiki/玉作湯神社','Wikipedia',true,now()),
('tamawakasu','玉若酢命','たまわかすのみこと','kami','国津神','{}','記紀','隠岐国の総社・玉若酢命神社の主祭神。隠岐開拓の神。','https://ja.wikipedia.org/wiki/玉若酢命神社','Wikipedia',true,now()),
('kagamitsukuri','鏡作神','かがみつくりのかみ','kami','天津神','{石凝姥命}','記紀','鏡造りの祖神。美作国一宮・中山神社の主祭神。','https://ja.wikipedia.org/wiki/中山神社','Wikipedia',true,now()),
('kurozumi_munetada','黒住宗忠','くろずみむねただ','kami','人物神','{宗忠大神}','史実','黒住教の教祖。宗忠神社に教祖宗忠大神として祀られる。','https://ja.wikipedia.org/wiki/黒住宗忠','Wikipedia',true,now()),
('daitsuchisho_nyorai','大通智勝如来','だいつうちしょうにょらい','buddha','如来','{}','法華経','法華経に説かれる過去仏。四国霊場では南光坊のみが本尊とする。','https://ja.wikipedia.org/wiki/南光坊','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ② 新規神仏の司るご利益（30種から選択）
-- ============================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sada_okami' and g.slug in ('kotsu_anzen','kaiun','majo_kekkai'))
or (d.slug='kushiakarutama' and g.slug in ('shobai','kaiun','enmusubi'))
or (d.slug='tamawakasu' and g.slug in ('kaiun','choju','kanai_anzen'))
or (d.slug='kagamitsukuri' and g.slug in ('shobai','kaiun','bigan'))
or (d.slug='kurozumi_munetada' and g.slug in ('byoki_heyu','kaiun','yakubarai'))
or (d.slug='daitsuchisho_nyorai' and g.slug in ('gakugyo','kaiun','jouju'))
on conflict do nothing;

-- ============================================================
-- ③ 社寺
-- ============================================================
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- 鳥取県
('akaiiwa-jinja','赤猪岩神社','あかいいわじんじゃ','shrine','旧村社','鳥取県','南部町','鳥取県西伯郡南部町寺内232',35.365278,133.349250,null,null,null,'大国主が兄神に焼石で殺されたと伝わる再生神話の地。','https://ja.wikipedia.org/wiki/赤猪岩神社','Wikipedia',true,now()),
-- 島根県
('kamosu-jinja','神魂神社','かもすじんじゃ','shrine','旧県社','島根県','松江市','島根県松江市大庭町563',35.425528,133.084306,null,null,null,'現存最古の大社造本殿（国宝）で知られる。出雲国造ゆかりの古社。','https://ja.wikipedia.org/wiki/神魂神社','Wikipedia',true,now()),
('sada-jinja','佐太神社','さだじんじゃ','shrine','旧国幣小社','島根県','松江市','島根県松江市鹿島町佐陀宮内73',35.508917,133.006444,null,null,'http://sadajinjya.jp/','出雲国二宮。三殿並立の本殿と佐陀神能（ユネスコ無形遺産）で知られる。','https://ja.wikipedia.org/wiki/佐太神社','Wikipedia',true,now()),
('tamatsukuriyu-jinja','玉作湯神社','たまつくりゆじんじゃ','shrine','旧県社','島根県','松江市','島根県松江市玉湯町玉造508',35.413667,133.011750,null,null,null,'玉造温泉に鎮座。勾玉づくりの祖神を祀り、願い石で名高い。','https://ja.wikipedia.org/wiki/玉作湯神社','Wikipedia',true,now()),
('tamawakasumikoto-jinja','玉若酢命神社','たまわかすみことじんじゃ','shrine','旧郷社','島根県','隠岐の島町','島根県隠岐郡隠岐の島町下西701',36.207111,133.312694,null,null,null,'隠岐国の総社。八百杉と随神門・本殿が重要文化財。','https://ja.wikipedia.org/wiki/玉若酢命神社','Wikipedia',true,now()),
('washibara-hachimangu','鷲原八幡宮','わしばらはちまんぐう','shrine','旧郷社','島根県','津和野町','島根県鹿足郡津和野町鷲原イ632',34.460389,131.768472,950,null,null,'津和野三大社の一。流鏑馬馬場が県史跡で日本遺産構成文化財。','https://ja.wikipedia.org/wiki/鷲原八幡宮','Wikipedia',true,now()),
-- 岡山県
('nakayama-jinja-tsuyama','中山神社','なかやまじんじゃ','shrine','美作国一宮（旧国幣中社）','岡山県','津山市','岡山県津山市一宮695',35.100194,133.994583,707,null,null,'美作国一宮。鏡作神を祀り、中山造の本殿は重要文化財。','https://ja.wikipedia.org/wiki/中山神社','Wikipedia',true,now()),
('munetada-jinja-okayama','宗忠神社','むねただじんじゃ','shrine','旧県社','岡山県','岡山市','岡山県岡山市北区上中野1-3-10',34.645280,133.901670,1885,null,'http://www.munetada.jp/','黒住教教祖・黒住宗忠を祀る大元の社。','https://ja.wikipedia.org/wiki/宗忠神社','Wikipedia',true,now()),
-- 広島県
('senkoji-onomichi','千光寺','せんこうじ','temple','真言宗系単立','広島県','尾道市','広島県尾道市東土堂町15-1',34.410925,133.198783,806,'千手観音','http://www.senkouji.jp/','千光寺山の中腹に建ち、尾道と瀬戸内を一望する古刹。','https://ja.wikipedia.org/wiki/千光寺_(尾道市)','Wikipedia',true,now()),
('jodoji-onomichi','浄土寺','じょうどじ','temple','真言宗泉涌寺派','広島県','尾道市','広島県尾道市東久保町20-28',34.412167,133.210306,616,'十一面観音','http://www.ermjp.com/j/temple/','聖徳太子開基と伝わる尾道の名刹。本堂・多宝塔が国宝。','https://ja.wikipedia.org/wiki/浄土寺_(尾道市)','Wikipedia',true,now()),
('fudoin-hiroshima','不動院','ふどういん','temple','真言宗別格本山','広島県','広島市','広島県広島市東区牛田新町3-4-9',34.427028,132.471111,null,'薬師如来',null,'安国寺の遺構。原爆に耐えた国宝の金堂で知られる。','https://ja.wikipedia.org/wiki/不動院_(広島市)','Wikipedia',true,now()),
-- 山口県
('kozanji','功山寺','こうざんじ','temple','曹洞宗','山口県','下関市','山口県下関市長府川端一丁目2-3',33.995889,130.981917,1327,'千手観音菩薩','http://kouzanji.org/','国宝の禅宗様仏殿で知られる。高杉晋作挙兵の地。','https://ja.wikipedia.org/wiki/功山寺','Wikipedia',true,now()),
('tokoji-hagi','東光寺','とうこうじ','temple','黄檗宗','山口県','萩市','山口県萩市椿東椎原1647',34.412528,131.426056,1691,'釈迦如来','https://www.toukouji.net/','毛利家の菩提寺。黄檗様式の伽藍と藩主墓所で知られる。','https://ja.wikipedia.org/wiki/東光寺_(萩市)','Wikipedia',true,now()),
('kameyama-hachimangu-shimonoseki','亀山八幡宮','かめやまはちまんぐう','shrine','旧県社','山口県','下関市','山口県下関市中之町1-1',33.957417,130.945000,859,null,'http://www.kameyamagu.com','関門海峡を見下ろす下関の総鎮守。','https://ja.wikipedia.org/wiki/亀山八幡宮_(下関市)','Wikipedia',true,now()),
('imahachimangu-yamaguchi','今八幡宮','いまはちまんぐう','shrine','旧県社','山口県','山口市','山口県山口市上宇野令828-1',34.187292,131.481431,null,null,null,'山口の総鎮守。本殿・拝殿・楼門が重要文化財。','https://ja.wikipedia.org/wiki/今八幡宮','Wikipedia',true,now()),
('iminomiya-jinja','忌宮神社','いみのみやじんじゃ','shrine','長門国二宮（旧県社）','山口県','下関市','山口県下関市長府宮の内町1-18',33.998972,130.987556,199,null,'http://www.iminomiya-jinjya.com/','仲哀天皇の行宮跡と伝わる長門二宮。奇祭・数方庭祭で知られる。','https://ja.wikipedia.org/wiki/忌宮神社','Wikipedia',true,now()),
-- 徳島県
('gokurakuji-naruto','極楽寺','ごくらくじ','temple','高野山真言宗','徳島県','鳴門市','徳島県鳴門市大麻町檜段の上12',34.155650,134.490347,null,'阿弥陀如来','https://www.ca.pikara.ne.jp/gokurakuji/','四国八十八ヶ所第2番札所。安産祈願の寺。','https://ja.wikipedia.org/wiki/極楽寺_(鳴門市)','Wikipedia',true,now()),
('shosanji','焼山寺','しょうさんじ','temple','高野山真言宗','徳島県','神山町','徳島県名西郡神山町下分中318',33.985028,134.310250,815,'虚空蔵菩薩',null,'標高約700mの第12番札所。遍路の難所として名高い。','https://ja.wikipedia.org/wiki/焼山寺','Wikipedia',true,now()),
('dainichiji-tokushima','大日寺','だいにちじ','temple','真言宗大覚寺派','徳島県','徳島市','徳島県徳島市一宮町西丁263',34.038100,134.462700,815,'十一面観音','http://dai13.jp/','一宮神社の別当寺であった第13番札所。','https://ja.wikipedia.org/wiki/大日寺_(徳島市)','Wikipedia',true,now()),
('kakurinji-katsuura','鶴林寺','かくりんじ','temple','高野山真言宗','徳島県','勝浦町','徳島県勝浦郡勝浦町生名鷲ヶ尾14',33.913861,134.505611,798,'地蔵菩薩',null,'標高約470mの第20番札所。「お鶴さん」と親しまれる難所。','https://ja.wikipedia.org/wiki/鶴林寺_(徳島県)','Wikipedia',true,now()),
('tairyuji','太龍寺','たいりゅうじ','temple','高野山真言宗','徳島県','阿南市','徳島県阿南市加茂町龍山2',33.882528,134.521889,793,'虚空蔵菩薩','https://www.88shikokuhenro.jp/21tairyuji/','「西の高野」と称される第21番札所。空海修行の地。','https://ja.wikipedia.org/wiki/太龍寺','Wikipedia',true,now()),
-- 香川県
('yakuriji','八栗寺','やくりじ','temple','真言宗大覚寺派','香川県','高松市','香川県高松市牟礼町牟礼3416',34.359889,134.139528,829,'聖観音','https://yakuriji.jp/','五剣山に建つ第85番札所。聖天信仰で知られる。','https://ja.wikipedia.org/wiki/八栗寺','Wikipedia',true,now()),
('shidoji','志度寺','しどじ','temple','真言宗善通寺派','香川県','さぬき市','香川県さぬき市志度1102',34.324306,134.179639,626,'十一面観音','https://shidoji.or.jp/','海女の玉取り伝説で名高い第86番札所。','https://ja.wikipedia.org/wiki/志度寺','Wikipedia',true,now()),
('okuboji','大窪寺','おおくぼじ','temple','真言宗系単立','香川県','さぬき市','香川県さぬき市多和兼割96',34.191417,134.206750,717,'薬師如来',null,'結願所として知られる第88番札所。','https://ja.wikipedia.org/wiki/大窪寺','Wikipedia',true,now()),
('nagaoji','長尾寺','ながおじ','temple','天台宗','香川県','さぬき市','香川県さぬき市長尾西653',34.266706,134.171719,739,'聖観音','https://www.nagaoji.com/','行基開基と伝わる第87番札所。日本三大門の山門。','https://ja.wikipedia.org/wiki/長尾寺','Wikipedia',true,now()),
('negoroji','根香寺','ねごろじ','temple','天台宗系単立','香川県','高松市','香川県高松市中山町1506',34.344500,133.960560,null,'千手観音','http://www1.plala.or.jp/negoro/','青峰に建つ紅葉の名所、第82番札所。牛鬼伝説で知られる。','https://ja.wikipedia.org/wiki/根香寺','Wikipedia',true,now()),
('iyadaniji','弥谷寺','いやだにじ','temple','真言宗善通寺派','香川県','三豊市','香川県三豊市三野町大見乙70',34.229720,133.724261,null,'千手観音','https://iyadanizi.xsrv.jp/','弥谷山に建つ第71番札所。岩壁の磨崖仏と石段で知られる。','https://ja.wikipedia.org/wiki/弥谷寺','Wikipedia',true,now()),
-- 愛媛県
('yokomineji','横峰寺','よこみねじ','temple','真言宗御室派','愛媛県','西条市','愛媛県西条市小松町石鎚甲2253',33.837861,133.111139,651,'大日如来','https://www.88shikokuhenro.jp/60yokomineji/','標高約750mの第60番札所。伊予最高所の遍路の難所。','https://ja.wikipedia.org/wiki/横峰寺','Wikipedia',true,now()),
('hantaji','繁多寺','はんたじ','temple','真言宗豊山派','愛媛県','松山市','愛媛県松山市畑寺町32',33.828139,132.804556,749,'薬師如来',null,'松山城と瀬戸内を望む高台に建つ第50番札所。','https://ja.wikipedia.org/wiki/繁多寺','Wikipedia',true,now()),
('joruriji-matsuyama','浄瑠璃寺','じょうるりじ','temple','真言宗豊山派','愛媛県','松山市','愛媛県松山市浄瑠璃町282',33.753556,132.819111,708,'薬師如来',null,'樹齢千年のイブキで知られる第46番札所。','https://ja.wikipedia.org/wiki/浄瑠璃寺_(松山市)','Wikipedia',true,now()),
('iwayaji-kumakogen','岩屋寺','いわやじ','temple','真言宗豊山派','愛媛県','久万高原町','愛媛県上浮穴郡久万高原町七鳥1468',33.658667,132.980722,815,'不動明王',null,'岩山全体を霊地とする第45番札所。遍路屈指の難所。','https://ja.wikipedia.org/wiki/岩屋寺_(愛媛県)','Wikipedia',true,now()),
('taisanji-matsuyama','太山寺','たいさんじ','temple','真言宗智山派','愛媛県','松山市','愛媛県松山市太山寺町1730',33.885083,132.714972,587,'十一面観音',null,'国宝の本堂で知られる第52番札所。一夜建立伝説の寺。','https://ja.wikipedia.org/wiki/太山寺_(松山市)','Wikipedia',true,now()),
('iyo-kokubunji','伊予国分寺','いよこくぶんじ','temple','真言律宗','愛媛県','今治市','愛媛県今治市国分4-1-33',34.026167,133.025444,756,'薬師瑠璃光如来',null,'伊予国分寺の法燈を継ぐ第59番札所。塔跡が国史跡。','https://ja.wikipedia.org/wiki/伊予国分寺','Wikipedia',true,now()),
('nankobo','南光坊','なんこうぼう','temple','真言宗御室派','愛媛県','今治市','愛媛県今治市別宮町3-1',34.068750,132.995750,594,'大通智勝如来',null,'四国霊場で唯一大通智勝如来を本尊とする第55番札所。','https://ja.wikipedia.org/wiki/南光坊','Wikipedia',true,now()),
('daihoji-kumakogen','大宝寺','だいほうじ','temple','真言宗豊山派','愛媛県','久万高原町','愛媛県上浮穴郡久万高原町菅生2-1173',33.660889,132.912083,701,'十一面観音',null,'四国遍路の中札所とされる第44番札所。','https://ja.wikipedia.org/wiki/大宝寺_(久万高原町)','Wikipedia',true,now()),
-- 高知県
('shinshoji-muroto','津照寺','しんしょうじ','temple','真言宗豊山派','高知県','室戸市','高知県室戸市室津2652-イ',33.287806,134.148250,807,'楫取地蔵菩薩','https://88shikokuhenro.jp/25shinshoji/','室津港を見下ろす第25番札所。楫取地蔵で知られる。','https://ja.wikipedia.org/wiki/津照寺','Wikipedia',true,now()),
('kongochoji-muroto','金剛頂寺','こんごうちょうじ','temple','真言宗豊山派','高知県','室戸市','高知県室戸市元乙523',33.307220,134.122861,807,'薬師如来',null,'室戸岬を望む第26番札所。修行の道場の霊場。','https://ja.wikipedia.org/wiki/金剛頂寺_(室戸市)','Wikipedia',true,now()),
('shoryuji-tosa','青龍寺','しょうりゅうじ','temple','真言宗豊山派','高知県','土佐市','高知県土佐市宇佐町竜163',33.426000,133.450806,815,'波切不動明王',null,'横浪半島に建つ第36番札所。「竜のお不動さん」。','https://ja.wikipedia.org/wiki/青龍寺_(土佐市)','Wikipedia',true,now()),
('sekkeiji','雪蹊寺','せっけいじ','temple','臨済宗妙心寺派','高知県','高知市','高知県高知市長浜857-3',33.500830,133.543083,815,'薬師如来',null,'長宗我部元親の菩提寺となった第33番札所。','https://ja.wikipedia.org/wiki/雪蹊寺','Wikipedia',true,now()),
('zenrakuji-kochi','善楽寺','ぜんらくじ','temple','真言宗豊山派','高知県','高知市','高知県高知市一宮しなね2-23-11',33.592500,133.578000,810,'阿弥陀如来','https://zenrakuji.sakura.ne.jp/','土佐神社の別当寺であった第30番札所。','https://ja.wikipedia.org/wiki/善楽寺','Wikipedia',true,now()),
('tosa-kokubunji','土佐国分寺','とさこくぶんじ','temple','真言宗智山派','高知県','南国市','高知県南国市国分546',33.598694,133.640417,756,'千手観音',null,'紀貫之ゆかりの第29番札所。本堂が重要文化財。','https://ja.wikipedia.org/wiki/土佐国分寺','Wikipedia',true,now()),
('dainichiji-konan','大日寺','だいにちじ','temple','真言宗智山派','高知県','香南市','高知県香南市野市町母代寺476-1',33.577583,133.705389,729,'大日如来','http://dainichiji28.org/','行基開基と伝わる第28番札所。','https://ja.wikipedia.org/wiki/大日寺_(香南市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ④ 御祭神/本尊の紐付け
-- ============================================================
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
-- 鳥取
   (t.slug='akaiiwa-jinja' and d.slug in ('okuninushi'))
-- 島根
or (t.slug='kamosu-jinja' and d.slug in ('izanami'))
or (t.slug='sada-jinja' and d.slug in ('sada_okami'))
or (t.slug='tamatsukuriyu-jinja' and d.slug in ('kushiakarutama'))
or (t.slug='tamawakasumikoto-jinja' and d.slug in ('tamawakasu'))
or (t.slug='washibara-hachimangu' and d.slug in ('hachiman'))
-- 岡山
or (t.slug='nakayama-jinja-tsuyama' and d.slug in ('kagamitsukuri'))
or (t.slug='munetada-jinja-okayama' and d.slug in ('kurozumi_munetada'))
-- 広島
or (t.slug='senkoji-onomichi' and d.slug in ('senju_kannon'))
or (t.slug='jodoji-onomichi' and d.slug in ('juichimen_kannon'))
or (t.slug='fudoin-hiroshima' and d.slug in ('yakushi_nyorai'))
-- 山口
or (t.slug='kozanji' and d.slug in ('senju_kannon'))
or (t.slug='tokoji-hagi' and d.slug in ('shaka_nyorai'))
or (t.slug='kameyama-hachimangu-shimonoseki' and d.slug in ('hachiman'))
or (t.slug='imahachimangu-yamaguchi' and d.slug in ('hachiman'))
or (t.slug='iminomiya-jinja' and d.slug in ('chuai','jingu_kogo','hachiman'))
-- 徳島
or (t.slug='gokurakuji-naruto' and d.slug in ('amida_nyorai'))
or (t.slug='shosanji' and d.slug in ('kokuzo_bosatsu'))
or (t.slug='dainichiji-tokushima' and d.slug in ('juichimen_kannon'))
or (t.slug='kakurinji-katsuura' and d.slug in ('jizo_bosatsu'))
or (t.slug='tairyuji' and d.slug in ('kokuzo_bosatsu'))
-- 香川
or (t.slug='yakuriji' and d.slug in ('sho_kannon'))
or (t.slug='shidoji' and d.slug in ('juichimen_kannon'))
or (t.slug='okuboji' and d.slug in ('yakushi_nyorai'))
or (t.slug='nagaoji' and d.slug in ('sho_kannon'))
or (t.slug='negoroji' and d.slug in ('senju_kannon'))
or (t.slug='iyadaniji' and d.slug in ('senju_kannon'))
-- 愛媛
or (t.slug='yokomineji' and d.slug in ('dainichi_nyorai'))
or (t.slug='hantaji' and d.slug in ('yakushi_nyorai'))
or (t.slug='joruriji-matsuyama' and d.slug in ('yakushi_nyorai'))
or (t.slug='iwayaji-kumakogen' and d.slug in ('fudo_myoo'))
or (t.slug='taisanji-matsuyama' and d.slug in ('juichimen_kannon'))
or (t.slug='iyo-kokubunji' and d.slug in ('yakushi_nyorai'))
or (t.slug='nankobo' and d.slug in ('daitsuchisho_nyorai'))
or (t.slug='daihoji-kumakogen' and d.slug in ('juichimen_kannon'))
-- 高知
or (t.slug='shinshoji-muroto' and d.slug in ('jizo_bosatsu'))
or (t.slug='kongochoji-muroto' and d.slug in ('yakushi_nyorai'))
or (t.slug='shoryuji-tosa' and d.slug in ('fudo_myoo'))
or (t.slug='sekkeiji' and d.slug in ('yakushi_nyorai'))
or (t.slug='zenrakuji-kochi' and d.slug in ('amida_nyorai'))
or (t.slug='tosa-kokubunji' and d.slug in ('senju_kannon'))
or (t.slug='dainichiji-konan' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- 配祀（role='sub'）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='kamosu-jinja' and d.slug in ('izanagi'))
or (t.slug='tamatsukuriyu-jinja' and d.slug in ('okuninushi','sukunabikona'))
on conflict do nothing;
