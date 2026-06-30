-- ============================================================
-- 御朱印ナビ 地域データ: 北海道・東北
-- 対象県: 北海道, 青森, 岩手, 宮城, 秋田, 山形, 福島
-- 全件 ja.wikipedia.org の infobox を WebFetch で裏取り（十進緯度経度あり）
-- 既存除外: hokkaido-jingu(北海道神宮), chusonji(中尊寺), osaki-hachimangu(大崎八幡宮)
-- ============================================================

-- ───────────────────────── ① 新規神仏 ─────────────────────────
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shiotsuchi','塩土老翁神','しおつちのおじ','kami','国津神','{}','記紀','製塩と航海・道案内の神。鹽竈神社の主祭神。','https://ja.wikipedia.org/wiki/シオツチノオジ','Wikipedia',true,now()),
('shiwahiko','志波彦大神','しわひこのおおかみ','kami','国津神','{}','延喜式','陸奥国の式内名神大社・志波彦神社の祭神。農耕・国土開発の神。','https://ja.wikipedia.org/wiki/志波彦神社','Wikipedia',true,now()),
('ideha','伊氐波神','いではのかみ','kami','国津神','{}','その他','出羽国の地主神。出羽神社（羽黒山）の祭神。','https://ja.wikipedia.org/wiki/出羽三山','Wikipedia',true,now()),
('oohiko','大毘古命','おおびこのみこと','kami','国津神','{大彦命}','記紀','四道将軍の一人。北陸・東北平定の伝承を持つ。','https://ja.wikipedia.org/wiki/オオビコ','Wikipedia',true,now()),
('kanayamahiko','金山毘古神','かなやまひこのかみ','kami','国津神','{金山彦神}','記紀','鉱山・金属・鍛冶の神。金華山黄金山神社の祭神。','https://ja.wikipedia.org/wiki/カナヤマヒコ','Wikipedia',true,now()),
('toyouke','豊受大神','とようけのおおかみ','kami','天津神','{豊受比売命,豊宇気姫命}','記紀','衣食住・産業の守護神。伊勢神宮外宮の祭神。','https://ja.wikipedia.org/wiki/トヨウケビメ','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','大国主の子。託宣・商売・漁業の神。恵比寿と習合。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('tsukuyomi','月夜見命','つくよみのみこと','kami','天津神','{月読命}','記紀','月を司る神。天照大神の弟。','https://ja.wikipedia.org/wiki/ツクヨミ','Wikipedia',true,now()),
('ugayafukiaezu','鵜葺草葺不合命','うがやふきあえずのみこと','kami','天津神','{}','記紀','神武天皇の父。海と安産の神徳を持つ。','https://ja.wikipedia.org/wiki/ウガヤフキアエズ','Wikipedia',true,now()),
('toyotamahime','豊玉姫命','とよたまひめのみこと','kami','国津神','{}','記紀','海神の娘。安産・縁結びの神。','https://ja.wikipedia.org/wiki/トヨタマビメ','Wikipedia',true,now()),
('oyamatsumi','大山津見神','おおやまつみのかみ','kami','国津神','{大山祇神}','記紀','山を司る神。山林・酒造の守護。','https://ja.wikipedia.org/wiki/オオヤマツミ','Wikipedia',true,now()),
('jimmu','神倭伊波礼彦命','かむやまといわれびこのみこと','kami','天津神','{神武天皇}','記紀','初代天皇。建国・開拓の象徴。','https://ja.wikipedia.org/wiki/神武天皇','Wikipedia',true,now()),
('uesugi_kenshin','上杉謙信','うえすぎけんしん','kami','御霊','{}','史実','戦国武将。米沢・上杉神社の祭神。武運・勝負の神。','https://ja.wikipedia.org/wiki/上杉謙信','Wikipedia',true,now()),
('matsudaira_sadanobu','松平定信','まつだいらさだのぶ','kami','御霊','{守国大明神}','史実','白河藩主・寛政の改革を行った老中。南湖神社の祭神。','https://ja.wikipedia.org/wiki/松平定信','Wikipedia',true,now()),
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{}','仏教','六道で衆生を救う菩薩。恐山菩提寺の本尊。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now()),
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','仏教','無限の智慧と福徳を蔵する菩薩。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now()),
('nyoirin_kannon','如意輪観音','にょいりんかんのん','buddha','菩薩','{}','仏教','如意宝珠と法輪で衆生の願いを叶える観音。','https://ja.wikipedia.org/wiki/如意輪観音','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{}','仏教','十一の顔であらゆる方角の衆生を救う観音。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ② 新規神仏の司るご利益 ─────────────────────────
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shiotsuchi'          and g.slug in ('kaijo_anzen','anzan','tabi_anzen'))
or (d.slug='shiwahiko'           and g.slug in ('suisan_noko','kaiun'))
or (d.slug='ideha'               and g.slug in ('kaiun','yakubarai'))
or (d.slug='oohiko'              and g.slug in ('shobu','yakubarai'))
or (d.slug='kanayamahiko'        and g.slug in ('shobai','kinun','shigoto'))
or (d.slug='toyouke'             and g.slug in ('shobai','suisan_noko','kanai_anzen'))
or (d.slug='kotoshironushi'      and g.slug in ('shobai','suisan_noko','kaiun'))
or (d.slug='tsukuyomi'           and g.slug in ('kaiun','yakubarai'))
or (d.slug='ugayafukiaezu'       and g.slug in ('anzan','kosodate'))
or (d.slug='toyotamahime'        and g.slug in ('anzan','enmusubi'))
or (d.slug='oyamatsumi'          and g.slug in ('suisan_noko','shobai','yakubarai'))
or (d.slug='jimmu'               and g.slug in ('kaiun','shobu'))
or (d.slug='uesugi_kenshin'      and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='matsudaira_sadanobu' and g.slug in ('gakumon','shusse'))
or (d.slug='jizo_bosatsu'        and g.slug in ('kosodate','byoki_heyu','choju'))
or (d.slug='kokuzo_bosatsu'      and g.slug in ('gakugyo','gakumon','kaiun'))
or (d.slug='nyoirin_kannon'      and g.slug in ('jouju','enmusubi','anzan'))
or (d.slug='juichimen_kannon'    and g.slug in ('byoki_heyu','yakubarai','jouju'))
on conflict do nothing;

-- ───────────────────────── ③ 社寺 ─────────────────────────
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values

-- ── 北海道 ──
('hakodate-hachimangu','函館八幡宮','はこだてはちまんぐう','shrine','八幡神（旧国幣中社・別表神社）','北海道','函館市','北海道函館市谷地頭町2-5',41.753861,140.709861,1445,null,null,'文安2年創建と伝わる函館の総鎮守。品陀和気命を祀る。','https://ja.wikipedia.org/wiki/函館八幡宮','Wikipedia',true,now()),
('tarumaesan-jinja','樽前山神社','たるまえさんじんじゃ','shrine','山岳信仰','北海道','苫小牧市','北海道苫小牧市字高丘6-49',42.660886,141.604108,null,null,'http://www.tarumaesanjinja.com/','樽前山を御神体とし大山津見神らを祀る苫小牧の鎮守。','https://ja.wikipedia.org/wiki/樽前山神社','Wikipedia',true,now()),
('kamikawa-jinja','上川神社','かみかわじんじゃ','shrine','神明系','北海道','旭川市','北海道旭川市神楽岡公園2-1',43.752422,142.364728,1893,null,'https://www.kamikawajinja.com/','上川盆地開拓の鎮守として明治26年創建。天照大神らを祀る。','https://ja.wikipedia.org/wiki/上川神社','Wikipedia',true,now()),
('obihiro-jinja','帯廣神社','おびひろじんじゃ','shrine','開拓神','北海道','帯広市','北海道帯広市東3条南2丁目1番地',42.932189,143.208772,1910,null,'http://www.obihirojinja.jp/','十勝開拓の鎮守。大国主神ら開拓三神を祀る。','https://ja.wikipedia.org/wiki/帯廣神社','Wikipedia',true,now()),
('hokkaido-gokoku-jinja','北海道護國神社','ほっかいどうごこくじんじゃ','shrine','護国神社','北海道','旭川市','北海道旭川市花咲町1丁目2282番2',43.788167,142.366750,1902,null,'http://hokkaido-gokoku.org/','北海道・樺太ゆかりの戦没者を祀る護国神社。','https://ja.wikipedia.org/wiki/北海道護國神社','Wikipedia',true,now()),
('nishino-jinja','西野神社','にしのじんじゃ','shrine','八幡系','北海道','札幌市','北海道札幌市西区平和1条3丁目1-1',43.059722,141.260556,1885,null,'http://nishinojinja.or.jp/','豊玉姫命・譽田別命らを祀る札幌西区の鎮守。縁結びで知られる。','https://ja.wikipedia.org/wiki/西野神社','Wikipedia',true,now()),

-- ── 青森 ──
('uto-jinja','善知鳥神社','うとうじんじゃ','shrine','宗像三女神','青森県','青森市','青森県青森市安方2-7-18',40.826694,140.742444,null,null,'https://utojinja.sakura.ne.jp/','青森発祥の地とされる総鎮守。宗像三女神を祀る。','https://ja.wikipedia.org/wiki/善知鳥神社','Wikipedia',true,now()),
('iwakiyama-jinja','岩木山神社','いわきやまじんじゃ','shrine','山岳信仰（旧国幣小社）','青森県','弘前市','青森県弘前市百沢字寺沢27',40.621889,140.340611,780,null,'https://iwakiyamajinja.or.jp/','岩木山を御神体とする津軽の総鎮守。「お岩木さま」。','https://ja.wikipedia.org/wiki/岩木山神社','Wikipedia',true,now()),
('kushihiki-hachimangu','櫛引八幡宮','くしひきはちまんぐう','shrine','八幡神（別表神社）','青森県','八戸市','青森県八戸市八幡字八幡丁3-2',40.490333,141.434778,1191,null,'http://www.kushihikihachimangu.com/','南部氏の総鎮守。国宝の赤糸威鎧で名高い。','https://ja.wikipedia.org/wiki/櫛引八幡宮','Wikipedia',true,now()),
('takayama-inari-jinja','高山稲荷神社','たかやまいなりじんじゃ','shrine','稲荷系','青森県','つがる市','青森県つがる市牛潟町鷲野沢147-1',40.938500,140.312389,null,null,'https://takayamainari.jp/','連なる千本鳥居で知られる津軽の稲荷社。','https://ja.wikipedia.org/wiki/高山稲荷神社','Wikipedia',true,now()),
('osorezan-bodaiji','恐山菩提寺','おそれざんぼだいじ','temple','曹洞宗','青森県','むつ市','青森県むつ市田名部字宇曽利山3-2',41.279000,141.120000,862,'地蔵菩薩','https://osorezan.or.jp/','日本三大霊場の一つ。イタコの口寄せで知られる。','https://ja.wikipedia.org/wiki/恐山','Wikipedia',true,now()),
('kabushima-jinja','蕪嶋神社','かぶしまじんじゃ','shrine','宗像三女神','青森県','八戸市','青森県八戸市鮫町字鮫56-2',40.539072,141.557486,1296,null,'https://kabushima.com/','ウミネコ繁殖地として国の天然記念物。市杵島姫命を祀る。','https://ja.wikipedia.org/wiki/蕪嶋神社','Wikipedia',true,now()),
('engakuji-fukaura','円覚寺','えんかくじ','temple','真言宗醍醐派','青森県','西津軽郡深浦町','青森県西津軽郡深浦町大字深浦字浜町275',40.642250,139.922861,807,'十一面観音','http://www.engakuji.jp/','大同2年開創と伝わる深浦の古刹。海上安全の信仰を集める。','https://ja.wikipedia.org/wiki/円覚寺_(青森県深浦町)','Wikipedia',true,now()),
('hirosaki-toshogu','弘前東照宮','ひろさきとうしょうぐう','shrine','東照宮','青森県','弘前市','青森県弘前市笹森町38',40.608083,140.474500,1617,null,null,'弘前藩が勧請した東照宮。徳川家康・天照大神を祀る。','https://ja.wikipedia.org/wiki/弘前東照宮','Wikipedia',true,now()),

-- ── 岩手 ──
('motsuji','毛越寺','もうつうじ','temple','天台宗','岩手県','西磐井郡平泉町','岩手県西磐井郡平泉町平泉字大沢58',38.987220,141.107500,850,'薬師如来','https://www.motsuji.or.jp/','平泉の世界遺産。浄土庭園で名高い天台宗の古刹。','https://ja.wikipedia.org/wiki/毛越寺','Wikipedia',true,now()),
('morioka-hachimangu','盛岡八幡宮','もりおかはちまんぐう','shrine','八幡神','岩手県','盛岡市','岩手県盛岡市八幡町13-1',39.695417,141.163917,1062,null,'https://www.morioka8man.jp','盛岡藩の総鎮守。チャグチャグ馬コや流鏑馬で知られる。','https://ja.wikipedia.org/wiki/盛岡八幡宮','Wikipedia',true,now()),
('komagata-jinja','駒形神社','こまがたじんじゃ','shrine','駒形大神（旧国幣小社）','岩手県','奥州市','岩手県奥州市水沢中上野町1-83',39.136528,141.138083,null,null,'http://www.rnac.ne.jp/~komagata/','駒ヶ岳を奥宮とする陸中一宮。駒形大神を祀る。','https://ja.wikipedia.org/wiki/駒形神社','Wikipedia',true,now()),
('shoboji-oshu','正法寺','しょうぼうじ','temple','曹洞宗','岩手県','奥州市','岩手県奥州市水沢黒石町字正法寺129',39.068083,141.224917,1348,'如意輪観音','https://shoboji.net/','日本最大級の茅葺屋根本堂を持つ奥州の曹洞宗古刹。','https://ja.wikipedia.org/wiki/正法寺_(奥州市)','Wikipedia',true,now()),
('tendaiji','天台寺','てんだいじ','temple','天台宗','岩手県','二戸市','岩手県二戸市浄法寺町御山久保33-1',40.198333,141.186556,728,'聖観音','http://www.tendaiji.or.jp/','八葉山に立つ古刹。瀬戸内寂聴の住職で知られた。','https://ja.wikipedia.org/wiki/天台寺','Wikipedia',true,now()),

-- ── 宮城 ──
('shiogama-jinja','鹽竈神社','しおがまじんじゃ','shrine','陸奥国一宮（旧国幣中社）','宮城県','塩竈市','宮城県塩竈市一森山1番1号',38.318750,141.012556,null,null,'http://www.shiogamajinja.jp/','全国の塩竈神社の総本社。塩土老翁神を祀る陸奥国一宮。','https://ja.wikipedia.org/wiki/鹽竈神社','Wikipedia',true,now()),
('zuiganji','瑞巌寺','ずいがんじ','temple','臨済宗妙心寺派','宮城県','宮城郡松島町','宮城県宮城郡松島町松島字町内91',38.372178,141.059597,828,'聖観音菩薩','https://www.zuiganji.or.jp','伊達政宗が再興した松島の禅刹。国宝の本堂で名高い。','https://ja.wikipedia.org/wiki/瑞巌寺','Wikipedia',true,now()),
('takekoma-jinja','竹駒神社','たけこまじんじゃ','shrine','稲荷系','宮城県','岩沼市','宮城県岩沼市稲荷町1-1',38.105000,140.862333,842,null,'https://takekomajinja.jp','日本三稲荷の一つに数えられる東北の稲荷総本宮。','https://ja.wikipedia.org/wiki/竹駒神社','Wikipedia',true,now()),
('kinkasan-koganeyama-jinja','金華山黄金山神社','きんかさんこがねやまじんじゃ','shrine','金運信仰','宮城県','石巻市','宮城県石巻市鮎川浜金華山5番地',38.298028,141.556000,750,null,'http://kinkasan.jp/','金華山島に鎮座。金山毘古神を祀る金運の社。','https://ja.wikipedia.org/wiki/金華山黄金山神社','Wikipedia',true,now()),
('mutsu-kokubunji','陸奥国分寺','むつこくぶんじ','temple','真言宗智山派','宮城県','仙台市','宮城県仙台市若林区木ノ下2-8-28',38.251308,140.902811,745,'薬師如来','http://www.08943.com/','聖武天皇の詔で創建。伊達政宗再建の薬師堂が重文。','https://ja.wikipedia.org/wiki/陸奥国分寺','Wikipedia',true,now()),

-- ── 秋田 ──
('akita-suwagu','秋田諏訪宮','あきたすわぐう','shrine','諏訪系','秋田県','仙北郡美郷町','秋田県仙北郡美郷町六郷字本道町19',39.423694,140.543028,802,null,'http://www.akitasuwagu.jp/','坂上田村麻呂創建と伝わる六郷の総鎮守。建御名方を祀る。','https://ja.wikipedia.org/wiki/秋田諏訪宮','Wikipedia',true,now()),
('koshio-jinja','古四王神社','こしおうじんじゃ','shrine','武神信仰','秋田県','秋田市','秋田県秋田市寺内児桜一丁目55-5',39.736250,140.083167,658,null,null,'武甕槌命・大毘古命を祀る古社。北方鎮護の信仰を集めた。','https://ja.wikipedia.org/wiki/古四王神社','Wikipedia',true,now()),
('taiheizan-miyoshi-jinja','太平山三吉神社','たいへいざんみよしじんじゃ','shrine','山岳信仰','秋田県','秋田市','秋田県秋田市広面字赤沼3-2',39.726167,140.144389,673,null,'http://www.miyoshi.or.jp/','太平山を御神体とする全国三吉神社の総本宮。勝負の神。','https://ja.wikipedia.org/wiki/太平山三吉神社','Wikipedia',true,now()),
('akagami-jinja','赤神神社','あかがみじんじゃ','shrine','山岳信仰','秋田県','男鹿市','秋田県男鹿市船川港本山門前字祓川35',39.870667,139.750917,null,null,null,'男鹿半島・本山に鎮座。五社堂の石段伝説で知られる。','https://ja.wikipedia.org/wiki/赤神神社','Wikipedia',true,now()),
('karamatsu-jinja','唐松神社','からまつじんじゃ','shrine','女一代守神','秋田県','大仙市','秋田県大仙市協和境字下台84',39.610303,140.320722,982,null,null,'女性の一代守神として安産・縁結びの信仰を集める古社。','https://ja.wikipedia.org/wiki/唐松神社','Wikipedia',true,now()),

-- ── 山形 ──
('dewa-jinja','出羽神社','いではじんじゃ','shrine','出羽三山（旧国幣小社）','山形県','鶴岡市','山形県鶴岡市羽黒町手向字羽黒山33',38.702556,139.981861,null,null,'http://www.dewasanzan.jp/','羽黒山頂に鎮座する出羽三山神社の中心社。','https://ja.wikipedia.org/wiki/出羽三山','Wikipedia',true,now()),
('risshakuji','立石寺','りっしゃくじ','temple','天台宗','山形県','山形市','山形県山形市大字山寺4456-1',38.312556,140.437389,860,'薬師如来','https://rissyakuji.jp/','「山寺」の通称で親しまれる名刹。芭蕉の句で名高い。','https://ja.wikipedia.org/wiki/立石寺','Wikipedia',true,now()),
('uesugi-jinja','上杉神社','うえすぎじんじゃ','shrine','人物神（別格官幣社）','山形県','米沢市','山形県米沢市丸の内1丁目4-13',37.909306,140.104083,1871,null,null,'米沢城本丸跡に鎮座。上杉謙信を祀る。','https://ja.wikipedia.org/wiki/上杉神社','Wikipedia',true,now()),
('chokaisan-omonoimi-jinja','鳥海山大物忌神社','ちょうかいさんおおものいみじんじゃ','shrine','出羽国一宮（旧国幣中社）','山形県','飽海郡遊佐町','山形県飽海郡遊佐町大字吹浦字鳥海山1',39.097694,140.048694,null,null,'http://www9.plala.or.jp/thoukai/','鳥海山を御神体とする出羽国一宮。大物忌大神を祀る。','https://ja.wikipedia.org/wiki/大物忌神社','Wikipedia',true,now()),
('wakamatsuji','若松寺','じゃくしょうじ','temple','天台宗','山形県','天童市','山形県天童市大字山元2205-1',38.363060,140.418890,708,'聖観音','http://www.wakamatu-kannon.jp/','最上三十三観音第一番。縁結び観音として名高い。','https://ja.wikipedia.org/wiki/若松寺','Wikipedia',true,now()),
('chokai-gassan-ryosho-gu','鳥海月山両所宮','ちょうかいがっさんりょうしょぐう','shrine','山岳信仰','山形県','山形市','山形県山形市宮町3-8-41',38.270917,140.337167,1063,null,null,'鳥海・月山の両霊峰を祀る山形市の総鎮守。','https://ja.wikipedia.org/wiki/鳥海月山両所宮','Wikipedia',true,now()),

-- ── 福島 ──
('isasumi-jinja','伊佐須美神社','いさすみじんじゃ','shrine','岩代国一宮（旧国幣中社）','福島県','大沼郡会津美里町','福島県大沼郡会津美里町字宮林甲4377',37.456775,139.840681,560,null,'http://isasumi.or.jp/','会津総鎮守・岩代国一宮。会津の地名発祥の社。','https://ja.wikipedia.org/wiki/伊佐須美神社','Wikipedia',true,now()),
('fukushima-inari-jinja','福島稲荷神社','ふくしまいなりじんじゃ','shrine','稲荷系','福島県','福島市','福島県福島市宮町5番2号',37.755592,140.468756,987,null,'https://www.fukushima-inari.com/','安倍晴明の勧請と伝わる福島の総鎮守。','https://ja.wikipedia.org/wiki/福島稲荷神社','Wikipedia',true,now()),
('kaiseizan-daijingu','開成山大神宮','かいせいざんだいじんぐう','shrine','神明系','福島県','郡山市','福島県郡山市開成3丁目1番38号',37.397636,140.353158,1876,null,'http://www.kaiseizan.jp/','「東北のお伊勢さま」。天照大御神らを祀る。','https://ja.wikipedia.org/wiki/開成山大神宮','Wikipedia',true,now()),
('eryuji','恵隆寺','えりゅうじ','temple','真言宗豊山派','福島県','河沼郡会津坂下町','福島県河沼郡会津坂下町大字塔寺字松原2944',37.574944,139.799389,540,'十一面千手観音菩薩','http://tachikikannon.jp/','立木観音で知られる会津の古刹。','https://ja.wikipedia.org/wiki/恵隆寺','Wikipedia',true,now()),
('enzoji-yanaizu','円蔵寺','えんぞうじ','temple','臨済宗妙心寺派','福島県','河沼郡柳津町','福島県河沼郡柳津町柳津字寺家町甲176',37.533060,139.724720,807,'虚空蔵菩薩','https://temple.aizu-yanaizu.com/','福満虚空藏菩薩として日本三虚空蔵の一つ。','https://ja.wikipedia.org/wiki/円蔵寺','Wikipedia',true,now()),
('nanko-jinja','南湖神社','なんこじんじゃ','shrine','人物神（別表神社）','福島県','白河市','福島県白河市菅生舘2',37.112861,140.218972,1922,null,'http://nankojinja.server-shared.com/','南湖公園に鎮座。白河藩主・松平定信を祀る。','https://ja.wikipedia.org/wiki/南湖神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ④ 御祭神/本尊の紐付け ─────────────────────────
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
-- 北海道
   (t.slug='hakodate-hachimangu'        and d.slug in ('hachiman'))
or (t.slug='tarumaesan-jinja'           and d.slug in ('oyamatsumi'))
or (t.slug='kamikawa-jinja'             and d.slug in ('amaterasu','okuninushi','sukunabikona'))
or (t.slug='obihiro-jinja'              and d.slug in ('okuninushi','sukunabikona'))
or (t.slug='nishino-jinja'              and d.slug in ('toyotamahime','ugayafukiaezu','hachiman'))
-- 青森
or (t.slug='uto-jinja'                  and d.slug in ('ichikishima'))
or (t.slug='iwakiyama-jinja'            and d.slug in ('okuninushi','oyamatsumi','ukanomitama'))
or (t.slug='kushihiki-hachimangu'       and d.slug in ('hachiman'))
or (t.slug='takayama-inari-jinja'       and d.slug in ('ukanomitama'))
or (t.slug='osorezan-bodaiji'           and d.slug in ('jizo_bosatsu'))
or (t.slug='kabushima-jinja'            and d.slug in ('ichikishima'))
or (t.slug='engakuji-fukaura'           and d.slug in ('juichimen_kannon'))
or (t.slug='hirosaki-toshogu'           and d.slug in ('ieyasu','amaterasu'))
-- 岩手
or (t.slug='motsuji'                    and d.slug in ('yakushi_nyorai'))
or (t.slug='morioka-hachimangu'         and d.slug in ('hachiman'))
or (t.slug='shoboji-oshu'               and d.slug in ('nyoirin_kannon'))
or (t.slug='tendaiji'                   and d.slug in ('sho_kannon'))
-- 宮城
or (t.slug='shiogama-jinja'             and d.slug in ('shiotsuchi'))
or (t.slug='zuiganji'                   and d.slug in ('sho_kannon'))
or (t.slug='takekoma-jinja'             and d.slug in ('ukanomitama'))
or (t.slug='kinkasan-koganeyama-jinja'  and d.slug in ('kanayamahiko'))
or (t.slug='mutsu-kokubunji'            and d.slug in ('yakushi_nyorai'))
-- 秋田
or (t.slug='akita-suwagu'               and d.slug in ('takeminakata'))
or (t.slug='koshio-jinja'               and d.slug in ('takemikazuchi','oohiko'))
or (t.slug='taiheizan-miyoshi-jinja'    and d.slug in ('okuninushi','sukunabikona'))
or (t.slug='akagami-jinja'              and d.slug in ('ninigi'))
or (t.slug='karamatsu-jinja'            and d.slug in ('jingu_kogo','toyouke'))
-- 山形
or (t.slug='dewa-jinja'                 and d.slug in ('ideha','ukanomitama'))
or (t.slug='risshakuji'                 and d.slug in ('yakushi_nyorai'))
or (t.slug='uesugi-jinja'               and d.slug in ('uesugi_kenshin'))
or (t.slug='wakamatsuji'                and d.slug in ('sho_kannon'))
or (t.slug='chokai-gassan-ryosho-gu'    and d.slug in ('ukanomitama','tsukuyomi'))
-- 福島
or (t.slug='isasumi-jinja'              and d.slug in ('izanami'))
or (t.slug='fukushima-inari-jinja'      and d.slug in ('toyouke','okuninushi','kotoshironushi'))
or (t.slug='kaiseizan-daijingu'         and d.slug in ('amaterasu','toyouke','jimmu'))
or (t.slug='eryuji'                     and d.slug in ('senju_kannon'))
or (t.slug='enzoji-yanaizu'             and d.slug in ('kokuzo_bosatsu'))
or (t.slug='nanko-jinja'                and d.slug in ('matsudaira_sadanobu'))
on conflict do nothing;

-- 鹽竈神社 別宮=主祭神 塩土老翁神(main, 上記)。左右宮=配祀 武甕槌神/経津主神(sub)
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='shiogama-jinja' and d.slug in ('takemikazuchi','futsunushi'))
on conflict do nothing;

-- 鳥海山大物忌神社 主祭神=大物忌大神（豊受大神と同神とされる）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chokaisan-omonoimi-jinja' and d.slug in ('toyouke'))
on conflict do nothing;
