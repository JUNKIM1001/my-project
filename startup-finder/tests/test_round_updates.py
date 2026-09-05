"""ラウンド情報の更新経路のテスト（import_json のマージ / apply_round_updates）。

インメモリSQLiteに最小データを投入して回すので、ローカルDBにも本番にも触れない。
usage: .venv/bin/python -m pytest tests/ -q
"""

import os
import sys

import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.pop("DATABASE_URL", None)

from sqlalchemy import create_engine  # noqa: E402
from sqlalchemy.orm import sessionmaker  # noqa: E402

from app.db import Base  # noqa: E402
from app.models import Company  # noqa: E402
from app.rounds import (  # noqa: E402
    is_month_refinement, keep_max_total, round_is_newer, should_replace_round, stage_for_status,
)
from app.scripts.sync_fields_to_postgres import sync_row  # noqa: E402
from app.scripts import apply_round_updates as aru  # noqa: E402
from app.scripts.import_json import merge_into, record_to_fields  # noqa: E402


@pytest.fixture
def db():
    engine = create_engine("sqlite://")
    Base.metadata.create_all(bind=engine)
    s = sessionmaker(bind=engine)()
    s.add_all([
        Company(id=1, name="株式会社Alpha", status="active", stage="シリーズB", total_raised_oku=15.0,
                last_round_date="2023-05", last_round_name="シリーズB", last_round_amount_oku=10.0,
                last_round_investors="ジャフコ グループ,UB Ventures", investors="ジャフコ グループ,UB Ventures",
                sources='["https://example.com/b"]', last_verified="2026-07"),
        Company(id=2, name="株式会社Beta", status="active", stage="シリーズA",
                last_round_date="2022-01", last_round_name="シリーズA"),
            Company(id=3, name="株式会社Gamma", status="active", stage="シード",
                last_round_date="2024-04"),
        Company(id=4, name="株式会社Delta", status="active", stage="シリーズC以降", total_raised_oku=56.0,
                last_round_date="2024", last_round_name="シリーズD", last_round_amount_oku=13.4),
    ])
    s.commit()
    yield s
    s.close()


def test_round_is_newer():
    assert round_is_newer("2025-11", "2023-05")
    assert round_is_newer("2025-11", None)
    assert round_is_newer("2025-11", "bad")
    assert not round_is_newer("2025-11", "2025-11")   # 同月は据え置き
    assert not round_is_newer("2023-05", "2025-11")
    assert not round_is_newer(None, "2023-05")
    assert not round_is_newer("2025-13", None)         # 月が不正
    # 既存が年のみ: 翌年以降だけ新しい扱い。同年は日付だけでは判断しない
    assert round_is_newer("2025-01", "2024")
    assert not round_is_newer("2024-03", "2024")
    assert not round_is_newer("2022-03", "2024")


def test_month_refinement_and_stage_for_status():
    # 同年かつラウンド名一致 or 金額一致のときだけ月補完とみなす
    assert is_month_refinement("2024-05", "2024", "シリーズD", "シリーズ D", None, None)
    assert not is_month_refinement("2024-05", "2024", "別名", "シリーズD", 13.4, 13.4)  # 名前が両方あれば一致必須
    assert is_month_refinement("2024-05", "2024", None, "シリーズD", 13.4, 13.4)          # 片方欠けなら金額で判定
    assert not is_month_refinement("2024-05", "2024", None, "シリーズD", "", 13.4)         # 空文字・非数値で落ちない
    assert not is_month_refinement("2024-05", "2024", "", None, "abc", 13.4)
    assert is_month_refinement("2024-05", "2024", None, None, "13.4", 13.4)              # 数値文字列は許容
    assert not is_month_refinement("2024-01", "2024", "シリーズB", "シリーズD", 5.0, 13.4)
    assert not is_month_refinement("2025-01", "2024", "シリーズD", "シリーズD", 13.4, 13.4)  # 年が違えば通常判定
    assert should_replace_round("2025-01", "2024") and not should_replace_round("2024-01", "2024", "B", "D", 1, 2)
    # 終了ステータスには終了ステージを強制する
    assert stage_for_status("ipo", "シリーズA") == "IPO済"
    assert stage_for_status("ma", "M&A済") == "M&A済"
    assert stage_for_status("ipo", "M&A済") == "IPO済"   # status と食い違う終了ステージは status 側を正とする
    assert stage_for_status("closed", None) == "清算"
    assert stage_for_status("active", "シリーズB") == "シリーズB"


