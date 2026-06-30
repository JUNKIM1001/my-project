-- ============================================================
-- 関東地方（茨城・栃木・群馬・埼玉・千葉・東京・神奈川）社寺データ 2巡目
-- AGENT_SPEC.md 準拠。全件 ja.wikipedia.org の infobox を WebFetch で裏取り。
-- 座標は infobox の十進値（度分秒は十進変換）を採用。座標が無い社寺は不採録。
-- 1巡目(kanto.sql / extra-famous*.sql)収録分とは重複させていない。
-- 狙い目: 坂東三十三観音・著名神社・著名寺の「次のティア」を中心に41件。
-- ============================================================

-- ============================================================
-- ① 新規神仏（既存柱に無いものだけ）
-- ============================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('togo_heihachiro','東郷平八郎','とうごうへいはちろう','kami','御霊','{東郷平八郎命}','史実','日露戦争日本海海戦を勝利に導いた連合艦隊司令長官。東郷神社の祭神。','https://ja.wikipedia.org/wiki/東郷神社_(渋谷区)','Wikipedia',true,now()),
('nogi_maresuke','乃木希典','のぎまれすけ','kami','御霊','{乃木希典命}','史実','明治の陸軍大将。日露戦争旅順攻略で知られ、明治天皇に殉じた。乃木神社の祭神。','https://ja.wikipedia.org/wiki/乃木希典','Wikipedia',true,now()),
('nogi_shizuko','乃木静子','のぎしずこ','kami','御霊','{乃木静子命}','史実','乃木希典の妻。夫とともに殉死し乃木神社に合祀される。','https://ja.wikipedia.org/wiki/乃木希典','Wikipedia',true,now()),
('amenohohi','天菩比命','あめのほひのみこと','kami','天津神','{天穂日命,アメノホヒ}','記紀','天照大神の子。出雲国造・菅原氏らの祖神とされる。','https://ja.wikipedia.org/wiki/アメノホヒ','Wikipedia',true,now()),
('kushimachi','櫛真智命','くしまちのみこと','kami','天津神','{久志麻知命}','延喜式','卜占を司る神。武蔵御嶽神社の主祭神。','https://ja.wikipedia.org/wiki/武蔵御嶽神社','Wikipedia',true,now()),
('kunado','久那戸神','くなどのかみ','kami','国津神','{岐神,クナド}','記紀','道の岐れに坐し邪を防ぐ道祖・防塞の神。息栖神社の主祭神。','https://ja.wikipedia.org/wiki/岐の神','Wikipedia',true,now()),
('koma_jakko','高麗王若光','こまのこにきしじゃっこう','kami','御霊','{高麗若光}','史実・社伝','高句麗からの渡来人で武蔵国高麗郡の郡司。高麗神社の主祭神。出世明神と称される。','https://ja.wikipedia.org/wiki/高麗神社','Wikipedia',true,now()),
('ninomiya_sontoku','二宮尊徳','にのみやそんとく','kami','御霊','{二宮金次郎,二宮尊徳翁}','史実','江戸後期の農政家・思想家。報徳思想で農村復興を指導。報徳二宮神社の祭神。','https://ja.wikipedia.org/wiki/二宮尊徳','Wikipedia',true,now()),
('taishakuten','帝釈天','たいしゃくてん','buddha','天部','{インドラ}','仏教','仏法守護の天部の神。柴又帝釈天の本尊として信仰される。','https://ja.wikipedia.org/wiki/帝釈天','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ② 新規神仏の司るご利益
-- ============================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='togo_heihachiro' and g.slug in ('shobu','kaijo_anzen','shusse'))
or (d.slug='nogi_maresuke' and g.slug in ('shobu','gakumon','shusse'))
or (d.slug='nogi_shizuko' and g.slug in ('enmusubi','kanai_anzen'))
or (d.slug='amenohohi' and g.slug in ('gakumon','shobai','kaiun'))
or (d.slug='kushimachi' and g.slug in ('yakubarai','majo_kekkai','kaiun'))
or (d.slug='kunado' and g.slug in ('yakubarai','majo_kekkai','tabi_anzen'))
or (d.slug='koma_jakko' and g.slug in ('shusse','shigoto','kaiun'))
or (d.slug='ninomiya_sontoku' and g.slug in ('gakugyo','shobai','shigoto'))
or (d.slug='taishakuten' and g.slug in ('yakubarai','shobu','kaiun'))
on conflict do nothing;

