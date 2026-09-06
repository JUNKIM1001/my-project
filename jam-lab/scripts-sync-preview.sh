#!/bin/bash
# iCloud 配下はプレビュー用サーバーから直接読めないため /tmp にミラーして配信する（他プロジェクトと同じ方式）
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
rsync -a --delete --exclude node_modules --exclude .git "$SRC/" /tmp/jam-lab-preview/
echo "synced -> /tmp/jam-lab-preview"
