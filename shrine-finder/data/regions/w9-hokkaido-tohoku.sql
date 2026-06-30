-- w9 北海道・東北 追加データ（実在・Wikipedia infobox 裏取り）
-- 既存の deity slug は再定義しない。新規神仏のみ ① で定義。

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('iyahiko','伊夜日子大神','いやひこのおおかみ','kami','天津神','{}','記紀・越後一宮','天香山命と同一とされる越後弥彦の祖神。開拓・産業の神。','https://ja.wikipedia.org/wiki/野幌神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='iyahiko' and g.slug in ('kaiun','shobai','suisan_noko'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('otaru-sumiyoshi-jinja','住吉神社（小樽）','すみよしじんじゃ','shrine','旧県社・別表神社','北海道','小樽市','北海道小樽市住ノ江2-5-1',43.182944,141.003222,1868,null,'http://www.otarusumiyoshijinja.or.jp/','小樽総鎮守。住吉三神と神功皇后を祀る別表神社。','https://ja.wikipedia.org/wiki/住吉神社_(小樽市)','Wikipedia',true,now()),
('nopporo-jinja','野幌神社','のっぽろじんじゃ','shrine','旧村社','北海道','江別市','北海道江別市西野幌155',43.062500,141.544722,1891,null,null,'新潟県からの開拓者が創建。天照大神・大国主・伊夜日子大神を祀る。','https://ja.wikipedia.org/wiki/野幌神社','Wikipedia',true,now()),
('matsumae-gokoku-jinja','松前護國神社','まつまえごこくじんじゃ','shrine','護国神社','北海道','松前郡松前町','北海道松前郡松前町豊岡',41.441389,140.116944,1869,null,null,'箱館戦争などで国に殉じた人々の神霊を祀る道内最古級の招魂社。','https://ja.wikipedia.org/wiki/松前護國神社','Wikipedia',true,now()),
('tokachi-jinja','十勝神社','とかちじんじゃ','shrine','旧県社','北海道','広尾郡広尾町','北海道広尾郡広尾町茂寄1-13',42.291083,143.310889,1666,null,null,'十勝地方の一宮を称する古社。海・食物・塩の神を祀る。','https://ja.wikipedia.org/wiki/十勝神社','Wikipedia',true,now()),
('shintotsukawa-jinja','新十津川神社','しんとつかわじんじゃ','shrine','旧県社','北海道','樺戸郡新十津川町','北海道樺戸郡新十津川町中央37',43.571444,141.869528,1891,null,null,'奈良・玉置神社の分社として創建。国常立尊ら五柱を祀る。','https://ja.wikipedia.org/wiki/新十津川神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='otaru-sumiyoshi-jinja' and d.slug in ('sumiyoshi','jingu_kogo')) or
   (t.slug='nopporo-jinja' and d.slug in ('amaterasu','okuninushi','iyahiko')) or
   (t.slug='matsumae-gokoku-jinja' and d.slug in ('gokoku_eirei')) or
   (t.slug='tokachi-jinja' and d.slug in ('watatsumi','ukemochi','shiozuchi')) or
   (t.slug='shintotsukawa-jinja' and d.slug in ('kunitokotachi','izanagi','izanami','amaterasu','jinmu'))
on conflict do nothing;

-- === batch2 (Yamagata) ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('eboshiyama-hachimangu','烏帽子山八幡宮','えぼしやまはちまんぐう','shrine','旧県社','山形県','南陽市','山形県南陽市赤湯1415',38.051417,140.167306,1093,null,'https://www.ne.jp/asahi/eboshiyama/hachimangu/','日本最大級の一本石鳥居で知られる赤湯総鎮守。','https://ja.wikipedia.org/wiki/烏帽子山八幡宮','Wikipedia',true,now()),
('sagae-hachimangu','寒河江八幡宮','さがえはちまんぐう','shrine','旧県社','山形県','寒河江市','山形県寒河江市八幡町5-70',38.378278,140.270750,1093,null,'http://www.sagae-hachimangu.org/','前九年の役の戦勝を機に石清水八幡を勧請した寒河江総鎮守。','https://ja.wikipedia.org/wiki/寒河江八幡宮','Wikipedia',true,now()),
('kinowa-jinja','城輪神社','きのわじんじゃ','shrine','式内社','山形県','酒田市','山形県酒田市城輪字表物忌35',38.966389,139.910139,712,null,null,'城輪柵の鎮守と伝わる式内社。倉稲魂命を祀る。','https://ja.wikipedia.org/wiki/城輪神社','Wikipedia',true,now()),
('kinbo-jinja-tsuruoka','金峯神社（鶴岡）','きんぼうじんじゃ','shrine','旧県社','山形県','鶴岡市','山形県鶴岡市大字青龍寺字金峯1',38.678853,139.805553,808,null,'https://www.kinbo.info/','金峯山を神体とする古社。少彦名神ら四柱を祀る。','https://ja.wikipedia.org/wiki/金峯神社_(鶴岡市)','Wikipedia',true,now()),
('ayukai-hachimangu','鮎貝八幡宮','あゆかいはちまんぐう','shrine','旧県社','山形県','西置賜郡白鷹町','山形県西置賜郡白鷹町鮎貝2303-2',38.190194,140.075722,1060,null,null,'源義家が八幡神を勧請したと伝わる白鷹の総鎮守。','https://ja.wikipedia.org/wiki/鮎貝八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='eboshiyama-hachimangu' and d.slug in ('hachiman','michizane','ikazuchi')) or
   (t.slug='sagae-hachimangu' and d.slug in ('hachiman')) or
   (t.slug='kinowa-jinja' and d.slug in ('ukanomitama')) or
   (t.slug='kinbo-jinja-tsuruoka' and d.slug in ('sukunabikona','okuninushi','kotoshironushi','ankan_tenno')) or
   (t.slug='ayukai-hachimangu' and d.slug in ('hachiman','ukanomitama'))
on conflict do nothing;

-- === batch3 (Aomori / Yamagata) ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('owani-kumano-jinja','熊野神社（大鰐町）','くまのじんじゃ','shrine','旧村社','青森県','南津軽郡大鰐町','青森県南津軽郡大鰐町唐牛杉ノ木66',40.499389,140.609083,1573,null,null,'天正年間創建、伊弉諾・伊弉冉を祀る大鰐の古社。','https://ja.wikipedia.org/wiki/熊野神社_(大鰐町)','Wikipedia',true,now()),
('munakata-jinja-hirosaki','胸肩神社（弘前）','むなかたじんじゃ','shrine','旧村社','青森県','弘前市','青森県弘前市品川町89',40.594583,140.478056,807,null,null,'宗像三女神を祀る弘前の古社。','https://ja.wikipedia.org/wiki/胸肩神社_(青森県弘前市)','Wikipedia',true,now()),
('horyo-jinja','法量神社','ほうりょうじんじゃ','shrine','旧村社','青森県','十和田市','青森県十和田市法量字山ノ下25',40.591417,141.091194,1708,null,null,'高龗神を祀る奥入瀬川流域の古社。','https://ja.wikipedia.org/wiki/法量神社','Wikipedia',true,now()),
('yuzusame-jinja','由豆佐売神社','ゆずさめじんじゃ','shrine','式内社','山形県','鶴岡市','山形県鶴岡市湯田川字岩清水86',38.694333,139.767806,650,null,null,'湯田川温泉の鎮守と伝わる式内社。','https://ja.wikipedia.org/wiki/由豆佐売神社','Wikipedia',true,now()),
('torigoe-hachiman-jinja','鳥越八幡神社','とりごえはちまんじんじゃ','shrine','旧郷社','山形県','新庄市','山形県新庄市鳥越1224',38.741670,140.316390,1229,null,'https://torigoehachiman.org/','本殿・拝殿が重要文化財の新庄の八幡社。','https://ja.wikipedia.org/wiki/鳥越八幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='owani-kumano-jinja' and d.slug in ('izanagi','izanami')) or
   (t.slug='munakata-jinja-hirosaki' and d.slug in ('ichikishima','tagirihime','tagitsuhime')) or
   (t.slug='horyo-jinja' and d.slug in ('takaokami')) or
   (t.slug='yuzusame-jinja' and d.slug in ('okuninushi','sukunabikona')) or
   (t.slug='torigoe-hachiman-jinja' and d.slug in ('hachiman'))
on conflict do nothing;

-- === batch4 (Fukushima) ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iino-hachimangu','飯野八幡宮','いいのはちまんぐう','shrine','旧県社','福島県','いわき市','福島県いわき市平八幡小路84',37.060361,140.882111,1186,null,null,'重要文化財の社殿群を持つ平の総鎮守。八幡三神を祀る。','https://ja.wikipedia.org/wiki/飯野八幡宮','Wikipedia',true,now()),
('iwaki-okunitama-jinja','大國魂神社（いわき）','おおくにたまじんじゃ','shrine','式内社','福島県','いわき市','福島県いわき市平菅波字宮前54',37.052500,140.940000,null,null,'http://ookunitama.jp/','大国主ら三柱を祀る磐城の式内社。','https://ja.wikipedia.org/wiki/大國魂神社_(いわき市)','Wikipedia',true,now()),
('kobimine-jinja','子眉嶺神社','こびみねじんじゃ','shrine','名神大社','福島県','相馬郡新地町','福島県相馬郡新地町駒ケ嶺字大作44',37.852197,140.896128,702,null,'https://kobiminejinja.jp/','豊受比売命を祀る名神大社。馬の守護で知られる。','https://ja.wikipedia.org/wiki/子眉嶺神社','Wikipedia',true,now()),
('odairagata-tenmangu','小平潟天満宮','おびらがたてんまんぐう','shrine','旧村社','福島県','耶麻郡猪苗代町','福島県耶麻郡猪苗代町中小松西浜甲1615',37.517889,140.117944,948,null,null,'猪苗代湖畔に鎮座する菅原道真を祀る天満宮。','https://ja.wikipedia.org/wiki/小平潟天満宮','Wikipedia',true,now()),
('hokotsuki-jinja','桙衝神社','ほこつきじんじゃ','shrine','式内社','福島県','須賀川市','福島県須賀川市桙衝字亀居山97-1',37.270889,140.261500,712,null,null,'日本武尊・武甕槌神を祀る須賀川の式内社。','https://ja.wikipedia.org/wiki/桙衝神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iino-hachimangu' and d.slug in ('hachiman','jingu_kogo','himegami')) or
   (t.slug='iwaki-okunitama-jinja' and d.slug in ('okuninushi','kotoshironushi','sukunabikona')) or
   (t.slug='kobimine-jinja' and d.slug in ('toyouke')) or
   (t.slug='odairagata-tenmangu' and d.slug in ('michizane')) or
   (t.slug='hokotsuki-jinja' and d.slug in ('yamato_takeru','takemikazuchi'))
on conflict do nothing;

-- === batch5 (Akita) ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanezawa-hachimangu','金澤八幡宮','かねざわはちまんぐう','shrine','旧郷社','秋田県','横手市','秋田県横手市金沢字安本館4',39.373500,140.576361,1093,null,null,'後三年の役の古戦場・金沢柵跡に勧請された八幡宮。','https://ja.wikipedia.org/wiki/金澤八幡宮','Wikipedia',true,now()),
('gozanoishi-jinja','御座石神社','ござのいしじんじゃ','shrine','旧村社','秋田県','仙北市','秋田県仙北市西木町桧木内字相内潟1',39.751583,140.650528,1811,null,null,'田沢湖畔に鎮座、辰子姫伝説で知られる神社。','https://ja.wikipedia.org/wiki/御座石神社','Wikipedia',true,now()),
('tsuchizaki-shinmeisha','土崎神明社','つちざきしんめいしゃ','shrine','旧県社','秋田県','秋田市','秋田県秋田市土崎港中央3丁目9-37',39.756940,140.070830,1620,null,'http://www.tsuchizakishinnmeisha.or.jp/','土崎港の総鎮守。曳山祭(ユネスコ無形文化遺産)で有名。','https://ja.wikipedia.org/wiki/土崎神明社','Wikipedia',true,now()),
('toko-yasaka-jinja','東湖八坂神社','とうこやさかじんじゃ','shrine','旧郷社','秋田県','潟上市','秋田県潟上市天王字天王106',39.897417,139.963000,801,null,null,'素戔嗚尊を祀る。統人行事(国指定重要無形民俗文化財)で知られる。','https://ja.wikipedia.org/wiki/東湖八坂神社','Wikipedia',true,now()),
('shirataki-jinja','白瀑神社','しらたきじんじゃ','shrine','旧郷社','秋田県','山本郡八峰町','秋田県山本郡八峰町八森字館10',40.338861,140.037967,853,null,null,'神輿の滝浴びで知られる八森の古社。','https://ja.wikipedia.org/wiki/白瀑神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanezawa-hachimangu' and d.slug in ('hachiman')) or
   (t.slug='gozanoishi-jinja' and d.slug in ('kotoshironushi','watatsumi')) or
   (t.slug='tsuchizaki-shinmeisha' and d.slug in ('amaterasu')) or
   (t.slug='toko-yasaka-jinja' and d.slug in ('susanoo')) or
   (t.slug='shirataki-jinja' and d.slug in ('hinokagutsuchi','haniyamahime','amaterasu','susanoo'))
on conflict do nothing;

-- === batch6 (Miyagi / Iwate) ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('atsuhitakahiko-jinja','熱日高彦神社','あつひたかひこじんじゃ','shrine','式内社','宮城県','角田市','宮城県角田市島田字四拾刈12',37.937694,140.832889,null,null,'http://hitaka.org/','日本武尊ゆかりと伝わる伊具郡の式内社。瓊瓊杵尊を祀る。','https://ja.wikipedia.org/wiki/熱日高彦神社','Wikipedia',true,now()),
('saeno-jinja','佐倍乃神社','さえのじんじゃ','shrine','式内社','宮城県','名取市','宮城県名取市愛島笠島字西台1-4',38.162028,140.846670,110,null,null,'笠島道祖神社とも。猿田彦・天鈿女の夫婦神を祀る式内社。','https://ja.wikipedia.org/wiki/佐倍乃神社','Wikipedia',true,now()),
('ryoyozaki-jinja','零羊崎神社','ひつじさきじんじゃ','shrine','旧県社','宮城県','石巻市','宮城県石巻市湊字牧山7',38.439639,141.341583,null,null,null,'牧山に鎮座、豊玉彦命(海神)を祀る石巻の古社。','https://ja.wikipedia.org/wiki/零羊崎神社_(石巻市湊)','Wikipedia',true,now()),
('hayama-jinja-kesennuma','早馬神社','はやまじんじゃ','shrine','旧村社','宮城県','気仙沼市','宮城県気仙沼市唐桑町宿浦75',38.903194,141.638610,1217,null,'http://hayama.jinja.jp/','唐桑半島に鎮座する鎌倉以来の古社。','https://ja.wikipedia.org/wiki/早馬神社','Wikipedia',true,now()),
('osaki-jinja-kamaishi','尾崎神社（釜石）','おさきじんじゃ','shrine','旧県社','岩手県','釜石市','岩手県釜石市浜町3-23',39.280278,141.893889,null,null,null,'日本武尊ゆかりの剣を祀ると伝わる釜石の鎮守。','https://ja.wikipedia.org/wiki/尾崎神社_(釜石市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='atsuhitakahiko-jinja' and d.slug in ('ninigi','yamato_takeru')) or
   (t.slug='saeno-jinja' and d.slug in ('sarutahiko','ame_no_uzume')) or
   (t.slug='ryoyozaki-jinja' and d.slug in ('toyotamahiko')) or
   (t.slug='hayama-jinja-kesennuma' and d.slug in ('ukanomitama')) or
   (t.slug='osaki-jinja-kamaishi' and d.slug in ('yamato_takeru'))
on conflict do nothing;

-- === batch7 (Iwate / Akita / Hokkaido) ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hanamaki-jinja','花巻神社','はなまきじんじゃ','shrine','旧村社','岩手県','花巻市','岩手県花巻市愛宕町384-1',39.396972,141.110583,1955,null,'https://www.hanamaki-jinja.com/','愛宕・稲荷・八坂を合祀した花巻の鎮守。','https://ja.wikipedia.org/wiki/花巻神社','Wikipedia',true,now()),
('ichinoseki-hachiman-jinja','一関八幡神社','いちのせきはちまんじんじゃ','shrine','旧郷社','岩手県','一関市','岩手県一関市釣山19',38.922944,141.131528,800,null,'https://tamura-hachiman.com/','坂上田村麻呂を配祀する一関総鎮守。','https://ja.wikipedia.org/wiki/一関八幡神社','Wikipedia',true,now()),
('tsuzureko-jinja','綴子神社','つづれこじんじゃ','shrine','旧郷社','秋田県','北秋田市','秋田県北秋田市綴子字西館47',40.253194,140.368444,659,null,'http://www.tsudurekojinja.or.jp/','世界一の大太鼓行事で知られる八幡社。','https://ja.wikipedia.org/wiki/綴子神社','Wikipedia',true,now()),
('matsudate-sugawara-jinja','松舘菅原神社','まつだてすがわらじんじゃ','shrine','旧村社','秋田県','鹿角市','秋田県鹿角市八幡平字天神館33',40.158944,140.779944,1022,null,null,'菅原道真を祀る鹿角の天神社。天神講舞で知られる。','https://ja.wikipedia.org/wiki/松舘菅原神社','Wikipedia',true,now()),
('ishikari-hachiman-jinja','石狩八幡神社','いしかりはちまんじんじゃ','shrine','旧村社','北海道','石狩市','北海道石狩市弁天町1',43.250333,141.356444,1858,null,'https://hana8man.wixsite.com/mysite','石狩湊の鎮守。応神天皇と倉稲魂を祀る。','https://ja.wikipedia.org/wiki/石狩八幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hanamaki-jinja' and d.slug in ('kagutsuchi','toyouke','susanoo')) or
   (t.slug='ichinoseki-hachiman-jinja' and d.slug in ('hachiman','sakanoue_tamuramaro')) or
   (t.slug='tsuzureko-jinja' and d.slug in ('hachiman')) or
   (t.slug='matsudate-sugawara-jinja' and d.slug in ('michizane')) or
   (t.slug='ishikari-hachiman-jinja' and d.slug in ('hachiman','ukanomitama'))
on conflict do nothing;

-- === batch8 (Fukushima) ===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('suzumigaoka-hachiman-jinja','涼ケ岡八幡神社','すずみがおかはちまんじんじゃ','shrine','旧郷社','福島県','相馬市','福島県相馬市坪田字涼ケ岡51',37.776917,140.909750,1335,null,'http://www.hachimanjinjya.or.jp/','重要文化財の社殿群を持つ相馬の八幡社。','https://ja.wikipedia.org/wiki/涼ケ岡八幡神社','Wikipedia',true,now()),
('yanagawa-hachimangu','梁川八幡宮','やながわはちまんぐう','shrine','旧郷社','福島県','伊達市','福島県伊達市梁川町八幡字堂庭11',37.866306,140.612694,984,null,null,'伊達氏ゆかりの八幡宮。','https://ja.wikipedia.org/wiki/梁川八幡宮','Wikipedia',true,now()),
('oyamazumi-jinja-nishiaizu','大山祇神社（西会津）','おおやまずみじんじゃ','shrine','旧村社','福島県','耶麻郡西会津町','福島県耶麻郡西会津町野沢字大久保1445-2',37.536110,139.605560,778,null,'http://www.ooyamazumi.net/','「のざわの山の神」として親しまれる西会津の古社。','https://ja.wikipedia.org/wiki/大山祇神社_(西会津町)','Wikipedia',true,now()),
('okaburaya-jinja','大鏑矢神社','おおかぶらやじんじゃ','shrine','式内社','福島県','田村市','福島県田村市船引町東部台6-1',37.438306,140.582417,801,null,'http://www.ookaburaya-jinja.ftw.jp/','坂上田村麻呂が戦勝祈願したと伝わる田村の式内社。','https://ja.wikipedia.org/wiki/大鏑矢神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='suzumigaoka-hachiman-jinja' and d.slug in ('hachiman','chuai','jingu_kogo')) or
   (t.slug='yanagawa-hachimangu' and d.slug in ('hachiman')) or
   (t.slug='oyamazumi-jinja-nishiaizu' and d.slug in ('oyamatsumi','iwanagahime','konohanasakuya')) or
   (t.slug='okaburaya-jinja' and d.slug in ('takamimusubi','sakanoue_tamuramaro'))
on conflict do nothing;
