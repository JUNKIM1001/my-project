// エンドポイント共通の処理: CORS・レート制限・キャッシュ・ETag（API_SPEC §5〜§7）
import { consume } from './ratelimit.js'
import { etagOf } from './serialize.js'
import { problem, serverError } from './problem.js'

const CACHE = 'public, s-maxage=3600, stale-while-revalidate=86400'

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, If-None-Match')
  res.setHeader('Access-Control-Max-Age', '86400')
}

/**
 * ハンドラを共通処理でくるむ。
 * handler(req, url) が返した値を JSON として返す。
 * { status, body } を返すとステータスを指定できる。
 */
export function handle(handler) {
  return async (req, res) => {
    cors(res)

    if (req.method === 'OPTIONS') {
      res.statusCode = 204
      return res.end()
    }
    if (req.method !== 'GET') {
      return problem(res, {
        code: 'method-not-allowed', status: 405,
        title: 'GET のみ利用できます', instance: req.url,
      })
    }

    // レート制限
    const rl = await consume(req)
    res.setHeader('RateLimit-Limit', String(rl.limit))
    res.setHeader('RateLimit-Remaining', String(rl.remaining))
    res.setHeader('RateLimit-Reset', String(rl.reset))
    if (!rl.allowed) {
      res.setHeader('Retry-After', String(rl.reset))
      return problem(res, {
        code: 'rate-limit-exceeded', status: 429,
        title: 'リクエストが多すぎます',
        detail: `${rl.reset}秒後に再試行してください。上限緩和が必要な場合は /v1/meta の連絡先までご相談ください。`,
        instance: req.url,
      })
    }

    try {
      // クエリ文字列は座標を含みうるためログしない（DESIGN §5）
      const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`)
      const result = await handler(req, url, res)
      if (res.writableEnded) return // ハンドラ側で応答済み（エラー等）

      const body = JSON.stringify(result)
      const etag = etagOf(body)
      res.setHeader('ETag', etag)
      res.setHeader('Cache-Control', CACHE)
      res.setHeader('Content-Type', 'application/json; charset=utf-8')

      if (req.headers['if-none-match'] === etag) {
        res.statusCode = 304
        return res.end()
      }
      res.statusCode = 200
      res.end(body)
    } catch (e) {
      console.error('handler error:', e?.message)
      if (!res.writableEnded) serverError(res, req.url)
    }
  }
}
