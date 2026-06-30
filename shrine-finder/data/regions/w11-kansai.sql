-- w11-kansai.sql  近畿(7府県)社寺データ拡張 第11弾
-- 仕様: AGENT_SPEC.md 準拠。_have_kansai.txt と重複しない著名社寺。
-- ja.wikipedia.org infobox の十進座標で裏取り済み。座標無しは除外。

-- ===== バッチ1 (1-5) =====
-- 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ikomatsuhiko','伊古麻都比古神','いこまつひこのかみ','kami','国津神','{}','社伝','生駒の地主神。往馬大社の主祭神。','https://ja.wikipedia.org/wiki/往馬大社','Wikipedia',true,now()),
('ikomatsuhime','伊古麻都比賣神','いこまつひめのかみ','kami','国津神','{}','社伝','生駒の地主神。往馬大社の主祭神。','https://ja.wikipedia.org/wiki/往馬大社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ikomatsuhiko' and g.slug in ('kaiun','kanai_anzen'))
or (d.slug='ikomatsuhime' and g.slug in ('kaiun','kanai_anzen'))
on conflict do nothing;

-- 神峯山寺(大阪/高槻), 往馬大社(奈良/生駒), 久度神社(奈良/王寺), 許波多神社(京都/宇治), 龍田大社は既収録のため除外→廣峯も既収録
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kabusan-ji','神峯山寺','かぶさんじ','temple','天台宗','大阪府','高槻市','大阪府高槻市原3301-1',34.897611,135.608833,697,'毘沙門天','http://www.kabusan.or.jp/','日本最初の毘沙門天安置の霊場と伝わる古刹。新西国三十三箇所第14番。','https://ja.wikipedia.org/wiki/神峯山寺','Wikipedia',true,now()),
('ikoma-taisha','往馬大社','いこまたいしゃ','shrine','往馬坐伊古麻都比古神社（式内大社・旧県社）','奈良県','生駒市','奈良県生駒市壱分町1527-1',34.67806,135.70361,null,null,'https://ikomataisha.or.jp/','生駒山を神体とする式内大社。火祭りで知られる古社。','https://ja.wikipedia.org/wiki/往馬大社','Wikipedia',true,now()),
('kudo-jinja-oji','久度神社_(王寺町)','くどじんじゃ','shrine','久度神社（式内社・旧村社）','奈良県','北葛城郡王寺町','奈良県北葛城郡王寺町久度4丁目9-1',34.59917,135.69778,null,null,null,'竈の神・久度大神を祀る式内社。783年に官社に列せられた。','https://ja.wikipedia.org/wiki/久度神社_(王寺町)','Wikipedia',true,now()),
('kohata-jinja','許波多神社','こはたじんじゃ','shrine','許波多神社（式内社・旧村社）','京都府','宇治市','京都府宇治市五ヶ庄古川13',34.91667,135.79389,645,null,null,'天忍穂耳尊を祀る式内社。大化年間の創建と伝わる。','https://ja.wikipedia.org/wiki/許波多神社','Wikipedia',true,now()),
('sakurai-jinja-sakai','桜井神社_(堺市)','さくらいじんじゃ','shrine','桜井神社（式内社・旧府社）','大阪府','堺市','大阪府堺市南区片蔵645',34.485417,135.506167,null,null,null,'堺市唯一の国宝・拝殿を有する式内社。上神谷のこおどりで知られる。','https://ja.wikipedia.org/wiki/桜井神社_(堺市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kabusan-ji' and d.slug in ('bishamonten'))
or (t.slug='ikoma-taisha' and d.slug in ('ikomatsuhiko','ikomatsuhime'))
or (t.slug='kudo-jinja-oji' and d.slug in ('kudo_no_okami'))
or (t.slug='kohata-jinja' and d.slug in ('amenooshihomimi'))
or (t.slug='sakurai-jinja-sakai' and d.slug in ('hachiman','chuai','jingu_kogo'))
on conflict do nothing;

