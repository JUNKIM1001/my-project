// src/main.js — 起点。canvas / scene / hud / charts / game を結線し、rAF ループを回す。
//   - 実時間 dt は 1 フレーム最大 0.25 s（タブ復帰時の暴走防止）
//   - dt × 倍速 を 0.05 s のサブステップに分割して game.step → (sim.step → metrics.update)
//   - scene.update は毎フレーム、HUD / チャートは ~10 Hz（CPU 節約）

import { createScene } from './render/scene.js';
import { createHud } from './ui/hud.js';
import { createCharts } from './ui/charts.js';
import { createGame, STEP } from './game.js';

const MAX_FRAME_DT = 0.25;
const HUD_INTERVAL = 0.1;
/** 1 フレームで進めるサブステップ数の上限（0.25 s × ×4 = 20 ステップが通常の最大） */
const MAX_SUBSTEPS = 40;

const canvas = document.getElementById('scene');
const hud = createHud(document);
const charts = createCharts(hud.chartCanvases);
const scene = createScene(canvas, { sag: false });
if (scene.unavailable) showWebglUnavailable(scene.error);
const game = createGame({ hud, charts, scene });
game.boot();

/** WebGL 初期化失敗時の静的メッセージ（3D なしでも sim / HUD / チャートは動くので起動は続ける） */
function showWebglUnavailable(error) {
  const box = document.createElement('div');
  box.id = 'webgl-unavailable';
  box.setAttribute('role', 'alert');
  box.style.cssText =
    'position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);z-index:1;max-width:min(520px,calc(100vw - 48px));' +
    'padding:18px 22px;border-radius:12px;background:rgba(10,14,22,0.9);border:1px solid rgba(255,255,255,0.16);' +
    'color:#e8ecf3;font-size:14px;line-height:1.7;text-align:center;pointer-events:none;';
  box.textContent = '3D 描画（WebGL）を利用できません。ブラウザの設定でハードウェアアクセラレーションを有効にするか、別のブラウザでお試しください。';
  document.body.appendChild(box);
  if (error) console.warn('[jam-lab] WebGL unavailable:', error);
}

// 開発・検証用フック（DevTools から game.step() や scene を触るため。通信・保存には使わない）
window.__jamlab = { game, scene, hud, charts };

let last = performance.now();
let acc = 0;      // sim 時間の未消化分 [s]
let hudAcc = 0;   // HUD 更新までの実時間 [s]

function frame(now) {
  const dtReal = Math.min(MAX_FRAME_DT, Math.max(0, (now - last) / 1000));
  last = now;

  if (game.isSimRunning()) {
    acc += dtReal * game.speed;
    let n = 0;
    while (acc >= STEP && n < MAX_SUBSTEPS) {
      game.step(STEP);
      acc -= STEP;
      n++;
    }
    if (n >= MAX_SUBSTEPS) acc = 0; // 追いつけない場合は捨てる（スパイラル防止）
  } else {
    acc = 0;
  }

  const sim = game.sim;
  // speed: カメラ追従の平滑化をゲーム倍速に合わせる（×2/×4 で追従距離が伸びないように）
  if (sim) scene.update(sim, dtReal, { cameraMode: game.cameraMode, playerIndex: sim.playerIndex, speed: game.speed });

  hudAcc += dtReal;
  if (hudAcc >= HUD_INTERVAL) {
    hudAcc = 0;
    game.refreshHud();
  }
  requestAnimationFrame(frame);
}
requestAnimationFrame(frame);

// リサイズ: three.js と 2D チャートの両方を追従させる
let resizeTimer = 0;
function onResize() {
  scene.resize();
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => { charts.resize(); game.refreshHud(); }, 60);
}
window.addEventListener('resize', onResize);
window.addEventListener('orientationchange', onResize);

// タブ復帰時は経過時間を切り捨て（rAF 停止中の dt を持ち越さない）
document.addEventListener('visibilitychange', () => {
  if (!document.hidden) { last = performance.now(); acc = 0; }
});
