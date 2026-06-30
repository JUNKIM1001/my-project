# 御朱印ナビ（仮称）— 要件定義 / データ辞書

> Phase 0 成果物 — **🔍 レビュー①** 対象ドキュメント
> このドキュメントが承認されたら Phase 1（Supabase基盤＋データ投入）に進みます。

## 1. プロダクト概要

「願い事」または「現在地・目的地」から、最適な**神様／仏様**と、それを祀る**神社・お寺**が
見つかる情報提供アプリ。iOS（SwiftUI）ネイティブ、データは Supabase。

### 中核となる体験（ユースケース）
1. **願い事から探す**: 「縁結びがしたい」→ 縁結びを司る神仏 → それを祀る近くの神社一覧
2. **場所から探す**: 現在地／目的地周辺の社寺を地図・距離順で発見し、ご利益で絞り込み
3. **学ぶ・推しを見つける**: 神仏図鑑で由来やご利益を知り、「好きな神社／神様」に出会う

---

## 2. ご利益カテゴリ（確定リスト — 完全網羅対象）

`goriyaku` マスタ。`slug` は英数字キー、`name` は表示名。`icon` は SF Symbols 名（仮）。

| # | slug | 表示名 | 代表的な願い | icon(仮) |
|---|------|--------|--------------|----------|
| 1 | enmusubi | 縁結び | 良縁・人間関係 | heart.circle |
| 2 | renai | 恋愛成就 | 恋の成就・復縁 | heart.fill |
| 3 | anzan | 安産祈願 | 安産・母子健康 | figure.and.child.holdinghands |
| 4 | kosodate | 子宝・子育て | 子授け・育児 | figure.2.and.child.holdinghands |
| 5 | kotsu_anzen | 交通安全 | 事故防止・旅の安全 | car.fill |
| 6 | yakubarai | 厄除け・厄払い | 厄年・災難除け | shield.lefthalf.filled |
| 7 | byoki_heyu | 病気平癒・健康 | 治癒・無病息災 | cross.case.fill |
| 8 | ekibyo | 疫病退散 | 感染症除け | allergens |
| 9 | gakugyo | 学業成就・合格 | 受験・学問 | graduationcap.fill |
| 10 | shobai | 商売繁盛 | 商売・事業繁栄 | yensign.circle.fill |
| 11 | kinun | 金運上昇 | 財運・蓄財 | banknote.fill |
| 12 | shobu | 勝負運・必勝 | 試合・勝負事 | flag.checkered |
| 13 | shusse | 出世開運 | 昇進・運気上昇 | arrow.up.forward.circle.fill |
| 14 | kanai_anzen | 家内安全 | 家族の安全 | house.fill |
| 15 | shigoto | 仕事・就職 | 就職・転職 | briefcase.fill |
| 16 | geino | 芸能・技芸上達 | 芸事・音楽・上達 | music.note |
| 17 | gakumon | 学問・知恵 | 知恵・学識 | book.fill |
| 18 | kaiun | 開運招福 | 総合運・福徳 | sparkles |
| 19 | majo_kekkai | 魔除け・方位除け | 邪気・方位 | hexagon.fill |
| 20 | suisan_noko | 五穀豊穣・豊漁 | 農業・漁業 | leaf.fill |
| 21 | mizu_amagoi | 水・雨乞い・治水 | 水利・防災 | drop.fill |
| 22 | kaijo_anzen | 海上安全 | 航海・漁の安全 | ferry.fill |
| 23 | bochu | 武運・武道 | 武術・スポーツ | figure.martial.arts |
| 24 | enkiri | 縁切り | 悪縁切り | scissors |
| 25 | choju | 長寿・延命 | 健康長寿 | hourglass |
| 26 | anchin | 安鎮・国家安泰 | 鎮護・平安 | building.columns.fill |
| 27 | bigan | 美容・美願 | 美容・若返り | sparkle |
| 28 | petto | ペット守護 | 動物・ペット | pawprint.fill |
| 29 | jouju | 心願成就 | 願い全般 | star.circle.fill |
| 30 | tabi_anzen | 旅行安全 | 旅・道中安全 | airplane |

> ※ MVPでは 1〜18 を主軸に運用、19〜30 は該当神仏が揃い次第有効化。確定後 `goriyaku` に投入。

---

## 3. 神仏（deity）整備方針

神様（kami）と仏様（buddha）を統合テーブル `deity` で管理。`kind` で区別。

### 3.1 神様（kami）— 系統別に約100〜150柱（実質網羅）
| 系統(category) | 代表例 |
|---|---|
| 天津神 | 天照大神, 天御中主神, 高皇産霊神, 思兼神, 天手力男神, 邇邇芸命 |
| 国津神 | 大国主神, 少彦名神, 大物主神, 事代主神, 建御名方神 |
| 三貴子・記紀神 | 須佐之男命, 月読命, 伊邪那岐, 伊邪那美 |
| 宗像・水神 | 宗像三女神(市杵島姫), 綿津見神, 瀬織津姫 |
| 武神・八幡 | 八幡神(応神天皇), 武甕槌神, 経津主神, 神功皇后 |
| 学問・天神 | 菅原道真(天満宮) |
| 稲荷・農耕 | 宇迦之御魂神(稲荷), 保食神, 大年神 |
| 火・鍛冶・道 | 火之迦具土神, 猿田彦神, 天宇受売命 |
| 山・木・花 | 木花咲耶姫, 石長比売, 大山祇神 |
| 七福神 | 恵比寿, 大黒天, 毘沙門天, 弁財天, 福禄寿, 寿老人, 布袋 |
| 御霊・その他 | 崇徳天皇, 平将門, 日本武尊 ほか |

