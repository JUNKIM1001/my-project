"""JPX「新規上場会社情報」からⅠの部PDFのカタログを作り、DBのIPO企業と照合する。

- 対象: 当年 index.html + 過去アーカイブ（00-archives-01.. を404まで。2026-08時点で2022年分まで存在）
- 出力: data/ipo_docs/jpx_catalog.json（全上場銘柄）/ db_match.json（DBのstatus='ipo'企業との一致）
- 名寄せ: NFKC正規化・（株）/株式会社/ホールディングス除去・「代表者インタビュー」等の付記除去
- 週次タスクから呼ぶ想定（新規IPOがexit追跡でstatus=ipoになった翌週に、ここで照合→ipo_extractへ）

usage:
  DATABASE_URL="" .venv/bin/python -m app.scripts.ipo_catalog
"""

import html
import json
import os
import re
import unicodedata
import urllib.request

from app.db import BASE_DIR, SessionLocal
from app.models import Company

BASE = "https://www.jpx.co.jp"
# 当年 + 過去アーカイブ（00-archives-01, 02, ... と年ごとに増える。404になるまで辿る）
PAGES = ["/listing/stocks/new/index.html"] + [
    "/listing/stocks/new/00-archives-%02d.html" % i for i in range(1, 9)]
DOC_DIR = os.path.join(BASE_DIR, "data", "ipo_docs")


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    return urllib.request.urlopen(req, timeout=30).read().decode("utf-8", "replace")


def clean(cell):
    return html.unescape(re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", cell))).strip()


def norm(name):
    n = unicodedata.normalize("NFKC", name or "")
    n = re.sub(r"(代表者インタビュー|上場会社インタビュー|インタビュー)", "", n)
    n = n.replace("（株）", "").replace("(株)", "").replace("*", "")
    n = re.sub(r"[（(].*?[）)]", "", n)
    n = re.sub(r"(株式会社|ホールディングス|ＨＤ|HD)", "", n)
    return re.sub(r"[\s　・．.,、。－\-–—]", "", n).lower()


def build_catalog():
    catalog = []
    for path in PAGES:
        try:
            page = fetch(BASE + path)
        except Exception as e:
            if "404" in str(e) and "archives" in path:
                break  # アーカイブはここで終わり
            print("fetch error", path, e)
            continue
        cur = None
        for row in re.findall(r"<tr[^>]*>(.*?)</tr>", page, re.S):
            cells = [clean(c) for c in re.findall(r"<td[^>]*>(.*?)</td>", row, re.S)]
            hrefs = re.findall(r'href="([^"]+\.pdf)"', row)
            if not cells:
                continue
            m = re.match(r"(\d{4}/\d{2}/\d{2})", cells[0])
            if m:
                name = re.sub(r"\s*(代表者インタビュー|上場会社インタビュー)\s*$", "", cells[1].replace(" *", "")).strip()
                cur = {"listing_date": m.group(1).replace("/", "-"), "name_jpx": name,
                       "code": cells[2].strip() if len(cells) > 2 else None,
                       "market": None, "outline_pdf": None, "ichi_pdf": None}
                for h in hrefs:
                    if h.endswith("-Outline.pdf"):
                        cur["outline_pdf"] = BASE + h
                catalog.append(cur)
            elif cur is not None:
                if cells[0] and not cur["market"]:
                    cur["market"] = cells[0]
                for h in hrefs:
                    if h.endswith("-1s.pdf"):
                        cur["ichi_pdf"] = BASE + h
    return [c for c in catalog if c["ichi_pdf"]]


def main():
    os.makedirs(DOC_DIR, exist_ok=True)
    catalog = build_catalog()
    json.dump(catalog, open(os.path.join(DOC_DIR, "jpx_catalog.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    by_norm = {}
    for e in catalog:
        by_norm.setdefault(norm(e["name_jpx"]), e)
    db = SessionLocal()
    matched, unmatched = [], []
    for c in db.query(Company).filter(Company.status == "ipo").all():
        e = by_norm.get(norm(c.name))
        if e:
            matched.append({"company_id": c.id, "name": c.name, "code": e["code"], "listing_date": e["listing_date"],
                            "market": e["market"], "ichi_pdf": e["ichi_pdf"], "outline_pdf": e["outline_pdf"]})
        else:
            unmatched.append(c.name)
    json.dump(matched, open(os.path.join(DOC_DIR, "db_match.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("JPXカタログ %d件（Ⅰの部あり）/ DBのIPO企業 一致 %d社・未一致 %d社" % (len(catalog), len(matched), len(unmatched)))
    if unmatched:
        print("未一致（カタログ期間外の可能性）:", unmatched[:10])


if __name__ == "__main__":
    main()
