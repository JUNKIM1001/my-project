// Google OAuth 初回認証スクリプト
// 使い方: node scripts/google-auth.js
// config/credentials.json (Google Cloud Console でダウンロードした OAuth クライアントID) が必要

const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { google } = require('googleapis');

const SCOPES = [
  'https://www.googleapis.com/auth/calendar',
  'https://www.googleapis.com/auth/gmail.readonly',
  'https://www.googleapis.com/auth/gmail.send',
  'https://www.googleapis.com/auth/gmail.compose',
  'https://www.googleapis.com/auth/gmail.modify',
];

const CREDENTIALS_PATH = path.join(__dirname, '../config/credentials.json');
const TOKEN_PATH = path.join(__dirname, '../config/token.json');

function main() {
  if (!fs.existsSync(CREDENTIALS_PATH)) {
    console.error(`credentials.json が見つかりません: ${CREDENTIALS_PATH}`);
    console.error('Google Cloud Console > APIとサービス > 認証情報 から OAuth クライアントID (デスクトップアプリ) を作成し、JSONをダウンロードして config/credentials.json として保存してください。');
    process.exit(1);
  }

  const credentials = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf-8'));
  const { client_secret, client_id, redirect_uris } = credentials.installed || credentials.web;
  const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);

  const authUrl = oAuth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
    prompt: 'consent',
  });

  console.log('以下のURLをブラウザで開いて認証してください:');
  console.log(authUrl);

  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  rl.question('\n表示された認証コードを貼り付けてください: ', (code) => {
    rl.close();
    oAuth2Client.getToken(code.trim(), (err, token) => {
      if (err) {
        console.error('トークン取得に失敗しました:', err);
        process.exit(1);
      }
      oAuth2Client.setCredentials(token);
      fs.writeFileSync(TOKEN_PATH, JSON.stringify(token, null, 2));
      console.log(`トークンを保存しました: ${TOKEN_PATH}`);
    });
  });
}

main();
