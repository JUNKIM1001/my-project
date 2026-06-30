import SwiftUI

/// 神仏図鑑。神様／仏様タブ＋検索。
struct DeityListView: View {
    @EnvironmentObject var store: DataStore
    @State private var kind = "kami"
    @State private var query = ""

    private var filtered: [Deity] {
        store.deities
            .filter { $0.kind == kind }
            .filter { query.isEmpty || $0.name.contains(query) || $0.kana.contains(query) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("種別", selection: $kind) {
                    Text("神様").tag("kami")
                    Text("仏様").tag("buddha")
                }
                .pickerStyle(.segmented)
                .padding()

                List(filtered) { d in
                    NavigationLink(value: d) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(d.name).font(.headline)
                                Text(d.category).font(.caption2)
                                    .padding(.horizontal, 6).padding(.vertical, 1)
                                    .background(Color(.secondarySystemBackground)).clipShape(Capsule())
                            }
                            Text(d.kana).font(.caption).foregroundStyle(.secondary)
                            Text(d.description).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }.padding(.vertical, 2)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $query, prompt: "神仏を検索")
            }
            .navigationTitle("神仏図鑑")
            .navigationDestination(for: Deity.self) { DeityDetailView(deity: $0) }
            .navigationDestination(for: Shrine.self) { ShrineDetailView(shrine: $0) }
        }
    }
}
