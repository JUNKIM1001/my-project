-- 御朱印ナビ データ拡張: 北海道・青森県・岩手県
-- 担当: w6-hokkaido-a
-- 出典: ja.wikipedia.org の各記事 infobox（十進座標で裏取り）
-- 重複禁止リスト _have_hokkaido-tohoku.txt と照合済み

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sarutahiko','猿田彦神','さるたひこのかみ','kami','国津神','{}','記紀','道開き・導きの神。天孫降臨を先導した。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('omononushi','大物主神','おおものぬしのかみ','kami','国津神','{}','記紀','三輪山の神。国造り・農業・酒造の神。','https://ja.wikipedia.org/wiki/オオモノヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sanbo_kojin','三宝荒神','さんぼうこうじん','kami','御霊','{}','民間信仰','火と竈の神。地域では権現様とも。','https://ja.wikipedia.org/wiki/三宝荒神','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sarutahiko' and g.slug in ('kaiun','tabi_anzen','shobai'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='omononushi' and g.slug in ('shobai','byoki_heyu','suisan_noko'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sanbo_kojin' and g.slug in ('yakubarai','kanai_anzen','majo_kekkai'))
on conflict do nothing;

-- ③ 社寺（batch 1）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shinoro-jinja','篠路神社','しのろじんじゃ','shrine','旧郷社','北海道','札幌市','北海道札幌市北区篠路4条7丁目2番',43.146111,141.364917,1855,null,null,'札幌市北区の開拓期に創建された古社。','https://ja.wikipedia.org/wiki/篠路神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nishikiyama-tenmangu','錦山天満宮','にしきやまてんまんぐう','shrine','旧村社','北海道','江別市','北海道江別市野幌代々木町38番地1',43.096278,141.519722,1889,null,'https://www.nishikiyama.or.jp/','江別・野幌の天神様。学業成就で知られる。','https://ja.wikipedia.org/wiki/錦山天満宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('otaru-sumiyoshi-jinja','住吉神社','すみよしじんじゃ','shrine','別表神社・旧県社','北海道','小樽市','北海道小樽市住ノ江2-5-1',43.182944,141.003222,1868,null,'http://www.otarusumiyoshijinja.or.jp/','小樽総鎮守。道内最大級の百貫神輿で有名。','https://ja.wikipedia.org/wiki/住吉神社_(小樽市)','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ota-san-jinja','太田山神社','おたさんじんじゃ','shrine','旧郷社','北海道','久遠郡せたな町','北海道久遠郡せたな町大成区太田17番地',42.267592,139.781253,1441,null,'https://www.town.setana.lg.jp/otajinja/','断崖に建つ「日本一危険な神社」。道南五大霊場の一。','https://ja.wikipedia.org/wiki/太田山神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tono-kojin-jinja','荒神神社','こうじんじんじゃ','shrine','-','岩手県','遠野市','岩手県遠野市青笹町中沢',39.303083,141.585833,null,null,null,'田の中に建つ茅葺の小社。遠野の原風景として有名。','https://ja.wikipedia.org/wiki/荒神神社_(遠野市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（batch 1）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shinoro-jinja' and d.slug in ('amaterasu','hachiman','ukanomitama','michizane','omononushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nishikiyama-tenmangu' and d.slug in ('amaterasu','michizane'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='otaru-sumiyoshi-jinja' and d.slug in ('sumiyoshi','jingu_kogo'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ota-san-jinja' and d.slug in ('sarutahiko'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tono-kojin-jinja' and d.slug in ('sanbo_kojin'))
on conflict do nothing;

-- ===== batch 2 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('futsunushi','経津主神','ふつぬしのかみ','kami','天津神','{}','記紀','刀剣・武の神。香取神宮の主祭神。','https://ja.wikipedia.org/wiki/フツヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{}','記紀','雷と剣の武神。鹿島神宮の主祭神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('toyouke','豊受大神','とようけのおおかみ','kami','天津神','{}','記紀','食物・農耕の女神。伊勢神宮外宮の主祭神。','https://ja.wikipedia.org/wiki/トヨウケビメ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('watatsumi','綿津見神','わたつみのかみ','kami','国津神','{}','記紀','海の神。海上安全・漁業の守護。','https://ja.wikipedia.org/wiki/ワタツミ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{}','記紀','神武天皇の母。安産・子育ての神。','https://ja.wikipedia.org/wiki/タマヨリビメ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ugayafukiaezu','鵜茅葺不合命','うがやふきあえずのみこと','kami','国津神','{}','記紀','神武天皇の父。海と陸を結ぶ神。','https://ja.wikipedia.org/wiki/ウガヤフキアエズ','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('tsugaru_nobuhide','津軽信英','つがるのぶひで','kami','御霊','{}','史実','黒石津軽家の祖。黒石神社の祭神。','https://ja.wikipedia.org/wiki/黒石神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='futsunushi' and g.slug in ('shobu','yakubarai','kaiun'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','shobai'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='toyouke' and g.slug in ('shobai','suisan_noko','kaiun'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='watatsumi' and g.slug in ('kaijo_anzen','suisan_noko','shobai'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tamayorihime' and g.slug in ('anzan','kosodate','enmusubi'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ugayafukiaezu' and g.slug in ('anzan','kosodate','kaiun'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='tsugaru_nobuhide' and g.slug in ('kaiun','gakumon','shusse'))
on conflict do nothing;

-- ③ 社寺（batch 2）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kuroishi-jinja','黒石神社','くろいしじんじゃ','shrine','旧県社','青森県','黒石市','青森県黒石市市ノ町20',40.641361,140.593556,1879,null,null,'黒石津軽家の祖・津軽信英を祀る。','https://ja.wikipedia.org/wiki/黒石神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shigariwake-jinja','志賀理和氣神社','しがりわけじんじゃ','shrine','式内社・旧県社','岩手県','紫波郡紫波町','岩手県紫波郡紫波町桜町本町川原1',39.547306,141.174389,804,null,null,'延喜式内社のうち最北に位置する古社。赤石神社とも。','https://ja.wikipedia.org/wiki/志賀理和氣神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chinjufu-hachimangu','鎮守府八幡宮','ちんじゅふはちまんぐう','shrine','旧県社','岩手県','奥州市','岩手県奥州市水沢佐倉河宮ノ内12',39.184500,141.137250,801,null,'https://chinjufu.jp/','坂上田村麻呂が胆沢鎮守府に勧請したと伝わる八幡宮。','https://ja.wikipedia.org/wiki/鎮守府八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yokoyama-hachimangu','横山八幡宮','よこやまはちまんぐう','shrine','旧郷社','岩手県','宮古市','岩手県宮古市宮町2丁目5-1',39.638139,141.943722,680,null,'https://y-hachimangu.com/','宮古の総鎮守。旧南部領の有力八幡宮の一。','https://ja.wikipedia.org/wiki/横山八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('unotori-jinja','鵜鳥神社','うのとりじんじゃ','shrine','旧郷社','岩手県','下閉伊郡普代村','岩手県下閉伊郡普代村卯起',40.009500,141.852111,807,null,null,'三陸の漁師に信仰される海の神。鵜鳥神楽で知られる。','https://ja.wikipedia.org/wiki/鵜鳥神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（batch 2）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kuroishi-jinja' and d.slug in ('tsugaru_nobuhide'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shigariwake-jinja' and d.slug in ('futsunushi','takemikazuchi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chinjufu-hachimangu' and d.slug in ('hachiman','jingu_kogo','ichikishima'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yokoyama-hachimangu' and d.slug in ('hachiman','amaterasu','toyouke'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='unotori-jinja' and d.slug in ('ugayafukiaezu','tamayorihime','watatsumi'))
on conflict do nothing;

-- ===== batch 3 =====
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('minamoto_yoshitsune','源義経','みなもとのよしつね','kami','御霊','{}','史実','悲劇の武将。北行伝説により蝦夷地で神格化。','https://ja.wikipedia.org/wiki/源義経','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('seishi_kannon','勢至菩薩','せいしぼさつ','buddha','菩薩','{}','仏教','智慧の光で衆生を救う菩薩。','https://ja.wikipedia.org/wiki/勢至菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='minamoto_yoshitsune' and g.slug in ('shobu','shusse','kaiun'))
on conflict do nothing;
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='seishi_kannon' and g.slug in ('gakugyo','kaiun','byoki_heyu'))
on conflict do nothing;

-- ③ 社寺（batch 3）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yoshitsune-jinja','義経神社','よしつねじんじゃ','shrine','旧無格社','北海道','沙流郡平取町','北海道沙流郡平取町本町119-1',42.592306,142.136222,1798,null,'https://yoshitsune-jinja.com/website/','義経北行伝説にちなみ源義経を祀る。アイヌのオキクルミ信仰とも習合。','https://ja.wikipedia.org/wiki/義経神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('tokuyama-daijingu','徳山大神宮','とくやまだいじんぐう','shrine','旧県社','北海道','松前郡松前町','北海道松前郡松前町字松前字下女郎66',41.434720,140.110560,null,null,null,'渡島国の一宮格。松前藩の伊勢信仰の中心。','https://ja.wikipedia.org/wiki/徳山大神宮','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('urausu-jinja','浦臼神社','うらうすじんじゃ','shrine','旧村社','北海道','樺戸郡浦臼町','北海道樺戸郡浦臼町キナウスナイ186',43.451056,141.832750,1910,null,null,'エゾリスとカタクリの参道で知られる小社。','https://ja.wikipedia.org/wiki/浦臼神社','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('jokenji','常堅寺','じょうけんじ','temple','曹洞宗','岩手県','遠野市','岩手県遠野市土淵町土淵7-50',39.354514,141.570969,1490,'勢至観世音菩薩',null,'カッパ狛犬で有名。背後にカッパ淵がある遠野の名刹。','https://ja.wikipedia.org/wiki/常堅寺','Wikipedia',true,now())
on conflict (slug) do nothing;
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('fukusenji-tono','福泉寺','ふくせんじ','temple','真言宗豊山派','岩手県','遠野市','岩手県遠野市松崎町駒木7-57',39.373633,141.563558,1912,'聖観音菩薩',null,'日本最大級の木彫大観音像で知られる。','https://ja.wikipedia.org/wiki/福泉寺_(遠野市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（batch 3）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yoshitsune-jinja' and d.slug in ('minamoto_yoshitsune'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tokuyama-daijingu' and d.slug in ('amaterasu','toyouke'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='urausu-jinja' and d.slug in ('hachiman','okuninushi'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='jokenji' and d.slug in ('seishi_kannon'))
on conflict do nothing;
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='fukusenji-tono' and d.slug in ('sho_kannon'))
on conflict do nothing;
