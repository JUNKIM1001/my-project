// src/ui/charts.js — Canvas 2D チャート 4 種。
//   (a) timeline : 車列の平均速度の時系列（metrics.history）
//   (b) spaceTime: 時空間図（metrics.spaceTime）。横 = 時間（右が最新）、縦 = プレイヤーから後方の車
//   (c) minimap  : 周回路ミニマップ（shared/track.js の pointAt を使う）
//   (d) scatter  : 用量反応（横 = 踏んだ秒数、縦 = 後続車の総時間損失）。試行ごとに点が増える。
//                 縦軸に台数ではなく損失秒を使うのは、台数が閾値判定で頭打ちになる一方、
//                 損失秒は踏んだ長さに対して滑らかに増えるため（BRAKE_REDESIGN.md の実測）
// すべて DPR 対応。描画は ~10 Hz 想定。毎フレームの大量アロケーションを避けるため、
// 時空間図は ImageData を再利用し、ミニマップの道路形状は Path2D をキャッシュする。

import { pointAt, RADIUS, STRAIGHT, LENGTH } from '../shared/track.js';
import { jamHeat, heatColor, heatSummary, HEAT_SEGMENTS } from '../shared/heat.js';

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

export function createCharts({ timeline, spaceTime, minimap, scatter, course, courseReadout, ringReadout }) {
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
  const mmCache = new Map();   // canvas → 経路キャッシュ
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

  // 渋滞ヒート（区間ごとの重さ）。draw のたびに sim から計算し、ミニマップとコース全体の両方で使う
  let heatBuf = new Float32Array(HEAT_SEGMENTS);
  const HEAT_PALETTE = Array.from({ length: 32 }, (_, i) => {
    const c = heatColor(i / 31);
    return `rgb(${Math.round(c[0]*255)},${Math.round(c[1]*255)},${Math.round(c[2]*255)})`;
  });
  const heatCss = (h) => HEAT_PALETTE[Math.max(0, Math.min(31, Math.round(h * 31)))];

  /**
   * 周回路の地図。道路そのものを「渋滞の重さ」で色分けし（流れている区間は道路色のまま、
   * 減速は橙、停止は赤の帯）、その上に車の点とプレイヤーを描く。target を変えて 2 つの canvas に描ける。
   */
  function drawRing(target, { sim, v0, sag, heat, observing }) {
    const f = fit(target);
    if (!f) return;
    const { ctx, w, h } = f;
    ctx.clearRect(0, 0, w, h);
    // 経路は canvas ごとにキャッシュ（ミニマップとコース全体でサイズが違うため、共通変数だと毎回作り直しになる）
    const key = `${w}x${h}`;
    let cache = mmCache.get(target);
    if (!cache || cache.key !== key) {
      buildTrackPaths(w, h);
      cache = { key, path: mmPath, sag: mmSagPath, sx: mmStartX, sy: mmStartY, scale: mmScale, cx: mmCx, cy: mmCy };
      mmCache.set(target, cache);
    } else {
      mmPath = cache.path; mmSagPath = cache.sag; mmStartX = cache.sx; mmStartY = cache.sy;
      mmScale = cache.scale; mmCx = cache.cx; mmCy = cache.cy;
    }

    // 道路（下地）
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    const roadW = Math.max(6, 9 * mmScale);
    ctx.strokeStyle = 'rgba(255,255,255,0.16)';
    ctx.lineWidth = roadW;
    ctx.stroke(mmPath);
    if (sag) {
      ctx.strokeStyle = 'rgba(245,165,36,0.30)';
      ctx.lineWidth = roadW;
      ctx.stroke(mmSagPath);
      ctx.fillStyle = 'rgba(245,165,36,0.8)';
      ctx.font = `9px ${FONT}`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      const pm = pointAt(400);
      ctx.fillText('サグ', projX(pm), projY(pm) + (projY(pm) > mmCy ? 12 : -12));
    }
    // 渋滞の帯: 重さ 0.05 以上の区間だけを色で上書き（2 m 刻み、線分で描く）
    if (heat) {
      const segLen = LENGTH / heat.length;
      ctx.lineCap = 'butt';
      ctx.lineWidth = roadW;
      for (let k = 0; k < heat.length; k++) {
        const hk = heat[k];
        if (hk < 0.05) continue;
        const a = pointAt(k * segLen), b = pointAt((k + 1) * segLen);
        ctx.strokeStyle = heatCss(hk);
        ctx.beginPath(); ctx.moveTo(projX(a), projY(a)); ctx.lineTo(projX(b), projY(b)); ctx.stroke();
      }
      ctx.lineCap = 'round';
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
      ctx.beginPath(); ctx.arc(x, y, r + 1.6, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = '#fff';
      ctx.lineWidth = 1.5;
      ctx.beginPath(); ctx.arc(x, y, r + 4, 0, Math.PI * 2); ctx.stroke();
      if (observing) {   // 観察中はプレイヤーの後方（波が進む側）に「←」を添える
        ctx.fillStyle = 'rgba(255,255,255,0.75)';
        ctx.font = `10px ${FONT}`;
        ctx.textAlign = 'center';
        ctx.fillText('あなた', x, y - r - 9);
      }
    }
  }

  function drawMinimap(args) {
    const { sim } = args;
    const v0 = args.v0 || 22.2;
    const ref = Math.min(args.ref || (sim && sim.equilibriumSpeed > 0 ? sim.equilibriumSpeed : v0), v0);   // v0 を超えない
    const heat = args.heat || (sim && sim.cars ? jamHeat(sim.cars, ref, heatBuf) : null);
    if (heat) heatBuf = heat;
    const a = { ...args, heat };
    drawRing(minimap, a);
    if (course) drawRing(course, a);
    // 読み上げ用の一行: 渋滞区間の割合と最も重い地点
    if (heat && (courseReadout || ringReadout)) {
      const sm = heatSummary(heat);
      const txt = sm.maxHeat < 0.05
        ? '渋滞なし ─ 車列は流れています'
        : `コース全体のうち ${Math.round(sm.jammedRatio * 100)}% が渋滞 ・ いちばん重い場所はスタートから ${Math.round(sm.maxAt)} m`;
      if (courseReadout && courseReadout.textContent !== txt) courseReadout.textContent = txt;
      if (ringReadout && ringReadout.textContent !== txt) ringReadout.textContent = txt;
    }
  }

  // ---------------------------------------------------------------
  // (d) 用量反応の散布図（踏んだ秒数 → 後続車の総時間損失）
  // ---------------------------------------------------------------
  const SCAT_SEC_MAX = 6;
  // 新しい点の「ポン」（0.4 秒）: 点数が増えた時刻を覚え、経過時間で拡大→収束を描く。
  // draw は ~10 Hz なので、アニメ中だけ rAF で散布図を追加再描画して滑らかにする
  const SCAT_POP_MS = 400;
  let scatPrevN = 0, scatPopAt = -Infinity, scatRaf = 0;
  const scatRedraw = () => { scatRaf = 0; if (lastArgs) drawScatter(lastArgs); };

  /** 目盛りの上限を切りのよい値に丸める（18 → 20、4 → 5） */
  function niceMax(v) {
    if (!(v > 0)) return 5;
    const pow = Math.pow(10, Math.floor(Math.log10(v)));
    const n = v / pow;
    return (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * pow;
  }

  function drawScatter({ attempts }) {
    if (!scatter) return;
    const f = fit(scatter);
    if (!f) return;
    const { ctx, w, h } = f;
    ctx.clearRect(0, 0, w, h);
    const padL = 30, padR = 12, padT = 10, padB = 20;
    const pw = w - padL - padR, ph = h - padT - padB;
    if (pw <= 0 || ph <= 0) return;

    // 軸の範囲（点がなくても枠と目盛りは出す）
    const list = attempts || [];
    let maxSec = 0, maxAff = 0, n = 0;
    for (let i = 0; i < list.length; i++) {
      const a = list[i];
      if (!a || !Number.isFinite(a.sec) || !Number.isFinite(a.timeLoss)) continue;
      if (a.sec > maxSec) maxSec = a.sec;
      if (a.timeLoss > maxAff) maxAff = a.timeLoss;
      n++;
    }
    // 点が増えたらポップ開始（減った = レベル切替なので静かにリセット）
    if (n > scatPrevN) scatPopAt = performance.now();
    scatPrevN = n;
    const popAge = (performance.now() - scatPopAt) / SCAT_POP_MS;  // 0..1 がアニメ中
    const xMax = Math.max(SCAT_SEC_MAX, Math.ceil(maxSec));
    const yMax = Math.max(30, niceMax(maxAff));
    const xOf = (s) => padL + pw * clamp01(s / xMax);
    const yOf = (c) => padT + ph * (1 - clamp01(c / yMax));

    // 目盛り（横線 4 本 + 秒の刻み）
    ctx.font = `10px ${FONT}`;
    ctx.lineWidth = 1;
    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    const yStep = yMax / (ph < 70 ? 2 : 4);
    for (let g = 0; g <= yMax + 1e-6; g += yStep) {
      const y = Math.round(yOf(g)) + 0.5;
      ctx.strokeStyle = GRID;
      ctx.beginPath(); ctx.moveTo(padL, y); ctx.lineTo(padL + pw, y); ctx.stroke();
      ctx.fillStyle = TEXT_FAINT;
      ctx.fillText(String(Math.round(g)), padL - 5, y);
    }
    ctx.strokeStyle = GRID;
    ctx.strokeRect(padL + 0.5, padT + 0.5, pw - 1, ph - 1);

    const xStep = xMax > 8 ? 2 : 1;
    ctx.fillStyle = TEXT_FAINT;
    ctx.textBaseline = 'top';
    for (let s = 0; s <= xMax + 1e-6; s += xStep) {
      const x = Math.round(xOf(s)) + 0.5;
      if (s > 0 && s < xMax) {
        ctx.strokeStyle = GRID;
        ctx.beginPath(); ctx.moveTo(x, padT); ctx.lineTo(x, padT + ph); ctx.stroke();
      }
      ctx.textAlign = s === 0 ? 'left' : (s >= xMax ? 'right' : 'center');
      ctx.fillText(String(s), x, padT + ph + 4);
    }
    // 軸の名前（目盛りと重ならないよう作図域の上端に置く）
    ctx.textBaseline = 'top';
    ctx.textAlign = 'left';
    ctx.fillText('縦: 損失 秒', padL + 4, padT + 3);
    ctx.textAlign = 'right';
    ctx.fillText('横: 踏んだ秒数', padL + pw - 4, padT + 3);

    if (n === 0) { placeholder(ctx, w, h, 'ブレーキを踏むと、ここに点が増えます'); return; }

    // 3 点以上たまったら最小二乗の近似線
    if (n >= 3) {
      let sx = 0, sy = 0, sxx = 0, sxy = 0;
      for (let i = 0; i < list.length; i++) {
        const a = list[i];
        if (!a || !Number.isFinite(a.sec) || !Number.isFinite(a.timeLoss)) continue;
        sx += a.sec; sy += a.timeLoss; sxx += a.sec * a.sec; sxy += a.sec * a.timeLoss;
      }
      const den = n * sxx - sx * sx;
      if (Math.abs(den) > 1e-9) {
        const slope = (n * sxy - sx * sy) / den;
        const inter = (sy - slope * sx) / n;
        ctx.save();
        ctx.beginPath(); ctx.rect(padL, padT, pw, ph); ctx.clip();
        ctx.strokeStyle = 'rgba(142,164,234,0.55)';
        ctx.setLineDash([4, 3]);
        ctx.lineWidth = 1.4;
        ctx.beginPath();
        ctx.moveTo(xOf(0), padT + ph * (1 - inter / yMax));
        ctx.lineTo(xOf(xMax), padT + ph * (1 - (inter + slope * xMax) / yMax));
        ctx.stroke();
        ctx.setLineDash([]);
        ctx.restore();
      }
    }

    // 点（直近は大きくアクセント色で強調）
    let last = null;
    for (let i = 0; i < list.length; i++) {
      const a = list[i];
      if (!a || !Number.isFinite(a.sec) || !Number.isFinite(a.timeLoss)) continue;
      last = a;
      if (i === list.length - 1) continue;
      ctx.fillStyle = 'rgba(142,164,234,0.42)';
      ctx.beginPath(); ctx.arc(xOf(a.sec), yOf(a.timeLoss), 3, 0, Math.PI * 2); ctx.fill();
    }
    if (last) {
      const x = xOf(last.sec), y = yOf(last.timeLoss);
      // ポップ: 拡大（最大 ≈1.8 倍）→ 収束。広がって消える輪も添える
      const popping = popAge >= 0 && popAge < 1;
      const s = popping ? 1 + 1.4 * (1 - popAge) * Math.sin(Math.PI * popAge) : 1;
      if (popping) {
        ctx.strokeStyle = `rgba(142,164,234,${(0.6 * (1 - popAge)).toFixed(3)})`;
        ctx.lineWidth = 2;
        ctx.beginPath(); ctx.arc(x, y, 7.5 + 16 * popAge, 0, Math.PI * 2); ctx.stroke();
      }
      ctx.fillStyle = ACCENT_HI;
      ctx.beginPath(); ctx.arc(x, y, 5 * s, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = 'rgba(255,255,255,0.75)';
      ctx.lineWidth = 1.4;
      ctx.beginPath(); ctx.arc(x, y, 7.5 * s, 0, Math.PI * 2); ctx.stroke();
      if (popping && !scatRaf) scatRaf = requestAnimationFrame(scatRedraw);
    }
  }

  /**
   * 全チャートを描く。args = { sim, metrics, v0, eventTime, sag, attempts }
   * attempts = [{ sec, timeLoss }]（散布図用。空配列 / 省略なら空の枠を描く）
   * metrics が null（タイトル / ブリーフィング中）でもミニマップは描く。
   */
  function draw(args) {
    lastArgs = args;
    drawTimeline(args);
    drawSpaceTime(args);
    drawMinimap(args);
    drawScatter(args);
  }

  /** リサイズ時: サイズは fit() が毎回追従するので、直近の引数で再描画するだけ */
  function resize() {
    mmKey = '';
    if (lastArgs) draw(lastArgs);
  }

  return { draw, resize, speedColor };
}
