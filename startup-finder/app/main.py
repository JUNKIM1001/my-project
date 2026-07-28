import csv
import io
import json
import os
import re
import sys
import time
import traceback
import urllib.parse
from datetime import date, datetime
from typing import Optional

from fastapi import Depends, FastAPI, HTTPException, Query, Request, Response
from fastapi.responses import FileResponse, JSONResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from sqlalchemy import or_, text
from sqlalchemy.orm import Session

from app.auth import (
    SESSION_COOKIE, SESSION_DAYS, create_session, delete_session,
    get_user_by_token, verify_password,
)
from app.db import IS_POSTGRES, Base, SessionLocal, engine, get_db
from app.models import AccessLog, Company

# ローカルSQLiteは起動時にスキーマを作る。Postgres(本番)はコールドスタートの
# たびに問い合わせが増えて遅くなるため行わない（スキーマ作成・更新は
# app/scripts/migrate_to_postgres.py が担当。テーブル追加時は再実行すること）。
if not IS_POSTGRES:
    Base.metadata.create_all(bind=engine)

# 既存SQLite DBへの追いつきマイグレーション（不足カラムのみ追加）。
# Postgres（Supabase）は create_all が全カラム込みで作るため不要。
if engine.dialect.name == "sqlite":
    with engine.connect() as _conn:
        _cols = [r[1] for r in _conn.execute(text("PRAGMA table_info(companies)"))]
        for _col in ("contact_url", "rep_linkedin", "rep_x", "rep_facebook"):
            if _col not in _cols:
                _conn.execute(text("ALTER TABLE companies ADD COLUMN %s VARCHAR" % _col))
        _cols = [r[1] for r in _conn.execute(text("PRAGMA table_info(access_logs)"))]
        for _col, _typ in (("params", "VARCHAR"), ("result_count", "INTEGER"), ("company_id", "INTEGER")):
            if _cols and _col not in _cols:
                _conn.execute(text("ALTER TABLE access_logs ADD COLUMN %s %s" % (_col, _typ)))
        # ログイン制限がIPで引くのでインデックスを張る
        _conn.execute(text("CREATE INDEX IF NOT EXISTS ix_access_logs_ip ON access_logs (ip)"))
        _conn.commit()

app = FastAPI(title="Startup Finder — 国内スタートアップDB")

STATIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "static")
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


# ===== アクセスログ =====

# ページ表示ごとに必ず飛ぶノイズ系APIは記録しない
LOG_SKIP_PATHS = {"/api/me", "/api/meta", "/favicon.ico"}


def client_ip(request: Request):
    """接続元IP。詐称できないプロキシヘッダを優先する。

    x-vercel-forwarded-for / x-real-ip はプラットフォームが付与するので信頼できる。
    x-forwarded-for はクライアントが自由に足せるため、直近プロキシが追記する
    「最も右の値」を採る（左端はクライアント由来の偽装値になりうる）。
    ※ログイン制限の土台になるので、プロキシ配下で運用すること。
    """
    for header in ("x-vercel-forwarded-for", "x-real-ip"):
        value = request.headers.get(header)
        if value:
            return value.split(",")[0].strip()
    fwd = request.headers.get("x-forwarded-for")
    if fwd:
        return fwd.split(",")[-1].strip()
    return request.client.host if request.client else None


def action_for(path: str) -> str:
    if path == "/":
        return "page_view"
    if path == "/api/companies":
        return "search"
    if re.fullmatch(r"/api/companies/\d+", path):
        return "detail"
    if path == "/api/synergy":
        return "synergy_search"
    if path == "/api/trends":
        return "trends_view"
    if path == "/api/compare/analyze":
        return "compare_ai"
    if path == "/api/compare":
        return "compare"
    if path == "/api/export.csv":
        return "csv_export"
    if path == "/api/logout":
        return "logout"
    if path.startswith("/api/logs"):
        return "log_view"
    return "other"


