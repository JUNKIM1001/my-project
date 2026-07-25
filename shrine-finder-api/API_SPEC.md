# おまいりナビ Open API 仕様書 v1

お出かけアプリの開発者が「いまいる地域の近くにある神社・お寺」を取得するための、
認証不要・無料の公開API。

- ベースURL（予定）: `https://api.omairi-navi.app/v1`
- 形式: REST / JSON (UTF-8)
- 認証: **不要**（APIキーなし・登録なし）
- レート制限: IP単位（後述）
- データ: 2,086社寺・481神仏・30ご利益（全47都道府県、すべて出典付きで裏取り済み）

---

## 1. 設計方針

### 1.1 プライバシー：位置は「粗く」受け取る

利用者アプリのユーザーの現在地は個人情報になりうる。本APIは
**ピンポイントの座標を受け取らない**ことを原則とする。

| 優先 | 渡し方 | 例 | 粒度 | 備考 |
|---|---|---|---|---|
| **推奨** | 都道府県＋市区町村 | `?pref=京都府&city=宇治市` | 市区町村 | iOS `CLPlacemark.administrativeArea`/`locality`、Android `Geocoder` の値をそのまま渡せる |
| 可 | 粗い緯度経度 | `?lat=34.89&lng=135.81` | 約1km四方 | **小数第2位までに丸めて送る**こと。3位以下はサーバ側で切り捨て、受け取っても保持しない |

- サーバは**受け取った座標を、丸めた形でのみ処理し、アクセスログに残さない**。
- 座標を丸めることで得られる結果は「半径1km程度の誤差を含む近い順」となる。
  徒歩ナビ用途には十分で、個人の追跡には使えない粒度。
- 地域名だけで十分な用途では、座標を一切送らないことを推奨する。

### 1.2 認証：完全オープン＋レート制限

APIキーの発行・管理は利用者にも運営にも負担になるため設けない。
かわりにIP単位のレート制限で乱用を防ぐ。

### 1.3 提供するデータの範囲（ライセンス方針）

本APIが返すのは、**事実データと自作の短い紹介文のみ**。
Wikipedia由来の長文解説（CC BY-SA）は**APIでは配布しない**。
これにより、**利用者側にライセンス継承（share-alike）義務が生じない**。

| 項目 | API提供 | 理由 |
|---|---|---|
| 名称・よみ・種別・宗派・住所・座標 | ✅ | 事実データ（著作権の対象外） |
| 短い紹介文 `summary` | ✅ | おまいりナビの自作テキスト |
| 御祭神/本尊・ご利益・国宝・御朱印・テレビ放映 | ✅ | 事実データ |
| 公式サイト/Wikipediaへのリンク | ✅ | URLのみ |
| **長文解説（歴史・由緒）** | ❌ | Wikipedia由来（CC BY-SA）。詳細ページへのリンクで代替 |
| 写真 | URLとライセンス表記のみ | 画像は各配信元から直接取得。表示時は `image.license`/`image.author` の表示が必要 |

---

## 2. エンドポイント

| メソッド | パス | 用途 |
|---|---|---|
| GET | `/v1/shrines` | 社寺を検索（地域 or 粗い座標から。近い順） |
| GET | `/v1/shrines/{id}` | 社寺1件の詳細 |
| GET | `/v1/areas` | 都道府県・市区町村の一覧と件数（地域選択UI用） |
| GET | `/v1/goriyaku` | ご利益カテゴリ一覧（絞り込みUI用） |
| GET | `/v1/meta` | データ版・件数・ライセンス情報 |

---

### 2.1 `GET /v1/shrines` — 社寺検索

#### パラメータ

| 名前 | 型 | 既定 | 説明 |
|---|---|---|---|
| `pref` | string | — | 都道府県。`京都府` / `京都` どちらでも可 |
| `city` | string | — | 市区町村。`宇治市` / `京都市` / `美郷町` など。ゆるく解決（§3.1） |
| `lat` | number | — | 緯度。**小数第2位に丸めて送る**（-90〜90） |
| `lng` | number | — | 経度。**小数第2位に丸めて送る**（-180〜180） |
| `radius_km` | number | 10 | `lat`/`lng` 指定時の検索半径。最大 50 |
| `type` | enum | — | `shrine`（神社）/ `temple`（寺） |
| `goriyaku` | string | — | ご利益ID。例 `enmusubi`（`/v1/goriyaku` で一覧取得） |
| `goshuin` | boolean | — | `true` で御朱印を確認済みの社寺のみ |
| `national_treasure` | boolean | — | `true` で国宝を有する社寺のみ |
| `tv` | boolean | — | `true` で直近1年にテレビ放映された社寺のみ |
| `q` | string | — | 名称・よみの部分一致 |
| `limit` | integer | 20 | 1〜100 |
| `offset` | integer | 0 | ページング用 |
| `order` | enum | 自動 | `distance` / `name`。座標指定時は既定 `distance`、それ以外は `name` |

