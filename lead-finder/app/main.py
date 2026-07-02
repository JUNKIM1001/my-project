import csv
import io
from typing import Optional

from dotenv import load_dotenv
from fastapi import FastAPI, Depends, UploadFile, File
from fastapi.staticfiles import StaticFiles
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db import get_db, Base, engine, ensure_columns
from app.models import Company, SearchHistory, CompanyProfile
from app.scraper.ai_search import ai_search_companies
from app.scraper.dedupe import build_name_index, find_existing_match, normalize_name
from app.scraper.pitch_reader import build_profile_from_file, build_profile_from_url

load_dotenv()

Base.metadata.create_all(bind=engine)
ensure_columns()

app = FastAPI(title="Lead Finder — 事業会社向け営業リード管理")


@app.get("/api/options")
def get_options(db: Session = Depends(get_db)):
    industries = set()
    for (industry,) in db.query(Company.industry).filter(Company.industry.isnot(None)).all():
        if industry and industry.strip():
            industries.add(industry.strip())
    return {"industries": sorted(industries)}


def _filtered_query(
    db: Session,
    industry: Optional[str],
    keyword: Optional[str],
    scope: Optional[str] = None,
):
    query = db.query(Company)

    # scope:
    #   None / "latest"  → 直近のAI検索でリストアップした結果のみ（既定）
    #   "ai"             → これまでのAI検索でリストアップした全候補
    #   "all"            → 手動登録含む全件
    if scope in (None, "", "latest"):
        latest = db.query(func.max(SearchHistory.id)).scalar()
        query = query.filter(Company.last_search_id == latest)
    elif scope == "ai":
        query = query.filter(Company.last_search_id.isnot(None))
    # "all" はフィルタ無し

    if industry:
        query = query.filter(Company.industry == industry)
    if keyword:
        like = f"%{keyword}%"
        query = query.filter(
            (Company.name.like(like)) | (Company.business.like(like)) | (Company.needs.like(like))
        )

    return query.order_by(Company.score.desc().nullslast(), Company.name)


def _serialize(c: Company) -> dict:
    return {
        "id": c.id,
        "name": c.name,
        "industry": c.industry,
        "business": c.business,
        "employee_scale": c.employee_scale,
        "region": c.region,
        "website": c.website,
        "needs": c.needs.split(",") if c.needs else [],
        "needs_evidence": c.needs_evidence,
        "score": c.score,
        "proposal_points": c.proposal_points.split(",") if c.proposal_points else [],
        "key_person_hint": c.key_person_hint,
        "contact_url": c.contact_url,
        "reason": c.reason,
        "source": c.source,
        "review_status": c.review_status,
        "status": c.status,
        "owner": c.owner,
        "next_action": c.next_action,
        "next_action_due": c.next_action_due,
        "lead_memo": c.lead_memo,
        "lead_registered_at": c.lead_registered_at.isoformat() if c.lead_registered_at else None,
        "sheet_synced_at": c.sheet_synced_at.isoformat() if c.sheet_synced_at else None,
    }


@app.get("/api/companies")
def list_companies(
    industry: Optional[str] = None,
    keyword: Optional[str] = None,
    scope: Optional[str] = None,
    db: Session = Depends(get_db),
):
    results = _filtered_query(db, industry, keyword, scope).all()
    return [_serialize(c) for c in results]


class ManualCompanyRequest(BaseModel):
    name: str
    industry: Optional[str] = None
    website: Optional[str] = None
    business: Optional[str] = None
    as_lead: bool = True  # 手動登録は既知の見込み客であることが多いため、既定で有効リード化


@app.post("/api/companies")
def add_company(req: ManualCompanyRequest, db: Session = Depends(get_db)):
    """展示会・紹介などで得たリードの手動登録。"""
    name = req.name.strip()
    if not name:
        return {"error": "企業名を入力してください"}
    existing = db.query(Company).filter(Company.name == name).first()
    if existing is None:
        index = build_name_index(db)
        existing = find_existing_match(index, name)
    if existing is not None:
        return {"error": f"「{existing.name}」は登録済みです（id={existing.id}）"}

    c = Company(
        name=name,
        industry=req.industry or None,
        website=req.website or None,
        business=req.business or None,
        source="手動登録",
    )
    if req.as_lead:
        c.review_status = "承認"
        c.lead_registered_at = func.now()
        c.status = "未着手"
    db.add(c)
    db.commit()
    return {"id": c.id, "name": c.name, "review_status": c.review_status}


