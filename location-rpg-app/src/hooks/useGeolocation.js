import { useEffect, useState } from 'react'

export function useGeolocation() {
  const [position, setPosition] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (!navigator.geolocation) {
      setError('このブラウザは位置情報に対応していません')
      return
    }
    const watchId = navigator.geolocation.watchPosition(
      (pos) => {
        setPosition({ lat: pos.coords.latitude, lng: pos.coords.longitude })
        setError(null)
      },
      (err) => setError(err.message),
      { enableHighAccuracy: true, maximumAge: 5000, timeout: 10000 }
    )
    return () => navigator.geolocation.clearWatch(watchId)
  }, [])

  return { position, error }
}

// ハバーサイン公式で2点間の距離をメートルで返す
export function distanceMeters(a, b) {
  const R = 6371000
  const toRad = (deg) => (deg * Math.PI) / 180
  const dLat = toRad(b.lat - a.lat)
  const dLng = toRad(b.lng - a.lng)
  const lat1 = toRad(a.lat)
  const lat2 = toRad(b.lat)
  const sinDLat = Math.sin(dLat / 2)
  const sinDLng = Math.sin(dLng / 2)
  const h = sinDLat * sinDLat + Math.cos(lat1) * Math.cos(lat2) * sinDLng * sinDLng
  return 2 * R * Math.asin(Math.sqrt(h))
}
