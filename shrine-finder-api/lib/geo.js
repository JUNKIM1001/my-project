// 位置情報の扱い（API_SPEC §1.1, §3.2 / DESIGN §5）
//
// プライバシー方針: 受け取った座標は必ず小数第2位（約1km四方）に丸め、
// 丸めた値だけを処理に使う。生の座標は保持もログ出力もしない。

/** 座標を小数第2位に丸める（≒1.1km四方）。 */
export const coarse = (v) => Math.round(v * 100) / 100

const R = 6371000 // 地球半径(m)
const rad = (x) => (x * Math.PI) / 180

/** 2地点間の距離（メートル）。Haversine式。 */
export function distanceM(a, b) {
  const dLat = rad(b.lat - a.lat)
  const dLng = rad(b.lng - a.lng)
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2
  return R * 2 * Math.asin(Math.sqrt(h))
}
