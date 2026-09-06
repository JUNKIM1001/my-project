"""IPO企業のⅠの部（JPX公開PDF）から株主構成・資本政策・戦略を構造化抽出する。

前提: data/ipo_docs/db_match.json（build: JPXカタログとDBのIPO企業の照合結果）
流れ: PDF取得(キャッシュ) → pypdfでテキスト化 → 見出しで必要セクションを切り出し
      → Gemini で構造化JSON → ipo_analysis テーブルへ保存（1社1行・再実行で上書き）

usage:
  DATABASE_URL="" GEMINI_API_KEY=... .venv/bin/python -m app.scripts.ipo_extract [--code 593A] [--limit N] [--refresh]
"""

import argparse
import json
import os
import re
import sys
import time
import urllib.request
from datetime import datetime

from pypdf import PdfReader

from app.analysis import _extract_json
from app.db import BASE_DIR, Base, SessionLocal, engine
from app.models import Company, IpoAnalysis

DOC_DIR = os.path.join(BASE_DIR, "data", "ipo_docs")
MATCH = os.path.join(DOC_DIR, "db_match.json")
MODEL = "gemini-flash-latest"

SYSTEM_PROMPT = """あなたは日本のIPO実務に精通したアナリストです。渡されるのは、ある会社の
「新規上場申請のための有価証券報告書（Ⅰの部）」および「新規上場会社概要」から抜粋したテキストです。
ここから資本政策と株主構成を復元し、次のスキーマのJSONだけを ```json ブロックで返してください。

ルール:
- 記載されている数値のみを使う。推定値はキー名に _est を付け、根拠を note に書く
- 金額は円（整数）、株数は株（整数）、比率は%（小数1桁）
- 株主の category は 創業者/経営陣/VC/CVC・事業会社/金融機関/大学・公的/従業員・SO/その他 から選ぶ
  （※の注記「当社代表取締役」「大株主上位10名」等と名称から判断。投資事業有限責任組合はVC、事業会社名はCVC・事業会社）
- capital_history は「発行済株式総数、資本金等の推移」と「第三者割当等の概況」「沿革」を統合し、設立から上場申請までの
  全ての発行・分割・転換を日付順に並べる。price_per_share_yen は発行価格が明記されていればそれを、無ければ
  (資本金増加額+資本準備金増加額)/発行株数 で算出して price_per_share_yen_est に入れる
- post_money_yen_est = price_per_share × その時点の発行済株式総数（分割は調整）。算出できない場合は null
- 発行株数が0またはnullの行（期末残高だけの行・「共通」等）は capital_history に入れない
- 上場申請までに株式分割が行われている場合、capital_history の shares / price_per_share_yen(_est) / post_shares_total は
  すべて分割後基準に換算して揃える（例: 1株→5株分割なら分割前の10,000円は2,000円、株数は5倍）。company.split_ratio_total に
  累積分割倍率、各行の note に「分割前 10,000円」のように原記載を残す。derived の価格倍率も換算後の値で計算する
- IPO条件（公開価格・吸収金額・主幹事）は「新規上場会社概要」を第一に、無ければ「当DB既収録のIPO条件メモ」から採り、
  メモ由来の場合は note に「DBメモ由来（報道ベース）」と書く
- 特別利害関係者等の株式等の移動状況（既存株主間の売買）は secondary_transfers に入れる
- 経営方針・成長戦略・KSF・リスクは原文の趣旨を各60字以内に要約

{
 "company": {"name": "", "listing_date": "YYYY-MM-DD", "market": "", "fiscal_year_end_month": 9, "split_ratio_total": 1},
 "ipo_terms": {"offer_price_yen": null, "shares_offered_new": null, "shares_offered_secondary": null,
               "raised_total_yen": null, "market_cap_at_ipo_yen_est": null, "lead_underwriter": null, "note": ""},
 "shareholders": [{"name": "", "category": "", "shares": 0, "pct": 0.0, "potential_shares": null, "attributes": ""}],
 "shareholder_summary": {"founders_pct": 0.0, "management_pct": 0.0, "vc_pct": 0.0, "corporate_pct": 0.0,
                         "financial_pct": 0.0, "employee_so_pct": 0.0, "other_pct": 0.0, "top10_pct": 0.0},
 "capital_history": [{"date": "YYYY-MM-DD", "event": "設立|第三者割当|株式分割|転換|SO発行|その他", "share_class": "",
                      "shares": 0, "price_per_share_yen": null, "price_per_share_yen_est": null, "amount_yen": null,
                      "post_shares_total": null, "post_money_yen_est": null, "investors": [], "note": ""}],
 "secondary_transfers": [{"date": "", "from": "", "to": "", "shares": 0, "price_per_share_yen": null, "reason": ""}],
 "stock_options": {"potential_shares": null, "potential_pct": null, "note": ""},
 "financials": [{"fiscal_year": "", "revenue_myen": null, "ordinary_income_myen": null, "net_income_myen": null,
                 "equity_myen": null, "total_assets_myen": null, "employees": null}],
 "strategy": {"business_summary": "", "mission": "", "growth_strategy": [], "ksf": [], "risks": [], "use_of_proceeds": ""},
 "derived": {"founder_pct_at_ipo": null, "vc_pct_at_ipo": null, "rounds_count": null,
             "first_round_price_yen": null, "last_round_price_yen": null, "price_multiple_first_to_last_est": null,
             "years_founding_to_ipo": null},
 "page_refs": {"shareholders": "", "capital_history": "", "financials": "", "strategy": ""},
 "quality_note": "抽出上の注意・欠損"
}"""


