"""Google Sheets への接続（サービスアカウント認証）。

必要な環境変数:
  GOOGLE_SERVICE_ACCOUNT_FILE ... サービスアカウントの鍵JSONのパス
  LEADS_SPREADSHEET_ID        ... 同期先スプレッドシートのID（URLの /d/ と /edit の間）
  LEADS_WORKSHEET_NAME        ... ワークシート名（省略時: 有効リード）

セットアップ手順は docs/sheets-lead-management.md を参照。
"""
import os

DEFAULT_WORKSHEET = "有効リード"
SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]


class SheetsConfigError(RuntimeError):
    pass


def get_config() -> dict:
    sa_file = os.environ.get("GOOGLE_SERVICE_ACCOUNT_FILE", "").strip()
    spreadsheet_id = os.environ.get("LEADS_SPREADSHEET_ID", "").strip()
    worksheet = os.environ.get("LEADS_WORKSHEET_NAME", "").strip() or DEFAULT_WORKSHEET
    return {
        "service_account_file": sa_file,
        "spreadsheet_id": spreadsheet_id,
        "worksheet": worksheet,
        "url": f"https://docs.google.com/spreadsheets/d/{spreadsheet_id}" if spreadsheet_id else None,
        "configured": bool(sa_file and spreadsheet_id),
    }


def open_worksheet():
    """設定に従ってワークシートを開く。無ければ作成する。"""
    cfg = get_config()
    if not cfg["service_account_file"]:
        raise SheetsConfigError(".env に GOOGLE_SERVICE_ACCOUNT_FILE を設定してください")
    if not os.path.exists(cfg["service_account_file"]):
        raise SheetsConfigError(f"サービスアカウント鍵が見つかりません: {cfg['service_account_file']}")
    if not cfg["spreadsheet_id"]:
        raise SheetsConfigError(".env に LEADS_SPREADSHEET_ID を設定してください")

    import gspread
    from google.oauth2.service_account import Credentials

    creds = Credentials.from_service_account_file(cfg["service_account_file"], scopes=SCOPES)
    gc = gspread.authorize(creds)
    spreadsheet = gc.open_by_key(cfg["spreadsheet_id"])
    try:
        ws = spreadsheet.worksheet(cfg["worksheet"])
    except gspread.WorksheetNotFound:
        ws = spreadsheet.add_worksheet(title=cfg["worksheet"], rows=200, cols=20)
    return ws
