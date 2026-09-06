// 車列シミュレーション本体 — IDM（Treiber 2000）+ 反応遅れ + 周回路（1 km リング）。
// DOM / three.js 非依存の純粋モジュール。main が 0.05 s 刻みで step(dt) を呼ぶ。
// 設計: DESIGN.md「モジュール API 契約 / src/sim/model.js」。
//  - 巡回順序不変: cars[i] の先行車は cars[(i+1)%N]、最後尾 cars[N-1] の先行車は cars[0]（1 周またぎ）。
//    s は [0, LENGTH) に wrap するため、先頭側の車が 0 を跨ぐと配列は数値昇順ではなくなる（昇順なのは初期配置だけ）。
//    不変なのは「配列上の巡回順序」であり、追い越しは起きない（衝突ガードが保証する）。
//  - 反応遅れ tau: 各車が (gap, Δv) の履歴をリングバッファに持ち、tau 秒前の値で IDM を評価。
//  - 数値安定化: a∈[-9,4]、v>=0、gap<0.3 m なら v=min(v, leader.v) かつ s を押し戻す（違反が消えるまで最大 N+2 pass）。
//    衝突ガードは巡回順序で unwrap した座標で行う（wrap 後の s で測ると逆向きの追い越しを見逃すため）。
//  - パラメータは物理量ごとに値域を clamp（LIMITS）。非有限値は無視して直前の値を維持する。
//  - 決定論: 自前 PRNG（mulberry32）。同じ seed・同じ入力列なら同じ結果。
import { LENGTH, CAR_LENGTH, wrap, forwardDistance, gradeAt } from '../shared/track.js';

/** 手動運転のアクセル最大加速 / ブレーキ最大減速 [m/s²]（スポーツカーらしく強め。衝突は別途防ぐ） */
export const A_MAX = 3.0;
export const B_MAX = 6.0;
/** 加速度クランプ [m/s²] */
const A_MIN_CLAMP = -9;
const A_MAX_CLAMP = 4;
/** これ未満には物理的に詰まらない最小バンパー間距離 [m] */
export const MIN_GAP = 0.3;
const GRAVITY = 9.81;
/** ブレーキランプ点灯のしきい値 [m/s²] */
const BRAKE_LAMP_A = -0.5;
/** 手動運転の上限速度（v0 比）。無限加速を避けるだけの緩い上限 */
const MANUAL_VMAX_RATIO = 1.5;

export const DEFAULTS = Object.freeze({
  carCount: 48,
  v0: 22.2,
  T: 1.05,
  tau: 0.65,
  a: 1.0,
  b: 1.6,
  s0: 2.0,
  noise: 0.0,
  sag: false,
  playerIndex: 0,
  seed: 1,
  initialSpeedRatio: 1,
});

/** 走行中に setParams で変更できるキー（carCount / sag / seed / playerIndex は reset 時のみ） */
const RUNTIME_KEYS = ['T', 'tau', 'v0', 'noise', 'a', 'b', 's0'];
/** 物理量ごとの値域 [min, max]。createSim / reset / setParams 共通で clamp する（NaN / Infinity 化の防止） */
export const LIMITS = Object.freeze({
  v0: [1, Infinity],
  a: [0.1, Infinity],
  b: [0.1, Infinity],
  T: [0, Infinity],
  s0: [0, Infinity],
  tau: [0, 5],
  noise: [0, 2],
  initialSpeedRatio: [0, Infinity],
});
/** 均等配置の定常速度 vEq に影響するキー（変更時に再計算） */
const EQ_KEYS = ['T', 'v0', 's0', 'a', 'b'];
/** 衝突ガードの判定余裕 [m]（wrap の丸め誤差で同じ車を毎 pass 押し戻さないため） */
const GAP_EPS = 1e-9;

/**
 * params を検証して in-place で正規化する。非有限値（undefined / NaN / Infinity / 文字列）は無視して
 * fallback（直前の値。無ければ DEFAULTS）に戻し、数値は LIMITS で clamp する。
 */
function sanitizeParams(params, fallback = DEFAULTS) {
  for (const k of Object.keys(LIMITS)) {
    const [lo, hi] = LIMITS[k];
    let v = params[k];
    if (typeof v !== 'number' || !Number.isFinite(v)) v = Number.isFinite(fallback[k]) ? fallback[k] : DEFAULTS[k];
    params[k] = Math.min(hi, Math.max(lo, v));
  }
  for (const k of ['carCount', 'seed', 'playerIndex']) {
    const v = params[k];
    if (typeof v !== 'number' || !Number.isFinite(v)) params[k] = Number.isFinite(fallback[k]) ? fallback[k] : DEFAULTS[k];
  }
  params.sag = !!params.sag;
  return params;
}

