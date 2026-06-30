-- w6-kanto-b : 関東（千葉県・東京都・神奈川県）著名社寺データ
-- 全件 ja.wikipedia.org の infobox 十進座標で裏取り。座標の無いものは除外。
-- 既存 _have_kanto.txt 収録分とは重複させない。
-- ============================================================
-- ① 新規神仏（既存14柱に無いものだけ）
-- ============================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yoshida_shoin','吉田松陰','よしだしょういん','kami','御霊','{}','史実','幕末長州の思想家・教育者。松下村塾を主宰し維新の志士を育てた。','https://ja.wikipedia.org/wiki/松陰神社','Wikipedia',true,now()),
('takeuchi_sukune','武内宿禰','たけうちのすくね','kami','御霊','{}','記紀','五代の天皇に仕えたと伝わる長寿の名臣。延命・武運の神。','https://ja.wikipedia.org/wiki/武内宿禰','Wikipedia',true,now()),
('yamato_takeru','日本武尊','やまとたけるのみこと','kami','天津神','{}','記紀','景行天皇の皇子。東征の英雄神。武運・勝負の神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','天照大神の弟。八岐大蛇退治の英雄神で厄除・水の神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kushinadahime','櫛名田比売','くしなだひめ','kami','国津神','{}','記紀','素戔嗚尊の妃。縁結び・夫婦和合の女神。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ② 新規神仏の司るご利益
-- ============================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yoshida_shoin' and g.slug in ('gakugyo','gakumon','shusse'))
   or (d.slug='takeuchi_sukune' and g.slug in ('choju','shusse','shigoto'))
   or (d.slug='yamato_takeru' and g.slug in ('shobu','yakubarai','kaiun'))
   or (d.slug='susanoo' and g.slug in ('yakubarai','kanai_anzen','enmusubi'))
   or (d.slug='kushinadahime' and g.slug in ('enmusubi','renai','kanai_anzen'))
on conflict do nothing;

-- ============================================================
-- ③ 社寺
-- ============================================================
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shoin-jinja-tokyo','松陰神社','しょういんじんじゃ','shrine','松陰神社（旧府社）','東京都','世田谷区','東京都世田谷区若林4-35-1',35.647220,139.656083,1882,null,'http://www.shoinjinja.org','吉田松陰を祀り墓所を擁する。学業成就の信仰を集める。','https://ja.wikipedia.org/wiki/松陰神社','Wikipedia',true,now()),
('hatonomori-hachiman','鳩森八幡神社','はとのもりはちまんじんじゃ','shrine','鳩森八幡神社','東京都','渋谷区','東京都渋谷区千駄ヶ谷1-1-24',35.677694,139.709444,860,null,'https://www.hatonomori-shrine.or.jp/','千駄ヶ谷の鎮守。都内最古級の富士塚と将棋堂で知られる。','https://ja.wikipedia.org/wiki/鳩森八幡神社','Wikipedia',true,now()),
('junisho-jinja-kamakura','十二所神社','じゅうにそじんじゃ','shrine','十二所神社','神奈川県','鎌倉市','神奈川県鎌倉市十二所285',35.323581,139.581047,1278,null,null,'鎌倉十二所の鎮守。天神七代・地神五代の十二神を祀る。','https://ja.wikipedia.org/wiki/十二所神社_(鎌倉市)','Wikipedia',true,now()),
('hiratsuka-hachimangu','平塚八幡宮','ひらつかはちまんぐう','shrine','平塚八幡宮（旧県社）','神奈川県','平塚市','神奈川県平塚市浅間町1-6',35.333953,139.349125,380,null,'http://www.hachiman.org/','相模国の鶴峰山八幡。國府祭に参加する古社。','https://ja.wikipedia.org/wiki/平塚八幡宮','Wikipedia',true,now()),
('tsurumine-hachimangu','鶴嶺八幡宮','つるみねはちまんぐう','shrine','鶴嶺八幡宮','神奈川県','茅ヶ崎市','神奈川県茅ヶ崎市浜之郷462',35.338439,139.391194,1030,null,'https://www.tsuruminehachimangu.com','茅ヶ崎総鎮守。樹齢950年の大銀杏と浜降祭で知られる。','https://ja.wikipedia.org/wiki/鶴嶺八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ④ 御祭神/本尊の紐付け
-- ============================================================
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shoin-jinja-tokyo' and d.slug in ('yoshida_shoin'))
   or (t.slug='hatonomori-hachiman' and d.slug in ('hachiman','jingu_kogo'))
   or (t.slug='hiratsuka-hachimangu' and d.slug in ('hachiman','jingu_kogo','takeuchi_sukune'))
   or (t.slug='tsurumine-hachimangu' and d.slug in ('hachiman'))
on conflict do nothing;

-- ============================================================
-- バッチ2
-- ============================================================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sarutahiko','猿田彦大神','さるたひこのおおかみ','kami','国津神','{}','記紀','天孫降臨を先導した道開きの神。交通安全・旅の守護神。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now()),
('kuraokami','闇淤加美神','くらおかみのかみ','kami','国津神','{}','記紀','谷の水と雨を司る龍神。雨乞い・水の神。','https://ja.wikipedia.org/wiki/オカミ神','Wikipedia',true,now()),
('sanbo_son','三宝尊','さんぼうそん','buddha','如来','{}','日蓮宗','仏・法・僧の三宝を一体とする日蓮宗の本尊。','https://ja.wikipedia.org/wiki/三宝尊','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② ご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sarutahiko' and g.slug in ('kotsu_anzen','tabi_anzen','kaiun'))
   or (d.slug='kuraokami' and g.slug in ('mizu_amagoi','suisan_noko','kaiun'))
   or (d.slug='sanbo_son' and g.slug in ('jouju','kaiun','yakubarai'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('matsubara-jinja-odawara','松原神社','まつばらじんじゃ','shrine','松原神社（旧県社）','神奈川県','小田原市','神奈川県小田原市本町2-10-16',35.249440,139.159861,null,null,null,'小田原宿の総鎮守。小田原流の神輿振りで知られる例大祭。','https://ja.wikipedia.org/wiki/松原神社_(小田原市)','Wikipedia',true,now()),
('choko-jinja','銚港神社','ちょうこうじんじゃ','shrine','銚港神社','千葉県','銚子市','千葉県銚子市馬場町1-4',35.731694,140.840444,717,null,'https://www.chokojinja.info/','銚子の総氏神。飯沼観音と並ぶ古社で水の龍神を祀る。','https://ja.wikipedia.org/wiki/銚港神社','Wikipedia',true,now()),
('saruta-jinja','猿田神社','さるたじんじゃ','shrine','猿田神社','千葉県','銚子市','千葉県銚子市猿田町1677',35.747220,140.733330,null,null,'http://www.choshikanko.com/extra/saruta/','垂仁朝の創建と伝わる道開きの古社。猿田彦大神を祀る。','https://ja.wikipedia.org/wiki/猿田神社','Wikipedia',true,now()),
('kamegaoka-hachimangu-zushi','亀岡八幡宮','かめがおかはちまんぐう','shrine','亀岡八幡宮','神奈川県','逗子市','神奈川県逗子市逗子5-2-13',35.296278,139.580194,null,null,'https://kamegaoka-hachimangu.com/','逗子の鎮守。鶴岡八幡宮の鶴に対する亀の社と伝わる。','https://ja.wikipedia.org/wiki/亀岡八幡宮_(逗子市)','Wikipedia',true,now()),
('hondo-ji','本土寺','ほんどじ','temple','日蓮宗','千葉県','松戸市','千葉県松戸市平賀63',35.840417,139.928583,1277,'三宝尊','http://www.hondoji.net/','あじさい寺として名高い日蓮宗の名刹。日蓮聖人ゆかり。','https://ja.wikipedia.org/wiki/本土寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='matsubara-jinja-odawara' and d.slug in ('yamato_takeru','susanoo','ukanomitama'))
   or (t.slug='choko-jinja' and d.slug in ('kuraokami'))
   or (t.slug='saruta-jinja' and d.slug in ('sarutahiko'))
   or (t.slug='kamegaoka-hachimangu-zushi' and d.slug in ('hachiman'))
   or (t.slug='hondo-ji' and d.slug in ('sanbo_son'))
on conflict do nothing;

-- ============================================================
-- バッチ3
-- ============================================================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ninigi','邇邇芸命','ににぎのみこと','kami','天津神','{}','記紀','天照大神の孫。天孫降臨の主神で稲穂と国土の守護神。','https://ja.wikipedia.org/wiki/ニニギ','Wikipedia',true,now()),
('ototachibana','弟橘媛','おとたちばなひめ','kami','御霊','{}','記紀','日本武尊の妃。走水の海で入水し夫を救った貞節の女神。','https://ja.wikipedia.org/wiki/オトタチバナヒメ','Wikipedia',true,now()),
('himegami','比売大神','ひめがみ','kami','天津神','{}','記紀','八幡神に並び祀られる女神。宗像三女神とされる事が多い。','https://ja.wikipedia.org/wiki/比売大神','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② ご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ninigi' and g.slug in ('suisan_noko','kaiun','kanai_anzen'))
   or (d.slug='ototachibana' and g.slug in ('renai','kaijo_anzen','kanai_anzen'))
   or (d.slug='himegami' and g.slug in ('kaiun','enmusubi','kaijo_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ozen-ji','王禅寺','おうぜんじ','temple','真言宗豊山派','神奈川県','川崎市','神奈川県川崎市麻生区王禅寺940',35.585222,139.521864,757,'聖観音','禅寺丸柿の発祥地として知られる古刹。武相不動の札所。','https://ja.wikipedia.org/wiki/王禅寺','Wikipedia',true,now()),
('kurihama-tenjinsha','久里浜天神社','くりはまてんじんしゃ','shrine','久里浜天神社','神奈川県','横須賀市','神奈川県横須賀市久里浜5-19-3',35.227917,139.703500,1660,null,'https://tenjinsha.or.jp/','久里浜開拓の鎮守。学問の神菅原道真を祀る。','https://ja.wikipedia.org/wiki/久里浜天神社','Wikipedia',true,now()),
('hashirimizu-jinja','走水神社','はしりみずじんじゃ','shrine','走水神社','神奈川県','横須賀市','神奈川県横須賀市走水2-12-5',35.261444,139.730917,null,null,null,'日本武尊の東征伝説に由来する古社。弟橘媛を配祀。','https://ja.wikipedia.org/wiki/走水神社_(横須賀市)','Wikipedia',true,now()),
('nishi-kano-jinja','西叶神社','にしかのうじんじゃ','shrine','叶神社','神奈川県','横須賀市','神奈川県横須賀市西浦賀1-1-13',35.241940,139.718060,1181,null,'https://kanoujinjya.jp/','浦賀の鎮守。東西の叶神社の勾玉巡りで知られる。','https://ja.wikipedia.org/wiki/叶神社','Wikipedia',true,now()),
('takataki-jinja','高瀧神社','たかたきじんじゃ','shrine','高瀧神社','千葉県','市原市','千葉県市原市高滝1',35.352780,140.153890,672,null,null,'上総の古社。安産・子授けの信仰を集める。','https://ja.wikipedia.org/wiki/高滝神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ozen-ji' and d.slug in ('sho_kannon'))
   or (t.slug='kurihama-tenjinsha' and d.slug in ('michizane'))
   or (t.slug='hashirimizu-jinja' and d.slug in ('yamato_takeru'))
   or (t.slug='nishi-kano-jinja' and d.slug in ('hachiman','himegami','jingu_kogo'))
   or (t.slug='takataki-jinja' and d.slug in ('ninigi'))
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='hashirimizu-jinja' and d.slug in ('ototachibana'))
on conflict do nothing;

-- ============================================================
-- バッチ4
-- ============================================================
-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{}','記紀','雷と剣を司る武神。鹿島神宮の主祭神で武運・厄除の神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now()),
('toyouke','豊受大神','とようけのおおかみ','kami','天津神','{}','記紀','食物と穀物を司る女神。伊勢外宮の主祭神。','https://ja.wikipedia.org/wiki/トヨウケビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② ご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takemikazuchi' and g.slug in ('shobu','yakubarai','shobai'))
   or (d.slug='toyouke' and g.slug in ('shobai','suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('zama-jinja','座間神社','ざまじんじゃ','shrine','座間神社','神奈川県','座間市','神奈川県座間市座間1-3437',35.493083,139.393083,null,null,'https://zamajinja.or.jp/','座間の鎮守。日本武尊を祀り疫病鎮めの伝承を伝える。','https://ja.wikipedia.org/wiki/座間神社','Wikipedia',true,now()),
('fukami-jinja','深見神社','ふかみじんじゃ','shrine','深見神社','神奈川県','大和市','神奈川県大和市深見3367',35.468611,139.471611,478,null,null,'相模国十三座の式内社。樹齢五百年のハルニレが御神木。','https://ja.wikipedia.org/wiki/深見神社','Wikipedia',true,now()),
('oiwa-inari-tamiya-shinjuku','於岩稲荷田宮神社','おいわいなりたみやじんじゃ','shrine','於岩稲荷田宮神社','東京都','新宿区','東京都新宿区左門町17',35.685472,139.721000,null,null,null,'四谷怪談ゆかりのお岩稲荷。田宮家の屋敷神に由来する。','https://ja.wikipedia.org/wiki/於岩稲荷田宮神社_(新宿区)','Wikipedia',true,now()),
('amanawa-shinmei-jinja','甘縄神明神社','あまなわしんめいじんじゃ','shrine','甘縄神明神社','神奈川県','鎌倉市','神奈川県鎌倉市長谷1-12-1',35.314500,139.537000,710,null,null,'鎌倉最古と伝わる神明社。天照大神を祀る。','https://ja.wikipedia.org/wiki/甘縄神明神社','Wikipedia',true,now()),
('yakumo-jinja-kamakura','八雲神社','やくもじんじゃ','shrine','八雲神社','神奈川県','鎌倉市','神奈川県鎌倉市大町1-11-22',35.315083,139.554611,null,null,null,'鎌倉大町の鎮守。祇園社を勧請した厄除けの古社。','https://ja.wikipedia.org/wiki/八雲神社_(鎌倉市大町)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='zama-jinja' and d.slug in ('yamato_takeru'))
   or (t.slug='fukami-jinja' and d.slug in ('kuraokami','takemikazuchi'))
   or (t.slug='oiwa-inari-tamiya-shinjuku' and d.slug in ('toyouke','ukanomitama'))
   or (t.slug='amanawa-shinmei-jinja' and d.slug in ('amaterasu'))
   or (t.slug='yakumo-jinja-kamakura' and d.slug in ('susanoo','kushinadahime'))
on conflict do nothing;
