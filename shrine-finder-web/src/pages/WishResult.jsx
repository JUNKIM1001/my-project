import { useParams, Link } from 'react-router-dom'
import { useStore, useGeo } from '../data/providers'
import { ShrineRow } from '../components/ui'

export default function WishResult() {
  const { slug } = useParams()
  const store = useStore()
  const geo = useGeo()
  const g = store.goriyakuBySlug[slug]
  const deities = store.deitiesForGoriyaku(slug)

  let ranked = store.shrinesForGoriyaku(slug)
  ranked = geo.coords
    ? ranked.map((s) => [s, store.dist(geo.coords, s)]).sort((a, b) => a[1] - b[1])
    : ranked.map((s) => [s, null])

  return (
    <div className="page">
      <header className="appbar">
        <Link to="/" className="iconbtn">‹</Link>
        <h1>{g?.name || 'ご利益'}</h1>
        <span className="iconbtn" />
      </header>

      <section className="sec">
        <div className="sec-head"><b>「{g?.name}」を司る神仏</b></div>
        <div className="hscroll">
          {deities.map((d) => (
            <Link key={d.slug} to={`/deity/${d.slug}`} className="dchip">
              <span>{d.kind === 'kami' ? '⛩️' : '✦'}</span>
              <span className="ellipsis">{d.name}</span>
            </Link>
          ))}
        </div>
      </section>

      {!geo.coords && (
        <button className="cta" onClick={geo.request}>📍 現在地から近い順に並べる</button>
      )}

      <section className="sec">
        <div className="sec-head">
          <b>参拝できる社寺（{geo.coords ? '近い順・' : ''}{ranked.length}件）</b>
        </div>
        <div className="list">
          {ranked.map(([s, d]) => <ShrineRow key={s.slug} shrine={s} highlight={slug} distance={d} />)}
        </div>
      </section>
    </div>
  )
}
