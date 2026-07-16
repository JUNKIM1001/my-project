import { useParams, Link, useNavigate } from 'react-router-dom'
import { MapContainer, TileLayer, CircleMarker } from 'react-leaflet'
import { useStore, useFavorites } from '../data/providers'
import { ShrineHero, TypeBadge, NTBadge, TVBadge, GoshuinBadge, GoriyakuTags, RecommendCard } from '../components/ui'
import { safeURL, isShrine, isNationalTreasure, hasGoshuin, tvActive, deityRoleLabel } from '../data/store'

export default function ShrineDetail() {
  const { slug } = useParams()
  const store = useStore()
  const fav = useFavorites()
  const nav = useNavigate()
  const s = store.bySlug[slug]
  if (!s) return <div className="page"><p className="empty">見つかりません</p></div>

  const related = store.related(s)
  const website = safeURL(s.website)
  const source = safeURL(s.source)
  const dir = `https://www.google.com/maps/dir/?api=1&destination=${s.lat},${s.lng}`

  return (
    <div className="page">
      <header className="appbar">
        <button className="iconbtn" onClick={() => nav(-1)}>‹</button>
        <h1 className="ellipsis">{s.name}</h1>
        <button className="iconbtn" onClick={() => fav.toggle(s.slug)} aria-label="お気に入り">
          {fav.has(s.slug) ? '❤️' : '🤍'}
        </button>
      </header>

      <div className="detail-hero"><ShrineHero shrine={s} showCredit /></div>

      <section className="card">
        <div className="row-head">
          <TypeBadge shrine={s} />
          {isNationalTreasure(s) && <NTBadge />}
          {tvActive(s) && <TVBadge />}
          {hasGoshuin(s) && <GoshuinBadge />}
          <span className="muted small">{s.sect}</span>
        </div>
        <div className="muted">{s.kana}</div>
        <p>{s.description}</p>
        {s.longDescription && <p className="muted small">{s.longDescription}</p>}
        {tvActive(s) && (
          <p className="tv-note">
            📺 {s.tv.program ? `「${s.tv.program}」` : 'テレビ'}で紹介（{s.tv.date}）
            {safeURL(s.tv.source) && <> — <a href={s.tv.source} target="_blank" rel="noreferrer">出典</a></>}
          </p>
        )}
        {hasGoshuin(s) && <p className="muted small">御朱印：あり</p>}
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
