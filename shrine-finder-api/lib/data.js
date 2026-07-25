// データ読み込みと索引の構築（DESIGN §3.2）
// コールドスタート時に1回だけ構築し、以降のリクエストで使い回す。
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))

let cache = null

export function getData() {
  if (cache) return cache

  const raw = JSON.parse(readFileSync(join(ROOT, 'data/api-data.json'), 'utf8'))

  const byId = new Map(raw.shrines.map((s) => [s.id, s]))
  const byPref = new Map()
  for (const s of raw.shrines) {
    if (!byPref.has(s.pref)) byPref.set(s.pref, [])
    byPref.get(s.pref).push(s)
  }
  // 都道府県ごとの市区町村名一覧（前方一致・部分一致の探索用）
  const cityNames = new Map()
  for (const [pref, list] of byPref) {
    cityNames.set(pref, [...new Set(list.map((s) => s.city))])
  }
  const goriyakuIds = new Set(raw.goriyaku.map((g) => g.id))

  cache = { ...raw, byId, byPref, cityNames, goriyakuIds }
  return cache
}
