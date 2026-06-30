import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useStore } from '../data/providers'
import {
  safeURL, isShrine, isNationalTreasure, typeLabel, deityRoleLabel, distanceLabel,
} from '../data/store'

/** オリジナルのシンボルアート（神社=鳥居 / 寺=五重塔） */
export function Motif({ shrine }) {
  const shrineType = isShrine(shrine)
  const colors = shrineType ? ['#c4543b', '#962618'] : ['#3d557e', '#274a55']
  return (
    <svg className="motif" viewBox="0 0 168 96" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
      <defs>
        <linearGradient id={`g-${shrine.slug}`} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor={colors[0]} />
          <stop offset="1" stopColor={colors[1]} />
        </linearGradient>
      </defs>
      <rect width="168" height="96" fill={`url(#g-${shrine.slug})`} />
      {shrineType ? (
        <g fill="#fbf8f3">
          <rect x="55" y="30" width="6" height="50" />
          <rect x="107" y="30" width="6" height="50" />
          <path d="M30 24 Q84 18 138 24 L138 31 Q84 27 30 31 Z" />
          <rect x="46" y="40" width="76" height="6" />
        </g>
      ) : (
        <g fill="#fbf8f3">
          <rect x="83" y="20" width="2" height="12" />
          <path d="M58 36 Q84 28 110 36 L110 41 Q84 34 58 41 Z" />
          <path d="M50 50 Q84 42 118 50 L118 55 Q84 48 50 55 Z" />
          <path d="M44 64 Q84 56 124 64 L124 69 Q84 62 44 69 Z" />
          <rect x="76" y="66" width="16" height="16" />
        </g>
      )}
    </svg>
  )
}

export function ShrineHero({ shrine, showCredit = false }) {
  const store = useStore()
  const [err, setErr] = useState(false)
  const url = safeURL(shrine.imageURL)
  const credit = store.imageCredit(shrine)
  return (
    <div className="hero">
      {url && !err ? (
        <img src={url} alt={shrine.name} loading="lazy" onError={() => setErr(true)} />
      ) : (
        <Motif shrine={shrine} />
      )}
      {showCredit && url && !err && credit && <span className="credit">{credit}</span>}
    </div>
  )
}

export function TypeBadge({ shrine }) {
  return <span className={`badge ${isShrine(shrine) ? 'b-shrine' : 'b-temple'}`}>{typeLabel(shrine)}</span>
}
export function NTBadge() {
  return <span className="badge b-nt">★国宝</span>
}

export function GoriyakuTags({ slugs, highlight }) {
  const store = useStore()
  return (
    <div className="tags">
      {store.names(slugs).map((g) => (
        <span key={g.slug} className={`tag ${g.slug === highlight ? 'hit' : ''}`}>{g.name}</span>
      ))}
    </div>
  )
}

export function ShrineRow({ shrine, highlight, distance }) {
  const store = useStore()
  return (
    <Link to={`/shrine/${shrine.slug}`} className="row">
      <div className="row-head">
        <span className="row-name">{shrine.name}</span>
        <TypeBadge shrine={shrine} />
        {isNationalTreasure(shrine) && <NTBadge />}
        <span className="spacer" />
        {distance != null && <span className="row-dist">{distanceLabel(distance)}</span>}
      </div>
      <div className="row-meta">
        {shrine.pref} {shrine.city}・{deityRoleLabel(shrine)}：{store.deitiesOf(shrine).map((d) => d.name).join('、')}
      </div>
      <GoriyakuTags slugs={store.goriyakuSlugsOf(shrine)} highlight={highlight} />
    </Link>
  )
}

export function RecommendCard({ shrine, distance }) {
  return (
    <Link to={`/shrine/${shrine.slug}`} className="rec-card">
      <div className="rec-photo">
        <ShrineHero shrine={shrine} />
        {isNationalTreasure(shrine) && <span className="rec-nt"><NTBadge /></span>}
        {distance != null && <span className="rec-dist">{distanceLabel(distance)}</span>}
      </div>
      <div className="rec-text">
        <div className="rec-name">{shrine.name}</div>
        <div className="rec-loc">{shrine.pref}{shrine.city}</div>
      </div>
    </Link>
  )
}
