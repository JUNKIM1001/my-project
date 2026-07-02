#!/usr/bin/env bash
#
# review-loop.sh
# Claude Code(修正) × Codex(レビュー) の自動ループ
#
# 流れ:
#   1. Codex が未コミット差分をレビュー
#   2. 指摘がなければ終了
#   3. 指摘があれば Claude Code が自動で修正
#   4. 1〜3 を最大 MAX_ITER 回くり返す
#   ※ コミットはしません。最後に人間が git diff で確認してコミットしてください。
#
# 使い方:
#   chmod +x review-loop.sh        # 初回だけ実行権限を付与
#   ./review-loop.sh               # 既定の観点でレビュー
#   ./review-loop.sh "セキュリティとパフォーマンス重視"   # 観点を指定
#
set -euo pipefail

# ===== 設定 =====
MAX_ITER=3                          # 安全装置: 最大反復回数
FOCUS="${1:-}"                      # レビュー観点（任意の引数）
LOGDIR="codex-reviews"              # レビュー結果の保存先
mkdir -p "$LOGDIR"

# ===== 事前チェック =====
command -v claude >/dev/null || { echo "❌ claude が見つかりません"; exit 1; }
command -v codex  >/dev/null || { echo "❌ codex が見つかりません"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "❌ git リポジトリ内で実行してください"; exit 1; }

if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "ℹ レビュー対象の変更がありません。先に Claude Code でコードを書いてください。"
  exit 0
fi

# ===== メインループ =====
for i in $(seq 1 "$MAX_ITER"); do
  echo ""
  echo "========== レビュー反復 $i / $MAX_ITER =========="
  STAMP=$(date +%Y%m%d-%H%M%S)
  REVIEW_FILE="$LOGDIR/review-$STAMP.md"

  echo "▶ Codex がレビュー中..."
  # Codex に未コミット差分をレビューさせる。指摘ゼロなら最終行に REVIEW_CLEAN を出すよう指示。
  codex exec --skip-git-repo-check \
    "あなたは厳格なコードレビュアーです。git の未コミット差分(staged/unstaged/untracked)だけをレビューしてください。${FOCUS:+重点観点: $FOCUS。}重大度(P0/P1/P2)付きで、ファイルと行番号と修正方針を簡潔に列挙してください。修正すべき指摘が一つもない場合は、最終行に REVIEW_CLEAN とだけ出力してください。" \
    | tee "$REVIEW_FILE"

  # 指摘なし判定（最終行が REVIEW_CLEAN と完全一致する場合のみ）
  if tail -n1 "$REVIEW_FILE" | grep -qx "REVIEW_CLEAN"; then
    echo ""
    echo "✅ 指摘なし。ループを終了します。"
    break
  fi

  echo ""
  echo "▶ Claude Code が修正中..."
  # 修正のみ許可（コミットや破壊的操作はさせない）
  claude -p "以下は別のレビューツール(Codex)によるコードレビュー結果です。妥当な指摘だけを判断して、未コミットのコードを修正してください。既存のテストは壊さないこと。修正した内容を最後に日本語で要約してください。

--- レビュー結果 ---
$(cat "$REVIEW_FILE")" \
    --allowedTools "Read,Edit,Write,Grep,Glob"

  if [ "$i" -eq "$MAX_ITER" ]; then
    echo ""
    echo "⚠ 最大反復回数($MAX_ITER回)に達しました。残りの指摘は手動で確認してください。"
  fi
done

echo ""
echo "=================================================="
echo "完了。次の手順:"
echo "  1) git diff           で変更内容を必ず目視確認"
echo "  2) 問題なければ        git add -A && git commit -m \"...\""
echo "  レビュー履歴は $LOGDIR/ に保存されています。"
