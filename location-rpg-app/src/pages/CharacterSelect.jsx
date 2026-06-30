import { useNavigate } from 'react-router-dom'
import { characters } from '../data/mockData'
import { useGame } from '../data/GameContext'

export default function CharacterSelect() {
  const { selectCharacter } = useGame()
  const navigate = useNavigate()

  const handleSelect = (id) => {
    selectCharacter(id)
    navigate('/map')
  }

  return (
    <div className="page">
      <h1>相棒を選ぼう</h1>
      <p>最近、街にモンスターが出没するようになった。相棒と一緒に調査してほしい。</p>
      <div className="character-grid">
        {characters.map((c) => (
          <button key={c.id} className="character-card" onClick={() => handleSelect(c.id)}>
            <img src={c.image} alt={c.name} />
            <h2>{c.name}</h2>
            <p className="character-type">{c.type}</p>
            <p>{c.description}</p>
            <ul className="stats">
              <li>HP: {c.hp}</li>
              <li>こうげき: {c.attack}</li>
              <li>すばやさ: {c.speed}</li>
            </ul>
          </button>
        ))}
      </div>
    </div>
  )
}
