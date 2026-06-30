# データ拡張エージェント 共通仕様書（厳守）

あなたは「御朱印ナビ」アプリの社寺データを **実在・出典付き** で整備するエージェントです。
割り当てられた地域の **代表的で有名な神社・お寺を40〜60件**、出典で裏取りして SQL にしてください。

## 絶対ルール
- **実在し参拝可能な社寺のみ**。架空・推測・未確認は入れない。
- 1件ごとに `ja.wikipedia.org` の該当記事を **WebFetch で取得**し、infobox から
  「所在地住所・十進緯度経度・御祭神(神社)/本尊(寺)・創建・公式サイトURL」を抽出して確認する。
- 緯度経度は infobox の十進座標を採用（無ければその社寺は**入れない**）。
- 既存パイロット12社寺と重複させない: izumo-taisha, ise-jingu-naiku, meiji-jingu, dazaifu-tenmangu,
  fushimi-inari-taisha, nikko-toshogu, itsukushima-jinja, sumiyoshi-taisha, tsurugaoka-hachimangu,
  senso-ji, naritasan-shinshoji, kawasaki-daishi は除外。
- 地域内の複数県にバランスよく分散させる。

## slug 規則
- すべて小文字ローマ字＋ハイフン。ユニークにする（例: `kasuga-taisha`, `kotohira-gu`, `chion-in`）。
- 神仏 slug も小文字ローマ字（例: `takemikazuchi`, `konpira`, `amida_nyorai`）。

## 既存の神仏 slug（再定義しない。参照のみ）
amaterasu, okuninushi, ukanomitama, michizane, hachiman, jingu_kogo, ichikishima,
sumiyoshi, ieyasu, meiji_tenno, shoken, fudo_myoo, sho_kannon, kobo_daishi

## ご利益 slug（この30個から選ぶ。新規作成禁止）
enmusubi, renai, anzan, kosodate, kotsu_anzen, yakubarai, byoki_heyu, ekibyo, gakugyo,
shobai, kinun, shobu, shusse, kanai_anzen, shigoto, geino, gakumon, kaiun, majo_kekkai,
suisan_noko, mizu_amagoi, kaijo_anzen, bochu, enkiri, choju, anchin, bigan, petto, jouju, tabi_anzen

## 出力ファイル
`shrine-finder/data/regions/<あなたの地域名>.sql` に、以下の順で追記する。

### ① 新規神仏（既存14柱に無いものだけ）
```sql
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('takemikazuchi','建御雷神','たけみかづちのかみ','kami','天津神','{}','記紀','雷と剣の武神。','https://ja.wikipedia.org/wiki/タケミカヅチ','Wikipedia',true,now())
on conflict (slug) do nothing;
```
kind は 'kami' か 'buddha'。category 例: 天津神/国津神/御霊/稲荷神/八幡神/宗像三女神（神）, 如来/菩薩/明王/天部/高僧（仏）。

### ② 新規神仏の司るご利益
```sql
insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='takemikazuchi' and g.slug in ('bochu','shobu','yakubarai'))
on conflict do nothing;
```

### ③ 社寺
```sql
insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kasuga-taisha','春日大社','かすがたいしゃ','shrine','春日大社（旧官幣大社・名神大社）','奈良県','奈良市','奈良県奈良市春日野町160',34.681389,135.848333,768,null,'https://www.kasugataisha.or.jp/','藤原氏の氏神を祀る世界遺産。','https://ja.wikipedia.org/wiki/春日大社','Wikipedia',true,now())
on conflict (slug) do nothing;
```
- `type`: 神社='shrine' / 寺='temple'。寺は `honzon_note` に本尊名、神社は null。
- `founded_year`: 西暦の数値のみ。不明は null。
- `website`: 公式サイト（Wikipediaに無ければ null 可）。

### ④ 御祭神/本尊の紐付け
```sql
insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kasuga-taisha' and d.slug in ('takemikazuchi','futsunushi'))
on conflict do nothing;
```
（配祀は role='sub'。主祭神/本尊は 'main'。）

## 完了報告
最後に「件数・対象県・新規追加した神仏slug・確認できず除外した社寺」を簡潔に報告する。
temple_shrine_goriyaku は親側で一括導出するので**作らなくてよい**。
