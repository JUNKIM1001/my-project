-- w10 北海道・東北 追加データ（実在・ja.wikipedia infobox 裏取り）
-- 既存の deity slug は再定義しない。新規神仏のみ ① で定義。
-- 担当: 北海道・東北。_have に無い著名社寺を収録。

-- === batch1 (Fukushima / Iwate) ===
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shinatsuhiko','志那都比古神','しなつひこのかみ','kami','天津神','{}','記紀','風を司る男神。','https://ja.wikipedia.org/wiki/シナツヒコ','Wikipedia',true,now()),
('shinatsuhime','志那都比売神','しなつひめのかみ','kami','天津神','{}','記紀','風を司る女神。','https://ja.wikipedia.org/wiki/シナツヒコ','Wikipedia',true,now()),
('iidesan_no_kami','飯豊山大神','いいでさんのおおかみ','kami','国津神','{}','山岳信仰','飯豊山を神体とする山の神（五社権現）。','https://ja.wikipedia.org/wiki/飯豊山神社','Wikipedia',true,now()),
('nanbu_clan','南部氏歴代','なんぶしれきだい','kami','御霊','{}','地域信仰','遠野南部家歴代当主の神霊。','https://ja.wikipedia.org/wiki/南部神社_(遠野市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shinatsuhiko' and g.slug in ('suisan_noko','kaijo_anzen','yakubarai')) or
   (d.slug='shinatsuhime' and g.slug in ('suisan_noko','kaijo_anzen','yakubarai')) or
   (d.slug='iidesan_no_kami' and g.slug in ('kaiun','yakubarai','tabi_anzen')) or
   (d.slug='nanbu_clan' and g.slug in ('kaiun','shobu','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('adatara-jinja','安達太良神社','あだたらじんじゃ','shrine','旧県社','福島県','本宮市','福島県本宮市本宮字立石232',37.521156,140.404350,1146,null,null,'本宮の地名の由来となった安達太良神社の総本社。高皇産霊神らを祀る。','https://ja.wikipedia.org/wiki/安達太良神社','Wikipedia',true,now()),
('iidesan-jinja','飯豊山神社','いいでさんじんじゃ','shrine','旧県社','福島県','喜多方市','福島県喜多方市山都町一ノ木',37.720830,139.779170,652,null,null,'飯豊山を神体とする山岳信仰の古社。麓宮と奥宮を持つ。','https://ja.wikipedia.org/wiki/飯豊山神社','Wikipedia',true,now()),
('kashima-miko-jinja-minamisoma','鹿島御子神社','かしまみこじんじゃ','shrine','式内社','福島県','南相馬市','福島県南相馬市鹿島区鹿島字町143',37.702833,140.966639,null,null,'http://www13.ocn.ne.jp/~mikojnja/','延喜式内社。天足別命を祀り、鎮火祭で知られる。','https://ja.wikipedia.org/wiki/鹿島御子神社','Wikipedia',true,now()),
('nanbu-jinja-tono','南部神社（遠野）','なんぶじんじゃ','shrine','旧村社','岩手県','遠野市','岩手県遠野市東舘町3-6',39.327333,141.527694,1882,null,'https://tono-nanbu.jimdofree.com','遠野南部家歴代当主を祀る。旧称鍋倉神社。','https://ja.wikipedia.org/wiki/南部神社_(遠野市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='adatara-jinja' and d.slug in ('takamimusubi','kamimusubi')) or
   (t.slug='iidesan-jinja' and d.slug in ('iidesan_no_kami')) or
   (t.slug='kashima-miko-jinja-minamisoma' and d.slug in ('kashima_amatariwake','shinatsuhiko','shinatsuhime')) or
   (t.slug='nanbu-jinja-tono' and d.slug in ('nanbu_clan'))
on conflict do nothing;

-- === batch2 (Akita) ===
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yojiro_inari','与次郎','よじろう','kami','稲荷神','{}','地域信仰','秋田藩主佐竹氏の飛脚を務めたとされる狐の霊。','https://ja.wikipedia.org/wiki/与次郎稲荷神社','Wikipedia',true,now()),
('chuken_shiro','忠犬シロ','ちゅうけんしろ','kami','御霊','{}','地域信仰','主人に忠義を尽くしたマタギの猟犬シロの霊。','https://ja.wikipedia.org/wiki/老犬神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yojiro_inari' and g.slug in ('shobai','tabi_anzen','kotsu_anzen')) or
   (d.slug='chuken_shiro' and g.slug in ('petto','kanai_anzen','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('odate-hachiman-jinja','大館八幡神社','おおだてはちまんじんじゃ','shrine','旧県社','秋田県','大館市','秋田県大館市八幡1',40.274083,140.571861,1610,null,null,'正八幡宮・若宮八幡宮の二棟が重要文化財。大館総鎮守。','https://ja.wikipedia.org/wiki/大館八幡神社','Wikipedia',true,now()),
('nanakura-jinja','七座神社','ななくらじんじゃ','shrine','旧郷社','秋田県','能代市','秋田県能代市二ツ井町小繋字青森',40.201986,140.257156,658,null,null,'米代川を挟み七座山に向かう古社。学業成就で知られる。','https://ja.wikipedia.org/wiki/七座神社','Wikipedia',true,now()),
('yojiro-inari-jinja','与次郎稲荷神社','よじろういなりじんじゃ','shrine','旧無格社','秋田県','秋田市','秋田県秋田市千秋公園',39.721940,140.123060,1600,null,null,'飛脚を務めた狐・与次郎を祀る千秋公園の稲荷社。','https://ja.wikipedia.org/wiki/与次郎稲荷神社','Wikipedia',true,now()),
('roken-jinja','老犬神社','ろうけんじんじゃ','shrine','旧郷社','秋田県','大館市','秋田県大館市葛原',40.238889,140.686944,1620,null,null,'忠犬シロを祀る。秋田犬ゆかりの神社。','https://ja.wikipedia.org/wiki/老犬神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='odate-hachiman-jinja' and d.slug in ('hachiman','jingu_kogo')) or
   (t.slug='nanakura-jinja' and d.slug in ('kunitokotachi','kunisazuchi','toyokumununu','izanagi','izanami','michizane')) or
   (t.slug='yojiro-inari-jinja' and d.slug in ('yojiro_inari','ukanomitama')) or
   (t.slug='roken-jinja' and d.slug in ('chuken_shiro'))
on conflict do nothing;

-- === batch3 (Iwate) ===
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nanbu_morioka','盛岡南部家歴代','もりおかなんぶけれきだい','kami','御霊','{}','地域信仰','盛岡藩主南部家歴代当主の神霊。','https://ja.wikipedia.org/wiki/桜山神社_(盛岡市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nanbu_morioka' and g.slug in ('kaiun','shobu','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sakurayama-jinja-morioka','桜山神社（盛岡）','さくらやまじんじゃ','shrine','旧県社','岩手県','盛岡市','岩手県盛岡市内丸1-42',39.701472,141.151833,1749,null,'https://sakurayamajinja.jp/','盛岡城跡に鎮座し南部家歴代を祀る。烏帽子岩で有名。','https://ja.wikipedia.org/wiki/桜山神社_(盛岡市)','Wikipedia',true,now()),
('sakakiyama-inari-jinja','榊山稲荷神社','さかきやまいなりじんじゃ','shrine','旧無格社','岩手県','盛岡市','岩手県盛岡市北山2-12-12',39.718861,141.152111,1597,null,'http://kaiunjinja.jp/','南部直政が盛岡城築城時に城下の守護として祀った稲荷社。','https://ja.wikipedia.org/wiki/榊山稲荷神社','Wikipedia',true,now()),
('unosumi-jinja','鵜住神社','うのすみじんじゃ','shrine','旧村社','岩手県','釜石市','岩手県釜石市鵜住居町第13地割28',39.324720,141.883890,1690,null,null,'応神天皇と大山祇命を祀る。十一面観音像を所蔵。','https://ja.wikipedia.org/wiki/鵜住神社','Wikipedia',true,now()),
('kotohira-jinja-kuji','金刀比羅神社（久慈）','ことひらじんじゃ','shrine','旧村社','岩手県','久慈市','岩手県久慈市湊町13-90',40.203194,141.791306,1718,null,null,'久慈湾を望む高台に鎮座する金刀比羅社。','https://ja.wikipedia.org/wiki/金刀比羅神社_(久慈市)','Wikipedia',true,now()),
('omiya-jinja-morioka','大宮神社（盛岡）','おおみやじんじゃ','shrine','旧郷社','岩手県','盛岡市','岩手県盛岡市本宮51',39.684056,141.115444,802,null,null,'坂上田村麻呂ゆかりと伝わる古社。豊受大神を祀る。','https://ja.wikipedia.org/wiki/大宮神社_(盛岡市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sakurayama-jinja-morioka' and d.slug in ('nanbu_mitsuyuki','nanbu_morioka')) or
   (t.slug='sakakiyama-inari-jinja' and d.slug in ('toyouke')) or
   (t.slug='unosumi-jinja' and d.slug in ('hachiman','oyamatsumi')) or
   (t.slug='kotohira-jinja-kuji' and d.slug in ('konpira','omononushi')) or
   (t.slug='omiya-jinja-morioka' and d.slug in ('toyouke'))
on conflict do nothing;

-- === batch4 (Fukushima) ===
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nishine_kenja','佐藤新右衛門・古川善兵衛','さとうしんえもん・ふるかわぜんべえ','kami','御霊','{}','地域信仰','西根堰を開削した江戸初期の偉人の神霊。','https://ja.wikipedia.org/wiki/西根神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nishine_kenja' and g.slug in ('suisan_noko','mizu_amagoi','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kokuwakura-jinja','子鍬倉神社','こくわくらじんじゃ','shrine','式内社','福島県','いわき市','福島県いわき市平揚土30',37.056694,140.886000,806,null,null,'衣食住の三要素を象徴する社名を持つ式内社。','https://ja.wikipedia.org/wiki/子鍬倉神社','Wikipedia',true,now()),
('kunitama-jinja-iwaki','國魂神社（いわき）','くにたまじんじゃ','shrine','式内社','福島県','いわき市','福島県いわき市勿来町窪田馬場72',36.893667,140.764278,806,null,'https://kunitamajinja.com/','大国主神らを祀る勿来の式内社。','https://ja.wikipedia.org/wiki/國魂神社_(いわき市)','Wikipedia',true,now()),
('kokoroshimizu-hachiman','心清水八幡神社','こころしみずはちまんじんじゃ','shrine','旧県社','福島県','河沼郡会津坂下町','福島県河沼郡会津坂下町塔寺字松原2908',37.575750,139.797694,1055,null,null,'塔寺八幡とも。120mに及ぶ長帳が国重文。','https://ja.wikipedia.org/wiki/心清水八幡神社','Wikipedia',true,now()),
('taka-jinja','多珂神社','たかじんじゃ','shrine','式内社','福島県','南相馬市','福島県南相馬市原町区高木の内112',37.600781,140.992644,null,null,null,'全国の多賀神社で唯一の名神大社とされる古社。','https://ja.wikipedia.org/wiki/多珂神社','Wikipedia',true,now()),
('nishine-jinja','西根神社','にしねじんじゃ','shrine','旧県社','福島県','福島市','福島県福島市飯坂町湯野字高畑2',37.831056,140.460417,1887,null,null,'西根堰を開いた偉人を祀る。鷽替え祭で有名。','https://ja.wikipedia.org/wiki/西根神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kokuwakura-jinja' and d.slug in ('ukanomitama')) or
   (t.slug='kunitama-jinja-iwaki' and d.slug in ('okuninushi','suseribime','sukunabikona')) or
   (t.slug='kokoroshimizu-hachiman' and d.slug in ('hachiman','jingu_kogo','himegami')) or
   (t.slug='taka-jinja' and d.slug in ('izanagi')) or
   (t.slug='nishine-jinja' and d.slug in ('nishine_kenja','michizane'))
on conflict do nothing;

-- === batch5 (Hokkaido) ===
-- ③ 社寺（新規神仏なし）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sorachi-jinja','空知神社','そらちじんじゃ','shrine','旧県社','北海道','美唄市','北海道美唄市西2条南1-1-1',43.332839,141.857089,1891,null,null,'屯田兵が入植し創建した美唄総鎮守。樹齢900年の水松が市指定。','https://ja.wikipedia.org/wiki/空知神社','Wikipedia',true,now()),
('atsuta-jinja-ishikari','厚田神社','あつたじんじゃ','shrine','旧村社','北海道','石狩市','北海道石狩市厚田区厚田1-14',43.401028,141.433694,1848,null,null,'保食神を祀る厚田の古社。ニシン大漁の記念碑が残る。','https://ja.wikipedia.org/wiki/厚田神社','Wikipedia',true,now()),
('urakawa-jinja','浦河神社','うらかわじんじゃ','shrine','旧郷社','北海道','浦河郡浦河町','北海道浦河郡浦河町大通2丁目',42.163610,142.775694,1669,null,null,'松前の佐藤権左衛門が金刀比羅の大物主を勧請。海上渡御で知られる。','https://ja.wikipedia.org/wiki/浦河神社','Wikipedia',true,now()),
('ebetsu-jinja','江別神社','えべつじんじゃ','shrine','旧郷社','北海道','江別市','北海道江別市萩ヶ岡1-1',43.110631,141.554219,1885,null,'http://park19.wakwak.com/~e-jinjya/','熊本の屯田兵が加藤清正を祀って創建した江別総鎮守。','https://ja.wikipedia.org/wiki/江別神社','Wikipedia',true,now()),
('haboro-jinja','羽幌神社','はぼろじんじゃ','shrine','旧郷社','北海道','苫前郡羽幌町','北海道苫前郡羽幌町南大通6丁目',44.362611,141.697333,1886,null,null,'漁民が稲荷を祀ったのが起源の羽幌総鎮守。','https://ja.wikipedia.org/wiki/羽幌神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sorachi-jinja' and d.slug in ('amaterasu','okuninushi')) or
   (t.slug='atsuta-jinja-ishikari' and d.slug in ('ukemochi')) or
   (t.slug='urakawa-jinja' and d.slug in ('ukemochi','omononushi','ichikishima')) or
   (t.slug='ebetsu-jinja' and d.slug in ('amaterasu','okuninushi','kato_kiyomasa')) or
   (t.slug='haboro-jinja' and d.slug in ('ukemochi'))
on conflict do nothing;

-- === batch6 (Miyagi) ===
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('date_shigenari','伊達成実','だてしげざね','kami','御霊','{}','地域信仰','伊達政宗を支えた武将。亘理の開発に尽くした。','https://ja.wikipedia.org/wiki/亘理神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='date_shigenari' and g.slug in ('shobu','kaiun','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('koganeyama-jinja-wakuya','黄金山神社（涌谷）','こがねやまじんじゃ','shrine','旧県社','宮城県','遠田郡涌谷町','宮城県遠田郡涌谷町黄金山',38.559828,141.139147,749,null,'https://wakuya-koganeyama.info/','日本初の産金地に鎮座。金山彦神を祀る。東大寺大仏の金を産出。','https://ja.wikipedia.org/wiki/黄金山神社_(涌谷町)','Wikipedia',true,now()),
('watari-jinja','亘理神社','わたりじんじゃ','shrine','旧村社','宮城県','亘理郡亘理町','宮城県亘理郡亘理町',38.033778,140.850694,1879,null,null,'亘理を開発した伊達成実を祀る。','https://ja.wikipedia.org/wiki/亘理神社','Wikipedia',true,now()),
('manzo-inari-jinja','萬蔵稲荷神社','まんぞういなりじんじゃ','shrine','旧無格社','宮城県','白石市','宮城県白石市大鳥馬頭山6',37.908694,140.511500,1785,null,null,'連続する朱鳥居で知られる白石の稲荷社。','https://ja.wikipedia.org/wiki/萬蔵稲荷神社','Wikipedia',true,now()),
('aoba-jinja-ishinomaki','青葉神社（石巻）','あおばじんじゃ','shrine','旧無格社','宮城県','石巻市','宮城県石巻市門脇',38.434444,141.265333,1881,null,null,'伊達政宗（武振彦命）を祀る仙台青葉神社の分社。','https://ja.wikipedia.org/wiki/青葉神社_(石巻市)','Wikipedia',true,now()),
('isuzu-jinja-kesennuma','五十鈴神社（気仙沼）','いすずじんじゃ','shrine','旧村社','宮城県','気仙沼市','宮城県気仙沼市魚町2-6-7',38.907111,141.579194,1394,null,null,'気仙沼湾を望む古社。天照大神らを祀る。','https://ja.wikipedia.org/wiki/五十鈴神社_(気仙沼市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='koganeyama-jinja-wakuya' and d.slug in ('kanayamahiko','amaterasu','sarutahiko')) or
   (t.slug='watari-jinja' and d.slug in ('date_shigenari')) or
   (t.slug='manzo-inari-jinja' and d.slug in ('ukanomitama')) or
   (t.slug='aoba-jinja-ishinomaki' and d.slug in ('date_masamune')) or
   (t.slug='isuzu-jinja-kesennuma' and d.slug in ('amaterasu','watatsumi','susanoo'))
on conflict do nothing;

-- === batch7 (Akita / Miyagi)（新規神仏なし）===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yokote-shinmeisha','横手神明社','よこてしんめいしゃ','shrine','旧郷社','秋田県','横手市','秋田県横手市神明町7-2',39.307944,140.568610,1716,null,'https://akita-jinjacho.sakura.ne.jp/','日本武尊ゆかりと伝わる横手の総鎮守。青銅製の杖頭が重文。','https://ja.wikipedia.org/wiki/横手神明社','Wikipedia',true,now()),
('takaiwa-jinja-noshiro','高岩神社（能代）','たかいわじんじゃ','shrine','旧村社','秋田県','能代市','秋田県能代市二ツ井町',40.237667,140.269333,857,null,null,'清水寺に似た懸造の社殿を持つ円仁開基伝承の古社。','https://ja.wikipedia.org/wiki/高岩神社_(能代市)','Wikipedia',true,now()),
('dakigaeri-jinja','抱返神社','だきがえりじんじゃ','shrine','旧村社','秋田県','仙北市','秋田県仙北市田沢湖卒田字黒倉139',39.609278,140.652944,1062,null,null,'抱返り渓谷の入口に鎮座する水の神の社。','https://ja.wikipedia.org/wiki/抱返神社','Wikipedia',true,now()),
('ohira-hachiman-jinja','大衡八幡神社','おおひらはちまんじんじゃ','shrine','旧村社','宮城県','黒川郡大衡村','宮城県黒川郡大衡村大衡八幡48',38.464083,140.878361,1577,null,'http://oohirahachimanjinja.jp/','八幡造の社殿を持つ大衡の総鎮守。','https://ja.wikipedia.org/wiki/大衡八幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yokote-shinmeisha' and d.slug in ('amaterasu','toyouke','sarutahiko','susanoo','michizane')) or
   (t.slug='takaiwa-jinja-noshiro' and d.slug in ('takamimusubi','kamimusubi','okuninushi')) or
   (t.slug='dakigaeri-jinja' and d.slug in ('mizuhanome')) or
   (t.slug='ohira-hachiman-jinja' and d.slug in ('hachiman','amaterasu','amenominakanushi','kukurihime'))
on conflict do nothing;

-- === batch8 (Hokkaido)（新規神仏なし）===
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shimamatsu-jinja','島松神社','しままつじんじゃ','shrine','旧無格社','北海道','恵庭市','北海道恵庭市島松本町4-3',42.927881,141.576128,1901,null,null,'旧島松村の鎮守。豊受大神を祀る神明造の社。','https://ja.wikipedia.org/wiki/島松神社','Wikipedia',true,now()),
('shiraoi-hachiman-jinja','白老八幡神社','しらおいはちまんじんじゃ','shrine','旧郷社','北海道','白老郡白老町','北海道白老郡白老町本町1-1-11',42.552100,141.352900,1798,null,'https://shiraoihatimanjinjya.org/','弁天堂を起源とする白老の八幡社。','https://ja.wikipedia.org/wiki/白老八幡神社','Wikipedia',true,now()),
('rubeshibe-jinja','留辺蘂神社','るべしべじんじゃ','shrine','旧村社','北海道','北見市','北海道北見市留辺蘂町宮下町115',43.790111,143.620361,1912,null,'https://sites.google.com/view/rubeshibejinjya','留辺蘂市街を見下ろす高台に鎮座する総鎮守。','https://ja.wikipedia.org/wiki/留辺蘂神社','Wikipedia',true,now()),
('hamamasu-jinja','浜益神社','はまましじんじゃ','shrine','旧郷社','北海道','石狩市','北海道石狩市浜益区浜益227',43.602139,141.391861,1835,null,null,'稲荷社を起源とする浜益の総鎮守。','https://ja.wikipedia.org/wiki/浜益神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shimamatsu-jinja' and d.slug in ('toyouke')) or
   (t.slug='shiraoi-hachiman-jinja' and d.slug in ('hachiman')) or
   (t.slug='rubeshibe-jinja' and d.slug in ('amaterasu')) or
   (t.slug='hamamasu-jinja' and d.slug in ('ukemochi','ichikishima'))
on conflict do nothing;
