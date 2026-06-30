import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useStore, useGeo } from '../data/providers'
import { ShrineRow } from '../components/ui'

export default function Search() {
  const store = useStore()
  const geo = useGeo()
  const [q, setQ] = useState('')
  const [type, setType] = useState(null)
  const [ntOnly, setNtOnly] = useState(false)

  const results = store.search(q, { type, ntOnly, origin: geo.coords })

  return (
    <div className="page">
      <header className="appbar">
        <Link to="/" className="iconbtn">‹</Link>
        <h1>社寺をさがす</h1>
        <span className="iconbtn" />
      </header>

      <div className="searchbar">
        <span>🔍</span>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="社寺名・地名で検索（例: 八幡、京都）" />
        {q && <button onClick={() => setQ('')}>✕</button>}
      </div>

      <div className="filterbar">
        <div className="seg">
          <button className={type === null ? 'on' : ''} onClick={() => setType(null)}>すべて</button>
          <button className={type === 'shrine' ? 'on' : ''} onClick={() => setType('shrine')}>神社</button>
          <button className={type === 'temple' ? 'on' : ''} onClick={() => setType('temple')}>寺</button>
        </div>
        <button className={`chip ${ntOnly ? 'on' : ''}`} onClick={() => setNtOnly((v) => !v)}>★ 国宝</button>
      </div>

      <div className="list">
        {results.length === 0 ? (
          <p className="empty">該当する社寺がありません。</p>
        ) : (
          results.slice(0, 300).map(([s, d]) => <ShrineRow key={s.slug} shrine={s} distance={d} />)
        )}
      </div>
    </div>
  )
}
