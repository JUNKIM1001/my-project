require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { sendDailySummary } = require('../src/dailySummary');

sendDailySummary()
  .then((text) => {
    console.log('送信内容:\n' + text);
    console.log('\n送信完了');
  })
  .catch((e) => console.error('エラー:', e.data || e));
