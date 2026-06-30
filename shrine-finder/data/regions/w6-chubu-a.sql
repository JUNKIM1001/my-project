-- 御朱印ナビ データ拡張: 中部W6-a（新潟・富山・石川・福井・山梨）
-- 出典: ja.wikipedia.org の infobox（十進座標）で裏取り。座標無しは除外。
-- 既存 _have_chubu.txt と重複しない著名社寺のみ。

-- ===== バッチ1 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ninigi','瓊瓊杵尊','ににぎのみこと','kami','天津神','{}','記紀','天照大神の孫。葦原中国に降臨した天孫。','https://ja.wikipedia.org/wiki/ニニギ','Wikipedia',true,now()),
('amenokoyane','天児屋根命','あめのこやねのみこと','kami','天津神','{}','記紀','中臣・藤原氏の祖神。祝詞を司る神。','https://ja.wikipedia.org/wiki/アメノコヤネ','Wikipedia',true,now()),
('futodama','太玉命','ふとだまのみこと','kami','天津神','{}','記紀','忌部氏の祖神。祭祀を司る神。','https://ja.wikipedia.org/wiki/フトダマ','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖を仏格化した如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。浄土系の本尊。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('gochi_nyorai','五智如来','ごちにょらい','buddha','如来','{}','仏教','大日如来を中心とする五仏。密教の五智を表す。','https://ja.wikipedia.org/wiki/五智如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ninigi' and g.slug in ('kaiun','shusse','suisan_noko'))
or (d.slug='amenokoyane' and g.slug in ('gakugyo','kaiun','shobai'))
or (d.slug='futodama' and g.slug in ('shobai','kaiun','yakubarai'))
or (d.slug='shaka_nyorai' and g.slug in ('byoki_heyu','kaiun','jouju'))
or (d.slug='amida_nyorai' and g.slug in ('byoki_heyu','jouju','kaiun'))
or (d.slug='gochi_nyorai' and g.slug in ('kaiun','byoki_heyu','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('rinsen-ji-joetsu','林泉寺','りんせんじ','temple','曹洞宗','新潟県','上越市','新潟県上越市中門前1-1-1',37.15,138.226,1497,'釈迦牟尼仏','http://myhp.joetsu.jp/rinsenji/','上杉謙信が学んだ上杉氏ゆかりの名刹。','https://ja.wikipedia.org/wiki/林泉寺_(上越市)','Wikipedia',true,now()),
('gochi-kokubun-ji','五智国分寺','ごちこくぶんじ','temple','天台宗','新潟県','上越市','新潟県上越市五智3-20-21',37.168556,138.224944,null,'五智如来','https://www5c.biglobe.ne.jp/~etigo/index.htm','越後国分寺の法統を継ぐ天台宗の古刹。','https://ja.wikipedia.org/wiki/五智国分寺','Wikipedia',true,now()),
('amatsu-jinja-itoigawa','天津神社','あまつじんじゃ','shrine','天津神社（式内社・旧県社）','新潟県','糸魚川市','新潟県糸魚川市一の宮1-3-34',37.04015,137.864225,null,null,null,'糸魚川の式内社。けんか祭りで知られる。','https://ja.wikipedia.org/wiki/天津神社_(糸魚川市)','Wikipedia',true,now()),
('jikoji-gosen','慈光寺','じこうじ','temple','曹洞宗','新潟県','五泉市','新潟県五泉市蛭野870',37.636972,139.193306,null,'十一面観世音菩薩','https://www.jikouji.com/','越後四ヶ道場の一。杉並木の参道で名高い禅刹。','https://ja.wikipedia.org/wiki/慈光寺_(五泉市)','Wikipedia',true,now()),
('zentoku-ji-nanto','善徳寺','ぜんとくじ','temple','真宗大谷派','富山県','南砺市','富山県南砺市城端405',36.515667,136.902006,1470,'阿弥陀如来','https://www.johana-betsuin.com/','城端別院。越中の真宗信仰の中心。','https://ja.wikipedia.org/wiki/善徳寺_(南砺市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='rinsen-ji-joetsu' and d.slug in ('shaka_nyorai'))
or (t.slug='gochi-kokubun-ji' and d.slug in ('gochi_nyorai'))
or (t.slug='amatsu-jinja-itoigawa' and d.slug in ('ninigi','amenokoyane','futodama'))
or (t.slug='jikoji-gosen' and d.slug in ('sho_kannon'))
or (t.slug='zentoku-ji-nanto' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== バッチ2 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nunakawahime','奴奈川姫','ぬなかわひめ','kami','国津神','{}','記紀・出雲国風土記','越の国の女神。大国主の妻とされる。','https://ja.wikipedia.org/wiki/ヌナカワヒメ','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方瑠璃光浄土の教主。医薬・病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nunakawahime' and g.slug in ('enmusubi','anzan','kanai_anzen'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zuisen-ji-inami','瑞泉寺','ずいせんじ','temple','真宗大谷派','富山県','南砺市','富山県南砺市井波3050',36.558486,136.97220,1390,'阿弥陀如来','https://www.inamibetsuin.com/','井波別院。井波彫刻発祥の地として知られる。','https://ja.wikipedia.org/wiki/瑞泉寺_(南砺市)','Wikipedia',true,now()),
('keta-jinja-takaoka','気多神社','けたじんじゃ','shrine','気多神社（越中国一宮・式内社）','富山県','高岡市','富山県高岡市伏木一宮1-10-1',36.800222,137.044306,757,null,null,'越中国一宮。能登気多大社からの勧請と伝わる。','https://ja.wikipedia.org/wiki/気多神社','Wikipedia',true,now()),
('tentoku-in-kanazawa','天徳院','てんとくいん','temple','曹洞宗','石川県','金沢市','石川県金沢市小立野4-4-4',36.551461,136.677008,1623,'釈迦牟尼仏','https://www.tentokuin.jp/','加賀藩前田利常が珠姫を弔って建立した菩提寺。','https://ja.wikipedia.org/wiki/天徳院_(金沢市)','Wikipedia',true,now()),
('kinken-gu','金剱宮','きんけんぐう','shrine','金剱宮（白山七社・旧県社）','石川県','白山市','石川県白山市鶴来日詰町巳118-5',36.44975,136.630167,null,null,null,'白山七社の一。金運のパワースポットとして名高い。','https://ja.wikipedia.org/wiki/金剱宮','Wikipedia',true,now()),
('jinguji-obama','神宮寺','じんぐうじ','temple','天台宗','福井県','小浜市','福井県小浜市神宮寺30-4',35.459667,135.782972,714,'薬師如来','http://wakasa-jinguuji.com/','東大寺二月堂お水取りに先立つ「お水送り」の寺。','https://ja.wikipedia.org/wiki/神宮寺_(小浜市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zuisen-ji-inami' and d.slug in ('amida_nyorai'))
or (t.slug='keta-jinja-takaoka' and d.slug in ('okuninushi','nunakawahime'))
or (t.slug='tentoku-in-kanazawa' and d.slug in ('shaka_nyorai'))
or (t.slug='kinken-gu' and d.slug in ('ninigi'))
or (t.slug='jinguji-obama' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- ===== バッチ3 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('konohanasakuyahime','木花開耶姫命','このはなさくやひめのみこと','kami','天津神','{}','記紀','富士山の女神。浅間神社の主祭神。安産・火防の神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{}','仏教','十一の顔を持つ変化観音。除災と滅罪の菩薩。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='konohanasakuyahime' and g.slug in ('anzan','kosodate','yakubarai'))
or (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('asama-jinja-fuefuki','浅間神社','あさまじんじゃ','shrine','浅間神社（甲斐国一宮・名神大社論社）','山梨県','笛吹市','山梨県笛吹市一宮町一宮1684',35.647758,138.697442,865,null,'http://asamajinja.jp/','甲斐国一宮。木花開耶姫命を祀る。','https://ja.wikipedia.org/wiki/浅間神社_(笛吹市)','Wikipedia',true,now()),
('unpo-ji-koshu','雲峰寺','うんぽうじ','temple','臨済宗妙心寺派','山梨県','甲州市','山梨県甲州市塩山上萩原2678',35.739472,138.804444,745,'十一面観音','https://www.unpouji.com/','武田家の「風林火山」軍旗を伝える古刹。','https://ja.wikipedia.org/wiki/雲峰寺','Wikipedia',true,now()),
('toko-ji-kofu','東光寺','とうこうじ','temple','臨済宗妙心寺派','山梨県','甲府市','山梨県甲府市東光寺3-7-37',35.667833,138.588444,1262,'薬師如来','https://kai-toukouji.com/','甲斐五山の一。蘭渓道隆ゆかりの禅刹。','https://ja.wikipedia.org/wiki/東光寺_(甲府市)','Wikipedia',true,now()),
('kogaku-ji-koshu','向嶽寺','こうがくじ','temple','臨済宗向嶽寺派','山梨県','甲州市','山梨県甲州市塩山上於曽2026',35.711167,138.722611,1380,'釈迦如来','https://www.kogakuji.com/','臨済宗向嶽寺派の大本山。','https://ja.wikipedia.org/wiki/向嶽寺','Wikipedia',true,now()),
('onko-ji-kofu','遠光寺','おんこうじ','temple','日蓮宗','山梨県','甲府市','山梨県甲府市伊勢2丁目',35.647806,138.568361,1214,'十界曼荼羅','https://www.onkouji.com/','甲斐の日蓮宗有力寺院。八角形の本堂で知られる。','https://ja.wikipedia.org/wiki/遠光寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='asama-jinja-fuefuki' and d.slug in ('konohanasakuyahime'))
or (t.slug='unpo-ji-koshu' and d.slug in ('juichimen_kannon'))
or (t.slug='toko-ji-kofu' and d.slug in ('yakushi_nyorai'))
or (t.slug='kogaku-ji-koshu' and d.slug in ('shaka_nyorai'))
on conflict do nothing;