// ---- 乱数 -------------------------------------------------------------

/** mulberry32: 32bit シードの決定論的 PRNG。[0,1) を返す */
function mulberry32(seed) {
  let t = (seed | 0) >>> 0;
  return function next() {
    t = (t + 0x6D2B79F5) >>> 0;
    let r = Math.imul(t ^ (t >>> 15), 1 | t);
    r = (r + Math.imul(r ^ (r >>> 7), 61 | r)) ^ r;
    return ((r ^ (r >>> 14)) >>> 0) / 4294967296;
  };
}

/** Box-Muller 法で標準正規乱数 1 個（noise > 0 のときだけ呼ぶ） */
function gaussian(rng) {
  const u1 = 1 - rng(); // (0,1] にして log(0) を避ける
  const u2 = rng();
  return Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
}

// ---- 反応遅れ用リングバッファ ---------------------------------------------

function createHistory(cap) {
  return { gap: new Float64Array(cap), dv: new Float64Array(cap), cap, head: 0, count: 0 };
}

function histPush(h, gap, dv) {
  h.gap[h.head] = gap;
  h.dv[h.head] = dv;
  h.head = (h.head + 1) % h.cap;
  if (h.count < h.cap) h.count++;
}

/** k ステップ前の値を out に書く（k=0 が最新）。履歴が足りなければ最古の値を使う */
function histGet(h, k, out) {
  const kk = Math.min(k, h.count - 1);
  const idx = (h.head - 1 - kk + 2 * h.cap) % h.cap;
  out.gap = h.gap[idx];
  out.dv = h.dv[idx];
}

/** 容量変更。新しい方から min(count, newCap) 件を時系列順に保つ */
function histResize(h, newCap) {
  if (newCap === h.cap) return h;
  const n = createHistory(newCap);
  const keep = Math.min(h.count, newCap);
  const tmp = { gap: 0, dv: 0 };
  for (let k = keep - 1; k >= 0; k--) { // 古い順に詰め直す
    histGet(h, k, tmp);
    histPush(n, tmp.gap, tmp.dv);
  }
  return n;
}

// ---- IDM -------------------------------------------------------------------

/**
 * 均等配置（バンパー間 gap）で加速度 0 になる定常速度 [m/s]（v0 以下）。
 * Δv=0 なので s* = s0 + vT。二分法で解く。密度が高いほど v0 より大きく下がる。
 * metrics の基準速度・reset の初期速度に使う。
 */
export function equilibriumSpeed(params, gap) {
  const { v0, T, s0 } = params;
  if (gap <= s0) return 0;
  let lo = 0;
  let hi = v0;
  for (let i = 0; i < 60; i++) {
    const mid = (lo + hi) / 2;
    const f = 1 - Math.pow(mid / v0, 4) - Math.pow((s0 + mid * T) / gap, 2);
    if (f > 0) lo = mid; else hi = mid;
  }
  return (lo + hi) / 2;
}

/** IDM 加速度。gap / dv は（遅れを含む）観測値、v は自車の現在速度 */
function idmAccel(p, v, gap, dv) {
  const g = Math.max(gap, 0.1);
  const interaction = v * dv / (2 * Math.sqrt(p.a * p.b));
  const sStar = p.s0 + Math.max(0, v * p.T + interaction);
  return p.a * (1 - Math.pow(v / p.v0, 4) - (sStar / g) * (sStar / g));
}

// ---- シミュレータ ----------------------------------------------------------

