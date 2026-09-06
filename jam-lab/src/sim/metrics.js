// 計測 — 影響台数・総時間損失・停止台数・渋滞波速度・時系列/時空間バッファ・基本図の値。
// game が markEvent() でイベント開始を打刻し、毎 sim.step 後に update(sim) を呼ぶ。
// markEvent 前は累積値を積まない（eventTime は null）。
// 基準速度 ref は「この車列が均等配置で出せる定常速度」min(freeFlowSpeed, sim.equilibriumSpeed)。
// 高密度では v0 で走れないので v0 を基準にすると全車が常に「影響あり」になってしまうため。
// ref は update() ごとに再計算する（安価）。走行中に T / v0 / s0 をスライダーで変えると sim.equilibriumSpeed
// が変わるので、totalTimeLoss / affectedCount / 時空間図はその時点の条件で評価される。refSpeed で参照可。
import { LENGTH, CAR_LENGTH, forwardDistance } from '../shared/track.js';

const AFFECTED_RATIO = 0.7;   // 影響を受けた: v < ref×0.7
const WAVE_RATIO = 0.7;       // 渋滞波の到達: 初めて v < ref×0.7（「影響」と同じ閾値。弱いパルスでも波面を捕まえる）
const STOPPED_V = 1.0;        // 停止扱い [m/s]
const BRAKE_EVENT_A = -1.5;   // プレイヤーの「ブレーキ回数」しきい値
const HISTORY_DT = 1.0;
const HISTORY_MAX = 600;
const SPACETIME_DT = 0.5;
const SPACETIME_MAX = 240;
const WAVE_MIN_SAMPLES = 4;
/** 直前の波標本よりこの距離 [m] 以上「手前」に戻る到達標本は別の波 / ノイズ起因とみなして捨てる */
const WAVE_BACKJUMP_M = 50;
/** サグの上り区間 [m]（shared/track.js の勾配定義と同じ 400〜650） */
const SAG_CLIMB = [400, 650];

