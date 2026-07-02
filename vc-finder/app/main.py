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
from app.models import VC, SearchHistory, CompanyProfile
from app.scraper.crawler import crawl_seed_vcs, discover_from_list_page
from app.scraper.ai_search import ai_search_vcs
from app.scraper.dedupe import build_name_index, find_existing_match, normalize_name
from app.scraper.pitch_reader import build_profile_from_file, build_profile_from_url

load_dotenv()

Base.metadata.create_all(bind=engine)
ensure_columns()

app = FastAPI(title="VC/CVC Finder")


FIXED_STAGES = ["シード", "シリーズA", "シリーズB", "シリーズC", "シリーズD以降", "その他"]


@app.get("/api/options")
def get_options(db: Session = Depends(get_db)):
    sectors = set()
    categories = set()
    for (sectors_str,) in db.query(VC.sectors).filter(VC.sectors.isnot(None)).all():
        for s in sectors_str.split(","):
            if s.strip():
                sectors.add(s.strip())
    for (cat,) in db.query(VC.category).filter(VC.category.isnot(None)).all():
        if cat and cat.strip():
            categories.add(cat.strip())

    return {
        "stages": FIXED_STAGES,
        "sectors": sorted(sectors),
        "types": ["VC", "CVC"],
        "categories": sorted(categories),
    }


def _filtered_query(
    db: Session,
    type: Optional[str],
    stage: Optional[str],
    sector: Optional[str],
    category: Optional[str],
    entertainment: Optional[bool],
    keyword: Optional[str],
    review_status: Optional[str] = None,
):
    query = db.query(VC)

    # scope（旧 review_status）の値:
    #   None / "latest"  → 直近のAI検索でリストアップした結果のみ（既定）
    #   "ai"             → これまでのAI検索でリストアップした全VC（全期間）
    #   "all"            → 取込済みマスタ含む全件（参照用）
    if review_status in (None, "", "latest"):
        latest = db.query(func.max(SearchHistory.id)).scalar()
        query = query.filter(VC.last_search_id == latest)
    elif review_status == "ai":
        query = query.filter(VC.last_search_id.isnot(None))
    # "all" はフィルタ無し（全件）

    if type:
        query = query.filter(VC.type == type)
    if stage:
        query = query.filter(VC.stages.contains(stage))
    if sector:
        query = query.filter(VC.sectors.contains(sector))
    if category:
        query = query.filter(VC.category == category)
    if entertainment:
        query = query.filter(
            (VC.entertainment_track_record.isnot(None))
            | (VC.recent_entertainment_investment.isnot(None))
        )
    if keyword:
        like = f"%{keyword}%"
        query = query.filter(
            (VC.name.like(like)) | (VC.description.like(like)) | (VC.parent_company.like(like))
        )

    return query.order_by(VC.score.desc().nullslast(), VC.name)


def _serialize(v: VC) -> dict:
    return {
        "id": v.id,
        "name": v.name,
        "type": v.type,
        "category": v.category,
        "founded_year": v.founded_year,
        "parent_company": v.parent_company,
        "website": v.website,
        "description": v.description,
        "stages": v.stages.split(",") if v.stages else [],
        "sectors": v.sectors.split(",") if v.sectors else [],
        "regions": v.regions.split(",") if v.regions else [],
        "entertainment_track_record": bool(v.entertainment_track_record),
        "recent_entertainment_investment": bool(v.recent_entertainment_investment),
        "status": v.status,
        "relevant_assets": v.relevant_assets.split(",") if v.relevant_assets else [],
        "investment_active": v.investment_active,
        "investment_evidence": v.investment_evidence,
        "score": v.score,
        "pitch_points": v.pitch_points.split(",") if v.pitch_points else [],
        "contact_url": v.contact_url,
        "rep_name": v.rep_name,
        "rep_linkedin": v.rep_linkedin,
        "rep_facebook": v.rep_facebook,
        "review_status": v.review_status,
        "owner": v.owner,
        "next_action": v.next_action,
        "next_action_due": v.next_action_due,
        "lead_memo": v.lead_memo,
        "lead_registered_at": v.lead_registered_at.isoformat() if v.lead_registered_at else None,
        "sheet_synced_at": v.sheet_synced_at.isoformat() if v.sheet_synced_at else None,
    }


