import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { MapContainer, TileLayer, Marker, Circle, useMap } from 'react-leaflet'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { useGeolocation, distanceMeters } from '../hooks/useGeolocation'
import { useGame } from '../data/GameContext'
import { mapSpots, monsters, items, ENCOUNTER_RADIUS_METERS } from '../data/mockData'

// 初回取得位置を基準に、モックスポットの絶対座標を一度だけ計算する
function buildSpots(origin) {
  return mapSpots.map((spot) => ({
    ...spot,
    lat: origin.lat + spot.dLat,
    lng: origin.lng + spot.dLng,
  }))
}

const playerIcon = L.divIcon({
  className: 'map-icon player-icon player-icon-marker',
  html: '🧭',
  iconSize: [28, 28],
})

const monsterIcon = L.divIcon({
  className: 'map-icon monster-icon',
  html: '👹',
  iconSize: [26, 26],
})

const itemIcon = L.divIcon({
  className: 'map-icon item-icon',
  html: '🎁',
  iconSize: [26, 26],
})

function RecenterButton({ position }) {
  const map = useMap()
  if (!position) return null
  return (
    <button
      className="recenter-btn"
      onClick={() => map.setView([position.lat, position.lng], map.getZoom())}
    >
      現在地に戻る
    </button>
  )
}

export default function MapExplore() {
  const { position, error } = useGeolocation()
  const { character, state, collectItem } = useGame()
  const navigate = useNavigate()
  const [origin, setOrigin] = useState(null)
  const [spots, setSpots] = useState([])

  useEffect(() => {
    if (position && !origin) {
      setOrigin(position)
      setSpots(buildSpots(position))
    }
  }, [position, origin])

  const remainingSpots = useMemo(
    () => spots.filter((s) => !state.collectedSpotIds.includes(s.id)),
    [spots, state.collectedSpotIds]
  )

  const spotsWithDistance = useMemo(() => {
    if (!position) return []
    return remainingSpots
      .map((spot) => ({ spot, distance: distanceMeters(position, spot) }))
      .sort((a, b) => a.distance - b.distance)
  }, [remainingSpots, position])

  if (!character) {
    return (
      <div className="page">
        <p>まずはキャラクターを選んでください。</p>
        <button onClick={() => navigate('/')}>キャラクター選択へ</button>
      </div>
    )
  }

  const handleInteract = (spot) => {
    if (spot.type === 'monster') {
      navigate(`/battle/${spot.id}`)
    } else {
      collectItem(spot.refId, spot.id)
    }
  }

  return (
    <div className="page">
      <h1>フィールド探索</h1>
      <p>
        相棒: <strong>{character.name}</strong>
      </p>

      {error && <p className="warning">位置情報を取得できません: {error}(端末の位置情報設定をご確認ください)</p>}
      {!error && !position && <p>位置情報を取得しています…</p>}

      {position && (
        <>
          <p className="coords">
            現在地: {position.lat.toFixed(5)}, {position.lng.toFixed(5)}
          </p>
          <div className="map-wrap">
            <MapContainer
              center={[position.lat, position.lng]}
              zoom={17}
              scrollWheelZoom
              style={{ height: '320px', width: '100%', borderRadius: '8px' }}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <Marker position={[position.lat, position.lng]} icon={playerIcon} />
              {spotsWithDistance.map(({ spot, distance }) => {
                const inRange = distance <= ENCOUNTER_RADIUS_METERS
                return (
                  <div key={spot.id}>
                    <Marker
                      position={[spot.lat, spot.lng]}
                      icon={spot.type === 'monster' ? monsterIcon : itemIcon}
                    />
                    {inRange && (
                      <Circle
                        center={[spot.lat, spot.lng]}
                        radius={ENCOUNTER_RADIUS_METERS}
                        pathOptions={{ color: '#ff8a3d', fillOpacity: 0.15 }}
                      />
                    )}
                  </div>
                )
              })}
              <RecenterButton position={position} />
            </MapContainer>
          </div>
        </>
      )}

      <h2>近くのスポット</h2>
      {error && <p className="hint">位置情報が取得できないため、スポットを表示できません。</p>}
      {!error && !position && <p className="hint">位置情報の取得を待っています…</p>}
      {!error && position && spotsWithDistance.length === 0 && (
        <p>近くのスポットはすべて探索済みです。</p>
      )}
      <ul className="spot-list">
        {spotsWithDistance.map(({ spot, distance }) => {
          const inRange = distance <= ENCOUNTER_RADIUS_METERS
          const ref =
            spot.type === 'monster'
              ? monsters.find((m) => m.id === spot.refId)
              : items.find((i) => i.id === spot.refId)
          return (
            <li key={spot.id} className={`spot-item ${inRange ? 'in-range' : ''}`}>
              <div>
                <strong>{spot.type === 'monster' ? '👹 ' : '🎁 '}{ref?.name}</strong>
                <span className="distance">約 {Math.round(distance)}m</span>
              </div>
              <button disabled={!inRange} onClick={() => handleInteract(spot)}>
                {spot.type === 'monster' ? 'たたかう' : 'ひろう'}
              </button>
            </li>
          )
        })}
      </ul>

      <nav className="bottom-nav">
        <button onClick={() => navigate('/inventory')}>持ち物</button>
        <button onClick={() => navigate('/missions')}>ミッション</button>
      </nav>
    </div>
  )
}
