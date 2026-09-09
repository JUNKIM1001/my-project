// src/game.js — ゲームの状態機械と採点。
//   title → briefing → playing → result（→ 次のレベル / もう一度 / タイトル）
// sim / metrics / levels（純粋 JS）と hud / charts / scene（DOM・three.js）を結線する。
// 実時間ループは main.js が持ち、ここは「1 サブステップ進める」「HUD を更新する」を提供する。

import { createSim } from './sim/model.js';
import { createMetrics } from './sim/metrics.js';
import { PLAY_LEVELS as LEVELS, FREE_LEVEL, evaluate, scoreOf } from './sim/levels.js';
import { createSound } from './ui/sound.js';
import { CAR_LENGTH, forwardDistance } from './shared/track.js';

/** sim のサブステップ幅 [s]（DESIGN.md 推奨値） */
export const STEP = 0.05;
/** 「ブレーキを踏む」ボタン / B キーの既定パルス */
const PULSE = { decel: 2.0, duration: 2.0 };
const CAMERA_CYCLE = ['chase', 'overhead', 'overview', 'cockpit'];
/** 1 回のブレーキの結果を見るための観察時間 [シム秒]。この間は次のブレーキを受け付けない */
const OBSERVE_SEC = 20;
const STORAGE_KEY = 'jamlab.progress.v1';
/** サグ部の上り区間 [m]（shared/track.js の定義と一致させる） */
const SAG_UP_FROM = 400, SAG_UP_TO = 650;
/** 途中終了時に観察完了とみなす、イベント後の最低観察時間 [s] */
const OBSERVED_SEC = 30;

const fmt0 = (x) => (Number.isFinite(x) ? Math.round(x).toString() : '—');
const fmt1 = (x) => (Number.isFinite(x) ? x.toFixed(1) : '—');
const fmtSigned1 = (x) => (Number.isFinite(x) ? (x > 0 ? '+' : '') + x.toFixed(1) : '—');

/** 進捗 { [levelId]: { stars, score } }。旧形式（数値 = 星）はそのまま読めるよう変換する */
function loadProgress() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    const obj = raw ? JSON.parse(raw) : {};
    if (!obj || typeof obj !== 'object') return {};
    // 値を必ず { stars: 0..3 の整数, score: 0..100 の整数 | null } に正規化する（壊れた保存値を持ち越さない）
    // null / 空文字は「未記録」として null のまま残す（+null が 0 になって「0 点」に化けないように）
    const clampInt = (v, lo, hi) => (v == null || v === '' || !Number.isFinite(+v) ? null : Math.max(lo, Math.min(hi, Math.round(+v))));
    const known = new Set(LEVELS.map((l) => l.id));
    for (const k of Object.keys(obj)) {
      const v = obj[k];
      const stars = clampInt(typeof v === 'number' ? v : v && v.stars, 0, 3);
      const score = v && typeof v === 'object' ? clampInt(v.score, 0, 100) : null;
      // 現在のレベル ID に無い記録（旧レベル名）は捨てる
      if (stars == null || !known.has(k)) delete obj[k]; else obj[k] = { stars, score };
    }
    return obj;
  } catch { return {}; }
}
const VIEW_KEY = 'jamlab.viewMode';
const ONBOARD_KEY = 'jamlab.onboarded';
const readLS = (k) => { try { return localStorage.getItem(k); } catch { return null; } };
const writeLS = (k, v) => { try { localStorage.setItem(k, v); } catch { /* 保存できなくても動作は続ける */ } };
function saveProgress(progress) {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(progress)); } catch { /* プライベートモード等は無視 */ }
}

