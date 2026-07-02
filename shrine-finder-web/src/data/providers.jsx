import { createContext, useContext, useEffect, useState, useCallback } from 'react'
import { loadStore } from './store'

const StoreCtx = createContext(null)
const FavCtx = createContext(null)
const GeoCtx = createContext(null)

export function AppProviders({ children }) {
  const [store, setStore] = useState(null)
  const [loadError, setLoadError] = useState(null)
  const [loadAttempt, setLoadAttempt] = useState(0)
  useEffect(() => {
    let active = true
    loadStore()
      .then((s) => { if (active) setStore(s) })
      .catch((err) => { if (active) setLoadError(err) })
    return () => { active = false }
  }, [loadAttempt])
  const retryLoad = useCallback(() => {
    setLoadError(null)
    setLoadAttempt((n) => n + 1)
  }, [])

  // お気に入り（localStorage）
  const [slugs, setSlugs] = useState(() => {
    try { return new Set(JSON.parse(localStorage.getItem('favorite_shrine_slugs') || '[]')) }
    catch { return new Set() }
  })
  useEffect(() => {
    try { localStorage.setItem('favorite_shrine_slugs', JSON.stringify([...slugs])) }
    catch { /* プライベートモード等で保存できない場合は無視 */ }
  }, [slugs])
  const toggleFav = useCallback((slug) => {
    setSlugs((prev) => {
      const n = new Set(prev)
      if (n.has(slug)) n.delete(slug)
      else n.add(slug)
      return n
    })
  }, [])

  // 現在地: status = 'idle' | 'loading' | 'granted' | 'denied' | 'error'
  const [coords, setCoords] = useState(null)
  const [geoStatus, setGeoStatus] = useState('idle')
  const requestGeo = useCallback(() => {
    if (!navigator.geolocation) { setGeoStatus('error'); return }
    setGeoStatus('loading')
    navigator.geolocation.getCurrentPosition(
      (p) => {
        setCoords({ lat: p.coords.latitude, lng: p.coords.longitude })
        setGeoStatus('granted')
      },
      (err) => setGeoStatus(err.code === 1 ? 'denied' : 'error'),
      { enableHighAccuracy: false, timeout: 8000, maximumAge: 60000 }
    )
  }, [])

  // すでに許可済みのときだけ自動取得（許可ダイアログを勝手に出さない）
  useEffect(() => {
    if (!navigator.geolocation || !navigator.permissions?.query) return
    let active = true
    navigator.permissions.query({ name: 'geolocation' })
      .then((p) => { if (active && p.state === 'granted') requestGeo() })
      .catch(() => {})
    return () => { active = false }
  }, [requestGeo])

  if (loadError) {
    return (
      <div className="loading">
        <div className="empty-state">
          <div className="empty-emoji">⚠️</div>
          <p>データを読み込めませんでした</p>
          <p className="muted small">通信環境をご確認のうえ、もう一度お試しください。</p>
          <button className="cta" onClick={retryLoad}>再読み込み</button>
        </div>
      </div>
    )
  }
  if (!store) return <div className="loading">読み込み中…</div>

  return (
    <StoreCtx.Provider value={store}>
      <FavCtx.Provider value={{ slugs, has: (s) => slugs.has(s), toggle: toggleFav }}>
        <GeoCtx.Provider value={{ coords, status: geoStatus, request: requestGeo }}>{children}</GeoCtx.Provider>
      </FavCtx.Provider>
    </StoreCtx.Provider>
  )
}

export const useStore = () => useContext(StoreCtx)
export const useFavorites = () => useContext(FavCtx)
export const useGeo = () => useContext(GeoCtx)
