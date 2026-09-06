// src/ui/charts.js — Canvas 2D チャート 3 種。
//   (a) timeline : 車列の平均速度の時系列（metrics.history）
//   (b) spaceTime: 時空間図（metrics.spaceTime）。横 = 時間（右が最新）、縦 = プレイヤーから後方の車
//   (c) minimap  : 周回路ミニマップ（shared/track.js の pointAt を使う）
// すべて DPR 対応。描画は ~10 Hz 想定。毎フレームの大量アロケーションを避けるため、
// 時空間図は ImageData を再利用し、ミニマップの道路形状は Path2D をキャッシュする。

import { pointAt, RADIUS, STRAIGHT, LENGTH } from '../shared/track.js';

const FONT = '-apple-system, BlinkMacSystemFont, "Helvetica Neue", "Hiragino Sans", "Noto Sans JP", sans-serif';
const C_TEAL = [45, 212, 191];
const C_AMBER = [245, 165, 36];
const C_RED = [229, 72, 77];
const ACCENT_HI = '#8ea4ea';
const C_AMBER_CSS = `rgb(${C_AMBER.join(',')})`;
const GRID = 'rgba(255,255,255,0.08)';
const TEXT_FAINT = 'rgba(232,236,243,0.42)';

/** 速度比 0..1 → 色。0 = 赤（停止）、0.5 = 橙（減速）、1 = 青緑（流れている） */
const PALETTE_N = 48;
const paletteRGB = new Uint8ClampedArray(PALETTE_N * 3);
const paletteCSS = new Array(PALETTE_N);
(function buildPalette() {
  for (let i = 0; i < PALETTE_N; i++) {
    const r = i / (PALETTE_N - 1);
    const [a, b, t] = r < 0.5 ? [C_RED, C_AMBER, r / 0.5] : [C_AMBER, C_TEAL, (r - 0.5) / 0.5];
    const rgb = [0, 1, 2].map((k) => Math.round(a[k] + (b[k] - a[k]) * t));
    paletteRGB.set(rgb, i * 3);
    paletteCSS[i] = `rgb(${rgb[0]},${rgb[1]},${rgb[2]})`;
  }
})();
const clamp01 = (x) => (x < 0 ? 0 : x > 1 ? 1 : x);
const paletteIndex = (ratio) => Math.round(clamp01(Number.isFinite(ratio) ? ratio : 0) * (PALETTE_N - 1));
export const speedColor = (ratio) => paletteCSS[paletteIndex(ratio)];

/**
 * canvas を CSS サイズ × DPR に合わせ、CSS ピクセル座標系の ctx を返す。
 * サイズが変わっていなければ backing store を触らない（クリアも呼び出し側が行う）。
 */
function fit(cv) {
  const w = cv.clientWidth | 0;
  const h = cv.clientHeight | 0;
  if (w === 0 || h === 0) return null;
  const dpr = Math.min(2, window.devicePixelRatio || 1);
  if (cv.width !== Math.round(w * dpr) || cv.height !== Math.round(h * dpr)) {
    cv.width = Math.round(w * dpr);
    cv.height = Math.round(h * dpr);
  }
  const ctx = cv.__ctx || (cv.__ctx = cv.getContext('2d'));
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  return { ctx, w, h };
}

function placeholder(ctx, w, h, text) {
  ctx.fillStyle = TEXT_FAINT;
  ctx.font = `12px ${FONT}`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(text, w / 2, h / 2);
}

