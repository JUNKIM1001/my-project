import { useStore, useFavorites } from '../data/providers'
import { ShrineRow } from '../components/ui'
import usePageTitle from '../hooks/usePageTitle'

export default function Favorites() {
  const store = useStore()
  const fav = useFavorites()
  usePageTitle('お気に入り')
  const saved = store.shrines.filter((s) => fav.has(s.slug))

  return (
    <div className="page">
      <header className="appbar">
        <span className="iconbtn" />
        <h1>お気に入り</h1>
        <span className="iconbtn" />
      </header>
      {saved.length === 0 ? (
        <div className="empty-state">
          <div className="empty-emoji">♡</div>
          <p>お気に入りはまだありません</p>
          <p className="muted small">社寺の詳細でハートを押すと、ここに保存されます。</p>
        </div>
      ) : (
        <div className="list">{saved.map((s) => <ShrineRow key={s.slug} shrine={s} />)}</div>
      )}
    </div>
  )
}
