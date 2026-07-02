import SwiftUI
import UIKit

/// 願い事から探す入口。おすすめの有名社寺 ＋ 最近見た社寺 ＋ ご利益グリッド。
struct HomeView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var location: LocationService
    @EnvironmentObject var recent: RecentStore
    private let cols = [GridItem(.adaptive(minimum: 104), spacing: 12)]

    /// 最近見た社寺（新しい順・slug から解決できたもののみ）
    private var recentShrines: [Shrine] {
        recent.slugs.compactMap { slug in store.shrines.first { $0.slug == slug } }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    recommendSection

                    if !recentShrines.isEmpty {
                        recentSection
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("願い事から探す").font(.title3.bold())
                        Text("ご利益を選ぶと、ふさわしい神仏とお参り先が見つかります。")
                            .font(.subheadline).foregroundStyle(.secondary)
                        LazyVGrid(columns: cols, spacing: 12) {
                            ForEach(store.goriyakuCounts, id: \.0.id) { item in
                                NavigationLink(value: item.0) {
                                    GoriyakuCard(goriyaku: item.0, count: item.1)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("おまいりナビ")
            .navigationDestination(for: Goriyaku.self) { WishResultView(goriyaku: $0) }
            .navigationDestination(for: Shrine.self) { ShrineDetailView(shrine: $0) }
            .navigationDestination(for: Deity.self) { DeityDetailView(deity: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink { AboutView() } label: { Image(systemName: "info.circle") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SearchView() } label: { Image(systemName: "magnifyingglass") }
                }
            }
            .task { location.request() }
        }
    }

    private var recommendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("代表的な有名社寺", systemImage: "star.fill").font(.title3.bold())
                Spacer()
                if location.currentLocation != nil {
                    Text("近い順").font(.caption).foregroundStyle(.secondary)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.recommended(near: location.currentLocation)) { s in
                        NavigationLink(value: s) {
                            RecommendCard(shrine: s, distance: location.currentLocation?.distance(from: s.location))
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("最近見た社寺", systemImage: "clock.arrow.circlepath").font(.title3.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentShrines) { s in
                        NavigationLink(value: s) {
                            RecommendCard(shrine: s)
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

/// おすすめカード（象徴アートのヒーロー付き）
struct RecommendCard: View {
    @EnvironmentObject var store: DataStore
    let shrine: Shrine
    var distance: Double? = nil
    // Dynamic Type に追随するサイズ（固定値の代わり）
    @ScaledMetric(relativeTo: .subheadline) private var cardWidth: CGFloat = 168
    @ScaledMetric(relativeTo: .subheadline) private var photoHeight: CGFloat = 96
    @ScaledMetric(relativeTo: .subheadline) private var textHeight: CGFloat = 48

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 写真フィールド（はみ出しをクリップ）
            ShrineHeroView(shrine: shrine)
                .frame(width: cardWidth, height: photoHeight)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    if let distance {
                        Text(distance.distanceLabel)
                            .font(.caption2.bold()).padding(.horizontal, 6).padding(.vertical, 2)
                            .background(.ultraThinMaterial).clipShape(Capsule()).padding(6)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if shrine.isNationalTreasure { NationalTreasureBadge().padding(6) }
                }
            // 文字フィールド（写真とは別の固定領域・不透明背景）
            VStack(alignment: .leading, spacing: 2) {
                Text(shrine.name).font(.subheadline.bold()).foregroundStyle(.primary)
                    .lineLimit(1).minimumScaleFactor(0.8)
                Text("\(shrine.pref)\(shrine.city)").font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
            .padding(.horizontal, 8)
            .frame(width: cardWidth, height: textHeight, alignment: .leading)
            .background(Color(.secondarySystemBackground))
        }
        .frame(width: cardWidth)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct GoriyakuCard: View {
    let goriyaku: Goriyaku
    let count: Int
    @ScaledMetric(relativeTo: .subheadline) private var cardMinHeight: CGFloat = 96
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: goriyaku.icon).font(.title2).foregroundStyle(toriiRed)
            VStack(spacing: 2) {
                Text(goriyaku.name).font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center).foregroundStyle(.primary)
                if let description = goriyaku.description, !description.isEmpty {
                    Text(description).font(.caption2).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).lineLimit(2)
                }
            }
            Text("\(count)社寺").font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: cardMinHeight)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// ご利益の検索結果：司る神仏 ＋ 参拝できる社寺（現在地から近い順）。
struct WishResultView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var location: LocationService
    @Environment(\.openURL) private var openURL
    let goriyaku: Goriyaku
    @State private var prefFilter: String? = nil   // nil=すべての都道府県

    /// 現在地が分かれば近い順、無ければ規定順。距離はラベル表示用。
    /// 都道府県フィルタが選ばれていれば該当都道府県のみに絞る（近い順ソートと併用可）。
    private var ranked: [(shrine: Shrine, distance: Double?)] {
        var list = store.shrines(forGoriyaku: goriyaku.slug)
        if let prefFilter {
            list = list.filter { $0.pref == prefFilter }
        }
        if let origin = location.currentLocation {
            return list.map { ($0, origin.distance(from: $0.location)) }
                       .sorted { ($0.1 ?? 0) < ($1.1 ?? 0) }
        }
        return list.map { ($0, nil) }
    }

    var body: some View {
        List {
            // ご利益の副文（例:「良縁・人間関係」）をヘッダとして表示
            if let description = goriyaku.description, !description.isEmpty {
                Section {
                    Label(description, systemImage: goriyaku.icon)
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }

            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(store.deities(forGoriyaku: goriyaku.slug)) { d in
                            NavigationLink(value: d) {
                                VStack(spacing: 4) {
                                    Image(systemName: d.kind == "kami" ? "leaf.circle.fill" : "circle.hexagongrid.fill")
                                        .foregroundStyle(toriiRed)
                                    Text(d.name).font(.caption).foregroundStyle(.primary)
                                        .lineLimit(1).frame(maxWidth: 92)
                                }
                                .padding(8).background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }.buttonStyle(.plain)
                        }
                    }.padding(.vertical, 4)
                }
            } header: { Text("「\(goriyaku.name)」を司る神仏") }

            if location.currentLocation == nil {
                Section {
                    if location.isDenied {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("位置情報が許可されていません", systemImage: "location.slash")
                                .font(.subheadline)
                            Text("設定アプリで位置情報を許可してください。近い順の並べ替えに使用します。")
                                .font(.caption).foregroundStyle(.secondary)
                            Button("設定を開く") {
                                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    } else {
                        Button {
                            location.request()
                        } label: {
                            Label("現在地から近い順に並べる", systemImage: "location.fill")
                        }
                    }
                }
            }

            Section {
                Menu {
                    Picker("都道府県", selection: $prefFilter) {
                        Text("すべての都道府県").tag(String?.none)
                        ForEach(store.prefectures, id: \.self) { p in
                            Text(p).tag(String?.some(p))
                        }
                    }
                } label: {
                    HStack {
                        Label(prefFilter ?? "すべての都道府県", systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(prefFilter != nil ? toriiRed : .secondary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }

                if ranked.isEmpty {
                    Text("該当する社寺がありません")
                        .font(.subheadline).foregroundStyle(.secondary)
                } else {
                    ForEach(ranked, id: \.shrine.id) { item in
                        NavigationLink(value: item.shrine) {
                            ShrineRow(shrine: item.shrine, highlight: goriyaku.slug, distance: item.distance)
                        }
                    }
                }
            } header: {
                Text(location.currentLocation != nil
                     ? "参拝できる社寺（近い順・\(ranked.count)件）"
                     : "参拝できる社寺（\(ranked.count)件）")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(goriyaku.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