export function createCharts({ timeline, spaceTime, minimap }) {
  let lastArgs = null;

  // ---------------------------------------------------------------
  // (a) 平均速度の時系列
  // ---------------------------------------------------------------
  function drawTimeline({ metrics, v0, eventTime }) {
    const f = fit(timeline);
    if (!f) return;
    const { ctx, w, h } = f;
    ctx.clearRect(0, 0, w, h);
    const padL = 34, padR = 12, padT = 8, padB = 16;
    const pw = w - padL - padR, ph = h - padT - padB;
    if (pw <= 0 || ph <= 0) return;

    const v0kmh = (v0 || 22.2) * 3.6;
    const vmax = Math.max(40, Math.ceil((v0kmh * 1.15) / 20) * 20);
    // モバイルの縦積みで描画域が低いときは目盛りを 0 / 中央 / 上限 の 3 本に間引く（ラベル重なり防止）
    const gridStep = ph < 70 ? vmax / 2 : (vmax > 100 ? 40 : 20);

    // 目盛り
    ctx.font = `10px ${FONT}`;
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'right';
    ctx.lineWidth = 1;
    for (let g = 0; g <= vmax; g += gridStep) {
      const y = Math.round(padT + ph * (1 - g / vmax)) + 0.5;
      ctx.strokeStyle = GRID;
      ctx.beginPath(); ctx.moveTo(padL, y); ctx.lineTo(padL + pw, y); ctx.stroke();
      ctx.fillStyle = TEXT_FAINT;
      ctx.fillText(String(g), padL - 6, y);
    }
    // 希望速度の参照線
    {
      const y = padT + ph * (1 - v0kmh / vmax);
      ctx.setLineDash([3, 4]);
      ctx.strokeStyle = 'rgba(142,164,234,0.45)';
      ctx.beginPath(); ctx.moveTo(padL, y); ctx.lineTo(padL + pw, y); ctx.stroke();
      ctx.setLineDash([]);
    }

    const hist = metrics && metrics.history;
    if (!hist || !hist.t || hist.t.length < 2) { placeholder(ctx, w, h, '走行データを記録中…'); return; }
    const t = hist.t, v = hist.meanSpeed, n = t.length;
    const t1 = t[n - 1];
    const t0 = Math.min(t[0], t1 - 60); // 最低 60 秒幅で表示
    const span = Math.max(1e-6, t1 - t0);
    const xOf = (tt) => padL + pw * (tt - t0) / span;
    const yOf = (ms) => padT + ph * (1 - clamp01((ms * 3.6) / vmax));

    // 面 + 線
    ctx.beginPath();
    for (let i = 0; i < n; i++) { const x = xOf(t[i]), y = yOf(v[i]); if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y); }
    ctx.strokeStyle = paletteCSS[PALETTE_N - 1];
    ctx.lineWidth = 1.6;
    ctx.lineJoin = 'round';
    ctx.stroke();
    ctx.lineTo(xOf(t1), padT + ph);
    ctx.lineTo(xOf(t[0]), padT + ph);
    ctx.closePath();
    ctx.fillStyle = 'rgba(45,212,191,0.10)';
    ctx.fill();

    // イベント時刻
    if (eventTime != null && eventTime >= t0 && eventTime <= t1) {
      const x = Math.round(xOf(eventTime)) + 0.5;
      ctx.setLineDash([3, 3]);
      ctx.strokeStyle = 'rgba(245,165,36,0.8)';
      ctx.beginPath(); ctx.moveTo(x, padT); ctx.lineTo(x, padT + ph); ctx.stroke();
      ctx.setLineDash([]);
      ctx.fillStyle = C_AMBER_CSS;
      ctx.textAlign = x > padL + pw - 50 ? 'right' : 'left';
      ctx.fillText('イベント', x + (ctx.textAlign === 'left' ? 4 : -4), padT + 7);
    }

    // 時間軸ラベル
    ctx.fillStyle = TEXT_FAINT;
    ctx.textBaseline = 'alphabetic';
    ctx.textAlign = 'left';
    ctx.fillText(`${Math.round(t0)} s`, padL, h - 4);
    ctx.textAlign = 'right';
    ctx.fillText(`${Math.round(t1)} s`, padL + pw, h - 4);

    // 現在値の点
    const cx = xOf(t1), cy = yOf(v[n - 1]);
    ctx.fillStyle = speedColor(v[n - 1] / (v0 || 22.2));
    ctx.beginPath(); ctx.arc(cx, cy, 3, 0, Math.PI * 2); ctx.fill();
  }
  // ---------------------------------------------------------------
  // (b) 時空間図
  // ---------------------------------------------------------------
  let stOff = null, stCtx = null, stImg = null, stN = 0, stCols = 0;
  const ST_MAX_COLS = 240;

  function drawSpaceTime({ metrics, sim, eventTime }) {
    const f = fit(spaceTime);
    if (!f) return;
    const { ctx, w, h } = f;
    ctx.clearRect(0, 0, w, h);
    const padL = 46, padR = 8, padT = 6, padB = 16;
    const pw = w - padL - padR, ph = h - padT - padB;
    if (pw <= 0 || ph <= 0) return;

    // 縦軸ラベル
    ctx.font = `10px ${FONT}`;
    ctx.fillStyle = TEXT_FAINT;
    ctx.textAlign = 'right';
    ctx.textBaseline = 'top';
    ctx.fillStyle = ACCENT_HI;
    ctx.fillText('あなた ▸', padL - 4, padT);
    ctx.fillStyle = TEXT_FAINT;
    if (ph >= 60) {
      ctx.textBaseline = 'middle';
      ctx.fillText('後方 ↓', padL - 4, padT + ph * 0.5);
      ctx.textBaseline = 'bottom';
      ctx.fillText('1 周先', padL - 4, padT + ph);
    } else {
      // 低い描画域（モバイル縦積み）では 2 ラベルに絞る
      ctx.textBaseline = 'bottom';
      ctx.fillText('後方 ↓', padL - 4, padT + ph);
    }

    // 枠
    ctx.strokeStyle = GRID;
    ctx.lineWidth = 1;
    ctx.strokeRect(padL + 0.5, padT + 0.5, pw - 1, ph - 1);

    const st = metrics && metrics.spaceTime;
    const rows = st && st.rows;
    if (!rows || rows.length === 0 || !sim) { placeholder(ctx, w, h, '走行を始めると、速度の伝わり方が模様として現れます'); return; }

    const times = st.times || [];
    const cols = rows.length;
    const N = rows[0].length;
    const maxCols = Math.max(cols, ST_MAX_COLS);
    if (stN !== N || stCols !== maxCols || !stOff) {
      stOff = document.createElement('canvas');
      stOff.width = maxCols;
      stOff.height = N;
      stCtx = stOff.getContext('2d');
      stImg = stCtx.createImageData(maxCols, N);
      stN = N; stCols = maxCols;
    }
    const data = stImg.data;
    data.fill(0); // 未記録領域は透明
    // 車数変更直後は playerIndex >= N になり得るので N で正規化（負値も吸収）
    const pi = (((sim.playerIndex | 0) % N) + N) % N;
    const x0 = maxCols - cols; // 最新を右端に
    for (let c = 0; c < cols; c++) {
      const row = rows[c];
      if (!row || row.length !== N) continue;
      const x = x0 + c;
      for (let k = 0; k < N; k++) {
        // k = 0 がプレイヤー、k が増えるほど後方の車（周回路なので最後は 1 周先 = 前方）
        let idx = pi - k; if (idx < 0) idx += N;
        const v = row[idx];
        const p = paletteIndex(v === undefined ? 1 : v) * 3; // 未記録は「流れている」扱い（偽の赤を描かない）
        const o = (k * maxCols + x) * 4;
        data[o] = paletteRGB[p]; data[o + 1] = paletteRGB[p + 1]; data[o + 2] = paletteRGB[p + 2]; data[o + 3] = 235;
      }
    }
    stCtx.putImageData(stImg, 0, 0);
    ctx.imageSmoothingEnabled = false;
    ctx.drawImage(stOff, 0, 0, maxCols, N, padL, padT, pw, ph);

    // プレイヤー行の目印（左端の小さな青いティック）
    ctx.fillStyle = ACCENT_HI;
    ctx.fillRect(padL - 2, padT, 2, Math.max(2, ph / N));

    // 時間軸: 列 → 時刻。列幅は記録間隔（0.5 s 想定、times から推定）
    const tNow = times.length ? times[times.length - 1] : 0;
    const dtCol = times.length > 1 ? (times[times.length - 1] - times[0]) / (times.length - 1) : 0.5;
    const xOfTime = (tt) => padL + pw * (x0 + (cols - 1) - (tNow - tt) / (dtCol || 0.5) + 0.5) / maxCols;
    ctx.fillStyle = TEXT_FAINT;
    ctx.textBaseline = 'alphabetic';
    ctx.textAlign = 'right';
    ctx.fillText('現在', padL + pw, h - 4);
    ctx.textAlign = 'left';
    ctx.fillText(`${Math.round(maxCols * (dtCol || 0.5))} 秒前`, padL, h - 4);

    if (eventTime != null && eventTime <= tNow) {
      const x = xOfTime(eventTime);
      if (x >= padL && x <= padL + pw) {
        ctx.setLineDash([3, 3]);
        ctx.strokeStyle = 'rgba(245,165,36,0.9)';
        ctx.beginPath(); ctx.moveTo(Math.round(x) + 0.5, padT); ctx.lineTo(Math.round(x) + 0.5, padT + ph); ctx.stroke();
        ctx.setLineDash([]);
      }
    }
  }

  // ---------------------------------------------------------------
  // (c) 周回路ミニマップ
  // ---------------------------------------------------------------
  let mmKey = '', mmPath = null, mmSagPath = null, mmStartX = 0, mmStartY = 0;
  let mmScale = 1, mmCx = 0, mmCy = 0;
  // 周回路（スタジアム形）の外接矩形: 長辺 = z 方向、短辺 = x 方向
  const TRACK_W = STRAIGHT + 2 * RADIUS; // 427.3
  const TRACK_H = 2 * RADIUS;            // 127.3

  /** track 座標 (x, z) → canvas。長辺を横に寝かせる */
  function projX(p) { return mmCx + p.z * mmScale; }
  function projY(p) { return mmCy + p.x * mmScale; }

  function buildTrackPaths(w, h) {
    const pad = 10;
    mmScale = Math.min((w - pad * 2) / TRACK_W, (h - pad * 2) / TRACK_H);
    mmCx = w / 2; mmCy = h / 2;
    mmPath = new Path2D();
    for (let s = 0; s <= LENGTH; s += 5) {
      const p = pointAt(s);
      if (s === 0) mmPath.moveTo(projX(p), projY(p)); else mmPath.lineTo(projX(p), projY(p));
    }
    mmPath.closePath();
    // サグ区間 250〜650 m（下り→上り）
    mmSagPath = new Path2D();
    for (let s = 250; s <= 650; s += 5) {
      const p = pointAt(s);
      if (s === 250) mmSagPath.moveTo(projX(p), projY(p)); else mmSagPath.lineTo(projX(p), projY(p));
    }
    const p0 = pointAt(0);
    mmStartX = projX(p0); mmStartY = projY(p0);
  }

  function drawMinimap({ sim, v0, sag }) {
    const f = fit(minimap);
    if (!f) return;
    const { ctx, w, h } = f;
    ctx.clearRect(0, 0, w, h);
    const key = `${w}x${h}`;
    if (key !== mmKey) { buildTrackPaths(w, h); mmKey = key; }

    // 道路
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.strokeStyle = 'rgba(255,255,255,0.13)';
    ctx.lineWidth = Math.max(5, 7 * mmScale);
    ctx.stroke(mmPath);
    if (sag) {
      ctx.strokeStyle = 'rgba(245,165,36,0.35)';
      ctx.lineWidth = Math.max(5, 7 * mmScale);
      ctx.stroke(mmSagPath);
      ctx.fillStyle = 'rgba(245,165,36,0.8)';
      ctx.font = `9px ${FONT}`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      const pm = pointAt(400);
      ctx.fillText('サグ', projX(pm), projY(pm) + (projY(pm) > mmCy ? 12 : -12));
    }
    // スタート地点のティック
    ctx.fillStyle = 'rgba(255,255,255,0.25)';
    ctx.fillRect(mmStartX - 1, mmStartY - 6, 2, 12);

    if (!sim || !sim.cars) return;
    const cars = sim.cars;
    const vref = v0 || 22.2;
    const r = Math.max(2.2, Math.min(3.6, 3.2 * mmScale));
    let player = null;
    for (let i = 0; i < cars.length; i++) {
      const c = cars[i];
      const p = pointAt(c.s);
      if (i === sim.playerIndex) { player = p; continue; }
      ctx.fillStyle = speedColor(c.v / vref);
      ctx.beginPath(); ctx.arc(projX(p), projY(p), r, 0, Math.PI * 2); ctx.fill();
    }
    if (player) {
      const x = projX(player), y = projY(player);
      ctx.fillStyle = ACCENT_HI;
      ctx.beginPath(); ctx.arc(x, y, r + 1.2, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = '#fff';
      ctx.lineWidth = 1.5;
      ctx.beginPath(); ctx.arc(x, y, r + 3.5, 0, Math.PI * 2); ctx.stroke();
    }
  }

  /**
   * 全チャートを描く。args = { sim, metrics, v0, eventTime, sag }
   * metrics が null（タイトル / ブリーフィング中）でもミニマップは描く。
   */
  function draw(args) {
    lastArgs = args;
    drawTimeline(args);
    drawSpaceTime(args);
    drawMinimap(args);
  }

  /** リサイズ時: サイズは fit() が毎回追従するので、直近の引数で再描画するだけ */
  function resize() {
    mmKey = '';
    if (lastArgs) draw(lastArgs);
  }

  return { draw, resize, speedColor };
}
