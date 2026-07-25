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

/// 検証済みデータ（appdata.json）を読み込み、検索クエリを提供する中核ストア。
/// 将来的にはこのクラスの実装を Supabase 取得に差し替えるだけでよい。
@MainActor
final class DataStore: ObservableObject {
    @Published private(set) var goriyaku: [Goriyaku] = []
    @Published private(set) var deities: [Deity] = []
    @Published private(set) var shrines: [Shrine] = []

    private var goriyakuBySlug: [String: Goriyaku] = [:]
    private var deityBySlug: [String: Deity] = [:]
    /// 社寺ごとの導出ご利益（御祭神／本尊が司るご利益の和集合）
    private var shrineGoriyaku: [String: [String]] = [:]
    /// CC0/PD写真のクレジットと画像キャッシュ
    private var credits: [String: PhotoCredit] = [:]
    private var photoCache: [String: UIImage] = [:]
    /// 読み込み時に1回だけ計算する集計（bodyから毎回2,086件を走査しないため）
    private var prefCountsCache: [String: Int] = [:]
    private var tvCandidates: [Shrine] = []
    private var goriyakuCountsCache: [(Goriyaku, Int)] = []

    init() { load() }

    private func load() {
        guard let url = Bundle.main.url(forResource: "appdata", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(AppData.self, from: data) else {
            assertionFailure("appdata.json の読み込みに失敗")
            return
        }
        goriyaku = decoded.goriyaku
        deities = decoded.deities
        shrines = decoded.shrines
        goriyakuBySlug = Dictionary(uniqueKeysWithValues: goriyaku.map { ($0.slug, $0) })
        deityBySlug = Dictionary(uniqueKeysWithValues: deities.map { ($0.slug, $0) })

        for shrine in shrines {
            var ordered: [String] = []
            var seen = Set<String>()
            for d in shrine.deities {
                for g in deityBySlug[d]?.goriyaku ?? [] where !seen.contains(g) {
                    seen.insert(g); ordered.append(g)
                }
            }
            shrineGoriyaku[shrine.slug] = ordered
        }

        // 一覧・ホームで繰り返し使う集計は、ここで1回だけ計算しておく
        var counts: [String: Int] = [:]
        for s in shrines { counts[s.pref, default: 0] += 1 }
        prefCountsCache = counts
        tvCandidates = shrines.filter { $0.tv != nil }
            .sorted { ($0.tv?.date ?? "") > ($1.tv?.date ?? "") }
        goriyakuCountsCache = goriyaku.compactMap { g in
            let c = shrines.reduce(into: 0) { acc, s in
                if (shrineGoriyaku[s.slug] ?? []).contains(g.slug) { acc += 1 }
            }
            return c > 0 ? (g, c) : nil
        }.sorted { $0.1 > $1.1 }

        if let u = Bundle.main.url(forResource: "photo_credits", withExtension: "json"),
           let d = try? Data(contentsOf: u),
           let c = try? JSONDecoder().decode([String: PhotoCredit].self, from: d) {
            credits = c
        }
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
    var goshuinCount: Int { shrines.lazy.filter(\.hasGoshuin).count }

    // MARK: 地域から探す
    /// 8地方区分（北→南）。地域画面のグルーピングと表示順。
    static let regions: [(name: String, prefs: [String])] = [
        ("北海道", ["北海道"]),
        ("東北", ["青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県"]),
        ("関東", ["茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県"]),
        ("中部", ["新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県"]),
        ("近畿", ["三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県"]),
        ("中国", ["鳥取県", "島根県", "岡山県", "広島県", "山口県"]),
        ("四国", ["徳島県", "香川県", "愛媛県", "高知県"]),
        ("九州・沖縄", ["福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]),
    ]

    /// 都道府県ごとの社寺件数（読み込み時に1回だけ集計してキャッシュ）
    func prefCounts() -> [String: Int] { prefCountsCache }

    /// ある都道府県の社寺。現在地があれば近い順、無ければ市区町村→よみ順。
    func shrines(inPref pref: String, near origin: CLLocation? = nil) -> [(Shrine, Double?)] {
        let list = shrines.filter { $0.pref == pref }
        if let origin {
            return list.map { ($0, origin.distance(from: $0.location)) }
                       .sorted { ($0.1 ?? 0) < ($1.1 ?? 0) }
        }
        return list.sorted { ($0.city, $0.kana) < ($1.city, $1.kana) }.map { ($0, nil) }
    }

    /// 直近1年にテレビ放映された社寺（放映日の新しい順）。1年経過分は自動的に外れる。
    /// tv を持つ社寺だけを候補として保持し、1年判定のみ都度行う（全件走査を避ける）。
    func tvFeatured() -> [Shrine] {
        tvCandidates.filter(\.isTVActive)
    }

    /// 名称・かな・都道府県・市区町村でのフリーワード検索（種別・国宝・近い順の絞り込み付き）
    func search(_ query: String, type: String? = nil, nationalTreasureOnly: Bool = false,
                near origin: CLLocation? = nil) -> [(Shrine, Double?)] {
        let q = query.trimmingCharacters(in: .whitespaces)
        var list = shrines.filter { s in
            (type == nil || s.type == type!) &&
            (!nationalTreasureOnly || s.isNationalTreasure) &&
            (q.isEmpty || s.name.contains(q) || s.kana.contains(q) ||
             s.pref.contains(q) || s.city.contains(q))
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
    /// ご利益ごとの社寺件数（多い順）。0件は除外。読み込み時にキャッシュ済み。
    func goriyakuCounts() -> [(Goriyaku, Int)] { goriyakuCountsCache }

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
