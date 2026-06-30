-- w6-shikoku-b.sql
-- 四国（徳島県・香川県・愛媛県・高知県）の著名社寺データ
-- 出典: ja.wikipedia.org infobox の十進座標で裏取り
-- 既存 _have_chugoku-shikoku.txt と重複しないものを収録

-- ① 新規神仏 -------------------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方浄瑠璃世界の教主。病気平癒・現世利益の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('miroku_bosatsu','弥勒菩薩','みろくぼさつ','buddha','菩薩','{}','仏教','釈迦の次に成仏すると説かれる未来仏。','https://ja.wikipedia.org/wiki/弥勒菩薩','Wikipedia',true,now()),
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{延命地蔵菩薩}','仏教','六道で衆生を救う菩薩。子供・旅人の守護。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖・釈迦を仏として表した如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{恵比寿}','記紀','大国主神の子。託宣・漁業・商売繁盛の神。恵比寿と習合。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。極楽往生を導く如来。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{十一面観世音菩薩}','仏教','十一の面を持つ観音菩薩。除災・現世利益。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{}','仏教','真言密教の本尊。宇宙の真理そのものを表す如来。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now()),
('bishamonten','毘沙門天','びしゃもんてん','buddha','天部','{多聞天}','仏教','四天王・七福神の一柱。武運・財福の守護神。','https://ja.wikipedia.org/wiki/毘沙門天','Wikipedia',true,now()),
('susanoo','須佐之男命','すさのおのみこと','kami','天津神','{素戔嗚尊,牛頭天王}','記紀','天照大神の弟。除疫・厄除けの荒ぶる神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益 -------------------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','kanai_anzen','choju'))
or (d.slug='miroku_bosatsu' and g.slug in ('kaiun','jouju','gakumon'))
or (d.slug='jizo_bosatsu' and g.slug in ('kosodate','tabi_anzen','choju'))
or (d.slug='shaka_nyorai' and g.slug in ('kaiun','yakubarai','kinun'))
or (d.slug='kotoshironushi' and g.slug in ('shobai','suisan_noko','kaijo_anzen'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','kaiun','choju'))
or (d.slug='juichimen_kannon' and g.slug in ('yakubarai','byoki_heyu','kaiun'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','jouju','gakumon'))
or (d.slug='bishamonten' and g.slug in ('shobu','kinun','yakubarai'))
or (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','enmusubi'))
on conflict do nothing;

-- ③ 社寺 -----------------------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('onzan-ji','恩山寺','おんざんじ','temple','高野山真言宗','徳島県','小松島市','徳島県小松島市田野町恩山寺谷40',33.986000,134.578250,null,'薬師如来',null,'四国八十八箇所第18番札所。空海が母と再会した伝承で知られる。','https://ja.wikipedia.org/wiki/恩山寺','Wikipedia',true,now()),
('tatsue-ji','立江寺','たつえじ','temple','高野山真言宗','徳島県','小松島市','徳島県小松島市立江町若松13',33.967861,134.605806,747,'延命地蔵菩薩','http://www.tatsueji.com/','四国八十八箇所第19番札所。阿波の関所寺と称される。','https://ja.wikipedia.org/wiki/立江寺_(小松島市)','Wikipedia',true,now()),
('joraku-ji-tokushima','常楽寺','じょうらくじ','temple','高野山真言宗','徳島県','徳島市','徳島県徳島市国府町延命606',34.050333,134.475639,815,'弥勒菩薩',null,'四国八十八箇所第14番札所。本尊が弥勒菩薩なのは八十八ヶ所で当寺のみ。','https://ja.wikipedia.org/wiki/常楽寺_(徳島市)','Wikipedia',true,now()),
('awa-kokubun-ji','阿波国分寺','あわこくぶんじ','temple','曹洞宗','徳島県','徳島市','徳島県徳島市国府町矢野718-1',34.055611,134.473610,756,'薬師如来',null,'四国八十八箇所第15番札所。聖武天皇の詔で建立された阿波国の国分寺。','https://ja.wikipedia.org/wiki/阿波国分寺','Wikipedia',true,now()),
('ido-ji','井戸寺','いどじ','temple','真言宗善通寺派','徳島県','徳島市','徳島県徳島市国府町井戸北屋敷80-1',34.085167,134.485444,673,'七仏薬師如来',null,'四国八十八箇所第17番札所。弘法大師が掘ったと伝わる井戸で知られる。','https://ja.wikipedia.org/wiki/井戸寺','Wikipedia',true,now()),
('kotoshironushi-jinja-tokushima','事代主神社','ことしろぬしじんじゃ','shrine','旧県社','徳島県','徳島市','徳島県徳島市通町2-16',34.071333,134.550908,null,null,null,'「おいべっさん」と親しまれる。1月のえびす祭は20万人を集める阿波の名社。','https://ja.wikipedia.org/wiki/事代主神社_(徳島市)','Wikipedia',true,now()),
('konsen-ji','金泉寺','こんせんじ','temple','高野山真言宗','徳島県','板野町','徳島県板野郡板野町大寺66',34.147436,134.468544,729,'釈迦如来','https://www.88shikokuhenro.jp/03konsenji/','四国八十八箇所第3番札所。寺名にちなみ金運上昇の御利益で知られる。','https://ja.wikipedia.org/wiki/金泉寺','Wikipedia',true,now()),
('yoda-ji','與田寺','よだじ','temple','真言宗善通寺派','香川県','東かがわ市','香川県東かがわ市中筋466',34.241694,134.321694,739,'薬師如来','https://yodaji.com/','四国八十八箇所総奥之院。「厄除けの寺」として年間約20万人が参拝。','https://ja.wikipedia.org/wiki/與田寺','Wikipedia',true,now()),
('iwaseo-hachimangu','石清尾八幡宮','いわせおはちまんぐう','shrine','旧県社','香川県','高松市','香川県高松市宮脇町1-30-3',34.337361,134.034440,918,null,'http://www.iwaseo.com/','高松の総鎮守。応神天皇・仲哀天皇・神功皇后を祀る。','https://ja.wikipedia.org/wiki/石清尾八幡宮','Wikipedia',true,now()),
('hagiwara-ji','萩原寺','はぎわらじ','temple','真言宗大覚寺派','香川県','観音寺市','香川県観音寺市大野原町萩原2742',34.071110,133.688444,807,'伽羅陀山火伏地蔵菩薩','http://www.hagiwaraji.or.jp/','四国別格二十霊場第16番。約2000株の萩の名所として知られる。','https://ja.wikipedia.org/wiki/萩原寺','Wikipedia',true,now()),
('sairin-ji','西林寺','さいりんじ','temple','真言宗豊山派','愛媛県','松山市','愛媛県松山市高井町1007',33.793722,132.813944,741,'十一面観世音菩薩',null,'四国八十八箇所第48番札所。周囲より低い土地に建ち独特の伝承を持つ。','https://ja.wikipedia.org/wiki/西林寺_(松山市)','Wikipedia',true,now()),
('yasaka-ji-matsuyama','八坂寺','やさかじ','temple','真言宗醍醐派','愛媛県','松山市','愛媛県松山市浄瑠璃町八坂773',33.757944,132.812861,701,'阿弥陀如来',null,'四国八十八箇所第47番札所。八つの坂を切り開いた寺名の由来を持つ。','https://ja.wikipedia.org/wiki/八坂寺_(松山市)','Wikipedia',true,now()),
('buraku-ji','豊楽寺','ぶらくじ','temple','真言宗智山派','高知県','大豊町','高知県長岡郡大豊町寺内314',33.792083,133.727111,724,'薬師如来',null,'柴折薬師。薬師堂は四国最古の建造物で国宝。日本三大薬師の一つ。','https://ja.wikipedia.org/wiki/豊楽寺','Wikipedia',true,now()),
('wakamiya-hachimangu-kochi','若宮八幡宮','わかみやはちまんぐう','shrine','旧県社','高知県','高知市','高知県高知市長浜6600',33.494989,133.543610,1185,null,'https://wakamiya-kochi.com/','長宗我部元親ゆかりの社。4月のどろんこ祭で知られる。','https://ja.wikipedia.org/wiki/若宮八幡宮_(高知市)','Wikipedia',true,now()),
('koon-ji','香園寺','こうおんじ','temple','真言宗（単立）','愛媛県','西条市','愛媛県西条市小松町南川甲19',33.893528,133.103306,null,'大日如来','http://www.koyasudaishi.or.jp/','四国八十八箇所第61番札所。「子安大師」として安産・子育て祈願で名高い。','https://ja.wikipedia.org/wiki/香園寺','Wikipedia',true,now()),
('kichijo-ji-saijo','吉祥寺','きちじょうじ','temple','真言宗東寺派','愛媛県','西条市','愛媛県西条市氷見乙1048',33.896056,133.129170,null,'毘沙門天',null,'四国八十八箇所第63番札所。八十八ヶ所で唯一毘沙門天を本尊とする寺。','https://ja.wikipedia.org/wiki/吉祥寺_(西条市)','Wikipedia',true,now()),
('hoju-ji-saijo','宝寿寺','ほうじゅじ','temple','真言宗善通寺派','愛媛県','西条市','愛媛県西条市小松町新屋敷甲428',33.897333,133.114944,729,'十一面観世音菩薩',null,'四国八十八箇所第62番札所。聖武天皇の勅願により道慈が開創と伝わる。','https://ja.wikipedia.org/wiki/宝寿寺','Wikipedia',true,now()),
('takinomiya-jinja','滝宮神社','たきのみやじんじゃ','shrine','旧郷社','香川県','綾川町','香川県綾歌郡綾川町滝宮1347',34.249836,133.919078,709,null,null,'菅原道真ゆかりの社。国指定無形民俗文化財「滝宮念仏踊」で知られる。','https://ja.wikipedia.org/wiki/滝宮神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け --------------------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='onzan-ji' and d.slug='yakushi_nyorai')
or (t.slug='tatsue-ji' and d.slug='jizo_bosatsu')
or (t.slug='joraku-ji-tokushima' and d.slug='miroku_bosatsu')
or (t.slug='awa-kokubun-ji' and d.slug='yakushi_nyorai')
or (t.slug='ido-ji' and d.slug='yakushi_nyorai')
or (t.slug='kotoshironushi-jinja-tokushima' and d.slug in ('kotoshironushi','okuninushi'))
or (t.slug='konsen-ji' and d.slug='shaka_nyorai')
or (t.slug='yoda-ji' and d.slug='yakushi_nyorai')
or (t.slug='iwaseo-hachimangu' and d.slug='hachiman')
or (t.slug='hagiwara-ji' and d.slug='jizo_bosatsu')
or (t.slug='sairin-ji' and d.slug='juichimen_kannon')
or (t.slug='yasaka-ji-matsuyama' and d.slug='amida_nyorai')
or (t.slug='buraku-ji' and d.slug='yakushi_nyorai')
or (t.slug='wakamiya-hachimangu-kochi' and d.slug in ('hachiman','ichikishima'))
or (t.slug='koon-ji' and d.slug='dainichi_nyorai')
or (t.slug='kichijo-ji-saijo' and d.slug='bishamonten')
or (t.slug='hoju-ji-saijo' and d.slug='juichimen_kannon')
or (t.slug='takinomiya-jinja' and d.slug='susanoo')
on conflict do nothing;