- `pref`/`city` と `lat`/`lng` は**併用可**（地域で絞ってから近い順に並べる）。
- どちらも指定がない場合は全国から `order=name` で返す（`limit` 上限あり）。
- `lat` と `lng` は必ず両方指定する（片方だけは 400）。

#### レスポンス例

```
GET /v1/shrines?pref=京都府&city=宇治市&limit=2
```

```json
{
  "meta": {
    "total": 8,
    "limit": 2,
    "offset": 0,
    "order": "name",
    "resolved_area": { "pref": "京都府", "city": "宇治市", "match": "exact" },
    "data_version": "2026-07-25"
  },
  "shrines": [
    {
      "id": "byodoin",
      "name": "朝日山平等院",
      "kana": "あさひさんびょうどういん",
      "type": "temple",
      "sect": "単立（天台宗・浄土宗）",
      "area": { "pref": "京都府", "city": "宇治市" },
      "address": "京都府宇治市宇治蓮華116",
      "location": { "lat": 34.8892, "lng": 135.8077 },
      "summary": "十円硬貨で名高い鳳凰堂を持つ世界遺産。藤原氏の極楽浄土を表す。",
      "enshrined": {
        "role": "本尊",
        "deities": [{ "id": "amida-nyorai", "name": "阿弥陀如来", "kind": "buddha" }]
      },
      "goriyaku": [
        { "id": "byoki_heyu", "name": "病気平癒・健康" },
        { "id": "jouju", "name": "心願成就" }
      ],
      "national_treasure": true,
      "goshuin": true,
      "tv": {
        "date": "2026-06-06",
        "program": "ブラタモリ（NHK総合）「京都・平等院鳳凰堂」",
        "source": "https://www.lmaga.jp/news/2026/06/1063119/"
      },
      "image": {
        "url": "https://upload.wikimedia.org/...",
        "license": "CC BY-SA 4.0",
        "author": "撮影者名"
      },
      "links": {
        "website": "https://www.byodoin.or.jp/",
        "wikipedia": "https://ja.wikipedia.org/wiki/平等院",
        "detail": "https://omairi-navi.vercel.app/shrine/byodoin"
      }
    }
  ],
  "attribution": {
    "text": "神社・お寺データ: おまいりナビ (https://omairi-navi.vercel.app)",
    "required": true
  }
}
```

座標指定時は各社寺に `distance_m`（整数・メートル）が付く。

```
GET /v1/shrines?lat=34.89&lng=135.81&radius_km=5&goshuin=true
```

#### 注意（`tv` フィールド）

`tv` は**放映日から1年以内のもののみ**返す。1年を過ぎると自動的に `null` になる
（データは残るがAPIには出ない）。「最近テレビで紹介された」バッジ表示に使える。

---

### 2.2 `GET /v1/shrines/{id}` — 詳細

`id` は社寺の安定ID（例 `byodoin`）。`/v1/shrines` の `id` をそのまま使う。
レスポンスは検索結果の1件と同じ構造に、`related`（内容が近い社寺の最大8件）を加えたもの。

存在しない `id` は `404`。

---

### 2.3 `GET /v1/areas` — 地域一覧

地域選択UIを作るための一覧。

```json
{
  "meta": { "total_shrines": 2086, "data_version": "2026-07-25" },
  "regions": [
    {
      "name": "近畿",
      "prefectures": [
        { "name": "京都府", "count": 121,
          "cities": [ { "name": "宇治市", "count": 8 }, { "name": "京都市東山区", "count": 15 } ] }
      ]
    }
  ]
}
```

`?pref=京都府` を付けるとその都道府県のみ返す。

---

### 2.4 `GET /v1/goriyaku` — ご利益一覧

```json
{
  "goriyaku": [
    { "id": "kaiun", "name": "開運招福", "count": 1715 },
    { "id": "enmusubi", "name": "縁結び", "count": 729 }
  ]
}
```

---

### 2.5 `GET /v1/meta` — メタ情報

データ版・件数・ライセンス・レート制限の現在値を返す。監視や利用者の実装確認に使う。

---

## 3. 動作の詳細

### 3.1 地域名の解決（ゆるいマッチング）

逆ジオコーディングの結果は端末やOSによって表記が揺れるため、以下の順で解決する。
結果は `meta.resolved_area.match` に `exact` / `prefix` / `contains` / `pref_only` として返す。

> **重要**: データには政令市の「市名のみ」と「市名＋区」が混在する（例: `京都市` 81件と
> `京都市伏見区` 3件が併存）。そのため**前方一致を第一段とし、完全一致はその部分集合として扱う**。
> 完全一致を優先すると、`京都市` の検索で区表記の21件を取りこぼす。

**解決の順序**

