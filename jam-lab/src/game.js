// src/game.js — ゲームの状態機械と採点。
//   title → briefing → playing → result（→ 次のレベル / もう一度 / タイトル）
// sim / metrics / levels（純粋 JS）と hud / charts / scene（DOM・three.js）を結線する。
// 実時間ループは main.js が持ち、ここは「1 サブステップ進める」「HUD を更新する」を提供する。

import { createSim } from './sim/model.js';
import { createMetrics } from './sim/metrics.js';
import { PLAY_LEVELS as LEVELS, FREE_LEVEL, evaluate } from './sim/levels.js';
import { CAR_LENGTH, forwardDistance } from './shared/track.js';

/** sim のサブステップ幅 [s]（DESIGN.md 推奨値） */
export const STEP = 0.05;
/** 「ブレーキを踏む」ボタン / B キーの既定パルス */
const PULSE = { decel: 2.0, duration: 2.0 };
const CAMERA_CYCLE = ['chase', 'overhead', 'overview', 'cockpit'];
/** キー押し続けでアクセル / ブレーキが最大になるまでの秒数（タップ = 弱く、長押し = 強く） */
const RAMP_SEC = 0.6;
const STORAGE_KEY = 'jamlab.progress.v1';
/** サグ部の上り区間 [m]（shared/track.js の定義と一致させる） */
const SAG_UP_FROM = 400, SAG_UP_TO = 650;
/** 途中終了時に観察完了とみなす、イベント後の最低観察時間 [s] */
const OBSERVED_SEC = 30;

const fmt0 = (x) => (Number.isFinite(x) ? Math.round(x).toString() : '—');
const fmt1 = (x) => (Number.isFinite(x) ? x.toFixed(1) : '—');
const fmtSigned1 = (x) => (Number.isFinite(x) ? (x > 0 ? '+' : '') + x.toFixed(1) : '—');

function loadProgress() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    const obj = raw ? JSON.parse(raw) : {};
    return obj && typeof obj === 'object' ? obj : {};
  } catch { return {}; }
}
function saveProgress(progress) {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(progress)); } catch { /* プライベートモード等は無視 */ }
}

