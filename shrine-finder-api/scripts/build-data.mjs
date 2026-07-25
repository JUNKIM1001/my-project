// appdata.json（または Supabase）から、API が返す形に絞ったデータを生成する。
//
//   node scripts/build-data.mjs
//
// 重要: 長文解説(long_description)は Wikipedia 由来(CC BY-SA)のため
// **意図的に出力しない**。利用者にライセンス継承義務を負わせないため（API_SPEC §1.3）。
//
// 既定ではリポジトリ同梱の appdata.json を読む。SUPABASE_URL / SUPABASE_ANON_KEY が
// 設定されていればそちらを優先する（本番ビルド時）。
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))
const LOCAL_APPDATA = join(ROOT, '../shrine-finder/ios/ShrineFinder/Resources/appdata.json')
const OUT_DIR = join(ROOT, 'data')
const OUT = join(OUT_DIR, 'api-data.json')

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY

/** 8地方区分（北→南）。/v1/areas の並び順に使う。 */
const REGIONS = [
  { name: '北海道', prefs: ['北海道'] },
  { name: '東北', prefs: ['青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県'] },
  { name: '関東', prefs: ['茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県'] },
  { name: '中部', prefs: ['新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県', '静岡県', '愛知県'] },
  { name: '近畿', prefs: ['三重県', '滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県'] },
  { name: '中国', prefs: ['鳥取県', '島根県', '岡山県', '広島県', '山口県'] },
  { name: '四国', prefs: ['徳島県', '香川県', '愛媛県', '高知県'] },
  { name: '九州・沖縄', prefs: ['福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'] },
]

const DETAIL_BASE = 'https://omairi-navi.vercel.app/shrine/'
const httpOnly = (u) => (typeof u === 'string' && /^https?:\/\//i.test(u) ? u : null)

async function fetchFromSupabase() {
  const headers = { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` }
  const all = async (path) => {
    const r = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, { headers })
    if (!r.ok) throw new Error(`${path}: ${r.status}`)
    return r.json()
  }
  const goriyaku = await all('goriyaku?select=*&order=sort_order')
  const deities = await all('deities?select=*')
  const shrines = []
  for (let from = 0; ; from += 1000) {
    const r = await fetch(`${SUPABASE_URL}/rest/v1/shrines?select=*`, {
      headers: { ...headers, 'Range-Unit': 'items', Range: `${from}-${from + 999}` },
    })
    if (!r.ok) throw new Error(`shrines: ${r.status}`)
    const batch = await r.json()
    shrines.push(...batch)
    if (batch.length < 1000) break
  }
  // Supabase の列名(snake_case)を appdata.json 形式に寄せる
  return {
    goriyaku,
    deities,
    shrines: shrines.map((s) => ({
      ...s,
      imageURL: s.image_url ?? null,
      imageLicense: s.image_license ?? null,
      imageAuthor: s.image_author ?? null,
    })),
  }
}

function loadSource() {
  if (SUPABASE_URL && SUPABASE_KEY) {
    console.log('Supabase から取得します…')
    return fetchFromSupabase()
  }
  console.log('同梱 appdata.json から生成します…')
  return JSON.parse(readFileSync(LOCAL_APPDATA, 'utf8'))
}

const src = await loadSource()

const goriyakuById = Object.fromEntries(src.goriyaku.map((g) => [g.slug, g]))
const deityById = Object.fromEntries(src.deities.map((d) => [d.slug, d]))

// 社寺ごとの導出ご利益（祀る神仏が司るご利益の和集合）を先に計算しておく
function goriyakuOf(shrine) {
  const seen = new Set()
  const out = []
  for (const ds of shrine.deities || []) {
    for (const g of deityById[ds]?.goriyaku || []) {
      if (!seen.has(g) && goriyakuById[g]) {
        seen.add(g)
        out.push({ id: g, name: goriyakuById[g].name })
      }
    }
  }
  return out
}

const shrines = src.shrines.map((s) => ({
  id: s.slug,
  name: s.name,
  kana: s.kana,
  type: s.type,
  sect: s.sect || null,
  pref: s.pref,
  city: s.city,
  address: s.address,
  lat: s.lat,
  lng: s.lng,
  summary: s.description, // 自作の短い紹介文。長文解説は出力しない
  deities: (s.deities || [])
    .map((id) => deityById[id])
    .filter(Boolean)
    .map((d) => ({ id: d.slug, name: d.name, kind: d.kind })),
  goriyaku: goriyakuOf(s),
  national_treasure: s.nt === true,
  goshuin: s.goshuin === true,
  tv: s.tv ?? null, // 1年判定は実行時に行う（時間経過で自動的に落ちる）
  website: httpOnly(s.website),
  wikipedia: httpOnly(s.source),
  detail: DETAIL_BASE + s.slug,
  image: httpOnly(s.imageURL)
    ? { url: httpOnly(s.imageURL), license: s.imageLicense || null, author: s.imageAuthor || null }
    : null,
}))

// ご利益ごとの件数
const goriyakuCounts = {}
for (const s of shrines) for (const g of s.goriyaku) goriyakuCounts[g.id] = (goriyakuCounts[g.id] || 0) + 1

// 地域索引（都道府県 → 市区町村 → 件数）
const areas = {}
for (const s of shrines) {
  const a = (areas[s.pref] ||= { count: 0, cities: {} })
  a.count++
  a.cities[s.city] = (a.cities[s.city] || 0) + 1
}

const out = {
  data_version: new Date().toISOString().slice(0, 10),
  regions: REGIONS,
  shrines,
  goriyaku: src.goriyaku
    .map((g) => ({ id: g.slug, name: g.name, count: goriyakuCounts[g.slug] || 0 }))
    .filter((g) => g.count > 0)
    .sort((a, b) => b.count - a.count),
  areas,
  counts: {
    shrines: shrines.length,
    deities: src.deities.length,
    goriyaku: src.goriyaku.length,
    prefectures: Object.keys(areas).length,
    national_treasure: shrines.filter((s) => s.national_treasure).length,
    goshuin: shrines.filter((s) => s.goshuin).length,
  },
}

// 長文解説が混入していないことを検査（ライセンス方針の自動チェック）
const leaked = JSON.stringify(out).includes('longDescription') ||
  JSON.stringify(out).includes('long_description')
if (leaked) {
  console.error('❌ 長文解説が出力に混入しています。CC BY-SA の配布方針に反するため中止します。')
  process.exit(1)
}

mkdirSync(OUT_DIR, { recursive: true })
writeFileSync(OUT, JSON.stringify(out))
const kb = (Buffer.byteLength(JSON.stringify(out)) / 1024).toFixed(0)
console.log(`✅ ${OUT} を生成（${out.counts.shrines}社寺 / ${kb}KB / data_version=${out.data_version}）`)