-- ============================================================
-- ③ 社寺
-- ============================================================
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values

-- 茨城県
('ikisu-jinja','息栖神社','いきすじんじゃ','shrine','式内社論社・旧県社','茨城県','神栖市','茨城県神栖市息栖2882',35.8858056,140.6251333,807,null,'http://ikisujinja.com/','鹿島・香取と並ぶ東国三社の一。久那戸神を祀る。','https://ja.wikipedia.org/wiki/息栖神社','Wikipedia',true,now()),
('amabiki-rakuhoji','雨引観音（楽法寺）','あまびきかんのん','temple','真言宗豊山派','茨城県','桜川市','茨城県桜川市本木1',36.33083,140.12083,587,'観世音菩薩','https://amabiki.or.jp/','坂東三十三観音第24番。安産・子育ての雨引観音。','https://ja.wikipedia.org/wiki/楽法寺','Wikipedia',true,now()),
('mito-hachimangu','水戸八幡宮','みとはちまんぐう','shrine','旧県社','茨城県','水戸市','茨城県水戸市八幡町8-54',36.387722,140.459917,1592,null,'http://www.mitohachimangu.or.jp','水府総鎮守。重文の本殿と御葉付公孫樹で知られる八幡宮。','https://ja.wikipedia.org/wiki/水戸八幡宮','Wikipedia',true,now()),
('hitachi-izumo-taisha','常陸国出雲大社','ひたちのくにいずもたいしゃ','shrine','単立','茨城県','笠間市','茨城県笠間市福原2006',36.354167,140.184278,1992,null,'https://izumotaisha.or.jp/','大国主大神を祀り縁結びで知られる。巨大な大注連縄で有名。','https://ja.wikipedia.org/wiki/常陸国出雲大社','Wikipedia',true,now()),
('daiho-hachimangu','大宝八幡宮','だいほうはちまんぐう','shrine','旧県社','茨城県','下妻市','茨城県下妻市大宝667',36.204667,139.971639,701,null,'https://www.daiho.or.jp/','関東最古とされる八幡宮。重文の本殿を有する。','https://ja.wikipedia.org/wiki/大宝八幡宮','Wikipedia',true,now()),

-- 栃木県
('sano-yakuyoke-daishi','佐野厄除大師（惣宗寺）','さのやくよけだいし','temple','天台宗','栃木県','佐野市','栃木県佐野市金井上町2233',36.3109222,139.5713472,944,'如意輪観音・元三大師','https://sanoyakuyokedaishi.or.jp/','関東三大師の一。佐野厄除大師として正月の参拝で知られる。','https://ja.wikipedia.org/wiki/惣宗寺','Wikipedia',true,now()),
('oyaji-utsunomiya','大谷寺','おおやじ','temple','天台宗','栃木県','宇都宮市','栃木県宇都宮市大谷町1198',36.596222,139.820917,null,'千手観音（大谷磨崖仏）','https://www.ooyaji.jp/','坂東三十三観音第19番。大谷石の岩壁に刻まれた磨崖仏で知られる。','https://ja.wikipedia.org/wiki/大谷寺_(宇都宮市)','Wikipedia',true,now()),
('bannaji','鑁阿寺','ばんなじ','temple','真言宗大日派（本山）','栃木県','足利市','栃木県足利市家富町2220',36.337528,139.452250,1196,'大日如来','http://www.ashikaga-bannaji.org/','足利氏の館跡に建つ真言宗大日派本山。日本100名城の一。','https://ja.wikipedia.org/wiki/鑁阿寺','Wikipedia',true,now()),
('ohirasan-jinja','太平山神社','おおひらさんじんじゃ','shrine','旧県社','栃木県','栃木市','栃木県栃木市平井町659',36.362556,139.693083,827,null,'http://www.ohirasanjinja.rpr.jp/','太平山山上に鎮座しあじさい坂で知られる古社。','https://ja.wikipedia.org/wiki/太平山神社','Wikipedia',true,now()),

