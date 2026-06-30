-- ============================================================
-- 関東地方（茨城・栃木・群馬・埼玉・千葉・東京・神奈川）社寺データ
-- AGENT_SPEC.md 準拠。全件 ja.wikipedia.org の infobox を WebFetch で裏取り。
-- 座標は infobox の十進値（度分秒は十進変換）を採用。
-- 既存パイロット/分担分（明治神宮・日光東照宮・鶴岡八幡宮・浅草寺・成田山新勝寺・
-- 川崎大師・鹿島神宮・武蔵一宮氷川神社・大崎八幡宮）は除外。
-- ============================================================

-- ============================================================
-- ① 新規神仏（既存柱に無いものだけ）
-- ============================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('izanagi','伊弉諾尊','いざなぎのみこと','kami','天津神','{}','記紀','国生み・神生みを行った男神。伊弉冊尊と対をなす。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('yamatotakeru','日本武尊','やまとたけるのみこと','kami','天津神','{ヤマトタケル,倭建命}','記紀','景行天皇の皇子で東征伝説の英雄神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('toyouke','豊受大神','とようけのおおかみ','kami','天津神','{豊受姫}','記紀','食物・穀物を司る女神。伊勢神宮外宮の祭神。','https://ja.wikipedia.org/wiki/トヨウケビメ','Wikipedia',true,now()),
('oyamatsumi','大山祇神','おおやまつみのかみ','kami','国津神','{大山積神}','記紀','山を司る神。木花咲耶姫の父。','https://ja.wikipedia.org/wiki/オオヤマツミ','Wikipedia',true,now()),
('oyamakui','大山咋神','おおやまくいのかみ','kami','国津神','{山王}','記紀','比叡山・松尾山の地主神。山王信仰の祭神。','https://ja.wikipedia.org/wiki/オオヤマクイ','Wikipedia',true,now()),
('kushinadahime','奇稲田姫命','くしなだひめのみこと','kami','国津神','{櫛名田比売}','記紀','素戔嗚尊の妻神。八岐大蛇から救われた稲田の女神。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('kagutsuchi','火産霊神','ほむすびのかみ','kami','天津神','{火之迦具土神,カグツチ}','記紀','火を司る神。','https://ja.wikipedia.org/wiki/カグツチ','Wikipedia',true,now()),
('haniyasuhime','埴山姫神','はにやまひめのかみ','kami','国津神','{波邇夜須毘売}','記紀','土を司る女神。','https://ja.wikipedia.org/wiki/ハニヤスビコ・ハニヤスビメ','Wikipedia',true,now()),
('tamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{玉依毘売}','記紀','海神の娘で神武天皇の母とされる女神。','https://ja.wikipedia.org/wiki/タマヨリビメ_(神武天皇の母)','Wikipedia',true,now()),
('amenofutodama','天太玉命','あめのふとだまのみこと','kami','天津神','{布刀玉命}','記紀','忌部氏の祖神。祭祀を司る神。','https://ja.wikipedia.org/wiki/フトダマ','Wikipedia',true,now()),
('hikohohodemi','彦火火出見尊','ひこほほでみのみこと','kami','天津神','{山幸彦,火遠理命}','記紀','瓊瓊杵尊の子。海幸山幸神話の山幸彦。','https://ja.wikipedia.org/wiki/ホオリ','Wikipedia',true,now()),
('samukawahiko','寒川比古命','さむかわひこのみこと','kami','国津神','{}','社伝','寒川神社の男神。相模国の守護神。','https://ja.wikipedia.org/wiki/寒川神社','Wikipedia',true,now()),
('samukawahime','寒川比女命','さむかわひめのみこと','kami','国津神','{}','社伝','寒川神社の女神。相模国の守護神。','https://ja.wikipedia.org/wiki/寒川神社','Wikipedia',true,now()),
('masakado','平将門','たいらのまさかど','kami','御霊','{将門公}','史実・伝承','平安中期の武将。神田明神に御霊として祀られる。','https://ja.wikipedia.org/wiki/平将門','Wikipedia',true,now()),
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{お地蔵さま}','仏教','六道で衆生を救う菩薩。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{十一面観世音菩薩}','仏教','十一の顔を持ち衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ② 新規神仏の司るご利益
-- ============================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','yakubarai'))
or (d.slug='yamatotakeru' and g.slug in ('shobu','yakubarai','shusse','kaiun'))
or (d.slug='toyouke' and g.slug in ('suisan_noko','shobai','kanai_anzen'))
or (d.slug='oyamatsumi' and g.slug in ('shobai','kaiun','tabi_anzen'))
or (d.slug='oyamakui' and g.slug in ('shobai','yakubarai','kaiun'))
or (d.slug='kushinadahime' and g.slug in ('enmusubi','renai','kanai_anzen'))
or (d.slug='kagutsuchi' and g.slug in ('yakubarai','majo_kekkai'))
or (d.slug='haniyasuhime' and g.slug in ('suisan_noko','anzan'))
or (d.slug='tamayorihime' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='amenofutodama' and g.slug in ('shobai','kaiun','shigoto'))
or (d.slug='hikohohodemi' and g.slug in ('kaiun','suisan_noko','tabi_anzen'))
or (d.slug='samukawahiko' and g.slug in ('yakubarai','majo_kekkai','kaiun'))
or (d.slug='samukawahime' and g.slug in ('yakubarai','majo_kekkai','kaiun'))
or (d.slug='masakado' and g.slug in ('shobu','yakubarai','shusse'))
or (d.slug='jizo_bosatsu' and g.slug in ('kosodate','choju','byoki_heyu'))
or (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','enmusubi','kaiun'))
on conflict do nothing;

-- ============================================================
-- ③ 社寺
-- ============================================================
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values

-- 茨城県
('kasama-inari','笠間稲荷神社','かさまいなりじんじゃ','shrine','旧県社・別表神社',  '茨城県','笠間市','茨城県笠間市笠間1',36.386083,140.254111,651,null,'http://www.kasama.or.jp/','日本三大稲荷の一つ。五穀豊穣・商売繁盛の神。','https://ja.wikipedia.org/wiki/笠間稲荷神社','Wikipedia',true,now()),
('oarai-isosaki','大洗磯前神社','おおあらいいそさきじんじゃ','shrine','式内社（名神大社）・旧国幣中社','茨城県','東茨城郡大洗町','茨城県東茨城郡大洗町磯浜町6890',36.31583,140.587444,856,null,'https://www.oarai-isosakijinja.net/','海上の鳥居で知られる大己貴命を祀る古社。','https://ja.wikipedia.org/wiki/大洗磯前神社','Wikipedia',true,now()),
('sakatsura-isosaki','酒列磯前神社','さかつらいそさきじんじゃ','shrine','式内社（名神大社）・旧県社','茨城県','ひたちなか市','茨城県ひたちなか市磯崎町4607-2',36.382306,140.623694,856,null,'https://sakatura.org/','大洗磯前神社と対をなす少彦名命を祀る古社。','https://ja.wikipedia.org/wiki/酒列磯前神社','Wikipedia',true,now()),
('tsukubasan-jinja','筑波山神社','つくばさんじんじゃ','shrine','式内社（名神大社）論社・旧県社','茨城県','つくば市','茨城県つくば市筑波1番地',36.213667,140.101306,null,null,'https://tsukubasanjinja.jp/','筑波山を神体とし伊弉諾・伊弉冊を祀る古社。','https://ja.wikipedia.org/wiki/筑波山神社','Wikipedia',true,now()),
('mito-toshogu','水戸東照宮','みととうしょうぐう','shrine','旧県社','茨城県','水戸市','茨城県水戸市宮町2-5-13',36.37250,140.47333,1621,null,'https://gongensan-mito-toshogu.jp/','徳川家康と水戸藩祖頼房を祀る東照宮。','https://ja.wikipedia.org/wiki/水戸東照宮','Wikipedia',true,now()),

-- 栃木県
('nikko-futarasan','日光二荒山神社','にっこうふたらさんじんじゃ','shrine','式内社（名神大社）・下野国一宮・旧国幣中社','栃木県','日光市','栃木県日光市山内2307',36.758417,139.59639,767,null,'http://www.futarasan.jp/','日光の二荒山大神を祀る世界遺産の古社。','https://ja.wikipedia.org/wiki/日光二荒山神社','Wikipedia',true,now()),
('nikko-rinnoji','日光山輪王寺','にっこうさんりんのうじ','temple','天台宗（門跡寺院）','栃木県','日光市','栃木県日光市山内2300',36.754389,139.601139,766,'阿弥陀如来・千手観音・馬頭観音（三仏）','https://www.rinnoji.or.jp/','勝道上人開山。日光の世界遺産を構成する門跡寺院。','https://ja.wikipedia.org/wiki/輪王寺','Wikipedia',true,now()),
('nikko-chuzenji','日光山中禅寺','にっこうさんちゅうぜんじ','temple','天台宗','栃木県','日光市','栃木県日光市中宮祠2482',36.730917,139.49167,784,'十一面千手観世音菩薩（立木観音）','https://www.rinnoji.or.jp/history/temple/chuzenji/','中禅寺湖畔の立木観音で知られる輪王寺別院。','https://ja.wikipedia.org/wiki/中禅寺_(日光市)','Wikipedia',true,now()),
('furumine-jinja','古峯神社','ふるみねじんじゃ','shrine','旧郷社','栃木県','鹿沼市','栃木県鹿沼市草久3027',36.654889,139.526472,null,null,'http://www.furumine-jinjya.jp/','天狗の社として知られる日本武尊を祀る神社。','https://ja.wikipedia.org/wiki/古峯神社','Wikipedia',true,now()),

-- 群馬県
('haruna-jinja','榛名神社','はるなじんじゃ','shrine','式内社・旧県社','群馬県','高崎市','群馬県高崎市榛名山町849',36.45861,138.85222,586,null,'https://www.haruna.or.jp/','榛名山の岩肌に鎮座する火産霊神・埴山姫神の古社。','https://ja.wikipedia.org/wiki/榛名神社','Wikipedia',true,now()),
('nukisaki-jinja','一之宮貫前神社','いちのみやぬきさきじんじゃ','shrine','式内社（名神大社）・上野国一宮・旧国幣中社','群馬県','富岡市','群馬県富岡市一ノ宮1535',36.2551528,138.8576528,534,null,'http://www.nukisaki.or.jp/','石段を下って参拝する珍しい上野国一宮。','https://ja.wikipedia.org/wiki/貫前神社','Wikipedia',true,now()),
('myogi-jinja','妙義神社','みょうぎじんじゃ','shrine','旧県社','群馬県','富岡市','群馬県富岡市妙義町妙義6番地',36.300472,138.762389,537,null,'https://myougi.jp/','妙義山麓に鎮座する日本武尊らを祀る古社。','https://ja.wikipedia.org/wiki/妙義神社','Wikipedia',true,now()),
('ikaho-jinja','伊香保神社','いかほじんじゃ','shrine','式内社論社・旧県社','群馬県','渋川市','群馬県渋川市伊香保町伊香保2',36.495917,138.91583,825,null,null,'伊香保温泉を守護する大己貴命・少彦名命の神社。','https://ja.wikipedia.org/wiki/伊香保神社','Wikipedia',true,now()),
('raiden-jinja-itakura','雷電神社','らいでんじんじゃ','shrine','旧郷社','群馬県','邑楽郡板倉町','群馬県邑楽郡板倉町板倉2334',36.227528,139.607833,598,null,'http://www.raiden.or.jp','関東一円の雷電神社の総本宮とされる古社。','https://ja.wikipedia.org/wiki/雷電神社_(板倉町)','Wikipedia',true,now()),

-- 埼玉県
('mitsumine-jinja','三峯神社','みつみねじんじゃ','shrine','旧県社・別表神社','埼玉県','秩父市','埼玉県秩父市三峰298-1',35.9254306,138.9303972,null,null,'https://www.mitsuminejinja.or.jp/','秩父の山中に鎮座する伊弉諾・伊弉冊を祀る古社。','https://ja.wikipedia.org/wiki/三峯神社','Wikipedia',true,now()),
('chichibu-jinja','秩父神社','ちちぶじんじゃ','shrine','式内社・知知夫国一宮・旧県社','埼玉県','秩父市','埼玉県秩父市番場町1-1',35.9976028,139.0841278,null,null,'https://www.chichibu-jinja.or.jp/','秩父夜祭で知られる知知夫国一宮。','https://ja.wikipedia.org/wiki/秩父神社','Wikipedia',true,now()),
('hikawa-nyotai','氷川女体神社','ひかわにょたいじんじゃ','shrine','式内社論社・旧郷社','埼玉県','さいたま市','埼玉県さいたま市緑区宮本2丁目17-1',35.88694,139.693778,null,null,null,'武蔵一宮氷川神社と対をなす奇稲田姫命の古社。','https://ja.wikipedia.org/wiki/氷川女体神社','Wikipedia',true,now()),
('kawagoe-hikawa','川越氷川神社','かわごえひかわじんじゃ','shrine','旧県社','埼玉県','川越市','埼玉県川越市宮下町2-11-3',35.927500,139.488528,541,null,'https://www.kawagoehikawa.jp/','縁結びで知られる川越総鎮守。','https://ja.wikipedia.org/wiki/川越氷川神社','Wikipedia',true,now()),
('washinomiya-jinja','鷲宮神社','わしのみやじんじゃ','shrine','旧県社','埼玉県','久喜市','埼玉県久喜市鷲宮一丁目6番1号',36.10000,139.65500,null,null,'http://www.washinomiyajinja.or.jp/','関東最古とも伝わる天穂日命らを祀る古社。','https://ja.wikipedia.org/wiki/鷲宮神社','Wikipedia',true,now()),
('kawagoe-kitain','喜多院','きたいん','temple','天台宗','埼玉県','川越市','埼玉県川越市小仙波町1-20-1',35.91750,139.488972,830,'阿弥陀如来','https://kitain.net/','川越大師と呼ばれる徳川家ゆかりの天台宗寺院。','https://ja.wikipedia.org/wiki/喜多院','Wikipedia',true,now()),

-- 千葉県
('katori-jingu','香取神宮','かとりじんぐう','shrine','式内社（名神大社）・下総国一宮・旧官幣大社','千葉県','香取市','千葉県香取市香取1697',35.8861194,140.5286861,null,null,null,'経津主大神を祀る東国三社の一。下総国一宮。','https://ja.wikipedia.org/wiki/香取神宮','Wikipedia',true,now()),
('tamasaki-jinja','玉前神社','たまさきじんじゃ','shrine','式内社（名神大社）・上総国一宮・旧国幣中社','千葉県','長生郡一宮町','千葉県長生郡一宮町一宮3048',35.3760972,140.3604833,null,null,'http://www.tamasaki.org/','玉依姫命を祀る上総国一宮。','https://ja.wikipedia.org/wiki/玉前神社','Wikipedia',true,now()),
('awa-jinja','安房神社','あわじんじゃ','shrine','式内社（名神大社）・安房国一宮・旧官幣大社','千葉県','館山市','千葉県館山市大神宮589',34.9224444,139.8367361,null,null,'http://www.awajinjya.org/','天太玉命を祀る安房国一宮。','https://ja.wikipedia.org/wiki/安房神社','Wikipedia',true,now()),
('tanjoji-kamogawa','誕生寺','たんじょうじ','temple','日蓮宗（大本山）','千葉県','鴨川市','千葉県鴨川市小湊183',35.117417,140.19833,1276,'十界本尊','http://www.tanjoh-ji.jp/','日蓮聖人の誕生地に建つ日蓮宗大本山。','https://ja.wikipedia.org/wiki/誕生寺_(鴨川市)','Wikipedia',true,now()),

-- 東京都
('kanda-myojin','神田明神','かんだみょうじん','shrine','旧府社・別表神社','東京都','千代田区','東京都千代田区外神田2丁目16番2号',35.702028,139.767889,730,null,'https://www.kandamyoujin.or.jp/','江戸総鎮守。大己貴命・少彦名命・平将門を祀る。','https://ja.wikipedia.org/wiki/神田明神','Wikipedia',true,now()),
('nezu-jinja','根津神社','ねづじんじゃ','shrine','旧府社・別表神社','東京都','文京区','東京都文京区根津一丁目28番9号',35.7202139,139.7606944,null,null,'https://nedujinja.or.jp/','つつじと権現造社殿で知られる東京十社の一。','https://ja.wikipedia.org/wiki/根津神社','Wikipedia',true,now()),
('hie-jinja-chiyoda','日枝神社','ひえじんじゃ','shrine','旧官幣大社・別表神社','東京都','千代田区','東京都千代田区永田町2丁目10番5号',35.67472,139.739583,1478,null,'https://www.hiejinja.net/','山王祭で知られる大山咋神を祀る江戸三大祭の社。','https://ja.wikipedia.org/wiki/日枝神社_(千代田区)','Wikipedia',true,now()),
('tomioka-hachimangu','富岡八幡宮','とみおかはちまんぐう','shrine','旧府社・別表神社','東京都','江東区','東京都江東区富岡一丁目20番3号',35.67194,139.799611,1627,null,'http://www.tomiokahachimangu.or.jp/','深川八幡祭で知られる江戸最大の八幡宮。','https://ja.wikipedia.org/wiki/富岡八幡宮','Wikipedia',true,now()),
('yasukuni-jinja','靖国神社','やすくにじんじゃ','shrine','旧別格官幣社・別表神社','東京都','千代田区','東京都千代田区九段北3丁目1番1号',35.6939583,139.7426917,1869,null,null,'明治以降の戦没者を祀る東京・九段の神社。','https://ja.wikipedia.org/wiki/靖国神社','Wikipedia',true,now()),
('asakusa-jinja','浅草神社','あさくさじんじゃ','shrine','旧郷社','東京都','台東区','東京都台東区浅草二丁目3番1号',35.715139,139.797444,628,null,'https://www.asakusajinja.jp/','三社祭で知られる浅草寺の隣に鎮座する神社。','https://ja.wikipedia.org/wiki/浅草神社','Wikipedia',true,now()),
('okunitama-jinja','大國魂神社','おおくにたまじんじゃ','shrine','式内社・武蔵国総社・旧官幣小社','東京都','府中市','東京都府中市宮町3-1',35.6674639,139.4789417,111,null,'https://www.ookunitamajinja.or.jp/','くらやみ祭で知られる武蔵国総社。','https://ja.wikipedia.org/wiki/大國魂神社','Wikipedia',true,now()),
('zojoji','増上寺','ぞうじょうじ','temple','浄土宗（大本山）','東京都','港区','東京都港区芝公園4丁目7番35号',35.657417,139.748278,1393,'阿弥陀如来','https://www.zojoji.or.jp/','徳川将軍家の菩提寺である浄土宗大本山。','https://ja.wikipedia.org/wiki/増上寺','Wikipedia',true,now()),
('kaneiji','寛永寺','かんえいじ','temple','天台宗（関東総本山）','東京都','台東区','東京都台東区上野桜木一丁目14番11号',35.72139,139.774306,1625,'薬師如来','https://kaneiji.jp/','徳川将軍家の祈願寺・菩提寺。上野の天台宗総本山。','https://ja.wikipedia.org/wiki/寛永寺','Wikipedia',true,now()),
('takaosan-yakuoin','高尾山薬王院','たかおさんやくおういん','temple','真言宗智山派（大本山）','東京都','八王子市','東京都八王子市高尾町2177',35.625861,139.250222,744,'薬師如来・飯縄権現','https://www.takaosan.or.jp/','高尾山頂近くに建つ真言宗智山派大本山。','https://ja.wikipedia.org/wiki/高尾山薬王院','Wikipedia',true,now()),

-- 神奈川県
('samukawa-jinja','寒川神社','さむかわじんじゃ','shrine','式内社（名神大社）・相模国一宮・旧国幣中社','神奈川県','高座郡寒川町','神奈川県高座郡寒川町宮山3916',35.3796389,139.3833333,null,null,'https://samukawajinjya.jp/','八方除で知られる相模国一宮。','https://ja.wikipedia.org/wiki/寒川神社','Wikipedia',true,now()),
('oyama-afuri','大山阿夫利神社','おおやまあふりじんじゃ','shrine','式内社論社・旧県社','神奈川県','伊勢原市','神奈川県伊勢原市大山355',35.44056,139.231056,null,null,'http://www.afuri.or.jp/','大山山頂に本社を置く大山祇神を祀る古社。','https://ja.wikipedia.org/wiki/大山阿夫利神社','Wikipedia',true,now()),
('enoshima-jinja','江島神社','えのしまじんじゃ','shrine','旧県社','神奈川県','藤沢市','神奈川県藤沢市江の島2-3-8',35.300361,139.479611,552,null,'http://www.enoshimajinja.or.jp/','江の島に鎮座する宗像三女神を祀る古社。','https://ja.wikipedia.org/wiki/江島神社','Wikipedia',true,now()),
('hakone-jinja','箱根神社','はこねじんじゃ','shrine','旧国幣小社・別表神社','神奈川県','足柄下郡箱根町','神奈川県足柄下郡箱根町元箱根80-1',35.204750,139.025361,null,null,'https://hakonejinja.or.jp/','芦ノ湖畔に鎮座する箱根大神を祀る古社。','https://ja.wikipedia.org/wiki/箱根神社','Wikipedia',true,now()),
('kotokuin','高徳院','こうとくいん','temple','浄土宗','神奈川県','鎌倉市','神奈川県鎌倉市長谷4丁目2番28号',35.316722,139.5361472,null,'銅造阿弥陀如来坐像（鎌倉大仏・国宝）','https://www.kotoku-in.jp/','鎌倉大仏で知られる浄土宗の寺院。','https://ja.wikipedia.org/wiki/高徳院','Wikipedia',true,now()),
('hasedera-kamakura','長谷寺','はせでら','temple','浄土宗系単立','神奈川県','鎌倉市','神奈川県鎌倉市長谷3丁目11番2号',35.312472,139.532944,736,'十一面観世音菩薩','https://www.hasedera.jp/','長谷観音とあじさいで知られる鎌倉の古刹。','https://ja.wikipedia.org/wiki/長谷寺_(鎌倉市)','Wikipedia',true,now()),
('kenchoji','建長寺','けんちょうじ','temple','臨済宗建長寺派（大本山）','神奈川県','鎌倉市','神奈川県鎌倉市山ノ内8',35.3317889,139.5553472,1253,'地蔵菩薩','https://www.kenchoji.com/','鎌倉五山第一位の臨済宗大本山。','https://ja.wikipedia.org/wiki/建長寺','Wikipedia',true,now()),
('engakuji','円覚寺','えんがくじ','temple','臨済宗円覚寺派（大本山）','神奈川県','鎌倉市','神奈川県鎌倉市山ノ内409',35.3377028,139.5474972,1282,'宝冠釈迦如来','https://www.engakuji.or.jp/','鎌倉五山第二位の臨済宗大本山。','https://ja.wikipedia.org/wiki/円覚寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ④ 御祭神/本尊の紐付け
-- ============================================================
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
-- 茨城
   (t.slug='kasama-inari' and d.slug in ('ukanomitama'))
or (t.slug='oarai-isosaki' and d.slug in ('okuninushi'))
or (t.slug='sakatsura-isosaki' and d.slug in ('sukunabikona'))
or (t.slug='tsukubasan-jinja' and d.slug in ('izanagi','izanami'))
or (t.slug='mito-toshogu' and d.slug in ('ieyasu'))
-- 栃木
or (t.slug='nikko-futarasan' and d.slug in ('okuninushi'))
or (t.slug='nikko-rinnoji' and d.slug in ('amida_nyorai','senju_kannon'))
or (t.slug='nikko-chuzenji' and d.slug in ('juichimen_kannon'))
or (t.slug='furumine-jinja' and d.slug in ('yamatotakeru'))
-- 群馬
or (t.slug='haruna-jinja' and d.slug in ('kagutsuchi','haniyasuhime'))
or (t.slug='nukisaki-jinja' and d.slug in ('futsunushi'))
or (t.slug='myogi-jinja' and d.slug in ('yamatotakeru','toyouke','michizane'))
or (t.slug='ikaho-jinja' and d.slug in ('okuninushi','sukunabikona'))
or (t.slug='raiden-jinja-itakura' and d.slug in ('takemikazuchi'))
-- 埼玉
or (t.slug='mitsumine-jinja' and d.slug in ('izanagi','izanami'))
or (t.slug='chichibu-jinja' and d.slug in ('michizane'))
or (t.slug='hikawa-nyotai' and d.slug in ('kushinadahime'))
or (t.slug='kawagoe-hikawa' and d.slug in ('susanoo','kushinadahime','okuninushi'))
or (t.slug='washinomiya-jinja' and d.slug in ('okuninushi'))
or (t.slug='kawagoe-kitain' and d.slug in ('amida_nyorai'))
-- 千葉
or (t.slug='katori-jingu' and d.slug in ('futsunushi'))
or (t.slug='tamasaki-jinja' and d.slug in ('tamayorihime'))
or (t.slug='awa-jinja' and d.slug in ('amenofutodama'))
or (t.slug='tanjoji-kamogawa' and d.slug in ('shaka_nyorai'))
-- 東京
or (t.slug='kanda-myojin' and d.slug in ('okuninushi','sukunabikona','masakado'))
or (t.slug='nezu-jinja' and d.slug in ('susanoo','okuninushi','hachiman'))
or (t.slug='hie-jinja-chiyoda' and d.slug in ('oyamakui'))
or (t.slug='tomioka-hachimangu' and d.slug in ('hachiman'))
or (t.slug='asakusa-jinja' and d.slug in ('amaterasu'))
or (t.slug='okunitama-jinja' and d.slug in ('okuninushi'))
or (t.slug='zojoji' and d.slug in ('amida_nyorai'))
or (t.slug='kaneiji' and d.slug in ('yakushi_nyorai'))
or (t.slug='takaosan-yakuoin' and d.slug in ('yakushi_nyorai'))
-- 神奈川
or (t.slug='samukawa-jinja' and d.slug in ('samukawahiko','samukawahime'))
or (t.slug='oyama-afuri' and d.slug in ('oyamatsumi'))
or (t.slug='enoshima-jinja' and d.slug in ('ichikishima'))
or (t.slug='hakone-jinja' and d.slug in ('ninigi','konohanasakuya','hikohohodemi'))
or (t.slug='kotokuin' and d.slug in ('amida_nyorai'))
or (t.slug='hasedera-kamakura' and d.slug in ('juichimen_kannon'))
or (t.slug='kenchoji' and d.slug in ('jizo_bosatsu'))
or (t.slug='engakuji' and d.slug in ('shaka_nyorai'))
on conflict do nothing;
