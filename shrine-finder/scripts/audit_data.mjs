// appdata.json の品質検査。データ追加のたびに実行し、不良データの混入を防ぐ。
//
//   node scripts/audit_data.mjs            検査して結果を表示（問題があれば exit 1）
//   node scripts/audit_data.mjs --json     機械可読の結果を出力
//
// 検査項目は「利用者に実害が出るもの」に絞る。単なる書式の好みは対象にしない。
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))
const APPDATA = join(ROOT, 'ios/ShrineFinder/Resources/appdata.json')

const data = JSON.parse(readFileSync(APPDATA, 'utf8'))
const S = data.shrines
const deitySlugs = new Set(data.deities.map((d) => d.slug))
const goriyakuSlugs = new Set(data.goriyaku.map((g) => g.slug))

const issues = []
const add = (severity, kind, detail, items) =>
  issues.push({ severity, kind, detail, items: items || [] })

const key4 = (s) => `${s.lat.toFixed(4)},${s.lng.toFixed(4)}`

// ---- 1. 重複（利用者には「同じ社寺が2回出る」形で見える）----
const byNameCoord = {}
for (const s of S) {
  const k = `${s.name}|${key4(s)}`
  ;(byNameCoord[k] ||= []).push(s)
}
const exactDups = Object.values(byNameCoord).filter((v) => v.length > 1)
if (exactDups.length) {
  add('error', 'duplicate-exact', `同名かつ同座標の重複 ${exactDups.length}組（余剰 ${exactDups.reduce((a, g) => a + g.length - 1, 0)}件）`,
    exactDups.map((g) => g.map((s) => `${s.name}[${s.slug}]`).join(' ⇔ ')))
}

// 同座標だが名称違い（別名・表記ゆれの疑い）。誤検出もありうるので警告どまり。
const byCoord = {}
for (const s of S) (byCoord[key4(s)] ||= []).push(s)
const sameCoord = Object.values(byCoord).filter(
  (v) => v.length > 1 && new Set(v.map((s) => s.name)).size > 1
)
if (sameCoord.length) {
  add('warn', 'duplicate-samecoord', `同座標で名称が異なる ${sameCoord.length}組（別名・表記ゆれの疑い）`,
    sameCoord.map((g) => g.map((s) => `${s.name}[${s.slug}]`).join(' ⇔ ')))
}

