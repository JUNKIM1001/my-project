-- 関東 観光著名社寺 追加分 (kanto-3)
-- 担当: 茨城・栃木・群馬・埼玉・千葉・東京・神奈川
-- 全件 ja.wikipedia.org infobox の十進座標で裏取り済み

-- ===== バッチ1: 東京の著名社寺 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('iwatsutsuo','岩筒雄命','いわつつおのみこと','kami','天津神','{}','記紀','経津主神の祖とされる剣の神。赤城神社の祭神。','https://ja.wikipedia.org/wiki/赤城神社_(新宿区)','Wikipedia',true,now()),
('akagihime','赤城姫命','あかぎひめのみこと','kami','国津神','{}','赤城信仰','赤城山の女神。赤城神社に祀られる。','https://ja.wikipedia.org/wiki/赤城神社_(新宿区)','Wikipedia',true,now()),
('ono_no_takamura','小野篁','おののたかむら','kami','御霊','{野相公}','歴史','平安初期の漢学者・歌人。学問の神として小野照崎神社に祀られる。','https://ja.wikipedia.org/wiki/小野篁','Wikipedia',true,now()),
('sutoku_tenno','崇徳天皇','すとくてんのう','kami','御霊','{崇徳院}','歴史','第75代天皇。讃岐に配流され金刀比羅・讃岐の地で神格化された。','https://ja.wikipedia.org/wiki/崇徳天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='iwatsutsuo' and g.slug in ('shobu','yakubarai'))
or (d.slug='akagihime' and g.slug in ('enmusubi','kanai_anzen'))
or (d.slug='ono_no_takamura' and g.slug in ('gakumon','gakugyo','geino'))
or (d.slug='sutoku_tenno' and g.slug in ('yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hanazono-jinja','花園神社','はなぞのじんじゃ','shrine','旧郷社','東京都','新宿区','東京都新宿区新宿5丁目17番3号',35.693528,139.705139,1590,null,'http://www.hanazono-jinja.or.jp','新宿総鎮守。酉の市と芸能の神で知られ、境内には芸能浅間神社がある。','https://ja.wikipedia.org/wiki/花園神社','Wikipedia',true,now()),
('akagi-jinja-shinjuku','赤城神社','あかぎじんじゃ','shrine','旧郷社','東京都','新宿区','東京都新宿区赤城元町1-10',35.704972,139.736333,1300,null,'https://www.akagi-jinja.jp/','牛込総鎮守。隈研吾設計の現代的社殿で知られる。','https://ja.wikipedia.org/wiki/赤城神社_(新宿区)','Wikipedia',true,now()),
('onoteru-jinja','小野照崎神社','おのてるさきじんじゃ','shrine','旧郷社','東京都','台東区','東京都台東区下谷2-13-14',35.721917,139.783610,852,null,'http://onoteru.or.jp/','小野篁・菅原道真を祀る学問芸能の社。下谷の鎮守。','https://ja.wikipedia.org/wiki/小野照崎神社','Wikipedia',true,now()),
('torikoe-jinja','鳥越神社','とりこえじんじゃ','shrine','旧村社','東京都','台東区','東京都台東区鳥越2-4-1',35.701940,139.785560,651,null,null,'日本武尊を祀る古社。都内最大級の千貫神輿の例大祭で有名。','https://ja.wikipedia.org/wiki/鳥越神社','Wikipedia',true,now()),
('gotokuji','豪徳寺','ごうとくじ','temple','曹洞宗','東京都','世田谷区','東京都世田谷区豪徳寺2丁目24-7',35.648778,139.647417,1480,'釈迦如来','https://gotokuji.jp/','井伊家の菩提寺。招き猫発祥の地の一つとして知られる。','https://ja.wikipedia.org/wiki/豪徳寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hanazono-jinja' and d.slug in ('ukanomitama','yamatotakeru','ukemochi'))
or (t.slug='akagi-jinja-shinjuku' and d.slug in ('iwatsutsuo','akagihime'))
or (t.slug='onoteru-jinja' and d.slug in ('ono_no_takamura','michizane'))
or (t.slug='torikoe-jinja' and d.slug in ('yamatotakeru'))
or (t.slug='gotokuji' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== バッチ2: 東京の著名社寺(続) =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('setagaya-hachimangu','世田谷八幡宮','せたがやはちまんぐう','shrine','旧郷社','東京都','世田谷区','東京都世田谷区宮坂一丁目26番3号',35.648890,139.644440,1091,null,null,'源義家ゆかりの八幡宮。奉納相撲(江戸三大相撲)で知られる。','https://ja.wikipedia.org/wiki/世田谷八幡宮','Wikipedia',true,now()),
('sengakuji','泉岳寺','せんがくじ','temple','曹洞宗','東京都','港区','東京都港区高輪2丁目11-1',35.637722,139.736278,1612,'釈迦如来','https://sengakuji.or.jp/','赤穂浪士四十七士と浅野長矩の墓所で知られる江戸の名刹。','https://ja.wikipedia.org/wiki/泉岳寺','Wikipedia',true,now()),
('shiba-daijingu','芝大神宮','しばだいじんぐう','shrine','旧府社','東京都','港区','東京都港区芝大門1丁目12-7',35.657639,139.753060,1005,null,'https://www.shibadaijingu.com/','伊勢神宮の内外宮の神を祀る「関東のお伊勢様」。東京十社の一。','https://ja.wikipedia.org/wiki/芝大神宮','Wikipedia',true,now()),
('toranomon-kotohiragu','虎ノ門金刀比羅宮','とらのもんことひらぐう','shrine','旧府社','東京都','港区','東京都港区虎ノ門一丁目2番地7号',35.669611,139.748000,1660,null,'http://www.kotohira.or.jp/','讃岐金刀比羅宮の分霊を祀る。海上守護・商売繁盛の都心の社。','https://ja.wikipedia.org/wiki/虎ノ門金刀比羅宮','Wikipedia',true,now()),
('takahata-fudoson','高幡不動尊金剛寺','たかはたふどうそんこんごうじ','temple','真言宗智山派','東京都','日野市','東京都日野市高幡733',35.662083,139.410560,810,'大日如来','https://www.takahatafudoson.or.jp','関東三大不動の一。不動堂・仁王門は重文。あじさいの名所。','https://ja.wikipedia.org/wiki/高幡不動尊金剛寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='setagaya-hachimangu' and d.slug in ('hachiman','chuai','jingu_kogo'))
or (t.slug='sengakuji' and d.slug in ('shaka_nyorai'))
or (t.slug='shiba-daijingu' and d.slug in ('amaterasu','toyouke'))
or (t.slug='toranomon-kotohiragu' and d.slug in ('omononushi','sutoku_tenno'))
or (t.slug='takahata-fudoson' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='takahata-fudoson' and d.slug in ('fudo_myoo'))
on conflict do nothing;

-- ===== バッチ3: 神奈川 鎌倉(その1) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('benzaiten','弁財天','べんざいてん','buddha','天部','{弁才天,宇賀弁財天,サラスヴァティー}','仏教','水・財・芸能を司る天部の女神。宇賀神と習合する。','https://ja.wikipedia.org/wiki/弁才天','Wikipedia',true,now()),
('omiyanome','大宮売命','おおみやのめのみこと','kami','天津神','{}','記紀','宮中を守護し和を司る女神。稲荷五社の一柱。','https://ja.wikipedia.org/wiki/オオミヤノメ','Wikipedia',true,now()),
('morinaga_shinno','護良親王','もりながしんのう','kami','御霊','{大塔宮}','歴史','後醍醐天皇の皇子。建武の中興に尽くし鎌倉宮に祀られる。','https://ja.wikipedia.org/wiki/護良親王','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='benzaiten' and g.slug in ('kinun','geino','gakumon','shobai'))
or (d.slug='omiyanome' and g.slug in ('shobai','enmusubi','kanai_anzen'))
or (d.slug='morinaga_shinno' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zeniarai-benzaiten','銭洗弁財天宇賀福神社','ぜにあらいべんざいてんうがふくじんじゃ','shrine','旧無格社','神奈川県','鎌倉市','神奈川県鎌倉市佐助二丁目25番16号',35.325761,139.542219,1185,null,null,'洞窟の霊水で銭を洗うと money が増えるとされる金運の社。','https://ja.wikipedia.org/wiki/銭洗弁財天宇賀福神社','Wikipedia',true,now()),
('sasuke-inari','佐助稲荷神社','さすけいなりじんじゃ','shrine','旧無格社','神奈川県','鎌倉市','神奈川県鎌倉市佐助2-22-12',35.324444,139.538889,1190,null,'https://sasukeinari.jp/','源頼朝の挙兵を助けた稲荷の伝説を持つ。連なる朱鳥居で有名。','https://ja.wikipedia.org/wiki/佐助稲荷神社','Wikipedia',true,now()),
('egara-tenjin','荏柄天神社','えがらてんじんしゃ','shrine','旧村社','神奈川県','鎌倉市','神奈川県鎌倉市二階堂74',35.325861,139.564306,1104,null,'http://www.tenjinsha.com/','日本三天神の一に数えられる古社。鎌倉幕府の鬼門鎮護。','https://ja.wikipedia.org/wiki/荏柄天神社','Wikipedia',true,now()),
('kamakuragu','鎌倉宮','かまくらぐう','shrine','旧官幣中社','神奈川県','鎌倉市','神奈川県鎌倉市二階堂154',35.326167,139.566861,1869,null,'http://www.kamakuraguu.jp/','護良親王を祀る。明治天皇の創建による大塔宮。','https://ja.wikipedia.org/wiki/鎌倉宮','Wikipedia',true,now()),
('hokokuji-kamakura','報国寺','ほうこくじ','temple','臨済宗建長寺派','神奈川県','鎌倉市','神奈川県鎌倉市浄明寺2丁目7-4',35.319972,139.569278,1334,'釈迦三尊','https://houkokuji.or.jp/','約2千本の孟宗竹が茂る「竹の寺」として知られる。','https://ja.wikipedia.org/wiki/報国寺_(鎌倉市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zeniarai-benzaiten' and d.slug in ('ichikishima','benzaiten'))
or (t.slug='sasuke-inari' and d.slug in ('ukanomitama','okuninushi','sarutahiko','omiyanome','kotoshironushi'))
or (t.slug='egara-tenjin' and d.slug in ('michizane'))
or (t.slug='kamakuragu' and d.slug in ('morinaga_shinno'))
or (t.slug='hokokuji-kamakura' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== バッチ4: 神奈川 鎌倉・足柄・横浜 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kotosaka_no_o','事解之男命','ことさかのおのみこと','kami','天津神','{}','記紀','伊弉冉尊の離別の際に生じた熊野信仰の神。','https://ja.wikipedia.org/wiki/師岡熊野神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kotosaka_no_o' and g.slug in ('yakubarai','enkiri'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('meigetsuin','明月院','めいげついん','temple','臨済宗建長寺派','神奈川県','鎌倉市','神奈川県鎌倉市山ノ内189',35.334992,139.551456,1160,'聖観音','http://www.komainu.com/','「あじさい寺」として名高い。悟りの窓と明月院ブルーで知られる。','https://ja.wikipedia.org/wiki/明月院','Wikipedia',true,now()),
('tokeiji','東慶寺','とうけいじ','temple','臨済宗円覚寺派','神奈川県','鎌倉市','神奈川県鎌倉市山ノ内1367',35.335244,139.545631,1285,'釈迦如来',null,'江戸期に女性を救った縁切寺(駆け込み寺)として知られる尼寺。','https://ja.wikipedia.org/wiki/東慶寺','Wikipedia',true,now()),
('komyoji-kamakura','光明寺','こうみょうじ','temple','浄土宗','神奈川県','鎌倉市','神奈川県鎌倉市材木座六丁目17番19号',35.303250,139.554720,1243,'阿弥陀如来','http://komyoji-kamakura.or.jp/','浄土宗の関東総本山。材木座海岸に面する大伽藍。','https://ja.wikipedia.org/wiki/光明寺_(鎌倉市)','Wikipedia',true,now()),
('daiyuzan-saijoji','大雄山最乗寺','だいゆうざんさいじょうじ','temple','曹洞宗','神奈川県','南足柄市','神奈川県南足柄市大雄町1157',35.301940,139.075560,1394,'釈迦牟尼仏','https://daiyuuzan.or.jp','曹洞宗の大寺。天狗伝説と巨大な高下駄で知られる修行道場。','https://ja.wikipedia.org/wiki/最乗寺','Wikipedia',true,now()),
('morooka-kumano','師岡熊野神社','もろおかくまのじんじゃ','shrine','旧郷社','神奈川県','横浜市','神奈川県横浜市港北区師岡町字表谷戸1137番地',35.524170,139.635560,724,null,'http://www.kumanojinja.or.jp','関東の熊野信仰の中心地。横浜北部の総鎮守。','https://ja.wikipedia.org/wiki/師岡熊野神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='meigetsuin' and d.slug in ('sho_kannon'))
or (t.slug='tokeiji' and d.slug in ('shaka_nyorai'))
or (t.slug='komyoji-kamakura' and d.slug in ('amida_nyorai'))
or (t.slug='daiyuzan-saijoji' and d.slug in ('shaka_nyorai'))
or (t.slug='morooka-kumano' and d.slug in ('izanami','hayatama','kotosaka_no_o'))
on conflict do nothing;

-- ===== バッチ5: 神奈川・埼玉 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kangiten','歓喜天','かんぎてん','buddha','天部','{聖天,大聖歓喜天,ガネーシャ}','仏教','象頭人身の天部。夫婦和合・商売繁盛を司る聖天信仰の本尊。','https://ja.wikipedia.org/wiki/歓喜天','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kangiten' and g.slug in ('shobai','enmusubi','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('seto-jinja','瀬戸神社','せとじんじゃ','shrine','旧郷社','神奈川県','横浜市','神奈川県横浜市金沢区瀬戸18-14',35.332528,139.621972,1180,null,'http://www.setojinja.or.jp/','源頼朝が伊豆三島明神を勧請した古社。金沢の海の守護神。','https://ja.wikipedia.org/wiki/瀬戸神社','Wikipedia',true,now()),
('morito-daimyojin','森戸大明神','もりとだいみょうじん','shrine','旧村社','神奈川県','三浦郡葉山町','神奈川県三浦郡葉山町堀内1025',35.272861,139.569722,1180,null,'http://moritojinja.jp/','源頼朝勧請の葉山の総鎮守。相模湾と富士を望む景勝の社。','https://ja.wikipedia.org/wiki/森戸大明神','Wikipedia',true,now()),
('tsuki-jinja','調神社','つきじんじゃ','shrine','旧県社','埼玉県','さいたま市','埼玉県さいたま市浦和区岸町3-17-25',35.853444,139.655830,771,null,null,'鳥居が無く狛犬の代わりに兎を置く「つきのみや」。月信仰の古社。','https://ja.wikipedia.org/wiki/調神社','Wikipedia',true,now()),
('kawagoe-hachimangu','川越八幡宮','かわごえはちまんぐう','shrine','旧村社','埼玉県','川越市','埼玉県川越市南通町19-1',35.911278,139.484556,1030,null,'http://kawagoe-hachimangu.net/','源頼信創建と伝わる川越総鎮守の八幡。縁結びの夫婦銀杏で知られる。','https://ja.wikipedia.org/wiki/川越八幡宮','Wikipedia',true,now()),
('shoden-kangiin','聖天山歓喜院','しょうでんざんかんぎいん','temple','高野山真言宗','埼玉県','熊谷市','埼玉県熊谷市妻沼1627',36.228194,139.374720,1179,'歓喜天','http://www.ksky.ne.jp/~shouden/','「妻沼聖天山」として親しまれる。国宝の本殿(聖天堂)で名高い。','https://ja.wikipedia.org/wiki/歓喜院_(熊谷市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='seto-jinja' and d.slug in ('oyamatsumi'))
or (t.slug='morito-daimyojin' and d.slug in ('oyamatsumi','kotoshironushi'))
or (t.slug='tsuki-jinja' and d.slug in ('amaterasu','toyouke','susanoo'))
or (t.slug='kawagoe-hachimangu' and d.slug in ('hachiman'))
or (t.slug='shoden-kangiin' and d.slug in ('kangiten'))
on conflict do nothing;

-- ===== バッチ6: 埼玉・千葉 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nichiren','日蓮','にちれん','buddha','高僧','{立正大師}','仏教','鎌倉時代の僧。日蓮宗の宗祖。法華経を唱導した。','https://ja.wikipedia.org/wiki/日蓮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nichiren' and g.slug in ('yakubarai','kaiun','shobu'))
on conflict do nothing;
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hodosan-jinja','宝登山神社','ほどさんじんじゃ','shrine','旧県社','埼玉県','秩父郡長瀞町','埼玉県秩父郡長瀞町長瀞1828',36.093222,139.103097,111,null,'https://www.hodosan-jinja.or.jp/','秩父三社の一。宝登山麓に鎮座し火防・盗難除けで知られる。','https://ja.wikipedia.org/wiki/宝登山神社','Wikipedia',true,now()),
('chiba-jinja','千葉神社','ちばじんじゃ','shrine','旧県社','千葉県','千葉市','千葉県千葉市中央区院内1-16-1',35.611806,140.123833,1000,null,'http://www.chibajinja.com','妙見信仰の総本社格。北辰妙見尊星王を祀る厄除開運の社。','https://ja.wikipedia.org/wiki/千葉神社','Wikipedia',true,now()),
('kemigawa-jinja','検見川神社','けみがわじんじゃ','shrine','旧村社','千葉県','千葉市','千葉県千葉市花見川区検見川町1-1',35.653556,140.065972,869,null,'http://www.kemigawa-jinja.com/','八方除けの守護神として知られる三神殿の古社。','https://ja.wikipedia.org/wiki/検見川神社','Wikipedia',true,now()),
('iigaoka-hachimangu','飯香岡八幡宮','いいがおかはちまんぐう','shrine','旧県社','千葉県','市原市','千葉県市原市八幡1057-1',35.537531,140.117675,675,null,null,'上総国総社とされる古社。本殿は国の重要文化財。','https://ja.wikipedia.org/wiki/飯香岡八幡宮','Wikipedia',true,now()),
('sogenji-mobara','茂原藻原寺','もばらそうげんじ','temple','日蓮宗','千葉県','茂原市','千葉県茂原市茂原1201',35.429083,140.284306,1276,'三宝尊','https://higashiminobu.sougenji.nichiren-shu.jp/','日蓮宗の本山。「東身延」と称される名刹。','https://ja.wikipedia.org/wiki/藻原寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hodosan-jinja' and d.slug in ('jimmu','oyamatsumi','hinokagutsuchi'))
or (t.slug='chiba-jinja' and d.slug in ('amenominakanushi'))
or (t.slug='kemigawa-jinja' and d.slug in ('susanoo','ukanomitama','izanami'))
or (t.slug='iigaoka-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
or (t.slug='sogenji-mobara' and d.slug in ('nichiren'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='chiba-jinja' and d.slug in ('futsunushi','yamatotakeru'))
on conflict do nothing;

-- ===== バッチ7: 茨城・栃木・群馬 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('furu_no_okami','布留大神','ふるのおおかみ','kami','天津神','{布都御魂}','記紀','石上の神剣に宿る霊威。武運・除災を司る。','https://ja.wikipedia.org/wiki/常陸國總社宮','Wikipedia',true,now()),
('amenomihoko','天御鉾命','あめのみほこのみこと','kami','天津神','{}','記紀','機織・産業の神。足利織姫神社の祭神。','https://ja.wikipedia.org/wiki/足利織姫神社','Wikipedia',true,now()),
('yachichihime','八千々姫命','やちちひめのみこと','kami','天津神','{}','記紀','機織を司る女神。天御鉾命とともに織物の神とされる。','https://ja.wikipedia.org/wiki/足利織姫神社','Wikipedia',true,now()),
('akagi_no_kami','赤城神','あかぎのかみ','kami','国津神','{赤城大明神}','赤城信仰','赤城山を神格化した山岳神。赤城神社の主神。','https://ja.wikipedia.org/wiki/赤城神社_(前橋市三夜沢町)','Wikipedia',true,now()),
('toyokiirihiko','豊城入彦命','とよきいりひこのみこと','kami','御霊','{}','記紀','崇神天皇の皇子で東国経営の祖神。上毛野氏の祖。','https://ja.wikipedia.org/wiki/赤城神社_(前橋市三夜沢町)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='furu_no_okami' and g.slug in ('yakubarai','shobu'))
or (d.slug='amenomihoko' and g.slug in ('shobai','enmusubi','shigoto'))
or (d.slug='yachichihime' and g.slug in ('enmusubi','renai','shobai'))
or (d.slug='akagi_no_kami' and g.slug in ('kaiun','yakubarai','suisan_noko'))
or (d.slug='toyokiirihiko' and g.slug in ('shobu','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oiwa-jinja','御岩神社','おいわじんじゃ','shrine','旧郷社','茨城県','日立市','茨城県日立市入四間町752',36.635125,140.588833,null,null,'http://www.oiwajinja.jp/','188柱の神々を祀る御岩山の霊場。日本最強パワースポットと称される。','https://ja.wikipedia.org/wiki/御岩神社','Wikipedia',true,now()),
('hitachi-sosyagu','常陸国総社宮','ひたちのくにそうしゃぐう','shrine','旧県社','茨城県','石岡市','茨城県石岡市総社二丁目8-1',36.187861,140.269056,729,null,'http://www.sosyagu.jp/','常陸国の総社。石岡のおまつり(常陸國總社宮例大祭)で名高い。','https://ja.wikipedia.org/wiki/常陸國總社宮','Wikipedia',true,now()),
('ashikaga-orihime','足利織姫神社','あしかがおりひめじんじゃ','shrine','旧無格社','栃木県','足利市','栃木県足利市西宮町3889番地',36.339222,139.444944,1705,null,'https://www.orihimejinjya.com/','織物の街足利の守護。縁結びの社として知られる朱塗りの社殿。','https://ja.wikipedia.org/wiki/足利織姫神社','Wikipedia',true,now()),
('miyosawa-akagi','赤城神社（三夜沢）','みよさわあかぎじんじゃ','shrine','旧県社','群馬県','前橋市','群馬県前橋市三夜沢町114番地',36.484056,139.177694,null,null,null,'全国約300社の赤城神社の本社とされる古社。赤城山信仰の中心。','https://ja.wikipedia.org/wiki/赤城神社_(前橋市三夜沢町)','Wikipedia',true,now()),
('shorinzan-darumaji','少林山達磨寺','しょうりんざんだるまじ','temple','黄檗宗','群馬県','高崎市','群馬県高崎市鼻高町296',36.330560,138.956940,1712,'十一面観音','http://www.daruma.or.jp/','高崎だるま発祥の寺。少林山七草大祭だるま市で知られる。','https://ja.wikipedia.org/wiki/少林山達磨寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oiwa-jinja' and d.slug in ('kunitokotachi','okuninushi','izanagi','izanami'))
or (t.slug='hitachi-sosyagu' and d.slug in ('izanagi','okuninushi','susanoo','ninigi','omiyanome','furu_no_okami'))
or (t.slug='ashikaga-orihime' and d.slug in ('amenomihoko','yachichihime'))
or (t.slug='miyosawa-akagi' and d.slug in ('akagi_no_kami','okuninushi','toyokiirihiko'))
or (t.slug='shorinzan-darumaji' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- ===== バッチ8: 千葉・東京 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ototachibanahime','弟橘媛命','おとたちばなひめのみこと','kami','御霊','{弟橘比売}','記紀','日本武尊の妃。走水で入水し海を鎮めた。夫婦愛の神。','https://ja.wikipedia.org/wiki/大鳥神社_(目黒区)','Wikipedia',true,now()),
('kishimojin','鬼子母神','きしもじん','buddha','天部','{訶梨帝母}','仏教','子授け・安産・子育てを守護する女神。法華経の守護神。','https://ja.wikipedia.org/wiki/鬼子母神','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ototachibanahime' and g.slug in ('enmusubi','renai','kaijo_anzen'))
or (d.slug='kishimojin' and g.slug in ('kosodate','anzan','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('seichoji-kamogawa','清澄寺','せいちょうじ','temple','日蓮宗','千葉県','鴨川市','千葉県鴨川市清澄322-1',35.160944,140.151390,771,'十界曼荼羅','http://www.seichoji.com','日蓮が立教開宗した日蓮宗大本山。日蓮宗四霊場の一。','https://ja.wikipedia.org/wiki/清澄寺_(鴨川市)','Wikipedia',true,now()),
('nihonji-nokogiriyama','鋸山日本寺','のこぎりやまにほんじ','temple','曹洞宗','千葉県','安房郡鋸南町','千葉県安房郡鋸南町元名184',35.156408,139.832111,725,'薬師瑠璃光如来','http://www.nihonji.jp/','行基開創と伝わる古刹。日本最大の磨崖仏大仏と地獄のぞきで名高い。','https://ja.wikipedia.org/wiki/日本寺_(千葉県鋸南町)','Wikipedia',true,now()),
('oji-jinja','王子神社','おうじじんじゃ','shrine','旧郷社','東京都','北区','東京都北区王子本町一丁目1番12号',35.753278,139.735917,1322,null,'http://ojijinja.tokyo.jp','東京十社の一。王子大神を祀り、王子の地名の由来となった社。','https://ja.wikipedia.org/wiki/王子神社_(東京都北区)','Wikipedia',true,now()),
('homyoji-kishimojin','雑司ヶ谷鬼子母神堂（法明寺）','ぞうしがやきしもじんどう','temple','日蓮宗','東京都','豊島区','東京都豊島区南池袋3-18-18',35.724361,139.713750,810,'三宝尊','http://www.homyoji.or.jp/','子授け・安産の鬼子母神で名高い。境内の鬼子母神堂は重要文化財。','https://ja.wikipedia.org/wiki/法明寺_(豊島区)','Wikipedia',true,now()),
('otori-jinja-meguro','大鳥神社（目黒）','おおとりじんじゃ','shrine','旧郷社','東京都','目黒区','東京都目黒区下目黒3-1-2',35.632139,139.708083,806,null,'https://www.outorijinja.or.jp/','目黒区最古の神社。酉の市と熊手で知られる。','https://ja.wikipedia.org/wiki/大鳥神社_(目黒区)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='seichoji-kamogawa' and d.slug in ('nichiren'))
or (t.slug='nihonji-nokogiriyama' and d.slug in ('yakushi_nyorai'))
or (t.slug='oji-jinja' and d.slug in ('izanagi','izanami','amaterasu','hayatama','kotosaka_no_o'))
or (t.slug='homyoji-kishimojin' and d.slug in ('kishimojin'))
or (t.slug='otori-jinja-meguro' and d.slug in ('yamatotakeru','kunitokotachi','ototachibanahime'))
on conflict do nothing;

-- ===== バッチ9: 神奈川・東京 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ame_no_uzume','天鈿女命','あめのうずめのみこと','kami','天津神','{天宇受売命}','記紀','天岩戸で舞った芸能の祖神。猿田彦の妻。','https://ja.wikipedia.org/wiki/アメノウズメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ame_no_uzume' and g.slug in ('geino','enmusubi','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iseyama-kotai-jingu','伊勢山皇大神宮','いせやまこうたいじんぐう','shrine','旧県社','神奈川県','横浜市','神奈川県横浜市西区宮崎町64番地',35.450280,139.626110,1870,null,'https://www.iseyama.jp/','「関東のお伊勢さま」と称される横浜総鎮守。','https://ja.wikipedia.org/wiki/伊勢山皇大神宮','Wikipedia',true,now()),
('karasumori-jinja','烏森神社','からすもりじんじゃ','shrine','旧村社','東京都','港区','東京都港区新橋二丁目15番5号',35.666781,139.756794,940,null,'http://karasumorijinja.or.jp/','新橋の鎮守。色鮮やかな心願成就のお守りと御朱印で人気。','https://ja.wikipedia.org/wiki/烏森神社','Wikipedia',true,now()),
('asagaya-shinmeigu','阿佐ヶ谷神明宮','あさがやしんめいぐう','shrine','旧村社','東京都','杉並区','東京都杉並区阿佐谷北1-25-5',35.707339,139.637000,1190,null,'http://www.shinmeiguu.com/','伊勢の神を祀る杉並の大社。八難除けと美しい授与品で知られる。','https://ja.wikipedia.org/wiki/阿佐ヶ谷神明宮','Wikipedia',true,now()),
('inage-jinja','稲毛神社','いなげじんじゃ','shrine','旧県社','神奈川県','川崎市','神奈川県川崎市川崎区宮本町7-7',35.530830,139.704440,null,null,'https://www.takemikatsuchi.net','川崎の総鎮守。武甕槌神を祀る厄除けの古社。','https://ja.wikipedia.org/wiki/稲毛神社','Wikipedia',true,now()),
('izumo-sagami-bunshi','出雲大社相模分祠','いずもおおやしろさがみぶんし','shrine','出雲大社教','神奈川県','秦野市','神奈川県秦野市平沢1221',35.370560,139.209440,1888,null,'https://www.izumosan.com/','「関東のいづも」と称される縁結びの社。','https://ja.wikipedia.org/wiki/出雲大社相模分祠','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iseyama-kotai-jingu' and d.slug in ('amaterasu'))
or (t.slug='karasumori-jinja' and d.slug in ('ukanomitama','ame_no_uzume','ninigi'))
or (t.slug='asagaya-shinmeigu' and d.slug in ('amaterasu'))
or (t.slug='inage-jinja' and d.slug in ('takemikazuchi'))
or (t.slug='izumo-sagami-bunshi' and d.slug in ('okuninushi'))
on conflict do nothing;

-- ===== バッチ10: 茨城・千葉・栃木 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('fujiwara_hidesato','藤原秀郷','ふじわらのひでさと','kami','御霊','{俵藤太}','歴史','平将門を討った平安中期の武将。武勇の神として祀られる。','https://ja.wikipedia.org/wiki/藤原秀郷','Wikipedia',true,now()),
('ame_no_hiwashi','天日鷲命','あめのひわしのみこと','kami','天津神','{}','記紀','阿波忌部の祖神。紡績・開運の神。鷲子山上神社の主神。','https://ja.wikipedia.org/wiki/鷲子山上神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='fujiwara_hidesato' and g.slug in ('shobu','yakubarai','shusse'))
or (d.slug='ame_no_hiwashi' and g.slug in ('kaiun','shobai','shigoto'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oosugi-jinja','大杉神社','おおすぎじんじゃ','shrine','旧郷社','茨城県','稲敷市','茨城県稲敷市阿波958番地',35.952247,140.382722,767,null,'https://www.oosugi-jinja.or.jp/','「あんばさま」と親しまれる日本唯一の夢むすび大明神。','https://ja.wikipedia.org/wiki/大杉神社','Wikipedia',true,now()),
('awa-jinja-tateyama','安房神社','あわじんじゃ','shrine','旧官幣大社','千葉県','館山市','千葉県館山市大神宮589',34.922444,139.836736,-660,null,'http://www.awajinjya.org/','安房国一宮。忌部氏の祖神を祀る古社。','https://ja.wikipedia.org/wiki/安房神社','Wikipedia',true,now()),
('karasawayama-jinja','唐沢山神社','からさわやまじんじゃ','shrine','旧別格官幣社','栃木県','佐野市','栃木県佐野市富士町1409',36.353781,139.600847,1883,null,'http://www.karasawayama.com','藤原秀郷を祀る山城跡の社。猫の神社としても親しまれる。','https://ja.wikipedia.org/wiki/唐沢山神社','Wikipedia',true,now()),
('shizu-jinja','静神社','しずじんじゃ','shrine','旧県社','茨城県','那珂市','茨城県那珂市静2',36.501670,140.422220,806,null,'https://shizu.e-naka.jp/index.html','常陸国二宮。織物の祖神を祀る。','https://ja.wikipedia.org/wiki/静神社','Wikipedia',true,now()),
('torinokosan-jinja','鷲子山上神社','とりのこさんしょうじんじゃ','shrine','旧郷社','栃木県','那須郡那珂川町','栃木県那須郡那珂川町矢又1948',36.699720,140.235056,807,null,'http://www.torinokosan.com/','栃木・茨城の県境に鎮座。日本一の大フクロウで知られる開運の社。','https://ja.wikipedia.org/wiki/鷲子山上神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oosugi-jinja' and d.slug in ('omononushi'))
or (t.slug='awa-jinja-tateyama' and d.slug in ('amenofutodama'))
or (t.slug='karasawayama-jinja' and d.slug in ('fujiwara_hidesato'))
or (t.slug='shizu-jinja' and d.slug in ('shitori_takehazuchi'))
or (t.slug='torinokosan-jinja' and d.slug in ('ame_no_hiwashi','okuninushi','sukunabikona'))
on conflict do nothing;

-- ===== バッチ11: 東京・茨城・神奈川 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('fukurokuju','福禄寿','ふくろくじゅ','buddha','天部','{福禄寿}','道教・七福神','幸福・封禄・長寿を授ける七福神の一神。','https://ja.wikipedia.org/wiki/福禄寿','Wikipedia',true,now()),
('nintoku_tenno','仁徳天皇','にんとくてんのう','kami','御霊','{大鷦鷯尊}','記紀','第16代天皇。仁政で知られ「聖帝」と称される。','https://ja.wikipedia.org/wiki/仁徳天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='fukurokuju' and g.slug in ('choju','kaiun','kinun'))
or (d.slug='nintoku_tenno' and g.slug in ('kaiun','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('koami-jinja','小網神社','こあみじんじゃ','shrine','旧村社','東京都','中央区','東京都中央区日本橋小網町16-23',35.684167,139.780472,1466,null,'https://koamijinja.or.jp/','日本橋の強運厄除の社。東京銭洗い弁天と福禄寿で名高い。','https://ja.wikipedia.org/wiki/小網神社','Wikipedia',true,now()),
('matsuchiyama-shoden','待乳山聖天','まつちやましょうでん','temple','聖観音宗','東京都','台東区','東京都台東区浅草7-4-1',35.717361,139.802972,595,'歓喜天・十一面観音','http://www.matsuchiyama.jp/','浅草寺の支院。大根と巾着の聖天信仰で知られる。','https://ja.wikipedia.org/wiki/待乳山聖天','Wikipedia',true,now()),
('tsukubasan-omido','筑波山大御堂','つくばさんおおみどう','temple','真言宗豊山派','茨城県','つくば市','茨城県つくば市筑波748番地2',36.212639,140.099417,782,'十一面千手観世音菩薩','https://tsukubasan-omido.jp','坂東三十三観音第25番。筑波山中腹の古刹。','https://ja.wikipedia.org/wiki/筑波山大御堂','Wikipedia',true,now()),
('wakamiya-hachiman-kawasaki','若宮八幡宮（川崎）','わかみやはちまんぐう','shrine','旧郷社','神奈川県','川崎市','神奈川県川崎市川崎区大師駅前2丁目13-16',35.534661,139.724664,1559,null,null,'大師河原の鎮守。境内のかなまら様(金山神社)の祭で世界的に知られる。','https://ja.wikipedia.org/wiki/若宮八幡宮_(川崎市)','Wikipedia',true,now()),
('hebikubo-jinja','蛇窪神社','へびくぼじんじゃ','shrine','旧村社','東京都','品川区','東京都品川区二葉4-4-12',35.602583,139.715194,1322,null,'https://hebikubo.jp/','「上神明天祖神社」。白蛇を祀る財運・金運の社として人気。','https://ja.wikipedia.org/wiki/蛇窪神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='koami-jinja' and d.slug in ('ukanomitama','ichikishima','fukurokuju'))
or (t.slug='matsuchiyama-shoden' and d.slug in ('kangiten','juichimen_kannon'))
or (t.slug='tsukubasan-omido' and d.slug in ('senju_kannon'))
or (t.slug='wakamiya-hachiman-kawasaki' and d.slug in ('nintoku_tenno'))
or (t.slug='hebikubo-jinja' and d.slug in ('amaterasu','amenokoyane','hachiman'))
on conflict do nothing;
