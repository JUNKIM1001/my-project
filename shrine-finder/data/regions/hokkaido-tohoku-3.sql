-- ============================================================
-- 御朱印ナビ 地域データ: 北海道・東北（3巡目／観光著名社寺）
-- 対象県: 北海道, 青森, 岩手, 宮城, 秋田, 山形, 福島
-- 全件 ja.wikipedia.org の infobox を WebFetch で裏取り（十進緯度経度あり）
-- 1巡目(hokkaido-tohoku.sql)・2巡目(hokkaido-tohoku-2.sql)・既存社寺とは重複させない
-- ============================================================

-- ───────────────────────── ① 新規神仏 ─────────────────────────
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('usagi_myojin','卯子酉明神','うねどりみょうじん','kami','御霊','{卯子酉大明神}','民間信仰','遠野の卯子酉様の祭神。縁結びの神として信仰される。','https://ja.wikipedia.org/wiki/卯子酉様','Wikipedia',true,now()),
('godai_myoo','五大明王','ごだいみょうおう','buddha','明王','{五大尊}','仏教','不動・降三世・軍荼利・大威徳・金剛夜叉の五明王。松島五大堂の本尊。','https://ja.wikipedia.org/wiki/五大明王','Wikipedia',true,now()),
('kashima_amatariwake','鹿島天足別命','かしまあまたりわけのみこと','kami','天津神','{}','記紀','武甕槌命の御子神。鹿島御児神社の祭神。石巻の地名起源に関わる。','https://ja.wikipedia.org/wiki/鹿島御児神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ② 新規神仏の司るご利益 ─────────────────────────
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='usagi_myojin'         and g.slug in ('enmusubi','renai','jouju'))
or (d.slug='godai_myoo'           and g.slug in ('yakubarai','majo_kekkai','kaiun'))
or (d.slug='kashima_amatariwake'  and g.slug in ('shigoto','kaijo_anzen','ekibyo'))
on conflict do nothing;

-- ───────────────────────── ③ 社寺 ─────────────────────────
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('yukura-jinja','湯倉神社','ゆくらじんじゃ','shrine','旧郷社','北海道','函館市','北海道函館市湯川町2丁目28-1',41.782111,140.791000,1617,null,'https://www.yukurajinja.or.jp/','函館・湯の川温泉の鎮守。少彦名神らを祀る。','https://ja.wikipedia.org/wiki/湯倉神社','Wikipedia',true,now()),
('kameda-hachimangu','亀田八幡宮','かめだはちまんぐう','shrine','旧県社','北海道','函館市','北海道函館市八幡町3-2',41.791556,140.736556,1390,null,null,'函館・亀田地域の総鎮守。箱館戦争降伏の地としても知られる。','https://ja.wikipedia.org/wiki/亀田八幡宮','Wikipedia',true,now()),
('kakushuji','革秀寺','かくしゅうじ','temple','曹洞宗','青森県','弘前市','青森県弘前市藤代1丁目4-1',40.612722,140.450111,1610,'釈迦如来','http://www.kakusyuji.or.jp/','弘前藩祖津軽為信の菩提寺。本堂・霊屋は重要文化財。','https://ja.wikipedia.org/wiki/革秀寺','Wikipedia',true,now()),
('unedori-sama','卯子酉様','うねどりさま','shrine','単立','岩手県','遠野市','岩手県遠野市遠野町2地割',39.325250,141.513722,null,null,null,'遠野の縁結びの神。左手だけで赤布を結べば縁が結ばれるとされる。','https://ja.wikipedia.org/wiki/卯子酉様','Wikipedia',true,now()),
('matsushima-godaido','松島五大堂','まつしまごだいどう','temple','臨済宗妙心寺派','宮城県','松島町','宮城県宮城郡松島町松島字町内111',38.369719,141.064211,807,'五大明王','http://www.zuiganji.or.jp/','瑞巌寺の境外仏堂。現建物は伊達政宗造営で東北最古の桃山建築。重要文化財。','https://ja.wikipedia.org/wiki/五大堂','Wikipedia',true,now()),
('kashima-miko-jinja','鹿島御児神社','かしまみこじんじゃ','shrine','旧県社','宮城県','石巻市','宮城県石巻市日和が丘2丁目1-10',38.423972,141.307306,null,null,'https://kashimamiko.org/','石巻・日和山に鎮座。武甕槌命とその御子鹿島天足別命を祀る。','https://ja.wikipedia.org/wiki/鹿島御児神社','Wikipedia',true,now()),
('tsuriishi-jinja','釣石神社','つりいしじんじゃ','shrine','単立','宮城県','石巻市','宮城県石巻市北上町十三浜字追波305',38.569586,141.434186,1618,null,null,'落ちそうで落ちない巨石で知られ、合格祈願の神社として信仰される。','https://ja.wikipedia.org/wiki/釣石神社','Wikipedia',true,now())
on conflict (slug) do nothing;

-- ───────────────────────── ④ 御祭神/本尊の紐付け ─────────────────────────
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='yukura-jinja'        and d.slug in ('sukunabikona','okuninushi','ukanomitama'))
or (t.slug='kameda-hachimangu'   and d.slug in ('hachiman'))
or (t.slug='kakushuji'           and d.slug in ('shaka_nyorai'))
or (t.slug='unedori-sama'        and d.slug in ('usagi_myojin'))
or (t.slug='matsushima-godaido'  and d.slug in ('godai_myoo'))
or (t.slug='kashima-miko-jinja'  and d.slug in ('takemikazuchi','kashima_amatariwake'))
or (t.slug='tsuriishi-jinja'     and d.slug in ('amenokoyane'))
on conflict do nothing;
