"""data/raw/*.json（リサーチ結果）をSQLiteに取り込む。

- 同名企業はマージ（後から来たデータで null 埋め・sources/themes は結合）
- 直近ラウンドが既存より新しい（last_round.date が後の月）場合は、ラウンド情報・
  ステージ・累計調達額を新データで上書きする（週次クロールの反映漏れ対策）
- 法人格の表記ゆれ（株式会社の前後）を正規化して名寄せする

usage: .venv/bin/python3 -m app.scripts.import_json
"""

import glob
import json
import os
import re
import sys

from app.db import BASE_DIR, SessionLocal, engine
from app.models import Company
from app.rounds import keep_max_total, round_is_newer, should_replace_round, stage_for_status
from app.schema import ensure_sqlite_schema

RAW_DIR = os.path.join(BASE_DIR, "data", "raw")


# カナ/英字などnorm_nameで吸収できない表記ゆれの対応表
NAME_ALIASES = {
    "チューリング": "turing",
}


def norm_name(name):
    """名寄せ用キー: 括弧書き（旧社名等）・法人格・空白・記号を落として比較する。"""
    n = re.sub(r"[（(].*?[）)]", "", name or "")  # （旧・〜）等を除去
    n = re.sub(r"(株式会社|合同会社|有限会社)", "", n)
    n = re.sub(r"[\s　・．.,、。－\-–—]", "", n)
    n = n.lower()
    return NAME_ALIASES.get(n, n)


def safe_url(u):
    """http/https 以外のスキーム（javascript: 等）は取り込まない。"""
    if isinstance(u, str) and re.match(r"^https?://", u.strip(), re.IGNORECASE):
        return u.strip()
    return None


def join_list(values):
    items = [str(v).strip() for v in (values or []) if str(v).strip()]
    # 重複除去（順序維持）
    seen = []
    for it in items:
        if it not in seen:
            seen.append(it)
    return ",".join(seen) if seen else None


def merge_csv(a, b):
    items = []
    for part in (a or "").split(",") + (b or "").split(","):
        p = part.strip()
        if p and p not in items:
            items.append(p)
    return ",".join(items) if items else None


def merge_json_list(a, b):
    try:
        la = json.loads(a) if a else []
    except Exception:
        la = []
    try:
        lb = json.loads(b) if b else []
    except Exception:
        lb = []
    out = []
    for item in la + lb:
        if item not in out:
            out.append(item)
    return json.dumps(out, ensure_ascii=False) if out else None


VALID_STATUS = {"active", "ipo", "ma", "closed"}

# 既存が空欄のときだけ新データで埋める列
FILL_COLS = (
    "website", "founded_year", "hq", "representative",
    "description", "stage", "total_raised_oku",
    "valuation_oku", "valuation_source", "last_round_date",
    "last_round_name", "last_round_amount_oku",
    "last_round_investors", "last_round_lead", "status_note", "employee_count",
    "last_verified", "contact_url", "rep_linkedin", "rep_x",
    "rep_facebook",
)
# 直近ラウンドが新しいときにまとめて差し替える列（古いラウンドの引受先を残さない）
ROUND_COLS = (
    "last_round_date", "last_round_name", "last_round_amount_oku",
    "last_round_investors", "last_round_lead",
)


