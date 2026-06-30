-- 九州・沖縄 追加データ (w7)
-- 対象県: 福岡,佐賀,長崎,熊本,大分,宮崎,鹿児島,沖縄
-- ja.wikipedia.org infobox の十進座標で裏取り

-- ===== batch 1 (1-5) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('izanagi','伊邪那岐命','いざなぎのみこと','kami','天津神','{}','記紀','国生み・神生みを行った男神。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('izanami','伊邪那美命','いざなみのみこと','kami','天津神','{}','記紀','イザナギの妹であり妻。国生みの女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('watatsumi','綿津見三神','わたつみさんじん','kami','国津神','{}','記紀','海を司る底津・中津・表津の綿津見神。','https://ja.wikipedia.org/wiki/ワタツミ','Wikipedia',true,now()),
('tsukushi_no_kami','筑紫神','つくしのかみ','kami','国津神','{}','社伝','筑紫国の国魂神。','https://ja.wikipedia.org/wiki/筑紫神社','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('nyoirin_kannon','如意輪観音','にょいりんかんのん','buddha','菩薩','{}','仏教','如意宝珠と法輪を持つ観音菩薩。','https://ja.wikipedia.org/wiki/如意輪観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='izanagi' and g.slug in ('enmusubi','kanai_anzen','kaiun'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='watatsumi' and g.slug in ('kaijo_anzen','suisan_noko','shobai'))
or (d.slug='tsukushi_no_kami' and g.slug in ('yakubarai','kaiun','suisan_noko'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','byoki_heyu','kaiun'))
or (d.slug='nyoirin_kannon' and g.slug in ('jouju','kaiun','byoki_heyu'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanzeon-ji','観世音寺','かんぜおんじ','temple','天台宗','福岡県','太宰府市','福岡県太宰府市観世音寺五丁目6番1号',33.515028,130.521306,746,'聖観音',null,'天智天皇が母斉明天皇追善のため発願した九州随一の仏教彫刻の宝庫。','https://ja.wikipedia.org/wiki/観世音寺','Wikipedia',true,now()),
('ukishima-jinja','浮島神社','うきしまじんじゃ','shrine','浮島熊野坐神社','熊本県','上益城郡嘉島町','熊本県上益城郡嘉島町井寺2827',32.755667,130.778500,1001,null,'http://www.ukishimajinja.com/','湧水池に浮かぶ島のように見える社。縁結び・安産で知られる。','https://ja.wikipedia.org/wiki/浮島神社_(嘉島町)','Wikipedia',true,now()),
('sairaiin-naha','西来院','さいらいいん','temple','臨済宗妙心寺派','沖縄県','那覇市','沖縄県那覇市首里赤田町1-5-1',26.217667,127.722528,1573,'阿弥陀如来',null,'琉球王朝時代から続く首里十二箇所の一つ。達磨堂で知られる。','https://ja.wikipedia.org/wiki/西来院_(那覇市)','Wikipedia',true,now()),
('shikaumi-jinja','志賀海神社','しかうみじんじゃ','shrine','志賀海神社','福岡県','福岡市','福岡県福岡市東区志賀島877',33.667889,130.313194,null,'https://www.shikaumi-jinja.jp/','全国の綿津見神・海神社の総本社。安曇氏ゆかりの海神。','https://ja.wikipedia.org/wiki/志賀海神社','Wikipedia',true,now()),
('chikushi-jinja','筑紫神社','ちくしじんじゃ','shrine','筑紫神社','福岡県','筑紫野市','福岡県筑紫野市原田2550',33.457000,130.542889,null,null,'筑紫国の国魂を祀る式内名神大社。粥卜祭で知られる。','https://ja.wikipedia.org/wiki/筑紫神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanzeon-ji' and d.slug in ('sho_kannon'))
or (t.slug='ukishima-jinja' and d.slug in ('izanagi','izanami'))
or (t.slug='sairaiin-naha' and d.slug in ('amida_nyorai'))
or (t.slug='shikaumi-jinja' and d.slug in ('watatsumi'))
or (t.slug='chikushi-jinja' and d.slug in ('tsukushi_no_kami'))
on conflict do nothing;

-- ===== batch 2 (6-10) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{}','仏教','千の手で衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','仏教','無限の福徳と智慧を蔵する菩薩。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='senju_kannon' and g.slug in ('jouju','byoki_heyu','kaiun'))
or (d.slug='kokuzo_bosatsu' and g.slug in ('gakugyo','gakumon','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('bairin-ji-kurume','梅林寺','ばいりんじ','temple','臨済宗妙心寺派','福岡県','久留米市','福岡県久留米市京町209',33.323222,130.499500,1621,'如意輪観音',null,'久留米藩主有馬家の菩提寺。厳しい修行で知られる禅刹。','https://ja.wikipedia.org/wiki/梅林寺_(久留米市)','Wikipedia',true,now()),
('takezaki-kanzeon-ji','竹崎観世音寺','たけざきかんぜおんじ','temple','真言宗御室派','佐賀県','藤津郡太良町','佐賀県藤津郡太良町大浦大竹崎248',32.956100,130.218900,null,'千手観音',null,'有明海に臨む古刹。竹崎観音として知られ初詣で賑わう。','https://ja.wikipedia.org/wiki/竹崎観世音寺','Wikipedia',true,now()),
('saikyo-ji-hirado','最教寺','さいきょうじ','temple','真言宗智山派','長崎県','平戸市','長崎県平戸市岩の上町1206-1',33.363222,129.553250,1607,'虚空蔵菩薩',null,'平戸藩主松浦鎮信が創建。西の高野山と称される。','https://ja.wikipedia.org/wiki/最教寺_(平戸市)','Wikipedia',true,now()),
('tobata-hachimangu','飛幡八幡宮','とばたはちまんぐう','shrine','飛幡八幡宮','福岡県','北九州市','福岡県北九州市戸畑区浅生2丁目2-2',33.893556,130.827500,1190,null,'https://tdetode.jimdofree.com/','戸畑の総鎮守。戸畑祇園大山笠の中心となる別表神社。','https://ja.wikipedia.org/wiki/飛幡八幡宮','Wikipedia',true,now()),
('koso-hachimangu','甲宗八幡神社','こうそうはちまんぐう','shrine','甲宗八幡神社','福岡県','北九州市','福岡県北九州市門司区旧門司1丁目7-18',33.952780,130.967780,860,null,'http://www.kosohachimangu.jp/','門司の鎮守。神功皇后の甲を神体とする別表神社。','https://ja.wikipedia.org/wiki/甲宗八幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='bairin-ji-kurume' and d.slug in ('nyoirin_kannon'))
or (t.slug='takezaki-kanzeon-ji' and d.slug in ('senju_kannon'))
or (t.slug='saikyo-ji-hirado' and d.slug in ('kokuzo_bosatsu'))
or (t.slug='tobata-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='koso-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;

-- ===== batch 3 (11-15) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','大国主の子。託宣・商売・漁業の神。恵比寿と習合。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('toyouke','豊受大神','とようけのおおかみ','kami','天津神','{}','記紀','食物・穀物を司る神。伊勢外宮の祭神。','https://ja.wikipedia.org/wiki/トヨウケビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kotoshironushi' and g.slug in ('shobai','suisan_noko','kinun'))
or (d.slug='toyouke' and g.slug in ('shobai','suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanbashira-gu','神柱宮','かんばしらぐう','shrine','神柱宮','宮崎県','都城市','宮崎県都城市前田町1417-1',31.732250,131.072028,1026,null,'https://kanbashira.net/','島津荘の鎮守として創建された都城の総鎮守。別表神社。','https://ja.wikipedia.org/wiki/神柱宮','Wikipedia',true,now()),
('takahashi-inari-jinja','高橋稲荷神社','たかはしいなりじんじゃ','shrine','高橋稲荷神社','熊本県','熊本市','熊本県熊本市西区上代九丁目6-20',32.783000,130.658583,1496,null,null,'日本五大稲荷の一つに数えられる熊本の稲荷社。初午大祭で賑わう。','https://ja.wikipedia.org/wiki/高橋稲荷神社','Wikipedia',true,now()),
('wakamatsu-ebisu-jinja','若松恵比須神社','わかまつえびすじんじゃ','shrine','若松恵比須神社','福岡県','北九州市','福岡県北九州市若松区浜町1丁目2-37',33.905280,130.812780,null,null,'http://wakamatsu-ebisu.jp/','若松の総鎮守。商売繁盛のえびす様として信仰される別表神社。','https://ja.wikipedia.org/wiki/若松恵比須神社','Wikipedia',true,now()),
('nouso-hachimangu','曩祖八幡宮','のうそはちまんぐう','shrine','曩祖八幡宮','福岡県','飯塚市','福岡県飯塚市宮町2-2-3',33.641080,130.684310,null,null,'http://nouso.or.jp/','飯塚の総鎮守。飯塚山笠の中心となる別表神社。','https://ja.wikipedia.org/wiki/曩祖八幡宮','Wikipedia',true,now()),
('otomi-jinja-buzen','大富神社','おおとみじんじゃ','shrine','大富神社','福岡県','豊前市','福岡県豊前市山田256',33.604778,131.101333,671,null,null,'宗像・八幡・住吉の神を祀る豊前の古社。八屋祇園で知られる。','https://ja.wikipedia.org/wiki/大富神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanbashira-gu' and d.slug in ('amaterasu','toyouke'))
or (t.slug='takahashi-inari-jinja' and d.slug in ('ukanomitama'))
or (t.slug='wakamatsu-ebisu-jinja' and d.slug in ('kotoshironushi','okuninushi'))
or (t.slug='nouso-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='otomi-jinja-buzen' and d.slug in ('ichikishima','hachiman','sumiyoshi'))
on conflict do nothing;

-- ===== batch 4 (16-20) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{}','仏教','十一の顔で衆生を見守る観音菩薩。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','病苦を癒す東方瑠璃光浄土の如来。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('sukunahikona','少彦名命','すくなひこなのみこと','kami','国津神','{}','記紀','大国主と国造りを行った医薬・酒造の神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('kunitokotachi','国常立尊','くにのとこたちのみこと','kami','天津神','{}','記紀','天地開闢に現れた根源神。','https://ja.wikipedia.org/wiki/クニノトコタチ','Wikipedia',true,now()),
('ameno_koyane','天児屋根命','あめのこやねのみこと','kami','天津神','{}','記紀','祝詞を司る中臣・藤原氏の祖神。','https://ja.wikipedia.org/wiki/アメノコヤネ','Wikipedia',true,now()),
('jinmu_tenno','神武天皇','じんむてんのう','kami','人神','{}','記紀','初代天皇。日向から東征し橿原で即位した。','https://ja.wikipedia.org/wiki/神武天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='juichimen_kannon' and g.slug in ('jouju','byoki_heyu','yakubarai'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kaiun'))
or (d.slug='sukunahikona' and g.slug in ('byoki_heyu','shobai','choju'))
or (d.slug='kunitokotachi' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='ameno_koyane' and g.slug in ('gakumon','shusse','kaiun'))
or (d.slug='jinmu_tenno' and g.slug in ('kaiun','shobu','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fumon-in-asakura','普門院','ふもんいん','temple','高野山真言宗','福岡県','朝倉市','福岡県朝倉市杷木志波5376',33.373194,130.771333,747,'十一面観音',null,'国宝の本堂を持つ古刹。行基開創と伝わる。','https://ja.wikipedia.org/wiki/普門院_(朝倉市)','Wikipedia',true,now()),
('buzo-ji','武蔵寺','ぶぞうじ','temple','天台宗','福岡県','筑紫野市','福岡県筑紫野市武蔵621',33.489440,130.507833,645,'薬師如来',null,'九州最古と伝わる仏蹟。二日市温泉発祥にまつわる長者伝説で知られる。','https://ja.wikipedia.org/wiki/武蔵寺','Wikipedia',true,now()),
('awashima-jinja-uto','粟嶋神社','あわしまじんじゃ','shrine','粟嶋神社','熊本県','宇土市','熊本県宇土市新開町557',32.699694,130.633667,1633,null,null,'病気平癒を願う日本一小さい鳥居「ミニ鳥居」で有名な社。','https://ja.wikipedia.org/wiki/粟嶋神社_(宇土市)','Wikipedia',true,now()),
('miyahara-sanjingu','宮原三神宮','みやはらさんじんぐう','shrine','宮原三神宮','熊本県','八代郡氷川町','熊本県八代郡氷川町宮原492',32.557986,130.679128,1161,null,null,'伊勢内宮・日吉・下鴨の三社を勧請した氷川町の総鎮守。','https://ja.wikipedia.org/wiki/宮原三神宮','Wikipedia',true,now()),
('nishioka-jingu','西岡神宮','にしおかじんぐう','shrine','西岡神宮','熊本県','宇土市','熊本県宇土市神馬町694',32.678306,130.647972,713,null,null,'宇土地域の総鎮護として創建された春日・八幡・住吉を祀る古社。','https://ja.wikipedia.org/wiki/西岡神宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fumon-in-asakura' and d.slug in ('juichimen_kannon'))
or (t.slug='buzo-ji' and d.slug in ('yakushi_nyorai'))
or (t.slug='awashima-jinja-uto' and d.slug in ('sukunahikona'))
or (t.slug='miyahara-sanjingu' and d.slug in ('amaterasu','kunitokotachi','jinmu_tenno'))
or (t.slug='nishioka-jingu' and d.slug in ('ameno_koyane','hachiman','sumiyoshi'))
on conflict do nothing;

-- ===== batch 5 (21-25) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('susanoo','須佐之男命','すさのおのみこと','kami','天津神','{}','記紀','天照の弟。八岐大蛇退治の英雄神。厄除・祇園信仰の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kushinadahime','櫛名田姫','くしなだひめ','kami','国津神','{}','記紀','須佐之男に救われ妻となった稲田の女神。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('yamato_takeru','日本武尊','やまとたけるのみこと','kami','人神','{}','記紀','景行天皇の皇子。各地を平定した伝説の英雄。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('sarutahiko','猿田彦命','さるたひこのみこと','kami','国津神','{}','記紀','天孫降臨を道案内した道開きの神。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now()),
('amenouzume','天鈿女命','あめのうずめのみこと','kami','天津神','{}','記紀','天岩戸で舞った芸能の女神。猿田彦の妻。','https://ja.wikipedia.org/wiki/アメノウズメ','Wikipedia',true,now()),
('ninigi','邇邇芸命','ににぎのみこと','kami','天津神','{}','記紀','天照の孫。高千穂に降臨した天孫。','https://ja.wikipedia.org/wiki/ニニギ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','shobu'))
or (d.slug='kushinadahime' and g.slug in ('enmusubi','kanai_anzen','suisan_noko'))
or (d.slug='yamato_takeru' and g.slug in ('shobu','kaiun','tabi_anzen'))
or (d.slug='sarutahiko' and g.slug in ('tabi_anzen','kotsu_anzen','kaiun'))
or (d.slug='amenouzume' and g.slug in ('geino','enmusubi','kaiun'))
or (d.slug='ninigi' and g.slug in ('kaiun','suisan_noko','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kushida-gu-kanzaki','櫛田宮','くしだぐう','shrine','櫛田宮','佐賀県','神埼市','佐賀県神埼市神埼町神埼419',33.310167,130.372583,null,null,'神埼の総鎮守。博多櫛田神社の本社とされ、みゆき大祭で知られる。','https://ja.wikipedia.org/wiki/櫛田宮','Wikipedia',true,now()),
('ryuzoji-hachimangu','龍造寺八幡宮','りゅうぞうじはちまんぐう','shrine','龍造寺八幡宮','佐賀県','佐賀市','佐賀県佐賀市白山1丁目3-2',33.255425,130.298531,1187,null,'龍造寺・鍋島両家が崇敬した佐賀城下の鎮守。','https://ja.wikipedia.org/wiki/龍造寺八幡宮','Wikipedia',true,now()),
('aratate-jinja','荒立神社','あらたてじんじゃ','shrine','荒立神社','宮崎県','西臼杵郡高千穂町','宮崎県西臼杵郡高千穂町三田井',32.711722,131.317083,null,null,'猿田彦と天鈿女を祀る高千穂の縁結び・芸能の社。','https://ja.wikipedia.org/wiki/荒立神社','Wikipedia',true,now()),
('kushifuru-jinja','槵觸神社','くしふるじんじゃ','shrine','槵觸神社','宮崎県','西臼杵郡高千穂町','宮崎県西臼杵郡高千穂町三田井',32.710028,131.315583,1694,null,'天孫降臨の地・槵觸峰を神体とする高千穂の古社。','https://ja.wikipedia.org/wiki/槵觸神社','Wikipedia',true,now()),
('kashikuri-jinja','加紫久利神社','かしくりじんじゃ','shrine','加紫久利神社','鹿児島県','出水市','鹿児島県出水市下鯖町1272',32.119639,130.348889,702,null,'薩摩国二宮に列する式内社。出水の総鎮守。','https://ja.wikipedia.org/wiki/加紫久利神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kushida-gu-kanzaki' and d.slug in ('susanoo','kushinadahime','yamato_takeru'))
or (t.slug='ryuzoji-hachimangu' and d.slug in ('hachiman'))
or (t.slug='aratate-jinja' and d.slug in ('sarutahiko','amenouzume'))
or (t.slug='kushifuru-jinja' and d.slug in ('ninigi'))
or (t.slug='kashikuri-jinja' and d.slug in ('amaterasu','susanoo'))
on conflict do nothing;
