import { useMemo, useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { useStore, useGeo } from '../data/providers'
import { ShrineRow, PagedList } from '../components/ui'
import usePageTitle from '../hooks/usePageTitle'
import NotFound from './NotFound'

export default function WishResult() {
  const { slug } = useParams()
  const store = useStore()
  const geo = useGeo()
  const g = store.goriyakuBySlug[slug]
  usePageTitle(g ? g.name : undefined)
  const [pref, setPref] = useState('')

  const ranked = useMemo(() => {
    let list = store.shrinesForGoriyaku(slug)
    if (pref) list = list.filter((s) => s.pref === pref)
    return geo.coords
      ? list.map((s) => [s, store.dist(geo.coords, s)]).sort((a, b) => a[1] - b[1])
      : list.map((s) => [s, null])
  }, [store, slug, pref, geo.coords])

  if (!g) return <NotFound message="このご利益は見つかりません" />

  const deities = store.deitiesForGoriyaku(slug)
  const geoUnavailable = geo.status === 'denied' || geo.status === 'error'

  return (
    <div className="page">
      <header className="appbar">
        <Link to="/" className="iconbtn">‹</Link>
        <h1>{g.name}</h1>
        <span className="iconbtn" />
      </header>

      <section className="sec">
        <div className="sec-head"><b>「{g.name}」を司る神仏</b></div>
        {g.description && <p className="muted small">{g.description}</p>}
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
        geoUnavailable ? (
          <p className="geo-note muted small">
            位置情報が利用できないため、近い順の並べ替えはできません。ブラウザの設定でこのサイトの位置情報を許可すると、現在地から近い順に表示できます。
          </p>
        ) : (
          <button className="cta" onClick={geo.request} disabled={geo.status === 'loading'}>
            {geo.status === 'loading' ? '📍 現在地を取得中…' : '📍 現在地から近い順に並べる'}
          </button>
        )
      )}

      <section className="sec">
        <div className="sec-head">
          <b>参拝できる社寺（{geo.coords ? '近い順・' : ''}{ranked.length}件）</b>
          <select value={pref} onChange={(e) => setPref(e.target.value)} aria-label="都道府県で絞る">
            <option value="">すべての都道府県</option>
            {store.prefectures.map((p) => <option key={p} value={p}>{p}</option>)}
          </select>
        </div>
        <PagedList
          items={ranked}
          empty={pref ? `${pref}に該当する社寺がありません。` : '該当する社寺がありません。'}
          renderItem={([s, d]) => <ShrineRow key={s.slug} shrine={s} highlight={slug} distance={d} />}
        />
      </section>
    </div>
  )
}
