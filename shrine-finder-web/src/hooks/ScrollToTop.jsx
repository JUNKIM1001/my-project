import { useEffect } from 'react'
import { useLocation, useNavigationType } from 'react-router-dom'

/**
 * ページ遷移（PUSH）時のみスクロール位置を先頭に戻す。
 * 戻る/進む（POP）時はブラウザのスクロール復元に任せる。
 * このアプリの実スクロールコンテナは .content なので、window と両方を戻す。
 */
export default function ScrollToTop() {
  const { pathname } = useLocation()
  const navigationType = useNavigationType()
  useEffect(() => {
    if (navigationType !== 'PUSH') return
    window.scrollTo(0, 0)
    document.querySelector('.content')?.scrollTo(0, 0)
  }, [pathname, navigationType])
  return null
}
