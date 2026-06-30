import SwiftUI

/// ライセンス・出典（謝辞）。データ／写真の帰属表示（CC BY-SA等のコンプライアンス）。
struct AcknowledgementsView: View {
    @EnvironmentObject var store: DataStore

    private var photoCount: Int { store.shrines.lazy.filter { $0.imageURL != nil }.count }

    var body: some View {
        List {
            Section("社寺・神仏データ") {
                Text("社寺の名称・所在地・御祭神/本尊・由緒等は、日本語版ウィキペディア（CC BY-SA）、各社寺の公式サイト、自治体・観光協会の公開情報をもとに作成しています。")
                    .font(.footnote)
                link("ウィキペディア 日本語版", "https://ja.wikipedia.org/")
                link("CC BY-SA 4.0", "https://creativecommons.org/licenses/by-sa/4.0/deed.ja")
                link("CC BY-SA 3.0", "https://creativecommons.org/licenses/by-sa/3.0/deed.ja")
            }

            Section("写真") {
                Text("掲載写真（\(photoCount)社寺）は、ウィキメディア・コモンズの自由ライセンス（CC0 / パブリックドメイン / CC BY / CC BY-SA）の画像のみを使用しています。各写真の作者・ライセンスは、社寺の詳細画面に表示しています。写真の無い社寺には当アプリ独自のシンボル図を表示します。")
                    .font(.footnote)
                link("ウィキメディア・コモンズ", "https://commons.wikimedia.org/")
                link("CC0 / パブリックドメイン", "https://creativecommons.org/publicdomain/zero/1.0/deed.ja")
            }

            Section("地図・経路") {
                Text("地図表示・経路案内には Apple MapKit を使用しています。")
                    .font(.footnote)
            }

            Section("アイコン・イラスト") {
                Text("アプリアイコン、および写真の無い社寺に表示する鳥居・五重塔のシンボル図は、当アプリのオリジナル制作です（第三者の著作物は使用していません）。")
                    .font(.footnote)
            }

            Section {
                Text("各ライセンスの条件に従い、原著作者の帰属表示を行っています。権利に関するお問い合わせは開発者までご連絡ください。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("ライセンス・出典")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func link(_ title: String, _ url: String) -> some View {
        Link(destination: URL(string: url)!) { Label(title, systemImage: "link") }
    }
}
