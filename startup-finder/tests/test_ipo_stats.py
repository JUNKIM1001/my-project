"""ipo_stats の純粋ロジック: ラウンド名推定・投資家名正規化・IRR見込み計算。"""
import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app.ipo_stats import round_label, norm_investor, company_events, aggregate_investors


def test_round_label_from_share_class():
    assert round_label("Ａ種優先株式", False) == "シリーズA"
    assert round_label("A-2種優先株式", True) == "シリーズA"
    assert round_label("Ｄ種優先株式", True) == "シリーズD"
    assert round_label("E種優先株式", True) == "シリーズE+"
    assert round_label("普通株式", False) == "シード"
    assert round_label("普通株式", True) == "普通株(追加)"


def test_norm_investor_aliases_and_kinds():
    assert norm_investor("グローバル・ブレイン７号投資事業有限責任組合") == ("グローバル・ブレイン", "VC")
    assert norm_investor("ジャフコ SV5共有投資事業有限責任組合") == ("ジャフコ", "VC")
    assert norm_investor("株式会社三菱UFJ銀行")[1] == "金融機関"
    assert norm_investor("伊藤忠商事株式会社") == ("伊藤忠商事", "CVC・事業会社")
    assert norm_investor("大和ベンチャー１号投資事業有限責任組合") == ("大和企業投資", "VC")
    assert norm_investor("他") is None


class _C:  # Company/IpoAnalysis の最小スタブ
    def __init__(self, **kw): self.__dict__.update(kw)


def test_company_events_irr_and_rounds():
    hist = [
        {"date": "2019-04-01", "event": "設立", "share_class": "普通株式", "shares": 1000},
        {"date": "2020-04-01", "event": "第三者割当", "share_class": "A種優先株式", "shares": 100, "price_per_share_yen": 500,
         "post_shares_total": 1100, "post_money_yen_est": 550000, "investors": ["ジャフコ SV5投資事業有限責任組合"]},
        {"date": "2022-04-01", "event": "第三者割当", "share_class": "B種優先株式", "shares": 100, "price_per_share_yen": 1000,
         "post_shares_total": 1200, "post_money_yen_est": 1200000, "investors": ["伊藤忠商事株式会社", "他"]},
    ]
    row = _C(analysis_json=json.dumps({"capital_history": hist, "ipo_terms": {"offer_price_yen": 2000}}), listing_date="2024-04-01", code="000A")
    c = _C(id=1, name="テスト社", sectors="SaaS,AI")
    ev = company_events(c, row)
    assert [e["round"] for e in ev] == ["シリーズA", "シリーズB"]
    a = ev[0]
    assert a["moic"] == 4.0 and abs(a["years_to_ipo"] - 4.0) < 0.1
    assert abs(a["irr"] - (4.0 ** (1 / 4.0) - 1)) < 0.01          # ≈ 41%
    assert ev[1]["moic"] == 2.0 and abs(ev[1]["irr"] - (2.0 ** 0.5 - 1)) < 0.01
    assert ev[1]["investors"] == [{"name": "伊藤忠商事", "kind": "CVC・事業会社", "raw": "伊藤忠商事株式会社"}]
    agg = aggregate_investors(ev)
    names = {x["name"]: x for x in agg}
    assert names["ジャフコ"]["companies"] == 1 and names["ジャフコ"]["irr_median"] > 0.4
    assert names["伊藤忠商事"]["rounds"] == {"シリーズB": 1}


def test_company_events_without_offer_price_has_no_irr():
    row = _C(analysis_json=json.dumps({"capital_history": [{"date": "2021-01-01", "event": "第三者割当", "share_class": "A種優先株式", "shares": 1, "price_per_share_yen": 100, "investors": ["X Ventures"]}], "ipo_terms": {}}), listing_date="2024-01-01", code="1")
    ev = company_events(_C(id=2, name="Y", sectors=""), row)
    assert ev[0]["moic"] is None and ev[0]["irr"] is None
