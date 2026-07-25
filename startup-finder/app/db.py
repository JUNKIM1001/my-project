import os

from fastapi import Request
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "data", "startup.db")

# DATABASE_URL があれば Postgres（Supabase等）、なければローカルSQLite
DATABASE_URL = os.environ.get("DATABASE_URL", "").strip()
IS_POSTGRES = bool(DATABASE_URL)

if IS_POSTGRES:
    # Supabase/Heroku形式の postgres:// を SQLAlchemy が要求する postgresql:// に正規化
    _url = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    # 遠隔DBへの接続確立(TCP+TLS+認証)が処理時間の大半を占めるため、
    # ウォームな実行環境では接続を使い回す。Supabaseの Transaction pooler は
    # トランザクション単位でサーバ接続を割り当てるので、クライアント側で
    # 接続を保持したままにして問題ない。
    engine = create_engine(
        _url,
        pool_size=1,          # 1関数インスタンスが同時に使うのは1本
        max_overflow=2,       # 同時実行が重なった時の逃げ道
        pool_recycle=300,     # プーラ側に切られた接続を掴み続けない
        pool_pre_ping=True,   # 死んだ接続なら静かに張り直す
    )
else:
    engine = create_engine(
        "sqlite:///" + DB_PATH,
        connect_args={"check_same_thread": False},
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db(request: Request):
    """DBセッション。認証・本処理・アクセスログで1本を共有する。

    ミドルウェアが request.state.db に用意したものを使い回す。接続を
    増やすと、そのたびに接続確立のコストを払うことになるため。
    """
    db = getattr(request.state, "db", None)
    if db is not None:
        yield db
        return
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
