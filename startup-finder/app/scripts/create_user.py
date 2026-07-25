"""ユーザーの作成・パスワード変更。

usage:
  .venv/bin/python3 -m app.scripts.create_user <username> [--name 表示名] [--password パスワード]

- 既存ユーザー名を指定するとパスワード・表示名を更新する
- --password を省略すると対話プロンプトで入力（画面に表示されない）
"""

import argparse
import getpass

from app.auth import hash_password
from app.db import Base, SessionLocal, engine
from app.models import User


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("username")
    parser.add_argument("--name", help="表示名（担当者名として使われる）")
    parser.add_argument("--password", help="省略時は対話入力")
    args = parser.parse_args()

    password = args.password or getpass.getpass("パスワード: ")
    if len(password) < 8:
        raise SystemExit("パスワードは8文字以上にしてください")

    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    user = db.query(User).filter(User.username == args.username).first()
    if user is None:
        user = User(
            username=args.username,
            display_name=args.name or args.username,
            password_hash=hash_password(password),
        )
        db.add(user)
        action = "created"
    else:
        user.password_hash = hash_password(password)
        if args.name:
            user.display_name = args.name
        action = "updated"
    db.commit()
    print("%s: %s (表示名: %s)" % (action, user.username, user.display_name))
    db.close()


if __name__ == "__main__":
    main()
