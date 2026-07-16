import { createContext, useContext, useEffect, useState, useCallback } from 'react'
import { loadStore } from './store'
import { loadStoreFromSupabase } from './supabase'

const StoreCtx = createContext(null)
const FavCtx = createContext(null)
const GeoCtx = createContext(null)

export function AppProviders({ children }) {
  const [store, setStore] = useState(null)
  useEffect(() => {
    // Supabaseが設定されていればそこから取得、無ければ同梱appdata.jsonにフォールバック
    loadStoreFromSupabase().then((s) => (s ? setStore(s) : loadStore().then(setStore)))
  }, [])

  // お気に入り（localStorage）
  const [slugs, setSlugs] = useState(() => {
    try { return new Set(JSON.parse(localStorage.getItem('favorite_shrine_slugs') || '[]')) }
    catch { return new Set() }
  })
  const toggleFav = useCallback((slug) => {
    setSlugs((prev) => {
      const n = new Set(prev)
      n.has(slug) ? n.delete(slug) : n.add(slug)
      localStorage.setItem('favorite_shrine_slugs', JSON.stringify([...n]))
      return n
    })
  }, [])

  // 現在地
  const [coords, setCoords] = useState(null)
  const requestGeo = useCallback(() => {
    if (!navigator.geolocation) return
    navigator.geolocation.getCurrentPosition(
      (p) => setCoords({ lat: p.coords.latitude, lng: p.coords.longitude }),
      () => {},
      { enableHighAccuracy: false, timeout: 8000, maximumAge: 60000 }
    )
  }, [])

  if (!store) return <div className="loading">読み込み中…</div>

  return (
    <StoreCtx.Provider value={store}>
      <FavCtx.Provider value={{ slugs, has: (s) => slugs.has(s), toggle: toggleFav }}>
        <GeoCtx.Provider value={{ coords, request: requestGeo }}>{children}</GeoCtx.Provider>
      </FavCtx.Provider>
    </StoreCtx.Provider>
  )
}

export const useStore = () => useContext(StoreCtx)
export const useFavorites = () => useContext(FavCtx)
export const useGeo = () => useContext(GeoCtx)