-- 群馬県
('mizusawa-dera','水澤寺','みずさわでら','temple','天台宗','群馬県','渋川市','群馬県渋川市伊香保町水沢214',36.479333,138.94528,null,'十一面千手観世音菩薩','https://mizusawakannon.or.jp/','坂東三十三観音第16番。水澤観音として知られる。','https://ja.wikipedia.org/wiki/水澤寺','Wikipedia',true,now()),
('kanmuri-inari','冠稲荷神社','かんむりいなりじんじゃ','shrine','旧村社','群馬県','太田市','群馬県太田市細谷町1',36.2688028,139.3515250,1125,null,'https://kanmuri.com/','日本七稲荷の一に数えられる縁結び・子宝の社。','https://ja.wikipedia.org/wiki/冠稲荷神社','Wikipedia',true,now()),
('serada-toshogu','世良田東照宮','せらだとうしょうぐう','shrine','旧県社','群馬県','太田市','群馬県太田市世良田町3119-1',36.2619500,139.2754472,1644,null,'http://www.net-you.com/toshogu/index.php','徳川氏発祥の地に建ち日光東照宮の旧社殿を移築した東照宮。','https://ja.wikipedia.org/wiki/世良田東照宮','Wikipedia',true,now()),
('maebashi-toshogu','前橋東照宮','まえばしとうしょうぐう','shrine','旧県社','群馬県','前橋市','群馬県前橋市大手町3-13-19',36.39444,139.06194,1624,null,'http://www.toshogu.net/maebashi/','前橋城跡に鎮座する徳川家康を祀る東照宮。','https://ja.wikipedia.org/wiki/前橋東照宮','Wikipedia',true,now()),

-- 埼玉県
('jikoji-tokigawa','慈光寺','じこうじ','temple','天台宗','埼玉県','比企郡ときがわ町','埼玉県比企郡ときがわ町西平386',36.011500,139.232111,770,'十一面千手千眼観世音菩薩','https://www.temple.or.jp/','坂東三十三観音第9番。国宝の装飾経で知られる山岳寺院。','https://ja.wikipedia.org/wiki/慈光寺_(埼玉県ときがわ町)','Wikipedia',true,now()),
('kawagoe-nakain','中院','なかいん','temple','天台宗','埼玉県','川越市','埼玉県川越市小仙波町5-15-1',35.914917,139.490361,830,'阿弥陀如来','https://www.nakain.com/','喜多院と並ぶ天台宗寺院。狭山茶発祥地・しだれ桜で知られる。','https://ja.wikipedia.org/wiki/中院','Wikipedia',true,now()),
('kawagoe-kumano','川越熊野神社','かわごえくまのじんじゃ','shrine','旧村社','埼玉県','川越市','埼玉県川越市連雀町17-1',35.919111,139.483083,1590,null,'https://www.kawagoekumano.jp/','川越の中心に鎮座する熊野大神を祀る縁結びの社。','https://ja.wikipedia.org/wiki/熊野神社_(川越市)','Wikipedia',true,now()),
('koma-jinja','高麗神社','こまじんじゃ','shrine','旧郷社','埼玉県','日高市','埼玉県日高市新堀833',35.898583,139.322806,716,null,'https://komajinja.or.jp/','高麗王若光を祀り出世明神と称される渡来人ゆかりの古社。','https://ja.wikipedia.org/wiki/高麗神社','Wikipedia',true,now()),