# インクリメンタル検索の入力途中断片（"生"→"生成"→"生成AI"）を1行に集約する猶予秒数
SEARCH_COLLAPSE_SEC = 60


def log_access(request: Request, username, action, status, info=None):
    """1操作を1行記録する。ログ失敗で本処理を落とさない。

    info はエンドポイントが request.state.log_info に載せた構造化情報:
      keyword（検索語・社名）/ params（絞り込み条件）/ result_count / company_id
    """
    try:
        info = info or {}
        if info.get("skip"):
            return  # 追加読み込みなど、分析対象にしない操作
        db = getattr(request.state, "db", None)  # リクエスト共有の接続を使う
        if db is None:
            return
        try:
            path = request.url.path
            keyword = info.get("keyword")
            if keyword is None and "keyword" not in info and request.url.query:
                # エンドポイントが情報を載せなかった場合（401等）の素朴なフォールバック
                keyword = urllib.parse.unquote_plus(str(request.url.query))
            now = datetime.now().astimezone()
            ip = client_ip(request)

            if action == "search" and keyword:
                # 直前の自分の検索の打ちかけ（前方一致）なら新規行にせず上書きする
                prev = (
                    db.query(AccessLog)
                    .filter(AccessLog.action == "search",
                            AccessLog.username == username,
                            AccessLog.ip == ip)
                    .order_by(AccessLog.id.desc())
                    .first()
                )
                if prev and prev.keywords and (
                    keyword.startswith(prev.keywords) or prev.keywords.startswith(keyword)
                ):
                    try:
                        recent = (now - datetime.fromisoformat(prev.ts)).total_seconds() <= SEARCH_COLLAPSE_SEC
                    except ValueError:
                        recent = False
                    if recent:
                        prev.ts = now.isoformat(timespec="seconds")
                        prev.keywords = keyword
                        prev.params = info.get("params")
                        prev.result_count = info.get("result_count")
                        prev.status = status
                        db.commit()
                        return

            db.add(AccessLog(
                ts=now.isoformat(timespec="seconds"),
                ip=ip,
                username=username,
                action=action,
                keywords=keyword or None,
                params=info.get("params"),
                result_count=info.get("result_count"),
                company_id=info.get("company_id"),
                method=request.method,
                path=path,
                status=status,
            ))
            db.commit()
        except Exception:
            db.rollback()  # 共有セッションを壊れたまま残さない
            raise
    except Exception:
        # 本処理は落とさないが、黙って握りつぶすと障害調査ができないので
        # stderr（Vercelの関数ログに出る）へは残す
        print("[access-log] write failed: %s" % traceback.format_exc(limit=3),
              file=sys.stderr)


# ===== 認証 =====

@app.middleware("http")
async def auth_middleware(request: Request, call_next):
    path = request.url.path
    if path.startswith("/static"):
        return await call_next(request)

    # 認証・本処理・アクセスログでDBセッションを1本だけ共有する。
    # 遠隔DBでは接続の確立が最も高くつくので、本数を増やさないことが効く。
    db = SessionLocal()
    request.state.db = db
    try:
        if path == "/api/login":
            # ログイン試行はエンドポイント内で成否・ユーザー名込みで記録する
            return await call_next(request)
        user = get_user_by_token(db, request.cookies.get(SESSION_COOKIE))
        if user is None:
            if path.startswith("/api/"):
                if path not in LOG_SKIP_PATHS:
                    log_access(request, None, action_for(path), 401)
                return JSONResponse({"detail": "unauthorized"}, status_code=401)
            return FileResponse(os.path.join(STATIC_DIR, "login.html"))
        request.state.user = user
        response = await call_next(request)
        if path not in LOG_SKIP_PATHS:
            log_access(request, user.username, action_for(path), response.status_code,
                       info=getattr(request.state, "log_info", None))
        return response
    finally:
        db.close()


