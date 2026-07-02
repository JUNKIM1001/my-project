import { useDeferredValue, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { useStore, useGeo } from '../data/providers'
import { ShrineRow, PagedList } from '../components/ui'
import usePageTitle from '../hooks/usePageTitle'

export default function Search() {
  const store = useStore()
  const geo = useGeo()
  usePageTitle('社寺をさがす')
  const [q, setQ] = useState('')
  const [type, setType] = useState(null)
  const [ntOnly, setNtOnly] = useState(false)

  const deferredQ = useDeferredValue(q)
  const results = useMemo(
    () => store.search(deferredQ, { type, ntOnly, origin: geo.coords }),
    [store, deferredQ, type, ntOnly, geo.coords]
  )

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

      <PagedList
        items={results}
        empty="該当する社寺がありません。"
        renderItem={([s, d]) => <ShrineRow key={s.slug} shrine={s} distance={d} />}
      />
    </div>
  )
}
