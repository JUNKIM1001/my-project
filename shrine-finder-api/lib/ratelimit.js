// レート制限（API_SPEC §5 / DESIGN §6）
//
// Upstash Redis のスライディングウィンドウ。IPはハッシュ化して保存する（生IPは残さない）。
// 環境変数が未設定、または Redis 障害時は **フェイルオープン**（制限せず通す）。
// 公開APIでは「止まる」より「一時的に緩い」ほうが害が小さいため。
import { createHash } from 'node:crypto'

const URL = process.env.UPSTASH_REDIS_REST_URL
const TOKEN = process.env.UPSTASH_REDIS_REST_TOKEN
const SALT = process.env.RATELIMIT_SALT || 'omairi-navi'

export const LIMITS = { perMinute: 60, perDay: 10000 }

const hashIp = (ip) => createHash('sha256').update(ip + SALT).digest('hex').slice(0, 24)

/** x-forwarded-for の先頭を採用する。 */
export function clientIp(req) {
  const xff = req.headers['x-forwarded-for']
  if (typeof xff === 'string' && xff.length) return xff.split(',')[0].trim()
  return req.socket?.remoteAddress || 'unknown'
}

async function redis(command) {
  const r = await fetch(URL, {
    method: 'POST',
    headers: { Authorization: `Bearer ${TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(command),
  })
  if (!r.ok) throw new Error(`upstash: ${r.status}`)
  return r.json()
}

/**
 * 制限を1つ消費する。
 * @returns {{allowed: boolean, limit: number, remaining: number, reset: number}}
 */
export async function consume(req) {
  // 未設定なら制限なし（ローカル開発・初期運用）
  if (!URL || !TOKEN) {
    return { allowed: true, limit: LIMITS.perMinute, remaining: LIMITS.perMinute, reset: 60 }
  }
  const id = hashIp(clientIp(req))
  const minuteKey = `rl:m:${id}`
  const dayKey = `rl:d:${id}`
  try {
    // INCR + 初回のみ EXPIRE（パイプラインで1往復にまとめる）
    const res = await redis([
      ['INCR', minuteKey],
      ['EXPIRE', minuteKey, '60', 'NX'],
      ['INCR', dayKey],
      ['EXPIRE', dayKey, '86400', 'NX'],
      ['TTL', minuteKey],
    ])
    const minuteCount = Number(res[0]?.result ?? 0)
    const dayCount = Number(res[2]?.result ?? 0)
    const ttl = Number(res[4]?.result ?? 60)
    const overMinute = minuteCount > LIMITS.perMinute
    const overDay = dayCount > LIMITS.perDay
    return {
      allowed: !overMinute && !overDay,
      limit: LIMITS.perMinute,
      remaining: Math.max(0, LIMITS.perMinute - minuteCount),
      reset: ttl > 0 ? ttl : 60,
    }
  } catch {
    // フェイルオープン
    return { allowed: true, limit: LIMITS.perMinute, remaining: LIMITS.perMinute, reset: 60 }
  }
}