-- 千葉県
('kasamori-ji','笠森寺','かさもりでら','temple','天台宗','千葉県','長生郡長南町','千葉県長生郡長南町笠森302',35.399611,140.198917,784,'十一面観世音菩薩','http://kasamori-ji.or.jp/','坂東三十三観音第31番。四方懸造の観音堂で知られる笠森観音。','https://ja.wikipedia.org/wiki/笠森寺','Wikipedia',true,now()),
('nagoji','那古寺','なごじ','temple','真言宗智山派','千葉県','館山市','千葉県館山市那古1125',35.02556,139.857972,717,'千手観世音菩薩','https://www.nagoji.com/','坂東三十三観音第33番（結願寺）。那古観音として知られる。','https://ja.wikipedia.org/wiki/那古寺','Wikipedia',true,now()),
('oohi-jinja','意富比神社（船橋大神宮）','おおひじんじゃ','shrine','式内社・旧県社','千葉県','船橋市','千葉県船橋市宮本5-2-1',35.696222,139.992972,null,null,'http://www.oohijinja.jp/','船橋大神宮と通称される天照大御神を祀る式内社。','https://ja.wikipedia.org/wiki/意富比神社','Wikipedia',true,now()),
('sakuragi-jinja-noda','櫻木神社','さくらぎじんじゃ','shrine','旧村社','千葉県','野田市','千葉県野田市桜台210',35.937806,139.874861,851,null,'https://www.sakuragi.info/','野田最古とされ桜の名所として知られる神社。','https://ja.wikipedia.org/wiki/櫻木神社_(野田市)','Wikipedia',true,now()),

