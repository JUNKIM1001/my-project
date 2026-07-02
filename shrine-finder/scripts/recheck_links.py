#!/usr/bin/env python3
"""死リンク判定の誤検出(DNSスロットリング)を是正する。
元の公式URLを地域SQLから復元し、website が null の社寺を低並列・リトライ付きで再検証。
明確な死リンク(404/410 or 3回連続DNS失敗)以外は website を復元する。"""
import json, os, re, ssl, socket, time, glob, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, "data/appdata.json")  # 正準ソース。編集後は scripts/sync_appdata.py で配布ファイルを生成
UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605 Safari/605"}
CTX = ssl.create_default_context(); CTX.check_hostname = False; CTX.verify_mode = ssl.CERT_NONE

# ---- SQL から slug -> website を復元 ----
def value_tuples(block):
    out, depth, cur, inq = [], 0, "", False
    for ch in block:
        if inq:
            cur += ch
            if ch == "'": inq = False
            continue
        if ch == "'": inq = True; cur += ch; continue
        if ch == "(":
            depth += 1
            if depth == 1: cur = ""; continue
        if ch == ")":
            depth -= 1
            if depth == 0: out.append(cur); cur = ""; continue
        if depth >= 1: cur += ch
    return out
def split_fields(t):
    f, cur, inq, depth = [], "", False, 0
    for ch in t:
        if inq:
            cur += ch
            if ch == "'": inq = False
            continue
        if ch == "'": inq = True; cur += ch; continue
        if ch in "{(": depth += 1; cur += ch; continue
        if ch in "})": depth -= 1; cur += ch; continue
        if ch == "," and depth == 0: f.append(cur.strip()); cur = ""; continue
        cur += ch
    if cur.strip(): f.append(cur.strip())
    return f
def uq(x):
    x = x.strip()
    if x.lower() == "null": return None
    if x.startswith("'") and x.endswith("'"): return x[1:-1].replace("''", "'")
    return x

slug_web = {}
files = glob.glob(os.path.join(ROOT, "data/regions/*.sql")) + \
        [os.path.join(ROOT, "supabase/migrations/0004_temple_shrine_seed_pilot.sql")]
for path in files:
    if not os.path.exists(path): continue
    sql = open(path, encoding="utf-8").read()
    for m in re.finditer(r"insert\s+into\s+temple_shrine\s*\(([^)]*)\)\s*values(.*?)on\s+conflict",
                         sql, re.IGNORECASE | re.DOTALL):
        cols = [c.strip() for c in m.group(1).split(",")]
        for tup in value_tuples(m.group(2)):
            vals = split_fields(tup)
            if len(vals) != len(cols): continue
            r = dict(zip(cols, vals))
            s = uq(r.get("slug", "")); w = uq(r.get("website"))
            if s and w and s not in slug_web: slug_web[s] = w

def check(url, tries=3):
    last = ("uncertain", "?")
    for _ in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=10, context=CTX) as r:
                r.read(128); return "ok", r.status
        except urllib.error.HTTPError as e:
            return ("dead" if e.code in (404, 410) else "uncertain"), e.code
        except urllib.error.URLError as e:
            reason = str(getattr(e, "reason", e)); last = ("dnsfail", reason[:30])
        except Exception as e:
            last = ("uncertain", str(e)[:30])
        time.sleep(1.5)
    return last  # 3回連続失敗

data = json.load(open(APP, encoding="utf-8"))
# website が None で、SQLに元URLがある社寺を再検証
todo = [(i, slug_web[s["slug"]]) for i, s in enumerate(data["shrines"])
        if not s.get("website") and s["slug"] in slug_web]
print("再検証対象(null化された公式サイト):", len(todo))

with ThreadPoolExecutor(max_workers=8) as ex:
    res = list(ex.map(lambda t: check(t[1]), todo))

restored = dead = 0
deadlist = []
for (i, url), (status, info) in zip(todo, res):
    if status in ("ok", "uncertain"):  # 生存 or 不確実 → 復元(温存)
        data["shrines"][i]["website"] = url; restored += 1
    else:  # dnsfail(3連続) or dead(404/410) → 真の死リンク
        dead += 1; deadlist.append((data["shrines"][i]["name"], url, info))

json.dump(data, open(APP, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(f"復元: {restored} / 真の死リンク(除去のまま): {dead}")
print("--- 真の死リンク ---")
for n, u, info in deadlist: print(f"  {n}: {u} ({info})")
