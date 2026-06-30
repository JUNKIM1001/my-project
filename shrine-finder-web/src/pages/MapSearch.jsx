import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { MapContainer, TileLayer, CircleMarker, Popup, useMap, useMapEvents } from 'react-leaflet'
import { useStore, useGeo } from '../data/providers'
import { ShrineRow } from '../components/ui'
import { isShrine } from '../data/store'

function MapController({ onBounds, onReady }) {
  const map = useMap()
  useEffect(() => { onReady(map); onBounds(map.getBounds()) }, [map]) // eslint-disable-line
  useMapEvents({ moveend: () => onBounds(map.getBounds()), zoomend: () => onBounds(map.getBounds()) })
  return null
}

export default function MapSearch() {
  const store = useStore()
  const geo = useGeo()
  const [map, setMap] = useState(null)
  const [bounds, setBounds] = useState(null)
  const [q, setQ] = useState('')
  const [goriyakuFilter, setGoriyakuFilter] = useState('')
  const [shrineOnly, setShrineOnly] = useState(false)

  useEffect(() => { geo.request() }, []) // eslint-disable-line
  useEffect(() => { if (map && geo.coords) map.flyTo([geo.coords.lat, geo.coords.lng], 12) }, [geo.coords]) // eslint-disable-line

  const visible = bounds
    ? store.shrinesInBounds({
        latMin: bounds.getSouth(), latMax: bounds.getNorth(),
        lngMin: bounds.getWest(), lngMax: bounds.getEast(),
        center: { lat: bounds.getCenter().lat, lng: bounds.getCenter().lng },
        goriyaku: goriyakuFilter || null, type: shrineOnly ? 'shrine' : null, limit: 200,
      })
    : []

  async function goTo(query) {
    const t = query.trim()
    if (!t || !map) return
    const hit = store.shrines.find((s) => s.name.includes(t) || s.city.includes(t) || s.pref.includes(t))
    if (hit) { map.flyTo([hit.lat, hit.lng], 12); return }
    try {
      const r = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=jp&q=${encodeURIComponent(t)}`
      )
      const j = await r.json()
      if (j[0]) map.flyTo([parseFloat(j[0].lat), parseFloat(j[0].lon)], 12)
    } catch { /* ignore */ }
  }

  return (
    <div className="page map-page">
      <header className="appbar">
        <span className="iconbtn" />
        <h1>地図でさがす</h1>
        <button className="iconbtn" onClick={() => geo.request()} aria-label="現在地">📍</button>
      </header>

      <div className="searchbar">
        <span>🔍</span>
        <form style={{ flex: 1, display: 'flex' }} onSubmit={(e) => { e.preventDefault(); goTo(q) }}>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="行き先を入力（例: 出雲、京都、高尾山）" />
        </form>
        {q && <button onClick={() => setQ('')}>✕</button>}
      </div>

      <div className="mapwrap">
        <MapContainer center={[35.681, 139.767]} zoom={11} style={{ height: '100%' }}>
          <TileLayer attribution='&copy; OpenStreetMap contributors' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
          <MapController onReady={setMap} onBounds={setBounds} />
          {visible.slice(0, 150).map(([s]) => (
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
        <span className="muted small">{visible.length}件</span>
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
