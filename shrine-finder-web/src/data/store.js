// データストア（iOS版 DataStore と同一ロジック）。appdata.json を読み込み検索クエリを提供。

// 47都道府県の地理順（北→南）。フィルタの表示順に使う。
const PREF_ORDER = [
  '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
  '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
  '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県',
  '岐阜県', '静岡県', '愛知県', '三重県',
  '滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県',
  '鳥取県', '島根県', '岡山県', '広島県', '山口県',
  '徳島県', '香川県', '愛媛県', '高知県',
  '福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県',
]

const RECOMMENDED = [
  'ise-jingu-naiku', 'izumo-taisha', 'fushimi-inari-taisha', 'meiji-jingu',
  'itsukushima-jinja', 'kiyomizu-dera', 'kasuga-taisha', 'dazaifu-tenmangu',
  'nikko-toshogu', 'senso-ji', 'fujisan-hongu-sengen', 'kumano-hongu-taisha',
]

export function haversine(a, b) {
  const R = 6371000, d = (x) => (x * Math.PI) / 180
  const dla = d(b.lat - a.lat), dlo = d(b.lng - a.lng)
  const h = Math.sin(dla / 2) ** 2 + Math.cos(d(a.lat)) * Math.cos(d(b.lat)) * Math.sin(dlo / 2) ** 2
  return R * 2 * Math.asin(Math.sqrt(h))
}

export function distanceLabel(m) {
  return m >= 1000 ? `${(m / 1000).toFixed(1)}km` : `${Math.round(m)}m`
}

// 検索用正規化：カタカナ→ひらがな + 小文字化（カタカナ入力でもかなにヒットさせる）
export function normalizeQuery(str) {
  return (str || '')
    .replace(/[ァ-ヶ]/g, (c) => String.fromCharCode(c.charCodeAt(0) - 0x60))
    .toLowerCase()
}

const HTTP = /^https?:\/\//i
export const safeURL = (u) => (u && HTTP.test(u) ? u : null)

export function isNationalTreasure(s) { return s.nt === true }
export function isShrine(s) { return s.type === 'shrine' }
export function typeLabel(s) { return isShrine(s) ? '神社' : '寺' }
export function deityRoleLabel(s) { return isShrine(s) ? '御祭神' : '本尊' }

export function createStore(data) {
  const { goriyaku, deities, shrines } = data
  const goriyakuBySlug = Object.fromEntries(goriyaku.map((g) => [g.slug, g]))
  const deityBySlug = Object.fromEntries(deities.map((d) => [d.slug, d]))
  const bySlug = Object.fromEntries(shrines.map((s) => [s.slug, s]))

  // 社寺ごとのご利益：社寺固有の明示分を先頭に、御祭神/本尊由来の導出分との和集合
  const shrineGoriyaku = {}
  // 検索用の正規化済みテキスト（名前・かな・通称・都道府県・市区町村）
  const searchText = {}
  for (const s of shrines) {
    const seen = new Set(), arr = []
    for (const g of s.goriyaku || [])
      if (!seen.has(g)) { seen.add(g); arr.push(g) }
    for (const ds of s.deities)
      for (const g of deityBySlug[ds]?.goriyaku || [])
        if (!seen.has(g)) { seen.add(g); arr.push(g) }
    shrineGoriyaku[s.slug] = arr
    searchText[s.slug] = normalizeQuery(
      `${s.name}\n${s.kana || ''}\n${(s.aliases || []).join('\n')}\n${s.pref}\n${s.city}`
    )
  }

  // ご利益 → 社寺の逆引きインデックス（一度だけ構築）
  const shrinesByGoriyaku = new Map(goriyaku.map((g) => [g.slug, []]))
  for (const s of shrines)
    for (const g of shrineGoriyaku[s.slug])
      shrinesByGoriyaku.get(g)?.push(s)
  const goriyakuCounts = goriyaku
    .map((g) => [g, shrinesByGoriyaku.get(g.slug).length])
    .filter(([, c]) => c > 0)
    .sort((a, b) => b[1] - a[1])

  // データに存在する都道府県のみ、地理順（北→南）の固定配列で保持
  const prefSet = new Set(shrines.map((s) => s.pref))
  const prefectures = PREF_ORDER.filter((p) => prefSet.has(p))

  const goriyakuSlugsOf = (s) => shrineGoriyaku[s.slug] || []
  const deitiesOf = (s) => s.deities.map((d) => deityBySlug[d]).filter(Boolean)
  const names = (slugs) => slugs.map((g) => goriyakuBySlug[g]).filter(Boolean)

  return {
    goriyaku, deities, shrines, goriyakuBySlug, deityBySlug, bySlug, prefectures,
    goriyakuName: (slug) => goriyakuBySlug[slug]?.name || slug,
    deity: (slug) => deityBySlug[slug],
    shrine: (slug) => bySlug[slug],
    deitiesOf, goriyakuSlugsOf, names,

    shrinesForGoriyaku: (slug) => shrinesByGoriyaku.get(slug) || [],
    deitiesForGoriyaku: (slug) => deities.filter((d) => d.goriyaku.includes(slug)),
    shrinesEnshrining: (deitySlug) => shrines.filter((s) => s.deities.includes(deitySlug)),

    goriyakuCounts: () => goriyakuCounts,

    nationalTreasureCount: () => shrines.filter(isNationalTreasure).length,
    prefectureCount: () => new Set(shrines.map((s) => s.pref)).size,

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

    search(query, { type = null, ntOnly = false, pref = null, origin = null } = {}) {
      const q = normalizeQuery((query || '').trim())
      let list = shrines.filter(
        (s) =>
          (type == null || s.type === type) &&
          (!ntOnly || isNationalTreasure(s)) &&
          (pref == null || s.pref === pref) &&
          (q === '' || searchText[s.slug].includes(q))
      )
      if (origin) return list.map((s) => [s, haversine(origin, s)]).sort((a, b) => a[1] - b[1])
      list = list.slice().sort((a, b) => (a.kana || '').localeCompare(b.kana || '', 'ja'))
      return list.map((s) => [s, null])
    },

    recommended(origin) {
      const list = RECOMMENDED.map((slug) => bySlug[slug]).filter(Boolean)
      if (!origin) return list
      return list.slice().sort((a, b) => haversine(origin, a) - haversine(origin, b))
    },

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
  if (!res.ok) throw new Error(`appdata.json の取得に失敗しました (HTTP ${res.status})`)
  const data = await res.json()
  return createStore(data)
}
