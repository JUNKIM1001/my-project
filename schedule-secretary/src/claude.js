const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// 自然言語の日程調整依頼を解析して構造化データにする
async function parseScheduleRequest(text) {
  const now = new Date();
  const nowStr = now.toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' });

  const msg = await anthropic.messages.create({
    model: 'claude-sonnet-4-5',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: `現在日時: ${nowStr} (日本時間)

以下はユーザーからの日程調整依頼です。内容を解析し、JSON形式のみで出力してください（説明文不要）。

依頼: "${text}"

出力JSON形式:
{
  "person": "調整相手の名前（不明なら null）",
  "email": "調整相手のメールアドレス（本文中にあれば抽出、なければ null）",
  "purpose": "用件・タイトル",
  "durationMinutes": 所要時間（分、指定なければ60）,
  "rangeFromDays": 候補探索開始（今日から何日後か、整数。例: 「来週」なら7程度、指定なければ0）,
  "rangeToDays": 候補探索終了（今日から何日後か、整数。指定なければ rangeFromDays + 7）
}`,
    }],
  });

  const textContent = msg.content.find((c) => c.type === 'text').text;
  const jsonMatch = textContent.match(/\{[\s\S]*\}/);
  return JSON.parse(jsonMatch[0]);
}

// 提案文の生成（相手への送信用）
async function generateProposalMessage({ person, purpose, slots }) {
  const slotsText = slots.map((s, i) => {
    const start = new Date(s.start);
    const end = new Date(s.end);
    const dateStr = start.toLocaleDateString('ja-JP', { month: 'long', day: 'numeric', weekday: 'short' });
    const startTime = start.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit', hour12: false });
    const endTime = end.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit', hour12: false });
    return `${i + 1}. ${dateStr} ${startTime}〜${endTime}`;
  }).join('\n');

  return `${person ? person + '様\n\n' : ''}${purpose}の件、以下の日程はいかがでしょうか。\n\n${slotsText}\n\nご都合の良い日時をお知らせいただけますと幸いです。\nよろしくお願いいたします。`;
}

// DMメッセージの意図を分類する
// pendingList: [{ reqId, person, purpose, email, slots: [{index, start, end}] }]
async function classifyMessage(text, pendingList) {
  const now = new Date();
  const nowStr = now.toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' });

  const pendingText = pendingList.length === 0
    ? '(現在、確定待ちの依頼はありません)'
    : pendingList.map((p) => {
        const slotsText = p.slots.map((s) => `    - index ${s.index}: ${new Date(s.start).toLocaleString('ja-JP')} 〜 ${new Date(s.end).toLocaleTimeString('ja-JP')}`).join('\n');
        return `- reqId: ${p.reqId}\n  相手: ${p.person || '不明'} ${p.email || ''}\n  用件: ${p.purpose || ''}\n  候補:\n${slotsText}`;
      }).join('\n');

  const msg = await anthropic.messages.create({
    model: 'claude-sonnet-4-5',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: `現在日時: ${nowStr} (日本時間)

あなたは日程調整AI秘書です。ユーザーからのSlack DMメッセージの意図を分類してください。

# 現在確定待ちの依頼一覧
${pendingText}

# ユーザーのメッセージ
"${text}"

# 分類ルール
- 新しい日程調整の依頼（例: 「Aさんと来週MTGしたい」）→ intent: "schedule"
- 確定待ちの依頼に対し、相手から返事が来た旨の報告（例: 「Aさんは火曜14時でOKだそうです」）で、上記一覧の中から該当する依頼・候補が特定できる → intent: "confirm"、該当する reqId と slot index を指定
- 確定待ちの依頼をキャンセルしたい → intent: "cancel"、reqId を指定
- 確定待ち一覧を見たい → intent: "list"
- 上記のいずれにも該当しない、または情報不足で特定できない → intent: "other"

JSON形式のみで出力してください（説明文不要）:
{
  "intent": "schedule" | "confirm" | "cancel" | "list" | "other",
  "reqId": "該当する場合のreqId、なければnull",
  "slotIndex": 該当する場合のindex（数値）、なければnull,
  "reply": "intentがotherの場合のユーザーへの簡潔な返信メッセージ"
}`,
    }],
  });

  const textContent = msg.content.find((c) => c.type === 'text').text;
  const jsonMatch = textContent.match(/\{[\s\S]*\}/);
  return JSON.parse(jsonMatch[0]);
}

// 受信メールが日程調整の依頼かどうかを判定し、構造化データを返す
async function parseEmailRequest({ fromName, fromEmail, subject, body }) {
  const now = new Date();
  const nowStr = now.toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' });

  const msg = await anthropic.messages.create({
    model: 'claude-sonnet-4-5',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: `現在日時: ${nowStr} (日本時間)

以下は受信したメールです。これが「日程調整・打ち合わせの日程を相談・依頼するメール」かどうかを判定し、JSON形式のみで出力してください（説明文不要）。

差出人: ${fromName} <${fromEmail}>
件名: ${subject}
本文:
"""
${body}
"""

出力JSON形式:
{
  "isRequest": true/false,
  "person": "差出人の名前（${JSON.stringify(fromName)}を使用）",
  "email": "${fromEmail}",
  "purpose": "用件・タイトル（件名や本文から推測）",
  "durationMinutes": 所要時間（分、不明なら60）,
  "rangeFromDays": 候補探索開始（今日から何日後か、整数。指定なければ0）,
  "rangeToDays": 候補探索終了（今日から何日後か、整数。指定なければ rangeFromDays + 7）
}`,
    }],
  });

  const textContent = msg.content.find((c) => c.type === 'text').text;
  const jsonMatch = textContent.match(/\{[\s\S]*\}/);
  return JSON.parse(jsonMatch[0]);
}

module.exports = { parseScheduleRequest, generateProposalMessage, classifyMessage, parseEmailRequest };
