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
    var body: some View {
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
