"""Vercel サーバレス関数のエントリポイント。全リクエストをFastAPIアプリに委譲する。"""

from app.main import app  # noqa: F401  (Vercelは `app` というASGI変数を検出する)
