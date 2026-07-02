import Foundation
import CoreLocation

/// 現在地を取得する薄いラッパ。許可が無い／未取得の場合は nil。
@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var authorization: CLAuthorizationStatus = .notDetermined
    /// 直近の位置取得エラー（取得に成功したらクリア）
    @Published var lastError: Error?

    private let manager = CLLocationManager()

    /// 位置情報の利用が拒否・制限されているか（設定アプリへの導線表示用）
    var isDenied: Bool {
        authorization == .denied || authorization == .restricted
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorization = manager.authorizationStatus
    }

    func request() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
        default: break
        }
    }

    var currentLocation: CLLocation? {
        coordinate.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorization = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.coordinate = loc.coordinate
            self.lastError = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in self.lastError = error }
    }
}
