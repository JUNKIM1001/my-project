import SwiftUI

/// 神仏詳細：由来・司るご利益・祀る社寺。
struct DeityDetailView: View {
    @EnvironmentObject var store: DataStore
    let deity: Deity

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(deity.kana).font(.subheadline).foregroundStyle(.secondary)
                    HStack {
                        Label(deity.kindLabel, systemImage: deity.kind == "kami" ? "leaf.circle.fill" : "circle.hexagongrid.fill")
                        Text("・\(deity.category)")
                    }.font(.caption).foregroundStyle(toriiRed)
                    Text(deity.description).font(.body).padding(.top, 2)
                }.padding(.vertical, 4)
            }

            Section("司るご利益") {
                GoriyakuTagFlow(goriyaku: store.names(forGoriyaku: deity.goriyaku))
                    .padding(.vertical, 4)
            }

            Section("この神仏を祀る社寺") {
                ForEach(store.shrines(enshrining: deity.slug)) { s in
                    NavigationLink(value: s) { ShrineRow(shrine: s) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(deity.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
