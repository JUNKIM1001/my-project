import { Link } from 'react-router-dom'
import { useStore } from '../data/providers'
import { REGIONS } from '../data/store'

export default function RegionSearch() {
  const store = useStore()
  const counts = store.prefCounts()

  return (
    <div className="page">
      <header className="appbar">
        <Link to="/" className="iconbtn" aria-label="戻る">‹</Link>
        <h1>地域から探す</h1>
        <Link to="/search" className="iconbtn" aria-label="検索">🔍</Link>
      </header>

      {REGIONS.map((r) => {
        const prefs = r.prefs.filter((p) => counts[p])
        if (prefs.length === 0) return null
        return (
          <section className="sec" key={r.name}>
            <div className="sec-head"><b>{r.name}</b></div>
            <div className="grid">
              {prefs.map((p) => (
                <Link key={p} to={`/region/${encodeURIComponent(p)}`} className="gcard">
                  <div className="gname">{p}</div>
                  <div className="muted small">{counts[p]}社寺</div>
                </Link>
              ))}
            </div>
          </section>
        )
      })}
    </div>
  )
}
