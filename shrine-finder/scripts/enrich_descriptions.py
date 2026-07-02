#!/usr/bin/env python3
"""各社寺の ja.wikipedia 記事の冒頭(intro extract)を取得し longDescription に格納。
歴史・由緒・著名な関わりなどを補う。Wikimedia API のみ(Claudeクレジット不使用)。"""
import json, os, re, time, urllib.parse, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, "data/appdata.json")  # 正準ソース。編集後は scripts/sync_appdata.py で配布ファイルを生成
UA = {"User-Agent": "ShrineFinderApp/0.9 (description enrichment; local dev)"}
MAXLEN = 520

def api(params):
    url = "https://ja.wikipedia.org/w/api.php?" + urllib.parse.urlencode(params)
    for _ in range(3):
        try:
            return json.load(urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=40))
        except Exception:
            time.sleep(2)
    return {}

def title_of(src):
    m = re.search(r"/wiki/(.+)$", src or "")
    return urllib.parse.unquote(m.group(1)).replace("_", " ") if m else None

def trim(text):
    t = re.sub(r"\s+\n", "\n", (text or "").strip())
    t = re.sub(r"\n{2,}", "\n", t)
    if len(t) <= MAXLEN:
        return t
    cut = t[:MAXLEN]
    p = cut.rfind("。")
    return (cut[:p+1] if p > 120 else cut) + ("…" if p <= 120 else "")

data = json.load(open(APP, encoding="utf-8"))
want = {}
for s in data["shrines"]:
    t = title_of(s.get("source"))
    if t: want.setdefault(t, []).append(s)
titles = list(want.keys())
print("対象:", len(titles))

resolve, title_extract = {}, {}
def absorb(d):
    q = d.get("query", {})
    for k in ("normalized", "redirects"):
        for m in q.get(k, []): resolve[m["from"]] = m["to"]
    for p in q.get("pages", {}).values():
        if p.get("extract"): title_extract[p["title"]] = p["extract"]

for i in range(0, len(titles), 20):
    absorb(api({"action": "query", "format": "json", "redirects": 1,
                "prop": "extracts", "exintro": 1, "explaintext": 1,
                "titles": "|".join(titles[i:i+20])}))
    time.sleep(0.3)

def final(t):
    seen = set()
    while t in resolve and t not in seen:
        seen.add(t); t = resolve[t]
    return t

n = 0
for t, slist in want.items():
    ex = title_extract.get(final(t))
    if not ex: continue
    desc = trim(ex)
    if len(desc) < 30: continue
    for s in slist:
        s["longDescription"] = desc; n += 1

json.dump(data, open(APP, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(f"説明を拡充: {n}社寺 / 全{len(data['shrines'])}社寺")
