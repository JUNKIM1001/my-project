-- 北海道・東北 追加分 (hokkaido-tohoku-5.sql)
-- 担当: 北海道,青森,岩手,宮城,秋田,山形,福島
-- ja.wikipedia.org infobox の十進座標で裏取り。既存5ファイル・_have リストと重複なし。
-- 仕様①〜④厳守。座標がinfoboxに無いものは除外。

-- ===== ③ 社寺 (batch 1) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nagayama-jinja','永山神社','ながやまじんじゃ','shrine','永山神社（旧県社）','北海道','旭川市','北海道旭川市永山4条18丁目',43.808478,142.434831,1891,null,'http://www.hokkaidou-asahikawa-nagayamajinnja.com','旭川・永山に入植した屯田兵が郷里の神を勧請して創建。旭川最古級の神社。','https://ja.wikipedia.org/wiki/永山神社','Wikipedia',true,now()),
('sapporo-fushimi-inari-jinja','札幌伏見稲荷神社','さっぽろふしみいなりじんじゃ','shrine','札幌伏見稲荷神社','北海道','札幌市','北海道札幌市中央区伏見2丁目2-17',43.034917,141.325333,1884,null,'https://fushimiinari.or.jp/','藻岩山麓に鎮座する稲荷社。連なる朱鳥居で知られる御朱印人気社。','https://ja.wikipedia.org/wiki/札幌伏見稲荷神社','Wikipedia',true,now()),
('hassamu-jinja','発寒神社','はっさむじんじゃ','shrine','発寒神社','北海道','札幌市','北海道札幌市西区発寒11条3丁目1番33',43.091694,141.294389,1856,null,'http://www.hassamujinja.com/','幕末の発寒開拓に始まる西区の鎮守。豊受大神・倉稲魂大神を祀る。','https://ja.wikipedia.org/wiki/発寒神社','Wikipedia',true,now()),
('suwa-jinja-sapporo','諏訪神社（札幌市）','すわじんじゃ','shrine','諏訪神社','北海道','札幌市','北海道札幌市東区北十二条東1丁目',43.075972,141.354056,1882,null,null,'信州諏訪大社の分霊を祀る札幌東区の鎮守。建御名方神を主祭神とする。','https://ja.wikipedia.org/wiki/諏訪神社_(札幌市)','Wikipedia',true,now()),
('shinkotoni-jinja','新琴似神社','しんことにじんじゃ','shrine','新琴似神社','北海道','札幌市','北海道札幌市北区新琴似8条3丁目1-6',43.113583,141.332361,1887,null,'http://www.shinkotonijinja.or.jp/','新琴似屯田兵村の鎮守として創建。屯田兵ゆかりの祭礼で知られる。','https://ja.wikipedia.org/wiki/新琴似神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 1) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nagayama-jinja' and d.slug in ('amaterasu','okuninushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sapporo-fushimi-inari-jinja' and d.slug in ('ukanomitama'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='sapporo-fushimi-inari-jinja' and d.slug in ('oyamatsumi','okuninushi','kotoshironushi','amenouzume'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hassamu-jinja' and d.slug in ('toyouke','ukanomitama'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='suwa-jinja-sapporo' and d.slug in ('takeminakata'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='suwa-jinja-sapporo' and d.slug in ('yasakatome'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shinkotoni-jinja' and d.slug in ('amaterasu','toyouke','jimmu'))
on conflict do nothing;

-- ===== ① 新規神仏 (batch 2用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('miyoshi','三吉霊神','みよしのおおかみ','kami','御霊','{}','民間信仰','秋田・太平山に座す勝負・力の神。藤原三吉を神格化したとされる。','https://ja.wikipedia.org/wiki/太平山三吉神社','Wikipedia',true,now()),
('okunitama','大国魂神','おおくにたまのかみ','kami','国津神','{}','記紀','国土の御霊として国土経営・守護を司る神。','https://ja.wikipedia.org/wiki/大国魂神','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 (batch 2用) =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='miyoshi' and g.slug in ('shobu','shusse','shobai'))
   or (d.slug='okunitama' and g.slug in ('kaiun','kanai_anzen','shobai'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 2) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('miyoshi-jinja-sapporo','三吉神社（札幌市）','みよしじんじゃ','shrine','三吉神社','北海道','札幌市','北海道札幌市中央区南1条西8丁目17番地',43.058444,141.345167,1878,null,'https://miyoshi-sapporo.or.jp/','秋田・太平山三吉神社の分霊を祀る札幌中心部の社。「さんきちさん」と親しまれる。','https://ja.wikipedia.org/wiki/三吉神社_(札幌市)','Wikipedia',true,now()),
('sapporomura-jinja','札幌村神社','さっぽろむらじんじゃ','shrine','札幌村神社','北海道','札幌市','北海道札幌市東区北16条東14丁目3-1',43.083083,141.37225,1900,null,null,'札幌村の開拓鎮守として創建。大国魂神・大己貴神・少彦名神を祀る。','https://ja.wikipedia.org/wiki/札幌村神社','Wikipedia',true,now()),
('shiroishi-jinja-sapporo','白石神社（札幌市）','しろいしじんじゃ','shrine','白石神社','北海道','札幌市','北海道札幌市白石区本通14丁目北1-12',43.04042,141.42819,1872,null,'https://shiroishijinja.jp/','白石区開拓の鎮守。神武天皇を祀り、初詣で賑わう白石区総鎮守。','https://ja.wikipedia.org/wiki/白石神社_(札幌市)','Wikipedia',true,now()),
('toyosaka-jinja-eniwa','豊栄神社（恵庭市）','とよさかじんじゃ','shrine','豊栄神社','北海道','恵庭市','北海道恵庭市大町3丁目6番5号',42.885506,141.568431,1874,null,null,'恵庭の開拓鎮守。大国魂大神・豊受姫神を祀る恵庭の総鎮守。','https://ja.wikipedia.org/wiki/豊栄神社_(恵庭市)','Wikipedia',true,now()),
('tojuin','等澍院','とうじゅいん','temple','天台宗','北海道','様似郡様似町','北海道様似郡様似町潮見台11-4',42.129583,142.919139,1806,'薬師瑠璃光如来','http://tojuin.jimdo.com/','江戸幕府が蝦夷地に建てた蝦夷三官寺の一つ。様似に位置する天台宗寺院。','https://ja.wikipedia.org/wiki/等澍院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 2) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='miyoshi-jinja-sapporo' and d.slug in ('miyoshi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='miyoshi-jinja-sapporo' and d.slug in ('okuninushi','sukunahikona'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sapporomura-jinja' and d.slug in ('okunitama','okuninushi','sukunahikona'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shiroishi-jinja-sapporo' and d.slug in ('jimmu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='toyosaka-jinja-eniwa' and d.slug in ('okunitama','toyouke'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tojuin' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- ===== ① 新規神仏 (batch 3用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tsugaru_nobumasa','津軽信政命','つがるのぶまさのみこと','kami','御霊','{}','史実','弘前藩4代藩主。津軽中興の名君として高照神社に祀られる。','https://ja.wikipedia.org/wiki/津軽信政','Wikipedia',true,now()),
('mazu','媽祖','まそ','kami','天部','{}','中国民間信仰','航海・漁業の守護女神。天妃・天后とも。日本では弁天と習合した。','https://ja.wikipedia.org/wiki/媽祖','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 (batch 3用) =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tsugaru_nobumasa' and g.slug in ('shusse','kaiun','gakumon'))
   or (d.slug='mazu' and g.slug in ('kaijo_anzen','suisan_noko','tabi_anzen'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 3) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takateru-jinja','高照神社','たかてるじんじゃ','shrine','高照神社（旧県社）','青森県','弘前市','青森県弘前市高岡字神馬野87',40.62325,140.35425,1712,null,null,'弘前藩4代藩主・津軽信政を祀る神社。重要文化財の社殿群が残る。','https://ja.wikipedia.org/wiki/高照神社','Wikipedia',true,now()),
('tsuruta-hachimangu','鶴田八幡宮','つるたはちまんぐう','shrine','鶴田八幡宮','青森県','北津軽郡鶴田町','青森県北津軽郡鶴田町鶴田字生松53',40.753778,140.430778,807,null,null,'譽田別命を祀る津軽の八幡宮。鶴の舞橋に近い鶴田町の鎮守。','https://ja.wikipedia.org/wiki/鶴田八幡宮','Wikipedia',true,now()),
('gumonji','求聞寺','ぐもんじ','temple','真言宗智山派','青森県','弘前市','青森県弘前市百沢字寺沢29',40.621917,140.344389,1629,'虚空蔵菩薩','https://ja.wikipedia.org/wiki/求聞寺','岩木山麓に建つ津軽藩祈願所。虚空蔵菩薩を本尊とする真言宗寺院。','https://ja.wikipedia.org/wiki/求聞寺','Wikipedia',true,now()),
('fumonin-hirosaki','普門院（弘前市）','ふもんいん','temple','曹洞宗','青森県','弘前市','青森県弘前市西茂森2丁目17-4',40.597028,140.453722,1678,'聖観音菩薩','https://ja.wikipedia.org/wiki/普門院_(弘前市)','弘前・禅林街に建つ曹洞宗の古刹。聖観音菩薩を本尊とする。','https://ja.wikipedia.org/wiki/普門院_(弘前市)','Wikipedia',true,now()),
('hoonji-hirosaki','報恩寺（弘前市）','ほうおんじ','temple','天台宗','青森県','弘前市','青森県弘前市新寺町34',40.59458,140.466063,1656,'釈迦如来','https://ja.wikipedia.org/wiki/報恩寺_(弘前市)','弘前・新寺町の天台宗寺院。釈迦如来を本尊とする津軽の名刹。','https://ja.wikipedia.org/wiki/報恩寺_(弘前市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 3) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takateru-jinja' and d.slug in ('tsugaru_nobumasa'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='takateru-jinja' and d.slug in ('takemikazuchi','amenokoyane','futsunushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tsuruta-hachimangu' and d.slug in ('hachiman'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='gumonji' and d.slug in ('kokuzo_bosatsu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fumonin-hirosaki' and d.slug in ('sho_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hoonji-hirosaki' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== ① 新規神仏 (batch 4用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tanichihiko','多邇知比古神','たにちひこのかみ','kami','国津神','{}','地方信仰','丹内山神社の主祭神。岩手・東和の地主神として信仰される。','https://ja.wikipedia.org/wiki/丹内山神社','Wikipedia',true,now()),
('gyoran_kannon','魚籃観音','ぎょらんかんのん','buddha','菩薩','{}','仏教','三十三観音の一。魚籃を持ち漁業・海上安全を守護する観音の化身。','https://ja.wikipedia.org/wiki/魚籃観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 (batch 4用) =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tanichihiko' and g.slug in ('kaiun','kanai_anzen','enmusubi'))
   or (d.slug='gyoran_kannon' and g.slug in ('kaijo_anzen','suisan_noko','byoki_heyu'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 4) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('taiguji','袋宮寺','たいぐうじ','temple','天台宗','青森県','弘前市','青森県弘前市新寺町26',40.596444,140.46625,1677,'十一面観音','https://www.taiguji.org/','弘前・新寺町の天台宗寺院。巨大な十一面観音立像で知られる。','https://ja.wikipedia.org/wiki/袋宮寺','Wikipedia',true,now()),
('inari-jinja-oma','稲荷神社（大間町）','いなりじんじゃ','shrine','稲荷神社','青森県','下北郡大間町','青森県下北郡大間町大字大間字大間91',41.525556,140.911389,1730,null,null,'本州最北・大間の鎮守。稲荷大神に媽祖・金毘羅・弁財天を合祀する海の社。','https://ja.wikipedia.org/wiki/稲荷神社_(大間町)','Wikipedia',true,now()),
('tannaisan-jinja','丹内山神社','たんないさんじんじゃ','shrine','丹内山神社','岩手県','花巻市','岩手県花巻市東和町谷内2-303',39.345944,141.28275,null,null,null,'巨大な胎内石「アラハバキ大神の巨石」で知られる東和の古社。','https://ja.wikipedia.org/wiki/丹内山神社','Wikipedia',true,now()),
('kamaishi-daikannon','釜石大観音','かまいしだいかんのん','temple','曹洞宗','岩手県','釜石市','岩手県釜石市平田3-9-1',39.256611,141.901028,1970,'魚籃観音','http://kamaishi-daikannon.com/','釜石湾を見下ろす高さ48.5mの魚籃観音像。曹洞宗石応寺が建立。','https://ja.wikipedia.org/wiki/釜石大観音','Wikipedia',true,now()),
('okama-jinja','御釜神社','おかまじんじゃ','shrine','御釜神社','宮城県','塩竈市','宮城県塩竈市本町6-1',38.316217,141.017869,null,null,null,'鹽竈神社の境外末社。製塩神話の神竈を祀り「藻塩焼神事」で知られる。','https://ja.wikipedia.org/wiki/御釜神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 4) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='taiguji' and d.slug in ('juichimen_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='inari-jinja-oma' and d.slug in ('ukanomitama'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='inari-jinja-oma' and d.slug in ('mazu','konpira','benzaiten'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tannaisan-jinja' and d.slug in ('tanichihiko'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='tannaisan-jinja' and d.slug in ('amenominakanushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kamaishi-daikannon' and d.slug in ('gyoran_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='okama-jinja' and d.slug in ('shiotsuchi'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 5) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('konpoji','箟峯寺','こんぽうじ','temple','天台宗','宮城県','遠田郡涌谷町','宮城県遠田郡涌谷町字箟岳山1',38.564833,141.179,807,'十一面観世音菩薩','http://www.town.wakuya.miyagi.jp/sangyo/kanko/konpouji.html','箟岳山上に建つ天台宗の古刹。奥州三十三観音第九番札所。','https://ja.wikipedia.org/wiki/箟峯寺','Wikipedia',true,now()),
('kozoji-kakuda','高蔵寺（角田市）','こうぞうじ','temple','真言宗智山派','宮城県','角田市','宮城県角田市高倉字寺前49',37.999861,140.718278,819,'阿弥陀如来','https://ja.wikipedia.org/wiki/高蔵寺_(角田市)','宮城県最古の木造建築・国指定重要文化財の阿弥陀堂で知られる古刹。','https://ja.wikipedia.org/wiki/高蔵寺_(角田市)','Wikipedia',true,now()),
('hanabushi-jinja','鼻節神社','はなぶしじんじゃ','shrine','鼻節神社（式内社）','宮城県','宮城郡七ヶ浜町','宮城県宮城郡七ヶ浜町花淵浜字誰道2',38.296061,141.084817,630,null,null,'松島湾を望む花淵岬に鎮座する式内社。猿田彦神を主祭神とする。','https://ja.wikipedia.org/wiki/鼻節神社','Wikipedia',true,now()),
('miyagi-gokoku-jinja','宮城縣護國神社','みやぎけんごこくじんじゃ','shrine','宮城縣護國神社','宮城県','仙台市','宮城県仙台市青葉区川内1',38.252194,140.855556,1904,null,'http://gokokujinja.org','仙台城本丸跡に鎮座する護国神社。宮城県関係の戦没者を祀る。','https://ja.wikipedia.org/wiki/宮城縣護國神社','Wikipedia',true,now()),
('soegawa-jinja','副川神社','そえがわじんじゃ','shrine','副川神社（式内社）','秋田県','南秋田郡八郎潟町','秋田県南秋田郡八郎潟町浦大町字小坂45',39.973333,140.087778,701,null,null,'出羽国三宮とされる式内社。高岳山上に鎮座する八郎潟の古社。','https://ja.wikipedia.org/wiki/副川神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 5) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='konpoji' and d.slug in ('juichimen_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kozoji-kakuda' and d.slug in ('amida_nyorai'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hanabushi-jinja' and d.slug in ('sarutahiko'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='hanabushi-jinja' and d.slug in ('toyouke','oyamatsumi','michizane'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='miyagi-gokoku-jinja' and d.slug in ('eirei'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='soegawa-jinja' and d.slug in ('amaterasu','toyouke','susanoo'))
on conflict do nothing;

-- ===== ① 新規神仏 (batch 6用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('uesugi_yozan','上杉鷹山','うえすぎようざん','kami','御霊','{}','史実','米沢藩中興の名君。藩政改革で知られ松岬神社に祀られる。','https://ja.wikipedia.org/wiki/上杉治憲','Wikipedia',true,now()),
('uesugi_kagekatsu','上杉景勝','うえすぎかげかつ','kami','御霊','{}','史実','米沢藩初代藩主。上杉謙信の養子で五大老の一人。','https://ja.wikipedia.org/wiki/上杉景勝','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 (batch 6用) =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='uesugi_yozan' and g.slug in ('shusse','gakumon','shigoto'))
   or (d.slug='uesugi_kagekatsu' and g.slug in ('shobu','shusse','kaiun'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 6) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tentokuji-akita','天徳寺（秋田市）','てんとくじ','temple','曹洞宗','秋田県','秋田市','秋田県秋田市泉三嶽根10-1',39.738664,140.120025,1462,'聖観音','https://ja.wikipedia.org/wiki/天徳寺_(秋田市)','秋田藩主佐竹氏の菩提寺。重要文化財の山門・本堂が残る曹洞宗寺院。','https://ja.wikipedia.org/wiki/天徳寺_(秋田市)','Wikipedia',true,now()),
('kanmanji','蚶満寺','かんまんじ','temple','曹洞宗','秋田県','にかほ市','秋田県にかほ市象潟町象潟島2',39.215417,139.903083,853,'釈迦如来','https://ja.wikipedia.org/wiki/蚶満寺','象潟の景勝地に建つ古刹。松尾芭蕉が訪れた地として名高い。','https://ja.wikipedia.org/wiki/蚶満寺','Wikipedia',true,now()),
('yamagata-gokoku-jinja','山形県護国神社','やまがたけんごこくじんじゃ','shrine','山形県護国神社','山形県','山形市','山形県山形市薬師町2-8-75',38.262564,140.347183,1869,null,'http://www.yamagataken-gokokujinja.jp/','山形市の薬師公園に鎮座する護国神社。山形県関係の戦没者を祀る。','https://ja.wikipedia.org/wiki/山形県護国神社','Wikipedia',true,now()),
('matsugasaki-jinja','松岬神社','まつがさきじんじゃ','shrine','松岬神社','山形県','米沢市','山形県米沢市丸の内1丁目3-60',37.909283,140.106619,1902,null,null,'上杉神社の摂社。名君・上杉鷹山と上杉景勝らを祀る米沢城跡の社。','https://ja.wikipedia.org/wiki/松岬神社','Wikipedia',true,now()),
('narushima-hachiman-jinja','成島八幡神社','なるしまはちまんじんじゃ','shrine','成島八幡神社','山形県','米沢市','山形県米沢市広幡町成島1058',37.930944,140.077861,777,null,'http://www.city.yonezawa.yamagata.jp/kanko/rekishi/pg/r09.html','坂上田村麻呂創建と伝わる古社。重要文化財の本殿が残る米沢の八幡宮。','https://ja.wikipedia.org/wiki/成島八幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 6) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tentokuji-akita' and d.slug in ('sho_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanmanji' and d.slug in ('shaka_nyorai'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yamagata-gokoku-jinja' and d.slug in ('eirei'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='matsugasaki-jinja' and d.slug in ('uesugi_yozan','uesugi_kagekatsu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='narushima-hachiman-jinja' and d.slug in ('hachiman'))
on conflict do nothing;

-- ===== ① 新規神仏 (batch 7用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kitabatake_akiie','北畠顕家','きたばたけあきいえ','kami','御霊','{}','史実','南朝方の公卿・武将。陸奥将軍府を率い霊山神社に祀られる。','https://ja.wikipedia.org/wiki/北畠顕家','Wikipedia',true,now()),
('kitabatake_chikafusa','北畠親房','きたばたけちかふさ','kami','御霊','{}','史実','南朝の重臣で『神皇正統記』の著者。霊山神社に祀られる。','https://ja.wikipedia.org/wiki/北畠親房','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 (batch 7用) =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kitabatake_akiie' and g.slug in ('shobu','gakumon','shusse'))
   or (d.slug='kitabatake_chikafusa' and g.slug in ('gakumon','gakugyo','kaiun'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 7) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daishoji-takahata','大聖寺（高畠町）','だいしょうじ','temple','真言宗智山派','山形県','東置賜郡高畠町','山形県東置賜郡高畠町亀岡41',37.980072,140.190139,807,'大日如来','https://kameokamonju.jp/','「亀岡文殊」として知られる日本三文殊の一。学業成就で信仰を集める。','https://ja.wikipedia.org/wiki/大聖寺_(山形県高畠町)','Wikipedia',true,now()),
('nihonmatsu-jinja','二本松神社','にほんまつじんじゃ','shrine','二本松神社','福島県','二本松市','福島県二本松市本町1丁目61',37.5925,140.434611,1145,null,'https://nihonmatsu-shrine.com/','二本松藩総鎮守。日本三大提灯祭りの一つ「二本松提灯祭り」で名高い。','https://ja.wikipedia.org/wiki/二本松神社','Wikipedia',true,now()),
('iwatsutsukowake-jinja','石都々古和気神社','いわつつこわけじんじゃ','shrine','石都々古和気神社（式内社）','福島県','石川郡石川町','福島県石川郡石川町下泉269',37.144972,140.450889,null,null,null,'八幡山の磐境信仰に発する陸奥国の式内社。三十三末社の巨石群で知られる。','https://ja.wikipedia.org/wiki/石都々古和気神社','Wikipedia',true,now()),
('kogaikuni-jinja','蚕養国神社','こがいくにじんじゃ','shrine','蚕養国神社（式内社）','福島県','会津若松市','福島県会津若松市蚕養町2番1号',37.504722,139.938806,811,null,'http://www.kogaikuni.com','養蚕の守護神を祀る会津の式内社。会津五桜「峰張桜」で知られる。','https://ja.wikipedia.org/wiki/蚕養国神社','Wikipedia',true,now()),
('ryozen-jinja','霊山神社','りょうぜんじんじゃ','shrine','霊山神社（別格官幣社）','福島県','伊達市','福島県伊達市霊山町大石字古城1',37.799,140.646472,1881,null,null,'南朝・北畠氏一族を祀る別格官幣社。霊山の麓に鎮座する。','https://ja.wikipedia.org/wiki/霊山神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 7) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daishoji-takahata' and d.slug in ('dainichi_nyorai','monju_bosatsu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nihonmatsu-jinja' and d.slug in ('izanami','hayatama'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='nihonmatsu-jinja' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iwatsutsukowake-jinja' and d.slug in ('ajisukitakahikone','okuninushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='iwatsutsukowake-jinja' and d.slug in ('hachiman'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kogaikuni-jinja' and d.slug in ('ukemochi','wakumusubi','amaterasu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ryozen-jinja' and d.slug in ('kitabatake_akiie','kitabatake_chikafusa'))
on conflict do nothing;

-- ===== ① 新規神仏 (batch 8用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('wakatoshi','若年神','わかとしのかみ','kami','国津神','{}','記紀','大年神の御子神。穀物・農耕の若々しい実りを司る。','https://ja.wikipedia.org/wiki/若年神','Wikipedia',true,now()),
('kayanohime','鹿屋野比売神','かやのひめのかみ','kami','国津神','{}','記紀','野や草を司る草祖神。野椎神とも呼ばれる。','https://ja.wikipedia.org/wiki/カヤノヒメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 (batch 8用) =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='wakatoshi' and g.slug in ('suisan_noko','shobai','kaiun'))
   or (d.slug='kayanohime' and g.slug in ('suisan_noko','kaiun','byoki_heyu'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 8) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hidaka-jinja','日高神社','ひだかじんじゃ','shrine','日高神社','岩手県','奥州市','岩手県奥州市水沢字日高小路13',39.142889,141.132361,810,null,null,'坂上田村麻呂創建と伝わる水沢の古社。重要文化財の本殿が残る。','https://ja.wikipedia.org/wiki/日高神社','Wikipedia',true,now()),
('hakusan-jinja-hiraizumi','白山神社（平泉町）','はくさんじんじゃ','shrine','白山神社','岩手県','西磐井郡平泉町','岩手県西磐井郡平泉町平泉衣関173番地',39.003333,141.100528,850,null,null,'中尊寺の鎮守社。茅葺の能舞台で奉納される「中尊寺薪能」で名高い。','https://ja.wikipedia.org/wiki/白山神社_(平泉町)','Wikipedia',true,now()),
('yubari-jinja','夕張神社','ゆうばりじんじゃ','shrine','夕張神社','北海道','夕張市','北海道夕張市住初6番地',43.064722,141.981694,1894,null,'http://www.hokkaidojinjacho.jp/data/05/05001.html','炭鉱の街・夕張の鎮守。大山祇神らを祀る夕張の総鎮守。','https://ja.wikipedia.org/wiki/夕張神社','Wikipedia',true,now()),
('yamanoue-daijingu','山上大神宮','やまのうえだいじんぐう','shrine','山上大神宮','北海道','函館市','北海道函館市船見町15-1',41.76625,140.701083,1368,null,'http://www.hokkaidojinjacho.jp/data/02/02004.html','函館山麓の古社。坂本龍馬の従者ゆかりの社として知られる。','https://ja.wikipedia.org/wiki/山上大神宮','Wikipedia',true,now()),
('iwamizawa-jinja','岩見沢神社','いわみざわじんじゃ','shrine','岩見沢神社','北海道','岩見沢市','北海道岩見沢市12条西1丁目3',43.195519,141.773078,1885,null,null,'岩見沢開拓の鎮守。天照大神・大国主神を祀る岩見沢の総鎮守。','https://ja.wikipedia.org/wiki/岩見沢神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 8) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hidaka-jinja' and d.slug in ('amenominakanushi','homusubi','otoshi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='hidaka-jinja' and d.slug in ('mitoshi','wakatoshi','mizuhanome','okuninushi','ukanomitama'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hakusan-jinja-hiraizumi' and d.slug in ('izanagi','izanami'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yubari-jinja' and d.slug in ('oyamatsumi','okuninushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='yubari-jinja' and d.slug in ('kayanohime','michizane'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yamanoue-daijingu' and d.slug in ('amaterasu','toyouke'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iwamizawa-jinja' and d.slug in ('amaterasu','okuninushi'))
on conflict do nothing;
