# おまいりナビ Open API

お出かけアプリの開発者向けに、**地域や粗い位置情報から近くの神社・お寺を返す**公開API。
認証不要・無料・商用利用可。

- 収録: **2,086社寺**（全47都道府県）／481神仏／30ご利益
- すべて公式サイト・自治体・Wikipedia等で**出典付きで裏取り済み**
- 御朱印の有無（88社寺を確認済み）、国宝、直近1年のテレビ放映情報つき

📖 [仕様書](API_SPEC.md) ／ [OpenAPI定義](openapi.yaml) ／ [設計書](DESIGN.md)

---

## クイックスタート

### 現在地の市区町村から探す（推奨）

```bash
curl -G "https://api.omairi-navi.app/v1/shrines" \
  --data-urlencode "pref=京都府" \
  --data-urlencode "city=宇治市"
```

### 御朱印がもらえる神社だけ、近い順に

```bash
curl "https://api.omairi-navi.app/v1/shrines?lat=34.89&lng=135.81&radius_km=5&goshuin=true"
```

---

## プライバシーについて（重要）

**ユーザーの正確な現在地は送らないでください。**

本APIは位置を粗い粒度でしか必要としません。

| 推奨度 | 方法 | 例 |
|---|---|---|
| ◎ | 市区町村名で渡す | `?pref=京都府&city=宇治市` |
| ○ | 座標を**小数第2位に丸めて**渡す（約1km四方） | `?lat=34.89&lng=135.81` |
| ✕ | 生のGPS座標をそのまま渡す | `?lat=34.889231&lng=135.807745` |

サーバ側でも小数第3位以下は切り捨て、座標をログに残しません。

```js
// 座標を送る場合は、必ずアプリ側で丸めてから
const coarse = (v) => Math.round(v * 100) / 100
fetch(`https://api.omairi-navi.app/v1/shrines?lat=${coarse(lat)}&lng=${coarse(lng)}`)
```

---

## 使用例

### JavaScript / TypeScript

```js
async function nearbyShrines(pref, city) {
  const url = new URL('https://api.omairi-navi.app/v1/shrines')
  url.searchParams.set('pref', pref)
  url.searchParams.set('city', city)
  url.searchParams.set('limit', '20')

  const res = await fetch(url)
  if (!res.ok) throw new Error((await res.json()).title)
  const { shrines, meta, attribution } = await res.json()

  console.log(`${meta.total}件`, attribution.text) // 出典表示は必須
  return shrines
}
```

### Swift (iOS) — 逆ジオコーディングの結果をそのまま渡す

```swift
let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
var comps = URLComponents(string: "https://api.omairi-navi.app/v1/shrines")!
comps.queryItems = [
    .init(name: "pref", value: placemark?.administrativeArea),  // "京都府"
    .init(name: "city", value: placemark?.locality),            // "宇治市"
    .init(name: "limit", value: "20"),
]
let (data, _) = try await URLSession.shared.data(from: comps.url!)
```

### Kotlin (Android)

```kotlin
val address = Geocoder(context, Locale.JAPAN)
    .getFromLocation(lat, lng, 1)?.firstOrNull()
val url = "https://api.omairi-navi.app/v1/shrines".toHttpUrl().newBuilder()
    .addQueryParameter("pref", address?.adminArea)   // "京都府"
    .addQueryParameter("city", address?.locality)    // "宇治市"
    .build()
```

---

## 主なエンドポイント

| エンドポイント | 用途 |
|---|---|
| `GET /v1/shrines` | 検索（地域 or 粗い座標・近い順） |
| `GET /v1/shrines/{id}` | 詳細（＋関連社寺） |
| `GET /v1/areas` | 都道府県・市区町村の一覧と件数（地域選択UI用） |
| `GET /v1/goriyaku` | ご利益カテゴリ一覧（絞り込みUI用） |
| `GET /v1/meta` | データ版・件数・レート制限 |

主な絞り込み: `type`（shrine/temple）・`goriyaku`・`goshuin`・`national_treasure`・`tv`・`q`

詳細は [API_SPEC.md](API_SPEC.md) を参照。

---

## 表記ゆれは吸収します

逆ジオコーディングの結果はOSや端末で揺れますが、そのまま渡して構いません。

| 渡した値 | 結果 |
|---|---|
| `京都市` | 京都市＋各区の**102件すべて** |
| `美郷町` | `仙北郡美郷町` を返す（郡名の省略を吸収） |
| `京都` | `京都府` として解釈 |
| 特定できない市名 | エラーにせず**都道府県全体**を返し `meta.notice` で通知 |

---

## 制限とお願い

- **レート制限**: 60回/分・10,000回/日（IP単位）。超過時は `429`。
  緩和が必要な場合はご相談ください（連絡先は `/v1/meta`）。
- **キャッシュ推奨**: 応答は1時間キャッシュ可能（`ETag` 対応）。CDNヒット時は制限を消費しません。
- **出典表示が必要**: アプリ内のどこかに
  `神社・お寺データ: おまいりナビ (https://omairi-navi.vercel.app)` を表示してください。
  レスポンスの `attribution.text` にそのまま使える文字列が入っています。
- **写真を表示する場合**は `image.license` と `image.author` を併記してください。
- データの正確性は保証しません。参拝可否・授与品・拝観時間は各社寺の公式情報をご確認ください。

---

## 開発

```bash
npm run build:data     # appdata.json → data/api-data.json を生成
npm test               # 振る舞いのテスト（20件）
node scripts/dev-server.mjs 8787   # ローカル検証サーバ
```

環境変数（任意）:

| 変数 | 用途 |
|---|---|
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | ビルド時のデータ取得元（未設定なら同梱JSON） |
| `UPSTASH_REDIS_REST_URL` / `..._TOKEN` | レート制限（未設定なら無制限＝ローカル開発向け） |
| `API_CONTACT` | `/v1/meta` に載せる連絡先 |
