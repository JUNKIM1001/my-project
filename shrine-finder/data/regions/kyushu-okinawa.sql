-- 九州・沖縄 著名社寺バッチ（43件）— 出典: 日本語Wikipedia 各記事 infobox（座標・所在地・御祭神/本尊）
-- 担当県: 福岡・佐賀・長崎・熊本・大分・宮崎・鹿児島・沖縄
-- すべてWebFetchでja.wikipediaのinfoboxを裏取り。座標(十進)が確認できた実在・参拝可能社寺のみ。
-- 既存除外(別エージェント/パイロット): 太宰府天満宮,宗像大社,宇佐神宮,阿蘇神社,霧島神宮,波上宮。

-- ① 新規神仏（既存に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{"玉依姫"}','記紀','綿津見神の娘。鸕鷀草葺不合尊の妃で神武天皇の母神。安産・子育ての神。','https://ja.wikipedia.org/wiki/タマヨリビメ_(日向神話)','Wikipedia',true,now()),
('ugayafukiaezu','鸕鷀草葺不合尊','うがやふきあえずのみこと','kami','国津神（日向三代）','{"鵜葺草葺不合命"}','記紀','山幸彦と豊玉姫の子。神武天皇の父神。鵜戸神宮の御祭神。','https://ja.wikipedia.org/wiki/ウガヤフキアエズ','Wikipedia',true,now()),
('hikohohodemi','彦火火出見尊','ひこほほでみのみこと','kami','国津神（日向三代）','{"山幸彦","火遠理命"}','記紀','海幸山幸神話の山幸彦。豊玉姫を娶る。鹿児島神宮の御祭神。','https://ja.wikipedia.org/wiki/ホオリ','Wikipedia',true,now()),
('toyotamahime','豊玉比売命','とよたまひめのみこと','kami','国津神','{"豊玉姫"}','記紀','綿津見神の娘。山幸彦の妃で鸕鷀草葺不合尊の母。海・安産の神。','https://ja.wikipedia.org/wiki/トヨタマビメ','Wikipedia',true,now()),
('jimmu','神武天皇','じんむてんのう','kami','人格神（初代天皇）','{"神日本磐余彦尊","狭野尊"}','記紀','日本神話における初代天皇。日向から東征し橿原で即位したと伝わる。','https://ja.wikipedia.org/wiki/神武天皇','Wikipedia',true,now()),
('chuai','仲哀天皇','ちゅうあいてんのう','kami','人格神（天皇）','{"足仲彦尊"}','記紀','第14代天皇。神功皇后の夫、応神天皇の父。八幡神とともに祀られる。','https://ja.wikipedia.org/wiki/仲哀天皇','Wikipedia',true,now()),
('amenooshihomimi','天忍穂耳命','あめのおしほみみのみこと','kami','天津神','{"正勝吾勝勝速日天忍穂耳尊"}','記紀','天照大神の子でニニギの父。英彦山神宮の主祭神。農業・産業の神。','https://ja.wikipedia.org/wiki/アメノオシホミミ','Wikipedia',true,now()),
('kato_kiyomasa','加藤清正','かとうきよまさ','kami','人格神（武将）','{"清正公"}','その他','肥後熊本藩初代藩主。築城・治水の名手として崇敬され加藤神社に祀られる。','https://ja.wikipedia.org/wiki/加藤清正','Wikipedia',true,now()),
('shimazu_nariakira','島津斉彬','しまづなりあきら','kami','人格神（藩主）','{"照國大明神"}','その他','薩摩藩11代藩主。殖産興業を進めた幕末の名君。照國神社に照國大明神として祀られる。','https://ja.wikipedia.org/wiki/島津斉彬','Wikipedia',true,now()),
('kuroda_josui','黒田孝高','くろだよしたか','kami','人格神（武将）','{"黒田如水","水鏡権現"}','その他','福岡藩祖。豊臣秀吉の軍師として名高い。子の長政とともに光雲神社に祀られる。','https://ja.wikipedia.org/wiki/黒田孝高','Wikipedia',true,now()),
('hosokawa_tadatoshi','細川忠利','ほそかわただとし','kami','人格神（藩主）','{}','その他','肥後熊本藩初代藩主。細川家歴代とともに出水神社に祀られる。','https://ja.wikipedia.org/wiki/細川忠利','Wikipedia',true,now()),
('kanenaga_shinno','懐良親王','かねながしんのう','kami','人格神（皇族）','{"征西将軍宮"}','その他','後醍醐天皇の皇子。南朝の征西将軍として九州で活躍。八代宮に祀られる。','https://ja.wikipedia.org/wiki/懐良親王','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tamayorihime'     and g.slug in ('anzan','kosodate','enmusubi'))
 or (d.slug='ugayafukiaezu'   and g.slug in ('anzan','kosodate','enmusubi','kanai_anzen'))
 or (d.slug='hikohohodemi'    and g.slug in ('kaijo_anzen','suisan_noko','kaiun'))
 or (d.slug='toyotamahime'    and g.slug in ('anzan','kaijo_anzen','enmusubi'))
 or (d.slug='jimmu'           and g.slug in ('kaiun','shobu','shusse'))
 or (d.slug='chuai'           and g.slug in ('shobu','yakubarai','kaiun'))
 or (d.slug='amenooshihomimi' and g.slug in ('shobai','suisan_noko','kaiun'))
 or (d.slug='kato_kiyomasa'   and g.slug in ('shobu','shusse','kaiun'))
 or (d.slug='shimazu_nariakira' and g.slug in ('gakugyo','shusse','kaiun'))
 or (d.slug='kuroda_josui'    and g.slug in ('shobu','shusse','kaiun'))
 or (d.slug='hosokawa_tadatoshi' and g.slug in ('shusse','kaiun','kanai_anzen'))
 or (d.slug='kanenaga_shinno' and g.slug in ('shobu','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- 福岡県
('hakozakigu','筥崎宮','はこざきぐう','shrine','旧官幣大社・別表神社','福岡県','福岡市東区','福岡県福岡市東区箱崎1丁目22番1号',33.614694,130.422889,921,null,'https://www.hakozakigu.or.jp/','日本三大八幡の一。応神天皇を祀り、敵国降伏の扁額と放生会で名高い。','https://ja.wikipedia.org/wiki/筥崎宮','Wikipedia',true,now()),
('sumiyoshi-jinja-fukuoka','住吉神社（福岡）','すみよしじんじゃ','shrine','旧官幣小社・筑前国一宮','福岡県','福岡市博多区','福岡県福岡市博多区住吉3-1-51',33.585750,130.413750,null,null,'https://www.nihondaiichisumiyoshigu.jp/','全国2300余の住吉神社の始源とされる古社。住吉三神を祀り航海守護で崇敬。','https://ja.wikipedia.org/wiki/住吉神社_(福岡市)','Wikipedia',true,now()),
('kushida-jinja','櫛田神社','くしだじんじゃ','shrine','旧県社','福岡県','福岡市博多区','福岡県福岡市博多区上川端町1-41',33.593111,130.410694,757,null,null,'博多総鎮守「お櫛田さん」。博多祇園山笠で知られ大幡主大神らを祀る。','https://ja.wikipedia.org/wiki/櫛田神社_(福岡市)','Wikipedia',true,now()),
('terumo-jinja','光雲神社','てるもじんじゃ','shrine','旧県社','福岡県','福岡市中央区','福岡県福岡市中央区西公園13-1',33.597220,130.376390,1766,null,'https://www.terumojinja.com/','福岡藩祖・黒田孝高と長政を祀る。西公園に鎮座する黒田家ゆかりの社。','https://ja.wikipedia.org/wiki/光雲神社','Wikipedia',true,now()),
('miyajidake-jinja','宮地嶽神社','みやじだけじんじゃ','shrine','旧県社','福岡県','福津市','福岡県福津市宮司元町7-1',33.779944,130.486361,null,null,'https://www.miyajidake.or.jp/','日本最大級の大注連縄と「光の道」で名高い。神功皇后を主祭神とする。','https://ja.wikipedia.org/wiki/宮地嶽神社','Wikipedia',true,now()),
('hikosan-jingu','英彦山神宮','ひこさんじんぐう','shrine','別表神社','福岡県','田川郡添田町','福岡県田川郡添田町英彦山1',33.477944,130.926222,531,null,'http://www.hikosanjingu.or.jp/','日本三大修験の霊山・英彦山に鎮座。天忍穂耳命を祀る山岳信仰の中心。','https://ja.wikipedia.org/wiki/英彦山神宮','Wikipedia',true,now()),
('kamado-jinja','竈門神社','かまどじんじゃ','shrine','旧県社','福岡県','太宰府市','福岡県太宰府市内山883',33.528861,130.552389,673,null,'https://kamadojinja.or.jp/','宝満山に鎮座し玉依姫命を祀る。縁結びの社として知られる。','https://ja.wikipedia.org/wiki/竈門神社','Wikipedia',true,now()),
('zendoji','善導寺','ぜんどうじ','temple','浄土宗（鎮西派大本山）','福岡県','久留米市','福岡県久留米市善導寺町飯田550',33.330028,130.603806,1191,'阿弥陀如来','http://www.zendoji.jp/','聖光（弁長）が開いた浄土宗鎮西派の大本山。阿弥陀如来を本尊とする。','https://ja.wikipedia.org/wiki/善導寺_(久留米市)','Wikipedia',true,now()),
-- 佐賀県
('yutoku-inari-jinja','祐徳稲荷神社','ゆうとくいなりじんじゃ','shrine','単立神社','佐賀県','鹿島市','佐賀県鹿島市古枝乙1855',33.073610,130.108330,1687,null,'https://www.yutokusan.jp/','日本三大稲荷の一。倉稲魂大神を祀り、朱塗りの懸造本殿で知られる。','https://ja.wikipedia.org/wiki/祐徳稲荷神社','Wikipedia',true,now()),
('yodohime-jinja','與止日女神社','よどひめじんじゃ','shrine','式内社・旧県社','佐賀県','佐賀市','佐賀県佐賀市大和町大字川上1',33.326306,130.268330,564,null,null,'肥前国一宮とされる古社。與止日女命を祀り、嘉瀬川のほとりに鎮座する。','https://ja.wikipedia.org/wiki/與止日女神社','Wikipedia',true,now()),
('tozan-jinja','陶山神社','とうざんじんじゃ','shrine','旧村社','佐賀県','西松浦郡有田町','佐賀県西松浦郡有田町大樽2-5-1',33.188861,129.899417,1658,null,null,'有田焼の磁器製鳥居や狛犬で知られる。応神天皇を主祭神とする焼物の神社。','https://ja.wikipedia.org/wiki/陶山神社_(有田町)','Wikipedia',true,now()),
('chiriku-hachimangu','千栗八幡宮','ちりくはちまんぐう','shrine','旧国幣小社・別表神社','佐賀県','三養基郡みやき町','佐賀県三養基郡みやき町大字白壁字千栗3624',33.331417,130.478722,724,null,'https://chirikuhachiman.sakura.ne.jp/','肥前国一宮とされる八幡宮。応神天皇らを祀り、お粥試しの神事で名高い。','https://ja.wikipedia.org/wiki/千栗八幡宮','Wikipedia',true,now()),
('ouo-jinja','大魚神社','おおうおじんじゃ','shrine','旧村社','佐賀県','藤津郡太良町','佐賀県藤津郡太良町大字多良1875-51',33.030194,130.175694,1693,null,null,'有明海の海中に立つ鳥居で知られる。大魚大明神を祀り、干満で姿を変える。','https://ja.wikipedia.org/wiki/大魚神社','Wikipedia',true,now()),
-- 長崎県
('suwa-jinja-nagasaki','鎮西大社諏訪神社','ちんぜいたいしゃすわじんじゃ','shrine','旧国幣中社・別表神社','長崎県','長崎市','長崎県長崎市上西山町18-15',32.754278,129.881917,1555,null,'https://www.osuwasan.jp/','長崎の総鎮守「おすわさん」。建御名方神を祀り、長崎くんちで名高い。','https://ja.wikipedia.org/wiki/諏訪神社_(長崎市)','Wikipedia',true,now()),
('sofukuji','崇福寺','そうふくじ','temple','黄檗宗','長崎県','長崎市','長崎県長崎市鍛冶屋町7-5',32.742250,129.883667,1629,'釈迦如来','https://nagasaki-sofukuji.com/','唐僧超然が開いた唐寺。大雄宝殿と第一峰門は国宝。釈迦如来を本尊とする。','https://ja.wikipedia.org/wiki/崇福寺_(長崎市)','Wikipedia',true,now()),
('kofukuji-nagasaki','興福寺','こうふくじ','temple','黄檗宗','長崎県','長崎市','長崎県長崎市寺町4-32',32.747861,129.883889,1624,'釈迦如来','http://kofukuji.com/','日本最初の黄檗宗寺院「あか寺」。隠元禅師ゆかりの唐寺で大雄宝殿は重文。','https://ja.wikipedia.org/wiki/興福寺_(長崎市)','Wikipedia',true,now()),
('kameyama-hachimangu','亀山八幡宮','かめやまはちまんぐう','shrine','旧県社・別表神社','長崎県','佐世保市','長崎県佐世保市八幡町3-3',33.181883,129.717217,675,null,null,'佐世保唯一の別表神社。応神天皇らを祀り、佐世保くんちで名高い「亀山さん」。','https://ja.wikipedia.org/wiki/亀山八幡宮_(佐世保市)','Wikipedia',true,now()),
-- 熊本県
('honmyoji','本妙寺','ほんみょうじ','temple','日蓮宗（六条門流）','熊本県','熊本市西区','熊本県熊本市西区花園4-13-1',32.816778,130.689556,1585,'十界曼荼羅','http://www.honmyouji.jp/','加藤清正の菩提寺。浄池廟に清正公を祀り、176段の石段と桜で知られる。','https://ja.wikipedia.org/wiki/本妙寺_(熊本市)','Wikipedia',true,now()),
('kato-jinja','加藤神社','かとうじんじゃ','shrine','旧県社','熊本県','熊本市中央区','熊本県熊本市中央区本丸2-1',32.807111,130.705444,1871,null,'http://www.kato-jinja.or.jp/','熊本城内に鎮座し加藤清正を祀る。清正公さんとして親しまれる。','https://ja.wikipedia.org/wiki/加藤神社','Wikipedia',true,now()),
('aoi-aso-jinja','青井阿蘇神社','あおいあそじんじゃ','shrine','旧県社・別表神社','熊本県','人吉市','熊本県人吉市上青井町118',32.213556,130.752861,806,null,'https://www.aoisan.jp','茅葺の社殿群が国宝の古社。阿蘇三神を祀り「青井さん」と慕われる。','https://ja.wikipedia.org/wiki/青井阿蘇神社','Wikipedia',true,now()),
('yatsushiro-gu','八代宮','やつしろぐう','shrine','旧官幣中社・別表神社','熊本県','八代市','熊本県八代市松江城町7-34',32.507780,130.599583,1884,null,null,'建武中興十五社の一。後醍醐天皇の皇子・懐良親王を祀る「将軍さん」。','https://ja.wikipedia.org/wiki/八代宮','Wikipedia',true,now()),
('izumi-jinja-kumamoto','出水神社','いずみじんじゃ','shrine','旧県社','熊本県','熊本市中央区','熊本県熊本市中央区水前寺公園8-1',32.791750,130.734472,1878,null,'http://www.suizenji.or.jp/izumi/01.html','水前寺成趣園内に鎮座し細川家歴代を祀る。能楽でも知られる。','https://ja.wikipedia.org/wiki/出水神社_(熊本市)','Wikipedia',true,now()),
-- 大分県
('fukiji','富貴寺','ふきじ','temple','天台宗','大分県','豊後高田市','大分県豊後高田市田染蕗2395',33.537722,131.528750,718,'阿弥陀如来','https://bungotakada-kanko.jp/spot/fukiji/','九州最古の木造建築・大堂(国宝)で名高い六郷満山の古刹。阿弥陀如来を本尊とする。','https://ja.wikipedia.org/wiki/富貴寺','Wikipedia',true,now()),
('yusuhara-hachimangu','柞原八幡宮','ゆすはらはちまんぐう','shrine','旧国幣小社・別表神社','大分県','大分市','大分県大分市大字八幡987',33.238389,131.551000,830,null,'http://www.oita-yusuhara.com/','豊後国一宮の八幡宮。八幡造の社殿と国天然記念物の大楠で知られる。','https://ja.wikipedia.org/wiki/柞原八幡宮','Wikipedia',true,now()),
('sasamuta-jinja','西寒多神社','ささむたじんじゃ','shrine','式内社・旧国幣中社・別表神社','大分県','大分市','大分県大分市寒田1644',33.172780,131.598389,null,null,null,'豊後国一宮とされる古社。西寒多大神(天照大神ほか)を祀り、藤の名所。','https://ja.wikipedia.org/wiki/西寒多神社','Wikipedia',true,now()),
('rakanji-nakatsu','羅漢寺','らかんじ','temple','曹洞宗','大分県','中津市','大分県中津市本耶馬渓町跡田1501',33.480917,131.186389,1338,'釈迦如来','https://rakanji.jp/','耶馬渓の岩窟に3700余体の石仏が並ぶ。日本最古の五百羅漢で知られる。','https://ja.wikipedia.org/wiki/羅漢寺_(中津市)','Wikipedia',true,now()),
('ankokuji-kunisaki','安国寺','あんこくじ','temple','臨済宗妙心寺派','大分県','国東市','大分県国東市国東町安国寺2245',33.561500,131.719778,1394,null,null,'足利尊氏が全国に建てた安国寺の一。国宝の足利尊氏木像を蔵する六郷満山の禅刹。','https://ja.wikipedia.org/wiki/安国寺_(国東市)','Wikipedia',true,now()),
-- 宮崎県
('udo-jingu','鵜戸神宮','うどじんぐう','shrine','旧官幣大社・別表神社','宮崎県','日南市','宮崎県日南市大字宮浦3232',31.650280,131.466670,null,null,'https://www.udojingu.com/','海蝕洞の中に本殿が鎮座する「下り宮」。鸕鷀草葺不合尊を祀り縁結びで名高い。','https://ja.wikipedia.org/wiki/鵜戸神宮','Wikipedia',true,now()),
('miyazaki-jingu','宮崎神宮','みやざきじんぐう','shrine','旧官幣大社・別表神社','宮崎県','宮崎市','宮崎県宮崎市神宮2-4-1',31.938528,131.423472,null,null,'https://miyazakijingu.or.jp/','神武天皇を祀る宮崎の総社。神武さまとして親しまれ流鏑馬でも知られる。','https://ja.wikipedia.org/wiki/宮崎神宮','Wikipedia',true,now()),
('takachiho-jinja','高千穂神社','たかちほじんじゃ','shrine','旧村社・別表神社','宮崎県','西臼杵郡高千穂町','宮崎県西臼杵郡高千穂町大字三田井1037',32.706444,131.302306,null,null,null,'高千穂郷八十八社の総社。瓊瓊杵尊ら高千穂皇神を祀り夜神楽で名高い。','https://ja.wikipedia.org/wiki/高千穂神社','Wikipedia',true,now()),
('tsuno-jinja','都農神社','つのじんじゃ','shrine','式内社・旧国幣小社・別表神社','宮崎県','児湯郡都農町','宮崎県児湯郡都農町大字川北13294',32.263111,131.558667,null,null,'https://tunojinjya6.webnode.jp','日向国一宮。大己貴命(大国主)を祀り縁結び・商売繁盛で崇敬される。','https://ja.wikipedia.org/wiki/都農神社','Wikipedia',true,now()),
('amanoiwato-jinja','天岩戸神社','あまのいわとじんじゃ','shrine','旧村社','宮崎県','西臼杵郡高千穂町','宮崎県西臼杵郡高千穂町大字岩戸1073-1',32.734440,131.350560,null,null,'https://amanoiwato-jinja.jp/','天岩戸神話の御神体・洞窟を祀る。天照大神を祀り天安河原で知られる。','https://ja.wikipedia.org/wiki/天岩戸神社','Wikipedia',true,now()),
('imayama-daishiji','今山大師寺','いまやまだいしじ','temple','真言宗（単立）','宮崎県','延岡市','宮崎県延岡市山下町2-3998',32.590000,131.666110,1839,'弘法大師','https://www.imayamadaisi.com/','今山の頂に立つ日本最大級の弘法大師銅像で名高い。延岡の春の風物詩・大師祭。','https://ja.wikipedia.org/wiki/今山大師寺','Wikipedia',true,now()),
-- 鹿児島県
('kagoshima-jingu','鹿児島神宮','かごしまじんぐう','shrine','旧官幣大社・別表神社・大隅国一宮','鹿児島県','霧島市','鹿児島県霧島市隼人町内2496',31.753714,130.737861,708,null,'https://kagoshima-jingu.jp/','大隅国一宮。彦火火出見尊(山幸彦)を祀り、初午祭の鈴かけ馬踊りで知られる。','https://ja.wikipedia.org/wiki/鹿児島神宮','Wikipedia',true,now()),
('terukuni-jinja','照國神社','てるくにじんじゃ','shrine','旧別格官幣社・別表神社','鹿児島県','鹿児島市','鹿児島県鹿児島市照国町19-35',31.594806,130.550083,1864,null,'http://www.terukunijinja.jp/','薩摩藩主・島津斉彬を照國大明神として祀る鹿児島の総鎮守。六月燈で名高い。','https://ja.wikipedia.org/wiki/照國神社','Wikipedia',true,now()),
('nitta-jinja','新田神社','にったじんじゃ','shrine','旧国幣中社・別表神社・薩摩国一宮','鹿児島県','薩摩川内市','鹿児島県薩摩川内市宮内町1935-2',31.827639,130.292667,null,null,'http://www.niita-jinja.jp/','薩摩国一宮。瓊瓊杵尊を祀り、可愛山陵(ニニギの陵)を擁する。','https://ja.wikipedia.org/wiki/新田神社_(薩摩川内市)','Wikipedia',true,now()),
('hirakiki-jinja','枚聞神社','ひらききじんじゃ','shrine','式内社・旧国幣小社・薩摩国一宮','鹿児島県','指宿市','鹿児島県指宿市開聞十町1366',31.207639,130.539611,708,null,null,'薩摩国一宮。開聞岳を望む地に大日孁貴命(天照大神)を祀る古社。','https://ja.wikipedia.org/wiki/枚聞神社','Wikipedia',true,now()),
('kagoshima-gokoku-jinja','鹿児島県護国神社','かごしまけんごこくじんじゃ','shrine','護国神社・別表神社','鹿児島県','鹿児島市','鹿児島県鹿児島市草牟田2-60-7',31.609083,130.541694,1868,null,'http://www.k-gokoku.or.jp/','戊辰戦争以降の県出身戦没者7万7千余柱を祀る鹿児島県の護国神社。','https://ja.wikipedia.org/wiki/鹿児島県護国神社','Wikipedia',true,now()),
-- 沖縄県
('futenmagu','普天満宮','ふてんまぐう','shrine','旧無格社（琉球八社）','沖縄県','宜野湾市','沖縄県宜野湾市普天間1-27-10',26.292889,127.777194,null,null,'http://futenmagu.or.jp/','琉球八社の一。熊野権現と琉球古神道神を祀り、洞穴(普天満宮洞穴)で知られる。','https://ja.wikipedia.org/wiki/普天満宮','Wikipedia',true,now()),
('okinogu','沖宮','おきのぐう','shrine','単立（琉球八社）','沖縄県','那覇市','沖縄県那覇市奥武山町44',26.202778,127.677083,null,null,'https://okinogu.or.jp/','琉球八社の一。天照大神を本源とする天受久女龍宮王御神を祀る。奥武山に鎮座。','https://ja.wikipedia.org/wiki/沖宮','Wikipedia',true,now()),
('shikinagu','識名宮','しきなぐう','shrine','旧無格社（琉球八社）','沖縄県','那覇市','沖縄県那覇市繁多川4-1-43',26.210194,127.713417,null,null,'http://sikinagu.com/','琉球八社の一。尚元王が王子の病気平癒を機に創建したと伝わる那覇の古社。','https://ja.wikipedia.org/wiki/識名宮','Wikipedia',true,now()),
('asato-hachimangu','安里八幡宮','あさとはちまんぐう','shrine','旧無格社（琉球八社）','沖縄県','那覇市','沖縄県那覇市安里124',26.221083,127.694944,1457,null,'https://asatohachimangu.net/','琉球八社で唯一の八幡宮。応神天皇らを祀り、尚徳王が創建したと伝わる。','https://ja.wikipedia.org/wiki/安里八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（main）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hakozakigu'              and d.slug='hachiman')
 or (t.slug='sumiyoshi-jinja-fukuoka' and d.slug='sumiyoshi')
 or (t.slug='kushida-jinja'          and d.slug='amaterasu')
 or (t.slug='terumo-jinja'           and d.slug='kuroda_josui')
 or (t.slug='miyajidake-jinja'       and d.slug='jingu_kogo')
 or (t.slug='hikosan-jingu'          and d.slug='amenooshihomimi')
 or (t.slug='kamado-jinja'           and d.slug='tamayorihime')
 or (t.slug='zendoji'                and d.slug='amida_nyorai')
 or (t.slug='yutoku-inari-jinja'     and d.slug='ukanomitama')
 or (t.slug='tozan-jinja'            and d.slug='hachiman')
 or (t.slug='chiriku-hachimangu'     and d.slug='hachiman')
 or (t.slug='suwa-jinja-nagasaki'    and d.slug='takeminakata')
 or (t.slug='sofukuji'               and d.slug='shaka_nyorai')
 or (t.slug='kofukuji-nagasaki'      and d.slug='shaka_nyorai')
 or (t.slug='kato-jinja'             and d.slug='kato_kiyomasa')
 or (t.slug='aoi-aso-jinja'          and d.slug='takeiwatatsu')
 or (t.slug='yatsushiro-gu'          and d.slug='kanenaga_shinno')
 or (t.slug='izumi-jinja-kumamoto'   and d.slug='hosokawa_tadatoshi')
 or (t.slug='fukiji'                 and d.slug='amida_nyorai')
 or (t.slug='yusuhara-hachimangu'    and d.slug='hachiman')
 or (t.slug='sasamuta-jinja'         and d.slug='amaterasu')
 or (t.slug='rakanji-nakatsu'        and d.slug='shaka_nyorai')
 or (t.slug='udo-jingu'              and d.slug='ugayafukiaezu')
 or (t.slug='miyazaki-jingu'         and d.slug='jimmu')
 or (t.slug='takachiho-jinja'        and d.slug='ninigi')
 or (t.slug='tsuno-jinja'            and d.slug='okuninushi')
 or (t.slug='amanoiwato-jinja'       and d.slug='amaterasu')
 or (t.slug='imayama-daishiji'       and d.slug='kobo_daishi')
 or (t.slug='kagoshima-jingu'        and d.slug='hikohohodemi')
 or (t.slug='terukuni-jinja'         and d.slug='shimazu_nariakira')
 or (t.slug='nitta-jinja'            and d.slug='ninigi')
 or (t.slug='hirakiki-jinja'         and d.slug='amaterasu')
 or (t.slug='futenmagu'              and d.slug='izanami')
 or (t.slug='okinogu'                and d.slug='amaterasu')
 or (t.slug='shikinagu'              and d.slug='izanami')
 or (t.slug='kameyama-hachimangu'    and d.slug='hachiman')
 or (t.slug='asato-hachimangu'       and d.slug='hachiman')
on conflict do nothing;

-- 配祀（sub）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='hakozakigu'          and d.slug in ('jingu_kogo','tamayorihime'))
 or (t.slug='kamado-jinja'       and d.slug in ('jingu_kogo','hachiman'))
 or (t.slug='chiriku-hachimangu' and d.slug in ('chuai','jingu_kogo'))
 or (t.slug='yusuhara-hachimangu' and d.slug in ('chuai','jingu_kogo'))
 or (t.slug='kagoshima-jingu'    and d.slug in ('toyotamahime','chuai','jingu_kogo','hachiman'))
 or (t.slug='udo-jingu'          and d.slug in ('amaterasu','jimmu'))
 or (t.slug='miyazaki-jingu'     and d.slug in ('ugayafukiaezu','tamayorihime'))
 or (t.slug='nitta-jinja'        and d.slug in ('amaterasu','amenooshihomimi'))
 or (t.slug='terumo-jinja'       and d.slug='hachiman')
 or (t.slug='kameyama-hachimangu' and d.slug in ('chuai','jingu_kogo'))
 or (t.slug='asato-hachimangu'   and d.slug in ('jingu_kogo','tamayorihime'))
on conflict do nothing;