-- ===== バッチ2 (6-10) =====
-- 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('akaruhime','阿迦留姫命','あかるひめのみこと','kami','国津神','{}','記紀','天日槍の妻と伝わる女神。姫嶋神社の主祭神で再出発の神。','https://ja.wikipedia.org/wiki/姫嶋神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='akaruhime' and g.slug in ('kaiun','shusse','jouju'))
on conflict do nothing;

-- 御霊神社(大阪/中央), 野田恵美須神社(大阪/福島), 大江神社(大阪/天王寺), 姫嶋神社(大阪/西淀川), 阿遅速雄神社(大阪/鶴見)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('goryo-jinja-osaka','御霊神社_(大阪市)','ごりょうじんじゃ','shrine','御霊神社（旧府社）','大阪府','大阪市','大阪府大阪市中央区淡路町4-4-3',34.687417,135.49917,null,null,'https://www.goryojinja.jp/','船場の総鎮守。御霊文楽座があったことで知られる。','https://ja.wikipedia.org/wiki/御霊神社_(大阪市)','Wikipedia',true,now()),
('noda-ebisu-jinja','野田恵美須神社','のだえびすじんじゃ','shrine','野田恵美須神社（旧村社）','大阪府','大阪市','大阪府大阪市福島区玉川4-1-1',34.6884,135.4793,1115,null,null,'野田の戎さんとして親しまれる商売繁盛の社。','https://ja.wikipedia.org/wiki/野田恵美須神社','Wikipedia',true,now()),
('oe-jinja-osaka','大江神社_(大阪市)','おおえじんじゃ','shrine','大江神社（旧村社）','大阪府','大阪市','大阪府大阪市天王寺区夕陽丘町5-40',34.65694,135.512028,null,null,null,'四天王寺七宮の一。狛虎で知られ阪神タイガースファンの参拝で有名。','https://ja.wikipedia.org/wiki/大江神社_(大阪市)','Wikipedia',true,now()),
('himejima-jinja','姫嶋神社','ひめじまじんじゃ','shrine','姫嶋神社（旧郷社）','大阪府','大阪市','大阪府大阪市西淀川区姫島4-14-2',34.704611,135.453167,null,null,'https://himejimajinja.com/','やりなおし神社として知られる再出発・決断の社。','https://ja.wikipedia.org/wiki/姫嶋神社','Wikipedia',true,now()),
('ajihayao-jinja','阿遅速雄神社','あぢはやおじんじゃ','shrine','阿遅速雄神社（式内社・旧郷社）','大阪府','大阪市','大阪府大阪市鶴見区放出東3-31-18',34.68861,135.56472,668,null,null,'草薙剣が一時奉安されたと伝わる式内社。樹齢千年の楠を有す。','https://ja.wikipedia.org/wiki/阿遅速雄神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='goryo-jinja-osaka' and d.slug in ('amaterasu_aramitama','hachiman','kamakura_gongoro'))
or (t.slug='noda-ebisu-jinja' and d.slug in ('ebisu','amaterasu','hachiman'))
or (t.slug='oe-jinja-osaka' and d.slug in ('toyouke','susanoo','okuninushi','sukunahikona'))
or (t.slug='himejima-jinja' and d.slug in ('akaruhime','sumiyoshi'))
or (t.slug='ajihayao-jinja' and d.slug in ('ajisukitakahikone'))
on conflict do nothing;

-- ===== バッチ3 (11-15) =====
-- 松帆神社(兵庫/淡路), 由良湊神社(兵庫/洲本), 濱宮(和歌山/和歌山), 加太春日神社(和歌山/和歌山), 賀多神社(三重/鳥羽)
-- 新規神仏なし(既存柱のみ)
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('matsuho-jinja','松帆神社','まつほじんじゃ','shrine','松帆神社（旧村社）','兵庫県','淡路市','兵庫県淡路市久留麻256',34.534139,134.988944,1339,null,null,'楠木正成ゆかりの八幡社。国指定重要文化財の太刀「菊一文字」を蔵す。','https://ja.wikipedia.org/wiki/松帆神社','Wikipedia',true,now()),
('yuraminato-jinja','由良湊神社','ゆらみなとじんじゃ','shrine','由良湊神社（式内社・旧郷社）','兵庫県','洲本市','兵庫県洲本市由良3丁目5-2',34.292306,134.94333,null,null,null,'由良の湊の鎮守。ねりこ祭りで知られる式内社。','https://ja.wikipedia.org/wiki/由良湊神社','Wikipedia',true,now()),
('hamanomiya-wakayama','濱宮','はまのみや','shrine','濱宮（旧村社）','和歌山県','和歌山市','和歌山県和歌山市毛見1303',34.1610611,135.1856639,null,null,null,'元伊勢「名草浜宮」と伝わる古社。天照大神を祀る。','https://ja.wikipedia.org/wiki/濱宮','Wikipedia',true,now()),
('kada-kasuga-jinja','加太春日神社','かだかすがじんじゃ','shrine','加太春日神社（旧村社）','和歌山県','和歌山市','和歌山県和歌山市加太1343',34.275194,135.074694,null,null,null,'加太の鎮守。慶長元年造営の本殿は国指定重要文化財。','https://ja.wikipedia.org/wiki/加太春日神社','Wikipedia',true,now()),
('kata-jinja-toba','賀多神社','かたじんじゃ','shrine','賀多神社（旧郷社）','三重県','鳥羽市','三重県鳥羽市鳥羽2丁目9-1',34.48333,136.83972,724,null,null,'鳥羽の総鎮守。伊勢神宮外宮の古材で式年遷宮を行う。','https://ja.wikipedia.org/wiki/賀多神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='matsuho-jinja' and d.slug in ('hachiman','chuai','jingu_kogo'))
or (t.slug='yuraminato-jinja' and d.slug in ('hayaakitsuhiko','hayaakitsuhime','hachiman'))
or (t.slug='hamanomiya-wakayama' and d.slug in ('amaterasu'))
or (t.slug='kada-kasuga-jinja' and d.slug in ('amenokoyane','takemikazuchi','futsunushi'))
or (t.slug='kata-jinja-toba' and d.slug in ('amenooshihomimi'))
on conflict do nothing;
