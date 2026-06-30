-- =====================================================================
-- 御朱印ナビ 社寺データ拡張: 中部地方
-- 対象県: 新潟,富山,石川,福井,山梨,長野,岐阜,静岡,愛知
-- 出典: ja.wikipedia.org（各社寺記事の infobox から所在地・十進座標・
--        御祭神/本尊・創建・公式サイトを WebFetch で裏取り）
-- 全 50 件（座標が infobox に無い社寺は除外）
-- =====================================================================

-- ---------------------------------------------------------------------
-- ① 新規神仏（既存柱に無いものだけ）
-- ---------------------------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nunakawahime','沼河比売','ぬなかわひめ','kami','国津神','{奴奈川姫}','記紀','高志国の女神。大国主の妻で建御名方神の母。子宝・安産・翡翠の神。','https://ja.wikipedia.org/wiki/ヌナカワヒメ','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{積羽八重事代主神,恵比寿}','記紀','大国主の子。託宣・海・商売の神。えびす神と習合。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('kanayamahiko','金山彦命','かなやまひこのみこと','kami','国津神','{}','記紀','鉱山・金属・鍛冶の神。南宮大社の主祭神。','https://ja.wikipedia.org/wiki/カナヤマヒコ','Wikipedia',true,now()),
('izanagi','伊邪那岐神','いざなぎのかみ','kami','天津神','{伊弉諾尊}','記紀','国生み・神生みの男神。イザナミの夫。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('amenotajikarao','天手力雄命','あめのたぢからおのみこと','kami','天津神','{天手力男神}','記紀','天岩戸を開いた怪力の神。スポーツ・開運の神。','https://ja.wikipedia.org/wiki/アメノタヂカラオ','Wikipedia',true,now()),
('oyamazumi','大山祇神','おおやまづみのかみ','kami','国津神','{大山積神}','記紀','山の神。木花開耶姫の父。山林・酒造・海上の守護。','https://ja.wikipedia.org/wiki/オオヤマツミ','Wikipedia',true,now()),
('hotakami','穂高見命','ほたかみのみこと','kami','国津神','{宇都志日金析命}','記紀','綿津見神の子とされる海神系の神。安曇族の祖神。穂高神社主祭神。','https://ja.wikipedia.org/wiki/穂高神社','Wikipedia',true,now()),
('watatsumi','綿津見神','わたつみのかみ','kami','国津神','{海神}','記紀','海を司る神。航海・漁業の守護。','https://ja.wikipedia.org/wiki/ワタツミ','Wikipedia',true,now()),
('hinokagutsuchi','火之迦具土神','ひのかぐつちのかみ','kami','国津神','{火産霊神,秋葉大神}','記紀','火の神。防火・鎮火・火伏せの神。秋葉信仰の本神。','https://ja.wikipedia.org/wiki/カグツチ','Wikipedia',true,now()),
('amenohoakari','天火明命','あめのほあかりのみこと','kami','天津神','{天照国照彦火明命}','記紀','尾張氏の祖神。日・農耕の神。真清田神社主祭神。','https://ja.wikipedia.org/wiki/アメノホアカリ','Wikipedia',true,now()),
('ikushima','生島大神','いくしまのおおかみ','kami','国津神','{生島神}','記紀','国土・万物に生命力を与える神。生島足島神社主祭神。','https://ja.wikipedia.org/wiki/生島足島神社','Wikipedia',true,now()),
('tarushima','足島大神','たるしまのおおかみ','kami','国津神','{足島神}','記紀','国土を満ち足らしめる神。生島足島神社主祭神。','https://ja.wikipedia.org/wiki/生島足島神社','Wikipedia',true,now()),
('inishikiiribiko','五十瓊敷入彦命','いにしきいりひこのみこと','kami','国津神','{}','記紀','垂仁天皇の皇子。開拓・産業・武の神。伊奈波神社主祭神。','https://ja.wikipedia.org/wiki/伊奈波神社','Wikipedia',true,now()),
('mitoshi','御歳大神','みとしのおおかみ','kami','国津神','{水無大神,水無神}','記紀','穀物・農耕を司る年神系の神。飛騨一宮水無神社主祭神。','https://ja.wikipedia.org/wiki/飛騨一宮水無神社','Wikipedia',true,now()),
('amenominakanushi','天之御中主神','あめのみなかぬしのかみ','kami','天津神','{}','記紀','造化三神の首座。宇宙の中心・根源の神。','https://ja.wikipedia.org/wiki/アメノミナカヌシ','Wikipedia',true,now()),
('takamimusubi','高皇産霊神','たかみむすびのかみ','kami','天津神','{高木神}','記紀','造化三神の一柱。生成・縁結びの神。','https://ja.wikipedia.org/wiki/タカミムスビ','Wikipedia',true,now()),
('kamimusubi','神皇産霊神','かみむすびのかみ','kami','天津神','{}','記紀','造化三神の一柱。生成・縁結びの神。','https://ja.wikipedia.org/wiki/カミムスビ','Wikipedia',true,now()),
('uesugi_kenshin','上杉謙信','うえすぎけんしん','kami','御霊','{長尾景虎}','歴史','越後の戦国大名。軍神・武運の神として春日山神社に祀られる。','https://ja.wikipedia.org/wiki/上杉謙信','Wikipedia',true,now()),
('maeda_toshiie','前田利家','まえだとしいえ','kami','御霊','{}','歴史','加賀藩祖。武功・出世の神として尾山神社に祀られる。','https://ja.wikipedia.org/wiki/前田利家','Wikipedia',true,now()),
('takeda_shingen','武田信玄','たけだしんげん','kami','御霊','{武田晴信}','歴史','甲斐の戦国大名。武運・勝負・出世の神として武田神社に祀られる。','https://ja.wikipedia.org/wiki/武田信玄','Wikipedia',true,now()),
('shibata_katsuie','柴田勝家','しばたかついえ','kami','御霊','{}','歴史','織田家筆頭家老。越前北ノ庄城主。柴田神社に祀られる。','https://ja.wikipedia.org/wiki/柴田勝家','Wikipedia',true,now()),
('kogane_no_okami','金大神','こがねのおおかみ','kami','御霊','{渟熨斗姫命}','記紀','金運・財運を司るとされる金神社の主祭神。','https://ja.wikipedia.org/wiki/金神社_(岐阜市)','Wikipedia',true,now()),
('dakiniten','吒枳尼真天','だきにしんてん','buddha','天部','{豊川吒枳尼真天}','仏教','稲穂を担い白狐に乗る天部の神。商売繁盛・福徳の守護。豊川稲荷の鎮守。','https://ja.wikipedia.org/wiki/豊川稲荷','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{十一面観世音菩薩}','仏教','十一の顔を持つ観音菩薩。除災・病気平癒の利益。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ---------------------------------------------------------------------
-- ② 新規神仏の司るご利益（30種から選択）
-- ---------------------------------------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nunakawahime' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='kotoshironushi' and g.slug in ('shobai','kinun','enmusubi'))
or (d.slug='kanayamahiko' and g.slug in ('shobai','shigoto','kinun'))
or (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','yakubarai'))
or (d.slug='amenotajikarao' and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='oyamazumi' and g.slug in ('shobai','kaiun','suisan_noko'))
or (d.slug='hotakami' and g.slug in ('kaijo_anzen','suisan_noko','kotsu_anzen'))
or (d.slug='watatsumi' and g.slug in ('kaijo_anzen','suisan_noko'))
or (d.slug='hinokagutsuchi' and g.slug in ('yakubarai','majo_kekkai','shigoto'))
or (d.slug='amenohoakari' and g.slug in ('suisan_noko','kaiun','shobai'))
or (d.slug='ikushima' and g.slug in ('kaiun','kanai_anzen','byoki_heyu'))
or (d.slug='tarushima' and g.slug in ('kaiun','kanai_anzen','shobai'))
or (d.slug='inishikiiribiko' and g.slug in ('shobu','shigoto','kaiun'))
or (d.slug='mitoshi' and g.slug in ('suisan_noko','shobai','kaiun'))
or (d.slug='amenominakanushi' and g.slug in ('kaiun','enmusubi','yakubarai'))
or (d.slug='takamimusubi' and g.slug in ('enmusubi','renai','kaiun'))
or (d.slug='kamimusubi' and g.slug in ('enmusubi','renai','kaiun'))
or (d.slug='uesugi_kenshin' and g.slug in ('shobu','shusse','kinun'))
or (d.slug='maeda_toshiie' and g.slug in ('shusse','shobu','shobai'))
or (d.slug='takeda_shingen' and g.slug in ('shobu','shusse','shigoto'))
or (d.slug='shibata_katsuie' and g.slug in ('shobu','shusse'))
or (d.slug='kogane_no_okami' and g.slug in ('kinun','shobai','shusse'))
or (d.slug='dakiniten' and g.slug in ('shobai','kinun','majo_kekkai'))
or (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','yakubarai','kaiun'))
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values

-- 新潟県 -------------------------------------------------------------
('kota-jinja','居多神社','こたじんじゃ','shrine','越後国一宮（旧県社・式内社）','新潟県','上越市','新潟県上越市五智6-1-11',37.1664389,138.2231694,null,null,'http://www.kotajinja.jp/','越後国一宮。大国主・奴奈川姫らを祀り、縁結び・子授けで知られる。','https://ja.wikipedia.org/wiki/居多神社','Wikipedia',true,now()),
('kasugayama-jinja','春日山神社','かすがやまじんじゃ','shrine','旧県社','新潟県','上越市','新潟県上越市大豆1743',37.147472,138.208889,1901,null,null,'春日山城跡に鎮座し、軍神・上杉謙信を祀る。','https://ja.wikipedia.org/wiki/春日山神社','Wikipedia',true,now()),
('niigata-gokoku-jinja','新潟縣護國神社','にいがたけんごこくじんじゃ','shrine','護国神社（別表神社）','新潟県','新潟市','新潟県新潟市中央区西船見町5932-300',37.9220444,139.0290750,1868,null,'https://www.niigata-gokoku.or.jp/','新潟県ゆかりの英霊を祀る護国神社。日本海に面した松林に鎮座。','https://ja.wikipedia.org/wiki/新潟県護国神社','Wikipedia',true,now()),
('kokujoji','国上寺','こくじょうじ','temple','真言宗豊山派','新潟県','燕市','新潟県燕市国上1407',37.665889,138.812722,709,'阿弥陀如来','https://kokujouji.com/','越後最古の古刹。良寛が住した五合庵で知られる。','https://ja.wikipedia.org/wiki/国上寺','Wikipedia',true,now()),

-- 富山県 -------------------------------------------------------------
('zuiryuji','瑞龍寺','ずいりゅうじ','temple','曹洞宗','富山県','高岡市','富山県高岡市関本町35',36.735595,137.010504,1614,'釈迦如来','http://www.zuiryuji.jp/','加賀藩二代藩主前田利長の菩提寺。仏殿・法堂・山門が国宝。','https://ja.wikipedia.org/wiki/瑞龍寺_(高岡市)','Wikipedia',true,now()),
('oyama-jinja-tateyama','雄山神社（前立社壇）','おやまじんじゃ まえだてしゃだん','shrine','越中国一宮（旧国幣小社・式内社）','富山県','中新川郡立山町','富山県中新川郡立山町岩峅寺1',36.5831083,137.3925194,701,null,'http://www.oyamajinja.org','立山を神体山とする越中国一宮。立山信仰の中心。','https://ja.wikipedia.org/wiki/雄山神社','Wikipedia',true,now()),
('takase-jinja','高瀬神社','たかせじんじゃ','shrine','越中国一宮（旧国幣小社・式内社）','富山県','南砺市','富山県南砺市高瀬291',36.5718611,136.9482500,null,null,'http://www.takase.or.jp/','大己貴命を祀る越中国一宮。縁結び・厄除けで知られる。','https://ja.wikipedia.org/wiki/高瀬神社','Wikipedia',true,now()),
('hojozu-hachimangu','放生津八幡宮','ほうじょうづはちまんぐう','shrine','旧県社','富山県','射水市','富山県射水市八幡町2-2-27',36.780583,137.094472,746,null,'http://www.houjyoudu.com/','大伴家持が宇佐八幡を勧請したと伝わる。曳山祭が有名。','https://ja.wikipedia.org/wiki/放生津八幡宮','Wikipedia',true,now()),
('nissekiji','大岩山日石寺','おおいわさんにっせきじ','temple','真言密宗（大本山）','富山県','中新川郡上市町','富山県中新川郡上市町大岩163',36.662139,137.391083,725,'不動明王','https://ooiwasan.com/','磨崖仏の不動明王を本尊とする大岩不動。六本滝の滝行で知られる。','https://ja.wikipedia.org/wiki/日石寺','Wikipedia',true,now()),

-- 石川県 -------------------------------------------------------------
('keta-taisha','氣多大社','けたたいしゃ','shrine','能登国一宮（旧国幣大社・式内社）','石川県','羽咋市','石川県羽咋市寺家町ク1',36.9260083,136.7674417,null,null,'https://keta.jp','能登国一宮。大己貴命を祀り、縁結びの神として信仰を集める。','https://ja.wikipedia.org/wiki/気多大社','Wikipedia',true,now()),
('natadera','那谷寺','なたでら','temple','高野山真言宗','石川県','小松市','石川県小松市那谷町ユ122',36.3134083,136.4203917,717,'千手観音','https://natadera.com','奇岩遊仙境で知られる白山信仰の古刹。芭蕉も訪れた紅葉の名所。','https://ja.wikipedia.org/wiki/那谷寺','Wikipedia',true,now()),
('oyama-jinja-kanazawa','尾山神社','おやまじんじゃ','shrine','旧別格官幣社（別表神社）','石川県','金沢市','石川県金沢市尾山町11-1',36.5663222,136.6557917,1873,null,'http://www.oyama-jinja.or.jp/','加賀藩祖・前田利家とまつを祀る。和漢洋折衷の神門が有名。','https://ja.wikipedia.org/wiki/尾山神社','Wikipedia',true,now()),
('kanazawa-jinja','金沢神社','かなざわじんじゃ','shrine','旧県社','石川県','金沢市','石川県金沢市兼六町1-3',36.5604028,136.6627333,1794,null,'http://www.kanazawa-jj.or.jp/','兼六園に隣接し菅原道真を祀る。学業成就の神として信仰。','https://ja.wikipedia.org/wiki/金沢神社','Wikipedia',true,now()),

-- 福井県 -------------------------------------------------------------
('kehi-jingu','氣比神宮','けひじんぐう','shrine','越前国一宮（旧官幣大社・名神大社）','福井県','敦賀市','福井県敦賀市曙町11-68',35.6549583,136.0747000,null,null,'https://kehijingu.jp/','北陸道総鎮守の越前国一宮。日本三大鳥居の大鳥居で知られる。','https://ja.wikipedia.org/wiki/氣比神宮','Wikipedia',true,now()),
('heisenji-hakusan-jinja','平泉寺白山神社','へいせんじはくさんじんじゃ','shrine','旧県社','福井県','勝山市','福井県勝山市平泉寺町平泉寺',36.043917,136.542111,717,null,null,'白山信仰越前側の拠点。苔の参道が美しい国史跡。','https://ja.wikipedia.org/wiki/平泉寺白山神社','Wikipedia',true,now()),
('tsurugi-jinja','劔神社','つるぎじんじゃ','shrine','越前国二宮（旧国幣小社・式内社）','福井県','丹生郡越前町','福井県丹生郡越前町織田113-1',35.957833,136.055389,null,null,'http://tsurugi-jinja.jp/','素盞嗚尊を祀る越前二宮。織田信長ゆかりの社で梵鐘が国宝。','https://ja.wikipedia.org/wiki/劔神社','Wikipedia',true,now()),
('shibata-jinja','柴田神社','しばたじんじゃ','shrine','旧無格社','福井県','福井市','福井県福井市中央1-21-17',36.0602750,136.2195250,1890,null,'https://sibatajinja.jp','北ノ庄城跡に建ち柴田勝家を祀る。お市の方も祀られる。','https://ja.wikipedia.org/wiki/柴田神社','Wikipedia',true,now()),
('myotsuji','明通寺','みょうつうじ','temple','真言宗御室派','福井県','小浜市','福井県小浜市門前5-22',35.453550,135.804450,806,'薬師如来','https://myotsuji.jimdofree.com/','坂上田村麻呂創建と伝わる。本堂・三重塔が福井県唯一の国宝。','https://ja.wikipedia.org/wiki/明通寺','Wikipedia',true,now()),

-- 山梨県 -------------------------------------------------------------
('takeda-jinja','武田神社','たけだじんじゃ','shrine','旧県社（別表神社）','山梨県','甲府市','山梨県甲府市古府中町2611',35.686889,138.577472,1919,null,'http://www.takedajinja.or.jp/','躑躅ヶ崎館跡に鎮座し武田信玄を祀る。勝運の神として信仰。','https://ja.wikipedia.org/wiki/武田神社','Wikipedia',true,now()),
('kuonji','久遠寺','くおんじ','temple','日蓮宗（総本山）','山梨県','南巨摩郡身延町','山梨県南巨摩郡身延町身延3567',35.381917,138.424861,1281,'十界大曼荼羅','https://www.kuonji.jp/','日蓮宗総本山。身延山に立ち、しだれ桜と菩提梯で知られる。','https://ja.wikipedia.org/wiki/久遠寺','Wikipedia',true,now()),
('kitaguchi-hongu-fuji-sengen','北口本宮冨士浅間神社','きたぐちほんぐうふじせんげんじんじゃ','shrine','旧県社（別表神社）','山梨県','富士吉田市','山梨県富士吉田市上吉田5558',35.470750,138.792417,null,null,'https://www.sengenjinja.jp','富士登山吉田口の起点。世界遺産富士山構成資産の浅間神社。','https://ja.wikipedia.org/wiki/北口本宮冨士浅間神社','Wikipedia',true,now()),

-- 長野県 -------------------------------------------------------------
('togakushi-jinja','戸隠神社（中社）','とがくしじんじゃ ちゅうしゃ','shrine','旧国幣小社（別表神社）','長野県','長野市','長野県長野市戸隠3690',36.742389,138.085000,null,null,'https://www.togakushi-jinja.jp/','天手力雄命を祀る戸隠五社の一。天岩戸開きの神話で知られる。','https://ja.wikipedia.org/wiki/戸隠神社','Wikipedia',true,now()),
('ikushimatarushima-jinja','生島足島神社','いくしまたるしまじんじゃ','shrine','信濃国二宮（旧県社・名神大社）','長野県','上田市','長野県上田市下之郷中池西701',36.360250,138.218194,null,null,'https://www.ikushimatarushima.com/','池中の島に鎮座する古社。武田家ゆかりの文書を伝える。','https://ja.wikipedia.org/wiki/生島足島神社','Wikipedia',true,now()),
('hotaka-jinja','穂高神社','ほたかじんじゃ','shrine','信濃国三宮（旧国幣小社・名神大社）','長野県','安曇野市','長野県安曇野市穂高6079',36.338667,137.884306,null,null,'http://www.hotakajinja.com/','日本アルプスの総鎮守。安曇族の祖神を祀り御船祭が有名。','https://ja.wikipedia.org/wiki/穂高神社','Wikipedia',true,now()),
('kitamuki-kannon','北向観音','きたむきかんのん','temple','天台宗','長野県','上田市','長野県上田市別所温泉1666',36.349833,138.156389,825,'千手観世音菩薩','https://www.kitamuki-kannon.com/','別所温泉にある北を向く本堂が珍しい霊場。善光寺と両参りの寺。','https://ja.wikipedia.org/wiki/北向観音','Wikipedia',true,now()),
('anrakuji-ueda','安楽寺','あんらくじ','temple','曹洞宗','長野県','上田市','長野県上田市別所温泉2361',36.352220,138.153330,null,'釈迦如来','http://www.anrakuji.com/','日本唯一の現存する木造八角三重塔（国宝）で知られる禅刹。','https://ja.wikipedia.org/wiki/安楽寺_(上田市)','Wikipedia',true,now()),
('yohashira-jinja','四柱神社','よはしらじんじゃ','shrine','旧村社（別表神社）','長野県','松本市','長野県松本市大手3-3-20',36.234972,137.970389,1879,null,'http://www.go.tvm.ne.jp/~yohasira/','造化三神と天照大神を祀り「願いごとむすびの神」として知られる。','https://ja.wikipedia.org/wiki/四柱神社','Wikipedia',true,now()),
('kozenji','光前寺','こうぜんじ','temple','天台宗','長野県','駒ヶ根市','長野県駒ヶ根市赤穂29',35.7348472,137.8954389,860,'不動明王','http://www.kozenji.or.jp/','霊犬早太郎伝説と光苔で知られる信濃五大天台寺院の一。','https://ja.wikipedia.org/wiki/光前寺','Wikipedia',true,now()),

-- 岐阜県 -------------------------------------------------------------
('nangu-taisha','南宮大社','なんぐうたいしゃ','shrine','美濃国一宮（旧国幣大社・名神大社）','岐阜県','不破郡垂井町','岐阜県不破郡垂井町宮代峯1734-1',35.360972,136.525306,null,null,'http://www.nangu-san.com/','金山彦命を祀る美濃国一宮。全国の鉱山・金属業の総本宮。','https://ja.wikipedia.org/wiki/南宮大社','Wikipedia',true,now()),
('kegonji-tanigumi','谷汲山華厳寺','たにぐみさんけごんじ','temple','天台宗','岐阜県','揖斐郡揖斐川町','岐阜県揖斐郡揖斐川町谷汲徳積23',35.537194,136.607889,798,'十一面観音','http://kegonji.or.jp/','西国三十三所第三十三番満願の札所。紅葉の名所として知られる。','https://ja.wikipedia.org/wiki/華厳寺','Wikipedia',true,now()),
('inaba-jinja','伊奈波神社','いなばじんじゃ','shrine','美濃国三宮（旧国幣小社・式内社）','岐阜県','岐阜市','岐阜県岐阜市伊奈波通1-1',35.427250,136.770611,null,null,'http://www.inabasan.com','五十瓊敷入彦命を祀る岐阜の総産土神。厄除け・開運で信仰。','https://ja.wikipedia.org/wiki/伊奈波神社','Wikipedia',true,now()),
('chiyoho-inari','千代保稲荷神社','ちよぼいなりじんじゃ','shrine','単立','岐阜県','海津市','岐阜県海津市平田町三郷1980',35.263556,136.646417,null,null,'https://chiyohoinari.or.jp/','「おちょぼさん」の愛称で親しまれる日本三大稲荷の一。','https://ja.wikipedia.org/wiki/千代保稲荷神社','Wikipedia',true,now()),
('hida-ichinomiya-minashi','飛騨一宮水無神社','ひだいちのみやみなしじんじゃ','shrine','飛騨国一宮（旧国幣小社・式内社）','岐阜県','高山市','岐阜県高山市一之宮町5323',36.085306,137.251861,null,null,'http://minashijinjya.or.jp/','位山を神体山とする飛騨国一宮。御歳大神を祀る。','https://ja.wikipedia.org/wiki/飛騨一宮水無神社','Wikipedia',true,now()),
('kogane-jinja-gifu','金神社','こがねじんじゃ','shrine','旧郷社','岐阜県','岐阜市','岐阜県岐阜市金町5-3',35.416722,136.757472,null,null,'https://koganejinjya.com/','金運・財運の神として信仰される岐阜市中心部の古社。','https://ja.wikipedia.org/wiki/金神社_(岐阜市)','Wikipedia',true,now()),

-- 静岡県 -------------------------------------------------------------
('kunozan-toshogu','久能山東照宮','くのうざんとうしょうぐう','shrine','旧別格官幣社（別表神社）','静岡県','静岡市','静岡県静岡市駿河区根古屋390',34.964833,138.467583,1617,null,'https://www.toshogu.or.jp/','徳川家康を最初に祀った東照宮。社殿が国宝。','https://ja.wikipedia.org/wiki/久能山東照宮','Wikipedia',true,now()),
('mishima-taisha','三嶋大社','みしまたいしゃ','shrine','伊豆国一宮（旧官幣大社・名神大社）','静岡県','三島市','静岡県三島市大宮町2-1-5',35.1224056,138.9188306,null,null,null,'伊豆国一宮。大山祇命・事代主神を祀り源頼朝の崇敬を受けた。','https://ja.wikipedia.org/wiki/三嶋大社','Wikipedia',true,now()),
('akihasan-hongu-akiha-jinja','秋葉山本宮秋葉神社','あきはさんほんぐうあきはじんじゃ','shrine','旧県社（別表神社）','静岡県','浜松市','静岡県浜松市天竜区春野町領家328',34.981222,137.865778,709,null,'https://www.akihasanhongu.jp/','火之迦具土大神を祀る全国秋葉信仰の総本宮。火防の神。','https://ja.wikipedia.org/wiki/秋葉山本宮秋葉神社','Wikipedia',true,now()),
('kasuisai','可睡斎','かすいさい','temple','曹洞宗','静岡県','袋井市','静岡県袋井市久能2915-1',34.774833,137.920056,1401,'聖観音','https://www.kasuisai.or.jp/','徳川家康ゆかりの禅刹。秋葉信仰の火防霊場・ぼたん園で知られる。','https://ja.wikipedia.org/wiki/可睡斎','Wikipedia',true,now()),
('okuni-jinja','小國神社','おくにじんじゃ','shrine','遠江国一宮（旧国幣小社・式内社）','静岡県','周智郡森町','静岡県周智郡森町一宮3956-1',34.847500,137.899170,555,null,'https://www.okunijinja.or.jp/','大己貴命を祀る遠江国一宮。本宮山麓の紅葉の名所。','https://ja.wikipedia.org/wiki/小國神社','Wikipedia',true,now()),
('yusanji','油山寺','ゆさんじ','temple','真言宗智山派','静岡県','袋井市','静岡県袋井市村松1',34.785639,137.935830,701,'薬師如来','https://yusanji.jp/','目の霊山として知られる遠州三山の一。三重塔が国重文。','https://ja.wikipedia.org/wiki/油山寺','Wikipedia',true,now()),
('hattasan-soneiji','法多山尊永寺','はったさんそんえいじ','temple','高野山真言宗','静岡県','袋井市','静岡県袋井市豊沢2777',34.737778,137.977222,725,'正観世音菩薩','https://www.hattasan.or.jp/','厄除観音と厄除だんごで知られる遠州三山の一。','https://ja.wikipedia.org/wiki/法多山尊永寺','Wikipedia',true,now()),

-- 愛知県 -------------------------------------------------------------
('toyokawa-inari','豊川稲荷','とよかわいなり','temple','曹洞宗','愛知県','豊川市','愛知県豊川市豊川町1',34.8245167,137.3920111,1441,'千手観音','https://www.toyokawainari.jp/','正式名は妙厳寺。鎮守の吒枳尼真天を祀り商売繁盛で知られる。','https://ja.wikipedia.org/wiki/豊川稲荷','Wikipedia',true,now()),
('osu-kannon','大須観音','おおすかんのん','temple','真言宗智山派','愛知県','名古屋市','愛知県名古屋市中区大須2-21-47',35.1597583,136.8995083,1333,'聖観音','https://www.osu-kannon.jp/','日本三大観音の一。最古写本の古事記を蔵する真福寺。','https://ja.wikipedia.org/wiki/大須観音','Wikipedia',true,now()),
('masumida-jinja','真清田神社','ますみだじんじゃ','shrine','尾張国一宮（旧国幣中社・名神大社）','愛知県','一宮市','愛知県一宮市真清田1-2-1',35.3075556,136.8020861,null,null,'http://www.masumida.or.jp/','天火明命を祀る尾張国一宮。一宮市の名の由来。','https://ja.wikipedia.org/wiki/真清田神社','Wikipedia',true,now()),
('toga-jinja','砥鹿神社','とがじんじゃ','shrine','三河国一宮（旧国幣小社・式内社）','愛知県','豊川市','愛知県豊川市一宮町西垣内2',34.847639,137.421194,null,null,'http://www.togajinja.or.jp/','大己貴命を祀る三河国一宮。本宮山を神体山とする。','https://ja.wikipedia.org/wiki/砥鹿神社','Wikipedia',true,now()),
('kasadera-kannon','笠寺観音','かさでらかんのん','temple','真言宗智山派','愛知県','名古屋市','愛知県名古屋市南区笠寺町上新町83',35.0995417,136.9366917,733,'十一面観音','https://kasadera.jp/','尾張四観音の一。玉照姫伝説で知られる笠覆寺。','https://ja.wikipedia.org/wiki/笠寺観音','Wikipedia',true,now()),
('inuyama-naritasan','犬山成田山','いぬやまなりたさん','temple','真言宗智山派','愛知県','犬山市','愛知県犬山市犬山北白山平5',35.3891000,136.9492306,1953,'不動明王','https://inuyama-naritasan.or.jp/','成田山新勝寺の名古屋別院大聖寺。交通安全祈願で知られる。','https://ja.wikipedia.org/wiki/犬山成田山','Wikipedia',true,now()),
('tsushima-jinja','津島神社','つしまじんじゃ','shrine','旧国幣小社（別表神社）','愛知県','津島市','愛知県津島市神明町1',35.1782361,136.7186472,540,null,'https://tsushimajinja.or.jp/','全国津島・天王社の総本社。素盞嗚尊を祀り牛頭天王信仰で知られる。','https://ja.wikipedia.org/wiki/津島神社','Wikipedia',true,now()),
('okazaki-tenmangu','岡崎天満宮','おかざきてんまんぐう','shrine','旧郷社','愛知県','岡崎市','愛知県岡崎市中町北野1',34.956250,137.179806,1217,null,'http://www.tennjinn.com/','菅原道真を祀る学問の神。受験合格祈願で知られる。','https://ja.wikipedia.org/wiki/岡崎天満宮','Wikipedia',true,now()),
('haritsuna-jinja','針綱神社','はりつなじんじゃ','shrine','旧県社','愛知県','犬山市','愛知県犬山市犬山北古券65-1',35.387331,136.939967,null,null,'http://www.haritsunajinja.com/','犬山城下の総鎮守。安産・子授けの神として信仰され犬山祭で有名。','https://ja.wikipedia.org/wiki/針綱神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ---------------------------------------------------------------------
-- ④ 御祭神/本尊の紐付け（主祭神/本尊=main、配祀=sub）
-- ---------------------------------------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kota-jinja' and d.slug in ('okuninushi'))
or (t.slug='kasugayama-jinja' and d.slug in ('uesugi_kenshin'))
or (t.slug='kokujoji' and d.slug in ('amida_nyorai'))
or (t.slug='zuiryuji' and d.slug in ('shaka_nyorai'))
or (t.slug='oyama-jinja-tateyama' and d.slug in ('izanagi','amenotajikarao'))
or (t.slug='takase-jinja' and d.slug in ('okuninushi'))
or (t.slug='hojozu-hachimangu' and d.slug in ('hachiman'))
or (t.slug='nissekiji' and d.slug in ('fudo_myoo'))
or (t.slug='keta-taisha' and d.slug in ('okuninushi'))
or (t.slug='natadera' and d.slug in ('senju_kannon'))
or (t.slug='oyama-jinja-kanazawa' and d.slug in ('maeda_toshiie'))
or (t.slug='kanazawa-jinja' and d.slug in ('michizane'))
or (t.slug='kehi-jingu' and d.slug in ('ketsumimiko'))
or (t.slug='heisenji-hakusan-jinja' and d.slug in ('izanami'))
or (t.slug='tsurugi-jinja' and d.slug in ('susanoo'))
or (t.slug='shibata-jinja' and d.slug in ('shibata_katsuie'))
or (t.slug='myotsuji' and d.slug in ('yakushi_nyorai'))
or (t.slug='takeda-jinja' and d.slug in ('takeda_shingen'))
or (t.slug='kuonji' and d.slug in ('shaka_nyorai'))
or (t.slug='kitaguchi-hongu-fuji-sengen' and d.slug in ('konohanasakuya'))
or (t.slug='togakushi-jinja' and d.slug in ('amenotajikarao'))
or (t.slug='ikushimatarushima-jinja' and d.slug in ('ikushima','tarushima'))
or (t.slug='hotaka-jinja' and d.slug in ('hotakami'))
or (t.slug='kitamuki-kannon' and d.slug in ('senju_kannon'))
or (t.slug='anrakuji-ueda' and d.slug in ('shaka_nyorai'))
or (t.slug='yohashira-jinja' and d.slug in ('amenominakanushi','takamimusubi','kamimusubi','amaterasu'))
or (t.slug='kozenji' and d.slug in ('fudo_myoo'))
or (t.slug='nangu-taisha' and d.slug in ('kanayamahiko'))
or (t.slug='kegonji-tanigumi' and d.slug in ('juichimen_kannon'))
or (t.slug='inaba-jinja' and d.slug in ('inishikiiribiko'))
or (t.slug='chiyoho-inari' and d.slug in ('ukanomitama'))
or (t.slug='hida-ichinomiya-minashi' and d.slug in ('mitoshi'))
or (t.slug='kogane-jinja-gifu' and d.slug in ('kogane_no_okami'))
or (t.slug='kunozan-toshogu' and d.slug in ('ieyasu'))
or (t.slug='mishima-taisha' and d.slug in ('oyamazumi','kotoshironushi'))
or (t.slug='akihasan-hongu-akiha-jinja' and d.slug in ('hinokagutsuchi'))
or (t.slug='kasuisai' and d.slug in ('sho_kannon'))
or (t.slug='okuni-jinja' and d.slug in ('okuninushi'))
or (t.slug='yusanji' and d.slug in ('yakushi_nyorai'))
or (t.slug='hattasan-soneiji' and d.slug in ('sho_kannon'))
or (t.slug='toyokawa-inari' and d.slug in ('senju_kannon'))
or (t.slug='osu-kannon' and d.slug in ('sho_kannon'))
or (t.slug='masumida-jinja' and d.slug in ('amenohoakari'))
or (t.slug='toga-jinja' and d.slug in ('okuninushi'))
or (t.slug='kasadera-kannon' and d.slug in ('juichimen_kannon'))
or (t.slug='inuyama-naritasan' and d.slug in ('fudo_myoo'))
or (t.slug='tsushima-jinja' and d.slug in ('susanoo'))
or (t.slug='okazaki-tenmangu' and d.slug in ('michizane'))
on conflict do nothing;

-- 配祀（sub）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='kota-jinja' and d.slug in ('nunakawahime','takeminakata','kotoshironushi'))
or (t.slug='kitaguchi-hongu-fuji-sengen' and d.slug in ('ninigi','oyamazumi'))
or (t.slug='hotaka-jinja' and d.slug in ('watatsumi','ninigi'))
or (t.slug='toyokawa-inari' and d.slug in ('dakiniten'))
on conflict do nothing;
