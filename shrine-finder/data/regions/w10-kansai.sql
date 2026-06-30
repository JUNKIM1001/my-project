-- w10-kansai.sql  近畿(7府県)社寺データ拡張 第10弾
-- 仕様: AGENT_SPEC.md 準拠。_have_kansai.txt と重複しない著名社寺。
-- ja.wikipedia.org infobox の十進座標で裏取り済み。座標無しは除外。

-- ① 新規神仏（既存に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenomikumari','天之水分大神','あめのみくまりのおおかみ','kami','天津神','{}','記紀','水の分配を司る水分（みくまり）の神。','https://ja.wikipedia.org/wiki/吉野水分神社','Wikipedia',true,now()),
('kuninomikumari','国水分神','くにのみくまりのかみ','kami','国津神','{}','記紀','国土の水の分配を司る水分の神。','https://ja.wikipedia.org/wiki/宇太水分神社','Wikipedia',true,now()),
('hayaakitsuhiko','速秋津比古神','はやあきつひこのかみ','kami','国津神','{}','記紀','水戸・河口を司る神。','https://ja.wikipedia.org/wiki/宇太水分神社','Wikipedia',true,now()),
('tsuhisusune','都久宿禰','つくすくね','kami','人神','{}','社伝','平群氏の祖神として祀られる。','https://ja.wikipedia.org/wiki/平群坐紀氏神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenomikumari' and g.slug in ('mizu_amagoi','suisan_noko','anzan'))
or (d.slug='kuninomikumari' and g.slug in ('mizu_amagoi','suisan_noko'))
or (d.slug='hayaakitsuhiko' and g.slug in ('mizu_amagoi','kaijo_anzen'))
or (d.slug='tsuhisusune' and g.slug in ('kaiun','kanai_anzen'))
on conflict do nothing;

-- ===== バッチ1 (1-5) =====
-- 吉野水分神社(奈良/吉野), 金峯神社(奈良/吉野), 宇太水分神社(奈良/宇陀), 平群坐紀氏神社(奈良/平群), 如意輪寺(奈良/吉野)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yoshino-mikumari-jinja','吉野水分神社','よしのみくまりじんじゃ','shrine','吉野水分神社（旧村社・世界遺産）','奈良県','吉野郡吉野町','奈良県吉野郡吉野町吉野山1612',34.353917,135.873139,null,null,null,'子守宮として信仰される世界遺産。豊臣秀頼が再建した桃山様式の社殿。','https://ja.wikipedia.org/wiki/吉野水分神社','Wikipedia',true,now()),
('kinpu-jinja-yoshino','金峯神社_(吉野町)','きんぷじんじゃ','shrine','金峯神社（旧郷社・世界遺産）','奈良県','吉野郡吉野町','奈良県吉野郡吉野町吉野山1651',34.342583,135.881806,null,null,null,'吉野山の地主神を祀る世界遺産。源義経の隠れ塔で知られる。','https://ja.wikipedia.org/wiki/金峯神社_(吉野町)','Wikipedia',true,now()),
('uda-mikumari-jinja','宇太水分神社','うだみくまりじんじゃ','shrine','宇太水分神社（式内大社・旧県社）','奈良県','宇陀市','奈良県宇陀市菟田野古市場244-3',34.474667,135.970694,null,null,'https://udanomikumari.sakura.ne.jp/','大和四水分の一。国宝の三殿が並ぶ式内大社。','https://ja.wikipedia.org/wiki/宇太水分神社','Wikipedia',true,now()),
('heguri-niimasu-kiuji-jinja','平群坐紀氏神社','へぐりにいますきうじじんじゃ','shrine','平群坐紀氏神社（式内大社・旧村社）','奈良県','生駒郡平群町','奈良県生駒郡平群町上庄五丁目1-1',34.6356528,135.7036167,null,null,null,'平群氏ゆかりの式内大社。延喜式神名帳に名神大社として記載。','https://ja.wikipedia.org/wiki/平群坐紀氏神社','Wikipedia',true,now()),
('nyoirin-ji-yoshino','如意輪寺','にょいりんじ','temple','浄土宗','奈良県','吉野郡吉野町','奈良県吉野郡吉野町吉野山1024',34.364556,135.867861,901,'如意輪観音','http://nyoirinji.com/','後醍醐天皇の勅願寺。近畿三十六不動尊霊場第30番。','https://ja.wikipedia.org/wiki/如意輪寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yoshino-mikumari-jinja' and d.slug in ('amenomikumari'))
or (t.slug='kinpu-jinja-yoshino' and d.slug in ('kanayamahiko'))
or (t.slug='uda-mikumari-jinja' and d.slug in ('amenomikumari','hayaakitsuhiko','kuninomikumari'))
or (t.slug='heguri-niimasu-kiuji-jinja' and d.slug in ('amaterasu','amenokoyane','tsuhisusune','hachiman'))
or (t.slug='nyoirin-ji-yoshino' and d.slug in ('nyoirin_kannon'))
on conflict do nothing;

