-- 中国・四国 社寺データ w8 (担当: 鳥取/島根/岡山/広島/山口/徳島/香川/愛媛/高知)
-- 出典: ja.wikipedia.org の infobox 十進座標で裏取り。座標が無いものは除外。
-- AGENT_SPEC.md 仕様①〜④に準拠。_have_chugoku-shikoku.txt および w6/w7 と重複しない著名社寺のみ。

-- ===== バッチ1 (5件: 岡山×4/広島) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('dakiniten','荼枳尼天','だきにてん','buddha','天部','{最上位経王大菩薩}','仏教','白狐に乗り稲穂を持つ天女形の福徳神。稲荷信仰と習合。','https://ja.wikipedia.org/wiki/荼枳尼天','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{千手千眼観自在菩薩}','仏教','千の手と眼で衆生をあまねく救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('asano_nagamasa','浅野長政','あさのながまさ','kami','御霊','{}','歴史','豊臣政権五奉行筆頭。広島浅野家の祖として祀られる。','https://ja.wikipedia.org/wiki/浅野長政','Wikipedia',true,now()),
('taokihooi','手置帆負命','たおきほおいのみこと','kami','国津神','{}','記紀','工匠・建築を司る神。讃岐忌部の祖神。','https://ja.wikipedia.org/wiki/タオキホオイ','Wikipedia',true,now()),
('hikosashiri','彦狭知命','ひこさしりのみこと','kami','国津神','{}','記紀','手置帆負命とともに建築・木工を司る神。','https://ja.wikipedia.org/wiki/ヒコサシリ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='dakiniten' and g.slug in ('shobai','kinun','kaiun'))
or (d.slug='senju_kannon' and g.slug in ('byoki_heyu','yakubarai','jouju'))
or (d.slug='asano_nagamasa' and g.slug in ('kaiun','shusse'))
or (d.slug='taokihooi' and g.slug in ('shigoto','kanai_anzen'))
or (d.slug='hikosashiri' and g.slug in ('shigoto','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saijo-inari','最上稲荷','さいじょういなり','temple','日蓮宗（最上稲荷山妙教寺）','岡山県','岡山市','岡山県岡山市北区高松稲荷712',34.708956,133.833411,752,'荼枳尼天','https://www.inari.ne.jp/','日本三大稲荷の一つ。神仏習合を今に伝える妙教寺。','https://ja.wikipedia.org/wiki/最上稲荷','Wikipedia',true,now()),
('yuga-jinja-honguu','由加神社本宮','ゆがじんじゃほんぐう','shrine','旧県社','岡山県','倉敷市','岡山県倉敷市児島由加2852',34.505917,133.851056,733,null,'https://www.yugasan.or.jp/','瑜伽山に鎮座する厄除けの古社。讃岐金刀比羅宮との両参りで知られる。','https://ja.wikipedia.org/wiki/由加神社本宮','Wikipedia',true,now()),
('saidaiji-kannon-in','西大寺観音院','さいだいじかんのんいん','temple','高野山真言宗別格本山','岡山県','岡山市','岡山県岡山市東区西大寺中3丁目8-8',34.653610,134.038028,777,'千手観音','https://www.saidaiji.jp/','日本三大奇祭「会陽（はだか祭り）」で名高い古刹。','https://ja.wikipedia.org/wiki/西大寺_(岡山市)','Wikipedia',true,now()),
('raikyuu-ji','頼久寺','らいきゅうじ','temple','臨済宗永源寺派','岡山県','高梁市','岡山県高梁市頼久寺町18',34.797417,133.618944,1339,'聖観音','https://raikyuji.com/','小堀遠州作の枯山水庭園（国名勝）で知られる備中の禅刹。','https://ja.wikipedia.org/wiki/頼久寺','Wikipedia',true,now()),
('nigitsu-jinja','饒津神社','にぎつじんじゃ','shrine','旧県社','広島県','広島市','広島県広島市東区二葉の里2丁目6-34',34.405028,132.469917,1835,null,'https://www.nigitsu.jp/','広島藩主浅野家の祖を祀る。被爆復興した二葉の里の鎮守。','https://ja.wikipedia.org/wiki/饒津神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saijo-inari' and d.slug in ('dakiniten'))
or (t.slug='yuga-jinja-honguu' and d.slug in ('taokihooi','hikosashiri'))
or (t.slug='saidaiji-kannon-in' and d.slug in ('senju_kannon'))
or (t.slug='raikyuu-ji' and d.slug in ('sho_kannon'))
or (t.slug='nigitsu-jinja' and d.slug in ('asano_nagamasa'))
on conflict do nothing;

-- ===== バッチ2 (5件: 広島/山口×2/岡山×2) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('antoku_tenno','安徳天皇','あんとくてんのう','kami','御霊','{}','歴史','第81代天皇。壇ノ浦の戦いで幼くして入水。','https://ja.wikipedia.org/wiki/安徳天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='antoku_tenno' and g.slug in ('kaijo_anzen','suisan_noko','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mitsugi-hachimangu','御調八幡宮','みつぎはちまんぐう','shrine','旧県社','広島県','三原市','広島県三原市八幡町宮内13',34.471361,133.081056,777,null,null,'和気清麻呂ゆかりの備後の八幡宮。重要文化財の行道面を伝える。','https://ja.wikipedia.org/wiki/御調八幡宮','Wikipedia',true,now()),
('akama-jingu','赤間神宮','あかまじんぐう','shrine','旧官幣大社','山口県','下関市','山口県下関市阿弥陀寺町4-1',33.959722,130.948472,859,null,'https://www.tenkaibou.jp/akama/','壇ノ浦で入水した安徳天皇を祀る。耳なし芳一の舞台。','https://ja.wikipedia.org/wiki/赤間神宮','Wikipedia',true,now()),
('kanyou-ji','漢陽寺','かんようじ','temple','臨済宗南禅寺派','山口県','周南市','山口県周南市鹿野上2872',34.235500,131.815083,1374,'聖観音','https://kanyouji.com/','重森三玲ゆかりの庭園と精進料理で知られる鹿野の禅刹。','https://ja.wikipedia.org/wiki/漢陽寺','Wikipedia',true,now()),
('goryu-sonryuin','五流尊瀧院','ごりゅうそんりゅういん','temple','修験道（児島五流）','岡山県','倉敷市','岡山県倉敷市林952',34.536694,133.818861,701,'十一面観音','https://www.goryusonryuin.com/','熊野信仰を伝える児島修験の総本山。後鳥羽上皇供養塔を残す。','https://ja.wikipedia.org/wiki/五流尊瀧院','Wikipedia',true,now()),
('kanryu-ji-kurashiki','観龍寺','かんりゅうじ','temple','真言宗御室派別格本山','岡山県','倉敷市','岡山県倉敷市阿知2丁目25-22',34.598028,133.771722,985,null,null,'倉敷美観地区を見下ろす鶴形山上の古刹。','https://ja.wikipedia.org/wiki/観龍寺_(倉敷市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mitsugi-hachimangu' and d.slug in ('hachiman'))
or (t.slug='akama-jingu' and d.slug in ('antoku_tenno'))
or (t.slug='kanyou-ji' and d.slug in ('sho_kannon'))
or (t.slug='goryu-sonryuin' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- ===== バッチ3 (5件: 徳島/香川/愛媛/高知×2) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yamatototohimomoso','倭迹々日百襲姫命','やまとととひももそひめのみこと','kami','御霊','{倭迹迹日百襲姫命}','記紀','崇神朝の巫女的皇女。水神・農耕信仰と結びつく。','https://ja.wikipedia.org/wiki/ヤマトトトヒモモソヒメ','Wikipedia',true,now()),
('ichijo_norifusa','一条教房','いちじょうのりふさ','kami','御霊','{土佐一条氏}','歴史','応仁の乱を避け中村に下向した公卿。土佐一条氏の祖。','https://ja.wikipedia.org/wiki/一条教房','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yamatototohimomoso' and g.slug in ('mizu_amagoi','suisan_noko','kaiun'))
or (d.slug='ichijo_norifusa' and g.slug in ('gakumon','kaiun','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('bizan-tenjinja','眉山天神社','びざんてんじんじゃ','shrine','旧県社','徳島県','徳島市','徳島県徳島市眉山町天神山1',34.069778,134.544611,1809,null,null,'眉山の麓に鎮座する菅原道真を祀る学問の社。','https://ja.wikipedia.org/wiki/眉山天神社','Wikipedia',true,now()),
('minushi-jinja','水主神社','みぬしじんじゃ','shrine','旧県社','香川県','東かがわ市','香川県東かがわ市水主1418-1',34.223889,134.298889,null,null,null,'倭迹々日百襲姫命を祀る讃岐の式内社。水主三山の古社。','https://ja.wikipedia.org/wiki/水主神社_(東かがわ市)','Wikipedia',true,now()),
('enmyo-ji-matsuyama','圓明寺','えんみょうじ','temple','真言宗智山派','愛媛県','松山市','愛媛県松山市和気町1丁目182',33.891750,132.739667,749,'阿弥陀如来','https://ja.wikipedia.org/wiki/圓明寺','四国八十八箇所第53番札所。キリシタン灯籠を残す。','https://ja.wikipedia.org/wiki/圓明寺','Wikipedia',true,now()),
('fuba-hachimangu','不破八幡宮','ふばはちまんぐう','shrine','旧県社','高知県','四万十市','高知県四万十市不破1392',32.980789,132.937431,1470,null,null,'土佐一条氏が勧請した幡多郷の総鎮守。秋祭りの神様の結婚式で有名。','https://ja.wikipedia.org/wiki/不破八幡宮','Wikipedia',true,now()),
('ichijo-jinja','一條神社','いちじょうじんじゃ','shrine','旧県社','高知県','四万十市','高知県四万十市中村本町1丁目3',32.993614,132.934217,1862,null,'https://ichijyo-jinjya.jp/','土佐一条氏歴代を祀る中村御所跡の社。「いちじょこさん」。','https://ja.wikipedia.org/wiki/一條神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='bizan-tenjinja' and d.slug in ('michizane'))
or (t.slug='minushi-jinja' and d.slug in ('yamatototohimomoso'))
or (t.slug='enmyo-ji-matsuyama' and d.slug in ('amida_nyorai'))
or (t.slug='fuba-hachimangu' and d.slug in ('hachiman','tamayori'))
or (t.slug='ichijo-jinja' and d.slug in ('ichijo_norifusa'))
on conflict do nothing;

-- ===== バッチ4 (5件: 岡山/広島×2/島根/山口) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenohohi','天穂日命','あめのほひのみこと','kami','天津神','{天菩比命}','記紀','天照大神の第二子。出雲国造・土師氏の祖神。','https://ja.wikipedia.org/wiki/アメノホヒ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenohohi' and g.slug in ('shobai','kaiun','suisan_noko'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('anyo-ji-kurashiki','安養寺','あんようじ','temple','高野山真言宗','岡山県','倉敷市','岡山県倉敷市浅原1573',34.635972,133.758972,782,'毘沙門天','https://ja.wikipedia.org/wiki/安養寺_(倉敷市)','朝原山の古刹。平安期の毘沙門天像（重文）と中四国最大級の梵鐘で知られる。','https://ja.wikipedia.org/wiki/安養寺_(倉敷市)','Wikipedia',true,now()),
('kosan-ji','耕三寺','こうさんじ','temple','浄土真宗本願寺派','広島県','尾道市','広島県尾道市瀬戸田町瀬戸田553-2',34.303750,133.090278,1936,'阿弥陀如来','https://www.kousanji.or.jp/','日本各地の名建築を模した堂塔が並ぶ「西の日光」。大理石庭園で有名。','https://ja.wikipedia.org/wiki/耕三寺','Wikipedia',true,now()),
('noki-jinja','能義神社','のきじんじゃ','shrine','旧県社','島根県','安来市','島根県安来市能義町366',35.399500,133.218400,null,null,null,'天穂日命を祀る出雲四大神の一社。能義郡の総鎮守。','https://ja.wikipedia.org/wiki/能義神社','Wikipedia',true,now()),
('waseda-jinja-hiroshima','早稲田神社','わせだじんじゃ','shrine','旧村社','広島県','広島市','広島県広島市東区牛田早稲田1丁目2-22',34.413694,132.475111,1511,null,null,'牛田の丘に鎮座する八幡神社。勝負・武運の神として崇敬される。','https://ja.wikipedia.org/wiki/早稲田神社_(広島市)','Wikipedia',true,now()),
('toishi-hachimangu','遠石八幡宮','といしはちまんぐう','shrine','旧県社','山口県','周南市','山口県周南市遠石2丁目3-1',34.039722,131.823111,622,null,'http://www.toishi.co.jp/','徳山湾を望む丘に鎮座する周防の八幡宮。宇佐八幡の分霊を祀る。','https://ja.wikipedia.org/wiki/遠石八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='anyo-ji-kurashiki' and d.slug in ('bishamonten'))
or (t.slug='kosan-ji' and d.slug in ('amida_nyorai'))
or (t.slug='noki-jinja' and d.slug in ('amenohohi'))
or (t.slug='waseda-jinja-hiroshima' and d.slug in ('hachiman'))
or (t.slug='toishi-hachimangu' and d.slug in ('hachiman'))
on conflict do nothing;

-- ===== バッチ5 (5件: 鳥取/愛媛×2/高知/徳島) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takaoshihime','高忍日賣大神','たかおしひめのおおかみ','kami','国津神','{}','記紀','産婆・乳母の祖神。安産・子育てを司る全国唯一の祭神。','https://ja.wikipedia.org/wiki/高忍日賣神社','Wikipedia',true,now()),
('ushihiko','宇志比古尊','うしひこのみこと','kami','国津神','{}','記紀','阿波・鳴門の在地神。宇志比古神社の主祭神。','https://ja.wikipedia.org/wiki/宇志比古神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takaoshihime' and g.slug in ('anzan','kosodate','byoki_heyu'))
or (d.slug='ushihiko' and g.slug in ('kanai_anzen','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hahaki-jinja','波波伎神社','ははきじんじゃ','shrine','旧県社','鳥取県','倉吉市','鳥取県倉吉市福庭654',35.465306,133.854194,null,null,null,'八重事代主命を祀る伯耆の式内社。国天然記念物の社叢で知られる。','https://ja.wikipedia.org/wiki/波波伎神社','Wikipedia',true,now()),
('mitsu-itsukushima-jinja','三津厳島神社','みついつくしまじんじゃ','shrine','旧郷社','愛媛県','松山市','愛媛県松山市神田町1-7',33.860830,132.718610,null,null,null,'松山三津の鎮守。宗像三女神を祀り、秋祭りの虎舞で有名。','https://ja.wikipedia.org/wiki/三津厳島神社','Wikipedia',true,now()),
('takaoshihime-jinja','高忍日賣神社','たかおしひめじんじゃ','shrine','旧県社','愛媛県','伊予郡松前町','愛媛県伊予郡松前町徳丸387',33.789583,132.760280,null,null,null,'産婆・乳母の祖神を祀る全国唯一の式内社。安産信仰で知られる。','https://ja.wikipedia.org/wiki/高忍日賣神社','Wikipedia',true,now()),
('sugimoto-jinja','椙本神社','すぎもとじんじゃ','shrine','旧郷社','高知県','吾川郡いの町','高知県吾川郡いの町大国町3093',33.550528,133.421000,793,null,null,'仁淀川のほとりに鎮座する「土佐の大国さま」。日本三大裸祭りの一。','https://ja.wikipedia.org/wiki/椙本神社','Wikipedia',true,now()),
('ushihiko-jinja','宇志比古神社','うしひこじんじゃ','shrine','旧郷社','徳島県','鳴門市','徳島県鳴門市大麻町大谷字山田66',34.161806,134.536889,null,null,null,'徳島県最古の神社本殿（重文）を残す鳴門大谷の古社。','https://ja.wikipedia.org/wiki/宇志比古神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hahaki-jinja' and d.slug in ('kotoshironushi'))
or (t.slug='mitsu-itsukushima-jinja' and d.slug in ('ichikishima'))
or (t.slug='takaoshihime-jinja' and d.slug in ('takaoshihime'))
or (t.slug='sugimoto-jinja' and d.slug in ('okuninushi'))
or (t.slug='ushihiko-jinja' and d.slug in ('ushihiko','hachiman'))
on conflict do nothing;

-- ===== バッチ6 (5件: 山口×2/高知/広島/岡山) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takamimusubi','高皇産霊神','たかみむすひのかみ','kami','天津神','{高御産巣日神,高木神}','記紀','造化三神の一柱。万物の生成を司る根源神。','https://ja.wikipedia.org/wiki/タカミムスビ','Wikipedia',true,now()),
('kido_takayoshi','木戸孝允','きどたかよし','kami','御霊','{桂小五郎}','歴史','長州藩出身の維新三傑の一人。','https://ja.wikipedia.org/wiki/木戸孝允','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takamimusubi' and g.slug in ('kaiun','jouju','shusse'))
or (d.slug='kido_takayoshi' and g.slug in ('gakumon','shusse','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nisho-yamada-jinja','二所山田神社','にしょやまだじんじゃ','shrine','旧郷社','山口県','周南市','山口県周南市鹿野下2894',34.234161,131.816800,899,null,null,'全国のおみくじの約7割を奉製する社。女性宮司の先駆けでも知られる。','https://ja.wikipedia.org/wiki/二所山田神社','Wikipedia',true,now()),
('katsurakio-jinja','葛木男神社','かつらきおじんじゃ','shrine','旧郷社','高知県','高知市','高知県高知市布師田1358',33.588225,133.601592,null,null,null,'高皇産霊神を祀る土佐の式内社。布師田の総鎮守。','https://ja.wikipedia.org/wiki/葛木男神社','Wikipedia',true,now()),
('suga-jinja-akitakata','清神社','すがじんじゃ','shrine','旧県社','広島県','安芸高田市','広島県安芸高田市吉田町吉田477',34.669972,132.705667,null,null,null,'須佐之男命を祀る古社。毛利氏吉田郡山城の鎮守として崇敬された。','https://ja.wikipedia.org/wiki/清神社','Wikipedia',true,now()),
('kumano-jinja-kurashiki','熊野神社','くまのじんじゃ','shrine','旧郷社','岡山県','倉敷市','岡山県倉敷市林684',34.540278,133.819806,701,null,null,'「日本第一熊野十二社権現」を称する児島の古社。重文の第二殿を残す。','https://ja.wikipedia.org/wiki/熊野神社_(倉敷市林)','Wikipedia',true,now()),
('kido-jinja','木戸神社','きどじんじゃ','shrine','旧無格社','山口県','山口市','山口県山口市糸米2丁目9',34.177778,131.461111,1886,null,null,'維新三傑・木戸孝允を祀る社。遺言の寄付が村の教育を支えた。','https://ja.wikipedia.org/wiki/木戸神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nisho-yamada-jinja' and d.slug in ('okuninushi'))
or (t.slug='katsurakio-jinja' and d.slug in ('takamimusubi'))
or (t.slug='suga-jinja-akitakata' and d.slug in ('susanoo'))
or (t.slug='kumano-jinja-kurashiki' and d.slug in ('izanami','izanagi'))
or (t.slug='kido-jinja' and d.slug in ('kido_takayoshi'))
on conflict do nothing;

-- ===== バッチ7 (1件: 山口) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yoshida_shoin','吉田松陰','よしだしょういん','kami','御霊','{吉田寅次郎}','歴史','幕末長州の思想家・教育者。松下村塾で維新の志士を育てた。','https://ja.wikipedia.org/wiki/吉田松陰','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yoshida_shoin' and g.slug in ('gakumon','gakugyo','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sakurayama-jinja-shimonoseki','櫻山神社','さくらやまじんじゃ','shrine','旧県社','山口県','下関市','山口県下関市上新地町2丁目6-22',33.961250,130.920417,1864,null,null,'高杉晋作の発議による招魂社の魁。吉田松陰ら維新志士391柱を祀る。','https://ja.wikipedia.org/wiki/櫻山神社_(下関市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sakurayama-jinja-shimonoseki' and d.slug in ('yoshida_shoin'))
on conflict do nothing;