1. **前方一致**（完全一致を含む）: `city` で始まる市区町村をすべて集める
   - すべてが入力と完全一致 → `match: "exact"`
   - 区などを含む → `match: "prefix"`
2. **部分一致**: 1で0件のとき、`city` を含むものを集める → `match: "contains"`
3. 見つからなければ都道府県全体 → `match: "pref_only"`

| 入力例 | 解決結果 | match |
|---|---|---|
| `京都府` + `宇治市` | `宇治市` の6件 | `exact` |
| `京都府` + `京都市` | `京都市` ＋ 各区、計102件 | `prefix` |
| `京都府` + `京都市伏見区` | 伏見区の3件 | `exact` |
| `神奈川県` + `横浜市` | 横浜市の12件 | `exact` |
| `秋田県` + `美郷町` | `仙北郡美郷町` の1件 | `contains`（郡名の省略を吸収） |
| `熊本県` + `上益城郡` | 郡内の町をすべて | `prefix`（郡名だけでも郡内をまとめて返す） |
| `大阪府` + 未知の市名 | 大阪府全体の69件 | `pref_only` |
| `京都` | `京都府` | 都道府県名の接尾辞（都/道/府/県）は省略可 |

- `city` が解決できない場合は**都道府県全体の結果を返し**、`match` を `pref_only`、
  `meta.notice` に「市区町村が特定できなかったため都道府県全体を返した」旨を入れる。
  （エラーにはしない。お出かけアプリで結果ゼロになるのを避けるため）
- `pref` が解決できない場合は `400`。

### 3.2 距離の計算

- Haversine式（地球半径 6,371km）。`distance_m` は整数メートル。
- 入力座標は小数第2位に丸めるため、**距離には最大約1kmの誤差**が含まれる。
  この誤差は仕様であり、`meta.location_precision` に `"~1km"` として明示する。

### 3.3 並び順

- `order=distance`: `distance_m` 昇順（座標未指定時は使用不可 → `400`）
- `order=name`: `kana` の昇順（読み仮名の五十音順）

---

## 4. エラー

RFC 9457 (Problem Details) 形式。`Content-Type: application/problem+json`。

```json
{
  "type": "https://api.omairi-navi.app/errors/invalid-parameter",
  "title": "パラメータが不正です",
  "status": 400,
  "detail": "radius_km は 50 以下で指定してください（指定値: 200）",
  "instance": "/v1/shrines"
}
```

| ステータス | 発生条件 |
|---|---|
| `400` | パラメータ不正（範囲外・`lat` のみ指定・未知の `goriyaku` ID・解決できない `pref`） |
| `404` | 指定 `id` の社寺が存在しない |
| `429` | レート制限超過 |
| `500` | サーバ内部エラー |

---

## 5. レート制限

IPアドレス単位のスライディングウィンドウ方式。

| 窓 | 上限 |
|---|---|
| 1分 | 60リクエスト |
| 1日 | 10,000リクエスト |

全レスポンスに以下のヘッダを付与する。

```
RateLimit-Limit: 60
RateLimit-Remaining: 57
RateLimit-Reset: 42
```

超過時は `429` と `Retry-After`（秒）を返す。
**より多くの利用が必要な場合は連絡いただければ個別に緩和する**（連絡先は `/v1/meta` に記載）。

---

## 6. キャッシュ

データ更新は週1回程度のため、積極的にキャッシュしてよい。

```
Cache-Control: public, s-maxage=3600, stale-while-revalidate=86400
ETag: "d41d8cd9"
```

- 利用者側でも**結果をキャッシュすることを推奨**（レート制限の消費を抑えられる）。
- `If-None-Match` による条件付きリクエストに対応（`304` を返す）。

## 7. CORS

ブラウザから直接呼べるよう、全オリジンを許可する。

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, OPTIONS
```

---

## 8. 利用条件

- **無料・商用利用可**。
- **出典表示が必要**：アプリ内のどこか（クレジット画面等）に
  `神社・お寺データ: おまいりナビ (https://omairi-navi.vercel.app)` を表示すること。
  レスポンスの `attribution` フィールドに表示すべき文字列が入っている。
- **写真を表示する場合**は `image.license` と `image.author` を併記すること
  （多くがCC BY-SA等の要帰属ライセンス）。
- データの正確性は保証しない。参拝可否・授与品の有無・拝観時間等は、
  必ず各社寺の公式情報を確認すること。本APIの利用により生じた損害について責任を負わない。
- 大量取得によるデータの丸ごと複製・再配布は禁止。

---

## 9. バージョン方針

- パスに版を含める（`/v1/`）。
- **後方互換の変更**（フィールド追加・新エンドポイント）は `v1` のまま行う。
  利用者は未知のフィールドを無視できる実装にすること。
- **破壊的変更**は `/v2/` を新設し、`v1` は最低6か月併存させる。
- 変更履歴は `/v1/meta` の `changelog_url` から辿れる。
