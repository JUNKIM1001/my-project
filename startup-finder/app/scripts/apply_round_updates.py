"""エージェント再調査の結果（data/raw/updates/*.json）をDBへ反映する。

data/raw/*.json（import_json の入力・企業プロフィール全体）とはスキーマが異なる
「差分更新」専用。data/raw/updates/ は import_json の glob 対象外なので混ざらない。

- 直近ラウンドが既存より新しい月の場合のみ、ラウンド情報（リード含む）・
  ステージ・累計調達額を上書きする
- IPO / M&A / 清算が判明した会社は status を遷移させる（active からのみ）
- 確認した会社は last_verified を実行月に更新し、出典・投資家を追記する
- id と name の両方が一致する行にだけ書き込む（名寄せ違いの誤上書き防止）
- 入力の検証に落ちたレコードは書き込まず WARN を出す（事実のみ・推測禁止の運用）

usage:
  DATABASE_URL="" .venv/bin/python3 -m app.scripts.apply_round_updates [--dry-run] [file.json ...]
  （ファイル省略時は data/raw/updates/*.json をすべて処理）
"""

import argparse
import glob
import json
import os
import sys
from datetime import date

from app.db import BASE_DIR, SessionLocal, engine
from app.models import Company
from app.rounds import (
    STAGE_BY_STATUS, keep_max_total, round_is_newer, should_replace_round, stage_for_status, valid_ym,
)
from app.schema import ensure_sqlite_schema
from app.scripts.import_json import join_list, merge_csv, merge_json_list, safe_url

UPDATES_DIR = os.path.join(BASE_DIR, "data", "raw", "updates")

VALID_STATUS = {"active", "ipo", "ma", "closed"}
VALID_STAGES = {
    "プレシード", "シード", "エンジェル", "プレシリーズA", "シリーズA", "プレシリーズB",
    "シリーズB", "シリーズC", "シリーズC以降", "シリーズD", "レイター",
    "IPO済", "M&A済", "清算",
}


def is_num(v):
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def validate(rec):
    """スキーマ検証。問題点の文字列リストを返す（空なら合格）。"""
    problems = []
    if not isinstance(rec.get("id"), int) or isinstance(rec.get("id"), bool):
        problems.append("id が整数でない")
    if not isinstance(rec.get("name"), str) or not rec["name"].strip():
        problems.append("name が空")
    for col in ("checked", "newer_round_found"):
        if not isinstance(rec.get(col), bool):
            problems.append("%s が真偽値でない" % col)
    if rec.get("status") not in VALID_STATUS:
        problems.append("status が不正: %r" % rec.get("status"))
    if rec.get("stage") is not None and rec["stage"] not in VALID_STAGES:
        problems.append("stage が不正: %r" % rec.get("stage"))
    for col in ("total_raised_oku", "valuation_oku"):
        if rec.get(col) is not None and not is_num(rec[col]):
            problems.append("%s が数値でない" % col)
    if rec.get("employee_count") is not None and (
            not isinstance(rec["employee_count"], int) or isinstance(rec["employee_count"], bool)):
        problems.append("employee_count が整数でない")
    if rec.get("valuation_oku") is not None and not safe_url(rec.get("valuation_source")):
        problems.append("valuation_oku に出典URLがない")
    lr = rec.get("last_round")
    if rec.get("newer_round_found"):
        if not isinstance(lr, dict):
            problems.append("newer_round_found なのに last_round がない")
        else:
            if not valid_ym(lr.get("date")):
                problems.append("last_round.date が YYYY-MM でない: %r" % lr.get("date"))
            if lr.get("amount_oku") is not None and not is_num(lr["amount_oku"]):
                problems.append("last_round.amount_oku が数値でない")
            if lr.get("lead") is not None and not isinstance(lr["lead"], str):
                problems.append("last_round.lead が文字列でない")
            if not [u for u in (safe_url(s) for s in (rec.get("sources") or [])) if u]:
                problems.append("新ラウンドに出典URLがない")
    return problems


