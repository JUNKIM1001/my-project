"""スモークテスト: 認証・検索・ページング・ログ・総当たり対策の基本動作。

一時SQLiteに最小データを投入して回すので、ローカルDBにも本番にも触れない。
usage: .venv/bin/python -m pytest tests/ -q
"""

import importlib
import os
import sys
import tempfile

import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


@pytest.fixture(scope="session")
def client():
    from fastapi.testclient import TestClient

    # アプリ本体のDBを一時ファイルに差し替えてからimportする
    tmp = tempfile.mkdtemp()
    os.environ.pop("DATABASE_URL", None)
    import app.db as app_db
    importlib.reload(app_db)
    app_db.DB_PATH = os.path.join(tmp, "test.db")
    app_db.engine = app_db.create_engine(
        "sqlite:///" + app_db.DB_PATH, connect_args={"check_same_thread": False})
    app_db.SessionLocal.configure(bind=app_db.engine)

    import app.main as app_main
    importlib.reload(app_main)

    # 最小データ投入
    from app.auth import hash_password
    from app.models import Company, User
    db = app_db.SessionLocal()
    db.add(User(username="test", display_name="テスト", password_hash=hash_password("test-pass-123")))
    for i, (name, raised, val) in enumerate([
        ("株式会社Alpha", 100.0, 500.0),
        ("株式会社Beta", 50.0, None),
        ("株式会社Gamma", None, None),
    ], start=1):
        db.add(Company(id=i, name=name, description="テスト企業%d" % i,
                       sectors="AI,SaaS", status="active",
                       total_raised_oku=raised, valuation_oku=val))
    db.commit()
    db.close()

    with TestClient(app_main.app) as c:
        yield c


def login(client):
    r = client.post("/api/login", json={"username": "test", "password": "test-pass-123"})
    assert r.status_code == 200
    return r


def test_requires_auth(client):
    assert client.get("/api/companies").status_code == 401


def test_login_and_me(client):
    login(client)
    me = client.get("/api/me")
    assert me.status_code == 200 and me.json()["username"] == "test"


def test_list_pagination_and_sort(client):
    login(client)
    r = client.get("/api/companies?limit=2&offset=0")
    d = r.json()
    assert d["count"] == 3 and len(d["items"]) == 2 and d["has_more"] is True
    r2 = client.get("/api/companies?limit=2&offset=2")
    d2 = r2.json()
    assert len(d2["items"]) == 1 and d2["has_more"] is False
    # 重複なし
    ids = [i["id"] for i in d["items"]] + [i["id"] for i in d2["items"]]
    assert len(set(ids)) == 3
    # nullslast: 調達額降順の先頭はAlpha、末尾（3件目）は調達額nullのGamma
    assert d["items"][0]["name"] == "株式会社Alpha"
    assert d2["items"][0]["name"] == "株式会社Gamma"


def test_search_and_filter(client):
    login(client)
    assert client.get("/api/companies?q=alpha").json()["count"] == 1  # 大文字小文字無視
    assert client.get("/api/companies?has_valuation=true").json()["count"] == 1
    assert client.get("/api/companies?sort=meeting_date").status_code == 422  # 削除済みソート


def test_detail_and_404(client):
    login(client)
    assert client.get("/api/companies/1").json()["name"] == "株式会社Alpha"
    assert client.get("/api/companies/999").status_code == 404


def test_meta(client):
    login(client)
    m = client.get("/api/meta").json()
    assert m["total"] == 3 and m["with_valuation"] == 1
    assert "with_meeting" not in m  # 削除済み機能のキーが復活していないこと


def test_access_log_and_summary(client):
    login(client)
    client.get("/api/companies?q=%E7%94%9F%E6%88%90AI")  # 生成AI
    logs = client.get("/api/logs?action=search").json()
    assert logs["count"] >= 1
    row = logs["items"][0]
    assert row["ip"] and row["ts"] and row["result_count"] is not None
    sm = client.get("/api/logs/summary").json()
    assert sm["total"] >= 1 and "top_companies" in sm and "zero_hit_keywords" in sm


def test_csv_exports(client):
    login(client)
    csv_text = client.get("/api/export.csv").text
    assert "企業名" in csv_text and "面談日" not in csv_text
    log_csv = client.get("/api/logs/export.csv").text
    assert "キーワード・内容" in log_csv


def test_bruteforce_block(client):
    headers = {"X-Forwarded-For": "203.0.113.200"}
    for _ in range(5):
        r = client.post("/api/login", headers=headers,
                        json={"username": "test", "password": "wrong"})
        assert r.status_code == 401
    r = client.post("/api/login", headers=headers,
                    json={"username": "test", "password": "wrong"})
    assert r.status_code == 429
    # 正しいパスワードでも同一IPはブロック
    r = client.post("/api/login", headers=headers,
                    json={"username": "test", "password": "test-pass-123"})
    assert r.status_code == 429
    # 別IPは通る
    r = client.post("/api/login", headers={"X-Forwarded-For": "203.0.113.201"},
                    json={"username": "test", "password": "test-pass-123"})
    assert r.status_code == 200
