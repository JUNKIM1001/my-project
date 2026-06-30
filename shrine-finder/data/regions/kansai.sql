-- 近畿（三重・滋賀・京都・大阪・兵庫・奈良・和歌山）著名社寺バッチ（42件）
-- 出典: 日本語Wikipedia 各記事 infobox（所在地・十進緯度経度・御祭神/本尊・創建・公式サイト）
-- すべてエージェントが1件ずつWebFetchで裏取り。実在・参拝可能。座標が infobox に無い社寺は除外。

-- ① 新規神仏（既存32柱に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('izanagi','伊弉諾尊','いざなぎのみこと','kami','天津神','{"伊邪那岐命"}','記紀','国生み・神生みの男神。伊弉冉尊とともに万物を生んだ。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('kanmu-tenno','桓武天皇','かんむてんのう','kami','御霊','{}','その他','平安京へ遷都した第50代天皇。平安神宮の御祭神。','https://ja.wikipedia.org/wiki/桓武天皇','Wikipedia',true,now()),
('komei-tenno','孝明天皇','こうめいてんのう','kami','御霊','{}','その他','幕末の第121代天皇。平安神宮に桓武天皇と共に祀られる。','https://ja.wikipedia.org/wiki/孝明天皇','Wikipedia',true,now()),
('kamowakeikazuchi','賀茂別雷大神','かもわけいかづちのおおかみ','kami','国津神','{"上賀茂大神"}','その他','雷を司る賀茂氏の祖神。上賀茂神社（賀茂別雷神社）の御祭神。','https://ja.wikipedia.org/wiki/賀茂別雷神社','Wikipedia',true,now()),
('tamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{}','記紀','賀茂別雷大神の母神。下鴨神社（賀茂御祖神社）の御祭神。','https://ja.wikipedia.org/wiki/タマヨリビメ','Wikipedia',true,now()),
('kamotaketsunumi','賀茂建角身命','かもたけつぬみのみこと','kami','国津神','{"八咫烏"}','記紀','賀茂氏の祖神。神武東征を導いた八咫烏に化身したとされる。','https://ja.wikipedia.org/wiki/賀茂建角身命','Wikipedia',true,now()),
('guze-kannon','救世観音','ぐぜかんのん','buddha','菩薩','{"救世観世音菩薩"}','仏教','衆生を世から救う観音。四天王寺の本尊。','https://ja.wikipedia.org/wiki/四天王寺','Wikipedia',true,now()),
('wakahirume','稚日女尊','わかひるめのみこと','kami','天津神','{}','記紀','若く瑞々しい日の女神。生田神社の御祭神。','https://ja.wikipedia.org/wiki/ワカヒルメ','Wikipedia',true,now()),
('kusunoki-masashige','楠木正成','くすのきまさしげ','kami','御霊','{"大楠公"}','その他','南北朝期の忠臣。湊川神社の御祭神。忠誠の象徴。','https://ja.wikipedia.org/wiki/楠木正成','Wikipedia',true,now()),
('rushana-butsu','盧舎那仏','るしゃなぶつ','buddha','如来','{"奈良の大仏","毘盧遮那仏"}','仏教','宇宙を照らす光の如来。東大寺の本尊（奈良の大仏）。','https://ja.wikipedia.org/wiki/東大寺盧舎那仏像','Wikipedia',true,now()),
('juichimen-kannon','十一面観音','じゅういちめんかんのん','buddha','菩薩','{"十一面観世音菩薩"}','仏教','十一の顔であらゆる方角の衆生を救う観音。','https://ja.wikipedia.org/wiki/十一面観音','Wikipedia',true,now()),
('jinmu-tenno','神武天皇','じんむてんのう','kami','御霊','{"神倭伊波礼毘古命"}','記紀','日本の初代天皇とされる。橿原神宮の御祭神。','https://ja.wikipedia.org/wiki/神武天皇','Wikipedia',true,now()),
('kumano-fusumi','熊野夫須美大神','くまのふすみのおおかみ','kami','熊野神','{"熊野権現","伊弉冉尊習合"}','その他','熊野那智大社の主祭神。結びと再生を司る熊野の女神。','https://ja.wikipedia.org/wiki/熊野那智大社','Wikipedia',true,now()),
('kumano-hayatama','熊野速玉大神','くまのはやたまのおおかみ','kami','熊野神','{"熊野権現","伊弉諾尊習合"}','その他','熊野速玉大社の主祭神。熊野三山信仰の一柱。','https://ja.wikipedia.org/wiki/熊野速玉大社','Wikipedia',true,now()),
('sarutahiko','猿田彦大神','さるたひこのおおかみ','kami','国津神','{"道開きの神"}','記紀','天孫降臨を先導した道開き・導きの神。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now()),
('amatsuhikone','天津彦根命','あまつひこねのみこと','kami','天津神','{}','記紀','天照大神の御子神。多度大社の御祭神。','https://ja.wikipedia.org/wiki/アマツヒコネ','Wikipedia',true,now()),
('nintoku-tenno','仁徳天皇','にんとくてんのう','kami','御霊','{}','その他','仁政で知られる第16代天皇。難波神社の御祭神。','https://ja.wikipedia.org/wiki/仁徳天皇','Wikipedia',true,now()),
('oyamakui','大山咋神','おおやまくいのかみ','kami','国津神','{"山王"}','記紀','山の地主神。日吉大社東本宮・全国山王社の御祭神。','https://ja.wikipedia.org/wiki/オオヤマクイ','Wikipedia',true,now()),
('fujiwara-kamatari','藤原鎌足','ふじわらのかまたり','kami','御霊','{"中臣鎌足"}','その他','大化の改新の中心人物で藤原氏の祖。談山神社の御祭神。','https://ja.wikipedia.org/wiki/藤原鎌足','Wikipedia',true,now()),
('tenji-tenno','天智天皇','てんじてんのう','kami','御霊','{"天智天皇","中大兄皇子"}','その他','漏刻（水時計）を作った第38代天皇。近江神宮の御祭神。','https://ja.wikipedia.org/wiki/天智天皇','Wikipedia',true,now()),
('niutsuhime','丹生都比売大神','にうつひめのおおかみ','kami','国津神','{"丹生明神"}','その他','水銀・水の女神。高野山の地主神。丹生都比売神社の御祭神。','https://ja.wikipedia.org/wiki/丹生都比売神社','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{"えびす習合"}','記紀','託宣・漁業・商売の神。恵比寿と習合し福の神として信仰される。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('nyoirin-kannon','如意輪観音','にょいりんかんのん','buddha','菩薩','{"如意輪観世音菩薩"}','仏教','如意宝珠と法輪で衆生の願いを叶える観音。石山寺の本尊。','https://ja.wikipedia.org/wiki/如意輪観音','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='izanagi'            and g.slug in ('enmusubi','kaiun','yakubarai','kanai_anzen'))
 or (d.slug='kanmu-tenno'        and g.slug in ('kaiun','shusse','majo_kekkai'))
 or (d.slug='komei-tenno'        and g.slug in ('kaiun','yakubarai'))
 or (d.slug='kamowakeikazuchi'   and g.slug in ('yakubarai','majo_kekkai','kaiun','shobu'))
 or (d.slug='tamayorihime'       and g.slug in ('enmusubi','anzan','kosodate','byoki_heyu'))
 or (d.slug='kamotaketsunumi'    and g.slug in ('tabi_anzen','kotsu_anzen','kaiun','yakubarai'))
 or (d.slug='guze-kannon'        and g.slug in ('byoki_heyu','jouju','kaiun','yakubarai'))
 or (d.slug='wakahirume'         and g.slug in ('enmusubi','renai','kaiun','bigan'))
 or (d.slug='kusunoki-masashige' and g.slug in ('shobu','shusse','gakugyo','kaiun'))
 or (d.slug='rushana-butsu'      and g.slug in ('jouju','kaiun','byoki_heyu','choju'))
 or (d.slug='juichimen-kannon'   and g.slug in ('byoki_heyu','yakubarai','kaiun','jouju'))
 or (d.slug='jinmu-tenno'        and g.slug in ('kaiun','shobu','shusse','majo_kekkai'))
 or (d.slug='kumano-fusumi'      and g.slug in ('enmusubi','jouju','kaiun','tabi_anzen'))
 or (d.slug='kumano-hayatama'    and g.slug in ('kaiun','yakubarai','jouju','tabi_anzen'))
 or (d.slug='sarutahiko'         and g.slug in ('kotsu_anzen','tabi_anzen','kaiun','shigoto'))
 or (d.slug='amatsuhikone'       and g.slug in ('shigoto','kaiun','suisan_noko'))
 or (d.slug='nintoku-tenno'      and g.slug in ('shobai','kaiun','kanai_anzen'))
 or (d.slug='oyamakui'           and g.slug in ('shobai','yakubarai','kaiun','majo_kekkai'))
 or (d.slug='fujiwara-kamatari'  and g.slug in ('gakumon','shusse','shigoto','kaiun'))
 or (d.slug='tenji-tenno'        and g.slug in ('gakugyo','gakumon','kaiun'))
 or (d.slug='niutsuhime'         and g.slug in ('majo_kekkai','yakubarai','kaiun','shobai'))
 or (d.slug='kotoshironushi'     and g.slug in ('shobai','suisan_noko','kinun','kaiun'))
 or (d.slug='nyoirin-kannon'     and g.slug in ('jouju','kaiun','byoki_heyu','enmusubi'))
on conflict do nothing;

-- ③ 社寺（42件）
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
-- 三重県
('tsubaki-okami-yashiro','椿大神社','つばきおおかみやしろ','shrine','伊勢国一宮（旧県社・別表神社）','三重県','鈴鹿市','三重県鈴鹿市山本町字御旅1871',34.964440,136.451670,null,null,'https://www.tsubaki.or.jp/','全国の猿田彦大神を祀る社の総本宮。道開きの神として信仰される。','https://ja.wikipedia.org/wiki/椿大神社','Wikipedia',true,now()),
('tado-taisha','多度大社','たどたいしゃ','shrine','旧国幣大社・別表神社','三重県','桑名市','三重県桑名市多度町多度1681',35.135500,136.622639,null,null,'https://tadotaisya.or.jp/','北伊勢大神宮とも称される名社。上げ馬神事で知られる。','https://ja.wikipedia.org/wiki/多度大社','Wikipedia',true,now()),
('futami-okitama-jinja','二見興玉神社','ふたみおきたまじんじゃ','shrine','旧村社・別表神社','三重県','伊勢市','三重県伊勢市二見町江575',34.508890,136.787780,null,null,'https://futamiokitamajinja.or.jp/','夫婦岩で名高い。伊勢参り前の禊の地として親しまれる。','https://ja.wikipedia.org/wiki/二見興玉神社','Wikipedia',true,now()),
('sarutahiko-jinja','猿田彦神社','さるたひこじんじゃ','shrine','旧無格社・単立','三重県','伊勢市','三重県伊勢市宇治浦田2-1-10',34.466940,136.720472,null,null,'http://www.sarutahikojinja.or.jp/','伊勢神宮内宮近くに鎮座。みちひらきの大神を祀る。','https://ja.wikipedia.org/wiki/猿田彦神社','Wikipedia',true,now()),
-- 滋賀県
('taga-taisha','多賀大社','たがたいしゃ','shrine','旧官幣大社・別表神社','滋賀県','犬上郡多賀町','滋賀県犬上郡多賀町多賀604',35.225560,136.291110,null,null,'https://www.tagataisya.or.jp/','お多賀さん。伊弉諾・伊弉冉二神を祀り延命長寿で信仰される。','https://ja.wikipedia.org/wiki/多賀大社','Wikipedia',true,now()),
('enryakuji','比叡山延暦寺','ひえいざんえんりゃくじ','temple','天台宗','滋賀県','大津市','滋賀県大津市坂本本町4220',35.070450,135.840925,788,'薬師如来','https://www.hieizan.or.jp/','最澄が開いた天台宗総本山。世界遺産で多くの名僧を輩出した。','https://ja.wikipedia.org/wiki/延暦寺','Wikipedia',true,now()),
('ishiyamadera','石光山石山寺','せっこうざんいしやまでら','temple','東寺真言宗','滋賀県','大津市','滋賀県大津市石山寺1丁目1-1',34.960419,135.905625,747,'如意輪観音','https://www.ishiyamadera.or.jp/','西国三十三所第13番。源氏物語ゆかりの観音霊場。','https://ja.wikipedia.org/wiki/石山寺','Wikipedia',true,now()),
('hiyoshi-taisha','日吉大社','ひよしたいしゃ','shrine','旧官幣大社・二十二社・別表神社','滋賀県','大津市','滋賀県大津市坂本5丁目1-1',35.073444,135.864972,null,null,'https://hiyoshitaisha.jp/','全国山王総本宮。山王信仰の中心で魔除け・方除けの社。','https://ja.wikipedia.org/wiki/日吉大社','Wikipedia',true,now()),
('tsukubusuma-jinja','竹生島神社','ちくぶしまじんじゃ','shrine','旧県社・別表神社','滋賀県','長浜市','滋賀県長浜市早崎町1665',35.420611,136.144194,null,null,'http://www.chikubusima.or.jp/','琵琶湖の竹生島に鎮座。日本三大弁財天の一つ。','https://ja.wikipedia.org/wiki/都久夫須麻神社','Wikipedia',true,now()),
('omi-jingu','近江神宮','おうみじんぐう','shrine','旧官幣大社・勅祭社・別表神社','滋賀県','大津市','滋賀県大津市神宮町1-1',35.032444,135.851222,1940,null,'https://oumijingu.org/','天智天皇を祀る。漏刻にちなみ時の神・かるたの聖地として知られる。','https://ja.wikipedia.org/wiki/近江神宮','Wikipedia',true,now()),
-- 京都府
('kamigamo-jinja','賀茂別雷神社（上賀茂神社）','かもわけいかづちじんじゃ','shrine','旧官幣大社・二十二社・別表神社','京都府','京都市北区','京都府京都市北区上賀茂本山339',35.060280,135.752780,677,null,'https://www.kamigamojinja.jp/','京都最古級の社。葵祭で知られる世界遺産。','https://ja.wikipedia.org/wiki/賀茂別雷神社','Wikipedia',true,now()),
('shimogamo-jinja','賀茂御祖神社（下鴨神社）','かもみおやじんじゃ','shrine','旧官幣大社・二十二社・別表神社','京都府','京都市左京区','京都府京都市左京区下鴨泉川町59',35.038890,135.772500,null,null,'https://www.shimogamo-jinja.or.jp/','糺の森に鎮座する世界遺産。上賀茂神社とともに葵祭を行う。','https://ja.wikipedia.org/wiki/賀茂御祖神社','Wikipedia',true,now()),
('kinkakuji','鹿苑寺（金閣寺）','ろくおんじ','temple','臨済宗相国寺派','京都府','京都市北区','京都府京都市北区金閣寺町1',35.039403,135.729364,1397,'聖観音','https://www.shokoku-ji.jp/kinkakuji/','金箔の舎利殿で名高い世界遺産。足利義満の北山文化を象徴する。','https://ja.wikipedia.org/wiki/鹿苑寺','Wikipedia',true,now()),
('toji','教王護国寺（東寺）','とうじ','temple','東寺真言宗','京都府','京都市南区','京都府京都市南区九条町1',34.980361,135.747694,796,'薬師如来','https://toji.or.jp/','弘法大師空海ゆかりの真言密教の根本道場。五重塔で名高い世界遺産。','https://ja.wikipedia.org/wiki/東寺','Wikipedia',true,now()),
('heian-jingu','平安神宮','へいあんじんぐう','shrine','旧官幣大社・勅祭社・別表神社','京都府','京都市左京区','京都府京都市左京区岡崎西天王町97',35.016670,135.782220,1895,null,'https://www.heianjingu.or.jp/','平安遷都1100年を記念して創建。大極殿を再現した社殿と神苑が美しい。','https://ja.wikipedia.org/wiki/平安神宮','Wikipedia',true,now()),
('kenninji','建仁寺','けんにんじ','temple','臨済宗建仁寺派','京都府','京都市東山区','京都府京都市東山区大和大路通四条下る小松町584',35.000986,135.773664,1202,'十一面観音','https://www.kenninji.jp/','栄西が開いた京都最古の禅寺。風神雷神図で名高い。','https://ja.wikipedia.org/wiki/建仁寺','Wikipedia',true,now()),
('ginkakuji','慈照寺（銀閣寺）','じしょうじ','temple','臨済宗相国寺派','京都府','京都市左京区','京都府京都市左京区銀閣寺町2',35.026875,135.798250,1490,'釈迦如来','https://www.shokoku-ji.jp/ginkakuji/','東山文化を代表する世界遺産。観音殿（銀閣）で知られる。','https://ja.wikipedia.org/wiki/慈照寺','Wikipedia',true,now()),
('tenryuji','天龍寺','てんりゅうじ','temple','臨済宗天龍寺派','京都府','京都市右京区','京都府京都市右京区嵯峨天龍寺芒ノ馬場町68',35.015964,135.673772,1343,'釈迦三尊','https://www.tenryuji.com/','京都五山第一位の禅寺。曹源池庭園で名高い世界遺産。','https://ja.wikipedia.org/wiki/天龍寺','Wikipedia',true,now()),
('daigoji','醍醐寺','だいごじ','temple','真言宗醍醐派','京都府','京都市伏見区','京都府京都市伏見区醍醐東大路町22',34.951500,135.821778,874,'薬師如来','https://www.daigoji.or.jp/','秀吉の花見で知られる世界遺産。五重塔は京都最古の建造物。','https://ja.wikipedia.org/wiki/醍醐寺','Wikipedia',true,now()),
('iwashimizu-hachimangu','石清水八幡宮','いわしみずはちまんぐう','shrine','旧官幣大社・二十二社・別表神社','京都府','八幡市','京都府八幡市八幡高坊30',34.879667,135.700056,860,null,'https://iwashimizu.or.jp/','日本三大八幡の一つ。男山に鎮座し国家鎮護の社として崇敬された。','https://ja.wikipedia.org/wiki/石清水八幡宮','Wikipedia',true,now()),
-- 大阪府
('shitennoji','四天王寺','してんのうじ','temple','和宗','大阪府','大阪市天王寺区','大阪府大阪市天王寺区四天王寺1丁目11-18',34.653900,135.516450,593,'救世観音','https://www.shitennoji.or.jp/','聖徳太子建立の日本仏法最初の官寺。和宗の総本山。','https://ja.wikipedia.org/wiki/四天王寺','Wikipedia',true,now()),
('osaka-tenmangu','大阪天満宮','おおさかてんまんぐう','shrine','旧府社・別表神社','大阪府','大阪市北区','大阪府大阪市北区天神橋2丁目1番8号',34.696025,135.512619,949,null,'https://osakatemmangu.or.jp/','天満の天神さん。菅原道真を祀り、天神祭で名高い。','https://ja.wikipedia.org/wiki/大阪天満宮','Wikipedia',true,now()),
('namba-jinja','難波神社','なんばじんじゃ','shrine','旧府社','大阪府','大阪市中央区','大阪府大阪市中央区博労町4丁目1-3',34.678969,135.499561,null,null,'https://www.nanba-jinja.or.jp/','仁徳天皇を祀る旧摂津国の名社。菖蒲の御神紋で知られる。','https://ja.wikipedia.org/wiki/難波神社','Wikipedia',true,now()),
('hiraoka-jinja','枚岡神社','ひらおかじんじゃ','shrine','河内国一宮（旧官幣大社・別表神社）','大阪府','東大阪市','大阪府東大阪市出雲井町7番16号',34.670000,135.651111,null,null,'http://www.hiraoka-jinja.org/','元春日とも称される河内国一宮。中臣・藤原氏の祖神を祀る。','https://ja.wikipedia.org/wiki/枚岡神社','Wikipedia',true,now()),
('imamiya-ebisu-jinja','今宮戎神社','いまみやえびすじんじゃ','shrine','旧郷社','大阪府','大阪市浪速区','大阪府大阪市浪速区恵美須西1丁目6-10',34.655333,135.502472,null,null,'https://www.imamiya-ebisu.jp/','商売繁盛の十日戎で名高い。えべっさんとして親しまれる。','https://ja.wikipedia.org/wiki/今宮戎神社','Wikipedia',true,now()),
-- 兵庫県
('ikuta-jinja','生田神社','いくたじんじゃ','shrine','旧官幣中社・別表神社','兵庫県','神戸市中央区','兵庫県神戸市中央区下山手通1丁目2-1',34.694806,135.190694,null,null,'https://ikutajinja.or.jp/','神戸の地名の由来となった古社。縁結びの神として信仰される。','https://ja.wikipedia.org/wiki/生田神社','Wikipedia',true,now()),
('minatogawa-jinja','湊川神社','みなとがわじんじゃ','shrine','旧別格官幣社・別表神社','兵庫県','神戸市中央区','兵庫県神戸市中央区多聞通3丁目1-1',34.681358,135.175438,1872,null,'http://www.minatogawajinja.or.jp/','楠木正成を祀る。楠公さんとして親しまれる。','https://ja.wikipedia.org/wiki/湊川神社','Wikipedia',true,now()),
('nishinomiya-jinja','西宮神社','にしのみやじんじゃ','shrine','旧県社・別表神社','兵庫県','西宮市','兵庫県西宮市社家町1-17',34.735694,135.334611,null,null,'https://nishinomiya-ebisu.com/','全国えびす神社の総本社。十日えびすの福男選びで知られる。','https://ja.wikipedia.org/wiki/西宮神社','Wikipedia',true,now()),
('izanagi-jingu','伊弉諾神宮','いざなぎじんぐう','shrine','淡路国一宮（旧官幣大社・別表神社）','兵庫県','淡路市','兵庫県淡路市多賀740',34.460000,134.852220,null,null,'https://kuniuminoshima.jp/','国生み神話の伊弉諾尊を祀る淡路国一宮。日本最古級の神社。','https://ja.wikipedia.org/wiki/伊弉諾神宮','Wikipedia',true,now()),
('nakayamadera','中山寺','なかやまでら','temple','真言宗中山寺派','兵庫県','宝塚市','兵庫県宝塚市中山寺2丁目11-1',34.821667,135.367667,null,'十一面観音','https://www.nakayamadera.or.jp/','西国三十三所第24番。安産祈願の寺として全国に知られる。','https://ja.wikipedia.org/wiki/中山寺_(宝塚市)','Wikipedia',true,now()),
-- 奈良県
('todaiji','東大寺','とうだいじ','temple','華厳宗','奈良県','奈良市','奈良県奈良市雑司町406-1',34.688972,135.839833,728,'盧舎那仏','https://www.todaiji.or.jp/','奈良の大仏で名高い華厳宗大本山。世界遺産。','https://ja.wikipedia.org/wiki/東大寺','Wikipedia',true,now()),
('kofukuji','興福寺','こうふくじ','temple','法相宗','奈良県','奈良市','奈良県奈良市登大路町48',34.683250,135.831167,669,'釈迦如来','http://www.kohfukuji.com/','藤原氏の氏寺。阿修羅像で名高い法相宗大本山の世界遺産。','https://ja.wikipedia.org/wiki/興福寺','Wikipedia',true,now()),
('horyuji','法隆寺','ほうりゅうじ','temple','聖徳宗','奈良県','生駒郡斑鳩町','奈良県生駒郡斑鳩町法隆寺山内1-1',34.614739,135.734172,607,'釈迦如来','http://www.horyuji.or.jp/','聖徳太子ゆかりの現存最古の木造建築群。世界遺産。','https://ja.wikipedia.org/wiki/法隆寺','Wikipedia',true,now()),
('kashihara-jingu','橿原神宮','かしはらじんぐう','shrine','旧官幣大社・勅祭社・別表神社','奈良県','橿原市','奈良県橿原市久米町934',34.488330,135.786110,1890,null,'https://kashiharajingu.or.jp/','初代神武天皇を祀る。畝傍山の麓、橿原宮跡に鎮座する。','https://ja.wikipedia.org/wiki/橿原神宮','Wikipedia',true,now()),
('tanzan-jinja','談山神社','たんざんじんじゃ','shrine','旧別格官幣社・別表神社','奈良県','桜井市','奈良県桜井市多武峰319',34.465889,135.861750,678,null,'http://www.tanzan.or.jp/','藤原鎌足を祀る。世界唯一の木造十三重塔で知られる紅葉の名所。','https://ja.wikipedia.org/wiki/談山神社','Wikipedia',true,now()),
('hasedera-nara','豊山神楽院長谷寺','ぶざんかぐらいんはせでら','temple','真言宗豊山派','奈良県','桜井市','奈良県桜井市初瀬731-1',34.535889,135.906833,686,'十一面観音','https://www.hasedera.or.jp/','花の御寺と称される真言宗豊山派総本山。西国三十三所第8番。','https://ja.wikipedia.org/wiki/長谷寺','Wikipedia',true,now()),
('omiwa-jinja','大神神社','おおみわじんじゃ','shrine','大和国一宮（旧官幣大社・二十二社・別表神社）','奈良県','桜井市','奈良県桜井市三輪1422',34.528750,135.853000,null,null,'https://oomiwa.or.jp/','三輪山を御神体とする本殿を持たない日本最古級の神社。','https://ja.wikipedia.org/wiki/大神神社','Wikipedia',true,now()),
-- 和歌山県
('kumano-nachi-taisha','熊野那智大社','くまのなちたいしゃ','shrine','旧官幣中社・別表神社','和歌山県','東牟婁郡那智勝浦町','和歌山県東牟婁郡那智勝浦町那智山1',33.668722,135.890167,null,null,'https://www.kumanonachitaisha.or.jp/','熊野三山の一。那智の滝とともに信仰される世界遺産。','https://ja.wikipedia.org/wiki/熊野那智大社','Wikipedia',true,now()),
('kimiidera','紀三井山金剛宝寺（紀三井寺）','きみいさんこんごうほうじ','temple','救世観音宗','和歌山県','和歌山市','和歌山県和歌山市紀三井寺1201',34.185167,135.190028,770,'十一面観音','https://www.kimiidera.com/','西国三十三所第2番。三つの霊泉と早咲きの桜で名高い観音霊場。','https://ja.wikipedia.org/wiki/紀三井寺','Wikipedia',true,now()),
('kumano-hayatama-taisha','熊野速玉大社','くまのはやたまたいしゃ','shrine','旧官幣大社・別表神社','和歌山県','新宮市','和歌山県新宮市新宮1',33.732167,135.983528,null,null,'https://kumanohayatama.jp/','熊野三山の一。熊野速玉大神を祀る世界遺産。','https://ja.wikipedia.org/wiki/熊野速玉大社','Wikipedia',true,now()),
('kokawadera','風猛山粉河寺','ふうもうざんこかわでら','temple','粉河観音宗','和歌山県','紀の川市','和歌山県紀の川市粉河2787',34.280961,135.405908,770,'千手観音','https://www.kokawadera.org/','西国三十三所第3番。秘仏の千手観音を本尊とする観音霊場。','https://ja.wikipedia.org/wiki/粉河寺','Wikipedia',true,now()),
('niutsuhime-jinja','丹生都比売神社','にうつひめじんじゃ','shrine','紀伊国一宮（旧官幣大社・別表神社）','和歌山県','伊都郡かつらぎ町','和歌山県伊都郡かつらぎ町上天野230',34.262722,135.522000,null,null,'https://niutsuhime.or.jp/','全国丹生都比売神社の総本社。高野山の地主神を祀る世界遺産。','https://ja.wikipedia.org/wiki/丹生都比売神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ④ 御祭神/本尊の紐付け（主祭神・本尊）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='tsubaki-okami-yashiro'    and d.slug='sarutahiko')
 or (t.slug='tado-taisha'              and d.slug='amatsuhikone')
 or (t.slug='futami-okitama-jinja'     and d.slug='sarutahiko')
 or (t.slug='sarutahiko-jinja'         and d.slug='sarutahiko')
 or (t.slug='taga-taisha'              and d.slug in ('izanagi','izanami'))
 or (t.slug='enryakuji'                and d.slug='yakushi_nyorai')
 or (t.slug='ishiyamadera'             and d.slug='nyoirin-kannon')
 or (t.slug='hiyoshi-taisha'           and d.slug in ('okuninushi','oyamakui'))
 or (t.slug='tsukubusuma-jinja'        and d.slug='ichikishima')
 or (t.slug='omi-jingu'                and d.slug='tenji-tenno')
 or (t.slug='kamigamo-jinja'           and d.slug='kamowakeikazuchi')
 or (t.slug='shimogamo-jinja'          and d.slug in ('tamayorihime','kamotaketsunumi'))
 or (t.slug='kinkakuji'                and d.slug='sho_kannon')
 or (t.slug='toji'                     and d.slug='yakushi_nyorai')
 or (t.slug='heian-jingu'              and d.slug in ('kanmu-tenno','komei-tenno'))
 or (t.slug='kenninji'                 and d.slug='juichimen-kannon')
 or (t.slug='ginkakuji'                and d.slug='shaka_nyorai')
 or (t.slug='tenryuji'                 and d.slug='shaka_nyorai')
 or (t.slug='daigoji'                  and d.slug='yakushi_nyorai')
 or (t.slug='iwashimizu-hachimangu'    and d.slug='hachiman')
 or (t.slug='shitennoji'               and d.slug='guze-kannon')
 or (t.slug='osaka-tenmangu'           and d.slug='michizane')
 or (t.slug='namba-jinja'              and d.slug='nintoku-tenno')
 or (t.slug='hiraoka-jinja'            and d.slug='amenokoyane')
 or (t.slug='imamiya-ebisu-jinja'      and d.slug='kotoshironushi')
 or (t.slug='ikuta-jinja'              and d.slug='wakahirume')
 or (t.slug='minatogawa-jinja'         and d.slug='kusunoki-masashige')
 or (t.slug='nishinomiya-jinja'        and d.slug='ebisu')
 or (t.slug='izanagi-jingu'            and d.slug in ('izanagi','izanami'))
 or (t.slug='nakayamadera'             and d.slug='juichimen-kannon')
 or (t.slug='todaiji'                  and d.slug='rushana-butsu')
 or (t.slug='kofukuji'                 and d.slug='shaka_nyorai')
 or (t.slug='horyuji'                  and d.slug='shaka_nyorai')
 or (t.slug='kashihara-jingu'          and d.slug='jinmu-tenno')
 or (t.slug='tanzan-jinja'             and d.slug='fujiwara-kamatari')
 or (t.slug='hasedera-nara'            and d.slug='juichimen-kannon')
 or (t.slug='omiwa-jinja'              and d.slug='omononushi')
 or (t.slug='kumano-nachi-taisha'      and d.slug='kumano-fusumi')
 or (t.slug='kimiidera'                and d.slug='juichimen-kannon')
 or (t.slug='kumano-hayatama-taisha'   and d.slug in ('kumano-hayatama','kumano-fusumi'))
 or (t.slug='kokawadera'               and d.slug='senju_kannon')
 or (t.slug='niutsuhime-jinja'         and d.slug='niutsuhime')
on conflict do nothing;

-- 配祀（sub）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='futami-okitama-jinja'    and d.slug='ukanomitama')
 or (t.slug='hiraoka-jinja'           and d.slug in ('futsunushi','takemikazuchi'))
 or (t.slug='imamiya-ebisu-jinja'     and d.slug in ('amaterasu','susanoo','wakahirume'))
 or (t.slug='niutsuhime-jinja'        and d.slug='ichikishima')
on conflict do nothing;
