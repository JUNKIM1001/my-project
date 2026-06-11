const { App } = require('@slack/bolt');
const { findFreeSlots } = require('./freeSlots');
const { parseScheduleRequest, generateProposalMessage, classifyMessage } = require('./claude');
const { createEvent, confirmEvent, deleteEvent, createDraft, createReplyDraft } = require('./google');
const store = require('./store');

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  appToken: process.env.SLACK_APP_TOKEN,
  socketMode: true,
});

let reqCounter = 0;

function fmtSlot(slot) {
  const start = new Date(slot.start);
  const end = new Date(slot.end);
  const dateStr = start.toLocaleDateString('ja-JP', { month: 'long', day: 'numeric', weekday: 'short' });
  const startTime = start.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit', hour12: false });
  const endTime = end.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit', hour12: false });
  return `${dateStr} ${startTime}〜${endTime}`;
}

// /schedule コマンド: 候補抽出
app.command('/schedule', async ({ command, ack, respond }) => {
  await ack();

  const text = command.text?.trim();
  if (!text) {
    await respond('使い方: `/schedule Aさん(a@example.com)と来週中に1時間のMTGを調整したい` のように依頼内容を入力してください。\n\n相手から返事が来たら `/confirm` で確定できます。');
    return;
  }

  await respond('依頼を解析しています...🤔');

  try {
    const parsed = await parseScheduleRequest(text);

    const from = new Date();
    from.setDate(from.getDate() + (parsed.rangeFromDays || 0));
    const to = new Date();
    to.setDate(to.getDate() + (parsed.rangeToDays || (parsed.rangeFromDays || 0) + 7));

    const slots = await findFreeSlots({ from, to, durationMinutes: parsed.durationMinutes || 60, maxResults: 3 });

    if (slots.length === 0) {
      await respond('指定期間内に空き枠が見つかりませんでした。期間を広げて再度お試しください。');
      return;
    }

    const reqId = `req_${++reqCounter}_${Date.now()}`;

    const blocks = [
      { type: 'section', text: { type: 'mrkdwn', text: `*${parsed.purpose || '日程調整'}*${parsed.person ? `（${parsed.person}様）` : ''}${parsed.email ? `\n${parsed.email}` : ''}\n所要時間: ${parsed.durationMinutes || 60}分\n\n以下の候補をすべて仮ブロックして相手に提案します。` } },
      { type: 'divider' },
    ];
    slots.forEach((slot, i) => {
      blocks.push({ type: 'section', text: { type: 'mrkdwn', text: `候補${i + 1}: ${fmtSlot(slot)}` } });
    });
    blocks.push({
      type: 'actions',
      elements: [{
        type: 'button',
        text: { type: 'plain_text', text: '全候補を仮ブロックして提案' },
        style: 'primary',
        action_id: 'tentative_block_all',
        value: JSON.stringify({ reqId, parsed, slots }),
      }],
    });

    await respond({ replace_original: true, blocks, text: '日程候補を提示しました' });
  } catch (e) {
    console.error(e);
    await respond('エラーが発生しました: ' + (e.message || e));
  }
});

