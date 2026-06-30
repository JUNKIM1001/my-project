-- w8-kanto.sql : 関東地方 著名社寺データ拡張（_have_kanto.txt 未収録）
-- 出典: ja.wikipedia.org infobox 十進座標で裏取り
-- 担当県: 茨城・栃木・群馬・埼玉・千葉・東京・神奈川

-- ===== バッチ1 (5件) =====

-- ① 新規神仏
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sukunabikona','少彦名命','すくなびこなのみこと','kami','国津神','{}','記紀','大国主と共に国造りを行った小さな神。医薬・温泉・酒造の神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','大国主の子。託宣・漁業の神で、えびす神とも習合する。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sukunabikona' and g.slug in ('byoki_heyu','shobai','choju'))
or (d.slug='kotoshironushi' and g.slug in ('shobai','suisan_noko','kaiun'))
on conflict do nothing;

-- ③ 社寺
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ogosato-tenmangu','大生郷天満宮','おおのごうてんまんぐう','shrine','大生郷天満宮（旧郷社）','茨城県','常総市','茨城県常総市大生郷町1234',36.060528,139.952694,929,null,'https://tenmangu.or.jp/','菅原道真の遺骨を祀ると伝わる「日本三天神」の一つ。','https://ja.wikipedia.org/wiki/大生郷天満宮','Wikipedia',true,now()),
('suzume-jinja-koga','雀神社','すずめじんじゃ','shrine','雀神社（旧郷社・古河総鎮守）','茨城県','古河市','茨城県古河市宮前町4-52',36.2006639,139.6974750,1605,null,null,'古河の総鎮守。社殿は徳川秀忠による造営と伝わる。','https://ja.wikipedia.org/wiki/雀神社_(古河市)','Wikipedia',true,now()),
('samuta-jinja','寒田神社','さむたじんじゃ','shrine','寒田神社（相模国式内社・旧郷社）','神奈川県','足柄上郡松田町','神奈川県足柄上郡松田町松田惣領1767',35.34583,139.13361,315,null,'http://www.samuta.or.jp/','酒匂川を望む相模国の式内社。日本武尊東征の伝承が残る古社。','https://ja.wikipedia.org/wiki/寒田神社','Wikipedia',true,now()),
('daikoin-ota','大光院','だいこういん','temple','浄土宗','群馬県','太田市','群馬県太田市金山町37-8',36.305722,139.36972,1613,'阿弥陀如来','https://oeyamadaikoin.jp/','徳川家康が新田義重追善のため建立。子育て呑龍として知られる。','https://ja.wikipedia.org/wiki/大光院_(太田市)','Wikipedia',true,now()),
('renkeiji-kawagoe','蓮馨寺','れんけいじ','temple','浄土宗鎮西派','埼玉県','川越市','埼玉県川越市連雀町7-1',35.919611,139.481889,1549,'阿弥陀如来','https://renkeiji.jp/','小江戸川越の名刹。おびんづる様と呑龍上人で親しまれる。','https://ja.wikipedia.org/wiki/蓮馨寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ogosato-tenmangu' and d.slug in ('michizane'))
or (t.slug='suzume-jinja-koga' and d.slug in ('okuninushi','sukunabikona','kotoshironushi'))
or (t.slug='samuta-jinja' and d.slug in ('yamatotakeru','ototachibanahime','michizane','hachiman'))
or (t.slug='daikoin-ota' and d.slug in ('amida_nyorai'))
or (t.slug='renkeiji-kawagoe' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== バッチ2 (5件) =====

-- （新規神仏なし。すべて既存 deity slug を使用）

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('suginomori-jinja','椙森神社','すぎのもりじんじゃ','shrine','椙森神社（旧村社）','東京都','中央区','東京都中央区日本橋堀留町1-10-2',35.688389,139.779583,1466,null,'https://sugimorijinja.or.jp/','日本橋七福神の恵比寿。富くじ興行で栄えた商売繁盛の社。','https://ja.wikipedia.org/wiki/椙森神社','Wikipedia',true,now()),
('tokyo-daijingu','東京大神宮','とうきょうだいじんぐう','shrine','東京大神宮（旧官祭招魂社系・神宮奉斎会）','東京都','千代田区','東京都千代田区富士見2-4-1',35.6999833,139.7468694,1880,null,'http://www.tokyodaijingu.or.jp/','「東京のお伊勢さま」。神前結婚式発祥の社で縁結びの社として著名。','https://ja.wikipedia.org/wiki/東京大神宮','Wikipedia',true,now()),
('ueno-toshogu','上野東照宮','うえのとうしょうぐう','shrine','上野東照宮（旧府社）','東京都','台東区','東京都台東区上野公園9-88',35.715361,139.770583,1627,null,'http://www.uenotoshogu.com/','上野公園内の徳川家康を祀る東照宮。金色殿と牡丹苑で知られる。','https://ja.wikipedia.org/wiki/上野東照宮','Wikipedia',true,now()),
('kasama-inari-tokyo','笠間稲荷神社東京別社','かさまいなりじんじゃとうきょうべっしゃ','shrine','笠間稲荷神社東京別社','東京都','中央区','東京都中央区日本橋浜町2-11-6',35.6881,139.7853,1860,null,'https://www.kasama.or.jp/tokyo/','日本橋七福神の寿老人。笠間稲荷の東京別社で五穀豊穣・商売の社。','https://ja.wikipedia.org/wiki/笠間稲荷神社東京別社','Wikipedia',true,now()),
('shimotsuke-issha-hachimangu','下野国一社八幡宮','しもつけのくにいっしゃはちまんぐう','shrine','下野国一社八幡宮（旧県社）','栃木県','足利市','栃木県足利市八幡町387',36.323972,139.435861,1056,null,'https://www.kadotainari.com/','源頼義・義家が創建した下野第一の八幡宮。境内の門田稲荷は縁切りで著名。','https://ja.wikipedia.org/wiki/下野国一社八幡宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='suginomori-jinja' and d.slug in ('ukanomitama','kotoshironushi'))
or (t.slug='tokyo-daijingu' and d.slug in ('amaterasu','toyouke'))
or (t.slug='ueno-toshogu' and d.slug in ('ieyasu'))
or (t.slug='kasama-inari-tokyo' and d.slug in ('ukanomitama'))
or (t.slug='shimotsuke-issha-hachimangu' and d.slug in ('hachiman','jingu_kogo','himegami'))
on conflict do nothing;

-- ===== バッチ3 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('gozuryu','五頭龍大神','ごずりゅうおおかみ','kami','国津神','{}','社伝','江の島・腰越に伝わる五頭龍の神。天女（弁財天）と結ばれた龍神。','https://ja.wikipedia.org/wiki/龍口明神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='gozuryu' and g.slug in ('enmusubi','mizu_amagoi','yakubarai'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hinata-yakushi','日向薬師','ひなたやくし','temple','高野山真言宗','神奈川県','伊勢原市','神奈川県伊勢原市日向1644',35.439611,139.275194,716,'薬師三尊','http://hinatayakushi.com/','宝城坊。日本三薬師の一つに数えられる丹沢山麓の古刹。','https://ja.wikipedia.org/wiki/日向薬師','Wikipedia',true,now()),
('tsurugaya-hachimangu','鶴谷八幡宮','つるがやはちまんぐう','shrine','鶴谷八幡宮（安房国総社・旧県社）','千葉県','館山市','千葉県館山市八幡68',35.005222,139.86667,1000,null,null,'安房国の総社。例祭やわたんまちで知られる南房総の古社。','https://ja.wikipedia.org/wiki/鶴谷八幡宮','Wikipedia',true,now()),
('otori-jinja-asakusa','鷲神社','おおとりじんじゃ','shrine','鷲神社（旧村社）','東京都','台東区','東京都台東区千束3-18-7',35.722556,139.791861,null,null,'https://otorisama.or.jp/','「おとりさま」。11月の酉の市発祥の社として知られる開運の社。','https://ja.wikipedia.org/wiki/鷲神社_(台東区)','Wikipedia',true,now()),
('jufukuji-kamakura','寿福寺','じゅふくじ','temple','臨済宗建長寺派','神奈川県','鎌倉市','神奈川県鎌倉市扇ガ谷1-17-7',35.32417,139.549028,1200,'釈迦如来',null,'鎌倉五山第三位。北条政子が栄西を開山として創建。','https://ja.wikipedia.org/wiki/寿福寺','Wikipedia',true,now()),
('ryuko-myojin','龍口明神社','りゅうこうみょうじんじゃ','shrine','龍口明神社（旧村社）','神奈川県','鎌倉市','神奈川県鎌倉市腰越1548-4',35.318194,139.507028,538,null,'http://gozuryu.com','江の島の弁財天と結ばれた五頭龍を祀る、鎌倉最古級の社。','https://ja.wikipedia.org/wiki/龍口明神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hinata-yakushi' and d.slug in ('yakushi_nyorai'))
or (t.slug='tsurugaya-hachimangu' and d.slug in ('hachiman','chuai','jingu_kogo'))
or (t.slug='otori-jinja-asakusa' and d.slug in ('amenohiwashi','yamatotakeru'))
or (t.slug='jufukuji-kamakura' and d.slug in ('shaka_nyorai'))
or (t.slug='ryuko-myojin' and d.slug in ('tamayorihime','gozuryu'))
on conflict do nothing;

-- ===== バッチ4 (5件) =====
-- （新規神仏なし。すべて既存 deity slug を使用）

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('araiyakushi-baishoin','新井薬師 梅照院','あらいやくし ばいしょういん','temple','真言宗豊山派','東京都','中野区','東京都中野区新井5-3-5',35.714139,139.667556,1586,'薬師如来・如意輪観音','https://araiyakushi.or.jp/','「新井薬師」。眼病平癒・子育て薬師として信仰を集める。','https://ja.wikipedia.org/wiki/新井薬師','Wikipedia',true,now()),
('matsushima-jinja','松島神社','まつしまじんじゃ','shrine','松島神社（旧村社）','東京都','中央区','東京都中央区日本橋人形町2-15-2',35.6846500,139.7854389,1585,null,'http://www.matsushimajinja.com/','日本橋七福神の大黒天。多くの神を祀る人形町の鎮守。','https://ja.wikipedia.org/wiki/松島神社','Wikipedia',true,now()),
('ryuzoji-maebashi','龍蔵寺','りゅうぞうじ','temple','天台宗','群馬県','前橋市','群馬県前橋市龍蔵寺町68',36.420583,139.072250,783,'阿弥陀如来','https://aoyagidaishi.com/','青柳大師。元三大師（厄除大師）の霊場として知られる。','https://ja.wikipedia.org/wiki/龍蔵寺_(前橋市)','Wikipedia',true,now()),
('fukutoku-jinja','福徳神社','ふくとくじんじゃ','shrine','福徳神社（芽吹稲荷）','東京都','中央区','東京都中央区日本橋室町2-4-14',35.687306,139.77444,859,null,'https://mebuki.jp/','日本橋の「芽吹稲荷」。徳川家康も参詣した宝くじ・金運の社。','https://ja.wikipedia.org/wiki/福徳神社','Wikipedia',true,now()),
('shinohara-hachiman','篠原八幡神社','しのはらはちまんじんじゃ','shrine','篠原八幡神社（旧村社）','神奈川県','横浜市','神奈川県横浜市港北区篠原町2735',35.505194,139.62333,1192,null,'http://www.shinohara-80000.jp/','源頼朝の創建と伝わる横浜・新横浜の鎮守。','https://ja.wikipedia.org/wiki/篠原八幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='araiyakushi-baishoin' and d.slug in ('yakushi_nyorai','nyoirin_kannon'))
or (t.slug='matsushima-jinja' and d.slug in ('izanagi'))
or (t.slug='ryuzoji-maebashi' and d.slug in ('amida_nyorai'))
or (t.slug='fukutoku-jinja' and d.slug in ('ukanomitama'))
or (t.slug='shinohara-hachiman' and d.slug in ('hachiman'))
on conflict do nothing;

-- ===== バッチ5 (5件) =====
-- （新規神仏なし。すべて既存 deity slug を使用）

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yabo-tenmangu','谷保天満宮','やぼてんまんぐう','shrine','谷保天満宮（旧府社）','東京都','国立市','東京都国立市谷保5209',35.680167,139.443667,903,null,'http://www.yabotenmangu.or.jp/','東日本最古の天満宮。関東三大天神の一つで交通安全祈願発祥の社。','https://ja.wikipedia.org/wiki/谷保天満宮','Wikipedia',true,now()),
('fuda-tenjin','布多天神社','ふだてんじんしゃ','shrine','布多天神社（式内社・旧郷社）','東京都','調布市','東京都調布市調布ヶ丘1-8-1',35.656722,139.545528,1477,null,'https://fudatenjin.or.jp/','調布の総鎮守。式内社で学問・厄除の天神様として信仰される。','https://ja.wikipedia.org/wiki/布多天神社','Wikipedia',true,now()),
('igusa-hachimangu','井草八幡宮','いぐさはちまんぐう','shrine','井草八幡宮（旧郷社）','東京都','杉並区','東京都杉並区善福寺1-33-1',35.716083,139.595583,null,null,'https://www.igusahachimangu.jp/','源頼朝が奥州征伐の戦勝を祈願したと伝わる広大な杜の八幡宮。','https://ja.wikipedia.org/wiki/井草八幡宮','Wikipedia',true,now()),
('jomyoji-kamakura','浄妙寺','じょうみょうじ','temple','臨済宗建長寺派','神奈川県','鎌倉市','神奈川県鎌倉市浄明寺3-8-31',35.322833,139.571306,1188,'釈迦如来','https://tokasan-jomyoji.com/','鎌倉五山第五位。足利氏ゆかりの禅刹で枯山水庭園と茶室で知られる。','https://ja.wikipedia.org/wiki/浄妙寺_(鎌倉市)','Wikipedia',true,now()),
('ekoin-ryogoku','回向院','えこういん','temple','浄土宗','東京都','墨田区','東京都墨田区両国2-8-10',35.6934,139.7919,1657,'阿弥陀如来','https://ekoin.or.jp/','明暦の大火の供養に始まる「諸宗山」。勧進相撲発祥の地。','https://ja.wikipedia.org/wiki/回向院','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yabo-tenmangu' and d.slug in ('michizane'))
or (t.slug='fuda-tenjin' and d.slug in ('sukunabikona','michizane'))
or (t.slug='igusa-hachimangu' and d.slug in ('hachiman'))
or (t.slug='jomyoji-kamakura' and d.slug in ('shaka_nyorai'))
or (t.slug='ekoin-ryogoku' and d.slug in ('amida_nyorai'))
on conflict do nothing;

-- ===== バッチ6 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('ganzan_daishi','元三大師','がんざんだいし','buddha','高僧','{}','仏教','天台宗の高僧良源（慈恵大師）。厄除け大師・角大師として信仰される。','https://ja.wikipedia.org/wiki/良源','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='ganzan_daishi' and g.slug in ('yakubarai','majo_kekkai','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('haijima-daishi','拝島大師 本覚院','はいじまだいし ほんがくいん','temple','天台宗','東京都','昭島市','東京都昭島市拝島町1-6-15',35.705778,139.347139,1578,'元三大師（良源）','https://www.haijimadaishi.com/','正月のだるま市で賑わう天台宗の名刹。厄除け大師。','https://ja.wikipedia.org/wiki/拝島大師','Wikipedia',true,now()),
('gojo-tenjinja','五條天神社','ごじょうてんじんしゃ','shrine','五條天神社（旧無格社）','東京都','台東区','東京都台東区上野公園4-17',35.713750,139.772111,null,null,'https://gojotenjinja.jp/','上野公園内。医薬の神を祀り、菅原道真も配祀する古社。','https://ja.wikipedia.org/wiki/五條天神社_(台東区)','Wikipedia',true,now()),
('ryugeji-kanazawa','龍華寺','りゅうげじ','temple','真言宗御室派','神奈川県','横浜市','神奈川県横浜市金沢区洲崎町9-31',35.334583,139.626528,1499,'大日如来','https://ryugeji.com/','金沢七福神の大黒天。ぼたん寺として親しまれる名刹。','https://ja.wikipedia.org/wiki/龍華寺_(横浜市)','Wikipedia',true,now()),
('tamagawa-daishi','玉川大師 玉真院','たまがわだいし ぎょくしんいん','temple','真言宗智山派','東京都','世田谷区','東京都世田谷区瀬田4-13-3',35.618778,139.627167,1925,'弘法大師','http://www.tamagawa-daishi.com/','地下霊場（おむろ）で知られる弘法大師信仰の寺。','https://ja.wikipedia.org/wiki/玉川大師','Wikipedia',true,now()),
('senryuji-komae','泉龍寺','せんりゅうじ','temple','曹洞宗','東京都','狛江市','東京都狛江市元和泉1-6-1',35.633056,139.575694,765,'釈迦如来','https://senryuji.or.jp/','良弁開創と伝わる狛江の名刹。雨乞いの弁財天池で知られる。','https://ja.wikipedia.org/wiki/泉龍寺_(狛江市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='haijima-daishi' and d.slug in ('ganzan_daishi'))
or (t.slug='gojo-tenjinja' and d.slug in ('okuninushi','sukunabikona'))
or (t.slug='ryugeji-kanazawa' and d.slug in ('dainichi_nyorai'))
or (t.slug='tamagawa-daishi' and d.slug in ('kobo_daishi'))
or (t.slug='senryuji-komae' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== バッチ7 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amenotomi','天富命','あめのとみのみこと','kami','天津神','{}','古語拾遺','忌部氏の祖。阿波・安房を開拓した産業・開拓の神。','https://ja.wikipedia.org/wiki/天富命','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='amenotomi' and g.slug in ('shobai','suisan_noko','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kanasana-jinja','金鑚神社','かなさなじんじゃ','shrine','金鑚神社（武蔵国二宮・名神大社）','埼玉県','児玉郡神川町','埼玉県児玉郡神川町二ノ宮751',36.1802556,139.0730611,862,null,'https://www.kanasana.jp/','武蔵国二宮。御室山を御神体とし本殿を持たない古社。多宝塔は重文。','https://ja.wikipedia.org/wiki/金鑚神社','Wikipedia',true,now()),
('yatsurugi-hachiman','八剱八幡神社','やつるぎはちまんじんじゃ','shrine','八剱八幡神社（旧郷社）','千葉県','木更津市','千葉県木更津市富士見1-6-15',35.381306,139.923167,null,null,'https://www.yaturugi.net/','木更津総鎮守。「関東一の大神輿」で知られる。','https://ja.wikipedia.org/wiki/八剱八幡神社','Wikipedia',true,now()),
('tomisaki-jinja','遠見岬神社','とみさきじんじゃ','shrine','遠見岬神社（旧郷社）','千葉県','勝浦市','千葉県勝浦市浜勝浦1',35.1468000,140.3155056,1849,null,'http://www.tomisaki.or.jp/','勝浦の総鎮守。春の「かつうらビッグひな祭り」石段飾りで著名。','https://ja.wikipedia.org/wiki/遠見岬神社','Wikipedia',true,now()),
('sogo-reido','宗吾霊堂 東勝寺','そうごれいどう とうしょうじ','temple','真言宗豊山派','千葉県','成田市','千葉県成田市宗吾1-558',35.7615556,140.2795833,null,'宗吾霊（木内惣五郎）','https://www.sogoreido.jp/','義民・佐倉惣五郎を祀る霊堂。あじさい寺としても知られる。','https://ja.wikipedia.org/wiki/宗吾霊堂','Wikipedia',true,now()),
('konjoin-yamaguchi-kannon','金乗院 山口観音','こんじょういん やまぐちかんのん','temple','真言宗豊山派','埼玉県','所沢市','埼玉県所沢市上山口2203',35.768556,139.41472,810,'千手観音','https://www.yamaguchikannon.com/','山口観音。狭山湖畔に建つ弘法大師ゆかりの霊場。','https://ja.wikipedia.org/wiki/金乗院_(所沢市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kanasana-jinja' and d.slug in ('amaterasu','susanoo'))
or (t.slug='yatsurugi-hachiman' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='tomisaki-jinja' and d.slug in ('amenotomi'))
or (t.slug='konjoin-yamaguchi-kannon' and d.slug in ('senju_kannon'))
on conflict do nothing;
-- 宗吾霊堂の本尊は宗吾霊（人霊）のため標準 deity 紐付けなし

-- ===== バッチ8 (5件) =====

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('toyokiiribiko','豊城入彦命','とよきいりひこのみこと','kami','天津神','{}','記紀','崇神天皇の皇子。東国経営の祖神で上毛野・赤城信仰の神。','https://ja.wikipedia.org/wiki/トヨキイリヒコ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='toyokiiribiko' and g.slug in ('shobu','kaiun','shusse'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kyoninji-kamogawa','鏡忍寺','きょうにんじ','temple','日蓮宗','千葉県','鴨川市','千葉県鴨川市広場1413',35.119278,140.106472,1281,'久遠実成本師釈迦牟尼仏','https://kyouninji.com/','小松原法難の霊跡に建つ日蓮宗の由緒寺院。','https://ja.wikipedia.org/wiki/鏡忍寺','Wikipedia',true,now()),
('takasaki-jinja','高崎神社','たかさきじんじゃ','shrine','高崎神社（旧県社）','群馬県','高崎市','群馬県高崎市赤坂町94',36.329556,139.000194,1243,null,'https://www.takasakijinja.or.jp/','高崎総鎮守「おくまんさま」。熊野大神を勧請した古社。','https://ja.wikipedia.org/wiki/高崎神社','Wikipedia',true,now()),
('kawaguchi-jinja','川口神社','かわぐちじんじゃ','shrine','川口神社（旧県社）','埼玉県','川口市','埼玉県川口市金山町6-15',35.798194,139.722694,940,null,'https://kawagutijinja.sakura.ne.jp/','川口の総鎮守。鋳物の街を守る金山彦命を併せ祀る。','https://ja.wikipedia.org/wiki/川口神社_(川口市)','Wikipedia',true,now()),
('ninomiya-akagi-jinja','二宮赤城神社','にのみやあかぎじんじゃ','shrine','二宮赤城神社（上野国二宮・名神大社論社）','群馬県','前橋市','群馬県前橋市二之宮町886',36.36722,139.167639,null,null,'http://ninomiya-akagijinja.com/','上野国二宮。約300社ある赤城神社の本宮論社の一つ。','https://ja.wikipedia.org/wiki/二宮赤城神社','Wikipedia',true,now()),
('shojoji-kisarazu','證誠寺','しょうじょうじ','temple','浄土真宗本願寺派','千葉県','木更津市','千葉県木更津市富士見2-9-30',35.3798278,139.9212028,null,'阿弥陀如来','http://www.kisarazu.gr.jp/shojoji/','童謡「証城寺の狸囃子」で名高い狸伝説の寺。','https://ja.wikipedia.org/wiki/證誠寺_(木更津市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kyoninji-kamogawa' and d.slug in ('shaka_nyorai'))
or (t.slug='takasaki-jinja' and d.slug in ('izanami','hayatama'))
or (t.slug='kawaguchi-jinja' and d.slug in ('susanoo','michizane','kanayamahiko'))
or (t.slug='ninomiya-akagi-jinja' and d.slug in ('toyokiiribiko','okuninushi'))
or (t.slug='shojoji-kisarazu' and d.slug in ('amida_nyorai'))
on conflict do nothing;
