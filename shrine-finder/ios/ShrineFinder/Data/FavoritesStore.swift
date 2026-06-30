import Foundation

/// お気に入り社寺の slug を端末に永続化（MVPはUserDefaults。将来Supabase同期に差し替え）。
@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var slugs: Set<String> = []
    private let key = "favorite_shrine_slugs"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        slugs = Set(saved)
    }

    func contains(_ slug: String) -> Bool { slugs.contains(slug) }

    func toggle(_ slug: String) {
        if slugs.contains(slug) { slugs.remove(slug) } else { slugs.insert(slug) }
        UserDefaults.standard.set(Array(slugs), forKey: key)
    }
}
