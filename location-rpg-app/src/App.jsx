import { HashRouter, Routes, Route } from 'react-router-dom'
import { GameProvider } from './data/GameContext'
import CharacterSelect from './pages/CharacterSelect'
import MapExplore from './pages/MapExplore'
import Battle from './pages/Battle'
import Inventory from './pages/Inventory'
import Missions from './pages/Missions'
import './App.css'

function App() {
  return (
    <GameProvider>
      <HashRouter>
        <Routes>
          <Route path="/" element={<CharacterSelect />} />
          <Route path="/map" element={<MapExplore />} />
          <Route path="/battle/:spotId" element={<Battle />} />
          <Route path="/inventory" element={<Inventory />} />
          <Route path="/missions" element={<Missions />} />
        </Routes>
      </HashRouter>
    </GameProvider>
  )
}

export default App