@app.get("/api/companies.csv")
def export_companies_csv(
    industry: Optional[str] = None,
    keyword: Optional[str] = None,
    scope: Optional[str] = None,
    db: Session = Depends(get_db),
):
    results = _filtered_query(db, industry, keyword, scope).all()

    buf = io.StringIO()
    writer = csv.writer(buf)
    writer.writerow([
        "＃", "企業名", "業界", "事業内容", "規模", "有望度",
        "想定ニーズ", "提案ポイント", "ニーズの根拠", "Webサイト", "問い合わせ先", "想定キーパーソン",
    ])
    for i, c in enumerate(results, start=1):
        writer.writerow([
            i,
            c.name,
            c.industry or "",
            c.business or "",
            c.employee_scale or "",
            c.score if c.score is not None else "",
            " / ".join((c.needs or "").split(",")),
            " / ".join((c.proposal_points or "").split(",")),
            c.needs_evidence or "",
            c.website or "",
            c.contact_url or "",
            c.key_person_hint or "",
        ])

    buf.seek(0)
    return StreamingResponse(
        iter([buf.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=lead_list.csv"},
    )


@app.post("/api/company-profile")
async def upload_company_profile(file: UploadFile = File(...), db: Session = Depends(get_db)):
    data = await file.read()
    result = build_profile_from_file(file.filename, data)
    if "error" in result:
        return result

    profile = CompanyProfile(
        filename=file.filename,
        summary=result["summary"],
        raw_text=(result.get("raw_text") or "")[:50000],
    )
    db.add(profile)
    db.commit()
    return {"filename": profile.filename, "summary": profile.summary}


class CompanyProfileUrlRequest(BaseModel):
    url: str


@app.post("/api/company-profile-url")
def upload_company_profile_url(req: CompanyProfileUrlRequest, db: Session = Depends(get_db)):
    result = build_profile_from_url(req.url)
    if "error" in result:
        return result

    profile = CompanyProfile(
        filename=req.url,
        summary=result["summary"],
        raw_text=(result.get("raw_text") or "")[:50000],
    )
    db.add(profile)
    db.commit()
    return {"filename": profile.filename, "summary": profile.summary}


@app.get("/api/company-profile")
def get_company_profile(db: Session = Depends(get_db)):
    profile = db.query(CompanyProfile).order_by(CompanyProfile.created_at.desc()).first()
    if profile is None:
        return {"filename": None, "summary": None}
    return {"filename": profile.filename, "summary": profile.summary}


class AISearchRequest(BaseModel):
    target: str  # 営業ターゲット条件（業界・規模・地域・除外条件など）


@app.post("/api/ai-search")
def ai_search(req: AISearchRequest, db: Session = Depends(get_db)):
    # Step0で読み込んだ自社商材情報 + Step1のターゲット条件 を組み合わせて検索条件を構成
    profile = db.query(CompanyProfile).order_by(CompanyProfile.created_at.desc()).first()
    parts = []
    if profile and profile.summary:
        parts.append("【自社商材情報（営業資料より）】\n" + profile.summary)
    if req.target:
        parts.append("【営業ターゲット条件】\n" + req.target)
    condition = "\n\n".join(parts).strip()

    if not condition:
        return {"error": "自社商材情報（Step0）または営業ターゲット条件（Step1）を入力してください。"}

    result = ai_search_companies(condition)
    if "error" in result:
        return result

    # 先に検索履歴を作成してIDを確定（各候補に紐づける）
    history = SearchHistory(
        condition=req.target or condition,
        result_count=len(result["candidates"]),
        result_names=",".join(c.get("name", "") for c in result["candidates"]),
        raw_response=result.get("raw"),
    )
    db.add(history)
    db.flush()
    search_id = history.id

    name_index = build_name_index(db)
    created, updated = 0, 0
    for c in result["candidates"]:
        name = c.get("name")
        if not name:
            continue

        existing = db.query(Company).filter(Company.name == name).first()
        if existing is None:
            existing = find_existing_match(name_index, name)
        if existing is not None:
            c["matched_existing"] = existing.name
        if existing is None:
            company = Company(
                name=name,
                industry=c.get("industry"),
                business=c.get("business"),
                employee_scale=c.get("employee_scale"),
                region=c.get("region"),
                website=c.get("website"),
                needs=",".join(c.get("needs") or []),
                needs_evidence=c.get("needs_evidence"),
                score=c.get("score"),
                proposal_points=",".join(c.get("proposal_points") or []),
                key_person_hint=c.get("key_person_hint"),
                contact_url=c.get("contact_url"),
                reason=c.get("reason"),
                source_url=c.get("source_url"),
                source="AI検索",
                last_search_id=search_id,
            )
            db.add(company)
            name_index[normalize_name(name)] = company
            created += 1
        else:
            existing.industry = c.get("industry") or existing.industry
            existing.business = c.get("business") or existing.business
            existing.employee_scale = c.get("employee_scale") or existing.employee_scale
            existing.region = c.get("region") or existing.region
            existing.website = c.get("website") or existing.website
            if c.get("needs"):
                existing.needs = ",".join(c["needs"])
            existing.needs_evidence = c.get("needs_evidence") or existing.needs_evidence
            if c.get("score") is not None:
                existing.score = c.get("score")
            if c.get("proposal_points"):
                existing.proposal_points = ",".join(c["proposal_points"])
            existing.key_person_hint = c.get("key_person_hint") or existing.key_person_hint
            existing.contact_url = c.get("contact_url") or existing.contact_url
            existing.reason = c.get("reason") or existing.reason
            existing.source_url = c.get("source_url") or existing.source_url
            existing.last_search_id = search_id
            updated += 1

    db.commit()

    return {"created": created, "updated": updated, "search_id": search_id, "candidates": result["candidates"]}


class ReviewRequest(BaseModel):
    review_status: str  # 承認（=有効リード） / 却下 / 候補


@app.post("/api/companies/{company_id}/review")
def review_company(company_id: int, req: ReviewRequest, db: Session = Depends(get_db)):
    if req.review_status not in ("承認", "却下", "候補"):
        return {"error": "review_status は 承認 / 却下 / 候補 のいずれかを指定してください"}
    c = db.query(Company).filter(Company.id == company_id).first()
    if c is None:
        return {"error": f"id={company_id} の企業が見つかりません"}
    c.review_status = req.review_status
    if req.review_status == "承認":
        if c.lead_registered_at is None:
            c.lead_registered_at = func.now()
        if not c.status:
            c.status = "未着手"
    db.commit()
    return {"id": c.id, "name": c.name, "review_status": c.review_status}


@app.get("/api/leads")
def list_leads(db: Session = Depends(get_db)):
    """有効リード（承認済み）の一覧。営業管理列も含めて返す。"""
    from app.sheets.sync import qualified_leads

    return [_serialize(c) for c in qualified_leads(db)]


@app.get("/api/sheets/info")
def sheets_info():
    from app.sheets.client import get_config

    cfg = get_config()
    return {"configured": cfg["configured"], "url": cfg["url"], "worksheet": cfg["worksheet"]}


@app.post("/api/sheets/setup")
def sheets_setup():
    from app.sheets.client import SheetsConfigError
    from app.sheets.sync import setup_sheet

    try:
        return setup_sheet()
    except SheetsConfigError as e:
        return {"error": str(e)}


@app.post("/api/sheets/push")
def sheets_push(db: Session = Depends(get_db)):
    from app.sheets.client import SheetsConfigError
    from app.sheets.sync import push_leads

    try:
        return push_leads(db)
    except SheetsConfigError as e:
        return {"error": str(e)}


@app.post("/api/sheets/pull")
def sheets_pull(db: Session = Depends(get_db)):
    from app.sheets.client import SheetsConfigError
    from app.sheets.sync import pull_leads

    try:
        return pull_leads(db)
    except SheetsConfigError as e:
        return {"error": str(e)}


@app.get("/api/history")
def list_history(db: Session = Depends(get_db)):
    items = db.query(SearchHistory).order_by(SearchHistory.created_at.desc()).limit(50).all()
    return [
        {
            "id": h.id,
            "condition": h.condition,
            "result_count": h.result_count,
            "result_names": h.result_names.split(",") if h.result_names else [],
            "created_at": h.created_at.isoformat() if h.created_at else None,
        }
        for h in items
    ]


app.mount("/", StaticFiles(directory="app/static", html=True), name="static")
