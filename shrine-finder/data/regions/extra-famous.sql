-- 全国 著名社寺 追加バッチ（12件）— 出典: 日本語Wikipedia 各記事 infobox（座標・所在地・御祭神/本尊）
-- 親（Claude）が直接WebFetchで裏取り。すべて実在・参拝可能。

-- ① 新規神仏（既存14柱に無いもの）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takemikazuchi','武甕槌神','たけみかづちのかみ','kami','天津神（武神）','{"建御雷神","鹿島神"}','記紀','雷と剣を司る武神。国譲り神話で活躍。鹿島神宮・春日大社の御祭神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now()),
('futsunushi','経津主神','ふつぬしのかみ','kami','天津神（武神）','{"香取神"}','記紀','刀剣・武の神。武甕槌神とともに国譲りに活躍。','https://ja.wikipedia.org/wiki/経津主神','Wikipedia',true,now()),
('amenokoyane','天児屋根命','あめのこやねのみこと','kami','天津神','{"春日権現"}','記紀','祝詞を司る神。藤原氏の祖神。春日大社の御祭神の一柱。','https://ja.wikipedia.org/wiki/アメノコヤネ','Wikipedia',true,now()),
('susanoo','須佐之男命','すさのおのみこと','kami','記紀神','{"素戔嗚尊","牛頭天王習合"}','記紀','天照大神の弟神。八岐大蛇退治の英雄神で、疫病除けの信仰を集める。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('omononushi','大物主神','おおものぬしのかみ','kami','国津神','{"金毘羅習合"}','記紀','三輪山・金刀比羅宮の神。海上守護・農業・醸造の神。','https://ja.wikipedia.org/wiki/オオモノヌシ','Wikipedia',true,now()),
('takeminakata','建御名方神','たけみなかたのかみ','kami','国津神','{"諏訪明神"}','記紀','諏訪大社の御祭神。武神・農耕神・狩猟の神。','https://ja.wikipedia.org/wiki/タケミナカタ','Wikipedia',true,now()),
('ketsumimiko','家都美御子大神','けつみみこのおおかみ','kami','熊野神','{"熊野権現","素戔嗚尊習合"}','その他','熊野本宮大社の主祭神。熊野三山信仰の中心神。','https://ja.wikipedia.org/wiki/熊野本宮大社','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{"無量寿仏"}','仏教','極楽浄土を司る如来。善光寺の本尊（一光三尊阿弥陀如来）。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('senju_kannon','千手観音菩薩','せんじゅかんのんぼさつ','buddha','菩薩','{"十一面千手観世音菩薩"}','仏教','千の手で衆生を救う観音。清水寺の本尊。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{"医王如来"}','仏教','病を癒やす医薬の如来。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takemikazuchi' and g.slug in ('bochu','shobu','yakubarai','kaiun'))
 or (d.slug='futsunushi'    and g.slug in ('bochu','shobu','yakubarai'))
 or (d.slug='amenokoyane'   and g.slug in ('gakumon','shusse','shigoto'))
 or (d.slug='susanoo'       and g.slug in ('ekibyo','yakubarai','enmusubi','kaiun'))
 or (d.slug='omononushi'    and g.slug in ('kaijo_anzen','shobai','byoki_heyu','kaiun','tabi_anzen'))
 or (d.slug='takeminakata'  and g.slug in ('bochu','shobu','suisan_noko','kaiun'))
 or (d.slug='ketsumimiko'   and g.slug in ('kaiun','yakubarai','jouju','tabi_anzen'))
 or (d.slug='amida_nyorai'  and g.slug in ('jouju','byoki_heyu','choju'))
 or (d.slug='senju_kannon'  and g.slug in ('kaiun','byoki_heyu','enmusubi','jouju','shobu'))
 or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kasuga-taisha','春日大社','かすがたいしゃ','shrine','旧官幣大社・二十二社・名神大社','奈良県','奈良市','奈良県奈良市春日野町160',34.681390,135.848330,768,null,'https://www.kasugataisha.or.jp/','藤原氏の氏神を祀る世界遺産。朱塗りの社殿と燈籠で知られる。','https://ja.wikipedia.org/wiki/春日大社','Wikipedia',true,now()),
('yasaka-jinja','八坂神社','やさかじんじゃ','shrine','旧官幣大社・別表神社','京都府','京都市東山区','京都府京都市東山区祇園町北側625',35.003610,135.778610,656,null,'https://www.yasaka-jinja.or.jp/','祇園さん。須佐之男命を祀り、疫病除けの祇園祭で名高い。','https://ja.wikipedia.org/wiki/八坂神社','Wikipedia',true,now()),
('kitano-tenmangu','北野天満宮','きたのてんまんぐう','shrine','旧官幣中社・二十二社','京都府','京都市上京区','京都府京都市上京区馬喰町',35.029194,135.735000,947,null,'https://www.kitanotenmangu.or.jp/','菅原道真を祀る天神信仰の中心。梅と学業成就で知られる。','https://ja.wikipedia.org/wiki/北野天満宮','Wikipedia',true,now()),
('kiyomizu-dera','音羽山清水寺','おとわさんきよみずでら','temple','北法相宗','京都府','京都市東山区','京都府京都市東山区清水1丁目294',34.994831,135.785003,778,'十一面千手観世音菩薩','https://www.kiyomizudera.or.jp/','清水の舞台で有名な世界遺産。千手観音を本尊とする観音霊場。','https://ja.wikipedia.org/wiki/清水寺','Wikipedia',true,now()),
('kotohira-gu','金刀比羅宮','ことひらぐう','shrine','単立神社','香川県','仲多度郡琴平町','香川県仲多度郡琴平町892番地1',34.184003,133.809536,null,null,'https://www.konpira.or.jp/','こんぴらさん。大物主神を祀り、海上守護で全国に信仰が広がる。','https://ja.wikipedia.org/wiki/金刀比羅宮','Wikipedia',true,now()),
('zenkoji','善光寺','ぜんこうじ','temple','無宗派（天台宗・浄土宗が護持）','長野県','長野市','長野県長野市元善町491',36.661700,138.187711,644,'一光三尊阿弥陀如来','https://www.zenkoji.jp/','宗派を問わない庶民信仰の寺。秘仏の阿弥陀如来を本尊とする。','https://ja.wikipedia.org/wiki/善光寺','Wikipedia',true,now()),
('suwa-taisha-kamisha','諏訪大社（上社本宮）','すわたいしゃ かみしゃほんみや','shrine','旧官幣大社・信濃国一宮','長野県','諏訪市','長野県諏訪市中洲宮山1',35.998158,138.119469,null,null,null,'建御名方神を祀る日本最古級の神社。御柱祭で知られる。','https://ja.wikipedia.org/wiki/諏訪大社','Wikipedia',true,now()),
('atsuta-jingu','熱田神宮','あつたじんぐう','shrine','旧官幣大社・尾張国三宮','愛知県','名古屋市熱田区','愛知県名古屋市熱田区神宮1-1-1',35.127361,136.908667,null,null,'https://www.atsutajingu.or.jp/','三種の神器・草薙剣を祀る。熱田大神（天照大神）が御祭神。','https://ja.wikipedia.org/wiki/熱田神宮','Wikipedia',true,now()),
('munakata-taisha','宗像大社（辺津宮）','むなかたたいしゃ へつみや','shrine','旧官幣大社・名神大社','福岡県','宗像市','福岡県宗像市田島2331',33.831167,130.514222,null,null,'https://munakata-taisha.or.jp/','宗像三女神を祀る世界遺産。海上・交通安全の総本社。','https://ja.wikipedia.org/wiki/宗像大社','Wikipedia',true,now()),
('kashima-jingu','鹿島神宮','かしまじんぐう','shrine','旧官幣大社・常陸国一宮','茨城県','鹿嶋市','茨城県鹿嶋市宮中2306-1',35.968856,140.631492,null,null,null,'武甕槌大神を祀る東国三社の一。武道・勝負の神として信仰される。','https://ja.wikipedia.org/wiki/鹿島神宮','Wikipedia',true,now()),
('koyasan-kongobuji','高野山 総本山金剛峯寺','こうやさん こんごうぶじ','temple','高野山真言宗','和歌山県','伊都郡高野町','和歌山県伊都郡高野町高野山132',34.214083,135.584170,816,'薬師如来','https://www.koyasan.or.jp/','弘法大師空海が開いた真言密教の聖地。世界遺産。','https://ja.wikipedia.org/wiki/金剛峯寺','Wikipedia',true,now()),
('kumano-hongu-taisha','熊野本宮大社','くまのほんぐうたいしゃ','shrine','旧官幣大社・名神大社','和歌山県','田辺市','和歌山県田辺市本宮町本宮1100',33.840250,135.773583,null,null,'http://www.hongutaisha.jp/','熊野三山の中心。家都美御子大神を祀る世界遺産の参詣の地。','https://ja.wikipedia.org/wiki/熊野本宮大社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kasuga-taisha'         and d.slug='takemikazuchi')
 or (t.slug='yasaka-jinja'          and d.slug='susanoo')
 or (t.slug='kitano-tenmangu'       and d.slug='michizane')
 or (t.slug='kiyomizu-dera'         and d.slug='senju_kannon')
 or (t.slug='kotohira-gu'           and d.slug='omononushi')
 or (t.slug='zenkoji'               and d.slug='amida_nyorai')
 or (t.slug='suwa-taisha-kamisha'   and d.slug='takeminakata')
 or (t.slug='atsuta-jingu'          and d.slug='amaterasu')
 or (t.slug='munakata-taisha'       and d.slug='ichikishima')
 or (t.slug='kashima-jingu'         and d.slug='takemikazuchi')
 or (t.slug='koyasan-kongobuji'     and d.slug='kobo_daishi')
 or (t.slug='kumano-hongu-taisha'   and d.slug='ketsumimiko')
on conflict do nothing;

-- 配祀（sub）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='kasuga-taisha'      and d.slug in ('futsunushi','amenokoyane'))
 or (t.slug='koyasan-kongobuji' and d.slug='yakushi_nyorai')
on conflict do nothing;