def merge_into(existing, fields):
    """既存レコードへ新データをマージする。戻り値: ラウンド情報を上書きしたか。

    - 新データの直近ラウンドが既存より新しい月なら ROUND_COLS を差し替え、
      stage / total_raised_oku / status_note / last_verified も（値がある時だけ）上書き
    - それ以外の列は既存の値を優先し、空欄のみ新データで埋める。リスト系は結合。
    """
    newer = should_replace_round(fields["last_round_date"], existing.last_round_date,
                                 fields["last_round_name"], existing.last_round_name,
                                 fields["last_round_amount_oku"], existing.last_round_amount_oku)
    if newer:
        # 年のみ日付の月補完（同一ラウンド）ではステージを動かさない。差し替え前に判定する
        meta = ("stage", "status_note", "last_verified") if round_is_newer(
            fields["last_round_date"], existing.last_round_date) else ("status_note", "last_verified")
        for col in ROUND_COLS:
            setattr(existing, col, fields[col])
        existing.total_raised_oku = keep_max_total(existing.total_raised_oku, fields["total_raised_oku"])
        for col in meta:
            if fields[col] not in (None, ""):
                setattr(existing, col, fields[col])
    for col in FILL_COLS:
        if getattr(existing, col) in (None, "") and fields[col] not in (None, ""):
            setattr(existing, col, fields[col])
    existing.sectors = merge_csv(existing.sectors, fields["sectors"])
    existing.themes = merge_csv(existing.themes, fields["themes"])
    existing.investors = merge_csv(existing.investors, fields["investors"])
    existing.partners = merge_csv(existing.partners, fields["partners"])
    existing.awards = merge_json_list(existing.awards, fields["awards"])
    existing.sources = merge_json_list(existing.sources, fields["sources"])
    # closed/ipo/ma の情報は active より優先（存続状況の正確性重視）。ステージも整合させる
    if existing.status == "active" and fields["status"] != "active":
        existing.status = fields["status"]
        existing.stage = stage_for_status(fields["status"], fields["stage"] or existing.stage)
    return newer


def record_to_fields(rec, theme):
    lr = rec.get("last_round") or {}
    status = rec.get("status")
    if status not in VALID_STATUS:
        status = "active"
    awards = rec.get("awards") or []
    sources = [u for u in (safe_url(s) for s in (rec.get("sources") or [])) if u]
    return {
        "name": (rec.get("name") or "").strip(),
        "website": safe_url(rec.get("website")),
        "founded_year": rec.get("founded_year"),
        "hq": rec.get("hq"),
        "representative": rec.get("representative"),
        "description": rec.get("description"),
        "sectors": join_list(rec.get("sectors")),
        "themes": theme,
        "stage": rec.get("stage"),
        "total_raised_oku": rec.get("total_raised_oku"),
        "valuation_oku": rec.get("valuation_oku"),
        "valuation_source": rec.get("valuation_source"),
        "last_round_date": lr.get("date"),
        "last_round_name": lr.get("round"),
        "last_round_amount_oku": lr.get("amount_oku"),
        "last_round_investors": join_list(lr.get("investors")),
        "last_round_lead": lr.get("lead") or None,
        "investors": join_list(rec.get("investors")),
        "partners": join_list(rec.get("partners")),
        "awards": json.dumps(awards, ensure_ascii=False) if awards else None,
        "status": status,
        "status_note": rec.get("status_note"),
        "employee_count": rec.get("employee_count"),
        "sources": json.dumps(sources, ensure_ascii=False) if sources else None,
        "last_verified": rec.get("last_verified"),
        "contact_url": safe_url(rec.get("contact_url")),
        "rep_linkedin": safe_url(rec.get("rep_linkedin")),
        "rep_x": safe_url(rec.get("rep_x")),
        "rep_facebook": safe_url(rec.get("rep_facebook")),
    }


def main():
    ensure_sqlite_schema(engine)
    db = SessionLocal()

    files = sorted(glob.glob(os.path.join(RAW_DIR, "*.json")))
    if not files:
        print("no raw json files in", RAW_DIR)
        sys.exit(1)

    # 既存レコードの名寄せインデックス
    index = {norm_name(c.name): c for c in db.query(Company).all()}
    inserted, merged, round_updated, skipped = 0, 0, 0, 0

    for path in files:
        theme = os.path.splitext(os.path.basename(path))[0]
        try:
            with open(path, encoding="utf-8") as f:
                records = json.load(f)
        except Exception as e:
            print("SKIP %s: %s" % (path, e))
            continue
        if not isinstance(records, list):
            print("SKIP %s: not a list" % path)
            continue

        for rec in records:
            fields = record_to_fields(rec, theme)
            if not fields["name"]:
                skipped += 1
                continue
            key = norm_name(fields["name"])
            existing = index.get(key)
            if existing is None:
                company = Company(**fields)
                db.add(company)
                index[key] = company
                inserted += 1
            else:
                if merge_into(existing, fields):
                    round_updated += 1
                merged += 1

    db.commit()
    total = db.query(Company).count()
    print("inserted=%d merged=%d round_updated=%d skipped=%d total=%d"
          % (inserted, merged, round_updated, skipped, total))
    db.close()


if __name__ == "__main__":
    main()
