// GET /v1/shrines — 社寺を検索する
import { handle } from '../../../lib/http.js'
import { search, InvalidParam } from '../../../lib/search.js'
import { badRequest } from '../../../lib/problem.js'

export default handle((req, url, res) => {
  try {
    return search(url.searchParams)
  } catch (e) {
    if (e instanceof InvalidParam) return badRequest(res, e.message, url.pathname)
    throw e
  }
})
