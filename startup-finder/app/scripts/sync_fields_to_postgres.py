"""ローカルSQLiteの内容を本番Postgresへ同期する。

1. フィールド同期: ローカルで補完した値を、本番側が空欄の場合のみ埋める
   （id+name一致の行のみ・本番優先）
2. マージ同期: partners / themes / investors / sources はリスト系のため「空欄のみ」
   ではなく既存値保持・重複除去の追記マージで反映する
3. 新規行の追加: ローカルにあって本番にない会社を丸ごとINSERTし、
   idシーケンスを進める（ローカルでのimport_json追加分を本番に反映する経路）
4. ラウンド同期: ローカルの直近ラウンドが本番より新しい月なら、ラウンド情報・
   ステージ・累計調達額（減らない）・備考・最終確認を本番へ上書きする
   （既存企業の追加調達を反映する経路。import_json / apply_round_updates の結果を運ぶ）
5. ステータス遷移: 本番が active でローカルが ipo/ma/closed なら本番へ反映する
   （ステージは終了ステータスに整合するものに揃える）

usage:
  DATABASE_URL="postgresql://..." .venv/bin/python -m app.scripts.sync_fields_to_postgres
"""

import json
import os
import sys

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

from app.db import DB_PATH
from app.models import Company, IpoAnalysis
from app.rounds import keep_max_total, round_is_newer, should_replace_round, stage_for_status, valid_ym
from app.schema import ensure_sqlite_schema

# 本番が空欄のときだけローカル値で埋める列
SYNC_COLS = (
    "rep_x", "rep_linkedin", "rep_facebook", "contact_url", "representative",
    "website", "hq", "founded_year", "employee_count", "last_verified",
    "valuation_oku", "valuation_source", "last_round_lead",
    "corporate_number", "capital_oku", "patent_count", "subsidy_count",
    "gbiz_json", "gbiz_updated",
)
# ローカルの直近ラウンドが新しいときに本番へ差し替える列
ROUND_COLS = (
    "last_round_date", "last_round_name", "last_round_amount_oku",
    "last_round_investors", "last_round_lead",
)
# 同じくラウンドが新しいときに（ローカルに値があれば）上書きする列
ROUND_META_COLS = ("stage", "status_note", "last_verified", "employee_count")
# 追記マージする列（CSV）
MERGE_CSV_COLS = ("partners", "themes", "investors")

# 後から追加した列は本番側に無ければ追加する（Postgresは起動時マイグレーションを行わないため）
EXTRA_DDL = (
    ("corporate_number", "VARCHAR"), ("capital_oku", "FLOAT8"),
    ("patent_count", "INTEGER"), ("subsidy_count", "INTEGER"),
    ("gbiz_json", "TEXT"), ("gbiz_updated", "VARCHAR"),
    ("last_round_lead", "VARCHAR"),
)


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


def sync_row(remote, local):
    """ローカル行の内容を本番行へ反映する（id+name一致済みの前提）。

    戻り値: {"filled": 埋めた列数, "merged": 追記した列数, "round": ラウンド差替有無, "status": 遷移有無}
    順序は fill → round → status → merge。fill は本番が空欄の列だけなので、後段の
    round/status 上書きと衝突しない。再実行しても同じ結果に収束する（冪等）。
    """
    r = {"filled": 0, "merged": 0, "round": False, "status": False}
    for col in SYNC_COLS:
        if getattr(remote, col) in (None, "") and getattr(local, col) not in (None, ""):
            setattr(remote, col, getattr(local, col))
            r["filled"] += 1
    # 最終確認月はローカルの方が新しければ進める（再調査で「変更なし」と確認した事実を運ぶ）
    if valid_ym(local.last_verified) and (
            not valid_ym(remote.last_verified) or local.last_verified > remote.last_verified):
        if remote.last_verified != local.last_verified:
            remote.last_verified = local.last_verified
            r["filled"] += 1
    if should_replace_round(local.last_round_date, remote.last_round_date,
                            local.last_round_name, remote.last_round_name,
                            local.last_round_amount_oku, remote.last_round_amount_oku):
        newer = round_is_newer(local.last_round_date, remote.last_round_date)
        for col in ROUND_COLS:
            setattr(remote, col, getattr(local, col))
        remote.total_raised_oku = keep_max_total(remote.total_raised_oku, local.total_raised_oku)
        for col in ROUND_META_COLS:
            if col == "stage" and not newer:
                continue   # 月補完（同一ラウンド）ではステージを動かさない
            if getattr(local, col) not in (None, ""):
                setattr(remote, col, getattr(local, col))
        r["round"] = True
    if remote.status == "active" and local.status in ("ipo", "ma", "closed"):
        remote.status = local.status
        remote.stage = stage_for_status(local.status, local.stage)
        if local.status_note not in (None, ""):
            remote.status_note = local.status_note
        r["status"] = True
    for col in MERGE_CSV_COLS:
        m = merge_csv(getattr(remote, col), getattr(local, col))
        if m != getattr(remote, col):
            setattr(remote, col, m)
            r["merged"] += 1
    m = merge_json_list(remote.sources, local.sources)
    if m != remote.sources:
        remote.sources = m
        r["merged"] += 1
    return r


