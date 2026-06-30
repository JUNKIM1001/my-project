import { useEffect, useMemo, useRef, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useGame } from '../data/GameContext'
import { mapSpots, monsters, items } from '../data/mockData'

// フェーズ: encounter -> command -> playerAction -> enemyAction -> result -> transition
const ENCOUNTER_DURATION = 1200
const ACTION_MOTION_DURATION = 400
const ACTION_HIT_DURATION = 500
const TURN_GAP_DURATION = 500

export default function Battle() {
  const { spotId } = useParams()
  const navigate = useNavigate()
  const { character, recordVictory } = useGame()

  const spot = mapSpots.find((s) => s.id === spotId)
  const monsterTemplate = monsters.find((m) => m.id === spot?.refId)
  const dropItem = useMemo(
    () => items.find((i) => i.id === monsterTemplate?.dropItemId),
    [monsterTemplate]
  )

  const [phase, setPhase] = useState('encounter')
  const [playerHp, setPlayerHp] = useState(character?.hp ?? 0)
  const [enemyHp, setEnemyHp] = useState(monsterTemplate?.hp ?? 0)
  const [log, setLog] = useState([])
  const [outcome, setOutcome] = useState(null) // 'win' | 'lose' | 'run'
  const [resultStep, setResultStep] = useState(0)
  const [playerAnim, setPlayerAnim] = useState(null) // 'attack' | 'defend' | 'run' | 'hit' | 'down'
  const [enemyAnim, setEnemyAnim] = useState(null) // 'hit' | 'down'
  const [popup, setPopup] = useState(null) // { side: 'player'|'enemy', text }

  const pendingCommand = useRef(null)
  const recorded = useRef(false)

  const appendLog = (msg) => setLog((l) => [msg, ...l])

  // エンカウント演出: 一定時間後にコマンド入力フェーズへ
  useEffect(() => {
    if (phase !== 'encounter' || !monsterTemplate) return
    appendLog(`野生の${monsterTemplate.name}が現れた!`)
    const t = setTimeout(() => setPhase('command'), ENCOUNTER_DURATION)
    return () => clearTimeout(t)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [phase, monsterTemplate])

  // 勝利・敗北の確定演出: 段階的に結果メッセージを表示する
  useEffect(() => {
    if (phase !== 'result' || !outcome) return
    if (outcome === 'win' && resultStep < (dropItem ? 2 : 1)) {
      const t = setTimeout(() => {
        if (resultStep === 0) appendLog(`${monsterTemplate.name}を たおした!`)
        if (resultStep === 1 && dropItem) appendLog(`${dropItem.name} を手に入れた!`)
        setResultStep((s) => s + 1)
      }, 700)
      return () => clearTimeout(t)
    }
  }, [phase, outcome, resultStep, dropItem, monsterTemplate])

  if (!character) {
    return (
      <div className="page">
        <p>まずはキャラクターを選んでください。</p>
        <button onClick={() => navigate('/')}>キャラクター選択へ</button>
      </div>
    )
  }

  if (!monsterTemplate) {
    return (
      <div className="page">
        <p>バトル情報が見つかりません。</p>
        <button onClick={() => navigate('/map')}>フィールドに戻る</button>
      </div>
    )
  }

  const runEnemyTurn = (currentPlayerHp, defending) => {
    setPhase('enemyAction')
    setTimeout(() => setEnemyAnim('attack'), 50)
    setTimeout(() => {
      setEnemyAnim(null)
      const rawDmg = Math.max(1, monsterTemplate.attack - 1 + Math.floor(Math.random() * 3))
      const dmg = defending ? Math.max(1, Math.floor(rawDmg / 2)) : rawDmg
      const nextHp = Math.max(0, currentPlayerHp - dmg)
      setPopup({ side: 'player', text: `-${dmg}` })
      setPlayerAnim('hit')
      setPlayerHp(nextHp)
      appendLog(
        defending
          ? `${character.name}は身を守りながら ${dmg} のダメージを受けた`
          : `${monsterTemplate.name}の攻撃! ${character.name}は ${dmg} のダメージを受けた`
      )
      setTimeout(() => {
        setPopup(null)
        setPlayerAnim(null)
        if (nextHp <= 0) {
          setPlayerAnim('down')
          appendLog(`${character.name}は たおれてしまった…`)
          setOutcome('lose')
          setPhase('result')
        } else {
          setPhase('command')
        }
      }, ACTION_HIT_DURATION)
    }, ACTION_MOTION_DURATION)
  }

  const startPlayerAction = (command) => {
    if (phase !== 'command') return
    pendingCommand.current = command
    setPhase('playerAction')

    if (command === 'run') {
      setPlayerAnim('run')
      appendLog(`${character.name}は逃げ出した!`)
      setTimeout(() => {
        setOutcome('run')
        setPhase('result')
      }, ACTION_MOTION_DURATION + TURN_GAP_DURATION)
      return
    }

    if (command === 'defend') {
      setPlayerAnim('defend')
      appendLog(`${character.name}は身を守っている`)
      setTimeout(() => {
        setPlayerAnim(null)
        setTimeout(() => runEnemyTurn(playerHp, true), TURN_GAP_DURATION)
      }, ACTION_MOTION_DURATION)
      return
    }

    // attack
    setPlayerAnim('attack')
    setTimeout(() => {
      setPlayerAnim(null)
      const dmg = Math.max(1, character.attack - 1 + Math.floor(Math.random() * 3))
      const nextEnemyHp = Math.max(0, enemyHp - dmg)
      setPopup({ side: 'enemy', text: `-${dmg}` })
      setEnemyAnim('hit')
      setEnemyHp(nextEnemyHp)
      appendLog(`${character.name}の攻撃! ${monsterTemplate.name}に ${dmg} のダメージ`)
      setTimeout(() => {
        setPopup(null)
        setEnemyAnim(null)
        if (nextEnemyHp <= 0) {
          setEnemyAnim('down')
          if (!recorded.current) {
            recorded.current = true
            recordVictory(`${spot.id}-${Date.now()}`, monsterTemplate.dropItemId, spot.id)
          }
          setOutcome('win')
          setPhase('result')
        } else {
          setTimeout(() => runEnemyTurn(playerHp, false), TURN_GAP_DURATION)
        }
      }, ACTION_HIT_DURATION)
    }, ACTION_MOTION_DURATION)
  }

  const showResultActions =
    phase === 'result' &&
    (outcome === 'lose' ||
      outcome === 'run' ||
      (outcome === 'win' && resultStep >= (dropItem ? 2 : 1)))

  return (
    <div className="page">
      <h1>バトル!</h1>
      <div className={`battle-field ${phase === 'encounter' ? 'encounter-in' : ''}`}>
        <div className={`combatant ${playerAnim ? `anim-${playerAnim}` : ''}`}>
          <h2>{character.name}</h2>
          <div className="hp-bar">
            <div
              className="hp-fill"
              style={{ width: `${(playerHp / character.hp) * 100}%`, transition: 'width 0.6s ease' }}
            />
          </div>
          <p>HP {playerHp} / {character.hp}</p>
          {popup?.side === 'player' && <span className="dmg-popup">{popup.text}</span>}
        </div>
        <div className={`combatant ${enemyAnim ? `anim-${enemyAnim}` : ''}`}>
          <h2>{monsterTemplate.name}</h2>
          <div className="hp-bar enemy">
            <div
              className="hp-fill"
              style={{ width: `${(enemyHp / monsterTemplate.hp) * 100}%`, transition: 'width 0.6s ease' }}
            />
          </div>
          <p>HP {enemyHp} / {monsterTemplate.hp}</p>
          {popup?.side === 'enemy' && <span className="dmg-popup">{popup.text}</span>}
        </div>
      </div>

      <div className="battle-log">
        {log.map((line, i) => (
          <p key={i}>{line}</p>
        ))}
      </div>

      {phase === 'command' && (
        <div className="battle-commands">
          <button onClick={() => startPlayerAction('attack')}>攻撃</button>
          <button onClick={() => startPlayerAction('defend')}>防御</button>
          <button onClick={() => startPlayerAction('run')}>逃げる</button>
        </div>
      )}

      {phase !== 'command' && phase !== 'result' && (
        <p className="hint">…</p>
      )}

      {showResultActions && (
        <div className="battle-result">
          {outcome === 'win' && <p>勝利した!</p>}
          {outcome === 'lose' && <p>力尽きてしまった…相棒は無事マップで回復する。</p>}
          {outcome === 'run' && <p>うまく逃げ切った。</p>}
          <button onClick={() => navigate('/map')}>フィールドに戻る</button>
        </div>
      )}
    </div>
  )
}
