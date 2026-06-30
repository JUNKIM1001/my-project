import SwiftUI

/// お気に入りに保存した社寺一覧。
struct FavoritesView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var favorites: FavoritesStore

    private var saved: [Shrine] { store.shrines.filter { favorites.contains($0.slug) } }

    var body: some View {
        NavigationStack {
            Group {
                if saved.isEmpty {
                    ContentUnavailableView("お気に入りはまだありません",
                        systemImage: "heart",
                        description: Text("社寺の詳細画面でハートを押すと、ここに保存されます。"))
                } else {
                    List(saved) { s in
                        NavigationLink(value: s) { ShrineRow(shrine: s) }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("お気に入り")
            .navigationDestination(for: Shrine.self) { ShrineDetailView(shrine: $0) }
            .navigationDestination(for: Deity.self) { DeityDetailView(deity: $0) }
        }
    }
}
