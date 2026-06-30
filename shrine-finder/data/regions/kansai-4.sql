-- 近畿（三重・滋賀・京都・大阪・兵庫・奈良・和歌山）追加データ kansai-4
-- 仕様: ja.wikipedia.org infobox の十進座標で裏取り。_have_kansai.txt と重複なし。

-- ===== Batch 1 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sakatoke_no_kami','酒解神','さかとけのかみ','kami','国津神','{}','記紀','酒造の神。大山祇神と同一視される。','https://ja.wikipedia.org/wiki/梅宮大社','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土を主宰する如来。浄土信仰の本尊。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('shijoko_nyorai','熾盛光如来','しじょうこうにょらい','buddha','如来','{}','仏教','天台密教の最高仏とされる如来。除災を司る。','https://ja.wikipedia.org/wiki/青蓮院','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{}','仏教','十一の面を持つ変化観音。除災・滅罪の利益。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖、釈迦牟尼仏。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('honen','法然','ほうねん','buddha','高僧','{}','仏教','浄土宗の開祖。','https://ja.wikipedia.org/wiki/法然','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sakatoke_no_kami' and g.slug in ('shobai','enmusubi','anzan'))
   or (d.slug='amida_nyorai' and g.slug in ('kaiun','byoki_heyu','jouju'))
   or (d.slug='shijoko_nyorai' and g.slug in ('yakubarai','majo_kekkai','kaiun'))
   or (d.slug='juichimen_kannon' and g.slug in ('yakubarai','byoki_heyu','kaiun'))
   or (d.slug='shaka_nyorai' and g.slug in ('kaiun','byoki_heyu','jouju'))
   or (d.slug='honen' and g.slug in ('jouju','kaiun','gakumon'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('umenomiya-taisha','梅宮大社','うめのみやたいしゃ','shrine','梅宮大社','京都府','京都市','京都府京都市右京区梅津フケノ川町30',35.004111,135.694889,null,null,'http://www.umenomiya.or.jp','酒造・子授けの神として知られる古社。猫神社としても親しまれる。','https://ja.wikipedia.org/wiki/梅宮大社','Wikipedia',true,now()),
('rokuharamitsuji','六波羅蜜寺','ろくはらみつじ','temple','真言宗智山派','京都府','京都市','京都府京都市東山区松原通大和大路東入二丁目轆轤町81-1',34.9971028,135.7733083,951,'十一面観音','https://rokuhara.or.jp/','空也上人開創。空也上人立像で著名な西国札所の寺。','https://ja.wikipedia.org/wiki/六波羅蜜寺','Wikipedia',true,now()),
('kodaiji','高台寺','こうだいじ','temple','臨済宗建仁寺派','京都府','京都市','京都府京都市東山区下河原通八坂鳥居前下る下河原町526',35.0007611,135.7811139,1606,'釈迦如来','https://www.kodaiji.com/','北政所が秀吉の菩提を弔って創建。蒔絵と紅葉ライトアップの名所。','https://ja.wikipedia.org/wiki/高台寺','Wikipedia',true,now()),
('chionin','知恩院','ちおんいん','temple','浄土宗','京都府','京都市','京都府京都市東山区新橋通大和大路東入三丁目林下町400',35.0052083,135.7834028,1175,'阿弥陀如来','https://www.chion-in.or.jp','浄土宗総本山。日本最大級の三門で名高い大伽藍。','https://ja.wikipedia.org/wiki/知恩院','Wikipedia',true,now()),
('shorenin','青蓮院','しょうれんいん','temple','天台宗','京都府','京都市','京都府京都市東山区粟田口三条坊町69-1',35.0073111,135.7831972,1150,'熾盛光如来','http://www.shorenin.com/','天台宗門跡寺院。青不動と庭園・ライトアップで知られる。','https://ja.wikipedia.org/wiki/青蓮院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='umenomiya-taisha' and d.slug in ('sakatoke_no_kami'))
   or (t.slug='rokuharamitsuji' and d.slug in ('juichimen_kannon'))
   or (t.slug='kodaiji' and d.slug in ('shaka_nyorai'))
   or (t.slug='chionin' and d.slug in ('honen','amida_nyorai'))
   or (t.slug='shorenin' and d.slug in ('shijoko_nyorai'))
on conflict do nothing;

-- ===== Batch 2 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('abe_no_seimei','安倍晴明','あべのせいめい','kami','御霊','{}','史実','平安期の陰陽師。除災・魔除けの神として祀られる。','https://ja.wikipedia.org/wiki/安倍晴明','Wikipedia',true,now()),
('kiyohara_no_yorinari','清原頼業','きよはらのよりなり','kami','御霊','{車折明神}','史実','平安末期の儒学者。学問・約束事の神（車折明神）。','https://ja.wikipedia.org/wiki/清原頼業','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='abe_no_seimei' and g.slug in ('majo_kekkai','yakubarai','kaiun'))
   or (d.slug='kiyohara_no_yorinari' and g.slug in ('gakumon','jouju','shobai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daikakuji','大覚寺','だいかくじ','temple','真言宗大覚寺派','京都府','京都市','京都府京都市右京区嵯峨大沢町4',35.0282361,135.6777417,876,'五大明王','https://www.daikakuji.or.jp/','旧嵯峨御所。大沢池と華道嵯峨御流の本拠で知られる門跡寺院。','https://ja.wikipedia.org/wiki/大覚寺','Wikipedia',true,now()),
('shinsenen','神泉苑','しんせんえん','temple','東寺真言宗','京都府','京都市','京都府京都市中京区御池通神泉苑町東入ル門前町166',35.0113806,135.7483722,824,'聖観音','http://www.shinsenen.org/','平安京の禁苑に由来。空海の請雨伝説で名高い古刹。','https://ja.wikipedia.org/wiki/神泉苑','Wikipedia',true,now()),
('rozanji','廬山寺','ろざんじ','temple','天台圓浄宗','京都府','京都市','京都府京都市上京区寺町通広小路上ル北之辺町397',35.024583,135.7683472,938,'阿弥陀三尊','https://www7a.biglobe.ne.jp/~rozanji/','紫式部邸宅址と源氏庭で知られる天台の本山。','https://ja.wikipedia.org/wiki/廬山寺','Wikipedia',true,now()),
('seimei-jinja','晴明神社','せいめいじんじゃ','shrine','晴明神社','京都府','京都市','京都府京都市上京区堀川通一条上る晴明町806-1',35.027750,135.751028,1007,null,'https://www.seimeijinja.jp/','陰陽師・安倍晴明を祀る。五芒星と魔除けで人気の社。','https://ja.wikipedia.org/wiki/晴明神社','Wikipedia',true,now()),
('kurumazaki-jinja','車折神社','くるまざきじんじゃ','shrine','車折神社','京都府','京都市','京都府京都市右京区嵯峨朝日町23',35.01583,135.68917,1189,null,'http://www.kurumazakijinja.or.jp','清原頼業を祀る。芸能神社と祈念神石で知られる。','https://ja.wikipedia.org/wiki/車折神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daikakuji' and d.slug in ('fudo_myoo'))
   or (t.slug='shinsenen' and d.slug in ('sho_kannon'))
   or (t.slug='rozanji' and d.slug in ('amida_nyorai'))
   or (t.slug='seimei-jinja' and d.slug in ('abe_no_seimei'))
   or (t.slug='kurumazaki-jinja' and d.slug in ('kiyohara_no_yorinari'))
on conflict do nothing;

-- ===== Batch 3 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('futsunomitama','布都御魂大神','ふつのみたまのおおかみ','kami','国津神','{}','記紀','神剣に宿る霊威。武運・除災の神。','https://ja.wikipedia.org/wiki/石上神宮','Wikipedia',true,now()),
('yamato_okunitama','日本大国魂大神','やまとおおくにたまのおおかみ','kami','国津神','{}','記紀','大和国の国魂神。国土守護の神。','https://ja.wikipedia.org/wiki/大和神社','Wikipedia',true,now()),
('mizuhanome','罔象女神','みづはのめのかみ','kami','国津神','{}','記紀','水を司る女神。祈雨・止雨の神。','https://ja.wikipedia.org/wiki/ミヅハノメ','Wikipedia',true,now()),
('senju_kannon','千手観音','せんじゅかんのん','buddha','菩薩','{千手千眼観世音菩薩}','仏教','千の手で衆生を救う観音。除災・厄除の利益。','https://ja.wikipedia.org/wiki/千手観音','Wikipedia',true,now()),
('bishamonten','毘沙門天','びしゃもんてん','buddha','天部','{多聞天}','仏教','四天王の一。武運・財福を授ける守護神。','https://ja.wikipedia.org/wiki/毘沙門天','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='futsunomitama' and g.slug in ('yakubarai','shobu','byoki_heyu'))
   or (d.slug='yamato_okunitama' and g.slug in ('kaiun','yakubarai','kanai_anzen'))
   or (d.slug='mizuhanome' and g.slug in ('mizu_amagoi','suisan_noko','shobai'))
   or (d.slug='senju_kannon' and g.slug in ('yakubarai','byoki_heyu','kaiun'))
   or (d.slug='bishamonten' and g.slug in ('shobu','kinun','shobai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('isonokami-jingu','石上神宮','いそのかみじんぐう','shrine','石上神宮（旧官幣大社・名神大社）','奈良県','天理市','奈良県天理市布留町384',34.59778,135.85194,null,null,'http://www.isonokami.jp/','日本最古級の神宮。神剣布都御魂を祀る。','https://ja.wikipedia.org/wiki/石上神宮','Wikipedia',true,now()),
('oyamato-jinja','大和神社','おおやまとじんじゃ','shrine','大和神社（旧官幣大社・名神大社）','奈良県','天理市','奈良県天理市新泉町星山306',34.57083,135.83750,null,null,'http://ooyamatohp.net/','大和の国魂を祀る古社。戦艦大和ゆかりでも知られる。','https://ja.wikipedia.org/wiki/大和神社','Wikipedia',true,now()),
('niukawakami-jinja-naka','丹生川上神社','にうかわかみじんじゃ','shrine','丹生川上神社（旧官幣大社）','奈良県','吉野郡東吉野村','奈良県吉野郡東吉野村大字小968',34.390306,135.986333,675,null,'https://niukawakami-jinja.jp/','水の神を祀る祈雨・止雨の名社（中社）。','https://ja.wikipedia.org/wiki/丹生川上神社','Wikipedia',true,now()),
('matsuodera-yamatokoriyama','松尾寺','まつおでら','temple','真言宗醍醐派','奈良県','大和郡山市','奈良県大和郡山市山田町683',34.6336417,135.7281028,718,'千手千眼観世音菩薩','https://matsuodera.com/','日本最古の厄除霊場とされる古刹。バラの名所。','https://ja.wikipedia.org/wiki/松尾寺_(大和郡山市)','Wikipedia',true,now()),
('chogosonshiji','朝護孫子寺','ちょうごそんしじ','temple','信貴山真言宗','奈良県','生駒郡平群町','奈良県生駒郡平群町信貴山2280-1',34.60944,135.671278,587,'毘沙門天','http://www.sigisan.or.jp/','信貴山の毘沙門さん。聖徳太子伝説と張子の寅で名高い。','https://ja.wikipedia.org/wiki/朝護孫子寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='isonokami-jingu' and d.slug in ('futsunomitama'))
   or (t.slug='oyamato-jinja' and d.slug in ('yamato_okunitama'))
   or (t.slug='niukawakami-jinja-naka' and d.slug in ('mizuhanome'))
   or (t.slug='matsuodera-yamatokoriyama' and d.slug in ('senju_kannon'))
   or (t.slug='chogosonshiji' and d.slug in ('bishamonten'))
on conflict do nothing;

-- ===== Batch 4 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ikasuri_no_kami','坐摩神','いかすりのかみ','kami','国津神','{}','記紀','井戸・土地を守護する坐摩五神の総称。住居守護の神。','https://ja.wikipedia.org/wiki/坐摩神社','Wikipedia',true,now()),
('sukunabikona','少彦名命','すくなびこなのみこと','kami','国津神','{}','記紀','大国主と国造りをした医薬・酒造・温泉の神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('monju_bosatsu','文殊菩薩','もんじゅぼさつ','buddha','菩薩','{}','仏教','智慧を司る菩薩。学業成就の利益。','https://ja.wikipedia.org/wiki/文殊菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ikasuri_no_kami' and g.slug in ('kanai_anzen','yakubarai','anzan'))
   or (d.slug='sukunabikona' and g.slug in ('byoki_heyu','shobai','kaiun'))
   or (d.slug='monju_bosatsu' and g.slug in ('gakugyo','gakumon','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ikasuri-jinja','坐摩神社','いかすりじんじゃ','shrine','坐摩神社（旧官幣中社）','大阪府','大阪市','大阪府大阪市中央区久太郎町4丁目渡辺3号',34.68083,135.49861,null,null,'http://www.ikasuri.or.jp/','摂津国一宮。住居守護・安産の神を祀る古社。','https://ja.wikipedia.org/wiki/坐摩神社','Wikipedia',true,now()),
('tsuyutenjinsha','露天神社','つゆのてんじんしゃ','shrine','露天神社','大阪府','大阪市','大阪府大阪市北区曽根崎2-5-4',34.699278,135.500806,701,null,'http://www.tuyutenjin.com/','「お初天神」の通称で知られる曽根崎心中ゆかりの社。','https://ja.wikipedia.org/wiki/露天神社','Wikipedia',true,now()),
('mizumadera','水間寺','みずまでら','temple','天台宗','大阪府','貝塚市','大阪府貝塚市水間638',34.3988583,135.3856056,744,'聖観世音菩薩','http://www.mizumadera.or.jp/','行基開創と伝わる厄除観音。新西国札所。','https://ja.wikipedia.org/wiki/水間寺','Wikipedia',true,now()),
('hattori-tenjingu','服部天神宮','はっとりてんじんぐう','shrine','服部天神宮','大阪府','豊中市','大阪府豊中市服部元町1丁目2-17',34.763028,135.475972,null,null,'https://hattoritenjingu.or.jp/','「足の神様」として知られる天神信仰の社。','https://ja.wikipedia.org/wiki/服部天神宮','Wikipedia',true,now()),
('ebaraji','家原寺','えばらじ','temple','行基宗','大阪府','堺市','大阪府堺市西区家原寺町1丁8-20',34.537472,135.474667,704,'文殊菩薩','https://www.chiemonjyuebaraji.jp/','行基生誕地に建つ「智恵の文殊」。合格祈願で名高い。','https://ja.wikipedia.org/wiki/家原寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ikasuri-jinja' and d.slug in ('ikasuri_no_kami'))
   or (t.slug='tsuyutenjinsha' and d.slug in ('michizane','okuninushi','amaterasu'))
   or (t.slug='mizumadera' and d.slug in ('sho_kannon'))
   or (t.slug='hattori-tenjingu' and d.slug in ('michizane','sukunabikona'))
   or (t.slug='ebaraji' and d.slug in ('monju_bosatsu'))
on conflict do nothing;

-- ===== Batch 5 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenohiboko','天日槍命','あめのひぼこのみこと','kami','国津神','{}','記紀','新羅から渡来したと伝わる神。但馬開拓の祖神。','https://ja.wikipedia.org/wiki/アメノヒボコ','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方瑠璃光浄土の如来。病気平癒の本尊。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('ame_no_mikage','天之御影命','あめのみかげのみこと','kami','天津神','{}','記紀','鍛冶・刀剣の祖神。御上神社の祭神。','https://ja.wikipedia.org/wiki/御上神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenohiboko' and g.slug in ('kaiun','shobai','suisan_noko'))
   or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','kaiun','choju'))
   or (d.slug='ame_no_mikage' and g.slug in ('shobu','shobai','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nofukuji','能福寺','のうふくじ','temple','天台宗','兵庫県','神戸市','兵庫県神戸市兵庫区北逆瀬川町1-39',34.6679889,135.1713917,805,'阿弥陀如来','http://nofukuji.jp/','平清盛ゆかりの古刹。兵庫大仏で知られる。','https://ja.wikipedia.org/wiki/能福寺','Wikipedia',true,now()),
('iwa-jinja','伊和神社','いわじんじゃ','shrine','伊和神社（旧国幣中社・名神大社）','兵庫県','宍粟市','兵庫県宍粟市一宮町須行名407',35.087528,134.586472,null,null,null,'播磨国一宮。大己貴神を祀る古社。','https://ja.wikipedia.org/wiki/伊和神社','Wikipedia',true,now()),
('izushi-jinja','出石神社','いずしじんじゃ','shrine','出石神社（旧国幣中社・名神大社）','兵庫県','豊岡市','兵庫県豊岡市出石町宮内99',35.4819444,134.8702861,null,null,null,'但馬国一宮。天日槍命を祀る。','https://ja.wikipedia.org/wiki/出石神社','Wikipedia',true,now()),
('kakurinji-kakogawa','鶴林寺','かくりんじ','temple','天台宗','兵庫県','加古川市','兵庫県加古川市加古川町北在家424',34.752278,134.832583,589,'薬師如来','https://www.kakurinji.or.jp/','聖徳太子創建伝承。「播磨の法隆寺」と称される古刹。','https://ja.wikipedia.org/wiki/鶴林寺_(加古川市)','Wikipedia',true,now()),
('mikami-jinja','御上神社','みかみじんじゃ','shrine','御上神社（旧官幣中社・名神大社）','滋賀県','野洲市','滋賀県野洲市三上838',35.05000,136.027361,null,null,'http://www.mikami-jinja.jp/','近江富士・三上山を神体とする。国宝本殿で名高い。','https://ja.wikipedia.org/wiki/御上神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nofukuji' and d.slug in ('amida_nyorai'))
   or (t.slug='iwa-jinja' and d.slug in ('okuninushi'))
   or (t.slug='izushi-jinja' and d.slug in ('amenohiboko'))
   or (t.slug='kakurinji-kakogawa' and d.slug in ('yakushi_nyorai'))
   or (t.slug='mikami-jinja' and d.slug in ('ame_no_mikage'))
on conflict do nothing;

-- ===== Batch 6 =====
-- （新規神仏なし。既存slugを使用）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shirahige-jinja','白鬚神社','しらひげじんじゃ','shrine','白鬚神社','滋賀県','高島市','滋賀県高島市鵜川215',35.2745139,136.0110889,null,null,'http://shirahigejinja.com/','琵琶湖に立つ湖中大鳥居で名高い近江最古の大社。','https://ja.wikipedia.org/wiki/白鬚神社','Wikipedia',true,now()),
('saikyoji','西教寺','さいきょうじ','temple','天台真盛宗','滋賀県','大津市','滋賀県大津市坂本5丁目13-1',35.081556,135.866056,618,'阿弥陀如来','http://www.saikyoji.org/','天台真盛宗総本山。明智光秀一族の菩提寺。','https://ja.wikipedia.org/wiki/西教寺','Wikipedia',true,now()),
('hyozu-taisha','兵主大社','ひょうずたいしゃ','shrine','兵主大社（旧県社・名神大社）','滋賀県','野洲市','滋賀県野洲市五条566',35.115278,136.010111,718,null,null,'八千矛神を祀る古社。国名勝の池泉庭園で知られる。','https://ja.wikipedia.org/wiki/兵主大社','Wikipedia',true,now()),
('dojoji','道成寺','どうじょうじ','temple','天台宗','和歌山県','日高郡日高川町','和歌山県日高郡日高川町鐘巻1738',33.914500,135.174556,701,'千手観音','http://www.dojoji.com/','安珍清姫伝説と絵解き説法で名高い和歌山最古の寺。','https://ja.wikipedia.org/wiki/道成寺','Wikipedia',true,now()),
('tsubaki-nakato-jinja','都波岐神社・奈加等神社','つばきなかとじんじゃ','shrine','都波岐奈加等神社（旧県社）','三重県','鈴鹿市','三重県鈴鹿市一ノ宮町1181',34.901250,136.601250,null,null,null,'伊勢国一宮。猿田彦大神を祀る古社。','https://ja.wikipedia.org/wiki/都波岐奈加等神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shirahige-jinja' and d.slug in ('sarutahiko'))
   or (t.slug='saikyoji' and d.slug in ('amida_nyorai'))
   or (t.slug='hyozu-taisha' and d.slug in ('okuninushi'))
   or (t.slug='dojoji' and d.slug in ('senju_kannon'))
   or (t.slug='tsubaki-nakato-jinja' and d.slug in ('sarutahiko'))
on conflict do nothing;

-- ===== Batch 7 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('aizen_myoo','愛染明王','あいぜんみょうおう','buddha','明王','{}','仏教','愛欲を悟りに昇華させる明王。縁結び・恋愛成就の利益。','https://ja.wikipedia.org/wiki/愛染明王','Wikipedia',true,now()),
('kumano_sanshojin','熊野三所権現','くまのさんしょごんげん','kami','御霊','{熊野三所神}','記紀','熊野信仰の主神。家都美御子・速玉・牟須美の総称。','https://ja.wikipedia.org/wiki/熊野権現','Wikipedia',true,now()),
('kitabatake_akiyoshi','北畠顕能','きたばたけあきよし','kami','御霊','{}','史実','南北朝期の伊勢国司・北畠氏の祖。','https://ja.wikipedia.org/wiki/北畠顕能','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='aizen_myoo' and g.slug in ('enmusubi','renai','jouju'))
   or (d.slug='kumano_sanshojin' and g.slug in ('kaiun','yakubarai','tabi_anzen'))
   or (d.slug='kitabatake_akiyoshi' and g.slug in ('shobu','kaiun','gakumon'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kongosanmaiin','金剛三昧院','こんごうさんまいいん','temple','高野山真言宗','和歌山県','伊都郡高野町','和歌山県伊都郡高野町高野山425',34.210222,135.586972,1211,'愛染明王','http://www.kongosanmaiin.or.jp','北条政子建立の高野山宿坊。国宝多宝塔で名高い。','https://ja.wikipedia.org/wiki/金剛三昧院','Wikipedia',true,now()),
('jisonin','慈尊院','じそんいん','temple','高野山真言宗','和歌山県','伊都郡九度山町','和歌山県伊都郡九度山町慈尊院832',34.29528,135.55000,816,'弥勒仏','http://jison-in.org/','空海ゆかりの高野山表玄関。女人高野として名高い。','https://ja.wikipedia.org/wiki/慈尊院','Wikipedia',true,now()),
('niukanshofu-jinja','丹生官省符神社','にうかんしょうぶじんじゃ','shrine','丹生官省符神社','和歌山県','伊都郡九度山町','和歌山県伊都郡九度山町慈尊院835',34.294222,135.549444,816,null,null,'空海創建と伝わる慈尊院鎮守。世界遺産の社。','https://ja.wikipedia.org/wiki/丹生官省符神社','Wikipedia',true,now()),
('tokei-jinja','闘鶏神社','とうけいじんじゃ','shrine','闘鶏神社（旧県社）','和歌山県','田辺市','和歌山県田辺市東陽1-1',33.729694,135.38389,419,null,'https://www.toukeijinja.or.jp/','弁慶の父・湛増ゆかり。熊野詣の世界遺産の社。','https://ja.wikipedia.org/wiki/闘鶏神社','Wikipedia',true,now()),
('kitabatake-jinja','北畠神社','きたばたけじんじゃ','shrine','北畠神社（旧別格官幣社）','三重県','津市','三重県津市美杉町上多気1148',34.518556,136.298861,1643,null,null,'伊勢国司北畠氏を祀る。国名勝の武家庭園で知られる。','https://ja.wikipedia.org/wiki/北畠神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kongosanmaiin' and d.slug in ('aizen_myoo'))
   or (t.slug='jisonin' and d.slug in ('miroku_nyorai'))
   or (t.slug='niukanshofu-jinja' and d.slug in ('niutsuhime'))
   or (t.slug='tokei-jinja' and d.slug in ('kumano_sanshojin'))
   or (t.slug='kitabatake-jinja' and d.slug in ('kitabatake_akiyoshi'))
on conflict do nothing;

-- ===== Batch 8 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nyoirin_kannon','如意輪観音','にょいりんかんのん','buddha','菩薩','{}','仏教','如意宝珠と法輪を持つ観音。福徳・智慧の利益。','https://ja.wikipedia.org/wiki/如意輪観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nyoirin_kannon' and g.slug in ('kaiun','byoki_heyu','jouju'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('komyoji-nagaokakyo','光明寺','こうみょうじ','temple','西山浄土宗','京都府','長岡京市','京都府長岡京市粟生西条ノ内26-1',34.9384667,135.6751889,1198,'法然上人像','http://www.komyo-ji.or.jp/','西山浄土宗総本山。紅葉の「もみじ参道」で名高い。','https://ja.wikipedia.org/wiki/光明寺_(長岡京市)','Wikipedia',true,now()),
('yoshiminedera','善峯寺','よしみねでら','temple','善峰観音宗','京都府','京都市','京都府京都市西京区大原野小塩町1372',34.938167,135.644194,1029,'十一面千手観世音菩薩','http://www.yoshiminedera.com/','西国札所。天然記念物の遊龍の松と眺望で名高い。','https://ja.wikipedia.org/wiki/善峯寺','Wikipedia',true,now()),
('kajuji','勧修寺','かじゅうじ','temple','真言宗山階派','京都府','京都市','京都府京都市山科区勧修寺仁王堂町27-6',34.9617694,135.8075750,900,'千手観音','https://kajuji.jp/','醍醐天皇創建の門跡寺院。氷室池の睡蓮と杜若で名高い。','https://ja.wikipedia.org/wiki/勧修寺','Wikipedia',true,now()),
('zuishinin','隨心院','ずいしんいん','temple','真言宗善通寺派','京都府','京都市','京都府京都市山科区小野御霊町35',34.9594944,135.8162861,991,'如意輪観音','https://www.zuishinin.or.jp/','小野小町ゆかりの門跡寺院。はねず梅で名高い。','https://ja.wikipedia.org/wiki/隨心院','Wikipedia',true,now()),
('hokongoin','法金剛院','ほうこんごういん','temple','律宗','京都府','京都市','京都府京都市右京区花園扇野町49',35.0191583,135.7159389,830,'阿弥陀如来','http://houkongouin.com/','待賢門院ゆかりの「蓮の寺」。極楽浄土の庭で名高い。','https://ja.wikipedia.org/wiki/法金剛院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='komyoji-nagaokakyo' and d.slug in ('honen'))
   or (t.slug='yoshiminedera' and d.slug in ('senju_kannon'))
   or (t.slug='kajuji' and d.slug in ('senju_kannon'))
   or (t.slug='zuishinin' and d.slug in ('nyoirin_kannon'))
   or (t.slug='hokongoin' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== Batch 9 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nigihayahi','饒速日尊','にぎはやひのみこと','kami','天津神','{}','記紀','天孫降臨以前に河内に天降ったとされる神。物部氏の祖神。','https://ja.wikipedia.org/wiki/ニギハヤヒ','Wikipedia',true,now()),
('umashimade','可美真手命','うましまでのみこと','kami','天津神','{宇摩志麻遅命}','記紀','饒速日尊の子。物部氏の祖。','https://ja.wikipedia.org/wiki/ウマシマヂ','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{牛頭天王}','記紀','天照大神の弟。厄除け・疫病退散の荒神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('shiotsuchi','塩土老翁神','しおつちのおじのかみ','kami','国津神','{}','記紀','航海・製塩・知恵を司る老翁神。','https://ja.wikipedia.org/wiki/シオツチノオジ','Wikipedia',true,now()),
('ikukunitama','生国魂神','いくくにたまのかみ','kami','国津神','{}','記紀','国土の生成霊。難波の地主神。','https://ja.wikipedia.org/wiki/生國魂神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nigihayahi' and g.slug in ('byoki_heyu','kaiun','shobu'))
   or (d.slug='umashimade' and g.slug in ('kaiun','yakubarai','shobai'))
   or (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','enmusubi'))
   or (d.slug='shiotsuchi' and g.slug in ('kaijo_anzen','anzan','kaiun'))
   or (d.slug='ikukunitama' and g.slug in ('kaiun','kanai_anzen','shobai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mozu-hachimangu','百舌鳥八幡宮','もずはちまんぐう','shrine','百舌鳥八幡宮（旧府社）','大阪府','堺市','大阪府堺市北区百舌鳥赤畑町5-706',34.554139,135.49472,null,null,'http://www.mozu8.com/','「ふとん太鼓」の月見祭で名高い八幡宮。','https://ja.wikipedia.org/wiki/百舌鳥八幡宮','Wikipedia',true,now()),
('ishikiri-tsurugiya-jinja','石切剣箭神社','いしきりつるぎやじんじゃ','shrine','石切剣箭神社（旧村社）','大阪府','東大阪市','大阪府東大阪市東石切町1丁目1-1',34.682194,135.646250,null,null,'http://www.ishikiri.or.jp/','「石切さん」。でんぼ（腫物）の神として名高い。','https://ja.wikipedia.org/wiki/石切剣箭神社','Wikipedia',true,now()),
('takidani-fudoson','瀧谷不動明王寺','たきだにふどうみょうおうじ','temple','真言宗智山派','大阪府','富田林市','大阪府富田林市彼方1762',34.4765500,135.5952306,821,'不動明王','http://www.takidanifudouson.or.jp/','日本三大不動の一。眼病平癒の「目の不動さん」。','https://ja.wikipedia.org/wiki/瀧谷不動明王寺','Wikipedia',true,now()),
('shipporyuji','七宝瀧寺','しっぽうりゅうじ','temple','真言宗犬鳴派','大阪府','泉佐野市','大阪府泉佐野市大木8',34.338500,135.387389,661,'倶利伽羅大龍不動明王','http://www.inunakisan.jp/','役行者開創と伝わる犬鳴山の修験道根本道場。','https://ja.wikipedia.org/wiki/七宝瀧寺','Wikipedia',true,now()),
('aguchi-jinja','開口神社','あぐちじんじゃ','shrine','開口神社（旧府社）','大阪府','堺市','大阪府堺市堺区甲斐町東2丁目1番29号',34.576861,135.474583,null,null,'http://www.aguchi.jp/','堺の氏神「大寺さん」。与謝野晶子ゆかりの社。','https://ja.wikipedia.org/wiki/開口神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='mozu-hachimangu' and d.slug in ('hachiman'))
   or (t.slug='ishikiri-tsurugiya-jinja' and d.slug in ('nigihayahi','umashimade'))
   or (t.slug='takidani-fudoson' and d.slug in ('fudo_myoo'))
   or (t.slug='shipporyuji' and d.slug in ('fudo_myoo'))
   or (t.slug='aguchi-jinja' and d.slug in ('shiotsuchi','susanoo','ikukunitama'))
on conflict do nothing;

-- ===== Batch 10 =====
-- （新規神仏なし。既存slugを使用）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sumadera','須磨寺','すまでら','temple','真言宗須磨寺派','兵庫県','神戸市','兵庫県神戸市須磨区須磨寺町4丁目6-8',34.64972,135.111806,886,'聖観音','https://www.sumadera.or.jp/','源平一ノ谷の合戦と平敦盛ゆかりの古刹。新西国札所。','https://ja.wikipedia.org/wiki/須磨寺','Wikipedia',true,now()),
('hiromine-jinja','廣峯神社','ひろみねじんじゃ','shrine','広峯神社（旧県社）','兵庫県','姫路市','兵庫県姫路市広嶺山52',34.873778,134.700333,734,null,'https://hiromine.or.jp/','全国の牛頭天王・天神信仰の総本宮とされる古社。','https://ja.wikipedia.org/wiki/広峯神社','Wikipedia',true,now()),
('taisanji-kobe','太山寺','たいさんじ','temple','天台宗','兵庫県','神戸市','兵庫県神戸市西区伊川谷町前開224',34.696333,135.067250,716,'薬師如来','http://www.do-main.co.jp/taisanji/','神戸唯一の国宝建造物・本堂で名高い天台の古刹。','https://ja.wikipedia.org/wiki/太山寺_(神戸市)','Wikipedia',true,now()),
('awashima-jinja','淡嶋神社','あわしまじんじゃ','shrine','淡嶋神社（旧郷社）','和歌山県','和歌山市','和歌山県和歌山市加太116',34.273694,135.066500,null,null,'http://www.kada.jp/awashima/','全国淡島信仰の総本社。雛流しと人形供養で名高い。','https://ja.wikipedia.org/wiki/淡嶋神社','Wikipedia',true,now()),
('onsenji-kinosaki','温泉寺','おんせんじ','temple','高野山真言宗','兵庫県','豊岡市','兵庫県豊岡市城崎町湯島985-2',35.62424,134.80051,738,'十一面観音','https://kinosaki-onsenji.jp/','城崎温泉の守護寺。ロープウェイで登る山上伽藍。','https://ja.wikipedia.org/wiki/温泉寺_(豊岡市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='sumadera' and d.slug in ('sho_kannon'))
   or (t.slug='hiromine-jinja' and d.slug in ('susanoo','itakeru'))
   or (t.slug='taisanji-kobe' and d.slug in ('yakushi_nyorai'))
   or (t.slug='awashima-jinja' and d.slug in ('sukunabikona','okuninushi','jingu_kogo'))
   or (t.slug='onsenji-kinosaki' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- ===== Batch 11 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yuki_munehiro','結城宗広','ゆうきむねひろ','kami','御霊','{}','史実','建武の新政に功あった南朝の武将。','https://ja.wikipedia.org/wiki/結城宗広','Wikipedia',true,now()),
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{}','仏教','無限の福徳と智慧を蔵する菩薩。記憶力・知恵の利益。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now()),
('aburahi_okami','油日大神','あぶらひのおおかみ','kami','国津神','{}','記紀','甲賀の地主神。武運・火・油の神。','https://ja.wikipedia.org/wiki/油日神社','Wikipedia',true,now()),
('namura_okami','苗村大神','なむらのおおかみ','kami','国津神','{}','記紀','近江竜王の地主神。五穀豊穣・子孫繁栄の神。','https://ja.wikipedia.org/wiki/苗村神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yuki_munehiro' and g.slug in ('shobu','kaiun','gakumon'))
   or (d.slug='kokuzo_bosatsu' and g.slug in ('gakugyo','gakumon','kaiun'))
   or (d.slug='aburahi_okami' and g.slug in ('shobu','shobai','yakubarai'))
   or (d.slug='namura_okami' and g.slug in ('suisan_noko','kosodate','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yuki-jinja-tsu','結城神社','ゆうきじんじゃ','shrine','結城神社（旧別格官幣社）','三重県','津市','三重県津市藤方2341',34.697750,136.515222,1824,null,'https://www.yuukijinja.com/','南朝の忠臣結城宗広を祀る。しだれ梅の名所。','https://ja.wikipedia.org/wiki/結城神社','Wikipedia',true,now()),
('tsu-kannon','津観音','つかんのん','temple','真言宗醍醐派','三重県','津市','三重県津市大門32-19',34.7206667,136.5132194,709,'聖観音','https://www.tsukannon.com/','日本三観音の一。恵日山観音寺大宝院。','https://ja.wikipedia.org/wiki/津観音','Wikipedia',true,now()),
('kongoshoji','金剛證寺','こんごうしょうじ','temple','臨済宗南禅寺派','三重県','伊勢市','三重県伊勢市朝熊町548',34.4574111,136.7854333,null,'虚空蔵菩薩','https://www.kongoshoji.or.jp/','朝熊山上の伊勢神宮の鬼門守護。「伊勢の奥の院」。','https://ja.wikipedia.org/wiki/金剛證寺','Wikipedia',true,now()),
('aburahi-jinja','油日神社','あぶらひじんじゃ','shrine','油日神社（旧県社）','滋賀県','甲賀市','滋賀県甲賀市甲賀町油日1042',34.887028,136.249722,null,null,'http://www.aburahijinjya.jp/','甲賀の総鎮守。重文の楼門・回廊が一直線に並ぶ古社。','https://ja.wikipedia.org/wiki/油日神社','Wikipedia',true,now()),
('namura-jinja','苗村神社','なむらじんじゃ','shrine','苗村神社（旧県社）','滋賀県','蒲生郡竜王町','滋賀県蒲生郡竜王町大字綾戸467',35.064861,136.127917,null,null,'https://namurajinjya.ryuoh.org/','33年に一度の大祭で知られる。国宝西本殿で名高い。','https://ja.wikipedia.org/wiki/苗村神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yuki-jinja-tsu' and d.slug in ('yuki_munehiro'))
   or (t.slug='tsu-kannon' and d.slug in ('sho_kannon'))
   or (t.slug='kongoshoji' and d.slug in ('kokuzo_bosatsu'))
   or (t.slug='aburahi-jinja' and d.slug in ('aburahi_okami'))
   or (t.slug='namura-jinja' and d.slug in ('namura_okami'))
on conflict do nothing;

-- ===== Batch 12 =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('jizo_bosatsu','地蔵菩薩','じぞうぼさつ','buddha','菩薩','{}','仏教','六道の衆生を救う菩薩。子授け・安産・子供守護の利益。','https://ja.wikipedia.org/wiki/地蔵菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏のご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='jizo_bosatsu' and g.slug in ('kosodate','anzan','byoki_heyu'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hokiji','法起寺','ほうきじ','temple','聖徳宗','奈良県','生駒郡斑鳩町','奈良県生駒郡斑鳩町大字岡本1873',34.622972,135.746222,638,'十一面観音','http://www.horyuji.or.jp/hokiji','日本最古の三重塔で名高い世界遺産。法隆寺の北東に位置。','https://ja.wikipedia.org/wiki/法起寺','Wikipedia',true,now()),
('akishinodera','秋篠寺','あきしのでら','temple','単立','奈良県','奈良市','奈良県奈良市秋篠町757',34.7031611,135.7756444,776,'薬師如来','https://akishinodera.or.jp/','伎芸天像と苔の境内で名高い古刹。','https://ja.wikipedia.org/wiki/秋篠寺','Wikipedia',true,now()),
('hannyaji','般若寺','はんにゃじ','temple','真言律宗','奈良県','奈良市','奈良県奈良市般若寺町221',34.7000611,135.8362167,629,'文殊菩薩','https://www.hannyaji.com/','「コスモス寺」として名高い。国宝楼門で知られる。','https://ja.wikipedia.org/wiki/般若寺','Wikipedia',true,now()),
('obitokedera','帯解寺','おびとけでら','temple','華厳宗','奈良県','奈良市','奈良県奈良市今市町734',34.6448500,135.8268361,858,'地蔵菩薩','https://www.obitokedera.or.jp/','日本最古の安産祈願霊場とされる「帯解子安地蔵」。','https://ja.wikipedia.org/wiki/帯解寺','Wikipedia',true,now()),
('jurinin','十輪院','じゅうりんいん','temple','真言宗醍醐派','奈良県','奈良市','奈良県奈良市十輪院町27',34.676278,135.833194,1283,'地蔵菩薩','http://www.jurin-in.com/','石仏龕と住宅風の国宝本堂で名高い奈良町の古刹。','https://ja.wikipedia.org/wiki/十輪院','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hokiji' and d.slug in ('juichimen_kannon'))
   or (t.slug='akishinodera' and d.slug in ('yakushi_nyorai'))
   or (t.slug='hannyaji' and d.slug in ('monju_bosatsu'))
   or (t.slug='obitokedera' and d.slug in ('jizo_bosatsu'))
   or (t.slug='jurinin' and d.slug in ('jizo_bosatsu'))
on conflict do nothing;
