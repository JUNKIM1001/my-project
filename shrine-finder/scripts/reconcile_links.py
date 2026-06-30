#!/usr/bin/env python3
"""公式サイトリンクの最終調整。
判定: ①HTTPで404/410 → 本当の死リンク(除去) ②公開DNS(8.8.8.8)で解決可 → 復元(環境DNSの誤検出を是正)
③8.8.8.8でも解決不可 → 本当に消滅(除去)。"""
import json, os, re, ssl, glob, subprocess, urllib.request, urllib.error, urllib.parse
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, "ios/ShrineFinder/Resources/appdata.json")
UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605 Safari/605"}
CTX = ssl.create_default_context(); CTX.check_hostname = False; CTX.verify_mode = ssl.CERT_NONE

def value_tuples(b):
    out, d, c, q = [], 0, "", False
    for ch in b:
        if q:
            c += ch
            if ch == "'": q = False
            continue
        if ch == "'": q = True; c += ch; continue
        if ch == "(":
            d += 1
            if d == 1: c = ""; continue
        if ch == ")":
            d -= 1
            if d == 0: out.append(c); c = ""; continue
        if d >= 1: c += ch
    return out
def split_fields(t):
    f, c, q, d = [], "", False, 0
    for ch in t:
        if q:
            c += ch
            if ch == "'": q = False
            continue
        if ch == "'": q = True; c += ch; continue
        if ch in "{(": d += 1; c += ch; continue
        if ch in "})": d -= 1; c += ch; continue
        if ch == "," and d == 0: f.append(c.strip()); c = ""; continue
        c += ch
    if c.strip(): f.append(c.strip())
    return f
def uq(x):
    x = x.strip()
    if x.lower() == "null": return None
    if x.startswith("'") and x.endswith("'"): return x[1:-1].replace("''", "'")
    return x

slug_web = {}
for path in glob.glob(os.path.join(ROOT, "data/regions/*.sql")) + \
            [os.path.join(ROOT, "supabase/migrations/0004_temple_shrine_seed_pilot.sql")]:
    if not os.path.exists(path): continue
    sql = open(path, encoding="utf-8").read()
    for m in re.finditer(r"insert\s+into\s+temple_shrine\s*\(([^)]*)\)\s*values(.*?)on\s+conflict", sql, re.I | re.S):
        cols = [c.strip() for c in m.group(1).split(",")]
        for tup in value_tuples(m.group(2)):
            v = split_fields(tup)
            if len(v) != len(cols): continue
            r = dict(zip(cols, v)); s = uq(r.get("slug", "")); w = uq(r.get("website"))
            if s and w and s not in slug_web: slug_web[s] = w

def dns_ok(host):
    try:
        out = subprocess.run(["nslookup", "-timeout=4", host, "8.8.8.8"],
                             capture_output=True, text=True, timeout=8).stdout
        ips = re.findall(r"^Address: (\S+)", out, re.M)
        return len(ips) > 0
    except Exception:
        return False

def http_dead(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=8, context=CTX) as r:
            r.read(64); return False
    except urllib.error.HTTPError as e:
        return e.code in (404, 410)
    except Exception:
        return False  # 解決不可等はDNS判定に委ねる

data = json.load(open(APP, encoding="utf-8"))
todo = [(i, slug_web[s["slug"]]) for i, s in enumerate(data["shrines"])
        if not s.get("website") and s["slug"] in slug_web]
print("最終判定対象:", len(todo))

def decide(url):
    if http_dead(url):
        return "dead404"
    host = urllib.parse.urlparse(url).hostname or ""
    return "restore" if dns_ok(host) else "deadDNS"

with ThreadPoolExecutor(max_workers=10) as ex:
    decisions = list(ex.map(lambda t: decide(t[1]), todo))

restore = d404 = ddns = 0
for (i, url), dec in zip(todo, decisions):
    if dec == "restore":
        data["shrines"][i]["website"] = url; restore += 1
    elif dec == "dead404": d404 += 1
    else: ddns += 1

json.dump(data, open(APP, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
n_web = sum(1 for s in data["shrines"] if s.get("website"))
print(f"復元(8.8.8.8で生存): {restore} / 404・410で除去: {d404} / 完全消滅で除去: {ddns}")
print(f"公式サイトを持つ社寺(最終): {n_web}")
