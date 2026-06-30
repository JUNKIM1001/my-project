-- 関東地方 追加データ (kanto-5) : 茨城・栃木・群馬・埼玉・千葉・東京・神奈川
-- ja.wikipedia infobox 十進座標で裏取り。_have_kanto.txt 既収録分は除外。
-- 5件ごとに追記保存。

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenohayatamahime','天速玉姫命','あめのはやたまひめのみこと','kami','国津神','{}','記紀','常陸国の延喜式内社・泉神社の祭神。湧水の神。','https://ja.wikipedia.org/wiki/泉神社_(日立市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenohayatamahime' and g.slug in ('mizu_amagoi','kaiun','byoki_heyu'))
on conflict do nothing;

-- ③ 社寺 (batch 1: 茨城・栃木・東京)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('izumi-jinja-hitachi','泉神社','いずみじんじゃ','shrine','旧郷社','茨城県','日立市','茨城県日立市水木町2-22-1',36.5185528,140.6249083,null,null,'https://izumi-jinjya.com/','延喜式内社。境内に「泉が森」の湧水があり水の神を祀る。','https://ja.wikipedia.org/wiki/泉神社_(日立市)','Wikipedia',true,now()),
('mito-yoshida-jinja','吉田神社','よしだじんじゃ','shrine','旧県社・名神大社','茨城県','水戸市','茨城県水戸市宮内町3193-2',36.36167,140.48194,null,null,'https://yoshidajinja.jp/','常陸国三宮。日本武尊を祀る朝日山上の古社。','https://ja.wikipedia.org/wiki/吉田神社_(水戸市)','Wikipedia',true,now()),
('suzumenomiya-jinja','雀宮神社','すずめのみやじんじゃ','shrine','旧郷社','栃木県','宇都宮市','栃木県宇都宮市雀の宮1-1-23',36.497472,139.873750,1713,null,null,'宇都宮城の南方を守護する朱雀の社。日光街道沿いの古社。','https://ja.wikipedia.org/wiki/雀宮神社','Wikipedia',true,now()),
('nogi-jinja-nasushiobara','乃木神社','のぎじんじゃ','shrine','旧県社','栃木県','那須塩原市','栃木県那須塩原市石林795',36.96889,140.07556,1916,null,null,'乃木希典夫妻を祀る。旧乃木邸が隣接し桜並木の参道で知られる。','https://ja.wikipedia.org/wiki/乃木神社_(那須塩原市)','Wikipedia',true,now()),
('bando-hoonji','坂東報恩寺','ばんどうほうおんじ','temple','浄土真宗大谷派','東京都','台東区','東京都台東区東上野6-13-13',35.712944,139.784667,null,'阿弥陀如来','https://www.bando-houonji.or.jp/','親鸞の高弟性信が下総に開いた古刹。坂東本（教行信証）で知られる。','https://ja.wikipedia.org/wiki/報恩寺_(台東区)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け (batch 1)
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='izumi-jinja-hitachi' and d.slug in ('amenohayatamahime'))
or (t.slug='mito-yoshida-jinja' and d.slug in ('yamato_takeru'))
or (t.slug='suzumenomiya-jinja' and d.slug in ('susanoo'))
or (t.slug='nogi-jinja-nasushiobara' and d.slug in ('nogi_maresuke','nogi_shizuko'))
or (t.slug='bando-hoonji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== batch 2 (群馬・埼玉・千葉) =====
-- 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('genmei_tenno','元明天皇','げんめいてんのう','kami','人物神','{}','記紀','和銅改元・和同開珎発行を行った第43代天皇。秩父・聖神社に祀る。','https://ja.wikipedia.org/wiki/聖神社_(秩父市)','Wikipedia',true,now()),
('sakitamahiko','前玉彦命','さきたまひこのみこと','kami','国津神','{}','記紀','埼玉県名の起源とされる前玉神社の祭神。','https://ja.wikipedia.org/wiki/前玉神社','Wikipedia',true,now()),
('sakitamahime','前玉比売命','さきたまひめのみこと','kami','国津神','{}','記紀','前玉彦命の后神。前玉神社の祭神。','https://ja.wikipedia.org/wiki/前玉神社','Wikipedia',true,now()),
('fujiwara_morokata','藤原師賢','ふじわらのもろかた','kami','人物神','{文貞公}','史実','後醍醐天皇の身代わりとなった公卿。小御門神社の祭神。','https://ja.wikipedia.org/wiki/小御門神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='genmei_tenno' and g.slug in ('kinun','shobai','kaiun'))
or (d.slug='sakitamahiko' and g.slug in ('kaiun','kanai_anzen'))
or (d.slug='sakitamahime' and g.slug in ('enmusubi','kanai_anzen'))
or (d.slug='fujiwara_morokata' and g.slug in ('kotsu_anzen','yakubarai','gakugyo'))
on conflict do nothing;

-- 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sakisaki-jinja','咲前神社','さきさきじんじゃ','shrine','旧郷社','群馬県','安中市','群馬県安中市鷺宮3308',36.301306,138.879250,531,null,null,'経津主神を祀る古社。養蚕守護の社として知られる。','https://ja.wikipedia.org/wiki/咲前神社','Wikipedia',true,now()),
('sakitama-jinja','前玉神社','さきたまじんじゃ','shrine','旧郷社','埼玉県','行田市','埼玉県行田市埼玉5450',36.123194,139.479639,null,null,null,'埼玉県名の起源とされる古社。さきたま古墳群の浅間塚上に鎮座。','https://ja.wikipedia.org/wiki/前玉神社','Wikipedia',true,now()),
('chichibu-hijiri-jinja','聖神社','ひじりじんじゃ','shrine','旧村社','埼玉県','秩父市','埼玉県秩父市黒谷2191',36.050081,139.102581,708,null,null,'和銅出土と和同開珎にちなむ「銭神様」。金運の社。','https://ja.wikipedia.org/wiki/聖神社_(秩父市)','Wikipedia',true,now()),
('komikado-jinja','小御門神社','こみかどじんじゃ','shrine','旧別格官幣社','千葉県','成田市','千葉県成田市名古屋898',35.85583,140.3585,1882,null,null,'藤原師賢を祀る。「身代わりの神」「航空安全」で知られる。','https://ja.wikipedia.org/wiki/小御門神社','Wikipedia',true,now()),
('narita-makata-jinja','麻賀多神社','まかたじんじゃ','shrine','旧郷社','千葉県','成田市','千葉県成田市台方1',35.770833,140.276389,608,null,null,'印旛沼周辺18社の総本社。大杉(県天然記念物)で知られる。','https://ja.wikipedia.org/wiki/麻賀多神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sakisaki-jinja' and d.slug in ('futsunushi','okuninushi'))
or (t.slug='sakitama-jinja' and d.slug in ('sakitamahiko','sakitamahime'))
or (t.slug='chichibu-hijiri-jinja' and d.slug in ('kanayamahiko','genmei_tenno'))
or (t.slug='komikado-jinja' and d.slug in ('fujiwara_morokata'))
or (t.slug='narita-makata-jinja' and d.slug in ('wakumusubi'))
on conflict do nothing;

-- ===== batch 3 (東京・神奈川) =====
-- 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenoshitaharu','天下春命','あめのしたはるのみこと','kami','天津神','{}','記紀','思兼命の御子神。武蔵国一宮・小野神社の主祭神。','https://ja.wikipedia.org/wiki/小野神社_(多摩市)','Wikipedia',true,now()),
('kamakura_gongoro','鎌倉権五郎景政','かまくらごんごろうかげまさ','kami','人物神','{鎌倉景政}','史実','後三年の役で武勇を示した平安期の武将。鎌倉・御霊神社の祭神。','https://ja.wikipedia.org/wiki/御霊神社_(鎌倉市)','Wikipedia',true,now()),
('arukahiko','有鹿比古命','あるかひこのみこと','kami','国津神','{}','記紀','相模国延喜式内社・有鹿神社の祭神。水と農耕の神。','https://ja.wikipedia.org/wiki/有鹿神社','Wikipedia',true,now()),
('arukahime','有鹿比売命','あるかひめのみこと','kami','国津神','{}','記紀','有鹿比古命の后神。有鹿神社の祭神。','https://ja.wikipedia.org/wiki/有鹿神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenoshitaharu' and g.slug in ('gakumon','kaiun','shusse'))
or (d.slug='kamakura_gongoro' and g.slug in ('shobu','byoki_heyu','yakubarai'))
or (d.slug='arukahiko' and g.slug in ('suisan_noko','mizu_amagoi','kanai_anzen'))
or (d.slug='arukahime' and g.slug in ('enmusubi','anzan','kanai_anzen'))
on conflict do nothing;

-- 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ono-jinja-tama','小野神社','おのじんじゃ','shrine','旧郷社・武蔵国一宮論社','東京都','多摩市','東京都多摩市一ノ宮1-18-8',35.6530028,139.4422722,null,null,null,'武蔵国一宮論社。天下春命を主祭神とする多摩の古社。','https://ja.wikipedia.org/wiki/小野神社_(多摩市)','Wikipedia',true,now()),
('anamori-inari-jinja','穴守稲荷神社','あなもりいなりじんじゃ','shrine','単立','東京都','大田区','東京都大田区羽田5-2-7',35.550389,139.749639,1810,null,'https://anamori.jp/','羽田に鎮座する東京有数の稲荷社。航空・旅行安全で知られる。','https://ja.wikipedia.org/wiki/穴守稲荷神社','Wikipedia',true,now()),
('goryo-jinja-kamakura','御霊神社','ごりょうじんじゃ','shrine','旧村社','神奈川県','鎌倉市','神奈川県鎌倉市坂ノ下4-9',35.311111,139.532778,null,null,null,'鎌倉権五郎景政を祀る通称「権五郎神社」。面掛行列で知られる。','https://ja.wikipedia.org/wiki/御霊神社_(鎌倉市)','Wikipedia',true,now()),
('kamegaike-hachimangu','亀ヶ池八幡宮','かめがいけはちまんぐう','shrine','旧村社','神奈川県','相模原市','神奈川県相模原市中央区上溝1678',35.550978,139.366186,1331,null,null,'相模原・上溝の総鎮守。亀の池に由来する八幡宮。','https://ja.wikipedia.org/wiki/亀ヶ池八幡宮','Wikipedia',true,now()),
('aruka-jinja','有鹿神社','あるかじんじゃ','shrine','旧郷社・名神大社','神奈川県','海老名市','神奈川県海老名市上郷1-4-41',35.453611,139.377306,null,null,null,'相模国最古級の延喜式内社。水引祭で知られる。','https://ja.wikipedia.org/wiki/有鹿神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ono-jinja-tama' and d.slug in ('amenoshitaharu'))
or (t.slug='anamori-inari-jinja' and d.slug in ('toyouke'))
or (t.slug='goryo-jinja-kamakura' and d.slug in ('kamakura_gongoro'))
or (t.slug='kamegaike-hachimangu' and d.slug in ('hachiman'))
or (t.slug='aruka-jinja' and d.slug in ('arukahiko','arukahime'))
on conflict do nothing;

-- ===== batch 4 (茨城・埼玉) =====
-- 社寺 (新規神仏なし。既存slug流用)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kasama-atago-jinja','愛宕神社','あたごじんじゃ','shrine','旧村社','茨城県','笠間市','茨城県笠間市泉101',36.291936,140.254592,806,null,null,'日本三大火防の一つに数えられる愛宕山上の古社。','https://ja.wikipedia.org/wiki/愛宕神社_(笠間市)','Wikipedia',true,now()),
('ibaraki-gokoku-jinja','茨城県護国神社','いばらきけんごこくじんじゃ','shrine','護国神社','茨城県','水戸市','茨城県水戸市見川1-2-1',36.374667,140.447417,1878,null,'https://www.ibaraki-gokoku.or.jp/','偕楽園桜山に鎮座する茨城県の護国神社。','https://ja.wikipedia.org/wiki/茨城県護国神社','Wikipedia',true,now()),
('chinju-hikawa-jinja','鎮守氷川神社','ちんじゅひかわじんじゃ','shrine','旧村社','埼玉県','川口市','埼玉県川口市青木5-18-48',35.817222,139.723056,null,null,null,'横尾忠則の天井画「自立の炎」で知られる川口の氷川社。','https://ja.wikipedia.org/wiki/鎮守氷川神社','Wikipedia',true,now()),
('nogoji-kumagaya','能護寺','のうごじ','temple','高野山真言宗','埼玉県','熊谷市','埼玉県熊谷市永井太田1141',36.231111,139.339111,743,'大日如来',null,'「妻沼のあじさい寺」として知られる行基開創の古刹。','https://ja.wikipedia.org/wiki/能護寺','Wikipedia',true,now()),
('heirinji-niiza','平林寺','へいりんじ','temple','臨済宗妙心寺派','埼玉県','新座市','埼玉県新座市野火止3-1-1',35.789844,139.560206,1375,'釈迦如来','https://www.heirinji.or.jp/','武蔵野の面影を残す国指定天然記念物の境内林で知られる名刹。','https://ja.wikipedia.org/wiki/平林寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kasama-atago-jinja' and d.slug in ('izanami'))
or (t.slug='ibaraki-gokoku-jinja' and d.slug in ('eirei'))
or (t.slug='chinju-hikawa-jinja' and d.slug in ('susanoo','kushinadahime'))
or (t.slug='nogoji-kumagaya' and d.slug in ('dainichi_nyorai'))
or (t.slug='heirinji-niiza' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== batch 5 (千葉) =====
-- 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenohirinome','天比理乃咩命','あめのひりのめのみこと','kami','天津神','{洲宮大明神}','記紀','天太玉命の后神。安房・洲崎神社の祭神。','https://ja.wikipedia.org/wiki/洲崎神社_(館山市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenohirinome' and g.slug in ('kaijo_anzen','enmusubi','kanai_anzen'))
on conflict do nothing;

-- 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('susaki-jinja-tateyama','洲崎神社','すのさきじんじゃ','shrine','旧県社・安房国一宮論社','千葉県','館山市','千葉県館山市洲崎1344',34.968056,139.758222,null,null,null,'安房国一宮論社。源頼朝が参拝した海上守護の古社。','https://ja.wikipedia.org/wiki/洲崎神社_(館山市)','Wikipedia',true,now()),
('matsudo-jinja','松戸神社','まつどじんじゃ','shrine','旧村社','千葉県','松戸市','千葉県松戸市松戸1457',35.780644,139.897789,1626,null,'https://www.matsudojinja.com/','日本武尊を祀る松戸の総鎮守。「松戸」地名由来の社。','https://ja.wikipedia.org/wiki/松戸神社','Wikipedia',true,now()),
('chiba-gokoku-jinja','千葉県護国神社','ちばけんごこくじんじゃ','shrine','護国神社','千葉県','千葉市','千葉県千葉市若葉区桜木4-1-1',35.620000,140.111670,1878,null,null,'千葉県出身の英霊を祀る護国神社。','https://ja.wikipedia.org/wiki/千葉県護国神社','Wikipedia',true,now()),
('funabashi-ninomiya-jinja','二宮神社','にのみやじんじゃ','shrine','旧郷社・下総国二宮','千葉県','船橋市','千葉県船橋市三山5-20-1',35.702000,140.052500,810,null,null,'下総国二宮。下総三山の七年祭りで知られる古社。','https://ja.wikipedia.org/wiki/二宮神社_(船橋市)','Wikipedia',true,now()),
('tamasaki-jinja-asahi','玉崎神社','たまさきじんじゃ','shrine','旧郷社・下総国二宮論社','千葉県','旭市','千葉県旭市飯岡2126-1',35.697639,140.726528,null,null,null,'九十九里浜東端の古社。日本武尊と玉依姫の伝承を伝える。','https://ja.wikipedia.org/wiki/玉崎神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='susaki-jinja-tateyama' and d.slug in ('amenohirinome'))
or (t.slug='matsudo-jinja' and d.slug in ('yamato_takeru'))
or (t.slug='chiba-gokoku-jinja' and d.slug in ('eirei'))
or (t.slug='funabashi-ninomiya-jinja' and d.slug in ('susanoo','kushinadahime'))
or (t.slug='tamasaki-jinja-asahi' and d.slug in ('tamayorihime'))
on conflict do nothing;

-- ===== batch 6 (東京) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yoyogi-hachimangu','代々木八幡宮','よよぎはちまんぐう','shrine','旧村社','東京都','渋谷区','東京都渋谷区代々木5-1-1',35.671917,139.688917,1212,null,'https://www.yoyogihachimangu.or.jp/','縄文遺跡の竪穴住居が残る渋谷の八幡宮。出世稲荷でも知られる。','https://ja.wikipedia.org/wiki/代々木八幡宮','Wikipedia',true,now()),
('kamimeguro-hikawa-jinja','上目黒氷川神社','かみめぐろひかわじんじゃ','shrine','旧村社','東京都','目黒区','東京都目黒区大橋2-16-21',35.652861,139.688139,null,null,null,'目黒富士で知られる大橋の氷川社。','https://ja.wikipedia.org/wiki/上目黒氷川神社','Wikipedia',true,now()),
('ushitenjin-kitano-jinja','牛天神北野神社','うしてんじんきたのじんじゃ','shrine','旧村社','東京都','文京区','東京都文京区春日1-5-2',35.70778,139.74667,1184,null,'https://ushitenjin.jp/','源頼朝が夢告により創建したと伝わる「牛天神」。','https://ja.wikipedia.org/wiki/北野神社_(文京区)','Wikipedia',true,now()),
('mizu-inari-jinja','水稲荷神社','みずいなりじんじゃ','shrine','旧村社','東京都','新宿区','東京都新宿区西早稲田3-5-43',35.711472,139.715278,941,null,null,'藤原秀郷の勧請と伝わる稲荷社。江戸最古の富士塚「高田富士」がある。','https://ja.wikipedia.org/wiki/水稲荷神社','Wikipedia',true,now()),
('juban-inari-jinja','十番稲荷神社','じゅうばんいなりじんじゃ','shrine','旧村社','東京都','港区','東京都港区麻布十番1-4-6',35.656972,139.735056,1950,null,'https://www.jubaninari.or.jp/','麻布十番の鎮守。火伏せのかえる御守で知られる。','https://ja.wikipedia.org/wiki/十番稲荷神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yoyogi-hachimangu' and d.slug in ('hachiman'))
or (t.slug='kamimeguro-hikawa-jinja' and d.slug in ('susanoo','amaterasu','michizane'))
or (t.slug='ushitenjin-kitano-jinja' and d.slug in ('michizane'))
or (t.slug='mizu-inari-jinja' and d.slug in ('ukanomitama'))
or (t.slug='juban-inari-jinja' and d.slug in ('ukanomitama','yamato_takeru'))
on conflict do nothing;

-- ===== batch 7 (神奈川) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanagawa-gokoku-jinja','神奈川県護国神社','かながわけんごこくじんじゃ','shrine','護国神社','神奈川県','鎌倉市','神奈川県鎌倉市常盤917',35.342647,139.531064,2018,null,null,'神奈川県・相模国の英霊を祀る護国神社。民間有志により再建。','https://ja.wikipedia.org/wiki/神奈川県護国神社','Wikipedia',true,now()),
('tsurumi-jinja','鶴見神社','つるみじんじゃ','shrine','旧村社','神奈川県','横浜市','神奈川県横浜市鶴見区鶴見中央1-14-1',35.511083,139.677389,null,null,null,'横浜・川崎最古級の古社。旧称杉山大明神。','https://ja.wikipedia.org/wiki/鶴見神社_(横浜市)','Wikipedia',true,now()),
('hoshikawa-sugiyama-jinja','星川杉山神社','ほしかわすぎやまじんじゃ','shrine','旧村社・式内社論社','神奈川県','横浜市','神奈川県横浜市保土ケ谷区星川1-19-1',35.456839,139.590233,null,null,null,'武蔵国都筑郡の式内社論社。日本武尊を祀る。','https://ja.wikipedia.org/wiki/星川杉山神社','Wikipedia',true,now()),
('yokohama-naritasan-enmeiin','成田山横浜別院延命院','なりたさんよこはまべついんえんめいいん','temple','真言宗智山派','神奈川県','横浜市','神奈川県横浜市西区宮崎町30',35.449167,139.627500,1870,'不動明王','https://www.yokohama-naritasan.or.jp/','成田山新勝寺の横浜別院。「野毛山不動尊」として親しまれる。','https://ja.wikipedia.org/wiki/成田山横浜別院延命院','Wikipedia',true,now()),
('koyurugi-jinja','小動神社','こゆるぎじんじゃ','shrine','旧村社','神奈川県','鎌倉市','神奈川県鎌倉市腰越2-9-12',35.306431,139.493103,1185,null,null,'腰越の鎮守。湘南の天王祭(腰越祭)で知られる。','https://ja.wikipedia.org/wiki/小動神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanagawa-gokoku-jinja' and d.slug in ('eirei'))
or (t.slug='tsurumi-jinja' and d.slug in ('itakeru','susanoo'))
or (t.slug='hoshikawa-sugiyama-jinja' and d.slug in ('yamato_takeru'))
or (t.slug='yokohama-naritasan-enmeiin' and d.slug in ('fudo_myoo'))
or (t.slug='koyurugi-jinja' and d.slug in ('susanoo','takeminakata','yamato_takeru'))
on conflict do nothing;
