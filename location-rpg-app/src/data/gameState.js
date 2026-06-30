const STORAGE_KEY = 'location-rpg-save'

const defaultState = {
  characterId: null,
  inventory: [],
  defeatedMonsterIds: [],
  collectedSpotIds: [],
  claimedMissionIds: [],
}

export function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return { ...defaultState }
    return { ...defaultState, ...JSON.parse(raw) }
  } catch {
    return { ...defaultState }
  }
}

export function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
}

export function clearState() {
  localStorage.removeItem(STORAGE_KEY)
}