export function createGame({ hud, charts, scene }) {
  // ---- 状態 ----
  const g = {
    phase: 'title',        // 'title' | 'briefing' | 'playing' | 'result'
    level: null,
    sim: null,
    metrics: null,
    cfg: null,             // 現在の sim に渡した設定（sag / carCount の参照用）
    overrides: {},         // スライダーで上書きした simConfig（やり直し時に維持）
    mode: 'auto',          // プレイヤー車の操作モード
    speed: 1,
    paused: false,
    cameraMode: 'chase',
    timeOfDay: 'morning',
  };
  let script = [];         // [{ at, action, args, fired }]
  let ctx = null;          // 採点コンテキスト（evaluate に渡す）
  let finalSummary = null;
  let freeAuto = false;    // フリーラボの自動運転トグル
  let booted = false;      // boot() の再呼び出しガード（リスナー多重登録防止）
  const progress = loadProgress();
  const allLevels = [...LEVELS, FREE_LEVEL];
  const findLevel = (id) => allLevels.find((l) => l.id === id) || LEVELS[0];

  // ---- プレイヤー入力 ----
  const input = { keyThrottle: false, keyBrake: false, touchThrottle: false, touchBrake: false, throttle: 0, brake: 0 };
  const lastControl = { mode: null, throttle: -1, brake: -1 };

  function sendControl(mode, throttle, brake) {
    if (lastControl.mode === mode && lastControl.throttle === throttle && lastControl.brake === brake) return;
    lastControl.mode = mode; lastControl.throttle = throttle; lastControl.brake = brake;
    g.sim.setPlayerControl({ mode, throttle, brake });
  }

  /** 押している間なだらかに強くなる（タップ = 軽いブレーキ、長押し = 強いブレーキ） */
  function updatePlayerControl(dt) {
    if (g.mode !== 'manual') return;
    const wantT = input.keyThrottle || input.touchThrottle;
    const wantB = input.keyBrake || input.touchBrake;
    input.throttle = wantT ? Math.min(1, input.throttle + dt / RAMP_SEC) : 0;
    input.brake = wantB ? Math.min(1, input.brake + dt / RAMP_SEC) : 0;
    sendControl('manual', input.throttle, input.brake);
  }

  function releaseInputs() {
    input.keyThrottle = input.keyBrake = input.touchThrottle = input.touchBrake = false;
    input.throttle = input.brake = 0;
  }

  function applyMode(mode) {
    g.mode = mode;
    releaseInputs();
    lastControl.mode = null;
    if (g.sim) sendControl(mode, 0, 0);
    hud.setMode(mode);
  }

  // ---- sim / scene の構築 ----
  function buildSim(level, overrides = {}) {
    const cfg = { ...level.simConfig, ...overrides };
    g.cfg = cfg;
    g.sim = createSim(cfg);
    g.metrics = createMetrics(g.sim, { freeFlowSpeed: g.sim.params.v0 });
    scene.setSag(!!cfg.sag);
    scene.setCarCount(g.sim.cars.length);
    lastControl.mode = null;
    return cfg;
  }

  function markEvent(opts) {
    if (!ctx || ctx.eventTime != null) return;
    ctx.eventTime = g.sim.time;
    g.metrics.markEvent(opts);
  }

  // ---- レベル 03（density）の実験記録 ----
  // 密度スライダーで再スタートすると sim / ctx は作り直されるので、「試した密度」と「各走行の結果」は
  // ここに持ち越す。ブリーフィングを開く / タイトルへ戻るまで（= そのレベルの 1 セッション）保持し、
  // ctx.densitiesTried / ctx.densityRuns として levels.evaluate に渡す。
  const densityLog = { densitiesTried: [], densityRuns: [] };
  function resetDensityLog() {
    densityLog.densitiesTried = [];
    densityLog.densityRuns = [];
  }
  /** 現在の走行結果を記録（スライダー再スタート / やり直し / 完了時）。density レベルの走行中だけ */
  function recordDensityRun() {
    if (!g.level || g.level.id !== 'density' || !g.sim || !g.metrics) return;
    const s = g.metrics.summary();
    densityLog.densityRuns.push({
      carCount: g.sim.carCount,
      sec: g.sim.time,
      stoppedCount: s.stoppedCount,
      totalTimeLoss: s.totalTimeLoss,
      density: s.density,
    });
  }

  function sliderSpec(level, cfg) {
    const values = { carCount: cfg.carCount, T: cfg.T, tau: cfg.tau, v0: cfg.v0 * 3.6, noise: cfg.noise ?? 0 };
    if (level === FREE_LEVEL) {
      return { visible: ['carCount', 'T', 'tau', 'v0', 'noise'], toggles: ['sag', 'auto'], values, toggleValues: { sag: !!cfg.sag, auto: freeAuto }, ranges: { carCount: { min: 20, max: 100 } } };
    }
    if (level.id === 'density') {
      return { visible: ['carCount', 'T', 'tau'], toggles: [], values, ranges: { carCount: { min: 40, max: 90 } } };
    }
    return { visible: ['T', 'tau'], toggles: [], values, ranges: {} };
  }

  // ---- フェーズ遷移 ----
  function showTitle() {
    g.phase = 'title';
    g.level = null;
    g.paused = false;
    ctx = null;
    resetDensityLog();
    releaseInputs();
    buildSim(LEVELS[0]);           // タイトル背景用に車列を流しておく（アトラクト）
    applyMode('auto');
    hud.setActiveLevel(null);
    hud.setHudVisible(false);
    hud.showTitle(LEVELS, progress);
  }

  function openBriefing(level) {
    g.level = level;
    g.overrides = {};
    g.phase = 'briefing';
    g.paused = false;
    ctx = null;
    resetDensityLog();
    releaseInputs();
    buildSim(level);               // ブリーフィング中も背景で車列を流す
    applyMode('auto');
    hud.setActiveLevel(level.id);
    hud.setPaused(false);
    hud.setHudVisible(true, true);
    const meta = Number.isFinite(level.durationSec)
      ? `${level.simConfig.carCount} 台の車列 ・ 制限時間 ${level.durationSec} 秒 ・ ${level.playerMode === 'manual' ? '自分で運転' : '自動運転（ボタンでブレーキ）'}`
      : `${level.simConfig.carCount} 台の車列 ・ 時間無制限`;
    hud.showBriefing(level, meta);
  }

  function startLevel(level, overrides = {}) {
    // 走行中の再スタート（密度スライダー / やり直し）なら、置き換える前の走行を記録しておく
    if (g.phase === 'playing' && g.level === level) recordDensityRun();
    g.level = level;
    g.overrides = overrides;
    const cfg = buildSim(level, overrides);
    if (level.id === 'density' && !densityLog.densitiesTried.includes(cfg.carCount)) densityLog.densitiesTried.push(cfg.carCount);
    g.phase = 'playing';
    g.paused = false;
    g.speed = 1;
    finalSummary = null;
    script = (level.script || []).map((e) => ({ ...e, fired: false }));
    ctx = {
      completed: false,
      quizCorrect: null,
      playerSagMinSpeedRatio: 1,
      playerPulses: 0,
      pulseDuration: PULSE.duration,
      leaderAhead: null,
      eventTime: null,
      carCount: cfg.carCount,
      tau: cfg.tau,
      densitiesTried: densityLog.densitiesTried, // 03: このレベルで試した台数（初期値を含む・重複なし）
      densityRuns: densityLog.densityRuns,       // 03: 再スタート前の各走行 { carCount, sec, stoppedCount, totalTimeLoss, density }
    };
    // 強制イベント（ブレーキパルス / 先行車ブレーキ）を持たないレベルは開始時点から計測。
    // 01 はプレイヤーが B を押した瞬間、02/04 は台本の先行車ブレーキ時刻を「イベント」とする。
    const hasForcedEvent = script.some((e) => e.action === 'pulseBrake' || e.action === 'leaderBrake');
    if (!hasForcedEvent && level.id !== 'brake-once') markEvent();

    const mode = level === FREE_LEVEL ? (freeAuto ? 'auto' : 'manual') : level.playerMode;
    applyMode(mode);
    hud.hideModals();
    hud.setHudVisible(true, false);
    hud.setActiveLevel(level.id);
    hud.setExperiment(level, { free: level === FREE_LEVEL, mode });
    hud.setSliders(sliderSpec(level, cfg));
    hud.setPaused(false);
    hud.setSpeed(1);
    hud.setTimer(0, level.durationSec);
    hud.toggleSheet(false);
    refreshHud();
  }

  /** 途中終了でも「観察完了」とみなす条件: イベント後 OBSERVED_SEC 秒以上経過 */
  function isObservationComplete() {
    return !!(ctx && ctx.eventTime != null && g.sim && g.sim.time - ctx.eventTime >= OBSERVED_SEC);
  }

  function finish(completed) {
    if (g.phase !== 'playing' || g.level === FREE_LEVEL) return;
    g.phase = 'result';
    g.paused = false;
    ctx.completed = completed;
    finalSummary = g.metrics.summary();
    recordDensityRun(); // 03: 完了した走行も記録（リザルトから「もう一度」で持ち越す）
    releaseInputs();
    if (g.level.quiz) {
      hud.showQuiz(g.level, g.level.quiz, (correct) => { ctx.quizCorrect = correct; showFinal(); });
    } else {
      showFinal();
    }
  }

  function showFinal() {
    const level = g.level;
    const s = finalSummary;
    let res;
    try { res = evaluate(level, s, ctx) || {}; } catch { res = {}; }
    const stars = Math.max(0, Math.min(3, res.stars | 0));
    const lines = Array.isArray(res.lines) ? res.lines : [];
    if (progress[level.id] == null || stars > progress[level.id]) { progress[level.id] = stars; saveProgress(progress); }
    hud.setLevelStars(level.id, progress[level.id]);
    const idx = LEVELS.indexOf(level);
    const next = idx >= 0 && idx < LEVELS.length - 1 ? LEVELS[idx + 1] : FREE_LEVEL;
    g.nextLevel = next;
    hud.showResult({
      level, stars, lines,
      headline: buildHeadline(level, s, ctx),
      numbers: buildNumbers(level, s, ctx),
      lesson: level.lesson,
      completed: ctx.completed,
      nextLabel: next === FREE_LEVEL ? 'フリーラボへ' : `次の実験 ${next.no} へ`,
    });
  }

  // ---- リザルト文（プレイヤーの操作と数字を結びつける） ----
  function buildHeadline(level, s, c) {
    const n = s.affectedCount ?? 0;
    const loss = Math.round(s.totalTimeLoss ?? 0);
    const stopped = s.stoppedCount ?? 0;
    const w = s.waveSpeed;
    const waveTxt = w == null || !Number.isFinite(w)
      ? '渋滞波の速度は測れませんでした（減速した車が少なすぎるため）'
      : `波は ${fmtSigned1(w)} km/h で${w < 0 ? '後方' : '前方'}へ進みました`;
    switch (level.id) {
      case 'brake-once':
        if (!c.playerPulses) return 'ブレーキを一度も踏まなかったので、車列は静かに流れ続けました。次は B キーで踏んで、後ろに何が起きるか見てみましょう。';
        return `あなたの ${c.pulseDuration} 秒のブレーキ（${c.playerPulses} 回）で、後ろの ${n} 台が減速し、合計 ${loss} 秒が失われました。${waveTxt}。`;
      case 'absorb-wave': {
        const ahead = c.leaderAhead ?? 3;
        const gt = s.playerMinGapTime;
        return `前方 ${ahead} 台目の急ブレーキに対して、あなたの後ろでは ${n} 台が減速し、${stopped} 台が止まりました。失われた時間は合計 ${loss} 秒。あなたの車間時間は最小 ${fmt1(gt)} 秒でした。`;
      }
      case 'density':
        return `${fmt0(s.density ?? c.carCount)} 台/km の車列は平均 ${fmt0((s.meanSpeed ?? 0) * 3.6)} km/h、${fmt0(s.flow)} 台/時で流れました。` +
          (stopped ? `${stopped} 台が一度は止まり、` : '') + `合計 ${loss} 秒が失われました。` +
          (w != null && w < 0 ? `${waveTxt}。` : '');
      case 'reaction':
        return `反応の遅れ ${fmt1(c.tau)} 秒の車列で、前方の急ブレーキは後ろの ${n} 台に広がり、${stopped} 台が止まりました。失われた時間は合計 ${loss} 秒。${waveTxt}。`;
      case 'sag': {
        const pct = Math.round((c.playerSagMinSpeedRatio ?? 1) * 100);
        return `サグ部（上り坂）でのあなたの最低速度は希望速度の ${pct}% でした。後ろの ${n} 台が減速し、${stopped} 台が止まり、合計 ${loss} 秒が失われました。`;
      }
      default:
        return `後ろの ${n} 台が減速し、合計 ${loss} 秒が失われました。${waveTxt}。`;
    }
  }

  function buildNumbers(level, s, c) {
    const out = [
      { label: '影響を受けた後続車', value: fmt0(s.affectedCount), unit: '台' },
      { label: '後続車の総時間損失', value: fmt0(s.totalTimeLoss), unit: '秒' },
      { label: '渋滞波の速度', value: s.waveSpeed == null ? '—' : fmtSigned1(s.waveSpeed), unit: 'km/h' },
      { label: '停止した車', value: fmt0(s.stoppedCount), unit: '台' },
    ];
    if (level.id === 'absorb-wave' || level.id === 'reaction') out.push({ label: 'あなたの最小車間時間', value: fmt1(s.playerMinGapTime), unit: '秒' });
    if (level.id === 'density') {
      out.push({ label: '車列の平均速度', value: fmt0((s.meanSpeed ?? 0) * 3.6), unit: 'km/h' });
      out.push({ label: '交通流率', value: fmt0(s.flow), unit: '台/時' });
    }
    if (level.id === 'sag') out.push({ label: 'サグ部での最低速度比', value: fmt0((c.playerSagMinSpeedRatio ?? 1) * 100), unit: '%' });
    if (level.playerMode === 'manual') out.push({ label: 'あなたの強いブレーキ', value: fmt0(s.playerBrakeEvents), unit: '回' });
    return out;
  }

  // ---- 台本イベント ----
  function fireScript() {
    const sim = g.sim;
    for (const e of script) {
      if (e.fired || sim.time < e.at) continue;
      e.fired = true;
      if (e.action === 'pulseBrake') {
        const args = e.args || PULSE;
        sim.pulseBrake(args);
        ctx.playerPulses++;
        ctx.pulseDuration = args.duration ?? PULSE.duration;
        markEvent();
        hud.flashPulse();
      } else if (e.action === 'leaderBrake') {
        const args = e.args || { aheadIndex: 3, decel: 3.0, duration: 2.5 };
        const braked = sim.triggerLeaderBrake(args);
        ctx.leaderAhead = args.aheadIndex ?? 3;
        markEvent(Number.isInteger(braked) ? { s: sim.cars[braked].s } : undefined);
        hud.toast(`前方 ${ctx.leaderAhead} 台目が急ブレーキ！ 車間を使って、後ろの車を止めずに受け流そう。`);
      } else if (e.action === 'hint') {
        const a = e.args;
        hud.toast(typeof a === 'string' ? a : (a && (a.text || a.message)) || '');
      }
    }
  }

  /** 採点用コンテキストの逐次更新（サグ通過時のプレイヤー速度比の最小値） */
  function trackCtx() {
    if (!g.cfg.sag) return;
    const sim = g.sim;
    const p = sim.cars[sim.playerIndex];
    if (p.s >= SAG_UP_FROM && p.s < SAG_UP_TO) {
      const r = p.v / sim.params.v0;
      if (r < ctx.playerSagMinSpeedRatio) ctx.playerSagMinSpeedRatio = r;
    }
  }

  // ---- 操作 ----
  function pulse() {
    if (g.phase !== 'playing' || g.paused) return;
    if (g.mode !== 'auto' && g.level !== FREE_LEVEL) return;
    g.sim.pulseBrake(PULSE);
    ctx.playerPulses++;
    markEvent();
    hud.flashPulse();
  }
  function togglePause() {
    if (g.phase !== 'playing') return;
    g.paused = !g.paused;
    if (g.paused) releaseInputs();
    hud.setPaused(g.paused);
  }
  function setSpeed(m) {
    if (![1, 2, 4].includes(m)) return;
    g.speed = m;
    hud.setSpeed(m);
  }
  function cycleCamera() {
    const i = CAMERA_CYCLE.indexOf(g.cameraMode);
    g.cameraMode = CAMERA_CYCLE[(i + 1) % CAMERA_CYCLE.length];
    scene.setCameraMode(g.cameraMode);
    hud.setCar(carInfo());
  }
  function toggleTimeOfDay() {
    g.timeOfDay = g.timeOfDay === 'morning' ? 'dusk' : 'morning';
    scene.setTimeOfDay(g.timeOfDay);
    hud.setCar(carInfo());
  }
  function onSlider(param, value) {
    if (g.phase !== 'playing' || !g.sim) return;
    if (param === 'carCount') { startLevel(g.level, { ...g.overrides, carCount: Math.round(value) }); return; }
    const simValue = param === 'v0' ? value / 3.6 : value;
    g.overrides = { ...g.overrides, [param]: simValue };
    g.sim.setParams({ [param]: simValue });
  }
  function onToggle(name, checked) {
    if (g.phase !== 'playing' || g.level !== FREE_LEVEL) return;
    if (name === 'sag') startLevel(g.level, { ...g.overrides, sag: checked });
    if (name === 'auto') {
      freeAuto = checked;
      applyMode(checked ? 'auto' : 'manual');
      hud.setExperiment(g.level, { free: true, mode: g.mode });
    }
  }

  function firstLevelToPlay() {
    return LEVELS.find((l) => progress[l.id] == null) || LEVELS[0];
  }

  // ---- キーボード ----
  function onKeyDown(e) {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    if (hud.isModalOpen()) {
      if (e.key === 'Enter') { if (hud.pressPrimary()) e.preventDefault(); }
      return;
    }
    switch (e.code) {
      case 'ArrowUp': case 'KeyW': input.keyThrottle = true; e.preventDefault(); break;
      case 'ArrowDown': case 'KeyS': input.keyBrake = true; e.preventDefault(); break;
      case 'KeyB': if (!e.repeat) pulse(); break;
      case 'KeyC': if (!e.repeat) cycleCamera(); break;
      case 'Space': if (!e.repeat) togglePause(); e.preventDefault(); break;
      case 'Digit1': setSpeed(1); break;
      case 'Digit2': setSpeed(2); break;
      case 'Digit3': setSpeed(4); break;
      default: break;
    }
  }
  function onKeyUp(e) {
    switch (e.code) {
      case 'ArrowUp': case 'KeyW': input.keyThrottle = false; break;
      case 'ArrowDown': case 'KeyS': input.keyBrake = false; break;
      default: break;
    }
  }

  // ---- HUD 更新（main が ~10 Hz で呼ぶ） ----
  function carInfo() {
    const sim = g.sim;
    const cars = sim.cars;
    const i = sim.playerIndex;
    const p = cars[i];
    const l = cars[(i + 1) % cars.length];
    const gap = cars.length > 1 ? Math.max(0, forwardDistance(p.s, l.s) - CAR_LENGTH) : null;
    return {
      speedKmh: p.v * 3.6,
      gap,
      gapTime: gap != null && p.v > 0.5 ? gap / p.v : null,
      braking: !!p.braking,
      cameraMode: g.cameraMode,
      timeOfDay: g.timeOfDay,
    };
  }

  function refreshHud() {
    const sim = g.sim;
    if (!sim) return;
    const playing = g.phase === 'playing' || g.phase === 'result';
    hud.setCar(carInfo());
    if (playing) {
      hud.setInfluence(g.metrics.summary());
      hud.setTimer(sim.time, g.level.durationSec);
      charts.draw({ sim, metrics: g.metrics, v0: sim.params.v0, eventTime: ctx ? ctx.eventTime : null, sag: !!g.cfg.sag });
    } else {
      charts.draw({ sim, metrics: null, v0: sim.params.v0, eventTime: null, sag: !!g.cfg.sag });
    }
  }

  // ---- 1 サブステップ（main が STEP 秒ごとに呼ぶ） ----
  function step(dt) {
    const sim = g.sim;
    if (!sim) return;
    if (g.phase === 'playing') {
      updatePlayerControl(dt);
      sim.step(dt);
      g.metrics.update(sim);
      fireScript();
      trackCtx();
      if (sim.time >= g.level.durationSec) finish(true);
    } else {
      sim.step(dt); // タイトル / ブリーフィングの背景（アトラクト）
    }
  }

  function isSimRunning() {
    return !!g.sim && !g.paused && (g.phase === 'playing' || g.phase === 'title' || g.phase === 'briefing');
  }

  // ---- 起動 ----
  function boot() {
    if (booted) return; // 2 回目以降は no-op（HUD / window リスナーの多重登録を防ぐ）
    booted = true;
    hud.setLevels(allLevels, progress);
    hud.on('selectLevel', (id) => openBriefing(findLevel(id)));
    hud.on('titleStart', () => openBriefing(firstLevelToPlay()));
    hud.on('titleFree', () => openBriefing(FREE_LEVEL));
    hud.on('briefStart', () => startLevel(g.level, {}));
    hud.on('briefBack', showTitle);
    hud.on('pulse', pulse);
    hud.on('restart', () => { if (g.level) startLevel(g.level, g.overrides); });
    // 「結果を見る」で途中終了: イベント（ブレーキ / 先行車ブレーキ / 計測開始）から
    // OBSERVED_SEC 以上たっていれば観察完了として採点する（時間切れを待たせない）
    hud.on('finish', () => finish(isObservationComplete()));
    hud.on('camera', cycleCamera);
    hud.on('tod', toggleTimeOfDay);
    hud.on('pause', togglePause);
    hud.on('speed', setSpeed);
    hud.on('slider', onSlider);
    hud.on('toggle', onToggle);
    hud.on('sheet', () => hud.toggleSheet());
    hud.on('hold', (which, down) => {
      if (which === 'throttle') input.touchThrottle = down;
      if (which === 'brake') input.touchBrake = down;
    });
    hud.on('resultRetry', () => startLevel(g.level, g.overrides));
    hud.on('resultNext', () => openBriefing(g.nextLevel || FREE_LEVEL));
    hud.on('resultTitle', showTitle);
    window.addEventListener('keydown', onKeyDown);
    window.addEventListener('keyup', onKeyUp);
    window.addEventListener('blur', releaseInputs);
    scene.setCameraMode(g.cameraMode);
    scene.setTimeOfDay(g.timeOfDay);
    showTitle();
  }

  return {
    boot, step, refreshHud, isSimRunning,
    get sim() { return g.sim; },
    get speed() { return g.speed; },
    get cameraMode() { return g.cameraMode; },
    get phase() { return g.phase; },
    get level() { return g.level; },
  };
}
