const fs = require('fs');
const path = require('path');
const { google } = require('googleapis');

const CREDENTIALS_PATH = path.join(__dirname, '../config/credentials.json');
const TOKEN_PATH = path.join(__dirname, '../config/token.json');

function getAuthClient() {
  const credentials = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf-8'));
  const token = JSON.parse(fs.readFileSync(TOKEN_PATH, 'utf-8'));
  const { client_secret, client_id, redirect_uris } = credentials.installed || credentials.web;
  const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);
  oAuth2Client.setCredentials(token);
  return oAuth2Client;
}

function getCalendar() {
  return google.calendar({ version: 'v3', auth: getAuthClient() });
}

// 指定日（Dateオブジェクト、ローカル時間）の予定一覧を取得
async function getEventsForDay(date, calendarId = 'primary') {
  const calendar = getCalendar();

  const start = new Date(date);
  start.setHours(0, 0, 0, 0);
  const end = new Date(date);
  end.setHours(23, 59, 59, 999);

  const res = await calendar.events.list({
    calendarId,
    timeMin: start.toISOString(),
    timeMax: end.toISOString(),
    singleEvents: true,
    orderBy: 'startTime',
  });

  return res.data.items || [];
}

// 予定をカレンダーに登録（仮ブロック / 確定）
async function createEvent({ summary, start, end, description, attendees, status, sendUpdates }, calendarId = 'primary') {
  const calendar = getCalendar();
  const requestBody = {
    summary,
    description,
    start: { dateTime: new Date(start).toISOString(), timeZone: 'Asia/Tokyo' },
    end: { dateTime: new Date(end).toISOString(), timeZone: 'Asia/Tokyo' },
  };
  if (status) requestBody.status = status; // 'tentative' | 'confirmed'
  if (attendees) requestBody.attendees = attendees.map((email) => ({ email }));

  const res = await calendar.events.insert({
    calendarId,
    requestBody,
    sendUpdates: sendUpdates || 'none', // 'all' で招待メール送信
  });
  return res.data;
}

// 予定を確定状態に更新（出席者追加・招待送信）
async function confirmEvent(eventId, { attendees } = {}, calendarId = 'primary') {
  const calendar = getCalendar();
  const requestBody = { status: 'confirmed' };
  if (attendees && attendees.length) {
    requestBody.attendees = attendees.map((email) => ({ email }));
  }
  const res = await calendar.events.patch({
    calendarId,
    eventId,
    requestBody,
    sendUpdates: attendees && attendees.length ? 'all' : 'none',
  });
  return res.data;
}

// 予定削除
async function deleteEvent(eventId, calendarId = 'primary') {
  const calendar = getCalendar();
  await calendar.events.delete({ calendarId, eventId, sendUpdates: 'none' }).catch((e) => {
    if (e.code !== 410 && e.code !== 404) throw e;
  });
}

// Gmail下書き作成
async function createDraft({ to, subject, body }) {
  const gmail = google.gmail({ version: 'v1', auth: getAuthClient() });

  const messageParts = [
    `To: ${to}`,
    'Content-Type: text/plain; charset=utf-8',
    'MIME-Version: 1.0',
    `Subject: =?utf-8?B?${Buffer.from(subject).toString('base64')}?=`,
    '',
    body,
  ];
  const message = messageParts.join('\n');
  const encodedMessage = Buffer.from(message)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');

  const res = await gmail.users.drafts.create({
    userId: 'me',
    requestBody: { message: { raw: encodedMessage } },
  });
  return res.data;
}

function getGmail() {
  return google.gmail({ version: 'v1', auth: getAuthClient() });
}

// 受信トレイの未読メールID一覧を取得
async function listUnreadMessages(maxResults = 10) {
  const gmail = getGmail();
  const res = await gmail.users.messages.list({
    userId: 'me',
    q: 'is:unread in:inbox',
    maxResults,
  });
  return (res.data.messages || []).map((m) => m.id);
}

function decodeBase64Url(data) {
  return Buffer.from(data.replace(/-/g, '+').replace(/_/g, '/'), 'base64').toString('utf-8');
}

function extractPlainText(payload) {
  if (!payload) return '';
  if (payload.mimeType === 'text/plain' && payload.body?.data) {
    return decodeBase64Url(payload.body.data);
  }
  if (payload.parts) {
    for (const part of payload.parts) {
      const text = extractPlainText(part);
      if (text) return text;
    }
  }
  if (payload.mimeType === 'text/html' && payload.body?.data) {
    return decodeBase64Url(payload.body.data).replace(/<[^>]+>/g, ' ');
  }
  return '';
}

// メール詳細を取得（送信者・件名・本文・スレッド情報）
async function getMessageDetails(id) {
  const gmail = getGmail();
  const res = await gmail.users.messages.get({ userId: 'me', id, format: 'full' });
  const headers = res.data.payload.headers || [];
  const getHeader = (name) => headers.find((h) => h.name.toLowerCase() === name.toLowerCase())?.value || '';

  const fromHeader = getHeader('From');
  const fromEmailMatch = fromHeader.match(/<([^>]+)>/);
  const fromEmail = fromEmailMatch ? fromEmailMatch[1] : fromHeader.trim();
  const fromName = fromHeader.replace(/<[^>]+>/, '').trim().replace(/^"|"$/g, '');

  return {
    id,
    threadId: res.data.threadId,
    from: fromHeader,
    fromEmail,
    fromName,
    subject: getHeader('Subject'),
    messageIdHeader: getHeader('Message-ID'),
    references: getHeader('References'),
    body: extractPlainText(res.data.payload).slice(0, 3000),
  };
}

// メールを既読にする
async function markAsRead(id) {
  const gmail = getGmail();
  await gmail.users.messages.modify({
    userId: 'me',
    id,
    requestBody: { removeLabelIds: ['UNREAD'] },
  });
}

// 既存スレッドへの返信下書きを作成
async function createReplyDraft({ threadId, to, subject, body, inReplyTo, references }) {
  const gmail = getGmail();
  const replySubject = /^re:/i.test(subject) ? subject : `Re: ${subject}`;

  const headerLines = [
    `To: ${to}`,
    'Content-Type: text/plain; charset=utf-8',
    'MIME-Version: 1.0',
    `Subject: =?utf-8?B?${Buffer.from(replySubject).toString('base64')}?=`,
  ];
  if (inReplyTo) headerLines.push(`In-Reply-To: ${inReplyTo}`);
  if (references || inReplyTo) headerLines.push(`References: ${references || inReplyTo}`);

  const message = [...headerLines, '', body].join('\n');
  const encodedMessage = Buffer.from(message)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');

  const res = await gmail.users.drafts.create({
    userId: 'me',
    requestBody: { message: { raw: encodedMessage, threadId } },
  });
  return res.data;
}

module.exports = {
  getAuthClient, getCalendar, getEventsForDay, createEvent, confirmEvent, deleteEvent, createDraft,
  listUnreadMessages, getMessageDetails, markAsRead, createReplyDraft,
};