export function createSim(options = {}) {
  const params = sanitizeParams({ ...DEFAULTS, ...options }, DEFAULTS);

  let cars = [];        // 外部公開の車配列（plain object）
  let hist = [];        // 車ごとの (gap, dv) 履歴
  let forcedDecel = []; // 強制ブレーキの減速度（0 で無効）
  let forcedUntil = []; // 強制ブレーキ終了時刻
  let u = new Float64Array(0); // step 内で使う unwrap 座標（巡回順序で展開した位置）
  let time = 0;
  let rng = mulberry32(params.seed);
  let lastDt = 0.05;    // 直近の step dt（tau 変更時のバッファ長計算に使う）
  let vEq = 0;
  const player = { mode: 'auto', throttle: 0, brake: 0 };
  const sample = { gap: 0, dv: 0 }; // histGet の一時出力

  const N = () => cars.length;
  const leaderIndex = (i) => (i + 1) % cars.length;
  /** i 番目の車と先行車のバンパー間距離 [m]（最後尾は cars[0] とのまたぎ距離） */
  const gapOf = (i) => forwardDistance(cars[i].s, cars[leaderIndex(i)].s) - CAR_LENGTH;

  function histCapacity(dt) {
    return Math.max(1, Math.round(params.tau / dt) + 1);
  }

  /** 現在の台数・パラメータでの均等配置の定常速度を再計算 */
  function recomputeEquilibrium(n = cars.length || params.carCount) {
    vEq = equilibriumSpeed(params, LENGTH / n - CAR_LENGTH);
  }

  function reset(overrides) {
    const prev = { ...params };
    if (overrides && typeof overrides === 'object') Object.assign(params, overrides);
    sanitizeParams(params, prev);
    const n = Math.max(2, Math.floor(params.carCount));
    params.carCount = n;
    params.playerIndex = Math.min(Math.max(0, params.playerIndex | 0), n - 1);
    time = 0;
    rng = mulberry32(params.seed);
    const spacing = LENGTH / n;
    recomputeEquilibrium(n);
    const v = Math.max(0, vEq * params.initialSpeedRatio);
    cars = [];
    hist = [];
    forcedDecel = [];
    forcedUntil = [];
    u = new Float64Array(n);
    const cap = histCapacity(lastDt);
    for (let i = 0; i < n; i++) {
      // 均等配置・定常速度。初期配置は s 昇順（走行後は wrap で崩れるが巡回順序は不変）
      cars.push({ s: i * spacing, v, a: 0, id: i, isPlayer: i === params.playerIndex, braking: false });
      hist.push(createHistory(cap));
      forcedDecel.push(0);
      forcedUntil.push(0);
    }
    player.mode = 'auto';
    player.throttle = 0;
    player.brake = 0;
  }

  /**
   * 走行中のパラメータ変更。RUNTIME_KEYS 以外は無視。非有限値は無視、範囲外は LIMITS で clamp。
   * tau が変われば履歴バッファ長を、T / v0 / s0 / a / b が変われば定常速度 vEq を再計算する
   * （metrics の基準速度がこれに追従する）。
   */
  function setParams(next) {
    if (!next || typeof next !== 'object') return;
    const prev = { ...params };
    for (const k of RUNTIME_KEYS) {
      const v = next[k];
      if (typeof v === 'number' && Number.isFinite(v)) params[k] = v;
    }
    sanitizeParams(params, prev);
    if (params.tau !== prev.tau) {
      const cap = histCapacity(lastDt);
      hist = hist.map((h) => histResize(h, cap));
    }
    if (EQ_KEYS.some((k) => params[k] !== prev[k])) recomputeEquilibrium();
  }

  function setPlayerControl({ mode, throttle, brake } = {}) {
    if (mode === 'auto' || mode === 'manual') player.mode = mode;
    if (throttle !== undefined) player.throttle = Math.min(1, Math.max(0, +throttle || 0));
    if (brake !== undefined) player.brake = Math.min(1, Math.max(0, +brake || 0));
  }

  function forceBrake(index, decel, duration) {
    forcedDecel[index] = Math.max(0, decel);
    forcedUntil[index] = time + Math.max(0, duration);
  }

  function pulseBrake({ decel = 2.0, duration = 2.0 } = {}) {
    forceBrake(params.playerIndex, decel, duration);
  }

  function triggerLeaderBrake({ aheadIndex = 3, decel = 3.0, duration = 2.5 } = {}) {
    const idx = (params.playerIndex + Math.max(1, aheadIndex | 0)) % cars.length;
    forceBrake(idx, decel, duration);
    return idx;
  }

  function step(dt) {
    if (!(dt > 0)) return;
    const n = cars.length;
    // 遅れステップ数。dt が変わって履歴が足りなければ拡張
    if (dt !== lastDt) {
      lastDt = dt;
      const cap = histCapacity(dt);
      if (cap !== hist[0].cap) hist = hist.map((h) => histResize(h, cap));
    }
    const k = Math.round(params.tau / dt);

    // 1) 現在の gap / Δv を全車分記録
    for (let i = 0; i < n; i++) {
      const lead = cars[leaderIndex(i)];
      histPush(hist[i], gapOf(i), cars[i].v - lead.v);
    }

    // 2) 加速度（全車、更新前の状態で評価）
    for (let i = 0; i < n; i++) {
      const c = cars[i];
      const lead = cars[leaderIndex(i)];
      let a;
      if (forcedDecel[i] > 0 && time < forcedUntil[i]) {
        a = -forcedDecel[i]; // 強制ブレーキは IDM / 手動より優先
      } else if (c.isPlayer && player.mode === 'manual') {
        a = player.throttle * A_MAX - player.brake * B_MAX;
        const gapNow = gapOf(i);
        const closing = c.v - lead.v;
        // 至近距離（s0 未満）で接近中なら「先行車より速くならない」加速度に抑える。
        // 遠くでは介入しない（プレイヤーは自分で詰められる）
        if (gapNow < params.s0 && closing > 0) a = Math.min(a, (lead.v - c.v) / dt);
        if (c.v >= params.v0 * MANUAL_VMAX_RATIO && a > 0) a = 0;
      } else {
        histGet(hist[i], k, sample);
        a = idmAccel(params, c.v, sample.gap, sample.dv);
      }
      a -= GRAVITY * gradeAt(c.s, params.sag);
      if (params.noise > 0) a += params.noise * gaussian(rng);
      if (a < A_MIN_CLAMP) a = A_MIN_CLAMP; else if (a > A_MAX_CLAMP) a = A_MAX_CLAMP;
      c.a = a;
    }

    // 3) 半陰的オイラー: v を先に更新し、新しい v で位置を進める。
    //    位置は更新前の巡回順序で unwrap した座標 u で扱う（u[i+1] >= u[i]、最後尾の先行車は u[0] + LENGTH）。
    //    wrap 後の s のまま gap を測ると、押し戻しで先行車が後続車を逆向きに追い越した場合に forwardDistance が
    //    「ほぼ 1 周」となって違反を見逃すため、ガードは u 上で行い、最後に wrap して s へ戻す。
    let acc = cars[0].s;
    for (let i = 0; i < n; i++) {
      const c = cars[i];
      if (i > 0) acc += forwardDistance(cars[i - 1].s, c.s);
      c.v = Math.max(0, c.v + c.a * dt);
      u[i] = acc + c.v * dt;
    }

    // 4) 衝突ガード（追い越し禁止）。後方から順に、gap < MIN_GAP なら速度を飽和させ位置を先行車の直後へ押し戻す。
    //    後方走査なので押し戻しの連鎖は 1 pass 内で後ろへ伝わるが、cars[0] を押し戻すと最後尾 cars[n-1]
    //    （先に処理済み）の gap が縮む（1 周またぎ）。連鎖が 1 周して戻る最悪ケースでも n+2 pass で収束する
    //    ので、違反が無くなるまで最大 n+2 pass まわす。
    const D = CAR_LENGTH + MIN_GAP; // 先行車との最小中心間距離
    for (let pass = 0; pass < n + 2; pass++) {
      let changed = false;
      for (let i = n - 1; i >= 0; i--) {
        const li = leaderIndex(i);
        const leadU = i === n - 1 ? u[0] + LENGTH : u[li];
        if (u[i] > leadU - D + GAP_EPS) {
          const c = cars[i];
          if (c.v > cars[li].v) c.v = cars[li].v;
          u[i] = leadU - D;
          changed = true;
        }
      }
      if (!changed) break;
    }
    for (let i = 0; i < n; i++) cars[i].s = wrap(u[i]);

    for (let i = 0; i < n; i++) cars[i].braking = cars[i].a < BRAKE_LAMP_A;
    time += dt;
  }

  reset();

  return {
    get params() { return Object.freeze({ ...params }); },
    get time() { return time; },
    get cars() { return cars; },
    get playerIndex() { return params.playerIndex; },
    get player() { return cars[params.playerIndex]; },
    get playerControl() { return { ...player }; },
    /** 現在の台数・パラメータでの均等配置の定常速度 [m/s] */
    get equilibriumSpeed() { return vEq; },
    get carCount() { return N(); },
    leaderIndex,
    gapOf,
    reset,
    setParams,
    setPlayerControl,
    pulseBrake,
    triggerLeaderBrake,
    step,
  };
}
