import SwiftUI

/// アプリ情報・データ出典。
struct AboutView: View {
    @EnvironmentObject var store: DataStore

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.9"
        return "v\(v)"
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(toriiRed)
                    Text("おまいりナビ").font(.title2.bold())
                    Text(version).font(.subheadline).foregroundStyle(.secondary)
                    Text("願い事と現在地から、最適な神社・お寺と神仏が見つかるアプリ。")
                        .font(.footnote).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section {
                row("社寺", "\(store.shrines.count) 件")
                row("神様・仏様", "\(store.deities.count) 柱/尊")
                row("ご利益カテゴリ", "\(store.goriyaku.count) 種")
                row("国宝を有する社寺", "⭐️ \(store.nationalTreasureCount) 件")
                row("カバー都道府県", "\(store.prefectureCount) / 47")
            } header: {
                Text("収録データ")
            } footer: {
                Text("全国の社寺は約15.8万（神社 約8.1万・寺院 約7.7万）。本アプリは、その中から全国的に著名・代表的な社寺を厳選して収録しています。")
            }

            Section("データの出典・正確性") {
                Text("掲載する社寺は、すべて実在し参拝可能なものです。住所・緯度経度・御祭神/本尊は、日本語Wikipedia・自治体・各社寺公式サイト等の信頼できる情報源で裏取りし、確認できたものだけを収録しています。")
                    .font(.footnote)
                Link(destination: URL(string: "https://ja.wikipedia.org/")!) {
                    Label("Wikipedia 日本語版", systemImage: "text.book.closed")
                }
            }

            Section("写真について") {
                Text("社寺の写真は CC0 または パブリックドメインのもの（Wikimedia Commons）のみを使用しています。写真の無い社寺は、当アプリ独自の鳥居・五重塔のシンボルアートを表示します。")
                    .font(.footnote)
            }

            Section("ご利用にあたって") {
                NavigationLink {
                    DisclaimerView()
                } label: {
                    Label("免責事項", systemImage: "exclamationmark.shield")
                }
                NavigationLink {
                    AcknowledgementsView()
                } label: {
                    Label("ライセンス・出典", systemImage: "doc.text")
                }
                Text("情報の正確性は保証されません。本アプリの利用により生じた損害・不利益について開発者は責任を負わず、補償もいたしません。参拝前に各社寺の公式情報をご確認ください。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("このアプリについて")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ k: String, _ v: String) -> some View {
        HStack { Text(k); Spacer(); Text(v).foregroundStyle(.secondary) }
    }
}
