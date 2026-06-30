import { useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useStore, useGeo } from '../data/providers'
import { RecommendCard } from '../components/ui'

export default function Home() {
  const store = useStore()
  const geo = useGeo()
  useEffect(() => { geo.request() }, []) // eslint-disable-line

  const counts = store.goriyakuCounts()
  const recs = store.recommended(geo.coords)

  return (
    <div className="page">
      <header className="appbar">
        <Link to="/about" className="iconbtn" aria-label="情報">ⓘ</Link>
        <h1>おまいりナビ</h1>
        <Link to="/search" className="iconbtn" aria-label="検索">🔍</Link>
      </header>

      <section className="sec">
        <div className="sec-head">
          <b>★ 代表的な有名社寺</b>
          {geo.coords && <span className="muted small">近い順</span>}
        </div>
        <div className="hscroll">
          {recs.map((s) => (
            <RecommendCard key={s.slug} shrine={s} distance={geo.coords ? store.dist(geo.coords, s) : null} />
          ))}
        </div>
      </section>

      <section className="sec">
        <b>願い事から探す</b>
        <p className="muted">ご利益を選ぶと、ふさわしい神仏とお参り先が見つかります。</p>
        <div className="grid">
          {counts.map(([g, c]) => (
            <Link key={g.slug} to={`/wish/${g.slug}`} className="gcard">
              <div className="gname">{g.name}</div>
              <div className="muted small">{c}社寺</div>
            </Link>
          ))}
        </div>
      </section>
    </div>
  )
}
