"""週次レポート生成: 直近1週間の資金調達・M&A/IPOを数字と企業リンク付きでHTML/テキスト化する。

- 入力: data/raw/weekly_YYYY-MM-DD.json（資金調達）/ exit_YYYY-MM-DD.json（M&A・IPO）のうち
        基準日から遡って7日以内の全ファイル（週に複数回クロールが走っても集約される）
- 文脈: ローカルSQLiteのDB総数・当年の調達収録数
- 出力: data/reports/weekly_report_YYYY-MM-DD.html / .txt
        data/reports/note_YYYY-MM-DD.txt（note投稿用原稿: 1行目タイトル、空行、本文。メール末尾にも同梱）
        標準出力にメール件名とファイルパスをJSONで出す（週次タスクがGmail送信に使う）

usage:
  DATABASE_URL="" .venv/bin/python -m app.scripts.weekly_report [--date YYYY-MM-DD]
"""

import argparse
import glob
import html
import json
import os
import re
import sqlite3
from datetime import date, datetime, timedelta
from statistics import median

from app.db import BASE_DIR, DB_PATH

RAW_DIR = os.path.join(BASE_DIR, "data", "raw")
OUT_DIR = os.path.join(BASE_DIR, "data", "reports")
APP_URL = "https://startup-finder-iota.vercel.app"
WINDOW_DAYS = 7


def file_date(path):
    m = re.search(r"(\d{4}-\d{2}-\d{2})\.json$", path)
    return date.fromisoformat(m.group(1)) if m else None


def load_window(prefix, base):
    """基準日から7日以内の prefix_*.json を全部読み、社名で重複除去して返す。"""
    seen, out = set(), []
    for p in sorted(glob.glob(os.path.join(RAW_DIR, prefix + "_*.json"))):
        d = file_date(p)
        if d is None or not (base - timedelta(days=WINDOW_DAYS) <= d <= base):
            continue
        try:
            recs = json.load(open(p, encoding="utf-8"))
        except (ValueError, OSError):
            continue
        for r in recs if isinstance(recs, list) else []:
            n = (r.get("name") or "").strip()
            if n and n not in seen:
                seen.add(n)
                out.append(r)
    return out


def esc(s):
    return html.escape(str(s)) if s is not None else ""


def safe_url(u):
    return u if isinstance(u, str) and re.match(r"^https?://", u) else None


def oku(v):
    if v is None:
        return "非公表"
    return ("%d" % v if float(v).is_integer() else "%.1f" % v) + "億円"


def db_context():
    try:
        c = sqlite3.connect(DB_PATH)
        q = lambda s: c.execute(s).fetchone()[0]
        year = date.today().strftime("%Y")
        return {
            "total": q("SELECT COUNT(*) FROM companies"),
            "this_year": q("SELECT COUNT(*) FROM companies WHERE last_round_date LIKE '%s%%'" % year),
            "with_partners": q("SELECT COUNT(*) FROM companies WHERE partners IS NOT NULL AND partners!=''"),
            "with_sns": q("SELECT COUNT(*) FROM companies WHERE rep_x IS NOT NULL OR rep_linkedin IS NOT NULL OR rep_facebook IS NOT NULL"),
            "year": year,
        }
    except sqlite3.Error:
        return None


def db_enrich(recs):
    """クロールJSONに website / description が欠けている社をDBの値で補う。

    クロール時にURLを拾えたかどうかで企業名リンクが付いたり付かなかったりするのを防ぐ。
    """
    try:
        c = sqlite3.connect(DB_PATH)
        cur = c.cursor()
    except sqlite3.Error:
        return
    for r in recs:
        if r.get("website") and r.get("description"):
            continue
        try:
            cur.execute("SELECT website, description FROM companies WHERE name=?", (r.get("name") or "",))
            row = cur.fetchone()
        except sqlite3.Error:
            return
        if not row:
            continue
        if not r.get("website") and row[0]:
            r["website"] = row[0]
        if not r.get("description") and row[1]:
            r["description"] = row[1]


