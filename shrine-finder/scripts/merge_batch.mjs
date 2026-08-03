// 日次追加バッチ: 収集した社寺データを appdata.json に安全に取り込む。
//
//   node scripts/merge_batch.mjs data/batches/2026-08-03-kansai.json          確認のみ
//   node scripts/merge_batch.mjs data/batches/2026-08-03-kansai.json --apply  取り込む
//
// 取り込み前に必ず検査し、既存と重複する候補や不備のある候補は**取り込まずに弾く**。
// これにより、追加を重ねても不良データが累積しない。
import { readFileSync, writeFileSync, copyFileSync, existsSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))
const CANON = join(ROOT, 'ios/ShrineFinder/Resources/appdata.json')
const WEB = join(dirname(ROOT), 'shrine-finder-web/public/appdata.json')

const file = process.argv[2]
const apply = process.argv.includes('--apply')
if (!file) {
  console.error('使い方: node scripts/merge_batch.mjs <バッチJSON> [--apply]')
  process.exit(1)
}
if (!existsSync(file)) {
  console.error(`ファイルが見つかりません: ${file}`)
  process.exit(1)
}

const data = JSON.parse(readFileSync(CANON, 'utf8'))
const batch = JSON.parse(readFileSync(file, 'utf8'))
const incoming = Array.isArray(batch) ? batch : batch.shrines
if (!Array.isArray(incoming)) {
  console.error('バッチJSONは配列、または {"shrines": [...]} の形式にしてください')
  process.exit(1)
}

const deitySlugs = new Set(data.deities.map((d) => d.slug))
const existingSlugs = new Set(data.shrines.map((s) => s.slug))
const existingKeys = new Set(data.shrines.map((s) => `${s.name}|${s.lat.toFixed(4)},${s.lng.toFixed(4)}`))
const existingCoords = new Set(data.shrines.map((s) => `${s.lat.toFixed(4)},${s.lng.toFixed(4)}`))
const existingNamePref = new Set(data.shrines.map((s) => `${s.name}|${s.pref}`))

const PREF_RE = /^(北海道|東京都|京都府|大阪府|.{2,3}県)$/

const accepted = []
const rejected = []
const seenInBatch = new Set()

for (const s of incoming) {
  const why = []

  // 必須項目
  if (!s.slug || !/^[a-z0-9-]+$/.test(s.slug)) why.push('slugが不正')
  if (!s.name) why.push('nameがない')
  if (!s.kana) why.push('kanaがない')
  if (s.type !== 'shrine' && s.type !== 'temple') why.push('typeがshrine/temple以外')
  if (!s.pref || !PREF_RE.test(s.pref)) why.push('prefが不正')
  if (!s.city) why.push('cityがない')
  if (!s.address || s.address.length < 6) why.push('addressが不足')
  if (typeof s.lat !== 'number' || typeof s.lng !== 'number') why.push('座標がない')
  else if (s.lat < 24 || s.lat > 46 || s.lng < 122 || s.lng > 146) why.push('座標が日本の範囲外')
  if (!s.description || s.description.length < 10) why.push('descriptionが短い')
  // データ方針: 出典なしは受け入れない
  if (!s.source || !/^https?:\/\//.test(s.source)) why.push('出典URLがない')
  if (s.website && !/^https?:\/\//.test(s.website)) why.push('websiteが不正なURL')

  // 神仏の参照が存在するか
  const unknown = (s.deities || []).filter((d) => !deitySlugs.has(d))
  if (unknown.length) why.push(`未知の神仏: ${unknown.join(',')}`)
  if (!(s.deities || []).length) why.push('御祭神/本尊が未設定')

  // 重複
  if (existingSlugs.has(s.slug)) why.push('slugが既存と重複')
  if (seenInBatch.has(s.slug)) why.push('バッチ内でslugが重複')
  if (typeof s.lat === 'number') {
    const k = `${s.name}|${s.lat.toFixed(4)},${s.lng.toFixed(4)}`
    if (existingKeys.has(k)) why.push('同名・同座標の社寺が既存')
    const c = `${s.lat.toFixed(4)},${s.lng.toFixed(4)}`
    if (existingCoords.has(c)) why.push('同一座標の社寺が既存（別名の疑い）')
  }
  if (existingNamePref.has(`${s.name}|${s.pref}`)) why.push('同一県内に同名の社寺が既存（要確認）')

  if (why.length) rejected.push({ s, why })
  else {
    accepted.push(s)
    seenInBatch.add(s.slug)
    existingSlugs.add(s.slug)
    if (typeof s.lat === 'number') {
      existingKeys.add(`${s.name}|${s.lat.toFixed(4)},${s.lng.toFixed(4)}`)
      existingCoords.add(`${s.lat.toFixed(4)},${s.lng.toFixed(4)}`)
    }
    existingNamePref.add(`${s.name}|${s.pref}`)
  }
}

console.log(`バッチ: ${file}`)
console.log(`候補 ${incoming.length}件 → 受入 ${accepted.length}件 / 却下 ${rejected.length}件\n`)

if (rejected.length) {
  console.log('却下された候補:')
  for (const r of rejected.slice(0, 30)) {
    console.log(`  ✕ ${r.s.name || '(名称不明)'} [${r.s.slug || '-'}] — ${r.why.join(' / ')}`)
  }
  if (rejected.length > 30) console.log(`  … ほか${rejected.length - 30}件`)
  console.log('')
}

if (accepted.length) {
  const byPref = {}
  for (const s of accepted) byPref[s.pref] = (byPref[s.pref] || 0) + 1
  console.log('受入の内訳:', Object.entries(byPref).map(([p, c]) => `${p} ${c}件`).join(' / '))
}

if (!apply) {
  console.log('\n(確認のみ。取り込むには --apply を付けてください)')
  process.exit(0)
}
if (!accepted.length) {
  console.log('\n取り込む候補がありません。')
  process.exit(0)
}

data.shrines.push(...accepted)
const out = JSON.stringify(data)
copyFileSync(CANON, CANON + '.bak')
writeFileSync(CANON, out)
writeFileSync(WEB, out)
console.log(`\n✅ ${accepted.length}件を追加し ${data.shrines.length}件になりました`)
console.log('   続けて `node scripts/audit_data.mjs` で全体検査を実行してください')
