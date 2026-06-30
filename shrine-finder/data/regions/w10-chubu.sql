-- =====================================================================
-- 中部地方 社寺データ (w10-chubu)
-- 出典: ja.wikipedia.org の infobox 十進座標で裏取り（座標無しは除外）
-- 対象県: 愛知・岐阜・静岡・長野・山梨・新潟・富山・石川・福井
-- 既存 _have_chubu.txt 収録分とは重複させない
-- =====================================================================

-- ① 新規神仏（既存14柱に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takeminakata','建御名方神','たけみなかたのかみ','kami','国津神','{}','記紀','大国主の子。諏訪大社の祭神で軍神・農耕神。','https://ja.wikipedia.org/wiki/タケミナカタ','Wikipedia',true,now()),
('yasakatome','八坂刀売神','やさかとめのかみ','kami','国津神','{}','記紀','建御名方神の妃神。諏訪大社下社の祭神。','https://ja.wikipedia.org/wiki/ヤサカトメ','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','大国主の子。託宣・恵比寿信仰の神。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('amenohoakari','天火明命','あめのほあかりのみこと','kami','天津神','{}','記紀','尾張氏の祖神。','https://ja.wikipedia.org/wiki/アメノホアカリ','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方浄瑠璃世界の教主。病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。浄土信仰の本尊。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{}','仏教','十一の顔を持つ変化観音。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takeminakata' and g.slug in ('shobu','shobai','kaiun'))
or (d.slug='yasakatome' and g.slug in ('enmusubi','anzan','kanai_anzen'))
or (d.slug='kotoshironushi' and g.slug in ('shobai','kinun','suisan_noko'))
or (d.slug='amenohoakari' and g.slug in ('kaiun','shobai'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','kaiun'))
or (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','yakubarai','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mandara-ji-konan','曼陀羅寺','まんだらじ','temple','浄土宗西山派','愛知県','江南市','愛知県江南市前飛保町寺町202',35.349611,136.856472,1329,'阿弥陀三尊','https://mandaraji.jimdofree.com/','後醍醐天皇勅願の藤の名所として知られる古刹。','https://ja.wikipedia.org/wiki/曼陀羅寺','Wikipedia',true,now()),
('suwa-taisha-shimosha-harumiya','諏訪大社下社春宮','すわたいしゃしもしゃはるみや','shrine','諏訪大社（信濃国一宮・旧官幣大社）','長野県','諏訪郡下諏訪町','長野県諏訪郡下諏訪町193',36.0820694,138.0821111,null,null,'https://suwataisha.or.jp/','諏訪大社四宮の一。御柱祭で知られる。','https://ja.wikipedia.org/wiki/諏訪大社','Wikipedia',true,now()),
('yahiko-jinja-tatsuno','矢彦神社','やひこじんじゃ','shrine','旧県社','長野県','上伊那郡辰野町','長野県上伊那郡辰野町大字小野3267',36.0545417,137.9692889,null,null,null,'小野神社と社叢を共有する古社。御柱祭を行う。','https://ja.wikipedia.org/wiki/小野神社・矢彦神社','Wikipedia',true,now()),
('misogi-jinja','身曾岐神社','みそぎじんじゃ','shrine','禊教系','山梨県','北杜市','山梨県北杜市小淵沢町上笹尾3437',35.862806,138.336806,1985,null,null,'広大な社叢と能楽殿を持つ禊教ゆかりの社。','https://ja.wikipedia.org/wiki/身曾岐神社','Wikipedia',true,now()),
('daizen-ji-koshu','大善寺','だいぜんじ','temple','真言宗智山派','山梨県','甲州市','山梨県甲州市勝沼町勝沼3559',35.655944,138.743167,718,'薬師如来','https://katsunuma.ne.jp/~daizenji/','本堂が国宝のぶどう寺として名高い古刹。','https://ja.wikipedia.org/wiki/大善寺_(甲州市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mandara-ji-konan' and d.slug in ('amida_nyorai'))
or (t.slug='suwa-taisha-shimosha-harumiya' and d.slug in ('takeminakata','yasakatome'))
or (t.slug='yahiko-jinja-tatsuno' and d.slug in ('okuninushi','kotoshironushi'))
or (t.slug='misogi-jinja' and d.slug in ('amaterasu'))
or (t.slug='daizen-ji-koshu' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- =========================== バッチ2 ===========================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yamatotakeru','日本武尊','やまとたけるのみこと','kami','天津神','{}','記紀','景行天皇の皇子。東征伝説で知られる英雄神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','天照大神の弟神。厄除け・八岐大蛇退治の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('amenominakanushi','天之御中主神','あめのみなかぬしのかみ','kami','天津神','{}','記紀','造化三神の首座。宇宙の中心神。','https://ja.wikipedia.org/wiki/アメノミナカヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yamatotakeru' and g.slug in ('shobu','yakubarai','kaiun'))
or (d.slug='susanoo' and g.slug in ('yakubarai','enmusubi','shobu'))
or (d.slug='amenominakanushi' and g.slug in ('kaiun','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('owaribe-jinja','尾張戸神社','おわりべじんじゃ','shrine','式内社・旧村社','愛知県','瀬戸市','愛知県瀬戸市十軒町845',35.25613306,137.05312194,null,null,null,'東谷山山頂に鎮座する尾張氏祖神を祀る式内社。','https://ja.wikipedia.org/wiki/尾張戸神社','Wikipedia',true,now()),
('iwazu-tenmangu','岩津天満宮','いわづてんまんぐう','shrine','旧無格社','愛知県','岡崎市','愛知県岡崎市岩津町東山53',35.00528,137.17667,1759,null,'https://iwazutenjin.jp/','合格祈願で知られる三河の天神様。','https://ja.wikipedia.org/wiki/岩津天満宮','Wikipedia',true,now()),
('takeda-hachimangu','武田八幡宮','たけだはちまんぐう','shrine','旧県社','山梨県','韮崎市','山梨県韮崎市神山町北宮地1185',35.7044583,138.4208667,822,null,null,'武田氏発祥の地とされ武田信玄が再建した古社。本殿は重文。','https://ja.wikipedia.org/wiki/武田八幡宮','Wikipedia',true,now()),
('miho-jinja-shizuoka','御穂神社','みほじんじゃ','shrine','式内社・旧県社','静岡県','静岡市','静岡県静岡市清水区三保1073',35.0001111,138.5208778,null,null,null,'三保松原の羽衣伝説で知られる富士山世界遺産構成資産。','https://ja.wikipedia.org/wiki/御穂神社','Wikipedia',true,now()),
('yaizu-jinja','焼津神社','やいづじんじゃ','shrine','式内社・別表神社','静岡県','焼津市','静岡県焼津市焼津2-7-2',34.8650389,138.3136444,null,null,'http://www.yaizujinja.or.jp/','日本武尊を祀る荒祭りで名高い古社。','https://ja.wikipedia.org/wiki/焼津神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='owaribe-jinja' and d.slug in ('amenohoakari'))
or (t.slug='iwazu-tenmangu' and d.slug in ('michizane'))
or (t.slug='takeda-hachimangu' and d.slug in ('hachiman'))
or (t.slug='miho-jinja-shizuoka' and d.slug in ('okuninushi'))
or (t.slug='yaizu-jinja' and d.slug in ('yamatotakeru'))
on conflict do nothing;

-- =========================== バッチ3 ===========================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('matsudaira_yoshinaga','松平慶永','まつだいらよしなが','kami','御霊','{春嶽}','史実','幕末の福井藩主・松平春嶽を祀る。','https://ja.wikipedia.org/wiki/松平春嶽','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='matsudaira_yoshinaga' and g.slug in ('gakumon','shusse','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nagono-jinja','那古野神社','なごのじんじゃ','shrine','旧県社','愛知県','名古屋市','愛知県名古屋市中区丸の内2-3-17',35.177417,136.899750,911,null,null,'名古屋城三の丸に鎮座した名古屋総鎮守。','https://ja.wikipedia.org/wiki/那古野神社','Wikipedia',true,now()),
('takaga-jinja','高賀神社','こうがじんじゃ','shrine','旧郷社','岐阜県','関市','岐阜県関市洞戸高賀1217',35.6503750,136.8539583,null,null,null,'高賀山信仰の中心。円空仏を伝える山岳信仰の社。','https://ja.wikipedia.org/wiki/高賀神社','Wikipedia',true,now()),
('gosen-hachimangu','五泉八幡宮','ごせんはちまんぐう','shrine','旧郷社','新潟県','五泉市','新潟県五泉市宮町5-46',37.741750,139.173944,879,null,null,'風鈴まつりで知られる五泉の総鎮守。','https://ja.wikipedia.org/wiki/五泉八幡宮','Wikipedia',true,now()),
('fukui-jinja','福井神社','ふくいじんじゃ','shrine','別表神社','福井県','福井市','福井県福井市大手3-16-1',36.066000,136.219333,1943,null,null,'幕末の名君・松平春嶽を祀る。戦後再建の近代建築。','https://ja.wikipedia.org/wiki/福井神社','Wikipedia',true,now()),
('jigen-ji-ojiya','慈眼寺','じげんじ','temple','真言宗智山派','新潟県','小千谷市','新潟県小千谷市平成2-3-35',37.307528,138.794333,860,'聖観音','https://ja.wikipedia.org/wiki/慈眼寺_(小千谷市)','戊辰戦争の「慈眼寺会談」の舞台となった古刹。','https://ja.wikipedia.org/wiki/慈眼寺_(小千谷市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nagono-jinja' and d.slug in ('susanoo'))
or (t.slug='takaga-jinja' and d.slug in ('amenominakanushi'))
or (t.slug='gosen-hachimangu' and d.slug in ('hachiman'))
or (t.slug='fukui-jinja' and d.slug in ('matsudaira_yoshinaga'))
or (t.slug='jigen-ji-ojiya' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- =========================== バッチ4 ===========================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖・釈尊。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{延命地蔵}','仏教','六道で衆生を救う菩薩。延命・子育ての仏。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now()),
('gokoku_eirei','護国の英霊','ごこくのえいれい','kami','御霊','{}','史実','国に殉じた戦没者の英霊を祀る。','https://ja.wikipedia.org/wiki/護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shaka_nyorai' and g.slug in ('jouju','yakubarai'))
or (d.slug='jizo_bosatsu' and g.slug in ('kosodate','choju','anchin'))
or (d.slug='gokoku_eirei' and g.slug in ('kaiun','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chuzen-ji-ueda','中禅寺','ちゅうぜんじ','temple','真言宗智山派','長野県','上田市','長野県上田市前山1721',36.33653,138.18558,825,'延命地蔵菩薩','https://ja.wikipedia.org/wiki/中禅寺_(上田市)','薬師堂が長野県最古の木造建築で国宝。','https://ja.wikipedia.org/wiki/中禅寺_(上田市)','Wikipedia',true,now()),
('shakuson-ji-komoro','釈尊寺','しゃくそんじ','temple','天台宗','長野県','小諸市','長野県小諸市大久保2250',36.331083,138.386306,724,'聖観世音菩薩','https://ja.wikipedia.org/wiki/釈尊寺','布引観音の名で知られる懸崖造りの古刹。','https://ja.wikipedia.org/wiki/釈尊寺','Wikipedia',true,now()),
('hida-gokoku-jinja','飛騨護國神社','ひだごこくじんじゃ','shrine','護国神社','岐阜県','高山市','岐阜県高山市堀端町90',36.140861,137.263167,1909,null,null,'飛騨出身の戦没者を祀る護国神社。','https://ja.wikipedia.org/wiki/飛騨護國神社','Wikipedia',true,now()),
('yoko-ji-hakui','永光寺','ようこうじ','temple','曹洞宗','石川県','羽咋市','石川県羽咋市酒井町イ11',36.912972,136.851056,1312,'釈迦如来','https://ja.wikipedia.org/wiki/永光寺','瑩山紹瑾が開いた曹洞宗の古刹。五老峰で知られる。','https://ja.wikipedia.org/wiki/永光寺','Wikipedia',true,now()),
('jion-ji-gujo','慈恩寺','じおんじ','temple','臨済宗妙心寺派','岐阜県','郡上市','岐阜県郡上市八幡町島谷399',35.748111,136.961556,1606,'釈迦如来','https://ja.wikipedia.org/wiki/慈恩寺_(郡上市)','郡上八幡城主遠藤慶隆開基。名園「てっ草園」で名高い。','https://ja.wikipedia.org/wiki/慈恩寺_(郡上市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chuzen-ji-ueda' and d.slug in ('jizo_bosatsu'))
or (t.slug='shakuson-ji-komoro' and d.slug in ('sho_kannon'))
or (t.slug='hida-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='yoko-ji-hakui' and d.slug in ('shaka_nyorai'))
or (t.slug='jion-ji-gujo' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- =========================== バッチ5 ===========================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kunitokotachi','国常立尊','くにのとこたちのみこと','kami','天津神','{}','記紀','天地開闢で最初に現れた神。','https://ja.wikipedia.org/wiki/クニノトコタチ','Wikipedia',true,now()),
('sanbo_son','三宝尊','さんぼうそん','buddha','如来','{}','仏教','仏法僧の三宝を一体に表す法華系の本尊。','https://ja.wikipedia.org/wiki/三宝尊','Wikipedia',true,now()),
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','仏教','無限の知恵と福徳を蔵する菩薩。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kunitokotachi' and g.slug in ('kaiun','yakubarai'))
or (d.slug='sanbo_son' and g.slug in ('jouju','yakubarai'))
or (d.slug='kokuzo_bosatsu' and g.slug in ('gakugyo','gakumon','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('myoken-jinja-gujo','明建神社','みょうけんじんじゃ','shrine','旧郷社','岐阜県','郡上市','岐阜県郡上市大和町牧814-1',35.8118000,136.9235528,null,null,null,'妙見信仰を伝える郡上の古社。七日祭で知られる。','https://ja.wikipedia.org/wiki/明建神社','Wikipedia',true,now()),
('honko-ji-kosai','本興寺','ほんこうじ','temple','法華宗陣門流','静岡県','湖西市','静岡県湖西市鷲津384',34.717167,137.538194,1383,'三宝尊','https://ja.wikipedia.org/wiki/本興寺_(湖西市)','法華宗陣門流の東海別院。鷲津本興寺。','https://ja.wikipedia.org/wiki/本興寺_(湖西市)','Wikipedia',true,now()),
('kamoe-ji','鴨江寺','かもえじ','temple','高野山真言宗','静岡県','浜松市','静岡県浜松市中央区鴨江4-17-1',34.7053222,137.7200056,702,'聖観世音菩薩','https://ja.wikipedia.org/wiki/鴨江寺','「鴨江観音」として親しまれる遠州の古刹。','https://ja.wikipedia.org/wiki/鴨江寺','Wikipedia',true,now()),
('kanzan-ji','舘山寺','かんざんじ','temple','曹洞宗','静岡県','浜松市','静岡県浜松市中央区舘山寺町2231',34.76111,137.61333,810,'虚空蔵菩薩','https://ja.wikipedia.org/wiki/舘山寺','浜名湖畔の景勝地にある弘法大師開創の古刹。','https://ja.wikipedia.org/wiki/舘山寺','Wikipedia',true,now()),
('takaoka-daibutsu','高岡大仏','たかおかだいぶつ','temple','浄土宗','富山県','高岡市','富山県高岡市大手町11-29',36.745639,137.017194,1907,'阿弥陀如来','http://www.takaokadaibutsu.xyz/','日本三大仏の一に数えられる銅造阿弥陀如来坐像。','https://ja.wikipedia.org/wiki/高岡大仏','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='myoken-jinja-gujo' and d.slug in ('kunitokotachi'))
or (t.slug='honko-ji-kosai' and d.slug in ('sanbo_son'))
or (t.slug='kamoe-ji' and d.slug in ('sho_kannon'))
or (t.slug='kanzan-ji' and d.slug in ('kokuzo_bosatsu'))
or (t.slug='takaoka-daibutsu' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- =========================== バッチ6 ===========================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('taira_masakado','平将門','たいらのまさかど','kami','御霊','{}','史実','平安期の武将。御霊信仰の対象。','https://ja.wikipedia.org/wiki/平将門','Wikipedia',true,now()),
('konohanasakuya','木花咲耶姫命','このはなのさくやひめのみこと','kami','天津神','{浅間大神}','記紀','富士山・浅間信仰の女神。安産・縁結びの神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now()),
('oyamatsumi','大山祇神','おおやまつみのかみ','kami','国津神','{}','記紀','山の神。酒造・鉱山の守護神。','https://ja.wikipedia.org/wiki/オオヤマツミ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='taira_masakado' and g.slug in ('yakubarai','shobu','kaiun'))
or (d.slug='konohanasakuya' and g.slug in ('anzan','kosodate','enmusubi'))
or (d.slug='oyamatsumi' and g.slug in ('shobai','kaiun','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('asuke-hachimangu','足助八幡宮','あすけはちまんぐう','shrine','旧郷社','愛知県','豊田市','愛知県豊田市足助町宮ノ後13',35.1342250,137.3107389,673,null,null,'本殿が重文。足（あし）に通じ足腰・旅の守護で知られる。','https://ja.wikipedia.org/wiki/足助八幡宮','Wikipedia',true,now()),
('mikubi-jinja','御首神社','みくびじんじゃ','shrine','旧郷社','岐阜県','大垣市','岐阜県大垣市荒尾町1283-1',35.3735944,136.5824722,null,null,'https://www.mikubijinja.com/','平将門の御神霊を祀り首から上の願掛けで知られる。','https://ja.wikipedia.org/wiki/御首神社','Wikipedia',true,now()),
('tada-ji-obama','多田寺','ただじ','temple','高野山真言宗','福井県','小浜市','福井県小浜市多田27-15-1',35.478250,135.768972,749,'薬師如来','https://ja.wikipedia.org/wiki/多田寺','若狭の古刹。重文の薬師如来・十一面観音を伝える。','https://ja.wikipedia.org/wiki/多田寺','Wikipedia',true,now()),
('ichinomiya-asama-jinja','一宮浅間神社','いちのみやあさまじんじゃ','shrine','旧県社','山梨県','西八代郡市川三郷町','山梨県西八代郡市川三郷町高田3696',35.5542000,138.4901611,865,null,null,'甲斐国八代郡の浅間信仰の古社。','https://ja.wikipedia.org/wiki/一宮浅間神社','Wikipedia',true,now()),
('yamanashioka-jinja','山梨岡神社','やまなしおかじんじゃ','shrine','式内社・旧県社','山梨県','笛吹市','山梨県笛吹市春日居町鎮目1096',35.664611,138.638750,null,null,null,'夔（き）の彫刻と太々神楽で知られる甲斐の古社。','https://ja.wikipedia.org/wiki/山梨岡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='asuke-hachimangu' and d.slug in ('hachiman'))
or (t.slug='mikubi-jinja' and d.slug in ('taira_masakado'))
or (t.slug='tada-ji-obama' and d.slug in ('yakushi_nyorai'))
or (t.slug='ichinomiya-asama-jinja' and d.slug in ('konohanasakuya'))
or (t.slug='yamanashioka-jinja' and d.slug in ('oyamatsumi'))
on conflict do nothing;

-- =========================== バッチ7 ===========================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tsukuyomi','月読命','つくよみのみこと','kami','天津神','{}','記紀','夜と月を司る神。三貴子の一柱。','https://ja.wikipedia.org/wiki/ツクヨミ','Wikipedia',true,now()),
('naito_clan','内藤家霊神','ないとうけれいしん','kami','御霊','{}','史実','村上藩主・内藤家歴代を祀る。','https://ja.wikipedia.org/wiki/藤基神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tsukuyomi' and g.slug in ('kaiun','yakubarai'))
or (d.slug='naito_clan' and g.slug in ('kaiun','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kumaku-jinja-nishio','久麻久神社','くまくじんじゃ','shrine','式内社・旧郷社','愛知県','西尾市','愛知県西尾市八ツ面町麗77',34.87611,137.07389,null,null,null,'八ツ面山に鎮座する式内社。本殿は重文。','https://ja.wikipedia.org/wiki/久麻久神社','Wikipedia',true,now()),
('sakami-jinja','酒見神社','さかみじんじゃ','shrine','式内社・旧郷社','愛知県','一宮市','愛知県一宮市今伊勢町本神戸字宮山1476',35.315889,136.795194,null,null,null,'倭姫命ゆかりの酒造の神を祀る式内社。','https://ja.wikipedia.org/wiki/酒見神社','Wikipedia',true,now()),
('fujimoto-jinja','藤基神社','ふじもとじんじゃ','shrine','旧県社','新潟県','村上市','新潟県村上市三之町11-12',38.22089306,139.47899111,1717,null,'https://www.fujimotojinja.com/','村上藩主内藤家を祀る。社殿彫刻で知られる。','https://ja.wikipedia.org/wiki/藤基神社','Wikipedia',true,now()),
('seinami-haguro-jinja','西奈彌羽黒神社','せなみはぐろじんじゃ','shrine','旧県社','新潟県','村上市','新潟県村上市羽黒町6-16',38.2175222,139.4782417,null,null,null,'村上大祭で知られる村上総鎮守。','https://ja.wikipedia.org/wiki/西奈彌羽黒神社','Wikipedia',true,now()),
('konzen-ji','金前寺','こんぜんじ','temple','高野山真言宗','福井県','敦賀市','福井県敦賀市金ケ崎町1-4',35.663389,136.076083,736,'十一面観音','https://ja.wikipedia.org/wiki/金前寺','金ヶ崎の袴掛観音として知られる古刹。','https://ja.wikipedia.org/wiki/金前寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kumaku-jinja-nishio' and d.slug in ('susanoo'))
or (t.slug='sakami-jinja' and d.slug in ('amaterasu'))
or (t.slug='fujimoto-jinja' and d.slug in ('naito_clan'))
or (t.slug='seinami-haguro-jinja' and d.slug in ('ukanomitama','tsukuyomi'))
or (t.slug='konzen-ji' and d.slug in ('juichimen_kannon'))
on conflict do nothing;
