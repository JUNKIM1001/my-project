import Foundation
import CoreLocation
import UIKit

/// 写真クレジット（photo_credits.json に対応）
struct PhotoCredit: Codable {
    let license: String
    let author: String
    let source: String
    let file: String
}

/// DataStore の読み込み失敗を表すエラー
enum DataStoreError: LocalizedError {
    case missingResource(String)
    var errorDescription: String? {
        switch self {
        case .missingResource(let name): return "\(name) が見つかりません"
        }
    }
}

/// 47都道府県（北から南の地理順・JIS X 0401 準拠）。
/// データに存在するものだけを DataStore.prefectures として残す。
private let allPrefectures = [
    "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
    "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
    "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県",
    "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県",
    "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県",
    "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
    "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
]

/// バックグラウンドで読み込み・導出計算した結果一式（MainActor への受け渡し用）
private struct LoadedData {
    let goriyaku: [Goriyaku]
    let deities: [Deity]
    let shrines: [Shrine]
    let goriyakuBySlug: [String: Goriyaku]
    let deityBySlug: [String: Deity]
    let shrineGoriyaku: [String: [String]]
    let goriyakuCounts: [(Goriyaku, Int)]
    let searchText: [String: String]
    let credits: [String: PhotoCredit]
    let prefectures: [String]
}

/// 検証済みデータ（appdata.json）を読み込み、検索クエリを提供する中核ストア。
/// 将来的にはこのクラスの実装を Supabase 取得に差し替えるだけでよい。
@MainActor
final class DataStore: ObservableObject {
    /// 読み込み状態。デコードはバックグラウンドで行い、完了後に loaded になる。
    enum LoadState {
        case loading
        case loaded
        case failed(Error)
    }

    @Published private(set) var state: LoadState = .loading
    @Published private(set) var goriyaku: [Goriyaku] = []
    @Published private(set) var deities: [Deity] = []
    @Published private(set) var shrines: [Shrine] = []
    /// ご利益ごとの社寺件数（多い順・0件は除外）。ロード時に一度だけ計算する。
    private(set) var goriyakuCounts: [(Goriyaku, Int)] = []
    /// データに存在する都道府県（北から南の地理順）。ロード時に一度だけ算出する。
    private(set) var prefectures: [String] = []

    private var goriyakuBySlug: [String: Goriyaku] = [:]
    private var deityBySlug: [String: Deity] = [:]
    /// 社寺ごとのご利益（社寺固有の明示分を先頭に、御祭神／本尊由来の導出分との和集合）
    private var shrineGoriyaku: [String: [String]] = [:]
    /// 検索用に正規化した「名称・かな・都道府県・市区町村」（slug ごと）
    private var searchText: [String: String] = [:]
    /// CC0/PD写真のクレジットと画像キャッシュ
    private var credits: [String: PhotoCredit] = [:]
    private var photoCache: [String: UIImage] = [:]

    init() { load() }

    /// デコードと導出計算をバックグラウンドで行い、結果を MainActor で反映する。
    /// 失敗時は state = .failed になり、「再試行」からこのメソッドを呼び直せる。
    func load() {
        state = .loading
        Task.detached(priority: .userInitiated) { [weak self] in
            do {
                let loaded = try DataStore.loadFromBundle()
                await self?.apply(loaded)
            } catch {
                await self?.fail(error)
            }
        }
    }

    private func apply(_ loaded: LoadedData) {
        goriyaku = loaded.goriyaku
        deities = loaded.deities
        shrines = loaded.shrines
        goriyakuBySlug = loaded.goriyakuBySlug
        deityBySlug = loaded.deityBySlug
        shrineGoriyaku = loaded.shrineGoriyaku
        goriyakuCounts = loaded.goriyakuCounts
        searchText = loaded.searchText
        credits = loaded.credits
        prefectures = loaded.prefectures
        state = .loaded
    }

    private func fail(_ error: Error) {
        state = .failed(error)
    }