-- ===== バッチ2 (6-10) =====
-- 穴太寺(京都/亀岡), 金剛院(京都/舞鶴), 楊谷寺(京都/長岡京), 随願寺(兵庫/姫路), 桑実寺(滋賀/近江八幡)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('anao-ji','穴太寺','あなおじ','temple','天台宗','京都府','亀岡市','京都府亀岡市曽我部町穴太東辻46',35.006675,135.5491917,705,'薬師如来','https://saikoku33.gr.jp/place/21','西国三十三所第21番札所。身代わり観音と庭園で知られる古刹。','https://ja.wikipedia.org/wiki/穴太寺','Wikipedia',true,now()),
('kongo-in-maizuru','金剛院_(舞鶴市)','こんごういん','temple','真言宗東寺派','京都府','舞鶴市','京都府舞鶴市鹿原595',35.476472,135.446944,829,'不動明王','https://konngouin.lovepop.jp/','丹後のもみじ寺と称される古刹。快慶作の仏像や三重塔を有す。','https://ja.wikipedia.org/wiki/金剛院_(舞鶴市)','Wikipedia',true,now()),
('yokoku-ji','楊谷寺','ようこくじ','temple','西山浄土宗','京都府','長岡京市','京都府長岡京市浄土谷堂ノ谷2',34.914333,135.652694,806,'十一面千手千眼観音菩薩','https://yanagidani.jp/','柳谷観音として知られる眼病平癒の霊場。新西国三十三箇所第17番。','https://ja.wikipedia.org/wiki/楊谷寺','Wikipedia',true,now()),
('zuigan-ji-himeji','随願寺','ずいがんじ','temple','天台宗','兵庫県','姫路市','兵庫県姫路市白国三丁目12-5',34.8721583,134.7127417,null,'薬師如来','https://saikoku33.gr.jp/place/15','増位山に建つ播磨の古刹。播磨西国三十三箇所第4番。','https://ja.wikipedia.org/wiki/随願寺','Wikipedia',true,now()),
('kuwanomi-dera','桑実寺','くわのみでら','temple','天台宗','滋賀県','近江八幡市','滋賀県近江八幡市安土町桑実寺675',35.1481194,136.1540861,677,'薬師如来','https://saikoku-yakushi.jp/','繖山に建つ古刹。足利義晴が仮幕府を置いた地。日本最古の養蚕伝来の地とされる。','https://ja.wikipedia.org/wiki/桑実寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='anao-ji' and d.slug in ('yakushi_nyorai'))
or (t.slug='kongo-in-maizuru' and d.slug in ('fudo_myoo'))
or (t.slug='yokoku-ji' and d.slug in ('senju_kannon'))
or (t.slug='zuigan-ji-himeji' and d.slug in ('yakushi_nyorai'))
or (t.slug='kuwanomi-dera' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- ① 追加神仏（バッチ3で必要）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('hoki_bosatsu','法起菩薩','ほうきぼさつ','buddha','菩薩','{}','修験道','役行者が感得したとされる金剛山の本尊。','https://ja.wikipedia.org/wiki/転法輪寺_(御所市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='hoki_bosatsu' and g.slug in ('yakubarai','kaiun','shobu'))
on conflict do nothing;

-- ===== バッチ3 (11-15) =====
-- 西明寺/湖東三山(滋賀/甲良), 長保寺(和歌山/海南), 榮山寺(奈良/五條), 転法輪寺(奈良/御所), 根来寺(和歌山/岩出)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saimyo-ji-koto','西明寺_(甲良町)','さいみょうじ','temple','天台宗','滋賀県','犬上郡甲良町','滋賀県犬上郡甲良町大字池寺26',35.183972,136.284278,834,'薬師如来','http://www.saimyouji.com/','湖東三山の一。国宝の本堂・三重塔を有す紅葉の名刹。','https://ja.wikipedia.org/wiki/西明寺_(滋賀県甲良町)','Wikipedia',true,now()),
('cho-ho-ji','長保寺','ちょうほうじ','temple','天台宗','和歌山県','海南市','和歌山県海南市下津町上689',34.109111,135.165639,1000,'釈迦如来','http://www.chohoji.or.jp/','紀州徳川家の菩提寺。本堂・多宝塔・大門の三棟が国宝。','https://ja.wikipedia.org/wiki/長保寺','Wikipedia',true,now()),
('eisan-ji','榮山寺','えいさんじ','temple','真言宗豊山派','奈良県','五條市','奈良県五條市小島町503',34.355944,135.720667,719,'薬師如来','https://www.eisanji.com/','藤原南家ゆかりの古刹。国宝の八角円堂と梵鐘で知られる。','https://ja.wikipedia.org/wiki/榮山寺','Wikipedia',true,now()),
('tenporin-ji-gose','転法輪寺_(御所市)','てんぽうりんじ','temple','真言宗醍醐派','奈良県','御所市','奈良県御所市高天',34.419694,135.671944,665,'法起菩薩','http://www.katsuragi-syugen.or.jp/','金剛山頂に建つ葛城修験の中心道場。役行者開創と伝わる。','https://ja.wikipedia.org/wiki/転法輪寺_(御所市)','Wikipedia',true,now()),
('negoro-ji','根来寺','ねごろじ','temple','新義真言宗','和歌山県','岩出市','和歌山県岩出市根来2286',34.28722,135.31667,1130,'大日如来','https://www.negoroji.org/','覚鑁が開いた新義真言宗の総本山。国宝の大塔で知られる。','https://ja.wikipedia.org/wiki/根来寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saimyo-ji-koto' and d.slug in ('yakushi_nyorai'))
or (t.slug='cho-ho-ji' and d.slug in ('shaka_nyorai'))
or (t.slug='eisan-ji' and d.slug in ('yakushi_nyorai'))
or (t.slug='tenporin-ji-gose' and d.slug in ('hoki_bosatsu'))
or (t.slug='negoro-ji' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- ① 追加神仏（バッチ4で必要）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kudara_king','百済王','くだらのこにきし','kami','人神','{}','社伝','百済王氏の祖。百済王族の霊を祀る。','https://ja.wikipedia.org/wiki/百済王神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kudara_king' and g.slug in ('kaiun','gakumon'))
on conflict do nothing;

-- ===== バッチ4 (16-20) =====
-- 四天王寺(三重/津), 慈眼寺/野崎観音(大阪/大東), 星田神社(大阪/交野), 百済王神社(大阪/枚方), 意賀美神社(大阪/枚方)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shitennoji-tsu','四天王寺_(津市)','してんのうじ','temple','曹洞宗','三重県','津市','三重県津市栄町1丁目892',34.72778,136.50972,null,'薬師如来','http://www.sitennoji.net/','聖徳太子建立と伝わる古刹。織田信長の母・土田御前の墓がある。西国薬師四十九霊場第34番。','https://ja.wikipedia.org/wiki/四天王寺_(津市)','Wikipedia',true,now()),
('jigen-ji-nozaki','慈眼寺_(大東市)','じげんじ','temple','曹洞宗','大阪府','大東市','大阪府大東市野崎2丁目7-1',34.7191972,135.644675,749,'十一面観音','http://www.nozakikannon.or.jp/','野崎観音として親しまれる。江戸期から続く野崎参りで知られる。','https://ja.wikipedia.org/wiki/野崎観音','Wikipedia',true,now()),
('hoshida-jinja','星田神社','ほしだじんじゃ','shrine','星田神社（旧村社）','大阪府','交野市','大阪府交野市星田2丁目5-14',34.765306,135.672111,null,null,'https://www.hoshidajinja.com/','住吉三神を祀る交野の古社。星田妙見宮とともに信仰される。','https://ja.wikipedia.org/wiki/星田神社','Wikipedia',true,now()),
('kudarao-jinja','百済王神社','くだらおうじんじゃ','shrine','百済王神社（旧村社）','大阪府','枚方市','大阪府枚方市中宮西之町1-68',34.815417,135.66028,null,null,'http://www.kudaraojinja.jp/','百済王氏ゆかりの古社。特別史跡百済寺跡に隣接する。','https://ja.wikipedia.org/wiki/百済王神社','Wikipedia',true,now()),
('okami-jinja-hirakata','意賀美神社_(枚方市)','おかみじんじゃ','shrine','意賀美神社（式内社・旧村社）','大阪府','枚方市','大阪府枚方市枚方上之町1-12',34.813528,135.64375,null,null,null,'淀川を見下ろす万年寺山に鎮座する式内社。梅林の名所。','https://ja.wikipedia.org/wiki/意賀美神社_(枚方市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shitennoji-tsu' and d.slug in ('yakushi_nyorai'))
or (t.slug='jigen-ji-nozaki' and d.slug in ('juichimen_kannon'))
or (t.slug='hoshida-jinja' and d.slug in ('sumiyoshi','jingu_kogo'))
or (t.slug='kudarao-jinja' and d.slug in ('kudara_king','susanoo'))
or (t.slug='okami-jinja-hirakata' and d.slug in ('takaokami'))
on conflict do nothing;

-- ===== バッチ5 (21-25) =====
-- 鏑射寺(兵庫/神戸), 伽耶院(兵庫/三木), 如意寺(兵庫/神戸), 櫟野寺(滋賀/甲賀), 木之本地蔵院(滋賀/長浜)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kaburai-ji','鏑射寺','かぶらいじ','temple','真言宗単立','兵庫県','神戸市','兵庫県神戸市北区道場町生野1078-1',34.8745861,135.2559222,581,'大日如来','http://www.kaburaiji.or.jp/','聖徳太子開創と伝わる神戸の古刹。三鈷山の山岳信仰の地。','https://ja.wikipedia.org/wiki/鏑射寺','Wikipedia',true,now()),
('gaya-in','伽耶院','がやいん','temple','本山修験宗','兵庫県','三木市','兵庫県三木市志染町大谷410',34.805583,135.058861,645,'毘沙門天','https://www.gayain.or.jp/index.html','本山修験宗の古刹。新西国三十三箇所第26番。','https://ja.wikipedia.org/wiki/伽耶院','Wikipedia',true,now()),
('nyo-i-ji-kobe','如意寺_(神戸市)','にょいじ','temple','天台宗','兵庫県','神戸市','兵庫県神戸市西区櫨谷町谷口259',34.6990722,135.0195944,645,'地蔵菩薩','https://saikoku33.gr.jp/','法道仙人開創と伝わる古刹。重文の三重塔・文殊堂・阿弥陀堂が残る。','https://ja.wikipedia.org/wiki/如意寺_(神戸市)','Wikipedia',true,now()),
('rakuya-ji','櫟野寺','らくやじ','temple','天台宗','滋賀県','甲賀市','滋賀県甲賀市甲賀町櫟野1377',34.897083,136.252389,792,'十一面観音','https://www.rakuyaji.jp/','最澄開創と伝わる甲賀の古刹。国宝の十一面観音坐像を本尊とする。','https://ja.wikipedia.org/wiki/櫟野寺','Wikipedia',true,now()),
('kinomoto-jizoin','木之本地蔵院','きのもとじぞういん','temple','時宗','滋賀県','長浜市','滋賀県長浜市木之本町木之本944',35.506028,136.225889,675,'地蔵菩薩','https://www.kinomoto-jizo.com/','日本三大地蔵の一。眼病平癒の信仰を集める時宗の古刹。','https://ja.wikipedia.org/wiki/木之本地蔵院','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kaburai-ji' and d.slug in ('dainichi_nyorai'))
or (t.slug='gaya-in' and d.slug in ('bishamonten'))
or (t.slug='nyo-i-ji-kobe' and d.slug in ('jizo_bosatsu'))
or (t.slug='rakuya-ji' and d.slug in ('juichimen_kannon'))
or (t.slug='kinomoto-jizoin' and d.slug in ('jizo_bosatsu'))
on conflict do nothing;

-- ① 追加神仏（バッチ6で必要）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kumano_fusumi','熊野夫須美大神','くまのふすみのおおかみ','kami','国津神','{}','記紀','熊野三山に祀られる結びの女神。伊邪那美命と同一視される。','https://ja.wikipedia.org/wiki/熊野那智大社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kumano_fusumi' and g.slug in ('enmusubi','kaiun','byoki_heyu'))
on conflict do nothing;

-- ===== バッチ6 (26-30) =====
-- 木本八幡宮(和歌山/和歌山), 神倉神社(和歌山/新宮), 熊野三所大神社(和歌山/那智勝浦), 補陀洛山寺(和歌山/那智勝浦), 水門吹上神社(和歌山/和歌山)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kimoto-hachimangu','木本八幡宮','きのもとはちまんぐう','shrine','木本八幡宮（旧県社）','和歌山県','和歌山市','和歌山県和歌山市西庄1番地',34.246639,135.135,null,null,null,'樫の宮山に鎮座する八幡宮。県無形民俗文化財の梯子獅子で知られる。','https://ja.wikipedia.org/wiki/木本八幡宮','Wikipedia',true,now()),
('kamikura-jinja','神倉神社','かみくらじんじゃ','shrine','神倉神社（熊野速玉大社摂社・世界遺産）','和歌山県','新宮市','和歌山県新宮市神倉1丁目13-8',33.72225,135.982833,null,null,null,'ゴトビキ岩を神体とする熊野の磐座信仰の聖地。お燈祭で知られる世界遺産。','https://ja.wikipedia.org/wiki/神倉神社','Wikipedia',true,now()),
('kumano-sansho-omiwa-jinja','熊野三所大神社','くまのさんしょおおみわじんじゃ','shrine','熊野三所大神社（旧村社）','和歌山県','東牟婁郡那智勝浦町','和歌山県東牟婁郡那智勝浦町浜の宮350',33.6449028,135.9344056,null,null,null,'浜の宮王子に鎮座し熊野三山の神を祀る。補陀洛山寺と並ぶ世界遺産。','https://ja.wikipedia.org/wiki/熊野三所大神社','Wikipedia',true,now()),
('fudarakusan-ji','補陀洛山寺','ふだらくさんじ','temple','天台宗','和歌山県','東牟婁郡那智勝浦町','和歌山県東牟婁郡那智勝浦町浜の宮348',33.644725,135.9344361,null,'三貌十一面千手千眼観世音菩薩','https://www.nachikan.jp/','補陀洛渡海で知られる世界遺産。観音浄土を目指す信仰の地。','https://ja.wikipedia.org/wiki/補陀洛山寺','Wikipedia',true,now()),
('minato-fukiage-jinja','水門吹上神社','みなとふきあげじんじゃ','shrine','水門吹上神社（旧県社）','和歌山県','和歌山市','和歌山県和歌山市小野町2丁目1番',34.23222,135.164944,null,null,null,'古事記の男之水門の地とされる古社。神武天皇ゆかりの社。','https://ja.wikipedia.org/wiki/水門吹上神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kimoto-hachimangu' and d.slug in ('hachiman','jingu_kogo','amaterasu'))
or (t.slug='kamikura-jinja' and d.slug in ('amaterasu','takakurashita'))
or (t.slug='kumano-sansho-omiwa-jinja' and d.slug in ('kumano_fusumi','ketsumimiko','hayatama'))
or (t.slug='fudarakusan-ji' and d.slug in ('senju_kannon'))
or (t.slug='minato-fukiage-jinja' and d.slug in ('ebisu','okuninushi'))
on conflict do nothing;

-- ===== バッチ7 (31-35) =====
-- 伝香寺(奈良/奈良), 璉珹寺(奈良/奈良), 岩屋寺(京都/京都山科), 長建寺(京都/京都伏見), 正暦寺(奈良/奈良)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('denko-ji','伝香寺','でんこうじ','temple','律宗','奈良県','奈良市','奈良県奈良市小川町24',34.680611,135.82575,771,'釈迦如来','https://saidaiji.or.jp/','筒井順慶の母が再興した菩提寺。散り椿で知られる奈良三名椿の一。','https://ja.wikipedia.org/wiki/伝香寺','Wikipedia',true,now()),
('renjo-ji','璉珹寺','れんじょうじ','temple','浄土真宗遣迎院派','奈良県','奈良市','奈良県奈良市西紀寺町45',34.6733306,135.8331389,null,'阿弥陀如来','https://renjoji.or.jp/','女性の裸形阿弥陀如来立像を本尊とする古刹。','https://ja.wikipedia.org/wiki/璉珹寺','Wikipedia',true,now()),
('iwaya-ji-kyoto','岩屋寺_(京都市)','いわやでら','temple','曹洞宗','京都府','京都市','京都府京都市山科区西野山桜ノ馬場町96',34.968972,135.795972,897,'大聖不動明王','https://ja.kyoto.travel/','大石内蔵助ゆかりの寺。山科に隠棲した遺品を伝える。','https://ja.wikipedia.org/wiki/岩屋寺_(京都市)','Wikipedia',true,now()),
('choken-ji-kyoto','長建寺_(京都市)','ちょうけんじ','temple','真言宗醍醐派','京都府','京都市','京都府京都市伏見区東柳町511',34.928361,135.76083,1699,'八臂弁才天','https://ja.kyoto.travel/','伏見奉行が建立した弁天信仰の寺。早咲きの糸桜で知られる。','https://ja.wikipedia.org/wiki/長建寺_(京都市)','Wikipedia',true,now()),
('shoryaku-ji','正暦寺','しょうりゃくじ','temple','菩提山真言宗','奈良県','奈良市','奈良県奈良市菩提山町157',34.644667,135.868444,992,'薬師如来','http://shoryakuji.jp/','日本清酒発祥の地とされる古刹。錦の里と称される紅葉の名所。','https://ja.wikipedia.org/wiki/正暦寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='denko-ji' and d.slug in ('shaka_nyorai'))
or (t.slug='renjo-ji' and d.slug in ('amida_nyorai'))
or (t.slug='iwaya-ji-kyoto' and d.slug in ('fudo_myoo'))
or (t.slug='choken-ji-kyoto' and d.slug in ('benzaiten'))
or (t.slug='shoryaku-ji' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;
