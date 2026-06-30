-- =====================================================================
-- 御朱印ナビ データ拡張: 九州・沖縄 (w10)
-- ja.wikipedia infobox の十進座標で裏取り。座標無しは除外。
-- 既存 _have_kyushu-okinawa.txt と重複しない著名社寺のみ収録。
-- =====================================================================

-- ① 新規神仏（既存14柱に無いものだけ）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('jinmu_tenno','神武天皇','じんむてんのう','kami','人神','{}','記紀','初代天皇。日向から東征し大和を平定したと伝わる。','https://ja.wikipedia.org/wiki/神武天皇','Wikipedia',true,now()),
('kamuyaimimi','神八井耳命','かむやいみみのみこと','kami','人神','{}','記紀','神武天皇の皇子。多氏・阿蘇氏らの祖とされる。','https://ja.wikipedia.org/wiki/神八井耳命','Wikipedia',true,now()),
('sarutahiko','猿田彦神','さるたひこのかみ','kami','国津神','{}','記紀','天孫降臨を道案内した導きの神。道祖神・交通安全の神。','https://ja.wikipedia.org/wiki/サルタヒコ','Wikipedia',true,now()),
('amenouzume','天鈿女命','あめのうずめのみこと','kami','天津神','{}','記紀','天岩戸で舞った芸能の女神。猿田彦の妻。','https://ja.wikipedia.org/wiki/アメノウズメ','Wikipedia',true,now()),
('shimazu_tadahisa','島津忠久','しまづただひさ','kami','御霊','{}','史伝','島津氏初代当主。鶴嶺神社などに祀られる。','https://ja.wikipedia.org/wiki/島津忠久','Wikipedia',true,now()),
('hime_okami','比売大神','ひめおおかみ','kami','宗像三女神','{}','記紀','宇佐・八幡系に祀られる女神。宗像三女神に比定される。','https://ja.wikipedia.org/wiki/ヒメガミ','Wikipedia',true,now()),
('unagihime','宇奈岐日女','うなぎひめ','kami','国津神','{}','社伝','由布院盆地を拓いたと伝わる女神。宇奈岐日女神社の祭神。','https://ja.wikipedia.org/wiki/宇奈岐日女神社','Wikipedia',true,now()),
('kunitokotachi','国常立尊','くにのとこたちのみこと','kami','天津神','{}','記紀','天地開闢に現れた根源神。','https://ja.wikipedia.org/wiki/クニノトコタチ','Wikipedia',true,now()),
('myoken','妙見菩薩','みょうけんぼさつ','buddha','菩薩','{}','仏教','北極星・北斗を神格化した菩薩。眼病平癒・国土守護。','https://ja.wikipedia.org/wiki/妙見菩薩','Wikipedia',true,now()),
('ninigi','瓊瓊杵尊','ににぎのみこと','kami','天津神','{}','記紀','天孫降臨した天照大神の孫。','https://ja.wikipedia.org/wiki/ニニギ','Wikipedia',true,now()),
('amida_nyorai','阿弥陀如来','あみだにょらい','buddha','如来','{}','仏教','西方極楽浄土の教主。','https://ja.wikipedia.org/wiki/阿弥陀如来','Wikipedia',true,now()),
('dainichi_nyorai','大日如来','だいにちにょらい','buddha','如来','{}','仏教','密教の本尊。宇宙の真理そのものとされる。','https://ja.wikipedia.org/wiki/大日如来','Wikipedia',true,now()),
('toyouke','豊受大神','とようけのおおかみ','kami','天津神','{}','記紀','食物・穀物を司る女神。伊勢外宮の祭神。','https://ja.wikipedia.org/wiki/トヨウケビメ','Wikipedia',true,now()),
('shaka_nyorai','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖を仏格化した如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now()),
('monju','文殊菩薩','もんじゅぼさつ','buddha','菩薩','{}','仏教','智慧を司る菩薩。学業成就の信仰を集める。','https://ja.wikipedia.org/wiki/文殊菩薩','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ② 新規神仏の司るご利益
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='jinmu_tenno' and g.slug in ('kaiun','shobu','shusse'))
or (d.slug='kamuyaimimi' and g.slug in ('kaiun','gakugyo'))
or (d.slug='sarutahiko' and g.slug in ('kotsu_anzen','kaiun','tabi_anzen'))
or (d.slug='amenouzume' and g.slug in ('geino','enmusubi','kaiun'))
or (d.slug='shimazu_tadahisa' and g.slug in ('shusse','kaiun'))
or (d.slug='hime_okami' and g.slug in ('kaijo_anzen','kaiun','kanai_anzen'))
or (d.slug='unagihime' and g.slug in ('suisan_noko','mizu_amagoi','kaiun'))
or (d.slug='kunitokotachi' and g.slug in ('kaiun','yakubarai'))
or (d.slug='myoken' and g.slug in ('byoki_heyu','kaiun','majo_kekkai'))
or (d.slug='ninigi' and g.slug in ('suisan_noko','kaiun','kanai_anzen'))
or (d.slug='amida_nyorai' and g.slug in ('jouju','byoki_heyu','kaiun'))
or (d.slug='dainichi_nyorai' and g.slug in ('kaiun','yakubarai','jouju'))
or (d.slug='toyouke' and g.slug in ('suisan_noko','shobai','kanai_anzen'))
or (d.slug='shaka_nyorai' and g.slug in ('jouju','byoki_heyu','kaiun'))
or (d.slug='monju' and g.slug in ('gakugyo','gakumon','kaiun'))
on conflict do nothing;

-- ③ 社寺 ＋ ④ 紐付け（5件ごと逐次保存）

-- --- batch 1 (1-5) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kawajiri-jingu','河尻神宮','かわじりじんぐう','shrine','旧県社','熊本県','熊本市','熊本県熊本市南区八幡5丁目1-50',32.748028,130.681722,1197,null,null,'鶴岡八幡の分霊を勧請した熊本市南部の八幡宮。加藤・細川両氏の崇敬を受けた。','https://ja.wikipedia.org/wiki/河尻神宮','Wikipedia',true,now()),
('otonari-jinja','男成神社','おとなりじんじゃ','shrine','旧郷社','熊本県','上益城郡山都町','熊本県上益城郡山都町男成519',32.685639,131.027056,null,null,null,'阿蘇氏の元服の社として知られる古社。','https://ja.wikipedia.org/wiki/男成神社','Wikipedia',true,now()),
('aratate-jinja','荒立神社','あらたてじんじゃ','shrine','神社','宮崎県','西臼杵郡高千穂町','宮崎県西臼杵郡高千穂町三田井宮尾野',32.711722,131.317083,null,null,null,'猿田彦命と天鈿女命を祀る。芸能・縁結びの信仰を集める高千穂の社。','https://ja.wikipedia.org/wiki/荒立神社','Wikipedia',true,now()),
('tsurugane-jinja','鶴嶺神社','つるがねじんじゃ','shrine','神社','鹿児島県','鹿児島市','鹿児島県鹿児島市吉野町9698-2',31.618250,130.576389,1869,null,null,'仙巌園内に鎮座し、島津家歴代当主を祀る。','https://ja.wikipedia.org/wiki/鶴嶺神社','Wikipedia',true,now()),
('nada-gu','奈多宮','なだぐう','shrine','旧県社','大分県','杵築市','大分県杵築市大字奈多229',33.428719,131.706279,729,null,'http://nadagu.wp.xdomain.jp/','宇佐神宮と深い関わりを持つ古社。八幡神像など国重文を蔵する。','https://ja.wikipedia.org/wiki/奈多宮','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kawajiri-jingu' and d.slug in ('hachiman'))
or (t.slug='otonari-jinja' and d.slug in ('amaterasu','jinmu_tenno','kamuyaimimi'))
or (t.slug='aratate-jinja' and d.slug in ('sarutahiko','amenouzume'))
or (t.slug='tsurugane-jinja' and d.slug in ('shimazu_tadahisa'))
or (t.slug='nada-gu' and d.slug in ('hime_okami','hachiman','jingu_kogo'))
on conflict do nothing;

-- --- batch 2 (6-10) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('unagihime-jinja','宇奈岐日女神社','うなぎひめじんじゃ','shrine','式内社・旧県社','大分県','由布市','大分県由布市湯布院町川上2220',33.256886,131.365589,849,null,null,'由布岳を神体とする式内社。樹齢千年超の大杵社の大スギで知られる。','https://ja.wikipedia.org/wiki/宇奈岐日女神社','Wikipedia',true,now()),
('kumo-hachimangu','雲八幡宮','くもはちまんぐう','shrine','旧郷社','大分県','中津市','大分県中津市耶馬溪町宮園407',33.426361,131.091750,703,null,'http://kumohachiman.j-air.net/','八幡神と妙見神を祀る。河童伝説の宮園楽で知られる。','https://ja.wikipedia.org/wiki/雲八幡宮','Wikipedia',true,now()),
('shirahige-tawara-jinja','白鬚田原神社','しらひげたわらじんじゃ','shrine','旧郷社','大分県','杵築市','大分県杵築市大田沓掛1693',33.503194,131.549861,710,null,null,'九州で唯一どぶろく醸造を許された「どぶろく祭り」で名高い社。','https://ja.wikipedia.org/wiki/白鬚田原神社','Wikipedia',true,now()),
('ryuganji-usa','龍岩寺','りゅうがんじ','temple','曹洞宗','大分県','宇佐市','大分県宇佐市院内町大門290-2',33.404278,131.270889,746,'阿弥陀如来',null,'断崖に懸造の奥院礼堂を備える。一木造の三尊像（国重文）を蔵する。','https://ja.wikipedia.org/wiki/龍岩寺_(宇佐市)','Wikipedia',true,now()),
('fukoji-bungoono','普光寺','ふこうじ','temple','高野山真言宗','大分県','豊後大野市','大分県豊後大野市朝地町上尾塚1225',32.984872,131.430278,null,'大日如来',null,'磨崖仏（不動明王）と紫陽花で知られる「あじさい寺」。','https://ja.wikipedia.org/wiki/普光寺_(豊後大野市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='unagihime-jinja' and d.slug in ('unagihime','kunitokotachi'))
or (t.slug='kumo-hachimangu' and d.slug in ('hachiman','myoken'))
or (t.slug='shirahige-tawara-jinja' and d.slug in ('ninigi','sarutahiko','amenouzume'))
or (t.slug='ryuganji-usa' and d.slug in ('amida_nyorai'))
or (t.slug='fukoji-bungoono' and d.slug in ('dainichi_nyorai'))
on conflict do nothing;

-- ① 追加神仏（batch3-4 用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('yakushi_nyorai','薬師如来','やくしにょらい','buddha','如来','{}','仏教','東方瑠璃光浄土の教主。病気平癒の仏。','https://ja.wikipedia.org/wiki/薬師如来','Wikipedia',true,now()),
('ankan_tenno','安閑天皇','あんかんてんのう','kami','人神','{}','記紀','第27代天皇。蔵王権現に習合し金峰神社等に祀られる。','https://ja.wikipedia.org/wiki/安閑天皇','Wikipedia',true,now()),
('hikohohodemi','彦火火出見尊','ひこほほでみのみこと','kami','天津神','{}','記紀','山幸彦。海神の娘豊玉姫を妃とした神。','https://ja.wikipedia.org/wiki/ホオリ','Wikipedia',true,now()),
('toyotamahime','豊玉姫','とよたまひめ','kami','国津神','{}','記紀','海神の娘。彦火火出見尊の妃で鵜茅葺不合命の母。','https://ja.wikipedia.org/wiki/トヨタマビメ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='yakushi_nyorai' and g.slug in ('byoki_heyu','choju','kaiun'))
or (d.slug='ankan_tenno' and g.slug in ('kaiun','shobu','yakubarai'))
or (d.slug='hikohohodemi' and g.slug in ('suisan_noko','kaijo_anzen','enmusubi'))
or (d.slug='toyotamahime' and g.slug in ('anzan','kosodate','enmusubi'))
on conflict do nothing;

-- --- batch 3 (11-15) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('shijukusho-jinja','四十九所神社','しじゅうくしょじんじゃ','shrine','旧郷社','鹿児島県','肝属郡肝付町','鹿児島県肝属郡肝付町新富5580',31.343306,130.946778,984,null,null,'伊勢から勧請した古社。900年続く「流鏑馬」（流鏑馬）で名高い。','https://ja.wikipedia.org/wiki/四十九所神社','Wikipedia',true,now()),
('miyaura-gu','宮浦宮','みやうらぐう','shrine','式内社・旧県社','鹿児島県','霧島市','鹿児島県霧島市福山町福山',31.671083,130.819528,null,null,null,'大隅国五社の式内社。夫婦銀杏の大樹で知られ錦江湾を望む。','https://ja.wikipedia.org/wiki/宮浦宮','Wikipedia',true,now()),
('iwatoji-kunisaki','岩戸寺','いわとうじ','temple','天台宗','大分県','国東市','大分県国東市国東町岩戸寺1232',33.619222,131.618833,718,'薬師如来',null,'六郷満山の古刹。国重文の国東塔と日本最古銘の石造仁王像で知られる。','https://ja.wikipedia.org/wiki/岩戸寺_(国東市)','Wikipedia',true,now()),
('buzen-zenkoji','豊前善光寺','ぶぜんぜんこうじ','temple','浄土宗','大分県','宇佐市','大分県宇佐市大字下時枝237',33.559667,131.305194,958,'善光寺式阿弥陀三尊','http://www.buzen-zenkoji.sakura.ne.jp/','信州善光寺の分身を伝える古刹。本堂は国重文。','https://ja.wikipedia.org/wiki/豊前善光寺','Wikipedia',true,now()),
('bungo-kokubunji','豊後国分寺','ぶんごこくぶんじ','temple','天台宗','大分県','大分市','大分県大分市国分972',33.194636,131.554139,741,'薬師如来',null,'聖武天皇の勅願による豊後国分寺の後継。七重塔跡を残す史跡。','https://ja.wikipedia.org/wiki/豊後国分寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='shijukusho-jinja' and d.slug in ('amaterasu','toyouke'))
or (t.slug='miyaura-gu' and d.slug in ('jinmu_tenno'))
or (t.slug='iwatoji-kunisaki' and d.slug in ('yakushi_nyorai'))
or (t.slug='buzen-zenkoji' and d.slug in ('amida_nyorai'))
or (t.slug='bungo-kokubunji' and d.slug in ('yakushi_nyorai'))
on conflict do nothing;

-- --- batch 4 (16-20) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kinpo-jinja-minamisatsuma','金峰神社','きんぽうじんじゃ','shrine','旧県社','鹿児島県','南さつま市','鹿児島県南さつま市金峰町尾下5559',31.467750,130.382194,null,null,null,'金峰山頂に鎮座する修験の社。安閑天皇を祀る。','https://ja.wikipedia.org/wiki/金峰神社_(南さつま市)','Wikipedia',true,now()),
('koriyama-hachiman-isa','郡山八幡神社','こおりやまはちまんじんじゃ','shrine','旧郷社','鹿児島県','伊佐市','鹿児島県伊佐市大口大田1549',32.083056,130.598167,1194,null,null,'本殿は国重文。日本最古の「焼酎」墨書が発見された社として有名。','https://ja.wikipedia.org/wiki/郡山八幡神社_(伊佐市)','Wikipedia',true,now()),
('takaya-jinja-minamisatsuma','竹屋神社','たかやじんじゃ','shrine','旧県社','鹿児島県','南さつま市','鹿児島県南さつま市加世田宮原2360',31.430833,130.309861,null,null,null,'加世田の総鎮守。彦火火出見尊・豊玉姫を祀り、磐境の遺構を残す。','https://ja.wikipedia.org/wiki/竹屋神社_(南さつま市)','Wikipedia',true,now()),
('onamuchi-jinja-kirishima','大穴持神社','おおあなもちじんじゃ','shrine','式内社・旧県社','鹿児島県','霧島市','鹿児島県霧島市国分広瀬3-1089',31.715353,130.756797,null,null,null,'大己貴命を祀る式内社。医薬・蛇難除けの神として信仰される。','https://ja.wikipedia.org/wiki/大穴持神社_(霧島市)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kinpo-jinja-minamisatsuma' and d.slug in ('ankan_tenno'))
or (t.slug='koriyama-hachiman-isa' and d.slug in ('jingu_kogo'))
or (t.slug='takaya-jinja-minamisatsuma' and d.slug in ('hikohohodemi','toyotamahime'))
or (t.slug='onamuchi-jinja-kirishima' and d.slug in ('okuninushi'))
on conflict do nothing;

-- ① 追加神仏（batch5-6 用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('susanoo','素戔嗚尊','すさのおのみこと','kami','天津神','{}','記紀','天照大神の弟。八岐大蛇退治で知られる荒ぶる神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('kushinadahime','櫛名田比売','くしなだひめ','kami','国津神','{}','記紀','八岐大蛇から救われた素戔嗚尊の妃。','https://ja.wikipedia.org/wiki/クシナダヒメ','Wikipedia',true,now()),
('yamatotakeru','日本武尊','やまとたけるのみこと','kami','人神','{}','記紀','景行天皇の皇子。各地を平定した英雄。武の神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('izanagi','伊弉諾尊','いざなぎのみこと','kami','天津神','{}','記紀','国生み・神生みを行った男神。','https://ja.wikipedia.org/wiki/イザナギ','Wikipedia',true,now()),
('izanami','伊弉冉尊','いざなみのみこと','kami','天津神','{}','記紀','国生み・神生みを行った女神。','https://ja.wikipedia.org/wiki/イザナミ','Wikipedia',true,now()),
('amenokoyane','天児屋根命','あめのこやねのみこと','kami','天津神','{}','記紀','祝詞を司る神。中臣・藤原氏の祖神。','https://ja.wikipedia.org/wiki/アメノコヤネ','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','enmusubi'))
or (d.slug='kushinadahime' and g.slug in ('enmusubi','kanai_anzen','anzan'))
or (d.slug='yamatotakeru' and g.slug in ('shobu','kaiun','yakubarai'))
or (d.slug='izanagi' and g.slug in ('enmusubi','kanai_anzen','kaiun'))
or (d.slug='izanami' and g.slug in ('enmusubi','anzan','kosodate'))
or (d.slug='amenokoyane' and g.slug in ('gakumon','shusse','kaiun'))
on conflict do nothing;

-- --- batch 5 (20-24) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('ryuzoji-hachimangu','龍造寺八幡宮','りゅうぞうじはちまんぐう','shrine','旧県社','佐賀県','佐賀市','佐賀県佐賀市白山一丁目3番2号',33.255425,130.298531,1187,null,null,'龍造寺氏が鶴岡八幡を勧請。龍造寺・鍋島両氏の崇敬社で1604年の石造鳥居が残る。','https://ja.wikipedia.org/wiki/龍造寺八幡宮','Wikipedia',true,now()),
('kushida-gu-kanzaki','櫛田宮','くしだぐう','shrine','旧県社','佐賀県','神埼市','佐賀県神埼市神埼町神埼419-1',33.310167,130.372583,null,null,'https://www5b.biglobe.ne.jp/~kusidagu/','櫛田三神を祀る古社。神埼の地名の由来とされ、隔年の御幸大祭で知られる。','https://ja.wikipedia.org/wiki/櫛田宮','Wikipedia',true,now()),
('nikita-jinja','新北神社','にきたじんじゃ','shrine','旧郷社','佐賀県','佐賀市','佐賀県佐賀市諸富町大字大堂1073',33.221670,130.341110,585,null,null,'素盞鳴命を祀る。樹齢2200年の槙や徐福伝説で知られる。','https://ja.wikipedia.org/wiki/新北神社','Wikipedia',true,now()),
('nannyo-jinja','男女神社','なんにょじんじゃ','shrine','神社','佐賀県','佐賀市','佐賀県佐賀市大和町大字久留間5109',33.317500,130.231390,null,null,'https://www.nannyojinja.or.jp/','伊弉諾・伊弉冉を祀る縁結びの社。今山の戦いの古事で知られる。','https://ja.wikipedia.org/wiki/男女神社','Wikipedia',true,now()),
('kushifuru-jinja','槵觸神社','くしふるじんじゃ','shrine','旧県社','宮崎県','西臼杵郡高千穂町','宮崎県西臼杵郡高千穂町大字三田井713',32.710028,131.315583,null,null,null,'くしふる峰を神体とする高千穂の古社。天孫降臨の地と伝わる。','https://ja.wikipedia.org/wiki/槵觸神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='ryuzoji-hachimangu' and d.slug in ('hachiman'))
or (t.slug='kushida-gu-kanzaki' and d.slug in ('susanoo','kushinadahime','yamatotakeru'))
or (t.slug='nikita-jinja' and d.slug in ('susanoo'))
or (t.slug='nannyo-jinja' and d.slug in ('izanagi','izanami'))
or (t.slug='kushifuru-jinja' and d.slug in ('ninigi','amenokoyane'))
on conflict do nothing;

-- --- batch 6 (25-27) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kota-jinja','巨田神社','こたじんじゃ','shrine','旧郷社','宮崎県','宮崎市','宮崎県宮崎市佐土原町上田島10732-1',32.057806,131.403722,831,null,null,'室町中期の本殿が国重文。巨田神楽と鴨越しの池で知られる。','https://ja.wikipedia.org/wiki/巨田神社','Wikipedia',true,now()),
('shiratori-jinja-ebino','白鳥神社','しらとりじんじゃ','shrine','旧県社','宮崎県','えびの市','宮崎県えびの市大字末永1479',31.978972,130.827333,959,null,null,'日本武尊を祀る霧島山中の古社。島津氏の崇敬を受けた。','https://ja.wikipedia.org/wiki/白鳥神社_(えびの市)','Wikipedia',true,now()),
('sogenji-naha','崇元寺','そうげんじ','temple','臨済宗','沖縄県','那覇市','沖縄県那覇市泊',26.220333,127.690583,1527,'釈迦如来',null,'琉球国王の菩提寺で歴代国王の位牌を安置した。石門が国重文として現存。','https://ja.wikipedia.org/wiki/崇元寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kota-jinja' and d.slug in ('hachiman','jingu_kogo','sumiyoshi'))
or (t.slug='shiratori-jinja-ebino' and d.slug in ('yamatotakeru'))
or (t.slug='sogenji-naha' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ① 追加神仏（batch7-8 用）
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('chikushi_no_kami','筑紫神','つくしのかみ','kami','国津神','{}','社伝','筑紫国の国魂神。筑紫神社の主祭神。','https://ja.wikipedia.org/wiki/筑紫神社','Wikipedia',true,now()),
('tamayorihime','玉依姫命','たまよりひめのみこと','kami','国津神','{}','記紀','海神の娘で神武天皇の母。豊玉姫の妹。','https://ja.wikipedia.org/wiki/タマヨリビメ_(日向神話)','Wikipedia',true,now()),
('chuai_tenno','仲哀天皇','ちゅうあいてんのう','kami','人神','{}','記紀','第14代天皇。神功皇后の夫、応神天皇の父。','https://ja.wikipedia.org/wiki/仲哀天皇','Wikipedia',true,now()),
('ameno_oshihomimi','天忍穂耳命','あめのおしほみみのみこと','kami','天津神','{}','記紀','天照大神の子で瓊瓊杵尊の父。','https://ja.wikipedia.org/wiki/アメノオシホミミ','Wikipedia',true,now()),
('takeuchi_sukune','武内宿禰','たけうちのすくね','kami','人神','{}','記紀','五代の天皇に仕えたと伝わる長寿の忠臣。','https://ja.wikipedia.org/wiki/武内宿禰','Wikipedia',true,now()),
('shiga_okami','志賀大神','しかのおおかみ','kami','綿津見','{}','記紀','綿津見三神。海上守護の神。志賀海神社の祭神。','https://ja.wikipedia.org/wiki/ワタツミ','Wikipedia',true,now()),
('tojiwake','十城別王','とおきわけのみこ','kami','人神','{}','記紀','日本武尊の子と伝わる。志々伎神社の祭神。','https://ja.wikipedia.org/wiki/志々伎神社','Wikipedia',true,now()),
('sai_on','蔡温','さいおん','kami','人神','{}','史伝','琉球王国の政治家。農業振興など国の繁栄に尽くした。','https://ja.wikipedia.org/wiki/蔡温','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='chikushi_no_kami' and g.slug in ('suisan_noko','yakubarai','kaiun'))
or (d.slug='tamayorihime' and g.slug in ('anzan','kosodate','enmusubi'))
or (d.slug='chuai_tenno' and g.slug in ('kaiun','shobu','kanai_anzen'))
or (d.slug='ameno_oshihomimi' and g.slug in ('shigoto','kaiun','shusse'))
or (d.slug='takeuchi_sukune' and g.slug in ('choju','shusse','shigoto'))
or (d.slug='shiga_okami' and g.slug in ('kaijo_anzen','suisan_noko','tabi_anzen'))
or (d.slug='tojiwake' and g.slug in ('shobu','kaiun','yakubarai'))
or (d.slug='sai_on' and g.slug in ('suisan_noko','shobai','kaiun'))
on conflict do nothing;

-- --- batch 7 (28-32) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('chikushi-jinja','筑紫神社','ちくしじんじゃ','shrine','名神大社・旧県社','福岡県','筑紫野市','福岡県筑紫野市原田2550',33.457000,130.542889,null,null,null,'筑紫国の国魂を祀る名神大社。粥卜祭で知られる。','https://ja.wikipedia.org/wiki/筑紫神社','Wikipedia',true,now()),
('takasu-jinja','高祖神社','たかすじんじゃ','shrine','旧県社','福岡県','糸島市','福岡県糸島市高祖1578',33.544775,130.260469,null,null,null,'本殿が国重文。高祖神楽で知られる怡土の古社。','https://ja.wikipedia.org/wiki/高祖神社','Wikipedia',true,now()),
('amanotanagao-jinja','天手長男神社','あまのたながおじんじゃ','shrine','式内社（論社）・旧県社','長崎県','壱岐市','長崎県壱岐市郷ノ浦町田中触730',33.764139,129.702500,811,null,null,'壱岐国一宮の論社。','https://ja.wikipedia.org/wiki/天手長男神社','Wikipedia',true,now()),
('shomogu','聖母宮','しょうもぐう','shrine','旧県社','長崎県','壱岐市','長崎県壱岐市勝本町勝本浦554-2',33.855111,129.690889,717,null,null,'神功皇后の行宮跡に建つと伝わる壱岐の古社。勝負・安産の信仰を集める。','https://ja.wikipedia.org/wiki/聖母宮','Wikipedia',true,now()),
('orihata-jinja','織幡神社','おりはたじんじゃ','shrine','名神大社・旧県社','福岡県','宗像市','福岡県宗像市鐘崎224',33.887792,130.525569,null,null,null,'宗像五社の一。鐘崎の岬に鎮座する名神大社。','https://ja.wikipedia.org/wiki/織幡神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='chikushi-jinja' and d.slug in ('chikushi_no_kami'))
or (t.slug='takasu-jinja' and d.slug in ('hikohohodemi','tamayorihime','jingu_kogo'))
or (t.slug='amanotanagao-jinja' and d.slug in ('ameno_oshihomimi'))
or (t.slug='shomogu' and d.slug in ('jingu_kogo','chuai_tenno','sumiyoshi'))
or (t.slug='orihata-jinja' and d.slug in ('takeuchi_sukune','sumiyoshi','shiga_okami'))
on conflict do nothing;

-- --- batch 8 (33-35) ---
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('daibu-hachimangu','大分八幡宮','だいぶはちまんぐう','shrine','旧県社','福岡県','飯塚市','福岡県飯塚市大分1272',33.584440,130.625560,726,null,'http://www.daibu-hachiman.com/','筥崎宮の元宮と伝わる八幡宮。神功皇后ゆかりの社。','https://ja.wikipedia.org/wiki/大分八幡宮','Wikipedia',true,now()),
('shijiki-jinja','志々伎神社','しじきじんじゃ','shrine','式内社・旧県社','長崎県','平戸市','長崎県平戸市野子町251',33.178931,129.369042,null,null,null,'十城別王を祀る平戸の古社。相撲の原型とされる神事で知られる。','https://ja.wikipedia.org/wiki/志々伎神社','Wikipedia',true,now()),
('yomochi-jinja','世持神社','よもちじんじゃ','shrine','旧郷社','沖縄県','那覇市','沖縄県那覇市奥武山町',26.220528,127.671028,1937,null,null,'蔡温・野国総管・儀間真常の琉球の三恩人を祀る。','https://ja.wikipedia.org/wiki/世持神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='daibu-hachimangu' and d.slug in ('hachiman','jingu_kogo','tamayorihime'))
or (t.slug='shijiki-jinja' and d.slug in ('tojiwake'))
or (t.slug='yomochi-jinja' and d.slug in ('sai_on'))
on conflict do nothing;
