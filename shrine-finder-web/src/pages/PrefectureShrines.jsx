import { useParams, Link } from 'react-router-dom'
import { useStore, useGeo } from '../data/providers'
import { ShrineRow } from '../components/ui'

export default function PrefectureShrines() {
  const { pref } = useParams()
  const store = useStore()
  const geo = useGeo()
  const name = pref || '' // React Router v7 が復号済みなので再デコードしない
  const list = store.shrinesInPref(name, geo.coords)

  return (
    <div className="page">
      <header className="appbar">
        <Link to="/region" className="iconbtn" aria-label="戻る">‹</Link>
        <h1>{name}</h1>
        <span className="iconbtn" />
      </header>

      {!geo.coords && list.length > 0 && (
        <button className="cta" onClick={geo.request}>📍 現在地から近い順に並べる</button>
      )}

      <section className="sec">
        <div className="sec-head">
          <b>{name}の社寺（{geo.coords ? '近い順・' : ''}{list.length}件）</b>
        </div>
        {list.length === 0 ? (
          <p className="muted">この地域の社寺はまだ登録されていません。</p>
        ) : (
          <div className="list">
            {list.map(([s, d]) => <ShrineRow key={s.slug} shrine={s} distance={d} />)}
          </div>
        )}
      </section>
    </div>
  )
}
