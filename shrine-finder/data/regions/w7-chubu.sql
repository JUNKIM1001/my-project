-- ============================================================
-- 御朱印ナビ データ拡張: 中部地方 (w7-chubu)
-- 担当県: 新潟・富山・石川・福井・山梨・長野・岐阜・静岡・愛知
-- 出典: ja.wikipedia.org infobox（十進座標で裏取り）
-- ============================================================

-- ① 新規神仏 -------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖を仏格化した如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{}','仏教','密教の本尊で宇宙の真理を体現する如来。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方浄瑠璃世界の教主で病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{}','仏教','千の手で衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('konohanasakuyahime','木花咲耶姫','このはなさくやひめ','kami','国津神','{}','記紀','富士山・浅間信仰の女神。安産・火防の神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now()),
('takemizuwake','武水別大神','たけみずわけのおおかみ','kami','国津神','{}','記紀','千曲川の水を司る水神。','https://ja.wikipedia.org/wiki/武水別神社','Wikipedia',true,now()),
('mononobe_futata','二田天物部命','ふたたあめのもののべのみこと','kami','天津神','{}','記紀','物部氏の祖神で越後二宮の祭神。','https://ja.wikipedia.org/wiki/物部神社_(柏崎市)','Wikipedia',true,now()),
('gokoku_eirei','護国の英霊','ごこくのえいれい','kami','御霊','{}','近代','国難に殉じた戦没者の御霊。','https://ja.wikipedia.org/wiki/護国神社','Wikipedia',true,now()),
('isotakeru','五十猛命','いそたけるのみこと','kami','天津神','{}','記紀','素戔嗚尊の子で植林・航海の神。','https://ja.wikipedia.org/wiki/イソタケル','Wikipedia',true,now()),
('takaokami','高龗神','たかおかみのかみ','kami','国津神','{}','記紀','水を司る龍神・雨乞いの神。','https://ja.wikipedia.org/wiki/オカミ神','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','八岐大蛇退治で知られる暴風雨・厄除の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{}','記紀','雷と剣の武神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now()),
('takeminakata','建御名方神','たけみなかたのかみ','kami','国津神','{}','記紀','諏訪信仰の祭神で武勇・農耕の神。','https://ja.wikipedia.org/wiki/タケミナカタ','Wikipedia',true,now()),
('takamimusubi','高皇産霊神','たかみむすひのかみ','kami','天津神','{}','記紀','万物の生成を司る造化三神の一柱。','https://ja.wikipedia.org/wiki/タカミムスビ','Wikipedia',true,now()),
('shiinetsuhiko','椎根津彦命','しいねつひこのみこと','kami','天津神','{}','記紀','神武東征を導いた海上の神。','https://ja.wikipedia.org/wiki/椎根津彦','Wikipedia',true,now()),
('omononushi','大物主神','おおものぬしのかみ','kami','国津神','{}','記紀','三輪山の神で国造り・農業・酒造の神。','https://ja.wikipedia.org/wiki/オオモノヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益 ------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shaka_nyorai' and g.slug in ('byoki_heyu','kaiun','yakubarai'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','ekibyo','choju'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','kaiun','byoki_heyu'))
or (d.slug='senju_kannon' and g.slug in ('byoki_heyu','enmusubi','kaiun'))
or (d.slug='konohanasakuyahime' and g.slug in ('anzan','kosodate','yakubarai'))
or (d.slug='takemizuwake' and g.slug in ('mizu_amagoi','suisan_noko','kaiun'))
or (d.slug='mononobe_futata' and g.slug in ('shobu','yakubarai','kaiun'))
or (d.slug='gokoku_eirei' and g.slug in ('kaiun','shobu','yakubarai'))
or (d.slug='isotakeru' and g.slug in ('suisan_noko','kaijo_anzen','shobai'))
or (d.slug='takaokami' and g.slug in ('mizu_amagoi','suisan_noko','kaiun'))
or (d.slug='susanoo' and g.slug in ('yakubarai','enmusubi','shobu'))
or (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','shusse'))
or (d.slug='takeminakata' and g.slug in ('shobu','suisan_noko','kaiun'))
or (d.slug='takamimusubi' and g.slug in ('kaiun','enmusubi','jouju'))
or (d.slug='shiinetsuhiko' and g.slug in ('kaijo_anzen','tabi_anzen','kaiun'))
or (d.slug='omononushi' and g.slug in ('shobai','byoki_heyu','kaiun'))
on conflict do nothing;

-- ③ 社寺 ----------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('soji-ji-soin','總持寺祖院','そうじじそいん','temple','曹洞宗','石川県','輪島市','石川県輪島市門前町門前1-18-1',37.28639,136.77056,1321,'釈迦牟尼仏','https://noto-soin.jp/','曹洞宗大本山總持寺の旧本山。能登の名刹。','https://ja.wikipedia.org/wiki/總持寺祖院','Wikipedia',true,now()),
('takemizuwake-jinja','武水別神社','たけみずわけじんじゃ','shrine','武水別神社（旧県社・名神大社）','長野県','千曲市','長野県千曲市八幡3012',36.5194667,138.1029750,null,null,'https://takemizuwake.jp/','信濃国四宮。八幡の杜に鎮まる名神大社。','https://ja.wikipedia.org/wiki/武水別神社','Wikipedia',true,now()),
('toyama-gokoku-jinja','富山縣護國神社','とやまけんごこくじんじゃ','shrine','富山縣護國神社（護国神社）','富山県','富山市','富山県富山市磯部町1-1',36.689806,137.201583,1913,null,'http://www.toyama-gokoku.jp/','富山県出身の戦没者を祀る護国神社。','https://ja.wikipedia.org/wiki/富山縣護國神社','Wikipedia',true,now()),
('fukui-gokoku-jinja','福井縣護國神社','ふくいけんごこくじんじゃ','shrine','福井縣護國神社（護国神社）','福井県','福井市','福井県福井市大宮2丁目13-18',36.081889,136.218330,1941,null,'http://www.fukuigokoku.jp/','福井県ゆかりの戦没者約3万2千柱を祀る。','https://ja.wikipedia.org/wiki/福井県護国神社','Wikipedia',true,now()),
('mononobe-jinja-kashiwazaki','物部神社','もののべじんじゃ','shrine','物部神社（旧県社・式内社）','新潟県','柏崎市','新潟県柏崎市西山町二田602',37.4541556,138.6751194,null,null,null,'越後国二宮とされる式内社。物部氏の祖神を祀る。','https://ja.wikipedia.org/wiki/物部神社_(柏崎市)','Wikipedia',true,now()),
('fukoji-urasa','普光寺','ふこうじ','temple','真言宗豊山派','新潟県','南魚沼市','新潟県南魚沼市浦佐2495',37.17028,138.91972,807,'大日如来','http://www.bisyamonnosato.com/top.html','浦佐毘沙門堂の裸押合大祭で知られる古刹。','https://ja.wikipedia.org/wiki/普光寺_(南魚沼市)','Wikipedia',true,now()),
('watatsu-jinja','度津神社','わたつじんじゃ','shrine','度津神社（佐渡国一宮・式内社）','新潟県','佐渡市','新潟県佐渡市羽茂飯岡550-4',37.8602500,138.3306389,null,null,null,'佐渡国一宮。五十猛命を祀る式内社。','https://ja.wikipedia.org/wiki/度津神社','Wikipedia',true,now()),
('murayama-sengen-jinja','村山浅間神社','むらやませんげんじんじゃ','shrine','村山浅間神社（富士山世界遺産構成資産）','静岡県','富士宮市','静岡県富士宮市村山字水神1151',35.261444,138.666139,null,null,null,'富士山修験の中心地。世界文化遺産の構成資産。','https://ja.wikipedia.org/wiki/村山浅間神社','Wikipedia',true,now()),
('hozo-ji-okazaki','法蔵寺','ほうぞうじ','temple','浄土宗西山深草派','愛知県','岡崎市','愛知県岡崎市本宿町寺山1',34.8887528,137.2616444,701,'阿弥陀如来','https://birthplace-tokugawa.com/','徳川家康が幼少期に学んだと伝わる古刹。','https://ja.wikipedia.org/wiki/法蔵寺_(岡崎市)','Wikipedia',true,now()),
('takisan-tosho-gu','滝山東照宮','たきさんとうしょうぐう','shrine','滝山東照宮（東照宮）','愛知県','岡崎市','愛知県岡崎市滝町山籠107',34.988389,137.205972,1646,null,null,'日光・久能山と並び称される三大東照宮の一つ。','https://ja.wikipedia.org/wiki/滝山東照宮','Wikipedia',true,now()),
('ogami-jinja-tonami','雄神神社','おがみじんじゃ','shrine','雄神神社（旧郷社・式内社）','富山県','砺波市','富山県砺波市庄川町庄6446',36.591500,136.997028,null,null,null,'庄川の名の由来となった水神を祀る式内社。','https://ja.wikipedia.org/wiki/雄神神社_(砺波市)','Wikipedia',true,now()),
('shinkomyo-ji','信光明寺','しんこうみょうじ','temple','浄土宗西山深草派','愛知県','岡崎市','愛知県岡崎市岩津町東山47',35.0029472,137.1750944,1451,'阿弥陀如来',null,'松平氏ゆかりの寺。観音堂は国の重要文化財。','https://ja.wikipedia.org/wiki/信光明寺','Wikipedia',true,now()),
('kasami-jinja','加佐美神社','かさみじんじゃ','shrine','加佐美神社（式内社）','岐阜県','各務原市','岐阜県各務原市蘇原古市場町5-1',35.422611,136.865500,864,null,null,'蘇原の産土神。応神天皇らを祀る式内社。','https://ja.wikipedia.org/wiki/加佐美神社','Wikipedia',true,now()),
('tentaku-ji','天澤寺','てんたくじ','temple','曹洞宗','山梨県','甲斐市','山梨県甲斐市亀沢2628',35.727220,138.528167,1475,'釈迦如来',null,'武田家臣ゆかりの曹洞宗寺院。六地蔵幢は県文化財。','https://ja.wikipedia.org/wiki/天澤寺','Wikipedia',true,now()),
('kanbara-jinja','蒲原神社','かんばらじんじゃ','shrine','蒲原神社（旧県社・式内論社）','新潟県','新潟市','新潟県新潟市中央区長嶺町3-18',37.914806,139.070111,null,null,'https://kanbarajinja.jp/','蒲原まつりで賑わう新潟市の古社。','https://ja.wikipedia.org/wiki/蒲原神社_(新潟市)','Wikipedia',true,now()),
('takamu-jinja-chikusa','高牟神社','たかむじんじゃ','shrine','高牟神社（式内社）','愛知県','名古屋市','愛知県名古屋市千種区今池1-4-18',35.169222,136.932528,null,null,'https://jinja-net.jp/takamujinja/','恋の三社めぐりの一社。古井の水で知られる式内社。','https://ja.wikipedia.org/wiki/高牟神社','Wikipedia',true,now()),
('shinpuku-ji-okazaki','真福寺','しんぷくじ','temple','天台宗','愛知県','岡崎市','愛知県岡崎市真福寺町薬師山6',35.0055111,137.1857944,594,'薬師如来','https://www.shinpukuji.com/','聖徳太子開創と伝わる三河最古級の寺。竹膳料理で有名。','https://ja.wikipedia.org/wiki/真福寺_(岡崎市)','Wikipedia',true,now()),
('ogushi-jinja','小梳神社','おぐしじんじゃ','shrine','小梳神社（旧県社）','静岡県','静岡市','静岡県静岡市葵区紺屋町7-13',34.973556,138.386333,null,null,null,'徳川家康が武運を祈ったと伝わる駿府の古社。','https://ja.wikipedia.org/wiki/小梳神社','Wikipedia',true,now()),
('hatori-jinja-hamamatsu','服織神社','はとりじんじゃ','shrine','服織神社（式内社）','静岡県','浜松市','静岡県浜松市中央区豊町2501',34.772361,137.804556,708,null,null,'機織の神を祀る遠江の式内社。','https://ja.wikipedia.org/wiki/服織神社_(浜松市)','Wikipedia',true,now()),
('chokei-ji-toyama','長慶寺','ちょうけいじ','temple','曹洞宗','富山県','富山市','富山県富山市五艘1882',36.711472,137.190361,1786,'釈迦如来',null,'富山藩主ゆかり。五百羅漢の石仏群で知られる。','https://ja.wikipedia.org/wiki/長慶寺_(富山市)','Wikipedia',true,now()),
('saiko-ji-fukui','西光寺','さいこうじ','temple','天台真盛宗','福井県','福井市','福井県福井市左内町8-21',36.058417,136.213167,1489,'阿弥陀如来','https://saikouji-fukui.jp/','柴田勝家・お市の方の墓所がある寺。','https://ja.wikipedia.org/wiki/西光寺_(福井市)','Wikipedia',true,now()),
('kubo-hachiman-jinja','大井俣窪八幡神社','おおいまたくぼはちまんじんじゃ','shrine','大井俣窪八幡神社（八幡宮）','山梨県','山梨市','山梨県山梨市北654',35.704722,138.690056,859,null,'http://kubohachiman.com/','武田氏が崇敬した八幡宮。本殿は重要文化財。','https://ja.wikipedia.org/wiki/大井俣窪八幡神社','Wikipedia',true,now()),
('miwa-jinja-fuefuki','美和神社','みわじんじゃ','shrine','美和神社（甲斐国二宮・式内社）','山梨県','笛吹市','山梨県笛吹市御坂町二之宮1450-1',35.629917,138.653556,null,null,null,'甲斐国二宮。大物主神を祀る式内社。','https://ja.wikipedia.org/wiki/美和神社_(笛吹市)','Wikipedia',true,now()),
('fukuon-ji','福光園寺','ふくおんじ','temple','真言宗智山派','山梨県','笛吹市','山梨県笛吹市御坂町大野寺2027',35.608528,138.675500,null,'不動明王',null,'運慶派・蓮慶作の吉祥天像（重文）で知られる古刹。','https://ja.wikipedia.org/wiki/福光園寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け -------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='soji-ji-soin' and d.slug in ('shaka_nyorai'))
or (t.slug='takemizuwake-jinja' and d.slug in ('takemizuwake'))
or (t.slug='toyama-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='fukui-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='mononobe-jinja-kashiwazaki' and d.slug in ('mononobe_futata'))
or (t.slug='fukoji-urasa' and d.slug in ('dainichi_nyorai'))
or (t.slug='watatsu-jinja' and d.slug in ('isotakeru'))
or (t.slug='murayama-sengen-jinja' and d.slug in ('konohanasakuyahime'))
or (t.slug='hozo-ji-okazaki' and d.slug in ('amida_nyorai'))
or (t.slug='takisan-tosho-gu' and d.slug in ('ieyasu'))
or (t.slug='ogami-jinja-tonami' and d.slug in ('takaokami'))
or (t.slug='shinkomyo-ji' and d.slug in ('amida_nyorai'))
or (t.slug='kasami-jinja' and d.slug in ('hachiman'))
or (t.slug='tentaku-ji' and d.slug in ('shaka_nyorai'))
or (t.slug='kanbara-jinja' and d.slug in ('shiinetsuhiko'))
or (t.slug='takamu-jinja-chikusa' and d.slug in ('takamimusubi','hachiman'))
or (t.slug='shinpuku-ji-okazaki' and d.slug in ('yakushi_nyorai'))
or (t.slug='ogushi-jinja' and d.slug in ('susanoo'))
or (t.slug='hatori-jinja-hamamatsu' and d.slug in ('takeminakata'))
or (t.slug='chokei-ji-toyama' and d.slug in ('shaka_nyorai'))
or (t.slug='saiko-ji-fukui' and d.slug in ('amida_nyorai'))
or (t.slug='kubo-hachiman-jinja' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='miwa-jinja-fuefuki' and d.slug in ('omononushi'))
or (t.slug='fukuon-ji' and d.slug in ('fudo_myoo'))
on conflict do nothing;
