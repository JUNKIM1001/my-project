// 地域名の解決（API_SPEC §3.1 / DESIGN §4）
//
// 逆ジオコーディングの表記ゆれを吸収する。
// 重要: データには政令市の「市名のみ」と「市名＋区」が混在するため
// （例: 京都市81件 と 京都市伏見区3件が併存）、**前方一致を第一段**とする。
// 完全一致を優先すると「京都市」の検索で区表記の21件を取りこぼす。

const SUFFIXES = ['都', '道', '府', '県']

/** 全角空白や前後の空白を除いて正規化する。 */
const norm = (s) => (s ?? '').replace(/[\s　]+/g, '').trim()

/**
 * 都道府県名を解決する。接尾辞(都/道/府/県)は省略可。
 * @returns {string|null} データ上の正式名（例 "京都府"）。解決できなければ null
 */
export function resolvePref(input, knownPrefs) {
  const q = norm(input)
  if (!q) return null
  if (knownPrefs.has(q)) return q
  for (const suf of SUFFIXES) {
    if (knownPrefs.has(q + suf)) return q + suf
  }
  return null
}

/**
 * 市区町村を解決する。
 * @param {string} input 入力された市区町村名
 * @param {string[]} cities その都道府県に存在する市区町村名の一覧
 * @returns {{cities: string[], match: 'exact'|'prefix'|'contains'|'pref_only'}}
 */
export function resolveCity(input, cities) {
  const q = norm(input)
  if (!q) return { cities: [], match: 'pref_only' }

  // 1. 前方一致（完全一致もここに含まれる）
  const prefix = cities.filter((c) => c === q || c.startsWith(q))
  if (prefix.length > 0) {
    const allExact = prefix.every((c) => c === q)
    return { cities: prefix, match: allExact ? 'exact' : 'prefix' }
  }

  // 2. 部分一致（郡名の省略を吸収: "美郷町" → "仙北郡美郷町"）
  const contains = cities.filter((c) => c.includes(q))
  if (contains.length > 0) return { cities: contains, match: 'contains' }

  // 3. 解決できず → 都道府県全体
  return { cities: [], match: 'pref_only' }
}
