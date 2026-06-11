const { WebClient } = require('@slack/web-api');

const client = new WebClient(process.env.SLACK_BOT_TOKEN);
let dmChannelId = null;

async function getDmChannel() {
  if (dmChannelId) return dmChannelId;
  const im = await client.conversations.open({ users: process.env.SLACK_USER_ID });
  dmChannelId = im.channel.id;
  return dmChannelId;
}

async function sendDM(text, blocks) {
  const channel = await getDmChannel();
  return client.chat.postMessage({ channel, text, blocks });
}

module.exports = { client, sendDM, getDmChannel };
