-- w6-kyushu-b.sql
-- 担当県: 大分県・宮崎県・鹿児島県・沖縄県
-- 出典: ja.wikipedia.org の infobox 十進座標で裏取り
-- 既存(_have_kyushu-okinawa.txt)・パイロット12社寺と重複しないもののみ

-- =========================================================
-- ① 新規神仏
-- =========================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('izanagi','伊邪那岐命','いざなぎのみこと','kami','天津神','{}','記紀','国生み・神生みを行った男神。禊によって三貴子を生んだ。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('izanami','伊邪那美命','いざなみのみこと','kami','天津神','{}','記紀','イザナギとともに国生み・神生みを行った女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('oyamatsumi','大山祇神','おおやまつみのかみ','kami','国津神','{}','記紀','山を司る神。神々の祖神格。','https://ja.wikipedia.org/wiki/オオヤマツミ','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏典','東方浄瑠璃世界の教主。病気平癒・除災の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('monju_bosatsu','文殊菩薩','もんじゅぼさつ','buddha','菩薩','{}','仏典','智慧を司る菩薩。学業成就の信仰を集める。','https://ja.wikipedia.org/wiki/文殊菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- =========================================================
-- ② 新規神仏の司るご利益
-- =========================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','yakubarai'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='oyamatsumi' and g.slug in ('kaiun','shobai','yakubarai'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','yakubarai'))
or (d.slug='monju_bosatsu' and g.slug in ('gakugyo','gakumon','kaiun'))
on conflict do nothing;

-- =========================================================
-- ③ 社寺  /  ④ 御祭神・本尊の紐付け
-- =========================================================

-- [宮崎] 霧島東神社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kirishima-higashi-jinja','霧島東神社','きりしまひがしじんじゃ','shrine','旧県社','宮崎県','西諸県郡高原町','宮崎県西諸県郡高原町祓川',31.891833,130.962056,null,null,null,'高千穂峰東麓に鎮座する霧島六社権現の一社。山頂の天之逆鉾を社宝とする。','https://ja.wikipedia.org/wiki/霧島東神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kirishima-higashi-jinja' and d.slug in ('izanagi','izanami'))
on conflict do nothing;

-- [宮崎] 大御神社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oomi-jinja','大御神社','おおみじんじゃ','shrine','旧無格社','宮崎県','日向市','宮崎県日向市日知屋1番地',32.411000,131.649417,null,null,'https://oomijinja.com/','「日向のお伊勢さま」と称される日向灘を望む神社。日本最大級のさざれ石群で知られる。','https://ja.wikipedia.org/wiki/大御神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oomi-jinja' and d.slug in ('amaterasu'))
on conflict do nothing;

-- [宮崎] 神門神社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mikado-jinja','神門神社','みかどじんじゃ','shrine','旧県社','宮崎県','東臼杵郡美郷町','宮崎県東臼杵郡美郷町南郷神門69-2',32.386000,131.330944,718,null,null,'百済王伝説「師走祭り」で知られる古社。本殿は国の重要文化財。','https://ja.wikipedia.org/wiki/神門神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mikado-jinja' and d.slug in ('oyamatsumi','ukanomitama','hachiman'))
on conflict do nothing;

-- [宮崎] 住吉神社（宮崎市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sumiyoshi-jinja-miyazaki','住吉神社','すみよしじんじゃ','shrine','旧県社','宮崎県','宮崎市','宮崎県宮崎市塩路3082',31.982500,131.476833,null,null,null,'全国の住吉神社の元宮を称する古社。住吉三神を祀る。','https://ja.wikipedia.org/wiki/住吉神社_(宮崎市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sumiyoshi-jinja-miyazaki' and d.slug in ('sumiyoshi'))
on conflict do nothing;

-- [鹿児島] 泰平寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('taiheiji-satsumasendai','泰平寺','たいへいじ','temple','真言宗','鹿児島県','薩摩川内市','鹿児島県薩摩川内市大小路町48-37',31.824472,130.305361,708,'薬師如来','http://www1.bbiq.jp/shio/index.html','和銅元年開創と伝わる古刹。豊臣秀吉の島津征伐の和睦の地として知られる。','https://ja.wikipedia.org/wiki/泰平寺_(薩摩川内市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='taiheiji-satsumasendai' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- ===== 追加神仏 (batch 2) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏典','西方極楽浄土の教主。浄土信仰の本尊。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amida_nyorai' and g.slug in ('jouju','choju','kaiun'))
on conflict do nothing;

