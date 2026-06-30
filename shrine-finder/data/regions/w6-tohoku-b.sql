-- ============================================================
-- 御朱印ナビ 地域データ: 東北B（宮城・秋田・山形・福島）追加ティア
-- 対象県: 宮城, 秋田, 山形, 福島
-- 全件 ja.wikipedia.org の infobox を WebFetch で裏取り（十進緯度経度あり）
-- 既存 _have_hokkaido-tohoku.txt と重複させない
-- 5件ごとに追記保存
-- ============================================================

-- ───────────────────────── ① 新規神仏 ─────────────────────────
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{武甕槌命,建御雷之男神}','記紀','雷と剣を司る武神。鹿島・春日の神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now()),
('futsunushi','経津主神','ふつぬしのかみ','kami','天津神','{経津主命,斎主神}','記紀','刀剣・武の神。香取神宮の主祭神。','https://ja.wikipedia.org/wiki/フツヌシ','Wikipedia',true,now()),
('hayatama','速玉之男命','はやたまのおのみこと','kami','国津神','{熊野速玉大神}','記紀','熊野三山の一柱。誓約・再生の神。','https://ja.wikipedia.org/wiki/ハヤタマノオ','Wikipedia',true,now()),
('izanami','伊弉冉尊','いざなみのみこと','kami','天津神','{伊邪那美命,熊野夫須美大神}','記紀','国生み・神生みの母神。死と再生を司る。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{摩訶毘盧遮那,湯殿山権現}','仏教','密教の根本仏。宇宙の真理そのものとされる。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ② 新規神仏の司るご利益 ─────────────────────────
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','kaiun'))
or (d.slug='futsunushi'    and g.slug in ('shobu','yakubarai','shusse'))
or (d.slug='hayatama'      and g.slug in ('enmusubi','yakubarai','jouju'))
or (d.slug='izanami'       and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','jouju'))
on conflict do nothing;

-- ───────────────────────── ③ 社寺 ─────────────────────────
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values

-- ── 宮城 ──
('taga-jinja-tagajo','多賀神社','たがじんじゃ','shrine','人物神','宮城県','多賀城市','宮城県多賀城市高崎1-14-13',38.300389,140.998056,796,null,null,'近江多賀大社を勧請した多賀城の古社。武甕槌命・経津主命を祀る。','https://ja.wikipedia.org/wiki/多賀神社_(多賀城市)','Wikipedia',true,now()),
('kumano-jinja-natori','熊野神社','くまのじんじゃ','shrine','熊野系','宮城県','名取市','宮城県名取市高舘熊野堂字岩口上51',38.203000,140.846750,1123,null,null,'名取熊野三社の一。紀州熊野を勧請した東北の熊野信仰の中心。','https://ja.wikipedia.org/wiki/熊野神社_(名取市)','Wikipedia',true,now()),

-- ── 秋田 ──
('asahiokayama-jinja','旭岡山神社','あさひおかやまじんじゃ','shrine','山岳信仰','秋田県','横手市','秋田県横手市大沢字旭岡1',39.295528,140.584472,807,null,null,'横手の梵天奉納祭で知られる山岳信仰の古社。','https://ja.wikipedia.org/wiki/旭岡山神社','Wikipedia',true,now()),

-- ── 山形 ──
('dainichibou','大日坊','だいにちぼう','temple','真言宗豊山派','山形県','鶴岡市','山形県鶴岡市大網字入道11',38.592528,139.900361,825,'湯殿山権現（胎蔵界大日如来）','http://www.dainichibou.or.jp/','湯殿山の女人入口。真如海上人の即身仏で知られる名刹。','https://ja.wikipedia.org/wiki/大日坊','Wikipedia',true,now()),
('kaikoji-sakata','海向寺','かいこうじ','temple','真言宗智山派','山形県','酒田市','山形県酒田市日吉町2-7-12',38.919214,139.830433,800,'胎蔵界大日如来（湯殿山権現）','https://kaikouji-sakata.jimdofree.com/','忠海・円明の二体の即身仏を安置する湯殿山系の寺。','https://ja.wikipedia.org/wiki/海向寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ④ 御祭神/本尊の紐付け ─────────────────────────
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='taga-jinja-tagajo'   and d.slug in ('takemikazuchi','futsunushi'))
or (t.slug='kumano-jinja-natori' and d.slug in ('hayatama','izanami'))
or (t.slug='asahiokayama-jinja'  and d.slug in ('ukanomitama'))
or (t.slug='dainichibou'         and d.slug in ('dainichi_nyorai'))
or (t.slug='kaikoji-sakata'      and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- ===== バッチ2 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{無量寿仏,無量光仏}','仏教','西方極楽浄土の教主。念仏者を浄土へ導く。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('ajisukitakahikone','味耜高彦根神','あぢすきたかひこねのかみ','kami','国津神','{都々古別大神,阿遅鉏高日子根}','記紀','大国主の子。農耕・雷の神。都々古別神社の祭神。','https://ja.wikipedia.org/wiki/アヂスキタカヒコネ','Wikipedia',true,now()),
('yamatotakeru','日本武尊','やまとたけるのみこと','kami','御霊','{倭建命}','記紀','景行天皇の皇子。東征の英雄神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('tagirihime','田心姫神','たぎりひめのかみ','kami','宗像三女神','{多紀理姫命,田霧姫}','記紀','宗像三女神の一柱。海上交通の守護神。','https://ja.wikipedia.org/wiki/タギリビメ','Wikipedia',true,now()),
('tagitsuhime','湍津姫神','たぎつひめのかみ','kami','宗像三女神','{多岐都比売命}','記紀','宗像三女神の一柱。海上交通の守護神。','https://ja.wikipedia.org/wiki/タギツヒメ','Wikipedia',true,now()),
('byakue_kannon','白衣観音','びゃくえかんのん','buddha','菩薩','{白衣大士,白処観音}','仏教','白衣をまとう観音。安産・延命の徳をもつ。','https://ja.wikipedia.org/wiki/白衣観音','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amida_nyorai'      and g.slug in ('jouju','byoki_heyu','kaiun'))
or (d.slug='ajisukitakahikone' and g.slug in ('suisan_noko','shobai','kaiun'))
or (d.slug='yamatotakeru'      and g.slug in ('shobu','shusse','tabi_anzen'))
or (d.slug='tagirihime'        and g.slug in ('kaijo_anzen','kotsu_anzen','kaiun'))
or (d.slug='tagitsuhime'       and g.slug in ('kaijo_anzen','kotsu_anzen','kaiun'))
or (d.slug='byakue_kannon'     and g.slug in ('anzan','choju','byoki_heyu'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- ── 福島 ──
('shiramizu-amidado','白水阿弥陀堂','しらみずあみだどう','temple','真言宗智山派','福島県','いわき市','福島県いわき市内郷白水町広畑221',37.036514,140.837269,1160,'阿弥陀如来','http://shiramizu-amidado.org/','願成寺の阿弥陀堂。福島県唯一の国宝建造物。浄土庭園で名高い。','https://ja.wikipedia.org/wiki/白水阿弥陀堂','Wikipedia',true,now()),
('tsutsukowake-yatsuki','八槻都々古別神社','やつきつつこわけじんじゃ','shrine','人物神','福島県','東白川郡棚倉町','福島県東白川郡棚倉町八槻字大宮224',36.994531,140.392100,811,null,null,'陸奥国一宮の論社。味耜高彦根命・日本武尊を祀る古社。','https://ja.wikipedia.org/wiki/都々古別神社_(八槻)','Wikipedia',true,now()),
('tsutsukowake-baba','馬場都々古別神社','ばばつつこわけじんじゃ','shrine','人物神','福島県','東白川郡棚倉町','福島県東白川郡棚倉町棚倉字馬場39',37.032072,140.375917,807,null,null,'陸奥国一宮の論社。棚倉城跡近くに鎮座する古社。','https://ja.wikipedia.org/wiki/都々古別神社_(馬場)','Wikipedia',true,now()),
('okitsushima-jinja-nihonmatsu','隠津島神社','おきつしまじんじゃ','shrine','宗像三女神','福島県','二本松市','福島県二本松市木幡字治家49',37.622194,140.577111,769,null,'http://okitushima.com/','木幡山に鎮座。宗像三女神を祀り「木幡の弁天様」と親しまれる。','https://ja.wikipedia.org/wiki/隠津島神社_(二本松市)','Wikipedia',true,now()),
-- ── 山形 ──
('nangakuji','南岳寺','なんがくじ','temple','真言宗智山派','山形県','鶴岡市','山形県鶴岡市砂田町3-6',38.724000,139.823000,null,'大日如来','https://nangakuji.jp/','鉄龍海上人の即身仏を安置する湯殿山系の寺。','https://ja.wikipedia.org/wiki/南岳寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shiramizu-amidado'  and d.slug in ('amida_nyorai'))
or (t.slug='tsutsukowake-yatsuki' and d.slug in ('ajisukitakahikone','yamatotakeru'))
or (t.slug='tsutsukowake-baba'    and d.slug in ('ajisukitakahikone','yamatotakeru'))
or (t.slug='okitsushima-jinja-nihonmatsu' and d.slug in ('ichikishima','tagirihime','tagitsuhime'))
or (t.slug='nangakuji'            and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- ===== バッチ3 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{釈迦牟尼仏,能仁}','仏教','仏教の開祖・釈迦を仏格化した如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{十一面観世音菩薩}','仏教','十一の顔をもつ変化観音。除災・延命を司る。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now()),
('kokuzo_bosatsu','虚空蔵菩薩','こくうぞうぼさつ','buddha','菩薩','{虚空蔵}','仏教','無限の知恵と福徳を蔵する菩薩。記憶力・知恵を授ける。','https://ja.wikipedia.org/wiki/虚空蔵菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shaka_nyorai'     and g.slug in ('yakubarai','byoki_heyu','jouju'))
or (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','choju','yakubarai'))
or (d.slug='kokuzo_bosatsu'   and g.slug in ('gakugyo','gakumon','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- ── 宮城 ──
('daikanmitsuji','大観密寺','だいかんみつじ','temple','真言宗智山派','宮城県','仙台市','宮城県仙台市泉区実沢字中山南31-36',38.300889,140.823111,1991,'白衣大観音','http://www.daikannon.com/','高さ100mの仙台大観音で知られる泉区の寺。','https://ja.wikipedia.org/wiki/大観密寺','Wikipedia',true,now()),
-- ── 秋田 ──
('hodaji-akita','補陀寺','ふだじ','temple','曹洞宗','秋田県','秋田市','秋田県秋田市山内字松原26',39.766806,140.166833,1349,'釈迦牟尼仏','https://hodaji.jp/','秋田三十三観音第23番。秋田藩ゆかりの曹洞宗古刹。','https://ja.wikipedia.org/wiki/補陀寺_(秋田市)','Wikipedia',true,now()),
('chokokuji-yurihonjo','長谷寺','ちょうこくじ','temple','曹洞宗','秋田県','由利本荘市','秋田県由利本荘市赤田字上田表115',39.428111,140.103000,1775,'十一面観世音菩薩','https://akatadaibutsu.com/','赤田大仏で知られ、日本三大長谷観音の一とされる。','https://ja.wikipedia.org/wiki/長谷寺_(由利本荘市)','Wikipedia',true,now()),
-- ── 福島 ──
('jigenji-kitakata','示現寺','じげんじ','temple','曹洞宗','福島県','喜多方市','福島県喜多方市熱塩加納町熱塩795',37.729167,139.886028,1375,'虚空蔵菩薩','https://www.jigenji.com/','熱塩温泉の禅刹。会津三十三観音第5番。','https://ja.wikipedia.org/wiki/示現寺','Wikipedia',true,now()),
('tenneiji-aizu','天寧寺','てんねいじ','temple','曹洞宗','福島県','会津若松市','福島県会津若松市東山町石山字天寧208',37.490222,139.953028,1447,'釈迦牟尼仏',null,'蘆名氏の菩提寺。新選組局長・近藤勇の墓で知られる。','https://ja.wikipedia.org/wiki/天寧寺_(会津若松市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daikanmitsuji'        and d.slug in ('byakue_kannon'))
or (t.slug='hodaji-akita'         and d.slug in ('shaka_nyorai'))
or (t.slug='chokokuji-yurihonjo'  and d.slug in ('juichimen_kannon'))
or (t.slug='jigenji-kitakata'     and d.slug in ('kokuzo_bosatsu'))
or (t.slug='tenneiji-aizu'        and d.slug in ('shaka_nyorai'))
on conflict do nothing;
