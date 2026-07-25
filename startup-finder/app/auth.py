"""パスワードハッシュとセッション管理（標準ライブラリのみで実装）。"""

import hashlib
import secrets
from datetime import datetime, timedelta

from sqlalchemy.orm import Session as DBSession

from app.models import AuthSession, User

SESSION_COOKIE = "sf_session"
SESSION_DAYS = 30
PBKDF2_ITERATIONS = 200_000


def hash_password(password):
    salt = secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac(
        "sha256", password.encode("utf-8"), salt.encode("utf-8"), PBKDF2_ITERATIONS
    ).hex()
    return salt + "$" + digest


def verify_password(password, password_hash):
    try:
        salt, digest = password_hash.split("$", 1)
    except ValueError:
        return False
    candidate = hashlib.pbkdf2_hmac(
        "sha256", password.encode("utf-8"), salt.encode("utf-8"), PBKDF2_ITERATIONS
    ).hex()
    return secrets.compare_digest(candidate, digest)


def create_session(db: DBSession, user: User):
    token = secrets.token_hex(32)
    db.add(AuthSession(
        token=token,
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(days=SESSION_DAYS),
    ))
    # 期限切れセッションはついでに掃除
    db.query(AuthSession).filter(AuthSession.expires_at < datetime.utcnow()).delete()
    db.commit()
    return token


def get_user_by_token(db: DBSession, token):
    if not token:
        return None
    sess = db.query(AuthSession).filter(AuthSession.token == token).first()
    if sess is None or sess.expires_at < datetime.utcnow():
        return None
    return db.query(User).get(sess.user_id)


def delete_session(db: DBSession, token):
    if token:
        db.query(AuthSession).filter(AuthSession.token == token).delete()
        db.commit()