// 全候補を仮ブロック
app.action('tentative_block_all', async ({ ack, body, respond }) => {
  await ack();
  const { reqId, parsed, slots } = JSON.parse(body.actions[0].value);

  try {
    const slotsWithEventId = [];
    for (const slot of slots) {
      const ev = await createEvent({
        summary: `[仮] ${parsed.purpose || '打ち合わせ'}${parsed.person ? `（${parsed.person}）` : ''}`,
        start: slot.start,
        end: slot.end,
        description: '日程調整AI秘書による仮ブロック。/confirm で確定してください。',
        status: 'tentative',
      });
      slotsWithEventId.push({ ...slot, eventId: ev.id });
    }

    store.set(reqId, { parsed, slots: slotsWithEventId, createdAt: Date.now() });

    const proposalText = await generateProposalMessage({ person: parsed.person, purpose: parsed.purpose, slots });

    const blocks = [
      { type: 'section', text: { type: 'mrkdwn', text: `✅ ${slots.length}件の候補を仮ブロックしました。` } },
      { type: 'divider' },
      { type: 'section', text: { type: 'mrkdwn', text: `*相手への提案文*\n\`\`\`${proposalText}\`\`\`` } },
    ];

    if (parsed.email) {
      try {
        if (parsed.gmailThreadId) {
          await createReplyDraft({
            threadId: parsed.gmailThreadId,
            to: parsed.email,
            subject: parsed.gmailSubject || `${parsed.purpose || '日程調整'}のご相談`,
            body: proposalText,
            inReplyTo: parsed.gmailMessageIdHeader,
            references: parsed.gmailReferences,
          });
          blocks.push({ type: 'context', elements: [{ type: 'mrkdwn', text: `📧 ${parsed.email} への返信下書き（元メールのスレッド）をGmailに作成しました。` }] });
        } else {
          await createDraft({ to: parsed.email, subject: `${parsed.purpose || '日程調整'}のご相談`, body: proposalText });
          blocks.push({ type: 'context', elements: [{ type: 'mrkdwn', text: `📧 ${parsed.email} 宛のメール下書きをGmailに作成しました。` }] });
        }
      } catch (e) {
        blocks.push({ type: 'context', elements: [{ type: 'mrkdwn', text: `⚠️ メール下書き作成に失敗: ${e.message || e}` }] });
      }
    }

    blocks.push({ type: 'context', elements: [{ type: 'mrkdwn', text: `相手から返事が来たら \`/confirm\` を実行し、この依頼（ID: ${reqId}）を確定してください。` }] });

    await respond({ replace_original: true, text: '仮ブロック完了', blocks });
  } catch (e) {
    console.error(e);
    await respond({ replace_original: false, text: '仮ブロックに失敗しました: ' + (e.message || e) });
  }
});

// /confirm コマンド: 保留中の依頼一覧 or 確定
app.command('/confirm', async ({ command, ack, respond }) => {
  await ack();

  const pending = store.all();
  const ids = Object.keys(pending);

  if (ids.length === 0) {
    await respond('現在、確定待ちの日程調整依頼はありません。');
    return;
  }

  const blocks = [{ type: 'section', text: { type: 'mrkdwn', text: '*確定待ちの依頼*\n相手が選んだ日程のボタンを押すと確定し、Googleカレンダーの招待が送信されます。' } }];

  for (const reqId of ids) {
    const { parsed, slots } = pending[reqId];
    blocks.push({ type: 'divider' });
    blocks.push({ type: 'section', text: { type: 'mrkdwn', text: `*${parsed.purpose || '日程調整'}*${parsed.person ? `（${parsed.person}）` : ''}${parsed.email ? ` ${parsed.email}` : ''}` } });
    slots.forEach((slot, i) => {
      blocks.push({
        type: 'section',
        text: { type: 'mrkdwn', text: `${fmtSlot(slot)}` },
        accessory: {
          type: 'button',
          text: { type: 'plain_text', text: 'この日程で確定' },
          style: 'primary',
          action_id: 'confirm_slot',
          value: JSON.stringify({ reqId, slotIndex: i }),
        },
      });
    });
    blocks.push({
      type: 'actions',
      elements: [{
        type: 'button',
        text: { type: 'plain_text', text: 'この依頼をキャンセル（全削除）' },
        style: 'danger',
        action_id: 'cancel_request',
        value: JSON.stringify({ reqId }),
      }],
    });
  }

  await respond({ blocks, text: '確定待ちの依頼一覧' });
});

