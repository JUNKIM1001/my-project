"""IPO分析の横断集計: ラウンド別バリュエーション・投資家別の参画とIRR見込み。

入力は ipo_analysis.analysis_json（Ⅰの部のAI抽出）。ここでは事実（届出書記載の
発行価格・株数・引受先・公開価格）から機械的に指標を出す。推定値は _est / 見込み と明示する。
"""

import json
import re
import unicodedata
from datetime import date

ROUND_ORDER = ["シード", "シリーズA", "シリーズB", "シリーズC", "シリーズD", "シリーズE+", "普通株(追加)"]

# 投資家名の正規化: ファンド名 → 運用会社名（主要どころは別名表を優先）
INVESTOR_ALIASES = [
    (r"^ジャフコ", "ジャフコ"), (r"^グロービス", "グロービス・キャピタル・パートナーズ"),
    (r"^(DNX|ＤＮＸ)", "DNX Ventures"), (r"^(Coral|コーラル)", "Coral Capital"), (r"^ANRI", "ANRI"),
    (r"^(JIC|ＪＩＣ)", "JIC（産業革新投資機構）"), (r"^三菱UFJキャピタル|^三菱ＵＦＪキャピタル", "三菱UFJキャピタル"),
    (r"^SMBCベンチャー|^ＳＭＢＣベンチャー", "SMBCベンチャーキャピタル"), (r"^みずほキャピタル", "みずほキャピタル"),
    (r"^SBI|^ＳＢＩ", "SBIインベストメント"), (r"^グローバル・ブレイン|^グローバルブレイン", "グローバル・ブレイン"),
    (r"^31VENTURES|^３１VENTURES|^31 ?VENTURES", "31VENTURES（三井不動産）"), (r"^東京大学エッジキャピタル|^UTEC|^ＵＴＥＣ", "UTEC"),
    (r"^Beyond Next|^BNV", "Beyond Next Ventures"), (r"^インキュベイトファンド", "インキュベイトファンド"),
    (r"^East Ventures", "East Ventures"), (r"^Eight Roads", "Eight Roads"), (r"^WiL|^ＷｉＬ", "WiL"),
    (r"^DBJキャピタル|^ＤＢＪキャピタル", "DBJキャピタル"), (r"^大和企業投資|^大和ベンチャー|^大和ＰＩ", "大和企業投資"),
    (r"^Salesforce|^セールスフォース", "Salesforce Ventures"), (r"^DCM|^ＤＣＭ", "DCM Ventures"),
    (r"^Angel Bridge|^エンジェルブリッジ", "Angel Bridge"), (r"^THE FUND|^ＴＨＥ ＦＵＮＤ", "THE FUND（三井住友海上／千葉道場）"),
    (r"^日本グロースキャピタル", "日本グロースキャピタル投資法人"), (r"^KDDI|^ＫＤＤＩ", "KDDI"), (r"^NTT|^ＮＴＴ", "NTTグループ"),
    (r"^Sony|^ソニー", "ソニーグループ"), (r"^Z Venture|^ZVC|^ＺＶＣ", "Z Venture Capital"),
]
VC_PAT = re.compile(r"投資事業|ベンチャー|Ventures?|キャピタル|Capital|Partners|パートナーズ|ファンド|Fund|投資法人|インベストメント|Investment|投資組合|LLC|L\.P\.|ＬＬＣ", re.I)
CORP_PAT = re.compile(r"株式会社|合同会社|銀行|保険|信託|Inc\.|Corp|Co\.,|ホールディングス|Holdings|証券", re.I)


def norm_investor(raw):
    """引受先の表記 → (正規化名, 種別)。種別: VC / CVC・事業会社 / 金融機関 / 個人 / その他。'他'等は None。"""
    if not raw:
        return None
    s = unicodedata.normalize("NFKC", str(raw)).strip()
    if s in ("他", "その他", "-", "－", "ほか") or len(s) < 2:
        return None
    for pat, canon in INVESTOR_ALIASES:
        if re.search(pat, s):
            return canon, ("CVC・事業会社" if canon in ("KDDI", "NTTグループ", "ソニーグループ") else "VC")
    is_vc = bool(VC_PAT.search(s))
    kind = "VC" if is_vc else ("金融機関" if re.search(r"銀行|信託|保険|証券|信用金庫", s) else ("CVC・事業会社" if CORP_PAT.search(s) else "個人"))
    # ファンド固有の号数・組合表記を落として運用会社名に寄せる
    name = re.sub(r"(第?\s*[0-9IVXⅠⅡⅢⅣⅤ]+\s*号)?\s*(投資事業(有限責任)?組合|投資組合|投資法人|ファンド)\s*.*$", "", s).strip()
    name = re.sub(r"(株式会社|合同会社|有限会社)", "", name).strip(" ・-－")
    return (name or s), kind


