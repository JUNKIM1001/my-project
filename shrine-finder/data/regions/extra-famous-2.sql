-- 全国 著名社寺 追加バッチ2（12件・地域カバー拡張）— 出典: 日本語Wikipedia 各記事 infobox
-- 北海道・東北・北陸・東海・南九州・沖縄を補強。すべて実在・参拝可能。

-- ① 新規神仏（8柱/尊）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('sukunabikona','少彦名神','すくなびこなのかみ','kami','国津神','{}','記紀','医薬・酒造・国造りの神。大国主と協力した小さな神。','https://ja.wikipedia.org/wiki/スクナビコナ','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{"釈迦牟尼仏"}','仏教','仏教の開祖・釈迦をかたどる如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('amenokagoyama','天香山命','あめのかごやまのみこと','kami','天津神','{"高倉下"}','記紀','越後を開拓した彌彦神社の祭神。産業・漁業の神。','https://ja.wikipedia.org/wiki/天香語山命','Wikipedia',true,now()),
('kukurihime','菊理媛神','くくりひめのかみ','kami','国津神','{"白山比咩大神"}','記紀','白山信仰の女神。和合・縁結びの神とされる。','https://ja.wikipedia.org/wiki/ククリヒメ','Wikipedia',true,now()),
('konohanasakuya','木花之佐久夜毘売命','このはなのさくやびめのみこと','kami','国津神','{"浅間大神"}','記紀','富士山の女神。安産・子育ての神。','https://ja.wikipedia.org/wiki/コノハナノサクヤビメ','Wikipedia',true,now()),
('takeiwatatsu','健磐龍命','たけいわたつのみこと','kami','国津神','{}','その他','阿蘇山を開いた阿蘇神社の祭神。農耕の神。','https://ja.wikipedia.org/wiki/健磐龍命','Wikipedia',true,now()),
('ninigi','瓊瓊杵尊','ににぎのみこと','kami','天津神','{"天津彦彦火瓊瓊杵尊"}','記紀','天孫降臨で地上に降りた天照大神の孫。','https://ja.wikipedia.org/wiki/ニニギ','Wikipedia',true,now()),
('izanami','伊弉冊尊','いざなみのみこと','kami','天津神','{"伊邪那美命"}','記紀','国生み・神生みの女神。万物を生み出す母神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='sukunabikona'  and g.slug in ('byoki_heyu','shobai','kaiun','choju'))
 or (d.slug='shaka_nyorai'   and g.slug in ('jouju','byoki_heyu','kaiun','gakumon'))
 or (d.slug='amenokagoyama'  and g.slug in ('suisan_noko','shobai','kaiun','shigoto'))
 or (d.slug='kukurihime'     and g.slug in ('enmusubi','kaiun','jouju'))
 or (d.slug='konohanasakuya' and g.slug in ('anzan','kosodate','enmusubi','bigan'))
 or (d.slug='takeiwatatsu'   and g.slug in ('suisan_noko','kaiun','shobai','yakubarai'))
 or (d.slug='ninigi'         and g.slug in ('kaiun','suisan_noko','anchin','jouju'))
 or (d.slug='izanami'        and g.slug in ('enmusubi','anzan','kaiun','yakubarai'))
on conflict do nothing;

-- ③ 社寺（12件）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('hokkaido-jingu','北海道神宮','ほっかいどうじんぐう','shrine','旧官幣大社・別表神社','北海道','札幌市中央区','北海道札幌市中央区宮ヶ丘474',43.054333,141.307500,1869,null,'http://www.hokkaidojingu.or.jp/','北海道の開拓・発展を見守る総鎮守。円山に鎮座。','https://ja.wikipedia.org/wiki/北海道神宮','Wikipedia',true,now()),
('chusonji','関山中尊寺','ちゅうそんじ','temple','天台宗','岩手県','西磐井郡平泉町','岩手県西磐井郡平泉町平泉衣関202',39.001528,141.102722,1105,'釈迦如来','https://www.chusonji.or.jp/','奥州藤原氏ゆかりの世界遺産。金色堂で名高い。','https://ja.wikipedia.org/wiki/中尊寺','Wikipedia',true,now()),
('osaki-hachimangu','大崎八幡宮','おおさきはちまんぐう','shrine','八幡宮（旧村社）','宮城県','仙台市青葉区','宮城県仙台市青葉区八幡四丁目6番1号',38.272194,140.845000,1607,null,'http://www.okos.co.jp/oosaki/','伊達政宗が造営した国宝の社殿。','https://ja.wikipedia.org/wiki/大崎八幡宮','Wikipedia',true,now()),
('yahiko-jinja','彌彦神社','やひこじんじゃ','shrine','越後国一宮（旧国幣中社）','新潟県','西蒲原郡弥彦村','新潟県西蒲原郡弥彦村弥彦2887番地2',37.706694,138.826000,null,null,'http://www.yahiko-jinjya.or.jp/','越後開拓の祖神を祀る越後一宮。弥彦山の麓に鎮座。','https://ja.wikipedia.org/wiki/彌彦神社','Wikipedia',true,now()),
('shirayama-hime-jinja','白山比咩神社','しらやまひめじんじゃ','shrine','加賀国一宮（旧国幣中社）','石川県','白山市','石川県白山市三宮町ニ105-1',36.434889,136.636200,null,null,'https://www.shirayama.or.jp/','全国白山神社の総本宮。霊峰白山を御神体とする。','https://ja.wikipedia.org/wiki/白山比咩神社','Wikipedia',true,now()),
('eiheiji','大本山永平寺','えいへいじ','temple','曹洞宗','福井県','吉田郡永平寺町','福井県吉田郡永平寺町志比5-15',36.053060,136.355560,1244,'釈迦如来','https://daihonzan-eiheiji.com/','道元が開いた曹洞宗の大本山。座禅修行の道場。','https://ja.wikipedia.org/wiki/永平寺','Wikipedia',true,now()),
('fujisan-hongu-sengen','富士山本宮浅間大社','ふじさんほんぐうせんげんたいしゃ','shrine','駿河国一宮（旧官幣大社）','静岡県','富士宮市','静岡県富士宮市宮町1-1',35.227406,138.610003,null,null,'http://www.fuji-hongu.or.jp/','全国浅間神社の総本社。富士山を御神体山として祀る。','https://ja.wikipedia.org/wiki/富士山本宮浅間大社','Wikipedia',true,now()),
('usa-jingu','宇佐神宮','うさじんぐう','shrine','八幡宮総本宮（旧官幣大社）','大分県','宇佐市','大分県宇佐市南宇佐2859',33.523472,131.377167,725,null,'http://www.usajinguu.com/','全国約4万社の八幡宮の総本宮。','https://ja.wikipedia.org/wiki/宇佐神宮','Wikipedia',true,now()),
('aso-jinja','阿蘇神社','あそじんじゃ','shrine','肥後国一宮（旧官幣大社）','熊本県','阿蘇市','熊本県阿蘇市一の宮町宮地3083-1',32.947780,131.115972,null,null,'http://asojinja.or.jp/','阿蘇開拓の神を祀る肥後一宮。全国阿蘇神社の総本社。','https://ja.wikipedia.org/wiki/阿蘇神社','Wikipedia',true,now()),
('kirishima-jingu','霧島神宮','きりしまじんぐう','shrine','旧官幣大社・別表神社','鹿児島県','霧島市','鹿児島県霧島市霧島田口2608番地5号',31.858944,130.871861,null,null,'https://kirishimajingu.or.jp/','天孫・瓊瓊杵尊を祀る南九州の名社。朱塗りの社殿が美しい。','https://ja.wikipedia.org/wiki/霧島神宮','Wikipedia',true,now()),
('naminoue-gu','波上宮','なみのうえぐう','shrine','琉球八社（旧官幣小社）','沖縄県','那覇市','沖縄県那覇市若狭一丁目25番11号',26.220728,127.671097,null,null,'http://naminouegu.jp/','海を望む崖上に鎮座する琉球八社の筆頭。沖縄総鎮守。','https://ja.wikipedia.org/wiki/波上宮','Wikipedia',true,now()),
('musashi-ichinomiya-hikawa','武蔵一宮 氷川神社','むさしいちのみや ひかわじんじゃ','shrine','武蔵国一宮（旧官幣大社・勅祭社）','埼玉県','さいたま市大宮区','埼玉県さいたま市大宮区高鼻町一丁目407番地',35.916750,139.629733,null,null,'https://musashiichinomiya-hikawa.or.jp/','全国氷川神社の総本社。大宮の地名の由来。','https://ja.wikipedia.org/wiki/氷川神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='hokkaido-jingu'             and d.slug='okuninushi')
 or (t.slug='chusonji'                   and d.slug='shaka_nyorai')
 or (t.slug='osaki-hachimangu'           and d.slug='hachiman')
 or (t.slug='yahiko-jinja'               and d.slug='amenokagoyama')
 or (t.slug='shirayama-hime-jinja'       and d.slug='kukurihime')
 or (t.slug='eiheiji'                    and d.slug='shaka_nyorai')
 or (t.slug='fujisan-hongu-sengen'       and d.slug='konohanasakuya')
 or (t.slug='usa-jingu'                  and d.slug='hachiman')
 or (t.slug='aso-jinja'                  and d.slug='takeiwatatsu')
 or (t.slug='kirishima-jingu'            and d.slug='ninigi')
 or (t.slug='naminoue-gu'                and d.slug='izanami')
 or (t.slug='musashi-ichinomiya-hikawa'  and d.slug='susanoo')
on conflict do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='hokkaido-jingu'             and d.slug in ('sukunabikona','meiji_tenno'))
 or (t.slug='osaki-hachimangu'           and d.slug='jingu_kogo')
 or (t.slug='usa-jingu'                  and d.slug='jingu_kogo')
 or (t.slug='musashi-ichinomiya-hikawa'  and d.slug='okuninushi')
on conflict do nothing;
