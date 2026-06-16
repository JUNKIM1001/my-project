from sqlalchemy.orm import Session

from app.models import VC

_STRIP_TOKENS = [
    "株式会社", "合同会社", "（株）", "(株)",
    "co., ltd.", "co.,ltd.", "co.,ltd", "co., ltd",
    "inc.", "inc", "l.p.", "lp",
    "、", "　", " ", "(", ")", "（", "）", "・", "ー", "-",
]


def normalize_name(name: str) -> str:
    if not name:
        return ""
    n = name.strip().lower()
    for tok in _STRIP_TOKENS:
        n = n.replace(tok, "")
    return n


def build_name_index(db: Session) -> dict:
    index = {}
    for v in db.query(VC).all():
        key = normalize_name(v.name)
        if key and key not in index:
            index[key] = v
    return index


def find_existing_match(index: dict, name: str, parent_company: str = None) -> VC:
    for candidate in (name, parent_company):
        key = normalize_name(candidate)
        if key and key in index:
            return index[key]
    return None
