import SwiftUI

/// お気に入りに保存した社寺一覧。
struct FavoritesView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var favorites: FavoritesStore

    /// 追加順（favorites.slugs の順）で表示する
    private var saved: [Shrine] {
        favorites.slugs.compactMap { slug in store.shrines.first { $0.slug == slug } }
    }

    var body: some View {
        NavigationStack {
            Group {
                if saved.isEmpty {
                    ContentUnavailableView("お気に入りはまだありません",
                        systemImage: "heart",
                        description: Text("社寺の詳細画面でハートを押すと、ここに保存されます。"))
                } else {
                    List {
                        ForEach(saved) { s in
                            NavigationLink(value: s) { ShrineRow(shrine: s) }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("お気に入り")
            .navigationDestination(for: Shrine.self) { ShrineDetailView(shrine: $0) }
            .navigationDestination(for: Deity.self) { DeityDetailView(deity: $0) }
        }
    }

    private func delete(at offsets: IndexSet) {
        favorites.remove(offsets.map { saved[$0].slug })
    }
}