def pdf_text_pages(path):
    r = PdfReader(path)
    return [(pg.extract_text() or "") for pg in r.pages]


def body_index(full, kw, start=0):
    """目次（点線が続く行）を飛ばして本文の見出し位置を返す。無ければ -1。"""
    while True:
        i = full.find(kw, start)
        if i < 0:
            return -1
        if "…" not in full[i:i + 150]:
            return i
        start = i + 1


def slice_section(full, kw, max_chars, stop_kws=()):
    i = body_index(full, kw)
    if i < 0:
        return ""
    end = i + max_chars
    for s in stop_kws:
        j = body_index(full, s, i + len(kw))
        if 0 <= j < end:
            end = j
    return full[i:end]


def build_context(pages, outline_text, db_note=""):
    full = "\n".join(pages)
    parts = []
    parts.append("### 新規上場会社概要（JPX）\n" + outline_text[:6000])
    if db_note:
        parts.append("### 当DB既収録のIPO条件メモ（報道ベース・概要PDFに無い場合の補助情報）\n" + db_note[:1000])
    parts.append("### 主要な経営指標等の推移\n" + slice_section(full, "【主要な経営指標等の推移】", 3500))
    parts.append("### 沿革\n" + slice_section(full, "【沿革】", 3500, ("【事業の内容】",)))
    parts.append("### 事業の内容\n" + slice_section(full, "【事業の内容】", 4000, ("【関係会社の状況】",)))
    parts.append("### 経営方針、経営環境及び対処すべき課題等\n" + slice_section(full, "【経営方針、経営環境及び対処すべき課題等】", 7000, ("【事業等のリスク】",)))
    parts.append("### 事業等のリスク（冒頭）\n" + slice_section(full, "【事業等のリスク】", 3000))
    parts.append("### 発行済株式総数、資本金等の推移\n" + slice_section(full, "【発行済株式総数、資本金等の推移】", 6000, ("【所有者別状況】",)))
    parts.append("### ストックオプション制度の内容\n" + slice_section(full, "【ストックオプション制度の内容】", 3000, ("【ライツプラン", "【その他の新株予約権")))
    # 第四部【株式公開情報】は本文開始ページから末尾（監査報告書手前）まで
    start_pg = next((k for k, t in enumerate(pages) if "第四部" in t and "株式公開情報" in t and "…" not in t[:400]), None)
    if start_pg is not None:
        p4 = "\n".join(pages[start_pg:])
        j = body_index(p4, "監査報告書")
        if j > 2000:
            p4 = p4[:j]
        parts.append("### 第四部 株式公開情報（特別利害関係者等の株式等の移動状況・第三者割当等の概況・株主の状況）\n" + p4[:70000])
    return "\n\n".join(parts)


