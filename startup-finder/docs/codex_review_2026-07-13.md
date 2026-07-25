# Codex コードレビュー結果 — startup-finder

- 実施日: 2026-07-13
- レビュアー: OpenAI Codex CLI v0.142.4（read-onlyサンドボックス）
- 対象: app/ 配下のPython、app/static/ のHTML/JS

---

以下、重要度順のコードレビューです。対象は `app/` 配下の Python と `app/static/` の HTML/JS です。

## 指摘事項

### High

1. **XSS: `onclick` 属性内にデータ由来文字列を埋め込んでいる**
   - `app/static/index.html:389`
   - `app/static/index.html:451`
   - `esc()` は HTML エスケープとしては有効ですが、イベントハンドラ属性内の JavaScript 文字列としては不十分です。`sector` に `');alert(1);//` のような値が入ると、ブラウザがエンティティをデコードした後に JS として解釈される可能性があります。
   - 修正案:
     - `onclick="filterBySector(...)"` をやめ、DOM API で `textContent` と `addEventListener` を使って生成する。
     - 少なくとも `data-sector` に値を入れて、クリック時に `dataset.sector` を読む。
     - `innerHTML` ベースの行生成を続ける場合も、JS 文字列への埋め込みは `JSON.stringify(s)` 相当で行う。

2. **XSS/危険リンク: `javascript:` URL をリンクとして表示できる**
   - `app/static/index.html:473`
   - `app/static/index.html:474`
   - `website` / `sources` はエスケープされていますが、`href="javascript:..."` や不正スキームは防げません。データ取り込み元に混入すると、ユーザークリックでスクリプト実行につながります。
   - 修正案:
     - サーバ側 import 時に `http:` / `https:` のみ許可する。
     - フロントでも `new URL(url)` で検証し、許可スキーム以外はリンク化しない。
     - 表示テキストと `href` は別々に扱う。

3. **CSV Formula Injection**
   - `app/main.py:316`
   - `app/main.py:326`
   - 企業名、URL、説明、投資家名などに `=`, `+`, `-`, `@`, タブ、改行始まりの値が入ると、Excel/Sheets で開いた際に数式として評価される可能性があります。
   - 修正案:
     - CSV 出力前に全セルを sanitize する。
     - 例: `str(value)` が `=+-@\t\r\n` のいずれかで始まる場合は先頭に `'` を付ける。
     - URL や自由記述欄は特に対象にする。

4. **CSRF 対策が Cookie の SameSite 依存のみ**
   - `app/main.py:73`
   - `app/main.py:80`
   - `app/main.py:231`
   - `SameSite=Lax` は一定の防御になりますが、状態変更 API に明示的な CSRF トークンがありません。特にローカルアプリを社内 LAN やトンネルで使う運用になるとリスクが上がります。
   - 修正案:
     - ログイン時に CSRF トークンを発行し、`PATCH` / `POST logout` で `X-CSRF-Token` を検証する。
     - Cookie には `secure` を HTTPS 時のみ付与する。
     - ローカル限定なら `127.0.0.1` バインドを README/起動設定で明示する。

5. **セッショントークンが平文で SQLite に保存されている**
   - `app/auth.py:35`
   - `app/auth.py:51`
   - DB ファイルがコピーされると、有効期限内のセッションをそのまま乗っ取れます。
   - 修正案:
     - Cookie にはランダムトークンを渡し、DB には `sha256(token)` などのハッシュのみ保存する。
     - `auth_sessions.token_hash` を primary key にする。
     - 既存セッションを無効化する移行を入れる。

6. **ログイン試行制限が弱く、`time.sleep` がワーカーをブロックする**
   - `app/main.py:69`
   - `app/main.py:70`
   - 総当たり対策が固定 sleep のみです。ユーザー名/IP 単位の試行制限がなく、同時リクエストで回避できます。
   - 修正案:
     - SQLite に `login_attempts` を持つ、またはメモリ上でユーザー名/IP ごとの失敗回数とロック時間を管理する。
     - FastAPI の同期 endpoint で `sleep` するより、失敗回数に応じた 429 を返す。

### Medium

7. **JSON カラム破損で API 全体が 500 になる**
   - `app/main.py:112`
   - `app/main.py:132`
   - `app/main.py:309`
   - `app/main.py:315`
   - `awards` / `sources` を `json.loads()` していますが、DB 内の値が壊れていると一覧・詳細・CSV が 500 になります。
   - 修正案:
     - `safe_json_loads(value, default)` を用意し、失敗時は空配列にする。
     - import 時にも型検証し、配列以外は reject または補正する。
     - 可能なら SQLAlchemy の `JSON` 型、SQLite なら `Text` + Pydantic 検証に寄せる。

8. **日付検証が形式チェックのみで、不正日付を保存できる**
   - `app/main.py:237`
   - `app/main.py:239`
   - `2026-99-99` のような値が通ります。
   - 修正案:
     - `datetime.date.fromisoformat(md)` で検証する。
     - モデル上も `meeting_date` は `String` ではなく `Date` にするのが望ましいです。

