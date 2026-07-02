#!/usr/bin/env python3
"""正準データ data/appdata.json から各アプリ向けの配布ファイルを生成する。

- iOS:  ios/ShrineFinder/Resources/appdata.json  (全項目・ミニファイ)
- Web:  ../shrine-finder-web/public/appdata.json          (longDescription抜き・ミニファイ)
        ../shrine-finder-web/public/appdata-details.json  (slug→longDescription)

データを編集したら data/appdata.json を直し、このスクリプトを実行すること。
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CANONICAL = os.path.join(ROOT, "data/appdata.json")
IOS_OUT = os.path.join(ROOT, "ios/ShrineFinder/Resources/appdata.json")
WEB_DIR = os.path.join(os.path.dirname(ROOT), "shrine-finder-web/public")
WEB_OUT = os.path.join(WEB_DIR, "appdata.json")
WEB_DETAILS_OUT = os.path.join(WEB_DIR, "appdata-details.json")


def dump(obj, path):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, separators=(",", ":"))
    print(f"  {os.path.relpath(path, ROOT)}: {os.path.getsize(path):,} bytes")


def validate(data):
    """slug重複・参照切れを検出したら同期を中断する。"""
    errors = []
    for kind in ("goriyaku", "deities", "shrines"):
        slugs = [x["slug"] for x in data[kind]]
        dupes = {s for s in slugs if slugs.count(s) > 1}
        if dupes:
            errors.append(f"{kind}: slug重複 {sorted(dupes)}")
    goriyaku = {g["slug"] for g in data["goriyaku"]}
    deities = {d["slug"] for d in data["deities"]}
    for d in data["deities"]:
        for g in d["goriyaku"]:
            if g not in goriyaku:
                errors.append(f"deity {d['slug']}: 不明なご利益 {g}")
    for s in data["shrines"]:
        for ds in s["deities"]:
            if ds not in deities:
                errors.append(f"shrine {s['slug']}: 不明な神仏 {ds}")
        for g in s.get("goriyaku", []):
            if g not in goriyaku:
                errors.append(f"shrine {s['slug']}: 不明なご利益 {g}")
    if errors:
        print("検証エラー:", *errors, sep="\n  ")
        sys.exit(1)


def main():
    with open(CANONICAL, encoding="utf-8") as f:
        data = json.load(f)
    validate(data)

    print("iOS:")
    dump(data, IOS_OUT)

    print("Web:")
    light = {
        "goriyaku": data["goriyaku"],
        "deities": data["deities"],
        "shrines": [
            {k: v for k, v in s.items() if k != "longDescription"}
            for s in data["shrines"]
        ],
    }
    dump(light, WEB_OUT)
    details = {
        "shrines": {
            s["slug"]: s["longDescription"]
            for s in data["shrines"]
            if s.get("longDescription")
        }
    }
    dump(details, WEB_DETAILS_OUT)


if __name__ == "__main__":
    main()
