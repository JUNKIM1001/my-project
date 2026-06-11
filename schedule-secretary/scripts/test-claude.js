require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { parseScheduleRequest } = require('../src/claude');

(async () => {
  const result = await parseScheduleRequest('Aさんと来週中に1時間のMTGを調整したい');
  console.log(result);
})().catch((e) => console.error(e));
