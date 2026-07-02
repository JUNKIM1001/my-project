import { describe, it, expect } from 'vitest'
import { createStore, haversine, distanceLabel, normalizeQuery, safeURL } from './store'

// 小さなfixture（appdata.json 全体は使わない）
const fixture = {
  goriyaku: [
    { slug: 'enmusubi', name: '縁結び', description: '良縁・人間関係' },
    { slug: 'gakugyo', name: '学業成就', description: '合格・学問' },
    { slug: 'yakubarai', name: '厄除け', description: '厄除け・魔除け' },
    { slug: 'unused', name: '未使用', description: 'どの社寺にもない' },
  ],
  deities: [
    { slug: 'okuninushi', name: '大国主', kana: 'おおくにぬし', kind: 'kami', category: '国津神', goriyaku: ['enmusubi'] },
    { slug: 'tenjin', name: '菅原道真', kana: 'すがわらのみちざね', kind: 'kami', category: '御霊', goriyaku: ['gakugyo'] },
  ],
  shrines: [
    {
      slug: 'kou-jinja', name: '甲神社', kana: 'こうじんじゃ', type: 'shrine', sect: '',
      pref: '東京都', city: '千代田区', lat: 35.68, lng: 139.76, deities: ['okuninushi'],
    },
    {
      slug: 'otsu-dera', name: '乙寺', kana: 'おつでら', type: 'temple', sect: '天台宗', nt: true,
      pref: '京都府', city: '京都市', lat: 35.0, lng: 135.75, deities: ['tenjin'],
    },
    {
      slug: 'hei-jinja', name: '丙神社', kana: 'へいじんじゃ', type: 'shrine', sect: '',
      pref: '東京都', city: '台東区', lat: 35.71, lng: 139.79, deities: ['okuninushi'],
      goriyaku: ['yakubarai', 'enmusubi'], // 明示上書き（enmusubi は導出分と重複）
    },
  ],
}

const store = createStore(fixture)
const bySlugList = (arr) => arr.map((s) => s.slug)

describe('haversine', () => {
  it('同一地点は 0', () => {
    expect(haversine({ lat: 35, lng: 135 }, { lat: 35, lng: 135 })).toBe(0)
  })
  it('緯度1度 ≒ 111.2km', () => {
    const d = haversine({ lat: 35, lng: 135 }, { lat: 36, lng: 135 })
    expect(d).toBeGreaterThan(110000)
    expect(d).toBeLessThan(112500)
  })
  it('東京—京都はおよそ360〜370km', () => {
    const d = haversine(fixture.shrines[0], fixture.shrines[1])
    expect(d).toBeGreaterThan(350000)
    expect(d).toBeLessThan(380000)
  })
})

describe('distanceLabel', () => {
  it('1km未満は m 表記', () => expect(distanceLabel(950)).toBe('950m'))
  it('1km以上は km 表記', () => expect(distanceLabel(1540)).toBe('1.5km'))
})

describe('normalizeQuery', () => {
  it('カタカナをひらがなへ変換する', () => {
    expect(normalizeQuery('ジンジャ')).toBe('じんじゃ')
    expect(normalizeQuery('コウジンジャ')).toBe('こうじんじゃ')
  })
  it('英字を小文字化する', () => expect(normalizeQuery('ABC')).toBe('abc'))
  it('ひらがな・漢字はそのまま', () => expect(normalizeQuery('神社かな')).toBe('神社かな'))
  it('null/undefined は空文字', () => {
    expect(normalizeQuery(null)).toBe('')
    expect(normalizeQuery(undefined)).toBe('')
  })
})

describe('safeURL', () => {
  it('http(s) のみ許可', () => {
    expect(safeURL('https://example.com')).toBe('https://example.com')
    expect(safeURL('javascript:alert(1)')).toBeNull()
    expect(safeURL('')).toBeNull()
  })
})

