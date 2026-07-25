"""Vercel サーバレス関数のエントリポイント。全リクエストをFastAPIアプリに委譲する。"""

import os
import sys

# api/ 配下から実行されるため、プロジェクトルート（app/ の親）を import パスに加える
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app  # noqa: E402,F401  (Vercelは `app` というASGI変数を検出する)
