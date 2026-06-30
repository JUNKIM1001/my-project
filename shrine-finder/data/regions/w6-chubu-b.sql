-- w6-chubu-b: 中部地方(長野・岐阜・静岡・愛知)著名社寺データ
-- 全件 ja.wikipedia.org の infobox 十進座標で裏取り。AGENT_SPEC.md 準拠。
-- 既存 _have_chubu.txt と重複しない著名社寺のみ収録。

-- ===== ① 新規神仏 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('toyotomi_hideyoshi','豊臣秀吉','とよとみひでよし','kami','御霊','{}','史実','戦国の天下人。出世開運の神として祀られる。','https://ja.wikipedia.org/wiki/豊国神社_(名古屋市)','Wikipedia',true,now()),
('amenominakanushi','天之御中主神','あめのみなかぬしのかみ','kami','天津神','{}','記紀','造化三神の首座。宇宙の根源神。','https://ja.wikipedia.org/wiki/結神社','Wikipedia',true,now()),
('takamimusubi','高皇産霊神','たかみむすひのかみ','kami','天津神','{}','記紀','造化三神の一柱。生成の神。','https://ja.wikipedia.org/wiki/結神社','Wikipedia',true,now()),
('kamimusubi','神皇産霊神','かみむすひのかみ','kami','天津神','{}','記紀','造化三神の一柱。縁結び・生成の神。','https://ja.wikipedia.org/wiki/結神社','Wikipedia',true,now()),
('sarutahiko','猿田彦命','さるたひこのみこと','kami','国津神','{}','記紀','道開きの神。導きの神。','https://ja.wikipedia.org/wiki/結神社','Wikipedia',true,now()),
('konohanasakuyahime','木花咲耶姫命','このはなさくやひめのみこと','kami','国津神','{}','記紀','富士山の女神。浅間信仰の主神。安産・子授け。','https://ja.wikipedia.org/wiki/山宮浅間神社','Wikipedia',true,now()),
('yamatotakeru','日本武尊','やまとたけるのみこと','kami','御霊','{}','記紀','英雄神。草薙剣ゆかりの皇子。','https://ja.wikipedia.org/wiki/草薙神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏の司るご利益 =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='toyotomi_hideyoshi' and g.slug in ('shusse','kaiun','shobu'))
   or (d.slug='amenominakanushi' and g.slug in ('kaiun','jouju'))
   or (d.slug='takamimusubi' and g.slug in ('enmusubi','jouju'))
   or (d.slug='kamimusubi' and g.slug in ('enmusubi','renai'))
   or (d.slug='sarutahiko' and g.slug in ('kaiun','tabi_anzen','kotsu_anzen'))
   or (d.slug='konohanasakuyahime' and g.slug in ('anzan','kosodate','enmusubi'))
   or (d.slug='yamatotakeru' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;

-- ===== ③ 社寺 =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('toyokuni-jinja-nagoya','豊国神社','とよくにじんじゃ','shrine','豊国神社（旧県社）','愛知県','名古屋市','愛知県名古屋市中村区中村町字木下屋敷',35.17417,136.85472,1885,null,'http://toyokuni-jinja.jp/','豊臣秀吉生誕地に建つ中村公園内の神社。出世開運。','https://ja.wikipedia.org/wiki/豊国神社_(名古屋市)','Wikipedia',true,now()),
('nagoya-toshogu','名古屋東照宮','なごやとうしょうぐう','shrine','東照宮（旧県社）','愛知県','名古屋市','愛知県名古屋市中区丸の内2-3-37',35.177556,136.899306,1619,null,'https://nagoyatoshogu.com/','尾張藩祖徳川義直が父家康を祀った東照宮。','https://ja.wikipedia.org/wiki/名古屋東照宮','Wikipedia',true,now()),
('musubu-jinja','結神社','むすぶじんじゃ','shrine','結神社（旧郷社）','岐阜県','安八郡安八町','岐阜県安八郡安八町西結584',35.3731917,136.6608944,1170,null,'https://musubujinja.jp/','縁結び・産業隆昌で知られる古社。','https://ja.wikipedia.org/wiki/結神社','Wikipedia',true,now()),
('yamamiya-sengen-jinja','山宮浅間神社','やまみやせんげんじんじゃ','shrine','浅間神社（富士山本宮浅間大社摂社）','静岡県','富士宮市','静岡県富士宮市山宮740',35.271222,138.637056,null,null,null,'本殿を持たず溶岩で祭場を組む浅間信仰の原初的聖地。世界遺産構成資産。','https://ja.wikipedia.org/wiki/山宮浅間神社','Wikipedia',true,now()),
('kusanagi-jinja','草薙神社','くさなぎじんじゃ','shrine','草薙神社（旧県社）','静岡県','静岡市','静岡県静岡市清水区草薙349',34.994472,138.452806,null,null,'https://kusanagijinjya.jp/','日本武尊を祀り草薙剣ゆかりの古社。','https://ja.wikipedia.org/wiki/草薙神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='toyokuni-jinja-nagoya' and d.slug in ('toyotomi_hideyoshi'))
   or (t.slug='nagoya-toshogu' and d.slug in ('ieyasu'))
   or (t.slug='musubu-jinja' and d.slug in ('amenominakanushi','takamimusubi','kamimusubi'))
   or (t.slug='yamamiya-sengen-jinja' and d.slug in ('konohanasakuyahime'))
   or (t.slug='kusanagi-jinja' and d.slug in ('yamatotakeru'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='musubu-jinja' and d.slug in ('sarutahiko'))
on conflict do nothing;

-- ===== batch 2 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{}','記紀','神武天皇の母神。八幡信仰で比売神として祀られる。','https://ja.wikipedia.org/wiki/浜松八幡宮','Wikipedia',true,now()),
('mihotsuhime','三穂津姫命','みほつひめのみこと','kami','天津神','{}','記紀','高皇産霊神の娘。大国主の后神。','https://ja.wikipedia.org/wiki/御穂神社','Wikipedia',true,now()),
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{}','記紀','雷と剣の武神。国譲りの主役。','https://ja.wikipedia.org/wiki/五社神社・諏訪神社','Wikipedia',true,now()),
('takeminakata','建御名方神','たけみなかたのかみ','kami','国津神','{}','記紀','諏訪大社の主神。軍神・農耕神。','https://ja.wikipedia.org/wiki/五社神社・諏訪神社','Wikipedia',true,now()),
('hirata_yukie','平田靱負','ひらたゆきえ','kami','御霊','{}','史実','宝暦治水を指揮した薩摩藩家老。治水の功神。','https://ja.wikipedia.org/wiki/治水神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tamayorihime' and g.slug in ('anzan','kosodate','enmusubi'))
   or (d.slug='mihotsuhime' and g.slug in ('enmusubi','kanai_anzen'))
   or (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','kaiun'))
   or (d.slug='takeminakata' and g.slug in ('shobu','shusse','suisan_noko'))
   or (d.slug='hirata_yukie' and g.slug in ('mizu_amagoi','yakubarai'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hamamatsu-hachimangu','浜松八幡宮','はままつはちまんぐう','shrine','八幡宮（旧県社）','静岡県','浜松市','静岡県浜松市中央区八幡町2',34.715944,137.736833,null,null,'http://www.hamamatsuhachimangu.org/','徳川家康ゆかりの雲立楠で知られる浜松総鎮守。','https://ja.wikipedia.org/wiki/浜松八幡宮','Wikipedia',true,now()),
('miho-jinja','御穂神社','みほじんじゃ','shrine','御穂神社（旧県社）','静岡県','静岡市','静岡県静岡市清水区三保1073',35.0001111,138.5208778,null,null,'https://miho-jinja.jp/','三保松原の羽衣伝説で知られる古社。世界遺産構成資産。','https://ja.wikipedia.org/wiki/御穂神社','Wikipedia',true,now()),
('gosha-suwa-jinja','五社神社・諏訪神社','ごしゃじんじゃすわじんじゃ','shrine','五社神社・諏訪神社（旧県社）','静岡県','浜松市','静岡県浜松市中央区利町302-5',34.7064111,137.7249639,1568,null,'http://www.gosyajinjya-suwajinjya.or.jp/','徳川秀忠誕生の産土神。子守り・子育ての守護。','https://ja.wikipedia.org/wiki/五社神社・諏訪神社','Wikipedia',true,now()),
('hida-toshogu','飛騨東照宮','ひだとうしょうぐう','shrine','東照宮','岐阜県','高山市','岐阜県高山市西之一色町3-1004',36.134278,137.243556,1619,null,null,'高山藩主金森氏が勧請した飛騨の東照宮。','https://ja.wikipedia.org/wiki/飛騨東照宮','Wikipedia',true,now()),
('chisui-jinja','治水神社','ちすいじんじゃ','shrine','治水神社','岐阜県','海津市','岐阜県海津市海津町油島',35.144389,136.668028,1938,null,'http://www.chisuijinja.jp','宝暦治水に殉じた薩摩義士を祀る木曽三川公園隣接の社。','https://ja.wikipedia.org/wiki/治水神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hamamatsu-hachimangu' and d.slug in ('hachiman','tamayorihime','jingu_kogo'))
   or (t.slug='miho-jinja' and d.slug in ('okuninushi','mihotsuhime'))
   or (t.slug='gosha-suwa-jinja' and d.slug in ('takemikazuchi','takeminakata'))
   or (t.slug='hida-toshogu' and d.slug in ('ieyasu'))
   or (t.slug='chisui-jinja' and d.slug in ('hirata_yukie'))
on conflict do nothing;

-- ===== batch 3 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','仏典','無限の知恵と福徳を蔵する菩薩。記憶・智慧。','https://ja.wikipedia.org/wiki/瑞泉寺_(犬山市)','Wikipedia',true,now()),
('ohinami','大神実命','おおかむさねのみこと','kami','国津神','{}','記紀','桃の神格化。邪気祓いの神。','https://ja.wikipedia.org/wiki/桃太郎神社_(犬山市)','Wikipedia',true,now()),
('mitoshi','御歳神','みとしのかみ','kami','国津神','{}','記紀','穀物・五穀豊穣の神。','https://ja.wikipedia.org/wiki/田縣神社','Wikipedia',true,now()),
('tamahime','玉姫命','たまひめのみこと','kami','国津神','{}','記紀','田縣神社の女神。子宝・縁結び。','https://ja.wikipedia.org/wiki/田縣神社','Wikipedia',true,now()),
('oyamakui','大山咋神','おおやまくいのかみ','kami','国津神','{}','記紀','山王信仰の主神。比叡山・日吉大社の神。','https://ja.wikipedia.org/wiki/日枝神社_(高山市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kokuzo_bosatsu' and g.slug in ('gakugyo','gakumon','kaiun'))
   or (d.slug='ohinami' and g.slug in ('yakubarai','majo_kekkai','kaiun'))
   or (d.slug='mitoshi' and g.slug in ('suisan_noko','shobai','kanai_anzen'))
   or (d.slug='tamahime' and g.slug in ('enmusubi','kosodate','anzan'))
   or (d.slug='oyamakui' and g.slug in ('yakubarai','shobai','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zuisenji-inuyama','瑞泉寺','ずいせんじ','temple','臨済宗妙心寺派','愛知県','犬山市','愛知県犬山市犬山瑞泉寺7',35.389861,136.947667,1415,'虚空蔵菩薩','https://sites.google.com/view/zuisenji','織田・豊臣の庇護を受けた青龍山の大伽藍。','https://ja.wikipedia.org/wiki/瑞泉寺_(犬山市)','Wikipedia',true,now()),
('momotaro-jinja-inuyama','桃太郎神社','ももたろうじんじゃ','shrine','桃太郎神社','愛知県','犬山市','愛知県犬山市栗栖古屋敷',35.4052556,136.9661972,null,null,null,'桃太郎伝説ゆかりのユニークな神社。木曽川沿い。','https://ja.wikipedia.org/wiki/桃太郎神社_(犬山市)','Wikipedia',true,now()),
('tagata-jinja','田縣神社','たがたじんじゃ','shrine','田縣神社（旧郷社）','愛知県','小牧市','愛知県小牧市田県町152',35.3158417,136.9411639,null,null,'http://www.tagatajinja.com/','子宝・五穀豊穣の信仰で知られる古社。豊年祭で有名。','https://ja.wikipedia.org/wiki/田縣神社','Wikipedia',true,now()),
('okehazama-shinmeisha','桶狭間神明社','おけはざましんめいしゃ','shrine','神明社','愛知県','名古屋市','愛知県名古屋市緑区桶狭間神明',35.052278,136.968444,null,null,null,'桶狭間古戦場ゆかりの地に鎮座する神明社。','https://ja.wikipedia.org/wiki/桶狭間神明社','Wikipedia',true,now()),
('hie-jinja-takayama','日枝神社','ひえじんじゃ','shrine','日枝神社（旧県社）','岐阜県','高山市','岐阜県高山市城山156',36.133194,137.261417,1141,null,'https://hiejinja.com/','春の高山祭（山王祭）で知られる飛騨高山の総鎮守。','https://ja.wikipedia.org/wiki/日枝神社_(高山市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zuisenji-inuyama' and d.slug in ('kokuzo_bosatsu'))
   or (t.slug='momotaro-jinja-inuyama' and d.slug in ('ohinami'))
   or (t.slug='tagata-jinja' and d.slug in ('mitoshi','tamahime'))
   or (t.slug='okehazama-shinmeisha' and d.slug in ('amaterasu'))
   or (t.slug='hie-jinja-takayama' and d.slug in ('oyamakui'))
on conflict do nothing;
