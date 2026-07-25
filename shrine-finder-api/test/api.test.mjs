// 振る舞いを固定するテスト（DESIGN §9）
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { search, InvalidParam } from '../lib/search.js'
import { resolvePref, resolveCity } from '../lib/area.js'
import { coarse, distanceM } from '../lib/geo.js'
import { tvActive } from '../lib/serialize.js'
import { getData } from '../lib/data.js'

const q = (s) => new URLSearchParams(s)
const data = getData()
const PREFS = new Set(data.byPref.keys())

// ---------- 地域の解決 ----------

test('都道府県: 接尾辞を省略できる', () => {
  assert.equal(resolvePref('京都', PREFS), '京都府')
  assert.equal(resolvePref('東京', PREFS), '東京都')
  assert.equal(resolvePref('北海道', PREFS), '北海道')
  assert.equal(resolvePref('京都府', PREFS), '京都府')
  assert.equal(resolvePref('存在しない', PREFS), null)
})

test('市区町村: 政令市は区も含めて返す（前方一致が第一段）', () => {
  // 設計上の要: データに「京都市」と「京都市◯◯区」が混在する。
  // 完全一致を優先すると区表記を取りこぼすため、前方一致を先に評価する。
  const r = resolveCity('京都市', data.cityNames.get('京都府'))
  assert.equal(r.match, 'prefix')
  assert.ok(r.cities.includes('京都市'), '市名のみの表記を含むこと')
  assert.ok(r.cities.includes('京都市伏見区'), '区表記も含むこと')

  const res = search(q('pref=京都府&city=京都市&limit=1'))
  assert.equal(res.meta.total, 102, '区を含めた件数（81件ではない）')
})

test('市区町村: 完全一致は exact', () => {
  const res = search(q('pref=京都府&city=宇治市&limit=1'))
  assert.equal(res.meta.resolved_area.match, 'exact')
  assert.equal(res.meta.total, 6)
})

test('市区町村: 郡名の省略を吸収する（contains）', () => {
  const res = search(q('pref=秋田県&city=美郷町&limit=1'))
  assert.equal(res.meta.resolved_area.match, 'contains')
  assert.equal(res.shrines[0].area.city, '仙北郡美郷町')
})

test('市区町村: 解決できなければ都道府県全体を返し notice を付ける（エラーにしない）', () => {
  const res = search(q('pref=大阪府&city=存在しない市&limit=1'))
  assert.equal(res.meta.resolved_area.match, 'pref_only')
  assert.ok(res.meta.notice.includes('存在しない市'))
  assert.ok(res.meta.total > 0)
})

// ---------- 位置情報 ----------

test('座標は小数第2位に丸める（プライバシー方針）', () => {
  assert.equal(coarse(34.8892), 34.89)
  assert.equal(coarse(135.80774), 135.81)
})

test('丸めても結果は変わらない（第3位以下は影響しない）', () => {
  const a = search(q('lat=34.8892&lng=135.8077&radius_km=5&limit=5'))
  const b = search(q('lat=34.89&lng=135.81&radius_km=5&limit=5'))
  assert.deepEqual(a.shrines.map((s) => s.id), b.shrines.map((s) => s.id))
})

test('距離が実測と一致する（京都駅→平等院 ≒ 12km）', () => {
  const d = distanceM({ lat: 34.99, lng: 135.76 }, { lat: 34.8892, lng: 135.8077 })
  assert.ok(d > 11500 && d < 12500, `実測 ${Math.round(d)}m`)
})

test('半径の外は返さない・近い順に並ぶ', () => {
  const res = search(q('lat=34.89&lng=135.81&radius_km=5&limit=50'))
  const ds = res.shrines.map((s) => s.distance_m)
  assert.ok(ds.every((d) => d <= 5000), '半径内であること')
  assert.deepEqual(ds, [...ds].sort((a, b) => a - b), '昇順であること')
  assert.equal(res.meta.location_precision, '~1km')
})

// ---------- 絞り込み ----------

test('goshuin=true は御朱印を確認済みのものだけ', () => {
  const res = search(q('goshuin=true&limit=100'))
  assert.equal(res.meta.total, data.counts.goshuin)
  assert.ok(res.shrines.every((s) => s.goshuin === true))
})

test('national_treasure=true は国宝のみ', () => {
  const res = search(q('national_treasure=true&limit=100'))
  assert.equal(res.meta.total, data.counts.national_treasure)
})

