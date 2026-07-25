"""ローカルSQLiteで補完したフィールドを本番Postgresへ同期する（空欄のみ埋める）。

- 対象: rep_x / rep_linkedin / rep_facebook / contact_url / representative /
        website / hq / founded_year / employee_count / last_verified
- マッチ: id が一致し、かつ name も一致する行のみ（安全確認）。不一致は報告してスキップ
- 本番側に既に値がある場合は上書きしない（本番優先）

usage:
  DATABASE_URL="postgresql://..." .venv/bin/python -m app.scripts.sync_fields_to_postgres
"""

import os
import sys

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db import DB_PATH
from app.models import Company

SYNC_COLS = (
    "rep_x", "rep_linkedin", "rep_facebook", "contact_url", "representative",
    "website", "hq", "founded_year", "employee_count", "last_verified",
)

url = os.environ.get("DATABASE_URL", "").strip()
if not url:
    sys.exit("DATABASE_URL を環境変数で指定してください")
url = url.replace("postgres://", "postgresql://", 1)

src = sessionmaker(bind=create_engine("sqlite:///" + DB_PATH))()
dst = sessionmaker(bind=create_engine(url))()

local = {c.id: c for c in src.query(Company).all()}
updated, filled, mismatched = 0, 0, []
for remote in dst.query(Company).all():
    l = local.get(remote.id)
    if l is None:
        continue
    if l.name != remote.name:
        mismatched.append((remote.id, remote.name, l.name))
        continue
    changed = False
    for col in SYNC_COLS:
        if getattr(remote, col) in (None, "") and getattr(l, col) not in (None, ""):
            setattr(remote, col, getattr(l, col))
            filled += 1
            changed = True
    if changed:
        updated += 1
dst.commit()
print("updated companies=%d filled fields=%d" % (updated, filled))
if mismatched:
    print("SKIPPED (id/name mismatch):", mismatched[:10])

n = dst.query(Company).filter(
    (Company.rep_x.isnot(None)) | (Company.rep_linkedin.isnot(None)) | (Company.rep_facebook.isnot(None))
).count()
print("prod companies with rep SNS:", n)