9. **権限設計が「ログイン済みなら全員更新可」になっている**
   - `app/main.py:231`
   - `app/main.py:242`
   - CVC 担当者が複数いる前提だと、誰でも全社の面談日・担当者を変更できます。
   - 修正案:
     - 運用上それでよいなら明文化する。
     - そうでなければ `User.role` や `owner_user_id` を追加し、編集可能範囲を制限する。
     - 更新履歴テーブルも追加すると監査しやすいです。

10. **秘密情報がコマンドライン引数に残る**
    - `app/scripts/create_user.py:4`
    - `app/scripts/create_user.py:22`
    - `--password` はシェル履歴やプロセス一覧に残る可能性があります。
    - 修正案:
      - `--password` を非推奨にし、原則 `getpass` 入力のみにする。
      - 自動化用途が必要なら環境変数または stdin から読む。

11. **LIKE 検索が部分一致すぎて誤マッチしやすい**
    - `app/main.py:194`
    - `app/main.py:200`
    - `sectors` / `investors` がカンマ区切り文字列なので、`AI` が別単語の一部に当たるなど名寄せ・絞り込み品質が落ちます。
    - 修正案:
      - `company_sectors`, `company_investors` などの関連テーブルに正規化する。
      - 短期対応なら区切り文字を前後に付けた正規化カラムを用意し、完全トークン一致で検索する。

12. **import の名寄せが過剰マージ/不足マージの両方を起こしやすい**
    - `app/scripts/import_json.py:27`
    - `app/scripts/import_json.py:31`
    - `app/scripts/import_json.py:119`
    - 法人格・記号・括弧を落とすだけなので、別会社の誤統合や、英日表記の取りこぼしが起きます。
    - 修正案:
      - `company_aliases` テーブルを作り、正規名・別名・根拠・手動確認済みフラグを持たせる。
      - 自動マージはスコアリングし、低信頼は `review_required` として別出力する。
      - `website` ドメイン一致を強い根拠に使う。

13. **既存値優先の import 方針により、古いデータが更新されない**
    - `app/scripts/import_json.py:147`
    - `app/scripts/import_json.py:156`
    - 調達額、従業員数、ステージなどは後続データのほうが新しい場合がありますが、既存値があると更新されません。
    - 修正案:
      - `last_verified` や source date を比較して新しい値を採用する。
      - フィールドごとに merge policy を定義する。
      - 上書き候補をログ出力し、人手確認できるようにする。

14. **起動時マイグレーションが ad hoc**
    - `app/main.py:26`
    - `app/main.py:31`
    - アプリ起動時に `ALTER TABLE` しています。今後カラム追加や型変更が増えると壊れやすいです。
    - 修正案:
      - Alembic を導入する。
      - ローカル利用前提でも `app/scripts/migrate.py` のように明示実行に分ける。
      - 少なくとも migration version テーブルを持つ。

### Low / 保守性・性能

15. **一覧・メタ・シナジー検索が全件取得前提**
    - `app/main.py:141`
    - `app/main.py:215`
    - `app/main.py:270`
    - 件数が増えるとレスポンスとブラウザ描画が重くなります。
    - 修正案:
      - `/api/companies` に `limit` / `offset` を追加する。
      - `/api/meta` は SQL の `GROUP BY` / 集計で返す。
      - シナジー検索は候補を SQL で絞ってから Python 採点する。

16. **検索が前方ワイルドカード LIKE でインデックスを使いにくい**
    - `app/main.py:185`
    - `app/main.py:186`
    - `%term%` は通常の index が効きません。
    - 修正案:
      - SQLite FTS5 を使う。
      - `name`, `description`, `sectors`, `investors`, `partners`, `hq` を FTS テーブルに同期する。
      - 少なくとも `status`, `stage`, `owner`, `meeting_date`, `total_raised_oku` には index を追加する。

17. **フロント側 fetch のエラーハンドリングが不足**
    - `app/static/index.html:376`
    - `app/static/index.html:419`
    - `app/static/index.html:441`
    - 401/500/ネットワークエラー時に JSON parse 失敗や無反応になります。
    - 修正案:
      - `apiFetch()` を共通化し、401 はログイン画面へ、非 2xx はメッセージ表示にする。
      - 検索中・失敗時の UI 状態を明示する。

18. **SQLi は現状大きな問題は見当たらないが、将来の拡張に注意**
    - `app/main.py:176`
    - `app/main.py:213`
    - `sort` / `order` は `Query(pattern=...)` と `getattr` 対象制限があり、主要な検索条件も SQLAlchemy のバインド経由です。
    - 修正案:
      - 今の whitelist 方針を維持する。
      - `text()` にユーザー入力を混ぜないルールを明文化する。

## 総評

最大の修正優先度は、`index.html` のイベントハンドラ属性への文字列埋め込み、CSV Formula Injection、セッション/CSRF 周りです。ローカル社内利用でも、DB の中身や import 元データを「信頼済み」とみなす設計になっているため、公開情報由来データを扱うアプリとしては XSS と CSV 出力の防御を先に入れるべきです。

設計面では、カンマ区切り文字列と `Text` JSON による簡易スキーマが、検索精度・名寄せ・データ品質・性能の制約になっています。短期は sanitize と検証関数の追加、次段で関連テーブル化・FTS5・import レビューキューを入れるのが現実的です。