@app.get("/api/vcs")
def list_vcs(
    type: Optional[str] = None,
    stage: Optional[str] = None,
    sector: Optional[str] = None,
    category: Optional[str] = None,
    entertainment: Optional[bool] = None,
    keyword: Optional[str] = None,
    review_status: Optional[str] = None,
    db: Session = Depends(get_db),
):
    results = _filtered_query(db, type, stage, sector, category, entertainment, keyword, review_status).all()
    return [_serialize(v) for v in results]


@app.get("/api/vcs.csv")
def export_vcs_csv(
    type: Optional[str] = None,
    stage: Optional[str] = None,
    sector: Optional[str] = None,
    category: Optional[str] = None,
    entertainment: Optional[bool] = None,
    keyword: Optional[str] = None,
    review_status: Optional[str] = None,
    db: Session = Depends(get_db),
):
    results = _filtered_query(db, type, stage, sector, category, entertainment, keyword, review_status).all()

    buf = io.StringIO()
    writer = csv.writer(buf)
    writer.writerow([
        "＃", "企業名", "設立年", "主な投資ステージ", "Webサイト",
        "最近の出資、協業ニュース", "リレーション有無", "適合度", "商談提案ポイント", "問い合わせ先",
        "代表者", "代表者LinkedIn", "代表者Facebook",
    ])
    for i, v in enumerate(results, start=1):
        stages = v.stages.split(",") if v.stages else []
        pitch = v.pitch_points.split(",") if v.pitch_points else []
        sns_unknown = not (v.rep_linkedin or v.rep_facebook)
        writer.writerow([
            i,
            v.name,
            v.founded_year or "",
            "・".join(stages),
            v.website or "",
            v.investment_evidence or "",
            "",
            v.score if v.score is not None else "",
            " / ".join(pitch),
            v.contact_url or "",
            v.rep_name or "未確認",
            v.rep_linkedin or ("未確認" if sns_unknown else ""),
            v.rep_facebook or ("未確認" if sns_unknown else ""),
        ])

    buf.seek(0)
    return StreamingResponse(
        iter([buf.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=vc_list.csv"},
    )


@app.post("/api/crawl")
def run_crawl():
    result = crawl_seed_vcs()
    return result


class DiscoverRequest(BaseModel):
    url: str


@app.post("/api/discover")
def discover(req: DiscoverRequest):
    result = discover_from_list_page(req.url)
    return result


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
    needs: str  # Step1: 商談ニーズ（求める出資・協業の内容）
    condition: Optional[str] = None  # 旧: 直接条件指定（後方互換）


@app.post("/api/ai-search")
def ai_search(req: AISearchRequest, db: Session = Depends(get_db)):
    sector_options = get_options(db)["sectors"]

    # Step0で読み込んだ自社事業情報 + Step1の商談ニーズ を組み合わせて検索条件を構成
    profile = db.query(CompanyProfile).order_by(CompanyProfile.created_at.desc()).first()
    parts = []
    if profile and profile.summary:
        parts.append("【自社事業情報（ピッチ資料より）】\n" + profile.summary)
    if req.needs:
        parts.append("【商談ニーズ（求めるVC/CVC・出資/協業の内容）】\n" + req.needs)
    if req.condition:
        parts.append(req.condition)
    condition = "\n\n".join(parts).strip()

    if not condition:
        return {"error": "自社事業情報（Step0）または商談ニーズ（Step1）を入力してください。"}

    result = ai_search_vcs(condition, sector_options=sector_options)
    if "error" in result:
        return result

    # 先に検索履歴を作成してIDを確定（各候補に紐づける）
    history = SearchHistory(
        condition=req.needs or req.condition or condition,
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

        existing = db.query(VC).filter(VC.name == name).first()
        if existing is None:
            existing = find_existing_match(name_index, name, c.get("parent_company"))
        if existing is not None:
            c["matched_existing"] = existing.name
        if existing is None:
            vc = VC(
                name=name,
                type=c.get("type") or "VC",
                parent_company=c.get("parent_company"),
                website=c.get("website"),
                description=c.get("reason"),
                stages=",".join(c.get("stages") or []),
                sectors=",".join(c.get("sectors") or []),
                regions=",".join(c.get("regions") or ["国内"]),
                relevant_assets=",".join(c.get("relevant_assets") or []),
                investment_active="true" if c.get("investment_active") else "false",
                investment_evidence=c.get("investment_evidence"),
                score=c.get("score"),
                pitch_points=",".join(c.get("pitch_points") or []),
                contact_url=c.get("contact_url"),
                rep_name=c.get("rep_name"),
                rep_linkedin=c.get("rep_linkedin"),
                rep_facebook=c.get("rep_facebook"),
                source_url=c.get("source_url"),
                last_search_id=search_id,
            )
            db.add(vc)
            name_index[normalize_name(name)] = vc
            created += 1
        else:
            existing.type = c.get("type") or existing.type
            existing.parent_company = c.get("parent_company") or existing.parent_company
            existing.website = c.get("website") or existing.website
            existing.description = c.get("reason") or existing.description
            if c.get("stages"):
                existing.stages = ",".join(c["stages"])
            if c.get("sectors"):
                existing.sectors = ",".join(c["sectors"])
            if c.get("regions"):
                existing.regions = ",".join(c["regions"])
            if c.get("relevant_assets"):
                existing.relevant_assets = ",".join(c["relevant_assets"])
            existing.investment_active = "true" if c.get("investment_active") else "false"
            existing.investment_evidence = c.get("investment_evidence") or existing.investment_evidence
            if c.get("score") is not None:
                existing.score = c.get("score")
            if c.get("pitch_points"):
                existing.pitch_points = ",".join(c["pitch_points"])
            existing.contact_url = c.get("contact_url") or existing.contact_url
            existing.rep_name = c.get("rep_name") or existing.rep_name
            existing.rep_linkedin = c.get("rep_linkedin") or existing.rep_linkedin
            existing.rep_facebook = c.get("rep_facebook") or existing.rep_facebook
            existing.source_url = c.get("source_url") or existing.source_url
            existing.last_search_id = search_id
            updated += 1

    db.commit()

    return {"created": created, "updated": updated, "search_id": search_id, "candidates": result["candidates"]}


class ReviewRequest(BaseModel):
    review_status: str  # 承認（=有効リード） / 却下 / 候補


@app.post("/api/vcs/{vc_id}/review")
def review_vc(vc_id: int, req: ReviewRequest, db: Session = Depends(get_db)):
    if req.review_status not in ("承認", "却下", "候補"):
        return {"error": "review_status は 承認 / 却下 / 候補 のいずれかを指定してください"}
    vc = db.query(VC).filter(VC.id == vc_id).first()
    if vc is None:
        return {"error": f"id={vc_id} のVCが見つかりません"}
    vc.review_status = req.review_status
    if req.review_status == "承認":
        if vc.lead_registered_at is None:
            vc.lead_registered_at = func.now()
        if not vc.status:
            vc.status = "未着手"
    db.commit()
    return {"id": vc.id, "name": vc.name, "review_status": vc.review_status}


@app.get("/api/leads")
def list_leads(db: Session = Depends(get_db)):
    """有効リード（承認済み）の一覧。営業管理列も含めて返す。"""
    from app.sheets.sync import qualified_leads

    return [_serialize(v) for v in qualified_leads(db)]


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
