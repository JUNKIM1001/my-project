// 社寺・神仏の全文説明（longDescription）の遅延取得。
// appdata-details.json（約600KB）を初回参照時にのみ fetch し、モジュール内にキャッシュする。
// 形式: { shrines: { slug: 本文 }, deities: { slug: 本文 } }

let cache = null
let pending = null

export function loadDetails() {
  if (cache) return Promise.resolve(cache)
  if (!pending) {
    pending = fetch(`${import.meta.env.BASE_URL}appdata-details.json`)
      .then((res) => {
        if (!res.ok) throw new Error(`appdata-details.json の取得に失敗しました (HTTP ${res.status})`)
        return res.json()
      })
      .then((json) => {
        cache = { shrines: json.shrines || {}, deities: json.deities || {} }
        return cache
      })
      .catch((err) => {
        pending = null // 失敗時は次回参照で再試行できるようにする
        throw err
      })
  }
  return pending
}
