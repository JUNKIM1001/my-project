-- w11-kanto.sql : 関東地方 著名社寺データ拡張（_have_kanto.txt 未収録）
-- 出典: ja.wikipedia.org infobox 十進座標で裏取り
-- 担当県: 茨城・栃木・群馬・埼玉・千葉・東京・神奈川
-- 仕様: AGENT_SPEC.md 厳守 / 5件ごと逐次保存

-- ===== バッチ1 (5件) 茨城・千葉・東京 =====

-- ① 新規神仏（新規なし）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('oou-jinja','大生神社','おおうじんじゃ','shrine','大生神社（式内社論社・旧郷社）','茨城県','潮来市','茨城県潮来市大生814',35.9918167,140.5517861,null,null,null,'鹿島神宮の元宮とも伝わる大生原台地の古社。','https://ja.wikipedia.org/wiki/大生神社','Wikipedia',true,now()),
('tanashi-jinja','田無神社','たなしじんじゃ','shrine','田無神社（旧村社）','東京都','西東京市','東京都西東京市田無町3-7-4',35.7300500,139.5441333,null,null,'https://www.tanashijinja.or.jp/','五龍神を祀る田無の総鎮守。金龍をはじめ五方位の龍神で知られる。','https://ja.wikipedia.org/wiki/田無神社','Wikipedia',true,now()),
('gohyaku-rakanji','五百羅漢寺','ごひゃくらかんじ','temple','浄土宗系単立','東京都','目黒区','東京都目黒区下目黒3-20-11',35.628917,139.709194,1695,'釈迦如来','http://www.rakan.or.jp/','松雲元慶作の羅漢像群で知られる目黒の禅刹。','https://ja.wikipedia.org/wiki/五百羅漢寺','Wikipedia',true,now()),
('sunomiya-jinja','洲宮神社','すのみやじんじゃ','shrine','洲宮神社（式内大社論社・旧県社）','千葉県','館山市','千葉県館山市洲宮921',34.95250,139.83806,null,null,null,'安房国二宮とされる古社。后神を祀り神田の御田植祭で知られる。','https://ja.wikipedia.org/wiki/洲宮神社','Wikipedia',true,now()),
('shimotatematsubara-shirahama','下立松原神社','しもたてまつばらじんじゃ','shrine','下立松原神社（式内小社論社・旧村社）','千葉県','南房総市','千葉県南房総市白浜町滝口1728',34.91500,139.86778,null,null,null,'天日鷲命を祀る安房の式内社論社。神事「お船祭」が伝わる。','https://ja.wikipedia.org/wiki/下立松原神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='oou-jinja' and d.slug in ('takemikazuchi'))
or (t.slug='tanashi-jinja' and d.slug in ('okuninushi','shinatsuhiko','susanoo','sarutahiko','yamatotakeru'))
or (t.slug='gohyaku-rakanji' and d.slug in ('shaka_nyorai'))
or (t.slug='sunomiya-jinja' and d.slug in ('amenohirinome'))
or (t.slug='shimotatematsubara-shirahama' and d.slug in ('amenohiwashi','amenofutodama'))
on conflict do nothing;

-- ===== バッチ2 (5件) 東京・神奈川 =====

-- ① 新規神仏（新規なし）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hebikubo-jinja','蛇窪神社','へびくぼじんじゃ','shrine','蛇窪神社（旧村社・天祖神社）','東京都','品川区','東京都品川区二葉4-4-12',35.602583,139.715194,1322,null,'http://hebikubo.jp/','白蛇伝説で知られる上神明天祖神社。巳の日詣りで賑わう。','https://ja.wikipedia.org/wiki/蛇窪神社','Wikipedia',true,now()),
('gosho-jinja-yugawara','五所神社','ごしょじんじゃ','shrine','五所神社（旧郷社）','神奈川県','足柄下郡湯河原町','神奈川県足柄下郡湯河原町宮下359-2',35.142694,139.094028,null,null,'http://goshojinjya.com/','湯河原の総鎮守。樹齢850年超の楠の巨木で知られる。','https://ja.wikipedia.org/wiki/五所神社_(湯河原町)','Wikipedia',true,now()),
('tamagawa-sengen-jinja','多摩川浅間神社','たまがわせんげんじんじゃ','shrine','多摩川浅間神社（旧村社）','東京都','大田区','東京都大田区田園調布1-55-12',35.587361,139.668639,1185,null,'https://www.sengenjinja.info/','多摩川を望む高台の浅間神社。北条政子ゆかりと伝わる。','https://ja.wikipedia.org/wiki/多摩川浅間神社','Wikipedia',true,now()),
('yukigaya-hachiman','雪ヶ谷八幡神社','ゆきがやはちまんじんじゃ','shrine','雪ヶ谷八幡神社（旧村社）','東京都','大田区','東京都大田区東雪谷2-25-1',35.596722,139.686278,1558,null,'https://yukigaya.info/','東雪谷の鎮守。出世稲荷や力石で知られる八幡社。','https://ja.wikipedia.org/wiki/雪ヶ谷八幡神社','Wikipedia',true,now()),
('awaguchi-jinja','安房口神社','あわぐちじんじゃ','shrine','安房口神社（旧村社）','神奈川県','横須賀市','神奈川県横須賀市吉井3-11',35.251889,139.698111,1179,null,null,'安房神社を遥拝する霊石「安房口の石」を御神体とする古社。','https://ja.wikipedia.org/wiki/安房口神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hebikubo-jinja' and d.slug in ('amaterasu'))
or (t.slug='gosho-jinja-yugawara' and d.slug in ('amaterasu'))
or (t.slug='tamagawa-sengen-jinja' and d.slug in ('konohanasakuyahime'))
or (t.slug='yukigaya-hachiman' and d.slug in ('hachiman'))
or (t.slug='awaguchi-jinja' and d.slug in ('amenofutodama'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='hebikubo-jinja' and d.slug in ('amenokoyane','hachiman'))
on conflict do nothing;

-- ===== バッチ3 (5件) 埼玉・東京 =====

-- ① 新規神仏（新規なし）

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nakayama-jinja-saitama','中山神社','なかやまじんじゃ','shrine','中山神社（旧村社・中氷川神社）','埼玉県','さいたま市','埼玉県さいたま市見沼区中川143',35.9001333,139.6639333,null,null,null,'武蔵一宮氷川神社と氷川女体神社の中間に鎮座する中氷川神社。','https://ja.wikipedia.org/wiki/中山神社_(さいたま市)','Wikipedia',true,now()),
('kasai-jinja','葛西神社','かさいじんじゃ','shrine','葛西神社（旧郷社）','東京都','葛飾区','東京都葛飾区東金町6-10-5',35.771444,139.878667,1185,null,'https://kasaijinjya.world.coocan.jp/','葛西三十三郷の総鎮守。祭囃子（葛西囃子）発祥の地。','https://ja.wikipedia.org/wiki/葛西神社','Wikipedia',true,now()),
('hirakawa-tenmangu','平河天満宮','ひらかわてんまんぐう','shrine','平河天満宮（旧村社）','東京都','千代田区','東京都千代田区平河町1-7-5',35.682444,139.740722,1478,null,'http://hirakawatenjin.or.jp','太田道灌が江戸城内に創建した学問の神。撫で牛で知られる。','https://ja.wikipedia.org/wiki/平河天満宮','Wikipedia',true,now()),
('tenryuji-nenogongen','天龍寺','てんりゅうじ','temple','天台宗','埼玉県','飯能市','埼玉県飯能市南461',35.907667,139.188611,911,'十一面観音','http://nenogongen.jp/','「子の権現」として足腰の守護で名高い奥武蔵の古刹。','https://ja.wikipedia.org/wiki/天龍寺_(飯能市)','Wikipedia',true,now()),
('akagi-jinja-shinjuku','赤城神社','あかぎじんじゃ','shrine','赤城神社（旧郷社・牛込総鎮守）','東京都','新宿区','東京都新宿区赤城元町1-10',35.704972,139.736333,1300,null,'https://www.akagi-jinja.jp/','神楽坂の総鎮守。隈研吾設計の社殿で知られる。','https://ja.wikipedia.org/wiki/赤城神社_(新宿区)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nakayama-jinja-saitama' and d.slug in ('okuninushi'))
or (t.slug='kasai-jinja' and d.slug in ('futsunushi'))
or (t.slug='hirakawa-tenmangu' and d.slug in ('michizane'))
or (t.slug='tenryuji-nenogongen' and d.slug in ('juichimen_kannon'))
or (t.slug='akagi-jinja-shinjuku' and d.slug in ('iwatsutsuo','akagihime'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='nakayama-jinja-saitama' and d.slug in ('susanoo','kushinadahime'))
or (t.slug='kasai-jinja' and d.slug in ('yamatotakeru','ieyasu'))
on conflict do nothing;
