import SwiftUI

@main
struct ShrineFinderApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var location = LocationService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(favorites)
                .environmentObject(location)
                .tint(toriiRed)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: DataStore

    var body: some View {
        switch store.state {
        case .loading:
            ProgressView("読み込み中…")
        case .failed(let error):
            ContentUnavailableView {
                Label("データを読み込めませんでした", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("再試行") { store.load() }
                    .buttonStyle(.borderedProminent)
            }
        case .loaded:
            TabView {
                HomeView()
                    .tabItem { Label("さがす", systemImage: "sparkles") }
                NearbyView()
                    .tabItem { Label("地図", systemImage: "map.fill") }
                DeityListView()
                    .tabItem { Label("図鑑", systemImage: "book.closed.fill") }
                FavoritesView()
                    .tabItem { Label("お気に入り", systemImage: "heart.fill") }
            }
        }
    }
}
