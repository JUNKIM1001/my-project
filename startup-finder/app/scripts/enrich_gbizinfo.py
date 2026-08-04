"""gBizINFO REST APIで全社の公的情報を付与するバッチ（冪等）。

- 法人名で検索→正規化名の完全一致で法人番号を特定（曖昧一致はスキップして報告）
- 基本情報(資本金/従業員数/設立)＋補助金＋特許＋表彰＋届出認定を取得
- 取得済み（gbiz_updatedあり）の社はスキップ。--refresh で再取得
- 空欄のみ埋める方針（既存の手動調査値を上書きしない）。ただしgbiz専用列は毎回更新

usage:
  GBIZINFO_API_TOKEN=... .venv/bin/python -m app.scripts.enrich_gbizinfo [--limit N] [--refresh]
"""

import argparse
import json
import os
import re
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
from datetime import date

from app.db import SessionLocal
from app.models import Company

BASE = "https://info.gbiz.go.jp/hojin/v1/hojin"
TOKEN = os.environ.get("GBIZINFO_API_TOKEN", "").strip()
SLEEP = 0.15  # 全体で毎秒数リクエスト程度に抑える


def norm(name):
    # NFKC: 登記名の全角英数（株式会社ＳｍａｒｔＨＲ等）を半角に畳んで比較する
    n = unicodedata.normalize("NFKC", name or "")
    n = re.sub(r"[（(].*?[）)]", "", n)
    n = re.sub(r"(株式会社|合同会社|有限会社|,\s*Inc\.?|Inc\.?)", "", n)
    n = re.sub(r"[\s　・．.,、。－\-–—]", "", n)
    return n.lower()


def api_get(path, params=None):
    url = BASE + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"X-hojinInfo-api-token": TOKEN})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=30) as res:
                return json.loads(res.read())
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return None
            if e.code in (429, 500, 502, 503) and attempt < 2:
                time.sleep(3 * (attempt + 1))
                continue
            raise
        except (TimeoutError, OSError):
            if attempt < 2:
                time.sleep(3)
                continue
            raise


def find_corporate_number(name):
    """法人名検索。正規化名の完全一致のみ採用（別会社への誤紐付けを避ける）。"""
    d = api_get("", {"name": name, "limit": "10"})
    infos = (d or {}).get("hojin-infos") or []
    target = norm(name)
    hits = [h for h in infos if norm(h.get("name")) == target]
    if len(hits) == 1:
        return hits[0]
    if len(hits) > 1:
        # 完全一致が複数＝同名法人。所在地情報なしでは断定できないため見送り
        return "ambiguous"
    return None


def yen_to_oku(v):
    try:
        return round(float(v) / 1e8, 2) or None
    except (TypeError, ValueError):
        return None


def enrich(c, basic, subsidy, patent, commend, cert):
    info = (basic or {}).get("hojin-infos", [{}])
    info = info[0] if info else {}
    c.corporate_number = info.get("corporate_number") or c.corporate_number
    c.capital_oku = yen_to_oku(info.get("capital_stock")) or c.capital_oku
    if not c.employee_count and info.get("employee_number"):
        try:
            c.employee_count = int(info["employee_number"])
        except (TypeError, ValueError):
            pass
    if not c.founded_year and info.get("date_of_establishment"):
        m = re.match(r"(\d{4})", info["date_of_establishment"])
        if m:
            c.founded_year = int(m.group(1))
    if not c.hq and info.get("location"):
        c.hq = info["location"]
    if not c.representative and info.get("representative_name"):
        c.representative = re.sub(r"[\s　]+", "", info["representative_name"])
    if not c.website and info.get("company_url"):
        c.website = info["company_url"]

    def items(d, key):
        arr = (d or {}).get("hojin-infos", [{}])
        return (arr[0] if arr else {}).get(key) or []

    subs = items(subsidy, "subsidy")
    pats = items(patent, "patent")
    comms = items(commend, "commendation")
    # 全省庁統一資格の等級（物品の製造：B等）は分析価値が薄いため除外
    certs = [x for x in items(cert, "certification")
             if not str(x.get("title", "")).startswith("物品の製造")]
    c.subsidy_count = len(subs) or None
    c.patent_count = len(pats) or None
    detail = {
        "subsidies": [{"title": s.get("title"), "amount": s.get("amount"),
                       "date": s.get("date_of_approval"), "gov": s.get("government_departments")}
                      for s in subs[:15]],
        "commendations": [{"title": x.get("title"), "target": x.get("target"),
                           "date": x.get("date_of_commendation")} for x in comms[:10]],
        "certifications": [{"title": x.get("title"), "date": x.get("date_of_approval")}
                           for x in certs[:10]],
    }
    c.gbiz_json = json.dumps(detail, ensure_ascii=False) if (subs or comms or certs) else None
    c.gbiz_updated = date.today().isoformat()


def main():
    if not TOKEN:
        sys.exit("GBIZINFO_API_TOKEN を環境変数で指定してください")
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=0, help="処理社数の上限（テスト用）")
    ap.add_argument("--refresh", action="store_true", help="取得済みも再取得")
    args = ap.parse_args()

    db = SessionLocal()
    q = db.query(Company).order_by(Company.id)
    companies = [c for c in q.all() if args.refresh or not c.gbiz_updated]
    if args.limit:
        companies = companies[:args.limit]
    print(f"対象: {len(companies)}社")

    done = matched = ambiguous = notfound = 0
    for c in companies:
        try:
            hit = find_corporate_number(c.name)
            time.sleep(SLEEP)
            if hit == "ambiguous":
                ambiguous += 1
                c.gbiz_updated = date.today().isoformat() + " (同名複数のためスキップ)"
            elif hit is None:
                notfound += 1
                c.gbiz_updated = date.today().isoformat() + " (未登録)"
            else:
                cn = hit.get("corporate_number")
                basic = api_get(f"/{cn}") or {"hojin-infos": [hit]}; time.sleep(SLEEP)
                subsidy = api_get(f"/{cn}/subsidy"); time.sleep(SLEEP)
                patent = api_get(f"/{cn}/patent"); time.sleep(SLEEP)
                commend = api_get(f"/{cn}/commendation"); time.sleep(SLEEP)
                cert = api_get(f"/{cn}/certification"); time.sleep(SLEEP)
                enrich(c, basic, subsidy, patent, commend, cert)
                matched += 1
        except Exception as e:
            print(f"  ERROR {c.name}: {e}")
        done += 1
        if done % 25 == 0:
            db.commit()
            print(f"  {done}/{len(companies)} 完了 (一致{matched}/同名複数{ambiguous}/未登録{notfound})")
    db.commit()
    print(f"完了: {done}社 / 法人番号一致{matched} / 同名複数{ambiguous} / gBiz未登録{notfound}")
    db.close()


if __name__ == "__main__":
    main()
