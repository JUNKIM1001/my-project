-- 近畿 第2弾（三重・滋賀・京都・大阪・兵庫・奈良・和歌山）著名社寺バッチ（50件）
-- 「次のティア」: 西国三十三所札所・別表神社/一宮論社・著名寺を中心に新規収録。
-- 出典: 日本語Wikipedia 各記事 infobox（所在地・十進緯度経度・御祭神/本尊・創建・公式サイト）
-- すべてエージェントが1件ずつWebFetchで裏取り。実在・参拝可能。座標が infobox に無い社寺は除外。
-- 1巡目 kansai.sql の42件および超有名社寺とは重複させない。

-- ① 新規神仏（既存の神仏 slug に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('miroku_nyorai','弥勒如来','みろくにょらい','buddha','如来','{"弥勒仏"}','仏教','五十六億七千万年後に現れて衆生を救う未来仏。施福寺・當麻寺の本尊系。','https://ja.wikipedia.org/wiki/弥勒菩薩','Wikipedia',true,now()),
('miroku_bosatsu','弥勒菩薩','みろくぼさつ','buddha','菩薩','{"弥勒"}','仏教','兜率天で修行し未来に成仏するとされる菩薩。園城寺の本尊。','https://ja.wikipedia.org/wiki/弥勒菩薩','Wikipedia',true,now()),
('zao_gongen','蔵王権現','ざおうごんげん','buddha','明王','{"金剛蔵王権現","金剛蔵王大権現"}','仏教','役行者が感得した修験道の本尊。吉野金峯山寺の本尊。','https://ja.wikipedia.org/wiki/蔵王権現','Wikipedia',true,now()),
('itakeru','五十猛命','いたけるのみこと','kami','国津神','{"大屋毘古神","大屋彦神"}','記紀','素戔嗚尊の御子で木の神・林業の神。伊太祁曽神社の御祭神。','https://ja.wikipedia.org/wiki/イタケル','Wikipedia',true,now()),
('hinokuma_okami','日前大神','ひのくまのおおかみ','kami','天津神','{"日像鏡"}','記紀','日前神宮の主祭神。天照大神の御霊代である日像鏡を御神体とする。','https://ja.wikipedia.org/wiki/日前神宮・國懸神宮','Wikipedia',true,now()),
('kunikakasu_okami','國懸大神','くにかかすのおおかみ','kami','天津神','{"日矛鏡"}','記紀','國懸神宮の主祭神。天照大神の御霊代である日矛鏡を御神体とする。','https://ja.wikipedia.org/wiki/日前神宮・國懸神宮','Wikipedia',true,now()),
('shotoku_taishi','聖徳太子','しょうとくたいし','kami','御霊','{"厩戸皇子","厩戸王","上宮太子"}','その他','飛鳥時代の皇族・政治家。仏教興隆の祖。橘寺の本尊（太子像）。','https://ja.wikipedia.org/wiki/聖徳太子','Wikipedia',true,now()),
('otori_oyagami','大鳥連祖神','おおとりのむらじのおやがみ','kami','天津神','{"天児屋根命同神説"}','その他','大鳥連の祖神。大鳥大社で日本武尊とともに祀られる。','https://ja.wikipedia.org/wiki/大鳥大社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='miroku_nyorai'    and g.slug in ('jouju','kaiun','byoki_heyu','choju'))
 or (d.slug='miroku_bosatsu'   and g.slug in ('jouju','kaiun','gakumon','choju'))
 or (d.slug='zao_gongen'       and g.slug in ('yakubarai','shobu','kaiun','majo_kekkai'))
 or (d.slug='itakeru'          and g.slug in ('suisan_noko','shobai','kaiun','kanai_anzen'))
 or (d.slug='hinokuma_okami'   and g.slug in ('kaiun','yakubarai','majo_kekkai'))
 or (d.slug='kunikakasu_okami' and g.slug in ('kaiun','yakubarai','majo_kekkai'))
 or (d.slug='shotoku_taishi'   and g.slug in ('gakugyo','gakumon','shusse','jouju'))
 or (d.slug='otori_oyagami'    and g.slug in ('shobu','kaiun','shusse'))
on conflict do nothing;

-- ③ 社寺（50件）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- 三重県
('aekuni-jinja','敢國神社','あえくにじんじゃ','shrine','伊賀国一宮（式内大社・旧県社）','三重県','伊賀市','三重県伊賀市一之宮877',34.787367,136.163939,658,null,'http://www.aekuni.jp/','伊賀国一宮。大彦命を主祭神とする伊賀地方総鎮守。','https://ja.wikipedia.org/wiki/敢國神社','Wikipedia',true,now()),
('senjuji-tsu','高田山専修寺','たかだやませんじゅじ','temple','真宗高田派','三重県','津市','三重県津市一身田町2819',34.762061,136.503556,null,'阿弥陀如来','http://www.senjuji.or.jp/','真宗高田派本山。国宝の御影堂・如来堂を持つ一身田の大伽藍。','https://ja.wikipedia.org/wiki/専修寺','Wikipedia',true,now()),
-- 滋賀県
('takebe-taisha','建部大社','たけべたいしゃ','shrine','近江国一宮（旧官幣大社・別表神社）','滋賀県','大津市','滋賀県大津市神領1丁目16-1',34.973500,135.913500,null,null,'http://takebetaisha.jp/','近江国一宮。日本武尊を主祭神とし出世開運の神として信仰される。','https://ja.wikipedia.org/wiki/建部大社','Wikipedia',true,now()),
('chomeiji','姨綺耶山長命寺','いきやさんちょうめいじ','temple','天台宗系単立','滋賀県','近江八幡市','滋賀県近江八幡市長命寺町157',35.162683,136.064003,619,'千手十一面聖観音','https://www.saikoku33.gr.jp/place/31','西国三十三所第31番。琵琶湖を望む山上に建つ延命長寿の観音霊場。','https://ja.wikipedia.org/wiki/長命寺','Wikipedia',true,now()),
('hogonji','巖金山宝厳寺','がんこんさんほうごんじ','temple','真言宗豊山派','滋賀県','長浜市','滋賀県長浜市早崎町1664',35.421122,136.143225,724,'弁才天','https://www.chikubushima.jp/','西国三十三所第30番。竹生島に建つ日本三大弁才天の一つ。','https://ja.wikipedia.org/wiki/宝厳寺','Wikipedia',true,now()),
('onjoji','長等山園城寺（三井寺）','ながらさんおんじょうじ','temple','天台寺門宗','滋賀県','大津市','滋賀県大津市園城寺町246',35.013400,135.852900,672,'弥勒菩薩','http://www.shiga-miidera.or.jp/','天台寺門宗総本山。西国三十三所第14番。三井の晩鐘で名高い。','https://ja.wikipedia.org/wiki/園城寺','Wikipedia',true,now()),
('hyakusaiji','釈迦山百済寺','しゃかさんひゃくさいじ','temple','天台宗','滋賀県','東近江市','滋賀県東近江市百済寺町323',35.126889,136.288833,606,'十一面観音','http://www.hyakusaiji.jp/','湖東三山の一つ。聖徳太子創建と伝わる近江最古級の古刹。','https://ja.wikipedia.org/wiki/百済寺_(東近江市)','Wikipedia',true,now()),
-- 京都府
('mimurotoji','明星山三室戸寺','みょうじょうさんみむろとじ','temple','本山修験宗','京都府','宇治市','京都府宇治市莵道滋賀谷21',34.900478,135.819194,770,'千手観音','https://www.mimurotoji.com/','西国三十三所第10番。あじさい・つつじの花の寺として知られる。','https://ja.wikipedia.org/wiki/三室戸寺','Wikipedia',true,now()),
('imakumano-kannonji','新那智山観音寺（今熊野観音寺）','しんなちさんかんのんじ','temple','真言宗泉涌寺派','京都府','京都市東山区','京都府京都市東山区泉涌寺山内町32',34.979706,135.780842,807,'十一面観音','https://www.kannon.jp/','西国三十三所第15番。頭痛封じ・智慧授けの観音霊場。','https://ja.wikipedia.org/wiki/今熊野観音寺','Wikipedia',true,now()),
('gokonomiya','御香宮神社','ごこうのみやじんじゃ','shrine','式内社・旧府社','京都府','京都市伏見区','京都府京都市伏見区御香宮門前町174',34.934722,135.767500,null,null,'http://www.gokounomiya.kyoto.jp/','名水「御香水」で名高い伏見の産土神。神功皇后を主祭神とする。','https://ja.wikipedia.org/wiki/御香宮神社','Wikipedia',true,now()),
('matsunoo-taisha','松尾大社','まつのおたいしゃ','shrine','旧官幣大社・二十二社・別表神社','京都府','京都市西京区','京都府京都市西京区嵐山宮町3',34.999964,135.685172,701,null,'https://www.matsunoo.or.jp/','京都最古級の社。大山咋神を祀り酒造の神として全国の蔵元に崇敬される。','https://ja.wikipedia.org/wiki/松尾大社','Wikipedia',true,now()),
('sanzenin','魚山三千院門跡','ぎょざんさんぜんいんもんぜき','temple','天台宗','京都府','京都市左京区','京都府京都市左京区大原来迎院町540',35.119800,135.834400,788,'薬師如来','http://www.sanzenin.or.jp/','大原に佇む天台三門跡の一つ。往生極楽院の阿弥陀三尊で名高い。','https://ja.wikipedia.org/wiki/三千院','Wikipedia',true,now()),
('jingoji','高雄山神護寺','たかおさんじんごじ','temple','高野山真言宗','京都府','京都市右京区','京都府京都市右京区梅ヶ畑高雄町5',35.055017,135.670867,824,'薬師如来','http://www.jingoji.or.jp/','空海・最澄ゆかりの古刹。高雄の紅葉と国宝薬師如来像で名高い。','https://ja.wikipedia.org/wiki/神護寺','Wikipedia',true,now()),
('kozanji','栂尾山高山寺','とがのおさんこうざんじ','temple','真言宗系単立','京都府','京都市右京区','京都府京都市右京区梅ヶ畑栂尾町8',35.060108,135.678569,1206,'釈迦如来','https://kosanji.com/','明恵上人ゆかりの世界遺産。鳥獣人物戯画と日本最古の茶園で知られる。','https://ja.wikipedia.org/wiki/高山寺','Wikipedia',true,now()),
('ninnaji','大内山仁和寺','おおうちやまにんなじ','temple','真言宗御室派','京都府','京都市右京区','京都府京都市右京区御室大内33',35.031056,135.713806,888,'阿弥陀如来','https://ninnaji.jp/','真言宗御室派総本山。御室桜で名高い門跡寺院の世界遺産。','https://ja.wikipedia.org/wiki/仁和寺','Wikipedia',true,now()),
('daihoonji','瑞応山大報恩寺（千本釈迦堂）','ずいおうざんだいほうおんじ','temple','真言宗智山派','京都府','京都市上京区','京都府京都市上京区七本松通今出川上ル溝前町',35.031869,135.739903,1227,'釈迦如来','https://daihoonji.jp/','千本釈迦堂の名で親しまれる。洛中最古の本堂とおかめ伝説で知られる。','https://ja.wikipedia.org/wiki/大報恩寺','Wikipedia',true,now()),
('sanjusangendo','蓮華王院本堂（三十三間堂）','れんげおういんほんどう','temple','天台宗','京都府','京都市東山区','京都府京都市東山区三十三間堂廻町657',34.987864,135.771731,1164,'千手観音','https://www.sanjusangendo.jp/','千一体の千手観音像が並ぶ国宝の本堂。通し矢で名高い。','https://ja.wikipedia.org/wiki/蓮華王院本堂','Wikipedia',true,now()),
('obakusan-manpukuji','黄檗山萬福寺','おうばくさんまんぷくじ','temple','黄檗宗','京都府','宇治市','京都府宇治市五ヶ庄三番割34',34.914256,135.806064,1661,'釈迦如来','https://www.obakusan.or.jp/','隠元禅師が開いた黄檗宗大本山。中国明朝風の伽藍と普茶料理で知られる。','https://ja.wikipedia.org/wiki/萬福寺','Wikipedia',true,now()),
('byodoin','朝日山平等院','あさひさんびょうどういん','temple','単立（天台宗・浄土宗）','京都府','宇治市','京都府宇治市宇治蓮華116',34.889292,135.807692,1052,'阿弥陀如来','https://www.byodoin.or.jp/','十円硬貨で名高い鳳凰堂を持つ世界遺産。藤原氏の極楽浄土を表す。','https://ja.wikipedia.org/wiki/平等院','Wikipedia',true,now()),
-- 大阪府
('fujiidera','紫雲山葛井寺','しうんざんふじいでら','temple','真言宗御室派','大阪府','藤井寺市','大阪府藤井寺市藤井寺1丁目16-21',34.570186,135.596556,725,'十一面千手千眼観音','http://www.fujiidera-temple.or.jp/','西国三十三所第5番。日本最古の千手観音（国宝）を本尊とする。','https://ja.wikipedia.org/wiki/葛井寺','Wikipedia',true,now()),
('sefukuji','槇尾山施福寺','まきのおさんせふくじ','temple','天台宗','大阪府','和泉市','大阪府和泉市槇尾山町136',34.392908,135.511578,null,'弥勒如来','https://www.city.kawachinagano.lg.jp/','西国三十三所第4番。険しい山道の先に建つ槇尾山の観音霊場。','https://ja.wikipedia.org/wiki/施福寺','Wikipedia',true,now()),
('tamatsukuri-inari','玉造稲荷神社','たまつくりいなりじんじゃ','shrine','旧府社','大阪府','大阪市中央区','大阪府大阪市中央区玉造2丁目3-8',34.677944,135.529944,null,null,'https://www.inari.or.jp/','大阪城の鎮守として豊臣・徳川に崇敬された稲荷社。','https://ja.wikipedia.org/wiki/玉造稲荷神社','Wikipedia',true,now()),
('otori-taisha','大鳥大社','おおとりたいしゃ','shrine','和泉国一宮（旧官幣大社・別表神社）','大阪府','堺市西区','大阪府堺市西区鳳北町1丁目1-2',34.536861,135.460750,null,null,'https://www.ootoritaisha.jp/','和泉国一宮。全国大鳥神社の総本社で日本武尊を祀る。','https://ja.wikipedia.org/wiki/大鳥大社','Wikipedia',true,now()),
('hochigai-jinja','方違神社','ほうちがいじんじゃ','shrine','旧郷社','大阪府','堺市堺区','大阪府堺市堺区北三国ヶ丘町2丁2-1',34.576940,135.489440,null,null,'http://www.hochigai-jinja.or.jp/','方位の災いを除く方違えの神として古来信仰される。','https://ja.wikipedia.org/wiki/方違神社','Wikipedia',true,now()),
('kanshinji','檜尾山観心寺','ひのおさんかんしんじ','temple','高野山真言宗','大阪府','河内長野市','大阪府河内長野市寺元475',34.437333,135.598583,701,'如意輪観音','https://www.kanshinji.com/','楠木正成ゆかりの古刹。国宝の如意輪観音像と本堂で知られる。','https://ja.wikipedia.org/wiki/観心寺','Wikipedia',true,now()),
('katsuoji','応頂山勝尾寺','おうちょうざんかつおうじ','temple','高野山真言宗','大阪府','箕面市','大阪府箕面市粟生間谷2914-1',34.865830,135.491110,727,'十一面千手観音','https://katsuo-ji-temple.or.jp/','西国三十三所第23番。勝運の勝ちダルマで名高い観音霊場。','https://ja.wikipedia.org/wiki/勝尾寺','Wikipedia',true,now()),
('sojiji','補陀洛山総持寺','ふだらくさんそうじじ','temple','高野山真言宗','大阪府','茨木市','大阪府茨木市総持寺1丁目6-1',34.829103,135.581569,879,'千手観音','http://sojiji.or.jp/','西国三十三所第22番。亀の恩返し伝説と包丁式で知られる観音霊場。','https://ja.wikipedia.org/wiki/総持寺_(茨木市)','Wikipedia',true,now()),
-- 兵庫県
('banshu-kiyomizudera','御嶽山清水寺（播州清水寺）','みたけさんきよみずでら','temple','天台宗','兵庫県','加東市','兵庫県加東市平木1194',34.972494,135.081822,null,'十一面観音','https://kiyomizudera.net/','西国三十三所第25番。御嶽山頂に建つ播州清水寺。','https://ja.wikipedia.org/wiki/清水寺_(兵庫県加東市)','Wikipedia',true,now()),
('hirota-jinja','廣田神社','ひろたじんじゃ','shrine','式内名神大社・二十二社・旧官幣大社・別表神社','兵庫県','西宮市','兵庫県西宮市大社町7番7号',34.752972,135.339972,null,null,'http://www.hirotahonsya.or.jp/','天照大神荒魂を祀る兵庫県最古級の名社。西宮の地名の由来。','https://ja.wikipedia.org/wiki/廣田神社','Wikipedia',true,now()),
('kaijin-jinja','海神社','かいじんじゃ','shrine','式内名神大社・旧官幣中社・別表神社','兵庫県','神戸市垂水区','兵庫県神戸市垂水区宮本町5-1',34.628694,135.054306,null,null,'http://kaijinjya.jp/','綿津見三神を祀る海上安全・漁業の社。垂水の浜の古社。','https://ja.wikipedia.org/wiki/海神社_(神戸市)','Wikipedia',true,now()),
('nagata-jinja','長田神社','ながたじんじゃ','shrine','式内名神大社・旧官幣中社・別表神社','兵庫県','神戸市長田区','兵庫県神戸市長田区長田町3-1-1',34.671194,135.147000,201,null,'https://nagatajinja.jp/','事代主神を祀る神戸三大神社の一つ。商売繁盛の福の神。','https://ja.wikipedia.org/wiki/長田神社','Wikipedia',true,now()),
('shosha-engyoji','書写山圓教寺','しょしゃざんえんぎょうじ','temple','天台宗','兵庫県','姫路市','兵庫県姫路市書写2968',34.891139,134.658139,966,'釈迦三尊','http://www.shosha.or.jp/','西国三十三所第27番。西の比叡山と称される書写山の大伽藍。','https://ja.wikipedia.org/wiki/圓教寺','Wikipedia',true,now()),
-- 奈良県
('okadera','東光山龍蓋寺（岡寺）','とうこうざんりゅうがいじ','temple','真言宗豊山派','奈良県','高市郡明日香村','奈良県高市郡明日香村岡806',34.471789,135.828372,null,'如意輪観音','http://www.okadera3307.com/','西国三十三所第7番。日本最初の厄除け霊場。日本最大の塑像本尊。','https://ja.wikipedia.org/wiki/岡寺','Wikipedia',true,now()),
('tsubosakadera','壷阪山南法華寺（壷阪寺）','つぼさかさんみなみほっけじ','temple','真言宗系単立','奈良県','高市郡高取町','奈良県高市郡高取町壷阪3',34.426556,135.810280,703,'十一面千手観音','http://www.tsubosaka1300.or.jp/','西国三十三所第6番。眼病平癒と壷阪霊験記で名高い観音霊場。','https://ja.wikipedia.org/wiki/壷阪寺','Wikipedia',true,now()),
('taimadera','二上山當麻寺','にじょうさんたいまでら','temple','真言宗・浄土宗','奈良県','葛城市','奈良県葛城市當麻1263',34.516083,135.694639,612,'当麻曼荼羅','http://www.taimadera.org/','中将姫の當麻曼荼羅で名高い古刹。東西両塔が現存する唯一の寺。','https://ja.wikipedia.org/wiki/當麻寺','Wikipedia',true,now()),
('muroji','宀一山室生寺','べんいちさんむろうじ','temple','真言宗室生寺派','奈良県','宇陀市','奈良県宇陀市室生78',34.537889,136.040611,null,'如意輪観音','http://www.murouji.or.jp/','女人高野と称される室生寺派大本山。屋外最小の国宝五重塔で名高い。','https://ja.wikipedia.org/wiki/室生寺','Wikipedia',true,now()),
('kinpusenji','国軸山金峯山寺','こくじくさんきんぷせんじ','temple','金峯山修験本宗','奈良県','吉野郡吉野町','奈良県吉野郡吉野町吉野山2498',34.368250,135.858167,null,'蔵王権現','https://www.kinpusen.or.jp/','吉野山に建つ修験道の総本山。秘仏蔵王権現を祀る世界遺産。','https://ja.wikipedia.org/wiki/金峯山寺','Wikipedia',true,now()),
('yakushiji','薬師寺','やくしじ','temple','法相宗','奈良県','奈良市','奈良県奈良市西ノ京町457',34.668356,135.784311,680,'薬師三尊','https://www.yakushiji.or.jp/','法相宗大本山。東塔と薬師三尊像で名高い世界遺産。','https://ja.wikipedia.org/wiki/薬師寺','Wikipedia',true,now()),
('toshodaiji','唐招提寺','とうしょうだいじ','temple','律宗','奈良県','奈良市','奈良県奈良市五条町13-46',34.675583,135.784833,759,'盧舎那仏','https://www.toshodaiji.jp/','鑑真和上が開いた律宗総本山。天平の金堂で名高い世界遺産。','https://ja.wikipedia.org/wiki/唐招提寺','Wikipedia',true,now()),
('saidaiji','勝宝山西大寺','しょうほうざんさいだいじ','temple','真言律宗','奈良県','奈良市','奈良県奈良市西大寺芝町1丁目1-5',34.693610,135.779500,765,'釈迦如来','http://saidaiji.or.jp/','真言律宗総本山。南都七大寺の一つ。大茶盛式で知られる。','https://ja.wikipedia.org/wiki/西大寺_(奈良市)','Wikipedia',true,now()),
('daianji','大安寺','だいあんじ','temple','高野山真言宗','奈良県','奈良市','奈良県奈良市大安寺2丁目18-1',34.668000,135.812722,null,'十一面観音','http://www.daianji.or.jp/','南都七大寺の一つ。がん封じの祈願寺として信仰される古刹。','https://ja.wikipedia.org/wiki/大安寺','Wikipedia',true,now()),
('tachibanadera','仏頭山橘寺','ぶっとうさんたちばなでら','temple','天台宗','奈良県','高市郡明日香村','奈良県高市郡明日香村橘532',34.470000,135.818060,606,'聖徳太子像','https://tachibanadera-asuka.jimdofree.com/','聖徳太子生誕の地と伝わる古刹。太子勝鬘経講讃像を本尊とする。','https://ja.wikipedia.org/wiki/橘寺','Wikipedia',true,now()),
('hokkeji','法華寺','ほっけじ','temple','光明宗','奈良県','奈良市','奈良県奈良市法華寺町882',34.692333,135.804111,745,'十一面観音','https://hokkejimonzeki.or.jp/','光明皇后が建てた総国分尼寺。国宝十一面観音像で名高い門跡尼寺。','https://ja.wikipedia.org/wiki/法華寺','Wikipedia',true,now()),
('enjoji-nara','忍辱山円成寺','にんにくせんえんじょうじ','temple','真言宗御室派','奈良県','奈良市','奈良県奈良市忍辱山町1273',34.695828,135.915394,null,'阿弥陀如来','http://www.enjyouji.jp/','運慶最初期の国宝大日如来坐像と浄土式庭園で名高い古刹。','https://ja.wikipedia.org/wiki/円成寺','Wikipedia',true,now()),
('katsuragi-hitokotonushi','葛城一言主神社','かつらぎひとことぬしじんじゃ','shrine','式内名神大社・旧県社','奈良県','御所市','奈良県御所市森脇432',34.445500,135.711900,null,null,'http://hitokotonushi.or.jp/','一言の願いを叶える一言主大神を祀る全国一言主神社の総本社。','https://ja.wikipedia.org/wiki/葛城一言主神社','Wikipedia',true,now()),
('ofusa-kannon','十無量山観音寺（おふさ観音）','じゅうむりょうざんかんのんじ','temple','高野山真言宗','奈良県','橿原市','奈良県橿原市小房町6-22',34.503194,135.797111,1650,'十一面観音','http://www.ofusa.jp/','バラと風鈴で名高い「花まんだらの寺」。厄除け・ぼけ封じの観音。','https://ja.wikipedia.org/wiki/おふさ観音','Wikipedia',true,now()),
-- 和歌山県
('seigantoji','那智山青岸渡寺','なちさんせいがんとじ','temple','天台宗','和歌山県','東牟婁郡那智勝浦町','和歌山県東牟婁郡那智勝浦町那智山8',33.669170,135.890000,null,'如意輪観音','https://seigantoji.or.jp/','西国三十三所第1番。那智の滝とともに信仰される世界遺産。','https://ja.wikipedia.org/wiki/青岸渡寺','Wikipedia',true,now()),
('negoroji','一乗山根来寺','いちじょうざんねごろじ','temple','新義真言宗','和歌山県','岩出市','和歌山県岩出市根来2286',34.287220,135.316670,1130,'大日如来','https://www.negoroji.org/','新義真言宗総本山。覚鑁が開いた大伽藍で国宝大塔（多宝塔）で名高い。','https://ja.wikipedia.org/wiki/根来寺','Wikipedia',true,now()),
('itakiso-jinja','伊太祁曽神社','いたきそじんじゃ','shrine','紀伊国一宮（旧官幣中社・別表神社）','和歌山県','和歌山市','和歌山県和歌山市伊太祈曽558',34.201694,135.250000,null,null,'https://itakiso-jinja.net/','紀伊国一宮論社。木の神・五十猛命を祀る木の国の総鎮守。','https://ja.wikipedia.org/wiki/伊太祁曽神社','Wikipedia',true,now()),
('hinokuma-jingu','日前神宮・國懸神宮','ひのくまじんぐう・くにかかすじんぐう','shrine','紀伊国一宮（式内名神大社・旧官幣大社）','和歌山県','和歌山市','和歌山県和歌山市秋月365',34.228890,135.202220,null,null,'http://hinokuma-jingu.com/','紀伊国一宮論社。天照大神の御霊代の鏡を祀る二つの神宮。','https://ja.wikipedia.org/wiki/日前神宮・國懸神宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（主祭神・本尊 = role 'main'）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='aekuni-jinja'            and d.slug='oohiko')
 or (t.slug='senjuji-tsu'            and d.slug='amida_nyorai')
 or (t.slug='takebe-taisha'          and d.slug in ('yamatotakeru','okuninushi'))
 or (t.slug='chomeiji'               and d.slug in ('senju_kannon','juichimen_kannon','sho_kannon'))
 or (t.slug='hogonji'                and d.slug='senju_kannon')
 or (t.slug='onjoji'                 and d.slug='miroku_bosatsu')
 or (t.slug='hyakusaiji'             and d.slug='juichimen_kannon')
 or (t.slug='mimurotoji'             and d.slug='senju_kannon')
 or (t.slug='imakumano-kannonji'     and d.slug='juichimen_kannon')
 or (t.slug='gokonomiya'             and d.slug='jingu_kogo')
 or (t.slug='matsunoo-taisha'        and d.slug='oyamakui')
 or (t.slug='sanzenin'               and d.slug='yakushi_nyorai')
 or (t.slug='jingoji'                and d.slug='yakushi_nyorai')
 or (t.slug='kozanji'                and d.slug='shaka_nyorai')
 or (t.slug='ninnaji'                and d.slug='amida_nyorai')
 or (t.slug='daihoonji'              and d.slug='shaka_nyorai')
 or (t.slug='sanjusangendo'          and d.slug='senju_kannon')
 or (t.slug='obakusan-manpukuji'     and d.slug='shaka_nyorai')
 or (t.slug='byodoin'                and d.slug='amida_nyorai')
 or (t.slug='fujiidera'              and d.slug='senju_kannon')
 or (t.slug='sefukuji'               and d.slug='miroku_nyorai')
 or (t.slug='tamatsukuri-inari'      and d.slug='ukanomitama')
 or (t.slug='otori-taisha'           and d.slug in ('yamatotakeru','otori_oyagami'))
 or (t.slug='hochigai-jinja'         and d.slug in ('susanoo','sumiyoshi','jingu_kogo'))
 or (t.slug='kanshinji'              and d.slug='nyoirin_kannon')
 or (t.slug='katsuoji'               and d.slug='senju_kannon')
 or (t.slug='sojiji'                 and d.slug='senju_kannon')
 or (t.slug='banshu-kiyomizudera'    and d.slug='juichimen_kannon')
 or (t.slug='hirota-jinja'           and d.slug='amaterasu')
 or (t.slug='kaijin-jinja'           and d.slug='watatsumi')
 or (t.slug='nagata-jinja'           and d.slug='kotoshironushi')
 or (t.slug='shosha-engyoji'         and d.slug='shaka_nyorai')
 or (t.slug='okadera'                and d.slug='nyoirin_kannon')
 or (t.slug='tsubosakadera'          and d.slug='senju_kannon')
 or (t.slug='taimadera'              and d.slug='miroku_nyorai')
 or (t.slug='muroji'                 and d.slug='nyoirin_kannon')
 or (t.slug='kinpusenji'             and d.slug='zao_gongen')
 or (t.slug='yakushiji'              and d.slug='yakushi_nyorai')
 or (t.slug='toshodaiji'             and d.slug='rushana-butsu')
 or (t.slug='saidaiji'               and d.slug='shaka_nyorai')
 or (t.slug='daianji'                and d.slug='juichimen_kannon')
 or (t.slug='tachibanadera'          and d.slug='shotoku_taishi')
 or (t.slug='hokkeji'                and d.slug='juichimen_kannon')
 or (t.slug='enjoji-nara'            and d.slug='amida_nyorai')
 or (t.slug='katsuragi-hitokotonushi' and d.slug='hitokotonushi')
 or (t.slug='ofusa-kannon'           and d.slug='juichimen_kannon')
 or (t.slug='seigantoji'             and d.slug='nyoirin_kannon')
 or (t.slug='negoroji'               and d.slug='dainichi_nyorai')
 or (t.slug='itakiso-jinja'          and d.slug='itakeru')
 or (t.slug='hinokuma-jingu'         and d.slug in ('hinokuma_okami','kunikakasu_okami'))
on conflict do nothing;
