import { useParams, Link, useNavigate } from 'react-router-dom'
import { useStore } from '../data/providers'
import { ShrineRow, GoriyakuTags } from '../components/ui'

export default function DeityDetail() {
  const { slug } = useParams()
  const store = useStore()
  const nav = useNavigate()
  const d = store.deityBySlug[slug]
  if (!d) return <div className="page"><p className="empty">見つかりません</p></div>
  const shrines = store.shrinesEnshrining(slug)
  return (
    <div className="page">
      <header className="appbar">
        <button className="iconbtn" onClick={() => nav(-1)}>‹</button>
        <h1>{d.name}</h1>
        <span className="iconbtn" />
      </header>
      <section className="card">
        <div className="muted">{d.kana}</div>
        <div className="accent small">{d.kind === 'kami' ? '神様' : '仏様'}・{d.category}</div>
        <p>{d.description}</p>
      </section>
      <section className="sec">
        <b>司るご利益</b>
        <GoriyakuTags slugs={d.goriyaku} />
      </section>
      <section className="sec">
        <b>この神仏を祀る社寺</b>
        <div className="list">{shrines.map((s) => <ShrineRow key={s.slug} shrine={s} />)}</div>
      </section>
    </div>
  )
}
