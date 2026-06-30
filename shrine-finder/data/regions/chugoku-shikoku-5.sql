-- 中国・四国 観光著名社寺 第5弾
-- 担当県: 鳥取,島根,岡山,広島,山口,徳島,香川,愛媛,高知
-- 出典: ja.wikipedia.org のinfobox十進座標を確認したもののみ。_have および既存chugoku-shikoku*.sql と重複なし。
-- 5件ごとに追記保存。座標がinfoboxに無いものは除外。

-- ===== バッチ1 (島根県・岡山県) =====
-- ① 新規神仏（既存に無いもののみ。on conflictで既存はスキップ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ikeda_mitsumasa','池田光政','いけだみつまさ','kami','人神','{}','史実','備前岡山藩主。名君として岡山神社に守護神として祀られる。','https://ja.wikipedia.org/wiki/池田光政','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ikeda_mitsumasa' and g.slug in ('gakumon','shusse','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nagahama-jinja-izumo','長浜神社','ながはまじんじゃ','shrine','長浜神社','島根県','出雲市','島根県出雲市西園町上長浜4258',35.345972,132.681028,null,null,'http://www.nagahamajinja.com/','国引き神話の八束水臣津野命を祀る。勝負・スポーツの神として信仰される。','https://ja.wikipedia.org/wiki/長浜神社','Wikipedia',true,now()),
('manpukuji-masuda','萬福寺','まんぷくじ','temple','時宗','島根県','益田市','島根県益田市東町25-33',34.678611,131.860028,1374,'阿弥陀如来',null,'益田氏の菩提寺。雪舟作と伝わる名勝庭園で知られる。','https://ja.wikipedia.org/wiki/萬福寺_(益田市)','Wikipedia',true,now()),
('ikoji-masuda','医光寺','いこうじ','temple','臨済宗東福寺派','島根県','益田市','島根県益田市染羽町4-29',34.680000,131.865694,1363,'薬師如来',null,'雪舟四大庭園の一つを擁する禅刹。総門は七尾城の門を移築。','https://ja.wikipedia.org/wiki/医光寺_(益田市)','Wikipedia',true,now()),
('anjuin-okayama','安住院','あんじゅういん','temple','真言宗善通寺派','岡山県','岡山市','岡山県岡山市中区国富3-1-29',34.6634417,133.9505639,749,'千手観音','http://www.anjuin.com','操山の麓に建つ古刹。岡山藩の祈願所。瀬戸内三十三観音霊場第12番。','https://ja.wikipedia.org/wiki/安住院','Wikipedia',true,now()),
('okayama-jinja','岡山神社','おかやまじんじゃ','shrine','岡山神社','岡山県','岡山市','岡山県岡山市北区石関町2-33',34.667750,133.931639,859,null,'http://www.okayama-jinjya.or.jp/','岡山城の北に鎮座する旧県社。随神門が重要文化財。','https://ja.wikipedia.org/wiki/岡山神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nagahama-jinja-izumo' and d.slug in ('yatsukamizuomitsuno')) or
   (t.slug='manpukuji-masuda' and d.slug in ('amida_nyorai')) or
   (t.slug='ikoji-masuda' and d.slug in ('yakushi_nyorai')) or
   (t.slug='anjuin-okayama' and d.slug in ('senju_kannon')) or
   (t.slug='okayama-jinja' and d.slug in ('okibitsuhiko','yamato_takeru'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='okayama-jinja' and d.slug in ('ikeda_mitsumasa'))
on conflict do nothing;

-- ===== バッチ2 (広島県・山口県) =====
-- ① 新規神仏（なし。既存slugのみ使用）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kokuzenji-hiroshima','國前寺','こくぜんじ','temple','日蓮宗','広島県','広島市','広島県広島市東区山根町32-1',34.403139,132.481250,1340,'三宝尊',null,'浅野家の祈願所となった日蓮宗の本山。本堂・庫裏が重要文化財。','https://ja.wikipedia.org/wiki/國前寺','Wikipedia',true,now()),
('hiroshima-toshogu','広島東照宮','ひろしまとうしょうぐう','shrine','広島東照宮','広島県','広島市','広島県広島市東区二葉の里2-1-18',34.40361,132.47556,1648,null,null,'浅野氏が徳川家康を祀る。被爆建物として唐門・翼廊が現存。','https://ja.wikipedia.org/wiki/広島東照宮','Wikipedia',true,now()),
('ryugeji-sera','龍華寺','りゅうげじ','temple','真言宗醍醐派','広島県','世羅郡世羅町','広島県世羅郡世羅町甲山',34.582639,133.059778,null,'十一面観音',null,'今高野山の中心寺院。弘法大師開基と伝わる。','https://ja.wikipedia.org/wiki/今高野山','Wikipedia',true,now()),
('daishoin-hagi','大照院','だいしょういん','temple','臨済宗南禅寺派','山口県','萩市','山口県萩市椿4132',34.395417,131.385806,1656,'釈迦如来',null,'萩藩主毛利家の菩提寺。墓所は国史跡。中国観音霊場第20番。','https://ja.wikipedia.org/wiki/大照院','Wikipedia',true,now()),
('joeiji-yamaguchi','常栄寺','じょうえいじ','temple','臨済宗東福寺派','山口県','山口市','山口県山口市宮野下2001-1',34.198,131.490,1563,'千手観音',null,'雪舟作と伝わる名勝庭園「雪舟庭」で知られる禅刹。','https://ja.wikipedia.org/wiki/常栄寺_(山口市)','Wikipedia',true,now()),
('yamaguchi-daijingu','山口大神宮','やまぐちだいじんぐう','shrine','山口大神宮','山口県','山口市','山口県山口市滝町4-4',34.184778,131.46806,1520,null,'http://www.yamaguchi-daijingu.or.jp/','大内義興が伊勢神宮を勧請。内宮・外宮を備え「西のお伊勢さま」と呼ばれる。','https://ja.wikipedia.org/wiki/山口大神宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hiroshima-toshogu' and d.slug in ('ieyasu')) or
   (t.slug='ryugeji-sera' and d.slug in ('juichimen_kannon')) or
   (t.slug='daishoin-hagi' and d.slug in ('shaka_nyorai')) or
   (t.slug='joeiji-yamaguchi' and d.slug in ('senju_kannon')) or
   (t.slug='yamaguchi-daijingu' and d.slug in ('amaterasu','toyouke'))
on conflict do nothing;

-- ===== バッチ3 (香川県・徳島県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenohiwashi','天日鷲命','あめのひわしのみこと','kami','天津神','{天日鷲翔矢命}','記紀','阿波忌部氏の祖神。麻・木綿など織物・産業の神。','https://ja.wikipedia.org/wiki/アメノヒワシ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenohiwashi' and g.slug in ('shobai','kaiun','suisan_noko'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sanuki-kokubunji','讃岐国分寺','さぬきこくぶんじ','temple','真言宗御室派','香川県','高松市','香川県高松市国分寺町国分2065',34.303139,133.94417,756,'十一面千手観音',null,'聖武天皇勅願の讃岐国分寺。境内が特別史跡。四国八十八ヶ所第80番。','https://ja.wikipedia.org/wiki/讃岐国分寺','Wikipedia',true,now()),
('kan-ei-jinja','冠纓神社','かんえいじんじゃ','shrine','冠纓神社','香川県','高松市','香川県高松市香南町由佐',34.238583,134.011556,861,null,null,'縁結びの神として知られる香南の総鎮守。巨大な獅子頭の夫婦獅子で有名。','https://ja.wikipedia.org/wiki/冠纓神社','Wikipedia',true,now()),
('jorokuji-tokushima-city','丈六寺','じょうろくじ','temple','曹洞宗','徳島県','徳島市','徳島県徳島市丈六町丈領',34.005222,134.550944,650,'聖観音',null,'「阿波の法隆寺」と称される名刹。観音堂・経蔵などが重要文化財。','https://ja.wikipedia.org/wiki/丈六寺','Wikipedia',true,now()),
('hachiman-jinja-tokushima','八幡神社','はちまんじんじゃ','shrine','八幡神社','徳島県','徳島市','徳島県徳島市八幡町',34.0631,134.5417,1697,null,null,'眉山の麓に鎮座する徳島市中五社の一つ。随身門が市指定文化財。','https://ja.wikipedia.org/wiki/八幡神社_(徳島市)','Wikipedia',true,now()),
('inbe-jinja','忌部神社','いんべじんじゃ','shrine','忌部神社','徳島県','徳島市','徳島県徳島市二軒屋町2-48',34.06028,134.54556,1892,null,null,'阿波忌部氏の祖神を祀る式内社・旧国幣中社。','https://ja.wikipedia.org/wiki/忌部神社','Wikipedia',true,now()),
('oji-jinja-tokushima','王子神社','おうじじんじゃ','shrine','王子神社','徳島県','徳島市','徳島県徳島市八万町向寺山55',34.041056,134.525722,null,null,null,'「猫神さん」として知られる神社。お松大権現の猫伝説で有名。','https://ja.wikipedia.org/wiki/王子神社_(徳島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sanuki-kokubunji' and d.slug in ('senju_kannon')) or
   (t.slug='kan-ei-jinja' and d.slug in ('chuai','hachiman','jingu_kogo')) or
   (t.slug='jorokuji-tokushima-city' and d.slug in ('sho_kannon')) or
   (t.slug='hachiman-jinja-tokushima' and d.slug in ('hachiman')) or
   (t.slug='inbe-jinja' and d.slug in ('amenohiwashi')) or
   (t.slug='oji-jinja-tokushima' and d.slug in ('amatsuhikone'))
on conflict do nothing;

-- ===== バッチ4 (愛媛県・高知県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yamauchi_kazutoyo','山内一豊','やまうちかずとよ','kami','人神','{山内一豊}','史実','土佐藩初代藩主。山内神社の祭神。','https://ja.wikipedia.org/wiki/山内一豊','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yamauchi_kazutoyo' and g.slug in ('shusse','kaiun','shobu'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('taihoji-matsuyama','大宝寺','たいほうじ','temple','真言宗豊山派','愛媛県','松山市','愛媛県松山市南江戸5-10-1',33.8400,132.7480,701,'阿弥陀如来',null,'本堂が愛媛県最古の国宝建築。「うば桜」伝説と小泉八雲の翻訳で知られる。','https://ja.wikipedia.org/wiki/大宝寺_(松山市)','Wikipedia',true,now()),
('izumo-taisha-matsuyama-bunshi','出雲大社松山分祠','いずもおおやしろまつやまぶんし','shrine','出雲大社教','愛媛県','松山市','愛媛県松山市本町3-5-5',33.8466833,132.7583806,1876,null,null,'出雲大社の御分霊を祀る分祠。縁結びの神として信仰される。','https://ja.wikipedia.org/wiki/出雲大社松山分祠','Wikipedia',true,now()),
('kaeriguma-hachiman','還熊八幡神社','かえりぐまはちまんじんじゃ','shrine','還熊八幡神社','愛媛県','松山市','愛媛県松山市山越3-3-2',33.859056,132.762750,null,null,null,'松山市山越に鎮座する八幡神社。地域の鎮守。','https://ja.wikipedia.org/wiki/還熊八幡神社','Wikipedia',true,now()),
('isono-jinja','伊曽乃神社','いそのじんじゃ','shrine','伊曽乃神社','愛媛県','西条市','愛媛県西条市中野甲1649',33.89278,133.186889,null,null,null,'西条まつりで知られる旧国幣中社。だんじり奉納数日本一。','https://ja.wikipedia.org/wiki/伊曽乃神社','Wikipedia',true,now()),
('yamauchi-jinja','山内神社','やまうちじんじゃ','shrine','山内神社','高知県','高知市','高知県高知市鷹匠町2-4-65',33.555528,133.531806,1935,null,null,'土佐藩主山内家歴代を祀る。旧別格官幣社。','https://ja.wikipedia.org/wiki/山内神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='taihoji-matsuyama' and d.slug in ('amida_nyorai')) or
   (t.slug='izumo-taisha-matsuyama-bunshi' and d.slug in ('okuninushi')) or
   (t.slug='kaeriguma-hachiman' and d.slug in ('hachiman')) or
   (t.slug='isono-jinja' and d.slug in ('amaterasu')) or
   (t.slug='yamauchi-jinja' and d.slug in ('yamauchi_kazutoyo'))
on conflict do nothing;

-- ===== バッチ5 (鳥取県・岡山県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('suseribime','須勢理毘売命','すせりびめのみこと','kami','国津神','{須世理姫}','記紀','素戔嗚尊の娘で大国主神の正妻。縁結びの女神。','https://ja.wikipedia.org/wiki/スセリビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='suseribime' and g.slug in ('enmusubi','renai','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fudoin-iwayado','不動院岩屋堂','ふどういんいわやどう','temple','真言宗醍醐派','鳥取県','八頭郡若桜町','鳥取県八頭郡若桜町岩屋堂',35.300361,134.430361,806,'不動明王',null,'天然の岩窟内に建つ懸造の仏堂。日本三大投入堂の一つで重要文化財。','https://ja.wikipedia.org/wiki/不動院岩屋堂','Wikipedia',true,now()),
('senjuji-okayama','千手寺','せんじゅじ','temple','高野山真言宗','岡山県','岡山市','岡山県岡山市北区大内田581',34.63167,133.845306,752,'千手観音','https://senjyuji.web.fc2.com/','報恩大師開基と伝わる古刹。仁和寺の末寺で一等格院。','https://ja.wikipedia.org/wiki/千手寺_(岡山市)','Wikipedia',true,now()),
('ryusenji-okayama','龍泉寺','りゅうせんじ','temple','日蓮宗最上稲荷教','岡山県','岡山市','岡山県岡山市北区下足守900',34.7162611,133.8251833,749,'最上位経王大菩薩',null,'最上稲荷の奥之院とされる龍王池の霊地。鬼子母神・八大龍王を祀る。','https://ja.wikipedia.org/wiki/龍泉寺_(岡山市)','Wikipedia',true,now()),
('rendaiji-kurashiki','蓮台寺','れんだいじ','temple','真言宗御室派','岡山県','倉敷市','岡山県倉敷市児島由加2855',34.5056250,133.850694,738,'十一面観音',null,'由加山の本坊。由加大権現を祀る。日本一の木造不動明王立像で知られる。','https://ja.wikipedia.org/wiki/蓮台寺_(倉敷市)','Wikipedia',true,now()),
('bicchu-kokusojagu','備中国総社宮','びっちゅうこくそうじゃぐう','shrine','備中国総社宮','岡山県','総社市','岡山県総社市総社2-18-1',34.6769611,133.7538778,null,null,null,'備中国の324社を合祀した総社。後楽園の作庭に影響を与えた庭園で知られる。','https://ja.wikipedia.org/wiki/備中国総社宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fudoin-iwayado' and d.slug in ('fudo_myoo')) or
   (t.slug='senjuji-okayama' and d.slug in ('senju_kannon')) or
   (t.slug='ryusenji-okayama' and d.slug in ('saijo_inari')) or
   (t.slug='rendaiji-kurashiki' and d.slug in ('juichimen_kannon')) or
   (t.slug='bicchu-kokusojagu' and d.slug in ('okuninushi','suseribime'))
on conflict do nothing;

-- ===== バッチ6 (島根県・山口県) =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('hayaakitsuhime','速秋津比売神','はやあきつひめのかみ','kami','国津神','{速秋津姫,水戸神}','記紀','水戸（河口）を司る祓いと水の女神。','https://ja.wikipedia.org/wiki/ハヤアキツヒコ・ハヤアキツヒメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='hayaakitsuhime' and g.slug in ('yakubarai','mizu_amagoi','kaijo_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iya-jinja','揖夜神社','いやじんじゃ','shrine','揖夜神社','島根県','松江市','島根県松江市東出雲町揖屋2229',35.430500,133.154111,null,null,null,'黄泉比良坂の神話で知られる意宇六社の一社。式内社。','https://ja.wikipedia.org/wiki/揖夜神社','Wikipedia',true,now()),
('mefu-jinja-matsue','売布神社','めふじんじゃ','shrine','売布神社','島根県','松江市','島根県松江市和多見町81',35.466389,133.058806,null,null,null,'祓いと水の女神を祀る式内社。出雲國神仏霊場第6番。','https://ja.wikipedia.org/wiki/売布神社_(松江市)','Wikipedia',true,now()),
('taga-jinja-matsue','多賀神社','たがじんじゃ','shrine','多賀神社','島根県','松江市','島根県松江市朝酌町970',35.45500,133.10167,null,null,null,'大橋川のほとりに鎮座する旧村社。神在祭が行われる。','https://ja.wikipedia.org/wiki/多賀神社_(松江市)','Wikipedia',true,now()),
('taineiji-nagato','大寧寺','たいねいじ','temple','曹洞宗','山口県','長門市','山口県長門市深川湯本1074',34.328222,131.162833,1410,'釈迦如来',null,'大内義隆終焉の地。大内氏の墓所がある曹洞宗の名刹。','https://ja.wikipedia.org/wiki/大寧寺','Wikipedia',true,now()),
('suo-kokubunji','周防国分寺','すおうこくぶんじ','temple','高野山真言宗','山口県','防府市','山口県防府市国分寺町2-67',34.062075,131.579389,741,'薬師如来','http://www.suoukokubunji.jp/','創建時の境内をほぼ維持する周防国分寺。金堂が重要文化財。','https://ja.wikipedia.org/wiki/周防国分寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iya-jinja' and d.slug in ('izanami')) or
   (t.slug='mefu-jinja-matsue' and d.slug in ('hayaakitsuhime')) or
   (t.slug='taga-jinja-matsue' and d.slug in ('susanoo')) or
   (t.slug='taineiji-nagato' and d.slug in ('shaka_nyorai')) or
   (t.slug='suo-kokubunji' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;
