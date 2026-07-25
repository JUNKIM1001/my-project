import SwiftUI

/// 都道府県参照（ナビゲーション用の値型）
struct PrefRef: Hashable { let pref: String }

/// 地域から探す：地方 → 都道府県 → 社寺一覧。
struct RegionView: View {
    var body: some View {
        NavigationStack {
            RegionGrid()
                .navigationTitle("地域から探す")
                .navigationDestination(for: PrefRef.self) { PrefectureShrinesView(pref: $0.pref) }
                .navigationDestination(for: Shrine.self) { ShrineDetailView(shrine: $0) }
                .navigationDestination(for: Deity.self) { DeityDetailView(deity: $0) }
        }
    }
}

/// 地方別の都道府県グリッド（NavigationStackを持たない中身。Home からも再利用）。
struct RegionGrid: View {
    @EnvironmentObject var store: DataStore
    private let cols = [GridItem(.adaptive(minimum: 104), spacing: 12)]

    var body: some View {
        ScrollView {
            let counts = store.prefCounts()
            VStack(alignment: .leading, spacing: 20) {
                ForEach(DataStore.regions, id: \.name) { region in
                    let prefs = region.prefs.filter { (counts[$0] ?? 0) > 0 }
                    if !prefs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(region.name).font(.title3.bold())
                            LazyVGrid(columns: cols, spacing: 12) {
                                ForEach(prefs, id: \.self) { pref in
                                    NavigationLink(value: PrefRef(pref: pref)) {
                                        PrefCard(pref: pref, count: counts[pref] ?? 0)
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct PrefCard: View {
    let pref: String
    let count: Int
    var body: some View {
        VStack(spacing: 6) {
            Text(pref).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2).minimumScaleFactor(0.8)
            Text("\(count)社寺").font(.caption).foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 76)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// ある都道府県の社寺一覧（現在地があれば近い順）。
struct PrefectureShrinesView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var location: LocationService
    let pref: String

    private var list: [(shrine: Shrine, distance: Double?)] {
        store.shrines(inPref: pref, near: location.currentLocation).map { ($0.0, $0.1) }
    }

    var body: some View {
        // body 内で1回だけ評価する（ForEach とヘッダーで二重に走査しない）
        let items = list
        List {
            if location.currentLocation == nil {
                Section {
                    Button { location.request() } label: {
                        Label("現在地から近い順に並べる", systemImage: "location.fill")
                    }
                }
            }
            Section {
                ForEach(items, id: \.shrine.id) { item in
                    NavigationLink(value: item.shrine) {
                        ShrineRow(shrine: item.shrine, distance: item.distance)
                    }
                }
            } header: {
                Text(location.currentLocation != nil
                     ? "\(pref)の社寺（近い順・\(items.count)件）"
                     : "\(pref)の社寺（\(items.count)件）")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(pref)
        .navigationBarTitleDisplayMode(.inline)
    }
}
