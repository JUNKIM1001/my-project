import dino1 from '../assets/characters/恐竜1.png'
import dino2 from '../assets/characters/恐竜2.png'

export const characters = [
  {
    id: 'flamon',
    name: 'ヒノコ',
    type: '炎タイプ・恐竜系',
    hp: 40,
    attack: 9,
    speed: 5,
    image: dino1,
    description: '元気いっぱいで猪突猛進。火を吐く技を得意とする。',
  },
  {
    id: 'fangmon',
    name: 'ガリュウ',
    type: '牙獣タイプ',
    hp: 34,
    attack: 7,
    speed: 9,
    image: dino2,
    description: 'クールで力強い。スピードと噛みつき技が得意。',
  },
]

// 基準座標(プレイヤーの初期位置周辺にスポットを配置する際のオフセット計算に使用)
export const monsters = [
  { id: 'slime', name: 'スライム', hp: 18, attack: 4, dropItemId: 'potion' },
  { id: 'batty', name: 'コウモリ', hp: 14, attack: 5, dropItemId: 'wing' },
  { id: 'rocky', name: 'いわんこ', hp: 24, attack: 6, dropItemId: 'stone' },
]

export const items = [
  { id: 'potion', name: 'きずぐすり', description: 'HPを15回復する' },
  { id: 'wing', name: 'こうもりのつばさ', description: '素早さが上がる素材' },
  { id: 'stone', name: 'ふしぎな石', description: 'ミッションで使う特別な石' },
]

// lat/lng はプレイヤーの初期位置からの相対オフセット(度)で生成される
export const mapSpots = [
  { id: 'spot1', type: 'monster', refId: 'slime', dLat: 0.0006, dLng: 0.0004 },
  { id: 'spot2', type: 'monster', refId: 'batty', dLat: -0.0005, dLng: 0.0007 },
  { id: 'spot3', type: 'item', refId: 'potion', dLat: 0.0003, dLng: -0.0006 },
  { id: 'spot4', type: 'monster', refId: 'rocky', dLat: -0.0008, dLng: -0.0003 },
  { id: 'spot5', type: 'item', refId: 'stone', dLat: 0.0009, dLng: 0.0002 },
]

export const missions = [
  {
    id: 'mission1',
    title: 'モンスターを3体たおせ',
    description: 'フィールドのモンスターを合計3体倒そう',
    condition: { type: 'defeatCount', count: 3 },
    qrCode: 'LOCATION-RPG-MISSION1-REWARD',
  },
  {
    id: 'mission2',
    title: 'アイテムを2つ集めよ',
    description: 'フィールドに落ちているアイテムを2つ拾おう',
    condition: { type: 'itemCount', count: 2 },
    qrCode: 'LOCATION-RPG-MISSION2-REWARD',
  },
]

// プレイヤーが何メートル以内に近づくとエンカウント/取得が発生するか
export const ENCOUNTER_RADIUS_METERS = 30
