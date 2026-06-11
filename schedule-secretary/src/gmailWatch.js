const { listUnreadMessages, getMessageDetails, markAsRead } = require('./google');
const { parseEmailRequest } = require('./claude');
const store = require('./store');
const { sendDM } = require('./slack');
const { buildProposalBlocksFromParsed } = require('./slackApp');

async function checkGmailInbox() {
  let ids;
  try {
    ids = await listUnreadMessages(10);
  } catch (e) {
    console.error('Gmail取得エラー:', e.message || e);
    return;
  }

  for (const id of ids) {
    if (store.isEmailProcessed(id)) continue;

    try {
      const msg = await getMessageDetails(id);
      const result = await parseEmailRequest(msg);

      store.markEmailProcessed(id);
      await markAsRead(id);

      if (!result.isRequest) continue;

      const parsed = {
        person: result.person || msg.fromName,
        email: result.email || msg.fromEmail,
        purpose: result.purpose,
        durationMinutes: result.durationMinutes,
        rangeFromDays: result.rangeFromDays,
        rangeToDays: result.rangeToDays,
        gmailThreadId: msg.threadId,
        gmailMessageIdHeader: msg.messageIdHeader,
        gmailReferences: msg.references,
        gmailSubject: msg.subject,
      };

      const headerNote = `📩 *Gmailで日程調整の依頼を検知しました*\n差出人: ${msg.fromName} <${msg.fromEmail}>\n件名: ${msg.subject}`;

      const { blocks, text } = await buildProposalBlocksFromParsed(parsed, headerNote);
      if (!blocks) {
        await sendDM(`${headerNote}\n\n${text}`);
      } else {
        await sendDM(text, blocks);
      }
    } catch (e) {
      console.error('メール処理エラー:', e.message || e);
    }
  }
}

module.exports = { checkGmailInbox };
