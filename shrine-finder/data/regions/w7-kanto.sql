-- w7-kanto.sql : 関東地方 著名社寺データ拡張（_have_kanto.txt 未収録）
-- 出典: ja.wikipedia.org infobox 十進座標で裏取り
-- 担当県: 茨城・栃木・群馬・埼玉・千葉・東京・神奈川

-- ===== バッチ1 (5件) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('susanoo','須佐之男命','すさのおのみこと','kami','天津神','{}','記紀','天照大神の弟。八岐大蛇退治で知られる荒ぶる神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kushinadahime','櫛稲田姫命','くしなだひめのみこと','kami','国津神','{}','記紀','スサノオの妻。稲田の神。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方浄瑠璃浄土の教主。病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='susanoo' and g.slug in ('yakubarai','shobu','enmusubi'))
or (d.slug='kushinadahime' and g.slug in ('enmusubi','anzan','kanai_anzen'))
or (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kanai_anzen'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('murahi-jinja','村檜神社','むらひじんじゃ','shrine','村檜神社（下野国三宮・式内社）','栃木県','栃木市','栃木県栃木市岩舟町小野寺4697',36.3697194,139.6244389,646,null,null,'下野国三宮。本殿は国指定重要文化財。','https://ja.wikipedia.org/wiki/村檜神社','Wikipedia',true,now()),
('soganji-kazo','總願寺','そうがんじ','temple','真言宗智山派','埼玉県','加須市','埼玉県加須市不動岡2-9-18',36.135250,139.585306,1616,'不動明王','https://souganji.com/','不動ヶ岡不動。関東三大不動の一つ、節分会で著名。','https://ja.wikipedia.org/wiki/總願寺','Wikipedia',true,now()),
('mamada-hachimangu','間々田八幡宮','ままだはちまんぐう','shrine','間々田八幡宮','栃木県','小山市','栃木県小山市間々田2330-1',36.274472,139.765944,729,null,'https://www.mamada-hachiman.jp/','奈良期創建。蛇祭り（じゃがまいた）で知られる。','https://ja.wikipedia.org/wiki/間々田八幡宮','Wikipedia',true,now()),
('rokusho-jinja-oiso','六所神社','ろくしょじんじゃ','shrine','六所神社（相模国総社・旧郷社）','神奈川県','中郡大磯町','神奈川県中郡大磯町国府本郷935',35.30694,139.27444,594,null,'http://www.rokusho.jp/','相模国総社。国府祭（こうのまち）で知られる。','https://ja.wikipedia.org/wiki/六所神社_(大磯町)','Wikipedia',true,now()),
('sagami-kokubunji','相模国分寺','さがみこくぶんじ','temple','高野山真言宗','神奈川県','海老名市','神奈川県海老名市国分南1-25-38',35.4526750,139.3991389,750,'薬師如来',null,'聖武天皇の詔による相模国分寺の法燈を継ぐ寺。','https://ja.wikipedia.org/wiki/相模国分寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='murahi-jinja' and d.slug in ('hachiman'))
or (t.slug='soganji-kazo' and d.slug in ('fudo_myoo'))
or (t.slug='mamada-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='rokusho-jinja-oiso' and d.slug in ('kushinadahime','susanoo','okuninushi'))
or (t.slug='sagami-kokubunji' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- ===== バッチ2 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takeminakata','建御名方命','たけみなかたのみこと','kami','国津神','{}','記紀','大国主の子。諏訪大社の祭神で軍神・農耕神。','https://ja.wikipedia.org/wiki/タケミナカタ','Wikipedia',true,now()),
('iwakamutsukari','磐鹿六雁命','いわかむつかりのみこと','kami','国津神','{}','記紀','料理・調味の祖神。料理人の崇敬を集める。','https://ja.wikipedia.org/wiki/磐鹿六雁命','Wikipedia',true,now()),
('bato_kannon','馬頭観音','ばとうかんのん','buddha','菩薩','{}','仏教','六観音の一。憤怒相をとり、家畜守護・厄除の仏。','https://ja.wikipedia.org/wiki/馬頭観音','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takeminakata' and g.slug in ('shobu','shigoto','kaiun'))
or (d.slug='iwakamutsukari' and g.slug in ('shobai','shigoto','kanai_anzen'))
or (d.slug='bato_kannon' and g.slug in ('yakubarai','petto','tabi_anzen'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yuki-suwa-jinja','結城諏訪神社','ゆうきすわじんじゃ','shrine','結城諏訪神社（旧郷社）','茨城県','結城市','茨城県結城市上山川161-1',36.24312417,139.87188583,940,null,'http://www.suwa-jinja.jp/','藤原秀郷が平将門討伐の戦勝を機に創建と伝わる。','https://ja.wikipedia.org/wiki/結城諏訪神社','Wikipedia',true,now()),
('ikushina-jinja','生品神社','いくしなじんじゃ','shrine','生品神社（旧県社）','群馬県','太田市','群馬県太田市新田市野井町645ほか',36.317472,139.307444,null,null,null,'新田義貞が鎌倉幕府討伐の旗揚げをした地として国史跡。','https://ja.wikipedia.org/wiki/生品神社','Wikipedia',true,now()),
('takabe-jinja','高家神社','たかべじんじゃ','shrine','高家神社（式内社・旧村社）','千葉県','南房総市','千葉県南房総市千倉町南朝夷164',34.96222,139.94944,null,null,null,'日本唯一の料理の祖神を祀る社。庖丁式の神事で著名。','https://ja.wikipedia.org/wiki/高家神社','Wikipedia',true,now()),
('saikoin-ishioka','西光院','さいこういん','temple','天台宗','茨城県','石岡市','茨城県石岡市吉生2734',36.244750,140.151500,807,'馬頭観世音菩薩',null,'懸造の本堂を持ち「関東の清水寺」と称される立木観音。','https://ja.wikipedia.org/wiki/西光院_(石岡市)','Wikipedia',true,now()),
('maebashi-hachimangu','前橋八幡宮','まえばしはちまんぐう','shrine','前橋八幡宮（旧県社）','群馬県','前橋市','群馬県前橋市本町2丁目',36.3888889,139.0705611,null,null,null,'前橋の総鎮守。貞観年間の創建と伝わる。','https://ja.wikipedia.org/wiki/前橋八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yuki-suwa-jinja' and d.slug in ('takeminakata'))
or (t.slug='ikushina-jinja' and d.slug in ('okuninushi'))
or (t.slug='takabe-jinja' and d.slug in ('iwakamutsukari','amaterasu','ukanomitama'))
or (t.slug='saikoin-ishioka' and d.slug in ('bato_kannon'))
or (t.slug='maebashi-hachimangu' and d.slug in ('hachiman'))
on conflict do nothing;

-- ===== バッチ3 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('nigihayahi','邇芸速日命','にぎはやひのみこと','kami','天津神','{}','記紀','物部氏の祖神。天磐船で天降ったと伝わる。','https://ja.wikipedia.org/wiki/ニギハヤヒ','Wikipedia',true,now()),
('omononushi','大物主神','おおものぬしのかみ','kami','国津神','{}','記紀','三輪山の神。国造り・農耕・酒造の神。','https://ja.wikipedia.org/wiki/オオモノヌシ','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{}','仏教','密教の根本仏。宇宙の真理そのものとされる。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖。悟りを開いた釈尊。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='nigihayahi' and g.slug in ('shobu','kaiun','shusse'))
or (d.slug='omononushi' and g.slug in ('shobai','byoki_heyu','kaiun'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='shaka_nyorai' and g.slug in ('byoki_heyu','jouju','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kitano-tenjinsha-tokorozawa','北野天神社','きたのてんじんしゃ','shrine','北野天神社（式内論社・旧県社）','埼玉県','所沢市','埼玉県所沢市小手指元町3-28-44',35.790556,139.428694,null,null,null,'物部天神社・国渭地祇神社・天満天神社の三社を合祀。','https://ja.wikipedia.org/wiki/北野天神社_(所沢市)','Wikipedia',true,now()),
('tokorozawa-shinmeisha','所澤神明社','ところざわしんめいしゃ','shrine','所澤神明社（旧村社）','埼玉県','所沢市','埼玉県所沢市宮本町1-2-4',35.79417,139.46333,null,null,'https://www.shinmeisha.or.jp/','武蔵野のお伊勢様と称される。日本初飛行ゆかりの社。','https://ja.wikipedia.org/wiki/所澤神明社','Wikipedia',true,now()),
('daifukuji-tateyama','大福寺','だいふくじ','temple','真言宗智山派','千葉県','館山市','千葉県館山市船形835',35.030917,139.84111,717,'十一面観世音菩薩',null,'崖観音。断崖の懸造に磨崖仏を祀る。館山湾を一望。','https://ja.wikipedia.org/wiki/大福寺_(館山市)','Wikipedia',true,now()),
('komatsuji-minamiboso','小松寺','こまつじ','temple','真言宗智山派','千葉県','南房総市','千葉県南房総市千倉町大貫1057',34.95,139.92,718,'薬師如来',null,'役行者開創と伝わる古刹。安房国札三十四観音二十六番。','https://ja.wikipedia.org/wiki/小松寺_(南房総市)','Wikipedia',true,now()),
('ankokuronji-kamakura','安国論寺','あんこくろんじ','temple','日蓮宗','神奈川県','鎌倉市','神奈川県鎌倉市大町4-4-18',35.3114528,139.558722,1253,'釈迦如来',null,'日蓮が立正安国論を執筆した岩窟のそばに建つ日蓮宗寺院。','https://ja.wikipedia.org/wiki/安国論寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kitano-tenjinsha-tokorozawa' and d.slug in ('nigihayahi','okuninushi','michizane'))
or (t.slug='tokorozawa-shinmeisha' and d.slug in ('amaterasu','ukanomitama','omononushi'))
or (t.slug='daifukuji-tateyama' and d.slug in ('sho_kannon'))
or (t.slug='komatsuji-minamiboso' and d.slug in ('yakushi_nyorai'))
or (t.slug='ankokuronji-kamakura' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== バッチ4 (5件) =====
-- 新規神仏なし（既存 deity slug を使用）

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('myohoji-suginami','妙法寺','みょうほうじ','temple','日蓮宗','東京都','杉並区','東京都杉並区堀ノ内3-48-8',35.692444,139.651806,null,'三宝尊（祖師日蓮像）',null,'堀ノ内のお祖師さま。厄除け祖師として江戸期から信仰を集める。','https://ja.wikipedia.org/wiki/妙法寺_(杉並区)','Wikipedia',true,now()),
('joshinji-kuhonbutsu','浄真寺','じょうしんじ','temple','浄土宗','東京都','世田谷区','東京都世田谷区奥沢7-41-3',35.608167,139.660875,1678,'釈迦如来',null,'九品仏。九体の阿弥陀如来像を安置することで知られる。','https://ja.wikipedia.org/wiki/九品仏浄真寺','Wikipedia',true,now()),
('kugenuma-fushimi-inari','鵠沼伏見稲荷神社','くげぬまふしみいなりじんじゃ','shrine','鵠沼伏見稲荷神社','神奈川県','藤沢市','神奈川県藤沢市鵠沼海岸5-11-17',35.3208056,139.4634167,1943,null,null,'湘南のお稲荷さん。伏見稲荷大社から勧請。','https://ja.wikipedia.org/wiki/鵠沼伏見稲荷神社','Wikipedia',true,now()),
('jojuin-kamakura','成就院','じょうじゅいん','temple','真言宗大覚寺派','神奈川県','鎌倉市','神奈川県鎌倉市極楽寺1-1-5',35.309028,139.531222,1219,'不動明王',null,'極楽寺坂のあじさい寺。縁結びの不動明王で知られる。','https://ja.wikipedia.org/wiki/成就院_(鎌倉市)','Wikipedia',true,now()),
('hongakuji-kamakura','本覚寺','ほんがくじ','temple','日蓮宗','神奈川県','鎌倉市','神奈川県鎌倉市小町1-12-12',35.317333,139.552389,1436,'釈迦如来',null,'東身延。鎌倉江の島七福神の夷神を祀り初えびすで賑わう。','https://ja.wikipedia.org/wiki/本覚寺_(鎌倉市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='myohoji-suginami' and d.slug in ('shaka_nyorai'))
or (t.slug='joshinji-kuhonbutsu' and d.slug in ('shaka_nyorai'))
or (t.slug='kugenuma-fushimi-inari' and d.slug in ('ukanomitama'))
or (t.slug='jojuin-kamakura' and d.slug in ('fudo_myoo'))
or (t.slug='hongakuji-kamakura' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== バッチ5 (5件) =====
-- 新規神仏なし（既存 deity slug を使用）

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('satakeji-hitachiota','佐竹寺','さたけじ','temple','真言宗豊山派','茨城県','常陸太田市','茨城県常陸太田市天神林町2404',36.526028,140.504667,807,'十一面観世音菩薩',null,'坂東三十三観音二十二番。本堂は国指定重要文化財。','https://ja.wikipedia.org/wiki/佐竹寺','Wikipedia',true,now()),
('koyamaji-sakuragawa','小山寺','おやまじ','temple','天台宗','茨城県','桜川市','茨城県桜川市富谷2190',36.383361,140.100250,735,'十一面観世音菩薩',null,'富谷観音。室町期の三重塔は関東有数の古塔。','https://ja.wikipedia.org/wiki/小山寺_(桜川市)','Wikipedia',true,now()),
('unganji-otawara','雲巌寺','うんがんじ','temple','臨済宗妙心寺派','栃木県','大田原市','栃木県大田原市雲岩寺27',36.85278,140.20944,1131,'釈迦如来',null,'日本四大禅道場の一。松尾芭蕉が奥の細道で訪れた古刹。','https://ja.wikipedia.org/wiki/雲巌寺','Wikipedia',true,now()),
('manpukuji-kamakura','満福寺','まんぷくじ','temple','真言宗大覚寺派','神奈川県','鎌倉市','神奈川県鎌倉市腰越2-4-8',35.307639,139.495028,744,'薬師如来',null,'源義経が腰越状を記した寺。弁慶ゆかりの遺品が残る。','https://ja.wikipedia.org/wiki/満福寺_(鎌倉市)','Wikipedia',true,now()),
('chokokuji-shiraiwa','長谷寺','ちょうこくじ','temple','金峯山修験本宗','群馬県','高崎市','群馬県高崎市白岩町',36.385278,138.932611,711,'十一面観世音菩薩',null,'白岩観音。坂東三十三観音十五番札所。','https://ja.wikipedia.org/wiki/長谷寺_(高崎市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='satakeji-hitachiota' and d.slug in ('sho_kannon'))
or (t.slug='koyamaji-sakuragawa' and d.slug in ('sho_kannon'))
or (t.slug='unganji-otawara' and d.slug in ('shaka_nyorai'))
or (t.slug='manpukuji-kamakura' and d.slug in ('yakushi_nyorai'))
or (t.slug='chokokuji-shiraiwa' and d.slug in ('sho_kannon'))
on conflict do nothing;

-- ===== バッチ6 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sarutahiko','猿田彦命','さるたひこのみこと','kami','国津神','{}','記紀','天孫降臨を先導した道開きの神。導き・交通の神。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sarutahiko' and g.slug in ('kotsu_anzen','kaiun','shusse'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ryushoin-namegawa','龍正院','りゅうしょういん','temple','天台宗','千葉県','成田市','千葉県成田市滑川1196',35.867083,140.341944,838,'十一面観世音菩薩',null,'滑河観音。坂東三十三観音二十八番。仁王門は重要文化財。','https://ja.wikipedia.org/wiki/龍正院','Wikipedia',true,now()),
('kannonkyoji-shibayama','観音教寺','かんのんきょうじ','temple','天台宗','千葉県','山武郡芝山町','千葉県山武郡芝山町芝山298',35.692778,140.426667,781,'十一面観世音菩薩',null,'芝山仁王尊。火事・盗難除けで江戸町火消の信仰を集めた。','https://ja.wikipedia.org/wiki/観音教寺','Wikipedia',true,now()),
('shoboji-iwadono','正法寺','しょうぼうじ','temple','真言宗智山派','埼玉県','東松山市','埼玉県東松山市岩殿1229',36.00139,139.362361,718,'千手観世音菩薩',null,'岩殿観音。坂東三十三観音十番札所。','https://ja.wikipedia.org/wiki/正法寺_(東松山市)','Wikipedia',true,now()),
('noninji-hanno','能仁寺','のうにんじ','temple','曹洞宗','埼玉県','飯能市','埼玉県飯能市飯能1329',35.860611,139.309694,1501,'毘盧遮那仏',null,'天覧山麓の禅刹。桃山期の池泉鑑賞式庭園で知られる。','https://ja.wikipedia.org/wiki/能仁寺_(飯能市)','Wikipedia',true,now()),
('muku-jinja-chichibu','椋神社','むくじんじゃ','shrine','椋神社（式内論社・旧郷社）','埼玉県','秩父市','埼玉県秩父市下吉田7377',36.045111,139.032889,null,null,null,'秩父吉田の龍勢（手作りロケット）の奉納で全国に知られる。','https://ja.wikipedia.org/wiki/椋神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ryushoin-namegawa' and d.slug in ('sho_kannon'))
or (t.slug='kannonkyoji-shibayama' and d.slug in ('sho_kannon'))
or (t.slug='shoboji-iwadono' and d.slug in ('sho_kannon'))
or (t.slug='noninji-hanno' and d.slug in ('dainichi_nyorai'))
or (t.slug='muku-jinja-chichibu' and d.slug in ('sarutahiko'))
on conflict do nothing;

-- ===== バッチ7 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('omiyanome','大宮売命','おおみやのめのみこと','kami','天津神','{}','記紀','稲荷神の一柱。和合・接客・芸能を司る神。','https://ja.wikipedia.org/wiki/オオミヤノメ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='omiyanome' and g.slug in ('shobai','geino','kanai_anzen'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('susanoo-jinja-takasaki','進雄神社','すさのおじんじゃ','shrine','進雄神社（旧郷社）','群馬県','高崎市','群馬県高崎市柴崎町801',36.318667,139.049194,869,null,null,'尾張津島牛頭天王社の勧請。歴代武将が戦勝を祈願した。','https://ja.wikipedia.org/wiki/進雄神社_(高崎市)','Wikipedia',true,now()),
('kashozan-ryugein','迦葉山龍華院','かしょうざんりゅうげいん','temple','曹洞宗','群馬県','沼田市','群馬県沼田市上発知町445',36.751389,139.063750,848,'十一面観世音菩薩',null,'迦葉山の天狗で知られる弥勒寺。日本三大天狗の一つ。','https://ja.wikipedia.org/wiki/弥勒寺_(沼田市)','Wikipedia',true,now()),
('mizonokuchi-jinja','溝口神社','みぞのくちじんじゃ','shrine','溝口神社（旧村社）','神奈川県','川崎市','神奈川県川崎市高津区溝口2-25-1',35.6023944,139.6103778,null,null,null,'溝口の総鎮守。江戸期は赤城大明神と称した。','https://ja.wikipedia.org/wiki/溝口神社','Wikipedia',true,now()),
('shirasasa-inari','白笹稲荷神社','しらささいなりじんじゃ','shrine','白笹稲荷神社','神奈川県','秦野市','神奈川県秦野市今泉1089',35.365083,139.21639,null,null,null,'関東三大稲荷の一つ。初午祭で賑わう。','https://ja.wikipedia.org/wiki/白笹稲荷神社','Wikipedia',true,now()),
('kotohira-jinja-kawasaki','琴平神社','ことひらじんじゃ','shrine','琴平神社','神奈川県','川崎市','神奈川県川崎市麻生区王禅寺東5',35.581833,139.517833,1570,null,null,'讃岐金刀比羅宮を勧請。武州柿生の里の鎮守。','https://ja.wikipedia.org/wiki/琴平神社_(川崎市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='susanoo-jinja-takasaki' and d.slug in ('susanoo'))
or (t.slug='kashozan-ryugein' and d.slug in ('sho_kannon'))
or (t.slug='mizonokuchi-jinja' and d.slug in ('amaterasu'))
or (t.slug='shirasasa-inari' and d.slug in ('ukanomitama','omiyanome','sarutahiko'))
or (t.slug='kotohira-jinja-kawasaki' and d.slug in ('amaterasu','omononushi'))
on conflict do nothing;
