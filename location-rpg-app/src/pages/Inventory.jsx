import { useNavigate } from 'react-router-dom'
import { useGame } from '../data/GameContext'

export default function Inventory() {
  const { inventoryItems } = useGame()
  const navigate = useNavigate()

  return (
    <div className="page">
      <h1>持ち物</h1>
      {inventoryItems.length === 0 && <p>まだ何も持っていません。フィールドでアイテムを探そう。</p>}
      <ul className="item-list">
        {inventoryItems.map((item, i) => (
          <li key={`${item.id}-${i}`}>
            <strong>{item.name}</strong>
            <p>{item.description}</p>
          </li>
        ))}
      </ul>
      <button onClick={() => navigate('/map')}>フィールドに戻る</button>
    </div>
  )
}
