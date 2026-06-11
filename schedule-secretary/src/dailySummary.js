const { getEventsForDay } = require('./google');
const { sendDM } = require('./slack');

function formatTime(dt) {
  const d = new Date(dt);
  return d.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit', hour12: false });
}

function formatEvent(event) {
  if (event.start.date) {
    // 終日予定
    return `・終日: ${event.summary || '(タイトルなし)'}`;
  }
  const start = formatTime(event.start.dateTime);
  const end = formatTime(event.end.dateTime);
  let line = `・${start}-${end} ${event.summary || '(タイトルなし)'}`;
  if (event.location) line += ` @ ${event.location}`;
  if (event.hangoutLink) line += `\n   ${event.hangoutLink}`;
  return line;
}

async function sendDailySummary(date = new Date()) {
  const events = await getEventsForDay(date);
  const dateStr = date.toLocaleDateString('ja-JP', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'short' });

  let text;
  if (events.length === 0) {
    text = `おはようございます！\n*${dateStr}* の予定はありません。`;
  } else {
    const lines = events.map(formatEvent).join('\n');
    text = `おはようございます！\n*${dateStr}* の予定（${events.length}件）\n\n${lines}`;
  }

  await sendDM(text);
  return text;
}

module.exports = { sendDailySummary };
