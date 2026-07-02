import { Routes, Route, NavLink } from 'react-router-dom'
import { lazy, Suspense } from 'react'
import ScrollToTop from './hooks/ScrollToTop'
import Home from './pages/Home'
import WishResult from './pages/WishResult'
import DeityList from './pages/DeityList'
import DeityDetail from './pages/DeityDetail'
import Favorites from './pages/Favorites'
import Search from './pages/Search'
import About from './pages/About'
import NotFound from './pages/NotFound'

// Leaflet を含むページは遅延読み込みし、初回バンドルから地図関連を外す
const MapSearch = lazy(() => import('./pages/MapSearch'))
const ShrineDetail = lazy(() => import('./pages/ShrineDetail'))

export default function App() {
  return (
    <div className="app">
      <ScrollToTop />
      <div className="content">
        <Suspense fallback={<div className="loading">読み込み中…</div>}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/wish/:slug" element={<WishResult />} />
            <Route path="/map" element={<MapSearch />} />
            <Route path="/deities" element={<DeityList />} />
            <Route path="/deity/:slug" element={<DeityDetail />} />
            <Route path="/shrine/:slug" element={<ShrineDetail />} />
            <Route path="/favorites" element={<Favorites />} />
            <Route path="/search" element={<Search />} />
            <Route path="/about" element={<About />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </Suspense>
      </div>
      <nav className="tabbar">
        <NavLink to="/" end>✨<span>さがす</span></NavLink>
        <NavLink to="/map">🗺️<span>地図</span></NavLink>
        <NavLink to="/deities">📖<span>図鑑</span></NavLink>
        <NavLink to="/favorites">❤️<span>お気に入り</span></NavLink>
      </nav>
    </div>
  )
}
