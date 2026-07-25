# 再開手順（2026-07-25 時点で中断）

このAPIは**実装・テスト・ローカル動作確認まで完了**している。
残っているのは**Vercelへのデプロイのみ**。中断理由は優先度が下がったため。

---

## いまどこまで終わっているか

| 項目 | 状態 |
|---|---|
| 仕様書 [API_SPEC.md](API_SPEC.md) | ✅ 確定 |
| OpenAPI定義 [openapi.yaml](openapi.yaml) | ✅ 確定 |
| 設計書 [DESIGN.md](DESIGN.md) | ✅ 確定 |
| 実装（エンドポイント5本・lib一式） | ✅ 完了 |
| テスト（20件） | ✅ 全合格 |
| ローカル動作確認 | ✅ 全エンドポイント確認済み |
| **本番デプロイ** | ⛔ **未完了（ここから再開）** |

---

## 中断した理由（技術的な状態）

Vercelのアクセストークンが権限エラーを返し、プロジェクトを作成できなかった。

```
Not authorized: Trying to access resource under scope "junkim1001s-projects".
You must re-authenticate to this scope or use a token with access to this scope.
```

`whoami` は通る（`junkim1001`）が、プロジェクトの作成・一覧が拒否される状態。
**トークンのスコープが Personal Account になっていたことが原因**と推測される。

---

## 再開する手順

### ステップ1: Vercelトークンを再発行（ユーザー作業・2分）

1. https://vercel.com/account/tokens を開く
2. 古いトークンがあれば削除（過去にチャットへ貼ったものは必ず削除）
3. **Create Token** をクリックし、以下を設定
   - TOKEN NAME: `omairi-api-deploy`（任意）
   - **SCOPE: `junkim1001's projects` を選ぶ** ← ここが重要。
     Personal Account を選ぶと同じエラーで失敗する
   - EXPIRATION: 30日程度で十分
4. 表示された `vcp_...` をコピー

### ステップ2: デプロイ

```bash
cd "/Users/thisiskj/Library/Mobile Documents/com~apple~CloudDocs/Clode code/shrine-finder-api"

export VERCEL_TOKEN="<新しいvcp_トークン>"
npx vercel@latest link --yes --project omairi-navi-api --token "$VERCEL_TOKEN"
npx vercel@latest pull --yes --environment=production --token "$VERCEL_TOKEN"
npx vercel@latest deploy --prod --token "$VERCEL_TOKEN"
```

> CLIのスコープ選択で再び詰まる場合は、`npx vercel@latest login` でブラウザ認証してから
> `npx vercel@latest --prod` を実行する方法に切り替える。

### ステップ3: 公開後の確認

```bash
BASE="https://omairi-navi-api.vercel.app"   # 実際に払い出されたURLに置き換える

curl -s "$BASE/v1/meta" | head -c 300
curl -s -G "$BASE/v1/shrines" --data-urlencode "pref=京都府" --data-urlencode "city=宇治市" | head -c 300
curl -s "$BASE/v1/shrines?lat=34.89&lng=135.81&radius_km=5&limit=3" | head -c 300
```

期待値:
- `/v1/meta` → `counts.shrines = 2086`
- 宇治市 → `meta.total = 6`
- **京都市 → `meta.total = 102`**（81でないこと。政令市の区を含む）

### ステップ4: デプロイ後にやること

- [ ] 発行したトークンを削除（デプロイ済みAPIは動き続ける）
- [ ] `README.md` と `API_SPEC.md` のベースURLを実URLに更新
      （現在は仮に `https://api.omairi-navi.app/v1` と記載）
- [ ] レート制限を有効にするなら Upstash Redis を用意し、Vercelの環境変数に
      `UPSTASH_REDIS_REST_URL` / `UPSTASH_REDIS_REST_TOKEN` を設定
      （未設定でも動作する。その場合は無制限）
- [ ] `API_CONTACT` 環境変数に問い合わせ先を設定（`/v1/meta` に表示される）

---

## 未決の3点（デプロイ時に決める）

1. **ドメイン**: 独自ドメイン `api.omairi-navi.app`（取得費用が必要）か、
   まず `omairi-navi-api.vercel.app` で始めるか。**後者を推奨**（後から移行可）
2. **上限緩和の連絡先**: メール or GitHub Issues
3. **利用規約の掲載場所**: 現在は API_SPEC.md §8 に記載

---

## ローカルで動かす（デプロイ不要）

```bash
cd "/Users/thisiskj/Library/Mobile Documents/com~apple~CloudDocs/Clode code/shrine-finder-api"
node scripts/build-data.mjs         # data/api-data.json を生成（gitignore対象）
npm test                            # 20件のテスト
node scripts/dev-server.mjs 8787    # http://localhost:8787/v1/shrines
```

> `data/api-data.json` はgit管理外。**cloneした直後は必ず `build-data.mjs` を実行する**
> （実行しないと `lib/data.js` がファイルを見つけられず落ちる）。

---

## 設計上の注意（忘れると壊れる点）

1. **市区町村の解決は「前方一致が第一段」**
   データに `京都市`(81件) と `京都市伏見区`(3件) が混在するため、完全一致を優先すると
   21件を静かに取りこぼす。政令市12市で同じ問題が起きる。
   テスト「市区町村: 政令市は区も含めて返す」がこれを守っている。

2. **長文解説（long_description）をAPIに出さない**
   Wikipedia由来（CC BY-SA）のため、配ると利用者にライセンス継承義務が生じる。
   `build-data.mjs` に混入検査があり、混入するとビルドが失敗する。

3. **座標は必ず小数第2位に丸める**
   プライバシー方針。`lib/geo.js` の `coarse()` を通す。ログにも出さない。

4. **データ更新時は `build-data.mjs` の再実行が必要**
   おまいりナビ本体のデータ（appdata.json / Supabase）を更新しても、
   APIは再ビルドするまで古いデータのまま。