def round_label(share_class, seen_preferred):
    """種類株名からラウンド名を推定する（日本の実務慣行: A種=シリーズA…）。"""
    cls = unicodedata.normalize("NFKC", share_class or "")
    m = re.search(r"([A-Z])\s*[-\d]*\s*種", cls)
    if m:
        letter = m.group(1)
        if letter == "S":
            return "シード"
        if letter in "ABCD":
            return "シリーズ" + letter
        return "シリーズE+"
    if "普通" in cls or cls == "":
        return "普通株(追加)" if seen_preferred else "シード"
    return "普通株(追加)"


def _years(d1, d2):
    try:
        a, b = date.fromisoformat(d1[:10]), date.fromisoformat(d2[:10])
        return max((b - a).days, 0) / 365.25
    except (ValueError, TypeError):
        return None


def company_events(company, row):
    """1社の第三者割当イベントを、ラウンド名・投資家・IRR見込み付きで平坦化する。"""
    d = json.loads(row.analysis_json or "{}")
    terms = d.get("ipo_terms") or {}
    offer = terms.get("offer_price_yen")
    sectors = [s for s in (company.sectors or "").split(",") if s]
    seen_pref = False
    out = []
    for r in d.get("capital_history") or []:
        cls = r.get("share_class") or ""
        if "種" in unicodedata.normalize("NFKC", cls):
            seen_pref = True
        if r.get("event") != "第三者割当":
            continue
        price = r.get("price_per_share_yen") or r.get("price_per_share_yen_est")
        yrs = _years(r.get("date") or "", row.listing_date or "")
        moic = (offer / price) if (offer and price) else None
        irr = ((moic ** (1 / yrs)) - 1) if (moic and yrs and yrs >= 0.25) else None
        investors = []
        for raw in r.get("investors") or []:
            n = norm_investor(raw)
            if n:
                investors.append({"name": n[0], "kind": n[1], "raw": raw})
        out.append({
            "company_id": company.id, "name": company.name, "code": row.code, "listing_date": row.listing_date,
            "sectors": sectors, "sector": sectors[0] if sectors else None,
            "round": round_label(cls, seen_pref and "種" not in unicodedata.normalize("NFKC", cls)),
            "share_class": cls, "date": r.get("date"),
            "price_yen": price, "price_is_est": r.get("price_per_share_yen") is None,
            "post_money_oku": (r["post_money_yen_est"] / 1e8) if r.get("post_money_yen_est") else None,
            "amount_oku": (r["amount_yen"] / 1e8) if r.get("amount_yen") else None,
            "offer_price_yen": offer, "moic": round(moic, 2) if moic else None,
            "irr": round(irr, 3) if irr is not None else None, "years_to_ipo": round(yrs, 1) if yrs is not None else None,
            "investors": investors,
        })
    return out


def _median(vals):
    v = sorted(x for x in vals if isinstance(x, (int, float)))
    if not v:
        return None
    m = len(v) // 2
    return round(v[m] if len(v) % 2 else (v[m - 1] + v[m]) / 2, 3)


def aggregate_investors(events):
    """イベント列 → 投資家別集計（参画社数・ラウンド分布・MOIC/IRR中央値・案件一覧）。"""
    agg = {}
    for e in events:
        for inv in e["investors"]:
            a = agg.setdefault(inv["name"], {"name": inv["name"], "kind": inv["kind"], "companies": set(), "rounds": {}, "deals": []})
            a["companies"].add(e["company_id"])
            a["rounds"][e["round"]] = a["rounds"].get(e["round"], 0) + 1
            a["deals"].append({"company_id": e["company_id"], "company": e["name"], "code": e["code"], "round": e["round"],
                               "date": e["date"], "entry_price_yen": e["price_yen"], "offer_price_yen": e["offer_price_yen"],
                               "moic": e["moic"], "irr": e["irr"], "years": e["years_to_ipo"], "sector": e["sector"]})
    items = []
    for a in agg.values():
        deals = sorted(a["deals"], key=lambda x: x["date"] or "")
        items.append({
            "name": a["name"], "kind": a["kind"], "companies": len(a["companies"]), "deals_count": len(deals),
            "rounds": a["rounds"], "moic_median": _median([x["moic"] for x in deals]),
            "irr_median": _median([x["irr"] for x in deals]),
            "irr_n": sum(1 for x in deals if x["irr"] is not None), "deals": deals,
        })
    items.sort(key=lambda x: (-x["companies"], -x["deals_count"], x["name"]))
    return items
