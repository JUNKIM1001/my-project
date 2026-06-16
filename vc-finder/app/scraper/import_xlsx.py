import sys

import openpyxl

from app.db import SessionLocal, Base, engine
from app.models import VC

STAGE_COLUMNS = [
    (4, "シード"),
    (5, "シリーズA"),
    (6, "シリーズB"),
    (7, "シリーズC"),
    (8, "シリーズD以降"),
    (9, "その他"),
]

CVC_CATEGORIES = {"事業会社系"}


def derive_type(category: str) -> str:
    if category in CVC_CATEGORIES:
        return "CVC"
    return "VC"


def import_xlsx(path: str) -> dict:
    Base.metadata.create_all(bind=engine)

    wb = openpyxl.load_workbook(path)
    ws = wb["VCリスト"]

    db = SessionLocal()
    created, updated, skipped = 0, 0, 0

    try:
        for row in ws.iter_rows(min_row=3, values_only=True):
            no = row[0]
            if not isinstance(no, (int, float)):
                continue

            name = row[1]
            if not name or not str(name).strip():
                skipped += 1
                continue
            name = str(name).strip()

            category = row[2]
            founded = row[3]
            founded_year = founded.year if hasattr(founded, "year") else None

            stages = [label for col, label in STAGE_COLUMNS if row[col] not in (None, "")]

            sectors_raw = row[10] or ""
            sectors = [s.strip() for s in str(sectors_raw).split(",") if s.strip()]

            website = row[11]
            entertainment_track_record = row[12] if isinstance(row[12], str) and row[12].strip() == "〇" else None
            recent_entertainment = row[13] if isinstance(row[13], str) and row[13].strip() == "〇" else None
            status = row[14]

            existing = db.query(VC).filter(VC.name == name).first()
            if existing is None:
                vc = VC(
                    name=name,
                    type=derive_type(category),
                    category=category,
                    founded_year=founded_year,
                    website=website,
                    stages=",".join(stages),
                    sectors=",".join(sectors),
                    regions="国内",
                    entertainment_track_record=entertainment_track_record,
                    recent_entertainment_investment=recent_entertainment,
                    status=status,
                    source_url="VCリスト.xlsx",
                )
                db.add(vc)
                created += 1
            else:
                existing.type = derive_type(category)
                existing.category = category
                existing.founded_year = founded_year
                existing.website = website or existing.website
                existing.stages = ",".join(stages)
                existing.sectors = ",".join(sectors)
                existing.entertainment_track_record = entertainment_track_record
                existing.recent_entertainment_investment = recent_entertainment
                existing.status = status
                updated += 1

            db.commit()
    finally:
        db.close()

    return {"created": created, "updated": updated, "skipped": skipped}


if __name__ == "__main__":
    print(import_xlsx(sys.argv[1]))
