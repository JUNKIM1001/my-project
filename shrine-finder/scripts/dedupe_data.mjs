// 同名かつ同座標の重複を1件に統合する。
//
//   node scripts/dedupe_data.mjs --dry    何が起きるか表示するだけ（既定）
//   node scripts/dedupe_data.mjs --apply  実際に appdata.json を書き換える
//
// 方針: 情報量の多い方を「残す側」とし、少ない方が持っている情報のうち
// 残す側に欠けているものだけを補完する（情報を捨てない）。
import { readFileSync, writeFileSync, copyFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))
const CANON = join(ROOT, 'ios/ShrineFinder/Resources/appdata.json')
const WEB = join(dirname(ROOT), 'shrine-finder-web/public/appdata.json')

const apply = process.argv.includes('--apply')
const data = JSON.parse(readFileSync(CANON, 'utf8'))

const key = (s) => `${s.name}|${s.lat.toFixed(4)},${s.lng.toFixed(4)}`
const score = (s) =>
  (s.website ? 4 : 0) +
  (s.imageURL ? 3 : 0) +
  (s.longDescription ? 2 : 0) +
  (s.deities || []).length +
  (s.description || '').length / 100 +
  (s.goshuin ? 1 : 0) +
  (s.nt ? 1 : 0)

// 名称は違うが同一社寺と確認できたもの（別名・旧字・山号の有無）。
// 自動判定に任せると別社殿を誤って統合するため、目視で確認した分だけを明示する。
// keep = 残すslug（正式名称・通称として通りが良い方） / drop = 統合して消すslug
const ALIAS_MERGES = [
  { keep: 'itate-hyozu-jinja', drop: 'kamafuta-jinja' },      // 射楯兵主神社（釜蓋神社）＝射楯兵主神社
  { keep: 'nissekiji', drop: 'nisseki-ji' },                  // 大岩山日石寺＝日石寺（山号の有無）
  { keep: 'saidaiji-kannon-in', drop: 'saidaiji-okayama' },   // 西大寺観音院＝西大寺（岡山）
  { keep: 'saimyoji-koura', drop: 'saimyo-ji-koto' },         // 西明寺（slugにWikipedia由来の"_(甲良町)"が残っていた方を削除）
  { keep: 'sakurayama-jinja', drop: 'sakurayama-jinja-morioka' }, // 櫻山神社＝桜山神社（盛岡）旧字/新字
]

const bySlug = Object.fromEntries(data.shrines.map((s) => [s.slug, s]))

const groups = {}
for (const s of data.shrines) (groups[key(s)] ||= []).push(s)
const dups = Object.values(groups).filter((g) => g.length > 1)

// 別名統合も同じ処理に流せるよう、グループとして足す
for (const m of ALIAS_MERGES) {
  const a = bySlug[m.keep], b = bySlug[m.drop]
  if (!a || !b) continue // 適用済みなら黙って飛ばす（再実行可能にするため）
  dups.push([a, b]) // 先頭を必ず残すよう、後段のソートで同点でも安定するようにする
  a.__forceKeep = true
}

// 補完対象のフィールド（残す側が欠いていれば、捨てる側から引き継ぐ）
const FILLABLE = [
  'website', 'imageURL', 'imageLicense', 'imageAuthor', 'longDescription',
  'sect', 'address', 'kana', 'goshuin', 'goshuinSource', 'tv',
]

const removed = new Set()
const log = []

for (const g of dups) {
  // __forceKeep が付いていれば必ずそれを残す（別名統合で残す側を明示した場合）
  const [keep, ...rest] = [...g].sort(
    (a, b) => (b.__forceKeep ? 1 : 0) - (a.__forceKeep ? 1 : 0) || score(b) - score(a)
  )
  const filled = []
  for (const drop of rest) {
    for (const f of FILLABLE) {
      const empty = keep[f] === undefined || keep[f] === null || keep[f] === '' || keep[f] === false
      if (empty && drop[f] !== undefined && drop[f] !== null && drop[f] !== '' && drop[f] !== false) {
        keep[f] = drop[f]
        filled.push(f)
      }
    }
    // 御祭神は和集合にする
    const merged = [...new Set([...(keep.deities || []), ...(drop.deities || [])])]
    if (merged.length > (keep.deities || []).length) {
      keep.deities = merged
      filled.push('deities')
    }
    // 国宝フラグは片方でも true なら true
    if (drop.nt === true && keep.nt !== true) { keep.nt = true; filled.push('nt') }
    removed.add(drop.slug)
  }
  log.push({ name: keep.name, keep: keep.slug, dropped: rest.map((s) => s.slug), filled: [...new Set(filled)] })
}

console.log(`重複 ${dups.length}組 / 削除対象 ${removed.size}件\n`)
for (const l of log) {
  console.log(`■ ${l.name}`)
  console.log(`   残す : ${l.keep}`)
  console.log(`   削除 : ${l.dropped.join(', ')}`)
  if (l.filled.length) console.log(`   補完 : ${l.filled.join(', ')}`)
}

if (!apply) {
  console.log('\n(確認のみ。実行するには --apply を付けてください)')
  process.exit(0)
}

data.shrines = data.shrines.filter((s) => !removed.has(s.slug))
for (const s of data.shrines) delete s.__forceKeep // 作業用フラグは残さない
const out = JSON.stringify(data)

copyFileSync(CANON, CANON + '.bak')
writeFileSync(CANON, out)
writeFileSync(WEB, out)
console.log(`\n✅ ${removed.size}件を削除し ${data.shrines.length}件になりました`)
console.log(`   バックアップ: ${CANON}.bak`)
console.log(`   反映: ${CANON}\n         ${WEB}`)
