import Foundation
import CoreLocation

// MARK: - データモデル（appdata.json に対応）

struct Goriyaku: Codable, Identifiable, Hashable {
    let slug: String
    let name: String
    let icon: String
    var id: String { slug }
}

struct Deity: Codable, Identifiable, Hashable {
    let slug: String
    let name: String
    let kana: String
    let kind: String          // "kami" | "buddha"
    let category: String
    let description: String
    let goriyaku: [String]
    var id: String { slug }

    var kindLabel: String { kind == "kami" ? "神様" : "仏様" }
}

/// 直近のテレビ放映情報（tv フィールド）
struct TVFeature: Codable, Hashable {
    let date: String        // "YYYY-MM-DD"
    let program: String?
    let source: String?
}

struct Shrine: Codable, Identifiable, Hashable {
    let slug: String
    let name: String
    let kana: String
    let type: String          // "shrine" | "temple"
    let sect: String
    let pref: String
    let city: String
    let address: String
    let lat: Double
    let lng: Double
    let deities: [String]
    let website: String?
    let description: String
    let source: String
    let nt: Bool?          // 国宝（建造物等）を有する社寺
    let imageURL: String?       // Wikipedia/Commonsの代表画像(自由ライセンスのみ)
    let imageLicense: String?   // 例: CC BY-SA 4.0
    let imageAuthor: String?
    let longDescription: String?   // Wikipedia記事の冒頭(歴史・由緒など)
    let goshuin: Bool?          // 御朱印の授与あり
    let tv: TVFeature?          // 直近のテレビ放映
    var id: String { slug }

    /// 表示用の写真クレジット（実行時にAsyncImageへ添える）
    var imageCredit: String? {
        guard imageURL != nil else { return nil }
        let who = (imageAuthor?.isEmpty == false) ? imageAuthor! : "Wikimedia Commons"
        return "写真: \(who) / \(imageLicense ?? "Wikimedia")"
    }

    // 安全なURL（http/httpsスキームのみ許可。javascript:/file:/独自スキーム等は弾く）
    var websiteURL: URL? { Shrine.httpURL(website) }
    var sourceURL: URL?  { Shrine.httpURL(source) }
    var photoURL: URL?   { Shrine.httpURL(imageURL) }
    private static func httpURL(_ s: String?) -> URL? {
        guard let s, let u = URL(string: s),
              let scheme = u.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else { return nil }
        return u
    }

    var isNationalTreasure: Bool { nt == true }
    var hasGoshuin: Bool { goshuin == true }
    var tvSourceURL: URL? { Shrine.httpURL(tv?.source) }

    /// テレビ放映が「1年以内」か（放映日が1年前の同日以降〜今日まで・暦日判定）。
    /// 実行時の現在日で判定するので、1年経過すると自動的に非表示になる。
    var isTVActive: Bool { Shrine.tvActive(tv?.date) }

    /// "YYYY-MM-DD" のパーサ（生成コストを避けて使い回す）
    private static let isoDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        f.calendar = Calendar(identifier: .gregorian)
        f.isLenient = false
        return f
    }()
    /// 端末が和暦設定でも判定がぶれないようグレゴリオ暦で固定
    private static let gregorian: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        return c
    }()
    /// 表示用「2026年6月6日」（パースできなければ元の文字列）
    private static let jaDisplayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "y年M月d日"
        return f
    }()
    static func jaDateLabel(_ dateStr: String) -> String {
        guard let d = isoDayFormatter.date(from: dateStr) else { return dateStr }
        return jaDisplayFormatter.string(from: d)
    }

    static func tvActive(_ dateStr: String?, now: Date = Date()) -> Bool {
        guard let dateStr, let aired = isoDayFormatter.date(from: dateStr) else { return false }
        let cal = gregorian
        let airedDay = cal.startOfDay(for: aired)
        let today = cal.startOfDay(for: now)
        guard let cutoff = cal.date(byAdding: .year, value: -1, to: today) else { return false }
        return airedDay >= cutoff && airedDay <= today
    }

    var isShrine: Bool { type == "shrine" }
    var typeLabel: String { isShrine ? "神社" : "寺" }
    var deityRoleLabel: String { isShrine ? "御祭神" : "本尊" }
    var coordinate: CLLocationCoordinate2D { .init(latitude: lat, longitude: lng) }
    var location: CLLocation { .init(latitude: lat, longitude: lng) }
}

struct AppData: Codable {
    let goriyaku: [Goriyaku]
    let deities: [Deity]
    let shrines: [Shrine]
}
