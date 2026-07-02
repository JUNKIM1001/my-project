import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useStore } from '../data/providers'
import usePageTitle from '../hooks/usePageTitle'

export default function DeityList() {
  const store = useStore()
  usePageTitle('神仏図鑑')
  const [kind, setKind] = useState('kami')
  const [q, setQ] = useState('')
  const list = store.deities.filter(
    (d) => d.kind === kind && (q === '' || d.name.includes(q) || (d.kana || '').includes(q))
  )
  return (
    <div className="page">
      <header className="appbar">
        <span className="iconbtn" />
        <h1>神仏図鑑</h1>
        <span className="iconbtn" />
      </header>
      <div className="seg seg-wide">
        <button className={kind === 'kami' ? 'on' : ''} onClick={() => setKind('kami')}>神様</button>
        <button className={kind === 'buddha' ? 'on' : ''} onClick={() => setKind('buddha')}>仏様</button>
      </div>
      <div className="searchbar">
        <span>🔍</span>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="神仏を検索" />
      </div>
      <div className="list">
        {list.map((d) => (
          <Link key={d.slug} to={`/deity/${d.slug}`} className="row">
            <div className="row-head">
              <span className="row-name">{d.name}</span>
              <span className="badge b-cat">{d.category}</span>
            </div>
            <div className="row-meta">{d.kana}</div>
            <div className="row-meta ellipsis">{d.description}</div>
          </Link>
        ))}
      </div>
    </div>
  )
}