class LoginBody(BaseModel):
    username: str
    password: str


# 総当たり対策: 同一IPからの連続失敗を一定時間ブロックする
LOGIN_WINDOW_MIN = 15     # 失敗を数える時間窓（分）
LOGIN_MAX_FAILURES = 5    # 窓内でこの回数失敗したらブロック


def login_block_seconds(db: Session, ip):
    """同一IPがブロック中なら解除までの残り秒数を返す（0ならログイン試行を許可）。

    直近の成功ログインより後の失敗だけを数えるため、一度ログインできれば解除される。
    ブロック中の試行はパスワード照合前に弾いて失敗として数えないので、
    時間の経過とともに自然に解除される（永久ロックにはならない）。
    """
    if not ip:
        return 0
    now = datetime.now().astimezone()
    rows = (
        db.query(AccessLog)
        .filter(AccessLog.ip == ip, AccessLog.action.in_(("login", "login_failed")))
        .order_by(AccessLog.id.desc())
        .limit(50)
        .all()
    )
    recent_failures = []
    for r in rows:
        if r.action == "login":
            break  # 成功にぶつかったら以前の失敗は無かったことにする
        try:
            t = datetime.fromisoformat(r.ts)
        except (ValueError, TypeError):
            continue
        if (now - t).total_seconds() <= LOGIN_WINDOW_MIN * 60:
            recent_failures.append(t)
    if len(recent_failures) < LOGIN_MAX_FAILURES:
        return 0
    # 最も古い失敗が時間窓から外れれば解除
    remain = LOGIN_WINDOW_MIN * 60 - (now - min(recent_failures)).total_seconds()
    return max(1, int(remain))


@app.post("/api/login")
def login(body: LoginBody, request: Request, response: Response, db: Session = Depends(get_db)):
    from app.models import User
    wait = login_block_seconds(db, client_ip(request))
    if wait:
        # パスワード照合前に弾く（この試行は失敗として数えない＝時間で自然解除）
        log_access(request, body.username.strip(), "login_blocked", 429)
        raise HTTPException(
            429,
            "ログインの失敗が続いたため一時的にロックしました。約%d分後にお試しください。"
            % max(1, round(wait / 60)),
            headers={"Retry-After": str(wait)},
        )
    user = db.query(User).filter(User.username == body.username.strip()).first()
    if user is None or not verify_password(body.password, user.password_hash):
        log_access(request, body.username.strip(), "login_failed", 401)
        time.sleep(0.5)  # 総当たり対策の軽い減速
        raise HTTPException(401, "ユーザー名またはパスワードが違います")
    log_access(request, user.username, "login", 200)
    token = create_session(db, user)
    response.set_cookie(
        SESSION_COOKIE, token,
        httponly=True, samesite="lax", max_age=SESSION_DAYS * 86400,
    )
    return {"username": user.username, "display_name": user.display_name}


@app.post("/api/logout")
def logout(request: Request, response: Response, db: Session = Depends(get_db)):
    delete_session(db, request.cookies.get(SESSION_COOKIE))
    response.delete_cookie(SESSION_COOKIE)
    return {"ok": True}


@app.get("/api/me")
def me(request: Request):
    u = request.state.user
    return {"username": u.username, "display_name": u.display_name}


@app.get("/")
def index():
    return FileResponse(os.path.join(STATIC_DIR, "index.html"))


# 資金調達シグナル: 直近ラウンドからこの範囲の月数が経過した存続企業に立てる
SIGNAL_MIN_MONTHS = 12
SIGNAL_MAX_MONTHS = 36


def months_since_ym(ym):
    """'YYYY-MM'（末尾に日付があっても可）から現在までの経過月数。不正はNone。"""
    if not ym or not re.match(r"^\d{4}-\d{2}", str(ym)):
        return None
    y, m = int(str(ym)[:4]), int(str(ym)[5:7])
    t = date.today()
    return (t.year - y) * 12 + (t.month - m)


