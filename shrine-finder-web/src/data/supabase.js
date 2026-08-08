// Supabase(PostgREST) から全データを取得して store を構築する。
// 環境変数 VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY 未設定、または失敗時は null を返し、
// 呼び出し側が appdata.json にフォールバックする。anon キーは公開前提(RLSで保護)。
import { createStore } from './store'

const URL = import.meta.env.VITE_SUPABASE_URL
const ANON = import.meta.env.VITE_SUPABASE_ANON_KEY

const mapShrine = (s) => ({
  ...s,
  imageURL: s.image_url ?? null,
  imageLicense: s.image_license ?? null,
  imageAuthor: s.image_author ?? null,
  longDescription: s.long_description ?? null,
})

export async function loadStoreFromSupabase() {
  if (!URL || !ANON) return null
  const headers = { apikey: ANON, Authorization: `Bearer ${ANON}` }
  try {
    // PostgREST は1回のリクエストで最大1000件しか返さない。件数の少ないテーブルでも
    // 必ずこの関数を通す（将来1000件を超えたときに黙って切り捨てられるのを防ぐため）。
    const getAll = async (path) => {
      const out = []
      const sep = path.includes('?') ? '&' : '?'
      for (let from = 0; ; from += 1000) {
        const r = await fetch(`${URL}/rest/v1/${path}${sep}`, {
          headers: { ...headers, 'Range-Unit': 'items', Range: `${from}-${from + 999}` },
        })
        // 総件数がちょうど1000の倍数だと、最後に範囲外を1回要求することになる。
        // この環境では200＋空配列が返るが、PostgRESTの版によっては416を返すため
        // 416も「データの終わり」として扱う。
        if (r.status === 416) break
        if (!r.ok) throw new Error(`${path}: ${r.status}`)
        const batch = await r.json()
        out.push(...batch)
        if (batch.length < 1000) break
      }
      return out
    }
    const goriyaku = await getAll('goriyaku?select=*&order=sort_order')
    const deities = await getAll('deities?select=*&order=slug')
    const shrines = await getAll('shrines?select=*&order=slug')
    if (shrines.length === 0) return null
    return createStore({ goriyaku, deities, shrines: shrines.map(mapShrine) })
  } catch (e) {
    console.warn('Supabase取得に失敗、appdata.jsonにフォールバック:', e.message)
    return null
  }
}
