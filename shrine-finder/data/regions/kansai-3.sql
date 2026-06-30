-- 近畿 観光著名社寺 追加分 (kansai-3)
-- 担当: 三重・滋賀・京都・大阪・兵庫・奈良・和歌山
-- 全件 ja.wikipedia.org infobox の十進座標で裏取り済み

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ashinazuchi','足名椎命','あしなづちのみこと','kami','国津神','{}','記紀','奇稲田姫の父神。出雲神話の国津神。','https://ja.wikipedia.org/wiki/アシナヅチ・テナヅチ','Wikipedia',true,now()),
('tenazuchi','手名椎命','てなづちのみこと','kami','国津神','{}','記紀','奇稲田姫の母神。出雲神話の国津神。','https://ja.wikipedia.org/wiki/アシナヅチ・テナヅチ','Wikipedia',true,now()),
('goho_maoson','護法魔王尊','ごほうまおうそん','buddha','天部','{サナト・クマラ}','鞍馬弘教','鞍馬山の尊天の一尊。地球の霊王とされる。','https://ja.wikipedia.org/wiki/鞍馬寺','Wikipedia',true,now()),
('amekuma','天熊人命','あめのくまひとのみこと','kami','天津神','{}','記紀','保食神に遣わされた神。火伏せの愛宕信仰に祀られる。','https://ja.wikipedia.org/wiki/愛宕神社','Wikipedia',true,now()),
('wakumusubi','稚産霊神','わくむすひのかみ','kami','天津神','{}','記紀','五穀・養蚕を司る生産の神。','https://ja.wikipedia.org/wiki/ワクムスビ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ashinazuchi' and g.slug in ('enmusubi','kanai_anzen'))
or (d.slug='tenazuchi' and g.slug in ('enmusubi','kanai_anzen'))
or (d.slug='goho_maoson' and g.slug in ('kaiun','yakubarai','shobu'))
or (d.slug='amekuma' and g.slug in ('yakubarai','kanai_anzen'))
or (d.slug='wakumusubi' and g.slug in ('suisan_noko','shobai','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('imamiya-jinja-kyoto','今宮神社','いまみやじんじゃ','shrine','旧府社','京都府','京都市','京都府京都市北区紫野今宮町21',35.0456250,135.7420139,1001,null,'http://imamiyajinja.org/','「玉の輿神社」とも呼ばれる疫病鎮めの社。やすらい祭で名高い。','https://ja.wikipedia.org/wiki/今宮神社_(京都市)','Wikipedia',true,now()),
('jishu-jinja','地主神社','じしゅじんじゃ','shrine','旧村社','京都府','京都市','京都府京都市東山区清水1丁目317',34.995056,135.784972,null,null,'http://www.jishujinja.or.jp/','清水寺境内に鎮座する縁結びの神社。恋占いの石で有名。','https://ja.wikipedia.org/wiki/地主神社','Wikipedia',true,now()),
('kifune-jinja','貴船神社','きふねじんじゃ','shrine','旧官幣中社','京都府','京都市','京都府京都市左京区鞍馬貴船町180',35.121722,135.762833,666,null,'https://kifunejinja.jp/','水の神を祀る全国の貴船神社の総本社。絵馬発祥の地。','https://ja.wikipedia.org/wiki/貴船神社','Wikipedia',true,now()),
('kuramadera','鞍馬寺','くらまでら','temple','鞍馬弘教（総本山）','京都府','京都市','京都府京都市左京区鞍馬本町1074',35.1180611,135.7707417,770,'尊天（毘沙門天・千手観世音・護法魔王尊の三身一体）','http://www.kuramadera.or.jp/','鞍馬山に開かれた霊山。牛若丸（源義経）修行の地として知られる。','https://ja.wikipedia.org/wiki/鞍馬寺','Wikipedia',true,now()),
('atago-jinja-kyoto','愛宕神社','あたごじんじゃ','shrine','旧府社','京都府','京都市','京都府京都市右京区嵯峨愛宕町1',35.0599444,135.6344472,701,null,'http://atagojinjya.jp/','愛宕山頂に鎮座する火伏せの総本社。全国900社の愛宕神社の本社。','https://ja.wikipedia.org/wiki/愛宕神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='imamiya-jinja-kyoto' and d.slug in ('okuninushi','kotoshironushi','kushinadahime'))
or (t.slug='jishu-jinja' and d.slug in ('okuninushi','susanoo','kushinadahime','ashinazuchi','tenazuchi'))
or (t.slug='kifune-jinja' and d.slug in ('takaokami'))
or (t.slug='kuramadera' and d.slug in ('bishamonten','senju_kannon','goho_maoson'))
or (t.slug='atago-jinja-kyoto' and d.slug in ('izanami','haniyasuhime','amekuma','wakumusubi','toyouke'))
on conflict do nothing;

-- ===== バッチ2: 京都の名刹 =====
-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shinnyodo','真如堂（真正極楽寺）','しんにょどう','temple','天台宗','京都府','京都市','京都府京都市左京区浄土寺真如町82',35.0218944,135.7904167,984,'阿弥陀如来','https://shin-nyo-do.jp/','正式名は鈴聲山真正極楽寺。京都屈指の紅葉の名所。','https://ja.wikipedia.org/wiki/真正極楽寺','Wikipedia',true,now()),
('eikando-zenrinji','永観堂禅林寺','えいかんどうぜんりんじ','temple','浄土宗西山禅林寺派（総本山）','京都府','京都市','京都府京都市左京区永観堂町48',35.0145250,135.7952917,853,'阿弥陀如来（みかえり阿弥陀）','http://www.eikando.or.jp/','「秋はもみじの永観堂」と称される紅葉の名所。みかえり阿弥陀で有名。','https://ja.wikipedia.org/wiki/禅林寺_(京都市)','Wikipedia',true,now()),
('nanzenji','南禅寺','なんぜんじ','temple','臨済宗南禅寺派（大本山）','京都府','京都市','京都府京都市左京区南禅寺福地町86',35.0119833,135.794389,1291,'釈迦牟尼仏','https://www.nanzenji.or.jp/','京都五山・鎌倉五山の上に列せられる別格の禅刹。水路閣で有名。','https://ja.wikipedia.org/wiki/南禅寺','Wikipedia',true,now()),
('tofukuji','東福寺','とうふくじ','temple','臨済宗東福寺派（大本山）','京都府','京都市','京都府京都市東山区本町15丁目778',34.9770500,135.7740944,1236,'釈迦牟尼仏','https://tofukuji.jp/','京都五山の一つ。通天橋の紅葉と巨大な三門で知られる。','https://ja.wikipedia.org/wiki/東福寺','Wikipedia',true,now()),
('sennyuji','泉涌寺','せんにゅうじ','temple','真言宗泉涌寺派（総本山）','京都府','京都市','京都府京都市東山区泉涌寺山内町27',34.97806,135.780333,1218,'釈迦如来・阿弥陀如来・弥勒如来','https://www.mitera.org/','皇室の菩提寺「御寺（みてら）」。楊貴妃観音で名高い。','https://ja.wikipedia.org/wiki/泉涌寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shinnyodo' and d.slug in ('amida_nyorai'))
or (t.slug='eikando-zenrinji' and d.slug in ('amida_nyorai'))
or (t.slug='nanzenji' and d.slug in ('shaka_nyorai'))
or (t.slug='tofukuji' and d.slug in ('shaka_nyorai'))
or (t.slug='sennyuji' and d.slug in ('shaka_nyorai','amida_nyorai','miroku_nyorai'))
on conflict do nothing;
