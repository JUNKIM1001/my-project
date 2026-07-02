import { useEffect, useMemo, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useStore } from '../data/providers'
import { ShrineRow, GoriyakuTags, PagedList } from '../components/ui'
import { loadDetails } from '../data/details'
import usePageTitle from '../hooks/usePageTitle'
import NotFound from './NotFound'

export default function DeityDetail() {
  const { slug } = useParams()
  const store = useStore()
  const nav = useNavigate()
  const d = store.deityBySlug[slug]
  usePageTitle(d ? d.name : undefined)
  const shrines = useMemo(() => store.shrinesEnshrining(slug), [store, slug])

  // 由来解説は初回参照時に appdata-details.json から遅延取得（失敗時はセクションを出さないだけ）
  const [details, setDetails] = useState(null)
  useEffect(() => {
    let active = true
    loadDetails()
      .then((x) => { if (active) setDetails(x) })
      .catch(() => { /* 取得失敗時は由来セクションを表示しない */ })
    return () => { active = false }
  }, [])
  const lore = details?.deities?.[slug] || null

  if (!d) return <NotFound message="この神仏は見つかりません" />
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
      {lore && (
        <section className="sec">
          <b>由来</b>
          <p className="muted small">{lore}</p>
        </section>
      )}
      <section className="sec">
        <b>司るご利益</b>
        <GoriyakuTags slugs={d.goriyaku} />
      </section>
      <section className="sec">
        <b>この神仏を祀る社寺</b>
        <PagedList
          items={shrines}
          empty="この神仏を祀る社寺は収録されていません。"
          renderItem={(s) => <ShrineRow key={s.slug} shrine={s} />}
        />
      </section>
    </div>
  )
}