    private nonisolated static func loadFromBundle() throws -> LoadedData {
        guard let url = Bundle.main.url(forResource: "appdata", withExtension: "json") else {
            throw DataStoreError.missingResource("appdata.json")
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(AppData.self, from: data)

        // slug が万一重複していてもクラッシュせず先勝ちで採用する
        let goriyakuBySlug = Dictionary(decoded.goriyaku.map { ($0.slug, $0) },
                                        uniquingKeysWith: { first, _ in first })
        let deityBySlug = Dictionary(decoded.deities.map { ($0.slug, $0) },
                                     uniquingKeysWith: { first, _ in first })

        var shrineGoriyaku: [String: [String]] = [:]
        var searchText: [String: String] = [:]
        for shrine in decoded.shrines {
            var ordered: [String] = []
            var seen = Set<String>()
            // 社寺固有の明示的なご利益を先頭に
            for g in shrine.goriyaku ?? [] where !seen.contains(g) {
                seen.insert(g); ordered.append(g)
            }
            // 御祭神／本尊が司るご利益との和集合
            for d in shrine.deities {
                for g in deityBySlug[d]?.goriyaku ?? [] where !seen.contains(g) {
                    seen.insert(g); ordered.append(g)
                }
            }
            shrineGoriyaku[shrine.slug] = ordered
            searchText[shrine.slug] = ([shrine.name, shrine.kana] + (shrine.aliases ?? []) +
                                       [shrine.pref, shrine.city])
                .map(normalizedForSearch).joined(separator: "\n")
        }

        // ご利益ごとの社寺件数（多い順・0件は除外）を事前計算
        var countBySlug: [String: Int] = [:]
        for slugs in shrineGoriyaku.values {
            for g in slugs { countBySlug[g, default: 0] += 1 }
        }
        let goriyakuCounts: [(Goriyaku, Int)] = decoded.goriyaku
            .compactMap { g in
                let c = countBySlug[g.slug] ?? 0
                return c > 0 ? (g, c) : nil
            }
            .sorted { $0.1 > $1.1 }

        var credits: [String: PhotoCredit] = [:]
        if let u = Bundle.main.url(forResource: "photo_credits", withExtension: "json"),
           let d = try? Data(contentsOf: u),
           let c = try? JSONDecoder().decode([String: PhotoCredit].self, from: d) {
            credits = c
        }

        // データに存在する都道府県のみを北から南の地理順で残す
        let prefsInData = Set(decoded.shrines.map(\.pref))
        let prefectures = allPrefectures.filter { prefsInData.contains($0) }

        return LoadedData(goriyaku: decoded.goriyaku, deities: decoded.deities, shrines: decoded.shrines,
                          goriyakuBySlug: goriyakuBySlug, deityBySlug: deityBySlug,
                          shrineGoriyaku: shrineGoriyaku, goriyakuCounts: goriyakuCounts,
                          searchText: searchText, credits: credits, prefectures: prefectures)
    }

    // MARK: 検索の正規化
    /// カタカナ→ひらがな統一・小文字化・前後空白除去。
    /// クエリと対象の双方に適用することで、カナ／かな・大文字小文字の揺れを吸収する。
    nonisolated static func normalizedForSearch(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let hiragana = trimmed.applyingTransform(.hiraganaToKatakana, reverse: true) ?? trimmed
        return hiragana.lowercased()
    }

    // MARK: 写真（CC0/パブリックドメインのみ）
    func photo(for shrine: Shrine) -> UIImage? {
        if let cached = photoCache[shrine.slug] { return cached }
        guard credits[shrine.slug] != nil else { return nil }
        for ext in ["jpg", "png"] {
            if let u = Bundle.main.url(forResource: shrine.slug, withExtension: ext),
               let img = UIImage(contentsOfFile: u.path) {
                photoCache[shrine.slug] = img
                return img
            }
        }
        return nil
    }
    func photoCredit(for shrine: Shrine) -> String? {
        guard let c = credits[shrine.slug] else { return nil }
        let who = c.author.isEmpty ? "Wikimedia Commons" : c.author
        return "写真: \(who) / \(c.license)"
    }

    /// 代表的な有名社寺（おすすめ表示用・この順で並べる）
    private let recommendedSlugs = [
        "ise-jingu-naiku", "izumo-taisha", "fushimi-inari-taisha", "meiji-jingu",
        "itsukushima-jinja", "kiyomizu-dera", "kasuga-taisha", "dazaifu-tenmangu",
        "nikko-toshogu", "senso-ji", "fujisan-hongu-sengen", "kumano-hongu-taisha"
    ]
    var recommended: [Shrine] {
        recommendedSlugs.compactMap { slug in shrines.first { $0.slug == slug } }
    }

    /// 現在地が分かれば近い順、無ければ規定順で「おすすめ」を返す
    func recommended(near origin: CLLocation?) -> [Shrine] {
        guard let origin else { return recommended }
        return recommended.sorted { origin.distance(from: $0.location) < origin.distance(from: $1.location) }
    }

    // MARK: 集計（情報画面用）
    var nationalTreasureCount: Int { shrines.lazy.filter(\.isNationalTreasure).count }
    var prefectureCount: Int { Set(shrines.map(\.pref)).count }

    /// 名称・かな・都道府県・市区町村でのフリーワード検索（種別・国宝・都道府県・近い順の絞り込み付き）。
    /// クエリ・対象とも正規化（かな統一・小文字化）した上で部分一致させる。
    func search(_ query: String, type: String? = nil, nationalTreasureOnly: Bool = false,
                pref: String? = nil, near origin: CLLocation? = nil) -> [(Shrine, Double?)] {
        let q = Self.normalizedForSearch(query)
        var list = shrines.filter { s in
            (type == nil || s.type == type!) &&
            (!nationalTreasureOnly || s.isNationalTreasure) &&
            (pref == nil || s.pref == pref!) &&
            (q.isEmpty || (searchText[s.slug] ?? "").contains(q))
        }
        if let origin {
            return list.map { ($0, origin.distance(from: $0.location)) }.sorted { ($0.1 ?? 0) < ($1.1 ?? 0) }
        }
        list.sort { $0.kana < $1.kana }
        return list.map { ($0, nil) }
    }

    // MARK: 参照
    func goriyaku(_ slug: String) -> Goriyaku? { goriyakuBySlug[slug] }
    func deity(_ slug: String) -> Deity? { deityBySlug[slug] }
    func names(forGoriyaku slugs: [String]) -> [Goriyaku] { slugs.compactMap { goriyakuBySlug[$0] } }

    func deities(of shrine: Shrine) -> [Deity] { shrine.deities.compactMap { deityBySlug[$0] } }
    func goriyakuSlugs(of shrine: Shrine) -> [String] { shrineGoriyaku[shrine.slug] ?? [] }

    // MARK: 検索
    /// あるご利益を授かれる社寺
    func shrines(forGoriyaku slug: String) -> [Shrine] {
        shrines.filter { (shrineGoriyaku[$0.slug] ?? []).contains(slug) }
    }
    /// あるご利益を司る神仏
    func deities(forGoriyaku slug: String) -> [Deity] {
        deities.filter { $0.goriyaku.contains(slug) }
    }
    /// ある神仏を祀る社寺
    func shrines(enshrining deitySlug: String) -> [Shrine] {
        shrines.filter { $0.deities.contains(deitySlug) }
    }

    /// 地図に表示されている矩形範囲内の社寺（中心からの距離付き・近い順・上限あり）
    func shrines(latMin: Double, latMax: Double, lngMin: Double, lngMax: Double,
                 center: CLLocation, goriyaku slug: String? = nil, type: String? = nil,
                 limit: Int = 200) -> [(Shrine, Double)] {
        shrines
            .filter { s in
                s.lat >= latMin && s.lat <= latMax && s.lng >= lngMin && s.lng <= lngMax &&
                (type == nil || s.type == type!) &&
                (slug == nil || (shrineGoriyaku[s.slug] ?? []).contains(slug!))
            }
            .map { ($0, center.distance(from: $0.location)) }
            .sorted { $0.1 < $1.1 }
            .prefix(limit).map { $0 }
    }

    /// この社寺に行った人へのおすすめ（御祭神/ご利益/系統の類似＋近さでスコアリング）
    func related(to shrine: Shrine, limit: Int = 8) -> [Shrine] {
        let gset = Set(goriyakuSlugs(of: shrine))
        let dset = Set(shrine.deities)
        let origin = shrine.location
        var scored: [(shrine: Shrine, score: Int, dist: Double)] = []
        for s in shrines where s.slug != shrine.slug {
            var score = Set(s.deities).intersection(dset).count * 4
            score += Set(goriyakuSlugs(of: s)).intersection(gset).count
            if !shrine.sect.isEmpty && s.sect == shrine.sect { score += 2 }
            if s.pref == shrine.pref { score += 1 }
            if score > 0 {
                scored.append((s, score, origin.distance(from: s.location)))
            }
        }
        scored.sort { $0.score != $1.score ? $0.score > $1.score : $0.dist < $1.dist }
        return scored.prefix(limit).map(\.shrine)
    }

    /// 指定座標から近い順に並べた社寺（距離メートル付き）
    func nearby(to origin: CLLocation, goriyaku slug: String? = nil, type: String? = nil) -> [(Shrine, Double)] {
        shrines
            .filter { slug == nil || (shrineGoriyaku[$0.slug] ?? []).contains(slug!) }
            .filter { type == nil || $0.type == type! }
            .map { ($0, origin.distance(from: $0.location)) }
            .sorted { $0.1 < $1.1 }
    }
}

extension Double {
    /// メートル → 「1.2km」「850m」表記
    var distanceLabel: String {
        self >= 1000 ? String(format: "%.1fkm", self / 1000) : "\(Int(self))m"
    }
}
