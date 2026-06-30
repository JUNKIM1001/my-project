import { useNavigate } from 'react-router-dom'
import { useGame } from '../data/GameContext'
import QrCode from '../components/QrCode'

export default function Missions() {
  const { missionProgress, claimMission } = useGame()
  const navigate = useNavigate()

  return (
    <div className="page">
      <h1>ミッション</h1>
      <ul className="mission-list">
        {missionProgress.map((m) => (
          <li key={m.id} className="mission-item">
            <h2>{m.title}</h2>
            <p>{m.description}</p>
            <p>
              進捗: {Math.min(m.current, m.target)} / {m.target}
            </p>
            {m.achieved && !m.claimed && (
              <button onClick={() => claimMission(m.id)}>QRコードを受け取る</button>
            )}
            {m.claimed && (
              <div className="qr-reward">
                <p>達成報酬のQRコードを店舗スタッフに見せよう!</p>
                <QrCode value={m.qrCode} />
              </div>
            )}
            {!m.achieved && <p className="hint">まだ達成していません</p>}
          </li>
        ))}
      </ul>
      <button onClick={() => navigate('/map')}>フィールドに戻る</button>
    </div>
  )
}