### 3.2 仏様（buddha）— 部類別に約40〜60尊（実質網羅）
| 部類(category) | 代表例 |
|---|---|
| 如来 | 釈迦如来, 阿弥陀如来, 薬師如来, 大日如来, 毘盧遮那仏 |
| 菩薩 | 観音菩薩(聖/千手/十一面/馬頭…), 地蔵菩薩, 文殊菩薩, 普賢菩薩, 弥勒菩薩, 虚空蔵菩薩, 勢至菩薩 |
| 明王 | 不動明王, 愛染明王, 降三世明王, 軍荼利明王, 孔雀明王 |
| 天部 | 毘沙門天, 弁財天, 大黒天, 吉祥天, 帝釈天, 梵天, 韋駄天, 歓喜天, 鬼子母神 |

> 各神仏に **司るご利益（`deity_goriyaku`）** を紐付ける（例: 菅原道真→学業成就/学問、宇迦之御魂神→商売繁盛/五穀豊穣）。

---

## 4. 社寺（temple_shrine）整備方針

- MVP: 全国の**代表的な社寺 300〜500件**を厳選収録（緯度経度・御祭神/本尊・ご利益付き）。
- 拡張: OpenStreetMap / 国土地理院 / Wikipedia 等のオープンデータ取込スクリプトで段階的に網羅へ。
- 系統(`sect`)例: 神社=稲荷系/八幡系/天神系/出雲系/伊勢系/諏訪系… 寺=天台宗/真言宗/浄土宗/浄土真宗/禅宗(臨済・曹洞)/日蓮宗/華厳宗…

---

## 5. データモデル（テーブル定義）

```
goriyaku(id, slug↑uniq, name, name_kana, icon, description, sort_order)
deity(id, slug↑uniq, name, name_kana, kind['kami'|'buddha'], category,
      aliases[], mythology_source, description, image_url)
temple_shrine(id, slug↑uniq, name, name_kana, type['shrine'|'temple'], sect,
      prefecture, city, address, lat, lng, founded_year, honzon_note,
      website, phone, description, image_url)

deity_goriyaku(deity_id→deity, goriyaku_id→goriyaku)                  -- 神仏が司るご利益
temple_shrine_deity(temple_shrine_id→ts, deity_id→deity, role['main'|'sub'])  -- 御祭神/本尊
temple_shrine_goriyaku(temple_shrine_id→ts, goriyaku_id→goriyaku)     -- 社寺のご利益(導出＋上書き)
favorite(user_id, temple_shrine_id→ts)                               -- お気に入り
```

- 近隣検索: PostGIS もしくは `cube`+`earthdistance` 拡張で RPC `nearby_temples(lat, lng, radius_km, ...)`。
- RLS: マスタ系は全公開read、`favorite` は本人のみ read/write（匿名Auth）。

---

## 6. 画面遷移（情報設計）

```
[ホーム]
 ├─「願い事から探す」→ [ご利益選択] → [該当神仏一覧] → [社寺一覧(距離順)] → [社寺詳細]
 ├─「現在地から探す」→ [地図/近隣リスト] --絞込(神社/寺・ご利益)--> [社寺詳細]
 ├─「神仏図鑑」      → [神仏一覧(神/仏タブ・ご利益フィルタ)] → [神仏詳細] → [祀る社寺] → [社寺詳細]
 └─「お気に入り」    → [保存社寺一覧] → [社寺詳細]

[社寺詳細]: 名称/写真/御祭神・本尊/ご利益タグ/地図/ルート案内(Apple Maps)/お気に入り登録/公式サイト
[神仏詳細]: 名称/系統/由来/司るご利益/祀る代表社寺
```

---

## 7. 非機能・前提
- iOS 17+ / SwiftUI / MapKit / CoreLocation / supabase-swift
- オフライン: マスタは将来ローカルキャッシュ検討（MVPはオンライン前提）
- 画像は初期プレースホルダ運用（著作権配慮）
- 出典・正確性: 由来やご利益は一般に流布する伝承ベース。出典メモを `description` に併記

---

## 🔍 レビュー① チェック項目
- [ ] ご利益カテゴリ（30種）の過不足・名称
- [ ] 神様／仏様の整備範囲（系統・代表例）
- [ ] データモデル（テーブル・関連）の妥当性
- [ ] 画面遷移・主要ユースケース
- [ ] アプリ名称（「御朱印ナビ」は仮。ご希望があれば変更）
