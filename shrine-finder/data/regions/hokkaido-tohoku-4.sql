-- 北海道・東北 追加分 (hokkaido-tohoku-4.sql)
-- 担当: 北海道,青森,岩手,宮城,秋田,山形,福島
-- ja.wikipedia.org infobox の十進座標で裏取り。既存4ファイル・_have リストと重複なし。

-- ===== ① 新規神仏 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sukunahikona','少彦名命','すくなひこなのみこと','kami','国津神','{}','記紀','大国主と国造りを行った医薬・温泉・酒造の小神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ② 新規神仏のご利益 =====
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sukunahikona' and g.slug in ('byoki_heyu','shobai','kaiun'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 1) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanahebisui-jinja','金蛇水神社','かなへびすいじんじゃ','shrine','金蛇水神社','宮城県','岩沼市','宮城県岩沼市三色吉字水神7',38.119694,140.837944,null,null,'https://kanahebi.cdx.jp/','金運・商売繁盛で知られる水神の社。藤と牡丹の名所。','https://ja.wikipedia.org/wiki/金蛇水神社','Wikipedia',true,now()),
('sendai-toshogu','仙台東照宮','せんだいとうしょうぐう','shrine','仙台東照宮','宮城県','仙台市','宮城県仙台市青葉区東照宮一丁目6-1',38.280194,140.885083,1654,null,'http://s-toshogu.jp/','伊達忠宗が徳川家康を祀って創建。重要文化財の社殿が残る。','https://ja.wikipedia.org/wiki/仙台東照宮','Wikipedia',true,now()),
('tsutsujigaoka-tenmangu','榴岡天満宮','つつじがおかてんまんぐう','shrine','榴岡天満宮','宮城県','仙台市','宮城県仙台市宮城野区榴ケ岡105-3',38.260757,140.893302,974,null,'https://tsutsujigaokatenmangu.jp/','学問の神・菅原道真を祀る仙台の天満宮。','https://ja.wikipedia.org/wiki/榴岡天満宮','Wikipedia',true,now()),
('akiu-jinja','秋保神社','あきうじんじゃ','shrine','秋保神社','宮城県','仙台市','宮城県仙台市太白区秋保町長袋字清水久保北22',38.263610,140.659611,808,null,'https://akiu.org/','勝負の神として信仰を集める秋保温泉郷の社。','https://ja.wikipedia.org/wiki/秋保神社','Wikipedia',true,now()),
('usu-zenkoji','有珠善光寺','うすぜんこうじ','temple','浄土宗','北海道','伊達市','北海道伊達市有珠町124番地',42.521110,140.780000,826,'阿弥陀如来','https://www.usu-zenkoji.jp','蝦夷三官寺の一つ。桜の名所として知られる古刹。','https://ja.wikipedia.org/wiki/有珠善光寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 1) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanahebisui-jinja' and d.slug in ('mizuhanome'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='kanahebisui-jinja' and d.slug in ('okuninushi','sukunahikona'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sendai-toshogu' and d.slug in ('ieyasu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tsutsujigaoka-tenmangu' and d.slug in ('michizane'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='akiu-jinja' and d.slug in ('takeminakata'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='usu-zenkoji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 2) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zenpoji','善寳寺','ぜんぽうじ','temple','曹洞宗','山形県','鶴岡市','山形県鶴岡市下川字関根100',38.772672,139.767314,940,'薬師如来','http://www.龍王尊.jp/','龍神信仰で名高い曹洞宗の祈祷寺。海上安全・大漁祈願で知られる。','https://ja.wikipedia.org/wiki/善寳寺','Wikipedia',true,now()),
('yachi-hachimangu','谷地八幡宮','やちはちまんぐう','shrine','谷地八幡宮','山形県','西村山郡河北町','山形県西村山郡河北町谷地乙224',38.426028,140.313060,1091,null,'https://www.yachihachimangu.jp/','源義家ゆかりの八幡宮。林家舞楽(国指定重要無形民俗文化財)で有名。','https://ja.wikipedia.org/wiki/谷地八幡宮','Wikipedia',true,now()),
('mitsuishi-jinja-morioka','三ツ石神社','みついしじんじゃ','shrine','三ツ石神社','岩手県','盛岡市','岩手県盛岡市名須川町2-1',39.709000,141.154361,null,null,null,'三つの巨石にまつわる「岩手」「不来方」地名伝説で知られる社。','https://ja.wikipedia.org/wiki/三ツ石神社','Wikipedia',true,now()),
('asaka-kunitsuko-jinja','安積国造神社','あさかくにつこじんじゃ','shrine','安積国造神社','福島県','郡山市','福島県郡山市清水台一丁目6-23',37.398781,140.381997,143,null,'http://www.asakakunituko.jp/','郡山総鎮守。秋祭りの山車と神輿で賑わう旧県社。','https://ja.wikipedia.org/wiki/安積国造神社','Wikipedia',true,now()),
('futahashira-jinja','二柱神社','ふたはしらじんじゃ','shrine','二柱神社','宮城県','仙台市','宮城県仙台市泉区市名坂字御釜田',38.319000,140.885944,1026,null,'https://f-shrine.com/index.html','縁結び・子育ての神として人気の社。旧称「丹波多神社」。','https://ja.wikipedia.org/wiki/二柱神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 2) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zenpoji' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yachi-hachimangu' and d.slug in ('hachiman'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mitsuishi-jinja-morioka' and d.slug in ('sukunahikona'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='asaka-kunitsuko-jinja' and d.slug in ('wakumusubi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='futahashira-jinja' and d.slug in ('izanagi','izanami'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='futahashira-jinja' and d.slug in ('ebisu'))
on conflict do nothing;

-- ===== 追加神仏 (batch 3用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('wakeikazuchi','別雷神','わけいかづちのかみ','kami','天津神','{}','記紀','賀茂別雷神社の主祭神。雷を司り厄除・電気守護の神。','https://ja.wikipedia.org/wiki/賀茂別雷神社','Wikipedia',true,now()),
('kamotamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{}','記紀','賀茂別雷神を生んだ母神。下鴨神社に祀られる。','https://ja.wikipedia.org/wiki/タマヨリビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='wakeikazuchi' and g.slug in ('yakubarai','kaiun','majo_kekkai'))
   or (d.slug='kamotamayorihime' and g.slug in ('enmusubi','anzan','kosodate'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 3) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kamo-jinja-sendai','賀茂神社','かもじんじゃ','shrine','賀茂神社（仙台市）','宮城県','仙台市','宮城県仙台市泉区古内字糺',38.321139,140.849056,1696,null,null,'上賀茂・下賀茂の二社が並ぶ古社。茅葺社殿は県指定文化財。','https://ja.wikipedia.org/wiki/賀茂神社_(仙台市)','Wikipedia',true,now()),
('mutsu-soshanomiya','陸奥総社宮','むつそうしゃのみや','shrine','陸奥総社宮','宮城県','多賀城市','宮城県多賀城市市川字奏社1',38.311061,140.993319,null,null,'http://sousyanomiya.jp/','陸奥国の総社。国司が国内諸社を一括参拝した社。','https://ja.wikipedia.org/wiki/陸奥総社宮','Wikipedia',true,now()),
('chitose-jinja','千歳神社','ちとせじんじゃ','shrine','千歳神社','北海道','千歳市','北海道千歳市真町1番地',42.818175,141.642089,1803,null,null,'千歳の総鎮守。弁財天堂を起源とする旧郷社。','https://ja.wikipedia.org/wiki/千歳神社','Wikipedia',true,now()),
('hokumon-jinja','北門神社','ほくもんじんじゃ','shrine','北門神社','北海道','稚内市','北海道稚内市中央1丁目1番21号',45.420000,141.671306,1785,null,null,'日本最北の地・稚内の総鎮守。旧称「宗谷大神宮」。','https://ja.wikipedia.org/wiki/北門神社','Wikipedia',true,now()),
('soma-ota-jinja','相馬太田神社','そうまおおたじんじゃ','shrine','相馬太田神社','福島県','南相馬市','福島県南相馬市原町区中太田字舘ノ内143',37.610972,140.967528,1321,null,null,'相馬妙見三社の一つ。相馬野馬追の出陣社として知られる。','https://ja.wikipedia.org/wiki/相馬太田神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 3) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kamo-jinja-sendai' and d.slug in ('wakeikazuchi','kamotaketsunumi','kamotamayorihime'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mutsu-soshanomiya' and d.slug in ('shiotsuchi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chitose-jinja' and d.slug in ('toyouke','ichikishima'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hokumon-jinja' and d.slug in ('amaterasu','takemikazuchi','kotoshironushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='soma-ota-jinja' and d.slug in ('amenominakanushi'))
on conflict do nothing;

-- ===== 追加神仏 (batch 4用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('haniyamahime','埴山姫命','はにやまひめのみこと','kami','国津神','{}','記紀','土・農耕を司る土の女神。','https://ja.wikipedia.org/wiki/ハニヤスビコ・ハニヤスビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='haniyamahime' and g.slug in ('suisan_noko','kanai_anzen'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 4) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('gassan-jinja','月山神社','がっさんじんじゃ','shrine','月山神社（旧官幣大社）','山形県','東田川郡庄内町','山形県東田川郡庄内町立谷澤本澤31',38.546861,140.025778,null,null,null,'出羽三山・月山頂上に鎮座する官幣大社。東北唯一の官幣大社。','https://ja.wikipedia.org/wiki/月山神社','Wikipedia',true,now()),
('iwahashi-jinja','磐椅神社','いわはしじんじゃ','shrine','磐椅神社','福島県','耶麻郡猪苗代町','福島県耶麻郡猪苗代町西峰6199',37.571189,140.104786,250,null,'http://iwahashijinja.official.jp/','磐梯山の山岳信仰に由来する古社。会津五桜の大鹿桜で有名。','https://ja.wikipedia.org/wiki/磐椅神社','Wikipedia',true,now()),
('kudoji','久渡寺','くどじ','temple','真言宗智山派','青森県','弘前市','青森県弘前市坂本山元1',40.539720,140.429170,null,'聖観音','https://ja.wikipedia.org/wiki/久渡寺','津軽三十三観音霊場第一番札所。円山応挙筆の幽霊画で知られる。','https://ja.wikipedia.org/wiki/久渡寺','Wikipedia',true,now()),
('shiwa-inari-jinja','志和稲荷神社','しわいなりじんじゃ','shrine','志和稲荷神社','岩手県','紫波郡紫波町','岩手県紫波郡紫波町升沢字前平17-1',39.558917,141.077833,1057,null,'http://www.shiwa-oinarisan.jp','源頼義ゆかりの古社。樹齢千年超の稲荷山大杉で知られる。','https://ja.wikipedia.org/wiki/志和稲荷神社','Wikipedia',true,now()),
('tonogo-hachimangu','遠野郷八幡宮','とおのごうはちまんぐう','shrine','遠野郷八幡宮','岩手県','遠野市','岩手県遠野市松崎町白岩23-19',39.343778,141.546472,1189,null,'https://www.tono8man.com/','遠野郷総鎮守。流鏑馬と南部曲り家の風情で知られる。','https://ja.wikipedia.org/wiki/遠野郷八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 4) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='gassan-jinja' and d.slug in ('tsukuyomi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iwahashi-jinja' and d.slug in ('oyamatsumi','haniyamahime'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kudoji' and d.slug in ('sho_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shiwa-inari-jinja' and d.slug in ('ukanomitama'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='shiwa-inari-jinja' and d.slug in ('sarutahiko'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tonogo-hachimangu' and d.slug in ('hachiman','okuninushi','kotoshironushi','sukunahikona','mitoshi'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 5) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hachiman-akita-jinja','八幡秋田神社','はちまんあきたじんじゃ','shrine','八幡秋田神社','秋田県','秋田市','秋田県秋田市千秋公園1-16',39.721556,140.123250,1907,null,null,'久保田城本丸跡に鎮座。八幡神と秋田藩主佐竹氏を祀る。','https://ja.wikipedia.org/wiki/八幡秋田神社','Wikipedia',true,now()),
('somiya-jinja','總宮神社','そうみやじんじゃ','shrine','總宮神社','山形県','長井市','山形県長井市横町14-24',38.115389,140.034778,802,null,null,'坂上田村麻呂創建と伝わる長井の古社。直江兼続お手植えの大杉で知られる。','https://ja.wikipedia.org/wiki/總宮神社','Wikipedia',true,now()),
('hirosaki-tenmangu','弘前天満宮','ひろさきてんまんぐう','shrine','弘前天満宮','青森県','弘前市','青森県弘前市西茂森1丁目1-34',40.601611,140.459583,1689,null,null,'菅原道真を祀る津軽の天神様。樹齢500年超の枝垂桜で有名。','https://ja.wikipedia.org/wiki/弘前天満宮','Wikipedia',true,now()),
('retsureppu-jinja','烈々布神社','れつれっぷじんじゃ','shrine','烈々布神社','北海道','札幌市','北海道札幌市東区北42条東10丁目1番1号',43.112583,141.359194,1889,null,'http://www.hokkaidojinjacho.jp/data/01/01050.html','北海道で最多の御祭神を祀るとされる東区の総鎮守。','https://ja.wikipedia.org/wiki/烈々布神社','Wikipedia',true,now()),
('miyoshi-jinja-sapporo','三吉神社','みよしじんじゃ','shrine','三吉神社（札幌市）','北海道','札幌市','北海道札幌市中央区南1条西8丁目17番地',43.058444,141.345167,1878,null,'https://miyoshi-sapporo.or.jp/','秋田・太平山三吉神社の分霊を祀る札幌中心部の社。「さんきちさん」。','https://ja.wikipedia.org/wiki/三吉神社_(札幌市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 5) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hachiman-akita-jinja' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='somiya-jinja' and d.slug in ('yamato_takeru'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hirosaki-tenmangu' and d.slug in ('michizane'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='retsureppu-jinja' and d.slug in ('amaterasu','susanoo','michizane'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='miyoshi-jinja-sapporo' and d.slug in ('okuninushi','sukunahikona'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='miyoshi-jinja-sapporo' and d.slug in ('michizane'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 6) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('entsuin-matsushima','円通院','えんつういん','temple','臨済宗妙心寺派','宮城県','宮城郡松島町','宮城県宮城郡松島町松島字町内67',38.371100,141.059700,1647,'聖観音','https://www.entuuin.or.jp/','瑞巌寺の塔頭。伊達光宗の霊廟「三慧殿」と苔庭・バラ園で知られる。','https://ja.wikipedia.org/wiki/円通院_(宮城県松島町)','Wikipedia',true,now()),
('kuronuma-jinja-fukushima','黒沼神社','くろぬまじんじゃ','shrine','黒沼神社','福島県','福島市','福島県福島市松川町金沢字宮ノ前45',37.670278,140.481056,null,null,'http://www.kuronumajinja.com','延喜式内社の論社。金沢の羽山ごもり(重要無形民俗文化財)で知られる。','https://ja.wikipedia.org/wiki/黒沼神社','Wikipedia',true,now()),
('enichiji-bandai','慧日寺','えにちじ','temple','真言宗豊山派','福島県','耶麻郡磐梯町','福島県耶麻郡磐梯町大字磐梯字本寺上4950',37.567417,139.986861,807,'薬師如来','http://www.town.bandai.fukushima.jp/site/enichiji/','徳一が開いた会津仏教の中心。国史跡「慧日寺跡」で金堂を復元。','https://ja.wikipedia.org/wiki/恵日寺_(福島県磐梯町)','Wikipedia',true,now()),
('hoyoji-aizu','法用寺','ほうようじ','temple','天台宗','福島県','大沼郡会津美里町','福島県大沼郡会津美里町雀林字三番山下3554',37.486614,139.814033,720,'十一面観音','https://ja.wikipedia.org/wiki/法用寺','会津の古刹。会津三十三観音第二十九番。三重塔と虎の尾桜で知られる。','https://ja.wikipedia.org/wiki/法用寺','Wikipedia',true,now()),
('shingu-kumano-jinja','新宮熊野神社','しんぐうくまのじんじゃ','shrine','新宮熊野神社','福島県','喜多方市','福島県喜多方市慶徳町新宮字熊野2258',37.619306,139.830139,1055,null,null,'国重文の拝殿「長床」で名高い熊野三山の分社。大イチョウも有名。','https://ja.wikipedia.org/wiki/新宮熊野神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 6) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='entsuin-matsushima' and d.slug in ('sho_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kuronuma-jinja-fukushima' and d.slug in ('yamato_takeru'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='enichiji-bandai' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hoyoji-aizu' and d.slug in ('juichimen_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shingu-kumano-jinja' and d.slug in ('susanoo','hayatama','izanami'))
on conflict do nothing;

-- ===== 追加神仏 (batch 7用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('minamoto_yoshimitsu','源義光','みなもとのよしみつ','kami','御霊','{新羅三郎}','史実','清和源氏の武将。新羅明神で元服し「新羅三郎」と称した武神。','https://ja.wikipedia.org/wiki/源義光','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='minamoto_yoshimitsu' and g.slug in ('shobu','shobai'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 7) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shioyuhiko-jinja','塩湯彦神社','しおゆひこじんじゃ','shrine','塩湯彦神社','秋田県','横手市','秋田県横手市山内大松川字御嶽山3',39.282111,140.618194,672,null,null,'御嶽山の温泉信仰に由来する延喜式内社。雪椿の北限群生地。','https://ja.wikipedia.org/wiki/塩湯彦神社','Wikipedia',true,now()),
('hokoji-nanbu','法光寺','ほうこうじ','temple','曹洞宗','青森県','三戸郡南部町','青森県三戸郡南部町大字法光寺字法光寺20',40.389750,141.324083,1250,'千手観音','https://ja.wikipedia.org/wiki/法光寺_(青森県南部町)','北条時頼が開いた南部地方の古刹。33mの承陽塔(三重塔)で知られる。','https://ja.wikipedia.org/wiki/法光寺_(青森県南部町)','Wikipedia',true,now()),
('chojasan-shinra-jinja','長者山新羅神社','ちょうじゃさんしんらじんじゃ','shrine','長者山新羅神社','青森県','八戸市','青森県八戸市長者1-6-10',40.502833,141.491028,1678,null,null,'八戸三社大祭・えんぶり・加賀美流騎馬打毬で知られる八戸藩の祈願社。','https://ja.wikipedia.org/wiki/長者山新羅神社','Wikipedia',true,now()),
('ogami-jinja-hachinohe','龗神社','おがみじんじゃ','shrine','法霊山龗神社','青森県','八戸市','青森県八戸市内丸2丁目1-51',40.514972,141.490389,null,null,null,'八戸最古の社で八戸三社大祭発祥の社。法霊神楽でも知られる。','https://ja.wikipedia.org/wiki/龗神社','Wikipedia',true,now()),
('churenji-yudonosan','注連寺','ちゅうれんじ','temple','真言宗智山派','山形県','鶴岡市','山形県鶴岡市大網字中台92-1',38.602611,139.887056,833,'大日如来','http://www2.plala.or.jp/sansuirijuku/index.html','湯殿山の即身仏(鉄門海上人)を安置する古刹。森敦「月山」の舞台。','https://ja.wikipedia.org/wiki/注連寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 7) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shioyuhiko-jinja' and d.slug in ('hayatama','oyamatsumi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hokoji-nanbu' and d.slug in ('senju_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chojasan-shinra-jinja' and d.slug in ('susanoo','minamoto_yoshimitsu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ogami-jinja-hachinohe' and d.slug in ('takaokami'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='churenji-yudonosan' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 8) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('onsen-jinja-iwaki','温泉神社','ゆぜんじんじゃ','shrine','温泉神社','福島県','いわき市','福島県いわき市常磐湯本町三函322',37.008194,140.845389,673,null,'http://onsen-jinja.or.jp/','いわき湯本温泉の守護神。延喜式内社で温泉・医薬の神を祀る。','https://ja.wikipedia.org/wiki/温泉神社_(いわき市)','Wikipedia',true,now()),
('kameoka-hachimangu-sendai','亀岡八幡宮','かめおかはちまんぐう','shrine','亀岡八幡宮（仙台市）','宮城県','仙台市','宮城県仙台市青葉区川内亀岡町62',38.261611,140.843111,1189,null,'https://hachimanguu.org','伊達氏が鶴岡八幡宮を勧請した古社。長い石段の参道で知られる。','https://ja.wikipedia.org/wiki/亀岡八幡宮_(仙台市)','Wikipedia',true,now()),
('atago-jinja-sendai','愛宕神社','あたごじんじゃ','shrine','愛宕神社（仙台市）','宮城県','仙台市','宮城県仙台市太白区向山4丁目17-1',38.245830,140.875611,1650,null,'https://atago.org/','伊達氏とともに移った仙台総鎮守。火伏せの神で市街を一望する高台に鎮座。','https://ja.wikipedia.org/wiki/愛宕神社_(仙台市)','Wikipedia',true,now()),
('rinnoji-sendai','輪王寺','りんのうじ','temple','曹洞宗','宮城県','仙台市','宮城県仙台市青葉区北山1丁目14-1',38.283194,140.858667,1441,'釈迦如来','https://rinno-ji.or.jp/','伊達家ゆかりの曹洞宗寺院。庭園と三重塔で知られる北山五山の一。','https://ja.wikipedia.org/wiki/輪王寺_(仙台市)','Wikipedia',true,now()),
('mutsu-kokubunniji','陸奥国分尼寺','むつこくぶんにじ','temple','曹洞宗','宮城県','仙台市','宮城県仙台市若林区白萩町33-26',38.251103,140.909522,741,'聖観音','https://ja.wikipedia.org/wiki/陸奥国分尼寺','聖武天皇の詔で建立された陸奥国分尼寺の後継。国史跡。','https://ja.wikipedia.org/wiki/陸奥国分尼寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 8) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='onsen-jinja-iwaki' and d.slug in ('okuninushi','sukunahikona'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kameoka-hachimangu-sendai' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='kameoka-hachimangu-sendai' and d.slug in ('kamotamayorihime'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='atago-jinja-sendai' and d.slug in ('kagutsuchi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='rinnoji-sendai' and d.slug in ('shaka_nyorai'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mutsu-kokubunniji' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 9) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hakodate-gokoku-jinja','函館護国神社','はこだてごこくじんじゃ','shrine','函館護国神社','北海道','函館市','北海道函館市青柳町9-23',41.759250,140.713278,1869,null,null,'箱館戦争の戦没者を祀る招魂社を起源とする護国神社。','https://ja.wikipedia.org/wiki/函館護国神社','Wikipedia',true,now()),
('ryugu-jinja-otaru','龍宮神社','りゅうぐうじんじゃ','shrine','龍宮神社（小樽市）','北海道','小樽市','北海道小樽市稲穂3丁目22番11号',43.200556,140.992139,1876,null,'http://dragonjinja.ec-net.jp/','榎本武揚が創建した小樽の社。海の神・綿津見三神を祀る。','https://ja.wikipedia.org/wiki/龍宮神社_(小樽市)','Wikipedia',true,now()),
('suitengu-otaru','水天宮','すいてんぐう','shrine','水天宮（小樽市）','北海道','小樽市','北海道小樽市相生町3-1',43.192780,141.004170,1859,null,null,'小樽港を見下ろす桜の名所。安産・水の神を祀る。','https://ja.wikipedia.org/wiki/水天宮_(小樽市)','Wikipedia',true,now()),
('sapporo-gokoku-jinja','札幌護国神社','さっぽろごこくじんじゃ','shrine','札幌護国神社','北海道','札幌市','北海道札幌市中央区南15条西5丁目1番地',43.040694,141.352917,1879,null,'http://s-gokoku-jinja.sakura.ne.jp/','屯田兵の戦没者を祀って創建。多賀殿を併せ持つ護国神社。','https://ja.wikipedia.org/wiki/札幌護国神社','Wikipedia',true,now()),
('teine-jinja','手稲神社','ていねじんじゃ','shrine','手稲神社','北海道','札幌市','北海道札幌市手稲区手稲本町2条3丁目4番28号',43.118667,141.240694,1899,null,null,'手稲・西区一帯の総鎮守。手稲山頂に奥宮を持つ。','https://ja.wikipedia.org/wiki/手稲神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 9) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ryugu-jinja-otaru' and d.slug in ('watatsumi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='suitengu-otaru' and d.slug in ('mizuhanome','ukemochi','izanagi','izanami'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sapporo-gokoku-jinja' and d.slug in ('izanagi','izanami'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='teine-jinja' and d.slug in ('okuninushi','sukunahikona','amaterasu'))
on conflict do nothing;

-- ===== 追加神仏 (batch 10用) =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenokaguyama','天香山命','あめのかぐやまのみこと','kami','天津神','{高倉下}','記紀','越後開拓の祖神。彌彦神社の祭神で殖産・漁業の神。','https://ja.wikipedia.org/wiki/天香山命','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenokaguyama' and g.slug in ('suisan_noko','shobai','kaiun'))
on conflict do nothing;

-- ===== ③ 社寺 (batch 10) =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hie-jinja-yamadera','日枝神社','ひえじんじゃ','shrine','日枝神社（山形市山寺）','山形県','山形市','山形県山形市山寺4449-4',38.312361,140.436889,860,null,'https://hie348.wixsite.com/yamaderahiejinja/','山寺立石寺の鎮守として円仁が日吉大社を勧請した社。','https://ja.wikipedia.org/wiki/日枝神社_(山形市)','Wikipedia',true,now()),
('ohirumemuchi-jinja','大日霊貴神社','おおひるめむちじんじゃ','shrine','大日霊貴神社（大日堂）','秋田県','鹿角市','秋田県鹿角市八幡平字堂の上16',40.144333,140.805806,718,null,null,'国重要無形民俗・ユネスコ無形文化遺産「大日堂舞楽」で知られる古社。','https://ja.wikipedia.org/wiki/大日霊貴神社','Wikipedia',true,now()),
('iyahiko-jinja-sapporo','伊夜日子神社','いやひこじんじゃ','shrine','伊夜日子神社（札幌）','北海道','札幌市','北海道札幌市中央区中島公園1番8号',43.041750,141.355639,1912,null,'https://iyahiko.or.jp/','新潟・弥彦神社の分霊を祀る中島公園内の社。学問の神も合祀。','https://ja.wikipedia.org/wiki/伊夜日子神社','Wikipedia',true,now()),
('soma-jinja-sapporo','相馬神社','そうまじんじゃ','shrine','相馬神社（札幌市）','北海道','札幌市','北海道札幌市豊平区平岸2条18丁目1番1号',43.020444,141.364778,1871,null,'https://hokkaidojinjacho.jp/相馬神社/','水沢からの開拓者が創建した平岸の社。樹齢300年超の栗の神木で知られる。','https://ja.wikipedia.org/wiki/相馬神社_(札幌市)','Wikipedia',true,now()),
('nakajima-jinja-muroran','中嶋神社','なかじまじんじゃ','shrine','中嶋神社（室蘭市）','北海道','室蘭市','北海道室蘭市宮の森町1丁目1-64',42.355000,141.021670,1890,null,null,'室蘭・中島地区の鎮守。屯田兵入植に由来する社。','https://ja.wikipedia.org/wiki/中嶋神社_(室蘭市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け (batch 10) =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hie-jinja-yamadera' and d.slug in ('oyamakui'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ohirumemuchi-jinja' and d.slug in ('amaterasu'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iyahiko-jinja-sapporo' and d.slug in ('amenokaguyama'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='iyahiko-jinja-sapporo' and d.slug in ('michizane'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='soma-jinja-sapporo' and d.slug in ('amenominakanushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nakajima-jinja-muroran' and d.slug in ('amaterasu','okuninushi','kotoshironushi'))
on conflict do nothing;
