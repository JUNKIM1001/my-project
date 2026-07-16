// データストア（iOS版 DataStore と同一ロジック）。appdata.json を読み込み検索クエリを提供。

const RECOMMENDED = [
  'ise-jingu-naiku', 'izumo-taisha', 'fushimi-inari-taisha', 'meiji-jingu',
  'itsukushima-jinja', 'kiyomizu-dera', 'kasuga-taisha', 'dazaifu-tenmangu',
  'nikko-toshogu', 'senso-ji', 'fujisan-hongu-sengen', 'kumano-hongu-taisha',
]

// 8地方区分（北→南）。地域から探す画面のグルーピングと表示順。
export const REGIONS = [
  { name: '北海道', prefs: ['北海道'] },
  { name: '東北', prefs: ['青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県'] },
  { name: '関東', prefs: ['茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県'] },
  { name: '中部', prefs: ['新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県', '静岡県', '愛知県'] },
  { name: '近畿', prefs: ['三重県', '滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県'] },
  { name: '中国', prefs: ['鳥取県', '島根県', '岡山県', '広島県', '山口県'] },
  { name: '四国', prefs: ['徳島県', '香川県', '愛媛県', '高知県'] },
  { name: '九州・沖縄', prefs: ['福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'] },
]

function haversine(a, b) {
  const R = 6371000, d = (x) => (x * Math.PI) / 180
  const dla = d(b.lat - a.lat), dlo = d(b.lng - a.lng)
  const h = Math.sin(dla / 2) ** 2 + Math.cos(d(a.lat)) * Math.cos(d(b.lat)) * Math.sin(dlo / 2) ** 2
  return R * 2 * Math.asin(Math.sqrt(h))
}

export function distanceLabel(m) {
  return m >= 1000 ? `${(m / 1000).toFixed(1)}km` : `${Math.round(m)}m`
}

const HTTP = /^https?:\/\//i
export const safeURL = (u) => (u && HTTP.test(u) ? u : null)

export function isNationalTreasure(s) { return s.nt === true }
export function hasGoshuin(s) { return s.goshuin === true }

// テレビ放映が「1年以内」か（放映日が「1年前の同日」以降〜今日まで）。
// 暦日で判定（タイムゾーン非依存の YYYY-MM-DD 文字列比較）。実行時の現在日で
// 判定するので、1年経過すると自動的にバッジが消える。未来日は非表示。
const ymd = (d) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
export function tvAiredDate(s) {
  const t = s.tv && s.tv.date ? Date.parse(s.tv.date) : NaN
  return Number.isNaN(t) ? null : t
}
export function tvActive(s, now = new Date()) {
  const d = s.tv && s.tv.date
  if (!d || !/^\d{4}-\d{2}-\d{2}$/.test(d)) return false
  const today = ymd(now)
  const cutoff = ymd(new Date(now.getFullYear() - 1, now.getMonth(), now.getDate()))
  return d >= cutoff && d <= today
}
export function isShrine(s) { return s.type === 'shrine' }
export function typeLabel(s) { return isShrine(s) ? '神社' : '寺' }
export function deityRoleLabel(s) { return isShrine(s) ? '御祭神' : '本尊' }

