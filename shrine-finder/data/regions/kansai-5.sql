-- 近畿(三重・滋賀・京都・大阪・兵庫・奈良・和歌山) 追加データ kansai-5
-- AGENT_SPEC.md 準拠。座標は ja.wikipedia.org infobox の十進座標を採用。
-- _have_kansai.txt 収録済みとは重複させない。

-- ===== ① 新規神仏 =====
-- (本バッチで使用する本尊/御祭神は既存slugで充足するものが多い。新規分のみ随時追加。)
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('imaki_no_okami','今木皇大神','いまきのすめおおかみ','kami','天津神','{}','延喜式','平野神社の主祭神。源氏・平氏ら多くの氏族の祖神とされる。','https://ja.wikipedia.org/wiki/平野神社','Wikipedia',true,now()),
('kudo_no_okami','久度大神','くどのおおかみ','kami','天津神','{}','延喜式','平野神社祭神。竈(かまど)を司る神とされる。','https://ja.wikipedia.org/wiki/平野神社','Wikipedia',true,now()),
('furuaki_no_okami','古開大神','ふるあきのおおかみ','kami','天津神','{}','延喜式','平野神社祭神。','https://ja.wikipedia.org/wiki/平野神社','Wikipedia',true,now()),
('amenomihashira','天御柱命','あめのみはしらのみこと','kami','天津神','{}','延喜式','龍田大社の祭神。風を司る男神。','https://ja.wikipedia.org/wiki/龍田大社','Wikipedia',true,now()),
('kunimihashira','国御柱命','くにのみはしらのみこと','kami','国津神','{}','延喜式','龍田大社の祭神。風を司る女神。','https://ja.wikipedia.org/wiki/龍田大社','Wikipedia',true,now()),
('wakaukanome','若宇加能売命','わかうかのめのみこと','kami','天津神','{}','延喜式','廣瀬大社の主祭神。水と五穀を司る豊穣の女神。','https://ja.wikipedia.org/wiki/廣瀬大社','Wikipedia',true,now()),
('shinno','神農','しんのう','kami','天部','{神農炎帝}','中国神話','医薬と農耕を司る神農。大阪・少彦名神社で薬の神として祀られる。','https://ja.wikipedia.org/wiki/少彦名神社_(大阪市)','Wikipedia',true,now()),
('uda_tenno','宇多天皇','うだてんのう','kami','御霊','{}','史実','第59代天皇。佐々木氏の祖と縁深く沙沙貴神社に祀られる。','https://ja.wikipedia.org/wiki/宇多天皇','Wikipedia',true,now()),
('sotoorihime','衣通姫尊','そとおりひめのみこと','kami','御霊','{衣通郎姫}','記紀','和歌三神の一柱。和歌の神として玉津島神社に祀られる絶世の美姫。','https://ja.wikipedia.org/wiki/玉津島神社','Wikipedia',true,now()),
('wake_hiromushi','和気広虫','わけのひろむし','kami','御霊','{和気広虫姫,葛木戸主}','史実','和気清麻呂の姉。孤児救済に尽くし、護王神社に弟と共に祀られる。','https://ja.wikipedia.org/wiki/和気広虫','Wikipedia',true,now()),
('sarumaru_dayu','猿丸大夫','さるまるだゆう','kami','御霊','{}','伝承','三十六歌仙の一人とされる伝説的歌人。瘤取り・がん封じの神として祀られる。','https://ja.wikipedia.org/wiki/猿丸神社','Wikipedia',true,now()),
('minamoto_no_yorimasa','源頼政','みなもとのよりまさ','kami','御霊','{}','史実','平安末期の武将・歌人。安井金比羅宮に祀られる。','https://ja.wikipedia.org/wiki/源頼政','Wikipedia',true,now()),
('rushana_butsu','盧舎那仏','るしゃなぶつ','buddha','如来','{毘盧遮那仏,廬舎那仏}','華厳経','華厳経の教主。宇宙の真理を体現する仏。方広寺・東大寺大仏など。','https://ja.wikipedia.org/wiki/盧舎那仏','Wikipedia',true,now()),
('myoken_bosatsu','妙見菩薩','みょうけんぼさつ','buddha','菩薩','{北辰菩薩,尊星王}','仏教','北極星・北斗七星を神格化した菩薩。開運・厄除・眼病平癒の信仰を集める。','https://ja.wikipedia.org/wiki/妙見菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ③ 社寺（5件ごと追記） =====

-- --- batch 1: 京都の禅刹・名園寺 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ryoanji','龍安寺','りょうあんじ','temple','臨済宗妙心寺派','京都府','京都市','京都府京都市右京区龍安寺御陵下町13',35.0344944,135.7182528,1450,'釈迦如来','http://www.ryoanji.jp/','枯山水の石庭で世界的に知られる世界遺産の禅寺。','https://ja.wikipedia.org/wiki/龍安寺','Wikipedia',true,now()),
('daitokuji','大徳寺','だいとくじ','temple','臨済宗大徳寺派','京都府','京都市','京都府京都市北区紫野大徳寺町53',35.0439167,135.7460806,1315,'釈迦如来','https://daitokujidaijiin.com/','茶の湯と縁が深い臨済宗大徳寺派大本山。多数の塔頭を擁する。','https://ja.wikipedia.org/wiki/大徳寺','Wikipedia',true,now()),
('myoshinji','妙心寺','みょうしんじ','temple','臨済宗妙心寺派','京都府','京都市','京都府京都市右京区花園妙心寺町64',35.0231639,135.7201861,1342,'釈迦如来','https://www.myoshinji.or.jp/','花園法皇開基、関山慧玄開山の臨済宗妙心寺派大本山。','https://ja.wikipedia.org/wiki/妙心寺','Wikipedia',true,now()),
('shokokuji','相国寺','しょうこくじ','temple','臨済宗相国寺派','京都府','京都市','京都府京都市上京区今出川通烏丸東入相国寺門前町701',35.03306,135.7623472,1382,'釈迦如来','https://www.shokoku-ji.jp/','足利義満が建立した京都五山第二位の禅刹。','https://ja.wikipedia.org/wiki/相国寺','Wikipedia',true,now()),
('chishakuin','智積院','ちしゃくいん','temple','真言宗智山派','京都府','京都市','京都府京都市東山区東大路通七条下ル東瓦町964',34.98806,135.77639,1601,'金剛界大日如来','https://chisan.or.jp/','長谷川等伯一門の障壁画と名勝庭園で名高い真言宗智山派総本山。','https://ja.wikipedia.org/wiki/智積院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ===== ④ 御祭神/本尊の紐付け =====
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ryoanji' and d.slug in ('shaka_nyorai'))
or (t.slug='daitokuji' and d.slug in ('shaka_nyorai'))
or (t.slug='myoshinji' and d.slug in ('shaka_nyorai'))
or (t.slug='shokokuji' and d.slug in ('shaka_nyorai'))
or (t.slug='chishakuin' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- --- batch 2: 京都嵯峨・伏見/北野・奈良の古刹 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nisonin','二尊院','にそんいん','temple','天台宗','京都府','京都市','京都市右京区嵯峨二尊院門前長神町27',35.0212278,135.6678806,834,'釈迦如来・阿弥陀如来','https://nisonin.jp/','嵯峨小倉山麓、紅葉の名所として知られる天台宗の古刹。','https://ja.wikipedia.org/wiki/二尊院','Wikipedia',true,now()),
('adashino-nenbutsuji','化野念仏寺','あだしのねんぶつじ','temple','浄土宗','京都府','京都市','京都府京都市右京区嵯峨鳥居本化野町17',35.0268056,135.6645222,811,'阿弥陀如来','http://www.nenbutsuji.jp/','約八千体の石仏石塔と千灯供養で知られる嵯峨鳥居本の寺。','https://ja.wikipedia.org/wiki/化野念仏寺','Wikipedia',true,now()),
('jonangu','城南宮','じょうなんぐう','shrine','式内社・旧府社','京都府','京都市','京都府京都市伏見区中島鳥羽離宮町7',34.9511194,135.746556,null,null,'http://www.jonangu.com','方除けの大社として信仰を集め、曲水の宴と神苑の花で名高い。','https://ja.wikipedia.org/wiki/城南宮','Wikipedia',true,now()),
('hirano-jinja','平野神社','ひらのじんじゃ','shrine','名神大社・旧官幣大社','京都府','京都市','京都府京都市北区平野宮本町1',35.0326083,135.7319444,794,null,'http://www.hiranojinja.com/','桜の名所として知られる二十二社上七社の古社。','https://ja.wikipedia.org/wiki/平野神社','Wikipedia',true,now()),
('gangoji','元興寺','がんごうじ','temple','真言律宗','奈良県','奈良市','奈良県奈良市中院町11',34.6778028,135.8313556,593,'智光曼荼羅(阿弥陀如来)','https://gangoji-tera.or.jp/','南都七大寺の一。奈良町に佇む世界遺産の古寺(極楽坊)。','https://ja.wikipedia.org/wiki/元興寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nisonin' and d.slug in ('shaka_nyorai','amida_nyorai'))
or (t.slug='adashino-nenbutsuji' and d.slug in ('amida_nyorai'))
or (t.slug='jonangu' and d.slug in ('okuninushi','jingu_kogo','kunitokotachi'))
or (t.slug='hirano-jinja' and d.slug in ('imaki_no_okami','kudo_no_okami','furuaki_no_okami','himegami'))
or (t.slug='gangoji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- --- batch 3: 奈良の古社寺・八幡 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shin-yakushiji','新薬師寺','しんやくしじ','temple','華厳宗','奈良県','奈良市','奈良県奈良市高畑町1352',34.675861,135.846167,747,'薬師如来','http://www.shinyakushiji.or.jp/','国宝の本堂と十二神将像で名高い、光明皇后ゆかりの古寺。','https://ja.wikipedia.org/wiki/新薬師寺','Wikipedia',true,now()),
('asukadera','飛鳥寺','あすかでら','temple','真言宗豊山派','奈良県','高市郡明日香村','奈良県高市郡明日香村飛鳥682',34.4786500,135.8201778,596,'釈迦如来(飛鳥大仏)','https://shin-saigoku.jp/templ/templ-009/','蘇我馬子の発願による日本最古級の本格寺院。飛鳥大仏を本尊とする。','https://ja.wikipedia.org/wiki/飛鳥寺','Wikipedia',true,now()),
('tatsuta-taisha','龍田大社','たつたたいしゃ','shrine','名神大社・旧官幣大社','奈良県','生駒郡三郷町','奈良県生駒郡三郷町立野南1丁目29-1',34.593083,135.687333,null,null,'http://www.tatsutataisha.jp/','風の神を祀る古社。秋の紅葉と風鎮大祭で知られる。','https://ja.wikipedia.org/wiki/龍田大社','Wikipedia',true,now()),
('hirose-taisha','廣瀬大社','ひろせたいしゃ','shrine','名神大社・旧官幣大社','奈良県','北葛城郡河合町','奈良県北葛城郡河合町大字川合99',34.591556,135.748389,null,null,'http://www.hirosetaisya.com/','水を司る大忌神を祀る二十二社中七社の古社。砂かけ祭で有名。','https://ja.wikipedia.org/wiki/廣瀬大社','Wikipedia',true,now()),
('tamukeyama-hachimangu','手向山八幡宮','たむけやまはちまんぐう','shrine','旧県社','奈良県','奈良市','奈良県奈良市雑司町434',34.68778,135.84472,749,null,'http://tamukeyama.or.jp/','東大寺の鎮守として宇佐より勧請された八幡宮。紅葉の名所。','https://ja.wikipedia.org/wiki/手向山八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shin-yakushiji' and d.slug in ('yakushi_nyorai'))
or (t.slug='asukadera' and d.slug in ('shaka_nyorai'))
or (t.slug='tatsuta-taisha' and d.slug in ('amenomihashira','kunimihashira'))
or (t.slug='hirose-taisha' and d.slug in ('wakaukanome'))
or (t.slug='tamukeyama-hachimangu' and d.slug in ('hachiman','jingu_kogo','chuai','nintoku_tenno'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='tamukeyama-hachimangu' and d.slug in ('himegami'))
on conflict do nothing;

-- --- batch 4: 大阪の古社・湖東の名刹 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('domyoji-tenmangu','道明寺天満宮','どうみょうじてんまんぐう','shrine','旧郷社','大阪府','藤井寺市','大阪府藤井寺市道明寺1-16-40',34.569306,135.617611,null,null,'https://www.domyojitenmangu.com/','菅原道真ゆかりの天満宮。梅の名所として親しまれる。','https://ja.wikipedia.org/wiki/道明寺天満宮','Wikipedia',true,now()),
('ikutama-jinja','生國魂神社','いくくにたまじんじゃ','shrine','名神大社・旧官幣大社','大阪府','大阪市','大阪府大阪市天王寺区生玉町13-9',34.665111,135.513000,null,null,'https://www.ikutamajinja.jp/','「いくたまさん」と親しまれる大阪最古級の古社。','https://ja.wikipedia.org/wiki/生國魂神社','Wikipedia',true,now()),
('kozugu','高津宮','こうづぐう','shrine','旧府社・別表神社','大阪府','大阪市','大阪府大阪市中央区高津1丁目1-29',34.6688611,135.5138611,866,null,'https://www.kouzu.or.jp','仁徳天皇を祀る古社。上方落語ゆかりの地としても知られる。','https://ja.wikipedia.org/wiki/高津宮','Wikipedia',true,now()),
('sukunahikona-jinja','少彦名神社','すくなひこなじんじゃ','shrine','無格社','大阪府','大阪市','大阪府大阪市中央区道修町2丁目1-8',34.68861,135.505972,1780,null,'http://www.sinnosan.jp/','道修町の薬の神「神農さん」。製薬業の守護で知られる。','https://ja.wikipedia.org/wiki/少彦名神社_(大阪市)','Wikipedia',true,now()),
('kongorinji','金剛輪寺','こんごうりんじ','temple','天台宗','滋賀県','愛知郡愛荘町','滋賀県愛知郡愛荘町松尾寺874番地',35.161250,136.28306,741,'聖観音菩薩','http://kongourinji.jp/','湖東三山の一。紅葉の名所として名高い天台の古刹。','https://ja.wikipedia.org/wiki/金剛輪寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='domyoji-tenmangu' and d.slug in ('michizane'))
or (t.slug='ikutama-jinja' and d.slug in ('ikushima','tarushima'))
or (t.slug='kozugu' and d.slug in ('nintoku_tenno'))
or (t.slug='sukunahikona-jinja' and d.slug in ('sukunahikona','shinno'))
or (t.slug='kongorinji' and d.slug in ('sho_kannon'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='domyoji-tenmangu' and d.slug in ('amenohohi'))
or (t.slug='ikutama-jinja' and d.slug in ('omononushi'))
or (t.slug='kozugu' and d.slug in ('hachiman','chuai','jingu_kogo'))
on conflict do nothing;

-- --- batch 5: 湖東/近江・播磨・紀州の社寺 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('eigenji','永源寺','えいげんじ','temple','臨済宗永源寺派','滋賀県','東近江市','滋賀県東近江市永源寺高野町41',35.080583,136.319583,1361,'観世音菩薩(世継観音)','https://eigenji-t.jp/','鈴鹿山麓の紅葉の名刹。臨済宗永源寺派大本山。','https://ja.wikipedia.org/wiki/永源寺','Wikipedia',true,now()),
('aga-jinja','阿賀神社','あがじんじゃ','shrine','旧村社・別表神社','滋賀県','東近江市','滋賀県東近江市小脇町2247',35.11778,136.18167,null,null,'http://www.tarobo.sakura.ne.jp/','「太郎坊宮」の通称で知られる赤神山の磐座信仰の社。勝運の神。','https://ja.wikipedia.org/wiki/太郎坊宮','Wikipedia',true,now()),
('sasaki-jinja','沙沙貴神社','ささきじんじゃ','shrine','式内社・旧県社','滋賀県','近江八幡市','滋賀県近江八幡市安土町常楽寺1',35.136806,136.134389,null,null,'https://sasakijinja.or.jp/','佐々木源氏発祥の地。なんじゃもんじゃの花でも知られる古社。','https://ja.wikipedia.org/wiki/沙沙貴神社','Wikipedia',true,now()),
('takasago-jinja','高砂神社','たかさごじんじゃ','shrine','旧県社','兵庫県','高砂市','兵庫県高砂市高砂町東宮町190',34.743806,134.803556,null,null,'http://takasagojinja.takara-bune.net/','謡曲「高砂」相生の松で名高い縁結び・夫婦和合の社。','https://ja.wikipedia.org/wiki/高砂神社','Wikipedia',true,now()),
('tamatsushima-jinja','玉津島神社','たまつしまじんじゃ','shrine','国史見在社・旧村社','和歌山県','和歌山市','和歌山県和歌山市和歌浦中3丁目4-26',34.187944,135.171861,null,null,'http://tamatsushimajinja.jp/','和歌の神を祀る和歌浦の古社。和歌三神の一社。','https://ja.wikipedia.org/wiki/玉津島神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='eigenji' and d.slug in ('sho_kannon'))
or (t.slug='aga-jinja' and d.slug in ('amenooshihomimi'))
or (t.slug='sasaki-jinja' and d.slug in ('sukunahikona','oohiko','nintoku_tenno','uda_tenno'))
or (t.slug='takasago-jinja' and d.slug in ('susanoo','okuninushi','kushinadahime'))
or (t.slug='tamatsushima-jinja' and d.slug in ('wakahirume','jingu_kogo','sotoorihime'))
on conflict do nothing;

-- --- batch 6: 京都六角堂・湖東/播磨の札所・紀州の八幡 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('goou-jinja','護王神社','ごおうじんじゃ','shrine','旧別格官幣社・別表神社','京都府','京都市','京都府京都市上京区烏丸通下長者町下ル桜鶴円町385',35.02222,135.75861,null,null,'http://www.gooujinja.or.jp','和気清麻呂を祀り、足腰守護と猪の神社として親しまれる。','https://ja.wikipedia.org/wiki/護王神社','Wikipedia',true,now()),
('tomobuchi-hachiman','鞆淵八幡神社','ともぶちはちまんじんじゃ','shrine','旧県社','和歌山県','紀の川市','和歌山県紀の川市中鞆渕58',34.220278,135.460250,1228,null,null,'石清水八幡宮ゆかりの古社。国宝の沃懸地螺鈿金銅装神輿で名高い。','https://ja.wikipedia.org/wiki/鞆淵八幡神社','Wikipedia',true,now()),
('chohoji','頂法寺','ちょうほうじ','temple','天台宗系単立','京都府','京都市','京都府京都市中京区六角通東洞院西入堂之前町248',35.0076611,135.7602361,587,'如意輪観音','https://www.ikenobo.jp/rokkakudo/','「六角堂」の名で親しまれる西国十八番札所。いけばな池坊発祥の地。','https://ja.wikipedia.org/wiki/頂法寺','Wikipedia',true,now()),
('saimyoji-koura','西明寺','さいみょうじ','temple','天台宗','滋賀県','犬上郡甲良町','滋賀県犬上郡甲良町大字池寺26',35.183972,136.284278,834,'薬師如来','http://www.saimyouji.com/','湖東三山の一。国宝の本堂と三重塔、紅葉で名高い古刹。','https://ja.wikipedia.org/wiki/西明寺_(滋賀県甲良町)','Wikipedia',true,now()),
('ichijoji-kasai','一乗寺','いちじょうじ','temple','天台宗','兵庫県','加西市','兵庫県加西市坂本町821-17',34.8593083,134.8190250,650,'聖観音菩薩','https://kanko-kasai.com/spot/culture/itijoji/','国宝の三重塔で知られる西国二十六番札所。法道仙人開基と伝わる。','https://ja.wikipedia.org/wiki/一乗寺_(兵庫県加西市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='goou-jinja' and d.slug in ('wake_kiyomaro','wake_hiromushi'))
or (t.slug='tomobuchi-hachiman' and d.slug in ('hachiman','chuai','himegami'))
or (t.slug='chohoji' and d.slug in ('nyoirin_kannon'))
or (t.slug='saimyoji-koura' and d.slug in ('yakushi_nyorai'))
or (t.slug='ichijoji-kasai' and d.slug in ('sho_kannon'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='tomobuchi-hachiman' and d.slug in ('nintoku_tenno','takeuchi_sukune','amenominakanushi','sarutahiko'))
on conflict do nothing;

-- --- batch 7: 生駒の古刹・伊勢の別宮 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chokyuji','長弓寺','ちょうきゅうじ','temple','真言律宗','奈良県','生駒市','奈良県生駒市上町4443',34.718556,135.726583,728,'十一面観音','https://chokyuji-ensyouin.jp/','鎌倉期の国宝本堂で知られる生駒の古寺。','https://ja.wikipedia.org/wiki/長弓寺','Wikipedia',true,now()),
('geku-toyouke','豊受大神宮','とようけだいじんぐう','shrine','神宮(外宮)','三重県','伊勢市','三重県伊勢市豊川町279番地',34.4872361,136.7029250,477,null,'https://www.isejingu.or.jp/','衣食住をはじめ産業の守護神を祀る、伊勢神宮の外宮。','https://ja.wikipedia.org/wiki/伊勢神宮','Wikipedia',true,now()),
('tsukiyomi-no-miya','月讀宮','つきよみのみや','shrine','皇大神宮別宮','三重県','伊勢市','三重県伊勢市中村町742-1',34.473500,136.728833,null,null,'https://www.isejingu.or.jp/','月讀尊を祀る伊勢神宮内宮の別宮。四宮が並び立つ。','https://ja.wikipedia.org/wiki/月読宮','Wikipedia',true,now()),
('takihara-no-miya','瀧原宮','たきはらのみや','shrine','皇大神宮別宮','三重県','度会郡大紀町','三重県度会郡大紀町滝原872',34.36611,136.42583,null,null,'https://www.isejingu.or.jp/','天照大神の遙宮(とおのみや)と称される内宮の別宮。','https://ja.wikipedia.org/wiki/瀧原宮','Wikipedia',true,now()),
('izawa-no-miya','伊雑宮','いざわのみや','shrine','志摩国一宮・皇大神宮別宮','三重県','志摩市','三重県志摩市磯部町上之郷374',34.38028,136.80889,null,null,'https://www.isejingu.or.jp/','志摩国一宮にして内宮の別宮。御田植祭で名高い。','https://ja.wikipedia.org/wiki/伊雑宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chokyuji' and d.slug in ('juichimen_kannon'))
or (t.slug='geku-toyouke' and d.slug in ('toyouke'))
or (t.slug='tsukiyomi-no-miya' and d.slug in ('tsukuyomi','izanagi','izanami'))
or (t.slug='takihara-no-miya' and d.slug in ('amaterasu'))
or (t.slug='izawa-no-miya' and d.slug in ('amaterasu'))
on conflict do nothing;

-- --- batch 8: 紀州/京都の御利益社・人気御朱印社 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hananoiwaya','花窟神社','はなのいわやじんじゃ','shrine','旧無格社','三重県','熊野市','三重県熊野市有馬町上地130番地',33.879861,136.09333,null,null,'https://hananoiwaya.com/','日本最古の神社とも伝わる、巨岩を御神体とする世界遺産の社。','https://ja.wikipedia.org/wiki/花の窟神社','Wikipedia',true,now()),
('sarumaru-jinja','猿丸神社','さるまるじんじゃ','shrine','旧無格社','京都府','綴喜郡宇治田原町','京都府綴喜郡宇治田原町禅定寺粽谷44',34.880139,135.884167,null,null,null,'瘤取り・がん封じの神として近畿一円の信仰を集める社。','https://ja.wikipedia.org/wiki/猿丸神社','Wikipedia',true,now()),
('yuki-jinja','由岐神社','ゆきじんじゃ','shrine','鞍馬寺鎮守社','京都府','京都市','京都府京都市左京区鞍馬本町1073',35.116083,135.771417,940,null,'http://www.yukijinjya.jp','鞍馬の火祭で名高い鞍馬山の鎮守。靫明神とも称される。','https://ja.wikipedia.org/wiki/由岐神社','Wikipedia',true,now()),
('yasui-konpiragu','安井金比羅宮','やすいこんぴらぐう','shrine','旧郷社','京都府','京都市','京都府京都市東山区東大路松原上ル下弁天町70',34.999917,135.775778,1275,null,'http://www.yasui-konpiragu.or.jp/','「縁切り縁結び碑」で全国に知られる悪縁切りの社。','https://ja.wikipedia.org/wiki/安井金比羅宮','Wikipedia',true,now()),
('mito-jinja','水度神社','みとじんじゃ','shrine','式内社・旧府社','京都府','城陽市','京都府城陽市寺田水度坂87番地',34.854694,135.789611,null,null,null,'旧寺田村の産土神。本殿は室町期の重要文化財。','https://ja.wikipedia.org/wiki/水度神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hananoiwaya' and d.slug in ('izanami','kagutsuchi'))
or (t.slug='sarumaru-jinja' and d.slug in ('sarumaru_dayu'))
or (t.slug='yuki-jinja' and d.slug in ('okuninushi','sukunahikona'))
or (t.slug='yasui-konpiragu' and d.slug in ('sutoku_tenno','omononushi','minamoto_no_yorimasa'))
or (t.slug='mito-jinja' and d.slug in ('amaterasu','takamimusubi','toyotamahime'))
on conflict do nothing;

-- --- batch 9: 大阪の太子ゆかり寺・京都東山の古刹 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ryuanji-mino','瀧安寺','りゅうあんじ','temple','本山修験宗','大阪府','箕面市','大阪府箕面市箕面公園2-23',34.8425222,135.4724278,658,'弁財天','https://www.ryuanji.org/','箕面公園内に建つ修験の古刹。日本の富くじ発祥の地と伝わる。','https://ja.wikipedia.org/wiki/瀧安寺','Wikipedia',true,now()),
('yachuji','野中寺','やちゅうじ','temple','高野山真言宗','大阪府','羽曳野市','大阪府羽曳野市野々上5丁目9-24',34.5593139,135.5919750,650,'薬師如来',null,'「中の太子」と称される聖徳太子建立三太子の一。','https://ja.wikipedia.org/wiki/野中寺','Wikipedia',true,now()),
('senkoji-hirano','全興寺','せんこうじ','temple','高野山真言宗','大阪府','大阪市','大阪府大阪市平野区平野本町4-12-21',34.623389,135.555333,null,'薬師如来','https://www.senkouji.net/','「平野薬師」と親しまれる、地獄堂で名高い下町の古寺。','https://ja.wikipedia.org/wiki/全興寺','Wikipedia',true,now()),
('yogenin','養源院','ようげんいん','temple','浄土真宗遣迎院派','京都府','京都市','京都府京都市東山区三十三間堂廻り町656',34.987861,135.773639,1594,'阿弥陀如来','https://yougenin.jp','俵屋宗達の杉戸絵と血天井で知られる淀殿ゆかりの寺。','https://ja.wikipedia.org/wiki/養源院','Wikipedia',true,now()),
('hokoji-kyoto','方広寺','ほうこうじ','temple','天台宗','京都府','京都市','京都府京都市東山区大和大路通七条上ル茶屋町527-2',34.9921056,135.7720639,1595,'盧舎那仏','https://souda-kyoto.jp/guide/spot/houkouji.html','豊臣秀吉建立の大仏殿跡。鐘銘事件の梵鐘で知られる。','https://ja.wikipedia.org/wiki/方広寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ryuanji-mino' and d.slug in ('benzaiten'))
or (t.slug='yachuji' and d.slug in ('yakushi_nyorai'))
or (t.slug='senkoji-hirano' and d.slug in ('yakushi_nyorai'))
or (t.slug='yogenin' and d.slug in ('amida_nyorai'))
or (t.slug='hokoji-kyoto' and d.slug in ('rushana_butsu'))
on conflict do nothing;

-- --- batch 10: 神戸/西宮/能勢・播磨の社寺 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yuzuruha-jinja','弓弦羽神社','ゆずるはじんじゃ','shrine','旧村社','兵庫県','神戸市','兵庫県神戸市東灘区御影郡家2丁目9番27号',34.723917,135.255083,849,null,'https://yuzuruha-jinja.jp/','御影の熊野信仰の古社。勝運・八咫烏の社として親しまれる。','https://ja.wikipedia.org/wiki/弓弦羽神社','Wikipedia',true,now()),
('koshikiiwa-jinja','越木岩神社','こしきいわじんじゃ','shrine','式内社論社','兵庫県','西宮市','兵庫県西宮市甑岩町5-4',34.758556,135.322083,1656,null,'http://www.koshikiiwa-jinja.jp/','巨石「甑岩」を御神体とする磐座信仰の社。子宝・安産の神。','https://ja.wikipedia.org/wiki/越木岩神社','Wikipedia',true,now()),
('nose-myoken','能勢妙見山','のせみょうけん','temple','日蓮宗','兵庫県','川西市','兵庫県川西市黒川字檜尾谷',34.92898,135.46645,null,'妙見菩薩','http://www.myoken.org/','北極星信仰の霊場。開運・厄除の妙見さんとして親しまれる。','https://ja.wikipedia.org/wiki/能勢妙見山','Wikipedia',true,now()),
('minume-jinja','敏馬神社','みぬめじんじゃ','shrine','式内社・旧県社','兵庫県','神戸市','兵庫県神戸市灘区岩屋中町4-1-8',34.703389,135.218806,null,null,null,'万葉集にも詠まれた神戸灘の古社。','https://ja.wikipedia.org/wiki/敏馬神社','Wikipedia',true,now()),
('chokoji-kato','朝光寺','ちょうこうじ','temple','高野山真言宗','兵庫県','加東市','兵庫県加東市畑609',34.932389,135.043833,651,'千手観音','https://shin-saigoku.jp/templ/templ-031/','国宝の本堂で知られる鹿野山の古刹。','https://ja.wikipedia.org/wiki/朝光寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yuzuruha-jinja' and d.slug in ('izanami','kotosaka_no_o','hayatama'))
or (t.slug='koshikiiwa-jinja' and d.slug in ('hiruko'))
or (t.slug='nose-myoken' and d.slug in ('myoken_bosatsu'))
or (t.slug='minume-jinja' and d.slug in ('susanoo'))
or (t.slug='chokoji-kato' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- --- batch 11: 播磨の札所・紀州の古社寺 ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sagamiji','酒見寺','さがみじ','temple','高野山真言宗','兵庫県','加西市','兵庫県加西市北条町北条1319',34.935694,134.829583,745,'十一面観音','https://shin-saigoku.jp/templ/templ-029/','聖武天皇の勅願による古刹。重文の多宝塔で知られる。','https://ja.wikipedia.org/wiki/酒見寺','Wikipedia',true,now()),
('fujishiro-jinja','藤白神社','ふじしろじんじゃ','shrine','旧県社','和歌山県','海南市','和歌山県海南市藤白466',34.14430861,135.20939194,null,null,'https://fujishiro-jinja.net/','熊野古道の藤白王子。鈴木姓発祥の地として知られる。','https://ja.wikipedia.org/wiki/藤白神社','Wikipedia',true,now()),
('kamayama-jinja','竈山神社','かまやまじんじゃ','shrine','式内社・旧官幣大社','和歌山県','和歌山市','和歌山県和歌山市和田438',34.201000,135.20444,null,null,null,'神武天皇の兄・彦五瀬命の墓所に鎮座する官幣大社。','https://ja.wikipedia.org/wiki/竈山神社','Wikipedia',true,now()),
('niu-sakadono-jinja','丹生酒殿神社','にうさかどのじんじゃ','shrine','村社','和歌山県','伊都郡かつらぎ町','和歌山県伊都郡かつらぎ町三谷631番地',34.289222,135.520000,null,null,null,'丹生都比売大神降臨の地と伝わる古社。大銀杏で名高い。','https://ja.wikipedia.org/wiki/丹生酒殿神社','Wikipedia',true,now()),
('negoroji','根来寺','ねごろじ','temple','新義真言宗','和歌山県','岩出市','和歌山県岩出市根来2286',34.28722,135.31667,1130,'大日如来','https://www.negoroji.org/','覚鑁が開いた新義真言宗総本山。国宝の大塔で名高い。','https://ja.wikipedia.org/wiki/根来寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sagamiji' and d.slug in ('juichimen_kannon'))
or (t.slug='fujishiro-jinja' and d.slug in ('nigihayahi'))
or (t.slug='kamayama-jinja' and d.slug in ('itsuse'))
or (t.slug='niu-sakadono-jinja' and d.slug in ('niutsuhime'))
or (t.slug='negoroji' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='fujishiro-jinja' and d.slug in ('amaterasu','hayatama'))
or (t.slug='niu-sakadono-jinja' and d.slug in ('hachiman'))
on conflict do nothing;

-- --- batch 12: 大和の古寺(橿原・桜井・奈良) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kumedera','久米寺','くめでら','temple','真言宗御室派','奈良県','橿原市','奈良県橿原市久米町502',34.4845639,135.7900306,null,'薬師如来',null,'久米仙人伝説で知られ、空海が大日経を感得した真言宗発祥ゆかりの寺。','https://ja.wikipedia.org/wiki/久米寺','Wikipedia',true,now()),
('ryosenji-nara','霊山寺','りょうせんじ','temple','霊山寺真言宗','奈良県','奈良市','奈良県奈良市中町3879',34.673028,135.741972,736,'薬師三尊','http://www.ryosenji.jp/','バラ園で名高い行基開基の古刹。霊山寺真言宗大本山。','https://ja.wikipedia.org/wiki/霊山寺_(奈良市)','Wikipedia',true,now()),
('shorinji-sakurai','聖林寺','しょうりんじ','temple','真言宗室生寺派','奈良県','桜井市','奈良県桜井市下692',34.491694,135.851833,712,'子安延命地蔵菩薩','http://www.shorinji-temple.jp/','国宝の十一面観音像で名高い、多武峰を望む古寺。','https://ja.wikipedia.org/wiki/聖林寺','Wikipedia',true,now()),
('abe-monjuin','安倍文殊院','あべもんじゅいん','temple','華厳宗','奈良県','桜井市','奈良県桜井市阿部645',34.503611,135.841861,645,'文殊菩薩','https://www.abemonjuin.or.jp/','日本三文殊の一。快慶作の国宝・騎獅文殊菩薩で知られる。','https://ja.wikipedia.org/wiki/安倍文殊院','Wikipedia',true,now()),
('byakugoji','白毫寺','びゃくごうじ','temple','真言律宗','奈良県','奈良市','奈良県奈良市白毫寺町392',34.6710139,135.8512083,715,'阿弥陀如来','https://narashikanko.or.jp/spot/detail_10020.html','高円山麓の花の寺。五色椿と眺望で知られる。','https://ja.wikipedia.org/wiki/白毫寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kumedera' and d.slug in ('yakushi_nyorai'))
or (t.slug='ryosenji-nara' and d.slug in ('yakushi_nyorai'))
or (t.slug='shorinji-sakurai' and d.slug in ('jizo_bosatsu'))
or (t.slug='abe-monjuin' and d.slug in ('monju_bosatsu'))
or (t.slug='byakugoji' and d.slug in ('amida_nyorai'))
on conflict do nothing;
