-- 関東 観光著名社寺 追加分 (kanto-4)
-- 担当: 茨城・栃木・群馬・埼玉・千葉・東京・神奈川
-- 全件 ja.wikipedia.org infobox の十進座標で裏取り済み。_have_kanto.txt と重複なし。

-- ===== バッチ1: 茨城・栃木 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tokugawa_mitsukuni','徳川光圀','とくがわみつくに','kami','御霊','{水戸黄門,義公}','歴史','水戸藩第2代藩主。「水戸黄門」として知られ常磐神社に祀られる。','https://ja.wikipedia.org/wiki/徳川光圀','Wikipedia',true,now()),
('tokugawa_nariaki','徳川斉昭','とくがわなりあき','kami','御霊','{烈公}','歴史','水戸藩第9代藩主。偕楽園を造営し常磐神社に祀られる。','https://ja.wikipedia.org/wiki/徳川斉昭','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tokugawa_mitsukuni' and g.slug in ('gakumon','kaiun','shusse'))
or (d.slug='tokugawa_nariaki' and g.slug in ('gakumon','shobu','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('muramatsusan-kokuzodo','村松山虚空蔵堂','むらまつさんこくぞうどう','temple','真言宗豊山派','茨城県','那珂郡東海村','茨城県那珂郡東海村村松8',36.4497111,140.5988500,807,'虚空蔵菩薩','http://www.taraku.or.jp/','日本三大虚空蔵堂の一。正式には村松山日高寺。十三詣りで知られる。','https://ja.wikipedia.org/wiki/村松山虚空蔵堂','Wikipedia',true,now()),
('hitokotonushi-jinja-joso','一言主神社','ひとことぬしじんじゃ','shrine','旧村社','茨城県','常総市','茨城県常総市大塚戸町875',36.0122250,139.9271472,809,null,'https://hitokoto.or.jp/','一言の願いを叶える神として信仰される常総の古社。','https://ja.wikipedia.org/wiki/一言主神社_(常総市)','Wikipedia',true,now()),
('tokiwa-jinja','常磐神社','ときわじんじゃ','shrine','旧別格官幣社','茨城県','水戸市','茨城県水戸市常磐町1-3-1',36.375000,140.455667,1873,null,'http://komonsan.jp/','偕楽園に隣接し、徳川光圀・斉昭を祀る。','https://ja.wikipedia.org/wiki/常磐神社','Wikipedia',true,now()),
('saimyoji-mashiko','西明寺','さいみょうじ','temple','真言宗豊山派','栃木県','芳賀郡益子町','栃木県芳賀郡益子町益子4469',36.452780,140.117361,737,'十一面観世音菩薩','http://fumon.jp/','坂東三十三観音第20番札所。三重塔・楼門は重文。','https://ja.wikipedia.org/wiki/西明寺_(栃木県益子町)','Wikipedia',true,now()),
('nasu-yuzen-jinja','那須温泉神社','なすゆぜんじんじゃ','shrine','旧県社','栃木県','那須郡那須町','栃木県那須郡那須町大字湯本182',37.100000,139.999194,640,null,'http://nasu-yuzen.jp/','那須温泉の守護社。那須与一ゆかり、紅葉の名所。','https://ja.wikipedia.org/wiki/那須温泉神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='muramatsusan-kokuzodo' and d.slug in ('kokuzo_bosatsu'))
or (t.slug='hitokotonushi-jinja-joso' and d.slug in ('hitokotonushi','kotoshironushi'))
or (t.slug='tokiwa-jinja' and d.slug in ('tokugawa_mitsukuni','tokugawa_nariaki'))
or (t.slug='saimyoji-mashiko' and d.slug in ('juichimen_kannon'))
or (t.slug='nasu-yuzen-jinja' and d.slug in ('okuninushi','sukunabikona','hachiman'))
on conflict do nothing;

-- ===== バッチ2: 群馬・埼玉・千葉 =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('morinji','茂林寺','もりんじ','temple','曹洞宗','群馬県','館林市','群馬県館林市堀工町1570',36.224417,139.531111,1426,'釈迦如来','https://morinji.com/','「分福茶釜」伝説の寺。境内に並ぶ狸像で知られる。','https://ja.wikipedia.org/wiki/茂林寺','Wikipedia',true,now()),
('santai-jinja','産泰神社','さんたいじんじゃ','shrine','旧郷社','群馬県','前橋市','群馬県前橋市下大屋町569',36.390000,139.178330,400,null,'http://www.santai-jinja.jp/','安産・子育ての守護神。木花佐久夜毘売命を祀る。','https://ja.wikipedia.org/wiki/産泰神社','Wikipedia',true,now()),
('jionji-iwatsuki','慈恩寺','じおんじ','temple','天台宗','埼玉県','さいたま市','埼玉県さいたま市岩槻区慈恩寺139',35.979440,139.710778,824,'千手観世音菩薩','http://www.jionji.com/','坂東三十三観音第12番札所。玄奘三蔵の霊骨を祀る玄奘塔で知られる。','https://ja.wikipedia.org/wiki/慈恩寺_(さいたま市)','Wikipedia',true,now()),
('hisaizu-jinja-koshigaya','久伊豆神社','ひさいずじんじゃ','shrine','旧郷社','埼玉県','越谷市','埼玉県越谷市越ヶ谷1700',35.901778,139.790500,1000,null,'https://www.hisaizujinja.jp/','越谷総鎮守。樹齢250年の大藤(天然記念物)で有名。','https://ja.wikipedia.org/wiki/久伊豆神社_(越谷市)','Wikipedia',true,now()),
('tamashiki-jinja','玉敷神社','たましきじんじゃ','shrine','旧県社','埼玉県','加須市','埼玉県加須市騎西552',36.107361,139.569667,703,null,null,'武蔵国埼玉郡の総鎮守。玉敷神社神楽は国指定重要無形民俗文化財。','https://ja.wikipedia.org/wiki/玉敷神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='morinji' and d.slug in ('shaka_nyorai'))
or (t.slug='santai-jinja' and d.slug in ('konohanasakuya'))
or (t.slug='jionji-iwatsuki' and d.slug in ('senju_kannon'))
or (t.slug='hisaizu-jinja-koshigaya' and d.slug in ('okuninushi'))
or (t.slug='tamashiki-jinja' and d.slug in ('okuninushi'))
on conflict do nothing;

-- ===== バッチ3: 千葉・東京・神奈川 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sadatatsu_shinno','貞辰親王','さだたつしんのう','kami','御霊','{}','歴史','平安時代の皇族。牛嶋神社に配祀される。','https://ja.wikipedia.org/wiki/牛嶋神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sadatatsu_shinno' and g.slug in ('yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nakayama-hokekyoji','法華経寺','ほけきょうじ','temple','日蓮宗','千葉県','市川市','千葉県市川市中山二丁目10番1号',35.720861,139.949361,1260,'十界曼荼羅','https://hokekyoji2101.wixsite.com/nakayama','日蓮宗大本山。日蓮真筆の国宝を所蔵。五重塔・法華堂は重文。','https://ja.wikipedia.org/wiki/法華経寺','Wikipedia',true,now()),
('enpukuji-choshi','円福寺','えんぷくじ','temple','真言宗単立','千葉県','銚子市','千葉県銚子市馬場町293',35.731940,140.840611,810,'十一面観世音菩薩','http://iinumakannon.com/','飯沼観音の通称で知られる坂東三十三観音第27番札所。','https://ja.wikipedia.org/wiki/円福寺_(銚子市)','Wikipedia',true,now()),
('imado-jinja','今戸神社','いまどじんじゃ','shrine','旧村社','東京都','台東区','東京都台東区今戸1丁目5-22',35.7193056,139.8035278,1063,null,'https://imadojinja1063.crayonsite.net/','招き猫発祥の地とされ、縁結びの社として人気。','https://ja.wikipedia.org/wiki/今戸神社','Wikipedia',true,now()),
('ushijima-jinja','牛嶋神社','うしじまじんじゃ','shrine','旧郷社','東京都','墨田区','東京都墨田区向島1-4-5',35.712972,139.804720,860,null,null,'本所総鎮守。撫牛と東京スカイツリーの守護で知られる。','https://ja.wikipedia.org/wiki/牛嶋神社','Wikipedia',true,now()),
('ryukoji','龍口寺','りゅうこうじ','temple','日蓮宗','神奈川県','藤沢市','神奈川県藤沢市片瀬三丁目13番37号',35.3117139,139.4893583,1337,'三宝尊','https://ryuukoji.com/','日蓮の龍ノ口法難の地に建つ霊跡本山。五重塔を有する。','https://ja.wikipedia.org/wiki/龍口寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='enpukuji-choshi' and d.slug in ('juichimen_kannon'))
or (t.slug='imado-jinja' and d.slug in ('hachiman','izanagi','izanami','fukurokuju'))
or (t.slug='ushijima-jinja' and d.slug in ('susanoo','amenohohi','sadatatsu_shinno'))
on conflict do nothing;

-- ===== バッチ4: 千葉・神奈川 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('toyokumununu','豊斟渟尊','とよくむぬのみこと','kami','天津神','{豊斟渟神}','記紀','神世七代の一柱。比々多神社の主祭神。','https://ja.wikipedia.org/wiki/比々多神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='toyokumununu' and g.slug in ('kaiun','anzan','kosodate'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chibadera','千葉寺','ちばでら','temple','真言宗豊山派','千葉県','千葉市','千葉県千葉市中央区千葉寺町161',35.595139,140.131694,709,'十一面観世音菩薩','http://www.bandou.gr.jp/','坂東三十三観音第29番札所。千葉氏ゆかりの古刹。','https://ja.wikipedia.org/wiki/千葉寺','Wikipedia',true,now()),
('kazusa-kokubunji','上総国分寺','かずさこくぶんじ','temple','真言宗豊山派','千葉県','市原市','千葉県市原市惣社1丁目7-23',35.4969222,140.1111389,741,'薬師如来','http://www.kazusakokubunji.jp/','聖武天皇の詔で建立された上総国分寺の法燈を継ぐ。国史跡。','https://ja.wikipedia.org/wiki/上総国分寺','Wikipedia',true,now()),
('jochiji','浄智寺','じょうちじ','temple','臨済宗円覚寺派','神奈川県','鎌倉市','神奈川県鎌倉市山ノ内1402',35.333389,139.546390,1283,'三世仏','https://jochiji.com/','鎌倉五山第四位の禅刹。鎌倉七福神の布袋尊で知られる。','https://ja.wikipedia.org/wiki/浄智寺','Wikipedia',true,now()),
('kakuonji','覚園寺','かくおんじ','temple','真言宗泉涌寺派','神奈川県','鎌倉市','神奈川県鎌倉市二階堂421',35.331940,139.563750,1296,'薬師三尊','https://kamakura894do.com/','北条義時開基の大倉薬師堂に始まる古刹。十二神将像は重文。','https://ja.wikipedia.org/wiki/覚園寺','Wikipedia',true,now()),
('hibita-jinja','比々多神社','ひびたじんじゃ','shrine','旧郷社','神奈川県','伊勢原市','神奈川県伊勢原市三ノ宮1472',35.401306,139.283944,-655,null,'http://hibita.jp/','相模国三宮。相模国最古級の古社で安産・縁結びの信仰を集める。','https://ja.wikipedia.org/wiki/比々多神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chibadera' and d.slug in ('juichimen_kannon'))
or (t.slug='kazusa-kokubunji' and d.slug in ('yakushi_nyorai'))
or (t.slug='jochiji' and d.slug in ('amida_nyorai','shaka_nyorai','miroku_bosatsu'))
or (t.slug='kakuonji' and d.slug in ('yakushi_nyorai'))
or (t.slug='hibita-jinja' and d.slug in ('toyokumununu','yamatotakeru'))
on conflict do nothing;

-- ===== バッチ5: 神奈川・栃木 =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shomyoji-kanazawa','称名寺','しょうみょうじ','temple','真言律宗','神奈川県','横浜市','神奈川県横浜市金沢区金沢町212-1',35.3441806,139.6303917,1258,'弥勒菩薩','https://www.city.yokohama.lg.jp/','金沢北条氏の菩提寺。浄土式庭園は国史跡、金沢文庫に隣接。','https://ja.wikipedia.org/wiki/称名寺_(横浜市)','Wikipedia',true,now()),
('izurusan-manganji','出流山満願寺','いずるさんまんがんじ','temple','真言宗智山派','栃木県','栃木市','栃木県栃木市出流町288',36.475528,139.589250,765,'千手観世音菩薩','http://www.idurusan.com/','坂東三十三観音第17番札所。奥之院の鍾乳洞磨崖仏で知られる。','https://ja.wikipedia.org/wiki/満願寺_(栃木市)','Wikipedia',true,now()),
('utsunomiya-futarasan-jinja','宇都宮二荒山神社','うつのみやふたらやまじんじゃ','shrine','旧国幣中社','栃木県','宇都宮市','栃木県宇都宮市馬場通り1丁目1-1',36.562694,139.885694,838,null,null,'下野国一宮。宇都宮の街の中心に鎮座する豊城入彦命を祀る古社。','https://ja.wikipedia.org/wiki/宇都宮二荒山神社','Wikipedia',true,now()),
('osaki-jinja','大前神社','おおさきじんじゃ','shrine','旧県社','栃木県','真岡市','栃木県真岡市東郷937',36.449194,140.025889,767,null,'https://oosakijinja.com/','延喜式内社。日本一の恵比寿大黒像とバイク神社で知られる。','https://ja.wikipedia.org/wiki/大前神社','Wikipedia',true,now()),
('omiwa-jinja-tochigi','大神神社','おおみわじんじゃ','shrine','旧県社','栃木県','栃木市','栃木県栃木市惣社町477',36.4059194,139.7821611,90,null,null,'下野国総社。歌枕「室の八嶋」で知られる古社。','https://ja.wikipedia.org/wiki/大神神社_(栃木市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shomyoji-kanazawa' and d.slug in ('miroku_bosatsu'))
or (t.slug='izurusan-manganji' and d.slug in ('senju_kannon'))
or (t.slug='utsunomiya-futarasan-jinja' and d.slug in ('toyokiirihiko'))
or (t.slug='osaki-jinja' and d.slug in ('okuninushi','kotoshironushi'))
or (t.slug='omiwa-jinja-tochigi' and d.slug in ('omononushi'))
on conflict do nothing;

-- ===== バッチ6: 群馬・埼玉 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('wakeikazuchi','別雷命','わけいかづちのみこと','kami','天津神','{賀茂別雷}','記紀','雷を司る神。賀茂別雷神社の祭神で各地の雷電・賀茂社に祀られる。','https://ja.wikipedia.org/wiki/賀茂別雷神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='wakeikazuchi' and g.slug in ('yakubarai','mizu_amagoi','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('isesaki-jinja','伊勢崎神社','いせさきじんじゃ','shrine','旧県社','群馬県','伊勢崎市','群馬県伊勢崎市本町21-1',36.319720,139.193330,1213,null,null,'伊勢崎の総鎮守。豊受姫命ほか多くの神を祀る。','https://ja.wikipedia.org/wiki/伊勢崎神社','Wikipedia',true,now()),
('sorinji-shibukawa','雙林寺','そうりんじ','temple','曹洞宗','群馬県','渋川市','群馬県渋川市中郷2399',36.537889,139.008639,1447,'釈迦如来','https://www.kabasan.or.jp/','上州の名刹で曹洞宗の修行道場。県重文の伽藍を有する。','https://ja.wikipedia.org/wiki/雙林寺_(渋川市)','Wikipedia',true,now()),
('ko-jinja','鴻神社','こうじんじゃ','shrine','旧村社','埼玉県','鴻巣市','埼玉県鴻巣市本宮町1-9',36.063060,139.510830,1873,null,'https://koujinja.or.jp/','鴻巣総鎮守。コウノトリ伝説にちなみ安産・子授けの信仰を集める。','https://ja.wikipedia.org/wiki/鴻神社','Wikipedia',true,now()),
('yakyu-inari-jinja','箭弓稲荷神社','やきゅういなりじんじゃ','shrine','旧県社','埼玉県','東松山市','埼玉県東松山市箭弓町2-5-14',36.034440,139.398610,712,null,'http://www.yakyu-inari.jp/','「やきゅう」の名から野球関係者の参拝で有名。牡丹園で知られる。','https://ja.wikipedia.org/wiki/箭弓稲荷神社','Wikipedia',true,now()),
('shodenin-hidaka','聖天院','しょうでんいん','temple','真言宗智山派','埼玉県','日高市','埼玉県日高市新堀990-1',35.896000,139.320280,751,'不動明王','http://shoudenin.jp/','高麗王若光ゆかりの古刹。高麗神社に隣接し銅鐘は重文。','https://ja.wikipedia.org/wiki/聖天院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='isesaki-jinja' and d.slug in ('toyouke'))
or (t.slug='sorinji-shibukawa' and d.slug in ('shaka_nyorai'))
or (t.slug='ko-jinja' and d.slug in ('susanoo','hayatama','wakeikazuchi'))
or (t.slug='yakyu-inari-jinja' and d.slug in ('ukanomitama'))
or (t.slug='shodenin-hidaka' and d.slug in ('fudo_myoo'))
on conflict do nothing;

-- ===== バッチ7: 埼玉・東京・千葉 =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shimabuji','四萬部寺','しまぶじ','temple','曹洞宗','埼玉県','秩父市','埼玉県秩父市栃谷418',36.027278,139.120694,1007,'聖観世音菩薩','https://www.shimabuji.com','秩父三十四観音霊場第1番札所。県重文の本堂で知られる。','https://ja.wikipedia.org/wiki/四萬部寺','Wikipedia',true,now()),
('mimeguri-jinja','三囲神社','みめぐりじんじゃ','shrine','旧村社','東京都','墨田区','東京都墨田区向島2-5-17',35.715000,139.806778,1100,null,null,'三井家の守護社。三柱鳥居やライオン像で知られる向島の稲荷社。','https://ja.wikipedia.org/wiki/三囲神社','Wikipedia',true,now()),
('kameari-katori-jinja','亀有香取神社','かめありかとりじんじゃ','shrine','旧村社','東京都','葛飾区','東京都葛飾区亀有3-42-24',35.765778,139.851194,1276,null,'https://www.kameari-katori.or.jp/','亀有の鎮守。スポーツ振興・足腰の守護で知られる。','https://ja.wikipedia.org/wiki/亀有香取神社','Wikipedia',true,now()),
('todoroki-fudoson','等々力不動尊','とどろきふどうそん','temple','真言宗智山派','東京都','世田谷区','東京都世田谷区等々力1-22-47',35.603667,139.646861,1200,'不動明王','http://www.manganji.or.jp/','等々力渓谷に臨む不動尊。関東三十六不動第17番札所。','https://ja.wikipedia.org/wiki/満願寺_(世田谷区)','Wikipedia',true,now()),
('katsushika-hachimangu','葛飾八幡宮','かつしかはちまんぐう','shrine','旧県社','千葉県','市川市','千葉県市川市八幡四丁目2番1号',35.7241083,139.9307972,890,null,'http://katsushikahachimangu.com','下総国総鎮守。国天然記念物の千本公孫樹で有名。','https://ja.wikipedia.org/wiki/葛飾八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shimabuji' and d.slug in ('sho_kannon'))
or (t.slug='mimeguri-jinja' and d.slug in ('ukanomitama'))
or (t.slug='kameari-katori-jinja' and d.slug in ('futsunushi'))
or (t.slug='todoroki-fudoson' and d.slug in ('fudo_myoo'))
or (t.slug='katsushika-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
on conflict do nothing;

-- ===== バッチ8: 神奈川・千葉 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('fujiwara_sukemitsu','藤原資盈','ふじわらのすけみつ','kami','御霊','{}','歴史','平安期の貴族。三浦半島に漂着し海南神社の主祭神として祀られる。','https://ja.wikipedia.org/wiki/海南神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='fujiwara_sukemitsu' and g.slug in ('kaijo_anzen','suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('eishoji','英勝寺','えいしょうじ','temple','浄土宗','神奈川県','鎌倉市','神奈川県鎌倉市扇ガ谷1-16-3',35.325139,139.549861,1636,'阿弥陀三尊','https://www.eshouji.com/','鎌倉唯一の尼寺。徳川家ゆかりで山門・仏殿など5棟が重文。','https://ja.wikipedia.org/wiki/英勝寺','Wikipedia',true,now()),
('zuisenji','瑞泉寺','ずいせんじ','temple','臨済宗円覚寺派','神奈川県','鎌倉市','神奈川県鎌倉市二階堂710',35.3270556,139.5753722,1327,'釈迦如来','https://www.kamakura-zuisenji.or.jp','夢窓疎石作庭の名園で知られる「花の寺」。鎌倉公方の菩提寺。','https://ja.wikipedia.org/wiki/瑞泉寺_(鎌倉市)','Wikipedia',true,now()),
('kainan-jinja','海南神社','かいなんじんじゃ','shrine','旧郷社','神奈川県','三浦市','神奈川県三浦市三崎4-12-11',35.14275722,139.6188444,982,null,'http://kainan.server-shared.com/','三浦半島の総鎮守。ユネスコ無形文化遺産チャッキラコで知られる。','https://ja.wikipedia.org/wiki/海南神社','Wikipedia',true,now()),
('tsurumine-hachimangu-ichihara','鶴峯八幡宮','つるみねはちまんぐう','shrine','旧村社','千葉県','市原市','千葉県市原市中高根1223',35.438917,140.104972,1277,null,'http://r.goope.jp/tsurumine','上総の八幡宮。県無形民俗文化財の十二座神楽で知られる。','https://ja.wikipedia.org/wiki/鶴峯八幡宮_(市原市)','Wikipedia',true,now()),
('tachibana-jinja-mobara','橘樹神社','たちばなじんじゃ','shrine','旧県社','千葉県','茂原市','千葉県茂原市本納738',35.489417,140.305750,110,null,null,'上総国二宮。弟橘媛を祀る延喜式内社で御陵と伝わる古墳を有する。','https://ja.wikipedia.org/wiki/橘樹神社_(茂原市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='eishoji' and d.slug in ('amida_nyorai'))
or (t.slug='zuisenji' and d.slug in ('shaka_nyorai'))
or (t.slug='kainan-jinja' and d.slug in ('fujiwara_sukemitsu'))
or (t.slug='tsurumine-hachimangu-ichihara' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
or (t.slug='tachibana-jinja-mobara' and d.slug in ('ototachibanahime'))
on conflict do nothing;

-- ===== バッチ9: 茨城・東京 =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('gassanji','月山寺','がっさんじ','temple','天台宗','茨城県','桜川市','茨城県桜川市西小塙1677',36.364720,140.146306,796,'薬師如来','http://www.gassanji.com/','関東天台の檀林(学問所)の一。常陸七福神の布袋尊を祀る。','https://ja.wikipedia.org/wiki/月山寺','Wikipedia',true,now()),
('hitachi-kokubunji','常陸国分寺','ひたちこくぶんじ','temple','真言宗智山派','茨城県','石岡市','茨城県石岡市府中5-1-5',36.1962056,140.2733583,752,'薬師如来','http://www.hitachikokubunji.com/','聖武天皇の詔で建立された常陸国分寺の法燈を継ぐ。境内は国特別史跡。','https://ja.wikipedia.org/wiki/常陸国分寺','Wikipedia',true,now()),
('ushiku-daibutsu','牛久大仏','うしくだいぶつ','temple','浄土真宗東本願寺派','茨城県','牛久市','茨城県牛久市久野町2083',35.979170,140.217500,1993,'阿弥陀如来','https://daibutu.net/','高さ120mの世界最大級のブロンズ立像。東本願寺の本廟。','https://ja.wikipedia.org/wiki/牛久大仏','Wikipedia',true,now()),
('irugi-jinja','居木神社','いるぎじんじゃ','shrine','旧村社','東京都','品川区','東京都品川区大崎3-8-20',35.619861,139.725111,1600,null,'http://irugijinjya.jp/','大崎の鎮守。日本武尊を主祭神とし多くの神を合祀する。','https://ja.wikipedia.org/wiki/居木神社','Wikipedia',true,now()),
('iwai-jinja','磐井神社','いわいじんじゃ','shrine','旧郷社','東京都','大田区','東京都大田区大森北2-20-8',35.585167,139.735500,580,null,'https://iwaijinja.tokyo/','延喜式内社で武蔵国の八幡総社と伝わる。鈴ヶ森の鎮守。','https://ja.wikipedia.org/wiki/磐井神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='gassanji' and d.slug in ('yakushi_nyorai'))
or (t.slug='hitachi-kokubunji' and d.slug in ('yakushi_nyorai'))
or (t.slug='ushiku-daibutsu' and d.slug in ('amida_nyorai'))
or (t.slug='irugi-jinja' and d.slug in ('yamatotakeru'))
or (t.slug='iwai-jinja' and d.slug in ('hachiman','chuai','jingu_kogo','okuninushi'))
on conflict do nothing;

-- ===== バッチ10: 東京の著名社寺 =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('gokokuji','護国寺','ごこくじ','temple','真言宗豊山派','東京都','文京区','東京都文京区大塚五丁目40番1号',35.721750,139.725639,1681,'如意輪観世音菩薩','http://www.gokokuji.or.jp/','徳川綱吉の母桂昌院ゆかりの大本山。観音堂は重文。','https://ja.wikipedia.org/wiki/護国寺','Wikipedia',true,now()),
('daienji-meguro','大円寺','だいえんじ','temple','天台宗','東京都','目黒区','東京都目黒区下目黒一丁目8番5号',35.632861,139.713750,1624,'釈迦如来','https://meguro-daienji.com/','行人坂の大火供養の石仏群(都有形文化財)で知られる。','https://ja.wikipedia.org/wiki/大円寺_(目黒区)','Wikipedia',true,now()),
('meguro-fudoson-ryusenji','目黒不動尊瀧泉寺','めぐろふどうそんりゅうせんじ','temple','天台宗','東京都','目黒区','東京都目黒区下目黒3-20-26',35.628610,139.708060,808,'不動明王','https://megurofudo.jp','江戸五色不動の一。関東最古の不動霊場とされる。','https://ja.wikipedia.org/wiki/目黒不動','Wikipedia',true,now()),
('atago-jinja-tokyo','愛宕神社','あたごじんじゃ','shrine','旧村社','東京都','港区','東京都港区愛宕一丁目5番3号',35.664778,139.748444,1603,null,'https://www.atago-jinja.com/','23区最高峰の愛宕山に鎮座。「出世の石段」で有名な防火の社。','https://ja.wikipedia.org/wiki/愛宕神社_(東京都港区)','Wikipedia',true,now()),
('kameido-katori-jinja','亀戸香取神社','かめいどかとりじんじゃ','shrine','旧村社','東京都','江東区','東京都江東区亀戸3-57-22',35.704361,139.825472,665,null,'https://www.kameido-katori.com/','スポーツ振興・勝運の神として信仰される亀戸の鎮守。','https://ja.wikipedia.org/wiki/亀戸香取神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='gokokuji' and d.slug in ('nyoirin_kannon'))
or (t.slug='daienji-meguro' and d.slug in ('shaka_nyorai'))
or (t.slug='meguro-fudoson-ryusenji' and d.slug in ('fudo_myoo'))
or (t.slug='atago-jinja-tokyo' and d.slug in ('kagutsuchi'))
or (t.slug='kameido-katori-jinja' and d.slug in ('futsunushi'))
on conflict do nothing;

-- ===== バッチ11: 神奈川・群馬 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('minamoto_no_yoshitsune','源義経','みなもとのよしつね','kami','御霊','{牛若丸,九郎判官}','歴史','平安末期の武将。白旗神社などに祀られる悲劇の英雄。','https://ja.wikipedia.org/wiki/源義経','Wikipedia',true,now()),
('hino_toshimoto','日野俊基','ひのとしもと','kami','御霊','{}','歴史','鎌倉末期の公卿。倒幕計画で処刑され葛原岡神社に祀られる。','https://ja.wikipedia.org/wiki/日野俊基','Wikipedia',true,now()),
('ujinowakiiratsuko','菟道稚郎子命','うじのわきいらつこのみこと','kami','天津神','{}','記紀','応神天皇の皇子。学問に秀で学業の神として前鳥神社に祀られる。','https://ja.wikipedia.org/wiki/菟道稚郎子','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='minamoto_no_yoshitsune' and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='hino_toshimoto' and g.slug in ('gakumon','shobu','yakubarai'))
or (d.slug='ujinowakiiratsuko' and g.slug in ('gakumon','gakugyo','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shirahata-jinja-fujisawa','白旗神社','しらはたじんじゃ','shrine','旧村社','神奈川県','藤沢市','神奈川県藤沢市藤沢二丁目4番7号',35.350528,139.478667,1186,null,'http://shirahata-jinja.jp/','源義経を祀る。義経首塚伝説で知られる藤沢の古社。','https://ja.wikipedia.org/wiki/白旗神社_(藤沢市)','Wikipedia',true,now()),
('kuzuharaoka-jinja','葛原岡神社','くずはらおかじんじゃ','shrine','旧村社','神奈川県','鎌倉市','神奈川県鎌倉市梶原5-9-1',35.329170,139.542500,1888,null,'http://www.kuzuharaoka.jp/','日野俊基を祀る。縁結びの神として人気のハイキング途上の社。','https://ja.wikipedia.org/wiki/葛原岡神社','Wikipedia',true,now()),
('hoshinoyadera','星谷寺','しょうこくじ','temple','真言宗大覚寺派','神奈川県','座間市','神奈川県座間市入谷西三丁目12-22',35.484889,139.398890,724,'聖観世音菩薩','http://www.bandou.gr.jp/','坂東三十三観音第8番札所。行基開創と伝わる座間の古刹。','https://ja.wikipedia.org/wiki/星谷寺','Wikipedia',true,now()),
('sakitori-jinja','前鳥神社','さきとりじんじゃ','shrine','旧県社','神奈川県','平塚市','神奈川県平塚市四之宮4丁目14-26',35.3569889,139.3646861,368,null,'http://www.sakitori.jp/','相模国四宮。菟道稚郎子命を祀り学問・就職の神で知られる。','https://ja.wikipedia.org/wiki/前鳥神社','Wikipedia',true,now()),
('nakanotake-jinja','中之嶽神社','なかのたけじんじゃ','shrine','旧郷社','群馬県','甘楽郡下仁田町','群馬県甘楽郡下仁田町上小坂1248',36.283806,138.737389,675,null,'https://www.nakanotake.com/','妙義山に鎮座。日本一の黄金大黒像で知られる古社。','https://ja.wikipedia.org/wiki/中之嶽神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shirahata-jinja-fujisawa' and d.slug in ('samukawahiko','minamoto_no_yoshitsune'))
or (t.slug='kuzuharaoka-jinja' and d.slug in ('hino_toshimoto'))
or (t.slug='hoshinoyadera' and d.slug in ('sho_kannon'))
or (t.slug='sakitori-jinja' and d.slug in ('ujinowakiiratsuko','oyamakui','yamatotakeru'))
or (t.slug='nakanotake-jinja' and d.slug in ('yamatotakeru'))
on conflict do nothing;

-- ===== バッチ12: 埼玉・栃木・群馬 =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chichibu-imamiya-jinja','秩父今宮神社','ちちぶいまみやじんじゃ','shrine','旧無格社','埼玉県','秩父市','埼玉県秩父市中町16-10',35.994917,139.080194,1535,null,'http://www.imamiyajinja.jp/','秩父霊場発祥の地。龍神を祀る御神木の大ケヤキで知られる。','https://ja.wikipedia.org/wiki/秩父今宮神社','Wikipedia',true,now()),
('nakahikawa-jinja-tokorozawa','中氷川神社','なかひかわじんじゃ','shrine','旧県社','埼玉県','所沢市','埼玉県所沢市山口1849',35.778833,139.430222,-50,null,'http://nakahikawa.or.jp/','武蔵国の氷川信仰の中間に位置する古社。狭山の総鎮守。','https://ja.wikipedia.org/wiki/中氷川神社_(所沢市)','Wikipedia',true,now()),
('nogi-jinja-tochigi','野木神社','のぎじんじゃ','shrine','旧郷社','栃木県','下都賀郡野木町','栃木県下都賀郡野木町野木2404',36.2155500,139.7080861,400,null,'https://www.nogijinja.or.jp/','菟道稚郎子命を祀る古社。フクロウの飛来地として知られる。','https://ja.wikipedia.org/wiki/野木神社','Wikipedia',true,now()),
('kamo-jinja-kiryu','賀茂神社','かもじんじゃ','shrine','旧郷社','群馬県','桐生市','群馬県桐生市広沢町6丁目833番地',36.371000,139.349194,90,null,null,'上野国の式内社。賀茂別雷神を祀り節分の神火神事で知られる。','https://ja.wikipedia.org/wiki/賀茂神社_(桐生市)','Wikipedia',true,now()),
('tamamura-hachimangu','玉村八幡宮','たまむらはちまんぐう','shrine','旧郷社','群馬県','佐波郡玉村町','群馬県佐波郡玉村町下新田1',36.304917,139.108833,1195,null,'https://top.tamamurahachimangu.net/','源頼朝ゆかりの八幡宮。本殿は国指定重要文化財。','https://ja.wikipedia.org/wiki/玉村八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chichibu-imamiya-jinja' and d.slug in ('izanagi','izanami','susanoo'))
or (t.slug='nakahikawa-jinja-tokorozawa' and d.slug in ('susanoo','kushinadahime','okuninushi'))
or (t.slug='nogi-jinja-tochigi' and d.slug in ('ujinowakiiratsuko'))
or (t.slug='kamo-jinja-kiryu' and d.slug in ('wakeikazuchi'))
or (t.slug='tamamura-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;
