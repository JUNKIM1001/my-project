"""Vercel サーバレス関数のエントリポイント。全リクエストをFastAPIアプリに委譲する。

Vercelのrewriteは環境によって「元のパス」ではなく書き換え先(/api/index)を
関数に渡すことがあるため、rewrite側で __orig_path クエリに元パスを埋め、
ここで復元してからFastAPIへ渡す（パラメータが無ければ何もしない後方互換）。
"""

import os
import sys
from urllib.parse import parse_qsl, unquote, urlencode

# api/ 配下から実行されるため、プロジェクトルート（app/ の親）を import パスに加える
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app as _fastapi_app  # noqa: E402


async def app(scope, receive, send):
    if scope.get("type") == "http":
        pairs = parse_qsl(scope.get("query_string", b"").decode("utf-8", "replace"),
                          keep_blank_values=True)
        orig = None
        rest = []
        for k, v in pairs:
            if k == "__orig_path":
                orig = v
            else:
                rest.append((k, v))
        if orig is not None:
            scope = dict(scope)
            scope["path"] = unquote(orig) or "/"
            scope["raw_path"] = scope["path"].encode("utf-8")
            scope["query_string"] = urlencode(rest).encode("utf-8")
    await _fastapi_app(scope, receive, send)
