"""ローカルSQLiteの内容を本番Postgresへ同期する。

1. フィールド同期: ローカルで補完した値を、本番側が空欄の場合のみ埋める
   （id+name一致の行のみ・本番優先）
2. 新規行の追加: ローカルにあって本番にない会社を丸ごとINSERTし、
   idシーケンスを進める（ローカルでのimport_json追加分を本番に反映する経路）

usage:
  DATABASE_URL="postgresql://..." .venv/bin/python -m app.scripts.sync_fields_to_postgres
"""

import os
import sys

from sqlalchemy import create_engine, text
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

# ローカルにのみ存在する会社を本番へINSERT（名寄せ済み前提: nameのユニーク制約が最終ガード）
remote_ids = {r[0] for r in dst.query(Company.id).all()}
remote_names = {r[0] for r in dst.query(Company.name).all()}
inserted = 0
for cid, l in sorted(local.items()):
    if cid in remote_ids or l.name in remote_names:
        continue
    data = {col.name: getattr(l, col.name) for col in Company.__table__.columns}
    dst.add(Company(**data))
    inserted += 1
if inserted:
    dst.commit()
    dst.execute(text(
        "SELECT setval(pg_get_serial_sequence('companies','id'), "
        "COALESCE((SELECT MAX(id) FROM companies), 1))"))
    dst.commit()
print("inserted new companies=%d" % inserted)
print("prod total:", dst.query(Company).count())

n = dst.query(Company).filter(
    (Company.rep_x.isnot(None)) | (Company.rep_linkedin.isnot(None)) | (Company.rep_facebook.isnot(None))
).count()
print("prod companies with rep SNS:", n)
