-- w10-kanto.sql : 関東地方 著名社寺データ拡張（_have_kanto.txt 未収録）
-- 出典: ja.wikipedia.org infobox 十進座標で裏取り
-- 担当県: 茨城・栃木・群馬・埼玉・千葉・東京・神奈川
-- 仕様: AGENT_SPEC.md 厳守 / 5件ごと逐次保存

-- ===== バッチ1 (5件) 茨城・栃木 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenooshihomimi','天忍穂耳尊','あめのおしほみみのみこと','kami','天津神','{}','記紀','天照大神の子で瓊瓊杵尊の父。稲穂の神。','https://ja.wikipedia.org/wiki/アメノオシホミミ','Wikipedia',true,now()),
('iwatsutsume','磐筒女命','いわつつめのみこと','kami','天津神','{}','記紀','経津主神を生んだ刀剣の女神。','https://ja.wikipedia.org/wiki/イワツツノオ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenooshihomimi' and g.slug in ('shusse','gakugyo','kaiun'))
or (d.slug='iwatsutsume' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kiryu-tenmangu','桐生天満宮','きりゅうてんまんぐう','shrine','桐生天満宮（旧郷社）','群馬県','桐生市','群馬県桐生市天神町1-2-1',36.422139,139.346361,null,null,'http://www.kiryutenjin.jp/','桐生総鎮守で本町通り入口に鎮座。社殿は国重文。','https://ja.wikipedia.org/wiki/桐生天満宮','Wikipedia',true,now()),
('nasu-jinja','那須神社','なすじんじゃ','shrine','那須神社（旧県社）','栃木県','大田原市','栃木県大田原市南金丸1628',36.864139,140.087861,null,null,'https://nasujinja.jp/','那須与一ゆかりの那須総鎮守。金丸八幡宮とも称される。','https://ja.wikipedia.org/wiki/那須神社','Wikipedia',true,now()),
('yakuoin-sakuragawa','椎尾山薬王院','しいおさんやくおういん','temple','天台宗','茨城県','桜川市','茨城県桜川市真壁町椎尾3178',36.235639,140.076667,782,'薬師如来',null,'筑波山西麓の古刹で三重塔とスダジイ巨木林で知られる。','https://ja.wikipedia.org/wiki/薬王院_(桜川市)','Wikipedia',true,now()),
('takahashi-jinja','高椅神社','たかはしじんじゃ','shrine','高椅神社（式内社・旧県社）','栃木県','小山市','栃木県小山市高椅702',36.337611,139.892111,111,null,'https://www.facebook.com/TAKAHASHIJINJA','料理の祖神を祀る式内社。鯉を食べない風習が伝わる。','https://ja.wikipedia.org/wiki/高椅神社','Wikipedia',true,now()),
('kozuke-sojajinja','上野総社神社','こうずけそうじゃじんじゃ','shrine','総社神社（上野国総社・旧県社）','群馬県','前橋市','群馬県前橋市元総社町1-31-45',36.388000,139.0378611,null,null,'http://www.net-you.com/souja/','上野国の総社で五百余柱を合祀。総社神社本殿は県重文。','https://ja.wikipedia.org/wiki/総社神社_(前橋市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kiryu-tenmangu' and d.slug in ('amenohohi','michizane'))
or (t.slug='nasu-jinja' and d.slug in ('hachiman'))
or (t.slug='yakuoin-sakuragawa' and d.slug in ('yakushi_nyorai'))
or (t.slug='takahashi-jinja' and d.slug in ('iwakamutsukari'))
or (t.slug='kozuke-sojajinja' and d.slug in ('iwatsutsuo','iwatsutsume','ukanomitama','futsunushi','susanoo'))
on conflict do nothing;

-- ===== バッチ2 (5件) 群馬・埼玉 =====

-- ① 新規神仏（新規なし）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oosugi-jinja','大杉神社','おおすぎじんじゃ','shrine','大杉神社（旧郷社・あんばさま）','茨城県','稲敷市','茨城県稲敷市阿波958',35.9522472,140.3827222,767,null,'https://www.oosugi-jinja.or.jp/','「あんばさま」と親しまれる関東の大杉信仰の総本宮。','https://ja.wikipedia.org/wiki/大杉神社','Wikipedia',true,now()),
('izumo-iwai-jinja','出雲伊波比神社','いずもいわいじんじゃ','shrine','出雲伊波比神社（式内社・旧郷社）','埼玉県','入間郡毛呂山町','埼玉県入間郡毛呂山町岩井西5-17-1',35.942417,139.311306,null,null,null,'埼玉県内で唯一流鏑馬が毎年奉納される式内社。','https://ja.wikipedia.org/wiki/出雲伊波比神社','Wikipedia',true,now()),
('kozuke-kokubunji','上野国分寺','こうずけこくぶんじ','temple','天台宗','群馬県','高崎市','群馬県高崎市東国分町1257',36.3950861,139.0224333,741,'釈迦如来',null,'聖武天皇の詔で建立された上野国の国分寺。跡地は国史跡。','https://ja.wikipedia.org/wiki/上野国分寺','Wikipedia',true,now()),
('anrakuji-yoshimi','安楽寺','あんらくじ','temple','真言宗智山派','埼玉県','比企郡吉見町','埼玉県比企郡吉見町御所374',36.054333,139.438278,806,'聖観世音菩薩','https://yoshimikannon.jp/','坂東十一番札所「吉見観音」。三重塔と仁王門が県文化財。','https://ja.wikipedia.org/wiki/安楽寺_(吉見町)','Wikipedia',true,now()),
('takasaki-byakue-kannon','高崎白衣大観音','たかさきびゃくえだいかんのん','temple','高野山真言宗','群馬県','高崎市','群馬県高崎市石原町2710-1',36.310944,138.980528,1936,'観音菩薩','https://www.takasakikannon.or.jp/','慈眼院の本尊。高さ41.8mの観音像で高崎のシンボル。','https://ja.wikipedia.org/wiki/高崎白衣大観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oosugi-jinja' and d.slug in ('omononushi','okuninushi','sukunabikona'))
or (t.slug='izumo-iwai-jinja' and d.slug in ('okuninushi','amenohohi'))
or (t.slug='kozuke-kokubunji' and d.slug in ('shaka_nyorai'))
or (t.slug='anrakuji-yoshimi' and d.slug in ('sho_kannon'))
or (t.slug='takasaki-byakue-kannon' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- ===== バッチ3 (5件) 千葉・東京 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('konohanasakuyahime','木花咲耶姫','このはなのさくやびめ','kami','国津神','{}','記紀','瓊瓊杵尊の妃。富士山の女神で安産・火難除けの神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{}','仏教','千の手で衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('sobataka_okami','側高大神','そばたかのおおかみ','kami','国津神','{}','社伝','側高神社の祭神。神名不詳の古社の神。','https://ja.wikipedia.org/wiki/側高神社_(香取市大倉)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='konohanasakuyahime' and g.slug in ('anzan','kosodate','yakubarai'))
or (d.slug='senju_kannon' and g.slug in ('byoki_heyu','kaiun','jouju'))
or (d.slug='sobataka_okami' and g.slug in ('kaiun','yakubarai','suisan_noko'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mamasan-guhoji','真間山弘法寺','ままさんぐほうじ','temple','日蓮宗','千葉県','市川市','千葉県市川市真間4-9-1',35.739944,139.907417,737,'三宝尊','http://mamasan.or.jp/','行基開創と伝わる真間の古刹。涙石と伏姫桜で知られる。','https://ja.wikipedia.org/wiki/弘法寺_(市川市)','Wikipedia',true,now()),
('sobataka-jinja','側高神社','そばたかじんじゃ','shrine','側高神社（香取神宮第一摂社・旧郷社）','千葉県','香取市','千葉県香取市大倉1',35.8951111,140.5536361,null,null,null,'香取神宮の第一摂社。髭撫祭で知られる古社。','https://ja.wikipedia.org/wiki/側高神社_(香取市大倉)','Wikipedia',true,now()),
('inage-sengen-jinja','稲毛浅間神社','いなげせんげんじんじゃ','shrine','稲毛浅間神社（旧県社）','千葉県','千葉市','千葉県千葉市稲毛区稲毛1-15-10',35.6364972,140.0825389,808,null,'http://www.inage-sengenjinja.or.jp/','富士信仰の浅間神社で安産・子育ての信仰を集める。','https://ja.wikipedia.org/wiki/稲毛浅間神社','Wikipedia',true,now()),
('higashifushimi-inari','東伏見稲荷神社','ひがしふしみいなりじんじゃ','shrine','東伏見稲荷神社','東京都','西東京市','東京都西東京市東伏見1-5-38',35.726639,139.557361,1929,null,'http://www.higashifushimi-inari.jp/','伏見稲荷大社から勧請された関東の稲荷信仰の拠点。','https://ja.wikipedia.org/wiki/東伏見稲荷神社','Wikipedia',true,now()),
('shofukuji-higashimurayama','正福寺','しょうふくじ','temple','臨済宗建長寺派','東京都','東村山市','東京都東村山市野口町4-6-1',35.764778,139.459472,1278,'千手観音','https://shofuku-ji.org/','地蔵堂（千体地蔵堂）は東京都内唯一の国宝建造物。','https://ja.wikipedia.org/wiki/正福寺_(東村山市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mamasan-guhoji' and d.slug in ('sanbo_son'))
or (t.slug='sobataka-jinja' and d.slug in ('sobataka_okami'))
or (t.slug='inage-sengen-jinja' and d.slug in ('konohanasakuyahime','ninigi','sarutahiko'))
or (t.slug='higashifushimi-inari' and d.slug in ('ukanomitama','sarutahiko','omiyanome'))
or (t.slug='shofukuji-higashimurayama' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- ===== バッチ4 (5件) 東京・神奈川 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takaokami','高龗神','たかおかみのかみ','kami','国津神','{}','記紀','水・雨を司る龍神。祈雨・止雨の神。','https://ja.wikipedia.org/wiki/オカミ','Wikipedia',true,now()),
('guan_yu','関帝（関羽）','かんてい','buddha','天部','{"関聖帝君"}','道教・三国志','三国時代の武将関羽を神格化。商売繁盛・信義の神。','https://ja.wikipedia.org/wiki/関羽','Wikipedia',true,now()),
('amenotajikarao','天手力男神','あめのたぢからおのかみ','kami','天津神','{}','記紀','天岩戸を開いた力の神。スポーツ・必勝の神。','https://ja.wikipedia.org/wiki/アメノタヂカラオ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takaokami' and g.slug in ('mizu_amagoi','kaiun','yakubarai'))
or (d.slug='guan_yu' and g.slug in ('shobai','kinun','shobu'))
or (d.slug='amenotajikarao' and g.slug in ('shobu','shigoto','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ebara-jinja','荏原神社','えばらじんじゃ','shrine','荏原神社（旧郷社）','東京都','品川区','東京都品川区北品川2-30-28',35.61694,139.74333,709,null,'http://www.ebarajinja.org/','南品川の鎮守。海中渡御で知られる天王祭で有名。','https://ja.wikipedia.org/wiki/荏原神社','Wikipedia',true,now()),
('konno-hachimangu','金王八幡宮','こんのうはちまんぐう','shrine','金王八幡宮（旧郷社）','東京都','渋谷区','東京都渋谷区渋谷3-5-12',35.657556,139.706250,1092,null,'https://www.konno-hachimangu.jp/','渋谷の鎮守で渋谷氏ゆかりの古社。金王桜で知られる。','https://ja.wikipedia.org/wiki/金王八幡宮','Wikipedia',true,now()),
('izumo-taisha-tokyo','出雲大社東京分祠','いずもおおやしろとうきょうぶんし','shrine','出雲大社東京分祠','東京都','港区','東京都港区六本木7-18-5',35.662278,139.728833,1878,null,'http://izumotaisya-tokyobunshi.com/','出雲大社の東京分祠。縁結びの神として信仰を集める。','https://ja.wikipedia.org/wiki/出雲大社東京分祠','Wikipedia',true,now()),
('yokohama-kanteibyo','横浜関帝廟','よこはまかんていびょう','temple','道教','神奈川県','横浜市','神奈川県横浜市中区山下町140',35.442282,139.6441905,1871,'関聖帝君','http://www.yokohama-kanteibyo.com/','横浜中華街のシンボル。商売の神・関羽を祀る。','https://ja.wikipedia.org/wiki/横浜関帝廟','Wikipedia',true,now()),
('namiyoke-inari','波除稲荷神社','なみよけいなりじんじゃ','shrine','波除稲荷神社','東京都','中央区','東京都中央区築地6-20-37',35.663472,139.771611,1659,null,'http://www.namiyoke.or.jp/','築地の鎮守。波除（厄除）の信仰と獅子祭で知られる。','https://ja.wikipedia.org/wiki/波除神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ebara-jinja' and d.slug in ('takaokami','amaterasu','toyouke','susanoo','amenotajikarao'))
or (t.slug='konno-hachimangu' and d.slug in ('hachiman'))
or (t.slug='izumo-taisha-tokyo' and d.slug in ('okuninushi'))
or (t.slug='yokohama-kanteibyo' and d.slug in ('guan_yu'))
or (t.slug='namiyoke-inari' and d.slug in ('ukanomitama'))
on conflict do nothing;

-- ===== バッチ5 (5件) 神奈川（鎌倉・湘南・県央） =====

-- ① 新規神仏（新規なし）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shojokoji','清浄光寺','しょうじょうこうじ','temple','時宗','神奈川県','藤沢市','神奈川県藤沢市西富1-8-1',35.3485139,139.4886444,1325,'阿弥陀如来','http://www.jishu.or.jp/','時宗総本山「遊行寺」。一遍上人絵伝は国宝。','https://ja.wikipedia.org/wiki/清浄光寺','Wikipedia',true,now()),
('gokurakuji-kamakura','極楽寺','ごくらくじ','temple','真言律宗','神奈川県','鎌倉市','神奈川県鎌倉市極楽寺3-6-7',35.31028,139.528472,1259,'釈迦如来',null,'忍性開山の真言律宗の古刹。鎌倉二十四地蔵の札所。','https://ja.wikipedia.org/wiki/極楽寺_(鎌倉市)','Wikipedia',true,now()),
('suzuka-myojin','鈴鹿明神社','すずかみょうじんしゃ','shrine','鈴鹿明神社（旧郷社）','神奈川県','座間市','神奈川県座間市入谷西2-46-1',35.4850917,139.3944833,null,null,'http://suzuka.or.jp/','座間・入谷の総鎮守。伊勢鈴鹿から勧請と伝わる古社。','https://ja.wikipedia.org/wiki/鈴鹿明神社','Wikipedia',true,now()),
('kibune-jinja-manazuru','貴船神社','きぶねじんじゃ','shrine','貴船神社（旧村社）','神奈川県','足柄下郡真鶴町','神奈川県足柄下郡真鶴町真鶴1117',35.14972,139.14611,889,null,'https://kibunejinja.com/','日本三大船祭りの一つ貴船まつりで知られる真鶴の鎮守。','https://ja.wikipedia.org/wiki/貴船神社_(真鶴町)','Wikipedia',true,now()),
('myohonji-kamakura','妙本寺','みょうほんじ','temple','日蓮宗','神奈川県','鎌倉市','神奈川県鎌倉市大町1-15-1',35.317583,139.555806,1260,'三宝尊',null,'比企一族ゆかりの日蓮宗霊跡本山。海棠の名所。','https://ja.wikipedia.org/wiki/妙本寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shojokoji' and d.slug in ('amida_nyorai'))
or (t.slug='gokurakuji-kamakura' and d.slug in ('shaka_nyorai'))
or (t.slug='suzuka-myojin' and d.slug in ('izanagi','susanoo'))
or (t.slug='kibune-jinja-manazuru' and d.slug in ('okuninushi','kotoshironushi','sukunabikona'))
or (t.slug='myohonji-kamakura' and d.slug in ('sanbo_son'))
on conflict do nothing;

-- ===== バッチ6 (5件) 埼玉・東京・神奈川 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenohinatori','天夷鳥命','あめのひなとりのみこと','kami','天津神','{}','記紀','天穂日命の子。出雲国造の祖神とされる。','https://ja.wikipedia.org/wiki/アメノヒナトリ','Wikipedia',true,now()),
('kukurihime','菊理媛命','くくりひめのみこと','kami','国津神','{}','日本書紀','黄泉で伊弉諾・伊弉冉を仲裁した神。縁結び・和合の神。','https://ja.wikipedia.org/wiki/ククリヒメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenohinatori' and g.slug in ('kaiun','shobai','yakubarai'))
or (d.slug='kukurihime' and g.slug in ('enmusubi','kanai_anzen','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('izumoiwai-jinja','出雲祝神社','いずもいわいじんじゃ','shrine','出雲祝神社（式内社・旧村社）','埼玉県','入間市','埼玉県入間市宮寺1',35.787694,139.376389,null,null,null,'日本武尊ゆかりと伝わる入間の式内社。寄木宮とも称された。','https://ja.wikipedia.org/wiki/出雲祝神社','Wikipedia',true,now()),
('entsuji-arakawa','円通寺','えんつうじ','temple','曹洞宗','東京都','荒川区','東京都荒川区南千住1-59-11',35.734000,139.793000,791,'聖観音菩薩','https://gray-aso-2253.hacca.jp/entsuji/','坂上田村麻呂創建と伝わる。彰義隊の墓と黒門で知られる。','https://ja.wikipedia.org/wiki/円通寺_(荒川区)','Wikipedia',true,now()),
('kosokuji-kamakura','光則寺','こうそくじ','temple','日蓮宗','神奈川県','鎌倉市','神奈川県鎌倉市長谷3-9-7',35.313139,139.532194,1274,'三宝尊',null,'宿屋光則ゆかりの日蓮宗寺院。花の寺として知られる。','https://ja.wikipedia.org/wiki/光則寺','Wikipedia',true,now()),
('joryuji-fujisawa','常立寺','じょうりゅうじ','temple','日蓮宗','神奈川県','藤沢市','神奈川県藤沢市片瀬3-14-3',35.3127917,139.4883861,1532,'三宝尊',null,'元使塚で知られる片瀬の古刹。枝垂梅の名所。','https://ja.wikipedia.org/wiki/常立寺_(藤沢市)','Wikipedia',true,now()),
('hakusan-jinja-bunkyo','白山神社','はくさんじんじゃ','shrine','白山神社（旧郷社）','東京都','文京区','東京都文京区白山5-31-26',35.722083,139.750528,948,null,null,'旧東京十社の一つ。文京あじさいまつりで知られる縁結びの社。','https://ja.wikipedia.org/wiki/白山神社_(文京区)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='izumoiwai-jinja' and d.slug in ('amenohohi','amenohinatori'))
or (t.slug='entsuji-arakawa' and d.slug in ('sho_kannon'))
or (t.slug='kosokuji-kamakura' and d.slug in ('sanbo_son'))
or (t.slug='joryuji-fujisawa' and d.slug in ('sanbo_son'))
or (t.slug='hakusan-jinja-bunkyo' and d.slug in ('kukurihime','izanagi','izanami'))
on conflict do nothing;
