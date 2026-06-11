require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { WebClient } = require('@slack/web-api');

const client = new WebClient(process.env.SLACK_BOT_TOKEN);

(async () => {
  const auth = await client.auth.test();
  console.log('接続成功:', auth.team, auth.user, auth.bot_id);

  if (process.env.SLACK_USER_ID) {
    const im = await client.conversations.open({ users: process.env.SLACK_USER_ID });
    await client.chat.postMessage({
      channel: im.channel.id,
      text: '日程調整AI秘書: 接続テストに成功しました🎉',
    });
    console.log('DM送信完了');
  } else {
    console.log('SLACK_USER_IDが未設定のため、DM送信はスキップしました');
  }
})().catch((e) => console.error('エラー:', e.data || e));
