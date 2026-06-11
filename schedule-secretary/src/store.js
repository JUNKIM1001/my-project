const fs = require('fs');
const path = require('path');

const STORE_PATH = path.join(__dirname, '../config/pending.json');

function load() {
  try {
    return JSON.parse(fs.readFileSync(STORE_PATH, 'utf-8'));
  } catch {
    return {};
  }
}

function save(data) {
  fs.writeFileSync(STORE_PATH, JSON.stringify(data, null, 2));
}

function get(reqId) {
  return load()[reqId];
}

function set(reqId, value) {
  const data = load();
  data[reqId] = value;
  save(data);
}

function remove(reqId) {
  const data = load();
  delete data[reqId];
  save(data);
}

function all() {
  const data = load();
  const result = {};
  for (const key of Object.keys(data)) {
    if (!key.startsWith('_')) result[key] = data[key];
  }
  return result;
}

// 処理済みメールIDの管理
function isEmailProcessed(id) {
  const data = load();
  return (data._processedEmails || []).includes(id);
}

function markEmailProcessed(id) {
  const data = load();
  const list = data._processedEmails || [];
  list.push(id);
  // 直近1000件のみ保持
  data._processedEmails = list.slice(-1000);
  save(data);
}

module.exports = { get, set, remove, all, isEmailProcessed, markEmailProcessed };
