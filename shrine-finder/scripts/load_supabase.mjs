// appdata.json を Supabase の goriyaku/deities/shrines テーブルへ upsert する。
// 使い方: SUPABASE_URL=... SUPABASE_SERVICE_KEY=... node scripts/load_supabase.mjs
// service_role キーはサーバー/CLIでのみ使用（アプリには絶対に埋め込まない）。
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const URL = process.env.SUPABASE_URL
const KEY = process.env.SUPABASE_SERVICE_KEY
if (!URL || !KEY) {
  console.error('環境変数 SUPABASE_URL と SUPABASE_SERVICE_KEY を設定してください。')
  process.exit(1)
}
const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))
const data = JSON.parse(readFileSync(join(ROOT, 'ios/ShrineFinder/Resources/appdata.json'), 'utf8'))

const H = { apikey: KEY, Authorization: `Bearer ${KEY}`, 'Content-Type': 'application/json',
            Prefer: 'resolution=merge-duplicates,return=minimal' }

async function upsert(table, rows) {
  for (let i = 0; i < rows.length; i += 500) {
    const chunk = rows.slice(i, i + 500)
    const r = await fetch(`${URL}/rest/v1/${table}?on_conflict=slug`, {
      method: 'POST', headers: H, body: JSON.stringify(chunk),
    })
    if (!r.ok) { console.error(`${table} 投入失敗 (${r.status}):`, await r.text()); process.exit(1) }
    process.stdout.write(`  ${table}: ${Math.min(i + 500, rows.length)}/${rows.length}\r`)
  }
  console.log(`  ${table}: ${rows.length} 件 完了`)
}

const shrineRow = (s) => ({
  slug: s.slug, name: s.name, kana: s.kana, type: s.type, sect: s.sect,
  pref: s.pref, city: s.city, address: s.address, lat: s.lat, lng: s.lng,
  deities: s.deities || [], website: s.website ?? null, description: s.description,
  source: s.source, nt: s.nt === true,
  image_url: s.imageURL ?? null, image_license: s.imageLicense ?? null,
  image_author: s.imageAuthor ?? null, long_description: s.longDescription ?? null,
  goshuin: s.goshuin === true, tv: s.tv ?? null,
})

console.log('Supabaseへ投入開始…')
await upsert('goriyaku', data.goriyaku.map((g, i) => ({ slug: g.slug, name: g.name, icon: g.icon, sort_order: i })))
await upsert('deities', data.deities.map((d) => ({
  slug: d.slug, name: d.name, kana: d.kana, kind: d.kind, category: d.category,
  description: d.description, goriyaku: d.goriyaku || [],
})))
await upsert('shrines', data.shrines.map(shrineRow))

// upsert は削除を反映しないため、appdata.json から消えた行を明示的に削除する。
// これをしないと、重複解消などで削除したデータが Supabase 側に残り続ける。
async function pruneDeleted(table, keepSlugs) {
  // PostgREST は1回のリクエストで最大1000件しか返さないため、必ずページングする
  const remote = []
  for (let from = 0; ; from += 1000) {
    const r = await fetch(`${URL}/rest/v1/${table}?select=slug`, {
      headers: {
        apikey: KEY, Authorization: `Bearer ${KEY}`,
        'Range-Unit': 'items', Range: `${from}-${from + 999}`,
      },
    })
    if (!r.ok) { console.error(`${table} の既存slug取得に失敗 (${r.status})`); return }
    const batch = await r.json()
    remote.push(...batch.map((x) => x.slug))
    if (batch.length < 1000) break
  }
  const stale = remote.filter((s) => !keepSlugs.has(s))
  if (!stale.length) { console.log(`  ${table}: 削除対象なし`); return }
  for (let i = 0; i < stale.length; i += 100) {
    const chunk = stale.slice(i, i + 100)
    const list = chunk.map((s) => `"${s}"`).join(',')
    const d = await fetch(`${URL}/rest/v1/${table}?slug=in.(${encodeURIComponent(list)})`, {
      method: 'DELETE', headers: H,
    })
    if (!d.ok) { console.error(`${table} の削除に失敗 (${d.status}):`, await d.text()); process.exit(1) }
  }
  console.log(`  ${table}: ${stale.length} 件を削除（${stale.slice(0, 5).join(', ')}${stale.length > 5 ? ' …' : ''}）`)
}

console.log('ローカルから消えた行を削除中…')
await pruneDeleted('shrines', new Set(data.shrines.map((s) => s.slug)))
await pruneDeleted('deities', new Set(data.deities.map((d) => d.slug)))
await pruneDeleted('goriyaku', new Set(data.goriyaku.map((g) => g.slug)))
console.log('✅ 全データ投入完了')
