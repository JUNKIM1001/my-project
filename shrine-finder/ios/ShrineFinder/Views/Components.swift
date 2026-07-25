import SwiftUI

let toriiRed = Color(red: 0.75, green: 0.22, blue: 0.17)
/// テレビ放映の強調色（ダークでもコントラストを確保するため明度を切り替える）
let tvAccent = Color(light: Color(red: 0.70, green: 0.12, blue: 0.32),
                     dark: Color(red: 1.00, green: 0.55, blue: 0.70))
/// 御朱印の強調色
let goshuinAccent = Color(light: Color(red: 0.36, green: 0.20, blue: 0.68),
                          dark: Color(red: 0.78, green: 0.70, blue: 1.00))

extension Color {
    /// ライト／ダークで別の色を使う（バッジ等のコントラスト確保用）
    init(light: Color, dark: Color) {
        self.init(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }
}

/// 神社／寺の種別バッジ
struct TypeBadge: View {
    let shrine: Shrine
    var body: some View {
        Text(shrine.typeLabel)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background((shrine.isShrine ? toriiRed : Color.blue).opacity(0.15))
            .foregroundStyle(shrine.isShrine ? toriiRed : Color.blue)
            .clipShape(Capsule())
    }
}

/// 国宝バッジ（⭐️国宝）
struct NationalTreasureBadge: View {
    var compact: Bool = false
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
            if !compact { Text("国宝") }
        }
        .font(.caption2.weight(.bold))
        .padding(.horizontal, compact ? 4 : 6).padding(.vertical, 2)
        .background(Color(red: 0.85, green: 0.65, blue: 0.13).opacity(0.22))
        .foregroundStyle(Color(red: 0.78, green: 0.55, blue: 0.0))
        .clipShape(Capsule())
    }
}

/// テレビ放映バッジ（📺 テレビ放映）
struct TVBadge: View {
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "tv.fill")
            Text("テレビ放映")
        }
        .font(.caption2.weight(.bold))
        .padding(.horizontal, 7).padding(.vertical, 2)
        .background(tvAccent.opacity(0.16))
        .foregroundStyle(tvAccent)
        .clipShape(Capsule())
    }
}

/// 御朱印バッジ
struct GoshuinBadge: View {
    var body: some View {
        Text("御朱印")
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(goshuinAccent.opacity(0.18))
            .foregroundStyle(goshuinAccent)
            .clipShape(Capsule())
    }
}

/// ご利益タグ。highlight に一致すると強調表示。
struct GoriyakuTag: View {
    let text: String
    var highlighted: Bool = false
    var muted: Bool = false
    var body: some View {
        Text(text)
            .font(.footnote)
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(highlighted ? toriiRed : (muted ? Color.clear : Color(.secondarySystemBackground)))
            .foregroundStyle(highlighted ? .white : (muted ? .secondary : .primary))
            .fontWeight(highlighted ? .semibold : .regular)
            .clipShape(Capsule())
    }
}

/// 折り返すタグ群。limit を指定すると該当ご利益を先頭に寄せ、上位のみ＋「ほか＋N」に集約。
struct GoriyakuTagFlow: View {
    let goriyaku: [Goriyaku]
    var highlight: String? = nil
    var limit: Int? = nil

    private var ordered: [Goriyaku] {
        guard let highlight else { return goriyaku }
        return goriyaku.filter { $0.slug == highlight } + goriyaku.filter { $0.slug != highlight }
    }
    var body: some View {
        let all = ordered
        // 隠すのが1件だけなら「ほか＋1」が同じ幅を食うので、そのまま表示する
        let cap = limit.map { all.count == $0 + 1 ? $0 + 1 : $0 }
        let shown = cap.map { Array(all.prefix($0)) } ?? all
        let extra = max(0, all.count - shown.count)
        if !shown.isEmpty {
            FlowLayout(spacing: 6) {
                ForEach(shown) { g in
                    GoriyakuTag(text: g.name, highlighted: g.slug == highlight)
                }
                if extra > 0 { GoriyakuTag(text: "ほか＋\(extra)", muted: true) }
            }
        }
    }
}

/// 社寺一覧の行
struct ShrineRow: View {
    @EnvironmentObject var store: DataStore
    let shrine: Shrine
    var highlight: String? = nil
    var distance: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(shrine.name).font(.title3.bold())
                Spacer()
                if let distance { Text(distance.distanceLabel).font(.subheadline.bold()).foregroundStyle(toriiRed) }
            }
            FlowLayout(spacing: 6) {
                TypeBadge(shrine: shrine)
                if shrine.isNationalTreasure { NationalTreasureBadge(compact: true) }
                if shrine.isTVActive { TVBadge() }
                if shrine.hasGoshuin { GoshuinBadge() }
            }
            Text("\(shrine.pref) \(shrine.city) ・ \(shrine.deityRoleLabel)：\(store.deities(of: shrine).map(\.name).joined(separator: "、"))")
                .font(.subheadline).foregroundStyle(.primary).opacity(0.82).lineLimit(2)
            GoriyakuTagFlow(goriyaku: store.names(forGoriyaku: store.goriyakuSlugs(of: shrine)), highlight: highlight, limit: 4)
        }
        .padding(.vertical, 5)
    }
}

/// シンプルな折り返しレイアウト（iOS16+ Layout）
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxW { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing; rowH = max(rowH, s.height)
        }
        return CGSize(width: maxW == .infinity ? x : maxW, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing; rowH = max(rowH, s.height)
        }
    }
}
