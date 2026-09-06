#!/usr/bin/env python3
"""startup-finder の ipo_analysis（Ⅰの部AI抽出）から資本政策ベンチマークを書き出す。

出力 data/ipo_benchmarks.json:
  - dilution_per_round: 第三者割当1回あたりの既存株主希薄化率（新株数 ÷ 発行後総株数）の分布
  - founder_pct / vc_pct / corporate_pct / rounds_count / price_multiple / years_to_ipo の分布
  - companies: 各社の要約（名前・コード・上場日・主要指標）
分布は n / min / q1 / median / q3 / max。スナップショット方式で generated_at を記録する。

使い方:
    python3 captable-sim/scripts/export_ipo_benchmarks.py \
        [--db startup-finder/data/startup.db] [--out captable-sim/data/ipo_benchmarks.json]
"""
import argparse
import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent


def quantiles(values):
    vals = sorted(v for v in values if isinstance(v, (int, float)))
    if not vals:
        return None
    def q(p):
        k = (len(vals) - 1) * p
        lo, hi = int(k), min(int(k) + 1, len(vals) - 1)
        return round(vals[lo] + (vals[hi] - vals[lo]) * (k - lo), 3)
    return {"n": len(vals), "min": vals[0], "q1": q(0.25), "median": q(0.5), "q3": q(0.75), "max": vals[-1]}


def round_dilutions(history):
    """第三者割当の各回について 新株数 ÷ 発行後総株数 を返す（post_shares_total が無い回は除外）。"""
    out = []
    for r in history or []:
        if r.get("event") != "第三者割当":
            continue
        new, post = r.get("shares"), r.get("post_shares_total")
        if isinstance(new, (int, float)) and isinstance(post, (int, float)) and post > 0 and 0 < new < post:
            out.append(round(new / post, 4))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=str(REPO_ROOT / "startup-finder" / "data" / "startup.db"))
    ap.add_argument("--out", default=str(REPO_ROOT / "captable-sim" / "data" / "ipo_benchmarks.json"))
    a = ap.parse_args()
    con = sqlite3.connect(a.db)
    rows = con.execute(
        "SELECT c.name, i.code, i.listing_date, i.market, i.analysis_json "
        "FROM ipo_analysis i JOIN companies c ON c.id = i.company_id ORDER BY i.listing_date DESC").fetchall()
    companies, dil_all = [], []
    cols = {k: [] for k in ("founder_pct", "vc_pct", "corporate_pct", "rounds_count", "price_multiple", "years_to_ipo", "so_pct")}
    for name, code, ld, market, js in rows:
        try:
            d = json.loads(js or "{}")
        except json.JSONDecodeError:
            continue
        ss, dv, so = d.get("shareholder_summary") or {}, d.get("derived") or {}, d.get("stock_options") or {}
        dils = round_dilutions(d.get("capital_history"))
        dil_all.extend(dils)
        rec = {"name": name, "code": code, "listing_date": ld, "market": market,
               "founder_pct": ss.get("founders_pct"), "vc_pct": ss.get("vc_pct"), "corporate_pct": ss.get("corporate_pct"),
               "rounds_count": dv.get("rounds_count"), "price_multiple": dv.get("price_multiple_first_to_last_est"),
               "years_to_ipo": dv.get("years_founding_to_ipo"), "so_pct": so.get("potential_pct"),
               "dilution_per_round": dils}
        companies.append(rec)
        for k in cols:
            cols[k].append(rec[k])
    out = {
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source": "startup-finder ipo_analysis（JPX公開のⅠの部をAI抽出・届出書記載値ベース）",
        "count": len(companies),
        "dilution_per_round": quantiles(dil_all),
        "stats": {k: quantiles(v) for k, v in cols.items()},
        "companies": companies,
    }
    Path(a.out).parent.mkdir(parents=True, exist_ok=True)
    Path(a.out).write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    dq = out["dilution_per_round"]
    print(f"companies={len(companies)} rounds_with_dilution={dq['n'] if dq else 0} -> {a.out}")
    if dq:
        print(f"  1ラウンド希薄化: 中央値 {dq['median']*100:.1f}% (Q1 {dq['q1']*100:.1f}% / Q3 {dq['q3']*100:.1f}%)")
    for k, v in out["stats"].items():
        if v: print(f"  {k}: median {v['median']} (n={v['n']})")


if __name__ == "__main__":
    main()