export function createStore(data) {
  const { goriyaku, deities, shrines } = data
  const goriyakuBySlug = Object.fromEntries(goriyaku.map((g) => [g.slug, g]))
  const deityBySlug = Object.fromEntries(deities.map((d) => [d.slug, d]))
  const bySlug = Object.fromEntries(shrines.map((s) => [s.slug, s]))

  // 社寺ごとの導出ご利益（御祭神/本尊が司るご利益の和集合）
  const shrineGoriyaku = {}
  for (const s of shrines) {
    const seen = new Set(), arr = []
    for (const ds of s.deities)
      for (const g of deityBySlug[ds]?.goriyaku || [])
        if (!seen.has(g)) { seen.add(g); arr.push(g) }
    shrineGoriyaku[s.slug] = arr
  }

  const goriyakuSlugsOf = (s) => shrineGoriyaku[s.slug] || []
  const deitiesOf = (s) => s.deities.map((d) => deityBySlug[d]).filter(Boolean)
  const names = (slugs) => slugs.map((g) => goriyakuBySlug[g]).filter(Boolean)

  return {
    goriyaku, deities, shrines, goriyakuBySlug, deityBySlug, bySlug,
    goriyakuName: (slug) => goriyakuBySlug[slug]?.name || slug,
    deity: (slug) => deityBySlug[slug],
    shrine: (slug) => bySlug[slug],
    deitiesOf, goriyakuSlugsOf, names,

    shrinesForGoriyaku: (slug) => shrines.filter((s) => goriyakuSlugsOf(s).includes(slug)),
    deitiesForGoriyaku: (slug) => deities.filter((d) => d.goriyaku.includes(slug)),
    shrinesEnshrining: (deitySlug) => shrines.filter((s) => s.deities.includes(deitySlug)),

    goriyakuCounts() {
      return goriyaku
        .map((g) => [g, shrines.filter((s) => goriyakuSlugsOf(s).includes(g.slug)).length])
        .filter(([, c]) => c > 0)
        .sort((a, b) => b[1] - a[1])
    },

    nationalTreasureCount: () => shrines.filter(isNationalTreasure).length,
    prefectureCount: () => new Set(shrines.map((s) => s.pref)).size,

    // 都道府県ごとの社寺件数 { '北海道': 12, ... }
    prefCounts() {
      const m = {}
      for (const s of shrines) m[s.pref] = (m[s.pref] || 0) + 1
      return m
    },

    // ある都道府県の社寺一覧。origin があれば近い順、無ければ市区町村→よみ順。
    shrinesInPref(pref, origin = null) {
      const list = shrines.filter((s) => s.pref === pref)
      if (origin) return list.map((s) => [s, haversine(origin, s)]).sort((a, b) => a[1] - b[1])
      return list
        .slice()
        .sort(
          (a, b) =>
            (a.city || '').localeCompare(b.city || '', 'ja') ||
            (a.kana || '').localeCompare(b.kana || '', 'ja')
        )
        .map((s) => [s, null])
    },

    nearby(origin, { goriyaku: g = null, type = null } = {}) {
      return shrines
        .filter((s) => (g == null || goriyakuSlugsOf(s).includes(g)) && (type == null || s.type === type))
        .map((s) => [s, haversine(origin, s)])
        .sort((a, b) => a[1] - b[1])
    },

    shrinesInBounds({ latMin, latMax, lngMin, lngMax, center, goriyaku: g = null, type = null, limit = 200 }) {
      const out = []
      for (const s of shrines) {
        if (s.lat < latMin || s.lat > latMax || s.lng < lngMin || s.lng > lngMax) continue
        if (type && s.type !== type) continue
        if (g && !goriyakuSlugsOf(s).includes(g)) continue
        out.push([s, center ? haversine(center, s) : 0])
      }
      out.sort((a, b) => a[1] - b[1])
      return out.slice(0, limit)
    },

    related(shrine, limit = 8) {
      const gset = new Set(goriyakuSlugsOf(shrine))
      const dset = new Set(shrine.deities)
      const scored = []
      for (const s of shrines) {
        if (s.slug === shrine.slug) continue
        let score = s.deities.filter((d) => dset.has(d)).length * 4
        score += goriyakuSlugsOf(s).filter((g) => gset.has(g)).length
        if (shrine.sect && s.sect === shrine.sect) score += 2
        if (s.pref === shrine.pref) score += 1
        if (score > 0) scored.push([s, score, haversine(shrine, s)])
      }
      scored.sort((a, b) => (a[1] !== b[1] ? b[1] - a[1] : a[2] - b[2]))
      return scored.slice(0, limit).map((x) => x[0])
    },

    search(query, { type = null, ntOnly = false, goshuinOnly = false, tvOnly = false, origin = null } = {}) {
      const q = (query || '').trim()
      let list = shrines.filter(
        (s) =>
          (type == null || s.type === type) &&
          (!ntOnly || isNationalTreasure(s)) &&
          (!goshuinOnly || hasGoshuin(s)) &&
          (!tvOnly || tvActive(s)) &&
          (q === '' || s.name.includes(q) || (s.kana || '').includes(q) || s.pref.includes(q) || s.city.includes(q))
      )
      if (origin) return list.map((s) => [s, haversine(origin, s)]).sort((a, b) => a[1] - b[1])
      list = list.slice().sort((a, b) => (a.kana || '').localeCompare(b.kana || ''))
      return list.map((s) => [s, null])
    },

    recommended(origin) {
      const list = RECOMMENDED.map((slug) => bySlug[slug]).filter(Boolean)
      if (!origin) return list
      return list.slice().sort((a, b) => haversine(origin, a) - haversine(origin, b))
    },

    // 直近1年にテレビ放映された社寺（放映日の新しい順）。1年経過分は自動的に外れる。
    tvFeatured(now = new Date()) {
      return shrines
        .filter((s) => tvActive(s, now))
        .sort((a, b) => tvAiredDate(b) - tvAiredDate(a))
    },

    goshuinCount: () => shrines.filter(hasGoshuin).length,

    imageCredit(s) {
      if (!s.imageURL) return null
      const who = s.imageAuthor || 'Wikimedia Commons'
      return `写真: ${who} / ${s.imageLicense || 'Wikimedia'}`
    },
    dist: haversine,
  }
}

export async function loadStore() {
  const res = await fetch(`${import.meta.env.BASE_URL}appdata.json`)
  const data = await res.json()
  return createStore(data)
}
