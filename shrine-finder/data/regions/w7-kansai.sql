-- ============================================================
-- w7-kansai.sql  近畿地方(三重/滋賀/京都/大阪/兵庫/奈良/和歌山)
-- ja.wikipedia.org infobox の十進座標で裏取り。_have_kansai.txt と重複なし。
-- ============================================================

-- ① 新規神仏 ------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。念仏により極楽往生を導く。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖。悟りを開いた釈迦牟尼仏。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('miroku_bosatsu','弥勒菩薩','みろくぼさつ','buddha','菩薩','{}','仏教','釈迦入滅後56億7千万年後に現れる未来仏。','https://ja.wikipedia.org/wiki/弥勒菩薩','Wikipedia',true,now()),
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{}','記紀','雷と剣の武神。鹿島・春日の神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','大国主の子。託宣・海・商売の神。えびす神と習合。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','天照大神の弟。荒ぶる神にして厄除・武勇の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kakimoto_hitomaro','柿本人麻呂','かきのもとのひとまろ','kami','御霊','{}','歴史','歌聖と崇められた飛鳥時代の歌人。学問・火防・眼病の神。','https://ja.wikipedia.org/wiki/柿本人麻呂','Wikipedia',true,now()),
('amaterasu_aramitama','天照大神荒魂','あまてらすおおみかみのあらみたま','kami','天津神','{}','記紀','天照大神の荒魂。撞賢木厳之御魂天疎向津媛命。','https://ja.wikipedia.org/wiki/廣田神社','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方瑠璃光浄土の教主。病気平癒・医薬の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{}','仏教','千の手で衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('nigihayahi','饒速日命','にぎはやひのみこと','kami','天津神','{}','記紀','天磐船で河内に降臨した天津神。物部氏の祖神。','https://ja.wikipedia.org/wiki/ニギハヤヒ','Wikipedia',true,now()),
('wakahirume','稚日女尊','わかひるめのみこと','kami','天津神','{}','記紀','機織りの女神。天照大神の妹神とも。','https://ja.wikipedia.org/wiki/ワカヒルメ','Wikipedia',true,now()),
('shiozuchi','塩槌翁尊','しおづちのおじのみこと','kami','国津神','{}','記紀','潮路を司る塩の翁神。安産・海の神。','https://ja.wikipedia.org/wiki/シオツチノオジ','Wikipedia',true,now()),
('yamatohime','倭姫命','やまとひめのみこと','kami','御霊','{}','記紀','天照大神を伊勢に祀った皇女。伊勢神宮創祀の祖。','https://ja.wikipedia.org/wiki/ヤマトヒメ','Wikipedia',true,now()),
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{}','仏教','六道で衆生を救う菩薩。子供・旅人の守護。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{}','仏教','密教の本尊。宇宙の根源とされる如来。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now()),
('michiomi','道臣命','みちのおみのみこと','kami','御霊','{}','記紀','神武東征に従った大伴氏の祖。武の神。','https://ja.wikipedia.org/wiki/道臣命','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益 ------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amida_nyorai' and g.slug in ('jouju','byoki_heyu','kaiun'))
or (d.slug='shaka_nyorai' and g.slug in ('byoki_heyu','kaiun','gakumon'))
or (d.slug='miroku_bosatsu' and g.slug in ('kaiun','jouju','choju'))
or (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','shobai'))
or (d.slug='kotoshironushi' and g.slug in ('shobai','kinun','kaijo_anzen'))
or (d.slug='susanoo' and g.slug in ('yakubarai','enmusubi','shobu'))
or (d.slug='kakimoto_hitomaro' and g.slug in ('gakumon','gakugyo','byoki_heyu'))
or (d.slug='amaterasu_aramitama' and g.slug in ('yakubarai','kaiun','shobu'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','kaiun','choju'))
or (d.slug='senju_kannon' and g.slug in ('byoki_heyu','kaiun','jouju'))
or (d.slug='nigihayahi' and g.slug in ('kaiun','shobai','yakubarai'))
or (d.slug='wakahirume' and g.slug in ('shobai','kaiun','enmusubi'))
or (d.slug='shiozuchi' and g.slug in ('anzan','kaijo_anzen','suisan_noko'))
or (d.slug='yamatohime' and g.slug in ('kaiun','kanai_anzen','jouju'))
or (d.slug='jizo_bosatsu' and g.slug in ('kosodate','tabi_anzen','byoki_heyu'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='michiomi' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺 ＋ ④ 紐付け ---------------------------------------

-- [1] 西芳寺(苔寺) 京都 ----------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('saihoji-kokedera','西芳寺','さいほうじ','temple','単立(臨済宗系)','京都府','京都市','京都府京都市西京区松尾神ケ谷町56',34.991961,135.683314,731,'阿弥陀如来','https://saihoji-kokedera.com/','苔寺の名で知られる世界遺産。夢窓疎石作の苔庭。','https://ja.wikipedia.org/wiki/西芳寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='saihoji-kokedera' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [2] 高山寺 京都 --------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kozanji-kyoto','高山寺','こうざんじ','temple','単立(真言宗系)','京都府','京都市','京都府京都市右京区梅ヶ畑栂尾町8',35.060108,135.678569,774,'釈迦如来','https://kosanji.com/','明恵上人中興。鳥獣人物戯画を伝える世界遺産。','https://ja.wikipedia.org/wiki/高山寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kozanji-kyoto' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- [3] 三宝院 京都 --------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sanboin-daigo','三宝院','さんぼういん','temple','真言宗醍醐派','京都府','京都市','京都府京都市伏見区醍醐東大路町22',34.952278,135.819440,1115,'弥勒菩薩','https://www.daigoji.or.jp/','醍醐寺の本坊。豊臣秀吉設計の庭園と国宝唐門。','https://ja.wikipedia.org/wiki/三宝院','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sanboin-daigo' and d.slug in ('miroku_bosatsu'))
on conflict do nothing;

-- [4] 立木神社 滋賀 ------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tachiki-jinja','立木神社','たちきじんじゃ','shrine','立木神社','滋賀県','草津市','滋賀県草津市草津4丁目1-3',35.013278,135.956139,767,null,'https://www.tatikijinja.net','東海道草津宿の鎮守。武甕槌命を祀り旅の安全で信仰。','https://ja.wikipedia.org/wiki/立木神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tachiki-jinja' and d.slug in ('takemikazuchi'))
on conflict do nothing;

-- [5] 柿本神社(明石) 兵庫 ------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kakimoto-jinja-akashi','柿本神社','かきもとじんじゃ','shrine','柿本神社','兵庫県','明石市','兵庫県明石市人丸町1-26',34.650208,135.001611,887,null,'http://www.kakinomoto-jinja.or.jp/','歌聖・柿本人麻呂を祀る人丸山の社。学問・眼病で信仰。','https://ja.wikipedia.org/wiki/柿本神社_(明石市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kakimoto-jinja-akashi' and d.slug in ('kakimoto_hitomaro'))
on conflict do nothing;

-- [6] 西本願寺 京都 ------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nishi-honganji','西本願寺','にしほんがんじ','temple','浄土真宗本願寺派','京都府','京都市','京都府京都市下京区本願寺門前町60',34.992047,135.751611,1591,'阿弥陀如来','https://hongwanji.kyoto/','浄土真宗本願寺派本山。桃山文化の世界遺産。','https://ja.wikipedia.org/wiki/西本願寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nishi-honganji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [7] 東本願寺 京都 ------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('higashi-honganji','東本願寺','ひがしほんがんじ','temple','真宗大谷派','京都府','京都市','京都府京都市下京区烏丸通七条上る常葉町754',34.991017,135.758456,1602,'阿弥陀如来','https://www.higashihonganji.or.jp/','真宗大谷派本山(真宗本廟)。御影堂は世界最大級の木造建築。','https://ja.wikipedia.org/wiki/東本願寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='higashi-honganji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [8] 法然院 京都 --------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('honen-in','法然院','ほうねんいん','temple','単立(浄土宗系)','京都府','京都市','京都府京都市左京区鹿ケ谷御所ノ段町30',35.023972,135.797417,1680,'阿弥陀如来','http://www.honen-in.jp/','哲学の道沿いの草庵。白砂壇と苔の参道で名高い。','https://ja.wikipedia.org/wiki/法然院','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='honen-in' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [9] 詩仙堂 京都 --------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shisendo','詩仙堂','しせんどう','temple','曹洞宗','京都府','京都市','京都府京都市左京区一乗寺門口町27',35.043719,135.796128,1641,'馬郎婦観音','http://www.kyoto-shisendo.net/','石川丈山の山荘。三十六詩仙の間とししおどしの庭。','https://ja.wikipedia.org/wiki/詩仙堂','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shisendo' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- [10] 曼殊院 京都 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('manshuin','曼殊院','まんしゅいん','temple','天台宗','京都府','京都市','京都府京都市左京区一乗寺竹ノ内町42',35.048806,135.803056,950,'阿弥陀如来','https://www.manshuinmonzeki.jp/','天台五箇室門跡の一つ。小さな桂離宮と称される枯山水。','https://ja.wikipedia.org/wiki/曼殊院','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='manshuin' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [11] 伊射波神社 三重 ---------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('izawa-jinja-toba','伊射波神社','いざわじんじゃ','shrine','伊射波神社','三重県','鳥羽市','三重県鳥羽市安楽島町字加布良古1210',34.472889,136.874333,null,null,null,'志摩国一宮の一つ。加布良古さんと親しまれる海辺の古社。','https://ja.wikipedia.org/wiki/伊射波神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='izawa-jinja-toba' and d.slug in ('wakahirume'))
on conflict do nothing;

-- [12] 慈眼院 大阪 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jigenin-izumisano','慈眼院','じげんいん','temple','真言宗御室派','大阪府','泉佐野市','大阪府泉佐野市日根野626',34.374250,135.343330,673,'薬師如来','https://ja.wikipedia.org/wiki/慈眼院','日本三名塔の一つ国宝多宝塔を持つ古刹。','https://ja.wikipedia.org/wiki/慈眼院','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jigenin-izumisano' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- [13] 孝恩寺 大阪 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('koonji-kaizuka','孝恩寺','こうおんじ','temple','浄土宗','大阪府','貝塚市','大阪府貝塚市木積798',34.418000,135.398000,726,'阿弥陀如来','https://ja.wikipedia.org/wiki/孝恩寺','釘無堂(国宝観音堂)で知られる大阪府最古の木造建築。','https://ja.wikipedia.org/wiki/孝恩寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='koonji-kaizuka' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [14] 久安寺 大阪 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kyuanji-ikeda','久安寺','きゅうあんじ','temple','高野山真言宗','大阪府','池田市','大阪府池田市伏尾町697',34.860083,135.444889,725,'千手観音','https://kyuanji.jp/','行基開創と伝わる花の寺。あじさいと紅葉の名所。','https://ja.wikipedia.org/wiki/久安寺_(池田市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kyuanji-ikeda' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- [15] 磐船神社 大阪 -----------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('iwafune-jinja-katano','磐船神社','いわふねじんじゃ','shrine','磐船神社','大阪府','交野市','大阪府交野市私市9丁目19-1',34.747780,135.693167,null,null,null,'天の磐船と呼ぶ巨岩を御神体とし岩窟めぐりで知られる。','https://ja.wikipedia.org/wiki/磐船神社_(交野市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='iwafune-jinja-katano' and d.slug in ('nigihayahi'))
on conflict do nothing;

-- [16] 大野寺 奈良 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('onoji-uda','大野寺','おおのでら','temple','真言宗室生寺派','奈良県','宇陀市','奈良県宇陀市室生大野1680',34.562583,136.015639,681,'弥勒菩薩','https://ja.wikipedia.org/wiki/大野寺','宇陀川対岸の弥勒磨崖仏と小糸枝垂桜で名高い古刹。','https://ja.wikipedia.org/wiki/大野寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='onoji-uda' and d.slug in ('miroku_bosatsu'))
on conflict do nothing;

-- [17] 常楽寺 滋賀(湖南三山) ----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jorakuji-konan','常楽寺','じょうらくじ','temple','天台宗系単立','滋賀県','湖南市','滋賀県湖南市西寺6丁目5-1',34.990125,136.048567,708,'千手観音','https://ja.wikipedia.org/wiki/常楽寺_(湖南市)','湖南三山の西寺。国宝本堂と三重塔を誇る古刹。','https://ja.wikipedia.org/wiki/常楽寺_(湖南市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jorakuji-konan' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- [18] 善水寺 滋賀(湖南三山) ----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zensuiji-konan','善水寺','ぜんすいじ','temple','天台宗','滋賀県','湖南市','滋賀県湖南市岩根3518',35.006444,136.112556,712,'薬師如来','https://ja.wikipedia.org/wiki/善水寺','湖南三山の一。国宝本堂を持ち最澄ゆかりの古刹。','https://ja.wikipedia.org/wiki/善水寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zensuiji-konan' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- [19] 塩竈神社 和歌山 ---------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shiogama-jinja-wakayama','塩竈神社','しおがまじんじゃ','shrine','塩竈神社','和歌山県','和歌山市','和歌山県和歌山市和歌浦中3丁目4-25',34.187083,135.172833,1917,null,null,'和歌浦の輿の窟に鎮座。安産と潮の神として信仰。','https://ja.wikipedia.org/wiki/塩竈神社_(和歌山市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shiogama-jinja-wakayama' and d.slug in ('shiozuchi'))
on conflict do nothing;

-- [20] 須佐神社(有田) 和歌山 ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('susa-jinja-arida','須佐神社','すさじんじゃ','shrine','須佐神社','和歌山県','有田市','和歌山県有田市千田1641',34.064875,135.141478,713,null,null,'式内名神大社。スサノオを祀り千田祭の鯖投げで知られる。','https://ja.wikipedia.org/wiki/須佐神社_(有田市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='susa-jinja-arida' and d.slug in ('susanoo'))
on conflict do nothing;

-- [21] 浄土寺 兵庫(国宝浄土堂) -------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jodoji-ono','浄土寺','じょうどじ','temple','高野山真言宗','兵庫県','小野市','兵庫県小野市浄谷町2094',34.864158,134.961097,1194,'阿弥陀如来','https://ja.wikipedia.org/wiki/浄土寺_(小野市)','国宝浄土堂と快慶作阿弥陀三尊像。重源開基の名刹。','https://ja.wikipedia.org/wiki/浄土寺_(小野市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jodoji-ono' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [22] 倭姫宮 三重 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yamatohime-no-miya','倭姫宮','やまとひめのみや','shrine','神宮(皇大神宮別宮)','三重県','伊勢市','三重県伊勢市楠部町',34.485889,136.722833,1923,null,'https://www.isejingu.or.jp/','伊勢神宮内宮の別宮。倭姫命を祀る最も新しい別宮。','https://ja.wikipedia.org/wiki/倭姫宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yamatohime-no-miya' and d.slug in ('yamatohime'))
on conflict do nothing;

-- [23] 地蔵院(関の地蔵) 三重 ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jizoin-seki','地蔵院','じぞういん','temple','真言宗御室派','三重県','亀山市','三重県亀山市関町新所1173',34.853028,136.389278,741,'地蔵菩薩','https://ja.wikipedia.org/wiki/地蔵院_(亀山市)','関宿の関の地蔵。日本最古とされる地蔵菩薩を祀る。','https://ja.wikipedia.org/wiki/地蔵院_(亀山市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jizoin-seki' and d.slug in ('jizo_bosatsu'))
on conflict do nothing;

-- [24] 津八幡宮 三重 -----------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tsu-hachimangu','津八幡宮','つはちまんぐう','shrine','津八幡宮','三重県','津市','三重県津市藤方2339',34.696861,136.514278,1336,null,null,'藤堂家の鎮守。津まつりの唐人踊り・八幡獅子で知られる。','https://ja.wikipedia.org/wiki/津八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tsu-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
on conflict do nothing;

-- [25] 神宮寺(丹生大師) 三重 ---------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jinguji-taki','神宮寺','じんぐうじ','temple','真言宗山階派','三重県','多気町','三重県多気郡多気町丹生3997',34.478610,136.492722,774,'弘法大師','https://ja.wikipedia.org/wiki/神宮寺_(三重県多気町)','丹生大師。女人高野と称される空海ゆかりの古刹。','https://ja.wikipedia.org/wiki/神宮寺_(三重県多気町)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jinguji-taki' and d.slug in ('kobo_daishi'))
on conflict do nothing;

-- [26] 感田神社 大阪 -----------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanda-jinja-kaizuka','感田神社','かんだじんじゃ','shrine','感田神社','大阪府','貝塚市','大阪府貝塚市中町10-1',34.447056,135.358833,1587,null,null,'貝塚寺内町の氏神。貝塚太鼓台祭の宮として知られる。','https://ja.wikipedia.org/wiki/感田神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanda-jinja-kaizuka' and d.slug in ('amaterasu','susanoo','michizane'))
on conflict do nothing;

-- [27] 不空院 奈良 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fukuin-nara','不空院','ふくういん','temple','真言律宗','奈良県','奈良市','奈良県奈良市高畑町1365',34.676528,135.846667,810,'不空羂索観音','https://ja.wikipedia.org/wiki/不空院','鑑真旧居跡と伝わる縁切り・縁結びの寺。','https://ja.wikipedia.org/wiki/不空院','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fukuin-nara' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- [28] 弘川寺 大阪 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hirokawadera','弘川寺','ひろかわでら','temple','真言宗醍醐派','大阪府','河南町','大阪府南河内郡河南町弘川43',34.474497,135.652939,665,'薬師如来','https://ja.wikipedia.org/wiki/弘川寺','西行終焉の地として名高い桜の名所。','https://ja.wikipedia.org/wiki/弘川寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hirokawadera' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- [29] 安楽寺 京都 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('anrakuji-kyoto','安楽寺','あんらくじ','temple','単立(浄土宗系)','京都府','京都市','京都府京都市左京区鹿ケ谷御所ノ段町21',35.021639,135.796528,1212,'阿弥陀如来','https://ja.wikipedia.org/wiki/安楽寺_(京都市)','哲学の道沿いの草庵。中風除けのかぼちゃ供養で知られる。','https://ja.wikipedia.org/wiki/安楽寺_(京都市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='anrakuji-kyoto' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- [30] 円光寺 京都 -------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('enkoji-kyoto','円光寺','えんこうじ','temple','臨済宗南禅寺派','京都府','京都市','京都府京都市左京区一乗寺小谷町13',35.045000,135.796940,1601,'千手観音','https://ja.wikipedia.org/wiki/円光寺_(京都市左京区)','徳川家康開基。十牛之庭の紅葉と圓光寺版木で有名。','https://ja.wikipedia.org/wiki/円光寺_(京都市左京区)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='enkoji-kyoto' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- [31] 天孫神社 滋賀 -----------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tenson-jinja-otsu','天孫神社','てんそんじんじゃ','shrine','天孫神社','滋賀県','大津市','滋賀県大津市京町3丁目3-36',35.005722,135.867111,800,null,null,'大津四宮。ユネスコ無形文化遺産・大津祭の宮として知られる。','https://ja.wikipedia.org/wiki/天孫神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tenson-jinja-otsu' and d.slug in ('okuninushi'))
on conflict do nothing;

-- [32] 刺田比古神社 和歌山 -----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sasutahiko-jinja','刺田比古神社','さすたひこじんじゃ','shrine','刺田比古神社','和歌山県','和歌山市','和歌山県和歌山市片岡町2丁目9',34.223794,135.174103,null,null,null,'岡の宮。徳川吉宗の拾い親と伝わる式内社。','https://ja.wikipedia.org/wiki/刺田比古神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sasutahiko-jinja' and d.slug in ('michiomi'))
on conflict do nothing;

-- [33] 恵運寺 和歌山 -----------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('eiunji-wakayama','恵運寺','えうんじ','temple','曹洞宗','和歌山県','和歌山市','和歌山県和歌山市吹上3丁目1-66',34.219333,135.171611,1619,'十一面観音','https://ja.wikipedia.org/wiki/恵運寺','紀州藩士山本主馬開基。猫寺として親しまれる禅寺。','https://ja.wikipedia.org/wiki/恵運寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='eiunji-wakayama' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- [34] 根来寺 和歌山(新義真言宗総本山) -----------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('negoroji','根来寺','ねごろじ','temple','新義真言宗','和歌山県','岩出市','和歌山県岩出市根来2286',34.287220,135.316670,1130,'大日如来','https://www.negoroji.org/','覚鑁開創の新義真言宗総本山。国宝大塔を誇る。','https://ja.wikipedia.org/wiki/根来寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='negoroji' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- [35] 斑鳩寺 兵庫(太子町) ----------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ikarugadera-taishi','斑鳩寺','いかるがでら','temple','天台宗','兵庫県','太子町','兵庫県揖保郡太子町鵤709',34.837058,134.575450,606,'釈迦如来','https://ja.wikipedia.org/wiki/斑鳩寺_(兵庫県太子町)','聖徳太子開基と伝わる古刹。三重塔と太子信仰の中心。','https://ja.wikipedia.org/wiki/斑鳩寺_(兵庫県太子町)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ikarugadera-taishi' and d.slug in ('shaka_nyorai'))
on conflict do nothing;
