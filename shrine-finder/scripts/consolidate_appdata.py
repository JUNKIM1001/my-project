#!/usr/bin/env python3
"""地域別SQL(data/regions/*.sql) を解析し、神仏slugを名寄せして appdata.json に統合する。
既存 appdata.json(36社寺/32神仏) を土台に、6地域の新規社寺・神仏をマージする。"""
import json, re, os, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, "ios/ShrineFinder/Resources/appdata.json")
BASE = os.path.join(ROOT, "scripts/appdata.backup.json")   # 地域統合前の土台(36社寺/32神仏)
# data/regions/ の全SQLを取り込む（extra-famous系は土台に既出のため除外）
EXCLUDE = {"extra-famous.sql", "extra-famous-2.sql"}
REGION_PATHS = sorted(p for p in glob.glob(os.path.join(ROOT, "data/regions/*.sql"))
                      if os.path.basename(p) not in EXCLUDE)

def norm(slug):  # 神仏slugの表記ゆれ吸収: ハイフン→アンダースコア
    return slug.strip().replace("-", "_")

# ---- 低レベルSQLパーサ ----
def value_tuples(block):
    out, depth, cur, inq = [], 0, "", False
    for ch in block:
        if inq:
            cur += ch
            if ch == "'": inq = False
            continue
        if ch == "'":
            inq = True; cur += ch; continue
        if ch == "(":
            depth += 1
            if depth == 1: cur = ""; continue
        if ch == ")":
            depth -= 1
            if depth == 0: out.append(cur); cur = ""; continue
        if depth >= 1: cur += ch
    return out

def split_fields(t):
    fields, cur, inq, depth = [], "", False, 0
    for ch in t:
        if inq:
            cur += ch
            if ch == "'": inq = False
            continue
        if ch == "'": inq = True; cur += ch; continue
        if ch in "{(": depth += 1; cur += ch; continue
        if ch in "})": depth -= 1; cur += ch; continue
        if ch == "," and depth == 0: fields.append(cur.strip()); cur = ""; continue
        cur += ch
    if cur.strip(): fields.append(cur.strip())
    return fields

def uq(f):
    f = f.strip()
    if f.lower() == "null": return None
    if f.startswith("'") and f.endswith("'"):
        return f[1:-1].replace("''", "'")
    return f

def find_inserts(sql, table):
    pat = re.compile(r"insert\s+into\s+" + table + r"\s*\(([^)]*)\)\s*values(.*?)on\s+conflict",
                     re.IGNORECASE | re.DOTALL)
    for m in pat.finditer(sql):
        cols = [c.strip() for c in m.group(1).split(",")]
        for tup in value_tuples(m.group(2)):
            vals = split_fields(tup)
            if len(vals) == len(cols):
                yield dict(zip(cols, vals))

def find_linkages(sql, table, keycol, valcol):
    """temple_shrine_deity / deity_goriyaku の where句から key->[vals] を抽出"""
    links = {}
    for m in re.finditer(r"insert\s+into\s+" + table + r"\b(.*?)on\s+conflict",
                          sql, re.IGNORECASE | re.DOTALL):
        body = m.group(1)
        for cm in re.finditer(
            keycol + r"\.slug\s*=\s*'([^']+)'\s+and\s+" + valcol +
            r"\.slug\s*(?:in\s*\(([^)]+)\)|=\s*'([^']+)')", body, re.IGNORECASE):
            key = cm.group(1)
            if cm.group(2):
                vals = re.findall(r"'([^']+)'", cm.group(2))
            else:
                vals = [cm.group(3)]
            links.setdefault(key, set()).update(vals)
    return links

# ---- 統合前の土台を読み込み（再実行で冪等） ----
data = json.load(open(BASE, encoding="utf-8"))
goriyaku_slugs = {g["slug"] for g in data["goriyaku"]}
# 不足ご利益を補完(仕様30種に揃える)
for extra in [("mizu_amagoi", "水・雨乞い・治水", "drop.fill"),
              ("enkiri", "縁切り", "scissors"),
              ("petto", "ペット守護", "pawprint.fill")]:
    if extra[0] not in goriyaku_slugs:
        data["goriyaku"].append({"slug": extra[0], "name": extra[1], "icon": extra[2]})
        goriyaku_slugs.add(extra[0])

deities = {d["slug"]: d for d in data["deities"]}          # 既存はnorm済み(underscore)
shrines = {s["slug"]: s for s in data["shrines"]}
report = []

