import os

from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.pool import NullPool

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "data", "startup.db")

# DATABASE_URL があれば Postgres（Supabase等）、なければローカルSQLite
DATABASE_URL = os.environ.get("DATABASE_URL", "").strip()

if DATABASE_URL:
    # Supabase/Heroku形式の postgres:// を SQLAlchemy が要求する postgresql:// に正規化
    _url = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    # サーバレス（Vercel）では接続を持ち回らず、リクエストごとに張って捨てる
    engine = create_engine(_url, poolclass=NullPool)
else:
    engine = create_engine(
        "sqlite:///" + DB_PATH,
        connect_args={"check_same_thread": False},
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
