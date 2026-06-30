-- ============================================================
-- w6-chugoku-a.sql
-- 担当: 鳥取県・島根県・岡山県・広島県・山口県
-- データ出典: ja.wikipedia.org infobox（十進座標で裏取り）
-- 仕様: data/AGENT_SPEC.md / 重複除外: data/regions/_have_chugoku-shikoku.txt
-- ============================================================

-- ① 新規神仏 ------------------------------------------------
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('susanoo','素戔嗚尊','すさのおのみこと','kami','国津神','{"スサノオ","須佐之男命","建速須佐之男命"}','記紀','天照大神の弟。八岐大蛇退治の英雄神で、厄除け・水・農耕の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nawa_nagatoshi','名和長年','なわながとし','kami','人物神','{}','史実','後醍醐天皇に仕えた南朝の忠臣。船上山の挙兵で知られる。','https://ja.wikipedia.org/wiki/名和神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('gokoku_eirei','護国の英霊','ごこくのえいれい','kami','御霊','{}','-','国家のために殉じた戦没者の英霊。','https://ja.wikipedia.org/wiki/松江護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('juichimen_kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{"十一面観世音菩薩"}','仏教','頭上に十一の顔を持つ変化観音。除災と現世利益の仏。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益 ------------------------------------
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','enmusubi','suisan_noko'))
or (d.slug='nawa_nagatoshi' and g.slug in ('shobu','kaiun','shusse'))
or (d.slug='gokoku_eirei' and g.slug in ('kaiun','shobu'))
or (d.slug='juichimen_kannon' and g.slug in ('byoki_heyu','yakubarai','kaiun'))
on conflict do nothing;

-- ③ 社寺 ----------------------------------------------------
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nawa-jinja','名和神社','なわじんじゃ','shrine','名和神社（旧別格官幣社）','鳥取県','西伯郡大山町','鳥取県西伯郡大山町名和556',35.50444,133.49500,1878,null,null,'南朝の忠臣・名和長年と一族を祀る。桜の名所。','https://ja.wikipedia.org/wiki/名和神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanzaki-jinja-kotoura','神崎神社','かんざきじんじゃ','shrine','神崎神社','鳥取県','東伯郡琴浦町','鳥取県東伯郡琴浦町赤碕210',35.51250,133.65056,null,null,'http://kanzakijinjya.com/','「荒神さん」と親しまれる古社。本殿の精緻な龍の彫刻で名高い。','https://ja.wikipedia.org/wiki/神崎神社_(琴浦町)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('mouke-jinja','茂宇気神社','もうけじんじゃ','shrine','茂宇気神社','鳥取県','鳥取市','鳥取県鳥取市鹿野町河内',35.426556,134.01472,null,null,null,'「儲け」に通じる社名から金運・開運の社として知られる。長い石段で有名。','https://ja.wikipedia.org/wiki/茂宇気神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('matsue-gokoku-jinja','松江護国神社','まつえごこくじんじゃ','shrine','松江護国神社','島根県','松江市','島根県松江市殿町1-15',35.47667,133.049583,1939,null,'https://www.matsuegokoku.com','松江城山にある護国神社。島根県東部出身の戦没者を祀る。','https://ja.wikipedia.org/wiki/松江護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('sogen-ji-okayama','曹源寺','そうげんじ','temple','臨済宗妙心寺派','岡山県','岡山市','岡山県岡山市中区円山1069',34.6591528,133.9727167,1698,'十一面観音','http://sogenji.jp/','岡山藩主池田氏の菩提寺。国際的な禅道場としても知られる。','https://ja.wikipedia.org/wiki/曹源寺_(岡山市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け ------------------------------------
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nawa-jinja' and d.slug in ('nawa_nagatoshi'))
or (t.slug='kanzaki-jinja-kotoura' and d.slug in ('susanoo'))
or (t.slug='mouke-jinja' and d.slug in ('amaterasu'))
or (t.slug='matsue-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='sogen-ji-okayama' and d.slug in ('juichimen_kannon'))
on conflict do nothing;

-- ===== バッチ2 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tamanooya','玉祖命','たまのおやのみこと','kami','天津神','{"櫛明玉命"}','記紀','天岩戸神話で八尺瓊勾玉を作った玉造部の祖神。','https://ja.wikipedia.org/wiki/玉祖神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tamanooya' and g.slug in ('shobai','kaiun','geino'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hokai-in','法界院','ほうかいいん','temple','真言宗(単立)','岡山県','岡山市','岡山県岡山市北区法界院6-1',34.693944,133.934139,729,'聖観世音菩薩',null,'中国三十三観音第5番。33年に一度開帳の秘仏観音を祀る古刹。','https://ja.wikipedia.org/wiki/法界院','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hiroshima-gokoku-jinja','広島護国神社','ひろしまごこくじんじゃ','shrine','広島護国神社','広島県','広島市','広島県広島市中区基町21-2',34.401167,132.458750,1868,null,'http://www.h-gokoku.or.jp/','広島城跡に鎮座。広島県西部出身の戦没者と原爆犠牲者を祀る。','https://ja.wikipedia.org/wiki/広島護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hanaoka-hachimangu','花岡八幡宮','はなおかはちまんぐう','shrine','花岡八幡宮（旧県社）','山口県','下松市','山口県下松市末武上400',34.0393639,131.8722278,709,null,'https://www.hanaokahachiman.com/','宇佐八幡から勧請した古社。多宝塔(国重文)が現存する。','https://ja.wikipedia.org/wiki/花岡八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fukutoku-inari-jinja','福徳稲荷神社','ふくとくいなりじんじゃ','shrine','福徳稲荷神社','山口県','下関市','山口県下関市豊浦町宇賀2960-1',34.198167,130.935333,1971,null,null,'響灘を望む絶景の参道で知られる稲荷社。','https://ja.wikipedia.org/wiki/福徳稲荷神社_(下関市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tamanooya-jinja','玉祖神社','たまのおやじんじゃ','shrine','玉祖神社（周防国一宮・式内社）','山口県','防府市','山口県防府市大崎1690',34.0577083,131.5336528,null,null,null,'周防国一宮。玉造部の祖神・玉祖命を祀る式内社。','https://ja.wikipedia.org/wiki/玉祖神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hokai-in' and d.slug in ('sho_kannon'))
or (t.slug='hiroshima-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='hanaoka-hachimangu' and d.slug in ('hachiman'))
or (t.slug='fukutoku-inari-jinja' and d.slug in ('ukanomitama'))
or (t.slug='tamanooya-jinja' and d.slug in ('tamanooya'))
on conflict do nothing;

-- ===== バッチ3 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('shitateruhime','下照姫命','したてるひめのみこと','kami','国津神','{"高姫命"}','記紀','大国主神の娘。和歌の祖神とされる美しい女神。','https://ja.wikipedia.org/wiki/シタテルヒメ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('toyotamahime','豊玉姫命','とよたまひめのみこと','kami','国津神','{"豊玉毘売"}','記紀','海神の娘で山幸彦の妃。安産・海上守護の女神。','https://ja.wikipedia.org/wiki/トヨタマビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='shitateruhime' and g.slug in ('enmusubi','renai','geino'))
or (d.slug='toyotamahime' and g.slug in ('anzan','kosodate','kaijo_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nikabe-jinja','仁壁神社','にかべじんじゃ','shrine','仁壁神社（周防国三宮・式内社）','山口県','山口市','山口県山口市三の宮2-6-22',34.189306,131.491889,null,null,null,'周防国三宮の式内社。下照姫命・住吉三神を祀る。','https://ja.wikipedia.org/wiki/仁壁神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yamaguchi-gokoku-jinja','山口県護国神社','やまぐちけんごこくじんじゃ','shrine','山口県護国神社','山口県','山口市','山口県山口市平野2-2-1',34.193750,131.490500,1941,null,'https://yamaguchi-gokoku.jp/','吉田松陰・高杉晋作ら山口県出身の殉難者・戦没者を祀る。','https://ja.wikipedia.org/wiki/山口県護国神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('okita-jinja','沖田神社','おきたじんじゃ','shrine','沖田神社（旧県社）','岡山県','岡山市','岡山県岡山市中区沖元411',34.637861,133.983028,1694,null,'http://www.okita-shrine.com/','岡山藩の干拓地の総鎮守。人柱伝説の「おきた姫」を祀る。','https://ja.wikipedia.org/wiki/沖田神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ushimado-jinja','牛窓神社','うしまどじんじゃ','shrine','牛窓神社（旧県社）','岡山県','瀬戸内市','岡山県瀬戸内市牛窓町牛窓2147',34.622528,134.172306,1012,null,'http://www.jinja-net.jp/ushimado/index.html','瀬戸内海を望む「牛窓八幡宮」。応神天皇らを祀る。','https://ja.wikipedia.org/wiki/牛窓神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tamaigu-toshogu','玉井宮東照宮','たまいぐうとうしょうぐう','shrine','玉井宮東照宮（旧県社）','岡山県','岡山市','岡山県岡山市中区東山1-3-81',34.656083,133.945806,703,null,'https://www.tamaigutousyouguu.com/','東山に鎮座。玉依姫らと徳川家康を祀る岡山城の守護社。','https://ja.wikipedia.org/wiki/玉井宮東照宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nikabe-jinja' and d.slug in ('shitateruhime','sumiyoshi'))
or (t.slug='yamaguchi-gokoku-jinja' and d.slug in ('gokoku_eirei'))
or (t.slug='okita-jinja' and d.slug in ('amaterasu'))
or (t.slug='ushimado-jinja' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='tamaigu-toshogu' and d.slug in ('toyotamahime','ieyasu'))
on conflict do nothing;