def has_funding_signal(c):
    m = months_since_ym(c.last_round_date)
    return bool(
        c.status == "active" and m is not None
        and SIGNAL_MIN_MONTHS <= m < SIGNAL_MAX_MONTHS
    )


def ym_before(months):
    """今日からmonthsヶ月前の 'YYYY-MM' 文字列。"""
    t = date.today()
    total = t.year * 12 + (t.month - 1) - months
    return "%04d-%02d" % (total // 12, total % 12 + 1)


def safe_json_list(value):
    """JSONカラムの破損でAPI全体が落ちないよう、失敗時は空リストを返す。"""
    try:
        v = json.loads(value) if value else []
        return v if isinstance(v, list) else []
    except (ValueError, TypeError):
        return []


def to_dict(c: Company, detail: bool = False):
    d = {
        "id": c.id,
        "name": c.name,
        "website": c.website,
        "founded_year": c.founded_year,
        "hq": c.hq,
        "representative": c.representative,
        "description": c.description,
        "sectors": [s for s in (c.sectors or "").split(",") if s],
        "stage": c.stage,
        "total_raised_oku": c.total_raised_oku,
        "valuation_oku": c.valuation_oku,
        "investors": [s for s in (c.investors or "").split(",") if s],
        "awards": [
            a if isinstance(a, dict) else {"event": str(a), "year": None, "result": None}
            for a in safe_json_list(c.awards)
        ],
        "status": c.status,
        "status_note": c.status_note,
        "last_round_date": c.last_round_date,
        "last_round_amount_oku": c.last_round_amount_oku,
        "months_since_last_round": months_since_ym(c.last_round_date),
        "funding_signal": has_funding_signal(c),
    }
    if detail:
        d.update({
            "valuation_source": c.valuation_source,
            "last_round": {
                "date": c.last_round_date,
                "round": c.last_round_name,
                "amount_oku": c.last_round_amount_oku,
                "investors": [s for s in (c.last_round_investors or "").split(",") if s],
            },
            "partners": [s for s in (c.partners or "").split(",") if s],
            "employee_count": c.employee_count,
            "sources": safe_json_list(c.sources),
            "last_verified": c.last_verified,
            "themes": [s for s in (c.themes or "").split(",") if s],
            "contact_url": c.contact_url,
            "rep_linkedin": c.rep_linkedin,
            "rep_x": c.rep_x,
            "rep_facebook": c.rep_facebook,
        })
    return d


@app.get("/api/meta")
def meta(db: Session = Depends(get_db)):
    # 集計に必要な列だけ取り出す（全カラムのORMオブジェクトを1846件作らない）
    rows = db.query(
        Company.sectors, Company.stage, Company.status,
        Company.valuation_oku, Company.last_round_date,
    ).all()
    sectors = {}
    stages = {}
    statuses = {}
    with_valuation = 0
    with_signal = 0
    for sec, stage, status, valuation, last_round in rows:
        for s in (sec or "").split(","):
            s = s.strip()
            if s:
                sectors[s] = sectors.get(s, 0) + 1
        if stage:
            stages[stage] = stages.get(stage, 0) + 1
        statuses[status] = statuses.get(status, 0) + 1
        if valuation:
            with_valuation += 1
        months = months_since_ym(last_round)
        if status == "active" and months is not None and SIGNAL_MIN_MONTHS <= months < SIGNAL_MAX_MONTHS:
            with_signal += 1
    return {
        "total": len(rows),
        "sectors": sorted(sectors.items(), key=lambda x: -x[1]),
        "stages": sorted(stages.items(), key=lambda x: -x[1]),
        "statuses": statuses,
        "with_valuation": with_valuation,
        "with_signal": with_signal,
        "signal_months": [SIGNAL_MIN_MONTHS, SIGNAL_MAX_MONTHS],
    }


@app.get("/api/companies")
def list_companies(
    request: Request,
    q: Optional[str] = None,
    sector: Optional[str] = None,
    stage: Optional[str] = None,
    status: Optional[str] = None,
    investor: Optional[str] = None,
    min_raised: Optional[float] = None,
    has_valuation: bool = False,
    has_award: bool = False,
    has_signal: bool = False,
    sort: str = Query("total_raised_oku", pattern="^(total_raised_oku|valuation_oku|founded_year|name|last_round_date)$"),
    order: str = Query("desc", pattern="^(asc|desc)$"),
    limit: int = Query(100, ge=1, le=2000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    query = db.query(Company)
    if q:
        for term in re.split(r"[\s　,、]+", q.strip()):
            if not term:
                continue
            like = "%" + term + "%"
            # ilike: Postgres/SQLiteの双方で英字の大文字小文字を無視した部分一致にする
            query = query.filter(or_(
                Company.name.ilike(like),
                Company.description.ilike(like),
                Company.sectors.ilike(like),
                Company.investors.ilike(like),
                Company.partners.ilike(like),
                Company.hq.ilike(like),
            ))
    if sector:
        query = query.filter(Company.sectors.ilike("%" + sector + "%"))
    if stage:
        query = query.filter(Company.stage == stage)
    if status:
        query = query.filter(Company.status == status)
    if investor:
        query = query.filter(Company.investors.ilike("%" + investor + "%"))
    if min_raised is not None:
        query = query.filter(Company.total_raised_oku >= min_raised)
    if has_valuation:
        query = query.filter(Company.valuation_oku.isnot(None))
    if has_award:
        query = query.filter(Company.awards.isnot(None))
    if has_signal:
        # 直近ラウンドが12〜36ヶ月前の存続企業（YYYY-MM形式の文字列比較で範囲判定）
        query = query.filter(
            Company.status == "active",
            Company.last_round_date > ym_before(SIGNAL_MAX_MONTHS),
            Company.last_round_date <= ym_before(SIGNAL_MIN_MONTHS),
        )

    # 並び順はSQLで確定させる（nullslast: NULLの位置はSQLite/Postgresで既定が異なる）。
    # idを第2キーにするのは、同値の行がページ間で入れ替わって重複・欠落するのを防ぐため。
    col = getattr(Company, sort)
    query = query.order_by(
        col.asc().nullslast() if order == "asc" else col.desc().nullslast(),
        Company.id.asc(),
    )

    total = query.count()
    companies = query.offset(offset).limit(limit).all()

    # アクセスログ用: 検索語と絞り込み条件を分離して渡す（sort/orderは分析ノイズなので除く）。
    # 2ページ目以降は「追加読み込み」であって新しい検索意図ではないので記録しない。
    if offset:
        request.state.log_info = {"skip": True}
    else:
        filters = [("sector", sector), ("stage", stage), ("status", status), ("investor", investor),
                   ("min_raised", min_raised), ("has_valuation", has_valuation or None),
                   ("has_award", has_award or None), ("has_signal", has_signal or None)]
        request.state.log_info = {
            "keyword": (q or "").strip() or None,
            "params": ", ".join("%s=%s" % (k, v) for k, v in filters if v is not None) or None,
            "result_count": total,
        }
    return {
        "count": total,
        "items": [to_dict(c) for c in companies],
        "offset": offset,
        "limit": limit,
        "has_more": offset + len(companies) < total,
    }


@app.get("/api/companies/{company_id}")
def get_company(company_id: int, request: Request, db: Session = Depends(get_db)):
    c = db.get(Company, company_id)
    if not c:
        raise HTTPException(404, "not found")
    # アクセスログ用: どの企業が閲覧されたか（IDは社名変更に耐える集計キー）
    request.state.log_info = {"keyword": c.name, "company_id": c.id}
    return to_dict(c, detail=True)


@app.get("/api/trends")
def trends(db: Session = Depends(get_db)):
    """トレンド分析用の軽量データセット。集計・描画はフロント側で行う。

    1社1行・描画に必要な列だけ返す（バブルチャート/散布図の軸切り替えを
    クライアントで自由にできるよう、集計前の素データを渡す設計）。
    """
    rows = db.query(
        Company.id, Company.name, Company.sectors, Company.stage, Company.status,
        Company.founded_year, Company.total_raised_oku, Company.valuation_oku,
        Company.last_round_date, Company.last_round_name, Company.last_round_amount_oku,
    ).all()
    items = []
    for r in rows:
        items.append({
            "id": r[0], "name": r[1],
            "sectors": [s.strip() for s in (r[2] or "").split(",") if s.strip()],
            "stage": r[3], "status": r[4], "founded_year": r[5],
            "total_raised_oku": r[6], "valuation_oku": r[7],
            "last_round_date": r[8], "last_round_name": r[9],
            "last_round_amount_oku": r[10],
        })
    return {"count": len(items), "items": items}


class CompareBody(BaseModel):
    ids: list[int]


def load_compare_companies(body: CompareBody, db: Session):
    if not (2 <= len(set(body.ids)) <= 6):
        raise HTTPException(422, "比較は2〜6社を選択してください")
    companies = db.query(Company).filter(Company.id.in_(body.ids)).all()
    if len(companies) != len(set(body.ids)):
        raise HTTPException(404, "存在しない企業IDが含まれています")
    order = {cid: i for i, cid in enumerate(body.ids)}
    return sorted(companies, key=lambda c: order[c.id])


@app.post("/api/compare")
def compare(body: CompareBody, request: Request, db: Session = Depends(get_db)):
    """選択企業の事実比較データ（詳細フィールド一式）を返す。"""
    companies = load_compare_companies(body, db)
    request.state.log_info = {"keyword": " vs ".join(c.name for c in companies)}
    return {"items": [to_dict(c, detail=True) for c in companies]}


@app.post("/api/compare/analyze")
def compare_analyze(body: CompareBody, request: Request, db: Session = Depends(get_db)):
    """KSF・ビジネスモデル・優位性のAI比較分析（Gemini・仮説として返す）。"""
    from app.analysis import analyze_companies
    companies = load_compare_companies(body, db)
    request.state.log_info = {"keyword": " vs ".join(c.name for c in companies)}
    result = analyze_companies(companies)
    if "error" in result:
        raise HTTPException(502, result["error"])
    return result


@app.get("/api/synergy")
def synergy(
    request: Request,
    assets: str = Query(..., description="自社のアセット・テーマをキーワードで（空白区切り）"),
    include_inactive: bool = False,
    db: Session = Depends(get_db),
):
    """自社アセット・テーマとのシナジー候補をキーワードマッチで採点する。

    sectors一致=3点、description一致=2点、partners/investors一致=1点。
    """
    terms = [t for t in re.split(r"[\s　,、/]+", assets.strip()) if len(t) >= 2]
    if not terms:
        return {"count": 0, "items": []}
    results = []
    for c in db.query(Company).all():
        if not include_inactive and c.status == "closed":
            continue
        score = 0
        hits = []
        text_sectors = c.sectors or ""
        text_desc = (c.description or "") + " " + (c.name or "")
        text_rel = (c.partners or "") + " " + (c.investors or "")
        for t in terms:
            if t in text_sectors:
                score += 3
                hits.append(t + "（分野）")
            elif t in text_desc:
                score += 2
                hits.append(t + "（事業内容）")
            elif t in text_rel:
                score += 1
                hits.append(t + "（提携・株主）")
        if score > 0:
            d = to_dict(c)
            d["synergy_score"] = score
            d["synergy_hits"] = hits
            results.append(d)
    results.sort(key=lambda x: -x["synergy_score"])
    request.state.log_info = {
        "keyword": assets.strip() or None,
        "params": "include_inactive=True" if include_inactive else None,
        "result_count": len(results),
    }
    return {"count": len(results), "items": results[:100]}


def csv_safe(v):
    """Excel等での数式インジェクション対策: 危険な先頭文字にはクォートを付ける。"""
    if v is None:
        return v
    s = str(v)
    # 先頭の空白を除いた位置の危険文字も対象にする（" =SUM(...)" 対策）
    if s.lstrip() and s.lstrip()[0] in "=+-@\t\r\n":
        return "'" + s
    return s


@app.get("/api/export.csv")
def export_csv(db: Session = Depends(get_db)):
    buf = io.StringIO()
    w = csv.writer(buf)
    w.writerow([
        "企業名", "分野", "ステージ", "設立年", "所在地", "代表者", "事業内容",
        "累計調達額(億円)", "評価額(億円)", "評価額出典", "直近ラウンド", "直近調達額(億円)",
        "主要株主・投資家", "提携先", "受賞歴", "ステータス", "備考", "従業員数",
        "Webサイト", "問い合わせ", "代表LinkedIn", "代表X", "代表Facebook",
        "出典URL", "最終確認",
    ])
    status_ja = {"active": "存続", "ipo": "IPO済", "ma": "M&A済", "closed": "倒産・解散"}
    for c in db.query(Company).order_by(Company.total_raised_oku.desc().nullslast()).all():
        awards_str = " / ".join(
            "%s %s %s" % (a.get("event", ""), a.get("year", ""), a.get("result", ""))
            if isinstance(a, dict) else str(a)
            for a in safe_json_list(c.awards)
        )
        sources = safe_json_list(c.sources)
        w.writerow([csv_safe(v) for v in (
            c.name, c.sectors, c.stage, c.founded_year, c.hq, c.representative,
            c.description, c.total_raised_oku, c.valuation_oku, c.valuation_source,
            "%s %s" % (c.last_round_date or "", c.last_round_name or ""),
            c.last_round_amount_oku, c.investors, c.partners, awards_str,
            status_ja.get(c.status, c.status), c.status_note, c.employee_count,
            c.website, c.contact_url, c.rep_linkedin, c.rep_x, c.rep_facebook,
            " ".join(str(s) for s in sources), c.last_verified,
        )])
    buf.seek(0)
    return StreamingResponse(
        iter([("﻿" + buf.getvalue()).encode("utf-8")]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=startups.csv"},
    )


# ===== アクセスログの照会・月次保存 =====

def log_to_dict(r: AccessLog):
    return {
        "id": r.id, "ts": r.ts, "ip": r.ip, "username": r.username,
        "action": r.action, "keywords": r.keywords, "params": r.params,
        "result_count": r.result_count, "company_id": r.company_id,
        "method": r.method, "path": r.path, "status": r.status,
    }


@app.get("/api/logs")
def list_logs(
    month: Optional[str] = Query(None, pattern=r"^\d{4}-\d{2}$"),
    action: Optional[str] = None,
    limit: int = Query(200, ge=1, le=5000),
    db: Session = Depends(get_db),
):
    """アクセスログの照会。month=YYYY-MM で月単位に絞り込める。"""
    query = db.query(AccessLog)
    if month:
        query = query.filter(AccessLog.ts.like(month + "%"))
    if action:
        query = query.filter(AccessLog.action == action)
    total = query.count()
    rows = query.order_by(AccessLog.id.desc()).limit(limit).all()
    return {"count": total, "items": [log_to_dict(r) for r in rows]}


@app.get("/api/logs/summary")
def logs_summary(
    month: Optional[str] = Query(None, pattern=r"^\d{4}-\d{2}$"),
    db: Session = Depends(get_db),
):
    """注目度の集計: どの企業・キーワードに関心が集まっているか。month省略時は当月。"""
    from collections import Counter
    month = month or datetime.now().astimezone().strftime("%Y-%m")
    rows = db.query(AccessLog).filter(AccessLog.ts.like(month + "%")).all()
    kw, zero_kw, companies, syn, sectors = Counter(), Counter(), Counter(), Counter(), Counter()
    actions, daily, by_user, by_ip = Counter(), Counter(), Counter(), Counter()
    for r in rows:
        actions[r.action] += 1
        daily[r.ts[:10]] += 1
        if r.username:
            by_user[r.username] += 1
        if r.ip:
            by_ip[r.ip] += 1
        if r.action == "search":
            if r.keywords:
                kw[r.keywords] += 1
                if r.result_count == 0:
                    zero_kw[r.keywords] += 1
            if r.params:
                m = re.search(r"sector=([^,]+)", r.params)
                if m:
                    sectors[m.group(1).strip()] += 1
        elif r.action == "detail" and r.keywords:
            companies[r.keywords] += 1
        elif r.action == "synergy_search" and r.keywords:
            syn[r.keywords] += 1
    return {
        "month": month,
        "total": len(rows),
        "actions": dict(actions),
        "top_companies": companies.most_common(20),       # 注目企業（詳細閲覧数）
        "top_keywords": kw.most_common(20),               # 注目検索キーワード
        "zero_hit_keywords": zero_kw.most_common(20),     # 検索されたがDBに無い（収録候補のヒント）
        "top_synergy_keywords": syn.most_common(20),      # シナジー検索のテーマ
        "top_sectors": sectors.most_common(20),           # 分野フィルタの利用
        "daily": sorted(daily.items()),
        "by_user": by_user.most_common(),
        "by_ip": by_ip.most_common(20),
    }


@app.get("/api/logs/months")
def log_months(db: Session = Depends(get_db)):
    """ログが存在する月の一覧と件数（月次保存の入口）。"""
    rows = db.execute(text(
        "SELECT substr(ts, 1, 7) AS month, COUNT(*) FROM access_logs "
        "GROUP BY month ORDER BY month DESC"
    )).all()
    return {"months": [{"month": m, "count": n} for m, n in rows]}


@app.get("/api/logs/export.csv")
def export_logs_csv(
    month: Optional[str] = Query(None, pattern=r"^\d{4}-\d{2}$"),
    db: Session = Depends(get_db),
):
    """月単位のログをCSVでダウンロードする。month省略時は当月。"""
    month = month or datetime.now().astimezone().strftime("%Y-%m")
    buf = io.StringIO()
    w = csv.writer(buf)
    w.writerow(["日時", "IPアドレス", "ユーザー", "操作", "キーワード・内容", "絞り込み条件",
                "結果件数", "企業ID", "メソッド", "パス", "ステータス"])
    rows = (
        db.query(AccessLog)
        .filter(AccessLog.ts.like(month + "%"))
        .order_by(AccessLog.id.asc())
        .all()
    )
    action_ja = {
        "search": "企業検索", "detail": "企業詳細", "synergy_search": "シナジー検索",
        "csv_export": "CSV出力", "page_view": "ページ表示", "login": "ログイン",
        "login_failed": "ログイン失敗", "login_blocked": "ログイン遮断",
        "logout": "ログアウト", "log_view": "ログ閲覧", "trends_view": "トレンド閲覧",
        "compare": "企業比較", "compare_ai": "比較AI分析",
        "other": "その他",
    }
    for r in rows:
        w.writerow([csv_safe(v) for v in (
            r.ts, r.ip, r.username, action_ja.get(r.action, r.action),
            r.keywords, r.params, r.result_count, r.company_id,
            r.method, r.path, r.status,
        )])
    buf.seek(0)
    return StreamingResponse(
        iter([("﻿" + buf.getvalue()).encode("utf-8")]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=access_logs_%s.csv" % month},
    )
