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
  const tvFeatured = store.tvFeatured()

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

      {tvFeatured.length > 0 && (
        <section className="sec">
          <div className="sec-head">
            <b>📺 最近テレビで紹介</b>
            <span className="muted small">直近1年</span>
          </div>
          <div className="hscroll">
            {tvFeatured.map((s) => (
              <RecommendCard key={s.slug} shrine={s} distance={geo.coords ? store.dist(geo.coords, s) : null} />
            ))}
          </div>
        </section>
      )}

      <section className="sec">
        <b>地域から探す</b>
        <p className="muted">都道府県ごとに神社・お寺を一覧できます。</p>
        <Link to="/region" className="gcard" style={{ display: 'block' }}>
          <div className="gname">📍 全国の社寺を地域から</div>
          <div className="muted small">{store.prefectureCount()}都道府県・{store.shrines.length}社寺</div>
        </Link>
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
