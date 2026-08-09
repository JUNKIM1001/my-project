"""ローカルSQLiteの内容を本番Postgresへ同期する。

1. フィールド同期: ローカルで補完した値を、本番側が空欄の場合のみ埋める
   （id+name一致の行のみ・本番優先）
2. マージ同期: partners / sources / themes はリスト系のため「空欄のみ」ではなく
   既存値保持・重複除去の追記マージで反映する
3. 新規行の追加: ローカルにあって本番にない会社を丸ごとINSERTし、
   idシーケンスを進める（ローカルでのimport_json追加分を本番に反映する経路）

usage:
  DATABASE_URL="postgresql://..." .venv/bin/python -m app.scripts.sync_fields_to_postgres
"""

import json

import os
import sys

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

from app.db import DB_PATH
from app.models import Company

SYNC_COLS = (
    "rep_x", "rep_linkedin", "rep_facebook", "contact_url", "representative",
    "website", "hq", "founded_year", "employee_count", "last_verified",
    "corporate_number", "capital_oku", "patent_count", "subsidy_count",
    "gbiz_json", "gbiz_updated",
)

# gBizINFO列は本番側に無ければ追加する（Postgresは起動時マイグレーションを行わないため）
GBIZ_DDL = (
    ("corporate_number", "VARCHAR"), ("capital_oku", "FLOAT8"),
    ("patent_count", "INTEGER"), ("subsidy_count", "INTEGER"),
    ("gbiz_json", "TEXT"), ("gbiz_updated", "VARCHAR"),
)

url = os.environ.get("DATABASE_URL", "").strip()
if not url:
    sys.exit("DATABASE_URL を環境変数で指定してください")
url = url.replace("postgres://", "postgresql://", 1)

src = sessionmaker(bind=create_engine("sqlite:///" + DB_PATH))()
_dst_engine = create_engine(url)
with _dst_engine.connect() as _conn:
    for _col, _typ in GBIZ_DDL:
        _conn.execute(text("ALTER TABLE companies ADD COLUMN IF NOT EXISTS %s %s" % (_col, _typ)))
    _conn.commit()
dst = sessionmaker(bind=_dst_engine)()

def merge_csv(a, b):
    items = []
    for part in (a or "").split(",") + (b or "").split(","):
        p = part.strip()
        if p and p not in items:
            items.append(p)
    return ",".join(items) if items else None


def merge_json_list(a, b):
    def load(v):
        try:
            x = json.loads(v) if v else []
            return x if isinstance(x, list) else []
        except (ValueError, TypeError):
            return []
    la = load(a)
    out = la + [x for x in load(b) if x not in la]
    return json.dumps(out, ensure_ascii=False) if out else None


local = {c.id: c for c in src.query(Company).all()}
updated, filled, merged, mismatched = 0, 0, 0, []
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
    for col in ("partners", "themes"):
        m = merge_csv(getattr(remote, col), getattr(l, col))
        if m != getattr(remote, col):
            setattr(remote, col, m)
            merged += 1
            changed = True
    m = merge_json_list(remote.sources, l.sources)
    if m != remote.sources:
        remote.sources = m
        merged += 1
        changed = True
    if changed:
        updated += 1
dst.commit()
print("updated companies=%d filled fields=%d merged fields=%d" % (updated, filled, merged))
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
