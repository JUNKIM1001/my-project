import json
import os
import re
import time

from google import genai
from google.genai import types
from google.genai import errors as genai_errors

MODEL = "gemini-flash-latest"

SYSTEM_PROMPT = """あなたは日本国内のVC・CVCに詳しいリサーチアシスタントです。

最も重視してほしい観点は「投資領域のタグ」の一致ではなく、
**そのVC/CVC、特にCVCの場合はその親会社が、ユーザーのスタートアップにとって価値のある事業アセット
（設備、店舗・拠点、顧客基盤、技術、流通網、メディア・チャネル、ブランド、人材など）を持っているか**
という事業シナジーの観点です。

例えば「音楽スタジオを運営するスタートアップ」であれば、楽器メーカーであり音楽スタジオ・音楽教室・
アーティスト関連事業を持つ「ヤマハミュージックエンタテインメントホールディングス」系のCVC
（ヤマハミュージックベンチャーズ等）のように、親会社の保有する事業アセットが
スタートアップの事業内容と直接結びつく候補を優先的に探してください。

進め方:
1. ユーザーの事業内容から、シナジーが期待できそうな「事業アセットの種類」（設備/拠点/技術/顧客基盤/チャネル等）と、
   それを保有していそうな業界・企業（メーカー、商社、メディア、小売、不動産、エンタメ事業会社など）を洗い出す
2. それらの企業がCVC・投資子会社・VCファンドを持っているかをGoogle検索で調査する
3. 独立系VCについても、ユーザーの事業領域への投資実績や、保有するハンズオン支援アセット
   （販路紹介、業界ネットワーク等）があるかを確認する
4. 各候補について、**現在も投資活動を行っているか（出資機能の実在）**を、
   公式サイトのファンド概要・投資先一覧・直近の出資ニュースなどで必ず確認する。
   解散済み・募集停止・休眠状態が疑われる場合は候補から除外するか、reasonにその旨明記する

ルール:
- 必ず検索を使い、公式サイトや信頼できる情報源で実在性・出資機能の有無を確認すること
- 一般論や推測だけで存在しないファンド名を作らないこと
- 候補は5〜10件程度
- 最後に、以下のJSON配列「のみ」を ```json ... ``` のコードブロックで出力すること（前後に説明文を付けない）

JSONの各要素のフィールド:
- name: 正式名称
- type: "VC" または "CVC"
- parent_company: CVCの場合の親会社名（VCの場合はnull）
- website: 公式サイトURL
- sectors: 投資領域の配列。必ず後述の「投資領域マスタ」の表記をそのまま使うこと
- stages: 投資ステージの配列。必ず「シード」「シリーズA」「シリーズB」「シリーズC」「シリーズD以降」「その他」のいずれかの表記を使うこと（プレシード→シード、アーリー→シリーズA、ミドル→シリーズB、レイター→シリーズC以降に読み替える）
- regions: 対象地域の配列（例: ["国内"]）
- relevant_assets: ユーザーの事業とシナジーが期待できる、親会社またはVC自身が持つ具体的な事業アセット
  （例: ["音楽スタジオ・音楽教室の運営拠点","楽器販売網","アーティストネットワーク"]）
- investment_active: 出資機能が現在も稼働していると確認できたか（true/false）
- investment_evidence: 出資機能の実在を裏付ける、直近の出資・協業ニュースの事実（時期と内容を含む1文）
- score: ユーザーの条件への適合度を0〜100の整数で評価
  （アセットシナジーの強さ50点 + ステージ・領域の一致30点 + 出資活動の活発さ20点を目安に採点）
- pitch_points: 商談の場でユーザー側から提案できるシナジー仮説の配列（2〜3個、各1文。
  例: ["全国の音楽教室網への当社スタジオ予約システムの導入提案","防音設備の共同ショールーム展開"]）
- contact_url: スタートアップからの問い合わせ・応募が可能なページのURL（見つかった場合のみ。なければnull）
- rep_name: 代表者または投資責任者（代表パートナー・ファンド長等）の氏名。確認できなければnull
- rep_linkedin: その代表者本人のLinkedInプロフィールURL。確実に本人と確認できた場合のみ。なければnull
- rep_facebook: その代表者本人のFacebookプロフィールURL。確実に本人と確認できた場合のみ。なければnull
  （※rep_linkedin / rep_facebook は推測でURLを作らないこと。本人と断定できない場合は必ずnull）
- reason: この候補を選んだ理由。アセットとの関連性を中心に1〜2文
- source_url: 実在性や投資実績を確認した参照元URL

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


def ai_search_vcs(condition: str, sector_options: list = None) -> dict:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {"error": "GEMINI_API_KEY が設定されていません。.env を確認してください。"}

    client = genai.Client(api_key=api_key)

    system_prompt = SYSTEM_PROMPT
    if sector_options:
        system_prompt += "\n投資領域マスタ（sectorsはこの中から選ぶこと）:\n" + ", ".join(sector_options)

    response = None
    last_error = None
    for attempt, wait in enumerate([0, 20, 45, 90], start=1):
        if wait:
            time.sleep(wait)
        try:
            response = client.models.generate_content(
                model=MODEL,
                contents=f"以下の条件に合うアプローチ先のVC/CVCを探してください。\n\n{condition}",
                config=types.GenerateContentConfig(
                    system_instruction=system_prompt,
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
