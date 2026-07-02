import Foundation

/// お気に入り社寺の slug を端末に永続化（MVPはUserDefaults。将来Supabase同期に差し替え）。
/// 追加順を保持する配列で管理する（先に追加したものが先頭）。
@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var slugs: [String] = []
    private let key = "favorite_shrine_slugs"

    init() {
        // 旧バージョンは Set 由来の順序不定な配列を保存していたが、
        // どちらも文字列配列として保存されているためそのまま読み込める。
        // 念のため重複は先勝ちで除去する（以後は追加順で保存される）。
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        var seen = Set<String>()
        slugs = saved.filter { seen.insert($0).inserted }
    }

    func contains(_ slug: String) -> Bool { slugs.contains(slug) }

    func toggle(_ slug: String) {
        if let i = slugs.firstIndex(of: slug) {
            slugs.remove(at: i)
        } else {
            slugs.append(slug)
        }
        save()
    }

    /// 指定した slug 群をまとめて削除（スワイプ削除用）
    func remove(_ slugsToRemove: [String]) {
        slugs.removeAll { slugsToRemove.contains($0) }
        save()
    }

    private func save() {
        UserDefaults.standard.set(slugs, forKey: key)
    }
}
