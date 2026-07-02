import Foundation
import CoreLocation

// MARK: - データモデル（appdata.json に対応）

struct Goriyaku: Codable, Identifiable, Hashable {
    let slug: String
    let name: String
    let icon: String
    let description: String?  // 副文（例:「良縁・人間関係」）
    var id: String { slug }
}

struct Deity: Codable, Identifiable, Hashable {
    let slug: String
    let name: String
    let kana: String
    let kind: String          // "kami" | "buddha"
    let category: String
    let description: String
    let longDescription: String?  // 図鑑詳細用の由来解説（主要神仏のみ）
    let goriyaku: [String]
    var id: String { slug }

    var kindLabel: String { kind == "kami" ? "神様" : "仏様" }
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
    let goriyaku: [String]?     // 社寺固有のご利益（御祭神/本尊からの導出に先行して表示）
    let aliases: [String]?      // 通称・別名（例:「お稲荷さん」）。検索対象に含める
    // 参拝実用情報（公式サイト等で確認できた社寺のみ）
    let hours: String?          // 参拝時間（例:「6:00〜17:00（季節により変動）」）
    let fee: String?            // 拝観料（例:「境内無料（本堂内陣500円）」）
    let goshuin: Bool?          // 御朱印の授与
    let access: String?         // 公共交通でのアクセス
    let website: String?
    let description: String
    let source: String
    let nt: Bool?          // 国宝（建造物等）を有する社寺
    let imageURL: String?       // Wikipedia/Commonsの代表画像(自由ライセンスのみ)
    let imageLicense: String?   // 例: CC BY-SA 4.0
    let imageAuthor: String?
    let longDescription: String?   // Wikipedia記事の冒頭(歴史・由緒など)
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
