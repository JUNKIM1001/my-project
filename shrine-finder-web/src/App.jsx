import { Routes, Route, NavLink, useLocation } from 'react-router-dom'
import { useEffect } from 'react'
import Home from './pages/Home'
import WishResult from './pages/WishResult'
import MapSearch from './pages/MapSearch'
import RegionSearch from './pages/RegionSearch'
import PrefectureShrines from './pages/PrefectureShrines'
import DeityList from './pages/DeityList'
import DeityDetail from './pages/DeityDetail'
import ShrineDetail from './pages/ShrineDetail'
import Favorites from './pages/Favorites'
import Search from './pages/Search'
import About from './pages/About'

function ScrollTop() {
  const { pathname } = useLocation()
  useEffect(() => { document.querySelector('.content')?.scrollTo(0, 0) }, [pathname])
  return null
}

export default function App() {
  return (
    <div className="app">
      <ScrollTop />
      <div className="content">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/wish/:slug" element={<WishResult />} />
          <Route path="/map" element={<MapSearch />} />
          <Route path="/region" element={<RegionSearch />} />
          <Route path="/region/:pref" element={<PrefectureShrines />} />
          <Route path="/deities" element={<DeityList />} />
          <Route path="/deity/:slug" element={<DeityDetail />} />
          <Route path="/shrine/:slug" element={<ShrineDetail />} />
          <Route path="/favorites" element={<Favorites />} />
          <Route path="/search" element={<Search />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </div>
      <nav className="tabbar">
        <NavLink to="/" end>✨<span>さがす</span></NavLink>
        <NavLink to="/region">📍<span>地域</span></NavLink>
        <NavLink to="/map">🗺️<span>地図</span></NavLink>
        <NavLink to="/deities">📖<span>図鑑</span></NavLink>
        <NavLink to="/favorites">❤️<span>お気に入り</span></NavLink>
      </nav>
    </div>
  )
}
