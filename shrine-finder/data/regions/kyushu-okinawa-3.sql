-- 九州・沖縄 観光著名社寺 第3弾
-- 担当県: 福岡,佐賀,長崎,熊本,大分,宮崎,鹿児島,沖縄
-- 出典: ja.wikipedia.org のinfobox座標を確認したもののみ。
-- 既収録分・座標なし(infobox)分は除外。

-- ① 新規神仏（既存に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kuroda_nagamasa','黒田長政','くろだながまさ','kami','人神','{武威円徳聖照権現}','史実','福岡藩初代藩主。関ヶ原の戦いで活躍した武将。','https://ja.wikipedia.org/wiki/黒田長政','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kuroda_nagamasa' and g.slug in ('shobu','kaiun','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('terumo-jinja-fukuoka','光雲神社','てるもじんじゃ','shrine','光雲神社（別表神社）','福岡県','福岡市','福岡県福岡市中央区西公園13-1',33.59722,130.37639,1766,null,'https://www.terumojinja.com/','黒田孝高・長政父子を祀る。福岡市西公園に鎮座する黒田家の祖霊社。','https://ja.wikipedia.org/wiki/光雲神社','Wikipedia',true,now()),
('torikai-hachimangu','鳥飼八幡宮','とりかいはちまんぐう','shrine','鳥飼八幡宮','福岡県','福岡市','福岡県福岡市中央区今川2丁目1-17',33.587111,130.366083,null,null,'https://hachimansama.jp/','神功皇后の伝承に由来する古社。縁結び・安産の信仰を集める。','https://ja.wikipedia.org/wiki/鳥飼八幡宮','Wikipedia',true,now()),
('kashiigu','香椎宮','かしいぐう','shrine','香椎宮（旧官幣大社・勅祭社）','福岡県','福岡市','福岡県福岡市東区香椎4-16-1',33.6534861,130.4526583,724,null,'http://kashiigu.com/','仲哀天皇・神功皇后を祀る勅祭社。香椎造の本殿は重要文化財。','https://ja.wikipedia.org/wiki/香椎宮','Wikipedia',true,now()),
('tooka-ebisu-fukuoka','十日恵比須神社','とおかえびすじんじゃ','shrine','十日恵比須神社','福岡県','福岡市','福岡県福岡市博多区東公園7-1',33.60389,130.41861,1591,null,'http://www.tooka-ebisu.or.jp/','商売繁盛の神として知られ、正月の十日恵比須大祭に多くの参拝者を集める。','https://ja.wikipedia.org/wiki/十日恵比須神社','Wikipedia',true,now()),
('nyoirinji-ogori','如意輪寺','にょいりんじ','temple','真言宗御室派','福岡県','小郡市','福岡県小郡市横隈1729',33.427556,130.567528,729,'如意輪観音','http://www.kyushyu24.com/frm10.aspx','住職が集めた蛙の置物で知られ「かえる寺」の通称で親しまれる。','https://ja.wikipedia.org/wiki/如意輪寺_(小郡市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='terumo-jinja-fukuoka' and d.slug in ('kuroda_josui','kuroda_nagamasa')) or
   (t.slug='torikai-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime')) or
   (t.slug='kashiigu' and d.slug in ('chuai','jingu_kogo')) or
   (t.slug='tooka-ebisu-fukuoka' and d.slug in ('kotoshironushi','okuninushi')) or
   (t.slug='nyoirinji-ogori' and d.slug in ('nyoirin_kannon'))
on conflict do nothing;

