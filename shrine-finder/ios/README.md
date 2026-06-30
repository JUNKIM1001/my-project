# おまいりナビ — iOSアプリ（SwiftUI）

願い事・現在地から、実在の神社・お寺と神仏が見つかるアプリ。MVPは検証済みデータ（`Resources/appdata.json`・24社寺/24神仏）を**オフライン同梱**。将来 `DataStore` の実装を Supabase 取得に差し替え可能。

## 動かし方
フルXcode（iOS SDK）が必要です。Command Line Tools だけではビルドできません。

```bash
# 1) Xcode を App Store からインストール後、初回設定
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 2) プロジェクト生成（project.yml から）。既に生成済みなら不要
cd shrine-finder/ios
brew install xcodegen   # 未導入時
xcodegen generate

# 3) 開いて実行（⌘R / iPhoneシミュレータ）
open ShrineFinder.xcodeproj
```
> `project.yml` が唯一の真実。ファイルを足したら `xcodegen generate` し直す。

## 画面構成（TabView）
| タブ | 画面 | 機能 |
|---|---|---|
| さがす | `HomeView` → `WishResultView` | ご利益グリッド→司る神仏＋参拝先（ヒットしたご利益を強調） |
| 地図 | `NearbyView` | MapKit＋現在地/既定地点から近い順、ご利益・神社のみ絞込 |
| 図鑑 | `DeityListView` → `DeityDetailView` | 神様/仏様タブ・検索、由来・司るご利益・祀る社寺 |
| お気に入り | `FavoritesView` | 端末保存（UserDefaults） |

`ShrineDetailView`: 御祭神/本尊・ご利益・地図・経路案内（Appleマップ）・公式/出典リンク・お気に入り。

## 構成（MVVM）
- `Models/` Codable モデル（appdata.json に対応）
- `Data/DataStore` データ読込＋検索（ご利益導出＝御祭神/本尊のご利益の和集合）。**Supabase差し替え点**
- `Data/FavoritesStore` お気に入り永続化
- `Services/LocationService` 現在地（CoreLocation）
- `Views/` 各画面・共通部品

## データ更新
`shrine-finder/data/dataset.json`（正準）を増やしたら `Resources/appdata.json` に反映。
Supabase運用に切り替える際は `DataStore.load()` を supabase-swift のクエリに置換。
