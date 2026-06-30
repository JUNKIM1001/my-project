-- 九州・沖縄 著名社寺バッチ 2巡目（42件）— 出典: 日本語Wikipedia 各記事 infobox（座標・所在地・御祭神/本尊）
-- 担当県: 福岡・佐賀・長崎・熊本・大分・宮崎・鹿児島・沖縄
-- すべてWebFetchでja.wikipediaのinfoboxを裏取り。座標(十進)が確認できた実在・参拝可能社寺のみ。
-- 1巡目(kyushu-okinawa.sql)およびパイロットと重複なし。座標がinfoboxに無い社寺は除外。

-- ① 新規神仏（既存に無いものだけ。tamayorihime/ugayafukiaezu/hikohohodemi/toyotamahime/jimmu/chuai/
--    amenooshihomimi/jingu_kogo/hachiman/sumiyoshi/amaterasu/susanoo/kushinadahime/kotoshironushi/
--    konohanasakuya/watatsumi/takeuchi_sukune/izanagi/izanami/ninigi 等は既存のため再定義しない）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kora_tamatare','高良玉垂命','こうらたまたれのみこと','kami','国津神','{"高良大菩薩"}','その他','高良大社の主祭神。筑後国一宮に祀られ、武運・延命長寿の神として崇敬される。','https://ja.wikipedia.org/wiki/高良大社','Wikipedia',true,now()),
('bato_kannon','馬頭観音','ばとうかんのん','buddha','菩薩','{"馬頭観世音菩薩"}','仏教','六観音の一。憤怒相をとり、衆生の煩悩を断つ。畜生道を救い旅・交通の守護とされる。','https://ja.wikipedia.org/wiki/馬頭観音','Wikipedia',true,now()),
('kunitokotachi','国常立尊','くにのとこたちのみこと','kami','天津神（神世七代）','{"国之常立神"}','記紀','天地開闢に最初に現れた神の一。根源神として八代神社(妙見宮)などに祀られる。','https://ja.wikipedia.org/wiki/クニノトコタチ','Wikipedia',true,now()),
('shirahiwake','白日別命','しらひわけのみこと','kami','国津神','{"筑紫国魂"}','記紀','筑紫国(筑前・筑後)の国魂神。雲仙の温泉神社などに四面宮の神として祀られる。','https://ja.wikipedia.org/wiki/温泉神社_(雲仙市)','Wikipedia',true,now()),
('kego_okami','警固大神','けごのおおかみ','kami','御霊（祓戸）','{"神直毘神","大直毘神","八十枉津日神"}','記紀','神直毘神・大直毘神・八十枉津日神の三柱の総称。災厄を祓い身を守る警固神社の主祭神。','https://ja.wikipedia.org/wiki/警固神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kora_tamatare' and g.slug in ('shobu','choju','yakubarai'))
 or (d.slug='bato_kannon'  and g.slug in ('tabi_anzen','kotsu_anzen','petto'))
 or (d.slug='kunitokotachi' and g.slug in ('kaiun','yakubarai','kanai_anzen'))
 or (d.slug='shirahiwake'  and g.slug in ('byoki_heyu','kaiun','yakubarai'))
 or (d.slug='kego_okami'   and g.slug in ('yakubarai','majo_kekkai','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- 福岡県
('suitengu-kurume','水天宮','すいてんぐう','shrine','旧県社','福岡県','久留米市','福岡県久留米市瀬下町265-1',33.320280,130.496110,1190,null,'https://www.suitengu.net/','全国の水天宮の総本宮。天御中主神・安徳天皇らを祀り、安産・水難除けで名高い。','https://ja.wikipedia.org/wiki/水天宮_(久留米市)','Wikipedia',true,now()),
('kora-taisha','高良大社','こうらたいしゃ','shrine','旧国幣大社・別表神社・筑後国一宮','福岡県','久留米市','福岡県久留米市御井町1',33.301611,130.565889,null,null,'http://www.kourataisya.or.jp/','筑後国一宮。高良山に鎮座し高良玉垂命を祀る。九州最大級の権現造社殿で名高い。','https://ja.wikipedia.org/wiki/高良大社','Wikipedia',true,now()),
('chinkokuji','鎮国寺','ちんこくじ','temple','真言宗御室派','福岡県','宗像市','福岡県宗像市吉田966',33.834583,130.517611,806,'大日如来','https://www.chinkokuji.or.jp/','弘法大師開基と伝わる宗像大社の神宮寺。大日如来を本尊とし「花の寺」で知られる。','https://ja.wikipedia.org/wiki/鎮国寺','Wikipedia',true,now()),
('tooka-ebisu-jinja','十日恵比須神社','とおかえびすじんじゃ','shrine','旧無格社','福岡県','福岡市博多区','福岡県福岡市博多区東公園7-1',33.603890,130.418610,1591,null,'http://www.tooka-ebisu.or.jp/','正月大祭「十日えびす」で博多に賑わいをもたらす商売繁盛の社。事代主命を祀る。','https://ja.wikipedia.org/wiki/十日恵比須神社','Wikipedia',true,now()),
('kego-jinja','警固神社','けごじんじゃ','shrine','旧県社','福岡県','福岡市中央区','福岡県福岡市中央区天神2-2-20',33.587780,130.399917,null,null,'https://www.kegojinja.or.jp/','天神の中心に鎮座する警固大神(三柱)を祀る古社。災厄を祓う守護神として崇敬。','https://ja.wikipedia.org/wiki/警固神社','Wikipedia',true,now()),
('umi-hachimangu','宇美八幡宮','うみはちまんぐう','shrine','旧県社','福岡県','糟屋郡宇美町','福岡県糟屋郡宇美町宇美2-1-1',33.570361,130.508833,574,null,'http://www.umi-hachimangu.or.jp','神功皇后が応神天皇を出産した地と伝わる。安産・子安の信仰で名高い八幡宮。','https://ja.wikipedia.org/wiki/宇美八幡宮','Wikipedia',true,now()),
('furo-gu','風浪宮','ふうろうぐう','shrine','旧県社','福岡県','大川市','福岡県大川市酒見726-1',33.211222,130.386722,192,null,'http://www.ofurousan.jp/','「おふろうさん」と親しまれる古社。少童命三座を祀り、白鷺伝説と石造大鳥居で知られる。','https://ja.wikipedia.org/wiki/風浪宮','Wikipedia',true,now()),
('shinozaki-hachiman-jinja','篠崎八幡神社','しのざきはちまんじんじゃ','shrine','旧県社','福岡県','北九州市小倉北区','福岡県北九州市小倉北区篠崎1-7-1',33.864833,130.869333,584,null,'http://www.shinozakihachimanjinja.or.jp/','小倉の総鎮守として崇敬される八幡宮。応神天皇らを祀り、縁結びの大蛇伝説で知られる。','https://ja.wikipedia.org/wiki/篠崎八幡神社','Wikipedia',true,now()),
('mekari-jinja','和布刈神社','めかりじんじゃ','shrine','旧県社','福岡県','北九州市門司区','福岡県北九州市門司区門司3492',33.960917,130.962278,200,null,'http://mekarijinja.com','関門海峡に臨む古社。旧暦元旦の和布刈神事(ワカメ刈り)で名高い。撞賢木厳之御魂天疎向津媛命を祀る。','https://ja.wikipedia.org/wiki/和布刈神社','Wikipedia',true,now()),
-- 佐賀県
('tajima-jinja','田島神社','たじまじんじゃ','shrine','式内社(名神大社)・旧県社','佐賀県','唐津市','佐賀県唐津市呼子町加部島3965',33.555830,129.890560,null,null,null,'松浦地方最古級の古社で宗像大社の元宮とも。宗像三女神(田島三神)を祀り航海守護で崇敬。','https://ja.wikipedia.org/wiki/田島神社','Wikipedia',true,now()),
('takeo-jinja','武雄神社','たけおじんじゃ','shrine','旧県社','佐賀県','武雄市','佐賀県武雄市武雄町大字武雄5335',33.188167,130.020944,735,null,'http://takeo-jinjya.jp/','御船山麓に鎮座し武内宿禰を祀る。樹齢三千年と伝わる御神木「武雄の大楠」で名高い。','https://ja.wikipedia.org/wiki/武雄神社','Wikipedia',true,now()),
('yoka-jinja','與賀神社','よかじんじゃ','shrine','旧県社','佐賀県','佐賀市','佐賀県佐賀市与賀町2-50',33.248586,130.294797,564,null,'http://yokajinjya.sagafan.jp/','佐賀城下の鎮守。與止日女神(豊玉姫命)を祀り、楼門と三の鳥居が国重文。','https://ja.wikipedia.org/wiki/與賀神社','Wikipedia',true,now()),
('karatsu-jinja','唐津神社','からつじんじゃ','shrine','旧県社','佐賀県','唐津市','佐賀県唐津市南城内3-13',33.452222,129.969556,755,null,'https://www.karatsu-jinja.org/','唐津くんちの曳山行事(ユネスコ無形文化遺産)で名高い唐津の総鎮守。住吉三神を祀る。','https://ja.wikipedia.org/wiki/唐津神社','Wikipedia',true,now()),
-- 長崎県
('unzen-onsen-jinja','温泉神社（雲仙）','うんぜんじんじゃ','shrine','式内論社・旧県社','長崎県','雲仙市','長崎県雲仙市小浜町雲仙319',32.742139,130.261750,701,null,null,'雲仙岳に鎮座する四面宮。白日別命ら筑紫五神を祀り、温泉(雲仙)信仰の中心。','https://ja.wikipedia.org/wiki/温泉神社_(雲仙市)','Wikipedia',true,now()),
('kameoka-jinja-hirado','亀岡神社','かめおかじんじゃ','shrine','旧県社','長崎県','平戸市','長崎県平戸市岩の上町1517',33.368167,129.556944,1631,null,'http://kameoka-j.jp/','平戸城跡に鎮座し平戸藩主松浦氏歴代を祀る。平戸神楽(国重要無形民俗文化財)で知られる。','https://ja.wikipedia.org/wiki/亀岡神社_(平戸市)','Wikipedia',true,now()),
('sanno-jinja-nagasaki','山王神社（長崎）','さんのうじんじゃ','shrine','旧県社','長崎県','長崎市','長崎県長崎市坂本2-5-6',32.767389,129.868722,1638,null,'http://www.sannou-jinjya.jp/','被爆を耐えた「片足鳥居」と二本の大クスで知られる長崎の被爆遺構の社。','https://ja.wikipedia.org/wiki/山王神社_(長崎市)','Wikipedia',true,now()),
('watadzumi-jinja','和多都美神社','わたづみじんじゃ','shrine','式内論社・旧村社','長崎県','対馬市','長崎県対馬市豊玉町仁位和宮55',34.379306,129.311861,null,null,'https://watadzumi.com/','海中に立つ鳥居で名高い対馬の古社。彦火々出見尊と豊玉姫命を祀る海宮伝承の地。','https://ja.wikipedia.org/wiki/和多都美神社','Wikipedia',true,now()),
-- 熊本県
('kengun-jinja','健軍神社','けんぐんじんじゃ','shrine','旧県社','熊本県','熊本市東区','熊本県熊本市東区健軍本町13-1',32.784853,130.755306,558,null,null,'熊本市最古とされる古社。健軍大神(阿蘇神社系の神々)を祀り、楼門と長い参道で知られる。','https://ja.wikipedia.org/wiki/健軍神社','Wikipedia',true,now()),
('kitaoka-jinja','北岡神社','きたおかじんじゃ','shrine','旧県社','熊本県','熊本市西区','熊本県熊本市西区春日1-8-16',32.793111,130.691944,934,null,'http://www.kitaoka-jinja.or.jp/','京都祇園社を勧請した熊本の祇園さん。健速須盞嗚尊・奇稲田姫命を祀り夫婦楠で知られる。','https://ja.wikipedia.org/wiki/北岡神社','Wikipedia',true,now()),
('fujisaki-hachimangu','藤崎八旛宮','ふじさきはちまんぐう','shrine','旧県社・別表神社','熊本県','熊本市中央区','熊本県熊本市中央区井川淵町3-1',32.808289,130.718664,935,null,'http://fujisakigu.or.jp/','肥後一国の総鎮守。応神天皇を祀り、勇壮な「ボシタ祭(秋季例大祭)」で名高い。','https://ja.wikipedia.org/wiki/藤崎八旛宮','Wikipedia',true,now()),
('yatsushiro-jinja','八代神社','やつしろじんじゃ','shrine','旧県社','熊本県','八代市','熊本県八代市妙見町405',32.499840,130.641000,795,null,null,'日本三大妙見の一「妙見宮」。天之御中主神・国常立尊を祀り、妙見祭(ユネスコ無形遺産)で名高い。','https://ja.wikipedia.org/wiki/八代神社','Wikipedia',true,now()),
('ungan-zenji','雲巌禅寺','うんがんぜんじ','temple','曹洞宗','熊本県','熊本市西区','熊本県熊本市西区松尾町平山589',32.819583,130.622833,1351,'四面馬頭観世音菩薩','http://www.iwatoyama.jp/','宮本武蔵が『五輪書』を著した霊巌洞で名高い古刹。岩窟に五百羅漢が並ぶ。','https://ja.wikipedia.org/wiki/雲巌禅寺','Wikipedia',true,now()),
-- 大分県
('futago-ji','両子寺','ふたごじ','temple','天台宗','大分県','国東市','大分県国東市安岐町両子1548',33.573986,131.603258,718,'阿弥陀如来','http://www.futagoji.jp','国東半島の中心・両子山に鎮座する六郷満山の総持院。仁王像と子授け祈願で名高い。','https://ja.wikipedia.org/wiki/両子寺','Wikipedia',true,now()),
('hayasuhime-jinja','早吸日女神社','はやすひめじんじゃ','shrine','式内社・旧県社','大分県','大分市','大分県大分市佐賀関3336-2',33.250111,131.878889,null,null,null,'佐賀関に鎮座する古社。八十枉津日神らを祀り、神武東征ゆかりの蛸断ち祈願で知られる。','https://ja.wikipedia.org/wiki/早吸日女神社','Wikipedia',true,now()),
('komo-jinja','薦神社','こもじんじゃ','shrine','旧県社','大分県','中津市','大分県中津市大字大貞209',33.567278,131.218083,834,null,'https://www.komojinja.jp/','宇佐神宮の祖宮とされ、三角池(御澄池)を御神体とする。国重文の神門で名高い八幡宮。','https://ja.wikipedia.org/wiki/薦神社','Wikipedia',true,now()),
('hachiman-asami-jinja','八幡朝見神社','はちまんあさみじんじゃ','shrine','旧県社','大分県','別府市','大分県別府市朝見2-15-19',33.271556,131.494944,1196,null,'http://www.asami.or.jp','別府温泉の守護神。誉田別命らを祀り、夫婦杉や流鏑馬で知られる別府の総鎮守。','https://ja.wikipedia.org/wiki/八幡朝見神社','Wikipedia',true,now()),
('tennen-ji','天念寺','てんねんじ','temple','天台宗','大分県','豊後高田市','大分県豊後高田市長岩屋1152',33.578583,131.540667,718,'釈迦如来','https://www.onie.jp/','六郷満山の修行の中心。国重要無形民俗文化財「修正鬼会」で名高い。耶馬の岩峰に建つ。','https://ja.wikipedia.org/wiki/天念寺','Wikipedia',true,now()),
-- 宮崎県
('aoshima-jinja','青島神社','あおしまじんじゃ','shrine','旧村社','宮崎県','宮崎市','宮崎県宮崎市青島2-13-1',31.804667,131.474861,null,null,'https://aoshima-jinja.jp/','「鬼の洗濯板」に囲まれた青島に鎮座。彦火火出見命と豊玉姫命を祀り縁結びで名高い。','https://ja.wikipedia.org/wiki/青島神社','Wikipedia',true,now()),
('sano-jinja','狭野神社','さのじんじゃ','shrine','旧県社','宮崎県','西諸県郡高原町','宮崎県西諸県郡高原町大字蒲牟田117',31.908583,130.969889,null,null,'https://sanojinjya.web.fc2.com/','霧島六社権現の一。神武天皇生誕の地と伝わり、神武天皇を祀る杉並木の参道で名高い。','https://ja.wikipedia.org/wiki/狭野神社','Wikipedia',true,now()),
('tsuma-jinja','都萬神社','つまじんじゃ','shrine','式内社・旧県社','宮崎県','西都市','宮崎県西都市大字妻1',32.115306,131.404389,null,null,'https://tsumajinja.webnode.jp/','日向国二宮。木花開耶姫命を祀り、縁結び・安産・酒造の神として崇敬される。','https://ja.wikipedia.org/wiki/都萬神社','Wikipedia',true,now()),
('ikime-jinja','生目神社','いきめじんじゃ','shrine','旧郷社','宮崎県','宮崎市','宮崎県宮崎市大字生目345',31.918278,131.376778,null,null,null,'「日向の生目様」と称される眼病平癒の神。応神天皇と平景清を祀る。','https://ja.wikipedia.org/wiki/生目神社','Wikipedia',true,now()),
('kirishima-higashi-jinja','霧島東神社','きりしまひがしじんじゃ','shrine','旧郷社','宮崎県','西諸県郡高原町','宮崎県西諸県郡高原町大字蒲牟田',31.891833,130.962056,null,null,null,'霧島六社権現の一。御池に臨み伊邪那岐・伊邪那美命を祀る。霧島山の山岳信仰の拠点。','https://ja.wikipedia.org/wiki/霧島東神社','Wikipedia',true,now()),
('eda-jinja-miyazaki','江田神社','えだじんじゃ','shrine','式内社・旧県社','宮崎県','宮崎市','宮崎県宮崎市阿波岐原町字産母127',31.960389,131.464889,null,null,'https://eda-jinnja7.webnode.jp/','伊邪那岐尊を祀る古社。近くの「みそぎ池」は禊祓発祥の地とされ祓いの社として名高い。','https://ja.wikipedia.org/wiki/江田神社_(宮崎市)','Wikipedia',true,now()),
-- 鹿児島県
('kamou-hachiman-jinja','蒲生八幡神社','かもうはちまんじんじゃ','shrine','旧県社','鹿児島県','姶良市','鹿児島県姶良市蒲生町上久徳2259-1',31.765889,130.569694,1123,null,'http://www.kamou80000.com/','日本一の大楠(国特別天然記念物)で名高い。八幡三神を祀る蒲生の総鎮守。','https://ja.wikipedia.org/wiki/蒲生八幡神社_(姶良市)','Wikipedia',true,now()),
('hakozaki-hachiman-izumi','箱崎八幡神社','はこざきはちまんじんじゃ','shrine','旧郷社','鹿児島県','出水市','鹿児島県出水市上知識町46',32.084500,130.341161,null,null,null,'島津家始祖の海難救助の伝承に由来する八幡宮。「日本一の大鈴」と大鳥居で名高い。','https://ja.wikipedia.org/wiki/箱崎八幡神社_(出水市)','Wikipedia',true,now()),
('shibi-jinja-izumi','紫尾神社','しびじんじゃ','shrine','旧郷社','鹿児島県','出水市','鹿児島県出水市高尾野町唐笠木819-1',32.071083,130.299139,null,null,null,'紫尾山を御神体とする古社。瓊瓊杵尊ら日向三代を祀り、温泉(紫尾温泉)信仰でも知られる。','https://ja.wikipedia.org/wiki/紫尾神社_(出水市)','Wikipedia',true,now()),
('itate-hyozu-jinja','射楯兵主神社（釜蓋神社）','いたてひょうずじんじゃ','shrine','旧無格社','鹿児島県','南九州市','鹿児島県南九州市頴娃町別府6827',31.249944,130.416250,null,null,'http://kamafutajinja.com/','「釜蓋神社」の通称で名高い。釜蓋を頭に載せて参拝する独特の祈願と素盞鳴命信仰で知られる。','https://ja.wikipedia.org/wiki/射楯兵主神社_(南九州市)','Wikipedia',true,now()),
('toyotamahime-jinja-chiran','豊玉姫神社','とよたまひめじんじゃ','shrine','旧県社','鹿児島県','南九州市','鹿児島県南九州市知覧町郡16510',31.372972,130.431000,null,null,null,'知覧の総鎮守。豊玉姫命を祀り、夏祭りの精巧な「水車からくり」(県無形民俗文化財)で名高い。','https://ja.wikipedia.org/wiki/豊玉姫神社_(南九州市)','Wikipedia',true,now()),
('udo-jinja-kanoya','鵜戸神社','うどじんじゃ','shrine','旧郷社','鹿児島県','鹿屋市','鹿児島県鹿屋市吾平町麓3574',31.330694,130.897611,null,null,null,'鵜戸六所権現として鸕鷀草葺不合尊ら六柱を祀る。吾平山上陵に近い大隅の古社。','https://ja.wikipedia.org/wiki/鵜戸神社_(鹿屋市)','Wikipedia',true,now()),
-- 沖縄県
('sueyoshigu','末吉宮','すえよしぐう','shrine','旧無格社（琉球八社）','沖縄県','那覇市','沖縄県那覇市首里末吉町1-8',26.230167,127.714056,1450,null,'http://jinjacho.naminouegu.jp/sueyoshi.html','琉球八社の一。熊野三神を祀り、石積みの参道と崖地に建つ社殿で知られる首里の古社。','https://ja.wikipedia.org/wiki/末吉宮','Wikipedia',true,now()),
('amekugu','天久宮','あめくぐう','shrine','旧無格社（琉球八社）','沖縄県','那覇市','沖縄県那覇市泊3-19-3',26.228306,127.682611,1465,null,'http://jinjacho.naminouegu.jp/ameku.html','琉球八社の一。熊野権現(伊弉冉尊ら)を祀る。那覇・泊の高台に鎮座する。','https://ja.wikipedia.org/wiki/天久宮','Wikipedia',true,now()),
('kingu','金武宮','きんぐう','shrine','旧無格社（琉球八社）','沖縄県','国頭郡金武町','沖縄県国頭郡金武町金武222',26.455306,127.921806,null,null,null,'琉球八社の一。鍾乳洞(金武観音寺の日秀洞)内に鎮座する珍しい社。熊野三神を祀る。','https://ja.wikipedia.org/wiki/金武宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（main）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='suitengu-kurume'        and d.slug='amenominakanushi')
 or (t.slug='kora-taisha'           and d.slug='kora_tamatare')
 or (t.slug='chinkokuji'            and d.slug='dainichi_nyorai')
 or (t.slug='tooka-ebisu-jinja'     and d.slug='kotoshironushi')
 or (t.slug='kego-jinja'            and d.slug='kego_okami')
 or (t.slug='umi-hachimangu'        and d.slug='hachiman')
 or (t.slug='furo-gu'               and d.slug='watatsumi')
 or (t.slug='shinozaki-hachiman-jinja' and d.slug='hachiman')
 or (t.slug='mekari-jinja'          and d.slug='amaterasu')
 or (t.slug='tajima-jinja'          and d.slug='ichikishima')
 or (t.slug='takeo-jinja'           and d.slug='takeuchi_sukune')
 or (t.slug='yoka-jinja'            and d.slug='toyotamahime')
 or (t.slug='karatsu-jinja'         and d.slug='sumiyoshi')
 or (t.slug='unzen-onsen-jinja'     and d.slug='shirahiwake')
 or (t.slug='kameoka-jinja-hirado'  and d.slug='hachiman')
 or (t.slug='sanno-jinja-nagasaki'  and d.slug='amaterasu')
 or (t.slug='watadzumi-jinja'       and d.slug='hikohohodemi')
 or (t.slug='kengun-jinja'          and d.slug='takeiwatatsu')
 or (t.slug='kitaoka-jinja'         and d.slug='susanoo')
 or (t.slug='fujisaki-hachimangu'   and d.slug='hachiman')
 or (t.slug='yatsushiro-jinja'      and d.slug='amenominakanushi')
 or (t.slug='ungan-zenji'           and d.slug='bato_kannon')
 or (t.slug='futago-ji'             and d.slug='amida_nyorai')
 or (t.slug='hayasuhime-jinja'      and d.slug='sumiyoshi')
 or (t.slug='komo-jinja'            and d.slug='hachiman')
 or (t.slug='hachiman-asami-jinja'  and d.slug='hachiman')
 or (t.slug='tennen-ji'             and d.slug='shaka_nyorai')
 or (t.slug='aoshima-jinja'         and d.slug='hikohohodemi')
 or (t.slug='sano-jinja'            and d.slug='jimmu')
 or (t.slug='tsuma-jinja'           and d.slug='konohanasakuya')
 or (t.slug='ikime-jinja'           and d.slug='hachiman')
 or (t.slug='kirishima-higashi-jinja' and d.slug='izanagi')
 or (t.slug='eda-jinja-miyazaki'    and d.slug='izanagi')
 or (t.slug='kamou-hachiman-jinja'  and d.slug='hachiman')
 or (t.slug='hakozaki-hachiman-izumi' and d.slug='hachiman')
 or (t.slug='shibi-jinja-izumi'     and d.slug='ninigi')
 or (t.slug='itate-hyozu-jinja'     and d.slug='susanoo')
 or (t.slug='toyotamahime-jinja-chiran' and d.slug='toyotamahime')
 or (t.slug='udo-jinja-kanoya'      and d.slug='ugayafukiaezu')
 or (t.slug='sueyoshigu'            and d.slug='izanami')
 or (t.slug='amekugu'               and d.slug='izanami')
 or (t.slug='kingu'                 and d.slug='izanami')
on conflict do nothing;

-- 配祀（sub）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='suitengu-kurume'        and d.slug='antoku_tenno')
 or (t.slug='kora-taisha'           and d.slug in ('hachiman','sumiyoshi'))
 or (t.slug='tooka-ebisu-jinja'     and d.slug='okuninushi')
 or (t.slug='umi-hachimangu'        and d.slug in ('jingu_kogo','tamayorihime','sumiyoshi','izanagi'))
 or (t.slug='furo-gu'               and d.slug in ('jingu_kogo','sumiyoshi','kora_tamatare'))
 or (t.slug='shinozaki-hachiman-jinja' and d.slug in ('jingu_kogo','chuai','ichikishima','tamayorihime'))
 or (t.slug='mekari-jinja'          and d.slug in ('hikohohodemi','ugayafukiaezu','toyotamahime'))
 or (t.slug='yoka-jinja'            and d.slug='ichikishima')
 or (t.slug='kameoka-jinja-hirado'  and d.slug='amaterasu')
 or (t.slug='kengun-jinja'          and d.slug='amaterasu')
 or (t.slug='kitaoka-jinja'         and d.slug='kushinadahime')
 or (t.slug='yatsushiro-jinja'      and d.slug='kunitokotachi')
 or (t.slug='komo-jinja'            and d.slug='jingu_kogo')
 or (t.slug='hachiman-asami-jinja'  and d.slug in ('jingu_kogo','chuai'))
 or (t.slug='watadzumi-jinja'       and d.slug='toyotamahime')
 or (t.slug='aoshima-jinja'         and d.slug in ('toyotamahime','shiotsuchi'))
 or (t.slug='kirishima-higashi-jinja' and d.slug='izanami')
 or (t.slug='sueyoshigu'            and d.slug='kumano_okami')
 or (t.slug='amekugu'               and d.slug='kumano_okami')
 or (t.slug='kingu'                 and d.slug in ('kumano_okami','kotoshironushi'))
on conflict do nothing;
