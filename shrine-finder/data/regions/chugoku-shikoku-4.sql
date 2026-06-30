-- 中国・四国 観光著名社寺 第4弾
-- 担当県: 鳥取,島根,岡山,広島,山口,徳島,香川,愛媛,高知
-- 出典: ja.wikipedia.org のinfobox十進座標を確認したもののみ。重複なし。

-- ===== バッチ1 (鳥取県) =====
-- ① 新規神仏（chugoku-shikoku系ファイルに未定義のものを補完。on conflictで既存はスキップ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ninigi','瓊瓊杵尊','ににぎのみこと','kami','天津神','{邇邇芸命}','記紀','天孫降臨の主神。天照大神の孫。','https://ja.wikipedia.org/wiki/ニニギ','Wikipedia',true,now()),
('hikohohodemi','彦火火出見尊','ひこほほでみのみこと','kami','天津神','{山幸彦,火遠理命}','記紀','瓊瓊杵尊の子。海幸山幸神話の山幸彦。','https://ja.wikipedia.org/wiki/ホオリ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ninigi' and g.slug in ('kaiun','suisan_noko','shusse')) or
   (d.slug='hikohohodemi' and g.slug in ('kaiun','suisan_noko'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daisenji-tottori','大山寺','だいせんじ','temple','天台宗','鳥取県','西伯郡大山町','鳥取県西伯郡大山町大山9',35.390972,133.534889,718,'地蔵菩薩',null,'伯耆大山の中腹に建つ天台宗の古刹。中国観音霊場第29番。','https://ja.wikipedia.org/wiki/大山寺_(鳥取県大山町)','Wikipedia',true,now()),
('hijiri-jinja-tottori','聖神社','ひじりじんじゃ','shrine','聖神社','鳥取県','鳥取市','鳥取県鳥取市行徳2-705',35.499972,134.220111,null,null,'http://hijirijinjya.jp/','鳥取市の総鎮守。隔年の神幸祭で知られる。本殿は県保護文化財。','https://ja.wikipedia.org/wiki/聖神社_(鳥取市)','Wikipedia',true,now()),
('tottori-toshogu','鳥取東照宮','とっとりとうしょうぐう','shrine','鳥取東照宮','鳥取県','鳥取市','鳥取県鳥取市上町87',35.5011611,134.2460861,1650,null,null,'池田光仲が創建した東照宮。本殿・唐門・拝殿が国の重要文化財。','https://ja.wikipedia.org/wiki/鳥取東照宮','Wikipedia',true,now()),
('hasedera-kurayoshi','長谷寺','はせでら','temple','天台宗','鳥取県','倉吉市','鳥取県倉吉市仲ノ町2960',35.426722,133.818389,721,'十一面観音','http://www.kurayoshi-hasedera.jp/','打吹山の中腹に建つ懸造の観音堂で知られる。中国観音霊場第30番。','https://ja.wikipedia.org/wiki/長谷寺_(倉吉市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daisenji-tottori' and d.slug in ('jizo_bosatsu')) or
   (t.slug='hijiri-jinja-tottori' and d.slug in ('ninigi','hikohohodemi','kotoshironushi')) or
   (t.slug='tottori-toshogu' and d.slug in ('ieyasu')) or
   (t.slug='hasedera-kurayoshi' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- ===== バッチ2 (島根県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sukunahikona','少彦名命','すくなひこなのみこと','kami','国津神','{少名毘古那神}','記紀','大国主と国造りを行った医薬・酒造の神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('kushimikenu','櫛御気野命','くしみけぬのみこと','kami','国津神','{素戔嗚尊}','記紀','出雲熊野大社の主神。スサノオの別名とされる。','https://ja.wikipedia.org/wiki/クシミケヌ','Wikipedia',true,now()),
('mizuwakasu','水若酢命','みずわかすのみこと','kami','国津神','{}','風土記','隠岐国一宮水若酢神社の主祭神。海防の神。','https://ja.wikipedia.org/wiki/水若酢神社','Wikipedia',true,now()),
('gotoba_tenno','後鳥羽天皇','ごとばてんのう','kami','人神','{}','史実','第82代天皇。承久の乱の後に隠岐へ配流された。','https://ja.wikipedia.org/wiki/後鳥羽天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sukunahikona' and g.slug in ('byoki_heyu','shobai','kaiun')) or
   (d.slug='kushimikenu' and g.slug in ('yakubarai','enmusubi','shobu')) or
   (d.slug='mizuwakasu' and g.slug in ('kaijo_anzen','yakubarai')) or
   (d.slug='gotoba_tenno' and g.slug in ('kaiun','gakumon'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oki-jinja','隠岐神社','おきじんじゃ','shrine','隠岐神社','島根県','隠岐郡海士町','島根県隠岐郡海士町大字福井1365-5',36.095750,133.101250,1939,null,'http://www.okijinja.sakura.ne.jp/','後鳥羽天皇を祀る隠岐の官幣中社。隠岐造の社殿で知られる。','https://ja.wikipedia.org/wiki/隠岐神社','Wikipedia',true,now()),
('mizuwakasu-jinja','水若酢神社','みずわかすじんじゃ','shrine','水若酢神社','島根県','隠岐郡隠岐の島町','島根県隠岐郡隠岐の島町郡723',36.2802167,133.2490389,null,null,null,'隠岐国一宮。本殿は隠岐造の重要文化財。','https://ja.wikipedia.org/wiki/水若酢神社','Wikipedia',true,now()),
('hirahama-hachimangu','平濱八幡宮','ひらはまはちまんぐう','shrine','平濱八幡宮','島根県','松江市','島根県松江市八幡町303',35.44167,133.116806,null,null,null,'出雲国最古とされる八幡宮。長寿の武内神社を境内に祀る。','https://ja.wikipedia.org/wiki/平浜八幡宮','Wikipedia',true,now()),
('mankusen-jinja','万九千神社','まんくせんじんじゃ','shrine','万九千神社','島根県','出雲市','島根県出雲市斐川町併川258',35.374667,132.787139,null,null,'https://mankusenjinja.jp/','神在月に八百万の神が最後に立ち寄り宴を開くと伝わる社。本殿を持たない。','https://ja.wikipedia.org/wiki/万九千神社','Wikipedia',true,now()),
('ichibataji-izumo','一畑寺','いちばたじ','temple','臨済宗妙心寺派','島根県','出雲市','島根県出雲市小境町803',35.4967750,132.8741028,894,'薬師如来','https://ichibata.jp/','「目のお薬師さま」として知られる一畑薬師教団の総本山。','https://ja.wikipedia.org/wiki/一畑寺','Wikipedia',true,now()),
('gesshoji-matsue','月照寺','げっしょうじ','temple','浄土宗','島根県','松江市','島根県松江市外中原町179',35.471361,133.039944,1664,'阿弥陀如来','https://gessyoji.jp/','松江松平家の菩提寺。あじさい寺、大亀の伝説で知られる国史跡。','https://ja.wikipedia.org/wiki/月照寺_(松江市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oki-jinja' and d.slug in ('gotoba_tenno')) or
   (t.slug='mizuwakasu-jinja' and d.slug in ('mizuwakasu')) or
   (t.slug='hirahama-hachimangu' and d.slug in ('hachiman','chuai','jingu_kogo')) or
   (t.slug='mankusen-jinja' and d.slug in ('kushimikenu','okuninushi','sukunahikona')) or
   (t.slug='ichibataji-izumo' and d.slug in ('yakushi_nyorai')) or
   (t.slug='gesshoji-matsue' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== バッチ3 (岡山県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('itsuse','五瀬命','いつせのみこと','kami','天津神','{彦五瀬命}','記紀','神武天皇の長兄。東征の途上で戦没した。','https://ja.wikipedia.org/wiki/イツセ','Wikipedia',true,now()),
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','仏教','無限の智慧と福徳を蔵する菩薩。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='itsuse' and g.slug in ('shobu','kaiun')) or
   (d.slug='kokuzo_bosatsu' and g.slug in ('gakugyo','chie','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ani-jinja','安仁神社','あにじんじゃ','shrine','安仁神社','岡山県','岡山市','岡山県岡山市東区西大寺一宮895',34.610528,134.095944,null,null,'https://www.anijinja.net/','備前国総鎮守の名神大社。五瀬命を祀る。','https://ja.wikipedia.org/wiki/安仁神社','Wikipedia',true,now()),
('isonokami-futsumitama-jinja','石上布都魂神社','いそのかみふつみたまじんじゃ','shrine','石上布都魂神社','岡山県','赤磐市','岡山県赤磐市石上1448',34.851750,133.97028,null,null,null,'備前国一宮の式内社。スサノオの大蛇退治の剣を祀ると伝わる。','https://ja.wikipedia.org/wiki/石上布都魂神社','Wikipedia',true,now()),
('entsuji-kurashiki','円通寺','えんつうじ','temple','曹洞宗','岡山県','倉敷市','岡山県倉敷市玉島柏島451',34.5411722,133.6628944,null,'聖観音菩薩','https://www.entsuji-kurashiki.jp/','良寛が約12年修行したことで知られる玉島の禅刹。','https://ja.wikipedia.org/wiki/円通寺_(倉敷市)','Wikipedia',true,now()),
('kiyamaji-mawari','木山寺','きやまじ','temple','高野山真言宗','岡山県','真庭市','岡山県真庭市木山1212',35.0172028,133.7150722,815,'薬師瑠璃光如来','http://www.kiyamaji.jp/','神仏習合の形を残す古刹。中国観音霊場第4番。','https://ja.wikipedia.org/wiki/木山寺','Wikipedia',true,now()),
('hofukuji-soja','宝福寺','ほうふくじ','temple','臨済宗東福寺派','岡山県','総社市','岡山県総社市井尻野1968',34.691306,133.733972,null,'虚空蔵菩薩','http://iyama-hofukuji.jp/','雪舟が涙で鼠を描いた逸話で知られる禅寺。三重塔は重要文化財。','https://ja.wikipedia.org/wiki/宝福寺_(総社市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ani-jinja' and d.slug in ('itsuse')) or
   (t.slug='isonokami-futsumitama-jinja' and d.slug in ('susanoo')) or
   (t.slug='entsuji-kurashiki' and d.slug in ('sho_kannon')) or
   (t.slug='kiyamaji-mawari' and d.slug in ('yakushi_nyorai')) or
   (t.slug='hofukuji-soja' and d.slug in ('kokuzo_bosatsu'))
on conflict do nothing;

-- ===== バッチ4 (広島県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('miroku_bosatsu','弥勒菩薩','みろくぼさつ','buddha','菩薩','{}','仏教','釈迦入滅後56億7千万年後に現れる未来仏。','https://ja.wikipedia.org/wiki/弥勒菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='miroku_bosatsu' and g.slug in ('kaiun','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('bandaiji-abuto','磐台寺','ばんだいじ','temple','臨済宗妙心寺派','広島県','福山市','広島県福山市沼隈町能登原',34.365694,133.346083,992,'十一面観音',null,'阿伏兎岬の断崖に建つ観音堂「阿伏兎観音」で知られる。観音堂は重要文化財。','https://ja.wikipedia.org/wiki/磐台寺','Wikipedia',true,now()),
('kojoji-setoda','向上寺','こうじょうじ','temple','曹洞宗','広島県','尾道市','広島県尾道市瀬戸田町瀬戸田58',34.306556,133.086833,1403,'聖観音菩薩','http://www.genets.co.jp/u1/KOJOJI/','生口島に建つ禅寺。永享4年建立の三重塔は国宝。','https://ja.wikipedia.org/wiki/向上寺','Wikipedia',true,now()),
('tenneiji-onomichi','天寧寺','てんねいじ','temple','曹洞宗','広島県','尾道市','広島県尾道市東土堂町17-29',34.409694,133.200639,1367,'弥勒菩薩',null,'尾道の坂の上に建つ禅寺。三重塔(海雲塔)は重要文化財。','https://ja.wikipedia.org/wiki/天寧寺_(尾道市)','Wikipedia',true,now()),
('saikokuji-onomichi','西國寺','さいこくじ','temple','真言宗醍醐派','広島県','尾道市','広島県尾道市西久保町29-27',34.415917,133.203389,729,'薬師如来','https://saikokuji.com/','大わらじで知られる尾道の真言宗大本山。金堂・三重塔は重要文化財。','https://ja.wikipedia.org/wiki/西国寺','Wikipedia',true,now()),
('hijiyama-jinja','比治山神社','ひじやまじんじゃ','shrine','比治山神社','広島県','広島市','広島県広島市南区比治山町5-10',34.388417,132.473194,null,null,'https://hijiyama-jinja.jp/','比治山に鎮座する広島市の別表神社。原爆で社殿を焼失し再建された。','https://ja.wikipedia.org/wiki/比治山神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='bandaiji-abuto' and d.slug in ('juichimen_kannon')) or
   (t.slug='kojoji-setoda' and d.slug in ('sho_kannon')) or
   (t.slug='tenneiji-onomichi' and d.slug in ('miroku_bosatsu')) or
   (t.slug='saikokuji-onomichi' and d.slug in ('yakushi_nyorai')) or
   (t.slug='hijiyama-jinja' and d.slug in ('okuninushi','sukunahikona'))
on conflict do nothing;

-- ===== バッチ5 (山口県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('konohanasakuyahime','木花咲耶姫','このはなさくやひめ','kami','天津神','{木花之佐久夜毘売}','記紀','瓊瓊杵尊の妻。富士山の女神で安産・子育ての神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='konohanasakuyahime' and g.slug in ('anzan','kosodate','enmusubi'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kotozaki-hachimangu','琴崎八幡宮','ことざきはちまんぐう','shrine','琴崎八幡宮','山口県','宇部市','山口県宇部市上宇部大字大小路',33.97167,131.27028,859,null,'https://kotozaki.com/','宇部の総鎮守。八幡三神を祀り、御守りの種類の多さで知られる。','https://ja.wikipedia.org/wiki/琴崎八幡宮','Wikipedia',true,now()),
('ootoshi-jinja-shimonoseki','大歳神社','おおとしじんじゃ','shrine','大歳神社','山口県','下関市','山口県下関市竹崎町1-13-10',33.951444,130.925500,1186,null,null,'源義経が壇ノ浦の戦勝を祈願したと伝わる下関の社。','https://ja.wikipedia.org/wiki/大歳神社_(下関市)','Wikipedia',true,now()),
('yasaka-jinja-yamaguchi','八坂神社','やさかじんじゃ','shrine','八坂神社','山口県','山口市','山口県山口市上竪小路100',34.1859972,131.4784056,1370,null,null,'大内弘世が京の祇園社を勧請した「祇園さま」。本殿は重要文化財。','https://ja.wikipedia.org/wiki/八坂神社_(山口市)','Wikipedia',true,now()),
('ryuzoji-yamaguchi','龍蔵寺','りゅうぞうじ','temple','真言宗御室派','山口県','山口市','山口県山口市吉敷1750',34.167722,131.412222,741,'阿弥陀如来',null,'紅葉と大銀杏で知られる古刹。中国観音霊場第17番。','https://ja.wikipedia.org/wiki/龍蔵寺_(山口市)','Wikipedia',true,now()),
('furukuma-jinja','古熊神社','ふるくまじんじゃ','shrine','古熊神社','山口県','山口市','山口県山口市古熊1-10-3',34.178722,131.488639,1373,null,null,'「山口の天神さま」と親しまれる菅原道真を祀る社。本殿・拝殿は重要文化財。','https://ja.wikipedia.org/wiki/古熊神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kotozaki-hachimangu' and d.slug in ('hachiman','jingu_kogo','chuai')) or
   (t.slug='ootoshi-jinja-shimonoseki' and d.slug in ('konohanasakuyahime')) or
   (t.slug='yasaka-jinja-yamaguchi' and d.slug in ('susanoo','kushinadahime')) or
   (t.slug='ryuzoji-yamaguchi' and d.slug in ('amida_nyorai')) or
   (t.slug='furukuma-jinja' and d.slug in ('michizane'))
on conflict do nothing;

-- ===== バッチ6 (徳島県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kashihahime','賀志波比売大神','かしはひめのおおかみ','kami','国津神','{}','地方神','津峯神社の主祭神。延命長寿の女神とされる。','https://ja.wikipedia.org/wiki/津峯神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kashihahime' and g.slug in ('choju','kaijo_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yakurahime-jinja','天石門別八倉比売神社','あめのいわとわけやくらひめじんじゃ','shrine','八倉比売神社','徳島県','徳島市','徳島県徳島市国府町西矢野宮谷531',34.0557806,134.4649583,null,null,null,'阿波国一宮の論社。大日靈女命(天照大神)を祀り、卑弥呼の墓説でも知られる。','https://ja.wikipedia.org/wiki/天石門別八倉比売神社','Wikipedia',true,now()),
('tsunomine-jinja','津峯神社','つのみねじんじゃ','shrine','津峯神社','徳島県','阿南市','徳島県阿南市津乃峰町東分343',33.89472,134.64361,724,null,'http://tsunomine-jinjya.com/','津峯山頂に鎮座する式内社。延命長寿・航海安全の信仰を集める。','https://ja.wikipedia.org/wiki/津峯神社','Wikipedia',true,now()),
('kirihataji-awa','切幡寺','きりはたじ','temple','高野山真言宗','徳島県','阿波市','徳島県阿波市市場町切幡字観音129',34.107750,134.304278,810,'千手観音',null,'四国八十八ヶ所第10番。上下二層が方形の大塔は重要文化財。','https://ja.wikipedia.org/wiki/切幡寺','Wikipedia',true,now()),
('anrakuji-kamiita','安楽寺','あんらくじ','temple','高野山真言宗','徳島県','板野郡上板町','徳島県板野郡上板町引野字寺ノ西北8',34.11806,134.388389,815,'薬師如来','https://anrakuji.org/','四国八十八ヶ所第6番。温泉と竜宮城様の山門で知られる。','https://ja.wikipedia.org/wiki/安楽寺_(徳島県上板町)','Wikipedia',true,now()),
('jizoji-itano','地蔵寺','じぞうじ','temple','真言宗御室派','徳島県','板野郡板野町','徳島県板野郡板野町羅漢字林東5',34.1372194,134.4319250,821,'延命地蔵菩薩',null,'四国八十八ヶ所第5番。奥の院の五百羅漢堂で知られる。','https://ja.wikipedia.org/wiki/地蔵寺_(徳島県板野町)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yakurahime-jinja' and d.slug in ('amaterasu')) or
   (t.slug='tsunomine-jinja' and d.slug in ('kashihahime')) or
   (t.slug='kirihataji-awa' and d.slug in ('senju_kannon')) or
   (t.slug='anrakuji-kamiita' and d.slug in ('yakushi_nyorai')) or
   (t.slug='jizoji-itano' and d.slug in ('jizo_bosatsu'))
on conflict do nothing;

-- ===== バッチ7 (香川県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yamato_takeru','日本武尊','やまとたけるのみこと','kami','人神','{倭建命}','記紀','景行天皇の皇子。東西を平定した伝説の英雄。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('bato_kannon','馬頭観音','ばとうかんのん','buddha','菩薩','{馬頭観世音}','仏教','憤怒相を持つ観音。畜生道の救済・交通安全の仏。','https://ja.wikipedia.org/wiki/馬頭観音','Wikipedia',true,now()),
('homusubi','火産霊命','ほむすびのみこと','kami','国津神','{軻遇突智,火結命}','記紀','火を司る神。火伏せ・防火の神として信仰される。','https://ja.wikipedia.org/wiki/カグツチ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yamato_takeru' and g.slug in ('shobu','yakubarai','kaiun')) or
   (d.slug='bato_kannon' and g.slug in ('kotsu_anzen','petto','byoki_heyu')) or
   (d.slug='homusubi' and g.slug in ('yakubarai','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shirotori-jinja-kagawa','白鳥神社','しろとりじんじゃ','shrine','白鳥神社','香川県','東かがわ市','香川県東かがわ市松原69',34.2461500,134.3637361,null,null,'http://www.shirotori-jinja.jp/','日本武尊の白鳥伝説の社。日本一低い山「御山」がある。','https://ja.wikipedia.org/wiki/白鳥神社_(東かがわ市)','Wikipedia',true,now()),
('oomizukami-jinja','大水上神社','おおみなかみじんじゃ','shrine','大水上神社','香川県','三豊市','香川県三豊市高瀬町羽方2677-2',34.148111,133.755194,null,null,null,'讃岐国二宮の式内社。雨乞いの「うなぎ淵」の神事で知られる。','https://ja.wikipedia.org/wiki/大水上神社','Wikipedia',true,now()),
('motoyamaji-mitoyo','本山寺','もとやまじ','temple','高野山真言宗','香川県','三豊市','香川県三豊市豊中町本山甲1445',34.139667,133.694056,807,'馬頭観音','https://motoyamaji.wixsite.com/shippouzan','四国八十八ヶ所第70番。本堂は国宝、五重塔で知られる。','https://ja.wikipedia.org/wiki/本山寺_(三豊市)','Wikipedia',true,now()),
('kanonji-kagawa','観音寺','かんおんじ','temple','真言宗大覚寺派','香川県','観音寺市','香川県観音寺市八幡町1-2-7',34.134500,133.647528,703,'聖観音菩薩',null,'四国八十八ヶ所第69番。68番神恵院と境内を共有する。銭形砂絵で名高い。','https://ja.wikipedia.org/wiki/観音寺_(観音寺市)','Wikipedia',true,now()),
('kamitani-jinja','神谷神社','かんだにじんじゃ','shrine','神谷神社','香川県','坂出市','香川県坂出市神谷町621',34.3248528,133.9167556,812,null,null,'流造社殿として現存最古、1219年建立の本殿は国宝。','https://ja.wikipedia.org/wiki/神谷神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shirotori-jinja-kagawa' and d.slug in ('yamato_takeru')) or
   (t.slug='oomizukami-jinja' and d.slug in ('hachiman','ichikishima')) or
   (t.slug='motoyamaji-mitoyo' and d.slug in ('bato_kannon')) or
   (t.slug='kanonji-kagawa' and d.slug in ('sho_kannon')) or
   (t.slug='kamitani-jinja' and d.slug in ('homusubi'))
on conflict do nothing;

-- ===== バッチ8 (愛媛県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('warei_okami','和霊大神','われいおおかみ','kami','人神','{山家清兵衛公頼}','史実','宇和島藩の家老山家清兵衛を祀る御霊神。','https://ja.wikipedia.org/wiki/和霊神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='warei_okami' and g.slug in ('shobai','suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shussekiji-ozu','出石寺','しゅっせきじ','temple','真言宗御室派','愛媛県','大洲市','愛媛県大洲市豊茂乙1',33.535750,132.465639,718,'千手観音','https://syussekiji-no7in20.jimdofree.com/','金山出石寺。標高812mの山上に建ち瀬戸内を一望する古刹。','https://ja.wikipedia.org/wiki/出石寺','Wikipedia',true,now()),
('senyuji-imabari','仙遊寺','せんゆうじ','temple','高野山真言宗','愛媛県','今治市','愛媛県今治市玉川町別所甲483',34.013194,132.977361,668,'千手観音',null,'四国八十八ヶ所第58番。作礼山の山上に建ち今治を見下ろす。','https://ja.wikipedia.org/wiki/仙遊寺','Wikipedia',true,now()),
('maegamiji-saijo','前神寺','まえがみじ','temple','真言宗石鈇派','愛媛県','西条市','愛媛県西条市洲之内甲1426',33.890222,133.160667,null,'阿弥陀如来',null,'四国八十八ヶ所第64番。石鎚山の麓に建つ石鈇派総本山。','https://ja.wikipedia.org/wiki/前神寺','Wikipedia',true,now()),
('sankakuji-shikokuchuo','三角寺','さんかくじ','temple','高野山真言宗','愛媛県','四国中央市','愛媛県四国中央市金田町三角寺甲75',33.967639,133.586500,null,'十一面観音',null,'四国八十八ヶ所第65番。三角の護摩壇に由来する山寺。','https://ja.wikipedia.org/wiki/三角寺','Wikipedia',true,now()),
('warei-jinja','和霊神社','われいじんじゃ','shrine','和霊神社','愛媛県','宇和島市','愛媛県宇和島市和霊町1451',33.22972,132.56528,1653,null,'https://wareijinja.fc2.net/','宇和島藩家老山家清兵衛を祀る。日本最大級の石造大鳥居と和霊大祭で知られる。','https://ja.wikipedia.org/wiki/和霊神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shussekiji-ozu' and d.slug in ('senju_kannon')) or
   (t.slug='senyuji-imabari' and d.slug in ('senju_kannon')) or
   (t.slug='maegamiji-saijo' and d.slug in ('amida_nyorai')) or
   (t.slug='sankakuji-shikokuchuo' and d.slug in ('juichimen_kannon')) or
   (t.slug='warei-jinja' and d.slug in ('warei_okami'))
on conflict do nothing;

-- ===== バッチ9 (高知県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('fudo_myoo','不動明王','ふどうみょうおう','buddha','明王','{お不動さま}','仏教','大日如来の化身。煩悩を断ち衆生を守護する明王。','https://ja.wikipedia.org/wiki/不動明王','Wikipedia',true,now()),
('amatsuhaha','天津羽羽神','あまつははのかみ','kami','天津神','{}','地方神','土佐朝倉神社の主祭神。味鋤高彦根命の后とされる女神。','https://ja.wikipedia.org/wiki/朝倉神社_(高知市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='fudo_myoo' and g.slug in ('yakubarai','shobu','majo_kekkai')) or
   (d.slug='amatsuhaha' and g.slug in ('enmusubi','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('asakura-jinja-kochi','朝倉神社','あさくらじんじゃ','shrine','朝倉神社','高知県','高知市','高知県高知市朝倉丙2100',33.553306,133.481694,null,null,null,'土佐国二宮の式内社。御神体山の赤鬼山を背に建つ。本殿は重要文化財。','https://ja.wikipedia.org/wiki/朝倉神社_(高知市)','Wikipedia',true,now()),
('zenjibuji-nankoku','禅師峰寺','ぜんじぶじ','temple','真言宗豊山派','高知県','南国市','高知県南国市十市3084',33.526694,133.61139,null,'十一面観音',null,'四国八十八ヶ所第32番。航海安全の「船魂観音」として信仰される。','https://ja.wikipedia.org/wiki/禅師峰寺','Wikipedia',true,now()),
('iwamotoji-shimanto','岩本寺','いわもとじ','temple','真言宗智山派','高知県','高岡郡四万十町','高知県高岡郡四万十町茂串町3-13',33.207972,133.134611,null,'不動明王','https://iwamotoji.jp/','四国八十八ヶ所第37番。575枚の格天井画で知られる。五仏を本尊とする。','https://ja.wikipedia.org/wiki/岩本寺','Wikipedia',true,now()),
('tanemaji-kochi','種間寺','たねまじ','temple','真言宗豊山派','高知県','高知市','高知県高知市春野町秋山72',33.491722,133.487583,null,'薬師如来',null,'四国八十八ヶ所第34番。安産祈願の寺として知られる。','https://ja.wikipedia.org/wiki/種間寺','Wikipedia',true,now()),
('ushioe-tenmangu','潮江天満宮','うしおえてんまんぐう','shrine','潮江天満宮','高知県','高知市','高知県高知市天神町19-20',33.553194,133.534500,905,null,'http://www.ushioe-tenmangu.jp/','菅原道真とその子を祀る高知市南部の総鎮守。初詣で賑わう。','https://ja.wikipedia.org/wiki/潮江天満宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='asakura-jinja-kochi' and d.slug in ('amatsuhaha')) or
   (t.slug='zenjibuji-nankoku' and d.slug in ('juichimen_kannon')) or
   (t.slug='iwamotoji-shimanto' and d.slug in ('fudo_myoo','sho_kannon','amida_nyorai','yakushi_nyorai','jizo_bosatsu')) or
   (t.slug='tanemaji-kochi' and d.slug in ('yakushi_nyorai')) or
   (t.slug='ushioe-tenmangu' and d.slug in ('michizane'))
on conflict do nothing;

-- ===== バッチ10 (徳島・愛媛・岡山・山口・広島 補完) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('konpira','金毘羅大権現','こんぴらだいごんげん','buddha','天部','{金毘羅,クンビーラ}','仏教','海上交通・海難救助を司る神仏習合の守護神。','https://ja.wikipedia.org/wiki/金毘羅権現','Wikipedia',true,now()),
('amenouzume','天宇受売命','あめのうずめのみこと','kami','天津神','{天鈿女命}','記紀','岩戸隠れで舞った芸能の女神。','https://ja.wikipedia.org/wiki/アメノウズメ','Wikipedia',true,now()),
('honen','法然上人','ほうねんしょうにん','buddha','高僧','{円光大師,源空}','仏教','浄土宗の開祖。専修念仏を説いた。','https://ja.wikipedia.org/wiki/法然','Wikipedia',true,now()),
('izanagi','伊邪那岐命','いざなぎのみこと','kami','天津神','{伊弉諾尊}','記紀','国生み・神生みを行った男神。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='konpira' and g.slug in ('kaijo_anzen','shobai','kotsu_anzen')) or
   (d.slug='amenouzume' and g.slug in ('geino','enmusubi','kaiun')) or
   (d.slug='honen' and g.slug in ('kaiun','jouju')) or
   (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hashikuraji-miyoshi','箸蔵寺','はしくらじ','temple','真言宗御室派','徳島県','三好市','徳島県三好市池田町州津蔵谷1006',34.0478222,133.8409611,828,'金毘羅大権現','http://www.hashikura.or.jp/','「こんぴら奥の院」と称される神仏習合の古刹。本殿など多数が重要文化財。','https://ja.wikipedia.org/wiki/箸蔵寺','Wikipedia',true,now()),
('yugun-jinja','雄郡神社','ゆうぐんじんじゃ','shrine','雄郡神社','愛媛県','松山市','愛媛県松山市小栗3-3-19',33.826528,132.757944,586,null,null,'松山市街の古社。天宇受売命と八幡三神を祀る。','https://ja.wikipedia.org/wiki/雄郡神社','Wikipedia',true,now()),
('tanjoji-kumenan','誕生寺','たんじょうじ','temple','浄土宗','岡山県','久米郡久米南町','岡山県久米郡久米南町里方808',34.955250,133.953000,1193,'円光大師','http://www.tanjoji.or.jp/','浄土宗開祖法然の誕生地に建つ寺。御影堂は重要文化財。','https://ja.wikipedia.org/wiki/誕生寺_(岡山県久米南町)','Wikipedia',true,now()),
('amidaji-hofu','阿弥陀寺','あみだじ','temple','華厳宗','山口県','防府市','山口県防府市牟礼上坂本1869',34.077000,131.614528,1187,'阿弥陀如来','https://www.c-able.ne.jp/~amidaji/amidagi.html','重源が東大寺別院として開いた寺。あじさい寺として名高い。鉄宝塔は国宝。','https://ja.wikipedia.org/wiki/阿弥陀寺_(防府市)','Wikipedia',true,now()),
('ushitora-jinja-onomichi','艮神社','うしとらじんじゃ','shrine','艮神社','広島県','尾道市','広島県尾道市長江1-3-5',34.410722,133.200667,806,null,null,'尾道旧市内最古の社。樹齢約900年の楠と、映画・アニメの舞台として知られる。','https://ja.wikipedia.org/wiki/艮神社_(尾道市長江)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hashikuraji-miyoshi' and d.slug in ('konpira')) or
   (t.slug='yugun-jinja' and d.slug in ('amenouzume','hachiman','jingu_kogo','chuai')) or
   (t.slug='tanjoji-kumenan' and d.slug in ('honen')) or
   (t.slug='amidaji-hofu' and d.slug in ('amida_nyorai')) or
   (t.slug='ushitora-jinja-onomichi' and d.slug in ('izanagi','amaterasu','susanoo','okibitsuhiko'))
on conflict do nothing;

-- ===== バッチ11 (岡山・広島・島根・高知 補完) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tsukuyomi','月読命','つくよみのみこと','kami','天津神','{月夜見尊}','記紀','天照大神の弟。夜と月を司る神。','https://ja.wikipedia.org/wiki/ツクヨミ','Wikipedia',true,now()),
('watatsumi','大綿津見命','おおわたつみのみこと','kami','国津神','{綿津見神}','記紀','海を司る海神。航海・漁業の守護神。','https://ja.wikipedia.org/wiki/ワタツミ','Wikipedia',true,now()),
('izanami','伊邪那美命','いざなみのみこと','kami','国津神','{伊弉冉尊}','記紀','イザナギの妻。国生み・神生みを行った女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tsukuyomi' and g.slug in ('kaiun','yakubarai')) or
   (d.slug='watatsumi' and g.slug in ('kaijo_anzen','suisan_noko','shobai')) or
   (d.slug='izanami' and g.slug in ('enmusubi','anzan','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('arawazu-kannonji','不洗観音寺','あらわずかんのんじ','temple','単立(真言宗)','岡山県','倉敷市','岡山県倉敷市中帯江820',34.604889,133.799972,729,'十一面観音','http://www.arawazu-kannonji.or.jp/','安産・子授け祈願で知られる倉敷の古刹。','https://ja.wikipedia.org/wiki/不洗観音寺','Wikipedia',true,now()),
('fukuyama-hachimangu','福山八幡宮','ふくやまはちまんぐう','shrine','福山八幡宮','広島県','福山市','広島県福山市北吉津町1-2-16',34.494861,133.359861,1683,null,'http://www.fukuyamahachimangu.or.jp/','東西二棟の本殿が並ぶ珍しい構造の福山総鎮守。','https://ja.wikipedia.org/wiki/福山八幡宮','Wikipedia',true,now()),
('nunakuma-jinja','沼名前神社','ぬなくまじんじゃ','shrine','沼名前神社','広島県','福山市','広島県福山市鞆町後地1225',34.386333,133.378361,null,null,null,'鞆の浦の総鎮守「鞆祇園さん」。桃山時代の能舞台は重要文化財。','https://ja.wikipedia.org/wiki/沼名前神社','Wikipedia',true,now()),
('rokusho-jinja-matsue','六所神社','ろくしょじんじゃ','shrine','六所神社','島根県','松江市','島根県松江市大草町496',35.427167,133.104222,null,null,null,'出雲国府跡に鎮座する出雲国総社。六柱の神を祀る。','https://ja.wikipedia.org/wiki/六所神社_(松江市)','Wikipedia',true,now()),
('wakamiya-hachimangu-kochi','若宮八幡宮','わかみやはちまんぐう','shrine','若宮八幡宮','高知県','高知市','高知県高知市長浜6600',33.4949889,133.54361,1185,null,null,'長宗我部元親の初陣を祈願した社。どろんこ祭りと元親銅像で知られる。','https://ja.wikipedia.org/wiki/若宮八幡宮_(高知市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='arawazu-kannonji' and d.slug in ('juichimen_kannon')) or
   (t.slug='fukuyama-hachimangu' and d.slug in ('hachiman','jingu_kogo','ichikishima')) or
   (t.slug='nunakuma-jinja' and d.slug in ('watatsumi','susanoo')) or
   (t.slug='rokusho-jinja-matsue' and d.slug in ('izanagi','izanami','amaterasu','tsukuyomi','susanoo','okuninushi')) or
   (t.slug='wakamiya-hachimangu-kochi' and d.slug in ('hachiman','jingu_kogo','ichikishima'))
on conflict do nothing;