-- 東京都
('togo-jinja','東郷神社','とうごうじんじゃ','shrine','旧府社','東京都','渋谷区','東京都渋谷区神宮前1-5-3',35.671667,139.705833,1940,null,'https://togojinja.or.jp/','日露戦争の英雄・東郷平八郎を祀る原宿の神社。','https://ja.wikipedia.org/wiki/東郷神社_(渋谷区)','Wikipedia',true,now()),
('nogi-jinja-tokyo','乃木神社','のぎじんじゃ','shrine','旧府社・別表神社','東京都','港区','東京都港区赤坂8-11-27',35.66889,139.72806,1923,null,'https://www.nogijinja.or.jp/','乃木希典夫妻を祀る赤坂の神社。旧乃木邸に隣接する。','https://ja.wikipedia.org/wiki/乃木神社_(東京都港区)','Wikipedia',true,now()),
('kameido-tenjin','亀戸天神社','かめいどてんじんしゃ','shrine','旧府社','東京都','江東区','東京都江東区亀戸3-6-1',35.703139,139.821000,1661,null,'https://kameidotenjin.or.jp/','藤と太鼓橋で知られる学問の神・菅原道真を祀る東宰府天満宮。','https://ja.wikipedia.org/wiki/亀戸天神社','Wikipedia',true,now()),
('yushima-tenmangu','湯島天満宮','ゆしまてんまんぐう','shrine','旧府社・別表神社','東京都','文京区','東京都文京区湯島3-30-1',35.707861,139.767833,458,null,'https://www.yushimatenjin.or.jp/','受験生が合格祈願に訪れる梅の名所。学問の神を祀る。','https://ja.wikipedia.org/wiki/湯島天満宮','Wikipedia',true,now()),
('shinagawa-jinja','品川神社','しながわじんじゃ','shrine','旧郷社・別表神社','東京都','品川区','東京都品川区北品川3-7-15',35.618472,139.739639,1187,null,'https://shinagawajinja.tokyo/','東京十社の一。東海七福神の大黒天で知られる品川総鎮守。','https://ja.wikipedia.org/wiki/品川神社','Wikipedia',true,now()),
('akasaka-hikawa','赤坂氷川神社','あかさかひかわじんじゃ','shrine','准勅祭社・旧府社','東京都','港区','東京都港区赤坂6-10-12',35.6682333,139.7355139,951,null,'https://www.akasakahikawa.or.jp/','東京十社の一。徳川吉宗が造営した社殿が残る縁結びの社。','https://ja.wikipedia.org/wiki/氷川神社_(港区)','Wikipedia',true,now()),
('ohmiya-hachimangu','大宮八幡宮','おおみやはちまんぐう','shrine','旧郷社','東京都','杉並区','東京都杉並区大宮2-3-1',35.6823750,139.6396639,1063,null,'https://www.ohmiya-hachimangu.or.jp/','源頼義が創建した「東京のへそ」と称される武蔵国の八幡宮。','https://ja.wikipedia.org/wiki/大宮八幡宮_(杉並区)','Wikipedia',true,now()),
('musashi-mitake','武蔵御嶽神社','むさしみたけじんじゃ','shrine','式内社論社・旧府社','東京都','青梅市','東京都青梅市御岳山176',35.782833,139.15000,null,null,'http://www.musashimitakejinja.jp/','御岳山頂に鎮座し大口真神（おいぬ様）信仰で知られる山岳の社。','https://ja.wikipedia.org/wiki/武蔵御嶽神社','Wikipedia',true,now()),
('tsukiji-honganji','築地本願寺','つきじほんがんじ','temple','浄土真宗本願寺派','東京都','中央区','東京都中央区築地3-15-1',35.666472,139.772306,1617,'阿弥陀如来','https://tsukijihongwanji.jp/','インド様式の伊東忠太設計による浄土真宗本願寺派の直轄寺院。','https://ja.wikipedia.org/wiki/築地本願寺','Wikipedia',true,now()),
('ikegami-honmonji','池上本門寺','いけがみほんもんじ','temple','日蓮宗（大本山）','東京都','大田区','東京都大田区池上1-1-1',35.57889,139.705167,1282,'三宝尊','https://honmonji.jp/','日蓮聖人入滅の地に建つ日蓮宗大本山。お会式で知られる。','https://ja.wikipedia.org/wiki/池上本門寺','Wikipedia',true,now()),
('jindaiji','深大寺','じんだいじ','temple','天台宗','東京都','調布市','東京都調布市深大寺元町5-15-1',35.6675250,139.550472,733,'宝冠阿弥陀如来','http://www.jindaiji.or.jp/','都内屈指の古刹で深大寺そばと白鳳仏（国宝）で知られる。','https://ja.wikipedia.org/wiki/深大寺','Wikipedia',true,now()),
('shibamata-taishakuten','柴又帝釈天（題経寺）','しばまたたいしゃくてん','temple','日蓮宗','東京都','葛飾区','東京都葛飾区柴又7-10-3',35.7584000,139.8782000,1629,'大曼荼羅（帝釈天）','https://www.taishakuten.com/','映画「男はつらいよ」で知られる柴又帝釈天。彫刻ギャラリーで有名。','https://ja.wikipedia.org/wiki/題経寺','Wikipedia',true,now()),
('nishiarai-daishi','西新井大師（總持寺）','にしあらいだいし','temple','真言宗豊山派','東京都','足立区','東京都足立区西新井1-15-1',35.780139,139.780000,826,'十一面観世音菩薩・弘法大師','https://www.nishiaraidaishi.or.jp/','関東三大師の一。厄除けの西新井大師として知られる。','https://ja.wikipedia.org/wiki/總持寺_(足立区)','Wikipedia',true,now()),
('suitengu-tokyo','水天宮','すいてんぐう','shrine','単立','東京都','中央区','東京都中央区日本橋蛎殻町2-4-1',35.68361,139.78500,1818,null,'https://www.suitengu.or.jp/','久留米水天宮の分社で安産・子授けの神として知られる。','https://ja.wikipedia.org/wiki/水天宮_(東京都中央区)','Wikipedia',true,now()),
('ana-hachimangu','穴八幡宮','あなはちまんぐう','shrine','旧村社','東京都','新宿区','東京都新宿区西早稲田2-1-11',35.707333,139.717222,1062,null,'https://www.anahachimanguu.jp/','一陽来復の御守と冬至祭で知られる早稲田の八幡宮。','https://ja.wikipedia.org/wiki/穴八幡宮','Wikipedia',true,now()),

