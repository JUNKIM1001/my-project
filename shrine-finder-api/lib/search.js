// 検索の中核ロジック（API_SPEC §2.1, §3）。HTTP から切り離してテスト可能にしている。
import { getData } from './data.js'
import { resolvePref, resolveCity } from './area.js'
import { coarse, distanceM } from './geo.js'
import { toShrine, tvActive, ATTRIBUTION } from './serialize.js'

export class InvalidParam extends Error {}

const num = (v, name) => {
  if (v == null || v === '') return null
  const n = Number(v)
  if (!Number.isFinite(n)) throw new InvalidParam(`${name} は数値で指定してください（指定値: ${v}）`)
  return n
}
const bool = (v) => v === 'true' || v === '1'

/**
 * @param {URLSearchParams} q
 * @param {Date} now テスト用に現在時刻を差し替えられるようにしている
 */
export function search(q, now = new Date()) {
  const data = getData()

  // --- 座標 ---
  let lat = num(q.get('lat'), 'lat')
  let lng = num(q.get('lng'), 'lng')
  if ((lat == null) !== (lng == null)) {
    throw new InvalidParam('lat と lng は両方指定してください')
  }
  if (lat != null) {
    if (lat < -90 || lat > 90) throw new InvalidParam(`lat は -90〜90 で指定してください（指定値: ${lat}）`)
    if (lng < -180 || lng > 180) throw new InvalidParam(`lng は -180〜180 で指定してください（指定値: ${lng}）`)
    // プライバシー方針: 受け取った座標は必ず丸める（DESIGN §5）
    lat = coarse(lat)
    lng = coarse(lng)
  }

  const radiusKm = num(q.get('radius_km'), 'radius_km') ?? 10
  if (lat != null && (radiusKm <= 0 || radiusKm > 50)) {
    throw new InvalidParam(`radius_km は 0 より大きく 50 以下で指定してください（指定値: ${radiusKm}）`)
  }

  // --- ページング ---
  const limit = Math.trunc(num(q.get('limit'), 'limit') ?? 20)
  if (limit < 1 || limit > 100) throw new InvalidParam(`limit は 1〜100 で指定してください（指定値: ${limit}）`)
  const offset = Math.trunc(num(q.get('offset'), 'offset') ?? 0)
  if (offset < 0) throw new InvalidParam(`offset は 0 以上で指定してください（指定値: ${offset}）`)

  // --- 地域の解決 ---
  let candidates = data.shrines
  let resolvedArea = null
  let notice = null
  const prefIn = q.get('pref')
  const cityIn = q.get('city')

  if (prefIn) {
    const pref = resolvePref(prefIn, new Set(data.byPref.keys()))
    if (!pref) throw new InvalidParam(`pref を解決できません（指定値: ${prefIn}）`)
    candidates = data.byPref.get(pref)
    resolvedArea = { pref, city: null, match: 'pref_only' }

    if (cityIn) {
      const r = resolveCity(cityIn, data.cityNames.get(pref))
      if (r.cities.length > 0) {
        const set = new Set(r.cities)
        candidates = candidates.filter((s) => set.has(s.city))
        resolvedArea = { pref, city: cityIn, match: r.match }
      } else {
        resolvedArea = { pref, city: null, match: 'pref_only' }
        notice = `市区町村「${cityIn}」を特定できなかったため、${pref}全体の結果を返しています。`
      }
    }
  } else if (cityIn) {
    throw new InvalidParam('city を指定する場合は pref も指定してください')
  }

  // --- 絞り込み ---
  const type = q.get('type')
  if (type && type !== 'shrine' && type !== 'temple') {
    throw new InvalidParam(`type は shrine か temple を指定してください（指定値: ${type}）`)
  }
  const goriyaku = q.get('goriyaku')
  if (goriyaku && !data.goriyakuIds.has(goriyaku)) {
    throw new InvalidParam(`未知の goriyaku です（指定値: ${goriyaku}）。/v1/goriyaku で一覧を取得できます。`)
  }
  const wantGoshuin = bool(q.get('goshuin'))
  const wantNT = bool(q.get('national_treasure'))
  const wantTV = bool(q.get('tv'))
  const text = (q.get('q') || '').trim()

  let list = candidates.filter((s) => {
    if (type && s.type !== type) return false
    if (goriyaku && !s.goriyaku.some((g) => g.id === goriyaku)) return false
    if (wantGoshuin && !s.goshuin) return false
    if (wantNT && !s.national_treasure) return false
    if (wantTV && !tvActive(s.tv, now)) return false
    if (text && !s.name.includes(text) && !s.kana.includes(text)) return false
    return true
  })

  // --- 並び順・距離 ---
  const orderIn = q.get('order')
  if (orderIn && orderIn !== 'distance' && orderIn !== 'name') {
    throw new InvalidParam(`order は distance か name を指定してください（指定値: ${orderIn}）`)
  }
  if (orderIn === 'distance' && lat == null) {
    throw new InvalidParam('order=distance は lat/lng の指定が必要です')
  }
  const order = orderIn ?? (lat != null ? 'distance' : 'name')

  let withDist
  if (lat != null) {
    const origin = { lat, lng }
    const maxM = radiusKm * 1000
    withDist = []
    for (const s of list) {
      const d = distanceM(origin, s)
      if (d <= maxM) withDist.push([s, d])
    }
    if (order === 'distance') withDist.sort((a, b) => a[1] - b[1])
    else withDist.sort((a, b) => a[0].kana.localeCompare(b[0].kana, 'ja'))
  } else {
    withDist = list
      .slice()
      .sort((a, b) => a.kana.localeCompare(b.kana, 'ja'))
      .map((s) => [s, null])
  }

  const total = withDist.length
  const page = withDist.slice(offset, offset + limit)

  const meta = {
    total,
    limit,
    offset,
    order,
    ...(resolvedArea ? { resolved_area: resolvedArea } : {}),
    ...(lat != null ? { location_precision: '~1km' } : {}),
    ...(notice ? { notice } : {}),
    data_version: data.data_version,
  }

  return {
    meta,
    shrines: page.map(([s, d]) => toShrine(s, d, now)),
    attribution: ATTRIBUTION,
  }
}
