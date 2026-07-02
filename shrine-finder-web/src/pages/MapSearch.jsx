import { useEffect, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { MapContainer, TileLayer, CircleMarker, Popup, useMap, useMapEvents } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import { useStore, useGeo } from '../data/providers'
import { ShrineRow } from '../components/ui'
import { isShrine } from '../data/store'
import usePageTitle from '../hooks/usePageTitle'

// 地図に表示する最大件数（取得・描画で共通）
const MAP_LIMIT = 150

function MapController({ onBounds, onReady }) {
  const map = useMap()
  useEffect(() => { onReady(map); onBounds(map.getBounds()) }, [map, onBounds, onReady])
  useMapEvents({ moveend: () => onBounds(map.getBounds()), zoomend: () => onBounds(map.getBounds()) })
  return null
}

export default function MapSearch() {
  const store = useStore()
  const geo = useGeo()
  usePageTitle('地図でさがす')
  const [map, setMap] = useState(null)
  const [bounds, setBounds] = useState(null)
  const [q, setQ] = useState('')
  const [goriyakuFilter, setGoriyakuFilter] = useState('')
  const [shrineOnly, setShrineOnly] = useState(false)
  const [placeSearch, setPlaceSearch] = useState('idle') // idle | loading | notfound | error

  // 現在地が得られたら初回だけ地図を移動（📍ボタンで再度移動できる）
  const flewRef = useRef(false)
  useEffect(() => {
    if (!map || !geo.coords || flewRef.current) return
    flewRef.current = true
    map.flyTo([geo.coords.lat, geo.coords.lng], 12)
  }, [map, geo.coords])

  const visible = bounds
    ? store.shrinesInBounds({
        latMin: bounds.getSouth(), latMax: bounds.getNorth(),
        lngMin: bounds.getWest(), lngMax: bounds.getEast(),
        center: { lat: bounds.getCenter().lat, lng: bounds.getCenter().lng },
        goriyaku: goriyakuFilter || null, type: shrineOnly ? 'shrine' : null, limit: MAP_LIMIT,
      })
    : []

  async function goTo(query) {
    const t = query.trim()
    if (!t || !map) return
    const hit = store.shrines.find((s) => s.name.includes(t) || s.city.includes(t) || s.pref.includes(t))
    if (hit) { setPlaceSearch('idle'); map.flyTo([hit.lat, hit.lng], 12); return }
    setPlaceSearch('loading')
    try {
      const r = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=jp&q=${encodeURIComponent(t)}`
      )
      if (!r.ok) throw new Error(`HTTP ${r.status}`)
      const j = await r.json()
      if (j[0]) {
        setPlaceSearch('idle')
        map.flyTo([parseFloat(j[0].lat), parseFloat(j[0].lon)], 12)
      } else {
        setPlaceSearch('notfound')
      }
    } catch {
      setPlaceSearch('error')
    }
  }

  const geoUnavailable = geo.status === 'denied' || geo.status === 'error'

  return (
    <div className="page map-page">
      <header className="appbar">
        <span className="iconbtn" />
        <h1>地図でさがす</h1>
        <button className="iconbtn" onClick={() => { flewRef.current = false; geo.request() }} aria-label="現在地">📍</button>
      </header>

      <div className="searchbar">
        <span>🔍</span>
        <form style={{ flex: 1, display: 'flex' }} onSubmit={(e) => { e.preventDefault(); goTo(q) }}>
          <input
            value={q}
            onChange={(e) => { setQ(e.target.value); setPlaceSearch('idle') }}
            placeholder="行き先を入力（例: 出雲、京都、高尾山）"
          />
        </form>
        {q && <button onClick={() => { setQ(''); setPlaceSearch('idle') }}>✕</button>}
      </div>

      {placeSearch !== 'idle' && (
        <p className="inline-note muted small" role="status">
          {placeSearch === 'loading' ? '場所を検索中…'
            : placeSearch === 'notfound' ? '「' + q.trim() + '」は見つかりませんでした。'
            : '検索に失敗しました。通信環境をご確認ください。'}
        </p>
      )}
      {geoUnavailable && (
        <p className="inline-note muted small" role="status">
          位置情報が利用できません。ブラウザの設定でこのサイトの位置情報を許可すると、現在地に移動できます。
        </p>
      )}

      <div className="mapwrap">
        <MapContainer center={[35.681, 139.767]} zoom={11} preferCanvas style={{ height: '100%' }}>
          <TileLayer attribution='&copy; OpenStreetMap contributors' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
          <MapController onReady={setMap} onBounds={setBounds} />
          {visible.map(([s]) => (
            <CircleMarker key={s.slug} center={[s.lat, s.lng]} radius={7}
              pathOptions={{
                color: isShrine(s) ? '#bf3830' : '#2d6a9f',
                fillColor: isShrine(s) ? '#bf3830' : '#2d6a9f', fillOpacity: 0.85, weight: 1,
              }}>
              <Popup>
                <Link to={`/shrine/${s.slug}`}><b>{s.name}</b></Link>
                <div style={{ fontSize: 11, color: '#666' }}>{s.pref}{s.city}</div>
              </Popup>
            </CircleMarker>
          ))}
        </MapContainer>
      </div>

      <div className="filterbar">
        <select value={goriyakuFilter} onChange={(e) => setGoriyakuFilter(e.target.value)}>
          <option value="">ご利益で絞る</option>
          {store.goriyaku.map((g) => <option key={g.slug} value={g.slug}>{g.name}</option>)}
        </select>
        <span className="muted small">{visible.length >= MAP_LIMIT ? `${MAP_LIMIT}件以上（近い順に${MAP_LIMIT}件表示）` : `${visible.length}件`}</span>
        <label className="toggle"><input type="checkbox" checked={shrineOnly} onChange={(e) => setShrineOnly(e.target.checked)} />神社のみ</label>
      </div>

      <div className="list">
        {visible.length === 0
          ? <p className="empty">この範囲に社寺がありません。地図を移動・縮小してください。</p>
          : visible.map(([s, d]) => <ShrineRow key={s.slug} shrine={s} highlight={goriyakuFilter || null} distance={d} />)}
      </div>
    </div>
  )
}
