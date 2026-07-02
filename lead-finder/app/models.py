from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db import Base


class Company(Base):
    """営業ターゲットの事業会社（見込み顧客）。"""
    __tablename__ = "companies"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, unique=True)
    industry = Column(String, nullable=True)        # 業界
    business = Column(Text, nullable=True)          # 事業内容（1〜2文）
    employee_scale = Column(String, nullable=True)  # 企業規模の目安（例: 従業員1,000名超）
    region = Column(String, nullable=True)          # 本社所在地・展開地域
    website = Column(String, nullable=True)
    needs = Column(Text, nullable=True)             # 想定される課題・ニーズ（comma-separated）
    needs_evidence = Column(Text, nullable=True)    # ニーズを裏付ける公開情報（ニュース等）
    score = Column(Integer, nullable=True)          # 有望度 0-100（AI評価）
    proposal_points = Column(Text, nullable=True)   # 営業提案ポイント（comma-separated）
    key_person_hint = Column(String, nullable=True) # 想定キーパーソンの部署・役職
    contact_url = Column(String, nullable=True)     # 問い合わせページURL
    reason = Column(Text, nullable=True)            # この候補を選んだ理由
    source_url = Column(String, nullable=True)      # 実在性・ニーズを確認した参照元
    source = Column(String, nullable=True)          # 候補の出所: AI検索 / 手動登録 / 取込
    review_status = Column(String, nullable=True)   # 候補/承認/却下（承認=有効リード）

    # --- 営業管理列（Googleシート側で編集し、pullで取り込む） ---
    status = Column(String, nullable=True)          # 商談ステージ（未着手/アプローチ中/商談中/受注/失注等）
    owner = Column(String, nullable=True)           # 営業担当者
    next_action = Column(String, nullable=True)     # 次アクション
    next_action_due = Column(String, nullable=True) # 次アクション期日（文字列のまま保持）
    lead_memo = Column(Text, nullable=True)         # 商談メモ

    lead_registered_at = Column(DateTime(timezone=True), nullable=True)  # 有効リード化した日時
    sheet_synced_at = Column(DateTime(timezone=True), nullable=True)     # 最後にシートと同期した日時
    last_search_id = Column(Integer, nullable=True)  # この候補を最後に提示したAI検索のID
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
    """自社の商材・サービス情報（営業資料から抽出）。"""
    __tablename__ = "company_profile"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=True)  # 読み込んだ営業資料のファイル名
    summary = Column(Text, nullable=True)     # AIが構造化した自社商材情報
    raw_text = Column(Text, nullable=True)    # 資料から抽出した生テキスト
    created_at = Column(DateTime(timezone=True), server_default=func.now())
