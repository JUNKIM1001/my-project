import { createContext, useContext, useEffect, useState } from 'react'
import { loadState, saveState } from './gameState'
import { characters, items, missions } from './mockData'

const GameContext = createContext(null)

export function GameProvider({ children }) {
  const [state, setState] = useState(() => loadState())

  useEffect(() => {
    saveState(state)
  }, [state])

  const selectCharacter = (characterId) => {
    setState((s) => ({ ...s, characterId }))
  }

  const collectItem = (itemId, spotId) => {
    setState((s) => {
      if (s.collectedSpotIds.includes(spotId)) return s
      return {
        ...s,
        inventory: [...s.inventory, itemId],
        collectedSpotIds: [...s.collectedSpotIds, spotId],
      }
    })
  }

  const recordVictory = (monsterInstanceId, dropItemId, spotId) => {
    setState((s) => ({
      ...s,
      defeatedMonsterIds: [...s.defeatedMonsterIds, monsterInstanceId],
      inventory: dropItemId ? [...s.inventory, dropItemId] : s.inventory,
      collectedSpotIds: spotId ? [...s.collectedSpotIds, spotId] : s.collectedSpotIds,
    }))
  }

  const claimMission = (missionId) => {
    setState((s) => {
      if (s.claimedMissionIds.includes(missionId)) return s
      return { ...s, claimedMissionIds: [...s.claimedMissionIds, missionId] }
    })
  }

  const character = characters.find((c) => c.id === state.characterId) || null

  const inventoryItems = state.inventory
    .map((id) => items.find((i) => i.id === id))
    .filter(Boolean)

  const missionProgress = missions.map((mission) => {
    let current = 0
    if (mission.condition.type === 'defeatCount') current = state.defeatedMonsterIds.length
    if (mission.condition.type === 'itemCount') current = state.inventory.length
    const achieved = current >= mission.condition.count
    return {
      ...mission,
      current,
      target: mission.condition.count,
      achieved,
      claimed: state.claimedMissionIds.includes(mission.id),
    }
  })

  const value = {
    state,
    character,
    inventoryItems,
    missionProgress,
    selectCharacter,
    collectItem,
    recordVictory,
    claimMission,
  }

  return <GameContext.Provider value={value}>{children}</GameContext.Provider>
}

export function useGame() {
  const ctx = useContext(GameContext)
  if (!ctx) throw new Error('useGame must be used within GameProvider')
  return ctx
}