// ---- 2. 必須項目の欠落・破損 ----
const bad = (pred, kind, detail, severity = 'error') => {
  const hit = S.filter(pred)
  if (hit.length) add(severity, kind, `${detail}: ${hit.length}件`, hit.slice(0, 10).map((s) => `${s.name}[${s.slug}]`))
}
bad((s) => !s.slug || !/^[a-z0-9-]+$/.test(s.slug), 'bad-slug', 'slugが不正（英小文字・数字・ハイフンのみ）')
bad((s) => !s.name || !s.kana, 'missing-name', '名称またはよみが空')
bad((s) => s.type !== 'shrine' && s.type !== 'temple', 'bad-type', 'typeがshrine/temple以外')
bad((s) => !s.source || !/^https?:\/\//.test(s.source), 'missing-source', '出典URLがない（データ方針違反）')
bad((s) => !s.address || s.address.length < 6, 'bad-address', '住所が短すぎる')
bad((s) => !s.description || s.description.length < 10, 'bad-description', '紹介文が短すぎる')

// slug重複はキーの健全性そのもの
const slugCount = {}
for (const s of S) slugCount[s.slug] = (slugCount[s.slug] || 0) + 1
const dupSlugs = Object.entries(slugCount).filter(([, c]) => c > 1)
if (dupSlugs.length) add('error', 'duplicate-slug', `slugの重複 ${dupSlugs.length}件`, dupSlugs.map(([k]) => k))

// ---- 3. 座標 ----
bad((s) => typeof s.lat !== 'number' || typeof s.lng !== 'number', 'missing-coord', '座標がない')
bad((s) => s.lat < 24 || s.lat > 46 || s.lng < 122 || s.lng > 146, 'coord-out-of-japan', '座標が日本の範囲外')
// 小数3桁以下は精度が粗く、地図上で数十〜数百mずれる
const coarse = S.filter((s) => (String(s.lat).split('.')[1] || '').length <= 3)
if (coarse.length) {
  add('warn', 'coord-low-precision', `座標の精度が粗い（小数3桁以下）: ${coarse.length}件`,
    coarse.slice(0, 10).map((s) => `${s.name}[${s.slug}] ${s.lat},${s.lng}`))
}

// 都道府県と座標の整合（県の代表点から離れすぎていないか）
const PREF_CENTER = {
  北海道: [43.06, 141.35], 青森県: [40.82, 140.74], 岩手県: [39.70, 141.15], 宮城県: [38.27, 140.87],
  秋田県: [39.72, 140.10], 山形県: [38.24, 140.36], 福島県: [37.75, 140.47], 茨城県: [36.34, 140.45],
  栃木県: [36.57, 139.88], 群馬県: [36.39, 139.06], 埼玉県: [35.86, 139.65], 千葉県: [35.61, 140.12],
  東京都: [35.69, 139.69], 神奈川県: [35.45, 139.64], 新潟県: [37.90, 139.02], 富山県: [36.70, 137.21],
  石川県: [36.59, 136.63], 福井県: [36.07, 136.22], 山梨県: [35.66, 138.57], 長野県: [36.65, 138.18],
  岐阜県: [35.39, 136.72], 静岡県: [34.98, 138.38], 愛知県: [35.18, 136.91], 三重県: [34.73, 136.51],
  滋賀県: [35.00, 135.87], 京都府: [35.02, 135.76], 大阪府: [34.69, 135.52], 兵庫県: [34.69, 135.18],
  奈良県: [34.69, 135.83], 和歌山県: [34.23, 135.17], 鳥取県: [35.50, 134.24], 島根県: [35.47, 133.05],
  岡山県: [34.66, 133.93], 広島県: [34.40, 132.46], 山口県: [34.19, 131.47], 徳島県: [34.07, 134.56],
  香川県: [34.34, 134.04], 愛媛県: [33.84, 132.77], 高知県: [33.56, 133.53], 福岡県: [33.61, 130.42],
  佐賀県: [33.25, 130.30], 長崎県: [32.74, 129.87], 熊本県: [32.79, 130.74], 大分県: [33.24, 131.61],
  宮崎県: [31.91, 131.42], 鹿児島県: [31.56, 130.56], 沖縄県: [26.21, 127.68],
}
const R = 6371, rad = (x) => (x * Math.PI) / 180
const distKm = (a, b) => {
  const dLat = rad(b[0] - a[0]), dLng = rad(b[1] - a[1])
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(rad(a[0])) * Math.cos(rad(b[0])) * Math.sin(dLng / 2) ** 2
  return R * 2 * Math.asin(Math.sqrt(h))
}
// 県ごとの広がりに応じた許容距離。一律の閾値だと網走・稚内・宮古島などが
// 誤検出になり、検査が信用されなくなるため個別に設定する。
const RADIUS_KM = {
  北海道: 600,   // 稚内・根室・松前まで含む
  沖縄県: 600,   // 宮古・八重山
  東京都: 1100,  // 小笠原諸島
  鹿児島県: 450, // 奄美・トカラ
  長崎県: 250,   // 対馬・五島
  島根県: 250,   // 隠岐
}
const DEFAULT_RADIUS_KM = 150
const misplaced = S.filter((s) => {
  const c = PREF_CENTER[s.pref]
  if (!c) return false
  return distKm(c, [s.lat, s.lng]) > (RADIUS_KM[s.pref] ?? DEFAULT_RADIUS_KM)
})
if (misplaced.length) {
  add('error', 'coord-pref-mismatch', `座標が都道府県から200km以上離れている（県の取り違えの疑い）: ${misplaced.length}件`,
    misplaced.slice(0, 10).map((s) => `${s.name}[${s.slug}] ${s.pref} → ${s.lat},${s.lng}`))
}

// 住所の先頭が pref と一致するか
const addrMismatch = S.filter((s) => s.address && !s.address.startsWith(s.pref))
if (addrMismatch.length) {
  add('warn', 'address-pref-mismatch', `住所が都道府県名で始まっていない: ${addrMismatch.length}件`,
    addrMismatch.slice(0, 10).map((s) => `${s.name}[${s.slug}] ${s.pref} / ${s.address}`))
}

// ---- 4. 参照の整合 ----
const orphanDeity = S.filter((s) => (s.deities || []).some((d) => !deitySlugs.has(d)))
if (orphanDeity.length) {
  add('error', 'orphan-deity', `存在しない神仏を参照: ${orphanDeity.length}件`,
    orphanDeity.slice(0, 10).map((s) => `${s.name}[${s.slug}]`))
}
const noDeity = S.filter((s) => !(s.deities || []).length)
if (noDeity.length) {
  add('warn', 'no-deity', `御祭神/本尊が未設定（ご利益検索に出てこない）: ${noDeity.length}件`,
    noDeity.slice(0, 10).map((s) => `${s.name}[${s.slug}]`))
}
const orphanGoriyaku = data.deities.filter((d) => (d.goriyaku || []).some((g) => !goriyakuSlugs.has(g)))
if (orphanGoriyaku.length) {
  add('error', 'orphan-goriyaku', `存在しないご利益を参照する神仏: ${orphanGoriyaku.length}件`,
    orphanGoriyaku.slice(0, 10).map((d) => `${d.name}[${d.slug}]`))
}

// ---- 5. 出典付きが必須の項目 ----
const goshuinNoSrc = S.filter((s) => s.goshuin === true && !s.goshuinSource)
if (goshuinNoSrc.length) {
  add('error', 'goshuin-no-source', `御朱印ありなのに出典がない: ${goshuinNoSrc.length}件`,
    goshuinNoSrc.slice(0, 10).map((s) => `${s.name}[${s.slug}]`))
}
const tvNoSrc = S.filter((s) => s.tv && !s.tv.source)
if (tvNoSrc.length) {
  add('error', 'tv-no-source', `テレビ放映情報に出典がない: ${tvNoSrc.length}件`,
    tvNoSrc.slice(0, 10).map((s) => `${s.name}[${s.slug}]`))
}
const tvBadDate = S.filter((s) => s.tv && !/^\d{4}-\d{2}-\d{2}$/.test(s.tv.date || ''))
if (tvBadDate.length) add('error', 'tv-bad-date', `テレビ放映日の書式が不正: ${tvBadDate.length}件`,
  tvBadDate.map((s) => `${s.name}[${s.slug}]`))

// ---- 出力 ----
const errors = issues.filter((i) => i.severity === 'error')
const warns = issues.filter((i) => i.severity === 'warn')

if (process.argv.includes('--json')) {
  console.log(JSON.stringify({ total: S.length, errors, warns }, null, 2))
} else {
  console.log(`社寺 ${S.length}件 を検査\n`)
  const show = (list, mark) => {
    for (const i of list) {
      console.log(`${mark} [${i.kind}] ${i.detail}`)
      for (const it of i.items.slice(0, 6)) console.log(`     ${it}`)
      if (i.items.length > 6) console.log(`     … ほか${i.items.length - 6}件`)
    }
  }
  show(errors, '❌')
  show(warns, '⚠️ ')
  if (!errors.length && !warns.length) console.log('✅ 問題なし')
  else console.log(`\n合計: エラー ${errors.length}種 / 警告 ${warns.length}種`)
}

process.exit(errors.length ? 1 : 0)
