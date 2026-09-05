"""ローカルSQLiteの status / status_note を本番Postgresへ同期する。

status は sync_fields_to_postgres の「空欄のみ埋める」方針に載らない
（本番側が既に "active" で埋まっているため）。M&A・IPO・倒産の状態遷移を
反映するための専用スクリプト。

- active → ipo/ma/closed の遷移のみ適用する（後退はさせない）
- id が一致し、かつ name も一致する行のみ（安全確認）
- status_note はローカル側に値があれば更新する

usage:
  DATABASE_URL="postgresql://..." .venv/bin/python -m app.scripts.sync_status_to_postgres
"""

import os
import sys

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db import DB_PATH
from app.models import Company

# active から遷移させてよい状態（この3つは active より優先）
TERMINAL = {"ipo", "ma", "closed"}

url = os.environ.get("DATABASE_URL", "").strip()
if not url:
    sys.exit("DATABASE_URL を環境変数で指定してください")
url = url.replace("postgres://", "postgresql://", 1)

src = sessionmaker(bind=create_engine("sqlite:///" + DB_PATH))()
dst = sessionmaker(bind=create_engine(url))()

local = {c.id: c for c in src.query(Company).all()}
changed, notes, mismatched = 0, 0, []
for remote in dst.query(Company).all():
    l = local.get(remote.id)
    if l is None:
        continue
    if l.name != remote.name:
        mismatched.append((remote.id, remote.name, l.name))
        continue
    if l.status in TERMINAL and remote.status != l.status:
        print("  %s: %s -> %s" % (remote.name, remote.status, l.status))
        remote.status = l.status
        changed += 1
    if l.status_note and l.status_note != remote.status_note:
        remote.status_note = l.status_note
        notes += 1
dst.commit()
print("status changed=%d, status_note updated=%d" % (changed, notes))
if mismatched:
    print("SKIPPED (id/name mismatch):", mismatched[:5])

for s in ("active", "ipo", "ma", "closed"):
    print("  prod %s: %d" % (s, dst.query(Company).filter(Company.status == s).count()))