export function createMetrics(sim, { freeFlowSpeed } = {}) {
  let ref = 1;
  let eventTime = null;
  let eventPos = 0;
  let lastTime = 0;
  let affected = new Set();
  let stopped = new Set();
  let waveSeen = new Set();
  let waveT = [];
  let waveD = [];
  let totalTimeLoss = 0;
  let playerMinGapTime = Infinity;
  let playerBrakeEvents = 0;
  let playerWasBraking = false;
  let playerSagMinRatio = Infinity; // サグ上り区間でのプレイヤー速度 / ref の最小値
  let nextHistoryT = 0;
  let nextSpaceTimeT = 0;
  const history = { t: [], meanSpeed: [] };
  const spaceTime = { times: [], rows: [] };

  /** 基準速度 = min(freeFlowSpeed（省略時 v0）, 現在の定常速度)。update ごとに呼ぶ */
  function computeRef(s = sim) {
    const v0 = s.params.v0;
    const want = Number.isFinite(freeFlowSpeed) && freeFlowSpeed > 0 ? freeFlowSpeed : v0;
    const eq = s.equilibriumSpeed > 0 ? s.equilibriumSpeed : v0;
    ref = Math.max(0.1, Math.min(want, eq));
  }

  function reset() {
    computeRef();
    eventTime = null;
    eventPos = 0;
    lastTime = sim.time;
    affected = new Set();
    stopped = new Set();
    waveSeen = new Set();
    waveT = [];
    waveD = [];
    totalTimeLoss = 0;
    playerMinGapTime = Infinity;
    playerBrakeEvents = 0;
    playerWasBraking = false;
    playerSagMinRatio = Infinity;
    nextHistoryT = sim.time;
    nextSpaceTimeT = sim.time;
    history.t.length = 0;
    history.meanSpeed.length = 0;
    spaceTime.times.length = 0;
    spaceTime.rows.length = 0;
    recordBuffers(sim.cars, sim.time); // t=0 の初期標本（以降は 1 s / 0.5 s の格子で追加）
  }

  /** イベント開始を打刻。位置は省略時プレイヤー位置（leaderBrake 時は { s } で先行車位置を渡せる） */
  function markEvent({ s } = {}) {
    eventTime = sim.time;
    eventPos = Number.isFinite(s) ? s : sim.cars[sim.playerIndex].s;
  }

  function meanSpeedOf(cars) {
    let sum = 0;
    for (const c of cars) sum += c.v;
    return cars.length ? sum / cars.length : 0;
  }

  function update(s = sim) {
    computeRef(s); // 走行中のパラメータ変更（T / v0 / s0）に基準速度を追従させる
    const cars = s.cars;
    const t = s.time;
    const dt = Math.max(0, t - lastTime);
    lastTime = t;
    const pi = s.playerIndex;
    const player = cars[pi];

    // プレイヤー安全指標（イベント前後を問わず常時）
    const pGap = s.gapOf(pi);
    if (player.v > 0.1) playerMinGapTime = Math.min(playerMinGapTime, pGap / player.v);
    const brakingNow = player.a < BRAKE_EVENT_A;
    if (brakingNow && !playerWasBraking) playerBrakeEvents++;
    playerWasBraking = brakingNow;
    if (s.params.sag && player.s >= SAG_CLIMB[0] && player.s < SAG_CLIMB[1]) {
      playerSagMinRatio = Math.min(playerSagMinRatio, player.v / ref);
    }

    // イベント後の累積
    if (eventTime !== null && dt > 0) {
      const arrivals = []; // この update で初めて波の閾値を跨いだ車のイベント地点からの後退距離（wrap 前）
      for (let i = 0; i < cars.length; i++) {
        const c = cars[i];
        if (i === pi) continue;
        const r = c.v / ref;
        if (r < 1) totalTimeLoss += (1 - r) * dt;
        if (r < AFFECTED_RATIO) affected.add(c.id);
        if (c.v < STOPPED_V) stopped.add(c.id);
        if (r < WAVE_RATIO && !waveSeen.has(c.id)) {
          waveSeen.add(c.id);
          arrivals.push(forwardDistance(c.s, eventPos));
        }
      }
      if (arrivals.length) pushWaveSamples(arrivals, t - eventTime);
    }

    recordBuffers(cars, t);
  }

  /**
   * 波の到達標本を追加する。raws は同一 update 内で閾値を跨いだ車の後退距離 forwardDistance(car.s, eventPos)
   * ∈ [0, LENGTH)。車は待つ間に前進するので、直後の車はイベント地点を少し通り過ぎてから減速する（d が僅かに負）。
   * 波は後方へ単調に進むため、直前の標本 prev に最も近くなるよう LENGTH の整数倍で unwrap し（1 周しても
   * 単調増加を保つ）、同時刻の複数標本は配列順ではなく後退距離の昇順で積む。直前の標本より WAVE_BACKJUMP_M
   * 以上手前へ戻る標本は（別の波やノイズ起因の減速なので）回帰に入れず捨てる。
   */
  function pushWaveSamples(raws, tRel) {
    const prev = waveD.length ? waveD[waveD.length - 1] : 0;
    const ds = raws.map((raw) => {
      let d = raw + Math.round((prev - raw) / LENGTH) * LENGTH;
      if (d - prev > LENGTH / 2) d -= LENGTH;
      else if (prev - d > LENGTH / 2) d += LENGTH;
      return d;
    }).sort((x, y) => x - y);
    for (const d of ds) {
      if (waveD.length && waveD[waveD.length - 1] - d >= WAVE_BACKJUMP_M) continue; // 50 m 以上の逆行は破棄
      waveT.push(tRel);
      waveD.push(d);
    }
  }

  /** 1 s 間引きの平均速度履歴と 0.5 s ごとの時空間行（v/ref を 0..1 に丸める） */
  function recordBuffers(cars, t) {
    if (t + 1e-9 >= nextHistoryT) {
      history.t.push(t);
      history.meanSpeed.push(meanSpeedOf(cars));
      if (history.t.length > HISTORY_MAX) { history.t.shift(); history.meanSpeed.shift(); }
      nextHistoryT += HISTORY_DT;
    }
    if (t + 1e-9 >= nextSpaceTimeT) {
      const row = new Float32Array(cars.length);
      for (let i = 0; i < cars.length; i++) row[i] = Math.min(1, Math.max(0, cars[i].v / ref));
      spaceTime.times.push(t);
      spaceTime.rows.push(row);
      if (spaceTime.rows.length > SPACETIME_MAX) { spaceTime.times.shift(); spaceTime.rows.shift(); }
      nextSpaceTimeT += SPACETIME_DT;
    }
  }

  /** 渋滞波速度 [km/h]。後退距離 d を t で回帰した傾き（後方へ進むので負で返す）。標本不足なら null */
  function waveSpeed() {
    const n = waveT.length;
    if (n < WAVE_MIN_SAMPLES) return null;
    let mt = 0;
    let md = 0;
    for (let i = 0; i < n; i++) { mt += waveT[i]; md += waveD[i]; }
    mt /= n; md /= n;
    let sxy = 0;
    let sxx = 0;
    for (let i = 0; i < n; i++) { sxy += (waveT[i] - mt) * (waveD[i] - md); sxx += (waveT[i] - mt) ** 2; }
    if (sxx < 1e-6) return null; // 全標本がほぼ同時刻 → 回帰不能
    return -(sxy / sxx) * 3.6;
  }

  function summary() {
    const cars = sim.cars;
    const density = cars.length / (LENGTH / 1000); // 台/km
    const meanSpeed = meanSpeedOf(cars);
    return {
      affectedCount: affected.size,
      totalTimeLoss,
      stoppedCount: stopped.size,
      waveSpeed: waveSpeed(),
      meanSpeed,
      flow: density * meanSpeed * 3.6,
      density,
      playerMinGapTime: Number.isFinite(playerMinGapTime) ? playerMinGapTime : null,
      playerBrakeEvents,
      // サグ上り（400〜650 m）でのプレイヤー最低速度比。サグ無効 / 未通過なら null。レベル 05 の星判定に使う
      playerSagMinSpeedRatio: Number.isFinite(playerSagMinRatio) ? playerSagMinRatio : null,
      eventTime,
      refSpeed: ref,
    };
  }

  reset();

  return {
    markEvent,
    update,
    summary,
    reset,
    history,
    spaceTime,
    get eventTime() { return eventTime; },
    get refSpeed() { return ref; },
    /** 回帰に使った (t, d) 標本（デバッグ / 図示用） */
    get waveSamples() { return waveT.map((t, i) => ({ t, d: waveD[i] })); },
  };
}

export { CAR_LENGTH };
