import { useEffect } from 'react'

const BASE = 'おまいりナビ'

/**
 * ルートごとにページタイトルを設定する。
 * - title が文字列: 「〇〇 | おまいりナビ」
 * - title が null: 既定タイトル（ホーム用）
 * - title が undefined: 何もしない（not-found 側でタイトルを設定するケース用）
 */
export default function usePageTitle(title) {
  useEffect(() => {
    if (title === undefined) return
    document.title = title ? `${title} | ${BASE}` : `${BASE} — 神社・お寺さがし`
  }, [title])
}
