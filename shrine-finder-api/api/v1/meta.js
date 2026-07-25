// GET /v1/meta — データ版・件数・ライセンス・レート制限
import { handle } from '../../lib/http.js'
import { getData } from '../../lib/data.js'
import { ATTRIBUTION } from '../../lib/serialize.js'
import { LIMITS } from '../../lib/ratelimit.js'

const CONTACT = process.env.API_CONTACT || 'https://github.com/JUNKIM1001/my-project/issues'

export default handle(() => {
  const data = getData()
  return {
    data_version: data.data_version,
    counts: data.counts,
    rate_limit: {
      per_minute: LIMITS.perMinute,
      per_day: LIMITS.perDay,
      contact: CONTACT,
    },
    attribution: ATTRIBUTION,
    terms_url: 'https://github.com/JUNKIM1001/my-project/blob/main/shrine-finder-api/API_SPEC.md#8-利用条件',
    changelog_url: 'https://github.com/JUNKIM1001/my-project/commits/main/shrine-finder-api',
  }
})
