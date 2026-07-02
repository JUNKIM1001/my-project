import { useNavigate } from 'react-router-dom'
import { useStore } from '../data/providers'
import usePageTitle from '../hooks/usePageTitle'

export default function About() {
  const store = useStore()
  const nav = useNavigate()
  usePageTitle('このアプリについて')
  const nt = store.nationalTreasureCount()
  const photos = store.shrines.filter((s) => s.imageURL).length
  return (
    <div className="page">
      <header className="appbar">
        <button className="iconbtn" onClick={() => nav(-1)}>‹</button>
        <h1>このアプリについて</h1>
        <span className="iconbtn" />
      </header>

      <section className="card center">
        <div className="big-emoji">⛩️</div>
        <h2>おまいりナビ</h2>
        <div className="muted">v1.0.0（Web版）</div>
        <p className="muted small">願い事と現在地から、最適な神社・お寺と神仏が見つかるアプリ。</p>
      </section>

      <section className="sec">
        <b>収録データ</b>
        <div className="kv"><span>社寺</span><b>{store.shrines.length} 件</b></div>
        <div className="kv"><span>神様・仏様</span><b>{store.deities.length} 柱/尊</b></div>
        <div className="kv"><span>ご利益カテゴリ</span><b>{store.goriyaku.length} 種</b></div>
        <div className="kv"><span>国宝を有する社寺</span><b>★ {nt} 件</b></div>
        <div className="kv"><span>実写写真</span><b>{photos} 社寺</b></div>
        <div className="kv"><span>カバー都道府県</span><b>{store.prefectureCount()} / 47</b></div>
        <p className="muted small">全国の社寺は約15.8万。本アプリは全国的に著名・代表的な社寺を厳選収録しています。</p>
      </section>

      <section className="sec">
        <b>データの出典・正確性</b>
        <p className="small">掲載する社寺は実在し参拝可能なものです。住所・地図・御祭神/本尊・由緒は、公式サイト・自治体・日本語Wikipedia等で裏取りしています。</p>
      </section>

      <section className="sec">
        <b>ライセンス・出典</b>
        <p className="small">社寺データ：日本語ウィキペディア（CC BY-SA）・各社寺公式サイト・自治体情報。
        写真：ウィキメディア・コモンズの自由ライセンス（CC0/PD/CC BY/CC BY-SA）のみ使用し、各写真の作者・ライセンスは詳細画面に表示。
        地図：OpenStreetMap contributors。アイコン・シンボル図は当アプリのオリジナルです。</p>
        <p>
          <a href="https://ja.wikipedia.org/" target="_blank" rel="noreferrer">Wikipedia</a>{' / '}
          <a href="https://commons.wikimedia.org/" target="_blank" rel="noreferrer">Wikimedia Commons</a>{' / '}
          <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noreferrer">OpenStreetMap</a>
        </p>
      </section>

      <section className="sec">
        <b>免責事項</b>
        <p className="muted small">情報の正確性は保証されません。本アプリの利用により生じた損害・不利益について開発者は責任を負わず、補償もいたしません。ご利益・由緒の記述は伝承に基づくもので宗教的効果を保証しません。参拝前に各社寺の公式情報をご確認ください。</p>
      </section>
    </div>
  )
}
