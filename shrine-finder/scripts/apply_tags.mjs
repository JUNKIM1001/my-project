// 御朱印・テレビ放映タグを appdata.json に適用する（タグファイルが真実・冪等）。
// 入力: data/tags/goshuin.json  [{ slug, source }]            → shrine.goshuin = true
//       data/tags/tv.json       [{ slug, date, program, source }] → shrine.tv = {date,program,source}
// 出力: ios/ShrineFinder/Resources/appdata.json と shrine-finder-web/public/appdata.json（両方）
import { readFileSync, writeFileSync, existsSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))          // shrine-finder/
const WORKSPACE = dirname(ROOT)                                        // Clode code/
const CANON = join(ROOT, 'ios/ShrineFinder/Resources/appdata.json')
const WEB = join(WORKSPACE, 'shrine-finder-web/public/appdata.json')

const readJSON = (p, fallback) => (existsSync(p) ? JSON.parse(readFileSync(p, 'utf8')) : fallback)
const goshuin = readJSON(join(ROOT, 'data/tags/goshuin.json'), [])
const tv = readJSON(join(ROOT, 'data/tags/tv.json'), [])

const data = JSON.parse(readFileSync(CANON, 'utf8'))
const bySlug = Object.fromEntries(data.shrines.map((s) => [s.slug, s]))

// いったん全消し（タグファイルを唯一の真実にするため）
for (const s of data.shrines) { delete s.goshuin; delete s.tv }

let g = 0, t = 0
const missing = []
for (const e of goshuin) {
  const s = bySlug[e.slug]
  if (!s) { missing.push(`goshuin:${e.slug}`); continue }
  s.goshuin = true
  if (e.source) s.goshuinSource = e.source
  g++
}
for (const e of tv) {
  const s = bySlug[e.slug]
  if (!s) { missing.push(`tv:${e.slug}`); continue }
  s.tv = { date: e.date, program: e.program || null, source: e.source || null }
  t++
}

const out = JSON.stringify(data)
writeFileSync(CANON, out)
writeFileSync(WEB, out)
console.log(`御朱印 ${g}件 / テレビ ${t}件 を適用。`)
if (missing.length) console.log(`⚠️ 未知スラッグ(${missing.length}): ${missing.join(', ')}`)
console.log(`書き込み: ${CANON}\n         ${WEB}`)
