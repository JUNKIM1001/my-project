import SwiftUI

/// 全社寺をフリーワード検索（種別・国宝・都道府県・近い順で絞り込み）。
struct SearchView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var location: LocationService
    @State private var query = ""
    @State private var typeFilter: String? = nil   // nil=すべて / "shrine" / "temple"
    @State private var ntOnly = false
    @State private var prefFilter: String? = nil   // nil=すべての都道府県

    private var results: [(shrine: Shrine, distance: Double?)] {
        store.search(query, type: typeFilter, nationalTreasureOnly: ntOnly,
                     pref: prefFilter, near: location.currentLocation)
            .map { ($0.0, $0.1) }
    }

    var body: some View {
        VStack(spacing: 0) {
            filterBar
            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(results, id: \.shrine.id) { item in
                    NavigationLink(value: item.shrine) {
                        ShrineRow(shrine: item.shrine, distance: item.distance)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "社寺名・地名で検索（例: 八幡、京都）")
        .navigationTitle("社寺をさがす")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            Picker("種別", selection: $typeFilter) {
                Text("すべて").tag(String?.none)
                Text("神社").tag(String?.some("shrine"))
                Text("寺").tag(String?.some("temple"))
            }
            .pickerStyle(.segmented)
            .fixedSize()

            Spacer()

            Menu {
                Picker("都道府県", selection: $prefFilter) {
                    Text("すべての都道府県").tag(String?.none)
                    ForEach(store.prefectures, id: \.self) { p in
                        Text(p).tag(String?.some(p))
                    }
                }
            } label: {
                Label(prefFilter ?? "都道府県", systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .tint(prefFilter != nil ? toriiRed : .secondary)

            Button { ntOnly.toggle() } label: {
                Label("国宝", systemImage: ntOnly ? "star.fill" : "star")
                    .font(.subheadline)
            }
            .tint(ntOnly ? toriiRed : .secondary)
        }
        .padding(.horizontal).padding(.vertical, 8)
    }
}
