-- 社寺パイロットシード（12件）— 出典: 日本語Wikipedia 各社寺記事（infobox所在地・座標）
-- すべて実在・参拝可能。住所・緯度経度・御祭神/本尊は出典で確認済み。

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('izumo-taisha','出雲大社','いずもおおやしろ','shrine','出雲大社（旧官幣大社・出雲国一宮）','島根県','出雲市','島根県出雲市大社町杵築東195',35.401944,132.685444,null,null,'https://izumooyashiro.or.jp/','縁結びの大神として名高い大国主大神を祀る、日本有数の古社。',  'https://ja.wikipedia.org/wiki/出雲大社','Wikipedia',true,now()),
('ise-jingu-naiku','伊勢神宮（内宮／皇大神宮）','いせじんぐう ないくう','shrine','神宮（二十二社・上七社）','三重県','伊勢市','三重県伊勢市宇治館町1番地',34.455000,136.725175,null,null,'https://www.isejingu.or.jp/','天照大御神を祀る神宮の中心。日本人の総氏神とされる。',          'https://ja.wikipedia.org/wiki/伊勢神宮','Wikipedia',true,now()),
('meiji-jingu','明治神宮','めいじじんぐう','shrine','旧官幣大社・勅祭社','東京都','渋谷区','東京都渋谷区代々木神園町1番1号',35.676110,139.699170,1920,null,'https://www.meijijingu.or.jp/','明治天皇・昭憲皇太后を祀る。都心の杜に鎮座し初詣参拝者数日本一。',   'https://ja.wikipedia.org/wiki/明治神宮','Wikipedia',true,now()),
('dazaifu-tenmangu','太宰府天満宮','だざいふてんまんぐう','shrine','天満宮（旧官幣中社）','福岡県','太宰府市','福岡県太宰府市宰府4丁目7番1号',33.521528,130.534861,919,null,'https://www.dazaifutenmangu.or.jp/','菅原道真を祀る全国天満宮の総本宮の一つ。学問の神。',            'https://ja.wikipedia.org/wiki/太宰府天満宮','Wikipedia',true,now()),
('fushimi-inari-taisha','伏見稲荷大社','ふしみいなりたいしゃ','shrine','稲荷神社（旧官幣大社・単立）','京都府','京都市伏見区','京都府京都市伏見区深草薮之内町68番地',34.966940,135.773060,711,null,'https://inari.jp/','全国約3万社の稲荷神社の総本宮。千本鳥居で知られる。',           'https://ja.wikipedia.org/wiki/伏見稲荷大社','Wikipedia',true,now()),
('nikko-toshogu','日光東照宮','にっこうとうしょうぐう','shrine','東照宮（旧別格官幣社・単立）','栃木県','日光市','栃木県日光市山内2301',36.758056,139.598944,1617,null,'https://www.toshogu.jp/','徳川家康（東照大権現）を祀る世界遺産。豪壮な権現造。',          'https://ja.wikipedia.org/wiki/日光東照宮','Wikipedia',true,now()),
('itsukushima-jinja','嚴島神社','いつくしまじんじゃ','shrine','安芸国一宮（旧官幣中社）','広島県','廿日市市','広島県廿日市市宮島町1-1',34.296022,132.319894,null,null,'http://www.itsukushimajinja.jp/','海上に立つ大鳥居で有名な世界遺産。宗像三女神を祀る。',          'https://ja.wikipedia.org/wiki/厳島神社','Wikipedia',true,now()),
('sumiyoshi-taisha','住吉大社','すみよしたいしゃ','shrine','摂津国一宮（旧官幣大社）','大阪府','大阪市住吉区','大阪府大阪市住吉区住吉2丁目9-89',34.612389,135.493778,null,null,'https://www.sumiyoshitaisha.net/','全国住吉神社の総本社。海上・航海安全の神。',                'https://ja.wikipedia.org/wiki/住吉大社','Wikipedia',true,now()),
('tsurugaoka-hachimangu','鶴岡八幡宮','つるがおかはちまんぐう','shrine','八幡宮（旧国幣中社）','神奈川県','鎌倉市','神奈川県鎌倉市雪ノ下2丁目1番31号',35.326086,139.556436,1063,null,'https://www.hachimangu.or.jp/','鎌倉武士の守護神。源氏ゆかりの八幡宮。',                    'https://ja.wikipedia.org/wiki/鶴岡八幡宮','Wikipedia',true,now()),
('senso-ji','金龍山浅草寺','きんりゅうざんせんそうじ','temple','聖観音宗（天台宗系単立）','東京都','台東区','東京都台東区浅草二丁目3番1号',35.714720,139.796750,628,'聖観世音菩薩','https://www.senso-ji.jp/','東京最古の寺。雷門・仲見世で知られる観音霊場。',              'https://ja.wikipedia.org/wiki/浅草寺','Wikipedia',true,now()),
('naritasan-shinshoji','成田山新勝寺','なりたさんしんしょうじ','temple','真言宗智山派','千葉県','成田市','千葉県成田市成田1番地の1',35.786053,140.318275,940,'不動明王','https://www.naritasan.or.jp/','不動明王信仰の中心。厄除け・交通安全の祈祷で名高い。',          'https://ja.wikipedia.org/wiki/成田山新勝寺','Wikipedia',true,now()),
('kawasaki-daishi','金剛山金乗院平間寺（川崎大師）','かわさきだいし へいけんじ','temple','真言宗智山派','神奈川県','川崎市川崎区','神奈川県川崎市川崎区大師町4番地48号',35.534722,139.729444,1128,'弘法大師（空海）','https://www.kawasakidaishi.com/','厄除け大師として知られる真言宗智山派の大本山。',              'https://ja.wikipedia.org/wiki/平間寺','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 御祭神 / 本尊（temple_shrine_deity）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='izumo-taisha'          and d.slug='okuninushi')
 or (t.slug='ise-jingu-naiku'        and d.slug='amaterasu')
 or (t.slug='meiji-jingu'            and d.slug in ('meiji_tenno','shoken'))
 or (t.slug='dazaifu-tenmangu'       and d.slug='michizane')
 or (t.slug='fushimi-inari-taisha'   and d.slug='ukanomitama')
 or (t.slug='nikko-toshogu'          and d.slug='ieyasu')
 or (t.slug='itsukushima-jinja'      and d.slug='ichikishima')
 or (t.slug='sumiyoshi-taisha'       and d.slug='sumiyoshi')
 or (t.slug='tsurugaoka-hachimangu'  and d.slug='hachiman')
 or (t.slug='senso-ji'               and d.slug='sho_kannon')
 or (t.slug='naritasan-shinshoji'    and d.slug='fudo_myoo')
 or (t.slug='kawasaki-daishi'        and d.slug='kobo_daishi')
on conflict do nothing;

-- 鶴岡八幡宮は神功皇后も配祀（出典: Wikipedia 鶴岡八幡宮）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true
where t.slug='tsurugaoka-hachimangu' and d.slug='jingu_kogo'
on conflict do nothing;

-- 社寺のご利益: 御祭神/本尊が司るご利益から自動導出（temple_shrine_goriyaku）
insert into temple_shrine_goriyaku (temple_shrine_id, goriyaku_id)
select distinct tsd.temple_shrine_id, dg.goriyaku_id
from temple_shrine_deity tsd
join deity_goriyaku dg on dg.deity_id = tsd.deity_id
on conflict do nothing;
