from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db import Base


class VC(Base):
    __tablename__ = "vcs"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, unique=True)
    type = Column(String, nullable=False)  # "VC" or "CVC" (derived from category)
    category = Column(String, nullable=True)  # 独立系/事業会社系/銀行・信金・信組系 etc (元リストの「VC種別」)
    founded_year = Column(Integer, nullable=True)
    parent_company = Column(String, nullable=True)
    website = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    stages = Column(Text, nullable=True)   # comma-separated
    sectors = Column(Text, nullable=True)  # comma-separated
    regions = Column(Text, nullable=True)  # comma-separated
    entertainment_track_record = Column(String, nullable=True)  # エンタメコンテンツ関連SU出資経歴
    recent_entertainment_investment = Column(String, nullable=True)  # 3年以内のエンタメ投資実績
    status = Column(String, nullable=True)  # 対応ステータス（未着手/連絡済み等）
    review_status = Column(String, nullable=True)  # AI候補の確認状態: 候補/承認/却下（元リスト由来はNULL）
    relevant_assets = Column(Text, nullable=True)  # シナジーが期待できる事業アセット（comma-separated）
    investment_active = Column(String, nullable=True)  # 出資機能が稼働中か（AI確認結果）
    investment_evidence = Column(Text, nullable=True)  # 出資機能の根拠
    score = Column(Integer, nullable=True)  # 条件への適合度 0-100（AI評価）
    pitch_points = Column(Text, nullable=True)  # 商談で提案できるシナジー要点（comma-separated）
    contact_url = Column(String, nullable=True)  # 問い合わせ・コンタクトページURL
    rep_name = Column(String, nullable=True)       # 代表者/投資責任者の氏名
    rep_linkedin = Column(String, nullable=True)   # 代表者のLinkedIn URL
    rep_facebook = Column(String, nullable=True)   # 代表者のFacebook URL
    last_search_id = Column(Integer, nullable=True)  # この候補を最後に提示したAI検索のID
    source_url = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())


class SearchHistory(Base):
    __tablename__ = "search_history"

    id = Column(Integer, primary_key=True, index=True)
    condition = Column(Text, nullable=False)
    result_count = Column(Integer, nullable=True)
    result_names = Column(Text, nullable=True)  # comma-separated
    raw_response = Column(Text, nullable=True)  # AIのJSON出力全文
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class CompanyProfile(Base):
    __tablename__ = "company_profile"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=True)  # 読み込んだピッチ資料のファイル名
    summary = Column(Text, nullable=True)     # AIが構造化した自社事業情報
    raw_text = Column(Text, nullable=True)    # 資料から抽出した生テキスト
    created_at = Column(DateTime(timezone=True), server_default=func.now())