def apply_record(existing, rec, verified_ym):
    """1社分を既存レコードへ反映する。戻り値: {"round": bool, "status": bool}."""
    out = {"round": False, "status": False}
    lr = rec.get("last_round") or {}
    note = rec.get("status_note") or (rec.get("note") or None)

    if rec.get("newer_round_found") and should_replace_round(
            lr.get("date"), existing.last_round_date, lr.get("round"), existing.last_round_name,
            lr.get("amount_oku"), existing.last_round_amount_oku):
        strictly_newer = round_is_newer(lr["date"], existing.last_round_date)  # 差し替え前に判定
        existing.last_round_date = lr["date"]
        existing.last_round_name = lr.get("round") or None
        existing.last_round_amount_oku = lr.get("amount_oku")
        existing.last_round_investors = join_list(lr.get("investors"))
        existing.last_round_lead = (lr.get("lead") or "").strip() or None
        if rec.get("stage") and strictly_newer:
            existing.stage = rec["stage"]   # 月補完（同一ラウンド）ではステージを動かさない
        existing.total_raised_oku = keep_max_total(existing.total_raised_oku, rec.get("total_raised_oku"))
        if note:
            existing.status_note = note
        out["round"] = True
    elif rec.get("newer_round_found") and lr.get("date") == existing.last_round_date:
        # 同月＝同一ラウンドの再確認。空欄のリード・引受先だけ補完する（既存値は壊さない）
        if not existing.last_round_lead and (lr.get("lead") or "").strip():
            existing.last_round_lead = lr["lead"].strip()
        if not existing.last_round_investors and lr.get("investors"):
            existing.last_round_investors = join_list(lr.get("investors"))

    if existing.status == "active" and rec["status"] in STAGE_BY_STATUS:
        existing.status = rec["status"]
        existing.stage = stage_for_status(rec["status"], rec.get("stage"))
        if note:
            existing.status_note = note
        out["status"] = True

    if rec.get("employee_count") is not None:
        existing.employee_count = rec["employee_count"]
    if rec.get("valuation_oku") is not None:
        existing.valuation_oku = rec["valuation_oku"]
        existing.valuation_source = safe_url(rec.get("valuation_source"))

    added = list(rec.get("investors_added") or []) + list(lr.get("investors") or [])
    if lr.get("lead"):
        added.append(lr["lead"])
    existing.investors = merge_csv(existing.investors, join_list(added))
    srcs = [u for u in (safe_url(s) for s in (rec.get("sources") or [])) if u]
    existing.sources = merge_json_list(existing.sources, json.dumps(srcs, ensure_ascii=False) if srcs else None)
    existing.last_verified = verified_ym
    return out


def apply_records(db, records, verified_ym, dry_run=False, log=print):
    stats = {"checked": 0, "round_updated": 0, "status_changed": 0,
             "skipped_invalid": 0, "skipped_not_found": 0, "not_newer": 0}
    for rec in records:
        problems = validate(rec) if isinstance(rec, dict) else ["要素がオブジェクトでない"]
        if problems:
            stats["skipped_invalid"] += 1
            log("WARN skip %s: %s" % (rec.get("name") if isinstance(rec, dict) else rec, "; ".join(problems)))
            continue
        existing = db.get(Company, rec["id"])
        if existing is None or existing.name != rec["name"]:
            stats["skipped_not_found"] += 1
            log("WARN skip id=%s name=%r: DBと id/name が一致しない（DB側: %r）"
                % (rec["id"], rec["name"], getattr(existing, "name", None)))
            continue
        before = (existing.last_round_date, existing.status)
        res = apply_record(existing, rec, verified_ym)
        stats["checked"] += 1
        if res["round"]:
            stats["round_updated"] += 1
        elif rec.get("newer_round_found"):
            stats["not_newer"] += 1
            log("INFO %s: last_round.date=%s は既存 %s より新しくないためラウンドは据え置き"
                % (rec["name"], (rec.get("last_round") or {}).get("date"), before[0]))
        if res["status"]:
            stats["status_changed"] += 1
        if dry_run and (res["round"] or res["status"]):
            log("PLAN %s: round %s -> %s / status %s -> %s"
                % (rec["name"], before[0], existing.last_round_date, before[1], existing.status))
    return stats


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("files", nargs="*", help="更新JSON（省略時は data/raw/updates/*.json）")
    ap.add_argument("--dry-run", action="store_true", help="書き込まずに変更予定だけ表示")
    ap.add_argument("--verified", default=date.today().strftime("%Y-%m"),
                    help="last_verified に入れる月 YYYY-MM（既定: 今月）")
    args = ap.parse_args(argv)
    if not valid_ym(args.verified):
        sys.exit("--verified は YYYY-MM 形式で指定してください")

    files = args.files or sorted(glob.glob(os.path.join(UPDATES_DIR, "*.json")))
    if not files:
        sys.exit("更新JSONがありません: %s" % UPDATES_DIR)

    ensure_sqlite_schema(engine)
    db = SessionLocal()
    total = {}
    try:
        for path in files:
            try:
                with open(path, encoding="utf-8") as f:
                    records = json.load(f)
            except (OSError, ValueError) as e:
                print("SKIP %s: %s" % (path, e))
                continue
            if not isinstance(records, list):
                print("SKIP %s: not a list" % path)
                continue
            stats = apply_records(db, records, args.verified, dry_run=args.dry_run)
            print("%s: %s" % (os.path.basename(path), stats))
            for k, v in stats.items():
                total[k] = total.get(k, 0) + v
        if args.dry_run:
            db.rollback()
            print("DRY-RUN（書き込みなし） total:", total)
        else:
            db.commit()
            print("APPLIED total:", total)
    finally:
        db.close()


if __name__ == "__main__":
    main()