def test_keep_max_total():
    assert keep_max_total(56.0, 7.6) == 56.0      # 累計は減らさない
    assert keep_max_total(15.0, 35.0) == 35.0
    assert keep_max_total(None, 3.0) == 3.0
    assert keep_max_total(5.0, None) == 5.0


def test_import_merge_overwrites_when_newer(db):
    c = db.get(Company, 1)
    fields = record_to_fields({
        "name": "株式会社Alpha", "stage": "シリーズC以降", "total_raised_oku": 35,
        "last_round": {"date": "2025-11", "round": "シリーズC 1stクローズ", "amount_oku": 20,
                       "lead": "ジャフコ グループ", "investors": ["ジャフコ グループ", "Carbide Ventures"]},
        "investors": ["Carbide Ventures"], "status": "active", "status_note": "累計35億円",
        "sources": ["https://example.com/c"], "last_verified": "2026-08",
    }, "t")
    assert merge_into(c, fields) is True
    assert c.stage == "シリーズC以降" and c.total_raised_oku == 35
    assert c.last_round_date == "2025-11" and c.last_round_amount_oku == 20
    assert c.last_round_lead == "ジャフコ グループ"
    assert c.last_round_investors == "ジャフコ グループ,Carbide Ventures"   # 旧ラウンドの引受先は残さない
    assert "UB Ventures" in c.investors and "Carbide Ventures" in c.investors  # 通算投資家は結合
    assert c.status_note == "累計35億円" and c.last_verified == "2026-08"
    assert "https://example.com/b" in c.sources and "https://example.com/c" in c.sources


def test_import_merge_keeps_existing_when_older_or_same(db):
    c = db.get(Company, 1)
    older = record_to_fields({"name": "株式会社Alpha", "stage": "シード", "total_raised_oku": 1,
                              "last_round": {"date": "2021-06", "round": "シリーズA", "amount_oku": 4.6},
                              "status": "active"}, "t")
    assert merge_into(c, older) is False
    same = record_to_fields({"name": "株式会社Alpha", "stage": "シード",
                             "last_round": {"date": "2023-05", "round": "別名", "amount_oku": 99},
                             "status": "active"}, "t")
    assert merge_into(c, same) is False
    assert c.stage == "シリーズB" and c.total_raised_oku == 15.0
    assert c.last_round_name == "シリーズB" and c.last_round_amount_oku == 10.0


def test_import_merge_year_only_date_and_total_guard(db):
    d = db.get(Company, 4)
    older_year = record_to_fields({"name": "株式会社Delta", "stage": "シリーズC", "total_raised_oku": 7.6,
                                   "last_round": {"date": "2022-03", "round": "シリーズC", "amount_oku": 20},
                                   "status": "active"}, "t")
    assert merge_into(d, older_year) is False           # "2024" より前の年では上書きしない
    assert d.last_round_date == "2024" and d.total_raised_oku == 56.0
    same_year = record_to_fields({"name": "株式会社Delta", "stage": "シリーズA", "total_raised_oku": 7.6,
                                  "last_round": {"date": "2024-05", "round": "シリーズD", "amount_oku": 13.4},
                                  "status": "active"}, "t")
    assert merge_into(d, same_year) is True             # 同年かつラウンド名一致は月の補完として採用
    assert d.last_round_date == "2024-05" and d.total_raised_oku == 56.0   # 累計は小さい値で潰さない
    assert d.stage == "シリーズC以降"                     # 月補完ではステージを動かさない


