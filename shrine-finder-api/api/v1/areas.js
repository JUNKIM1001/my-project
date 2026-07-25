// GET /v1/areas — 地域（都道府県・市区町村）の一覧と件数
import { handle } from '../../lib/http.js'
import { getData } from '../../lib/data.js'
import { resolvePref } from '../../lib/area.js'
import { badRequest } from '../../lib/problem.js'

export default handle((req, url, res) => {
  const data = getData()
  const prefIn = url.searchParams.get('pref')

  let only = null
  if (prefIn) {
    only = resolvePref(prefIn, new Set(data.byPref.keys()))
    if (!only) return badRequest(res, `pref を解決できません（指定値: ${prefIn}）`, url.pathname)
  }

  const regions = data.regions
    .map((r) => ({
      name: r.name,
      prefectures: r.prefs
        .filter((p) => data.areas[p] && (!only || p === only))
        .map((p) => ({
          name: p,
          count: data.areas[p].count,
          cities: Object.entries(data.areas[p].cities)
            .map(([name, count]) => ({ name, count }))
            .sort((a, b) => a.name.localeCompare(b.name, 'ja')),
        })),
    }))
    .filter((r) => r.prefectures.length > 0)

  return {
    meta: { total_shrines: data.counts.shrines, data_version: data.data_version },
    regions,
  }
})