def note_draft(raises, exits, amounts, stage_cnt, sector_cnt, inv_cnt, base):
    """note投稿用の原稿（タイトル, 本文）を作る。

    noteの編集画面は「1. 」で始まる行を自動で番号リスト化して構造が崩れるため、
    企業番号は【n】形式にする。URLは1行に単独で置くとnote側でリンクカードになる。
    """
    top = lambda d, k: "、".join("%s %d件" % (a, b) for a, b in sorted(d.items(), key=lambda x: -x[1])[:k]) or "—"
    start = base - timedelta(days=WINDOW_DAYS)
    period = "%d/%d〜%d/%d" % (start.month, start.day, base.month, base.day)
    title = "【週次】国内スタートアップ資金調達まとめ %s｜%d件" % (period, len(raises))
    if amounts:
        title += "・合計%s" % oku(sum(amounts))
    L = ["%d年%d月%d日〜%d月%d日の1週間に発表された、国内スタートアップの資金調達・M&Aを数字でまとめます。"
         "CVC向け国内スタートアップDB「Startup Finder」の週次クロール結果をもとにしています。"
         "数値は公表・報道値のみで、非公表分は集計から除いています。" % (start.year, start.month, start.day, base.month, base.day), ""]
    L += ["■ 今週のサマリー", "・資金調達の発表: %d件" % len(raises)]
    if amounts:
        L += ["・合計調達額（公表分）: %s" % oku(sum(amounts)), "・中央値: %s" % oku(median(amounts))]
        b = raises[0]; blr = b.get("last_round") or {}
        L.append("・最大案件: %s（%s、%s）" % (b["name"], blr.get("round") or "", oku(blr.get("amount_oku"))))
    L += ["・M&A・IPO: %d件" % len(exits), "", "■ 内訳",
          "・ステージ: %s" % top(stage_cnt, 5), "・分野: %s" % top(sector_cnt, 6), "・出資側（頻出）: %s" % top(inv_cnt, 5), "",
          "■ 今週の資金調達（金額順）", "表記は「被出資側（調達した企業）｜ラウンド・金額｜出資側（投資家）」です。", ""]
    if not raises:
        L.append("今週は該当する資金調達の発表を検出しませんでした。")
    for i, r in enumerate(raises, 1):
        lr = r.get("last_round") or {}
        invs = "、".join((lr.get("investors") or r.get("investors") or [])[:4]) or "非公表"
        L.append("【%d】%s｜%s・%s｜出資: %s" % (i, r["name"], lr.get("round") or r.get("stage") or "", oku(lr.get("amount_oku")), invs))
        if r.get("description"):
            L.append(r["description"])
        site = safe_url(r.get("website"))
        if site:
            L.append(site)
        L.append("")
    L.append("■ M&A・IPO・スタートアップによる出資")
    if exits:
        for x in exits:
            label = {"ma": "M&A", "ipo": "IPO", "closed": "解散", "invest": "出資"}.get(x.get("status"), x.get("status"))
            L.append("・%s（%s）%s" % (x["name"], label, x.get("status_note") or ""))
    else:
        L.append("・今週は検出なし")
    L += ["", "■ 出典について",
          "各案件は各社プレスリリース・報道（PR TIMES、Kepple、BRIDGE、日経、TechCrunch等）を出典としています。企業リンクは各社公式サイトです。",
          "", "Startup Finder（CVC向け国内スタートアップDB、約1,900社収録）: %s" % APP_URL]
    return title, "\n".join(L)


