-- 九州・沖縄 追加データ (kyushu-okinawa-4) : 著名社寺の追加収録
-- 出典: ja.wikipedia.org infobox の十進座標で裏取り
-- 既存収録(_have_kyushu-okinawa.txt)・既存SQLとは重複させない

-- ===== ① 新規神仏 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tagitsuhime','湍津姫神','たぎつひめのかみ','kami','宗像三女神','{}','記紀','宗像三女神の一柱。海上・交通の守護神。','https://ja.wikipedia.org/wiki/宗像大社','Wikipedia',true,now()),
('takirihime','田心姫神','たきりひめのかみ','kami','宗像三女神','{}','記紀','宗像三女神の一柱。沖津宮(沖ノ島)の祭神。','https://ja.wikipedia.org/wiki/宗像大社','Wikipedia',true,now()),
('nabeshima_naomasa','鍋島直正','なべしまなおまさ','kami','人物神','{閑叟}','史実','佐賀藩10代藩主。藩政改革と近代化を進めた名君。','https://ja.wikipedia.org/wiki/佐嘉神社','Wikipedia',true,now()),
('nabeshima_naohiro','鍋島直大','なべしまなおひろ','kami','人物神','{}','史実','佐賀藩11代藩主。維新後は外交官・貴族院議員。','https://ja.wikipedia.org/wiki/佐嘉神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tagitsuhime' and g.slug in ('kaijo_anzen','kotsu_anzen','suisan_noko'))
or (d.slug='takirihime' and g.slug in ('kaijo_anzen','kotsu_anzen','suisan_noko'))
or (d.slug='nabeshima_naomasa' and g.slug in ('gakumon','shusse','kaiun'))
or (d.slug='nabeshima_naohiro' and g.slug in ('gakumon','shusse','kaiun'))
on conflict do nothing;

