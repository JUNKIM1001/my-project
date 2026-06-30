-- 神仏シード（パイロット14柱/尊）— 出典: 日本語Wikipedia 各神仏記事
-- 実在の信仰対象。司るご利益は各社寺の検証データおよび一般的信仰に基づく。

insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('amaterasu','天照大御神','あまてらすおおみかみ','kami','天津神','{"天照坐皇大御神","アマテラス"}','記紀','高天原を治める太陽神。皇室の祖神。伊勢神宮内宮の御祭神。','https://ja.wikipedia.org/wiki/アマテラス','Wikipedia',true,now()),
('okuninushi','大国主大神','おおくにぬしのおおかみ','kami','国津神','{"大己貴命","大物主"}','記紀','国造りの神。縁結びの神として信仰される。出雲大社の御祭神。','https://ja.wikipedia.org/wiki/大国主','Wikipedia',true,now()),
('ukanomitama','宇迦之御魂大神','うかのみたまのおおかみ','kami','稲荷神','{"稲荷大神","お稲荷さん"}','記紀','五穀・食物を司る稲荷神。伏見稲荷大社の主祭神。','https://ja.wikipedia.org/wiki/ウカノミタマ','Wikipedia',true,now()),
('michizane','菅原道真','すがわらのみちざね','kami','天神・御霊','{"天満大自在天神","天神様"}','史実','平安時代の学者・政治家。学問の神「天神」として全国の天満宮に祀られる。','https://ja.wikipedia.org/wiki/菅原道真','Wikipedia',true,now()),
('hachiman','八幡神（応神天皇）','はちまんしん','kami','八幡神','{"誉田別命","応神天皇"}','記紀・史実','武運の神。全国の八幡宮の御祭神で、武家の守護神とされる。','https://ja.wikipedia.org/wiki/応神天皇','Wikipedia',true,now()),
('jingu_kogo','神功皇后','じんぐうこうごう','kami','記紀神','{"息長足姫尊"}','記紀','応神天皇の母。安産・武運の神として信仰される。','https://ja.wikipedia.org/wiki/神功皇后','Wikipedia',true,now()),
('ichikishima','市杵島姫命','いちきしまひめのみこと','kami','宗像三女神','{"宗像三女神","弁才天習合"}','記紀','宗像三女神の一柱。海上安全・芸能・財福の神。厳島神社の御祭神。','https://ja.wikipedia.org/wiki/市杵島姫命','Wikipedia',true,now()),
('sumiyoshi','住吉三神','すみよしさんじん','kami','記紀神','{"底筒男命","中筒男命","表筒男命"}','記紀','海と航海を司る三柱の神。住吉大社の御祭神。','https://ja.wikipedia.org/wiki/住吉三神','Wikipedia',true,now()),
('ieyasu','徳川家康（東照大権現）','とくがわいえやす','kami','御霊','{"東照大権現"}','史実','江戸幕府初代将軍。死後「東照大権現」として日光東照宮に神格化して祀られる。','https://ja.wikipedia.org/wiki/徳川家康','Wikipedia',true,now()),
('meiji_tenno','明治天皇','めいじてんのう','kami','御霊','{}','史実','日本の第122代天皇。明治神宮の御祭神。','https://ja.wikipedia.org/wiki/明治天皇','Wikipedia',true,now()),
('shoken','昭憲皇太后','しょうけんこうたいごう','kami','御霊','{}','史実','明治天皇の皇后。明治神宮に夫妻で祀られ、縁結びの信仰につながる。','https://ja.wikipedia.org/wiki/昭憲皇太后','Wikipedia',true,now()),
('fudo_myoo','不動明王','ふどうみょうおう','buddha','明王','{"大聖不動明王","お不動さま"}','仏教','五大明王の中心。煩悩を断ち厄災を払う。成田山新勝寺の本尊。','https://ja.wikipedia.org/wiki/不動明王','Wikipedia',true,now()),
('sho_kannon','聖観音菩薩','しょうかんのんぼさつ','buddha','菩薩','{"聖観世音菩薩","観音さま"}','仏教','慈悲をもって衆生を救う観音菩薩の基本形。浅草寺の本尊。','https://ja.wikipedia.org/wiki/観音菩薩','Wikipedia',true,now()),
('kobo_daishi','弘法大師（空海）','こうぼうだいし','buddha','高僧','{"空海","お大師さま"}','史実','真言宗の開祖。厄除け大師として川崎大師などで篤く信仰される。','https://ja.wikipedia.org/wiki/空海','Wikipedia',true,now())
on conflict (slug) do nothing;

-- 神仏が司るご利益（deity_goriyaku）
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
  (d.slug='amaterasu'   and g.slug in ('kaiun','anchin','suisan_noko','jouju'))
 or (d.slug='okuninushi'  and g.slug in ('enmusubi','renai','shobai','byoki_heyu','kanai_anzen'))
 or (d.slug='ukanomitama' and g.slug in ('shobai','kinun','suisan_noko','kanai_anzen','kotsu_anzen','geino'))
 or (d.slug='michizane'   and g.slug in ('gakugyo','gakumon','geino','jouju'))
 or (d.slug='hachiman'    and g.slug in ('shobu','shusse','bochu','kaiun','yakubarai'))
 or (d.slug='jingu_kogo'  and g.slug in ('anzan','kosodate','bochu','kaiun'))
 or (d.slug='ichikishima' and g.slug in ('kaijo_anzen','geino','kinun','bigan','jouju'))
 or (d.slug='sumiyoshi'   and g.slug in ('kaijo_anzen','kotsu_anzen','tabi_anzen','yakubarai'))
 or (d.slug='ieyasu'      and g.slug in ('shusse','shobu','anchin','kaiun'))
 or (d.slug='meiji_tenno' and g.slug in ('kaiun','kanai_anzen','gakugyo','jouju'))
 or (d.slug='shoken'      and g.slug in ('enmusubi','kanai_anzen','anzan'))
 or (d.slug='fudo_myoo'   and g.slug in ('yakubarai','kotsu_anzen','majo_kekkai','shobu','byoki_heyu'))
 or (d.slug='sho_kannon'  and g.slug in ('kaiun','byoki_heyu','jouju','enmusubi','anzan'))
 or (d.slug='kobo_daishi' and g.slug in ('yakubarai','kaiun','gakumon','kotsu_anzen'))
on conflict do nothing;
