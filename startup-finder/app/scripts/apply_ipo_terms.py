"""Web調査で得た公開価格等（offer_price_result_*.json）を ipo_analysis の ipo_terms に反映する。

- 既存値は上書きしない（null のみ埋める）。--force で上書き
- 反映した行は extracted_at を更新し、sync_fields_to_postgres の upsert 対象にする

usage: DATABASE_URL="" .venv/bin/python -m app.scripts.apply_ipo_terms [--force]
"""
import argparse
import glob
import json
import os
from datetime import datetime

from app.db import BASE_DIR, SessionLocal
from app.models import Company, IpoAnalysis

FIELDS = ("offer_price_yen", "first_price_yen", "market_cap_at_offer_yen", "raised_total_yen", "lead_underwriter")


def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--force", action="store_true"); a = ap.parse_args()
    db = SessionLocal()
    by_name = {c.name: c.id for c in db.query(Company).all()}
    rows = {r.company_id: r for r in db.query(IpoAnalysis).all()}
    applied = filled = 0
    for path in sorted(glob.glob(os.path.join(BASE_DIR, "data", "ipo_docs", "offer_price_result_*.json"))):
        for rec in json.load(open(path, encoding="utf-8")):
            cid = by_name.get(rec.get("name"))
            row = rows.get(cid)
            if not row:
                print("  未一致:", rec.get("name")); continue
            d = json.loads(row.analysis_json or "{}")
            terms = d.setdefault("ipo_terms", {})
            changed = False
            for f in FIELDS:
                v = rec.get(f)
                if v in (None, "") or (terms.get(f) not in (None, "") and not a.force):
                    continue
                key = "market_cap_at_ipo_yen_est" if f == "market_cap_at_offer_yen" else f
                terms[key] = v; changed = True; filled += 1
            if changed:
                terms["note"] = (terms.get("note") or "").replace("DBメモ由来（報道ベース）", "").strip()
                terms["source_web"] = rec.get("source")
                terms["note"] = (terms["note"] + " " if terms["note"] else "") + "公開価格等はWeb調査（IPO情報サイト/プレス）由来"
                row.analysis_json = json.dumps(d, ensure_ascii=False)
                row.extracted_at = datetime.now().astimezone().isoformat(timespec="seconds")
                applied += 1
    db.commit()
    n = sum(1 for r in db.query(IpoAnalysis).all() if (json.loads(r.analysis_json or "{}").get("ipo_terms") or {}).get("offer_price_yen"))
    print(f"applied companies={applied} fields={filled} | 公開価格あり {n}/{len(rows)}")


if __name__ == "__main__":
    main()
