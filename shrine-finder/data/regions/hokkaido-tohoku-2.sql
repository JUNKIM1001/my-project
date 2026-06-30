-- ============================================================
-- 御朱印ナビ 地域データ: 北海道・東北（2巡目／次のティア）
-- 対象県: 北海道, 青森, 岩手, 宮城, 秋田, 山形, 福島
-- 全件 ja.wikipedia.org の infobox を WebFetch で裏取り（十進緯度経度あり）
-- 1巡目（hokkaido-tohoku.sql）および既存社寺とは重複させない
-- ============================================================

-- ───────────────────────── ① 新規神仏 ─────────────────────────
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kamitsukeno_taji','上毛野君田道命','かみつけののきみたじのみこと','kami','御霊','{田道命}','史実','蝦夷征討で殉じた古代の将。猿賀神社の祭神。武勇・農耕の神とされる。','https://ja.wikipedia.org/wiki/猿賀神社','Wikipedia',true,now()),
('hirata_atsutane','平田篤胤','ひらたあつたね','kami','御霊','{}','史実','江戸後期の国学者。復古神道を大成。彌高神社の祭神。','https://ja.wikipedia.org/wiki/平田篤胤','Wikipedia',true,now()),
('sato_nobuhiro','佐藤信淵','さとうのぶひろ','kami','御霊','{}','史実','江戸後期の経世家・農政学者。彌高神社の配祀神。','https://ja.wikipedia.org/wiki/佐藤信淵','Wikipedia',true,now()),
('ankan_tenno','安閑天皇','あんかんてんのう','kami','御霊','{勾大兄広国押武金日命}','記紀','第27代天皇。保呂羽山波宇志別神社の祭神。','https://ja.wikipedia.org/wiki/安閑天皇','Wikipedia',true,now()),
('sakai_tadatsugu','酒井忠次','さかいただつぐ','kami','御霊','{}','史実','徳川四天王の一人。庄内藩主酒井家の祖。荘内神社の祭神。','https://ja.wikipedia.org/wiki/酒井忠次','Wikipedia',true,now()),
('hoshina_masayuki','保科正之','ほしなまさゆき','kami','御霊','{土津霊神}','史実','会津藩初代藩主。三代将軍家光の異母弟。土津神社の祭神。','https://ja.wikipedia.org/wiki/保科正之','Wikipedia',true,now()),
('date_masamune','伊達政宗','だてまさむね','kami','御霊','{武振彦命}','史実','仙台藩初代藩主・独眼竜。青葉神社の祭神。','https://ja.wikipedia.org/wiki/伊達政宗','Wikipedia',true,now()),
('hayatama','速玉之男命','はやたまのおのみこと','kami','国津神','{熊野速玉大神}','記紀','熊野三山の一柱。三熊野神社の祭神。誓約・再生の神。','https://ja.wikipedia.org/wiki/ハヤタマノオ','Wikipedia',true,now()),
('bato_kannon','馬頭観音','ばとうかんのん','buddha','菩薩','{馬頭観世音}','仏教','憤怒相をとる観音。畜獣・交通の守護。如宝寺の本尊の一。','https://ja.wikipedia.org/wiki/馬頭観音','Wikipedia',true,now()),
('miroku_bosatsu','弥勒菩薩','みろくぼさつ','buddha','菩薩','{}','仏教','釈迦入滅後56億7千万年後に成道する未来仏。本山慈恩寺の本尊。','https://ja.wikipedia.org/wiki/弥勒菩薩','Wikipedia',true,now()),
('nanbu_mitsuyuki','南部光行','なんぶみつゆき','kami','御霊','{}','史実','南部氏の祖。櫻山神社に南部氏歴代として祀られる。','https://ja.wikipedia.org/wiki/南部光行','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ② 新規神仏の司るご利益 ─────────────────────────
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kamitsukeno_taji'  and g.slug in ('shobu','suisan_noko','yakubarai'))
or (d.slug='hirata_atsutane'   and g.slug in ('gakumon','gakugyo'))
or (d.slug='sato_nobuhiro'     and g.slug in ('gakumon','shobai'))
or (d.slug='ankan_tenno'       and g.slug in ('kaiun','yakubarai'))
or (d.slug='sakai_tadatsugu'   and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='hoshina_masayuki'  and g.slug in ('gakumon','shusse','kaiun'))
or (d.slug='date_masamune'     and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='hayatama'          and g.slug in ('enmusubi','yakubarai','jouju'))
or (d.slug='bato_kannon'       and g.slug in ('kotsu_anzen','petto','byoki_heyu'))
or (d.slug='miroku_bosatsu'    and g.slug in ('kaiun','jouju','byoki_heyu'))
or (d.slug='nanbu_mitsuyuki'   and g.slug in ('shusse','kaiun','shobu'))
on conflict do nothing;

-- ───────────────────────── ③ 社寺 ─────────────────────────
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values

-- ── 北海道 ──
('ubagami-daijingu','姥神大神宮','うばがみだいじんぐう','shrine','神明系','北海道','檜山郡江差町','北海道檜山郡江差町姥神町99',41.866444,140.125028,1216,null,null,'北海道最古級の神社とされる江差の鎮守。天照皇大御神らを祀る。','https://ja.wikipedia.org/wiki/姥神大神宮','Wikipedia',true,now()),
('muroran-hachimangu','室蘭八幡宮','むろらんはちまんぐう','shrine','八幡神','北海道','室蘭市','北海道室蘭市海岸町2-9-3',42.320830,140.968060,1869,null,null,'鯨を売った資金で創建され「鯨八幡」と呼ばれる室蘭の鎮守。','https://ja.wikipedia.org/wiki/室蘭八幡宮','Wikipedia',true,now()),
('abashiri-jinja','網走神社','あばしりじんじゃ','shrine','宗像三女神','北海道','網走市','北海道網走市桂町2丁目1番1号',44.015722,144.270194,1812,null,null,'文化9年創建と伝わる網走の鎮守。宗像三女神を祀る。','https://ja.wikipedia.org/wiki/網走神社','Wikipedia',true,now()),
('hokkaidojingu-tongu','北海道神宮頓宮','ほっかいどうじんぐうとんぐう','shrine','神明系','北海道','札幌市','北海道札幌市中央区南2条東3丁目',43.059972,141.361417,1878,null,'https://tongusan.jp/','北海道神宮の市街地遥拝所。開拓三神と明治天皇を祀る。','https://ja.wikipedia.org/wiki/北海道神宮頓宮','Wikipedia',true,now()),
('otaru-sumiyoshi-jinja','住吉神社','すみよしじんじゃ','shrine','住吉系','北海道','小樽市','北海道小樽市住ノ江2-5-1',43.182944,141.003222,1868,null,'http://www.otarusumiyoshijinja.or.jp/','小樽の総鎮守。住吉三神と神功皇后を祀る。','https://ja.wikipedia.org/wiki/住吉神社_(小樽市)','Wikipedia',true,now()),
('kushiro-itsukushima-jinja','釧路一之宮厳島神社','くしろいちのみやいつくしまじんじゃ','shrine','宗像三女神','北海道','釧路市','北海道釧路市米町1丁目3-18',42.971972,144.372056,1805,null,'http://kushiro-itsukushimajinja.com/','釧路の総鎮守。市杵島姫命らを祀る道東有数の古社。','https://ja.wikipedia.org/wiki/厳島神社_(釧路市)','Wikipedia',true,now()),

-- ── 青森 ──
('hirota-jinja-aomori','廣田神社','ひろたじんじゃ','shrine','神明系','青森県','青森市','青森県青森市長島2-13-5',40.822500,140.742611,996,null,'https://hirotajinja.or.jp/','天照大御神荒御魂を祀る青森市街の鎮守。じゃんばら大注連縄で知られる。','https://ja.wikipedia.org/wiki/廣田神社_(青森市)','Wikipedia',true,now()),
('saruka-jinja','猿賀神社','さるかじんじゃ','shrine','人物神','青森県','平川市','青森県平川市猿賀字石林175',40.616917,140.562972,807,null,'http://ss701927.stars.ne.jp/','上毛野君田道命を祀る津軽の古社。蓮池で名高い。','https://ja.wikipedia.org/wiki/猿賀神社','Wikipedia',true,now()),
('saishoin','最勝院','さいしょういん','temple','真言宗智山派','青森県','弘前市','青森県弘前市大字銅屋町63',40.596469,140.468542,1532,'金剛界大日如来','http://www15.plala.or.jp/SAISYOU/','日本最北の重要文化財・五重塔を持つ津軽の名刹。','https://ja.wikipedia.org/wiki/最勝院','Wikipedia',true,now()),
('choshoji-hirosaki','長勝寺','ちょうしょうじ','temple','曹洞宗','青森県','弘前市','青森県弘前市西茂森1-13-8',40.598847,140.450800,1528,'釈迦如来','https://長勝寺.com','津軽家の菩提寺。本堂・三門など多くの重要文化財を持つ禅刹。','https://ja.wikipedia.org/wiki/長勝寺_(弘前市)','Wikipedia',true,now()),
('towada-jinja','十和田神社','とわだじんじゃ','shrine','山岳信仰','青森県','十和田市','青森県十和田市奥瀬十和田湖畔休屋486',40.433194,140.892220,807,null,null,'十和田湖畔に鎮座。日本武尊・須佐之男命を祀る霊場。','https://ja.wikipedia.org/wiki/十和田神社','Wikipedia',true,now()),
('hirosaki-hachimangu','弘前八幡宮','ひろさきはちまんぐう','shrine','八幡神','青森県','弘前市','青森県弘前市八幡町1丁目1-1',40.616083,140.479306,null,null,'https://hirosaki-hachimangu.com/','弘前藩の総鎮守。応神天皇・神功皇后らを祀る。','https://ja.wikipedia.org/wiki/弘前八幡宮','Wikipedia',true,now()),

-- ── 岩手 ──
('sakurayama-jinja','櫻山神社','さくらやまじんじゃ','shrine','人物神','岩手県','盛岡市','岩手県盛岡市内丸1-42',39.701472,141.151833,1749,null,'http://www.sakurayamajinja.jp','盛岡城跡に鎮座。南部氏歴代を祀る盛岡の鎮守。','https://ja.wikipedia.org/wiki/桜山神社_(盛岡市)','Wikipedia',true,now()),
('kokusekiji','黒石寺','こくせきじ','temple','天台宗','岩手県','奥州市','岩手県奥州市水沢黒石町山内',39.084278,141.206583,729,'薬師如来','http://www.kokusekiji.jp/','蘇民祭で知られる東北屈指の古刹。862年銘の薬師如来像を蔵す。','https://ja.wikipedia.org/wiki/黒石寺','Wikipedia',true,now()),
('takkoku-bishamondo','達谷窟毘沙門堂','たっこくのいわやびしゃもんどう','temple','天台宗','岩手県','西磐井郡平泉町','岩手県西磐井郡平泉町平泉字北澤16',38.968167,141.058444,801,'毘沙門天','http://www.iwayabetto.com/','坂上田村麻呂創建と伝わる岩窟の毘沙門堂。','https://ja.wikipedia.org/wiki/達谷窟','Wikipedia',true,now()),
('mikumano-jinja-narushima','三熊野神社','みくまのじんじゃ','shrine','熊野系','岩手県','花巻市','岩手県花巻市東和町北成島5区1',39.365639,141.197500,802,null,null,'成島毘沙門堂に隣接。泣き相撲の神事で知られる古社。','https://ja.wikipedia.org/wiki/三熊野神社_(花巻市)','Wikipedia',true,now()),
('hoonji-morioka','報恩寺','ほうおんじ','temple','曹洞宗','岩手県','盛岡市','岩手県盛岡市名須川町31-5',39.712208,141.156197,1362,'釈迦如来','http://hoonji-morioka.jp/','五百羅漢で名高い盛岡五山の一。','https://ja.wikipedia.org/wiki/報恩寺_(盛岡市)','Wikipedia',true,now()),

-- ── 宮城 ──
('aoba-jinja','青葉神社','あおばじんじゃ','shrine','人物神','宮城県','仙台市','宮城県仙台市青葉区青葉町7番1号',38.282833,140.862861,1874,null,'https://www.aoba-jinja.com/','仙台藩祖・伊達政宗（武振彦命）を祀る。','https://ja.wikipedia.org/wiki/青葉神社','Wikipedia',true,now()),
('shiwahiko-jinja','志波彦神社','しわひこじんじゃ','shrine','式内名神大社（旧国幣中社）','宮城県','塩竈市','宮城県塩竈市一森山1番1号',38.318833,141.013750,null,null,'http://www.shiogamajinja.jp/','鹽竈神社と同じ一森山に鎮座する式内名神大社。志波彦大神を祀る。','https://ja.wikipedia.org/wiki/志波彦神社・鹽竈神社','Wikipedia',true,now()),
('jogi-saihoji','定義如来西方寺','じょうぎにょらいさいほうじ','temple','浄土宗','宮城県','仙台市','宮城県仙台市青葉区大倉字上下1',38.365083,140.667780,1706,'阿弥陀如来','https://jogi.jp/','「定義如来」として親しまれる仙台屈指の古刹。縁結び・安産で知られる。','https://ja.wikipedia.org/wiki/西方寺_(仙台市)','Wikipedia',true,now()),

-- ── 秋田 ──
('iyataka-jinja','彌高神社','いやたかじんじゃ','shrine','人物神','秋田県','秋田市','秋田県秋田市千秋公園1-16',39.723060,140.125000,1881,null,'http://www.iyataka-jinja.jp/','久保田城跡に鎮座。国学者・平田篤胤らを祀る。','https://ja.wikipedia.org/wiki/彌高神社','Wikipedia',true,now()),
('hiyoshi-hachiman-jinja','日吉八幡神社','ひよしはちまんじんじゃ','shrine','日吉・八幡系','秋田県','秋田市','秋田県秋田市八橋本町1丁目4-1',39.722220,140.097220,null,null,null,'日枝山王と石清水八幡を勧請したと伝わる秋田の古社。三層塔が名高い。','https://ja.wikipedia.org/wiki/日吉八幡神社','Wikipedia',true,now()),
('shinzan-jinja','真山神社','しんざんじんじゃ','shrine','山岳信仰','秋田県','男鹿市','秋田県男鹿市北浦真山字水喰沢97',39.927083,139.766917,null,null,'http://www.namahage.ne.jp/~shinzanjinja/','男鹿・真山に鎮座。なまはげ柴灯まつりで知られる。瓊瓊杵尊らを祀る。','https://ja.wikipedia.org/wiki/真山神社','Wikipedia',true,now()),
('horowasan-haushiwake-jinja','保呂羽山波宇志別神社','ほろわさんはうしわけじんじゃ','shrine','山岳信仰','秋田県','横手市','秋田県横手市大森町八沢木字保呂羽山1-1',39.371206,140.309872,757,null,null,'保呂羽山に鎮座する式内社。霜月神楽で知られる。安閑天皇を祀る。','https://ja.wikipedia.org/wiki/保呂羽山波宇志別神社','Wikipedia',true,now()),
('sankokumano-jinja','三皇熊野神社','さんこうくまのじんじゃ','shrine','熊野系','秋田県','秋田市','秋田県秋田市牛島西3丁目10-11',39.692500,140.105222,804,null,'https://sankoukumano.sakura.ne.jp/','延暦年間創建と伝わる秋田市牛島の鎮守。天照皇大神らを祀る。','https://ja.wikipedia.org/wiki/三皇熊野神社','Wikipedia',true,now()),

-- ── 山形 ──
('yudonosan-jinja','湯殿山神社','ゆどのさんじんじゃ','shrine','出羽三山（旧国幣小社）','山形県','鶴岡市','山形県鶴岡市田麦俣字六十里山7',38.541556,139.986083,null,null,'http://www.dewasanzan.jp/','出羽三山の奥宮。社殿を持たず巨岩の御神体を拝する霊場。','https://ja.wikipedia.org/wiki/湯殿山神社','Wikipedia',true,now()),
('shonai-jinja','荘内神社','しょうないじんじゃ','shrine','人物神','山形県','鶴岡市','山形県鶴岡市馬場町4番1号',38.728306,139.824281,1877,null,'https://jinjahan.com/','鶴ヶ岡城本丸跡に鎮座。庄内藩主・酒井家歴代を祀る。','https://ja.wikipedia.org/wiki/荘内神社','Wikipedia',true,now()),
('kumano-taisha-nanyo','熊野大社','くまのたいしゃ','shrine','熊野系','山形県','南陽市','山形県南陽市宮内3476-1',38.078000,140.136940,806,null,'http://www.kumano-taisha.or.jp','日本三熊野の一つ「東北の伊勢」。伊弉諾・伊弉冉命を祀る。','https://ja.wikipedia.org/wiki/熊野神社_(南陽市)','Wikipedia',true,now()),
('sokoji-sakata','總光寺','そうこうじ','temple','曹洞宗','山形県','酒田市','山形県酒田市總光寺澤8',38.859170,139.968060,1384,'釈迦如来','http://www.sokoji-sakata.com/','名勝庭園「蓬莱園」と「きのこ杉」で知られる庄内の禅刹。','https://ja.wikipedia.org/wiki/總光寺_(酒田市)','Wikipedia',true,now()),
('honzan-jionji','本山慈恩寺','ほんざんじおんじ','temple','慈恩宗','山形県','寒河江市','山形県寒河江市大字慈恩寺地籍31',38.410250,140.250889,724,'弥勒菩薩','http://www.honzan-jionji.jp/','寒河江の山岳寺院。本堂が重要文化財の東北屈指の古刹。','https://ja.wikipedia.org/wiki/慈恩寺_(寒河江市)','Wikipedia',true,now()),

-- ── 福島 ──
('soma-nakamura-jinja','相馬中村神社','そうまなかむらじんじゃ','shrine','妙見信仰','福島県','相馬市','福島県相馬市中村字北町140',37.797125,140.913458,1611,null,'https://soumanakamurajinja.com/','相馬野馬追で名高い相馬氏の妙見社。天之御中主神を祀る。','https://ja.wikipedia.org/wiki/相馬中村神社','Wikipedia',true,now()),
('hanitsu-jinja','土津神社','はにつじんじゃ','shrine','人物神','福島県','耶麻郡猪苗代町','福島県耶麻郡猪苗代町字見祢山3',37.570560,140.100560,1675,null,'https://hanitsujinja.jp/','会津藩初代藩主・保科正之を祀る。「会津の東照宮」と称される。','https://ja.wikipedia.org/wiki/土津神社','Wikipedia',true,now()),
('aizu-sazaedo','会津さざえ堂','あいづさざえどう','temple','その他','福島県','会津若松市','福島県会津若松市一箕町八幡弁天下1404',37.504528,139.953972,1796,'阿弥陀如来','https://www.sazaedo.jp/','二重らせん構造で知られる国重文の円通三匝堂。','https://ja.wikipedia.org/wiki/さざえ堂','Wikipedia',true,now()),
('shojoji-yugawa','勝常寺','しょうじょうじ','temple','真言宗豊山派','福島県','河沼郡湯川村','福島県河沼郡湯川村勝常字代舞1764',37.563528,139.870078,810,'薬師如来','http://www.shojoji.jp/','東北初の国宝仏・薬師三尊を蔵す会津の古刹。','https://ja.wikipedia.org/wiki/勝常寺','Wikipedia',true,now()),
('nakano-fudoson','中野不動尊','なかのふどうそん','temple','曹洞宗','福島県','福島市','福島県福島市飯坂町中野字堰坂28',37.824806,140.415278,1179,'不動明王','https://nakanofudouson.jp/','日本三大不動の一つに数えられる飯坂の霊場。','https://ja.wikipedia.org/wiki/中野不動尊','Wikipedia',true,now()),
('nyohoji-koriyama','如宝寺','にょほうじ','temple','真言宗豊山派','福島県','郡山市','福島県郡山市堂前町4-24',37.395889,140.379222,807,'大日如来','http://www.nyohouji.com/','郡山の中心に立つ古刹。大日如来・馬頭観音・不動明王を祀る。','https://ja.wikipedia.org/wiki/如宝寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ④ 御祭神/本尊の紐付け ─────────────────────────
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
-- 北海道
   (t.slug='ubagami-daijingu'           and d.slug in ('amaterasu','amenokoyane','sumiyoshi'))
or (t.slug='muroran-hachimangu'         and d.slug in ('hachiman'))
or (t.slug='abashiri-jinja'             and d.slug in ('ichikishima'))
or (t.slug='hokkaidojingu-tongu'        and d.slug in ('okuninushi','sukunabikona','meiji_tenno'))
or (t.slug='otaru-sumiyoshi-jinja'      and d.slug in ('sumiyoshi','jingu_kogo'))
or (t.slug='kushiro-itsukushima-jinja'  and d.slug in ('ichikishima'))
-- 青森
or (t.slug='hirota-jinja-aomori'        and d.slug in ('amaterasu'))
or (t.slug='saruka-jinja'               and d.slug in ('kamitsukeno_taji'))
or (t.slug='saishoin'                   and d.slug in ('dainichi_nyorai'))
or (t.slug='choshoji-hirosaki'          and d.slug in ('shaka_nyorai'))
or (t.slug='towada-jinja'               and d.slug in ('susanoo','yamatotakeru'))
or (t.slug='hirosaki-hachimangu'        and d.slug in ('hachiman','jingu_kogo'))
-- 岩手
or (t.slug='sakurayama-jinja'           and d.slug in ('nanbu_mitsuyuki'))
or (t.slug='kokusekiji'                 and d.slug in ('yakushi_nyorai'))
or (t.slug='takkoku-bishamondo'         and d.slug in ('bishamonten'))
or (t.slug='mikumano-jinja-narushima'   and d.slug in ('izanami','kotoshironushi','hayatama'))
or (t.slug='hoonji-morioka'             and d.slug in ('shaka_nyorai'))
-- 宮城
or (t.slug='aoba-jinja'                 and d.slug in ('date_masamune'))
or (t.slug='shiwahiko-jinja'            and d.slug in ('shiwahiko'))
or (t.slug='jogi-saihoji'               and d.slug in ('amida_nyorai'))
-- 秋田
or (t.slug='iyataka-jinja'              and d.slug in ('hirata_atsutane','sato_nobuhiro'))
or (t.slug='hiyoshi-hachiman-jinja'     and d.slug in ('oyamakui','omononushi','hachiman'))
or (t.slug='shinzan-jinja'              and d.slug in ('ninigi','takemikazuchi'))
or (t.slug='horowasan-haushiwake-jinja' and d.slug in ('ankan_tenno'))
or (t.slug='sankokumano-jinja'          and d.slug in ('amaterasu','izanagi','izanami','susanoo','hachiman'))
-- 山形
or (t.slug='yudonosan-jinja'            and d.slug in ('oyamatsumi','okuninushi','sukunabikona'))
or (t.slug='shonai-jinja'               and d.slug in ('sakai_tadatsugu'))
or (t.slug='kumano-taisha-nanyo'        and d.slug in ('izanagi','izanami'))
or (t.slug='sokoji-sakata'              and d.slug in ('shaka_nyorai'))
or (t.slug='honzan-jionji'              and d.slug in ('miroku_bosatsu'))
-- 福島
or (t.slug='soma-nakamura-jinja'        and d.slug in ('amenominakanushi'))
or (t.slug='hanitsu-jinja'              and d.slug in ('hoshina_masayuki'))
or (t.slug='aizu-sazaedo'               and d.slug in ('amida_nyorai'))
or (t.slug='shojoji-yugawa'             and d.slug in ('yakushi_nyorai'))
or (t.slug='nakano-fudoson'             and d.slug in ('fudo_myoo'))
or (t.slug='nyohoji-koriyama'           and d.slug in ('dainichi_nyorai','bato_kannon','fudo_myoo'))
on conflict do nothing;

-- 三皇熊野神社・三熊野神社は配祀として須佐之男等を main 同列に含めた（infobox記載通り）
-- 真山神社の配祀（瓊瓊杵尊=主、武甕槌命=配）は role 区別せず main 扱い（spec上の簡略）