describe('ご利益の導出（明示分を先頭に、導出分との和集合）', () => {
  it('明示 goriyaku がない社寺は御祭神由来のみ', () => {
    expect(store.goriyakuSlugsOf(store.shrine('kou-jinja'))).toEqual(['enmusubi'])
  })
  it('明示 goriyaku は先頭に置かれ、導出分と重複なく和集合になる', () => {
    expect(store.goriyakuSlugsOf(store.shrine('hei-jinja'))).toEqual(['yakubarai', 'enmusubi'])
  })
})

describe('逆引きインデックス', () => {
  it('shrinesForGoriyaku が該当社寺を返す', () => {
    expect(bySlugList(store.shrinesForGoriyaku('enmusubi')).sort()).toEqual(['hei-jinja', 'kou-jinja'])
    expect(bySlugList(store.shrinesForGoriyaku('yakubarai'))).toEqual(['hei-jinja'])
    expect(store.shrinesForGoriyaku('gakugyo').length).toBe(1)
  })
  it('未知のご利益slugは空配列', () => {
    expect(store.shrinesForGoriyaku('nonexistent')).toEqual([])
  })
  it('goriyakuCounts は件数降順で0件を除外', () => {
    const counts = store.goriyakuCounts()
    expect(counts[0][0].slug).toBe('enmusubi')
    expect(counts[0][1]).toBe(2)
    expect(counts.every(([, c]) => c > 0)).toBe(true)
    expect(counts.find(([g]) => g.slug === 'unused')).toBeUndefined()
  })
})

describe('search', () => {
  it('カタカナ入力でも kana にヒットする', () => {
    expect(bySlugList(store.search('コウジンジャ').map(([s]) => s))).toEqual(['kou-jinja'])
  })
  it('ひらがな・漢字・地名でヒットする', () => {
    expect(store.search('こうじんじゃ').length).toBe(1)
    expect(store.search('甲神社').length).toBe(1)
    expect(store.search('東京都').length).toBe(2)
  })
  it('type / ntOnly フィルタ', () => {
    expect(store.search('', { type: 'temple' }).length).toBe(1)
    expect(bySlugList(store.search('', { ntOnly: true }).map(([s]) => s))).toEqual(['otsu-dera'])
  })
  it('origin 指定時は距離昇順で距離付き', () => {
    const res = store.search('', { origin: { lat: 35.68, lng: 139.76 } })
    expect(res[0][0].slug).toBe('kou-jinja')
    expect(res[0][1]).toBe(0)
    expect(res[1][1]).toBeLessThan(res[2][1])
  })
  it('origin なしは kana の五十音順', () => {
    expect(bySlugList(store.search('').map(([s]) => s))).toEqual(['otsu-dera', 'kou-jinja', 'hei-jinja'])
  })
})

describe('related', () => {
  it('同じ御祭神・同県の社寺が上位に来て、自分自身は含まない', () => {
    const rel = store.related(store.shrine('kou-jinja'))
    expect(rel[0].slug).toBe('hei-jinja')
    expect(bySlugList(rel)).not.toContain('kou-jinja')
  })
  it('limit を尊重する', () => {
    expect(store.related(store.shrine('kou-jinja'), 1).length).toBe(1)
  })
})

describe('shrinesInBounds', () => {
  it('範囲内のみ・中心からの距離昇順・limit 適用', () => {
    const res = store.shrinesInBounds({
      latMin: 35.5, latMax: 36, lngMin: 139, lngMax: 140,
      center: { lat: 35.68, lng: 139.76 },
    })
    expect(bySlugList(res.map(([s]) => s))).toEqual(['kou-jinja', 'hei-jinja'])
    const limited = store.shrinesInBounds({
      latMin: 35.5, latMax: 36, lngMin: 139, lngMax: 140,
      center: { lat: 35.68, lng: 139.76 }, limit: 1,
    })
    expect(limited.length).toBe(1)
  })
})