// 候補確定 → 招待送信、他の仮ブロック削除
app.action('confirm_slot', async ({ ack, body, respond }) => {
  await ack();
  const { reqId, slotIndex } = JSON.parse(body.actions[0].value);
  const pending = store.get(reqId);
  if (!pending) {
    await respond({ replace_original: false, text: 'この依頼は見つかりません（既に処理済みかもしれません）。' });
    return;
  }

  const { parsed, slots } = pending;
  const chosen = slots[slotIndex];

  try {
    await confirmEvent(chosen.eventId, { attendees: parsed.email ? [parsed.email] : [] });

    for (let i = 0; i < slots.length; i++) {
      if (i !== slotIndex) {
        await deleteEvent(slots[i].eventId);
      }
    }

    store.remove(reqId);

    await respond({
      replace_original: false,
      text: '確定しました',
      blocks: [
        { type: 'section', text: { type: 'mrkdwn', text: `✅ *${fmtSlot(chosen)}* で確定しました。${parsed.email ? `${parsed.email} へカレンダー招待を送信しました。` : ''}\n他の仮ブロックは削除しました。` } },
      ],
    });
  } catch (e) {
    console.error(e);
    await respond({ replace_original: false, text: '確定処理に失敗しました: ' + (e.message || e) });
  }
});

// 依頼キャンセル
app.action('cancel_request', async ({ ack, body, respond }) => {
  await ack();
  const { reqId } = JSON.parse(body.actions[0].value);
  const pending = store.get(reqId);
  if (!pending) {
    await respond({ replace_original: false, text: 'この依頼は見つかりません（既に処理済みかもしれません）。' });
    return;
  }

  for (const slot of pending.slots) {
    await deleteEvent(slot.eventId);
  }
  store.remove(reqId);

  await respond({ replace_original: false, text: `依頼をキャンセルし、仮ブロックを全て削除しました。` });
});

// 確定待ち一覧をBlock Kitで生成
function buildPendingBlocks(pending) {
  const ids = Object.keys(pending);
  if (ids.length === 0) {
    return [{ type: 'section', text: { type: 'mrkdwn', text: '現在、確定待ちの日程調整依頼はありません。' } }];
  }
  const blocks = [{ type: 'section', text: { type: 'mrkdwn', text: '*確定待ちの依頼*' } }];
  for (const reqId of ids) {
    const { parsed, slots } = pending[reqId];
    blocks.push({ type: 'divider' });
    blocks.push({ type: 'section', text: { type: 'mrkdwn', text: `*${parsed.purpose || '日程調整'}*${parsed.person ? `（${parsed.person}）` : ''}${parsed.email ? ` ${parsed.email}` : ''}` } });
    slots.forEach((slot, i) => {
      blocks.push({
        type: 'section',
        text: { type: 'mrkdwn', text: `${fmtSlot(slot)}` },
        accessory: { type: 'button', text: { type: 'plain_text', text: 'この日程で確定' }, style: 'primary', action_id: 'confirm_slot', value: JSON.stringify({ reqId, slotIndex: i }) },
      });
    });
    blocks.push({ type: 'actions', elements: [{ type: 'button', text: { type: 'plain_text', text: 'この依頼をキャンセル（全削除）' }, style: 'danger', action_id: 'cancel_request', value: JSON.stringify({ reqId }) }] });
  }
  return blocks;
}