for path in REGION_PATHS:
    name = os.path.basename(path)[:-4]
    sql = open(path, encoding="utf-8").read()
    dg = {norm(k): v for k, v in find_linkages(sql, "deity_goriyaku", "d", "g").items()}
    tsd = find_linkages(sql, "temple_shrine_deity", "t", "d")
    nd = ns = 0
    # 神仏
    for r in find_inserts(sql, "deity"):
        slug = norm(uq(r["slug"]))
        gory = sorted(x for x in dg.get(slug, set()) if x in goriyaku_slugs)
        if slug in deities:
            cur = set(deities[slug].get("goriyaku", []))
            deities[slug]["goriyaku"] = sorted(cur | set(gory))
        else:
            deities[slug] = {
                "slug": slug, "name": uq(r["name"]),
                "kana": uq(r.get("name_kana")) or "", "kind": uq(r["kind"]),
                "category": uq(r.get("category")) or "", "description": uq(r.get("description")) or "",
                "goriyaku": gory,
            }
            nd += 1
    # 社寺
    for r in find_inserts(sql, "temple_shrine"):
        slug = r["slug"]
        if slug.startswith("'"): slug = uq(slug)
        if slug in shrines: continue
        dlist = sorted(norm(x) for x in tsd.get(slug, set()))
        shrines[slug] = {
            "slug": slug, "name": uq(r["name"]), "kana": uq(r.get("name_kana")) or "",
            "type": uq(r["type"]), "sect": uq(r.get("sect")) or "",
            "pref": uq(r.get("prefecture")) or "", "city": uq(r.get("city")) or "",
            "address": uq(r.get("address")) or "",
            "lat": float(uq(r["lat"])), "lng": float(uq(r["lng"])),
            "deities": dlist, "website": uq(r.get("website")),
            "description": uq(r.get("description")) or "", "source": uq(r.get("source_url")) or "",
        }
        ns += 1
    report.append((name, nd, ns))

# ---- 参照されたが未定義の共通神仏を補完 ----
SUPPLEMENT = {
    "ebisu": {"name": "恵比寿", "kana": "えびす", "kind": "kami", "category": "七福神",
              "description": "七福神の一柱。漁業・商売繁盛・福徳の神。",
              "goriyaku": ["shobai", "kinun", "suisan_noko", "kaijo_anzen", "kaiun"]},
    "toyotama": {"name": "豊玉姫命", "kana": "とよたまひめのみこと", "kind": "kami", "category": "記紀神",
                 "description": "海神の娘。安産・縁結びの神。",
                 "goriyaku": ["anzan", "enmusubi", "kaijo_anzen", "kaiun"]},
}
referenced = {d for s in shrines.values() for d in s["deities"]}
for slug, info in SUPPLEMENT.items():
    if slug in referenced and slug not in deities:
        deities[slug] = {"slug": slug, **info}

# ---- 国宝（建造物等）を有する社寺フラグ ----
# slug厳密一致。同名分社（常陸出雲大社・釧路厳島・長崎興福寺・元善光寺等）の誤検出を避ける。
NT_SLUGS = {
    "aoi-aso-jinja", "byodoin", "chusonji", "daigoji", "enryakuji", "fudoin-hiroshima",
    "fukiji", "ginkakuji", "hasedera-nara", "horyuji", "ishiteji", "ishiyamadera",
    "itsukushima-jinja", "iwashimizu-hachimangu", "izumo-taisha", "jodoji-onomichi",
    "kamigamo-jinja", "kamosu-jinja", "kanshinji", "kasuga-taisha", "kibitsu-jinja",
    "kinpusenji", "kitano-tenmangu", "kiyomizu-dera", "kofukuji", "koyasan-kongobuji",
    "kunozan-toshogu", "mitokusan-sanbutsuji", "muroji", "myotsuji", "nikko-toshogu",
    "ninnaji", "osaki-hachimangu", "sanjusangendo", "shimogamo-jinja", "sumiyoshi-taisha",
    "taimadera", "taisanji-matsuyama", "todaiji", "toji", "toshodaiji", "usa-jingu",
    "yakushiji", "yasaka-jinja", "zenkoji", "zuiganji",
}
nt_flagged = []
for s in shrines.values():
    if s["slug"] in NT_SLUGS:
        s["nt"] = True
        nt_flagged.append(s["name"])

# ---- 整合性チェック ----
deity_slugs = set(deities)
orphans = sorted({d for s in shrines.values() for d in s["deities"] if d not in deity_slugs})
bad_gory = sorted({g for d in deities.values() for g in d["goriyaku"] if g not in goriyaku_slugs})
no_deity = [s["slug"] for s in shrines.values() if not s["deities"]]

# 出力
data["deities"] = sorted(deities.values(), key=lambda d: (d["kind"] != "kami", d["slug"]))
data["shrines"] = sorted(shrines.values(), key=lambda s: s["slug"])
json.dump(data, open(APP, "w", encoding="utf-8"), ensure_ascii=False, indent=2)

print("地域別 追加(新規神仏 / 新規社寺):")
for n, nd, ns in report: print(f"  {n:18s} 神仏+{nd:3d}  社寺+{ns:3d}")
print(f"\n合計: ご利益 {len(data['goriyaku'])} / 神仏 {len(data['deities'])} / 社寺 {len(data['shrines'])}")
print(f"孤立deity参照: {orphans if orphans else 'なし'}")
print(f"未定義goriyaku参照: {bad_gory if bad_gory else 'なし'}")
print(f"御祭神未設定の社寺: {len(no_deity)}件" + (f" 例{no_deity[:5]}" if no_deity else ""))
print(f"国宝マーク: {len(nt_flagged)}件 -> {'、'.join(sorted(nt_flagged))}")
