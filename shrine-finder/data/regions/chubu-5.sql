-- 中部地方 社寺データ拡張 chubu-5
-- 対象県: 新潟,富山,石川,福井,山梨,長野,岐阜,静岡,愛知
-- 出典: ja.wikipedia.org の infobox 十進座標で裏取り。_have_chubu.txt と重複なし。

-- ============================================================
-- バッチ1 (愛知・岐阜)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('montoku_tenno','文徳天皇','もんとくてんのう','kami','御霊','{}','史実','平安時代の第55代天皇。社の祖神として祀られる。','https://ja.wikipedia.org/wiki/文徳天皇','Wikipedia',true,now()),
('otoyo','乎止與命','おとよのみこと','kami','国津神','{}','記紀','尾張国造の祖。熱田神宮の宮簀媛の父神。','https://ja.wikipedia.org/wiki/乎止與命','Wikipedia',true,now()),
('iwanagahime','石長比売','いわながひめ','kami','国津神','{}','記紀','大山祇神の娘で木花咲耶姫の姉。長寿・縁結びの神。','https://ja.wikipedia.org/wiki/イワナガヒメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='montoku_tenno' and g.slug in ('kaiun','yakubarai'))
   or (d.slug='otoyo' and g.slug in ('kaiun','shobai'))
   or (d.slug='iwanagahime' and g.slug in ('choju','enmusubi','majo_kekkai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mama-kannon','間々観音','ままかんのん','temple','浄土宗','愛知県','小牧市','愛知県小牧市間々本町間々観音152',35.295028,136.909472,1492,'千手観音','https://mamakannon.wixsite.com/index','日本で唯一の「乳の観音」。子育て・安産・授乳祈願で知られる。','https://ja.wikipedia.org/wiki/間々観音','Wikipedia',true,now()),
('ibun-jinja','伊文神社','いぶんじんじゃ','shrine','伊文神社','愛知県','西尾市','愛知県西尾市伊文町17',34.870222,137.057389,null,null,'https://www.ibunjinja.net/','西尾の総鎮守。文徳天皇を祀り、西尾祭で知られる。','https://ja.wikipedia.org/wiki/伊文神社','Wikipedia',true,now()),
('mikawa-kokubunji','三河国分寺','みかわこくぶんじ','temple','曹洞宗','愛知県','豊川市','愛知県豊川市八幡町本郷31',34.8381806,137.3423417,741,'薬師如来','https://ja.wikipedia.org/wiki/三河国分寺','聖武天皇の詔により創建された三河国の国分寺。塔跡が国史跡。','https://ja.wikipedia.org/wiki/三河国分寺','Wikipedia',true,now()),
('choko-ji-toyota','長興寺','ちょうこうじ','temple','臨済宗東福寺派','愛知県','豊田市','愛知県豊田市長興寺1-29',35.0737444,137.1680944,1335,'十一面観音','https://ja.wikipedia.org/wiki/長興寺_(豊田市)','織田信長の肖像画(重要文化財)を所蔵する古刹。','https://ja.wikipedia.org/wiki/長興寺_(豊田市)','Wikipedia',true,now()),
('izu-jinja-gifu','伊豆神社','いずじんじゃ','shrine','伊豆神社','岐阜県','岐阜市','岐阜県岐阜市切通12-49',35.3993083,136.7942417,null,null,'https://ja.wikipedia.org/wiki/伊豆神社','岐阜市切通に鎮座。石長比売命を祀り縁結び・長寿の社。','https://ja.wikipedia.org/wiki/伊豆神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mama-kannon' and d.slug in ('senju_kannon'))
   or (t.slug='ibun-jinja' and d.slug in ('susanoo','okuninushi','montoku_tenno'))
   or (t.slug='mikawa-kokubunji' and d.slug in ('yakushi_nyorai'))
   or (t.slug='choko-ji-toyota' and d.slug in ('juichimen_kannon'))
   or (t.slug='izu-jinja-gifu' and d.slug in ('iwanagahime'))
on conflict do nothing;

-- ============================================================
-- バッチ2 (岐阜)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('oyayaishiki','大八椅命','おおやはしのみこと','kami','国津神','{}','記紀','飛騨国造の祖神。飛騨総社の主祭神。','https://ja.wikipedia.org/wiki/飛騨総社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='oyayaishiki' and g.slug in ('kaiun','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('eiho-ji','永保寺','えいほうじ','temple','臨済宗南禅寺派','岐阜県','多治見市','岐阜県多治見市虎渓山町1-40',35.34667,137.13083,1313,'聖観世音菩薩','https://kokeizan.or.jp/','夢窓疎石が開いた虎渓山の禅刹。観音堂・開山堂が国宝の名園。','https://ja.wikipedia.org/wiki/永保寺','Wikipedia',true,now()),
('miroku-ji-seki','弥勒寺','みろくじ','temple','天台寺門宗','岐阜県','関市','岐阜県関市池尻10-1',35.506194,136.893333,680,'弥勒菩薩','https://ja.wikipedia.org/wiki/弥勒寺_(関市)','円空が再興し、晩年を過ごした寺。円空入定の地として知られる。','https://ja.wikipedia.org/wiki/弥勒寺_(関市)','Wikipedia',true,now()),
('hida-soja','飛騨総社','ひだそうじゃ','shrine','飛騨総社','岐阜県','高山市','岐阜県高山市神田町2-114',36.148167,137.254222,931,null,'https://ja.wikipedia.org/wiki/飛騨総社','飛騨国内の神社を合祀した総社。高山の古社。','https://ja.wikipedia.org/wiki/飛騨総社','Wikipedia',true,now()),
('ankoku-ji-takayama','安国寺','あんこくじ','temple','臨済宗妙心寺派','岐阜県','高山市','岐阜県高山市国府町西門前474',36.2245972,137.2450417,1347,'釈迦牟尼仏','https://ja.wikipedia.org/wiki/安国寺_(高山市)','足利氏が諸国に建立した安国寺の一つ。経蔵が国宝。','https://ja.wikipedia.org/wiki/安国寺_(高山市)','Wikipedia',true,now()),
('daichi-ji-gifu','大智寺','だいちじ','temple','臨済宗妙心寺派','岐阜県','岐阜市','岐阜県岐阜市山県北野668-1',35.509972,136.841083,1500,'釈迦如来','https://ja.wikipedia.org/wiki/大智寺_(岐阜市)','美濃三十三観音霊場の札所。山県の古刹。','https://ja.wikipedia.org/wiki/大智寺_(岐阜市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='eiho-ji' and d.slug in ('sho_kannon'))
   or (t.slug='miroku-ji-seki' and d.slug in ('miroku_bosatsu'))
   or (t.slug='hida-soja' and d.slug in ('oyayaishiki'))
   or (t.slug='ankoku-ji-takayama' and d.slug in ('shaka_nyorai'))
   or (t.slug='daichi-ji-gifu' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ============================================================
-- バッチ3 (長野)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sakuma_shozan','佐久間象山','さくましょうざん','kami','御霊','{}','史実','幕末の松代藩士・思想家。学問・開明の祖として祀られる。','https://ja.wikipedia.org/wiki/象山神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sakuma_shozan' and g.slug in ('gakumon','gakugyo','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zozan-jinja','象山神社','ぞうざんじんじゃ','shrine','象山神社','長野県','長野市','長野県長野市松代町松代竹山町1502',36.560028,138.196194,1938,null,'https://www.zozan.jp/','幕末の思想家・佐久間象山を祀る。松代に鎮座し学問の神として崇敬。','https://ja.wikipedia.org/wiki/象山神社','Wikipedia',true,now()),
('suwa-taisha-kamisha-maemiya','諏訪大社上社前宮','すわたいしゃかみしゃまえみや','shrine','諏訪大社','長野県','茅野市','長野県茅野市宮川2030',35.9911333,138.1334111,null,null,'http://suwataisha.or.jp/','諏訪大社四宮の一つ。上社前宮として八坂刀売神を祀る古社。','https://ja.wikipedia.org/wiki/諏訪大社','Wikipedia',true,now()),
('kaizen-ji-iida','開善寺','かいぜんじ','temple','臨済宗妙心寺派','長野県','飯田市','長野県飯田市上川路1000',35.462306,137.815056,1335,'聖観音菩薩','https://ja.wikipedia.org/wiki/開善寺_(飯田市)','小笠原貞宗が開いた信濃の禅刹。山門が重要文化財。','https://ja.wikipedia.org/wiki/開善寺_(飯田市)','Wikipedia',true,now()),
('chishiki-ji-chikuma','智識寺','ちしきじ','temple','真言宗智山派','長野県','千曲市','長野県千曲市上山田1197',36.46603,138.1405,740,'十一面観世音菩薩','https://ja.wikipedia.org/wiki/智識寺_(千曲市)','聖武天皇ゆかりと伝わる古刹。大御堂が重要文化財。','https://ja.wikipedia.org/wiki/智識寺_(千曲市)','Wikipedia',true,now()),
('teisho-ji-saku','貞祥寺','ていしょうじ','temple','曹洞宗','長野県','佐久市','長野県佐久市前山1380-1',36.216472,138.448944,1521,'釈迦牟尼如来','https://ja.wikipedia.org/wiki/貞祥寺','伴野氏が開いた佐久の名刹。三重塔・山門が県宝。','https://ja.wikipedia.org/wiki/貞祥寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zozan-jinja' and d.slug in ('sakuma_shozan'))
   or (t.slug='suwa-taisha-kamisha-maemiya' and d.slug in ('yasakatome'))
   or (t.slug='kaizen-ji-iida' and d.slug in ('sho_kannon'))
   or (t.slug='chishiki-ji-chikuma' and d.slug in ('juichimen_kannon'))
   or (t.slug='teisho-ji-saku' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ============================================================
-- バッチ4 (富山・新潟・石川・福井)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('maeda_toshitsune','前田利常','まえだとしつね','kami','御霊','{}','史実','加賀藩三代藩主。小松天満宮などに祀られる。','https://ja.wikipedia.org/wiki/小松天満宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='maeda_toshitsune' and g.slug in ('kaiun','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oyama-jinja-minemotosha','雄山神社峰本社','おやまじんじゃみねもとしゃ','shrine','雄山神社','富山県','中新川郡立山町','富山県中新川郡立山町立山峰1',36.5731778,137.6179194,null,null,'http://www.oyamajinja.org/','立山山頂(雄山)に鎮座する越中一宮の本社。霊峰立山の信仰の中心。','https://ja.wikipedia.org/wiki/雄山神社','Wikipedia',true,now()),
('kakugan-ji','各願寺','かくがんじ','temple','真言宗','富山県','富山市','富山県富山市長沢5692',36.65694,137.11917,701,'薬師如来','https://ja.wikipedia.org/wiki/各願寺','立山開山ゆかりと伝わる古刹。越中の真言古刹。','https://ja.wikipedia.org/wiki/各願寺','Wikipedia',true,now()),
('kanko-ji-minamiuonuma','関興寺','かんこうじ','temple','臨済宗円覚寺派','新潟県','南魚沼市','新潟県南魚沼市上野267',36.989361,138.797639,1410,'釈迦牟尼仏','https://ja.wikipedia.org/wiki/関興寺','「関興寺の味噌なめたか」で知られる上田庄の禅刹。','https://ja.wikipedia.org/wiki/関興寺','Wikipedia',true,now()),
('komatsu-tenmangu','小松天満宮','こまつてんまんぐう','shrine','天満宮','石川県','小松市','石川県小松市天神町1',36.41583,136.44861,1657,null,'https://ja.wikipedia.org/wiki/小松天満宮','加賀藩前田利常が創建した梯川中州の天満宮。本殿が重要文化財。','https://ja.wikipedia.org/wiki/小松天満宮','Wikipedia',true,now()),
('daian-zenji','大安禅寺','だいあんぜんじ','temple','臨済宗妙心寺派','福井県','福井市','福井県福井市田ノ谷町21-4',36.101972,136.167806,1658,'釈迦如来','http://www.daianzenji.jp','福井藩松平家の菩提寺。花菖蒲と千畳敷大墓地で知られる。','https://ja.wikipedia.org/wiki/大安禅寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（主祭神/本尊）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oyama-jinja-minemotosha' and d.slug in ('izanagi'))
   or (t.slug='kakugan-ji' and d.slug in ('yakushi_nyorai'))
   or (t.slug='kanko-ji-minamiuonuma' and d.slug in ('shaka_nyorai'))
   or (t.slug='komatsu-tenmangu' and d.slug in ('michizane'))
   or (t.slug='daian-zenji' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ④ 配祀
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='oyama-jinja-minemotosha' and d.slug in ('amenotajikarao'))
   or (t.slug='komatsu-tenmangu' and d.slug in ('maeda_toshitsune'))
on conflict do nothing;

-- ============================================================
-- バッチ5 (福井・山梨・静岡・愛知)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yanahime','矢奈比売大神','やなひめのおおかみ','kami','国津神','{}','記紀','見付天神(矢奈比売神社)の主祭神。地域の守護神。','https://ja.wikipedia.org/wiki/矢奈比売神社','Wikipedia',true,now()),
('matsudaira_hideyasu','松平秀康','まつだいらひでやす','kami','御霊','{}','史実','徳川家康の次男で越前福井藩祖。福井の社に祀られる。','https://ja.wikipedia.org/wiki/結城秀康','Wikipedia',true,now()),
('matsudaira_yoshinaga','松平慶永','まつだいらよしなが','kami','御霊','{}','史実','幕末の福井藩主・春嶽。福井の社に祀られる。','https://ja.wikipedia.org/wiki/松平春嶽','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yanahime' and g.slug in ('kaiun','gakumon'))
   or (d.slug='matsudaira_hideyasu' and g.slug in ('kaiun','shusse'))
   or (d.slug='matsudaira_yoshinaga' and g.slug in ('kaiun','gakumon'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sakaenoyashiro','佐佳枝廼社','さかえのやしろ','shrine','佐佳枝廼社','福井県','福井市','福井県福井市大手3-12-3',36.0644111,136.2183028,1628,null,'https://www.sakaenoyashiro.or.jp','福井城内に鎮座する越前東照宮。徳川家康・松平秀康・春嶽を祀る。','https://ja.wikipedia.org/wiki/佐佳枝廼社','Wikipedia',true,now()),
('enko-ji-kofu','塩澤寺','えんこうじ','temple','真言宗智山派','山梨県','甲府市','山梨県甲府市湯村3-17-2',35.6846972,138.547472,955,'地蔵菩薩','https://ja.wikipedia.org/wiki/塩澤寺','湯村温泉の厄除地蔵で知られる古刹。厄除地蔵尊大祭で賑わう。','https://ja.wikipedia.org/wiki/塩澤寺','Wikipedia',true,now()),
('onmyo-ji-fuefuki','遠妙寺','おんみょうじ','temple','日蓮宗','山梨県','笛吹市','山梨県笛吹市石和町市部1016',35.650972,138.640222,1390,'十界曼荼羅','https://ja.wikipedia.org/wiki/遠妙寺_(笛吹市)','日蓮が鵜飼の亡霊を済度した伝説で知られる石和の古刹。','https://ja.wikipedia.org/wiki/遠妙寺_(笛吹市)','Wikipedia',true,now()),
('yanahime-jinja','矢奈比売神社','やなひめじんじゃ','shrine','矢奈比売神社','静岡県','磐田市','静岡県磐田市見付1114-2',34.729778,137.864083,null,null,'https://mitsuke-tenjin.com/','見付天神として親しまれる遠江の古社。霊犬悟空伝説と裸祭で有名。','https://ja.wikipedia.org/wiki/矢奈比売神社','Wikipedia',true,now()),
('ueji-hachimangu','上地八幡宮','うえじはちまんぐう','shrine','八幡宮','愛知県','岡崎市','愛知県岡崎市上地町字宮脇48',34.90750,137.15917,1190,null,'http://ueji80000.com/','源範頼の勧請と伝わる岡崎の八幡宮。徳川家康ゆかりの社。','https://ja.wikipedia.org/wiki/上地八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（主祭神/本尊）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sakaenoyashiro' and d.slug in ('ieyasu'))
   or (t.slug='enko-ji-kofu' and d.slug in ('jizo_bosatsu'))
   or (t.slug='onmyo-ji-fuefuki' and d.slug in ('nichiren'))
   or (t.slug='yanahime-jinja' and d.slug in ('yanahime'))
   or (t.slug='ueji-hachimangu' and d.slug in ('hachiman'))
on conflict do nothing;

-- ④ 配祀
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='sakaenoyashiro' and d.slug in ('matsudaira_hideyasu','matsudaira_yoshinaga'))
   or (t.slug='yanahime-jinja' and d.slug in ('michizane','kagutsuchi'))
on conflict do nothing;

-- ============================================================
-- バッチ6 (愛知・岐阜)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('seishi_bosatsu','勢至菩薩','せいしぼさつ','buddha','菩薩','{}','仏教','智慧の光で衆生を救う菩薩。阿弥陀三尊の脇侍。','https://ja.wikipedia.org/wiki/勢至菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='seishi_bosatsu' and g.slug in ('gakumon','kaiun','byoki_heyu'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tobe-jinja','富部神社','とべじんじゃ','shrine','富部神社','愛知県','名古屋市','愛知県名古屋市南区呼続4-13-38',35.105222,136.931500,1603,null,'http://www.tobe-shrine.org/','戸部天王とも呼ばれる南区の古社。本殿が重要文化財。','https://ja.wikipedia.org/wiki/富部神社','Wikipedia',true,now()),
('nanatsu-dera','七寺','ななつでら','temple','真言宗智山派','愛知県','名古屋市','愛知県名古屋市中区大須2-28-5',35.158194,136.900083,735,'観音菩薩','https://ja.wikipedia.org/wiki/七寺','大須に伝わる古刹。七寺一切経で知られる。','https://ja.wikipedia.org/wiki/七寺','Wikipedia',true,now()),
('bansho-ji','萬松寺','ばんしょうじ','temple','単立','愛知県','名古屋市','愛知県名古屋市中区大須3-29-12',35.1591250,136.9046889,1540,'十一面観音','http://www.banshoji.or.jp/','織田信秀が創建した織田家の菩提寺。大須の繁華街に立つ。','https://ja.wikipedia.org/wiki/萬松寺','Wikipedia',true,now()),
('kuranomori-hachimansha','闇之森八幡社','くらがりのもりはちまんしゃ','shrine','八幡社','愛知県','名古屋市','愛知県名古屋市中区正木2-6-18',35.148306,136.896389,1163,null,'https://ja.wikipedia.org/wiki/闇之森八幡社','闇の森(くらがりのもり)に鎮座する名古屋の八幡社。','https://ja.wikipedia.org/wiki/闇之森八幡社','Wikipedia',true,now()),
('kano-tenmangu','加納天満宮','かのうてんまんぐう','shrine','天満宮','岐阜県','岐阜市','岐阜県岐阜市加納天神町4-1',35.40694,136.75861,1445,null,'https://www.kanotenmangu.com/','加納城下の鎮守。斎藤利永が創建したと伝わる学問の社。','https://ja.wikipedia.org/wiki/加納天満宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tobe-jinja' and d.slug in ('susanoo'))
   or (t.slug='nanatsu-dera' and d.slug in ('sho_kannon','seishi_bosatsu'))
   or (t.slug='bansho-ji' and d.slug in ('juichimen_kannon'))
   or (t.slug='kuranomori-hachimansha' and d.slug in ('hachiman','jingu_kogo'))
   or (t.slug='kano-tenmangu' and d.slug in ('michizane'))
on conflict do nothing;

-- ============================================================
-- バッチ7 (静岡・山梨)
-- ============================================================

-- ① 新規神仏（既存柱で充足のため追加なし）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('izu-kokubunji','伊豆国分寺','いずこくぶんじ','temple','日蓮宗','静岡県','三島市','静岡県三島市泉町12-31',35.1200833,138.9097389,741,'釈迦如来','https://ja.wikipedia.org/wiki/伊豆国分寺','聖武天皇の詔で建立された伊豆国の国分寺。塔跡が国史跡。','https://ja.wikipedia.org/wiki/伊豆国分寺','Wikipedia',true,now()),
('ryuge-ji-shizuoka','龍華寺','りゅうげじ','temple','日蓮宗','静岡県','静岡市','静岡県静岡市清水区村松2085',34.990500,138.48444,1670,'釈迦如来','https://ja.wikipedia.org/wiki/龍華寺_(静岡市)','駿河湾と富士を望む観富山の日蓮宗寺院。大蘇鉄で有名。','https://ja.wikipedia.org/wiki/龍華寺_(静岡市)','Wikipedia',true,now()),
('higashiguchi-hongu-fuji-sengen','東口本宮冨士浅間神社','ひがしぐちほんぐうふじせんげんじんじゃ','shrine','浅間神社','静岡県','駿東郡小山町','静岡県駿東郡小山町須走126',35.362361,138.863389,807,null,'http://www.higashiguchi-fujisengenjinja.or.jp/index.html','富士山須走口登山道の起点に鎮座する浅間神社。世界遺産構成資産。','https://ja.wikipedia.org/wiki/東口本宮冨士浅間神社','Wikipedia',true,now()),
('omikuni-tama-jinja','淡海國玉神社','おうみくにたまじんじゃ','shrine','淡海國玉神社','静岡県','磐田市','静岡県磐田市見付2451',34.727806,137.857139,null,null,'https://ja.wikipedia.org/wiki/淡海國玉神社','遠江国の総社。見付の府八幡宮とともに国府の鎮守。','https://ja.wikipedia.org/wiki/淡海國玉神社','Wikipedia',true,now()),
('daizokyo-ji','大蔵経寺','だいぞうきょうじ','temple','真言宗智山派','山梨県','笛吹市','山梨県笛吹市石和町松本610',35.660583,138.633639,722,'不動明王','https://ja.wikipedia.org/wiki/大蔵経寺','武田氏ゆかりの石和の古刹。甲斐百八霊場の札所。','https://ja.wikipedia.org/wiki/大蔵経寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='izu-kokubunji' and d.slug in ('shaka_nyorai'))
   or (t.slug='ryuge-ji-shizuoka' and d.slug in ('shaka_nyorai'))
   or (t.slug='higashiguchi-hongu-fuji-sengen' and d.slug in ('konohanasakuyahime'))
   or (t.slug='omikuni-tama-jinja' and d.slug in ('okuninushi'))
   or (t.slug='daizokyo-ji' and d.slug in ('fudo_myoo'))
on conflict do nothing;