def build(base):
    raises = load_window("weekly", base)
    exits = load_window("exit", base)
    db_enrich(raises)
    ctx = db_context()

    def amt(r):
        lr = r.get("last_round") or {}
        return lr.get("amount_oku")

    raises.sort(key=lambda r: (amt(r) is None, -(amt(r) or 0)))
    amounts = [amt(r) for r in raises if amt(r) is not None]
    stage_cnt, sector_cnt, inv_cnt = {}, {}, {}
    for r in raises:
        if r.get("stage"):
            stage_cnt[r["stage"]] = stage_cnt.get(r["stage"], 0) + 1
        for s in r.get("sectors") or []:
            sector_cnt[s] = sector_cnt.get(s, 0) + 1
        for i in ((r.get("last_round") or {}).get("investors") or r.get("investors") or []):
            inv_cnt[i] = inv_cnt.get(i, 0) + 1
    top = lambda d, n: sorted(d.items(), key=lambda x: -x[1])[:n]

    period = "%s〜%s" % ((base - timedelta(days=WINDOW_DAYS)).strftime("%-m/%-d"), base.strftime("%-m/%-d"))
    biggest = raises[0] if raises and amt(raises[0]) is not None else None
    subject = "【Startup Finder 週次】%s 資金調達%d件" % (period, len(raises))
    if amounts:
        subject += "・合計%s" % oku(sum(amounts))
    if exits:
        subject += "・M&A/IPO %d件" % len(exits)

    # ---------- HTML ----------
    td = 'style="padding:8px 10px;border-bottom:1px solid #e6e9f0;vertical-align:top;font-size:13px"'
    th = 'style="padding:8px 10px;border-bottom:2px solid #c9d3e6;text-align:left;font-size:12px;color:#5d6675;background:#f3f5fa"'
    td_amt = td[:-1] + ';white-space:nowrap;font-weight:700;text-align:right"'
    th_amt = th.replace("text-align:left", "text-align:right")
    kpi = lambda label, val: (
        '<td style="padding:10px 14px;background:#f3f5fa;border-radius:10px;text-align:center">'
        '<div style="font-size:22px;font-weight:700;color:#1f2a44">%s</div>'
        '<div style="font-size:11px;color:#5d6675">%s</div></td>' % (esc(val), esc(label)))

    rows = []
    for r in raises:
        lr = r.get("last_round") or {}
        site = safe_url(r.get("website"))
        srcs = [u for u in (r.get("sources") or []) if safe_url(u)]
        name_html = ('<a href="%s" style="color:#2a5bd7;font-weight:700;text-decoration:none">%s</a>' % (esc(site), esc(r["name"]))
                     if site else '<b>%s</b>' % esc(r["name"]))
        desc = esc((r.get("description") or "")[:70])
        invs = "、".join((lr.get("investors") or r.get("investors") or [])[:4])
        src_html = " ".join('<a href="%s" style="color:#7a8494;font-size:11px">出典%d</a>' % (esc(u), i + 1) for i, u in enumerate(srcs[:2]))
        rows.append(
            "<tr>"
            "<td %s>%s<div style=\"color:#7a8494;font-size:11.5px;margin-top:2px\">%s</div></td>"
            "<td %s>%s</td><td %s>%s<br><span style=\"color:#7a8494;font-size:11px\">%s</span></td>"
            "<td %s>%s</td>"
            "<td %s>%s</td><td %s>%s</td></tr>"
            % (td, name_html, desc,
               td, esc("・".join((r.get("sectors") or [])[:2])),
               td, esc(lr.get("round") or r.get("stage") or "—"), esc(lr.get("date") or ""),
               td_amt, esc(oku(lr.get("amount_oku"))),
               td, ("出資: " + esc(invs)) if invs else "—",
               td, src_html or "—"))

    exit_rows = []
    for x in exits:
        srcs = [u for u in (x.get("sources") or []) if safe_url(u)]
        label = {"ma": "M&A", "ipo": "IPO", "closed": "解散", "invest": "出資（スタートアップが出資側）"}.get(x.get("status"), x.get("status"))
        exit_rows.append("<tr><td %s><b>%s</b></td><td %s>%s</td><td %s>%s</td><td %s>%s</td></tr>" % (
            td, esc(x["name"]), td, esc(label), td, esc(x.get("status_note") or ""),
            td, " ".join('<a href="%s" style="color:#7a8494;font-size:11px">出典%d</a>' % (esc(u), i + 1) for i, u in enumerate(srcs[:2])) or "—"))

    kpis = [("今週の調達件数", "%d件" % len(raises)),
            ("合計調達額", oku(sum(amounts)) if amounts else "—"),
            ("中央値", oku(median(amounts)) if amounts else "—"),
            ("M&A / IPO", "%d件" % len(exits))]
    ctx_html = ""
    if ctx:
        ctx_html = ('<p style="font-size:12.5px;color:#5d6675;margin:14px 0 0">DB累計 <b>%s社</b>（%s年の調達収録 %s社・提携先あり %s社・代表SNSあり %s社）</p>'
                    % (format(ctx["total"], ","), ctx["year"], ctx["this_year"], ctx["with_partners"], ctx["with_sns"]))

    def bullet_list(pairs, unit="件"):
        return "、".join("%s %d%s" % (esc(k), v, unit) for k, v in pairs) or "—"

    body = [
        '<div style="font-family:-apple-system,BlinkMacSystemFont,\'Hiragino Sans\',\'Noto Sans JP\',sans-serif;max-width:760px;margin:0 auto;color:#1f2a44">',
        '<h2 style="margin:0 0 4px;font-size:18px">📊 Startup Finder 週次レポート</h2>',
        '<p style="margin:0 0 16px;color:#5d6675;font-size:13px">対象期間 %s ／ 基準日 %s</p>' % (esc(period), base.isoformat()),
        '<table cellspacing="8" style="border-collapse:separate;width:100%%"><tr>%s</tr></table>' % "".join(kpi(l, v) for l, v in kpis),
    ]
    if biggest:
        blr = biggest.get("last_round") or {}
        body.append('<p style="font-size:13px;margin:10px 0 0">最大案件: <b>%s</b>（%s ／ %s）</p>'
                    % (esc(biggest["name"]), esc(blr.get("round") or ""), esc(oku(blr.get("amount_oku")))))
    body.append('<p style="font-size:12.5px;color:#5d6675;margin:6px 0 0">ステージ: %s<br>分野: %s<br>投資家（頻出）: %s</p>'
                % (bullet_list(top(stage_cnt, 5)), bullet_list(top(sector_cnt, 6)), bullet_list(top(inv_cnt, 5))))
    body.append(ctx_html)

    body.append('<h3 style="font-size:14px;margin:22px 0 8px">今週の資金調達（金額順）</h3>')
    body.append('<p style="font-size:12px;color:#7a8494;margin:0 0 6px">左列＝資金を受け取った企業（被出資側）、「出資:」＝資金を出した投資家・事業会社（出資側）</p>')
    if rows:
        body.append('<table style="border-collapse:collapse;width:100%%"><thead><tr><th %s>被出資側（調達した企業）</th><th %s>分野</th><th %s>ラウンド</th><th %s>金額</th><th %s>出資側（投資家）</th><th %s>出典</th></tr></thead><tbody>%s</tbody></table>'
                    % (th, th, th, th_amt, th, th, "".join(rows)))
    else:
        body.append('<p style="font-size:13px;color:#7a8494">今週は該当する資金調達の発表を検出しませんでした。</p>')

    body.append('<h3 style="font-size:14px;margin:22px 0 8px">M&A・IPO・スタートアップによる出資</h3>')
    if exit_rows:
        body.append('<table style="border-collapse:collapse;width:100%%"><thead><tr><th %s>企業</th><th %s>種別</th><th %s>内容</th><th %s>出典</th></tr></thead><tbody>%s</tbody></table>'
                    % (th, th, th, th, "".join(exit_rows)))
    else:
        body.append('<p style="font-size:13px;color:#7a8494">今週は検出なし。</p>')

    body.append('<p style="margin:24px 0 0;font-size:12.5px"><a href="%s" style="color:#2a5bd7">Startup Finder を開く →</a>　'
                '<span style="color:#7a8494">企業名リンクは各社サイト、出典は報道・プレスリリースです。数値は公表・報道値のみ（非公表は除外して集計）。</span></p>' % APP_URL)
    note_title, note_body = note_draft(raises, exits, amounts, stage_cnt, sector_cnt, inv_cnt, base)
    body.append('<h3 style="font-size:14px;margin:28px 0 6px">📝 note用原稿（コピーしてそのまま貼れます）</h3>'
                '<p style="font-size:12px;color:#7a8494;margin:0 0 6px">タイトル: <b style="color:#1f2a44">%s</b></p>'
                '<pre style="white-space:pre-wrap;word-break:break-all;font-family:inherit;font-size:12px;line-height:1.6;'
                'background:#f3f5fa;border:1px solid #e6e9f0;border-radius:8px;padding:12px">%s</pre>' % (esc(note_title), esc(note_body)))
    body.append("</div>")
    html_out = "\n".join(body)

    # ---------- plain text ----------
    lines = ["Startup Finder 週次レポート（%s）" % period, ""]
    lines.append("今週の調達: %d件 / 合計 %s / 中央値 %s / M&A・IPO %d件" % (
        len(raises), oku(sum(amounts)) if amounts else "—", oku(median(amounts)) if amounts else "—", len(exits)))
    lines.append("")
    for r in raises:
        lr = r.get("last_round") or {}
        lines.append("- 被出資: %s | %s %s | 出資: %s | %s" % (r["name"], lr.get("round") or "", oku(lr.get("amount_oku")),
                                                 "、".join((lr.get("investors") or [])[:3]) or "—", safe_url(r.get("website")) or (r.get("sources") or [""])[0]))
    if exits:
        lines.append("")
        lines.append("M&A・IPO・スタートアップによる出資:")
        for x in exits:
            lines.append("- %s [%s] %s" % (x["name"], x.get("status"), x.get("status_note") or ""))
    if ctx:
        lines.append("")
        lines.append("DB累計 %s社（%s年調達収録 %s社）" % (format(ctx["total"], ","), ctx["year"], ctx["this_year"]))
    lines.append(APP_URL)
    lines += ["", "=" * 40, "note用原稿", "タイトル: " + note_title, "", note_body]
    return subject, html_out, "\n".join(lines), len(raises), len(exits), note_title, note_body


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", help="基準日 YYYY-MM-DD（省略時は今日）")
    a = ap.parse_args()
    base = date.fromisoformat(a.date) if a.date else date.today()
    subject, html_out, text_out, n_raise, n_exit, note_title, note_body = build(base)
    os.makedirs(OUT_DIR, exist_ok=True)
    hp = os.path.join(OUT_DIR, "weekly_report_%s.html" % base.isoformat())
    tp = os.path.join(OUT_DIR, "weekly_report_%s.txt" % base.isoformat())
    open(hp, "w", encoding="utf-8").write(html_out)
    open(tp, "w", encoding="utf-8").write(text_out)
    np_ = os.path.join(OUT_DIR, "note_%s.txt" % base.isoformat())
    open(np_, "w", encoding="utf-8").write(note_title + "\n\n" + note_body)
    print(json.dumps({"subject": subject, "html_path": hp, "text_path": tp, "note_path": np_, "note_title": note_title,
                      "raises": n_raise, "exits": n_exit}, ensure_ascii=False))


if __name__ == "__main__":
    main()
