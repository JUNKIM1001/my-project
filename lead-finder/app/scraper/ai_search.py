import json
import os
import re
import time

from google import genai
from google.genai import types
from google.genai import errors as genai_errors

MODEL = "gemini-flash-latest"

SYSTEM_PROMPT = """あなたはB2B営業のターゲットリサーチに詳しいアシスタントです。

ユーザーの「自社商材情報」と「営業ターゲット条件」をもとに、
**その商材への導入ニーズを抱えていそうな日本国内の事業会社**を探してください。

最も重視してほしい観点は、業界タグの一致ではなく、
**その企業が今まさに、ユーザーの商材が解決できる課題・ニーズを抱えていそうか**という点です。
公開情報（プレスリリース、中期経営計画、採用情報、新店舗・新事業のニュース、DX投資の発表など）から
ニーズの「兆候」を見つけ、それを根拠として示してください。

進め方:
1. 自社商材から「解決できる課題」と「その課題を抱えやすい企業の特徴」
   （業界、事業モデル、規模、拠点数、成長フェーズなど）を洗い出す
2. その特徴に合う実在の事業会社をGoogle検索で調査する
3. 各社について、ニーズの兆候となる公開情報（時期を含む具体的な事実）を確認する
4. 問い合わせ窓口や、商談のキーパーソンになりそうな部署・役職も調べる

ルール:
- 必ず検索を使い、公式サイトや信頼できる情報源で実在性を確認すること
- 一般論や推測だけで存在しない企業名を作らないこと
- すでにユーザーが除外を指定した企業・業界は候補に入れないこと
- 候補は5〜10件程度
- 最後に、以下のJSON配列「のみ」を ```json ... ``` のコードブロックで出力すること（前後に説明文を付けない）

JSONの各要素のフィールド:
- name: 企業の正式名称
- industry: 業界（例: 小売、不動産、教育、エンタメ、製造）
- business: 事業内容（1〜2文）
- employee_scale: 企業規模の目安（例: "従業員約3,000名" "中堅・非上場"。不明ならnull）
- region: 本社所在地または主な展開地域
- website: 公式サイトURL
- needs: 想定される課題・ニーズの配列（各1文。例: ["全国の遊休スペースの収益化","若年層向け集客コンテンツの不足"]）
- needs_evidence: ニーズを裏付ける公開情報の事実（時期と内容を含む1文）
- score: 有望度を0〜100の整数で評価
  （ニーズ適合の強さ50点 + 導入体力・予算の見込み30点 + 接点の作りやすさ20点を目安に採点）
- proposal_points: 商談の場でユーザー側から提案できるトークの配列（2〜3個、各1文）
- key_person_hint: 商談のキーパーソンになりそうな部署・役職（例: "経営企画部 新規事業担当"。不明ならnull）
- contact_url: 法人からの問い合わせが可能なページのURL（見つかった場合のみ。なければnull）
- reason: この候補を選んだ理由。ニーズとの関連性を中心に1〜2文
- source_url: 実在性やニーズを確認した参照元URL

出力はscoreの高い順に並べること。
"""


def _extract_json(text: str):
    match = re.search(r"```json\s*(.*?)\s*```", text, re.DOTALL)
    candidate = match.group(1) if match else text
    candidate = candidate.strip()
    # ```json ブロックが無く前後に説明文が付く場合に備え、最初の [ から最後の ] までを抽出
    if not candidate.startswith("["):
        s, e = candidate.find("["), candidate.rfind("]")
        if s != -1 and e != -1 and e > s:
            candidate = candidate[s:e + 1]
    try:
        # strict=False: 文字列値内の生の改行・タブ等の制御文字を許容
        return json.loads(candidate, strict=False)
    except json.JSONDecodeError:
        # 末尾カンマなどの軽微な崩れを除去して再挑戦
        repaired = re.sub(r",\s*([\]}])", r"\1", candidate)
        return json.loads(repaired, strict=False)


def ai_search_companies(condition: str) -> dict:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {"error": "GEMINI_API_KEY が設定されていません。.env を確認してください。"}

    client = genai.Client(api_key=api_key)

    response = None
    last_error = None
    for attempt, wait in enumerate([0, 20, 45, 90], start=1):
        if wait:
            time.sleep(wait)
        try:
            response = client.models.generate_content(
                model=MODEL,
                contents=f"以下の条件に合う営業ターゲットの事業会社を探してください。\n\n{condition}",
                config=types.GenerateContentConfig(
                    system_instruction=SYSTEM_PROMPT,
                    tools=[types.Tool(google_search=types.GoogleSearch())],
                ),
            )
            break
        except genai_errors.ServerError as e:
            # 503等の一時的エラーはリトライ
            last_error = e
            continue
        except Exception as e:
            return {"error": f"Gemini APIの呼び出しに失敗しました: {e}"}

    if response is None:
        return {"error": f"Gemini APIが混雑しています。しばらく待って再実行してください: {last_error}"}

    final_text = response.text or ""

    try:
        candidates = _extract_json(final_text)
    except Exception as e:
        return {"error": f"AIの出力をJSONとして解析できませんでした: {e}", "raw": final_text}

    return {"candidates": candidates, "raw": final_text}
