-- 中部地方 社寺データ拡張 chubu-4
-- 対象県: 新潟,富山,石川,福井,山梨,長野,岐阜,静岡,愛知
-- 出典: ja.wikipedia.org の infobox 十進座標で裏取り。_have_chubu.txt と重複なし。

-- ============================================================
-- バッチ1 (愛知)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('aizen_myoo','愛染明王','あいぜんみょうおう','buddha','明王','{}','仏教','愛欲を悟りに転じる明王。縁結び・恋愛・染色業の守護。','https://ja.wikipedia.org/wiki/愛染明王','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='aizen_myoo' and g.slug in ('enmusubi','renai','shobai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shiroyama-hachimangu','城山八幡宮','しろやまはちまんぐう','shrine','八幡宮','愛知県','名古屋市','愛知県名古屋市千種区城山町2-88',35.16750,136.95972,1548,null,'http://www.shiroyama.or.jp/','末森城跡に鎮座。連理木で知られる縁結びの社、恋の三社めぐりの一社。','https://ja.wikipedia.org/wiki/城山八幡宮','Wikipedia',true,now()),
('togan-ji','桃巌寺','とうがんじ','temple','曹洞宗','愛知県','名古屋市','愛知県名古屋市千種区四谷通2-16',35.161250,136.964625,1532,'聖観世音菩薩','http://www.toganji.com/','織田信秀の菩提を弔う禅寺。名古屋大仏で知られる。','https://ja.wikipedia.org/wiki/桃巌寺','Wikipedia',true,now()),
('shokai-ji-inazawa','性海寺','しょうかいじ','temple','真言宗智山派','愛知県','稲沢市','愛知県稲沢市大塚南1-33',35.240028,136.793528,810,'愛染明王','https://www.inazawa-kankou.jp/','弘法大師開創と伝わる古刹。本堂・多宝塔が重要文化財。あじさい寺として有名。','https://ja.wikipedia.org/wiki/性海寺_(稲沢市)','Wikipedia',true,now()),
('yaotomi-jinja','八百富神社','やおとみじんじゃ','shrine','八百富神社','愛知県','蒲郡市','愛知県蒲郡市竹島町3-15',34.810528,137.231639,1181,null,'http://www.yaotomi.net/','三河湾の竹島全島を境内とする社。日本七弁天の一つ。','https://ja.wikipedia.org/wiki/八百富神社','Wikipedia',true,now()),
('sakura-tenjinsha','桜天神社','さくらてんじんしゃ','shrine','天神社','愛知県','名古屋市','愛知県名古屋市中区錦2-4-6',35.172750,136.901250,1537,null,null,'織田信秀が北野天満宮から菅原道真像を勧請した社。名古屋三天神の一つ。','https://ja.wikipedia.org/wiki/桜天神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shiroyama-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
   or (t.slug='togan-ji' and d.slug in ('sho_kannon'))
   or (t.slug='shokai-ji-inazawa' and d.slug in ('aizen_myoo'))
   or (t.slug='yaotomi-jinja' and d.slug in ('ichikishima'))
   or (t.slug='sakura-tenjinsha' and d.slug in ('michizane'))
on conflict do nothing;

-- ============================================================
-- バッチ2 (静岡・山梨)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('otoshimioya','大歳御祖命','おおとしみおやのみこと','kami','国津神','{}','記紀','穀物・農耕の祖神。商売繁盛・五穀豊穣の神。','https://ja.wikipedia.org/wiki/静岡浅間神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='otoshimioya' and g.slug in ('shobai','suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shimomiya-omuro-sengen-jinja','冨士山下宮小室浅間神社','ふじさんしたみやおむろせんげんじんじゃ','shrine','浅間神社','山梨県','富士吉田市','山梨県富士吉田市下吉田3-32-18',35.4948222,138.8031667,807,null,'http://www.fgo.jp/~yabusame/','富士吉田の産土神。流鏑馬による占い神事で知られる。','https://ja.wikipedia.org/wiki/冨士山下宮小室浅間神社','Wikipedia',true,now()),
('kiyomizu-dera-shizuoka','清水寺','きよみずでら','temple','高野山真言宗','静岡県','静岡市','静岡県静岡市葵区音羽町27-8',34.973889,138.392222,1559,'千手観音','https://www.kiyomizudera-shizuoka.com/','今川義元が京の清水寺に擬して創建。徳川家康が崇敬し葵紋を許された。','https://ja.wikipedia.org/wiki/清水寺_(静岡市)','Wikipedia',true,now()),
('shizuoka-sengen-jinja','静岡浅間神社','しずおかせんげんじんじゃ','shrine','浅間神社','静岡県','静岡市','静岡県静岡市葵区宮ケ崎町102-1',34.983639,138.375333,901,null,'http://www.shizuokasengen.net/','神部・浅間・大歳御祖の三社の総称。漆塗極彩色の社殿26棟が重要文化財。','https://ja.wikipedia.org/wiki/静岡浅間神社','Wikipedia',true,now()),
('fuchi-rokusho-sengen-jinja','富知六所浅間神社','ふじろくしょせんげんじんじゃ','shrine','浅間神社','静岡県','富士市','静岡県富士市浅間本町5-1',35.167128,138.675814,785,null,null,'富士下方五社の筆頭社。三日市浅間とも呼ばれる。樹齢約1200年の大楠で知られる。','https://ja.wikipedia.org/wiki/富知六所浅間神社','Wikipedia',true,now()),
('yamanaka-suwa-jinja','山中諏訪神社','やまなかすわじんじゃ','shrine','諏訪神社','山梨県','南都留郡山中湖村','山梨県南都留郡山中湖村山中御所13',35.427861,138.848694,966,null,null,'安産・子授けの神事で全国に知られる。武田信玄も社殿を寄進した。','https://ja.wikipedia.org/wiki/山中諏訪神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shimomiya-omuro-sengen-jinja' and d.slug in ('konohanasakuya'))
   or (t.slug='kiyomizu-dera-shizuoka' and d.slug in ('senju_kannon'))
   or (t.slug='shizuoka-sengen-jinja' and d.slug in ('okuninushi','konohanasakuya','otoshimioya'))
   or (t.slug='fuchi-rokusho-sengen-jinja' and d.slug in ('oyamazumi'))
   or (t.slug='yamanaka-suwa-jinja' and d.slug in ('takeminakata','toyotama'))
on conflict do nothing;

-- ============================================================
-- バッチ3 (長野)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yasakatome','八坂刀売神','やさかとめのかみ','kami','国津神','{}','記紀','建御名方神の妃神。諏訪大社下社の主祭神。','https://ja.wikipedia.org/wiki/八坂刀売神','Wikipedia',true,now()),
('nyoirin_kannon','如意輪観音','にょいりんかんのん','buddha','菩薩','{}','仏教','如意宝珠と法輪で衆生を救う観音。福徳・安産の信仰を集める。','https://ja.wikipedia.org/wiki/如意輪観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yasakatome' and g.slug in ('enmusubi','anzan','kanai_anzen'))
   or (d.slug='nyoirin_kannon' and g.slug in ('anzan','kaiun','byoki_heyu'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('suwa-taisha-shimosha-akimiya','諏訪大社下社秋宮','すわたいしゃしもしゃあきみや','shrine','諏訪大社（旧官幣大社・信濃国一宮）','長野県','諏訪郡下諏訪町','長野県諏訪郡下諏訪町5828',36.0754028,138.0913000,null,null,'https://suwataisha.or.jp/','諏訪大社四宮の一つ。八月から一月に神霊を祀る下社。御柱・幣拝殿で知られる。','https://ja.wikipedia.org/wiki/諏訪大社','Wikipedia',true,now()),
('gofukuji','牛伏寺','ごふくじ','temple','真言宗智山派','長野県','松本市','長野県松本市内田2573',36.1654528,138.0184972,756,'十一面観音','https://gofukuji.or.jp/','鉢伏山西麓の修験の山寺。平安後期の仏像四件が重要文化財。厄除けで知られる。','https://ja.wikipedia.org/wiki/牛伏寺','Wikipedia',true,now()),
('hase-dera-nagano','長谷寺','はせでら','temple','真言宗智山派','長野県','長野市','長野県長野市篠ノ井塩田878',36.548639,138.099361,637,'十一面観音','https://kitamuki-kannon.com/','日本三所長谷寺の一つ。人肌観音と称される十一面観音を本尊とする。','https://ja.wikipedia.org/wiki/長谷寺_(長野市)','Wikipedia',true,now()),
('shinano-kokubunji','信濃国分寺','しなのこくぶんじ','temple','天台宗','長野県','上田市','長野県上田市国分1049',36.3830361,138.2710833,741,'薬師如来','https://shinanokokubunji.net/','聖武天皇の詔による信濃国分寺の後継。室町期の三重塔が重要文化財。','https://ja.wikipedia.org/wiki/信濃国分寺','Wikipedia',true,now()),
('shoren-ji-omachi','盛蓮寺','しょうれんじ','temple','真言宗智山派','長野県','大町市','長野県大町市社2937',36.458889,137.871944,null,'如意輪観音','https://www.kanko-omachi.gr.jp/','仁科氏ゆかりの古刹。文明2年建立の観音堂は松本平最古の寺院建築で重要文化財。','https://ja.wikipedia.org/wiki/盛蓮寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='suwa-taisha-shimosha-akimiya' and d.slug in ('takeminakata','yasakatome'))
   or (t.slug='gofukuji' and d.slug in ('juichimen_kannon'))
   or (t.slug='hase-dera-nagano' and d.slug in ('juichimen_kannon'))
   or (t.slug='shinano-kokubunji' and d.slug in ('yakushi_nyorai'))
   or (t.slug='shoren-ji-omachi' and d.slug in ('nyoirin_kannon'))
on conflict do nothing;

-- ============================================================
-- バッチ4 (新潟・富山・石川)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kushinadahime','櫛名田比売','くしなだひめ','kami','国津神','{}','記紀','素戔嗚尊の妃神。八岐大蛇から救われた稲田の女神。縁結び・夫婦和合の神。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('futagami_okami','二上大神','ふたがみのおおかみ','kami','国津神','{}','社伝','越中二上山に鎮まる神。越中国一宮射水神社の祭神。','https://ja.wikipedia.org/wiki/二上射水神社','Wikipedia',true,now()),
('tateyama_gongen','立山権現','たてやまごんげん','kami','御霊','{}','社伝','立山を神格化した権現。伊弉那岐大神・天手力雄神を本地とする立山信仰の神。','https://ja.wikipedia.org/wiki/雄山神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kushinadahime' and g.slug in ('enmusubi','kanai_anzen','yakubarai'))
   or (d.slug='futagami_okami' and g.slug in ('kaiun','shobai','yakubarai'))
   or (d.slug='tateyama_gongen' and g.slug in ('kaiun','yakubarai','tabi_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saifuku-ji-uonuma','西福寺','さいふくじ','temple','曹洞宗','新潟県','魚沼市','新潟県魚沼市大浦174',37.193667,138.956611,1534,'阿弥陀如来','https://www.saifukuji-k.com/','石川雲蝶の彫刻で名高い禅寺。開山堂の天井彫刻は「日本のミケランジェロ」の傑作。','https://ja.wikipedia.org/wiki/西福寺_(魚沼市)','Wikipedia',true,now()),
('oyama-jinja-chugu-kiganden','雄山神社中宮祈願殿','おやまじんじゃちゅうぐうきがんでん','shrine','雄山神社（旧国幣小社・越中国一宮）','富山県','中新川郡立山町','富山県中新川郡立山町芦峅寺2',36.5831083,137.3925194,null,null,'http://www.oyamajinja.org','立山信仰の中核、芦峅寺の祈願殿。立山権現を祀る。','https://ja.wikipedia.org/wiki/雄山神社','Wikipedia',true,now()),
('kushida-jinja-imizu','櫛田神社','くしだじんじゃ','shrine','櫛田神社','富山県','射水市','富山県射水市串田6841',36.6919722,137.0450611,null,null,null,'式内社。秋祭りの火渡り神事で知られる。櫛にまつわる縁結びの社。','https://ja.wikipedia.org/wiki/櫛田神社_(射水市)','Wikipedia',true,now()),
('futagami-imizu-jinja','二上射水神社','ふたがみいみずじんじゃ','shrine','射水神社','富山県','高岡市','富山県高岡市二上1519',36.778083,137.017861,null,null,null,'射水神社の旧鎮座地。築山行事(重要無形民俗文化財)で知られる越中の古社。','https://ja.wikipedia.org/wiki/二上射水神社','Wikipedia',true,now()),
('myoryu-ji','妙立寺','みょうりゅうじ','temple','日蓮宗','石川県','金沢市','石川県金沢市野町1-2-12',36.555361,136.648972,1643,'大曼荼羅','https://www.myouryuji.or.jp/','加賀藩三代前田利常が建立。複雑な仕掛けから「忍者寺」と呼ばれる。','https://ja.wikipedia.org/wiki/妙立寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saifuku-ji-uonuma' and d.slug in ('amida_nyorai'))
   or (t.slug='oyama-jinja-chugu-kiganden' and d.slug in ('tateyama_gongen'))
   or (t.slug='kushida-jinja-imizu' and d.slug in ('susanoo','kushinadahime'))
   or (t.slug='futagami-imizu-jinja' and d.slug in ('futagami_okami'))
   or (t.slug='myoryu-ji' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ============================================================
-- バッチ5 (岐阜)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ichihayao','市隼雄命','いちはやおのみこと','kami','国津神','{}','社伝','五十瓊敷入彦命の御子神。安産・家内安全の神として岐阜橿森神社に祀られる。','https://ja.wikipedia.org/wiki/橿森神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ichihayao' and g.slug in ('anzan','kanai_anzen','kosodate'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zuiryo-ji-gifu','瑞龍寺','ずいりょうじ','temple','臨済宗妙心寺派','岐阜県','岐阜市','岐阜県岐阜市寺町19',35.419694,136.767000,1468,'薬師如来','https://www.gifu-zuiryouji.com/','土岐成頼の菩提寺として開かれた禅の専門道場。塔頭六院を擁する。','https://ja.wikipedia.org/wiki/瑞龍寺_(岐阜市)','Wikipedia',true,now()),
('gyokusho-in','玉性院','ぎょくしょういん','temple','真言宗醍醐派','岐阜県','岐阜市','岐阜県岐阜市加納天神町3-8',35.406278,136.759139,1600,'不動明王','https://www.gyokushoin.com/','加納の不動さん。節分のつり込み祭りで知られる岐阜の名物寺。','https://ja.wikipedia.org/wiki/玉性院','Wikipedia',true,now()),
('gokokushi-ji','護国之寺','ごこくしじ','temple','高野山真言宗','岐阜県','岐阜市','岐阜県岐阜市長良雄総194-1',35.446333,136.795500,746,'十一面千手観音','https://www.gokokushiji.jp/','行基開創と伝わる古刹。東大寺大仏開眼の金銅鉢が国宝。美濃七福神の一つ。','https://ja.wikipedia.org/wiki/護国之寺','Wikipedia',true,now()),
('osshin-ji','乙津寺','おっしんじ','temple','臨済宗妙心寺派','岐阜県','岐阜市','岐阜県岐阜市鏡島中1-2-25',35.415500,136.719083,738,'十一面千手観音','https://kagashimakoubou.com/','鏡島弘法。弘法大師ゆかりの日本三躰厄除大師の一つ。毎月21日が賑わう。','https://ja.wikipedia.org/wiki/乙津寺','Wikipedia',true,now()),
('kashimori-jinja','橿森神社','かしもりじんじゃ','shrine','橿森神社','岐阜県','岐阜市','岐阜県岐阜市若宮町1-8',35.419556,136.764083,null,null,null,'伊奈波神社の御子神を祀る岐阜まつりの一社。安産・家内安全で信仰される。','https://ja.wikipedia.org/wiki/橿森神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zuiryo-ji-gifu' and d.slug in ('yakushi_nyorai'))
   or (t.slug='gyokusho-in' and d.slug in ('fudo_myoo'))
   or (t.slug='gokokushi-ji' and d.slug in ('senju_kannon'))
   or (t.slug='osshin-ji' and d.slug in ('senju_kannon'))
   or (t.slug='kashimori-jinja' and d.slug in ('ichihayao'))
on conflict do nothing;

-- ============================================================
-- バッチ6 (愛知)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('bato_kannon','馬頭観音','ばとうかんのん','buddha','菩薩','{}','仏教','馬頭をいただく忿怒相の観音。家畜・旅・交通安全の守護仏。','https://ja.wikipedia.org/wiki/馬頭観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='bato_kannon' and g.slug in ('kotsu_anzen','tabi_anzen','petto'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chobo-ji','長母寺','ちょうぼじ','temple','臨済宗東福寺派','愛知県','名古屋市','愛知県名古屋市東区矢田3-13-71',35.1969833,136.9449333,1179,'阿弥陀如来',null,'尾張万歳発祥の地と伝わる古刹。無住一円ゆかりの臨済宗寺院。','https://ja.wikipedia.org/wiki/長母寺','Wikipedia',true,now()),
('yamada-tenmangu','山田天満宮','やまだてんまんぐう','shrine','天満宮','愛知県','名古屋市','愛知県名古屋市北区山田町3-25',35.19583,136.93833,1672,null,'https://www.yamatenjin.or.jp/','尾張藩二代徳川光友が大宰府から勧請。名古屋三天神の一つ。金神社の銭洗いで知られる。','https://ja.wikipedia.org/wiki/山田天満宮','Wikipedia',true,now()),
('ueno-tenmangu-nagoya','上野天満宮','うえのてんまんぐう','shrine','天満宮','愛知県','名古屋市','愛知県名古屋市千種区赤坂町4-89',35.18083,136.95694,null,null,'https://www.tenman.jp/','名古屋天神とも。学業成就で知られる名古屋三天神の一つ。撫で牛で有名。','https://ja.wikipedia.org/wiki/上野天満宮','Wikipedia',true,now()),
('seishu-ji','政秀寺','せいしゅうじ','temple','臨済宗妙心寺派','愛知県','名古屋市','愛知県名古屋市中区栄3-34-23',35.1630444,136.9049361,1553,'十一面観音',null,'織田信長が傅役平手政秀を弔うため建立。清須越で現在地に移転。','https://ja.wikipedia.org/wiki/政秀寺','Wikipedia',true,now()),
('ryusen-ji-moriyama','龍泉寺','りゅうせんじ','temple','天台宗','愛知県','名古屋市','愛知県名古屋市守山区竜泉寺1-902',35.223250,136.984528,null,'馬頭観音','https://ryusenji.org/','尾張四観音の一つ。最澄開創と伝わり、仁王門が重要文化財。','https://ja.wikipedia.org/wiki/龍泉寺_(名古屋市守山区)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chobo-ji' and d.slug in ('amida_nyorai'))
   or (t.slug='yamada-tenmangu' and d.slug in ('michizane'))
   or (t.slug='ueno-tenmangu-nagoya' and d.slug in ('michizane'))
   or (t.slug='seishu-ji' and d.slug in ('juichimen_kannon'))
   or (t.slug='ryusen-ji-moriyama' and d.slug in ('bato_kannon'))
on conflict do nothing;

-- ============================================================
-- バッチ7 (静岡・愛知)
-- ============================================================
-- 新規神仏なし

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daifuku-ji-hamamatsu','大福寺','だいふくじ','temple','高野山真言宗','静岡県','浜松市','静岡県浜松市浜名区三ヶ日町福長220-3',34.829833,137.550028,875,'薬師如来','https://daifukuji-mikkabi.com/','瑠璃山。奥山方広寺と並ぶ古刹で浜名湖畔の名園を持つ。大福寺納豆発祥。','https://ja.wikipedia.org/wiki/大福寺_(浜松市)','Wikipedia',true,now()),
('futagawa-fushimi-inari','二川伏見稲荷','ふたがわふしみいなり','shrine','稲荷神社','愛知県','豊橋市','愛知県豊橋市大岩町西郷内160',34.727694,137.444139,1910,null,'https://www.futagawafushimiinari.org/','京都伏見稲荷大社から勧請。御衣黄桜の名所として知られる東海の稲荷。','https://ja.wikipedia.org/wiki/二川伏見稲荷','Wikipedia',true,now()),
('sekigan-ji','赤岩寺','せきがんじ','temple','高野山真言宗','愛知県','豊橋市','愛知県豊橋市多米町赤岩山4',34.764889,137.445778,726,'聖観音','https://www.sekiganji.com/','三河三観音の一つ。鎌倉期の愛染明王坐像が重要文化財。','https://ja.wikipedia.org/wiki/赤岩寺','Wikipedia',true,now()),
('seiken-ji','清見寺','せいけんじ','temple','臨済宗妙心寺派','静岡県','静岡市','静岡県静岡市清水区興津清見寺町418-1',35.0476250,138.5130972,654,'釈迦如来','https://seikenji.com/','興津の名刹。徳川家康が学んだ寺で、朝鮮通信使遺跡と名勝庭園で知られる。','https://ja.wikipedia.org/wiki/清見寺','Wikipedia',true,now()),
('tesshu-ji','鉄舟寺','てっしゅうじ','temple','臨済宗妙心寺派','静岡県','静岡市','静岡県静岡市清水区村松2188',34.992667,138.483056,1570,'千手観音','https://www.tesshuuji.jp/','旧久能寺。国宝久能寺経を伝える。山岡鉄舟により再興・改称された禅寺。','https://ja.wikipedia.org/wiki/鉄舟寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daifuku-ji-hamamatsu' and d.slug in ('yakushi_nyorai'))
   or (t.slug='futagawa-fushimi-inari' and d.slug in ('ukanomitama'))
   or (t.slug='sekigan-ji' and d.slug in ('sho_kannon'))
   or (t.slug='seiken-ji' and d.slug in ('shaka_nyorai'))
   or (t.slug='tesshu-ji' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- ============================================================
-- バッチ8 (愛知・長野)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{}','仏教','六道で衆生を救う菩薩。子供・旅人の守護、延命・厄除の信仰を集める。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now()),
('nintoku_tenno','仁徳天皇','にんとくてんのう','kami','御霊','{}','記紀','第16代天皇。聖帝と仰がれ、若宮八幡社などに祀られる。','https://ja.wikipedia.org/wiki/仁徳天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='jizo_bosatsu' and g.slug in ('kosodate','yakubarai','choju'))
   or (d.slug='nintoku_tenno' and g.slug in ('kaiun','shobai','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('joko-ji-seto','定光寺','じょうこうじ','temple','臨済宗','愛知県','瀬戸市','愛知県瀬戸市定光寺町373',35.280111,137.091389,1336,'延命地蔵願王菩薩','https://www.jokoji.com/','尾張藩祖徳川義直の廟所(源敬公廟)を擁する禅刹。本堂は重要文化財。','https://ja.wikipedia.org/wiki/定光寺','Wikipedia',true,now()),
('miwa-jinja-nagoya','三輪神社','みわじんじゃ','shrine','三輪神社','愛知県','名古屋市','愛知県名古屋市中区大須3-9-32',35.160861,136.905583,1570,null,'https://www.miwajinja.com/','大須の三輪さん。三ツ鳥居と幸せのなでうさぎで知られる御朱印人気社。','https://ja.wikipedia.org/wiki/三輪神社_(名古屋市)','Wikipedia',true,now()),
('wakamiya-hachimansha-nagoya','若宮八幡社','わかみやはちまんしゃ','shrine','八幡社','愛知県','名古屋市','愛知県名古屋市中区栄3-35-30',35.163472,136.903444,null,null,'https://www.wakamiya.or.jp/','名古屋総鎮守。若宮大通の名の由来。福禄寿車を出す若宮まつりで知られる。','https://ja.wikipedia.org/wiki/若宮八幡社_(名古屋市中区)','Wikipedia',true,now()),
('fukashi-jinja','深志神社','ふかしじんじゃ','shrine','深志神社','長野県','松本市','長野県松本市深志3-7-43',36.23,137.97,1339,null,'https://fukashi-tenjin.com/','松本天神。松本城下の総鎮守で諏訪明神と菅原道真を祀る。','https://ja.wikipedia.org/wiki/深志神社','Wikipedia',true,now()),
('kumano-kotai-jinja','熊野皇大神社','くまのこうたいじんじゃ','shrine','熊野神社','長野県','北佐久郡軽井沢町','長野県北佐久郡軽井沢町峠町1',36.369,138.656,null,null,'https://kumanokoutaijinja.jp/','碓氷峠に鎮座し県境が社殿を分ける。日本三大熊野の一つ。','https://ja.wikipedia.org/wiki/熊野皇大神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='joko-ji-seto' and d.slug in ('jizo_bosatsu'))
   or (t.slug='miwa-jinja-nagoya' and d.slug in ('omononushi'))
   or (t.slug='wakamiya-hachimansha-nagoya' and d.slug in ('nintoku_tenno','hachiman'))
   or (t.slug='fukashi-jinja' and d.slug in ('takeminakata','michizane'))
   or (t.slug='kumano-kotai-jinja' and d.slug in ('izanami','yamatotakeru'))
on conflict do nothing;

-- ============================================================
-- バッチ9 (福井・新潟・石川)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('isohitatarashiko','五十日帯日子命','いかたらしひこのみこと','kami','国津神','{}','社伝','越後下田郷を開いた開拓神。治水・農耕を教えたと伝わる五十嵐神社の祭神。','https://ja.wikipedia.org/wiki/五十嵐神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='isohitatarashiko' and g.slug in ('suisan_noko','mizu_amagoi','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nakayama-dera-takahama','中山寺','なかやまでら','temple','真言宗御室派','福井県','大飯郡高浜町','福井県大飯郡高浜町中山27-2',35.496306,135.50083,736,'馬頭観音','https://www.wakasaji.org/','若狭の古刹。室町期の本堂が国宝。北陸三十三観音第一番札所。','https://ja.wikipedia.org/wiki/中山寺_(福井県高浜町)','Wikipedia',true,now()),
('haga-ji','羽賀寺','はがじ','temple','高野山真言宗','福井県','小浜市','福井県小浜市羽賀83-5',35.518806,135.76444,716,'十一面観音','https://www.wakasa-obama.jp/','行基開創と伝わる。十一面観音・千手観音など国重文を伝える若狭の名刹。','https://ja.wikipedia.org/wiki/羽賀寺','Wikipedia',true,now()),
('mantoku-ji-obama','萬徳寺','まんとくじ','temple','高野山真言宗','福井県','小浜市','福井県小浜市金屋74-23',35.468833,135.78528,1265,'阿弥陀如来','https://www.wakasa-mantokuji.com/','枯山水庭園(国名勝)と樹齢500年の楓で知られる若狭の古刹。','https://ja.wikipedia.org/wiki/萬徳寺_(小浜市)','Wikipedia',true,now()),
('ikarashi-jinja','五十嵐神社','いからしじんじゃ','shrine','五十嵐神社','新潟県','三条市','新潟県三条市飯田1',37.573889,139.049111,null,null,null,'式内社。五十嵐姓発祥の地とされ、下田郷開拓の祖神を祀る越後の古社。','https://ja.wikipedia.org/wiki/五十嵐神社','Wikipedia',true,now()),
('utasu-jinja','宇多須神社','うたすじんじゃ','shrine','宇多須神社','石川県','金沢市','石川県金沢市東山1-30-8',36.573000,136.668389,718,null,'https://utasujinja.or.jp/','金沢五社の一つ。ひがし茶屋街の鎮守で、かつて前田利家を密かに祀った社。','https://ja.wikipedia.org/wiki/宇多須神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nakayama-dera-takahama' and d.slug in ('bato_kannon'))
   or (t.slug='haga-ji' and d.slug in ('juichimen_kannon'))
   or (t.slug='mantoku-ji-obama' and d.slug in ('amida_nyorai'))
   or (t.slug='ikarashi-jinja' and d.slug in ('isohitatarashiko'))
   or (t.slug='utasu-jinja' and d.slug in ('takamimusubi'))
on conflict do nothing;

-- ============================================================
-- バッチ10 (富山・新潟・愛知)
-- ============================================================

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takeinadane','建稲種命','たけいなだねのみこと','kami','国津神','{}','社伝','日本武尊に従った尾張国造の祖。知多半島羽豆岬の羽豆神社に祀られる。','https://ja.wikipedia.org/wiki/羽豆神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takeinadane' and g.slug in ('kaijo_anzen','shobu','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hie-jinja-toyama','日枝神社','ひえじんじゃ','shrine','日枝神社','富山県','富山市','富山県富山市山王町4-12',36.686611,137.213667,null,null,'https://www.sannou-jinja.or.jp/','富山の山王さん。県内最大の祭り山王まつりで知られる富山市総鎮守。','https://ja.wikipedia.org/wiki/日枝神社_(富山市)','Wikipedia',true,now()),
('rengebu-ji','蓮華峰寺','れんげぶじ','temple','真言宗智山派','新潟県','佐渡市','新潟県佐渡市小比叡182',37.836028,138.287833,806,'観音菩薩',null,'弘法大師開創と伝わる佐渡の古刹。金堂・弘法堂・骨堂が国の重要文化財。あじさい寺。','https://ja.wikipedia.org/wiki/蓮華峰寺','Wikipedia',true,now()),
('hitsuji-jinja-nagoya','羊神社','ひつじじんじゃ','shrine','羊神社','愛知県','名古屋市','愛知県名古屋市北区辻町5-26',35.207389,136.926500,null,null,null,'式内社。羊の字を冠する珍しい社で未年に参拝者が集まる火防の神。','https://ja.wikipedia.org/wiki/羊神社_(名古屋市)','Wikipedia',true,now()),
('hazu-jinja','羽豆神社','はずじんじゃ','shrine','羽豆神社','愛知県','知多郡南知多町','愛知県知多郡南知多町師崎明神山',34.696389,136.972194,null,null,null,'知多半島先端の羽豆岬に鎮座する式内社。社叢は国の天然記念物。','https://ja.wikipedia.org/wiki/羽豆神社','Wikipedia',true,now()),
('omido-ji-nomadaibo','大御堂寺','おおみどうじ','temple','真言宗豊山派','愛知県','知多郡美浜町','愛知県知多郡美浜町野間東畠50',34.7708778,136.8529528,null,'阿弥陀如来','https://nomadaibou.jp/','野間大坊。源義朝終焉の地で、木太刀を供える義朝の墓で知られる。','https://ja.wikipedia.org/wiki/大御堂寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hie-jinja-toyama' and d.slug in ('oyamakui','okuninushi'))
   or (t.slug='rengebu-ji' and d.slug in ('sho_kannon'))
   or (t.slug='hitsuji-jinja-nagoya' and d.slug in ('hinokagutsuchi','amaterasu'))
   or (t.slug='hazu-jinja' and d.slug in ('takeinadane'))
   or (t.slug='omido-ji-nomadaibo' and d.slug in ('amida_nyorai'))
on conflict do nothing;
