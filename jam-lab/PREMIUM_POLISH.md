# 有料級への仕上げ 仕様（2026-09-09 第 2 弾）

ユーザー指示: (1) スマホで遊べるように、押すと減速するボタンを置く (2) クリア条件が分からないので分かりやすく
(3) Codex レビューを踏んで有料級に。

## 1. クリア条件の明示

- **クリア = 星 1 つ以上、パーフェクト = 星 3 つ**。この言葉をブリーフィング・プレイ中・リザルトで統一して使う。
- **プレイ中の目標チェックリスト**: `hud.setGoals(items)`、`items = [{ text, ok }]`（3 件、level.goals の文と
  criteria の達成フラグを対にしたもの）。simple 表示ではミッションバナーの下にコンパクトなカード
  「目標 ○○○」として常時表示、達成した瞬間に ✓ に変わりポップする。detail 表示では左パネルの目標欄に同じ内容。
- **ブリーフィング**: 「クリア条件」見出しの下に 3 目標を ★1/★2/★3 のラベル付きで並べ、
  「★1 でクリア、★3 でパーフェクト」と 1 行で添える。制限時間も明示。
- **リザルト**: 見出しの上に大きなバッジ「クリア！」「パーフェクト！」「未クリア — もう一度」。
  次のレベルが解放されたら「実験 03 が解放されました」を 1 行。

## 2. レベルの解放（進行感）

- 01 は常に解放。以降は「前のレベルをクリア（星 1 以上）」で解放。FREE は 01 クリアで解放。
- ロック中のタブは 🔒 ＋ 無効（aria-disabled）。押すとトースト「実験 0N をクリアすると解放されます」。
- タイトルに進捗「★ 9 / 15」と「次の実験: 03 混んでいる道路では」。
- game.js: `unlockedIds(progress) → Set<string>`、`hud.setLevels(levels, progress, { unlocked })`。
  既存の進捗（stars ≥ 1）はそのまま解放済みとして扱う。

## 3. スマホ操作

- 画面下の大きなブレーキボタン（`#touch-brake`）は **`(pointer: coarse)` または `(max-width: 1099px)`** で表示。
  直径 ≥ 96px、`touch-action: none`、`-webkit-touch-callout: none`、`user-select: none`、
  safe-area（`env(safe-area-inset-bottom)`）を考慮。ラベル「ブレーキ」＋小さく「押している間」。
- `body { touch-action: manipulation; }` でダブルタップ拡大を抑止。HUD のテキストは選択不可。
- 押下中は `navigator.vibrate?.(15)`、試行記録時に `vibrate(30)`（game.js、対応端末のみ）。
- LAN からの接続: `python3 -m http.server 8480` は全インターフェースで待つので、同じ Wi‑Fi のスマホから
  `http://<Mac の IP>:8480/` で開ける（README に記載）。

## 4. hud の追加 API（まとめ）

```js
hud.setGoals([{ text, ok }, ...])                       // 3 件。空配列で非表示（FREE）
hud.setLevels(levels, progress, { unlocked: Set })      // ロック表示。progress は { id: { stars, score } }
hud.showBriefing(level, meta, { goals, durationSec })   // クリア条件の見出しと ★ ラベル
hud.showResult({ ...既存, cleared, perfect, unlockedNext })
hud.showTitle(levels, progress, { unlocked, totalStars, maxStars, nextLevel })
```
イベント追加: `selectLevel` はロック中なら hud 側で発火せず、代わりに `lockedTap(levelId)` を発火。