def download(url, path):
    if os.path.exists(path) and os.path.getsize(path) > 10000:
        return path
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=60) as res, open(path, "wb") as f:
        f.write(res.read())
    return path


def gemini_extract(context):
    from google import genai
    from google.genai import errors as genai_errors
    from google.genai import types
    client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
    last = None
    for wait in (0, 10, 30):
        if wait:
            time.sleep(wait)
        try:
            res = client.models.generate_content(
                model=MODEL, contents=context,
                config=types.GenerateContentConfig(system_instruction=SYSTEM_PROMPT, temperature=0.1),
            )
            return _extract_json(res.text or "")
        except genai_errors.ServerError as e:
            last = e
            continue
    raise RuntimeError("Gemini混雑: %s" % last)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--code", help="証券コードで1社指定（例 593A）")
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--refresh", action="store_true")
    a = ap.parse_args()
    if not os.environ.get("GEMINI_API_KEY"):
        sys.exit("GEMINI_API_KEY が必要です")
    Base.metadata.create_all(bind=engine, tables=[IpoAnalysis.__table__])
    os.makedirs(DOC_DIR, exist_ok=True)
    targets = json.load(open(MATCH, encoding="utf-8"))
    if a.code:
        targets = [t for t in targets if t["code"] == a.code]
    db = SessionLocal()
    done = {r.company_id for r in db.query(IpoAnalysis).all()}
    if not a.refresh:
        targets = [t for t in targets if t["company_id"] not in done]
    if a.limit:
        targets = targets[:a.limit]
    print(f"対象 {len(targets)}社")
    ok = err = 0
    for t in targets:
        try:
            pdf = download(t["ichi_pdf"], os.path.join(DOC_DIR, f'{t["code"]}_1s.pdf'))
            pages = pdf_text_pages(pdf)
            outline = ""
            if t.get("outline_pdf"):
                try:
                    outline = "\n".join(pdf_text_pages(download(t["outline_pdf"], os.path.join(DOC_DIR, f'{t["code"]}_outline.pdf'))))
                except Exception:
                    outline = ""
            comp = db.query(Company).get(t["company_id"])
            ctx = build_context(pages, outline, (comp.status_note or "") if comp else "")
            data = gemini_extract(ctx)
            data["capital_history"] = [r for r in (data.get("capital_history") or [])
                                       if (r.get("shares") or 0) > 0 or r.get("event") == "設立"]
            row = db.query(IpoAnalysis).filter(IpoAnalysis.company_id == t["company_id"]).first() or IpoAnalysis(company_id=t["company_id"])
            row.code, row.listing_date, row.market = t["code"], t["listing_date"], t.get("market")
            row.source_pdf, row.outline_pdf = t["ichi_pdf"], t.get("outline_pdf")
            row.analysis_json = json.dumps(data, ensure_ascii=False)
            row.extracted_at = datetime.now().astimezone().isoformat(timespec="seconds")
            row.model = MODEL
            db.add(row); db.commit()
            sh = data.get("shareholders") or []; ch = data.get("capital_history") or []
            print(f"  OK {t['name']} ({t['code']}) pages={len(pages)} ctx={len(ctx)}字 株主{len(sh)} 資本政策{len(ch)}件")
            ok += 1
        except Exception as e:
            print(f"  ERROR {t['name']} ({t['code']}): {e}")
            err += 1
            db.rollback()
        time.sleep(1)
    print(f"完了: 成功{ok} / 失敗{err} / 保存済み合計 {db.query(IpoAnalysis).count()}")


if __name__ == "__main__":
    main()
