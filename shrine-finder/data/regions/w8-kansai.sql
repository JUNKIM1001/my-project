-- w8-kansai データ（近畿）: 観光ガイド掲載クラスで _have に無い著名社寺
-- 出典: ja.wikipedia.org infobox の十進座標で裏取り

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ame_no_futodama','天太玉命','あめのふとだまのみこと','kami','天津神','{}','記紀','忌部氏の祖神。祭祀を司る神。','https://ja.wikipedia.org/wiki/フトダマ','Wikipedia',true,now()),
('hata_no_kawakatsu','大避大神','おおさけのおおかみ','kami','人神','{秦河勝}','社伝','秦河勝を祀る。坂越の産土神。','https://ja.wikipedia.org/wiki/大避神社','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{建速須佐之男命}','記紀','天照大神の弟神。厄除け・疫病退散の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kushinadahime','櫛名田比売','くしなだひめ','kami','国津神','{奇稲田姫}','記紀','スサノオの妻神。縁結び・夫婦和合の神。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('izanagi','伊弉諾尊','いざなぎのみこと','kami','天津神','{}','記紀','国産み・神産みの男神。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('izanami','伊弉冉尊','いざなみのみこと','kami','天津神','{}','記紀','国産み・神産みの女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ame_no_futodama' and g.slug in ('suisan_noko','shobai','kaiun'))
or (d.slug='hata_no_kawakatsu' and g.slug in ('kaijo_anzen','shobai','kaiun'))
or (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','enmusubi'))
or (d.slug='kushinadahime' and g.slug in ('enmusubi','renai','kanai_anzen'))
or (d.slug='izanagi' and g.slug in ('enmusubi','kaiun','yakubarai'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nahaka-jinja','那波加神社','なはかじんじゃ','shrine','式内社・旧県社','滋賀県','大津市','滋賀県大津市苗鹿1-8-1',35.083694,135.889611,668,null,null,'天太玉命を祀る式内社。農耕を助けた天降りの神を伝える。','https://ja.wikipedia.org/wiki/那波加神社','Wikipedia',true,now()),
('osake-jinja','大避神社','おおさけじんじゃ','shrine','式内社（論社）','兵庫県','赤穂市','兵庫県赤穂市坂越1297',34.7680972,134.4319861,647,null,null,'秦河勝を祀る坂越の産土神。坂越の船祭りで知られる。','https://ja.wikipedia.org/wiki/大避神社','Wikipedia',true,now()),
('namba-yasaka-jinja','難波八阪神社','なんばやさかじんじゃ','shrine','旧郷社','大阪府','大阪市','大阪府大阪市浪速区元町2-9-19',34.661222,135.496694,null,null,'http://nambayasaka.jp/','巨大な獅子殿で知られる難波の氏神。','https://ja.wikipedia.org/wiki/難波八阪神社','Wikipedia',true,now()),
('goryo-jinja-osaka','御霊神社','ごりょうじんじゃ','shrine','旧府社','大阪府','大阪市','大阪府大阪市中央区淡路町4-4-3',34.687417,135.49917,null,null,'https://goryojinja.jp','船場の氏神。御霊文楽座でも知られる。','https://ja.wikipedia.org/wiki/御霊神社_(大阪市)','Wikipedia',true,now()),
('abeoji-jinja','阿倍王子神社','あべおうじじんじゃ','shrine','旧郷社','大阪府','大阪市','大阪府大阪市阿倍野区阿倍野元町9-4',34.631000,135.509111,null,null,'http://abeouji.tonosama.jp/','熊野九十九王子のひとつ。安倍晴明神社を境外社に持つ。','https://ja.wikipedia.org/wiki/阿倍王子神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nahaka-jinja' and d.slug in ('ame_no_futodama'))
or (t.slug='osake-jinja' and d.slug in ('hata_no_kawakatsu'))
or (t.slug='namba-yasaka-jinja' and d.slug in ('susanoo','kushinadahime'))
or (t.slug='abeoji-jinja' and d.slug in ('izanagi','izanami','susanoo','hachiman'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='osake-jinja' and d.slug in ('amaterasu'))
or (t.slug='goryo-jinja-osaka' and d.slug in ('amaterasu'))
on conflict do nothing;

-- ===== バッチ2 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('bishamonten','毘沙門天','びしゃもんてん','buddha','天部','{多聞天}','仏教','四天王の一。福徳と武運の守護神。','https://ja.wikipedia.org/wiki/毘沙門天','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方瑠璃光浄土の教主。病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('uji_no_wakiiratsuko','菟道稚郎子','うじのわきいらつこ','kami','人神','{}','記紀','応神天皇の皇子。学問の神として祀られる。','https://ja.wikipedia.org/wiki/菟道稚郎子','Wikipedia',true,now()),
('nintoku','仁徳天皇','にんとくてんのう','kami','人神','{大鷦鷯尊}','記紀','第16代天皇。仁政で知られる。','https://ja.wikipedia.org/wiki/仁徳天皇','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='bishamonten' and g.slug in ('shobu','kinun','yakubarai'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kanai_anzen'))
or (d.slug='uji_no_wakiiratsuko' and g.slug in ('gakugyo','gakumon','shusse'))
or (d.slug='nintoku' and g.slug in ('shobai','kaiun','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kyorinbo','教林坊','きょうりんぼう','temple','天台宗','滋賀県','近江八幡市','滋賀県近江八幡市安土町石寺1145',35.138889,136.163944,605,'赤川観音（聖観音）','https://kyourinbo.jimdofree.com/','小堀遠州作と伝わる庭園と紅葉で名高い石の寺。','https://ja.wikipedia.org/wiki/教林坊','Wikipedia',true,now()),
('bishamondo','毘沙門堂','びしゃもんどう','temple','天台宗','京都府','京都市','京都府京都市山科区安朱稲荷山町18',35.001611,135.818861,703,'毘沙門天','http://www.bishamon.or.jp/','天台宗の門跡寺院。紅葉の名所として知られる。','https://ja.wikipedia.org/wiki/毘沙門堂','Wikipedia',true,now()),
('ujigami-jinja','宇治上神社','うじがみじんじゃ','shrine','旧府社','京都府','宇治市','京都府宇治市宇治山田59',34.892111,135.811500,null,null,'https://www.ujikamijinja.jp','現存最古の神社建築をもつ世界遺産。','https://ja.wikipedia.org/wiki/宇治上神社','Wikipedia',true,now()),
('shoji-ji','勝持寺','しょうじじ','temple','天台宗','京都府','京都市','京都府京都市西京区大原野南春日町1194',34.960694,135.65167,679,'薬師如来','http://www.shoujiji.jp/','西行ゆかりの「花の寺」。桜と紅葉の名所。','https://ja.wikipedia.org/wiki/勝持寺','Wikipedia',true,now()),
('hokyoin','宝筐院','ほうきょういん','temple','臨済宗','京都府','京都市','京都府京都市右京区嵯峨釈迦堂門前南中院町9-1',35.022472,135.673583,null,'十一面千手観世音菩薩','https://www.houkyouin.jp/','嵯峨野の紅葉の名所。足利義詮と楠木正行の墓所。','https://ja.wikipedia.org/wiki/宝筐院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kyorinbo' and d.slug in ('sho_kannon'))
or (t.slug='bishamondo' and d.slug in ('bishamonten'))
or (t.slug='ujigami-jinja' and d.slug in ('uji_no_wakiiratsuko','hachiman','nintoku'))
or (t.slug='shoji-ji' and d.slug in ('yakushi_nyorai'))
or (t.slug='hokyoin' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- ===== バッチ3 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{摩訶毘盧遮那}','仏教','真言密教の根本仏。宇宙の真理を表す。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{釈迦牟尼仏}','仏教','仏教の開祖。悟りを開いた釈尊。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('haniyamahime','埴山姫命','はにやまひめのみこと','kami','国津神','{波邇夜須毘売}','記紀','土を司る女神。土木・陶器・農耕の神。','https://ja.wikipedia.org/wiki/ハニヤスビコ・ハニヤスビメ','Wikipedia',true,now()),
('niutsuhime','丹生都比売大神','にうつひめのおおかみ','kami','国津神','{丹生明神,稚日女尊}','記紀','水銀・水の女神。高野山の地主神。','https://ja.wikipedia.org/wiki/丹生都比売神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','majo_kekkai'))
or (d.slug='shaka_nyorai' and g.slug in ('byoki_heyu','jouju','kaiun'))
or (d.slug='haniyamahime' and g.slug in ('suisan_noko','shobai','kanai_anzen'))
or (d.slug='niutsuhime' and g.slug in ('majo_kekkai','yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('negoroji','根来寺','ねごろじ','temple','新義真言宗（総本山）','和歌山県','岩出市','和歌山県岩出市根来2286',34.28722,135.31667,1130,'大日如来','https://www.negoroji.org/','覚鑁が開いた新義真言宗の総本山。国宝の大塔で名高い。','https://ja.wikipedia.org/wiki/根来寺','Wikipedia',true,now()),
('chohoji','長保寺','ちょうほうじ','temple','天台宗','和歌山県','海南市','和歌山県海南市下津町上689',34.109111,135.165639,1000,'釈迦如来','http://www.chohoji.or.jp/','本堂・多宝塔・大門が国宝。紀州徳川家の菩提寺。','https://ja.wikipedia.org/wiki/長保寺','Wikipedia',true,now()),
('amanosan-kongoji','天野山金剛寺','あまのさんこんごうじ','temple','真言宗御室派（大本山）','大阪府','河内長野市','大阪府河内長野市天野町996',34.4295611,135.5290472,729,'大日如来','https://amanosan-kongoji.jp/','「女人高野」と称される古刹。南朝の行宮も置かれた。','https://ja.wikipedia.org/wiki/金剛寺_(河内長野市)','Wikipedia',true,now()),
('matsubara-hachiman-jinja','松原八幡神社','まつばらはちまんじんじゃ','shrine','旧県社','兵庫県','姫路市','兵庫県姫路市白浜町甲399',34.78551889,134.70618889,763,null,null,'「灘のけんか祭り」で知られる姫路の八幡宮。','https://ja.wikipedia.org/wiki/松原八幡神社','Wikipedia',true,now()),
('niu-jinja-taki','丹生神社','にうじんじゃ','shrine','式内社・旧村社','三重県','多気郡多気町','三重県多気郡多気町丹生3999',34.477611,136.493194,523,null,null,'水銀採掘ゆかりの式内社。伊勢椿の原木で知られる。','https://ja.wikipedia.org/wiki/丹生神社_(多気町)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='negoroji' and d.slug in ('dainichi_nyorai'))
or (t.slug='chohoji' and d.slug in ('shaka_nyorai'))
or (t.slug='amanosan-kongoji' and d.slug in ('dainichi_nyorai'))
or (t.slug='matsubara-hachiman-jinja' and d.slug in ('hachiman','jingu_kogo','ichikishima'))
or (t.slug='niu-jinja-taki' and d.slug in ('haniyamahime','niutsuhime'))
on conflict do nothing;

-- ===== バッチ4 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{無量寿仏,無量光仏}','仏教','西方極楽浄土の教主。極楽往生を導く仏。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('oishi_yoshio','大石良雄','おおいしよしお','kami','人神','{大石内蔵助}','史実','赤穂義士の筆頭。忠義の人として祀られる。','https://ja.wikipedia.org/wiki/大石良雄','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amida_nyorai' and g.slug in ('jouju','kaiun','byoki_heyu'))
or (d.slug='oishi_yoshio' and g.slug in ('shobu','gakugyo','shusse'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tenjuan','天授庵','てんじゅあん','temple','臨済宗南禅寺派','京都府','京都市','京都府京都市左京区南禅寺福地町86-8',35.010639,135.792250,1339,'釈迦如来','http://nanzenji.or.jp/','南禅寺の塔頭。枯山水と池泉庭園の紅葉で名高い。','https://ja.wikipedia.org/wiki/天授庵','Wikipedia',true,now()),
('entokuin','圓徳院','えんとくいん','temple','臨済宗建仁寺派','京都府','京都市','京都府京都市東山区下河原町530',35.000583,135.779389,1632,'釈迦如来','https://www.kodaiji.com/entoku-in/index.html','高台寺の塔頭。北政所ねね終焉の地。','https://ja.wikipedia.org/wiki/圓徳院','Wikipedia',true,now()),
('ako-oishi-jinja','赤穂大石神社','あこうおおいしじんじゃ','shrine','旧県社相当','兵庫県','赤穂市','兵庫県赤穂市上仮屋旧城内',34.74917,134.38861,1900,null,'http://www.ako-ooishijinjya.or.jp/','赤穂義士四十七士を祀る赤穂城内の神社。','https://ja.wikipedia.org/wiki/大石神社','Wikipedia',true,now()),
('gansenji','岩船寺','がんせんじ','temple','真言律宗','京都府','木津川市','京都府木津川市加茂町岩船上ノ門43',34.720250,135.885806,729,'阿弥陀如来','https://gansenji.or.jp/','国宝三重塔をもつ当尾の古刹。あじさい寺。','https://ja.wikipedia.org/wiki/岩船寺','Wikipedia',true,now()),
('joruriji','浄瑠璃寺','じょうるりじ','temple','真言律宗','京都府','木津川市','京都府木津川市加茂町西小札場40',34.7159361,135.8729194,1047,'阿弥陀如来（九体）',null,'九体阿弥陀堂と浄土庭園で知られる国宝の寺。','https://ja.wikipedia.org/wiki/浄瑠璃寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tenjuan' and d.slug in ('shaka_nyorai'))
or (t.slug='entokuin' and d.slug in ('shaka_nyorai'))
or (t.slug='ako-oishi-jinja' and d.slug in ('oishi_yoshio'))
or (t.slug='gansenji' and d.slug in ('amida_nyorai'))
or (t.slug='joruriji' and d.slug in ('amida_nyorai'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='joruriji' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- ===== バッチ5 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kuebiko','久延毘古命','くえびこのみこと','kami','国津神','{案山子の神}','記紀','知恵・学問の神。世のことを知り尽くす神とされる。','https://ja.wikipedia.org/wiki/クエビコ','Wikipedia',true,now()),
('nyoirin_kannon','如意輪観音','にょいりんかんのん','buddha','菩薩','{}','仏教','如意宝珠で衆生の願いを叶える観音。','https://ja.wikipedia.org/wiki/如意輪観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kuebiko' and g.slug in ('gakugyo','gakumon','shusse'))
or (d.slug='nyoirin_kannon' and g.slug in ('jouju','enmusubi','anzan'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kairyuoji','海龍王寺','かいりゅうおうじ','temple','真言律宗','奈良県','奈良市','奈良県奈良市法華寺北町897',34.6928972,135.8055528,731,'十一面観音','https://www.kairyuouji.jp/','光明皇后ゆかりの古刹。コスモス寺として親しまれる。','https://ja.wikipedia.org/wiki/海龍王寺','Wikipedia',true,now()),
('futaiji','不退寺','ふたいじ','temple','真言律宗','奈良県','奈良市','奈良県奈良市法蓮町517',34.6947833,135.8125222,845,'聖観音（業平観音）','http://www3.kcn.ne.jp/~futaiji/index.html','在原業平ゆかりの「業平寺」。','https://ja.wikipedia.org/wiki/不退寺','Wikipedia',true,now()),
('kuebiko-jinja','久延彦神社','くえひこじんじゃ','shrine','大神神社摂社','奈良県','桜井市','奈良県桜井市三輪',34.5309472,135.8514167,null,null,null,'大神神社の摂社。知恵・学業成就の神を祀る。','https://ja.wikipedia.org/wiki/久延彦神社','Wikipedia',true,now()),
('chuguji','中宮寺','ちゅうぐうじ','temple','聖徳宗','奈良県','生駒郡斑鳩町','奈良県生駒郡斑鳩町法隆寺北1-1-2',34.6149583,135.7395750,607,'如意輪観音（伝）','http://www.chuguji.jp/','法隆寺東院に隣接する尼寺。国宝半跏思惟像で名高い。','https://ja.wikipedia.org/wiki/中宮寺','Wikipedia',true,now()),
('kumedadera','久米田寺','くめだでら','temple','高野山真言宗','大阪府','岸和田市','大阪府岸和田市池尻町934',34.459389,135.411750,738,'釈迦如来','https://ja.wikipedia.org/wiki/久米田寺','行基が久米田池とともに開いた古刹。','https://ja.wikipedia.org/wiki/久米田寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kairyuoji' and d.slug in ('sho_kannon'))
or (t.slug='futaiji' and d.slug in ('sho_kannon'))
or (t.slug='kuebiko-jinja' and d.slug in ('kuebiko'))
or (t.slug='chuguji' and d.slug in ('nyoirin_kannon'))
or (t.slug='kumedadera' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== バッチ6 =====
-- ③ 社寺（新規神仏なし）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('unryuin','雲龍院','うんりゅういん','temple','真言宗泉涌寺派','京都府','京都市','京都府京都市東山区泉涌寺山内町36',34.977139,135.780111,1372,'薬師如来','http://www.unryuin.jp/','泉涌寺の別院。「悟りの間」の丸窓・角窓で知られる。','https://ja.wikipedia.org/wiki/雲龍院','Wikipedia',true,now()),
('genkouan','源光庵','げんこうあん','temple','曹洞宗','京都府','京都市','京都府京都市北区鷹峯北鷹峯町47',35.0548139,135.731722,1346,'釈迦如来','https://genkouan.or.jp/','「悟りの窓」「迷いの窓」と血天井で名高い禅寺。','https://ja.wikipedia.org/wiki/源光庵','Wikipedia',true,now()),
('rurikoin','瑠璃光院','るりこういん','temple','浄土真宗','京都府','京都市','京都府京都市左京区上高野東山55',35.063417,135.808611,2005,'阿弥陀如来','http://rurikoin.komyoji.com/','八瀬の名刹。机に映る「床もみじ」で知られる。','https://ja.wikipedia.org/wiki/瑠璃光院','Wikipedia',true,now()),
('jissoin','実相院','じっそういん','temple','単立（旧天台宗門跡）','京都府','京都市','京都府京都市左京区岩倉上蔵町121',35.0789639,135.7814833,1229,'不動明王','https://www.jissoin.com/','岩倉門跡。床に映る「床もみじ・床みどり」で名高い。','https://ja.wikipedia.org/wiki/実相院','Wikipedia',true,now()),
('jikishian','直指庵','じきしあん','temple','浄土宗','京都府','京都市','京都府京都市右京区北嵯峨北ノ段町3',35.033500,135.677028,1646,'阿弥陀如来','https://www5e.biglobe.ne.jp/~jikisian/','嵯峨野の紅葉の隠れ寺。「想い出草」で知られる。','https://ja.wikipedia.org/wiki/直指庵','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='unryuin' and d.slug in ('yakushi_nyorai'))
or (t.slug='genkouan' and d.slug in ('shaka_nyorai'))
or (t.slug='rurikoin' and d.slug in ('amida_nyorai'))
or (t.slug='jissoin' and d.slug in ('fudo_myoo'))
or (t.slug='jikishian' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== バッチ7 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenominakanushi','天御中主神','あめのみなかぬしのかみ','kami','天津神','{造化三神}','記紀','天地開闢の最初に現れた根源神。','https://ja.wikipedia.org/wiki/アメノミナカヌシ','Wikipedia',true,now()),
('takamimusubi','高皇産霊神','たかみむすひのかみ','kami','天津神','{造化三神}','記紀','万物を生み出す造化三神の一柱。','https://ja.wikipedia.org/wiki/タカミムスビ','Wikipedia',true,now()),
('kamimusubi','神皇産霊神','かみむすひのかみ','kami','天津神','{造化三神}','記紀','万物の生成を司る造化三神の一柱。','https://ja.wikipedia.org/wiki/カミムスビ','Wikipedia',true,now()),
('ebisu','蛭子神','えびすのかみ','kami','国津神','{恵比寿,事代主}','記紀','商売繁盛・漁業の福神。七福神の一。','https://ja.wikipedia.org/wiki/えびす','Wikipedia',true,now()),
('ukemochi','保食神','うけもちのかみ','kami','国津神','{}','記紀','食物を司る神。五穀豊穣の神。','https://ja.wikipedia.org/wiki/ウケモチ','Wikipedia',true,now()),
('nomi_no_sukune','野見宿禰','のみのすくね','kami','人神','{}','記紀','相撲の祖神。土師氏の祖。','https://ja.wikipedia.org/wiki/野見宿禰','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenominakanushi' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='takamimusubi' and g.slug in ('kaiun','enmusubi','shusse'))
or (d.slug='kamimusubi' and g.slug in ('kaiun','enmusubi','byoki_heyu'))
or (d.slug='ebisu' and g.slug in ('shobai','suisan_noko','kinun'))
or (d.slug='ukemochi' and g.slug in ('suisan_noko','shobai','kanai_anzen'))
or (d.slug='nomi_no_sukune' and g.slug in ('shobu','shusse','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('wada-jinja-kobe','和田神社','わだじんじゃ','shrine','旧村社','兵庫県','神戸市','兵庫県神戸市兵庫区和田宮通3',34.658111,135.173750,null,null,null,'和田岬の鎮守。天御中主大神・蛭子大神を祀る。','https://ja.wikipedia.org/wiki/和田神社_(神戸市)','Wikipedia',true,now()),
('hyotanyama-inari-jinja','瓢箪山稲荷神社','ひょうたんやまいなりじんじゃ','shrine','旧村社','大阪府','東大阪市','大阪府東大阪市瓢箪山町8-1',34.660750,135.642028,1583,null,null,'日本三大稲荷の一。辻占の総本社として知られる。','https://ja.wikipedia.org/wiki/瓢箪山稲荷神社','Wikipedia',true,now()),
('samuhara-jinja','サムハラ神社','さむはらじんじゃ','shrine','単立','大阪府','大阪市','大阪府大阪市西区立売堀2-5-26',34.678944,135.490972,1950,null,null,'造化三神を祀る。御守りで知られる人気の社。','https://ja.wikipedia.org/wiki/サムハラ神社','Wikipedia',true,now()),
('nomi-jinja-takatsuki','野見神社','のみじんじゃ','shrine','旧郷社','大阪府','高槻市','大阪府高槻市野見町6-6',34.84528,135.621250,887,null,null,'高槻城跡に鎮まる古社。永井神社を境内に持つ。','https://ja.wikipedia.org/wiki/野見神社_(高槻市)','Wikipedia',true,now()),
('katano-jinja','片埜神社','かたのじんじゃ','shrine','式内社・旧郷社','大阪府','枚方市','大阪府枚方市牧野阪2-21-15',34.841806,135.667639,null,null,null,'重要文化財の本殿をもつ河内国の鬼門守護社。','https://ja.wikipedia.org/wiki/片埜神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='wada-jinja-kobe' and d.slug in ('amenominakanushi','ichikishima','ebisu'))
or (t.slug='hyotanyama-inari-jinja' and d.slug in ('ukemochi'))
or (t.slug='samuhara-jinja' and d.slug in ('amenominakanushi','takamimusubi','kamimusubi'))
or (t.slug='nomi-jinja-takatsuki' and d.slug in ('susanoo','nomi_no_sukune'))
or (t.slug='katano-jinja' and d.slug in ('susanoo','michizane'))
on conflict do nothing;

-- ===== バッチ8 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('jundei_kannon','准胝観音','じゅんでいかんのん','buddha','菩薩','{准提観音}','仏教','清浄を司る観音。安産・子授けの仏。','https://ja.wikipedia.org/wiki/准胝観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='jundei_kannon' and g.slug in ('anzan','kosodate','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('matsuo-kannonji','松尾観音寺','まつおかんのんじ','temple','単立','三重県','伊勢市','三重県伊勢市楠部町156-6',34.487778,136.733361,712,'十一面観音','http://matsuokannonji.com/','日本最古の厄除観音と伝わる。龍神伝説で知られる。','https://ja.wikipedia.org/wiki/松尾観音寺','Wikipedia',true,now()),
('eshinin','恵心院','えしんいん','temple','真言宗智山派','京都府','宇治市','京都府宇治市宇治山田67',34.890306,135.811139,822,'十一面観音','https://ja.wikipedia.org/wiki/恵心院','源信ゆかりの宇治の「花の寺」。','https://ja.wikipedia.org/wiki/恵心院','Wikipedia',true,now()),
('chorakuji-kyoto','長楽寺','ちょうらくじ','temple','時宗','京都府','京都市','京都府京都市東山区円山町626',35.002583,135.783472,805,'准胝観音','http://www.age.ne.jp/x/chouraku/','円山公園奥の古刹。建礼門院ゆかりの紅葉の名所。','https://ja.wikipedia.org/wiki/長楽寺_(京都市)','Wikipedia',true,now()),
('imakumano-jinja','新熊野神社','いまくまのじんじゃ','shrine','旧村社','京都府','京都市','京都府京都市東山区今熊野椥ノ森町42',34.984611,135.773667,1160,null,'http://imakumanojinja.or.jp/','後白河院が勧請した京都三熊野の一。能楽発祥の地。','https://ja.wikipedia.org/wiki/新熊野神社','Wikipedia',true,now()),
('konomiya-jinja','胡宮神社','このみやじんじゃ','shrine','旧県社','滋賀県','犬上郡多賀町','滋賀県犬上郡多賀町敏満寺49',35.215222,136.286667,null,null,null,'敏満寺ゆかりの古社。国名勝の庭園を持つ。','https://ja.wikipedia.org/wiki/胡宮神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='matsuo-kannonji' and d.slug in ('sho_kannon'))
or (t.slug='eshinin' and d.slug in ('sho_kannon'))
or (t.slug='chorakuji-kyoto' and d.slug in ('jundei_kannon'))
or (t.slug='imakumano-jinja' and d.slug in ('izanami'))
or (t.slug='konomiya-jinja' and d.slug in ('izanagi','izanami'))
on conflict do nothing;

-- ===== バッチ9 =====
-- ③ 社寺（新規神仏なし）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('taizoin','退蔵院','たいぞういん','temple','臨済宗妙心寺派','京都府','京都市','京都府京都市右京区花園妙心寺町35',35.0218778,135.7192333,1404,'無因宗因禅師像','http://www.taizoin.com/','妙心寺の塔頭。国宝「瓢鮎図」と余香苑で名高い。','https://ja.wikipedia.org/wiki/退蔵院','Wikipedia',true,now()),
('keishunin','桂春院','けいしゅんいん','temple','臨済宗妙心寺派','京都府','京都市','京都府京都市右京区花園寺ノ中町11',35.0248528,135.7224333,1598,null,null,'妙心寺の塔頭。禅の四境地を表す四庭園で知られる。','https://ja.wikipedia.org/wiki/桂春院','Wikipedia',true,now()),
('hokyoji','宝鏡寺','ほうきょうじ','temple','臨済宗','京都府','京都市','京都府京都市上京区寺之内通堀川東入百々町547',35.0340389,135.7527417,1368,'聖観音菩薩','http://hokyoji.net/','人形供養で知られる尼門跡「人形寺」。','https://ja.wikipedia.org/wiki/宝鏡寺','Wikipedia',true,now()),
('zuihoin','瑞峯院','ずいほういん','temple','臨済宗大徳寺派','京都府','京都市','京都府京都市北区紫野大徳寺町81',35.0421472,135.7453861,1535,'観音菩薩','https://ja.wikipedia.org/wiki/瑞峯院','大徳寺の塔頭。大友宗麟の菩提寺。重森三玲の枯山水庭園。','https://ja.wikipedia.org/wiki/瑞峯院','Wikipedia',true,now()),
('korinin','興臨院','こうりんいん','temple','臨済宗大徳寺派','京都府','京都市','京都府京都市北区紫野大徳寺町80',35.042528,135.745556,1521,'釈迦如来','https://ja.wikipedia.org/wiki/興臨院','大徳寺の塔頭。畠山氏・前田家ゆかりの寺。','https://ja.wikipedia.org/wiki/興臨院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hokyoji' and d.slug in ('sho_kannon'))
or (t.slug='zuihoin' and d.slug in ('sho_kannon'))
or (t.slug='korinin' and d.slug in ('shaka_nyorai'))
on conflict do nothing;
