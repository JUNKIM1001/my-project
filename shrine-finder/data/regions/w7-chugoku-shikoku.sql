-- 中国・四国 社寺データ (担当: 鳥取/島根/岡山/広島/山口/徳島/香川/愛媛/高知)
-- 出典: ja.wikipedia.org の infobox 十進座標で裏取り。座標が無いものは除外。
-- AGENT_SPEC.md 仕様①〜④に準拠。_have_chugoku-shikoku.txt と重複しない著名社寺のみ。

-- ===== バッチ1 (5件: 島根/広島×3/広島) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('izanami','伊弉冉尊','いざなみのみこと','kami','国津神','{}','記紀','国生み・神生みの女神。黄泉の国を司る。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('chuai','仲哀天皇','ちゅうあいてんのう','kami','御霊','{帯中津日子命}','記紀','第14代天皇。神功皇后の夫。','https://ja.wikipedia.org/wiki/仲哀天皇','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方浄瑠璃世界の教主。病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('benzaiten','弁才天','べんざいてん','buddha','天部','{弁財天,市杵島姫}','仏教','音楽・弁舌・財福を司る天女。','https://ja.wikipedia.org/wiki/弁才天','Wikipedia',true,now()),
('sarutahiko','猿田彦大神','さるたひこのおおかみ','kami','国津神','{}','記紀','天孫降臨を先導した道開きの神。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='chuai' and g.slug in ('shobu','kaiun'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kanai_anzen'))
or (d.slug='benzaiten' and g.slug in ('geino','shobai','kinun'))
or (d.slug='sarutahiko' and g.slug in ('kotsu_anzen','kaiun','tabi_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('taikodani-inari-jinja','太皷谷稲成神社','たいこだにいなりじんじゃ','shrine','旧県社','島根県','鹿足郡津和野町','島根県鹿足郡津和野町後田409',34.465417,131.769170,1773,null,'http://taikodani.jp/','日本五大稲荷の一つに数えられる津和野の稲成神社。','https://ja.wikipedia.org/wiki/太皷谷稲成神社','Wikipedia',true,now()),
('kusatsu-hachiman-jinja','草津八幡神社','くさつはちまんじんじゃ','shrine','旧村社','広島県','広島市','広島県広島市西区田方1丁目11-18',34.382972,132.401639,null,null,'https://kusatsu189.com/','推古朝に創始と伝わる広島草津の八幡宮。','https://ja.wikipedia.org/wiki/草津八幡神社','Wikipedia',true,now()),
('misode-tenmangu','御袖天満宮','みそでてんまんぐう','shrine',null,'広島県','尾道市','広島県尾道市長江1丁目11-16',34.413472,133.202167,1069,null,'http://misodetenmangu.or.jp/','尾道の天神。映画ロケ地としても知られる石段の天満宮。','https://ja.wikipedia.org/wiki/御袖天満宮','Wikipedia',true,now()),
('daigan-ji-hatsukaichi','大願寺','だいがんじ','temple','高野山真言宗','広島県','廿日市市','広島県廿日市市宮島町3',34.295500,132.318167,null,'薬師如来・弁才天','https://itsukushima-daiganji.com/','宮島・厳島神社に隣接する真言宗寺院。日本三弁天の一つ。','https://ja.wikipedia.org/wiki/大願寺_(廿日市市)','Wikipedia',true,now()),
('sanzo-inari-jinja','三蔵稲荷神社','さんぞういなりじんじゃ','shrine',null,'広島県','福山市','広島県福山市丸之内1丁目8-7',34.492278,133.361056,null,null,'https://www.sanzoinari.jp/','福山城を守護する稲荷神社。','https://ja.wikipedia.org/wiki/三蔵稲荷神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='taikodani-inari-jinja' and d.slug in ('ukanomitama','izanami'))
or (t.slug='kusatsu-hachiman-jinja' and d.slug in ('hachiman','chuai','jingu_kogo'))
or (t.slug='misode-tenmangu' and d.slug in ('michizane'))
or (t.slug='daigan-ji-hatsukaichi' and d.slug in ('yakushi_nyorai','benzaiten'))
or (t.slug='sanzo-inari-jinja' and d.slug in ('ukanomitama','sarutahiko'))
on conflict do nothing;

-- ===== バッチ2 (5件: 岡山×2/島根/山口×2) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ugayafukiaezu','鵜葺草葺不合尊','うがやふきあえずのみこと','kami','天津神','{彦波限建鵜葺草葺不合尊}','記紀','神武天皇の父神。海神の娘玉依姫を母とする。','https://ja.wikipedia.org/wiki/ウガヤフキアエズ','Wikipedia',true,now()),
('matsudaira_naomasa','松平直政','まつだいらなおまさ','kami','御霊','{}','史実','松江松平家初代藩主。松江神社祭神。','https://ja.wikipedia.org/wiki/松平直政','Wikipedia',true,now()),
('mori_motonari','毛利元就','もうりもとなり','kami','御霊','{}','史実','安芸の戦国大名。中国地方を統一した名将。','https://ja.wikipedia.org/wiki/毛利元就','Wikipedia',true,now()),
('mori_takachika','毛利敬親','もうりたかちか','kami','御霊','{}','史実','長州藩第13代藩主。明治維新の功労者。','https://ja.wikipedia.org/wiki/毛利敬親','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ugayafukiaezu' and g.slug in ('anzan','kosodate','kaiun'))
or (d.slug='matsudaira_naomasa' and g.slug in ('shusse','kaiun'))
or (d.slug='mori_motonari' and g.slug in ('shobu','shusse','kaiun'))
or (d.slug='mori_takachika' and g.slug in ('shobu','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takano-jinja-tsuyama','高野神社','たかのじんじゃ','shrine','旧県社','岡山県','津山市','岡山県津山市二宮601',35.059286,133.964453,534,null,'https://takano-jinjya.or.jp/','美作国二宮。美作三大社の一社に数えられる古社。','https://ja.wikipedia.org/wiki/高野神社_(津山市二宮)','Wikipedia',true,now()),
('mimasaka-sosha-gu','美作総社宮','みまさかそうじゃぐう','shrine','旧県社','岡山県','津山市','岡山県津山市総社427',35.074083,133.994297,564,null,null,'美作国の総社。国指定重要文化財の本殿を有する。','https://ja.wikipedia.org/wiki/美作総社宮','Wikipedia',true,now()),
('matsue-jinja','松江神社','まつえじんじゃ','shrine','旧県社','島根県','松江市','島根県松江市殿町1番',35.473922,133.050339,1877,null,null,'松江城内に鎮座。松平直政・徳川家康らを祀る。','https://ja.wikipedia.org/wiki/松江神社','Wikipedia',true,now()),
('toyosaka-jinja-yamaguchi','豊榮神社','とよさかじんじゃ','shrine','旧別格官幣社','山口県','山口市','山口県山口市天花1丁目1-1',34.188806,131.480778,1762,null,null,'毛利元就を祀る山口の神社。野田神社と隣接。','https://ja.wikipedia.org/wiki/豊榮神社・野田神社','Wikipedia',true,now()),
('noda-jinja-yamaguchi','野田神社','のだじんじゃ','shrine','旧別格官幣社','山口県','山口市','山口県山口市天花1丁目1-2',34.188528,131.480389,1873,null,null,'毛利敬親を祀る山口の神社。豊榮神社と隣接。','https://ja.wikipedia.org/wiki/豊榮神社・野田神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takano-jinja-tsuyama' and d.slug in ('ugayafukiaezu'))
or (t.slug='mimasaka-sosha-gu' and d.slug in ('okuninushi'))
or (t.slug='matsue-jinja' and d.slug in ('matsudaira_naomasa','ieyasu'))
or (t.slug='toyosaka-jinja-yamaguchi' and d.slug in ('mori_motonari'))
or (t.slug='noda-jinja-yamaguchi' and d.slug in ('mori_takachika'))
on conflict do nothing;

-- ===== バッチ3 (5件: 徳島×2/山口/広島/愛媛) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tamayori','玉依姫命','たまよりひめのみこと','kami','国津神','{玉依姫}','記紀','海神の娘。神武天皇の母神。','https://ja.wikipedia.org/wiki/タマヨリビメ','Wikipedia',true,now()),
('ogetsuhime','大宜都比売命','おおげつひめのみこと','kami','国津神','{大気都比売}','記紀','五穀・食物を司る穀物の女神。阿波国の祖神。','https://ja.wikipedia.org/wiki/オオゲツヒメ','Wikipedia',true,now()),
('yakurahime','天石門別八倉比売命','あめのいわとわけやくらひめのみこと','kami','天津神','{}','記紀','阿波国一宮の主祭神とされる女神。','https://ja.wikipedia.org/wiki/天石門別八倉比売神社','Wikipedia',true,now()),
('jinmu','神武天皇','じんむてんのう','kami','御霊','{神倭伊波礼毘古命}','記紀','初代天皇。日本建国の祖とされる。','https://ja.wikipedia.org/wiki/神武天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tamayori' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='ogetsuhime' and g.slug in ('suisan_noko','shobai','kanai_anzen'))
or (d.slug='yakurahime' and g.slug in ('kaiun','yakubarai'))
or (d.slug='jinmu' and g.slug in ('kaiun','shobu','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hiwasa-hachiman-jinja','日和佐八幡神社','ひわさはちまんじんじゃ','shrine','旧郷社','徳島県','海部郡美波町','徳島県海部郡美波町日和佐浦369番地',33.734720,134.540280,1351,null,'http://hiwasahachiman.com/','大浜海岸に面する八幡宮。秋祭りのちょうさで知られる。','https://ja.wikipedia.org/wiki/日和佐八幡神社','Wikipedia',true,now()),
('ichinomiya-jinja-tokushima','一宮神社','いちのみやじんじゃ','shrine','旧県社','徳島県','徳島市','徳島県徳島市一宮町西丁237',34.037806,134.462639,1630,null,null,'阿波国一宮の論社。四国八十八ヶ所十三番大日寺の向かいに鎮座。','https://ja.wikipedia.org/wiki/一宮神社_(徳島市)','Wikipedia',true,now()),
('shirasaki-hachimangu','白崎八幡宮','しらさきはちまんぐう','shrine',null,'山口県','岩国市','山口県岩国市今津町6丁目12-23',34.160389,132.209389,1250,null,'http://www.sirasaki.com/','岩国の総鎮守として知られる八幡宮。','https://ja.wikipedia.org/wiki/白崎八幡宮','Wikipedia',true,now()),
('take-jinja','多家神社','たけじんじゃ','shrine','旧県社','広島県','安芸郡府中町','広島県安芸郡府中町宮の町3丁目',34.395906,132.510253,1873,null,'http://takejinja.net/','安芸国総鎮守。神武天皇東征伝承の地とされる。','https://ja.wikipedia.org/wiki/多家神社','Wikipedia',true,now()),
('matsuyama-toshogu','松山東照宮','まつやまとうしょうぐう','shrine',null,'愛媛県','松山市','愛媛県松山市祝谷東町640',33.856694,132.783389,1765,null,null,'松平定行が創建した松山の東照宮。旧称・松山神社。','https://ja.wikipedia.org/wiki/松山東照宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hiwasa-hachiman-jinja' and d.slug in ('hachiman','jingu_kogo','tamayori'))
or (t.slug='ichinomiya-jinja-tokushima' and d.slug in ('ogetsuhime','yakurahime'))
or (t.slug='shirasaki-hachimangu' and d.slug in ('hachiman','chuai','jingu_kogo'))
or (t.slug='take-jinja' and d.slug in ('jinmu'))
or (t.slug='matsuyama-toshogu' and d.slug in ('ieyasu','michizane'))
on conflict do nothing;

-- ===== バッチ4 (5件: 香川×4/愛媛) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('futodama','天太玉命','あめのふとだまのみこと','kami','天津神','{}','記紀','忌部氏の祖神。祭祀を司る神。','https://ja.wikipedia.org/wiki/フトダマ','Wikipedia',true,now()),
('oyamatsumi','大山積大神','おおやまつみのおおかみ','kami','国津神','{大山祇神}','記紀','山・海・武の守護神。三島・大山祇信仰の祖神。','https://ja.wikipedia.org/wiki/オオヤマツミ','Wikipedia',true,now()),
('goshi_junnansha','国事殉難者','こくじじゅんなんしゃ','kami','御霊','{護国の英霊}','史実','国家のために殉じた英霊。護国神社の祭神。','https://ja.wikipedia.org/wiki/護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='futodama' and g.slug in ('shobai','kaiun','jouju'))
or (d.slug='oyamatsumi' and g.slug in ('shobu','kaijo_anzen','suisan_noko'))
or (d.slug='goshi_junnansha' and g.slug in ('shobu','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('awai-jinja','粟井神社','あわいじんじゃ','shrine','旧郷社','香川県','観音寺市','香川県観音寺市粟井町1716番地',34.091194,133.704500,null,null,null,'約3千株のあじさいで知られる「あじさいの宮」。讃岐忌部氏の氏神。','https://ja.wikipedia.org/wiki/粟井神社','Wikipedia',true,now()),
('shotsu-ji','聖通寺','しょうつうじ','temple','真言宗御室派','香川県','綾歌郡宇多津町','香川県綾歌郡宇多津町2805',34.315333,133.833986,null,'薬師如来','http://www.shotsuji.com/','聖通寺山に建つ古刹。沖薬師として親しまれる。','https://ja.wikipedia.org/wiki/聖通寺','Wikipedia',true,now()),
('ubushina-jinja','宇夫階神社','うぶしなじんじゃ','shrine','旧県社','香川県','綾歌郡宇多津町','香川県綾歌郡宇多津町1644',34.308225,133.820658,null,null,null,'宇多津の総鎮守。大己貴命を祀る古社。','https://ja.wikipedia.org/wiki/宇夫階神社','Wikipedia',true,now()),
('kagawa-gokoku-jinja','香川県護国神社','かがわけんごこくじんじゃ','shrine','護国神社','香川県','善通寺市','香川県善通寺市文京町四丁目5番5号',34.224440,133.780000,1898,null,'http://sanukinomiya.org/','讃岐宮とも称する香川県の護国神社。','https://ja.wikipedia.org/wiki/讃岐宮','Wikipedia',true,now()),
('bekku-oyamazumi-jinja','別宮大山祇神社','べっくおおやまづみじんじゃ','shrine','旧県社','愛媛県','今治市','愛媛県今治市別宮町3丁目6-1',34.068722,132.995111,703,null,null,'大三島・大山祇神社の別宮。「三島地御前」と称される。','https://ja.wikipedia.org/wiki/別宮大山祇神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='awai-jinja' and d.slug in ('futodama'))
or (t.slug='shotsu-ji' and d.slug in ('yakushi_nyorai'))
or (t.slug='ubushina-jinja' and d.slug in ('okuninushi'))
or (t.slug='kagawa-gokoku-jinja' and d.slug in ('goshi_junnansha'))
or (t.slug='bekku-oyamazumi-jinja' and d.slug in ('oyamatsumi'))
on conflict do nothing;

-- ===== バッチ5 (5件: 高知/島根×2/広島×2) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kunitokotachi','国常立命','くにとこたちのみこと','kami','天津神','{国之常立神}','記紀','天地開闢の際に最初に現れた根源神。','https://ja.wikipedia.org/wiki/クニノトコタチ','Wikipedia',true,now()),
('kanayamahiko','金山彦命','かなやまひこのみこと','kami','国津神','{金山彦神}','記紀','鉱山・鍛冶・金属を司る神。','https://ja.wikipedia.org/wiki/カナヤマビコ','Wikipedia',true,now()),
('kushishirokahime','櫛代賀姫命','くししろかひめのみこと','kami','国津神','{}','記紀','石見・益田地方の祖神とされる女神。','https://ja.wikipedia.org/wiki/櫛代賀姫神社','Wikipedia',true,now()),
('izanagi','伊弉諾命','いざなぎのみこと','kami','天津神','{伊邪那岐命}','記紀','国生み・神生みの男神。アマテラスらの父神。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kunitokotachi' and g.slug in ('kaiun','yakubarai'))
or (d.slug='kanayamahiko' and g.slug in ('shobai','kinun','shigoto'))
or (d.slug='kushishirokahime' and g.slug in ('enmusubi','kanai_anzen'))
or (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('omura-jinja','小村神社','おむらじんじゃ','shrine','旧県社','高知県','高岡郡日高村','高知県高岡郡日高村下分1794',33.543278,133.393000,587,null,null,'土佐国二宮。国宝の金銅荘環頭大刀拵を伝える古社。','https://ja.wikipedia.org/wiki/小村神社','Wikipedia',true,now()),
('sahimeyama-jinja-masuda','佐毘売山神社','さひめやまじんじゃ','shrine','旧県社','島根県','益田市','島根県益田市乙子町51',34.680194,131.893306,null,null,'http://www.sahimeyama-jinja.jp/','金山彦命を祀る益田の古社。石見銀山の佐毘売山神社の本社。','https://ja.wikipedia.org/wiki/佐毘売山神社','Wikipedia',true,now()),
('kushishirokahime-jinja','櫛代賀姫神社','くししろかひめじんじゃ','shrine','旧県社','島根県','益田市','島根県益田市久城町963',34.701194,131.840111,806,null,null,'益田の式内社。櫛代賀姫命を祀る。','https://ja.wikipedia.org/wiki/櫛代賀姫神社','Wikipedia',true,now()),
('tsuruhane-jinja','鶴羽根神社','つるはねじんじゃ','shrine','旧県社','広島県','広島市','広島県広島市東区二葉の里2丁目5-11',34.404000,132.471417,1190,null,'http://www.tsuruhanejinja-hiroshima.jp/','広島東部の総氏神。二葉山七福神の一社。','https://ja.wikipedia.org/wiki/鶴羽根神社','Wikipedia',true,now()),
('kameyama-jinja-kure','亀山神社','かめやまじんじゃ','shrine','旧県社','広島県','呉市','広島県呉市清水1丁目9-36',34.241472,132.569111,1886,null,null,'呉の総鎮守。旧呉市街の氏神として崇敬される八幡宮。','https://ja.wikipedia.org/wiki/亀山神社_(呉市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='omura-jinja' and d.slug in ('kunitokotachi'))
or (t.slug='sahimeyama-jinja-masuda' and d.slug in ('kanayamahiko'))
or (t.slug='kushishirokahime-jinja' and d.slug in ('kushishirokahime','hachiman'))
or (t.slug='tsuruhane-jinja' and d.slug in ('hachiman','jingu_kogo','chuai'))
or (t.slug='kameyama-jinja-kure' and d.slug in ('hachiman','jingu_kogo','chuai'))
on conflict do nothing;

-- ===== バッチ6 (5件: 島根/岡山/愛媛×3) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('suseribime','須勢理姫命','すせりひめのみこと','kami','国津神','{由良比女大神}','記紀','スサノオの娘。大国主命の妻神。','https://ja.wikipedia.org/wiki/スセリビメ','Wikipedia',true,now()),
('ikazuchi','大雷神','おおいかづちのかみ','kami','国津神','{}','記紀','雷を司る神。農耕の水と結びつく。','https://ja.wikipedia.org/wiki/イカヅチ','Wikipedia',true,now()),
('takaokami','高龗神','たかおかみのかみ','kami','国津神','{}','記紀','龍神・水神。雨乞いと水を司る。','https://ja.wikipedia.org/wiki/オカミ','Wikipedia',true,now()),
('takitsuhime','瀧津姫命','たきつひめのみこと','kami','宗像三女神','{湍津姫}','記紀','宗像三女神の一柱。水・航海を司る。','https://ja.wikipedia.org/wiki/タギツヒメ','Wikipedia',true,now()),
('konohanasakuya','木花咲耶姫','このはなさくやひめ','kami','国津神','{木花之佐久夜毘売}','記紀','安産・子授けの女神。富士山の女神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now()),
('amenominakanushi','天之御中主神','あめのみなかぬしのかみ','kami','天津神','{}','記紀','天地開闢で最初に現れた造化三神の首座。','https://ja.wikipedia.org/wiki/アメノミナカヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='suseribime' and g.slug in ('enmusubi','renai','kanai_anzen'))
or (d.slug='ikazuchi' and g.slug in ('mizu_amagoi','yakubarai'))
or (d.slug='takaokami' and g.slug in ('mizu_amagoi','kaiun'))
or (d.slug='takitsuhime' and g.slug in ('kaijo_anzen','suisan_noko'))
or (d.slug='konohanasakuya' and g.slug in ('anzan','kosodate','enmusubi'))
or (d.slug='amenominakanushi' and g.slug in ('kaiun','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yurahime-jinja','由良比女神社','ゆらひめじんじゃ','shrine','旧郷社','島根県','隠岐郡西ノ島町','島根県隠岐郡西ノ島町浦郷922',36.092000,132.987889,null,null,null,'隠岐国一宮。イカ寄せの浜の伝説で知られる古社。','https://ja.wikipedia.org/wiki/由良比女神社','Wikipedia',true,now()),
('achi-jinja-kurashiki','阿智神社','あちじんじゃ','shrine','旧県社','岡山県','倉敷市','岡山県倉敷市本町12-1',34.597780,133.773610,null,null,'http://achi.fem.jp/','倉敷美観地区の鶴形山に鎮座。宗像三女神を祀る。','https://ja.wikipedia.org/wiki/阿智神社_(倉敷市)','Wikipedia',true,now()),
('ikku-jinja-niihama','一宮神社','いっくじんじゃ','shrine','旧県社','愛媛県','新居浜市','愛媛県新居浜市一宮町1丁目3-1',33.961806,133.279583,709,null,'https://www.ikkujinja.or.jp/','新居浜の総氏神。国天然記念物のクスノキ群で知られる。','https://ja.wikipedia.org/wiki/一宮神社_(新居浜市)','Wikipedia',true,now()),
('taki-jinja-imabari','多伎神社','たきじんじゃ','shrine','旧県社','愛媛県','今治市','愛媛県今治市古谷乙47',34.003500,132.994806,null,null,null,'式内名神大社。30余基の古墳群に囲まれた古社。','https://ja.wikipedia.org/wiki/多伎神社','Wikipedia',true,now()),
('kuroshima-jingu','黒嶋神宮','くろしまじんぐう','shrine','旧県社','愛媛県','新居浜市','愛媛県新居浜市黒島107',33.987389,133.345194,null,null,null,'安産の守護神として信仰される新居浜の式内社。','https://ja.wikipedia.org/wiki/黒嶋神宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yurahime-jinja' and d.slug in ('suseribime'))
or (t.slug='achi-jinja-kurashiki' and d.slug in ('ichikishima'))
or (t.slug='ikku-jinja-niihama' and d.slug in ('oyamatsumi','ikazuchi','takaokami'))
or (t.slug='taki-jinja-imabari' and d.slug in ('takitsuhime'))
or (t.slug='kuroshima-jingu' and d.slug in ('oyamatsumi','konohanasakuya','amenominakanushi'))
on conflict do nothing;
