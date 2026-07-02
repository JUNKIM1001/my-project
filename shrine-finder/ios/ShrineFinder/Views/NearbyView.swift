import SwiftUI
import MapKit
import CoreLocation

/// 地図で社寺を探す。表示中の地図範囲にある社寺をピン＆リスト表示する。
struct NearbyView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var location: LocationService
    @Environment(\.openURL) private var openURL

    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(center: .init(latitude: 35.681, longitude: 139.767),
                           span: .init(latitudeDelta: 0.8, longitudeDelta: 0.8)))
    @State private var region = MKCoordinateRegion(
        center: .init(latitude: 35.681, longitude: 139.767),
        span: .init(latitudeDelta: 0.8, longitudeDelta: 0.8))
    @State private var goriyakuFilter: String? = nil
    @State private var shrineOnly = false
    @State private var searchText = ""
    /// 表示中の地図範囲にある社寺（中心から近い順）。
    /// 地図カメラ・フィルタの変更時のみ再計算するキャッシュ（body評価ごとの再計算を避ける）。
    @State private var visible: [(Shrine, Double)] = []
    /// 初回の現在地取得時だけ地図をセンタリングする（以降はユーザーのパン操作を上書きしない）
    @State private var hasCenteredOnUser = false
    @State private var showsLocationDeniedAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("行き先を入力（例: 出雲、京都、高尾山）", text: $searchText)
                        .submitLabel(.search)
                        .onSubmit { goTo(searchText) }
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
                .padding(.horizontal).padding(.vertical, 8)

                Map(position: $camera) {
                    UserAnnotation()
                    ForEach(visible.prefix(120).map(\.0)) { s in
                        Marker(s.name, systemImage: s.isShrine ? "leaf.fill" : "building.columns.fill",
                               coordinate: s.coordinate)
                            .tint(s.isShrine ? toriiRed : .blue)
                    }
                }
                .onMapCameraChange(frequency: .onEnd) { ctx in
                    region = ctx.region
                    updateVisible()
                }
                .frame(height: 300)

                filters

                if visible.isEmpty {
                    ContentUnavailableView("この範囲に社寺がありません",
                        systemImage: "mappin.slash",
                        description: Text("地図を移動・縮小すると、その範囲の社寺が表示されます。"))
                        .frame(maxHeight: .infinity)
                } else {
                    List(visible, id: \.0.id) { item in
                        NavigationLink(value: item.0) {
                            ShrineRow(shrine: item.0, highlight: goriyakuFilter, distance: item.1)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("地図でさがす")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { locateTapped() } label: { Image(systemName: "location") }
                }
            }
            .navigationDestination(for: Shrine.self) { ShrineDetailView(shrine: $0) }
            .navigationDestination(for: Deity.self) { DeityDetailView(deity: $0) }
            .task {
                location.request()
                updateVisible()
            }
            .onChange(of: goriyakuFilter) { _, _ in updateVisible() }
            .onChange(of: shrineOnly) { _, _ in updateVisible() }
            .onChange(of: location.coordinate?.latitude) { _, _ in
                // 初回の位置取得時のみセンタリング（以降はユーザーの操作を優先）
                guard !hasCenteredOnUser, location.currentLocation != nil else { return }
                hasCenteredOnUser = true
                focusOnCurrent()
            }
            .alert("位置情報が許可されていません", isPresented: $showsLocationDeniedAlert) {
                Button("設定を開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("設定アプリで位置情報を許可してください。")
            }
        }
    }

    private var filters: some View {
        HStack {
            Menu {
                Button("すべてのご利益") { goriyakuFilter = nil }
                ForEach(store.goriyaku) { g in
                    Button(g.name) { goriyakuFilter = g.slug }
                }
            } label: {
                Label(goriyakuFilter.flatMap { store.goriyaku($0)?.name } ?? "ご利益で絞る",
                      systemImage: "line.3.horizontal.decrease.circle")
                    .font(.subheadline)
            }
            Spacer()
            Text("\(visible.count)件").font(.caption).foregroundStyle(.secondary)
            Spacer()
            Toggle("神社のみ", isOn: $shrineOnly).font(.subheadline).fixedSize()
        }
        .padding(.horizontal).padding(.vertical, 8)
    }

    /// 表示範囲の社寺を再計算する（地図カメラ・フィルタ変更時に呼ぶ）
    private func updateVisible() {
        let c = region.center, s = region.span
        let center = CLLocation(latitude: c.latitude, longitude: c.longitude)
        visible = store.shrines(
            latMin: c.latitude - s.latitudeDelta/2,  latMax: c.latitude + s.latitudeDelta/2,
            lngMin: c.longitude - s.longitudeDelta/2, lngMax: c.longitude + s.longitudeDelta/2,
            center: center, goriyaku: goriyakuFilter, type: shrineOnly ? "shrine" : nil, limit: 200)
    }

    /// 現在地ボタン：取得済みならセンタリング、拒否なら設定への導線、未確定なら許可を要求
    private func locateTapped() {
        if location.currentLocation != nil {
            focusOnCurrent()
        } else if location.isDenied {
            showsLocationDeniedAlert = true
        } else {
            location.request()
        }
    }

    private func focusOnCurrent() {
        guard let loc = location.currentLocation else { return }
        setRegion(loc.coordinate, deg: 0.6)
    }

    /// 行き先検索：まず社寺名・地名で一致を探し、無ければ地名をジオコーディングして地図を移動
    private func goTo(_ q: String) {
        let query = q.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        if let s = store.shrines.first(where: {
            $0.name.contains(query) || $0.city.contains(query) || $0.pref.contains(query) }) {
            setRegion(s.coordinate, deg: 0.5); return
        }
        CLGeocoder().geocodeAddressString(query + " 日本") { placemarks, _ in
            guard let loc = placemarks?.first?.location else { return }
            DispatchQueue.main.async { setRegion(loc.coordinate, deg: 0.5) }
        }
    }

    private func setRegion(_ center: CLLocationCoordinate2D, deg: Double) {
        let r = MKCoordinateRegion(center: center, span: .init(latitudeDelta: deg, longitudeDelta: deg))
        withAnimation { camera = .region(r) }
        region = r
        updateVisible()
    }
}
