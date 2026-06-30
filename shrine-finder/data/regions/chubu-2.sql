-- =====================================================================
-- 御朱印ナビ 社寺データ拡張: 中部地方（2巡目 / 次のティア）
-- 対象県: 新潟,富山,石川,福井,山梨,長野,岐阜,静岡,愛知
-- 出典: ja.wikipedia.org（各社寺記事の infobox から所在地・十進座標・
--        御祭神/本尊・創建・公式サイトを WebFetch で裏取り）
-- 全 46 件（座標が infobox に無い社寺は除外）
-- 1巡目 chubu.sql 収録分とは重複させていない
-- =====================================================================

-- ---------------------------------------------------------------------
-- ① 新規神仏（既存柱・1巡目で定義済みの柱に無いものだけ）
-- ---------------------------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takaokami','高龗神','たかおかみのかみ','kami','国津神','{高龗大神,淤加美神}','記紀','山上の水を司る龍神。降雨・止雨・水利の神。','https://ja.wikipedia.org/wiki/タカオカミ','Wikipedia',true,now()),
('kuraokami','闇龗神','くらおかみのかみ','kami','国津神','{闇龗大神,淤加美神}','記紀','谷間の水を司る龍神。降雨・水利・祈雨の神。','https://ja.wikipedia.org/wiki/タカオカミ','Wikipedia',true,now()),
('keitai_tenno','継体天皇','けいたいてんのう','kami','御霊','{男大迹天皇,袁本杼命}','歴史','越前出身と伝わる第26代天皇。福井ゆかりの国土開発・開運の神。','https://ja.wikipedia.org/wiki/継体天皇','Wikipedia',true,now()),
('okihagi','興萩命','おきはぎのみこと','kami','国津神','{}','記紀','大国主の子孫と伝わる佐久地方の開拓神。新海三社神社主祭神。','https://ja.wikipedia.org/wiki/新海三社神社','Wikipedia',true,now()),
('tatamihiko','多多美彦命','たたみひこのみこと','kami','国津神','{伊富岐大神}','記紀','伊吹山の神とされる美濃の地主神。伊富岐神社主祭神。','https://ja.wikipedia.org/wiki/伊富岐神社','Wikipedia',true,now()),
('itakeru','五十猛命','いたけるのみこと','kami','国津神','{大屋毘古神}','記紀','素盞嗚尊の子。樹木の種を全国に播いた林業・木の神。','https://ja.wikipedia.org/wiki/イソタケル','Wikipedia',true,now()),
('honda_tadakatsu','本多忠勝','ほんだただかつ','kami','御霊','{}','歴史','徳川四天王の一。岡崎ゆかりの武勇・勝運の神。龍城神社に祀られる。','https://ja.wikipedia.org/wiki/本多忠勝','Wikipedia',true,now()),
('oousu','大碓命','おおうすのみこと','kami','御霊','{}','記紀','景行天皇の皇子で日本武尊の兄。猿投山に葬られ猿投神社の主祭神。','https://ja.wikipedia.org/wiki/猿投神社','Wikipedia',true,now()),
('kunitokotachi','国常立尊','くにのとこたちのみこと','kami','天津神','{国之常立神}','記紀','天地開闢に最初に現れた根源神の一。国土の守護神。','https://ja.wikipedia.org/wiki/クニノトコタチ','Wikipedia',true,now()),
('kawakami_gozen','川上御前','かわかみごぜん','kami','国津神','{紙祖神,岡太大神}','伝承','越前和紙の製法を伝えたとされる紙漉きの祖神。岡太神社の祭神。','https://ja.wikipedia.org/wiki/大瀧神社・岡太神社','Wikipedia',true,now()),
('kotonomachihime','己等乃麻知媛命','ことのまちひめのみこと','kami','国津神','{許登能麻遅媛命}','記紀','天児屋命の母神。言葉・ことよさし(言霊)の神。事任八幡宮主祭神。','https://ja.wikipedia.org/wiki/事任八幡宮','Wikipedia',true,now()),
('owari_okunitama','尾張大国霊神','おわりおおくにたまのかみ','kami','国津神','{国府宮大神}','記紀','尾張の国土を司る地主神。国府宮（尾張大國霊神社）主祭神。','https://ja.wikipedia.org/wiki/尾張大国霊神社','Wikipedia',true,now()),
('nitta_yoshisada','新田義貞','にったよしさだ','kami','御霊','{}','歴史','鎌倉幕府を滅ぼした建武中興の武将。越前で戦死。藤島神社主祭神。','https://ja.wikipedia.org/wiki/新田義貞','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ---------------------------------------------------------------------
-- ② 新規神仏の司るご利益（30種から選択）
-- ---------------------------------------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takaokami' and g.slug in ('mizu_amagoi','yakubarai','kaiun'))
or (d.slug='kuraokami' and g.slug in ('mizu_amagoi','yakubarai','kaiun'))
or (d.slug='keitai_tenno' and g.slug in ('kaiun','shusse','shigoto'))
or (d.slug='okihagi' and g.slug in ('kaiun','suisan_noko','kanai_anzen'))
or (d.slug='tatamihiko' and g.slug in ('kaiun','yakubarai','suisan_noko'))
or (d.slug='itakeru' and g.slug in ('suisan_noko','kaijo_anzen','shigoto'))
or (d.slug='honda_tadakatsu' and g.slug in ('shobu','shusse','shigoto'))
or (d.slug='oousu' and g.slug in ('shobu','kaiun','yakubarai'))
or (d.slug='kunitokotachi' and g.slug in ('kaiun','yakubarai','kanai_anzen'))
or (d.slug='kawakami_gozen' and g.slug in ('shobai','shigoto','geino'))
or (d.slug='kotonomachihime' and g.slug in ('gakumon','jouju','kaiun'))
or (d.slug='owari_okunitama' and g.slug in ('kaiun','yakubarai','shobai'))
or (d.slug='nitta_yoshisada' and g.slug in ('shobu','shusse','kaiun'))
on conflict do nothing;

-- ---------------------------------------------------------------------
-- ③ 社寺
-- ---------------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values

-- 新潟県 -------------------------------------------------------------
('hakusan-jinja-niigata','白山神社','はくさんじんじゃ','shrine','旧県社（別表神社）','新潟県','新潟市','新潟県新潟市中央区一番堀通町510',37.915611,139.037333,null,null,'http://niigata-hakusan.com/','新潟の総鎮守。菊理媛大神を祀り縁結びの神として親しまれる。','https://ja.wikipedia.org/wiki/白山神社_(新潟市中央区一番堀通町)','Wikipedia',true,now()),
('nou-hakusan-jinja','能生白山神社','のうはくさんじんじゃ','shrine','旧県社（式内社論社）','新潟県','糸魚川市','新潟県糸魚川市大字能生7239',37.1068806,137.9941667,null,null,'http://nouhakusan.jp/','奴奈川姫を祀る古社。国宝級の本殿と舞楽で知られる。','https://ja.wikipedia.org/wiki/能生白山神社','Wikipedia',true,now()),
('amatsu-jinja-itoigawa','天津神社','あまつじんじゃ','shrine','越後国一宮（旧県社・式内社論社）','新潟県','糸魚川市','新潟県糸魚川市一の宮1-3-34',37.0401500,137.8642250,null,null,null,'瓊々杵尊を祀る越後一宮の一。けんか祭で知られる。','https://ja.wikipedia.org/wiki/天津神社_(糸魚川市)','Wikipedia',true,now()),
('rinsenji-joetsu','林泉寺','りんせんじ','temple','曹洞宗','新潟県','上越市','新潟県上越市中門前1-1-1',37.150000,138.226000,1497,'釈迦如来','http://myhp.joetsu.jp/rinsenji/','長尾・上杉氏の菩提寺。上杉謙信が学んだ寺として知られる。','https://ja.wikipedia.org/wiki/林泉寺_(上越市)','Wikipedia',true,now()),
('untoan','雲洞庵','うんとうあん','temple','曹洞宗','新潟県','南魚沼市','新潟県南魚沼市雲洞660',37.030556,138.890556,null,'釈迦牟尼仏','http://www.untouan.com/','越後一の禅寺と称された名刹。上杉景勝・直江兼続ゆかりの寺。','https://ja.wikipedia.org/wiki/雲洞庵','Wikipedia',true,now()),

-- 富山県 -------------------------------------------------------------
('imizu-jinja','射水神社','いみずじんじゃ','shrine','越中国一宮（旧国幣中社・式内社）','富山県','高岡市','富山県高岡市古城1-1',36.748528,137.021333,null,null,'https://www.imizujinjya.or.jp/','瓊々杵尊を祀る越中国一宮。高岡古城公園内に鎮座する。','https://ja.wikipedia.org/wiki/射水神社','Wikipedia',true,now()),
('hie-jinja-toyama','日枝神社','ひえじんじゃ','shrine','旧県社','富山県','富山市','富山県富山市山王町4-12',36.686611,137.213667,null,null,'https://www.hie.jp/','「富山山王さん」の愛称で親しまれ、山王祭で知られる総鎮守。','https://ja.wikipedia.org/wiki/日枝神社_(富山市)','Wikipedia',true,now()),
('ohota-jinja','於保多神社','おおたじんじゃ','shrine','旧県社','富山県','富山市','富山県富山市於保多町1-32',36.694170,137.225560,1263,null,null,'菅原道真と前田家の祖を祀る富山の天神様。学業成就で信仰。','https://ja.wikipedia.org/wiki/於保多神社','Wikipedia',true,now()),

-- 石川県 -------------------------------------------------------------
('kurikara-fudoji','倶利伽羅不動寺','くりからふどうじ','temple','高野山真言宗','石川県','河北郡津幡町','石川県河北郡津幡町倶利伽羅リ2',36.663528,136.815583,718,'不動明王','https://www.kurikara.or.jp/','源平倶利伽羅合戦の古戦場に建つ日本三不動の一。','https://ja.wikipedia.org/wiki/倶利伽羅不動寺','Wikipedia',true,now()),
('ishikawa-gokoku-jinja','石川護國神社','いしかわごこくじんじゃ','shrine','護国神社（別表神社）','石川県','金沢市','石川県金沢市石引4-18-1',36.5593306,136.6639361,1870,null,'https://www.ishikawagokoku.or.jp/','加賀ゆかりの英霊を祀る護国神社。兼六園東に鎮座する。','https://ja.wikipedia.org/wiki/石川護国神社','Wikipedia',true,now()),
('sugooisobe-jinja','菅生石部神社','すごういそべじんじゃ','shrine','加賀国二宮（旧国幣小社・式内社）','石川県','加賀市','石川県加賀市大聖寺敷地ル乙81',36.313028,136.320806,585,null,'http://www.tenjin.or.tv/','加賀国二宮。竹割まつりで知られる大聖寺の古社。','https://ja.wikipedia.org/wiki/菅生石部神社','Wikipedia',true,now()),
('suzu-jinja','須須神社','すずじんじゃ','shrine','旧県社（式内社）','石川県','珠洲市','石川県珠洲市三崎町寺家4-2',37.498330,137.346670,null,null,null,'能登半島先端に鎮座し瓊々杵尊を祀る奥能登の古社。','https://ja.wikipedia.org/wiki/須須神社','Wikipedia',true,now()),

-- 福井県 -------------------------------------------------------------
('fujishima-jinja','藤島神社','ふじしまじんじゃ','shrine','旧別格官幣社（別表神社）','福井県','福井市','福井県福井市毛矢3-8-21',36.056417,136.210944,1870,null,'https://nitta.or.jp/','新田義貞を主祭神とする建武中興十五社の一。','https://ja.wikipedia.org/wiki/藤島神社','Wikipedia',true,now()),
('keya-kurotatsu-jinja','毛谷黒龍神社','けやくろたつじんじゃ','shrine','旧県社','福井県','福井市','福井県福井市毛矢3-8-1',36.0568361,136.2118861,477,null,'https://www.kurotatu-jinja.jp/','日本古来の四大主祭神の一を祀る黒龍大明神。厄除・開運で信仰。','https://ja.wikipedia.org/wiki/毛谷黒龍神社','Wikipedia',true,now()),
('asuwa-jinja','足羽神社','あすわじんじゃ','shrine','旧県社（式内社）','福井県','福井市','福井県福井市足羽上町108',36.058361,136.209222,null,null,'https://asuwajinja.jp/','継体天皇を祀る福井市最古級の社。しだれ桜の名所。','https://ja.wikipedia.org/wiki/足羽神社','Wikipedia',true,now()),
('otaki-okamoto-jinja','大瀧神社・岡太神社','おおたきおかもとじんじゃ','shrine','旧県社（式内社）','福井県','越前市','福井県越前市大滝町23-10',35.906111,136.252972,719,null,'https://www.echizenwashi.jp/','全国唯一の紙の神「川上御前」を祀る。壮麗な社殿建築で知られる。','https://ja.wikipedia.org/wiki/大瀧神社・岡太神社','Wikipedia',true,now()),

-- 山梨県 -------------------------------------------------------------
('erinji','恵林寺','えりんじ','temple','臨済宗妙心寺派','山梨県','甲州市','山梨県甲州市塩山小屋敷2280',35.729972,138.713833,1330,'釈迦如来','http://www.erinji.jp/','夢窓疎石開山の武田氏の菩提寺。快川和尚の故事で知られる。','https://ja.wikipedia.org/wiki/恵林寺','Wikipedia',true,now()),
('daizenji-koshu','大善寺','だいぜんじ','temple','真言宗智山派','山梨県','甲州市','山梨県甲州市勝沼町勝沼3559',35.655944,138.743167,718,'薬師如来','http://katsunuma.ne.jp/~daizenji/','「ぶどう寺」の名で知られ、本堂(国宝)を持つ古刹。','https://ja.wikipedia.org/wiki/大善寺_(甲州市)','Wikipedia',true,now()),
('kanazakura-jinja','金櫻神社','かなざくらじんじゃ','shrine','旧郷社','山梨県','甲府市','山梨県甲府市御岳町2347',35.769417,138.556056,null,null,'https://kanazakura-shrin.webnode.jp/','金峰山を神体山とし少彦名命を祀る。金運・水晶加工の神。','https://ja.wikipedia.org/wiki/金櫻神社','Wikipedia',true,now()),
('sashideiso-otakeyama-jinja','差出磯大嶽山神社','さしでのいそおおたけさんじんじゃ','shrine','旧村社','山梨県','山梨市','山梨県山梨市南1376',35.697000,138.684361,null,null,'https://daitakesan.jp/','笛吹川に臨む磯に鎮座し大山祇命を祀る景勝の社。','https://ja.wikipedia.org/wiki/差出磯大嶽山神社','Wikipedia',true,now()),
('sakaori-no-miya','酒折宮','さかおりのみや','shrine','旧村社','山梨県','甲府市','山梨県甲府市酒折3-1-13',35.661028,138.596583,null,null,'http://sakaorinomiya.jp/','日本武尊を祀る山梨唯一の記紀記載社。連歌発祥の地。','https://ja.wikipedia.org/wiki/酒折宮','Wikipedia',true,now()),
('asama-jinja-fuefuki','浅間神社','あさまじんじゃ','shrine','甲斐国一宮（旧国幣中社・名神大社論社）','山梨県','笛吹市','山梨県笛吹市一宮町一宮1684',35.6477583,138.6974417,865,null,'http://asamajinja.jp/','木花開耶姫命を祀る甲斐国一宮。桃の名所一宮に鎮座。','https://ja.wikipedia.org/wiki/浅間神社_(笛吹市)','Wikipedia',true,now()),

-- 長野県 -------------------------------------------------------------
('iizuna-jinja','飯縄神社','いいづなじんじゃ','shrine','旧郷社','長野県','長野市','長野県長野市富田380',36.680806,138.168610,null,null,'http://www.iizuna-jinnjya.jp/','飯縄山を神体とする全国飯縄信仰の総本社。','https://ja.wikipedia.org/wiki/飯縄神社','Wikipedia',true,now()),
('shinkai-sansha-jinja','新海三社神社','しんかいさんしゃじんじゃ','shrine','旧県社','長野県','佐久市','長野県佐久市田口宮代2394',36.197472,138.511667,null,null,'http://www.shinkaisansya-jinja.jp/','佐久郡の総社。興萩命を祀り室町期の三重塔(国重文)で知られる。','https://ja.wikipedia.org/wiki/新海三社神社','Wikipedia',true,now()),
('nishina-shinmeigu','仁科神明宮','にしなしんめいぐう','shrine','旧県社（式内社）','長野県','大町市','長野県大町市社宮本1159',36.449944,137.879028,null,null,'https://www.sinmeigu.jp/','天照大神を祀り、現存最古の神明造本殿(国宝)を持つ。','https://ja.wikipedia.org/wiki/仁科神明宮','Wikipedia',true,now()),
('motozenkoji','元善光寺','もとぜんこうじ','temple','天台宗','長野県','飯田市','長野県飯田市座光寺2638',35.534070,137.856520,602,'善光寺如来','https://motozenkoji.jp/','善光寺如来が最初に祀られた地と伝わる古刹。両参りの寺。','https://ja.wikipedia.org/wiki/元善光寺','Wikipedia',true,now()),

-- 岐阜県 -------------------------------------------------------------
('shoboji-gifu-daibutsu','正法寺','しょうぼうじ','temple','黄檗宗','岐阜県','岐阜市','岐阜県岐阜市大仏町8',35.432750,136.771833,1638,'釈迦如来','https://www.gifu-daibutsu.com/','日本三大仏の一「岐阜大仏」で知られる乾漆仏の古刹。','https://ja.wikipedia.org/wiki/正法寺_(岐阜市大仏町)','Wikipedia',true,now()),
('ibuki-jinja','伊富岐神社','いぶきじんじゃ','shrine','美濃国二宮（旧郷社・式内社）','岐阜県','不破郡垂井町','岐阜県不破郡垂井町岩手1484-1',35.377111,136.494806,null,null,null,'伊吹山の神・多多美彦命を祀る美濃国二宮。','https://ja.wikipedia.org/wiki/伊富岐神社','Wikipedia',true,now()),
('tejikarao-jinja-gifu','手力雄神社','てぢからおじんじゃ','shrine','旧郷社','岐阜県','岐阜市','岐阜県岐阜市蔵前6-8-22',35.395694,136.805333,860,null,null,'天手力雄命を祀り、勇壮な火祭で知られる岐阜の古社。','https://ja.wikipedia.org/wiki/手力雄神社_(岐阜市)','Wikipedia',true,now()),
('nagataki-hakusan-jinja','長滝白山神社','ながたきはくさんじんじゃ','shrine','旧県社','岐阜県','郡上市','岐阜県郡上市白鳥町長滝138',35.920944,136.830639,717,null,null,'美濃側白山信仰の中心。長滝の延年(国重要無形民俗)で知られる。','https://ja.wikipedia.org/wiki/長滝白山神社','Wikipedia',true,now()),
('seki-zenkoji','関善光寺','せきぜんこうじ','temple','天台宗','岐阜県','関市','岐阜県関市西日吉町35',35.489389,136.915167,1753,'善光寺如来','http://www.seki-zenkoji.jp/','正式名は宗休寺。日本唯一の卍字戒壇巡りで知られる。','https://ja.wikipedia.org/wiki/関善光寺','Wikipedia',true,now()),

-- 静岡県 -------------------------------------------------------------
('koto-no-mama-hachimangu','事任八幡宮','ことのままはちまんぐう','shrine','遠江国一宮論社（旧県社・式内社）','静岡県','掛川市','静岡県掛川市八坂642',34.798389,138.075417,null,null,'http://kotonomama.org/','言霊の神・己等乃麻知媛命を祀り「願い事のままに叶う」社。','https://ja.wikipedia.org/wiki/事任八幡宮','Wikipedia',true,now()),
('hokoji-hamamatsu','方広寺','ほうこうじ','temple','臨済宗方広寺派（大本山）','静岡県','浜松市','静岡県浜松市浜名区引佐町奥山1577-1',34.848472,137.613972,1371,'釈迦如来','http://www.houkouji.or.jp/','奥山半僧坊で知られる臨済宗方広寺派の大本山。','https://ja.wikipedia.org/wiki/方広寺_(浜松市)','Wikipedia',true,now()),
('ryotanji-hamamatsu','龍潭寺','りょうたんじ','temple','臨済宗妙心寺派','静岡県','浜松市','静岡県浜松市浜名区引佐町井伊谷1989',34.828639,137.668139,733,'虚空蔵菩薩','https://www.ryotanji.com/','井伊氏の菩提寺。小堀遠州作の名勝庭園で知られる。','https://ja.wikipedia.org/wiki/龍潭寺_(浜松市)','Wikipedia',true,now()),
('izusan-jinja','伊豆山神社','いずさんじんじゃ','shrine','旧国幣小社（別表神社）','静岡県','熱海市','静岡県熱海市伊豆山708-1',35.115528,139.082417,null,null,'https://izusanjinjya.jp/','源頼朝と北条政子ゆかりの社。全国伊豆山神社の総本社。','https://ja.wikipedia.org/wiki/伊豆山神社','Wikipedia',true,now()),
('kinomiya-jinja','来宮神社','きのみやじんじゃ','shrine','旧村社','静岡県','熱海市','静岡県熱海市西山町43-1',35.100500,139.067806,710,null,'http://www.kinomiya.or.jp/','樹齢二千年の大楠で知られる熱海の来宮さん。','https://ja.wikipedia.org/wiki/来宮神社','Wikipedia',true,now()),

-- 愛知県 -------------------------------------------------------------
('owari-okunitama-jinja','尾張大國霊神社','おわりおおくにたまじんじゃ','shrine','尾張国総社（旧国幣小社）','愛知県','稲沢市','愛知県稲沢市国府宮1-1-1',35.256110,136.805139,null,null,'https://www.konomiya.or.jp/','「国府宮」の名で知られる尾張総社。はだか祭で有名。','https://ja.wikipedia.org/wiki/尾張大国霊神社','Wikipedia',true,now()),
('chiryu-jinja','知立神社','ちりゅうじんじゃ','shrine','三河国二宮（旧県社・式内社）','愛知県','知立市','愛知県知立市西町神田12',35.013111,137.041110,null,null,'http://chiryu-jinja.com/','三河国二宮。マムシ除けの神として信仰され花しょうぶで有名。','https://ja.wikipedia.org/wiki/知立神社','Wikipedia',true,now()),
('koshoji-nagoya','興正寺','こうしょうじ','temple','高野山真言宗（別格本山）','愛知県','名古屋市','愛知県名古屋市昭和区八事本町78',35.140667,136.9625194,1688,'大日如来','https://www.koushoji.or.jp/','八事山と号する名古屋の真言道場。五重塔(国重文)で知られる。','https://ja.wikipedia.org/wiki/興正寺_(名古屋市)','Wikipedia',true,now()),
('jimokuji','甚目寺','じもくじ','temple','真言宗智山派','愛知県','あま市','愛知県あま市甚目寺東門前24',35.195139,136.822889,597,'聖観音','http://www.jimokuji.or.jp/','尾張四観音の一。仁王門・三重塔(国重文)を持つ古刹。','https://ja.wikipedia.org/wiki/甚目寺','Wikipedia',true,now()),
('arako-kannon','荒子観音','あらこかんのん','temple','天台宗','愛知県','名古屋市','愛知県名古屋市中川区荒子町宮窓138',35.1365694,136.8582250,729,'聖観音','http://www.arakokannon.com/','尾張四観音の一。円空仏千二百体と名古屋最古の多宝塔で知られる。','https://ja.wikipedia.org/wiki/荒子観音','Wikipedia',true,now()),
('tatsuki-jinja','龍城神社','たつきじんじゃ','shrine','旧県社','愛知県','岡崎市','愛知県岡崎市康生町561',34.956110,137.159170,null,null,'http://home1.catvmics.ne.jp/~tatuki/','岡崎城内に鎮座し徳川家康と本多忠勝を祀る。','https://ja.wikipedia.org/wiki/龍城神社','Wikipedia',true,now()),
('sanage-jinja','猿投神社','さなげじんじゃ','shrine','三河国三宮（旧県社・式内社）','愛知県','豊田市','愛知県豊田市猿投町大城5',35.1752833,137.1774611,null,null,'http://sanagejinja.or.jp/','猿投山を神体とし大碓命を祀る三河三宮。','https://ja.wikipedia.org/wiki/猿投神社','Wikipedia',true,now()),
('iga-hachimangu','伊賀八幡宮','いがはちまんぐう','shrine','旧県社','愛知県','岡崎市','愛知県岡崎市伊賀町東郷中86',34.9714306,137.1646722,1470,null,'http://www.igahachimanguu.com/','松平・徳川家の氏神。家光造営の社殿群(国重文)で知られる。','https://ja.wikipedia.org/wiki/伊賀八幡宮','Wikipedia',true,now()),
('wakeoe-jinja','別小江神社','わけおえじんじゃ','shrine','旧郷社（式内社論社）','愛知県','名古屋市','愛知県名古屋市北区安井4-14-14',35.210389,136.921000,null,null,'http://wakeoe.com/','安井村の産土神。多彩な御朱印で知られる名古屋北区の古社。','https://ja.wikipedia.org/wiki/別小江神社','Wikipedia',true,now()),
('rokusho-jinja-okazaki','六所神社','ろくしょじんじゃ','shrine','旧県社','愛知県','岡崎市','愛知県岡崎市明大寺町耳取44',34.949417,137.168417,null,null,'https://www.rokushojinja.jp/','徳川家産土神。家光造営の極彩色社殿(国重文)で知られる。','https://ja.wikipedia.org/wiki/六所神社_(岡崎市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ---------------------------------------------------------------------
-- ④ 御祭神/本尊の紐付け（主祭神/本尊=main、配祀=sub）
-- ---------------------------------------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hakusan-jinja-niigata' and d.slug in ('kukurihime'))
or (t.slug='nou-hakusan-jinja' and d.slug in ('nunakawahime'))
or (t.slug='amatsu-jinja-itoigawa' and d.slug in ('ninigi'))
or (t.slug='rinsenji-joetsu' and d.slug in ('shaka_nyorai'))
or (t.slug='untoan' and d.slug in ('shaka_nyorai'))
or (t.slug='imizu-jinja' and d.slug in ('ninigi'))
or (t.slug='hie-jinja-toyama' and d.slug in ('oyamakui','omononushi'))
or (t.slug='ohota-jinja' and d.slug in ('michizane'))
or (t.slug='kurikara-fudoji' and d.slug in ('fudo_myoo'))
or (t.slug='ishikawa-gokoku-jinja' and d.slug in ('yamatotakeru'))
or (t.slug='sugooisobe-jinja' and d.slug in ('ninigi','toyotamahime','ugayafukiaezu'))
or (t.slug='suzu-jinja' and d.slug in ('ninigi','konohanasakuya'))
or (t.slug='fujishima-jinja' and d.slug in ('nitta_yoshisada'))
or (t.slug='keya-kurotatsu-jinja' and d.slug in ('takaokami','kuraokami','keitai_tenno'))
or (t.slug='asuwa-jinja' and d.slug in ('keitai_tenno'))
or (t.slug='otaki-okamoto-jinja' and d.slug in ('kunitokotachi','izanagi','kawakami_gozen'))
or (t.slug='erinji' and d.slug in ('shaka_nyorai'))
or (t.slug='daizenji-koshu' and d.slug in ('yakushi_nyorai'))
or (t.slug='kanazakura-jinja' and d.slug in ('sukunabikona','okuninushi'))
or (t.slug='sashideiso-otakeyama-jinja' and d.slug in ('oyamatsumi'))
or (t.slug='sakaori-no-miya' and d.slug in ('yamatotakeru'))
or (t.slug='asama-jinja-fuefuki' and d.slug in ('konohanasakuya'))
or (t.slug='iizuna-jinja' and d.slug in ('ukanomitama'))
or (t.slug='shinkai-sansha-jinja' and d.slug in ('okihagi','takeminakata'))
or (t.slug='nishina-shinmeigu' and d.slug in ('amaterasu'))
or (t.slug='motozenkoji' and d.slug in ('amida_nyorai'))
or (t.slug='shoboji-gifu-daibutsu' and d.slug in ('shaka_nyorai'))
or (t.slug='ibuki-jinja' and d.slug in ('tatamihiko'))
or (t.slug='tejikarao-jinja-gifu' and d.slug in ('amenotajikarao'))
or (t.slug='nagataki-hakusan-jinja' and d.slug in ('kukurihime','izanagi','izanami'))
or (t.slug='seki-zenkoji' and d.slug in ('amida_nyorai'))
or (t.slug='koto-no-mama-hachimangu' and d.slug in ('kotonomachihime'))
or (t.slug='hokoji-hamamatsu' and d.slug in ('shaka_nyorai'))
or (t.slug='ryotanji-hamamatsu' and d.slug in ('kokuzo_bosatsu'))
or (t.slug='izusan-jinja' and d.slug in ('ninigi'))
or (t.slug='kinomiya-jinja' and d.slug in ('yamatotakeru','itakeru','omononushi'))
or (t.slug='owari-okunitama-jinja' and d.slug in ('owari_okunitama'))
or (t.slug='chiryu-jinja' and d.slug in ('ugayafukiaezu','hikohohodemi','tamayorihime','jimmu'))
or (t.slug='koshoji-nagoya' and d.slug in ('dainichi_nyorai'))
or (t.slug='jimokuji' and d.slug in ('sho_kannon'))
or (t.slug='arako-kannon' and d.slug in ('sho_kannon'))
or (t.slug='tatsuki-jinja' and d.slug in ('ieyasu','honda_tadakatsu'))
or (t.slug='sanage-jinja' and d.slug in ('oousu'))
or (t.slug='iga-hachimangu' and d.slug in ('hachiman'))
or (t.slug='wakeoe-jinja' and d.slug in ('izanagi','izanami'))
or (t.slug='rokusho-jinja-okazaki' and d.slug in ('sarutahiko','shiotsuchi'))
on conflict do nothing;

-- 配祀（sub）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='hakusan-jinja-niigata' and d.slug in ('izanagi','izanami'))
or (t.slug='nou-hakusan-jinja' and d.slug in ('izanagi','omononushi'))
or (t.slug='amatsu-jinja-itoigawa' and d.slug in ('amenokoyane','amenofutodama'))
or (t.slug='sugooisobe-jinja' and d.slug in ('sukunabikona'))
or (t.slug='koto-no-mama-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
or (t.slug='izusan-jinja' and d.slug in ('hinokagutsuchi'))
or (t.slug='wakeoe-jinja' and d.slug in ('amaterasu','susanoo','tsukuyomi'))
or (t.slug='iga-hachimangu' and d.slug in ('jingu_kogo','ieyasu'))
on conflict do nothing;
