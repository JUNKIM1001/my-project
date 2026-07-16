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
    const getAll = async (path) => {
      const r = await fetch(`${URL}/rest/v1/${path}`, { headers })
      if (!r.ok) throw new Error(`${path}: ${r.status}`)
      return r.json()
    }
    const goriyaku = await getAll('goriyaku?select=*&order=sort_order')
    const deities = await getAll('deities?select=*')

    // shrines は 1000件超のためページング取得
    const shrines = []
    for (let from = 0; ; from += 1000) {
      const r = await fetch(`${URL}/rest/v1/shrines?select=*`, {
        headers: { ...headers, 'Range-Unit': 'items', Range: `${from}-${from + 999}` },
      })
      if (!r.ok) throw new Error(`shrines: ${r.status}`)
      const batch = await r.json()
      shrines.push(...batch)
      if (batch.length < 1000) break
    }
    if (shrines.length === 0) return null
    return createStore({ goriyaku, deities, shrines: shrines.map(mapShrine) })
  } catch (e) {
    console.warn('Supabase取得に失敗、appdata.jsonにフォールバック:', e.message)
    return null
  }
}