-- [鹿児島] 妙円寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('myoenji-hioki','妙円寺','みょうえんじ','temple','曹洞宗','鹿児島県','日置市','鹿児島県日置市伊集院町徳重521番地',31.632306,130.392780,1390,'釈迦如来','https://myoenji.jp/','島津義弘の菩提寺。「妙円寺詣り」で知られ、節分祭は県内有数の賑わい。','https://ja.wikipedia.org/wiki/妙円寺_(日置市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- [沖縄] 出雲大社沖縄分社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('izumo-taisha-okinawa','出雲大社沖縄分社','いずもおおやしろおきなわぶんしゃ','shrine','出雲大社教','沖縄県','那覇市','沖縄県那覇市古島1-16-13',26.230111,127.703528,null,null,null,'国内最南西端の出雲大社分社。縁結びの神大国主命を祀る。','https://ja.wikipedia.org/wiki/出雲大社沖縄分社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='izumo-taisha-okinawa' and d.slug in ('okuninushi'))
on conflict do nothing;

-- [大分] 文殊仙寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('monjusenji-kunisaki','文殊仙寺','もんじゅせんじ','temple','天台宗','大分県','国東市','大分県国東市国東町大恩寺2432',33.602469,131.613875,648,'文殊菩薩','http://www.monjyusenji.com/','「三人寄れば文殊の智恵」発祥の地とされる六郷満山の古刹。','https://ja.wikipedia.org/wiki/文殊仙寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='monjusenji-kunisaki' and d.slug in ('monju_bosatsu'))
on conflict do nothing;

-- [大分] 浄土寺（大分市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jodoji-oita','浄土寺','じょうどじ','temple','浄土宗','大分県','大分市','大分県大分市王子西町',33.242750,131.588639,1501,'阿弥陀如来','https://www.joudoji.com','松平忠直の墓所を有する浄土宗寺院。七棟が登録有形文化財。','https://ja.wikipedia.org/wiki/浄土寺_(大分市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jodoji-oita' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [沖縄] 護国寺（那覇市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('gokokuji-naha','護国寺','ごこくじ','temple','高野山真言宗','沖縄県','那覇市','沖縄県那覇市若狭1-25-5',26.220050,127.671590,1368,'聖観世音菩薩','http://w1.nirai.ne.jp/njm/','沖縄県最古の寺院。波上宮の神宮寺として創建された琉球真言宗の中心。','https://ja.wikipedia.org/wiki/護国寺_(那覇市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='gokokuji-naha' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- ===== 追加神仏 (batch 3) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('toyotamahime','豊玉姫命','とよたまひめのみこと','kami','国津神','{}','記紀','海神の娘。山幸彦の妃で鵜葺草葺不合命の母。安産の神。','https://ja.wikipedia.org/wiki/トヨタマビメ','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','八岐大蛇退治で知られる荒ぶる神。厄除け・疫病除けの神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('nejime_shigenaga','禰寝重長','ねじめしげなが','kami','御霊','{}','史実','大隅の戦国武将。鬼丸神社に御霊として祀られる。','https://ja.wikipedia.org/wiki/禰寝重長','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='toyotamahime' and g.slug in ('anzan','kosodate','enmusubi'))
or (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','shobu'))
or (d.slug='nejime_shigenaga' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;

-- [鹿児島] 川上天満宮
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kawakami-tenmangu','川上天満宮','かわかみてんまんぐう','shrine','旧郷社','鹿児島県','鹿児島市','鹿児島県鹿児島市川上町834',31.655000,130.552500,null,null,'https://kawakamitenmangu.wixsite.com/main','島津貞久が北野天満宮より勧請した菅原道真を祀る天神。','https://ja.wikipedia.org/wiki/川上天満宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kawakami-tenmangu' and d.slug in ('michizane'))
on conflict do nothing;

-- [鹿児島] 豊玉姫神社（南九州市・知覧）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('toyotamahime-jinja-chiran','豊玉姫神社','とよたまひめじんじゃ','shrine','旧県社','鹿児島県','南九州市','鹿児島県南九州市知覧町郡16510',31.372972,130.431000,null,null,'http://www.toyotamahime-jinja.or.jp/','知覧の総鎮守。七夕の水車からくり人形(県無形民俗文化財)で知られる。','https://ja.wikipedia.org/wiki/豊玉姫神社_(南九州市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='toyotamahime-jinja-chiran' and d.slug in ('toyotamahime'))
on conflict do nothing;

-- [宮崎] 椎葉厳島神社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shiiba-itsukushima-jinja','椎葉厳島神社','しいばいつくしまじんじゃ','shrine','旧村社','宮崎県','東臼杵郡椎葉村','宮崎県東臼杵郡椎葉村大字下福良1822',32.463833,131.154694,null,null,null,'平家落人伝説と鶴富姫の物語で知られる椎葉村の古社。','https://ja.wikipedia.org/wiki/椎葉厳島神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shiiba-itsukushima-jinja' and d.slug in ('ichikishima','susanoo'))
on conflict do nothing;

-- [鹿児島] 大慈寺（志布志市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daijiji-shibushi','大慈寺','だいじじ','temple','臨済宗妙心寺派','鹿児島県','志布志市','鹿児島県志布志市志布志町',31.476872,131.098656,1340,null,null,'日明貿易にも関わった薩摩の名刹。室町期には十刹の一に数えられた禅寺。','https://ja.wikipedia.org/wiki/大慈寺_(志布志市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- [鹿児島] 鬼丸神社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('onimaru-jinja','鬼丸神社','おにまるじんじゃ','shrine','旧村社','鹿児島県','日置市','鹿児島県日置市日吉町吉利4827',31.589440,130.341583,1580,null,null,'戦国武将禰寝重長を祀る。豊作祈願の奇祭「せっぺとべ」で知られる。','https://ja.wikipedia.org/wiki/鬼丸神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='onimaru-jinja' and d.slug in ('nejime_shigenaga'))
on conflict do nothing;

-- ===== 追加神仏 (batch 4) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('fugen_bosatsu','普賢菩薩','ふげんぼさつ','buddha','菩薩','{}','仏典','理知・修行を司る菩薩。白象に乗る姿で表される。','https://ja.wikipedia.org/wiki/普賢菩薩','Wikipedia',true,now()),
('takeo_shimogori_hiko','健男霜凝日子大神','たけおしもごりひこのおおかみ','kami','国津神','{}','記紀・地誌','祖母山を神体とする豊後の山岳神。式内社の祭神。','https://ja.wikipedia.org/wiki/健男霜凝日子神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='fugen_bosatsu' and g.slug in ('choju','gakugyo','kaiun'))
or (d.slug='takeo_shimogori_hiko' and g.slug in ('kaiun','yakubarai','anzan'))
on conflict do nothing;

-- [大分] 古要神社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('koyo-jinja','古要神社','こようじんじゃ','shrine','旧郷社','大分県','中津市','大分県中津市伊藤田3535',33.553972,131.233111,null,null,null,'傀儡子の舞と神相撲(国重要無形民俗文化財)で知られる古社。','https://ja.wikipedia.org/wiki/古要神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='koyo-jinja' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;

-- [大分] 普現寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fugenji-usuki','普現寺','ふげんじ','temple','臨済宗妙心寺派','大分県','臼杵市','大分県臼杵市野津町大字野津市1346',33.039472,131.691694,1294,'普賢菩薩',null,'峩嵋山普現禅寺。約200本の紅葉で知られ大分百景に選定。吉四六の墓所。','https://ja.wikipedia.org/wiki/普現寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fugenji-usuki' and d.slug in ('fugen_bosatsu'))
on conflict do nothing;

-- [沖縄] 桃林寺（石垣市）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tourinji-ishigaki','桃林寺','とうりんじ','temple','臨済宗妙心寺派','沖縄県','石垣市','沖縄県石垣市石垣285',24.343778,124.155694,1614,'観音菩薩','https://www.tourinji.net/','八重山列島最古の仏教寺院。隣接の権現堂は国の重要文化財。','https://ja.wikipedia.org/wiki/桃林寺_(石垣市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tourinji-ishigaki' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- [沖縄] 金武観音寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kin-kannonji','金武観音寺','きんかんのんじ','temple','高野山真言宗','沖縄県','国頭郡金武町','沖縄県国頭郡金武町金武222',26.455319,127.921450,null,'観音菩薩',null,'金峯山金武観音寺。日秀上人開基。沖縄に残る数少ない戦前の木造建築。','https://ja.wikipedia.org/wiki/金武観音寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kin-kannonji' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- [大分] 健男霜凝日子神社
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takeo-shimogori-hiko-jinja','健男霜凝日子神社','たけおしもごりひこじんじゃ','shrine','旧県社','大分県','竹田市','大分県竹田市神原1822',32.873000,131.356389,651,null,null,'祖母山を神体とする豊後国式内社。下宮・上宮・穴森社からなる山岳信仰の古社。','https://ja.wikipedia.org/wiki/健男霜凝日子神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takeo-shimogori-hiko-jinja' and d.slug in ('takeo_shimogori_hiko'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='takeo-shimogori-hiko-jinja' and d.slug in ('toyotamahime'))
on conflict do nothing;
