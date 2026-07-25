// 内部データ → APIレスポンス形への変換（API_SPEC §2.1）
import { createHash } from 'node:crypto'

export const ATTRIBUTION = {
  text: '神社・お寺データ: おまいりナビ (https://omairi-navi.vercel.app)',
  required: true,
}

const ONE_DAY = 86400000

/**
 * テレビ放映が「放映日から1年以内」か（暦日で判定）。
 * 1年を過ぎたものは API から自動的に落ちる（API_SPEC §2.1 注記）。
 */
export function tvActive(tv, now = new Date()) {
  if (!tv || typeof tv.date !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(tv.date)) return false
  const ymd = (d) =>
    `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  const today = ymd(now)
  const cutoff = ymd(new Date(now.getFullYear() - 1, now.getMonth(), now.getDate()))
  return tv.date >= cutoff && tv.date <= today
}

/** 社寺1件をAPIレスポンス形に整形する。distanceM を渡すと distance_m を付与。 */
export function toShrine(s, distanceM = null, now = new Date()) {
  const out = {
    id: s.id,
    name: s.name,
    kana: s.kana,
    type: s.type,
    sect: s.sect,
    area: { pref: s.pref, city: s.city },
    address: s.address,
    location: { lat: s.lat, lng: s.lng },
    summary: s.summary,
    enshrined: {
      role: s.type === 'shrine' ? '御祭神' : '本尊',
      deities: s.deities,
    },
    goriyaku: s.goriyaku,
    national_treasure: s.national_treasure,
    goshuin: s.goshuin,
    tv: tvActive(s.tv, now) ? s.tv : null,
    image: s.image,
    links: { website: s.website, wikipedia: s.wikipedia, detail: s.detail },
  }
  if (distanceM != null) out.distance_m = Math.round(distanceM)
  return out
}

/** ETag（本文のハッシュ）。 */
export const etagOf = (body) => `"${createHash('sha1').update(body).digest('hex').slice(0, 16)}"`
