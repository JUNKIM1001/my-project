-- ============================================================
-- w9-chubu.sql  中部9県 追加データ（実在・出典付き）
-- 担当: 中部（愛知/岐阜/静岡/山梨/長野/新潟/富山/石川/福井）
-- すべて ja.wikipedia.org の infobox 十進座標で裏取り。
-- ============================================================

-- ① 新規神仏（既存に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('birushana_nyorai','毘盧舎那如来','びるしゃなにょらい','buddha','如来','{}','華厳経','華厳経の教主で、全宇宙にあまねく光をそそぐ根本仏。','https://ja.wikipedia.org/wiki/毘盧遮那仏','Wikipedia',true,now())
('takakurashita','高倉下命','たかくらじのみこと','kami','天津神','{}','記紀','神武東征を助けた尾張・熱田ゆかりの神。','https://ja.wikipedia.org/wiki/高倉下','Wikipedia',true,now()),
('miyasuhime','宮簀媛命','みやすひめのみこと','kami','人物神','{}','記紀','日本武尊の妃で草薙剣を熱田に祀った尾張氏の姫。','https://ja.wikipedia.org/wiki/ミヤズヒメ','Wikipedia',true,now()),
('izanami','伊弉冉尊','いざなみのみこと','kami','神世七代','{}','記紀','国生み・神生みを行った母神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('okuninushi','大国主','おおくにぬし','kami','国津神','{}','記紀','出雲神話の国造りの神。縁結び・農業・医療の神。','https://ja.wikipedia.org/wiki/オオクニヌシ','Wikipedia',true,now()),
('ikonahime','伊古奈比咩命','いこなひめのみこと','kami','国津神','{}','記紀','三嶋大神の后神とされる伊豆白浜の女神。','https://ja.wikipedia.org/wiki/伊古奈比咩命神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='birushana_nyorai' and g.slug in ('kaiun','byoki_heyu','jouju'))
or (d.slug='takakurashita' and g.slug in ('kaiun','shobu','yakubarai'))
or (d.slug='miyasuhime' and g.slug in ('enmusubi','kanai_anzen','renai'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='okuninushi' and g.slug in ('enmusubi','shobai','byoki_heyu'))
or (d.slug='ikonahime' and g.slug in ('enmusubi','kaijo_anzen','suisan_noko'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('myoraku-ji-obama','妙楽寺','みょうらくじ','temple','高野山真言宗','福井県','小浜市','福井県小浜市野代28-13',35.472917,135.753139,797,'千手観音','https://www.wakasaobama.jp/','若狭最古の建築とされる本堂を持つ北陸三十三観音霊場第3番札所。','https://ja.wikipedia.org/wiki/妙楽寺_(小浜市)','Wikipedia',true,now()),
('seidai-ji-echizen','清大寺（越前大仏）','せいだいじ','temple','単立','福井県','勝山市','福井県勝山市片瀬50字',36.053639,136.519250,1987,'毘盧舎那如来','https://www.etizen-daibutu.com/','奈良大仏を上回る高さ17mの越前大仏を本尊とする寺院。','https://ja.wikipedia.org/wiki/越前大仏','Wikipedia',true,now()),
('saifuku-ji-uonuma','西福寺','さいふくじ','temple','曹洞宗','新潟県','魚沼市','新潟県魚沼市大浦174',37.193667,138.956611,1534,'阿弥陀如来','http://www.saifukuji-k.com/','石川雲蝶の彫刻で知られる開山堂を持つ越後の名刹。','https://ja.wikipedia.org/wiki/西福寺_(魚沼市)','Wikipedia',true,now()),
('onominato-jinja','大野湊神社','おおのみなとじんじゃ','shrine','大野湊神社（式内社・県社）','石川県','金沢市','石川県金沢市寺中町ハ163',36.596056,136.598330,727,null,'http://oonominato.web.fc2.com/','猿田彦大神を祀る金沢の式内社。神事能で知られる。','https://ja.wikipedia.org/wiki/大野湊神社','Wikipedia',true,now()),
('etchu-kokubunji','越中国分寺','えっちゅうこくぶんじ','temple','高野山真言宗','富山県','高岡市','富山県高岡市伏木一宮1丁目',36.797900,137.049400,756,'薬師如来','https://www.takaoka.or.jp/','聖武天皇の詔で建立された越中国分寺の後継寺院。薬師堂と称される。','https://ja.wikipedia.org/wiki/越中国分寺','Wikipedia',true,now()),
('kojaku-ji-toyota','香積寺','こうじゃくじ','temple','曹洞宗','愛知県','豊田市','愛知県豊田市足助町飯盛39',35.130889,137.314489,1427,'聖観世音菩薩','https://kojakuji.com/','飯盛山にあり、紅葉の名所「香嵐渓」の発祥となった寺。','https://ja.wikipedia.org/wiki/香積寺_(豊田市)','Wikipedia',true,now()),
('honjo-ji-sanjo','本成寺','ほんじょうじ','temple','法華宗（陣門流）','新潟県','三条市','新潟県三条市西本成寺1-1-20',37.622667,138.945083,1297,'三宝尊','http://www.honjyouji.or.jp/','法華宗陣門流の総本山。鬼踊りで知られる。','https://ja.wikipedia.org/wiki/本成寺_(三条市)','Wikipedia',true,now()),
('otaki-ontake-jinja','王滝御嶽神社','おんたけじんじゃ','shrine','御嶽神社（県社）','長野県','木曽郡王滝村','長野県木曽郡王滝村3315',35.814806,137.552000,702,null,'https://ontakejinja.jp/','御嶽信仰の中心となる王滝口の里宮。','https://ja.wikipedia.org/wiki/王滝御嶽神社','Wikipedia',true,now()),
('kenchu-ji-nagoya','建中寺','けんちゅうじ','temple','浄土宗','愛知県','名古屋市','愛知県名古屋市東区筒井1-7-57',35.179389,136.928000,1651,'阿弥陀如来','http://www.kenchuji.com/','尾張徳川家の菩提寺。名古屋市最大の木造建築の本堂を持つ。','https://ja.wikipedia.org/wiki/建中寺','Wikipedia',true,now()),
('nittai-ji','覚王山日泰寺','にったいじ','temple','超宗派','愛知県','名古屋市','愛知県名古屋市千種区法王町1-1',35.171556,136.955186,1904,'釈迦如来','https://www.nittaiji.or.jp/','タイから贈られた仏舎利を安置する超宗派の寺。','https://ja.wikipedia.org/wiki/覚王山日泰寺','Wikipedia',true,now()),
('takakuramusubi-jinja','高座結御子神社','たかくらむすびみこじんじゃ','shrine','高座結御子神社（式内社・名神大社）','愛知県','名古屋市','愛知県名古屋市熱田区高蔵町9-9',35.135194,136.904389,673,null,null,'熱田神宮の境外摂社で高蔵の鎮守。','https://ja.wikipedia.org/wiki/高座結御子神社','Wikipedia',true,now()),
('himekamiko-jinja','氷上姉子神社','ひかみあねごじんじゃ','shrine','氷上姉子神社（式内社）','愛知県','名古屋市','愛知県名古屋市緑区大高町火上山',35.061461,136.930264,392,null,'https://www.atsutajingu.or.jp/','熱田神宮の境外摂社。草薙剣ゆかりの宮簀媛命を祀る。','https://ja.wikipedia.org/wiki/氷上姉子神社','Wikipedia',true,now()),
('oyada-jinja','大矢田神社','おやだじんじゃ','shrine','大矢田神社（県社）','岐阜県','美濃市','岐阜県美濃市大矢田2596',35.555806,136.868375,null,null,null,'須佐之男命を祀り、紅葉とヒンココ祭で知られる。','https://ja.wikipedia.org/wiki/大矢田神社','Wikipedia',true,now()),
('suhara-jinja','洲原神社','すはらじんじゃ','shrine','洲原神社（県社）','岐阜県','美濃市','岐阜県美濃市須原468-1-1',35.592500,136.948500,721,null,null,'全国49社の洲原神社の総本社。美濃禅定道の拠点。','https://ja.wikipedia.org/wiki/洲原神社','Wikipedia',true,now()),
('shin-hase-dera-seki','新長谷寺','しんはせでら','temple','真言宗智山派','岐阜県','関市','岐阜県関市長谷寺町1',35.485094,136.923311,1222,'十一面観世音菩薩','https://www.tsugume.com/','吉田観音と呼ばれ、室町期の三重塔・本堂を持つ。','https://ja.wikipedia.org/wiki/新長谷寺','Wikipedia',true,now()),
('hioki-jinja-nagoya','日置神社','ひおきじんじゃ','shrine','日置神社（式内社）','愛知県','名古屋市','愛知県名古屋市中区橘1丁目',35.155280,136.899440,null,null,null,'桶狭間出陣前に織田信長が戦勝祈願した式内社。','https://ja.wikipedia.org/wiki/日置神社_(名古屋市)','Wikipedia',true,now()),
('suzaki-jinja-nagoya','洲崎神社','すさきじんじゃ','shrine','洲崎神社','愛知県','名古屋市','愛知県名古屋市中区栄1丁目31-25',35.163278,136.892944,859,null,null,'堀川沿いの古社で、白龍神社の信仰でも知られる。','https://ja.wikipedia.org/wiki/洲崎神社_(名古屋市)','Wikipedia',true,now()),
('kifuri-jinja','来振神社','きぶりじんじゃ','shrine','来振神社（式内社）','岐阜県','揖斐郡大野町','岐阜県揖斐郡大野町稲富2586',35.498111,136.655111,725,null,null,'金色の雪の瑞祥に由来する式内社。','https://ja.wikipedia.org/wiki/来振神社','Wikipedia',true,now()),
('shirahama-jinja-shimoda','伊古奈比咩命神社','いこなひめのみことじんじゃ','shrine','伊古奈比咩命神社（式内社・名神大社）','静岡県','下田市','静岡県下田市白浜2740',34.693961,138.973669,null,null,'http://www.ikonahime.com/','白濱神社とも呼ばれる伊豆最古級の名神大社。','https://ja.wikipedia.org/wiki/伊古奈比咩命神社','Wikipedia',true,now()),
('seihaku-ji-yamanashi','清白寺','せいはくじ','temple','臨済宗妙心寺派','山梨県','山梨市','山梨県山梨市三ケ所620',35.694000,138.708222,1333,'釈迦如来','https://seihakuji.com/','国宝の仏殿を持つ夢窓疎石開山の禅刹。','https://ja.wikipedia.org/wiki/清白寺','Wikipedia',true,now()),
('daiya-ji-echizen','大谷寺','おおたんじ','temple','天台宗','福井県','丹生郡越前町','福井県丹生郡越前町大谷寺42-4-1',36.005639,136.090444,null,'十一面観音','http://echizen-ohtanji.com/','越知山大谷寺。1323年銘の石造九重塔(重文)で知られる。','https://ja.wikipedia.org/wiki/大谷寺_(福井県越前町)','Wikipedia',true,now()),
('uonuma-jinja','魚沼神社','うおぬまじんじゃ','shrine','魚沼神社（県社）','新潟県','小千谷市','新潟県小千谷市土川2丁目699-1',37.305000,138.787694,null,null,null,'室町期の阿弥陀堂(重文)を持つ古社。','https://ja.wikipedia.org/wiki/魚沼神社','Wikipedia',true,now()),
('miho-jinja-shizuoka','御穂神社','みほじんじゃ','shrine','御穂神社（式内社）','静岡県','静岡市','静岡県静岡市清水区三保1073',35.000111,138.520878,null,null,'https://miho-jinja.jp/','三保松原の羽衣伝説で知られる駿河三宮の式内社。','https://ja.wikipedia.org/wiki/御穂神社','Wikipedia',true,now()),
('yaizu-jinja','焼津神社','やいづじんじゃ','shrine','焼津神社（式内社・別表神社）','静岡県','焼津市','静岡県焼津市焼津2丁目7-2',34.865039,138.313644,null,null,'https://www.yaizujinja.or.jp/','日本武尊を祀り荒祭で知られる別表神社。','https://ja.wikipedia.org/wiki/焼津神社','Wikipedia',true,now()),
('rinyo-ji-gifu','林陽寺','りんようじ','temple','曹洞宗','岐阜県','岐阜市','岐阜県岐阜市岩田西3-402',35.448222,136.833139,796,'薬師如来','http://www.rinyouji.com/','弘法大師ゆかりのしだれ桜で知られる古刹。','https://ja.wikipedia.org/wiki/林陽寺','Wikipedia',true,now()),
('keta-hongu','気多本宮','けたほんぐう','shrine','能登生国玉比古神社（県社）','石川県','七尾市','石川県七尾市所口町ハ部70-1',37.037780,136.963890,null,null,null,'能登国総鎮守。気多大社の本宮とされる古社。','https://ja.wikipedia.org/wiki/気多本宮','Wikipedia',true,now()),
('juzo-jinja','重蔵神社','じゅうぞうじんじゃ','shrine','重蔵神社（県社）','石川県','輪島市','石川県輪島市河井町4-68',37.394481,136.906219,null,null,'https://juzo.or.jp/','輪島の総鎮守。輪島大祭で知られる。','https://ja.wikipedia.org/wiki/重蔵神社','Wikipedia',true,now()),
('ena-jinja','恵那神社','えなじんじゃ','shrine','恵那神社（県社）','岐阜県','中津川市','岐阜県中津川市中津川3786',35.443472,137.533583,null,null,'https://enajinja.jp/','恵那山を神体とし、伊弉諾・伊弉冉を祀る式内論社。','https://ja.wikipedia.org/wiki/恵那神社','Wikipedia',true,now()),
('hida-tenmangu','飛騨天満宮','ひだてんまんぐう','shrine','飛騨天満宮','岐阜県','高山市','岐阜県高山市天満町2-30',36.135028,137.255028,903,null,'https://hidatenmangu.com/','菅原道真の子・菅原兼茂ゆかりの天満宮。','https://ja.wikipedia.org/wiki/飛騨天満宮','Wikipedia',true,now()),
('nemichi-jinja','根道神社','ねみちじんじゃ','shrine','根道神社','岐阜県','関市','岐阜県関市板取448',35.651940,136.821110,null,null,null,'「モネの池」で知られる関市板取の鎮守。','https://ja.wikipedia.org/wiki/根道神社','Wikipedia',true,now()),
('hida-gokoku-jinja','飛騨護國神社','ひだごこくじんじゃ','shrine','護国神社','岐阜県','高山市','岐阜県高山市堀端町90',36.140861,137.263167,1909,null,'http://www.hidatakayama.ne.jp/gokoku/','飛騨出身の戦没者を祀る護国神社。','https://ja.wikipedia.org/wiki/飛騨護國神社','Wikipedia',true,now()),
('koshoin-achi','信濃比叡広拯院','こうじょういん','temple','天台宗','長野県','下伊那郡阿智村','長野県下伊那郡阿智村智里3592-4',35.460111,137.668000,817,'薬師如来','https://shinano-hiei.jp/','最澄ゆかりの神坂峠の天台寺院。信濃比叡。','https://ja.wikipedia.org/wiki/信濃比叡広拯院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='myoraku-ji-obama' and d.slug in ('senju_kannon'))
or (t.slug='seidai-ji-echizen' and d.slug in ('birushana_nyorai'))
or (t.slug='saifuku-ji-uonuma' and d.slug in ('amida_nyorai'))
or (t.slug='onominato-jinja' and d.slug in ('sarutahiko'))
or (t.slug='etchu-kokubunji' and d.slug in ('yakushi_nyorai'))
or (t.slug='kojaku-ji-toyota' and d.slug in ('sho_kannon'))
or (t.slug='honjo-ji-sanjo' and d.slug in ('sanpo_son'))
or (t.slug='otaki-ontake-jinja' and d.slug in ('kunitokotachi'))
or (t.slug='kenchu-ji-nagoya' and d.slug in ('amida_nyorai'))
or (t.slug='nittai-ji' and d.slug in ('shaka_nyorai'))
or (t.slug='takakuramusubi-jinja' and d.slug in ('takakurashita'))
or (t.slug='himekamiko-jinja' and d.slug in ('miyasuhime'))
or (t.slug='oyada-jinja' and d.slug in ('susanoo'))
or (t.slug='suhara-jinja' and d.slug in ('izanagi','izanami'))
or (t.slug='shin-hase-dera-seki' and d.slug in ('juichimen_kannon'))
or (t.slug='hioki-jinja-nagoya' and d.slug in ('futodama'))
or (t.slug='suzaki-jinja-nagoya' and d.slug in ('susanoo','kushinadahime'))
or (t.slug='kifuri-jinja' and d.slug in ('izanagi','izanami','okuninushi'))
or (t.slug='shirahama-jinja-shimoda' and d.slug in ('ikonahime'))
or (t.slug='seihaku-ji-yamanashi' and d.slug in ('shaka_nyorai'))
or (t.slug='daiya-ji-echizen' and d.slug in ('juichimen_kannon','amida_nyorai'))
or (t.slug='uonuma-jinja' and d.slug in ('takakurashita'))
or (t.slug='miho-jinja-shizuoka' and d.slug in ('okuninushi','mihotsuhime'))
or (t.slug='yaizu-jinja' and d.slug in ('yamatotakeru'))
or (t.slug='rinyo-ji-gifu' and d.slug in ('yakushi_nyorai'))
or (t.slug='keta-hongu' and d.slug in ('okuninushi','susanoo','kushinadahime'))
or (t.slug='juzo-jinja' and d.slug in ('okuninushi'))
or (t.slug='ena-jinja' and d.slug in ('izanagi','izanami'))
or (t.slug='hida-tenmangu' and d.slug in ('michizane'))
or (t.slug='nemichi-jinja' and d.slug in ('izanami'))
or (t.slug='hida-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='koshoin-achi' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;
