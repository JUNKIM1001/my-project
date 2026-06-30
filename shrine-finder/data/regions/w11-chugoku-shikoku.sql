-- w11 中国・四国 追加データ
-- 担当: 中国・四国地方の著名社寺。ja.wikipedia infobox の十進座標で裏取り。
-- 既存(_have / 既収録slug)と重複しないものを収録。

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('kamikushiwake','神櫛別命','かみくしわけのみこと','kami','国津神','{}','記紀','景行天皇の皇子と伝わる讃岐国造の祖神。','https://ja.wikipedia.org/wiki/城山神社_(坂出市)','Wikipedia',true,now()),
('iiyorihiko','飯依比古命','いいよりひこのみこと','kami','国津神','{}','記紀','讃岐国の国魂とされる神。','https://ja.wikipedia.org/wiki/飯神社','Wikipedia',true,now()),
('mimatsuhiko','御間都比古色止命','みまつひこいろとのみこと','kami','国津神','{}','記紀','阿波・神山郷の開祖神と伝わる神。','https://ja.wikipedia.org/wiki/御間都比古神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='kamikushiwake' and g.slug in ('kaiun','yakubarai'))
or (d.slug='iiyorihiko' and g.slug in ('suisan_noko','kaiun'))
or (d.slug='mimatsuhiko' and g.slug in ('kaiun','shobai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nishiyama-koryuji','西山興隆寺','にしやまこうりゅうじ','temple','真言宗醍醐派','愛媛県','西条市','愛媛県西条市丹原町古田1657',33.905667,133.025333,642,'千手千眼観世音菩薩','https://www.nishiyamakoryuji.jp/','四国別格二十霊場第10番。紅葉の名所として知られる古刹。','https://ja.wikipedia.org/wiki/西山興隆寺','Wikipedia',true,now()),
('kiyama-jinja-sakaide','城山神社','きやまじんじゃ','shrine','城山神社（式内社・讃岐国造祖神）','香川県','坂出市','香川県坂出市府中町本村4760',34.294028,133.911306,null,null,null,'讃岐国造の祖・神櫛別命を祀る式内社（名神大社）。','https://ja.wikipedia.org/wiki/城山神社_(坂出市)','Wikipedia',true,now()),
('ii-jinja-marugame','飯神社','いいじんじゃ','shrine','飯神社（式内社）','香川県','丸亀市','香川県丸亀市飯野町東二字山根20',34.269889,133.840306,964,null,null,'讃岐国魂・飯依比古を祀る式内社。飯野山(讃岐富士)の麓に鎮座。','https://ja.wikipedia.org/wiki/飯神社','Wikipedia',true,now()),
('mimatsuhiko-jinja','御間都比古神社','みまつひこじんじゃ','shrine','御間都比古神社（式内社）','徳島県','名西郡神山町','徳島県名西郡神山町下分字物見石74-2',33.994889,134.473306,null,null,null,'神山郷の開祖神を祀る式内社。','https://ja.wikipedia.org/wiki/御間都比古神社','Wikipedia',true,now()),
('suwa-jinja-tokushima','諏訪神社','すわじんじゃ','shrine','諏訪神社','徳島県','徳島市','徳島県徳島市南佐古三番町',34.075694,134.535528,1585,null,null,'徳島城の鬼門鎮護として勧請されたと伝わる旧郷社。眉山の麓に鎮座。','https://ja.wikipedia.org/wiki/諏訪神社_(徳島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nishiyama-koryuji' and d.slug in ('senju_kannon'))
or (t.slug='kiyama-jinja-sakaide' and d.slug in ('kamikushiwake'))
or (t.slug='ii-jinja-marugame' and d.slug in ('iiyorihiko','sukunahikona'))
or (t.slug='mimatsuhiko-jinja' and d.slug in ('mimatsuhiko'))
or (t.slug='suwa-jinja-tokushima' and d.slug in ('takeminakata'))
on conflict do nothing;

-- ===== batch 2 =====
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ebisu-jinja-tokushima','蛭子神社','えびすじんじゃ','shrine','蛭子神社','徳島県','徳島市','徳島県徳島市南沖洲一丁目2',34.066444,134.584586,null,null,null,'事代主命を祀る。安政南海地震の記録を刻んだ百度石が市民遺産。','https://ja.wikipedia.org/wiki/蛭子神社_(徳島市)','Wikipedia',true,now()),
('higashikamo-jinja-sakaide','東鴨神社','ひがしかもじんじゃ','shrine','鴨神社（式内社論社）','香川県','坂出市','香川県坂出市加茂町992',34.312147,133.915672,null,null,null,'讃岐国の式内社・鴨神社の論社。弘仁年間の創建と伝わる。','https://ja.wikipedia.org/wiki/鴨神社_(坂出市)','Wikipedia',true,now()),
('hibayama-kume-jinja','比婆山久米神社','ひばやまくめじんじゃ','shrine','比婆山久米神社','島根県','安来市','島根県安来市伯太町横屋844-1',35.315333,133.242917,null,null,null,'イザナミ尊の御陵伝承が残る比婆山に鎮座。安産・子育ての信仰を集める。','https://ja.wikipedia.org/wiki/比婆山久米神社','Wikipedia',true,now()),
('yahoko-jinja-anan','八桙神社','やほこじんじゃ','shrine','八桙神社（式内社）','徳島県','阿南市','徳島県阿南市長生町宮内463',33.920194,134.616389,753,null,null,'大己貴命を祀る式内社。徳島県最古とされる古文書を蔵する。','https://ja.wikipedia.org/wiki/八桙神社','Wikipedia',true,now()),
('katsuragi-jinja-naruto','葛城神社','かつらぎじんじゃ','shrine','葛城神社','徳島県','鳴門市','徳島県鳴門市北灘町粟田',34.218610,134.534139,1055,null,null,'一言主神を祀り、眼病平癒の御神水で知られる。','https://ja.wikipedia.org/wiki/葛城神社_(鳴門市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ebisu-jinja-tokushima' and d.slug in ('kotoshironushi'))
or (t.slug='higashikamo-jinja-sakaide' and d.slug in ('hitokotonushi','tamayorihime'))
or (t.slug='hibayama-kume-jinja' and d.slug in ('izanami'))
or (t.slug='yahoko-jinja-anan' and d.slug in ('okuninushi'))
or (t.slug='katsuragi-jinja-naruto' and d.slug in ('hitokotonushi'))
on conflict do nothing;
