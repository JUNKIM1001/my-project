require('dotenv').config({ path: require('path').join(__dirname, '.env') });
const cron = require('node-cron');
const { sendDailySummary } = require('./src/dailySummary');
const { app: slackApp } = require('./src/slackApp');
const { checkGmailInbox } = require('./src/gmailWatch');

console.log('schedule-secretary 起動しました');

(async () => {
  await slackApp.start();
  console.log('Slack Bolt app (Socket Mode) 起動しました');
})();

// 毎朝7:00 (Asia/Tokyo) にデイリーサマリーを送信
cron.schedule('0 7 * * *', async () => {
  console.log('デイリーサマリーを送信します...');
  try {
    await sendDailySummary();
    console.log('送信完了');
  } catch (e) {
    console.error('送信失敗:', e.data || e);
  }
}, { timezone: 'Asia/Tokyo' });

console.log('毎朝7:00にデイリーサマリーを送信するようスケジュールしました');

// 5分おきにGmail受信トレイをチェック
cron.schedule('*/5 * * * *', async () => {
  try {
    await checkGmailInbox();
  } catch (e) {
    console.error('Gmailチェック失敗:', e.data || e);
  }
}, { timezone: 'Asia/Tokyo' });

console.log('5分おきにGmail受信トレイをチェックするようスケジュールしました');
