from app.db import SessionLocal
from app.models import VC

# 表記ゆれの統一
RENAME_MAP = {
    "エンタープライズソフトウェア・クラウド / SaaS": "エンタープライズソフトウェア・クラウド/SaaS",
    "ソーシャルメディア / SNS": "ソーシャルメディア/SNS",
    "ビッグデータ & アナリティクス": "ビッグデータ&アナリティクス",
    "ブロックチェーン & Web3": "ブロックチェーン&Web3",
    "人工知能・機械学習・生成AI（Generative AI）": "人工知能・機械学習・生成AI（GenerativeAI）",
    "宇宙テクノロジー（Space Tech）": "宇宙テクノロジー（SpaceTech）",
    "教育テッaク（EdTech）": "教育テック（EdTech）",
}

# 値なし扱いにする項目
DROP_VALUES = {"-", "ー"}

# カンマ抜けで複数項目が結合されてしまっているもの -> 分割後の項目リスト
SPLIT_MAP = {
    "サステナビリティテック（ESG/SDGsテック）ビッグデータ & アナリティクス": [
        "サステナビリティテック（ESG/SDGsテック）", "ビッグデータ&アナリティクス",
    ],
    "マーケティング・広告テック（AdTech）デジタルヘルス・ヘルステック（HealthTech）": [
        "マーケティング・広告テック（AdTech）", "デジタルヘルス・ヘルステック（HealthTech）",
    ],
    "メディア・エンターテインメント、輸送・モビリティ": [
        "メディア・エンターテインメント", "輸送・モビリティ",
    ],
    "製造テック（先端製造テック）金融（FinTech）": [
        "製造テック（先端製造テック）", "金融（FinTech）",
    ],
}


def normalize_sectors() -> dict:
    db = SessionLocal()
    updated = 0

    try:
        vcs = db.query(VC).filter(VC.sectors.isnot(None), VC.sectors != "").all()
        for vc in vcs:
            original = [s.strip() for s in vc.sectors.split(",") if s.strip()]
            normalized = []
            for s in original:
                if s in DROP_VALUES:
                    continue
                if s in SPLIT_MAP:
                    normalized.extend(SPLIT_MAP[s])
                    continue
                normalized.append(RENAME_MAP.get(s, s))

            # 重複除去（順序維持）
            seen = set()
            deduped = []
            for s in normalized:
                if s not in seen:
                    seen.add(s)
                    deduped.append(s)

            new_value = ",".join(deduped)
            if new_value != vc.sectors:
                vc.sectors = new_value
                updated += 1

        db.commit()
    finally:
        db.close()

    return {"updated": updated}


if __name__ == "__main__":
    print(normalize_sectors())
