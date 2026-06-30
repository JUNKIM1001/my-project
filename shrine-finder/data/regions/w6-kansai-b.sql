-- w6-kansai-b.sql
-- 担当県: 大阪府・兵庫県・奈良県・和歌山県
-- データ出典: ja.wikipedia.org infobox 十進座標で裏取り
-- 既存 _have_kansai.txt と重複しない著名社寺のみ収録

-- ============================================================
-- ① 新規神仏
-- ============================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','天照大神の弟。八岐大蛇退治の英雄神で厄除・除災の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('izanagi','伊弉諾尊','いざなぎのみこと','kami','天津神','{}','記紀','国生み・神生みを行った男神。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('izanami','伊弉冉尊','いざなみのみこと','kami','天津神','{}','記紀','国生み・神生みを行った女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('sukunabikona','少彦名命','すくなびこなのみこと','kami','国津神','{}','記紀','大国主と共に国造りを行った医薬・温泉の神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('sarutahiko','猿田彦命','さるたひこのみこと','kami','国津神','{}','記紀','道開きの神。導き・交通の神。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{}','仏教','千の手で衆生を救う観音菩薩。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。念仏信仰の本尊。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ② 新規神仏のご利益
-- ============================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='susanoo' and g.slug in ('yakubarai','shobu','enmusubi'))
or (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','choju'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='sukunabikona' and g.slug in ('byoki_heyu','shobai','kaiun'))
or (d.slug='sarutahiko' and g.slug in ('kotsu_anzen','kaiun','tabi_anzen'))
or (d.slug='senju_kannon' and g.slug in ('byoki_heyu','enmusubi','jouju'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','kaiun','byoki_heyu'))
on conflict do nothing;

-- ============================================================
-- ③ 社寺  ＋  ④ 御祭神/本尊の紐付け
-- ============================================================
-- 1. 大念佛寺 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('dainenbutsu-ji','大念佛寺','だいねんぶつじ','temple','融通念仏宗（総本山）','大阪府','大阪市','大阪府大阪市平野区平野上町1-7-26',34.6272444,135.5504972,1127,'十一尊天得如来','https://www.dainenbutsuji.com/','融通念仏宗の総本山。日本最初の念仏道場とされる。','https://ja.wikipedia.org/wiki/大念仏寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='dainenbutsu-ji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- 2. 水無瀬神宮 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('minase-jingu','水無瀬神宮','みなせじんぐう','shrine','水無瀬神宮（旧官幣大社）','大阪府','三島郡島本町','大阪府三島郡島本町広瀬3-10-24',34.884889,135.673083,1240,null,'https://www.minasejingu.jp/','後鳥羽天皇ら三帝を祀る大阪府唯一の神宮。','https://ja.wikipedia.org/wiki/水無瀬神宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 3. 杭全神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kumata-jinja','杭全神社','くまたじんじゃ','shrine','杭全神社（旧府社）','大阪府','大阪市','大阪府大阪市平野区平野宮町2-1-67',34.628944,135.554944,862,null,'https://kumata.jp/','平野郷の総鎮守。日本唯一の連歌所が現存する。','https://ja.wikipedia.org/wiki/杭全神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kumata-jinja' and d.slug in ('susanoo','izanami','izanagi'))
on conflict do nothing;

-- 4. 阿部野神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('abeno-jinja','阿部野神社','あべのじんじゃ','shrine','阿部野神社（旧別格官幣社）','大阪府','大阪市','大阪府大阪市阿倍野区北畠3-7-20',34.62833,135.499528,1882,null,'https://www.abenojinjya.com/','北畠親房・顕家を祀る建武中興十五社の一社。','https://ja.wikipedia.org/wiki/阿部野神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 5. 堀越神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('horikoshi-jinja','堀越神社','ほりこしじんじゃ','shrine','堀越神社（旧村社）','大阪府','大阪市','大阪府大阪市天王寺区茶臼山町1-8',34.651472,135.513222,null,null,'http://www.horikoshijinja.or.jp/','聖徳太子が四天王寺建立時に創建したと伝わる。御祭神は崇峻天皇。「一生に一度の願い」で知られる。','https://ja.wikipedia.org/wiki/堀越神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 6. 信太森葛葉稲荷神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shinodamori-kuzunoha-inari','信太森葛葉稲荷神社','しのだのもりくずのはいなりじんじゃ','shrine','信太森葛葉稲荷神社','大阪府','和泉市','大阪府和泉市葛の葉町1-11-47',34.509333,135.438639,null,null,'http://www.kuzunohainari.com/','安倍晴明の母とされる白狐「葛の葉」伝説の舞台。','https://ja.wikipedia.org/wiki/信太森葛葉稲荷神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shinodamori-kuzunoha-inari' and d.slug in ('ukanomitama'))
on conflict do nothing;

-- 7. 太融寺 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('taiyu-ji','太融寺','たいゆうじ','temple','高野山真言宗','大阪府','大阪市','大阪府大阪市北区太融寺町3-7',34.701806,135.504083,821,'千手観音','https://taiyuji.net/','弘法大師創建と伝わる。源融ゆかりの寺で新西国客番札所。','https://ja.wikipedia.org/wiki/太融寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='taiyu-ji' and d.slug in ('senju_kannon'))
on conflict do nothing;

-- 8. 生石神社 (兵庫)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oushiko-jinja','生石神社','おうしこじんじゃ','shrine','生石神社','兵庫県','高砂市','兵庫県高砂市阿弥陀町生石171',34.7825417,134.7952167,null,null,'http://www.ishinohouden.jp/','巨石「石の宝殿」を御神体とする。日本三奇の一つ。','https://ja.wikipedia.org/wiki/生石神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oushiko-jinja' and d.slug in ('okuninushi','sukunabikona'))
on conflict do nothing;

-- 9. 多井畑厄除八幡宮 (兵庫)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tainohata-yakuyoke-hachimangu','多井畑厄除八幡宮','たいのはたやくよけはちまんぐう','shrine','多井畑厄除八幡宮','兵庫県','神戸市','兵庫県神戸市須磨区多井畑字宮脇1',34.6623333,135.0956250,1170,null,'http://www.tainohatayakuyokehachimangu.or.jp/','日本最古の厄除けの霊地と称される。厄神大祭で知られる。','https://ja.wikipedia.org/wiki/多井畑厄除八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tainohata-yakuyoke-hachimangu' and d.slug in ('hachiman'))
on conflict do nothing;

-- 追加神仏（飛鳥坐神社ほか用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','大国主の子。託宣・商売・えびす信仰の神。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('omononushi','大物主神','おおものぬしのかみ','kami','国津神','{}','記紀','三輪山の神。国土経営・除災の神。','https://ja.wikipedia.org/wiki/オオモノヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kotoshironushi' and g.slug in ('shobai','kinun','kaiun'))
or (d.slug='omononushi' and g.slug in ('yakubarai','shobai','kaiun'))
on conflict do nothing;

-- 10. 紀州東照宮 (和歌山)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kishu-toshogu','紀州東照宮','きしゅうとうしょうぐう','shrine','紀州東照宮（旧県社）','和歌山県','和歌山市','和歌山県和歌山市和歌浦西2-1-20',34.192611,135.165667,1621,null,'https://www.kishutoshogu.org/','徳川家康と紀州藩祖徳川頼宣を祀る。「関西の日光」と称される。','https://ja.wikipedia.org/wiki/紀州東照宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kishu-toshogu' and d.slug in ('ieyasu'))
on conflict do nothing;

-- 11. 和歌浦天満宮 (和歌山)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('wakaura-tenmangu','和歌浦天満宮','わかうらてんまんぐう','shrine','和歌浦天満宮（旧県社）','和歌山県','和歌山市','和歌山県和歌山市和歌浦西2-1-24',34.191611,135.164222,964,null,'https://wakauratenmangu.jp/','菅原道真を祀る天神山中腹の古社。日本三菅廟の一つ。','https://ja.wikipedia.org/wiki/和歌浦天満宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='wakaura-tenmangu' and d.slug in ('michizane'))
on conflict do nothing;

-- 12. 須佐神社 (和歌山・有田)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('susa-jinja-arida','須佐神社','すさじんじゃ','shrine','須佐神社（旧県社・名神大社）','和歌山県','有田市','和歌山県有田市千田1641',34.0648750,135.1414778,713,null,null,'素戔嗚尊を祀る名神大社。千田の宮として知られる。','https://ja.wikipedia.org/wiki/須佐神社_(有田市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='susa-jinja-arida' and d.slug in ('susanoo'))
on conflict do nothing;

-- 13. 飛鳥坐神社 (奈良)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('asukaniimasu-jinja','飛鳥坐神社','あすかにいますじんじゃ','shrine','飛鳥坐神社（旧村社・名神大社）','奈良県','高市郡明日香村','奈良県高市郡明日香村飛鳥708',34.479694,135.822694,null,null,'http://asukaniimasujinja.jp','事代主神らを祀る古社。奇祭「おんだ祭」で知られる。','https://ja.wikipedia.org/wiki/飛鳥坐神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='asukaniimasu-jinja' and d.slug in ('kotoshironushi','omononushi'))
on conflict do nothing;

-- 追加神仏（高鴨神社用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ajisukitakahikone','阿遅志貴高日子根神','あぢすきたかひこねのかみ','kami','国津神','{}','記紀','大国主の子。鴨族の祖神で農耕・雷の神。','https://ja.wikipedia.org/wiki/アヂスキタカヒコネ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ajisukitakahikone' and g.slug in ('suisan_noko','kaiun','byoki_heyu'))
on conflict do nothing;

-- 14. 高鴨神社 (奈良)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('takakamo-jinja','高鴨神社','たかかもじんじゃ','shrine','高鴨神社（旧県社・名神大社）','奈良県','御所市','奈良県御所市鴨神1110',34.408194,135.707611,null,null,null,'全国の賀茂(鴨)社の総本宮。日本サクラソウの名所。','https://ja.wikipedia.org/wiki/高鴨神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='takakamo-jinja' and d.slug in ('ajisukitakahikone'))
on conflict do nothing;

-- 15. 鴨都波神社 (奈良)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kamotsuba-jinja','鴨都波神社','かもつばじんじゃ','shrine','鴨都波神社（旧県社・名神大社）','奈良県','御所市','奈良県御所市宮前町514',34.460528,135.732861,null,null,null,'事代主命を祀る鴨族ゆかりの名神大社。下鴨社とも。','https://ja.wikipedia.org/wiki/鴨都波神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kamotsuba-jinja' and d.slug in ('kotoshironushi'))
on conflict do nothing;

-- 16. 等彌神社 (奈良)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tomi-jinja','等彌神社','とみじんじゃ','shrine','等彌神社（旧県社・式内社）','奈良県','桜井市','奈良県桜井市桜井1176',34.506472,135.853972,null,null,null,'鳥見山麓の古社。神武天皇の大嘗祭伝承地とされる。','https://ja.wikipedia.org/wiki/等彌神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tomi-jinja' and d.slug in ('amaterasu'))
on conflict do nothing;

-- 追加神仏（勝鬘院・清荒神用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('aizen_myoo','愛染明王','あいぜんみょうおう','buddha','明王','{}','仏教','愛欲を悟りに転じる明王。縁結び・恋愛成就の本尊。','https://ja.wikipedia.org/wiki/愛染明王','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{}','仏教','密教の根本仏。宇宙の真理を表す如来。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='aizen_myoo' and g.slug in ('enmusubi','renai','jouju'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','jouju'))
on conflict do nothing;

-- 17. 射楯兵主神社（姫路総社） (兵庫)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('itatehyozu-jinja','射楯兵主神社','いたてひょうずじんじゃ','shrine','射楯兵主神社（播磨国総社・旧県社）','兵庫県','姫路市','兵庫県姫路市総社本町190',34.833889,134.697000,null,null,null,'播磨国総社。姫路城内に鎮座し「総社さん」と親しまれる。','https://ja.wikipedia.org/wiki/射楯兵主神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='itatehyozu-jinja' and d.slug in ('okuninushi'))
on conflict do nothing;

-- 18. 清荒神清澄寺 (兵庫)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kiyoshikojin-seichoji','清荒神清澄寺','きよしこうじんせいちょうじ','temple','真言三宝宗（大本山）','兵庫県','宝塚市','兵庫県宝塚市米谷字清シ1',34.822139,135.352583,896,'大日如来','https://www.kiyoshikojin.or.jp/','宇多天皇勅願の古刹。台所の神「三宝荒神」で知られる。','https://ja.wikipedia.org/wiki/清荒神清澄寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kiyoshikojin-seichoji' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- 19. 愛染堂勝鬘院 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('aizendo-shomanin','勝鬘院（愛染堂）','しょうまんいん（あいぜんどう）','temple','和宗','大阪府','大阪市','大阪府大阪市天王寺区夕陽丘町5-36',34.657111,135.512917,593,'愛染明王','https://aizendo.com/','聖徳太子創建と伝わる四天王寺別院。多宝塔は大阪最古の木造建築で国宝。','https://ja.wikipedia.org/wiki/勝鬘院','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='aizendo-shomanin' and d.slug in ('aizen_myoo'))
on conflict do nothing;

-- 20. 宝山寺（生駒聖天） (奈良)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hozan-ji-ikoma','宝山寺','ほうざんじ','temple','真言律宗（大本山）','奈良県','生駒市','奈良県生駒市門前町1-1',34.684667,135.686556,1678,'不動明王','https://www.hozanji.com/','生駒聖天として知られる。歓喜天を祀り商売繁盛で信仰を集める。','https://ja.wikipedia.org/wiki/宝山寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hozan-ji-ikoma' and d.slug in ('fudo_myoo'))
on conflict do nothing;

-- 21. おのころ島神社 (兵庫・淡路)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('onokorojima-jinja','おのころ島神社','おのころじまじんじゃ','shrine','自凝島神社','兵庫県','南あわじ市','兵庫県南あわじ市榎列下幡多415',34.31250,134.77111,null,null,'http://www.freedom.ne.jp/onokoro/','国生み神話の地と伝わる。高さ21.7mの大鳥居は日本三大鳥居の一つ。','https://ja.wikipedia.org/wiki/おのころ島神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='onokorojima-jinja' and d.slug in ('izanagi','izanami'))
on conflict do nothing;

-- 追加神仏（星田妙見宮用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenominakanushi','天之御中主神','あめのみなかぬしのかみ','kami','天津神','{}','記紀','造化三神の首座。宇宙の根源神で妙見信仰の本地。','https://ja.wikipedia.org/wiki/アメノミナカヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenominakanushi' and g.slug in ('kaiun','yakubarai','shusse'))
on conflict do nothing;

-- 22. 星田妙見宮（小松神社） (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hoshida-myoken','星田妙見宮','ほしだみょうけん','shrine','小松神社（星田妙見宮）','大阪府','交野市','大阪府交野市星田9-60-1',34.759472,135.678583,810,null,'https://www.hoshida-myoken.com/','弘法大師ゆかりの妙見信仰の社。隕石落下伝承の磐座を祀る。','https://ja.wikipedia.org/wiki/小松神社_(交野市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hoshida-myoken' and d.slug in ('amenominakanushi'))
on conflict do nothing;

-- 23. 呉服神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kureha-jinja','呉服神社','くれはじんじゃ','shrine','呉服神社','大阪府','池田市','大阪府池田市室町7-4',34.822917,135.422083,null,null,'https://kureha-shrine.com/','機織の祖神・呉服媛を祀る。「ごふく(呉服)」の語源とされる。','https://ja.wikipedia.org/wiki/呉服神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 24. 恩智神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('onji-jinja','恩智神社','おんぢじんじゃ','shrine','恩智神社（河内国二宮・名神大社）','大阪府','八尾市','大阪府八尾市恩智中町5-10',34.606611,135.638500,null,null,'http://www.onjijinja.or.jp/','河内国二宮。大御食津彦大神らを祀る名神大社。','https://ja.wikipedia.org/wiki/恩智神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 25. 美具久留御魂神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mikukurumitama-jinja','美具久留御魂神社','みくくるみたまじんじゃ','shrine','美具久留御魂神社（式内社・旧府社）','大阪府','富田林市','大阪府富田林市宮町3-2053',34.518000,135.601500,null,null,null,'大国主神の荒魂を祀る。河内の水分神社の一つで「下水分社」とも。','https://ja.wikipedia.org/wiki/美具久留御魂神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mikukurumitama-jinja' and d.slug in ('okuninushi'))
on conflict do nothing;

-- 追加神仏（泉穴師神社用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenooshihomimi','天忍穂耳命','あめのおしほみみのみこと','kami','天津神','{}','記紀','天照大神の子で瓊瓊杵尊の父。五穀豊穣・勝運の神。','https://ja.wikipedia.org/wiki/アメノオシホミミ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenooshihomimi' and g.slug in ('suisan_noko','shobu','kaiun'))
on conflict do nothing;

-- 26. 泉穴師神社 (大阪)
insert into temple_shrine (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('izumi-anashi-jinja','泉穴師神社','いずみあなしじんじゃ','shrine','泉穴師神社（和泉国二宮・式内社）','大阪府','泉大津市','大阪府泉大津市豊中町1-1-1',34.496528,135.419778,672,null,'http://izumi.anashi-jinja.com/','和泉国二宮。天忍穂耳命らを祀る古社。','https://ja.wikipedia.org/wiki/泉穴師神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='izumi-anashi-jinja' and d.slug in ('amenooshihomimi'))
on conflict do nothing;
