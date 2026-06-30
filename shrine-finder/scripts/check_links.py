#!/usr/bin/env python3
"""各社寺の website(公式サイト) を HTTP で検証。明確な死リンク(404/410/DNS失敗)は除去(null)する。
タイムアウトや403等の不確実なものは温存。Wikimedia/HTTPのみ使用(Claudeクレジット不使用)。"""
import json, os, ssl, socket, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, "ios/ShrineFinder/Resources/appdata.json")
UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605 (KHTML, like Gecko) Safari/605"}
CTX = ssl.create_default_context(); CTX.check_hostname = False; CTX.verify_mode = ssl.CERT_NONE

def check(url):
    req = urllib.request.Request(url, headers=UA, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=8, context=CTX) as r:
            r.read(256)
            return "ok", r.status
    except urllib.error.HTTPError as e:
        return ("dead" if e.code in (404, 410) else "uncertain"), e.code
    except urllib.error.URLError as e:
        reason = str(getattr(e, "reason", e))
        dead = any(k in reason for k in ("Name or service", "nodename nor servname",
                   "getaddrinfo", "No address associated", "Connection refused"))
        return ("dead" if dead else "uncertain"), reason[:40]
    except (socket.timeout, TimeoutError):
        return "uncertain", "timeout"
    except Exception as e:
        return "uncertain", str(e)[:40]

data = json.load(open(APP, encoding="utf-8"))
targets = [(i, s["website"]) for i, s in enumerate(data["shrines"]) if s.get("website")]
print("公式サイトを持つ社寺:", len(targets))

results = {}
with ThreadPoolExecutor(max_workers=24) as ex:
    for (i, url), (status, info) in zip(targets, ex.map(lambda t: check(t[1]), targets)):
        results[i] = (status, info, url)

ok = [i for i, (s, *_) in results.items() if s == "ok"]
dead = [i for i, (s, *_) in results.items() if s == "dead"]
unc = [i for i, (s, *_) in results.items() if s == "uncertain"]
print(f"OK: {len(ok)} / 死リンク(除去): {len(dead)} / 不確実(温存): {len(unc)}")
print("--- 除去する死リンク ---")
for i in dead:
    print(f"  {data['shrines'][i]['name']}: {results[i][2]} ({results[i][1]})")
print("--- 不確実(温存)の例 ---")
for i in unc[:12]:
    print(f"  {data['shrines'][i]['name']}: {results[i][2]} ({results[i][1]})")

for i in dead:
    data["shrines"][i]["website"] = None
json.dump(data, open(APP, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(f"\n死リンク {len(dead)} 件を除去して保存。")
