"""有効リード（review_status=承認 の事業会社）と Google スプレッドシートの双方向同期。

役割分担:
  - アプリ所有列（候補情報）: DBが正。push でシートへ上書きする。
  - 人間所有列（営業管理）  : シートが正。pull でDBへ取り込む。

シート上の行は DB の ID 列をキーに突合する。push はシート既存行の
人間所有列を保持したまま候補情報だけを更新し、リード化解除された行や
手で追加された行は消さない。

CLI:
  python -m app.sheets.sync setup   # ヘッダー行・商談ステージのプルダウンを整備
  python -m app.sheets.sync push    # DB → シート（有効リードを反映）
  python -m app.sheets.sync pull    # シート → DB（営業管理列を取り込み）
  python -m app.sheets.sync sync    # pull してから push（cron向け）
"""
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models import Company

# ヘッダー定義。前半がアプリ所有列（DBが正）、以降が人間所有列（シートが正）。
APP_COLUMNS = [
    "ID", "企業名", "業界", "事業内容", "規模", "有望度",
    "想定ニーズ", "提案ポイント", "ニーズの根拠", "Webサイト", "問い合わせ先",
    "想定キーパーソン", "リード登録日",
]
HUMAN_COLUMNS = ["商談ステージ", "担当者", "次アクション", "期日", "メモ"]
HEADERS = APP_COLUMNS + HUMAN_COLUMNS

STAGE_CHOICES = ["未着手", "アプローチ中", "初回接触済み", "商談中", "提案済み", "交渉中", "受注", "失注", "保留"]
DEFAULT_STAGE = "未着手"


def qualified_leads(db: Session):
    """有効リード＝承認済みの事業会社。有望度の高い順。"""
    return (
        db.query(Company)
        .filter(Company.review_status == "承認")
        .order_by(Company.score.desc().nullslast(), Company.name)
        .all()
    )


def company_to_app_values(c: Company) -> list:
    """アプリ所有列のセル値を組み立てる（純粋関数・テスト可能）。"""
    registered = ""
    if c.lead_registered_at:
        registered = c.lead_registered_at.strftime("%Y-%m-%d")
    return [
        str(c.id),
        c.name or "",
        c.industry or "",
        c.business or "",
        c.employee_scale or "",
        str(c.score) if c.score is not None else "",
        " / ".join((c.needs or "").split(",")),
        " / ".join((c.proposal_points or "").split(",")),
        c.needs_evidence or "",
        c.website or "",
        c.contact_url or "",
        c.key_person_hint or "",
        registered,
    ]


def company_to_human_values(c: Company) -> list:
    return [
        c.status or DEFAULT_STAGE,
        c.owner or "",
        c.next_action or "",
        c.next_action_due or "",
        c.lead_memo or "",
    ]


def _pad(row: list, length: int) -> list:
    return (row + [""] * length)[:length]


def merge_rows(existing_rows: list, leads: list) -> list:
    """シートの既存行と現在の有効リードをマージした新しいグリッドを返す。

    - 既存行はIDで突合し、アプリ所有列だけを最新化（人間所有列は保持）
    - シートに無いリードは末尾に追加（商談ステージは未着手）
    - リード化解除・手動追加の行はそのまま残す
    """
    n_app, n_all = len(APP_COLUMNS), len(HEADERS)
    leads_by_id = {str(c.id): c for c in leads}
    out = [list(HEADERS)]
    seen = set()

    for raw in existing_rows:
        row = _pad(list(raw), n_all)
        c = leads_by_id.get(row[0].strip())
        if c is not None:
            row = company_to_app_values(c) + row[n_app:]
            if not row[n_app].strip():
                row[n_app] = DEFAULT_STAGE
            seen.add(str(c.id))
        out.append(_pad(row, n_all))

    for c in leads:
        if str(c.id) not in seen:
            out.append(company_to_app_values(c) + company_to_human_values(c))
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
    for c in leads:
        c.sheet_synced_at = now
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
        c = db.query(Company).filter(Company.id == int(row[0])).first()
        if c is None:
            continue
        stage, owner, next_action, due, memo = (v.strip() for v in row[n_app:n_all])
        c.status = stage or c.status
        c.owner = owner or None
        c.next_action = next_action or None
        c.next_action_due = due or None
        c.lead_memo = memo or None
        c.sheet_synced_at = now
        updated += 1
    db.commit()
    return {"pulled": updated}


def setup_sheet(ws=None) -> dict:
    """ヘッダー行の整備・固定と、商談ステージ列のプルダウン設定。"""
    from app.sheets.client import open_worksheet

    ws = ws or open_worksheet()
    ws.update([HEADERS], "A1")
    ws.freeze(rows=1)

    stage_col = len(APP_COLUMNS)  # 0-indexed
    ws.spreadsheet.batch_update({
        "requests": [{
            "setDataValidation": {
                "range": {
                    "sheetId": ws.id,
                    "startRowIndex": 1,
                    "startColumnIndex": stage_col,
                    "endColumnIndex": stage_col + 1,
                },
                "rule": {
                    "condition": {
                        "type": "ONE_OF_LIST",
                        "values": [{"userEnteredValue": s} for s in STAGE_CHOICES],
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
