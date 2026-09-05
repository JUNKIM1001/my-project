"""ラウンド日付（"YYYY-MM"）の比較と、ステータス/ステージ整合のユーティリティ。

import_json / sync_fields_to_postgres / apply_round_updates が共有する
「どちらの直近ラウンドが新しいか」「終了ステータスに対応するステージ」の判定を集約する。
"""

import re

YM_RE = re.compile(r"^\d{4}-(0[1-9]|1[0-2])$")
YEAR_RE = re.compile(r"^\d{4}$")

# 終了ステータスに対応するステージ表記
STAGE_BY_STATUS = {"ipo": "IPO済", "ma": "M&A済", "closed": "清算"}


def valid_ym(s):
    return isinstance(s, str) and bool(YM_RE.match(s))


def year_only(s):
    return isinstance(s, str) and bool(YEAR_RE.match(s))


def round_is_newer(new_ym, old_ym):
    """new_ym が有効で、old_ym が無効/未設定か new_ym より前なら True。

    - 同月は「新しい」とみなさない（同一ラウンドの重複取り込みで既存値を壊さないため）
    - old_ym が年のみ（"2024"）の旧データは月不明として年で比べ、翌年以降の new_ym
      だけを新しい扱いにする（同年は is_month_refinement で同一ラウンドと確認できた時のみ）
    """
    if not valid_ym(new_ym):
        return False
    if year_only(old_ym):
        return new_ym[:4] > old_ym
    if not valid_ym(old_ym):
        return True
    return new_ym > old_ym


def _norm_name(s):
    return re.sub(r"[\s　]", "", s if isinstance(s, str) else "")


def _num(v):
    """数値（bool除く）ならfloat、数値文字列も許容、それ以外は None。"""
    if isinstance(v, bool):
        return None
    if isinstance(v, (int, float)):
        return float(v)
    try:
        return float(str(v).strip()) if str(v).strip() else None
    except (TypeError, ValueError):
        return None


def is_month_refinement(new_ym, old_ym, new_name=None, old_name=None, new_amount=None, old_amount=None):
    """既存が年のみで同年のとき、「同じラウンドの月補完」とみなせるかを判定する。

    - 両方にラウンド名があれば名前の一致を必須にする（同年・同額の別ラウンドを誤認しない）
    - どちらかにラウンド名が無いときだけ金額一致で同一ラウンドとみなす
    """
    if not (valid_ym(new_ym) and year_only(old_ym) and new_ym[:4] == old_ym):
        return False
    n1, n2 = _norm_name(new_name), _norm_name(old_name)
    if n1 and n2:
        return n1 == n2
    a, b = _num(new_amount), _num(old_amount)
    return a is not None and b is not None and a == b


def should_replace_round(new_ym, old_ym, new_name=None, old_name=None, new_amount=None, old_amount=None):
    """直近ラウンド列を new 側で差し替えてよいか（新しいラウンド、または年のみ日付の月補完）。"""
    return round_is_newer(new_ym, old_ym) or is_month_refinement(
        new_ym, old_ym, new_name, old_name, new_amount, old_amount)


def keep_max_total(old_total, new_total):
    """累計調達額は減らない前提で、新値が既存より小さければ既存を残す。

    後から来たファイルが「今回ラウンド額」を累計欄に入れているケースの防御。
    """
    if new_total is None:
        return old_total
    if old_total is None:
        return new_total
    return max(old_total, new_total)


def stage_for_status(status, stage=None):
    """終了ステータス（ipo/ma/closed）ならそれに整合するステージを返す。

    通常ステージ（シリーズA等）が渡されても終了ステージに置き換え、
    `ipo` + `シリーズA` のような不整合を作らない。active なら stage をそのまま返す。
    """
    if status in STAGE_BY_STATUS:
        return STAGE_BY_STATUS[status]   # 渡された終了ステージが status と食い違っていても status 側を正とする
    return stage