test('goriyaku で絞り込める', () => {
  const res = search(q('goriyaku=enmusubi&limit=5'))
  assert.ok(res.shrines.every((s) => s.goriyaku.some((g) => g.id === 'enmusubi')))
})

// ---------- テレビ放映の1年判定 ----------

test('テレビ放映は1年以内のみ返し、1年+1日で自動的に落ちる', () => {
  const tv = { date: '2026-06-06', program: '番組', source: 'https://example.com' }
  assert.equal(tvActive(tv, new Date(2026, 6, 25)), true, '1か月半後は有効')
  assert.equal(tvActive(tv, new Date(2027, 5, 6)), true, 'ちょうど1年後は有効')
  assert.equal(tvActive(tv, new Date(2027, 5, 7)), false, '1年+1日で無効')
  assert.equal(tvActive(tv, new Date(2026, 5, 5)), false, '放映前は無効')
  assert.equal(tvActive(null), false)
  assert.equal(tvActive({ date: '20260606' }), false, '不正な形式は無効')
})

test('tv=true は1年以内の社寺のみを返す', () => {
  const now = new Date(2026, 6, 25)
  const res = search(q('tv=true&limit=50'), now)
  assert.ok(res.meta.total > 0)
  assert.ok(res.shrines.every((s) => s.tv !== null))
})

test('1年経過後は tv フィールドが null になる', () => {
  const future = new Date(2030, 0, 1)
  const res = search(q('limit=100'), future)
  assert.ok(res.shrines.every((s) => s.tv === null))
  assert.equal(search(q('tv=true&limit=10'), future).meta.total, 0)
})

// ---------- ライセンス方針 ----------

test('長文解説はレスポンスに含まれない（CC BY-SA の継承義務を利用者に負わせない）', () => {
  const res = search(q('pref=京都府&city=宇治市&limit=5'))
  const json = JSON.stringify(res)
  assert.ok(!json.includes('longDescription'))
  assert.ok(!json.includes('long_description'))
  // 自作の短文は含まれる
  assert.ok(res.shrines[0].summary.length > 0)
})

test('出典表記が必ず付く', () => {
  const res = search(q('limit=1'))
  assert.equal(res.attribution.required, true)
  assert.ok(res.attribution.text.includes('おまいりナビ'))
})

// ---------- エラー ----------

test('不正なパラメータは InvalidParam', () => {
  assert.throws(() => search(q('lat=34.89')), InvalidParam, 'lat のみは不可')
  assert.throws(() => search(q('lat=34.89&lng=135.81&radius_km=200')), InvalidParam, '半径超過')
  assert.throws(() => search(q('lat=999&lng=1')), InvalidParam, '緯度が範囲外')
  assert.throws(() => search(q('limit=500')), InvalidParam, 'limit 超過')
  assert.throws(() => search(q('pref=存在しない県')), InvalidParam, '未知の都道府県')
  assert.throws(() => search(q('goriyaku=unknown')), InvalidParam, '未知のご利益')
  assert.throws(() => search(q('type=castle')), InvalidParam, '未知の種別')
  assert.throws(() => search(q('order=distance')), InvalidParam, '座標なしの距離順')
  assert.throws(() => search(q('city=宇治市')), InvalidParam, 'pref なしの city')
})

// ---------- ページング・整形 ----------

test('ページングが機能する', () => {
  const a = search(q('pref=京都府&limit=5&offset=0'))
  const b = search(q('pref=京都府&limit=5&offset=5'))
  assert.equal(a.meta.total, b.meta.total)
  assert.equal(a.shrines.length, 5)
  const ids = new Set(a.shrines.map((s) => s.id))
  assert.ok(b.shrines.every((s) => !ids.has(s.id)), '重複しないこと')
})

test('レスポンスの形が仕様どおり', () => {
  const s = search(q('pref=京都府&city=宇治市&limit=1')).shrines[0]
  for (const k of ['id', 'name', 'kana', 'type', 'area', 'address', 'location', 'summary',
                   'enshrined', 'goriyaku', 'national_treasure', 'goshuin', 'links']) {
    assert.ok(k in s, `${k} があること`)
  }
  assert.ok(['shrine', 'temple'].includes(s.type))
  assert.ok(['御祭神', '本尊'].includes(s.enshrined.role))
  assert.ok(s.links.detail.startsWith('https://'))
})
