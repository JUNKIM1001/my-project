const { getCalendar } = require('./google');

const BUSINESS_START_HOUR = 9;
const BUSINESS_END_HOUR = 18;

// busyイベント取得（範囲内、終日予定は除外）
async function getBusyEvents(timeMin, timeMax, calendarId = 'primary') {
  const calendar = getCalendar();
  const res = await calendar.events.list({
    calendarId,
    timeMin: timeMin.toISOString(),
    timeMax: timeMax.toISOString(),
    singleEvents: true,
    orderBy: 'startTime',
  });
  return (res.data.items || [])
    .filter((e) => e.start.dateTime && e.end.dateTime)
    .map((e) => ({ start: new Date(e.start.dateTime), end: new Date(e.end.dateTime) }));
}

// 指定期間内・営業時間内・durationMinutes分の空き枠を最大maxResults件探す
async function findFreeSlots({ from, to, durationMinutes = 60, maxResults = 3 }) {
  const busy = await getBusyEvents(from, to);
  const slots = [];

  const cursor = new Date(from);
  cursor.setMinutes(0, 0, 0);

  while (cursor < to && slots.length < maxResults) {
    const day = new Date(cursor);
    day.setHours(BUSINESS_START_HOUR, 0, 0, 0);
    const dayEnd = new Date(cursor);
    dayEnd.setHours(BUSINESS_END_HOUR, 0, 0, 0);

    const dow = day.getDay();
    if (dow === 0 || dow === 6) {
      cursor.setDate(cursor.getDate() + 1);
      cursor.setHours(0, 0, 0, 0);
      continue;
    }

    if (day < from) day.setTime(from.getTime());

    // 30分刻みでスロット候補をチェック
    let slotStart = new Date(day);
    // 切り上げ: 30分単位に丸める
    const minutes = slotStart.getMinutes();
    if (minutes > 0 && minutes <= 30) slotStart.setMinutes(30, 0, 0);
    else if (minutes > 30) { slotStart.setHours(slotStart.getHours() + 1, 0, 0, 0); }

    // この日の最初の空き枠を1件だけ採用し、日をまたいで分散させる
    while (slotStart < dayEnd) {
      const slotEnd = new Date(slotStart.getTime() + durationMinutes * 60000);
      if (slotEnd > dayEnd) break;

      const overlaps = busy.some((b) => slotStart < b.end && slotEnd > b.start);
      if (!overlaps && slotStart > new Date()) {
        slots.push({ start: new Date(slotStart), end: new Date(slotEnd) });
        break;
      }
      slotStart = new Date(slotStart.getTime() + 30 * 60000);
    }

    // 翌日へ
    cursor.setDate(cursor.getDate() + 1);
    cursor.setHours(0, 0, 0, 0);
  }

  return slots;
}

module.exports = { findFreeSlots, getBusyEvents };