-- ===== バッチ2 (6-10件目) =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('washio-atago-jinja','鷲尾愛宕神社','わしおあたごじんじゃ','shrine','鷲尾愛宕神社（別表神社）','福岡県','福岡市','福岡県福岡市西区愛宕2-7-1',33.58556,130.33472,72,null,null,'博多湾を一望する高台に鎮座する火除けの社。桜の名所としても知られる。','https://ja.wikipedia.org/wiki/鷲尾愛宕神社','Wikipedia',true,now()),
('kiyomizudera-nagasaki','清水寺','きよみずでら','temple','真言宗霊雲寺派','長崎県','長崎市','長崎県長崎市鍛冶屋町8-43',32.741056,129.884111,1623,'千手観世音菩薩','http://nagasaki-kiyomizudera.jp/','京都清水寺の僧慶順が開いた長崎の古刹。本堂は国の重要文化財。','https://ja.wikipedia.org/wiki/清水寺_(長崎市)','Wikipedia',true,now()),
('saikyoji-hirado','最教寺','さいきょうじ','temple','真言宗智山派','長崎県','平戸市','長崎県平戸市岩の上町1206-1',33.363222,129.553250,1607,'虚空蔵菩薩','https://ja.wikipedia.org/wiki/最教寺_(平戸市)','Wikipedia','「西の高野山」と称される平戸藩主松浦氏ゆかりの寺。大三重塔で知られる。','https://ja.wikipedia.org/wiki/最教寺_(平戸市)','Wikipedia',true,now()),
('yusuhara-hachimangu-oita','柞原八幡宮','ゆすはらはちまんぐう','shrine','柞原八幡宮（豊後国一宮・別表神社）','大分県','大分市','大分県大分市八幡987',33.238389,131.551000,836,null,'https://ja.wikipedia.org/wiki/柞原八幡宮','Wikipedia','豊後国一宮。八幡造の社殿群は国の重要文化財。','https://ja.wikipedia.org/wiki/柞原八幡宮','Wikipedia',true,now()),
('maki-odo','真木大堂','まきおおどう','temple','天台宗','大分県','豊後高田市','大分県豊後高田市田染真木1796',33.501111,131.517611,718,'阿弥陀如来','https://ja.wikipedia.org/wiki/真木大堂','Wikipedia','六郷満山の中心寺院の一つ。日本最大級の大威徳明王像など重文を多数所蔵。','https://ja.wikipedia.org/wiki/真木大堂','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='washio-atago-jinja' and d.slug in ('izanagi','izanami','amenooshihomimi','kagutsuchi')) or
   (t.slug='kiyomizudera-nagasaki' and d.slug in ('senju_kannon')) or
   (t.slug='saikyoji-hirado' and d.slug in ('kokuzo_bosatsu')) or
   (t.slug='yusuhara-hachimangu-oita' and d.slug in ('chuai','hachiman','jingu_kogo')) or
   (t.slug='maki-odo' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== バッチ3 (11-15件目) =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('monjusenji','文殊仙寺','もんじゅせんじ','temple','天台宗','大分県','国東市','大分県国東市国東町大恩寺2432',33.6024694,131.6138750,648,'文殊菩薩','https://ja.wikipedia.org/wiki/文殊仙寺','Wikipedia','日本三文殊の一つ。「三人寄れば文殊の知恵」発祥の地と伝わる六郷満山の古刹。','https://ja.wikipedia.org/wiki/文殊仙寺','Wikipedia',true,now()),
('okinogu-naha','沖宮','おきのぐう','shrine','沖宮（琉球八社）','沖縄県','那覇市','沖縄県那覇市奥武山町44',26.202778,127.677083,null,null,'http://okinogu.or.jp/','琉球八社の一社。奥武山公園内に鎮座する天照大神ゆかりの社。','https://ja.wikipedia.org/wiki/沖宮','Wikipedia',true,now()),
('jigenin-shuri-kannondo','慈眼院','じげんいん','temple','臨済宗妙心寺派','沖縄県','那覇市','沖縄県那覇市首里山川町3-1',26.219250,127.708750,1618,'千手観世音菩薩','http://www.shuri-kannondo.or.jp/','「首里観音堂」として親しまれる琉球王国ゆかりの寺。','https://ja.wikipedia.org/wiki/首里観音堂','Wikipedia',true,now()),
('kin-kannonji','金武観音寺','きんかんのんじ','temple','高野山真言宗','沖縄県','金武町','沖縄県国頭郡金武町金武222',26.4553194,127.9214500,1500,'聖観音','https://ja.wikipedia.org/wiki/金武観音寺','Wikipedia','日秀上人が開いた琉球の古刹。戦前の木造建築を残す本堂で知られる。','https://ja.wikipedia.org/wiki/金武観音寺','Wikipedia',true,now()),
('yaku-jinja','益救神社','やくじんじゃ','shrine','益救神社（式内社・別表神社）','鹿児島県','屋久島町','鹿児島県熊毛郡屋久島町宮之浦字水洗尻277',30.4271389,130.5718111,null,null,'http://www.yakujinja.com/','屋久島に鎮座する式内社。「益救（やく）」の名から救いの神として信仰される。','https://ja.wikipedia.org/wiki/益救神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='monjusenji' and d.slug in ('monju_bosatsu')) or
   (t.slug='okinogu-naha' and d.slug in ('amaterasu','kumano_okami')) or
   (t.slug='jigenin-shuri-kannondo' and d.slug in ('senju_kannon')) or
   (t.slug='kin-kannonji' and d.slug in ('sho_kannon')) or
   (t.slug='yaku-jinja' and d.slug in ('hikohohodemi'))
on conflict do nothing;

-- ===== バッチ4 (16-20件目) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yasomagatsuhi','八十禍津日神','やそまがつひのかみ','kami','天津神','{}','記紀','イザナギの禊で生まれた禍を司る神。警固大神の一柱。','https://ja.wikipedia.org/wiki/ヤソマガツヒ','Wikipedia',true,now()),
('kamunaobi','神直毘神','かむなおびのかみ','kami','天津神','{神直日神}','記紀','禍を直す神。警固大神の一柱。','https://ja.wikipedia.org/wiki/ナオビノカミ','Wikipedia',true,now()),
('onaobi','大直毘神','おおなおびのかみ','kami','天津神','{大直日神}','記紀','禍を直す神。警固大神の一柱。','https://ja.wikipedia.org/wiki/ナオビノカミ','Wikipedia',true,now()),
('nozaki_tsunayoshi','野崎綱吉','のざきつなよし','kami','人神','{野崎隠岐守綱吉}','史実','高島の領主。宝当神社の祭神で当選祈願の神として信仰される。','https://ja.wikipedia.org/wiki/宝当神社','Wikipedia',true,now()),
('koen_daibosatsu','皇円大菩薩','こうえんだいぼさつ','buddha','高僧','{}','仏教','法然の師として知られる平安期の天台僧・皇円を神格化したもの。','https://ja.wikipedia.org/wiki/皇円','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yasomagatsuhi' and g.slug in ('yakubarai','majo_kekkai')) or
   (d.slug='kamunaobi' and g.slug in ('yakubarai','kaiun')) or
   (d.slug='onaobi' and g.slug in ('yakubarai','kaiun')) or
   (d.slug='nozaki_tsunayoshi' and g.slug in ('kinun','kaiun','jouju')) or
   (d.slug='koen_daibosatsu' and g.slug in ('jouju','byoki_heyu','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sakurai-jinja-itoshima','桜井神社','さくらいじんじゃ','shrine','桜井神社','福岡県','糸島市','福岡県糸島市志摩桜井4227',33.628306,130.192028,1632,null,'https://www.sakuraijinja.com/','黒田忠之が創建した古社。本殿・拝殿・楼門は国の重要文化財。','https://ja.wikipedia.org/wiki/桜井神社_(糸島市)','Wikipedia',true,now()),
('arahira-tenjin','荒平天神','あらひらてんじん','shrine','菅原神社','鹿児島県','鹿屋市','鹿児島県鹿屋市天神町4014',31.379583,130.777417,1532,null,null,'錦江湾に突き出た岩礁に鎮座する菅原道真を祀る天神。学問の神として信仰される。','https://ja.wikipedia.org/wiki/荒平天神','Wikipedia',true,now()),
('hoto-jinja','宝当神社','ほうとうじんじゃ','shrine','宝当神社','佐賀県','唐津市','佐賀県唐津市高島523',33.47389,129.98806,1768,null,'https://houtoujinja.jp/','唐津湾の高島に鎮座し「宝くじが当たる神社」として全国から参拝者を集める。','https://ja.wikipedia.org/wiki/宝当神社','Wikipedia',true,now()),
('kamishikimi-kumanoimasu','上色見熊野座神社','かみしきみくまのいますじんじゃ','shrine','上色見熊野座神社','熊本県','高森町','熊本県阿蘇郡高森町上色見2619',32.854500,131.158667,null,null,null,'参道の苔むした石灯籠と穿戸岩で知られる神秘的な社。','https://ja.wikipedia.org/wiki/上色見熊野座神社','Wikipedia',true,now()),
('rengein-tanjoji','蓮華院誕生寺','れんげいんたんじょうじ','temple','真言律宗','熊本県','玉名市','熊本県玉名市築地2288',32.932667,130.535417,1930,'皇円大菩薩','https://www.rengein.jp/','皇円大菩薩を祀る祈祷寺。日本一の大梵鐘「飛龍の鐘」で知られる。','https://ja.wikipedia.org/wiki/蓮華院誕生寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sakurai-jinja-itoshima' and d.slug in ('kamunaobi','onaobi','yasomagatsuhi')) or
   (t.slug='arahira-tenjin' and d.slug in ('michizane')) or
   (t.slug='hoto-jinja' and d.slug in ('nozaki_tsunayoshi')) or
   (t.slug='kamishikimi-kumanoimasu' and d.slug in ('izanagi','izanami')) or
   (t.slug='rengein-tanjoji' and d.slug in ('koen_daibosatsu'))
on conflict do nothing;

-- ===== バッチ5 (21-25件目) =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kamafuta-jinja','射楯兵主神社','いたてつわものぬしじんじゃ','shrine','射楯兵主神社','鹿児島県','南九州市','鹿児島県南九州市頴娃町別府6827',31.249944,130.416250,1667,null,'http://kamafutajinja.com/','「釜蓋神社」の通称で知られ、釜の蓋を頭に載せて祈願する勝負・開運の社。','https://ja.wikipedia.org/wiki/射楯兵主神社_(南九州市)','Wikipedia',true,now()),
('kaijin-jinja-tsushima','海神神社','かいじんじんじゃ','shrine','海神神社（対馬国一宮・別表神社）','長崎県','対馬市','長崎県対馬市峰町木坂247',34.464250,129.283333,null,null,null,'対馬国一宮。豊玉姫命を祀り、神功皇后ゆかりの古社と伝わる。','https://ja.wikipedia.org/wiki/海神神社','Wikipedia',true,now()),
('hachiman-kamado-jinja','八幡竈門神社','はちまんかまどじんじゃ','shrine','八幡竈門神社','大分県','別府市','大分県別府市大字内竈1900',33.332389,131.483250,727,null,'http://hachimannkamado.sub.jp/','別府湾を望む高台に鎮座する八幡宮。鬼が築いたという九十九段の石段で知られる。','https://ja.wikipedia.org/wiki/八幡竈門神社','Wikipedia',true,now()),
('imayama-daishiji','今山大師寺','いまやまだいしじ','temple','真言宗','宮崎県','延岡市','宮崎県延岡市山下町2丁目3998',32.59000,131.66611,1839,'弘法大師','https://www.imayamadaisi.com/','日本一とされる弘法大師の青銅製立像で知られる延岡の大師寺。','https://ja.wikipedia.org/wiki/今山大師寺','Wikipedia',true,now()),
('ibusuki-jinja','揖宿神社','いぶすきじんじゃ','shrine','揖宿神社（式内社・別表神社）','鹿児島県','指宿市','鹿児島県指宿市東方773',31.253389,130.623667,706,null,'http://www.ibusukijinsha.com/','指宿郷の総鎮守。天照大御神を主祭神とする式内社。','https://ja.wikipedia.org/wiki/揖宿神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kamafuta-jinja' and d.slug in ('susanoo','ukemochi')) or
   (t.slug='kaijin-jinja-tsushima' and d.slug in ('toyotamahime')) or
   (t.slug='hachiman-kamado-jinja' and d.slug in ('hachiman','chuai','jingu_kogo')) or
   (t.slug='imayama-daishiji' and d.slug in ('kobo_daishi')) or
   (t.slug='ibusuki-jinja' and d.slug in ('amaterasu'))
on conflict do nothing;

-- ===== バッチ6 (26-30件目) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yaimimitama','八井耳玉命','やいみみたまのみこと','kami','人神','{甲佐明神}','記紀・社伝','神武天皇の皇子神八井耳命の系統とされる阿蘇開拓の神。甲佐神社の祭神。','https://ja.wikipedia.org/wiki/甲佐神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yaimimitama' and g.slug in ('suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('isahaya-jinja','諫早神社','いさはやじんじゃ','shrine','諫早神社','長崎県','諫早市','長崎県諫早市宇都町1-12',32.848389,130.043111,728,null,'http://www.isahaya-jinja.jp/','「四面宮（おしめんさん）」と親しまれる九州総守護の古社。天照大神らを祀る。','https://ja.wikipedia.org/wiki/諫早神社','Wikipedia',true,now()),
('niiyama-jinja','仁比山神社','にいやまじんじゃ','shrine','仁比山神社','佐賀県','神埼市','佐賀県神埼市神埼町的1692',33.3583361,130.3648528,729,null,null,'「山王さん」と呼ばれ大山咋命を祀る古社。十二年ごとの御田舞で知られる。','https://ja.wikipedia.org/wiki/仁比山神社','Wikipedia',true,now()),
('kosa-jinja','甲佐神社','こうさじんじゃ','shrine','甲佐神社','熊本県','甲佐町','熊本県上益城郡甲佐町上揚882',32.643389,130.834333,null,null,null,'肥後国二宮。甲佐明神(八井耳玉命)を祀る阿蘇系の古社。','https://ja.wikipedia.org/wiki/甲佐神社','Wikipedia',true,now()),
('sennyoji-daihiouin','千如寺大悲王院','せんにょじだいひおういん','temple','真言宗大覚寺派','福岡県','糸島市','福岡県糸島市雷山626',33.494611,130.228583,178,'千手観音','http://www.sennyoji.or.jp/','雷山中腹に建つ古刹。樹齢400年の大楓と紅葉の名所として知られる。','https://ja.wikipedia.org/wiki/雷山千如寺大悲王院','Wikipedia',true,now()),
('tennenji-bungotakada','天念寺','てんねんじ','temple','天台宗','大分県','豊後高田市','大分県豊後高田市長岩屋1152',33.578583,131.540667,718,'釈迦如来','https://ja.wikipedia.org/wiki/天念寺','Wikipedia','六郷満山の古刹。国指定重要無形民俗文化財「修正鬼会」と天念寺耶馬で知られる。','https://ja.wikipedia.org/wiki/天念寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='isahaya-jinja' and d.slug in ('amaterasu','okuninushi','sukunabikona')) or
   (t.slug='niiyama-jinja' and d.slug in ('oyamakui')) or
   (t.slug='kosa-jinja' and d.slug in ('yaimimitama')) or
   (t.slug='sennyoji-daihiouin' and d.slug in ('senju_kannon')) or
   (t.slug='tennenji-bungotakada' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== バッチ7 (31-35件目) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shimazu_tadayoshi','島津忠良','しまづただよし','kami','人神','{日新斎}','史実','島津氏中興の祖。いろは歌の教えで知られる戦国武将。','https://ja.wikipedia.org/wiki/島津忠良','Wikipedia',true,now()),
('fujiwara_hirotsugu','藤原広嗣','ふじわらのひろつぐ','kami','御霊','{}','史実','奈良時代の貴族。藤原広嗣の乱の主。御霊として鏡神社に祀られる。','https://ja.wikipedia.org/wiki/藤原広嗣','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shimazu_tadayoshi' and g.slug in ('gakumon','shobu','kaiun')) or
   (d.slug='fujiwara_hirotsugu' and g.slug in ('yakubarai','majo_kekkai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tsumakirishima-jinja','東霧島神社','つまきりしまじんじゃ','shrine','東霧島神社','宮崎県','都城市','宮崎県都城市高崎町東霧島1560',31.845389,131.059889,963,null,'https://tsumakirishimajinjya.com/','霧島六所権現の一つ。鬼岩階段や神石で知られる伊弉諾尊を祀る古社。','https://ja.wikipedia.org/wiki/東霧島神社','Wikipedia',true,now()),
('kirishimamine-jinja','霧島岑神社','きりしまみねじんじゃ','shrine','霧島岑神社','宮崎県','小林市','宮崎県小林市細野4937',31.966083,130.957861,837,null,null,'霧島六所権現の中心社。瓊瓊杵尊・木花開耶姫らを祀る。','https://ja.wikipedia.org/wiki/霧島岑神社','Wikipedia',true,now()),
('takeda-jinja-minamisatsuma','竹田神社','たけだじんじゃ','shrine','竹田神社','鹿児島県','南さつま市','鹿児島県南さつま市加世田武田17932',31.410472,130.315694,1869,null,null,'島津氏中興の祖・島津忠良を祀る。いろは歌の石碑が並ぶ参道で知られる。','https://ja.wikipedia.org/wiki/竹田神社_(南さつま市)','Wikipedia',true,now()),
('iwatoji-kunisaki','岩戸寺','いわとじ','temple','天台宗','大分県','国東市','大分県国東市国東町岩戸寺1232',33.619222,131.618833,718,'薬師如来','https://ja.wikipedia.org/wiki/岩戸寺_(国東市)','Wikipedia','六郷満山の古刹。1283年銘の国東塔は国の重要文化財。修正鬼会で知られる。','https://ja.wikipedia.org/wiki/岩戸寺_(国東市)','Wikipedia',true,now()),
('kagami-jinja-karatsu','鏡神社','かがみじんじゃ','shrine','鏡神社','佐賀県','唐津市','佐賀県唐津市鏡1827',33.432222,130.008611,null,null,null,'松浦の鏡の神として『源氏物語』にも登場する古社。神功皇后と藤原広嗣を祀る。','https://ja.wikipedia.org/wiki/鏡神社_(唐津市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tsumakirishima-jinja' and d.slug in ('izanagi')) or
   (t.slug='kirishimamine-jinja' and d.slug in ('ninigi','konohanasakuya')) or
   (t.slug='takeda-jinja-minamisatsuma' and d.slug in ('shimazu_tadayoshi')) or
   (t.slug='iwatoji-kunisaki' and d.slug in ('yakushi_nyorai')) or
   (t.slug='kagami-jinja-karatsu' and d.slug in ('jingu_kogo','fujiwara_hirotsugu'))
on conflict do nothing;