-- 神奈川県
('sugimoto-dera','杉本寺','すぎもとでら','temple','天台宗','神奈川県','鎌倉市','神奈川県鎌倉市二階堂903',35.322583,139.567444,734,'十一面観世音菩薩','https://sugimotodera.com/','坂東三十三観音第1番。苔の石段で知られる鎌倉最古の寺。','https://ja.wikipedia.org/wiki/杉本寺','Wikipedia',true,now()),
('gandenji-zushi','岩殿寺','がんでんじ','temple','曹洞宗','神奈川県','逗子市','神奈川県逗子市久木5-7-11',35.305056,139.572306,721,'十一面観世音菩薩','https://www.gandenji.jp/','坂東三十三観音第2番。逗子の岩殿観音として知られる。','https://ja.wikipedia.org/wiki/岩殿寺_(逗子市)','Wikipedia',true,now()),
('anyoin-kamakura','安養院','あんよういん','temple','浄土宗','神奈川県','鎌倉市','神奈川県鎌倉市大町3-1-22',35.31417,139.55528,1225,'阿弥陀如来','https://www.anyoin.or.jp/','坂東三十三観音第3番。北条政子ゆかりのつつじの寺。','https://ja.wikipedia.org/wiki/安養院_(鎌倉市)','Wikipedia',true,now()),
('gumyoji','弘明寺','ぐみょうじ','temple','高野山真言宗','神奈川県','横浜市','神奈川県横浜市南区弘明寺町267',35.42417,139.597417,737,'十一面観世音菩薩','https://www.gumyoji.jp/','坂東三十三観音第14番。横浜最古の寺で弘明寺観音として知られる。','https://ja.wikipedia.org/wiki/弘明寺','Wikipedia',true,now()),
('oyamadera-isehara','大山寺','おおやまでら','temple','真言宗大覚寺派','神奈川県','伊勢原市','神奈川県伊勢原市大山724',35.429278,139.239361,755,'鉄造不動明王','https://oyamadera.jp/','関東三大不動の一。大山阿夫利神社とともに大山詣で知られる。','https://ja.wikipedia.org/wiki/大山寺_(伊勢原市)','Wikipedia',true,now()),
('sojiji-yokohama','總持寺','そうじじ','temple','曹洞宗（大本山）','神奈川県','横浜市','神奈川県横浜市鶴見区鶴見2-1-1',35.5069889,139.6714583,1321,'釈迦如来','https://www.sojiji.jp/','永平寺と並ぶ曹洞宗大本山。能登から鶴見に移転した大寺院。','https://ja.wikipedia.org/wiki/總持寺','Wikipedia',true,now()),
('hotoku-ninomiya','報徳二宮神社','ほうとくにのみやじんじゃ','shrine','旧県社','神奈川県','小田原市','神奈川県小田原市城内8-10',35.25000,139.15278,1894,null,'http://www.ninomiya.or.jp/','小田原城址に鎮座する二宮尊徳を祀る神社。','https://ja.wikipedia.org/wiki/報徳二宮神社_(小田原市)','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ④ 御祭神/本尊の紐付け（主祭神/本尊=main、配祀=sub）
-- ============================================================
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
-- 茨城
   (t.slug='ikisu-jinja' and d.slug in ('kunado'))
or (t.slug='amabiki-rakuhoji' and d.slug in ('juichimen_kannon'))
or (t.slug='mito-hachimangu' and d.slug in ('hachiman','jingu_kogo'))
or (t.slug='hitachi-izumo-taisha' and d.slug in ('okuninushi'))
or (t.slug='daiho-hachimangu' and d.slug in ('hachiman','chuai','jingu_kogo'))
-- 栃木
or (t.slug='sano-yakuyoke-daishi' and d.slug in ('nyoirin_kannon'))
or (t.slug='oyaji-utsunomiya' and d.slug in ('senju_kannon'))
or (t.slug='bannaji' and d.slug in ('dainichi_nyorai'))
or (t.slug='ohirasan-jinja' and d.slug in ('ninigi','amaterasu','toyouke'))
-- 群馬
or (t.slug='mizusawa-dera' and d.slug in ('senju_kannon'))
or (t.slug='kanmuri-inari' and d.slug in ('ukanomitama'))
or (t.slug='serada-toshogu' and d.slug in ('ieyasu'))
or (t.slug='maebashi-toshogu' and d.slug in ('ieyasu'))
-- 埼玉
or (t.slug='jikoji-tokigawa' and d.slug in ('senju_kannon'))
or (t.slug='kawagoe-nakain' and d.slug in ('amida_nyorai'))
or (t.slug='kawagoe-kumano' and d.slug in ('izanagi'))
or (t.slug='koma-jinja' and d.slug in ('koma_jakko'))
-- 千葉
or (t.slug='kasamori-ji' and d.slug in ('juichimen_kannon'))
or (t.slug='nagoji' and d.slug in ('senju_kannon'))
or (t.slug='oohi-jinja' and d.slug in ('amaterasu'))
or (t.slug='sakuragi-jinja-noda' and d.slug in ('ukanomitama','takemikazuchi','izanagi','izanami'))
-- 東京
or (t.slug='togo-jinja' and d.slug in ('togo_heihachiro'))
or (t.slug='nogi-jinja-tokyo' and d.slug in ('nogi_maresuke'))
or (t.slug='kameido-tenjin' and d.slug in ('michizane'))
or (t.slug='yushima-tenmangu' and d.slug in ('amenotajikarao','michizane'))
or (t.slug='shinagawa-jinja' and d.slug in ('susanoo','ukanomitama'))
or (t.slug='akasaka-hikawa' and d.slug in ('susanoo','kushinadahime','okuninushi'))
or (t.slug='ohmiya-hachimangu' and d.slug in ('hachiman','chuai','jingu_kogo'))
or (t.slug='musashi-mitake' and d.slug in ('kushimachi'))
or (t.slug='tsukiji-honganji' and d.slug in ('amida_nyorai'))
or (t.slug='ikegami-honmonji' and d.slug in ('shaka_nyorai'))
or (t.slug='jindaiji' and d.slug in ('amida_nyorai'))
or (t.slug='shibamata-taishakuten' and d.slug in ('taishakuten'))
or (t.slug='nishiarai-daishi' and d.slug in ('juichimen_kannon','kobo_daishi'))
or (t.slug='suitengu-tokyo' and d.slug in ('amenominakanushi','antoku_tenno'))
or (t.slug='ana-hachimangu' and d.slug in ('hachiman','chuai','jingu_kogo'))
-- 神奈川
or (t.slug='sugimoto-dera' and d.slug in ('juichimen_kannon'))
or (t.slug='gandenji-zushi' and d.slug in ('juichimen_kannon'))
or (t.slug='anyoin-kamakura' and d.slug in ('amida_nyorai'))
or (t.slug='gumyoji' and d.slug in ('juichimen_kannon'))
or (t.slug='oyamadera-isehara' and d.slug in ('fudo_myoo'))
or (t.slug='sojiji-yokohama' and d.slug in ('shaka_nyorai'))
or (t.slug='hotoku-ninomiya' and d.slug in ('ninomiya_sontoku'))
on conflict do nothing;

-- 配祀（sub）
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'sub' from temple_shrine t join deity d on true where
   (t.slug='kameido-tenjin' and d.slug in ('amenohohi'))
or (t.slug='nogi-jinja-tokyo' and d.slug in ('nogi_shizuko'))
on conflict do nothing;
