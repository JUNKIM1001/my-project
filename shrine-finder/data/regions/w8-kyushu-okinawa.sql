-- 九州・沖縄 追加データ (w8)
-- 対象県: 福岡,佐賀,長崎,熊本,大分,宮崎,鹿児島,沖縄
-- ja.wikipedia.org infobox の十進座標で裏取り。_have重複なし。

-- ===== batch 1 (1-5) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('oyamakui','大山咋神','おおやまくいのかみ','kami','国津神','{}','記紀','比叡山・松尾山に坐す山の神。酒造の神としても信仰される。','https://ja.wikipedia.org/wiki/オオヤマクイ','Wikipedia',true,now()),
('kasuga_daimyojin','春日大明神','かすがだいみょうじん','kami','天津神','{}','神道','春日大社の四神の総称。藤原氏の氏神。','https://ja.wikipedia.org/wiki/春日大社','Wikipedia',true,now()),
('tachibana_muneshige','立花宗茂','たちばなむねしげ','kami','人格神','{}','史実','柳川藩初代藩主。武勇に優れた戦国武将。','https://ja.wikipedia.org/wiki/立花宗茂','Wikipedia',true,now()),
('karakuni_okinaga','辛国息長大姫大目命','からくにおきながおおひめおおめのみこと','kami','国津神','{}','社伝','香春神社の主神。新羅系渡来神とされる。','https://ja.wikipedia.org/wiki/香春神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='oyamakui' and g.slug in ('shobai','kanai_anzen','yakubarai'))
or (d.slug='kasuga_daimyojin' and g.slug in ('kaiun','yakubarai','kanai_anzen'))
or (d.slug='tachibana_muneshige' and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='karakuni_okinaga' and g.slug in ('yakubarai','kaiun','suisan_noko'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ukiha-inari-jinja','浮羽稲荷神社','うきはいなりじんじゃ','shrine','浮羽稲荷神社','福岡県','うきは市','福岡県うきは市浮羽町流川1513-9',33.323083,130.791722,1957,null,'https://ukiha-inari.jp/','山腹に91基の鳥居が連なる絶景の稲荷社。伏見稲荷より勧請。','https://ja.wikipedia.org/wiki/浮羽稲荷神社','Wikipedia',true,now()),
('onamuchi-jinja-chikuzen','大己貴神社','おおなむちじんじゃ','shrine','大己貴神社','福岡県','朝倉郡筑前町','福岡県朝倉郡筑前町弥永697-3',33.443611,130.654056,null,null,null,'日本最古級と伝わる古社。地元で「おんがさま」と呼ばれる。','https://ja.wikipedia.org/wiki/大己貴神社','Wikipedia',true,now()),
('sakamoto-hachimangu','坂本八幡宮','さかもとはちまんぐう','shrine','坂本八幡宮','福岡県','太宰府市','福岡県太宰府市坂本三丁目14-23',33.516778,130.513472,1532,null,null,'元号「令和」ゆかりの地として知られる太宰府の八幡宮。','https://ja.wikipedia.org/wiki/坂本八幡宮','Wikipedia',true,now()),
('mihashira-jinja-yanagawa','三柱神社','みはしらじんじゃ','shrine','三柱神社','福岡県','柳川市','福岡県柳川市三橋町高畑323-1',33.171000,130.404000,1826,null,null,'立花宗茂とその妻誾千代らを祀る柳川藩ゆかりの社。おにぎえで有名。','https://ja.wikipedia.org/wiki/三柱神社_(柳川市)','Wikipedia',true,now()),
('kawara-jinja','香春神社','かわらじんじゃ','shrine','香春神社','福岡県','田川郡香春町','福岡県田川郡香春町大字香春733',33.669611,130.840306,709,null,null,'香春三山の三神を合祀した式内社。豊前を代表する古社。','https://ja.wikipedia.org/wiki/香春神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ukiha-inari-jinja' and d.slug in ('ukanomitama','oyamakui','michizane'))
or (t.slug='onamuchi-jinja-chikuzen' and d.slug in ('okuninushi','amaterasu','kasuga_daimyojin'))
or (t.slug='sakamoto-hachimangu' and d.slug in ('hachiman'))
or (t.slug='mihashira-jinja-yanagawa' and d.slug in ('tachibana_muneshige'))
or (t.slug='kawara-jinja' and d.slug in ('karakuni_okinaga'))
on conflict do nothing;

-- ===== batch 2 (6-10) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖、釈迦牟尼仏。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('yamato_takeru','日本武尊','やまとたけるのみこと','kami','人格神','{}','記紀','景行天皇の皇子。各地を平定した英雄神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shaka_nyorai' and g.slug in ('jouju','byoki_heyu','kaiun'))
or (d.slug='yamato_takeru' and g.slug in ('shobu','yakubarai','tabi_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daiho-ji-goto','大宝寺','だいほうじ','temple','高野山真言宗','長崎県','五島市','長崎県五島市玉之浦町大宝633',32.601389,128.654528,701,'弘法大師',null,'「西の高野山」と称される古刹。空海が帰朝後に真言を講じたと伝わる。','https://ja.wikipedia.org/wiki/大宝寺_(五島市)','Wikipedia',true,now()),
('daien-ji-goto','大円寺','だいえんじ','temple','曹洞宗','長崎県','五島市','長崎県五島市大円寺町1-1',32.689030,128.833060,1521,'釈迦如来',null,'五島藩主五島氏の菩提寺。戦国期創建の曹洞宗寺院。','https://ja.wikipedia.org/wiki/大円寺_(五島市)','Wikipedia',true,now()),
('honko-ji-shimabara','本光寺','ほんこうじ','temple','曹洞宗','長崎県','島原市','長崎県島原市本光寺町3380',32.791472,130.352222,1669,'釈迦如来',null,'島原藩主深溝松平家の菩提寺。常盤歴史資料館を併設。','https://ja.wikipedia.org/wiki/本光寺_(島原市)','Wikipedia',true,now()),
('kushida-gu-kanzaki-saga','櫛田宮','くしだぐう','shrine','櫛田宮','佐賀県','神埼市','佐賀県神埼市神埼町神埼419-1',33.310167,130.372583,null,null,'櫛田三神を祀る式内古社。神埼の総鎮守。','https://ja.wikipedia.org/wiki/櫛田宮','Wikipedia',true,now()),
('kashikuri-jinja-izumi','加紫久利神社','かしくりじんじゃ','shrine','加紫久利神社','鹿児島県','出水市','鹿児島県出水市下鯖町1272',32.119639,130.348889,702,null,null,'薩摩国二宮とされる式内社。','https://ja.wikipedia.org/wiki/加紫久利神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daiho-ji-goto' and d.slug in ('kobo_daishi'))
or (t.slug='daien-ji-goto' and d.slug in ('shaka_nyorai'))
or (t.slug='honko-ji-shimabara' and d.slug in ('shaka_nyorai'))
or (t.slug='kushida-gu-kanzaki-saga' and d.slug in ('susanoo','kushinadahime','yamato_takeru'))
or (t.slug='kashikuri-jinja-izumi' and d.slug in ('amaterasu','takirihime','sumiyoshi','hachiman'))
on conflict do nothing;

-- ===== batch 3 (11-15) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shimazu_yoshihiro','島津義弘','しまづよしひろ','kami','人格神','{}','史実','薩摩の名将。「鬼島津」と恐れられた戦国武将。','https://ja.wikipedia.org/wiki/島津義弘','Wikipedia',true,now()),
('isotakeru','五十猛命','いそたけるのみこと','kami','国津神','{}','記紀','素戔嗚尊の御子。樹木・植林の神。','https://ja.wikipedia.org/wiki/イソタケル','Wikipedia',true,now()),
('konohanasakuya','木花開耶姫','このはなさくやひめ','kami','天津神','{}','記紀','瓊々杵尊の妃。富士山の女神、安産の神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shimazu_yoshihiro' and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='isotakeru' and g.slug in ('suisan_noko','kaiun','shigoto'))
or (d.slug='konohanasakuya' and g.slug in ('anzan','kosodate','enmusubi'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kuwadate-jinja','精矛神社','くわだてじんじゃ','shrine','精矛神社','鹿児島県','姶良市','鹿児島県姶良市加治木町日木山308',31.740667,130.677111,1869,null,null,'島津義弘を祭神とする社。加治木城跡に創建された。','https://ja.wikipedia.org/wiki/精矛神社','Wikipedia',true,now()),
('ayabe-jinja-miyaki','綾部神社','あやべじんじゃ','shrine','綾部神社','佐賀県','三養基郡みやき町','佐賀県三養基郡みやき町原古賀2338',33.360560,130.441110,1205,null,null,'旗上げ神事による天気占いで知られる「日本最古の気象台」。','https://ja.wikipedia.org/wiki/綾部神社','Wikipedia',true,now()),
('arahoko-jinja-kiyama','荒穂神社','あらほじんじゃ','shrine','荒穂神社','佐賀県','三養基郡基山町','佐賀県三養基郡基山町宮浦2050',33.433861,130.509556,650,null,null,'基山に鎮座する式内社。瓊々杵尊ほか六社を祀る。','https://ja.wikipedia.org/wiki/荒穂神社','Wikipedia',true,now()),
('inasa-jinja-shiroishi','稲佐神社','いなさじんじゃ','shrine','稲佐神社','佐賀県','杵島郡白石町','佐賀県杵島郡白石町辺田2925',33.163139,130.100694,null,null,null,'稲佐山に鎮座する国史見在社。古来の神仏習合の名残を留める。','https://ja.wikipedia.org/wiki/稲佐神社','Wikipedia',true,now()),
('noma-jinja-minamisatsuma','野間神社','のまじんじゃ','shrine','野間神社','鹿児島県','南さつま市','鹿児島県南さつま市笠沙町片浦4108',31.399456,130.159497,null,null,null,'野間岳に鎮座。瓊々杵尊が最初に上陸した地と伝わる。','https://ja.wikipedia.org/wiki/野間神社_(南さつま市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kuwadate-jinja' and d.slug in ('shimazu_yoshihiro'))
or (t.slug='ayabe-jinja-miyaki' and d.slug in ('hachiman','sumiyoshi'))
or (t.slug='arahoko-jinja-kiyama' and d.slug in ('ninigi'))
or (t.slug='inasa-jinja-shiroishi' and d.slug in ('isotakeru'))
or (t.slug='noma-jinja-minamisatsuma' and d.slug in ('ninigi','konohanasakuya'))
on conflict do nothing;
