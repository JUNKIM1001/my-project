"""ローカルSQLiteのスキーマ作成と追いつきマイグレーション。

アプリ起動（app.main）だけでなく、DBを直接触るスクリプト（import_json /
apply_round_updates）からも呼ぶ。モデルに列を足したら下の一覧にも追加すること。
Postgres（本番）は対象外: create_all はコールドスタートを遅くするため行わず、
列追加は sync_fields_to_postgres の DDL（ADD COLUMN IF NOT EXISTS）が担当する。
"""

from sqlalchemy import text

from app.db import Base
from app import models  # noqa: F401  Base にテーブル定義を登録するために読み込む

# 既存SQLite DBに後から追加した列（テーブルごと）
CATCHUP_COLUMNS = {
    "companies": (
        ("contact_url", "VARCHAR"), ("rep_linkedin", "VARCHAR"),
        ("rep_x", "VARCHAR"), ("rep_facebook", "VARCHAR"),
        ("corporate_number", "VARCHAR"), ("capital_oku", "FLOAT"),
        ("patent_count", "INTEGER"), ("subsidy_count", "INTEGER"),
        ("gbiz_json", "TEXT"), ("gbiz_updated", "VARCHAR"),
        ("last_round_lead", "VARCHAR"),
    ),
    "access_logs": (
        ("params", "VARCHAR"), ("result_count", "INTEGER"), ("company_id", "INTEGER"),
    ),
}


def ensure_sqlite_schema(engine):
    """SQLite のみ: テーブル作成 + 不足列の追加 + インデックス。Postgres では何もしない。"""
    if engine.dialect.name != "sqlite":
        return
    Base.metadata.create_all(bind=engine)
    with engine.connect() as conn:
        for table, cols in CATCHUP_COLUMNS.items():
            existing = [r[1] for r in conn.execute(text("PRAGMA table_info(%s)" % table))]
            if not existing:
                continue
            for col, typ in cols:
                if col not in existing:
                    conn.execute(text("ALTER TABLE %s ADD COLUMN %s %s" % (table, col, typ)))
        # ログイン制限がIPで引くのでインデックスを張る
        conn.execute(text("CREATE INDEX IF NOT EXISTS ix_access_logs_ip ON access_logs (ip)"))
        conn.commit()
