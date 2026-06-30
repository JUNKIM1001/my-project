import SwiftUI

let toriiRed = Color(red: 0.75, green: 0.22, blue: 0.17)

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

/// ご利益タグ。highlight に一致すると強調表示。
struct GoriyakuTag: View {
    let text: String
    var highlighted: Bool = false
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(highlighted ? toriiRed : Color(.secondarySystemBackground))
            .foregroundStyle(highlighted ? .white : .secondary)
            .clipShape(Capsule())
    }
}

/// 折り返すタグ群
struct GoriyakuTagFlow: View {
    let goriyaku: [Goriyaku]
    var highlight: String? = nil
    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(goriyaku) { g in
                GoriyakuTag(text: g.name, highlighted: g.slug == highlight)
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
                Text(shrine.name).font(.headline)
                TypeBadge(shrine: shrine)
                if shrine.isNationalTreasure { NationalTreasureBadge(compact: true) }
                Spacer()
                if let distance { Text(distance.distanceLabel).font(.subheadline.bold()).foregroundStyle(toriiRed) }
            }
            Text("\(shrine.pref) \(shrine.city) ・ \(shrine.deityRoleLabel)：\(store.deities(of: shrine).map(\.name).joined(separator: "、"))")
                .font(.caption).foregroundStyle(.secondary).lineLimit(2)
            GoriyakuTagFlow(goriyaku: store.names(forGoriyaku: store.goriyakuSlugs(of: shrine)), highlight: highlight)
        }
        .padding(.vertical, 4)
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
