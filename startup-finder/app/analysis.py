"""選択した複数スタートアップのKSF・ビジネスモデル比較分析（Gemini）。

出力は「AI生成の仮説」であり、DBの事実データとは分離して扱う（保存しない）。
vc-finder の ai_search.py と同じ呼び出しパターン（google-genai + 検索グラウンディング）。
"""

import json
import os
import re
import time

from google import genai
from google.genai import errors as genai_errors
from google.genai import types

MODEL = "gemini-flash-latest"

SYSTEM_PROMPT = """あなたはCVC（コーポレートベンチャーキャピタル）のアナリストです。
与えられた日本のスタートアップ数社について、KSF（重要成功要因）・ビジネスモデル・優位性を比較分析してください。

ルール:
- 提供されたファクトシート（調達額・株主・提携先・事業内容など）を主根拠とし、必要に応じてWeb検索で公開情報を補強する
- 断定できないことは「推定」と明示する。誇張しない
- 出力は必ず次のスキーマのJSONのみ（```json ブロックで囲む）:

{
 "overview": "この企業群が属する市場と競争構造の要約（200字以内）",
 "companies": [
   {
     "name": "社名（入力と完全一致）",
     "business_model": "誰に何をどう売るかの要約（80字以内）",
     "revenue_model": "収益形態の推定（例: SaaS月額課金／成果報酬／手数料）",
     "advantage_type": "優位性の分類（技術優位/顧客基盤/資本力/先行者/規制・認可/データ蓄積/ブランド/販路 から主要なもの1-2個）",
     "strengths": ["強み（各40字以内・最大3個）"],
     "risks": ["弱み・リスク（各40字以内・最大2個）"]
   }
 ],
 "ksf": [
   {
     "factor": "この市場のKSF（例: 導入実績による信頼獲得）",
     "why": "なぜ重要か（60字以内）",
     "assessment": {"社名": "◎/○/△のいずれか＋根拠一言（30字以内）"}
   }
 ],
 "differences": "各社のビジネスモデル・戦略の違いの核心（250字以内）",
 "note": "分析の限界・確認すべき点（80字以内）"
}

- ksfは3〜5個。assessmentは全社分を含める
- companiesは入力された全社を含める"""


def _extract_json(text: str):
    match = re.search(r"```json\s*(.*?)\s*```", text, re.DOTALL)
    candidate = (match.group(1) if match else text).strip()
    if not candidate.startswith("{"):
        s, e = candidate.find("{"), candidate.rfind("}")
        if s != -1 and e > s:
            candidate = candidate[s:e + 1]
    try:
        return json.loads(candidate, strict=False)
    except json.JSONDecodeError:
        repaired = re.sub(r",\s*([\]}])", r"\1", candidate)
        return json.loads(repaired, strict=False)


def fact_sheet(c) -> str:
    """Companyレコード1件をプロンプト用のファクトシートに整形する。"""
    lines = [f"## {c.name}"]
    if c.description:
        lines.append(f"事業内容: {c.description}")
    if c.sectors:
        lines.append(f"分野: {c.sectors}")
    parts = []
    if c.founded_year:
        parts.append(f"{c.founded_year}年設立")
    if c.hq:
        parts.append(c.hq)
    if c.employee_count:
        parts.append(f"従業員約{c.employee_count}名")
    if c.stage:
        parts.append(f"ステージ: {c.stage}")
    if parts:
        lines.append("・".join(parts))
    if c.total_raised_oku:
        lines.append(f"累計調達額: {c.total_raised_oku}億円")
    if c.valuation_oku:
        lines.append(f"評価額(公表/報道): {c.valuation_oku}億円")
    if c.last_round_date:
        lines.append(f"直近ラウンド: {c.last_round_date} {c.last_round_name or ''} {c.last_round_amount_oku or '?'}億円")
    if c.investors:
        lines.append(f"主要株主・投資家: {c.investors}")
    if c.partners:
        lines.append(f"提携事業会社: {c.partners}")
    if c.awards:
        lines.append(f"受賞歴: {c.awards}")
    # 公的情報（gBizINFO）— 技術力・公的評価の定量シグナル
    if c.patent_count:
        lines.append(f"特許・知財件数(gBizINFO): {c.patent_count}件")
    if c.capital_oku:
        lines.append(f"資本金: {c.capital_oku}億円")
    if c.gbiz_json:
        try:
            g = json.loads(c.gbiz_json)
            subs = [s.get("title") for s in g.get("subsidies", [])[:5] if s.get("title")]
            if subs:
                lines.append("補助金・助成金の採択: " + " / ".join(subs))
            comms = [x.get("title") for x in g.get("commendations", [])[:3] if x.get("title")]
            if comms:
                lines.append("表彰: " + " / ".join(comms))
        except (ValueError, TypeError):
            pass
    return "\n".join(lines)


def analyze_companies(companies) -> dict:
    """比較分析を実行。成功時 {"analysis": {...}} / 失敗時 {"error": "..."}"""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {"error": "GEMINI_API_KEY が設定されていません。"}

    client = genai.Client(api_key=api_key)
    sheets = "\n\n".join(fact_sheet(c) for c in companies)
    prompt = (
        f"以下の{len(companies)}社を比較分析してください。\n\n{sheets}"
    )

    response = None
    last_error = None
    # サーバレスの実行時間上限があるためリトライは短く1回だけ
    for wait in (0, 5):
        if wait:
            time.sleep(wait)
        try:
            response = client.models.generate_content(
                model=MODEL,
                contents=prompt,
                config=types.GenerateContentConfig(
                    system_instruction=SYSTEM_PROMPT,
                    tools=[types.Tool(google_search=types.GoogleSearch())],
                ),
            )
            break
        except genai_errors.ServerError as e:
            last_error = e
            continue
        except Exception as e:
            return {"error": f"Gemini API呼び出しに失敗しました: {e}"}
    if response is None:
        return {"error": f"Gemini APIが混雑しています。少し待って再実行してください: {last_error}"}

    text = response.text or ""
    try:
        return {"analysis": _extract_json(text)}
    except Exception as e:
        return {"error": f"AI出力の解析に失敗しました: {e}", "raw": text[:2000]}
