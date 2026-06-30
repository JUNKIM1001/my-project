#!/usr/bin/env python3
"""各社寺の ja.wikipedia 記事の代表画像(lead image)とライセンスを取得し、
自由ライセンス(CC0/PD/CC BY/CC BY-SA等)のものだけ image_url/license/author として格納する。
ライセンス確認は ja.wikipedia の imageinfo 経由(Commons・ローカル両対応)で広く拾う。
Wikimedia API のみ使用(Claudeのクレジット不使用)。"""
import json, os, re, time, urllib.parse, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, "ios/ShrineFinder/Resources/appdata.json")
UA = {"User-Agent": "ShrineFinderApp/0.9 (photo enrichment; local dev)"}

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

def strip(h): return re.sub("<[^>]+>", "", h or "").strip()

def is_free(lic):
    l = (lic or "").lower()
    if any(b in l for b in ("fair use", "non-free", "all rights", "著作権")): return False
    return any(k in l for k in ("cc0", "cc by", "cc-by", "public domain", "pdm", "pd-",
                                "fal", "gfdl", "attribution", "パブリック"))

data = json.load(open(APP, encoding="utf-8"))
want = {}
for s in data["shrines"]:
    t = title_of(s.get("source"))
    if t: want.setdefault(t, []).append(s)
titles = list(want.keys())
print("対象記事:", len(titles))

# 1) lead image(pageimage)＋サムネ
resolve, t_file, t_thumb = {}, {}, {}
def absorb(d):
    q = d.get("query", {})
    for k in ("normalized", "redirects"):
        for m in q.get(k, []): resolve[m["from"]] = m["to"]
    for p in q.get("pages", {}).values():
        if "pageimage" in p: t_file[p["title"]] = p["pageimage"]
        th = (p.get("thumbnail") or {}).get("source")
        if th: t_thumb[p["title"]] = th
for i in range(0, len(titles), 50):
    absorb(api({"action": "query", "format": "json", "redirects": 1,
                "titles": "|".join(titles[i:i+50]),
                "prop": "pageimages", "piprop": "name|thumbnail", "pithumbsize": 800}))
    time.sleep(0.3)
def final(t):
    seen = set()
    while t in resolve and t not in seen:
        seen.add(t); t = resolve[t]
    return t

# 2) File ごとのライセンス・作者(ja.wikipedia経由＝Commons/ローカル両対応)
files = sorted({t_file[final(t)] for t in titles if final(t) in t_file})
print("画像ファイル数:", len(files))
meta = {}
for i in range(0, len(files), 50):
    d = api({"action": "query", "format": "json",
             "titles": "|".join("File:" + f for f in files[i:i+50]),
             "prop": "imageinfo", "iiprop": "extmetadata"})
    for p in d.get("query", {}).get("pages", {}).values():
        ii = (p.get("imageinfo") or [{}])[0]; em = ii.get("extmetadata", {})
        meta[p.get("title", "")[5:]] = (em.get("LicenseShortName", {}).get("value", ""),
                                        strip(em.get("Artist", {}).get("value", ""))[:80])
    time.sleep(0.3)

# 3) 自由ライセンスのみ格納
n = 0
for t, slist in want.items():
    ft = final(t); fname = t_file.get(ft); thumb = t_thumb.get(ft)
    if not fname or not thumb: continue
    lic, author = meta.get(fname, ("", ""))
    if not is_free(lic): continue
    for s in slist:
        s["imageURL"] = thumb; s["imageLicense"] = lic; s["imageAuthor"] = author; n += 1

json.dump(data, open(APP, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(f"自由ライセンス画像: {n}社寺 / 全{len(data['shrines'])}社寺")
