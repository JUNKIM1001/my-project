import Foundation

/// 最近見た社寺の slug を端末に永続化（MVPはUserDefaults。将来Supabase同期に差し替え）。
/// 閲覧順（新しいものが先頭）を保持する配列で管理し、最大10件まで残す。
@MainActor
final class RecentStore: ObservableObject {
    @Published private(set) var slugs: [String] = []
    private let key = "recent_shrine_slugs"
    private let limit = 10

    init() {
        // 念のため重複は先勝ちで除去し、上限を超えた分は切り捨てる。
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        var seen = Set<String>()
        slugs = Array(saved.filter { seen.insert($0).inserted }.prefix(limit))
    }

    /// 閲覧を記録する。既出の slug は先頭へ移動し、全体を最大10件に保つ。
    func record(_ slug: String) {
        var updated = slugs
        updated.removeAll { $0 == slug }
        updated.insert(slug, at: 0)
        slugs = Array(updated.prefix(limit))
        save()
    }

    private func save() {
        UserDefaults.standard.set(slugs, forKey: key)
    }
}