def main():
    url = os.environ.get("DATABASE_URL", "").strip()
    if not url:
        sys.exit("DATABASE_URL を環境変数で指定してください")
    url = url.replace("postgres://", "postgresql://", 1)

    src_engine = create_engine("sqlite:///" + DB_PATH)
    ensure_sqlite_schema(src_engine)  # 旧ローカルDBでも新列を SELECT できるようにする
    src = sessionmaker(bind=src_engine)()
    dst_engine = create_engine(url)
    with dst_engine.connect() as conn:
        for col, typ in EXTRA_DDL:
            conn.execute(text("ALTER TABLE companies ADD COLUMN IF NOT EXISTS %s %s" % (col, typ)))
        conn.commit()
    # ipo_analysis テーブルは本番で create_all を走らせない方針のため、ここで作る（冪等）
    IpoAnalysis.__table__.create(bind=dst_engine, checkfirst=True)
    dst = sessionmaker(bind=dst_engine)()

    local = {c.id: c for c in src.query(Company).all()}
    updated, filled, merged, mismatched = 0, 0, 0, []
    round_updated, status_updated = 0, 0
    for remote in dst.query(Company).all():
        l = local.get(remote.id)
        if l is None:
            continue
        if l.name != remote.name:
            mismatched.append((remote.id, remote.name, l.name))
            continue
        r = sync_row(remote, l)
        filled += r["filled"]
        merged += r["merged"]
        round_updated += int(r["round"])
        status_updated += int(r["status"])
        if r["filled"] or r["merged"] or r["round"] or r["status"]:
            updated += 1
    dst.commit()
    print("updated companies=%d filled fields=%d merged fields=%d round_updated=%d status_updated=%d"
          % (updated, filled, merged, round_updated, status_updated))
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

    # IPO分析（1社1行）: ローカルの抽出結果を company_id で upsert（extracted_at が同じならスキップ）
    remote_ipo = {r.company_id: r for r in dst.query(IpoAnalysis).all()}
    ipo_up = 0
    for l in src.query(IpoAnalysis).all():
        r = remote_ipo.get(l.company_id)
        if r is None:
            r = IpoAnalysis(company_id=l.company_id)
            dst.add(r)
        elif r.extracted_at == l.extracted_at:
            continue
        for col in ("code", "listing_date", "market", "source_pdf", "outline_pdf",
                    "analysis_json", "extracted_at", "model"):
            setattr(r, col, getattr(l, col))
        ipo_up += 1
    dst.commit()
    print("ipo_analysis synced=%d (prod total %d)" % (ipo_up, dst.query(IpoAnalysis).count()))
    print("prod total:", dst.query(Company).count())

    n = dst.query(Company).filter(
        (Company.rep_x.isnot(None)) | (Company.rep_linkedin.isnot(None)) | (Company.rep_facebook.isnot(None))
    ).count()
    print("prod companies with rep SNS:", n)


if __name__ == "__main__":
    main()