// パース済みデータから候補提示ブロックを生成
async function buildProposalBlocksFromParsed(parsed, headerNote) {
  const from = new Date();
  from.setDate(from.getDate() + (parsed.rangeFromDays || 0));
  const to = new Date();
  to.setDate(to.getDate() + (parsed.rangeToDays || (parsed.rangeFromDays || 0) + 7));

  const slots = await findFreeSlots({ from, to, durationMinutes: parsed.durationMinutes || 60, maxResults: 3 });

  if (slots.length === 0) {
    return { blocks: null, text: '指定期間内に空き枠が見つかりませんでした。期間を広げて再度お試しください。' };
  }

  const reqId = `req_${++reqCounter}_${Date.now()}`;
  const blocks = [];
  if (headerNote) blocks.push({ type: 'section', text: { type: 'mrkdwn', text: headerNote } });
  blocks.push({ type: 'section', text: { type: 'mrkdwn', text: `*${parsed.purpose || '日程調整'}*${parsed.person ? `（${parsed.person}様）` : ''}${parsed.email ? `\n${parsed.email}` : ''}\n所要時間: ${parsed.durationMinutes || 60}分\n\n以下の候補をすべて仮ブロックして相手に提案します。` } });
  blocks.push({ type: 'divider' });
  slots.forEach((slot, i) => {
    blocks.push({ type: 'section', text: { type: 'mrkdwn', text: `候補${i + 1}: ${fmtSlot(slot)}` } });
  });
  blocks.push({
    type: 'actions',
    elements: [{ type: 'button', text: { type: 'plain_text', text: '全候補を仮ブロックして提案' }, style: 'primary', action_id: 'tentative_block_all', value: JSON.stringify({ reqId, parsed, slots }) }],
  });

  return { blocks, text: '日程候補を提示しました' };
}

// 新規日程調整依頼の候補提示ブロック（自然文から）
async function buildScheduleProposalBlocks(text) {
  const parsed = await parseScheduleRequest(text);
  return buildProposalBlocksFromParsed(parsed);
}

// DMでのメッセージを意図解析して処理
app.message(async ({ message, say }) => {
  if (message.channel_type !== 'im') return;
  if (message.subtype || message.bot_id) return; // bot自身の発言などは無視

  const text = message.text?.trim();
  if (!text) return;

  try {
    const pending = store.all();
    const pendingList = Object.entries(pending).map(([reqId, v]) => ({
      reqId,
      person: v.parsed.person,
      email: v.parsed.email,
      purpose: v.parsed.purpose,
      slots: v.slots.map((s, index) => ({ index, start: s.start, end: s.end })),
    }));

    const result = await classifyMessage(text, pendingList);

    switch (result.intent) {
      case 'schedule': {
        const { blocks, text: fallbackText } = await buildScheduleProposalBlocks(text);
        if (!blocks) await say(fallbackText);
        else await say({ blocks, text: fallbackText });
        break;
      }
      case 'confirm': {
        if (result.reqId == null || result.slotIndex == null || !pending[result.reqId]) {
          await say('該当する依頼・候補を特定できませんでした。`一覧` と送ると確定待ちの依頼を確認できます。');
          break;
        }
        const { parsed, slots } = pending[result.reqId];
        const chosen = slots[result.slotIndex];
        await confirmEvent(chosen.eventId, { attendees: parsed.email ? [parsed.email] : [] });
        for (let i = 0; i < slots.length; i++) {
          if (i !== result.slotIndex) await deleteEvent(slots[i].eventId);
        }
        store.remove(result.reqId);
        await say(`✅ *${fmtSlot(chosen)}* で確定しました。${parsed.email ? `${parsed.email} へカレンダー招待を送信しました。` : ''}\n他の仮ブロックは削除しました。`);
        break;
      }
      case 'cancel': {
        if (result.reqId == null || !pending[result.reqId]) {
          await say('該当する依頼を特定できませんでした。`一覧` と送ると確定待ちの依頼を確認できます。');
          break;
        }
        for (const slot of pending[result.reqId].slots) await deleteEvent(slot.eventId);
        store.remove(result.reqId);
        await say('依頼をキャンセルし、仮ブロックを全て削除しました。');
        break;
      }
      case 'list': {
        await say({ blocks: buildPendingBlocks(pending), text: '確定待ちの依頼一覧' });
        break;
      }
      default: {
        await say(result.reply || 'すみません、うまく理解できませんでした。日程調整の依頼や、相手からの返事の報告を送ってください。');
      }
    }
  } catch (e) {
    console.error(e);
    await say('エラーが発生しました: ' + (e.message || e));
  }
});

module.exports = { app, buildProposalBlocksFromParsed };
