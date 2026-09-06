from sqlalchemy import Column, DateTime, Float, Integer, String, Text
from sqlalchemy.sql import func

from app.db import Base


class Company(Base):
    """国内スタートアップ1社分のレコード。

    金額はすべて億円単位。valuation_oku は公表・報道ベースの値のみ
    （valuation_source に出典を持つ）。事実に基づかない推定値は入れない。
    """

    __tablename__ = "companies"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, unique=True)
    website = Column(String, nullable=True)
    founded_year = Column(Integer, nullable=True)
    hq = Column(String, nullable=True)
    representative = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    sectors = Column(Text, nullable=True)          # comma-separated
    themes = Column(Text, nullable=True)           # 収集テーマ (ai/saas/... comma-separated)
    stage = Column(String, nullable=True)          # シード〜レイター/IPO済/M&A済/清算

    total_raised_oku = Column(Float, nullable=True)    # 累計調達額（億円）
    valuation_oku = Column(Float, nullable=True)       # 公表・報道ベースの評価額（億円）
    valuation_source = Column(Text, nullable=True)     # 評価額の出典

    last_round_date = Column(String, nullable=True)    # "YYYY-MM"
    last_round_name = Column(String, nullable=True)    # シリーズB など
    last_round_amount_oku = Column(Float, nullable=True)
    last_round_investors = Column(Text, nullable=True)  # comma-separated
    last_round_lead = Column(String, nullable=True)     # 直近ラウンドのリード投資家（出典に明記がある場合のみ）

    investors = Column(Text, nullable=True)        # 主要株主・投資家 comma-separated
    partners = Column(Text, nullable=True)         # 提携事業会社 comma-separated
    awards = Column(Text, nullable=True)           # JSON: [{event, year, result}]

    status = Column(String, nullable=False, default="active")  # active/ipo/ma/closed
    status_note = Column(Text, nullable=True)      # M&A先・倒産時期など
    employee_count = Column(Integer, nullable=True)

    sources = Column(Text, nullable=True)          # JSON: [url, ...]
    last_verified = Column(String, nullable=True)  # "YYYY-MM"

    # 公的情報（gBizINFOバッチ enrich_gbizinfo.py が付与）
    corporate_number = Column(String, nullable=True, index=True)  # 法人番号（13桁・名寄せキー）
    capital_oku = Column(Float, nullable=True)       # 資本金（億円）
    patent_count = Column(Integer, nullable=True)    # 特許・実用新案等の件数
    subsidy_count = Column(Integer, nullable=True)   # 補助金・助成金の受給件数
    gbiz_json = Column(Text, nullable=True)          # 詳細JSON（補助金明細・表彰・届出認定）
    gbiz_updated = Column(String, nullable=True)     # 取得日 "YYYY-MM-DD"

    # 連絡先（CVCのアウトリーチ用）
    contact_url = Column(String, nullable=True)    # 問い合わせ・採用ページ等のURL
    rep_linkedin = Column(String, nullable=True)   # 代表者のLinkedIn URL
    rep_x = Column(String, nullable=True)          # 代表者のX(Twitter) URL
    rep_facebook = Column(String, nullable=True)   # 代表者のFacebook URL


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, nullable=False, unique=True)
    display_name = Column(String, nullable=False)   # 画面に表示する名前
    password_hash = Column(String, nullable=False)  # "salt$hash"（PBKDF2-SHA256）
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class AuthSession(Base):
    __tablename__ = "auth_sessions"

    token = Column(String, primary_key=True)
    user_id = Column(Integer, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    updated_at = Column(
        DateTime(timezone=True), onupdate=func.now(), server_default=func.now()
    )


class AccessLog(Base):
    """操作の監査ログ。いつ・どのIPから・誰が・何をしたかを1行で記録する。

    ts はローカルタイムゾーン付きISO文字列（例 2026-07-25T11:30:00+09:00）。
    先頭7文字が "YYYY-MM" になるため、月単位の絞り込みは前方一致で行う。
    """

    __tablename__ = "access_logs"

    id = Column(Integer, primary_key=True, index=True)
    ts = Column(String, nullable=False, index=True)   # ISO日時（TZ付き）
    ip = Column(String, nullable=True, index=True)    # 接続元IP（プロキシヘッダ優先）
    username = Column(String, nullable=True)          # 未ログイン時はNone
    action = Column(String, nullable=False, index=True)  # search/detail/synergy_search/csv_export/login/...
    keywords = Column(Text, nullable=True)            # 分析対象の本体: 検索語(q)/シナジー語(assets)/閲覧した社名
    params = Column(Text, nullable=True)              # 絞り込み条件（sector=AI, status=active 等。sort/orderは含めない）
    result_count = Column(Integer, nullable=True)     # 検索ヒット件数（0件キーワードの分析用）
    company_id = Column(Integer, nullable=True)       # detail時の企業ID（社名変更に耐える集計キー）
    method = Column(String, nullable=False)
    path = Column(String, nullable=False)
    status = Column(Integer, nullable=True)           # HTTPステータスコード


class IpoAnalysis(Base):
    """IPO企業のⅠの部（新規上場申請のための有価証券報告書）からの構造化抽出結果。

    analysis_json は Gemini による抽出（株主構成・資本政策履歴・SO・財務・戦略・IPO条件）。
    値は届出書記載値のみ（推定はフィールド名に _est を付けて区別）。1社1行。
    """

    __tablename__ = "ipo_analysis"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, nullable=False, unique=True, index=True)
    code = Column(String, nullable=True)          # 証券コード
    listing_date = Column(String, nullable=True)  # "YYYY-MM-DD"
    market = Column(String, nullable=True)        # グロース/スタンダード/プライム
    source_pdf = Column(String, nullable=True)    # Ⅰの部PDF(JPX)
    outline_pdf = Column(String, nullable=True)   # 新規上場会社概要PDF(JPX)
    analysis_json = Column(Text, nullable=True)
    extracted_at = Column(String, nullable=True)
    model = Column(String, nullable=True)