def test_apply_round_updates_newer_status_and_guards(db):
    logs = []
    recs = [
        {   # 新ラウンド（リード明記）
            "id": 1, "name": "株式会社Alpha", "checked": True, "newer_round_found": True,
            "stage": "シリーズC以降", "total_raised_oku": 35,
            "last_round": {"date": "2025-11", "round": "シリーズC 1stクローズ", "amount_oku": 20,
                           "lead": "ジャフコ グループ", "investors": ["ジャフコ グループ", "Carbide Ventures"]},
            "investors_added": ["Carbide Ventures"], "status": "active", "status_note": None,
            "employee_count": 300, "valuation_oku": None, "valuation_source": None,
            "sources": ["https://example.com/c"], "note": "デット含む",
        },
        {   # 上場していた
            "id": 2, "name": "株式会社Beta", "checked": True, "newer_round_found": False,
            "stage": None, "total_raised_oku": None, "last_round": None, "investors_added": [],
            "status": "ipo", "status_note": "2025年12月 東証グロース上場", "employee_count": None,
            "valuation_oku": None, "valuation_source": None,
            "sources": ["https://example.com/ipo"], "note": "",
        },
        {   # 「新ラウンド」だがDBより古い → 据え置き（last_verified だけ更新）
            "id": 3, "name": "株式会社Gamma", "checked": True, "newer_round_found": True,
            "stage": "シリーズA", "total_raised_oku": 3,
            "last_round": {"date": "2023-01", "round": "シリーズA", "amount_oku": 3, "lead": None, "investors": []},
            "investors_added": [], "status": "active", "status_note": None, "employee_count": None,
            "valuation_oku": None, "valuation_source": None, "sources": ["https://example.com/g"], "note": "",
        },
        {   # id と name が食い違う → 書かない
            "id": 3, "name": "株式会社Delta", "checked": True, "newer_round_found": False,
            "stage": None, "total_raised_oku": None, "last_round": None, "investors_added": [],
            "status": "closed", "status_note": "清算", "employee_count": None,
            "valuation_oku": None, "valuation_source": None, "sources": [], "note": "",
        },
        {   # 日付形式が不正 → 書かない
            "id": 1, "name": "株式会社Alpha", "checked": True, "newer_round_found": True,
            "stage": None, "total_raised_oku": None,
            "last_round": {"date": "2026/01", "round": "x", "amount_oku": 1, "lead": None, "investors": []},
            "investors_added": [], "status": "active", "status_note": None, "employee_count": None,
            "valuation_oku": None, "valuation_source": None, "sources": ["https://example.com/x"], "note": "",
        },
    ]
    stats = aru.apply_records(db, recs, "2026-08", log=logs.append)
    assert stats == {"checked": 3, "round_updated": 1, "status_changed": 1,
                     "skipped_invalid": 1, "skipped_not_found": 1, "not_newer": 1}

    a = db.get(Company, 1)
    assert a.last_round_date == "2025-11" and a.last_round_lead == "ジャフコ グループ"
    assert a.stage == "シリーズC以降" and a.total_raised_oku == 35 and a.employee_count == 300
    assert a.status_note == "デット含む"                     # status_note が無ければ note を採用
    assert "Carbide Ventures" in a.investors and "UB Ventures" in a.investors
    assert "https://example.com/c" in a.sources and a.last_verified == "2026-08"

    b = db.get(Company, 2)
    assert b.status == "ipo" and b.stage == "IPO済" and "東証グロース" in b.status_note

    g = db.get(Company, 3)
    assert g.last_round_date == "2024-04" and g.stage == "シード"   # 古いラウンドでは上書きしない
    assert g.status == "active" and g.last_verified == "2026-08"   # 別名レコードの closed は反映されない
    assert any("2026/01" in m for m in logs) and any("株式会社Delta" in m for m in logs)


def test_apply_same_month_fills_lead_only(db):
    a = db.get(Company, 1)
    a.last_round_lead = None
    rec = {"id": 1, "name": "株式会社Alpha", "checked": True, "newer_round_found": True,
           "stage": "シード", "total_raised_oku": 1,
           "last_round": {"date": "2023-05", "round": "別名", "amount_oku": 99, "lead": "ジャフコ グループ",
                          "investors": ["X"]},
           "investors_added": [], "status": "active", "status_note": None, "employee_count": None,
           "valuation_oku": None, "valuation_source": None, "sources": ["https://example.com/s"], "note": ""}
    stats = aru.apply_records(db, [rec], "2026-08", log=lambda m: None)
    assert stats["round_updated"] == 0 and stats["not_newer"] == 1
    assert a.last_round_lead == "ジャフコ グループ"                      # 空欄のリードだけ補完
    assert a.last_round_name == "シリーズB" and a.last_round_amount_oku == 10.0 and a.stage == "シリーズB"
    assert a.last_round_investors == "ジャフコ グループ,UB Ventures"      # 既存の引受先は保持


def test_apply_validation_requires_source_for_valuation():
    rec = {"id": 1, "name": "株式会社Alpha", "checked": True, "newer_round_found": False, "status": "active",
           "valuation_oku": 100, "valuation_source": None, "sources": []}
    assert any("valuation" in p for p in aru.validate(rec))
    rec["valuation_source"] = "https://example.com/v"
    assert aru.validate(rec) == []
    rec["newer_round_found"] = 1                      # 真偽値以外は不正
    assert any("newer_round_found" in p for p in aru.validate(rec))