-- ===== ③ 社寺 =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('suikyo-tenmangu','水鏡天満宮','すいきょうてんまんぐう','shrine','旧県社','福岡県','福岡市','福岡県福岡市中央区天神一丁目15番4号',33.5927028,130.4017861,1612,null,null,'天神の地名の由来となった菅原道真を祀る天満宮。','https://ja.wikipedia.org/wiki/水鏡天満宮','Wikipedia',true,now()),
('momiji-hachimangu','紅葉八幡宮','もみじはちまんぐう','shrine','旧県社','福岡県','福岡市','福岡県福岡市早良区高取1-26-55',33.578389,130.351000,1482,null,'http://www.momijihachimangu.or.jp/','早良の総守護。縁結び・厄除けで知られる八幡宮。','https://ja.wikipedia.org/wiki/紅葉八幡宮','Wikipedia',true,now()),
('munakata-nakatsugu','宗像大社中津宮','むなかたたいしゃなかつぐう','shrine','名神大社・官幣大社','福岡県','宗像市','福岡県宗像市大島1811',33.897333,130.431861,null,null,'https://munakata-taisha.or.jp/','世界遺産。大島に鎮座する宗像大社の中津宮。','https://ja.wikipedia.org/wiki/宗像大社','Wikipedia',true,now()),
('munakata-okitsugu','宗像大社沖津宮','むなかたたいしゃおきつぐう','shrine','名神大社・官幣大社','福岡県','宗像市','福岡県宗像市大島沖之島',34.241778,130.104000,null,null,'https://munakata-taisha.or.jp/','世界遺産。沖ノ島に鎮座する宗像大社の沖津宮。','https://ja.wikipedia.org/wiki/宗像大社','Wikipedia',true,now()),
('itouzu-hachiman','到津八幡神社','いとうづはちまんじんじゃ','shrine','旧県社','福岡県','北九州市','福岡県北九州市小倉北区上到津1丁目8-1',33.8778083,130.8532972,1184,null,null,'神功皇后伝承の地に鎮座。安産・子育ての八幡宮。','https://ja.wikipedia.org/wiki/到津八幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='suikyo-tenmangu' and d.slug in ('michizane'))
or (t.slug='momiji-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='munakata-nakatsugu' and d.slug in ('tagitsuhime'))
or (t.slug='munakata-okitsugu' and d.slug in ('takirihime'))
or (t.slug='itouzu-hachiman' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;

-- ===== batch 2 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tachibana_shuta','橘周太','たちばなしゅうた','kami','人物神','{}','史実','日露戦争・遼陽会戦で戦死した軍人。軍神として祀られる。','https://ja.wikipedia.org/wiki/橘神社_(雲仙市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tachibana_shuta' and g.slug in ('shobu','gakugyo','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saga-jinja','佐嘉神社','さがじんじゃ','shrine','旧県社','佐賀県','佐賀市','佐賀県佐賀市松原2-10-43',33.25194,130.30250,1933,null,'http://www.sagajinjya.jp','佐賀藩主鍋島直正・直大を祀る。維新近代化の名君を顕彰。','https://ja.wikipedia.org/wiki/佐嘉神社','Wikipedia',true,now()),
('fukusaiji','福済寺','ふくさいじ','temple','黄檗宗','長崎県','長崎市','長崎県長崎市筑後町2-56',32.7533083,129.8749722,1628,null,null,'唐寺の一つ。長崎観音と巨大フーコー振り子で知られる。','https://ja.wikipedia.org/wiki/福済寺','Wikipedia',true,now()),
('shofukuji-nagasaki','聖福寺','しょうふくじ','temple','黄檗宗','長崎県','長崎市','長崎県長崎市玉園町3-77',32.7530472,129.8770750,1677,null,null,'長崎四福寺の一つ。広東出身者ゆかりの唐寺。重要文化財4棟。','https://ja.wikipedia.org/wiki/聖福寺_(長崎市)','Wikipedia',true,now()),
('tachibana-jinja','橘神社','たちばなじんじゃ','shrine','旧県社','長崎県','雲仙市','長崎県雲仙市千々石町戊',32.786528,130.206583,1940,null,null,'軍神橘周太中佐を祀る。桜の名所で県内有数の初詣客を集める。','https://ja.wikipedia.org/wiki/橘神社_(雲仙市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saga-jinja' and d.slug in ('nabeshima_naomasa','nabeshima_naohiro'))
or (t.slug='tachibana-jinja' and d.slug in ('tachibana_shuta'))
on conflict do nothing;

-- ===== batch 3 (大分) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('himegami','比売神','ひめがみ','kami','天津神','{比売大神}','記紀','春日・八幡などで主神に配される女神の総称。','https://ja.wikipedia.org/wiki/春日神社_(大分市)','Wikipedia',true,now()),
('eirei','英霊','えいれい','kami','御霊','{護国の英霊}','史実','国家・郷土のために殉じた戦没者の御霊。護国神社の祭神。','https://ja.wikipedia.org/wiki/大分縣護國神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='himegami' and g.slug in ('enmusubi','kanai_anzen','kaiun'))
or (d.slug='eirei' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kasuga-jinja-oita','春日神社','かすがじんじゃ','shrine','旧県社','大分県','大分市','大分県大分市勢家町',33.245139,131.598194,860,null,null,'大和春日大社を勧請した大分の総鎮守。春日四神を祀る。','https://ja.wikipedia.org/wiki/春日神社_(大分市)','Wikipedia',true,now()),
('oita-gokoku','大分縣護國神社','おおいたけんごこくじんじゃ','shrine','護国神社','大分県','大分市','大分県大分市大字牧1371',33.235139,131.642028,1875,null,'http://www.oita-gokoku.jp/','松栄山に鎮座。大分県縁故の英霊約4万4千柱を祀る。','https://ja.wikipedia.org/wiki/大分縣護國神社','Wikipedia',true,now()),
('makiodo','真木大堂','まきおおどう','temple','天台宗','大分県','豊後高田市','大分県豊後高田市田染真木1796',33.501111,131.517611,718,'阿弥陀如来','http://www.makiodo.jp/','六郷満山の古刹。国宝級の九体仏像を伝える。','https://ja.wikipedia.org/wiki/真木大堂','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kasuga-jinja-oita' and d.slug in ('takemikazuchi','futsunushi','amenokoyane','himegami'))
or (t.slug='oita-gokoku' and d.slug in ('eirei'))
or (t.slug='makiodo' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== batch 4 (宮崎・鹿児島・沖縄) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('wake_kiyomaro','和気清麻呂','わけのきよまろ','kami','人物神','{護王大明神}','史実','奈良時代の忠臣。宇佐八幡宮神託事件で皇統を守った。','https://ja.wikipedia.org/wiki/和気神社_(霧島市)','Wikipedia',true,now()),
('kumano_gongen','熊野権現','くまのごんげん','kami','御霊','{熊野三所権現}','記紀・修験','熊野三山の神を権現として祀る信仰。','https://ja.wikipedia.org/wiki/宮古神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='wake_kiyomaro' and g.slug in ('shobu','shusse','byoki_heyu'))
or (d.slug='kumano_gongen' and g.slug in ('kaiun','yakubarai','choju'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('miyazaki-gokoku','宮崎縣護國神社','みやざきけんごこくじんじゃ','shrine','護国神社','宮崎県','宮崎市','宮崎県宮崎市神宮二丁目4-3',31.937111,131.421750,1955,null,null,'宮崎神宮の南に鎮座。戊辰以降の英霊約4万2千柱を祀る。','https://ja.wikipedia.org/wiki/宮崎県護国神社','Wikipedia',true,now()),
('kannoji-izumi','感応寺','かんのうじ','temple','臨済宗相国寺派','鹿児島県','出水市','鹿児島県出水市野田町下名',32.067361,130.266750,1194,null,null,'島津氏の菩提寺。栄西開山と伝わる九州屈指の古刹。島津五廟社を擁す。','https://ja.wikipedia.org/wiki/感応寺_(出水市)','Wikipedia',true,now()),
('wake-jinja-kirishima','和気神社','わけじんじゃ','shrine','旧県社','鹿児島県','霧島市','鹿児島県霧島市牧園町宿窪田3986',31.822389,130.762167,1946,null,null,'大隅に流された和気清麻呂を祀る。猪に守られた伝承で知られる。','https://ja.wikipedia.org/wiki/和気神社_(霧島市)','Wikipedia',true,now()),
('miyako-jinja','宮古神社','みやこじんじゃ','shrine','旧無格社','沖縄県','宮古島市','沖縄県宮古島市平良字西里5-1',24.807778,125.280444,1590,null,'https://miyako-jinja.com','日本最南端の神社。熊野三神と豊見親を祀る赤瓦の社。','https://ja.wikipedia.org/wiki/宮古神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='miyazaki-gokoku' and d.slug in ('eirei'))
or (t.slug='wake-jinja-kirishima' and d.slug in ('wake_kiyomaro'))
or (t.slug='miyako-jinja' and d.slug in ('kumano_gongen','kotoshironushi'))
on conflict do nothing;

-- ===== batch 5 (福岡・熊本・鹿児島) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kamuroki','神漏岐命','かむろぎのみこと','kami','天津神','{神漏岐}','記紀・祝詞','高天原の男神。祓いと国の始まりを司る根源神。','https://ja.wikipedia.org/wiki/幣立神社','Wikipedia',true,now()),
('kamuromi','神漏美命','かむろみのみこと','kami','天津神','{神漏美}','記紀・祝詞','高天原の女神。神漏岐命と対を成す根源神。','https://ja.wikipedia.org/wiki/幣立神社','Wikipedia',true,now()),
('toyotamahiko','豊玉彦命','とよたまひこのみこと','kami','国津神','{綿津見神}','記紀','海神綿津見の神。豊玉姫の父。','https://ja.wikipedia.org/wiki/鹿児島神社_(鹿児島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kamuroki' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='kamuromi' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='toyotamahiko' and g.slug in ('kaijo_anzen','suisan_noko','kotsu_anzen'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mizuta-tenmangu','水田天満宮','みずたてんまんぐう','shrine','旧県社','福岡県','筑後市','福岡県筑後市水田62-1',33.198639,130.485667,1226,null,'https://www.mizuta-koinoki.jp/','太宰府に次ぐ九州二大天満宮。境内の恋木神社は縁結びで有名。','https://ja.wikipedia.org/wiki/水田天満宮','Wikipedia',true,now()),
('heitate-jinja','幣立神社','へいたてじんじゃ','shrine','旧郷社','熊本県','上益城郡','熊本県上益城郡山都町大野712',32.687056,131.135722,null,null,null,'九州のへそに鎮座する高天原神話ゆかりの古社。','https://ja.wikipedia.org/wiki/幣立神社','Wikipedia',true,now()),
('kagoshima-jinja','鹿児島神社','かごしまじんじゃ','shrine','旧県社','鹿児島県','鹿児島市','鹿児島県鹿児島市草牟田二丁目',31.609750,130.539611,null,null,null,'鹿児島三社の一つ。旧称宇治瀬大明神。','https://ja.wikipedia.org/wiki/鹿児島神社_(鹿児島市)','Wikipedia',true,now()),
('onamuchi-jinja','大汝牟遅神社','おおなむちじんじゃ','shrine','旧郷社','鹿児島県','日置市','鹿児島県日置市吹上町中原2263',31.514722,130.350167,null,null,null,'千本楠の参道で知られる古社。流鏑馬神事を伝える。','https://ja.wikipedia.org/wiki/大汝牟遅神社','Wikipedia',true,now()),
('arata-hachimangu','荒田八幡宮','あらたはちまんぐう','shrine','旧県社','鹿児島県','鹿児島市','鹿児島県鹿児島市下荒田二丁目',31.574500,130.553583,708,null,null,'鹿児島五社の一つ。蝮除けの砂の信仰で知られる。','https://ja.wikipedia.org/wiki/荒田八幡宮_(鹿児島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mizuta-tenmangu' and d.slug in ('michizane'))
or (t.slug='heitate-jinja' and d.slug in ('kamuroki','kamuromi'))
or (t.slug='kagoshima-jinja' and d.slug in ('toyotamahiko','toyotamahime','toyouke'))
or (t.slug='onamuchi-jinja' and d.slug in ('okuninushi'))
or (t.slug='arata-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
on conflict do nothing;

-- ===== batch 6 (熊本) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kikuchi_takatoki','菊池武時','きくちたけとき','kami','人物神','{}','史実','南北朝期の肥後の武将。菊池一族の忠臣として祀られる。','https://ja.wikipedia.org/wiki/菊池神社_(菊池市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kikuchi_takatoki' and g.slug in ('shobu','shusse','yakubarai'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kikuchi-jinja','菊池神社','きくちじんじゃ','shrine','旧別格官幣社','熊本県','菊池市','熊本県菊池市隈府1257',32.987889,130.816167,1870,null,null,'建武中興十五社の一つ。菊池一族三代を祀る桜の名所。','https://ja.wikipedia.org/wiki/菊池神社_(菊池市)','Wikipedia',true,now()),
('kumamoto-gokoku','熊本県護國神社','くまもとけんごこくじんじゃ','shrine','護国神社','熊本県','熊本市','熊本県熊本市中央区宮内3-1',32.807722,130.699444,1869,null,'http://www.kumamoto-gokoku.jp/','熊本城近くに鎮座。明治維新以降の英霊約6万5千柱を祀る。','https://ja.wikipedia.org/wiki/熊本県護国神社','Wikipedia',true,now()),
('kofukuji-tamana','廣福寺','こうふくじ','temple','曹洞宗','熊本県','玉名市','熊本県玉名市石貫1379',32.968417,130.554417,1330,'釈迦如来',null,'永平寺直末の禅刹。菊池一族・加藤清正ゆかりの古刹。','https://ja.wikipedia.org/wiki/廣福寺_(玉名市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kikuchi-jinja' and d.slug in ('kikuchi_takatoki'))
or (t.slug='kumamoto-gokoku' and d.slug in ('eirei'))
or (t.slug='kofukuji-tamana' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== batch 7 (佐賀・長崎・大分・沖縄 護国神社ほか) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ushijima-tenmangu','牛嶋天満宮','うしじまてんまんぐう','shrine','旧郷社','佐賀県','佐賀市','佐賀県佐賀市東佐賀町',33.2566333,130.3108778,1151,null,null,'佐賀城の鬼門を守護する天満宮。樹齢千年の大楠で知られる。','https://ja.wikipedia.org/wiki/牛嶋天満宮','Wikipedia',true,now()),
('nagasaki-gokoku','長崎縣護國神社','ながさきけんごこくじんじゃ','shrine','護国神社','長崎県','長崎市','長崎県長崎市城栄町41-67',32.77722,129.85556,1869,null,null,'長崎県関係の戦没者約6万柱を祀る。原爆で焼失後再建。','https://ja.wikipedia.org/wiki/長崎縣護國神社','Wikipedia',true,now()),
('okinawa-gokoku','沖縄県護国神社','おきなわけんごこくじんじゃ','shrine','護国神社','沖縄県','那覇市','沖縄県那覇市奥武山町44',26.203222,127.676000,1936,null,null,'奥武山公園内に鎮座。約17万8千柱を祀り護国神社で最多。','https://ja.wikipedia.org/wiki/沖縄県護国神社','Wikipedia',true,now()),
('choanji-bungotakada','長安寺','ちょうあんじ','temple','天台宗','大分県','豊後高田市','大分県豊後高田市加礼川635',33.567778,131.548500,718,'千手観音',null,'六郷満山中山本寺の古刹。太郎天像など国重文を伝える。','https://ja.wikipedia.org/wiki/長安寺_(豊後高田市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ushijima-tenmangu' and d.slug in ('michizane'))
or (t.slug='nagasaki-gokoku' and d.slug in ('eirei'))
or (t.slug='okinawa-gokoku' and d.slug in ('eirei'))
or (t.slug='choanji-bungotakada' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- ===== batch 8 (福岡・博多の名刹) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fukuoka-gokoku','福岡県護国神社','ふくおかけんごこくじんじゃ','shrine','護国神社','福岡県','福岡市','福岡県福岡市中央区六本松1-1-1',33.58167,130.38222,1868,null,'https://fukuoka-gokoku.jp/','福岡県関係の戦没者約13万柱を祀る。大濠公園近くに鎮座。','https://ja.wikipedia.org/wiki/福岡県護国神社','Wikipedia',true,now()),
('jotenji','承天寺','じょうてんじ','temple','臨済宗東福寺派','福岡県','福岡市','福岡県福岡市博多区博多駅前一丁目29-9',33.595222,130.417028,1242,'釈迦如来',null,'円爾が開いた博多の禅刹。うどん・博多祇園山笠発祥の地。','https://ja.wikipedia.org/wiki/承天寺','Wikipedia',true,now()),
('shofukuji-fukuoka','聖福寺','しょうふくじ','temple','臨済宗妙心寺派','福岡県','福岡市','福岡県福岡市博多区御供所町6-1',33.597028,130.414111,1195,'三世仏',null,'栄西が開いた日本最初の禅寺。境内は国史跡。','https://ja.wikipedia.org/wiki/聖福寺_(福岡市)','Wikipedia',true,now()),
('tochoji','東長寺','とうちょうじ','temple','真言宗御室派','福岡県','福岡市','福岡県福岡市博多区御供所2-4',33.595111,130.414111,806,'千手観音',null,'弘法大師創建と伝わる九州真言宗別格本山。福岡大仏で知られる。','https://ja.wikipedia.org/wiki/東長寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fukuoka-gokoku' and d.slug in ('eirei'))
or (t.slug='jotenji' and d.slug in ('shaka_nyorai'))
or (t.slug='shofukuji-fukuoka' and d.slug in ('shaka_nyorai','amida_nyorai'))
or (t.slug='tochoji' and d.slug in ('senju_kannon','kobo_daishi'))
on conflict do nothing;

-- ===== batch 9 (佐賀・沖縄・鹿児島) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tachibana_moroe','橘諸兄','たちばなのもろえ','kami','人物神','{}','史実','奈良時代の左大臣。橘氏の祖。','https://ja.wikipedia.org/wiki/伊萬里神社','Wikipedia',true,now()),
('tenchi_tenno','天智天皇','てんぢてんのう','kami','人物神','{中大兄皇子}','史実','大化改新を主導した第38代天皇。','https://ja.wikipedia.org/wiki/一之宮神社_(鹿児島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tachibana_moroe' and g.slug in ('shusse','gakumon','kaiun'))
or (d.slug='tenchi_tenno' and g.slug in ('gakumon','shusse','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saga-gokoku','佐賀縣護國神社','さがけんごこくじんじゃ','shrine','護国神社','佐賀県','佐賀市','佐賀県佐賀市川原町8-15',33.25278,130.29306,1870,null,null,'佐賀県関係の戦没者約3万5千柱を祀る。戊辰戦争の佐賀藩士に始まる。','https://ja.wikipedia.org/wiki/佐賀県護国神社','Wikipedia',true,now()),
('imari-jinja','伊萬里神社','いまりじんじゃ','shrine','旧郷社','佐賀県','伊万里市','佐賀県伊万里市立花町84',33.276611,129.882000,null,null,null,'橘諸兄を祀る伊万里の総鎮守。香橘神社など三社を合祀。','https://ja.wikipedia.org/wiki/伊萬里神社','Wikipedia',true,now()),
('ichinomiya-jinja-kagoshima','一之宮神社','いちのみやじんじゃ','shrine','旧県社','鹿児島県','鹿児島市','鹿児島県鹿児島市郡元二丁目',31.563083,130.546306,null,null,null,'鹿児島三社の筆頭。郡元の弥生遺跡に隣接する古社。','https://ja.wikipedia.org/wiki/一之宮神社_(鹿児島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saga-gokoku' and d.slug in ('eirei'))
or (t.slug='imari-jinja' and d.slug in ('tachibana_moroe'))
or (t.slug='ichinomiya-jinja-kagoshima' and d.slug in ('amaterasu','sarutahiko','tenchi_tenno'))
on conflict do nothing;

-- ===== batch 10 (大分・佐賀・福岡) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('koshi','孔子','こうし','kami','人物神','{孔夫子}','史実','儒教の祖。学問・教育の聖人として聖廟に祀られる。','https://ja.wikipedia.org/wiki/多久聖廟','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='koshi' and g.slug in ('gakumon','gakugyo','shusse'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('senpukuji-kunisaki','泉福寺','せんぷくじ','temple','曹洞宗','大分県','国東市','大分県国東市国東町横手1913',33.577444,131.670750,1375,'釈迦如来',null,'九州曹洞宗の本山格。国宝の仏殿・開山堂を伝える六郷満山の禅刹。','https://ja.wikipedia.org/wiki/泉福寺_(国東市)','Wikipedia',true,now()),
('taku-seibyo','多久聖廟','たくせいびょう','temple','儒教','佐賀県','多久市','佐賀県多久市多久町1843-3',33.260000,130.097778,1708,'孔子',null,'多久茂文が創建した孔子廟。国指定重要文化財。','https://ja.wikipedia.org/wiki/多久聖廟','Wikipedia',true,now()),
('kurume-naritasan','成田山久留米分院','なりたさんくるめぶんいん','temple','真言宗智山派','福岡県','久留米市','福岡県久留米市上津町1386-22',33.284944,130.535222,1958,'不動明王','https://www.kurume-naritasan.or.jp/','高さ62mの救世慈母大観音で知られる成田山新勝寺の分院。','https://ja.wikipedia.org/wiki/成田山久留米分院','Wikipedia',true,now()),
('kitano-tenmangu-kurume','北野天満宮','きたのてんまんぐう','shrine','旧県社','福岡県','久留米市','福岡県久留米市北野町3267',33.343611,130.584611,1054,null,null,'河童の手の伝説で知られる久留米の天満宮。樹齢900年の大楠。','https://ja.wikipedia.org/wiki/北野天満宮_(久留米市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='senpukuji-kunisaki' and d.slug in ('shaka_nyorai'))
or (t.slug='taku-seibyo' and d.slug in ('koshi'))
or (t.slug='kurume-naritasan' and d.slug in ('fudo_myoo'))
or (t.slug='kitano-tenmangu-kurume' and d.slug in ('michizane'))
on conflict do nothing;

-- ===== batch 11 (鹿児島・長崎・熊本・大分) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('hiruko','蛭児尊','ひるこのみこと','kami','国津神','{蛭子}','記紀','イザナギ・イザナミの最初の子。後に恵比須と習合。','https://ja.wikipedia.org/wiki/蛭児神社_(霧島市)','Wikipedia',true,now()),
('habiki','波比岐神','はひきのかみ','kami','国津神','{}','記紀','大年神の御子神。金属・鍛冶の守護神。','https://ja.wikipedia.org/wiki/疋野神社','Wikipedia',true,now()),
('otoshi','大年神','おおとしのかみ','kami','国津神','{大歳神}','記紀','スサノオの御子。年穀・農耕を司る神。','https://ja.wikipedia.org/wiki/疋野神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='hiruko' and g.slug in ('shobai','kinun','kaiun'))
or (d.slug='habiki' and g.slug in ('shobai','shigoto','kaiun'))
or (d.slug='otoshi' and g.slug in ('suisan_noko','shobai','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hiruko-jinja-kirishima','蛭児神社','ひるこじんじゃ','shrine','旧県社','鹿児島県','霧島市','鹿児島県霧島市隼人町内2563',31.761222,130.750167,null,null,null,'大隅国二宮。蛭児尊を祀り恵比須信仰でも知られる古社。','https://ja.wikipedia.org/wiki/蛭児神社_(霧島市)','Wikipedia',true,now()),
('honrenji-nagasaki','本蓮寺','ほんれんじ','temple','日蓮宗','長崎県','長崎市','長崎県長崎市筑後町2-10',32.754139,129.873750,1620,null,null,'教会跡に建てられた肥前法華五ヶ寺の一つ。','https://ja.wikipedia.org/wiki/本蓮寺_(長崎市)','Wikipedia',true,now()),
('hikino-jinja','疋野神社','ひきのじんじゃ','shrine','旧県社','熊本県','玉名市','熊本県玉名市立願寺457',32.938194,130.552389,null,null,null,'式内社。波比岐神を祀る玉名の古社。長者伝説で知られる。','https://ja.wikipedia.org/wiki/疋野神社','Wikipedia',true,now()),
('ougimori-inari','扇森稲荷神社','おうぎもりいなりじんじゃ','shrine','旧無格社','大分県','竹田市','大分県竹田市大字拝田原字桜瀬811',32.956778,131.370361,1616,null,null,'狐頭様(こうとうさま)と親しまれる九州三大稲荷の一つ。','https://ja.wikipedia.org/wiki/扇森稲荷神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hiruko-jinja-kirishima' and d.slug in ('hiruko'))
or (t.slug='hikino-jinja' and d.slug in ('habiki','otoshi'))
or (t.slug='ougimori-inari' and d.slug in ('ukemochi'))
on conflict do nothing;

-- ===== batch 12 (福岡・鹿児島・大分) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('omiyahime','大宮能売命','おおみやのめのみこと','kami','稲荷神','{大宮売神}','記紀','稲荷三神の一柱。和合・接客の徳を司る女神。','https://ja.wikipedia.org/wiki/稲荷神社_(鹿児島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='omiyahime' and g.slug in ('shobai','enmusubi','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hachiman-kohyo-jinja','八幡古表神社','はちまんこひょうじんじゃ','shrine','旧県社','福岡県','築上郡','福岡県築上郡吉富町小犬丸353-1',33.614417,131.180389,null,null,null,'宇佐神宮の末社。傀儡子の舞と神相撲(国重要無形民俗文化財)で知られる。','https://ja.wikipedia.org/wiki/八幡古表神社','Wikipedia',true,now()),
('inari-jinja-kagoshima','稲荷神社','いなりじんじゃ','shrine','旧県社','鹿児島県','鹿児島市','鹿児島県鹿児島市稲荷町34',31.612611,130.568583,1209,null,null,'島津稲荷とも称される鹿児島五社の一つ。','https://ja.wikipedia.org/wiki/稲荷神社_(鹿児島市)','Wikipedia',true,now()),
('yasaka-jinja-hita','八坂神社','やさかじんじゃ','shrine','旧郷社','大分県','日田市','大分県日田市隈字下横町70',33.315500,130.930694,1706,null,null,'日田祇園祭(国重要無形民俗文化財)を担う隈の鎮守。','https://ja.wikipedia.org/wiki/八坂神社_(日田市)','Wikipedia',true,now()),
('ohara-hachimangu','大原八幡宮','おおはらはちまんぐう','shrine','旧県社','大分県','日田市','大分県日田市田島2丁目184',33.3207583,130.9457889,704,null,null,'日田の総鎮守。杉原神社を前身とする八幡宮。','https://ja.wikipedia.org/wiki/大原八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hachiman-kohyo-jinja' and d.slug in ('jingu_kogo'))
or (t.slug='inari-jinja-kagoshima' and d.slug in ('ukemochi','sarutahiko','omiyahime'))
or (t.slug='yasaka-jinja-hita' and d.slug in ('susanoo'))
or (t.slug='ohara-hachimangu' and d.slug in ('hachiman','jingu_kogo','himegami'))
on conflict do nothing;

-- ===== batch 13 (福岡) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('arahito-jinja','現人神社','あらひとじんじゃ','shrine','旧村社','福岡県','那珂川市','福岡県那珂川市仲3-6-20',33.506417,130.424806,null,null,null,'全国2千余の住吉神社の元宮とされる。日本三大住吉の一つ。','https://ja.wikipedia.org/wiki/現人神社','Wikipedia',true,now()),
('iimori-jinja','飯盛神社','いいもりじんじゃ','shrine','旧県社','福岡県','福岡市','福岡県福岡市西区大字飯盛609',33.538333,130.309389,859,null,null,'飯盛山に鎮座する縁結びの古社。文殊堂でも知られる。','https://ja.wikipedia.org/wiki/飯盛神社_(福岡市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='arahito-jinja' and d.slug in ('sumiyoshi'))
or (t.slug='iimori-jinja' and d.slug in ('izanami'))
on conflict do nothing;

-- ===== batch 14 (鹿児島) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shimazu_yoshihiro','島津義弘','しまづよしひろ','kami','人物神','{精矛厳健雄命}','史実','戦国期の薩摩の名将。関ヶ原の退き口で知られる。','https://ja.wikipedia.org/wiki/徳重神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shimazu_yoshihiro' and g.slug in ('shobu','shusse','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tokushige-jinja','徳重神社','とくしげじんじゃ','shrine','旧県社','鹿児島県','日置市','鹿児島県日置市伊集院町徳重1786',31.632389,130.394722,1871,null,null,'島津義弘を祀る。妙円寺詣りで知られる伊集院の古社。','https://ja.wikipedia.org/wiki/徳重神社','Wikipedia',true,now()),
('minakata-jinja-satsumasendai','南方神社','みなみかたじんじゃ','shrine','旧郷社','鹿児島県','薩摩川内市','鹿児島県薩摩川内市高江町',31.808000,130.298000,null,null,null,'建御名方命を主祭神とする諏訪系の古社。太郎太郎踊りで知られる。','https://ja.wikipedia.org/wiki/南方神社_(薩摩川内市)','Wikipedia',true,now()),
('saifukuji-kagoshima','最福寺','さいふくじ','temple','真言宗単立','鹿児島県','鹿児島市','鹿児島県鹿児島市平川町4850',31.4410028,130.5098528,null,'不動明王',null,'高さ18.5mの木造弁財天で知られる平川の名刹。','https://ja.wikipedia.org/wiki/最福寺_(鹿児島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tokushige-jinja' and d.slug in ('shimazu_yoshihiro'))
or (t.slug='minakata-jinja-satsumasendai' and d.slug in ('takeminakata'))
or (t.slug='saifukuji-kagoshima' and d.slug in ('fudo_myoo'))
on conflict do nothing;
