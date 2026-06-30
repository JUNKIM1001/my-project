-- 御朱印ナビ データ拡張: 北海道・東北
-- 対象県: 北海道, 青森, 岩手, 宮城, 秋田, 山形, 福島
-- 出典: ja.wikipedia.org のinfobox（十進座標を採用）。座標が無いものは除外。
-- 既存 _have_hokkaido-tohoku.txt 収録分とは重複させていない。

-- ============================================================
-- ① 新規神仏（既存14柱に無いもの）
-- ============================================================
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('omononushi','大物主神','おおものぬしのかみ','kami','国津神','{}','記紀','三輪山の神。国造り・農業・酒造・航海の守護神。','https://ja.wikipedia.org/wiki/オオモノヌシ','Wikipedia',true,now()),
('kotoshironushi','事代主神','ことしろぬしのかみ','kami','国津神','{}','記紀','託宣・漁業・商売の神。えびす神とも習合。','https://ja.wikipedia.org/wiki/コトシロヌシ','Wikipedia',true,now()),
('susanoo','須佐之男命','すさのおのみこと','kami','天津神','{}','記紀','八岐大蛇退治で知られる嵐と厄除けの神。','https://ja.wikipedia.org/wiki/スサノオ','Wikipedia',true,now()),
('yamatotakeru','日本武尊','やまとたけるのみこと','kami','天津神','{}','記紀','東征伝承で知られる英雄神。武運・開拓の神。','https://ja.wikipedia.org/wiki/ヤマトタケル','Wikipedia',true,now()),
('shakyamuni','釈迦如来','しゃかにょらい','buddha','如来','{}','仏教','仏教の開祖を仏格化した如来。','https://ja.wikipedia.org/wiki/釈迦如来','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ============================================================
-- ② 新規神仏の司るご利益
-- ============================================================
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='omononushi' and g.slug in ('kaiun','shobai','kaijo_anzen','byoki_heyu'))
or (d.slug='kotoshironushi' and g.slug in ('shobai','suisan_noko','kinun'))
or (d.slug='susanoo' and g.slug in ('yakubarai','ekibyo','enmusubi'))
or (d.slug='yamatotakeru' and g.slug in ('shobu','kaiun','tabi_anzen'))
or (d.slug='shakyamuni' and g.slug in ('byoki_heyu','kaiun','jouju'))
on conflict do nothing;

-- ============================================================
-- ③ 社寺  /  ④ 御祭神・本尊の紐付け
-- ============================================================

-- ---- 北海道 ----
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nemuro-kotohira-jinja','金刀比羅神社','ことひらじんじゃ','shrine','旧県社','北海道','根室市','北海道根室市琴平町1-4',43.343789,145.587472,1806,null,'https://www.nemuro-kotohira.com/','高田屋嘉兵衛が創建した道東屈指の古社。北方領土の旧鎮守の御霊も奉斎。','https://ja.wikipedia.org/wiki/金刀比羅神社_(根室市)','Wikipedia',true,now()),
('tottori-jinja-kushiro','鳥取神社','とっとりじんじゃ','shrine','旧村社','北海道','釧路市','北海道釧路市鳥取大通4-2-18',43.012639,144.352847,1891,null,'http://www.hokkaidojinjacho.jp/data/15/15003.html','鳥取県からの士族移住者が開いた鳥取村の鎮守。出雲大社より分霊。','https://ja.wikipedia.org/wiki/鳥取神社_(釧路市)','Wikipedia',true,now()),
('kokutai-ji-akkeshi','国泰寺','こくたいじ','temple','臨済宗南禅寺派','北海道','厚岸郡厚岸町','北海道厚岸郡厚岸町湾月町1',43.032778,144.839167,1804,'釈迦如来',null,'江戸幕府が蝦夷地に建てた蝦夷三官寺の一つ。国指定史跡。','https://ja.wikipedia.org/wiki/国泰寺_(北海道厚岸町)','Wikipedia',true,now()),
('ryutoku-ji-otaru','龍徳寺','りゅうとくじ','temple','曹洞宗','北海道','小樽市','北海道小樽市真栄1-3-8',43.180361,141.009278,1857,'釈迦如来',null,'小樽最古の本堂を持つ古刹。日本最大級の一木造木魚で知られる。','https://ja.wikipedia.org/wiki/龍徳寺_(小樽市)','Wikipedia',true,now()),
('yakumo-jinja-hokkaido','八雲神社','やくもじんじゃ','shrine','旧郷社','北海道','二海郡八雲町','北海道二海郡八雲町宮園町56',42.252167,140.262167,1879,null,null,'尾張藩士の入植により創建。熱田神宮唯一の分社として知られる。','https://ja.wikipedia.org/wiki/八雲神社_(八雲町)','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nemuro-kotohira-jinja' and d.slug in ('omononushi','kotoshironushi','ukanomitama'))
or (t.slug='tottori-jinja-kushiro' and d.slug in ('okuninushi'))
or (t.slug='kokutai-ji-akkeshi' and d.slug in ('shakyamuni'))
or (t.slug='ryutoku-ji-otaru' and d.slug in ('shakyamuni'))
or (t.slug='yakumo-jinja-hokkaido' and d.slug in ('amaterasu','susanoo','yamatotakeru'))
on conflict do nothing;
