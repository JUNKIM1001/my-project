"""IPO分析API: 1社の抽出結果取得と横断ベンチマーク集計。

test_smoke の一時SQLite + TestClient フィクスチャを流用する（ローカルDB・本番には触れない）。
"""

import json

from test_smoke import client  # noqa: F401  fixture


def _login(client):
    r = client.post("/api/login", json={"username": "test", "password": "test-pass-123"})
    assert r.status_code == 200


def _seed_ipo(company_id):
    import app.db as app_db
    from app.models import IpoAnalysis
    db = app_db.SessionLocal()
    row = db.query(IpoAnalysis).filter(IpoAnalysis.company_id == company_id).first() or IpoAnalysis(company_id=company_id)
    row.code, row.listing_date, row.market = "999A", "2026-01-15", "グロース"
    row.source_pdf = "https://www.jpx.co.jp/x/1s.pdf"
    row.analysis_json = json.dumps({
        "shareholder_summary": {"founders_pct": 30.5, "vc_pct": 25.0, "corporate_pct": 10.0, "top10_pct": 80.0},
        "shareholders": [{"name": "創業 太郎", "category": "創業者", "shares": 100, "pct": 30.5}],
        "capital_history": [{"date": "2020-01-01", "event": "設立", "shares": 100}],
        "derived": {"rounds_count": 3, "price_multiple_first_to_last_est": 4.2, "years_founding_to_ipo": 6.0},
        "ipo_terms": {"offer_price_yen": 1000, "raised_total_yen": 5000000000},
        "financials": [{"fiscal_year": "2025-03", "revenue_myen": 1200, "net_income_myen": -50, "employees": 80}],
        "stock_options": {"potential_pct": 8.0},
    }, ensure_ascii=False)
    row.extracted_at = "2026-08-18T00:00:00+09:00"
    row.model = "test"
    db.add(row)
    db.commit()
    db.close()


def test_ipo_detail_404_without_analysis(client):
    _login(client)
    r = client.get("/api/companies/2/ipo")
    assert r.status_code == 404


def test_ipo_detail_and_summary(client):
    _login(client)
    _seed_ipo(1)
    r = client.get("/api/companies/1/ipo")
    assert r.status_code == 200
    d = r.json()
    assert d["code"] == "999A" and d["listing_date"] == "2026-01-15"
    assert d["analysis"]["shareholder_summary"]["founders_pct"] == 30.5
    assert d["analysis"]["shareholders"][0]["category"] == "創業者"

    s = client.get("/api/ipo/summary")
    assert s.status_code == 200
    body = s.json()
    assert body["count"] == 1
    item = body["items"][0]
    assert item["company_id"] == 1 and item["founder_pct"] == 30.5 and item["rounds_count"] == 3
    assert item["revenue_myen"] == 1200 and item["raised_total_yen"] == 5000000000
    b = body["benchmarks"]
    assert b["founder_pct"]["median"] == 30.5 and b["founder_pct"]["n"] == 1
    assert b["years_to_ipo"]["median"] == 6.0
    # 値が無い指標は None（欠損で落ちない）
    assert b["so_pct"]["median"] == 8.0


def test_ipo_endpoints_require_auth(client):
    client.cookies.clear()
    assert client.get("/api/ipo/summary").status_code == 401
    assert client.get("/api/companies/1/ipo").status_code == 401