export function createGame({ hud, charts, scene }) {
  // ---- 音・表示モード（CASUAL_POLISH.md） ----
  const sound = createSound();
  let viewMode = readLS(VIEW_KEY) === 'detail' ? 'detail' : 'simple';
  let onboarded = readLS(ONBOARD_KEY) === '1';
  const bestScoreOf = (id) => (progress[id] && Number.isFinite(progress[id].score) ? progress[id].score : null);
  /** プレイ中の暫定スコア（完走したものとして評価する） */
  function liveScore() {
    if (!g.level || g.level === FREE_LEVEL || !g.metrics || !ctx) return null;
    try { return scoreOf(g.level, g.metrics.summary(), { ...ctx, completed: true }); } catch { return null; }
  }
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
  let booted = false;      // boot() の再呼び出しガード（リスナー多重登録防止）
  const progress = loadProgress();
  const allLevels = [...LEVELS, FREE_LEVEL];
  const findLevel = (id) => allLevels.find((l) => l.id === id) || LEVELS[0];

  // ---- プレイヤー入力 ----
  const input = { keyBrake: false, touchBrake: false, brake: 0 };
  const lastControl = { mode: null, throttle: -1, brake: -1 };

  function sendControl(mode, throttle, brake) {
    if (lastControl.mode === mode && lastControl.throttle === throttle && lastControl.brake === brake) return;
    lastControl.mode = mode; lastControl.throttle = throttle; lastControl.brake = brake;
    g.sim.setPlayerControl({ mode, throttle, brake });
  }

  /** 押している間なだらかに強くなる（タップ = 軽いブレーキ、長押し = 強いブレーキ） */
  // 車は常に自動運転（IDM）。試行が「踏んでいる」状態の間だけ一定の減速を重ねる。
  // 強さは固定で、プレイヤーが操作するのは「踏んでいる長さ」だけ（BRAKE_REDESIGN.md）。
  // 観察中は踏んでも効かない（1 回ずつ結果を確かめてもらうため）。
  function updatePlayerControl() {
    input.brake = trial && trial.phase === 'braking' ? 1 : 0;
    sendControl('auto', 0, input.brake);
  }

  function releaseInputs() {
    trial = null;
    sound.brake(false);
    input.keyBrake = input.touchBrake = false;
    input.brake = 0;
    if (g.sim) sendControl('auto', 0, 0);
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
    interp.curS = new Float64Array(0);   // 台数が変わるので作り直す
    captureInterp(false);
    return cfg;
  }

  // ---- 描画補間 ----
  // シムは 0.05 秒の固定ステップで進むが、描画は 60 fps。位置をそのまま描くと 3 フレームに 1 回しか
  // 動かず、カクついて見える。そこで直前 2 つのシム状態の位置を保持し、main が渡す alpha で
  // 線形補間して描く（定番の fixed-timestep + interpolation）。シムの決定性には影響しない。
  const interp = { prevS: new Float64Array(0), curS: new Float64Array(0), alpha: 1, ready: false };
  /** 車列の位置を curS に取り込む。shift = true なら現在値を prevS へ送ってから取り込む */
  function captureInterp(shift) {
    const cars = g.sim?.cars;
    if (!cars) { interp.ready = false; return; }
    if (interp.curS.length !== cars.length) {
      interp.prevS = new Float64Array(cars.length);
      interp.curS = new Float64Array(cars.length);
      for (let i = 0; i < cars.length; i++) { interp.prevS[i] = cars[i].s; interp.curS[i] = cars[i].s; }
      interp.ready = true;
      return;
    }
    if (shift) interp.prevS.set(interp.curS);
    for (let i = 0; i < cars.length; i++) interp.curS[i] = cars[i].s;
    interp.ready = true;
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
  // 試行（ブレーキ 1 回ごとの結果）も同じレベルのセッション内では持ち越す。
  // 03 は密度スライダーで再スタートしながら比べるので、ここで消えると成立しない。
  const attemptLog = { attempts: [] };
  function resetDensityLog() {
    densityLog.densitiesTried = [];
    densityLog.densityRuns = [];
    attemptLog.attempts = [];
  }
  /** 現在の走行結果を記録（スライダー再スタート / やり直し / 完了時）。密度を変えられるレベルだけ */
  function recordDensityRun() {
    if (!g.level || !g.level.densityRange || !g.sim || !g.metrics) return;
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
      return { visible: ['carCount', 'T', 'tau', 'v0', 'noise'], toggles: ['sag'], values, toggleValues: { sag: !!cfg.sag }, ranges: { carCount: { min: 20, max: 100 } } };
    }
    if (level.densityRange) {
      const [min, max] = level.densityRange;
      return { visible: ['carCount', 'T', 'tau'], toggles: [], values, ranges: { carCount: { min, max } } };
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
      ? `${level.simConfig.carCount} 台の車列 ・ 制限時間 ${level.durationSec} 秒 ・ 自動運転（あなたはブレーキだけ）`
      : `${level.simConfig.carCount} 台の車列 ・ 時間無制限`;
    hud.showBriefing(level, meta);
  }

  function startLevel(level, overrides = {}) {
    // 走行中の再スタート（密度スライダー / やり直し）なら、置き換える前の走行を記録しておく
    if (g.phase === 'playing' && g.level === level) recordDensityRun();
    // sim を作り直す前に入力と試行を捨てる。踏みっぱなし / 観察中のまま新しい車列へ持ち越すと、
    // 旧 sim の時刻で観察が完了したり、開始直後からブレーキが入ったりする
    releaseInputs();
    g.level = level;
    g.overrides = overrides;
    const cfg = buildSim(level, overrides);
    if (level.densityRange && !densityLog.densitiesTried.includes(cfg.carCount)) densityLog.densitiesTried.push(cfg.carCount);
    g.phase = 'playing';
    g.paused = false;
    g.speed = 1;
    finalSummary = null;
    script = (level.script || []).map((e) => ({ ...e, fired: false }));
    ctx = {
      completed: false,
      quizCorrect: null,
      playerSagMinSpeedRatio: 1,
      attempts: attemptLog.attempts,   // 1 回のブレーキごとの結果（レベル内で持ち越す）
      brakeCount: attemptLog.attempts.length,
      totalBrakeSec: attemptLog.attempts.reduce((t, a) => t + a.sec, 0),
      longestSec: attemptLog.attempts.reduce((m, a) => Math.max(m, a.sec), 0),
      shortestSec: attemptLog.attempts.reduce((m, a) => Math.min(m, a.sec), Infinity),
      leaderAhead: null,
      eventTime: null,
      carCount: cfg.carCount,
      tau: cfg.tau,
      densitiesTried: densityLog.densitiesTried, // 03: このレベルで試した台数（初期値を含む・重複なし）
      densityRuns: densityLog.densityRuns,       // 03: 再スタート前の各走行 { carCount, sec, stoppedCount, totalTimeLoss, density }
    };
    // レベル全体の累積計測の開始時刻。台本の強制イベントを持つレベルはその時刻を、
    // 持たないレベルは開始時点を「イベント」とする（プレイヤーのブレーキでも markEvent される）。
    const hasForcedEvent = script.some((e) => e.action === 'pulseBrake' || e.action === 'leaderBrake');
    if (!hasForcedEvent) markEvent();

    applyMode('auto');   // 車は常に自動運転。プレイヤーの操作はブレーキだけ
    hud.hideModals();
    sound.play('start');
    hud.setViewMode?.(viewMode);
    if (!onboarded && level !== FREE_LEVEL) hud.showOnboarding?.(); else hud.hideOnboarding?.();
    hud.setHudVisible(true, false);
    hud.setActiveLevel(level.id);
    hud.setExperiment(level, { free: level === FREE_LEVEL, mode: 'auto' });
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
    const score = scoreOf(level, s, ctx);
    const prev = progress[level.id] || { stars: 0, score: null };
    const isNewBest = Number.isFinite(score) && (prev.score == null || score > prev.score);
    progress[level.id] = { stars: Math.max(prev.stars | 0, stars), score: isNewBest ? score : prev.score };
    saveProgress(progress);
    hud.setLevelStars(level.id, progress[level.id].stars);
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
      score, bestScore: progress[level.id].score, isNewBest,
      // 演出の合図（hud が星ポップ / カウントアップの節目で呼ぶ）
      onStar: (i) => sound.play(['star1', 'star2', 'star3'][Math.min(2, i | 0)]),
      onTick: () => sound.play('tick'),
      onDone: () => { if (stars === 3) sound.play('fanfare'); if (isNewBest) sound.play('newBest'); },
    });
  }

  // ---- リザルト文（プレイヤーの操作と数字を結びつける） ----
  /**
   * リザルトの 1 行目。「踏んだ長さ → 起きた渋滞」を主役にする（BRAKE_REDESIGN.md）。
   * 2 回以上試していれば、最短と最長を並べて用量反応を見せる。
   */
  function buildHeadline(level, s, c) {
    const at = c.attempts || [];
    if (at.length === 0) {
      return 'ブレーキを一度も踏まなかったので、車列は静かに流れ続けました。'
        + '次は S / ↓ を押している間だけ踏んで、後ろに何が起きるか見てみましょう。';
    }
    if (at.length === 1) {
      const a = at[0];
      const w = a.waveSpeed;
      const waveTxt = w == null || !Number.isFinite(w)
        ? '減速した車が少なく、渋滞波の速度は測れませんでした'
        : `波は ${fmtSigned1(w)} km/h で${w < 0 ? '後方' : '前方'}へ進みました`;
      return `${fmt1(a.sec)} 秒のブレーキで、後ろの ${a.affected} 台が減速し、`
        + `合計 ${Math.round(a.timeLoss)} 秒が失われました。${waveTxt}。`;
    }
    const sorted = [...at].sort((x, y) => x.sec - y.sec);
    const lo = sorted[0], hi = sorted[sorted.length - 1];
    const secRatio = lo.sec > 0.05 ? hi.sec / lo.sec : null;
    const affRatio = lo.affected > 0 ? hi.affected / lo.affected : null;
    let cmp = '';
    if (secRatio && affRatio && hi.sec - lo.sec > 0.3) {
      cmp = `踏んだ時間が ${fmt1(secRatio)} 倍で、影響は ${fmt1(affRatio)} 倍に広がりました。`;
    }
    // 合計は「試行の合計」を出す。レベル全体の累積（loss）は桁が大きく、
    // 上に並べた 1 回ごとの数字と食い違って見えるため使わない
    const trialLoss = Math.round(at.reduce((t, a) => t + (a.timeLoss || 0), 0));
    return `${fmt1(lo.sec)} 秒 → ${lo.affected} 台、${fmt1(hi.sec)} 秒 → ${hi.affected} 台。${cmp}`
      + `${at.length} 回のブレーキで、後続に合計 ${trialLoss} 秒の遅れが出ました。`;
  }

  /**
   * リザルトの数値タイル。ブレーキを踏んだ回があれば「最後の 1 回」を主役にする。
   * レベル全体の累積は、時間がたつほど波が周回して積み上がり、1 回ごとの数字と桁が
   * 食い違って読みにくいため、副次的な行（buildLines 側）に回す。
   */
  function buildNumbers(level, s, c) {
    const at = (c && c.attempts) || [];
    if (at.length) {
      const a = at[at.length - 1];
      const out = [
        { label: '最後に踏んだ長さ', value: fmt1(a.sec), unit: '秒' },
        { label: 'その 1 回で減速した後続車', value: fmt0(a.affected), unit: '台' },
        { label: 'その 1 回で生まれた遅れ', value: fmt0(a.timeLoss), unit: '秒' },
        { label: 'そのときの渋滞波', value: a.waveSpeed == null ? '—' : fmtSigned1(a.waveSpeed), unit: 'km/h' },
      ];
      if (at.length > 1) out.push({ label: 'ブレーキを踏んだ回数', value: fmt0(at.length), unit: '回' });
      if (level.simConfig?.sag) out.push({ label: 'サグ部での最低速度比', value: fmt0((c.playerSagMinSpeedRatio ?? 1) * 100), unit: '%' });
      return out;
    }
    const out = [
      { label: '影響を受けた後続車', value: fmt0(s.affectedCount), unit: '台' },
      { label: '後続車の総時間損失', value: fmt0(s.totalTimeLoss), unit: '秒' },
      { label: '渋滞波の速度', value: s.waveSpeed == null ? '—' : fmtSigned1(s.waveSpeed), unit: 'km/h' },
      { label: '停止した車', value: fmt0(s.stoppedCount), unit: '台' },
    ];
    if (level.densityRange) {
      out.push({ label: '車列の平均速度', value: fmt0((s.meanSpeed ?? 0) * 3.6), unit: 'km/h' });
      out.push({ label: '交通流率', value: fmt0(s.flow), unit: '台/時' });
    }
    if (level.simConfig?.sag) out.push({ label: 'サグ部での最低速度比', value: fmt0((c.playerSagMinSpeedRatio ?? 1) * 100), unit: '%' });
    return out;
  }

  // ---- 台本イベント ----
  function fireScript() {
    const sim = g.sim;
    for (const e of script) {
      if (e.fired || sim.time < e.at) continue;
      e.fired = true;
      if (e.action === 'pulseBrake') {
        sim.pulseBrake(e.args || PULSE);   // 台本による強制ブレーキ（プレイヤー操作ではない）
        markEvent();
      } else if (e.action === 'leaderBrake') {
        const args = e.args || { aheadIndex: 3, decel: 3.0, duration: 2.5 };
        const braked = sim.triggerLeaderBrake(args);
        ctx.leaderAhead = args.aheadIndex ?? 3;
        markEvent(Number.isInteger(braked) ? { s: sim.cars[braked].s } : undefined);
        hud.toast(`前方 ${ctx.leaderAhead} 台目が急ブレーキ！ 車間を使って、後ろの車を止めずに受け流そう。`);
        sound.play('hint');
      } else if (e.action === 'hint') {
        const a = e.args;
        hud.toast(typeof a === 'string' ? a : (a && (a.text || a.message)) || '');
        sound.play('hint');
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

  // ---- 試行（1 回のブレーキ = 1 試行）----
  // 押した瞬間に専用の計測器を作り、離してから OBSERVE_SEC 秒観察して 1 点を記録する。
  // 観察中は次のブレーキを受け付けない（1 回ずつ結果を確かめてもらうため）。
  let trial = null;

  /** src: 'key' | 'touch'。押した瞬間に試行を始める（観察中・一時停止中は始まらない） */
  function brakeDown(src) {
    if (src === 'touch') input.touchBrake = true; else input.keyBrake = true;
    if (g.phase !== 'playing' || g.paused || !g.sim) return;
    if (trial && (trial.phase === 'braking' || trial.phase === 'observing')) return;
    trial = {
      phase: 'braking',
      startTime: g.sim.time,
      sec: 0,
      metrics: createMetrics(g.sim, { freeFlowSpeed: g.sim.params.v0 }),
      carCount: g.sim.cars.length,
      tau: g.sim.params.tau,
    };
    trial.metrics.markEvent();
    markEvent();                                       // レベル全体の計測もここから
    sound.brake(true);
    if (!onboarded) { onboarded = true; writeLS(ONBOARD_KEY, '1'); hud.hideOnboarding?.(); }
  }

  function brakeUp(src) {
    if (src === 'touch') input.touchBrake = false; else input.keyBrake = false;
    if (input.keyBrake || input.touchBrake) return;   // まだ別の入力で踏んでいる
    if (!trial || trial.phase !== 'braking') return;
    trial.sec = Math.max(0, g.sim.time - trial.startTime);
    trial.phase = 'observing';
    trial.observeUntil = g.sim.time + OBSERVE_SEC;
    sound.brake(false);
  }

  /** 観察が終わった試行を 1 点として記録する（step から毎サブステップ呼ばれる） */
  function updateTrial() {
    if (!trial) return;
    if (trial.phase === 'braking') {
      trial.sec = Math.max(0, g.sim.time - trial.startTime);
      return;
    }
    if (trial.phase !== 'observing' || g.sim.time < trial.observeUntil) return;
    const sm = trial.metrics.summary();
    const rec = {
      sec: +trial.sec.toFixed(2),
      affected: sm.affectedCount,
      timeLoss: sm.totalTimeLoss,
      stopped: sm.stoppedCount,
      waveSpeed: sm.waveSpeed,
      carCount: trial.carCount,
      tau: trial.tau,
    };
    ctx.attempts.push(rec);
    ctx.brakeCount = ctx.attempts.length;
    ctx.totalBrakeSec += rec.sec;
    ctx.longestSec = Math.max(ctx.longestSec, rec.sec);
    ctx.shortestSec = Math.min(ctx.shortestSec, rec.sec);
    trial = { phase: 'result', result: rec };
    sound.play('trial');
  }

  /** HUD に渡すブレーキ計の状態 */
  function brakeState() {
    if (!trial) return { phase: 'idle' };
    if (trial.phase === 'braking') return { phase: 'braking', holdSec: trial.sec };
    if (trial.phase === 'observing') {
      return { phase: 'observing', holdSec: trial.sec, remainSec: Math.max(0, trial.observeUntil - g.sim.time) };
    }
    return { phase: 'result', result: trial.result };
  }

  // ---- 操作 ----
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
      case 'ArrowDown': case 'KeyS': case 'KeyB':
        if (!e.repeat) brakeDown('key');
        e.preventDefault(); break;
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
      case 'ArrowDown': case 'KeyS': case 'KeyB':
        brakeUp('key'); break;
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
      hud.setBrakeState(brakeState());
      // 暫定スコアはプレイ中だけ更新する（リザルトへ移った後は確定値と食い違うので触らない）
      if (g.phase === 'playing' && g.level !== FREE_LEVEL) hud.setScore?.({ current: liveScore(), best: bestScoreOf(g.level.id), isNewBest: false });
      charts.draw({ sim, metrics: g.metrics, v0: sim.params.v0, eventTime: ctx ? ctx.eventTime : null,
        sag: !!g.cfg.sag, attempts: ctx ? ctx.attempts : [] });
    } else {
      hud.setBrakeState({ phase: 'idle' });
      charts.draw({ sim, metrics: null, v0: sim.params.v0, eventTime: null, sag: !!g.cfg.sag, attempts: [] });
    }
  }

  // ---- 1 サブステップ（main が STEP 秒ごとに呼ぶ） ----
  function step(dt) {
    const sim = g.sim;
    if (!sim) return;
    captureInterp(true);   // 進める前の状態を prevS へ送る
    if (g.phase === 'playing') {
      updatePlayerControl();
      sim.step(dt);
      g.metrics.update(sim);
      if (trial && trial.metrics) trial.metrics.update(sim);
      updateTrial();
      fireScript();
      trackCtx();
      if (sim.time >= g.level.durationSec) finish(true);
    } else {
      sim.step(dt); // タイトル / ブリーフィングの背景（アトラクト）
    }
    captureInterp(false);  // 進めた後の状態を curS に
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
    hud.on('brakeDown', () => brakeDown('touch'));
    hud.on('brakeUp', () => brakeUp('touch'));
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
    // 旧 API の保険（hud 側が hold を出す場合も brakeDown/Up と同じ扱いにする）
    hud.on('hold', (which, down) => {
      if (which !== 'brake') return;
      if (down) brakeDown('touch'); else brakeUp('touch');
    });
    hud.on('toggleMute', () => { sound.setMuted(!sound.muted); hud.setMuted?.(sound.muted); });
    hud.on('toggleView', () => {
      viewMode = viewMode === 'simple' ? 'detail' : 'simple';
      writeLS(VIEW_KEY, viewMode);
      hud.setViewMode?.(viewMode);
    });
    hud.setMuted?.(sound.muted);
    // ブラウザの自動再生制限: 最初の操作で AudioContext を起こす
    const unlockOnce = () => { sound.unlock(); window.removeEventListener('pointerdown', unlockOnce); window.removeEventListener('keydown', unlockOnce); };
    window.addEventListener('pointerdown', unlockOnce);
    window.addEventListener('keydown', unlockOnce);
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
    boot, step, refreshHud, isSimRunning, interp,
    get sim() { return g.sim; },
    get speed() { return g.speed; },
    get cameraMode() { return g.cameraMode; },
    get phase() { return g.phase; },
    get level() { return g.level; },
  };
}
