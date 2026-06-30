-- w6-kanto-a.sql : 関東(茨城・栃木・群馬・埼玉) 著名社寺データ
-- 担当: データ整備エージェント / 出典: ja.wikipedia.org infobox 十進座標で裏取り
-- 仕様: AGENT_SPEC.md 厳守。_have_kanto.txt と重複しないもののみ。

-- ① 新規神仏 -------------------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('susanoo','須佐之男命','すさのおのみこと','kami','天津神','{}','記紀','天照大神の弟。八岐大蛇退治の英雄神で厄除・除災の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('izanagi','伊邪那岐命','いざなぎのみこと','kami','天津神','{}','記紀','国生み・神生みを行った男神。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('izanami','伊邪那美命','いざなみのみこと','kami','天津神','{}','記紀','国生み・神生みを行った女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('sukunahikona','少彦名命','すくなひこなのみこと','kami','国津神','{}','記紀','大国主と国造りを行った医薬・酒造の神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('kagutsuchi','火産霊神','ほむすびのかみ','kami','天津神','{}','記紀','火の神。鎮火・火防の神。','https://ja.wikipedia.org/wiki/カグツチ','Wikipedia',true,now()),
('haniyasuhime','埴山姫神','はにやまひめのかみ','kami','国津神','{}','記紀','土の神。土・農耕の守護神。','https://ja.wikipedia.org/wiki/ハニヤスビコ・ハニヤスビメ','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','病気平癒を司る東方浄瑠璃世界の如来。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益 -------------------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','enmusubi'))
or (d.slug='izanagi' and g.slug in ('enmusubi','kanai_anzen','kaiun'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='sukunahikona' and g.slug in ('byoki_heyu','shobai','shusse'))
or (d.slug='kagutsuchi' and g.slug in ('yakubarai','kaiun'))
or (d.slug='haniyasuhime' and g.slug in ('suisan_noko','kanai_anzen'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','byoki_heyu'))
on conflict do nothing;

-- 追加神仏(随時) ---------------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kunisazuchi','国狭槌尊','くにのさづちのみこと','kami','天津神','{}','記紀','神世七代の一柱。国土の神。','https://ja.wikipedia.org/wiki/クニノサツチ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ③ 社寺 (batch 1: 茨城3・群馬1) ----------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nishikanasa-jinja','西金砂神社','にしかなさじんじゃ','shrine',null,'茨城県','常陸太田市','茨城県常陸太田市上宮河内町1915',36.65722,140.45000,806,null,null,'標高418mの断崖上に鎮座する古社。72年に一度の磯出大祭礼で知られる。','https://ja.wikipedia.org/wiki/西金砂山','Wikipedia',true,now()),
('soga-jinja-omitama','素鵞神社','そがじんじゃ','shrine',null,'茨城県','小美玉市','茨城県小美玉市小川古城1658-1',36.171500,140.358389,1529,null,'https://www.sogajinja.com/','約500年続く祇園祭で知られる旧天王宮。','https://ja.wikipedia.org/wiki/素鵞神社_(小美玉市)','Wikipedia',true,now()),
('atago-jinja-kasama','愛宕神社','あたごじんじゃ','shrine',null,'茨城県','笠間市','茨城県笠間市泉101',36.2919361,140.2545919,806,null,null,'日本三大火防神社の一つ。標高305mの愛宕山に鎮座し悪態まつりで有名。','https://ja.wikipedia.org/wiki/愛宕神社_(笠間市)','Wikipedia',true,now()),
('jigenin-takasaki','慈眼院','じげんいん','temple','高野山真言宗','群馬県','高崎市','群馬県高崎市石原町2710-1',36.310750,138.98111,null,'聖観音','https://takasakikannon.or.jp/','高崎白衣大観音で知られる高野山真言宗の寺院。','https://ja.wikipedia.org/wiki/慈眼院_(高崎市)','Wikipedia',true,now()),
('sairenji-namegata','西蓮寺','さいれんじ','temple','天台宗','茨城県','行方市','茨城県行方市西蓮寺504',36.071750,140.439139,782,'薬師如来',null,'「常陸の高野山」と称される天台宗の古刹。国指定重文の相輪橖を有す。','https://ja.wikipedia.org/wiki/西蓮寺_(行方市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け (batch 1) --------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nishikanasa-jinja' and d.slug in ('okuninushi','sukunahikona','kunisazuchi'))
or (t.slug='soga-jinja-omitama' and d.slug in ('susanoo'))
or (t.slug='atago-jinja-kasama' and d.slug in ('izanami'))
or (t.slug='jigenin-takasaki' and d.slug in ('sho_kannon'))
or (t.slug='sairenji-namegata' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- 追加神仏 (batch 2用) ---------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('omononushi','大物主神','おおものぬしのかみ','kami','国津神','{}','記紀','三輪山の神。国造り・厄除の神。','https://ja.wikipedia.org/wiki/オオモノヌシ','Wikipedia',true,now()),
('gamou_kumpei','蒲生君平','がもうくんぺい','kami','御霊','{}','史実','江戸後期の儒学者・尊皇家。学問の神として祀られる。','https://ja.wikipedia.org/wiki/蒲生君平','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ③ 社寺 (batch 2: 埼玉2・栃木1・茨城1・群馬1) ------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('gyoda-hachiman-jinja','行田八幡神社','ぎょうだはちまんじんじゃ','shrine',null,'埼玉県','行田市','埼玉県行田市行田16-23',36.13889,140.46139,null,null,'https://gyodahachiman.jp/','封じの宮として知られる行田の総鎮守。','https://ja.wikipedia.org/wiki/行田八幡神社','Wikipedia',true,now()),
('senba-toshogu','仙波東照宮','せんばとうしょうぐう','shrine',null,'埼玉県','川越市','埼玉県川越市小仙波町1-21-1',35.916444,139.489306,1617,null,null,'日本三大東照宮の一つ。徳川家康を祀る。','https://ja.wikipedia.org/wiki/仙波東照宮','Wikipedia',true,now()),
('gamo-jinja-utsunomiya','蒲生神社','がもうじんじゃ','shrine',null,'栃木県','宇都宮市','栃木県宇都宮市羽下町5丁目',36.568222,139.885250,1930,null,null,'尊皇家・蒲生君平を祀る学問の神。','https://ja.wikipedia.org/wiki/蒲生神社','Wikipedia',true,now()),
('isobe-inamura-jinja','磯部稲村神社','いそべいなむらじんじゃ','shrine',null,'茨城県','桜川市','茨城県桜川市磯部',36.368306,140.141111,111,null,null,'磯部桜川公園の桜で名高い式内社の論社。','https://ja.wikipedia.org/wiki/磯部稲村神社','Wikipedia',true,now()),
('ikaho-jinja','伊香保神社','いかほじんじゃ','shrine',null,'群馬県','渋川市','群馬県渋川市伊香保町伊香保',36.495917,138.91583,825,null,null,'伊香保温泉の石段街上に鎮座する上野国三宮。','https://ja.wikipedia.org/wiki/伊香保神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 紐付け (batch 2) ----------------------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='gyoda-hachiman-jinja' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='senba-toshogu' and d.slug in ('ieyasu'))
or (t.slug='gamo-jinja-utsunomiya' and d.slug in ('gamou_kumpei'))
or (t.slug='isobe-inamura-jinja' and d.slug in ('amaterasu'))
or (t.slug='ikaho-jinja' and d.slug in ('okuninushi','sukunahikona'))
on conflict do nothing;

-- 追加神仏 (batch 3用) ---------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kunitokotachi','国常立尊','くにのとこたちのみこと','kami','天津神','{}','記紀','天地開闢に最初に現れた根源神。','https://ja.wikipedia.org/wiki/クニノトコタチ','Wikipedia',true,now()),
('sanqing','三清道祖','さんせいどうそ','buddha','天部','{}','道教','道教の最高神。元始天尊・霊宝天尊・道徳天尊の三尊。','https://ja.wikipedia.org/wiki/三清','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ③ 社寺 (batch 3: 茨城1・埼玉2・群馬1・栃木1) ------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kabasan-jinja','加波山神社','かばさんじんじゃ','shrine',null,'茨城県','石岡市','茨城県石岡市大塚',36.299750,140.143806,null,null,null,'加波山を御神体とする山岳信仰の古社。きせる祭で知られる。','https://ja.wikipedia.org/wiki/加波山神社','Wikipedia',true,now()),
('seitenkyu-sakado','聖天宮','せいてんきゅう','temple','道教','埼玉県','坂戸市','埼玉県坂戸市塚越51-1',35.9634611,139.4272972,1995,'三清道祖','https://www.seitenkyu.com/','日本最大級の道教廟。台湾様式の壮麗な建築で知られる。','https://ja.wikipedia.org/wiki/聖天宮','Wikipedia',true,now()),
('furuoya-hachiman-jinja','古尾谷八幡神社','ふるおやはちまんじんじゃ','shrine',null,'埼玉県','川越市','埼玉県川越市古谷本郷1408',35.904028,139.549139,863,null,null,'ほろ祭(県無形民俗文化財)で知られる古社。','https://ja.wikipedia.org/wiki/古尾谷八幡神社','Wikipedia',true,now()),
('ikushina-jinja','生品神社','いくしなじんじゃ','shrine',null,'群馬県','太田市','群馬県太田市新田市野井町645',36.317472,139.307444,null,null,null,'新田義貞の旗揚げの地として知られる国史跡。','https://ja.wikipedia.org/wiki/生品神社','Wikipedia',true,now()),
('yasuzumi-jinja','安住神社','やすずみじんじゃ','shrine',null,'栃木県','高根沢町','栃木県塩谷郡高根沢町上高根沢2313',36.5911500,140.0301722,899,null,'https://yasuzumi.com/','日本初のバイク神社として知られる。','https://ja.wikipedia.org/wiki/安住神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 紐付け (batch 3) ----------------------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kabasan-jinja' and d.slug in ('kunitokotachi','izanagi','izanami'))
or (t.slug='seitenkyu-sakado' and d.slug in ('sanqing'))
or (t.slug='furuoya-hachiman-jinja' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='ikushina-jinja' and d.slug in ('okuninushi'))
or (t.slug='yasuzumi-jinja' and d.slug in ('sumiyoshi','jingu_kogo'))
on conflict do nothing;
