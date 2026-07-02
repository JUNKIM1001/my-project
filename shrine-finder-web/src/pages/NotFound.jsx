import { Link } from 'react-router-dom'
import usePageTitle from '../hooks/usePageTitle'

export default function NotFound({ message = 'お探しのページが見つかりません' }) {
  usePageTitle('見つかりません')
  return (
    <div className="page">
      <header className="appbar">
        <Link to="/" className="iconbtn" aria-label="ホームへ">‹</Link>
        <h1>見つかりません</h1>
        <span className="iconbtn" />
      </header>
      <div className="empty-state">
        <div className="empty-emoji">⛩️</div>
        <p>{message}</p>
        <p className="muted small">URLが変更されたか、削除された可能性があります。</p>
        <Link to="/" className="cta">ホームに戻る</Link>
      </div>
    </div>
  )
}
