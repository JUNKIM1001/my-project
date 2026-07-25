// GET /v1/shrines/{id} — 社寺の詳細（内容が近い社寺つき）
import { handle } from '../../../lib/http.js'
import { getData } from '../../../lib/data.js'
import { toShrine, ATTRIBUTION } from '../../../lib/serialize.js'
import { notFound } from '../../../lib/problem.js'
import { distanceM } from '../../../lib/geo.js'

/** 御祭神・ご利益・系統・距離の近さでスコアリングして関連社寺を返す。 */
function related(target, shrines, limit = 8) {
  const gset = new Set(target.goriyaku.map((g) => g.id))
  const dset = new Set(target.deities.map((d) => d.id))
  const scored = []
  for (const s of shrines) {
    if (s.id === target.id) continue
    let score = s.deities.filter((d) => dset.has(d.id)).length * 4
    score += s.goriyaku.filter((g) => gset.has(g.id)).length
    if (target.sect && s.sect === target.sect) score += 2
    if (s.pref === target.pref) score += 1
    if (score > 0) scored.push([s, score, distanceM(target, s)])
  }
  scored.sort((a, b) => (a[1] !== b[1] ? b[1] - a[1] : a[2] - b[2]))
  return scored.slice(0, limit).map((x) => x[0])
}

export default handle((req, url, res) => {
  const id = url.pathname.split('/').pop()
  const data = getData()
  const shrine = data.byId.get(id)
  if (!shrine) return notFound(res, `id「${id}」の社寺は存在しません`, url.pathname)

  return {
    shrine: toShrine(shrine),
    related: related(shrine, data.shrines).map((s) => toShrine(s)),
    attribution: ATTRIBUTION,
  }
})
