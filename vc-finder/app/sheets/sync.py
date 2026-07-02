"""有効リード（review_status=承認 のVC/CVC）と Google スプレッドシートの双方向同期。

役割分担:
  - アプリ所有列（候補情報）: DBが正。push でシートへ上書きする。
  - 人間所有列（営業管理）  : シートが正。pull でDBへ取り込む。

シート上の行は DB の ID 列をキーに突合する。push はシート既存行の
人間所有列を保持したまま候補情報だけを更新し、リード化解除された行や
手で追加された行は消さない。

CLI:
  python -m app.sheets.sync setup   # ヘッダー行・ステータスのプルダウンを整備
  python -m app.sheets.sync push    # DB → シート（有効リードを反映）
  python -m app.sheets.sync pull    # シート → DB（営業管理列を取り込み）
  python -m app.sheets.sync sync    # pull してから push（cron向け）
"""
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models import VC

# ヘッダー定義。前半がアプリ所有列（DBが正）、STATUS_COL 以降が人間所有列（シートが正）。
APP_COLUMNS = [
    "ID", "企業名", "種別", "親会社", "適合度", "主な投資ステージ",
    "商談提案ポイント", "最近の出資・協業", "Webサイト", "問い合わせ先",
    "代表者", "代表者SNS", "リード登録日",
]
HUMAN_COLUMNS = ["対応ステータス", "担当者", "次アクション", "期日", "メモ"]
HEADERS = APP_COLUMNS + HUMAN_COLUMNS

STATUS_CHOICES = ["未着手", "連絡済み", "返信あり", "商談設定", "商談済み", "検討中", "成約", "見送り"]
DEFAULT_STATUS = "未着手"


def qualified_leads(db: Session):
    """有効リード＝承認済みの候補。適合度の高い順。"""
    return (
        db.query(VC)
        .filter(VC.review_status == "承認")
        .order_by(VC.score.desc().nullslast(), VC.name)
        .all()
    )


def vc_to_app_values(vc: VC) -> list:
    """アプリ所有列のセル値を組み立てる（純粋関数・テスト可能）。"""
    sns = " / ".join(x for x in [vc.rep_linkedin, vc.rep_facebook] if x)
    registered = ""
    if vc.lead_registered_at:
        registered = vc.lead_registered_at.strftime("%Y-%m-%d")
    return [
        str(vc.id),
        vc.name or "",
        vc.type or "",
        vc.parent_company or "",
        str(vc.score) if vc.score is not None else "",
        "・".join((vc.stages or "").split(",")),
        " / ".join((vc.pitch_points or "").split(",")),
        vc.investment_evidence or "",
        vc.website or "",
        vc.contact_url or "",
        vc.rep_name or "",
        sns,
        registered,
    ]


def vc_to_human_values(vc: VC) -> list:
    return [
        vc.status or DEFAULT_STATUS,
        vc.owner or "",
        vc.next_action or "",
        vc.next_action_due or "",
        vc.lead_memo or "",
    ]


def _pad(row: list, length: int) -> list:
    return (row + [""] * length)[:length]


def merge_rows(existing_rows: list, leads: list) -> list:
    """シートの既存行と現在の有効リードをマージした新しいグリッドを返す。

    - 既存行はIDで突合し、アプリ所有列だけを最新化（人間所有列は保持）
    - シートに無いリードは末尾に追加（ステータスは未着手）
    - リード化解除・手動追加の行はそのまま残す
    """
    n_app, n_all = len(APP_COLUMNS), len(HEADERS)
    leads_by_id = {str(vc.id): vc for vc in leads}
    out = [list(HEADERS)]
    seen = set()

    for raw in existing_rows:
        row = _pad(list(raw), n_all)
        vc = leads_by_id.get(row[0].strip())
        if vc is not None:
            row = vc_to_app_values(vc) + row[n_app:]
            if not row[n_app].strip():
                row[n_app] = DEFAULT_STATUS
            seen.add(str(vc.id))
        out.append(_pad(row, n_all))

    for vc in leads:
        if str(vc.id) not in seen:
            out.append(vc_to_app_values(vc) + vc_to_human_values(vc))
    return out


def push_leads(db: Session, ws=None) -> dict:
    """DB → シート。有効リードをシートへ反映する。"""
    from app.sheets.client import open_worksheet

    ws = ws or open_worksheet()
    leads = qualified_leads(db)

    values = ws.get_all_values()
    existing = values[1:] if values else []
    grid = merge_rows(existing, leads)

    ws.clear()
    ws.update(grid, "A1")

    now = datetime.now(timezone.utc)
    for vc in leads:
        vc.sheet_synced_at = now
    db.commit()
    return {"pushed": len(leads), "rows": len(grid) - 1}


def pull_leads(db: Session, ws=None) -> dict:
    """シート → DB。人間所有列（営業管理）を取り込む。"""
    from app.sheets.client import open_worksheet

    ws = ws or open_worksheet()
    values = ws.get_all_values()
    if not values:
        return {"pulled": 0}

    n_app, n_all = len(APP_COLUMNS), len(HEADERS)
    updated = 0
    now = datetime.now(timezone.utc)
    for raw in values[1:]:
        row = _pad(list(raw), n_all)
        if not row[0].strip().isdigit():
            continue
        vc = db.query(VC).filter(VC.id == int(row[0])).first()
        if vc is None:
            continue
        status, owner, next_action, due, memo = (v.strip() for v in row[n_app:n_all])
        vc.status = status or vc.status
        vc.owner = owner or None
        vc.next_action = next_action or None
        vc.next_action_due = due or None
        vc.lead_memo = memo or None
        vc.sheet_synced_at = now
        updated += 1
    db.commit()
    return {"pulled": updated}


def setup_sheet(ws=None) -> dict:
    """ヘッダー行の整備・固定と、対応ステータス列のプルダウン設定。"""
    from app.sheets.client import open_worksheet

    ws = ws or open_worksheet()
    ws.update([HEADERS], "A1")
    ws.freeze(rows=1)

    status_col = len(APP_COLUMNS)  # 0-indexed
    ws.spreadsheet.batch_update({
        "requests": [{
            "setDataValidation": {
                "range": {
                    "sheetId": ws.id,
                    "startRowIndex": 1,
                    "startColumnIndex": status_col,
                    "endColumnIndex": status_col + 1,
                },
                "rule": {
                    "condition": {
                        "type": "ONE_OF_LIST",
                        "values": [{"userEnteredValue": s} for s in STATUS_CHOICES],
                    },
                    "showCustomUi": True,
                    "strict": False,
                },
            }
        }]
    })
    return {"worksheet": ws.title, "headers": HEADERS}


def main():
    import argparse

    from dotenv import load_dotenv

    load_dotenv()
    parser = argparse.ArgumentParser(description="有効リードとGoogleスプレッドシートの同期")
    parser.add_argument("command", choices=["setup", "push", "pull", "sync"])
    args = parser.parse_args()

    from app.db import SessionLocal, Base, engine, ensure_columns

    Base.metadata.create_all(bind=engine)
    ensure_columns()
    db = SessionLocal()
    try:
        if args.command == "setup":
            print(setup_sheet())
        elif args.command == "push":
            print(push_leads(db))
        elif args.command == "pull":
            print(pull_leads(db))
        elif args.command == "sync":
            result = pull_leads(db)
            result.update(push_leads(db))
            print(result)
    finally:
        db.close()


if __name__ == "__main__":
    main()
