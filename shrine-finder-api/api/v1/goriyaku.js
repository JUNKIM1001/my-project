// GET /v1/goriyaku — ご利益カテゴリの一覧
import { handle } from '../../lib/http.js'
import { getData } from '../../lib/data.js'

export default handle(() => ({ goriyaku: getData().goriyaku }))
