-- w8-chubu.sql : 中部地方 著名社寺データ拡張(週8)
-- 担当: 新潟,富山,石川,福井,山梨,長野,岐阜,静岡,愛知
-- すべて ja.wikipedia.org の infobox で十進座標を裏取り。_have_chubu.txt と重複なし。

-- =========================================================
-- ① 新規神仏
-- =========================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖を如来として祀る。曹洞宗・臨済宗本尊として広く安置される。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{}','仏教','十一の顔を持つ変化観音。除災・延命の利益で信仰される。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{}','仏教','千の手で衆生を救う変化観音。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('sanpo_son','三宝尊','さんぼうそん','buddha','如来','{}','仏教','法華経の三宝(仏・法・僧)を一体として祀る日蓮宗の本尊。','https://ja.wikipedia.org/wiki/三宝尊','Wikipedia',true,now())
on conflict (slug) do nothing;

-- =========================================================
-- ② 新規神仏の司るご利益
-- =========================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shaka_nyorai' and g.slug in ('byoki_heyu','kaiun','jouju'))
or (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','choju','yakubarai'))
or (d.slug='senju_kannon' and g.slug in ('byoki_heyu','kaiun','jouju'))
or (d.slug='sanpo_son' and g.slug in ('kaiun','yakubarai','jouju'))
on conflict do nothing;

-- =========================================================
-- ③ 社寺
-- =========================================================

-- 新潟
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('aoshi-jinja','蒼柴神社','あおしじんじゃ','shrine','旧県社','新潟県','長岡市','新潟県長岡市悠久町707',37.432389,138.882722,null,null,'https://www.aoshijinja.or.jp/','長岡藩三代藩主牧野忠辰を祀る。悠久山公園に鎮座する長岡の総鎮守的存在。','https://ja.wikipedia.org/wiki/蒼柴神社','Wikipedia',true,now()),
('honjoji-sanjo','本成寺','ほんじょうじ','temple','法華宗陣門流(総本山)','新潟県','三条市','新潟県三条市西本成寺1-1-20',37.622667,138.945083,1297,'三宝尊','http://www.honjyouji.or.jp/','法華宗陣門流の総本山。節分の鬼踊りで知られる古刹。','https://ja.wikipedia.org/wiki/本成寺_(三条市)','Wikipedia',true,now()),
('myosenji-sado','妙宣寺','みょうせんじ','temple','日蓮宗','新潟県','佐渡市','新潟県佐渡市阿仏坊29',37.971361,138.372500,1221,'釈迦如来','','佐渡の日蓮宗寺院。新潟県唯一の五重塔で知られる。','https://ja.wikipedia.org/wiki/妙宣寺_(佐渡市)','Wikipedia',true,now());

-- 石川
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yokoji-hakui','永光寺','ようこうじ','temple','曹洞宗','石川県','羽咋市','石川県羽咋市酒井町イ11',36.912972,136.851056,1312,'釈迦如来','','瑩山紹瑾ゆかりの曹洞宗の古刹。北陸三十三観音霊場第22番。','https://ja.wikipedia.org/wiki/永光寺','Wikipedia',true,now()),
('ozaki-jinja-kanazawa','尾崎神社','おざきじんじゃ','shrine','旧県社','石川県','金沢市','石川県金沢市丸の内5-5',36.5692167,136.6574806,1643,null,'','加賀藩四代藩主前田光高が創建した東照宮。朱塗りの社殿で「北陸の日光」と称される。','https://ja.wikipedia.org/wiki/尾崎神社','Wikipedia',true,now());

-- 福井
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('konzenji-tsuruga','金前寺','こんぜんじ','temple','高野山真言宗','福井県','敦賀市','福井県敦賀市金ケ崎町1-4',35.663389,136.076083,736,'十一面観音','http://www.konzenji.jp/','金ヶ崎に建つ古刹。泰澄開創と伝わり、十一面観音を本尊とする。','https://ja.wikipedia.org/wiki/金前寺','Wikipedia',true,now());

-- 山梨
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('seiunji-koshu','棲雲寺','せいうんじ','temple','臨済宗建長寺派','山梨県','甲州市','山梨県甲州市大和町木賊122',35.660611,138.810667,1348,'釈迦如来','http://www.tenmokusan.or.jp/','天目山の標高約1050mに建つ臨済宗の禅刹。武田氏ゆかりで石庭が名勝。','https://ja.wikipedia.org/wiki/栖雲寺','Wikipedia',true,now());

-- 岐阜
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('keta-wakamiya-jinja','気多若宮神社','けたわかみやじんじゃ','shrine','旧県社','岐阜県','飛騨市','岐阜県飛騨市古川町上気多1297',36.239472,137.197861,null,null,'','飛騨古川の総鎮守。古川祭(起し太鼓)で知られ、能登気多大社からの勧請と伝わる。','https://ja.wikipedia.org/wiki/気多若宮神社','Wikipedia',true,now());

-- 長野
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nyakuichi-oji-jinja','若一王子神社','にゃくいちおうじじんじゃ','shrine','旧県社','長野県','大町市','長野県大町市大町2097',36.515694,137.853472,null,null,'https://nyakuichi.jp/','神仏習合の姿を残し三重塔と観音堂を持つ。本殿は国重文。流鏑馬で知られる。','https://ja.wikipedia.org/wiki/若一王子神社','Wikipedia',true,now());

-- 福井(若狭彦・若狭姫)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('wakasahiko-jinja','若狭彦神社','わかさひこじんじゃ','shrine','若狭国一宮(上社)','福井県','小浜市','福井県小浜市龍前28-7',35.466083,135.778472,714,null,'','若狭国一宮の上社。彦火火出見尊を祀る。','https://ja.wikipedia.org/wiki/若狭彦神社','Wikipedia',true,now()),
('wakasahime-jinja','若狭姫神社','わかさひめじんじゃ','shrine','若狭国一宮(下社)','福井県','小浜市','福井県小浜市遠敷65-41',35.478917,135.780083,714,null,'','若狭彦神社の下社。豊玉姫命を祀り安産・子育の信仰を集める。','https://ja.wikipedia.org/wiki/若狭彦神社','Wikipedia',true,now());

-- 長野(戸隠 宝光社・九頭龍社)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('togakushi-hokosha','戸隠神社宝光社','とがくしじんじゃほうこうしゃ','shrine','戸隠神社','長野県','長野市','長野県長野市戸隠2110',36.732472,138.075861,null,null,'https://www.togakushi-jinja.jp/','戸隠五社の一。天表春命を祀り、学問・裁縫・女性の守護神として信仰される。','https://ja.wikipedia.org/wiki/戸隠神社','Wikipedia',true,now()),
('togakushi-kuzuryusha','戸隠神社九頭龍社','とがくしじんじゃくずりゅうしゃ','shrine','戸隠神社','長野県','長野市','長野県長野市戸隠3690',36.765611,138.062083,null,null,'https://www.togakushi-jinja.jp/','戸隠五社の一。奥社に隣接し九頭龍大神を祀る地主神。水神・縁結びの信仰。','https://ja.wikipedia.org/wiki/戸隠神社','Wikipedia',true,now());

-- 静岡
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nishiyama-honmonji','西山本門寺','にしやまほんもんじ','temple','法華宗興門流','静岡県','富士宮市','静岡県富士宮市西山671',35.237250,138.564306,1344,'十界曼荼羅','','興門八本山の一。広大な境内を持つ法華宗の古刹。','https://ja.wikipedia.org/wiki/西山本門寺','Wikipedia',true,now()),
('taisekiji','大石寺','たいせきじ','temple','日蓮正宗(総本山)','静岡県','富士宮市','静岡県富士宮市上条2057',35.28611,138.58694,1290,'本門戒壇の大御本尊','','日蓮正宗の総本山。五重塔(国重文)をはじめ50以上の堂宇が建ち並ぶ。','https://ja.wikipedia.org/wiki/大石寺','Wikipedia',true,now()),
('gansuiji','岩水寺','がんすいじ','temple','高野山真言宗','静岡県','浜松市','静岡県浜松市浜名区根堅2238',34.845389,137.793333,725,'薬師如来','https://gansuiji.jp/','龍宮山と号する古刹。安産の子安地蔵で知られる。','https://ja.wikipedia.org/wiki/岩水寺','Wikipedia',true,now());

-- 福井
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fukui-jinja','福井神社','ふくいじんじゃ','shrine','旧別格官幣社','福井県','福井市','福井県福井市大手3-16-1',36.066000,136.219333,1943,null,'','幕末の名君松平慶永(春嶽)を祀る。鉄筋コンクリートのモダニズム社殿で知られる。','https://ja.wikipedia.org/wiki/福井神社','Wikipedia',true,now());

-- 愛知
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iwayaji-minamichita','岩屋寺','いわやじ','temple','尾張高野山宗(総本山)','愛知県','知多郡南知多町','愛知県知多郡南知多町山海間草109',34.7301306,136.9127194,715,'千手観音','http://www.iwayaji.jp/','「岩屋観音」と呼ばれる尾張高野山宗の総本山。知多四国霊場の札所。','https://ja.wikipedia.org/wiki/岩屋寺_(愛知県南知多町)','Wikipedia',true,now());

-- (続く)
