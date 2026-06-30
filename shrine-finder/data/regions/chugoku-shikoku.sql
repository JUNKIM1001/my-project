-- 御朱印ナビ 社寺データ：中国・四国地方
-- 担当県: 鳥取・島根・岡山・広島・山口・徳島・香川・愛媛・高知
-- 全件 ja.wikipedia.org の infobox で裏取り（住所・十進座標・御祭神/本尊・創建・公式URL）。
-- 既存除外: izumo-taisha, itsukushima-jinja, kotohira-gu（=出雲大社・嚴島神社・金刀比羅宮）。
-- 仕様書 ①〜④ の順で追記。temple_shrine_goriyaku は親側で導出するため作成しない。

-- ============================================================
-- ① 新規神仏（既存14柱＋拡張分に無いものだけ）
-- ============================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('hakuto_kami','白兎神','はくとのかみ','kami','国津神','{因幡の白兎}','記紀','因幡の白兎を神格化。皮膚病・縁結びの神。','https://ja.wikipedia.org/wiki/白兎神社','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{えびす}','記紀','大国主の子。託宣・漁業・商売の神。えびす神と同一視。','https://ja.wikipedia.org/wiki/事代主','Wikipedia',true,now()),
('mihotsuhime','三穂津姫命','みほつひめのみこと','kami','天津神','{}','記紀','高皇産霊神の娘で大国主の后とされる。','https://ja.wikipedia.org/wiki/ミホツヒメ','Wikipedia',true,now()),
('kumano_okami','熊野大神','くまののおおかみ','kami','国津神','{櫛御気野命,スサノオ}','記紀','出雲・熊野大社の主祭神。櫛御気野命でスサノオの別名とされる。','https://ja.wikipedia.org/wiki/熊野大社','Wikipedia',true,now()),
('okibitsuhiko','大吉備津彦命','おおきびつひこのみこと','kami','天津神','{五十狭芹彦命}','記紀','吉備平定の四道将軍。桃太郎伝説の元とされる。','https://ja.wikipedia.org/wiki/吉備津彦命','Wikipedia',true,now()),
('takeuchi_sukune','武内宿禰命','たけうちのすくねのみこと','kami','人物神','{}','記紀','五代の天皇に仕えたとされる長寿の忠臣。延命・武運の神。','https://ja.wikipedia.org/wiki/武内宿禰','Wikipedia',true,now()),
('umashimaji','宇摩志麻遅命','うましまぢのみこと','kami','天津神','{}','記紀','物部氏の祖神。鎮魂・武の神。','https://ja.wikipedia.org/wiki/ウマシマヂ','Wikipedia',true,now()),
('kushinadahime','櫛稲田姫','くしなだひめ','kami','国津神','{奇稲田姫}','記紀','スサノオの后。八岐大蛇神話の姫神。縁結びの神。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('ooasahiko','大麻比古神','おおあさひこのかみ','kami','天津神','{}','記紀','阿波忌部氏の祖神。麻・農工・交通安全の神。','https://ja.wikipedia.org/wiki/大麻比古神社','Wikipedia',true,now()),
('ooyamatsumi','大山積神','おおやまつみのかみ','kami','国津神','{大山祇神,和多志大神}','記紀','山と海を司る神。武人の守護神として信仰。','https://ja.wikipedia.org/wiki/オオヤマツミ','Wikipedia',true,now()),
('ishizuchihiko','石鎚毘古命','いしづちひこのみこと','kami','国津神','{石鎚大神}','記紀','西日本最高峰・石鎚山の山岳信仰の神。','https://ja.wikipedia.org/wiki/石鎚神社','Wikipedia',true,now()),
('ajisukitakahikone','味鋤高彦根神','あじすきたかひこねのかみ','kami','国津神','{}','記紀','大国主の子。農耕・雷の神。','https://ja.wikipedia.org/wiki/アヂスキタカヒコネ','Wikipedia',true,now()),
('hitokotonushi','一言主神','ひとことぬしのかみ','kami','国津神','{}','記紀','一言の願いを聞き届けるとされる託宣の神。','https://ja.wikipedia.org/wiki/ヒトコトヌシ','Wikipedia',true,now()),
('monju_bosatsu','文殊菩薩','もんじゅぼさつ','buddha','菩薩','{}','大乗仏教','智慧を司る菩薩。学業成就の信仰を集める。','https://ja.wikipedia.org/wiki/文殊菩薩','Wikipedia',true,now()),
('antoku_tenno','安徳天皇','あんとくてんのう','kami','人物神','{}','史実','壇ノ浦で入水した幼帝。赤間神宮に祀られる。','https://ja.wikipedia.org/wiki/安徳天皇','Wikipedia',true,now()),
('yoshida_shoin','吉田松陰','よしだしょういん','kami','人物神','{吉田寅次郎}','史実','幕末の思想家・教育者。学問の神として松陰神社に祀られる。','https://ja.wikipedia.org/wiki/吉田松陰','Wikipedia',true,now()),
('tamura_okami','田村大神','たむらおおかみ','kami','国津神','{倭迹迹日百襲姫命}','記紀','讃岐国一宮・田村神社の主祭神。五柱の総称。','https://ja.wikipedia.org/wiki/田村神社_(高松市)','Wikipedia',true,now()),
('iyozuhiko','伊豫豆比古命','いよづひこのみこと','kami','国津神','{}','記紀','伊予の地主神。松山・椿神社の主祭神。','https://ja.wikipedia.org/wiki/伊豫豆比古命神社','Wikipedia',true,now()),
('akihayatama','飽速玉男命','あきはやたまおのみこと','kami','国津神','{}','記紀','安芸国造の祖神。交通安全の神として信仰。','https://ja.wikipedia.org/wiki/速谷神社','Wikipedia',true,now()),
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','大乗仏教','無限の智慧と福徳を蔵する菩薩。記憶・知恵の信仰。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now()),
('bishamonten','毘沙門天','びしゃもんてん','buddha','天部','{多聞天}','大乗仏教','四天王の一。武運・財福を授ける守護神。','https://ja.wikipedia.org/wiki/毘沙門天','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{}','密教','密教の根本仏。宇宙の真理を体現する。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now()),
('saijo_inari','最上位経王大菩薩','さいじょういきょうおうだいぼさつ','buddha','菩薩','{最上稲荷}','日蓮宗','日蓮宗の祈祷本尊として祀られる稲荷の神仏。','https://ja.wikipedia.org/wiki/最上稲荷','Wikipedia',true,now()),
('shitori_takehazuchi','建葉槌命','たけはづちのみこと','kami','天津神','{倭文神}','記紀','機織りの神。星神・武の神を平定した神とされる。','https://ja.wikipedia.org/wiki/タケハヅチ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ② 新規神仏の司るご利益（30種から選択）
-- ============================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='hakuto_kami' and g.slug in ('enmusubi','renai','byoki_heyu'))
or (d.slug='kotoshironushi' and g.slug in ('shobai','suisan_noko','kaiun'))
or (d.slug='mihotsuhime' and g.slug in ('enmusubi','kanai_anzen'))
or (d.slug='kumano_okami' and g.slug in ('yakubarai','kaiun','enmusubi'))
or (d.slug='okibitsuhiko' and g.slug in ('yakubarai','shobu','kaiun'))
or (d.slug='takeuchi_sukune' and g.slug in ('choju','shusse','shigoto'))
or (d.slug='umashimaji' and g.slug in ('yakubarai','shobu','byoki_heyu'))
or (d.slug='kushinadahime' and g.slug in ('enmusubi','renai','anzan'))
or (d.slug='ooasahiko' and g.slug in ('kotsu_anzen','shobai','kaiun'))
or (d.slug='ooyamatsumi' and g.slug in ('shobu','kaijo_anzen','shusse'))
or (d.slug='ishizuchihiko' and g.slug in ('yakubarai','shobu','kaiun'))
or (d.slug='ajisukitakahikone' and g.slug in ('suisan_noko','mizu_amagoi','shobai'))
or (d.slug='hitokotonushi' and g.slug in ('jouju','kaiun','enmusubi'))
or (d.slug='monju_bosatsu' and g.slug in ('gakugyo','gakumon','shusse'))
or (d.slug='antoku_tenno' and g.slug in ('yakubarai','kaiun'))
or (d.slug='yoshida_shoin' and g.slug in ('gakugyo','gakumon','shusse'))
or (d.slug='tamura_okami' and g.slug in ('kaiun','enmusubi','kanai_anzen'))
or (d.slug='iyozuhiko' and g.slug in ('kaiun','shobai','enmusubi'))
or (d.slug='akihayatama' and g.slug in ('kotsu_anzen','tabi_anzen','kaiun'))
or (d.slug='kokuzo_bosatsu' and g.slug in ('gakugyo','gakumon','kaiun'))
or (d.slug='bishamonten' and g.slug in ('shobu','kinun','shusse'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='saijo_inari' and g.slug in ('shobai','kinun','kaiun'))
or (d.slug='shitori_takehazuchi' and g.slug in ('enmusubi','shobu','kaiun'))
on conflict do nothing;

-- ============================================================
-- ③ 社寺
-- ============================================================
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- 鳥取県
('hakuto-jinja','白兎神社','はくとじんじゃ','shrine','旧村社','鳥取県','鳥取市','鳥取県鳥取市白兎603',35.52417,134.115417,null,null,'https://hakutojinja.jp/','因幡の白兎神話の舞台。皮膚病平癒・縁結びの社。','https://ja.wikipedia.org/wiki/白兎神社','Wikipedia',true,now()),
('mitokusan-sanbutsuji','三徳山三佛寺','みとくさんさんぶつじ','temple','天台宗','鳥取県','三朝町','鳥取県東伯郡三朝町三徳1010',35.399306,133.955750,849,'釈迦如来・阿弥陀如来・大日如来','https://mitokusan.jp/','断崖に建つ国宝・投入堂で知られる山岳寺院。','https://ja.wikipedia.org/wiki/三佛寺','Wikipedia',true,now()),
('ube-jinja','宇倍神社','うべじんじゃ','shrine','因幡国一宮（旧国幣中社）','鳥取県','鳥取市','鳥取県鳥取市国府町宮下651',35.48083,134.26889,648,null,'http://www.ubejinja.or.jp/','武内宿禰命を祀る因幡国一宮。長寿・金運の社。','https://ja.wikipedia.org/wiki/宇倍神社','Wikipedia',true,now()),
('shitori-jinja-yurihama','倭文神社','しとりじんじゃ','shrine','伯耆国一宮（旧国幣小社）','鳥取県','湯梨浜町','鳥取県東伯郡湯梨浜町大字宮内754',35.4903722,133.9029667,null,null,null,'建葉槌命を祀る伯耆国一宮。機織り・安産の社。','https://ja.wikipedia.org/wiki/倭文神社_(湯梨浜町)','Wikipedia',true,now()),
('ogamiyama-jinja','大神山神社','おおがみやまじんじゃ','shrine','旧国幣小社','鳥取県','米子市','鳥取県米子市尾高1025',35.41750,133.40611,null,null,'https://www.oogamiyama.or.jp/','大山の山岳信仰の中心。大己貴神を祀る。','https://ja.wikipedia.org/wiki/大神山神社','Wikipedia',true,now()),
-- 島根県
('miho-jinja','美保神社','みほじんじゃ','shrine','旧国幣中社','島根県','松江市','島根県松江市美保関町美保関608',35.5623111,133.3060472,null,null,'http://mihojinja.or.jp/','事代主神を祀るえびす社の総本社。漁業・商売の神。','https://ja.wikipedia.org/wiki/美保神社','Wikipedia',true,now()),
('kumano-taisha-shimane','熊野大社','くまのたいしゃ','shrine','出雲国一宮（旧国幣大社）','島根県','松江市','島根県松江市八雲町熊野2451',35.373194,133.070528,null,null,'http://www.kumanotaisha.or.jp/','火の発祥の社とされる出雲国一宮。','https://ja.wikipedia.org/wiki/熊野大社','Wikipedia',true,now()),
('hinomisaki-jinja','日御碕神社','ひのみさきじんじゃ','shrine','旧国幣小社','島根県','出雲市','島根県出雲市大社町日御碕455',35.429556,132.629306,null,null,null,'日沈宮と神の宮からなる朱塗りの社。','https://ja.wikipedia.org/wiki/日御碕神社','Wikipedia',true,now()),
('susa-jinja-izumo','須佐神社','すさじんじゃ','shrine','旧県社','島根県','出雲市','島根県出雲市佐田町須佐730',35.234694,132.736861,null,null,'http://www.susa-jinja.jp/','スサノオ終焉の地と伝わる古社。','https://ja.wikipedia.org/wiki/須佐神社_(出雲市)','Wikipedia',true,now()),
('yaegaki-jinja','八重垣神社','やえがきじんじゃ','shrine','旧県社','島根県','松江市','島根県松江市佐草町227',35.429028,133.073694,null,null,'https://yaegakijinja.or.jp/','スサノオと櫛稲田姫を祀る縁結びの社。鏡の池占いで有名。','https://ja.wikipedia.org/wiki/八重垣神社','Wikipedia',true,now()),
('mononobe-jinja-shimane','物部神社','もののべじんじゃ','shrine','石見国一宮（旧国幣小社）','島根県','大田市','島根県大田市川合町川合1545',35.15500,132.513472,514,null,'http://www.mononobe-jinja.jp/','物部氏の祖・宇摩志麻遅命を祀る石見国一宮。','https://ja.wikipedia.org/wiki/物部神社_(大田市)','Wikipedia',true,now()),
('gakuenji','鰐淵寺','がくえんじ','temple','天台宗','島根県','出雲市','島根県出雲市別所町148',35.423250,132.749389,594,'千手観音・薬師如来',null,'弁慶ゆかりと伝わる天台宗の古刹。紅葉の名所。','https://ja.wikipedia.org/wiki/鰐淵寺','Wikipedia',true,now()),
-- 岡山県
('kibitsu-jinja','吉備津神社','きびつじんじゃ','shrine','備中国一宮（旧官幣中社）','岡山県','岡山市','岡山県岡山市北区吉備津931',34.670667,133.850611,null,null,'https://kibitujinja.com/','大吉備津彦命を祀る備中国一宮。国宝の本殿と回廊。','https://ja.wikipedia.org/wiki/吉備津神社','Wikipedia',true,now()),
('kibitsuhiko-jinja','吉備津彦神社','きびつひこじんじゃ','shrine','備前国一宮（旧国幣小社）','岡山県','岡山市','岡山県岡山市北区一宮1043',34.6767528,133.863833,null,null,'http://www.kibitsuhiko.or.jp','吉備の中山に鎮座する備前国一宮。朝日の宮。','https://ja.wikipedia.org/wiki/吉備津彦神社','Wikipedia',true,now()),
('saijo-inari','最上稲荷','さいじょういなり','temple','日蓮宗','岡山県','岡山市','岡山県岡山市北区高松稲荷712',34.7089556,133.8334111,752,'久遠実成本師釈迦牟尼仏・最上位経王大菩薩','http://www.inari.ne.jp/mb/','日本三大稲荷の一。神仏習合を残す日蓮宗寺院。','https://ja.wikipedia.org/wiki/最上稲荷','Wikipedia',true,now()),
('yugasan-jinja-honguu','由加神社本宮','ゆがじんじゃほんぐう','shrine','旧郷社','岡山県','倉敷市','岡山県倉敷市児島由加2852',34.505917,133.851056,733,null,'https://yugasan.or.jp/','瑜伽大権現を祀る厄除けの社。金刀比羅宮との両参り信仰。','https://ja.wikipedia.org/wiki/由加神社本宮','Wikipedia',true,now()),
('saidaiji-okayama','西大寺','さいだいじ','temple','高野山真言宗','岡山県','岡山市','岡山県岡山市東区西大寺中三丁目8番8号',34.65361,134.038028,751,'千手観世音菩薩','https://www.saidaiji.jp/','日本三大奇祭の会陽（裸祭り）で知られる古刹。','https://ja.wikipedia.org/wiki/西大寺_(岡山市)','Wikipedia',true,now()),
-- 広島県
('daishoin-miyajima','大聖院','だいしょういん','temple','真言宗御室派','広島県','廿日市市','広島県廿日市市宮島町210',34.291944,132.318472,806,'十一面観音・波切不動明王','https://daisho-in.com/','宮島最古の寺院。弥山信仰の中心となる名刹。','https://ja.wikipedia.org/wiki/大聖院_(廿日市市)','Wikipedia',true,now()),
('hayatani-jinja','速谷神社','はやたにじんじゃ','shrine','安芸国二宮（旧国幣中社）','広島県','廿日市市','広島県廿日市市上平良308-1',34.359306,132.308361,null,null,'http://www.hayatanijinja.jp/','交通安全祈願で全国的に知られる安芸の古社。','https://ja.wikipedia.org/wiki/速谷神社','Wikipedia',true,now()),
('kibitsu-jinja-fukuyama','吉備津神社','きびつじんじゃ','shrine','備後国一宮（旧国幣小社）','広島県','福山市','広島県福山市新市町宮内400',34.5693361,133.2710694,806,null,'http://bingokibitujinja.com/','大吉備津彦命を祀る備後国一宮。国宝の本殿。','https://ja.wikipedia.org/wiki/吉備津神社_(福山市)','Wikipedia',true,now()),
('buttsuji','佛通寺','ぶっつうじ','temple','臨済宗佛通寺派','広島県','三原市','広島県三原市高坂町許山22',34.455861,133.026556,1397,'釈迦如来','http://www.buttsuji.or.jp','臨済宗佛通寺派の大本山。紅葉の名所。','https://ja.wikipedia.org/wiki/佛通寺','Wikipedia',true,now()),
-- 山口県
('hofu-tenmangu','防府天満宮','ほうふてんまんぐう','shrine','旧県社','山口県','防府市','山口県防府市松崎町14番1号',34.063278,131.574111,904,null,'https://www.hofutenmangu.com/','日本最初の天満宮とされる。日本三天神の一。','https://ja.wikipedia.org/wiki/防府天満宮','Wikipedia',true,now()),
('rurikoji','瑠璃光寺','るりこうじ','temple','曹洞宗','山口県','山口市','山口県山口市香山町7-1',34.189833,131.471778,1471,'薬師如来',null,'国宝の五重塔で知られる曹洞宗寺院。','https://ja.wikipedia.org/wiki/瑠璃光寺','Wikipedia',true,now()),
('sumiyoshi-jinja-shimonoseki','住吉神社','すみよしじんじゃ','shrine','長門国一宮（旧官幣中社）','山口県','下関市','山口県下関市一の宮住吉一丁目11-1',33.999611,130.956556,null,null,null,'住吉三神を祀る長門国一宮。国宝の本殿。','https://ja.wikipedia.org/wiki/住吉神社_(下関市)','Wikipedia',true,now()),
('akama-jingu','赤間神宮','あかまじんぐう','shrine','旧官幣大社','山口県','下関市','山口県下関市阿弥陀寺町4-1',33.959722,130.948472,859,null,'https://akama-jingu.com/','壇ノ浦で入水した安徳天皇を祀る。竜宮造りの水天門。','https://ja.wikipedia.org/wiki/赤間神宮','Wikipedia',true,now()),
('shoin-jinja-hagi','松陰神社','しょういんじんじゃ','shrine','旧県社','山口県','萩市','山口県萩市椿東1537',34.412139,131.418222,1907,null,'https://showin-jinja.or.jp/','吉田松陰を祀る。松下村塾が境内に残る。','https://ja.wikipedia.org/wiki/松陰神社','Wikipedia',true,now()),
('motonosumi-jinja','元乃隅神社','もとのすみじんじゃ','shrine','単立','山口県','長門市','山口県長門市油谷津黄498',34.41972,131.06278,1955,null,'https://motonosumi.com/','断崖に123基の朱鳥居が連なる絶景の社。','https://ja.wikipedia.org/wiki/元乃隅神社','Wikipedia',true,now()),
-- 徳島県
('oasahiko-jinja','大麻比古神社','おおあさひこじんじゃ','shrine','阿波国一宮（旧国幣中社）','徳島県','鳴門市','徳島県鳴門市大麻町板東字広塚13',34.1709278,134.5025667,null,null,'http://www.ooasahikojinja.jp/','阿波国一宮。交通安全・厄除けの大社。','https://ja.wikipedia.org/wiki/大麻比古神社','Wikipedia',true,now()),
('ryozenji','霊山寺','りょうぜんじ','temple','高野山真言宗','徳島県','鳴門市','徳島県鳴門市大麻町板東塚鼻126',34.1598028,134.5025917,null,'釈迦如来',null,'四国八十八ヶ所第1番札所。遍路の出発点。','https://ja.wikipedia.org/wiki/霊山寺_(鳴門市)','Wikipedia',true,now()),
('unpenji','雲辺寺','うんぺんじ','temple','真言宗御室派','徳島県','三好市','徳島県三好市池田町白地ノロウチ763-2',34.035222,133.723722,789,'千手観世音菩薩',null,'四国霊場最高所（標高927m）の第66番札所。','https://ja.wikipedia.org/wiki/雲辺寺','Wikipedia',true,now()),
-- 香川県
('zentsuji','善通寺','ぜんつうじ','temple','真言宗善通寺派','香川県','善通寺市','香川県善通寺市善通寺町三丁目3番1号',34.225111,133.774139,807,'薬師如来','http://www.zentsuji.com/','弘法大師空海生誕の地。真言宗善通寺派総本山。第75番札所。','https://ja.wikipedia.org/wiki/善通寺','Wikipedia',true,now()),
('shiromineji','白峯寺','しろみねじ','temple','真言宗御室派','香川県','坂出市','香川県坂出市青海町2635',34.333528,133.9267639,815,'千手観音',null,'崇徳上皇陵を擁する第81番札所。','https://ja.wikipedia.org/wiki/白峯寺','Wikipedia',true,now()),
('tamura-jinja-takamatsu','田村神社','たむらじんじゃ','shrine','讃岐国一宮（旧国幣中社）','香川県','高松市','香川県高松市一宮町字宮東286',34.286528,134.027278,709,null,'http://tamurajinja.com','讃岐国一宮。田村大神（五柱）を祀る。','https://ja.wikipedia.org/wiki/田村神社_(高松市)','Wikipedia',true,now()),
('yashimaji','屋島寺','やしまじ','temple','真言宗御室派','香川県','高松市','香川県高松市屋島東町字屋島峯1808',34.357917,134.101250,754,'十一面千手観世音菩薩',null,'屋島山上に建つ第84番札所。源平合戦の古戦場。','https://ja.wikipedia.org/wiki/屋島寺','Wikipedia',true,now()),
('konzoji','金倉寺','こんぞうじ','temple','天台寺門宗','香川県','善通寺市','香川県善通寺市金蔵寺町字本村1160',34.2500972,133.7810139,774,'薬師如来','http://www.kagawa-konzouji.or.jp/','智証大師円珍生誕の地。第76番札所。','https://ja.wikipedia.org/wiki/金倉寺','Wikipedia',true,now()),
-- 愛媛県
('oyamazumi-jinja','大山祇神社','おおやまづみじんじゃ','shrine','伊予国一宮（旧国幣大社）','愛媛県','今治市','愛媛県今治市大三島町宮浦3327',34.247889,133.005806,594,null,'https://oomishimagu.jp/','大三島に鎮座する全国の大山祇神社の総本社。武具の国宝多数。','https://ja.wikipedia.org/wiki/大山祇神社','Wikipedia',true,now()),
('ishizuchi-jinja','石鎚神社','いしづちじんじゃ','shrine','旧県社','愛媛県','西条市','愛媛県西条市西田甲797',33.889806,133.155500,null,null,'https://ishizuchisan.jp/','西日本最高峰・石鎚山を神体とする山岳信仰の社。','https://ja.wikipedia.org/wiki/石鎚神社','Wikipedia',true,now()),
('iyozuhiko-jinja','伊豫豆比古命神社','いよづひこのみことじんじゃ','shrine','旧県社','愛媛県','松山市','愛媛県松山市居相2-2-1',33.809306,132.771000,null,null,'http://tubaki.or.jp/','椿神社の通称で親しまれる松山の古社。商売繁盛の椿まつり。','https://ja.wikipedia.org/wiki/伊豫豆比古命神社','Wikipedia',true,now()),
('ishiteji','石手寺','いしてじ','temple','真言宗豊山派','愛媛県','松山市','愛媛県松山市石手2丁目9-21',33.847861,132.796472,729,'薬師如来','https://nehan.net/','道後温泉近くの第51番札所。国宝の仁王門。','https://ja.wikipedia.org/wiki/石手寺','Wikipedia',true,now()),
-- 高知県
('tosa-jinja','土佐神社','とさじんじゃ','shrine','土佐国一宮（旧国幣中社）','高知県','高知市','高知県高知市一宮しなね2丁目16-1',33.5926222,133.5770139,null,null,'https://tosajinja.com','土佐国一宮。味鋤高彦根神・一言主神を祀る。','https://ja.wikipedia.org/wiki/土佐神社','Wikipedia',true,now()),
('chikurinji-kochi','竹林寺','ちくりんじ','temple','真言宗智山派','高知県','高知市','高知県高知市五台山3577',33.546611,133.577472,724,'文殊菩薩','http://www.chikurinji.com/','五台山に建つ第31番札所。日本三文殊の一。','https://ja.wikipedia.org/wiki/竹林寺_(高知市)','Wikipedia',true,now()),
('kongofukuji','金剛福寺','こんごうふくじ','temple','真言宗豊山派','高知県','土佐清水市','高知県土佐清水市足摺岬214-1',32.726028,133.018556,822,'三面千手観音','https://kongoufukuji.com/','足摺岬に建つ第38番札所。補陀洛信仰の霊場。','https://ja.wikipedia.org/wiki/金剛福寺','Wikipedia',true,now()),
('hotsumisakiji','最御崎寺','ほつみさきじ','temple','真言宗豊山派','高知県','室戸市','高知県室戸市室戸岬町4058-1',33.249008,134.175739,807,'虚空蔵菩薩',null,'室戸岬に建つ第24番札所。空海修行の地。','https://ja.wikipedia.org/wiki/最御崎寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ④ 御祭神/本尊の紐付け
-- ============================================================
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
-- 鳥取
   (t.slug='hakuto-jinja' and d.slug in ('hakuto_kami'))
or (t.slug='mitokusan-sanbutsuji' and d.slug in ('shaka_nyorai','amida_nyorai','dainichi_nyorai'))
or (t.slug='ube-jinja' and d.slug in ('takeuchi_sukune'))
or (t.slug='shitori-jinja-yurihama' and d.slug in ('shitori_takehazuchi'))
or (t.slug='ogamiyama-jinja' and d.slug in ('okuninushi'))
-- 島根
or (t.slug='miho-jinja' and d.slug in ('kotoshironushi','mihotsuhime'))
or (t.slug='kumano-taisha-shimane' and d.slug in ('kumano_okami'))
or (t.slug='hinomisaki-jinja' and d.slug in ('amaterasu','susanoo'))
or (t.slug='susa-jinja-izumo' and d.slug in ('susanoo'))
or (t.slug='yaegaki-jinja' and d.slug in ('susanoo','kushinadahime'))
or (t.slug='mononobe-jinja-shimane' and d.slug in ('umashimaji'))
or (t.slug='gakuenji' and d.slug in ('senju_kannon','yakushi_nyorai'))
-- 岡山
or (t.slug='kibitsu-jinja' and d.slug in ('okibitsuhiko'))
or (t.slug='kibitsuhiko-jinja' and d.slug in ('okibitsuhiko'))
or (t.slug='saijo-inari' and d.slug in ('shaka_nyorai','saijo_inari'))
or (t.slug='yugasan-jinja-honguu' and d.slug in ('izanami'))
or (t.slug='saidaiji-okayama' and d.slug in ('senju_kannon'))
-- 広島
or (t.slug='daishoin-miyajima' and d.slug in ('sho_kannon','fudo_myoo'))
or (t.slug='hayatani-jinja' and d.slug in ('akihayatama'))
or (t.slug='kibitsu-jinja-fukuyama' and d.slug in ('okibitsuhiko'))
or (t.slug='buttsuji' and d.slug in ('shaka_nyorai'))
-- 山口
or (t.slug='hofu-tenmangu' and d.slug in ('michizane'))
or (t.slug='rurikoji' and d.slug in ('yakushi_nyorai'))
or (t.slug='sumiyoshi-jinja-shimonoseki' and d.slug in ('sumiyoshi'))
or (t.slug='akama-jingu' and d.slug in ('antoku_tenno'))
or (t.slug='shoin-jinja-hagi' and d.slug in ('yoshida_shoin'))
or (t.slug='motonosumi-jinja' and d.slug in ('ukanomitama','izanami'))
-- 徳島
or (t.slug='oasahiko-jinja' and d.slug in ('ooasahiko'))
or (t.slug='ryozenji' and d.slug in ('shaka_nyorai'))
or (t.slug='unpenji' and d.slug in ('senju_kannon'))
-- 香川
or (t.slug='zentsuji' and d.slug in ('yakushi_nyorai'))
or (t.slug='shiromineji' and d.slug in ('senju_kannon'))
or (t.slug='tamura-jinja-takamatsu' and d.slug in ('tamura_okami'))
or (t.slug='yashimaji' and d.slug in ('senju_kannon'))
or (t.slug='konzoji' and d.slug in ('yakushi_nyorai'))
-- 愛媛
or (t.slug='oyamazumi-jinja' and d.slug in ('ooyamatsumi'))
or (t.slug='ishizuchi-jinja' and d.slug in ('ishizuchihiko'))
or (t.slug='iyozuhiko-jinja' and d.slug in ('iyozuhiko'))
or (t.slug='ishiteji' and d.slug in ('yakushi_nyorai'))
-- 高知
or (t.slug='tosa-jinja' and d.slug in ('ajisukitakahikone','hitokotonushi'))
or (t.slug='chikurinji-kochi' and d.slug in ('monju_bosatsu'))
or (t.slug='kongofukuji' and d.slug in ('senju_kannon'))
or (t.slug='hotsumisakiji' and d.slug in ('kokuzo_bosatsu'))
on conflict do nothing;
