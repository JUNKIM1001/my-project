require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { findFreeSlots } = require('../src/freeSlots');

(async () => {
  const from = new Date();
  const to = new Date();
  to.setDate(to.getDate() + 7);

  const slots = await findFreeSlots({ from, to, durationMinutes: 60, maxResults: 3 });
  slots.forEach((s) => console.log(s.start.toLocaleString('ja-JP'), '-', s.end.toLocaleTimeString('ja-JP')));
})().catch((e) => console.error(e));
