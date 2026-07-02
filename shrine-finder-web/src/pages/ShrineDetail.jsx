import { useEffect, useState } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import { MapContainer, TileLayer, CircleMarker } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import { useStore, useFavorites } from '../data/providers'
import { ShrineHero, TypeBadge, NTBadge, GoriyakuTags, RecommendCard } from '../components/ui'
import { safeURL, isNationalTreasure, deityRoleLabel } from '../data/store'
import { loadDetails } from '../data/details'
import usePageTitle from '../hooks/usePageTitle'
import NotFound from './NotFound'

export default function ShrineDetail() {
  const { slug } = useParams()
  const store = useStore()
  const fav = useFavorites()
  const nav = useNavigate()
  const s = store.bySlug[slug]
  usePageTitle(s ? s.name : undefined)

  // 全文説明は初回参照時に appdata-details.json から遅延取得（失敗時は本文セクションを出さないだけ）
  const [details, setDetails] = useState(null)
  useEffect(() => {
    let active = true
    loadDetails()
      .then((d) => { if (active) setDetails(d) })
      .catch(() => { /* 取得失敗時は本文セクションを表示しない */ })
    return () => { active = false }
  }, [])
  const longDesc = details?.shrines?.[slug] || null

  // 共有（Web Share API がなければURLをクリップボードへ）
  const [copied, setCopied] = useState(false)
  useEffect(() => {
    if (!copied) return
    const t = setTimeout(() => setCopied(false), 2000)
    return () => clearTimeout(t)
  }, [copied])
  async function share() {
    const url = window.location.href
    if (navigator.share) {
      try { await navigator.share({ title: `${s.name} | おまいりナビ`, text: `${s.name}（${s.pref}${s.city}）`, url }) }
      catch { /* ユーザーによるキャンセル等は無視 */ }
      return
    }
    try {
      await navigator.clipboard.writeText(url)
      setCopied(true)
    } catch { /* クリップボード不可の環境では何もしない */ }
  }

  if (!s) return <NotFound message="この社寺は見つかりません" />

  const related = store.related(s)
  const website = safeURL(s.website)
  const source = safeURL(s.source)
  const dir = `https://www.google.com/maps/dir/?api=1&destination=${s.lat},${s.lng}`

  return (
    <div className="page">
      <header className="appbar">
        <button className="iconbtn" onClick={() => nav(-1)}>‹</button>
        <h1 className="ellipsis">{s.name}</h1>
        <button className="iconbtn" onClick={share} aria-label="共有">📤</button>
        <button className="iconbtn" onClick={() => fav.toggle(s.slug)} aria-label="お気に入り">
          {fav.has(s.slug) ? '❤️' : '🤍'}
        </button>
      </header>

      {copied && <div className="toast" role="status">リンクをコピーしました</div>}

      <div className="detail-hero"><ShrineHero shrine={s} showCredit /></div>

      <section className="card">
        <div className="row-head">
          <TypeBadge shrine={s} />
          {isNationalTreasure(s) && <NTBadge />}
          <span className="muted small">{s.sect}</span>
        </div>
        <div className="muted">{s.kana}</div>
        <p>{s.description}</p>
        {longDesc && <p className="muted small">{longDesc}</p>}
      </section>

      <section className="sec">
        <b>アクセス</b>
        <div className="minimap">
          <MapContainer center={[s.lat, s.lng]} zoom={15} scrollWheelZoom={false} style={{ height: 180 }}>
            <TileLayer attribution='&copy; OpenStreetMap' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
            <CircleMarker center={[s.lat, s.lng]} radius={9}
              pathOptions={{ color: '#bf3830', fillColor: '#bf3830', fillOpacity: 0.9 }} />
          </MapContainer>
        </div>
        <a className="cta" href={dir} target="_blank" rel="noreferrer">🚗 経路案内（地図で開く）</a>
        <div className="muted small">{s.address}</div>
      </section>

      <section className="sec">
        <b>{deityRoleLabel(s)}</b>
        <div className="list">
          {store.deitiesOf(s).map((d) => (
            <Link key={d.slug} to={`/deity/${d.slug}`} className="row">
              <div className="row-name">{d.name}</div>
              <div className="row-meta">{d.kind === 'kami' ? '神様' : '仏様'}・{d.category}</div>
            </Link>
          ))}
        </div>
      </section>

      <section className="sec">
        <b>授かれるご利益</b>
        <GoriyakuTags slugs={store.goriyakuSlugsOf(s)} />
      </section>

      {related.length > 0 && (
        <section className="sec">
          <b>ここに行った人はこちらも</b>
          <div className="hscroll">{related.map((r) => <RecommendCard key={r.slug} shrine={r} />)}</div>
        </section>
      )}

      <section className="sec">
        <b>参照</b>
        <div className="links">
          {website ? (
            <a href={website} target="_blank" rel="noreferrer">🌐 公式サイト</a>
          ) : source ? (
            <a href={source} target="_blank" rel="noreferrer">📖 Wikipediaで見る</a>
          ) : null}
        </div>
        <p className="muted small">データは公式サイト・自治体・日本語Wikipedia等で裏取りしています。</p>
      </section>
    </div>
  )
}
