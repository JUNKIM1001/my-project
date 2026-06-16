import json
import os
import re
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup

from app.db import SessionLocal, Base, engine
from app.models import VC

SEED_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "data", "seed_vcs.json")

HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; VCFinderBot/0.1; +https://example.com/bot)"
}

STAGE_KEYWORDS = {
    "シード": ["シード", "seed", "プレシリーズa"],
    "アーリー": ["アーリー", "early stage", "シリーズa"],
    "ミドル・レイター": ["ミドル", "レイター", "シリーズb", "シリーズc", "growth", "グロース"],
}

SECTOR_KEYWORDS = {
    "SaaS/IT・ソフトウェア": ["saas", "ソフトウェア", "クラウド", "it ", "デジタル"],
    "AI": ["ai", "人工知能", "機械学習", "生成ai"],
    "フィンテック": ["フィンテック", "fintech", "金融"],
    "ヘルスケア・バイオ": ["ヘルスケア", "医療", "創薬", "バイオ", "healthcare"],
    "ディープテック・製造": ["ディープテック", "deep tech", "ハードウェア", "ロボット", "製造"],
    "コンシューマー・EC": ["コンシューマー", "ec", "小売", "d2c"],
    "エンタメ・メディア": ["エンタメ", "メディア", "コンテンツ", "ゲーム"],
    "モビリティ": ["モビリティ", "自動運転", "mobility"],
    "不動産・建設": ["不動産", "建設", "プロップテック"],
    "食・農業": ["フード", "農業", "アグリ", "food"],
}


def fetch_text(url: str) -> str:
    try:
        resp = requests.get(url, headers=HEADERS, timeout=10)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")
        for tag in soup(["script", "style", "header", "footer", "nav"]):
            tag.decompose()
        text = soup.get_text(separator=" ")
        text = re.sub(r"\s+", " ", text)
        return text
    except Exception as e:
        return f"__ERROR__: {e}"


def detect_keywords(text: str, keyword_map: dict) -> list:
    lowered = text.lower()
    found = []
    for label, keywords in keyword_map.items():
        for kw in keywords:
            if kw.lower() in lowered:
                found.append(label)
                break
    return found


def make_description(text: str, limit: int = 300) -> str:
    if text.startswith("__ERROR__"):
        return ""
    return text[:limit]


def crawl_seed_vcs() -> dict:
    Base.metadata.create_all(bind=engine)

    with open(SEED_PATH, encoding="utf-8") as f:
        seeds = json.load(f)

    db = SessionLocal()
    created, updated, failed = 0, 0, 0

    try:
        for seed in seeds:
            text = fetch_text(seed["website"])

            if text.startswith("__ERROR__"):
                failed += 1
                stages, sectors, description = [], [], ""
            else:
                stages = detect_keywords(text, STAGE_KEYWORDS)
                sectors = detect_keywords(text, SECTOR_KEYWORDS)
                description = make_description(text)

            existing = db.query(VC).filter(VC.name == seed["name"]).first()
            if existing is None:
                vc = VC(
                    name=seed["name"],
                    type=seed["type"],
                    parent_company=seed.get("parent_company"),
                    website=seed["website"],
                    description=description,
                    stages=",".join(stages),
                    sectors=",".join(sectors),
                    regions="国内",
                    source_url=seed["website"],
                )
                db.add(vc)
                created += 1
            else:
                existing.type = seed["type"]
                existing.parent_company = seed.get("parent_company")
                existing.website = seed["website"]
                if description:
                    existing.description = description
                if stages:
                    existing.stages = ",".join(stages)
                if sectors:
                    existing.sectors = ",".join(sectors)
                existing.source_url = seed["website"]
                updated += 1

            db.commit()
    finally:
        db.close()

    return {"created": created, "updated": updated, "failed": failed, "total": len(seeds)}


EXCLUDE_DOMAINS = [
    "twitter.com", "x.com", "facebook.com", "instagram.com", "youtube.com",
    "linkedin.com", "note.com", "google.com", "apple.com", "play.google.com",
    "github.com",
]

EXCLUDE_TEXT_PATTERNS = [
    "プライバシー", "利用規約", "お問い合わせ", "サイトマップ", "cookie", "privacy",
    "terms", "contact", "ホーム", "トップ", "採用", "recruit", "ニュース", "news",
    "ブログ", "blog", "english", "日本語",
]

MAX_DISCOVER = 25


def fetch_soup(url: str):
    resp = requests.get(url, headers=HEADERS, timeout=10)
    resp.raise_for_status()
    return BeautifulSoup(resp.text, "lxml")


def discover_from_list_page(list_url: str) -> dict:
    Base.metadata.create_all(bind=engine)

    soup = fetch_soup(list_url)

    candidates = []
    seen_domains = set()
    for a in soup.find_all("a", href=True):
        text = a.get_text(strip=True)
        href = a["href"]
        if not text or len(text) < 2:
            continue
        if any(p.lower() in text.lower() for p in EXCLUDE_TEXT_PATTERNS):
            continue

        absolute = urljoin(list_url, href)
        parsed = urlparse(absolute)
        if parsed.scheme not in ("http", "https"):
            continue

        domain = parsed.netloc.lower()
        if any(domain.endswith(d) for d in EXCLUDE_DOMAINS):
            continue
        if urlparse(list_url).netloc.lower() == domain:
            # internal link on the list page itself, not an external VC site
            continue
        if domain in seen_domains:
            continue
        seen_domains.add(domain)

        candidates.append({"name": text, "website": f"{parsed.scheme}://{parsed.netloc}"})

        if len(candidates) >= MAX_DISCOVER:
            break

    db = SessionLocal()
    created, updated, failed = 0, 0, 0

    try:
        for cand in candidates:
            text = fetch_text(cand["website"])
            if text.startswith("__ERROR__"):
                failed += 1
                stages, sectors, description = [], [], ""
            else:
                stages = detect_keywords(text, STAGE_KEYWORDS)
                sectors = detect_keywords(text, SECTOR_KEYWORDS)
                description = make_description(text)

            existing = db.query(VC).filter(VC.website == cand["website"]).first()
            if existing is None:
                vc = VC(
                    name=cand["name"],
                    type="VC",
                    parent_company=None,
                    website=cand["website"],
                    description=description,
                    stages=",".join(stages),
                    sectors=",".join(sectors),
                    regions="国内",
                    source_url=list_url,
                )
                db.add(vc)
                created += 1
            else:
                if description:
                    existing.description = description
                if stages:
                    existing.stages = ",".join(stages)
                if sectors:
                    existing.sectors = ",".join(sectors)
                updated += 1

            db.commit()
    finally:
        db.close()

    return {"found": len(candidates), "created": created, "updated": updated, "failed": failed}


if __name__ == "__main__":
    print(crawl_seed_vcs())
