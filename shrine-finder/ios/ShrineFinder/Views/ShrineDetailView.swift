import SwiftUI
import MapKit

/// 社寺詳細：御祭神・ご利益・地図・経路案内・お気に入り・出典。
struct ShrineDetailView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var favorites: FavoritesStore
    let shrine: Shrine
    /// おすすめ（body評価ごとの全件走査を避けるため .task で一度だけ計算）
    @State private var related: [Shrine] = []

    var body: some View {
        List {
            Section {
                ShrineHeroView(shrine: shrine, showsCredit: true)
                    .frame(height: 170)
                    .clipped()
                    .listRowInsets(EdgeInsets())
            }
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        TypeBadge(shrine: shrine)
                        if shrine.isNationalTreasure { NationalTreasureBadge() }
                        Text(shrine.sect).font(.caption).foregroundStyle(.secondary)
                    }
                    Text(shrine.kana).font(.subheadline).foregroundStyle(.secondary)
                    Text(shrine.description).font(.body)
                    if let long = shrine.longDescription, !long.isEmpty {
                        Text(long).font(.callout).foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                }.padding(.vertical, 4)
            }

            Section {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: shrine.coordinate, span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)))) {
                    Marker(shrine.name, coordinate: shrine.coordinate).tint(toriiRed)
                }
                .frame(height: 180)
                .listRowInsets(EdgeInsets())

                Button { openInMaps() } label: {
                    Label("経路案内（マップで開く）", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                }
                if let access = shrine.access, !access.isEmpty {
                    Label(access, systemImage: "tram.fill")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Text(shrine.address).font(.caption).foregroundStyle(.secondary)
            } header: { Text("アクセス") }

            if shrine.hours != nil || shrine.fee != nil || shrine.goshuin != nil {
                Section("参拝情報") {
                    if let hours = shrine.hours {
                        LabeledContent("参拝時間", value: hours)
                    }
                    if let fee = shrine.fee {
                        LabeledContent("拝観料", value: fee)
                    }
                    if let goshuin = shrine.goshuin {
                        LabeledContent("御朱印", value: goshuin ? "あり" : "なし")
                    }
                }
            }

            Section(shrine.deityRoleLabel) {
                ForEach(store.deities(of: shrine)) { d in
                    NavigationLink(value: d) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(d.name).font(.subheadline.weight(.semibold))
                            Text("\(d.kindLabel)・\(d.category)").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            let goriyakuList = store.names(forGoriyaku: store.goriyakuSlugs(of: shrine))
            if !goriyakuList.isEmpty {
                Section("授かれるご利益") {
                    GoriyakuTagFlow(goriyaku: goriyakuList)
                        .padding(.vertical, 4)
                }
            }

            if !related.isEmpty {
                Section("ここに行った人はこちらも") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(related) { r in
                                NavigationLink(value: r) {
                                    RecommendCard(shrine: r)
                                }.buttonStyle(.plain)
                            }
                        }.padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                }
            }

            Section {
                // 参照リンクは1本に集約（公式サイトがあれば公式、無ければWikipedia）
                if let url = shrine.websiteURL {
                    Link(destination: url) { Label("公式サイト", systemImage: "globe") }
                } else if let url = shrine.sourceURL {
                    Link(destination: url) { Label("Wikipediaで見る", systemImage: "text.book.closed") }
                }
            } header: { Text("参照") } footer: {
                Text("データは公式サイト・自治体・日本語Wikipedia等の信頼できる情報源で裏取りしています。")
                    .font(.caption2)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(shrine.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: shrine.slug) { related = store.related(to: shrine) }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { favorites.toggle(shrine.slug) } label: {
                    Image(systemName: favorites.contains(shrine.slug) ? "heart.fill" : "heart")
                        .foregroundStyle(toriiRed)
                }
            }
        }
    }

    private func openInMaps() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: shrine.coordinate))
        item.name = shrine.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}
