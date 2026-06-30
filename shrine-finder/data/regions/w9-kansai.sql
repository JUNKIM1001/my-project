-- w9-kansai.sql  近畿(7府県)社寺データ拡張 第9弾
-- 仕様: AGENT_SPEC.md 準拠。_have_kansai.txt と重複しない著名社寺。
-- ja.wikipedia.org infobox の十進座標で裏取り済み。

-- ① 新規神仏（既存に無いものだけ。多くは既存slugを参照）
-- （このバッチで新規定義した神仏は末尾の②に対応）

-- ===== バッチ1 (1-5) =====
-- 籠神社(京都/宮津), 出雲大神宮(京都/亀岡), 成相寺(京都/宮津), 松尾寺(京都/舞鶴), 神呪寺(兵庫/西宮)

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kono-jinja','籠神社','このじんじゃ','shrine','元伊勢籠神社（丹後国一宮・名神大社）','京都府','宮津市','京都府宮津市大垣430',35.5828139,135.1966694,null,null,'https://www.motoise.jp/','元伊勢と称される丹後国一宮。彦火明命を祀る。','https://ja.wikipedia.org/wiki/籠神社','Wikipedia',true,now()),
('izumo-daijingu','出雲大神宮','いずもだいじんぐう','shrine','出雲大神宮（丹波国一宮）','京都府','亀岡市','京都府亀岡市千歳町千歳出雲無番地',35.0594056,135.5784111,709,null,'http://www.izumo-d.org','元出雲と称される丹波国一宮。大国主神を祀る縁結びの社。','https://ja.wikipedia.org/wiki/出雲大神宮','Wikipedia',true,now()),
('nariai-ji','成相寺','なりあいじ','temple','真言宗単立','京都府','宮津市','京都府宮津市成相寺339',35.5954389,135.1873722,704,'聖観世音菩薩','https://www.nariaiji.jp/','西国三十三所第28番札所。天橋立を望む古刹。','https://ja.wikipedia.org/wiki/成相寺','Wikipedia',true,now()),
('matsunoo-dera-maizuru','松尾寺_(舞鶴市)','まつのおでら','temple','真言宗醍醐派','京都府','舞鶴市','京都府舞鶴市松尾532',35.49743,135.46938,708,'馬頭観音菩薩','http://www.matsunoodera.com/','西国三十三所第29番札所。西国唯一の馬頭観音を本尊とする。','https://ja.wikipedia.org/wiki/松尾寺_(舞鶴市)','Wikipedia',true,now()),
('kanno-ji','神呪寺','かんのうじ','temple','真言宗御室派','兵庫県','西宮市','兵庫県西宮市甲山町25-1',34.773139,135.329778,827,'如意輪観音','https://www.ne.jp/asahi/kabutoyama/kanno-ji/','甲山大師として知られる古刹。新西国三十三箇所第21番。','https://ja.wikipedia.org/wiki/神呪寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（バッチ1）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kono-jinja' and d.slug in ('amenohoakari'))
or (t.slug='izumo-daijingu' and d.slug in ('okuninushi','mihotsuhime'))
or (t.slug='nariai-ji' and d.slug in ('sho_kannon'))
or (t.slug='matsunoo-dera-maizuru' and d.slug in ('bato_kannon'))
or (t.slug='kanno-ji' and d.slug in ('nyoirin_kannon'))
on conflict do nothing;