def test_apply_status_transition_forces_terminal_stage_and_dry_run_rollback(db):
    rec = {"id": 2, "name": "株式会社Beta", "checked": True, "newer_round_found": False,
           "stage": "シリーズA", "total_raised_oku": None, "last_round": None, "investors_added": [],
           "status": "ipo", "status_note": "上場", "employee_count": None,
           "valuation_oku": None, "valuation_source": None, "sources": ["https://example.com/i"], "note": ""}
    stats = aru.apply_records(db, [rec], "2026-08", dry_run=True)
    assert stats["status_changed"] == 1
    assert db.get(Company, 2).stage == "IPO済"        # ipo + シリーズA にはしない
    db.rollback()
    db.expire_all()
    b = db.get(Company, 2)
    assert b.status == "active" and b.stage == "シリーズA" and b.last_verified is None  # dry-run は残らない


def test_sync_row_fill_round_status_merge_idempotent():
    remote = Company(id=1, name="株式会社Alpha", status="active", stage="シリーズB", total_raised_oku=15.0,
                     last_round_date="2023-05", last_round_name="シリーズB", last_round_amount_oku=10.0,
                     last_round_investors="ジャフコ グループ", investors="ジャフコ グループ", hq=None,
                     sources='["https://example.com/b"]', partners=None, themes="a")
    local = Company(id=1, name="株式会社Alpha", status="ipo", stage="シリーズC以降", total_raised_oku=35.0,
                    last_round_date="2025-11", last_round_name="シリーズC", last_round_amount_oku=20.0,
                    last_round_investors="ジャフコ グループ,Carbide Ventures", last_round_lead="ジャフコ グループ",
                    investors="ジャフコ グループ,Carbide Ventures", hq="東京都品川区", status_note="2026-04 上場",
                    sources='["https://example.com/c"]', partners="Uberall", themes="a,b", last_verified="2026-08")
    r = sync_row(remote, local)
    assert r["round"] and r["status"] and r["filled"] >= 1 and r["merged"] >= 3
    assert remote.hq == "東京都品川区"                                   # fill: 空欄のみ
    assert remote.last_round_date == "2025-11" and remote.last_round_lead == "ジャフコ グループ"
    assert remote.total_raised_oku == 35.0
    assert remote.status == "ipo" and remote.stage == "IPO済"           # status 遷移はステージを整合させる
    assert remote.status_note == "2026-04 上場"
    assert remote.investors == "ジャフコ グループ,Carbide Ventures" and remote.partners == "Uberall"
    assert "https://example.com/b" in remote.sources and "https://example.com/c" in remote.sources
    # 再実行しても変化しない（冪等）
    snapshot = {c: getattr(remote, c) for c in ("stage", "status", "total_raised_oku", "last_round_date",
                                                 "investors", "sources", "themes")}
    r2 = sync_row(remote, local)
    assert r2 == {"filled": 0, "merged": 0, "round": False, "status": False}
    assert snapshot == {c: getattr(remote, c) for c in snapshot}
    # 本番の累計が大きいときは減らさない
    remote2 = Company(id=2, name="株式会社Beta", status="active", total_raised_oku=50.0, last_round_date="2021-01")
    local2 = Company(id=2, name="株式会社Beta", status="active", total_raised_oku=7.6, last_round_date="2024-05")
    assert sync_row(remote2, local2)["round"] and remote2.total_raised_oku == 50.0
    # 同月ラウンドでも空欄のリードは埋め、最終確認月は新しい方へ進める（古い方へは戻さない）
    remote3 = Company(id=3, name="株式会社Gamma", status="active", last_round_date="2025-11",
                      last_round_lead=None, last_verified="2026-07")
    local3 = Company(id=3, name="株式会社Gamma", status="active", last_round_date="2025-11",
                     last_round_lead="ジャフコ グループ", last_verified="2026-09")
    r3 = sync_row(remote3, local3)
    assert not r3["round"] and remote3.last_round_lead == "ジャフコ グループ" and remote3.last_verified == "2026-09"
    assert sync_row(remote3, Company(id=3, name="株式会社Gamma", status="active", last_verified="2026-01"))["filled"] == 0
    assert remote3.last_verified == "2026-09"
