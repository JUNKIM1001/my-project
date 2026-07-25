"""ローカルSQLite → Postgres(Supabase) へのデータ移行。

- companies / users をコピーする（access_logs・auth_sessionsは新環境で空から開始）
- 既にデータがあるテーブルはスキップする（冪等）
- コピー後にIDシーケンスを進める（明示ID挿入のため）

usage:
  DATABASE_URL="postgresql://..." .venv/bin/python -m app.scripts.migrate_to_postgres
"""

import os
import sys

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

from app.db import DB_PATH, Base
from app.models import Company, User

url = os.environ.get("DATABASE_URL", "").strip()
if not url:
    sys.exit("DATABASE_URL を環境変数で指定してください")
url = url.replace("postgres://", "postgresql://", 1)

src_engine = create_engine("sqlite:///" + DB_PATH)
dst_engine = create_engine(url)

Base.metadata.create_all(dst_engine)
src = sessionmaker(bind=src_engine)()
dst = sessionmaker(bind=dst_engine)()

for model in (Company, User):
    name = model.__tablename__
    existing = dst.query(model).count()
    if existing:
        print("%s: 既に %d 行あるためスキップ" % (name, existing))
        continue
    rows = src.query(model).all()
    for r in rows:
        data = {c.name: getattr(r, c.name) for c in model.__table__.columns}
        dst.add(model(**data))
    dst.commit()
    print("%s: %d 行コピー" % (name, len(rows)))

# 明示IDで挿入したのでシーケンスを最大IDまで進める
for table in ("companies", "users", "access_logs"):
    dst.execute(text(
        "SELECT setval(pg_get_serial_sequence('%s','id'), "
        "COALESCE((SELECT MAX(id) FROM %s), 1))" % (table, table)
    ))
dst.commit()
print("シーケンス調整完了")

# 検証
print("Postgres側の件数: companies=%d users=%d" % (
    dst.query(Company).count(), dst.query(User).count()))
