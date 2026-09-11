// src/ui/hud.js — HUD の DOM バインディング。
// index.html にある静的マークアップへ値を流し込むだけの薄い層。
// 毎フレームの更新は textContent の差分書き込みのみ（innerHTML の再構築はしない）。
// ゲームロジックは持たず、ユーザー操作は on(name, fn) で登録されたハンドラへ通知する。

const CAMERA_LABEL = { chase: '追従', overhead: '上空', overview: '全景', cockpit: '運転席', observe: '観察' };
const TOD_LABEL = { morning: '朝', dusk: '夕' };

/** スライダーの表示フォーマット（param → 文字列） */
const SLIDER_FORMAT = {
  carCount: (v) => `${Math.round(v)} 台/km`,
  T: (v) => `${v.toFixed(2)} s`,
  tau: (v) => `${v.toFixed(2)} s`,
  v0: (v) => `${Math.round(v)} km/h`,
  noise: (v) => `${v.toFixed(2)} m/s²`,
};

/** 前回と同じ文字列なら DOM に触らない */
function setText(el, str) {
  if (!el) return;
  if (el.__t !== str) { el.__t = str; el.textContent = str; }
}

/** 数値 + 単位の大表示（<small> を保ったまま先頭テキストだけ差し替える） */
function setBigNum(el, str) {
  if (!el) return;
  if (el.__t === str) return;
  el.__t = str;
  const first = el.firstChild;
  if (first && first.nodeType === 3) first.nodeValue = str;
  else el.insertBefore(document.createTextNode(str), first);
}

function fmtClock(sec) {
  if (!Number.isFinite(sec)) return '--:--';
  const s = Math.max(0, Math.floor(sec));
  const m = Math.floor(s / 60);
  return `${String(m).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
}

function starsText(n) {
  const k = Math.max(0, Math.min(3, n | 0));
  return '★'.repeat(k) + '☆'.repeat(3 - k);
}
/** 星のスクリーンリーダー用ラベル（★☆ の記号は読み上げに向かないため） */
function starsLabel(n) {
  return `星 ${Math.max(0, Math.min(3, n | 0))} つ`;
}
/** 星を表示する要素に role="img" + aria-label を付ける（stars == null なら外す） */
function setStarsA11y(elm, stars) {
  if (!elm) return;
  if (stars == null) { elm.removeAttribute('role'); elm.removeAttribute('aria-label'); return; }
  elm.setAttribute('role', 'img');
  elm.setAttribute('aria-label', starsLabel(stars));
}

/** 小さな要素ビルダー（モーダル内の稀な再構築用） */
function el(tag, className, text) {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text != null) e.textContent = text;
  return e;
}

export function createHud(doc = document) {
  const $ = (id) => doc.getElementById(id);
  const hud = $('hud');
  const handlers = new Map();
  const emit = (name, ...args) => { const f = handlers.get(name); if (f) f(...args); };

  const els = {
    tabs: $('level-tabs'), timer: $('timer'), timerTotal: $('timer-total'), pausedTag: $('paused-tag'),
    expNo: $('exp-no'), expTitle: $('exp-title'), expQuestion: $('exp-question'), expHowto: $('exp-howto'),
    btnBrake: $('btn-brake'), manualHint: $('manual-hint'), btnRestart: $('btn-restart'), btnFinish: $('btn-finish'),
    sliders: $('sliders'),
    infAffected: $('inf-affected'), infLoss: $('inf-loss'), infWave: $('inf-wave'),
    infStopped: $('inf-stopped'), infMean: $('inf-mean'), infFlow: $('inf-flow'), flowDensity: $('flow-density'),
    carSpeedWrap: $('car-speed-wrap'), carSpeed: $('car-speed'), carGap: $('car-gap'), carGapTime: $('car-gaptime'),
    brakeGauge: $('brake-gauge'), brakeNum: $('brake-num'), brakeValue: $('brake-value'),
    brakeLabel: $('brake-label'), brakeBar: $('brake-bar'), brakeBarFill: $('brake-bar-fill'),
    cameraMode: $('camera-mode'), todLabel: $('tod-label'),
    pauseLabel: $('pause-label'), speedSeg: $('speed-seg'), chartMeanNow: $('chart-mean-now'),
    toast: $('toast'),
    modalTitle: $('modal-title'), modalBriefing: $('modal-briefing'), modalResult: $('modal-result'),
    titleProgress: $('title-progress'),
    briefNo: $('brief-no'), briefTitle: $('brief-title'), briefQuestion: $('brief-question'), briefBullets: $('brief-bullets'),
    briefHowto: $('brief-howto'), briefGoalsBox: $('brief-goals-box'), briefGoals: $('brief-goals'), briefMeta: $('brief-meta'),
    resNo: $('res-no'), resTitle: $('res-title'), resQuiz: $('res-quiz'), quizQ: $('quiz-q'), quizChoices: $('quiz-choices'),
    quizExplain: $('quiz-explain'), quizDone: $('quiz-done'),
    resBody: $('res-body'), resStars: $('res-stars'), resStarsCap: $('res-stars-cap'), resIncomplete: $('res-incomplete'),
    resHeadline: $('res-headline'), resNumbers: $('res-numbers'), resLines: $('res-lines'),
    resLesson: $('res-lesson'), lessonTitle: $('lesson-title'), lessonBody: $('lesson-body'), lessonFact: $('lesson-fact'),
    resNext: $('res-next'), resRetry: $('res-retry'), resTitleBtn: $('res-title-btn'),
    // カジュアル仕上げ（CASUAL_POLISH.md）
    btnMute: $('btn-mute'), muteOn: $('mute-icon-on'), muteOff: $('mute-icon-off'),
    btnView: $('btn-view'), btnFinishTop: $('btn-finish-top'),
    missionNo: $('mission-no'), missionTitle: $('mission-title'), missionHowto: $('mission-howto'),
    missionDensity: $('mission-density'), missionDensityInput: $('mission-density-input'), missionDensityOut: $('mission-density-out'),
    scoreBlock: $('score-block'), scoreCurrent: $('score-current'), scoreBest: $('score-best'), scoreNew: $('score-new'),
    vignette: $('brake-vignette'), onboard: $('onboard-hint'),
    resScore: $('res-score'), resScoreNum: $('res-score-num'), resScoreBest: $('res-score-best'), resScoreNew: $('res-score-new'),
    confetti: $('confetti'),
    // 有料級仕上げ（PREMIUM_POLISH.md）: 目標チェックリスト / 解放 / クリア条件 / バッジ
    goalsCard: $('goals-card'), goalsList: $('goals-list'), expGoals: $('exp-goals'), expGoalsList: $('exp-goals-list'),
    titleStatus: $('title-status'), titleStars: $('title-stars'), titleNext: $('title-next'),
    briefRule: $('brief-rule'), briefDuration: $('brief-duration'),
    resBadge: $('res-badge'), resUnlock: $('res-unlock'),
  };

  els.btnPulse = els.btnBrake; // 旧名の別名（互換用）
  const win = doc.defaultView || window;
  const reducedMotion = () => !!(win.matchMedia && win.matchMedia('(prefers-reduced-motion: reduce)').matches);

  const chartCanvases = {
    timeline: $('chart-timeline'),
    spaceTime: $('chart-spacetime'),
    minimap: $('chart-minimap'),
    scatter: $('chart-scatter'),
    course: $('chart-course'),           // シンプル表示の「コース全体」パネル
    courseReadout: $('course-readout'),
    ringReadout: $('ring-readout'),
  };

  // ---------------------------------------------------------------
  // 静的なイベント結線（1 回だけ）
  // ---------------------------------------------------------------
  const click = (elm, name, ...args) => elm && elm.addEventListener('click', (e) => { e.currentTarget.blur(); emit(name, ...args); });
  click(els.btnRestart, 'restart');
  click(els.btnFinish, 'finish');
  click(els.btnFinishTop, 'finish');   // simple 表示ではトップバーの「結果を見る」を使う
  click(els.btnView, 'toggleView');
  click(els.btnMute, 'toggleMute');
  click($('btn-camera'), 'camera');
  click($('btn-camera-top'), 'camera');   // シンプル表示 / スマホでも視点を切り替えられるようトップバーにも置く
  click($('btn-tod'), 'tod');
  click($('btn-pause'), 'pause');
  click($('title-start'), 'titleStart');
  click($('title-free'), 'titleFree');
  click($('brief-start'), 'briefStart');
  click($('brief-back'), 'briefBack');
  click(els.resNext, 'resultNext');
  click(els.resRetry, 'resultRetry');
  click(els.resTitleBtn, 'resultTitle');
  click($('sheet-toggle'), 'sheet');

  els.speedSeg.addEventListener('click', (e) => {
    const b = e.target.closest('button[data-speed]');
    if (b) { b.blur(); emit('speed', Number(b.dataset.speed)); }
  });

  // スライダー: carCount は確定時（change）のみ、それ以外はドラッグ中（input）に通知
  for (const row of els.sliders.querySelectorAll('.slider')) {
    const param = row.dataset.param;
    const input = row.querySelector('input');
    const out = row.querySelector('output');
    const fmt = SLIDER_FORMAT[param] || ((v) => String(v));
    const show = () => setText(out, fmt(Number(input.value)));
    input.addEventListener('input', () => { show(); if (param !== 'carCount') emit('slider', param, Number(input.value)); else syncDensity(); });
    input.addEventListener('change', () => { show(); if (param === 'carCount') { syncDensity(); emit('slider', param, Number(input.value)); } input.blur(); });
  }

  // バナー下の台数スライダー（simple 用）: 左パネルの carCount スライダーの鏡。値・レンジは常に左パネル側が正
  const mainDensityInput = els.sliders.querySelector('.slider[data-param="carCount"] input');
  const mainDensityOut = els.sliders.querySelector('.slider[data-param="carCount"] output');
  function syncDensity() {
    const m = mainDensityInput, d = els.missionDensityInput;
    if (!m || !d) return;
    if (d.min !== m.min) d.min = m.min;
    if (d.max !== m.max) d.max = m.max;
    if (d.value !== m.value) d.value = m.value;
    setText(els.missionDensityOut, SLIDER_FORMAT.carCount(Number(d.value)));
  }
  if (els.missionDensityInput) {
    const d = els.missionDensityInput;
    d.addEventListener('input', () => setText(els.missionDensityOut, SLIDER_FORMAT.carCount(Number(d.value))));
    d.addEventListener('change', () => {
      const v = Number(d.value);
      if (mainDensityInput) { mainDensityInput.value = d.value; setText(mainDensityOut, SLIDER_FORMAT.carCount(v)); }
      emit('slider', 'carCount', v);
      d.blur();
    });
  }
  for (const row of els.sliders.querySelectorAll('.check')) {
    const input = row.querySelector('input');
    input.addEventListener('change', () => { emit('toggle', row.dataset.toggle, input.checked); input.blur(); });
  }

  // ブレーキボタン（マウス / タッチとも「押している間」だけ有効）。
  // 押し下げ = brakeDown、離す / 指が外れる = brakeUp。旧 'hold' も互換のため併せて通知する。
  const bindBrake = (elm) => {
    if (!elm) return;
    // 押した指（pointerId）だけを離す対象にする。2 本目の指の up/cancel で 1 本目のブレーキが
    // 外れないようにし、setPointerCapture で指がボタン外へ出ても up を受け取る
    let activeId = null;
    const press = (e) => {
      e.preventDefault();
      if (activeId !== null) return;
      activeId = e.pointerId ?? -1;
      try { elm.setPointerCapture?.(e.pointerId); } catch { /* 非対応は無視 */ }
      elm.classList.add('is-down');
      emit('hold', 'brake', true);
      emit('brakeDown');
    };
    const release = (e) => {
      if (activeId === null) return;
      if (e && e.pointerId !== undefined && e.pointerId !== activeId && e.type !== 'blur') return;
      try { elm.releasePointerCapture?.(activeId); } catch { /* 取得していなければ無視 */ }
      activeId = null;
      elm.classList.remove('is-down');
      emit('hold', 'brake', false);
      emit('brakeUp');
    };
    elm.addEventListener('pointerdown', press);
    elm.addEventListener('pointerup', release);
    elm.addEventListener('pointercancel', release);
    elm.addEventListener('lostpointercapture', release);
    elm.addEventListener('blur', release);
    // pointer capture 非対応（古い Safari 等）の保険: ボタン外で離しても window で拾って解放する
    window.addEventListener('pointerup', release);
    window.addEventListener('pointercancel', release);
    window.addEventListener('blur', () => release());
    elm.addEventListener('contextmenu', (e) => e.preventDefault());
  };
  bindBrake(els.btnBrake);
  bindBrake($('touch-brake'));

  // クイズ: 選択肢クリック → 判定 → 「結果を見る」へ
  let quizCallback = null;
  let quizCorrect = null;
  els.quizDone.addEventListener('click', () => {
    els.quizDone.blur();
    const cb = quizCallback; quizCallback = null;
    if (cb) cb(quizCorrect === true);
  });

  // ---------------------------------------------------------------
  // レベルタブ
  // ---------------------------------------------------------------
  const tabById = new Map();
  let unlockedSet = null;   // null = 全て解放（旧 API 互換）。Set<levelId> なら含まれないレベルはロック
  /** progress[id] は { stars, score }（旧形式の数値も受ける）→ 星数 or null */
  const starsOf = (p) => (p == null ? null : (typeof p === 'object' ? (p.stars ?? null) : p));
  const toSet = (u) => (u instanceof Set ? u : Array.isArray(u) ? new Set(u) : null);

  /**
   * レベルタブを作り直す。unlocked（Set<id>）を渡すと含まれないレベルは 🔒 + aria-disabled になり、
   * クリックは selectLevel ではなく lockedTap(levelId) を発火する。省略時は全て解放扱い。
   */
  function setLevels(levels, progress = {}, { unlocked } = {}) {
    unlockedSet = toSet(unlocked);
    els.tabs.replaceChildren();
    tabById.clear();
    for (const lv of levels) {
      const b = el('button', 'tab');
      b.type = 'button';
      b.dataset.id = lv.id;
      b.title = lv.title;
      const lock = el('span', 'tab-lock', '🔒');
      lock.setAttribute('aria-hidden', 'true');
      lock.hidden = true;
      b.append(lock, doc.createTextNode(lv.no));
      const st = el('span', 'tab-stars');
      b.append(st);
      b.addEventListener('click', () => {
        b.blur();
        if (b.classList.contains('is-locked')) emit('lockedTap', lv.id);
        else emit('selectLevel', lv.id);
      });
      els.tabs.append(b);
      tabById.set(lv.id, { b, st, lock, lv });
      if (progress[lv.id] != null) setLevelStars(lv.id, progress[lv.id]);
      applyLock(lv.id);
    }
  }
  function applyLock(id) {
    const t = tabById.get(id);
    if (!t) return;
    const locked = unlockedSet != null && !unlockedSet.has(id);
    t.b.classList.toggle('is-locked', locked);
    t.lock.hidden = !locked;
    if (locked) {
      t.b.setAttribute('aria-disabled', 'true');
      t.b.setAttribute('aria-label', `実験 ${t.lv.no} ${t.lv.title}（ロック中）`);
      t.b.title = `${t.lv.title}（ロック中）`;
    } else {
      t.b.removeAttribute('aria-disabled');
      t.b.removeAttribute('aria-label');
      t.b.title = t.lv.title;
    }
  }
  /** タブを作り直さずにロック状態だけ更新（Set<id> / 配列。null で全解放） */
  function setUnlocked(unlocked) {
    unlockedSet = toSet(unlocked);
    for (const id of tabById.keys()) applyLock(id);
  }
  function setActiveLevel(id) {
    for (const [lid, t] of tabById) t.b.classList.toggle('is-active', lid === id);
  }
  /** stars は数値 or { stars, score }（progress の 1 要素）。null で消す */
  function setLevelStars(id, stars) {
    const t = tabById.get(id);
    if (!t) return;
    const n = starsOf(stars);
    setText(t.st, n == null ? '' : starsText(n));
    setStarsA11y(t.st, n);
  }

  // ---------------------------------------------------------------
  // 目標チェックリスト（simple: バナー下のカード / detail: 左パネル）
  // 行は件数が変わった時だけ作り直し、毎 tick は textContent とクラスの差分更新のみ。
  // ○ → ✓ に変わった瞬間だけ 0.3 秒のポップ（is-pop）。
  // ---------------------------------------------------------------
  function makeGoalList(ul) {
    const rows = [];   // { li, mark, text, ok, popT }
    const rebuild = (n) => {
      for (const r of rows) clearTimeout(r.popT);
      rows.length = 0;
      ul.replaceChildren();
      for (let i = 0; i < n; i++) {
        const li = el('li', 'goal');
        const mark = el('span', 'goal-mark', '○');
        mark.setAttribute('role', 'img');
        mark.setAttribute('aria-label', '未達成');
        const text = el('span', 'goal-text', '');
        li.append(mark, text);
        ul.append(li);
        rows.push({ li, mark, text, ok: null, popT: 0 });
      }
    };
    return {
      update(items) {
        if (!ul) return;
        if (rows.length !== items.length) rebuild(items.length);
        for (let i = 0; i < items.length; i++) {
          const it = items[i] || {};
          const r = rows[i];
          setText(r.text, String(it.text ?? ''));
          const ok = !!it.ok;
          if (ok === r.ok) continue;
          const flipped = r.ok === false && ok;   // 初回描画（null → ok）ではポップさせない
          r.ok = ok;
          r.li.classList.toggle('is-ok', ok);
          setText(r.mark, ok ? '✓' : '○');
          r.mark.setAttribute('aria-label', ok ? '達成' : '未達成');
          clearTimeout(r.popT);
          if (flipped && !reducedMotion()) {
            r.li.classList.add('is-pop');
            r.popT = setTimeout(() => r.li.classList.remove('is-pop'), 350);
          } else {
            r.li.classList.remove('is-pop');
          }
        }
      },
    };
  }
  const goalsSimple = makeGoalList(els.goalsList);
  const goalsDetail = makeGoalList(els.expGoalsList);
  /** items = [{ text, ok }]（3 件）。空配列 / null で非表示（FREE） */
  function setGoals(items) {
    const list = Array.isArray(items) ? items : [];
    const hide = list.length === 0;
    if (els.goalsCard) els.goalsCard.hidden = hide;
    if (els.expGoals) els.expGoals.hidden = hide;
    goalsSimple.update(list);
    goalsDetail.update(list);
  }

  // ---------------------------------------------------------------
  // 左パネル（実験）
  // ---------------------------------------------------------------
  // ブレーキのみの操作系なので、ブレーキボタンとキー説明は常に出す（mode による出し分けはしない）
  function setExperiment(level, { free = false } = {}) {
    setText(els.expNo, level.no);
    setText(els.expTitle, level.title);
    setText(els.expQuestion, level.question || '');
    setText(els.expHowto, level.howTo || '');
    els.btnFinish.hidden = free;
    if (els.btnFinishTop) els.btnFinishTop.hidden = free;
    // simple 用のミッションバナー。台数スライダーは densityRange のあるレベルだけ
    setText(els.missionNo, level.no);
    setText(els.missionTitle, level.title);
    setText(els.missionHowto, level.howTo || '');
    hud.classList.toggle('has-density', !!level.densityRange);
  }

  // ---------------------------------------------------------------
  // 表示モード（simple / detail）・ミュート表示
  // ---------------------------------------------------------------
  let viewMode = 'detail';
  /** 'simple' | 'detail'。保存（localStorage）は game.js 側の責務 */
  function setViewMode(mode) {
    viewMode = mode === 'simple' ? 'simple' : 'detail';
    hud.classList.toggle('mode-simple', viewMode === 'simple');
    if (els.btnView) {
      // ボタンは「切り替え先」を示す
      setText(els.btnView, viewMode === 'simple' ? '詳細' : 'シンプル');
      els.btnView.setAttribute('aria-label', viewMode === 'simple' ? '詳細表示に切り替え' : 'シンプル表示に切り替え');
    }
  }
  function getViewMode() { return viewMode; }
  function setMuted(muted) {
    const m = !!muted;
    if (els.muteOn) els.muteOn.hidden = m;
    if (els.muteOff) els.muteOff.hidden = !m;
    if (els.btnMute) {
      els.btnMute.setAttribute('aria-pressed', String(m));
      els.btnMute.setAttribute('aria-label', m ? 'ミュート解除' : 'ミュート');
    }
  }

  // ---------------------------------------------------------------
  // スコア（車パネル）: current == null（FREE）なら非表示
  // ---------------------------------------------------------------
  function setScore({ current = null, best = null, isNewBest = false } = {}) {
    const has = current != null && Number.isFinite(current);
    els.scoreBlock.hidden = !has;
    if (!has) return;
    setText(els.scoreCurrent, String(Math.round(current)));
    setText(els.scoreBest, best != null && Number.isFinite(best) ? `ベスト ${Math.round(best)}` : '');
    els.scoreNew.hidden = !isNewBest;
  }

  // ---------------------------------------------------------------
  // 初回オンボーディング（吹き出し）。出すタイミングは game.js が決める
  // ---------------------------------------------------------------
  function showOnboarding() {
    if (!els.onboard) return;
    const coarse = !!(win.matchMedia && win.matchMedia('(pointer: coarse)').matches);
    setText(els.onboard, coarse ? '下のボタンを押している間ブレーキ' : 'S / ↓ を押している間ブレーキ');
    els.onboard.hidden = false;
  }
  function hideOnboarding() {
    if (els.onboard) els.onboard.hidden = true;
  }

  /**
   * スライダー群の表示・値・レンジをまとめて設定。
   * spec = { visible: string[], toggles: string[], values: {}, toggleValues: {}, ranges: { param: {min,max} } }
   */
  function setSliders(spec) {
    const visible = new Set(spec.visible || []);
    const toggles = new Set(spec.toggles || []);
    for (const row of els.sliders.querySelectorAll('.slider')) {
      const p = row.dataset.param;
      row.hidden = !visible.has(p);
      const input = row.querySelector('input');
      const r = spec.ranges && spec.ranges[p];
      if (r) { if (r.min != null) input.min = r.min; if (r.max != null) input.max = r.max; }
      if (spec.values && spec.values[p] != null) {
        input.value = spec.values[p];
        setText(row.querySelector('output'), (SLIDER_FORMAT[p] || String)(Number(input.value)));
      }
    }
    for (const row of els.sliders.querySelectorAll('.check')) {
      const t = row.dataset.toggle;
      row.hidden = !toggles.has(t);
      if (spec.toggleValues && spec.toggleValues[t] != null) row.querySelector('input').checked = !!spec.toggleValues[t];
    }
    els.sliders.hidden = visible.size === 0 && toggles.size === 0;
    syncDensity();
  }

  /** 旧 API 互換のダミー（操作はブレーキのみになり、モードによる出し分けは廃止） */
  function setMode() {}

  /** ブレーキボタンを光らせる（外部からのブレーキ通知用） */
  function flashPulse() {
    els.btnBrake.classList.remove('is-flash');
    // reflow を挟んでアニメーションを再開
    void els.btnBrake.offsetWidth;
    els.btnBrake.classList.add('is-flash');
  }

  // ---------------------------------------------------------------
  // 上部: タイマー / 一時停止 / 倍速
  // ---------------------------------------------------------------
  function setTimer(t, duration) {
    setText(els.timer, fmtClock(t));
    if (Number.isFinite(duration)) {
      setText(els.timerTotal, `/ ${fmtClock(duration)}`);
      els.timer.classList.toggle('is-warn', duration - t <= 10 && duration - t > 0);
    } else {
      setText(els.timerTotal, '');
      els.timer.classList.remove('is-warn');
    }
  }
  function setPaused(paused) {
    hud.classList.toggle('is-paused', paused);
    els.pausedTag.hidden = !paused;
    setText(els.pauseLabel, paused ? '再開' : '一時停止');
  }
  function setSpeed(mult) {
    for (const b of els.speedSeg.querySelectorAll('button')) b.classList.toggle('is-active', Number(b.dataset.speed) === mult);
  }

  // ---------------------------------------------------------------
  // 右下パネル: あなたが起こした波（WAVE IMPACT）
  // ---------------------------------------------------------------
  function setInfluence(s) {
    if (!s) return;
    setBigNum(els.infAffected, String(s.affectedCount ?? 0));
    setBigNum(els.infLoss, String(Math.round(s.totalTimeLoss ?? 0)));
    const w = s.waveSpeed;
    setBigNum(els.infWave, w == null || !Number.isFinite(w) ? '—' : (w > 0 ? '+' : '') + w.toFixed(1));
    els.infAffected.classList.toggle('is-hot', (s.affectedCount ?? 0) > 0);
    setText(els.infStopped, String(s.stoppedCount ?? 0));
    els.infStopped.classList.toggle('is-red', (s.stoppedCount ?? 0) > 0);
    setText(els.infMean, Number.isFinite(s.meanSpeed) ? `${(s.meanSpeed * 3.6).toFixed(0)} km/h` : '—');
    setText(els.infFlow, Number.isFinite(s.flow) ? `${Math.round(s.flow)} 台/時` : '—');
    setText(els.flowDensity, Number.isFinite(s.density) ? `· ${Math.round(s.density)} 台/km` : '');
    setText(els.chartMeanNow, Number.isFinite(s.meanSpeed) ? `${(s.meanSpeed * 3.6).toFixed(0)} km/h` : '');
  }

  // ---------------------------------------------------------------
  // 中央下: 車情報
  // ---------------------------------------------------------------
  function setCar({ speedKmh = 0, gap = null, gapTime = null, braking = false, cameraMode = 'chase', timeOfDay = 'morning' } = {}) {
    setText(els.carSpeed, String(Math.round(Math.max(0, speedKmh))));
    els.carSpeedWrap.classList.toggle('is-braking', !!braking);
    setText(els.carGap, gap == null ? '—' : gap.toFixed(0));
    setText(els.carGapTime, gapTime == null ? '—' : gapTime.toFixed(1));
    els.carGapTime.classList.toggle('is-warn', gapTime != null && gapTime < 1.0);
    setText(els.cameraMode, CAMERA_LABEL[cameraMode] || cameraMode);
    setText(els.todLabel, TOD_LABEL[timeOfDay] || timeOfDay);
  }

  // ---------------------------------------------------------------
  // 中央下: ブレーキ計（踏んでいる長さ → 観察中 → 結果）
  // ---------------------------------------------------------------
  let brakePhase = '';   // 直前のフェーズ（変化時だけクラス / hidden を触る）
  let obsTotal = 0;      // 観察フェーズの全体秒数（進捗バーの分母）
  let barPct = -1;       // 直前のバー幅（%）
  let vigLast = -1;      // 直前のビネット強度（0.05 刻み・変化時だけ style を触る）

  /**
   * state = { phase: 'idle'|'braking'|'observing'|'result', holdSec, remainSec,
   *           result: { sec, affected, timeLoss, stopped } }
   * ~10 Hz で呼ばれる前提。textContent の差分書き込みのみ。
   */
  function setBrakeState(state) {
    // 観察中はコース全体パネルを強調（渋滞が後ろへ広がる様子をここで見てもらう）
    $('panel-course')?.classList.toggle('is-observing', !!state && state.phase === 'observing');
    const s = state || {};
    const phase = s.phase || 'idle';
    if (phase !== brakePhase) {
      els.brakeGauge.className = `brake is-${phase}`;
      els.brakeNum.hidden = phase !== 'braking';
      els.brakeBar.hidden = phase !== 'observing';
      if (phase === 'observing') { obsTotal = Math.max(0.001, s.remainSec || 0); barPct = -1; }
      hud.classList.toggle('is-braking', phase === 'braking'); // 赤いビネット（CSS で opacity をイーズ）
      brakePhase = phase;
    }
    if (phase === 'braking') {
      const hold = Math.max(0, s.holdSec || 0);
      setText(els.brakeValue, hold.toFixed(1));
      setText(els.brakeLabel, 'ブレーキ中');
      // ビネットの濃さは踏んだ長さに同期（0.55 → 2.5 秒で 1.0）
      const vig = Math.round((0.55 + 0.45 * Math.min(1, hold / 2.5)) * 20) / 20;
      if (vig !== vigLast) { vigLast = vig; hud.style.setProperty('--vig', String(vig)); }
    } else if (phase === 'observing') {
      const remain = Math.max(0, s.remainSec || 0);
      setText(els.brakeLabel, `観察中 残り ${Math.ceil(remain)} 秒`);
      const pct = Math.round(Math.min(1, remain / obsTotal) * 100);
      if (pct !== barPct) { barPct = pct; els.brakeBarFill.style.width = `${pct}%`; }
    } else if (phase === 'result') {
      const r = s.result || {};
      const stopped = r.stopped > 0 ? `・停止 ${r.stopped} 台` : '';
      setText(els.brakeLabel,
        // 車情報パネルは幅が限られるので短く。詳しくはリザルトと散布図で見せる
        `${Number(r.sec || 0).toFixed(1)} 秒 → ${r.affected || 0} 台・遅れ ${Math.round(r.timeLoss || 0)} 秒${stopped}`);
    } else {
      setText(els.brakeLabel, 'S / ↓ を押している間ブレーキ');
    }
  }

  // ---------------------------------------------------------------
  // 可視状態・トースト・ボトムシート
  // ---------------------------------------------------------------
  function setHudVisible(visible, dim = false) {
    hud.classList.toggle('is-hidden', !visible);
    hud.classList.toggle('is-dim', visible && dim);
  }
  function toggleSheet(force) {
    hud.classList.toggle('sheet-open', force);
  }
  let toastTimer = 0;
  function toast(text, ms = 4500) {
    if (!text) return;
    setText(els.toast, text);
    els.toast.classList.add('is-show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => els.toast.classList.remove('is-show'), ms);
  }

  // ---------------------------------------------------------------
  // モーダル
  // ---------------------------------------------------------------
  function hideModals() {
    cancelResultFx();
    els.modalTitle.hidden = true;
    els.modalBriefing.hidden = true;
    els.modalResult.hidden = true;
    // バッジは毎回 hidden → 表示にしてアニメーションを再生させる（クイズ表示中は出さない）
    if (els.resBadge) els.resBadge.hidden = true;
    if (els.resUnlock) els.resUnlock.hidden = true;
  }

  // ---------------------------------------------------------------
  // リザルト演出: スコアのカウントアップ / 星のポップ通知 / 紙吹雪
  // ---------------------------------------------------------------
  let resRaf = 0;            // カウントアップの rAF
  const resTimers = [];      // 星 / 紙吹雪の setTimeout
  let confRaf = 0;           // 紙吹雪の rAF
  function cancelResultFx() {
    if (resRaf) { cancelAnimationFrame(resRaf); resRaf = 0; }
    for (const t of resTimers) clearTimeout(t);
    resTimers.length = 0;
    stopConfetti();
  }

  /** 0 → target を 0.8 秒でカウントアップ。onTick は 60 ms に 1 回まで、onDone は完了時 */
  function countUp(target, onTick, onDone) {
    const t0 = performance.now();
    let lastTick = -Infinity, lastVal = -1;
    const step = (now) => {
      const t = Math.min(1, (now - t0) / 800);
      const e = 1 - Math.pow(1 - t, 3);   // easeOutCubic
      const v = Math.round(target * e);
      if (v !== lastVal) {
        lastVal = v;
        setText(els.resScoreNum, String(v));
        if (onTick && now - lastTick >= 60) { lastTick = now; onTick(v); }
      }
      if (t < 1) resRaf = requestAnimationFrame(step);
      else { resRaf = 0; if (onDone) onDone(); }
    };
    resRaf = requestAnimationFrame(step);
  }

  // 紙吹雪: 粒の配列は 1 回だけ確保し、毎フレームのアロケーションをしない
  const CONF_N = 140;
  const CONF_COLORS = ['#f5a524', '#2dd4bf', '#8ea4ea', '#e5484d', '#ffffff'];
  const conf = {
    x: new Float32Array(CONF_N), y: new Float32Array(CONF_N), vx: new Float32Array(CONF_N), vy: new Float32Array(CONF_N),
    rot: new Float32Array(CONF_N), vr: new Float32Array(CONF_N), w: new Float32Array(CONF_N), h: new Float32Array(CONF_N),
    c: new Uint8Array(CONF_N),
  };
  function stopConfetti() {
    if (confRaf) { cancelAnimationFrame(confRaf); confRaf = 0; }
    const cv = els.confetti;
    if (cv && !cv.hidden) {
      const ctx = cv.getContext('2d');
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, cv.width, cv.height);
      cv.hidden = true;
    }
  }
  /** 3 星の紙吹雪（1.5 秒）。prefers-reduced-motion では何もしない */
  function startConfetti() {
    const cv = els.confetti;
    if (!cv || reducedMotion()) return;
    stopConfetti();
    const W = win.innerWidth, H = win.innerHeight;
    const dpr = Math.min(2, win.devicePixelRatio || 1);
    cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
    const ctx = cv.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    for (let i = 0; i < CONF_N; i++) {
      conf.x[i] = W * 0.5 + (Math.random() - 0.5) * W * 0.3;
      conf.y[i] = H * 0.38;
      conf.vx[i] = (Math.random() - 0.5) * 1100;
      conf.vy[i] = -(350 + Math.random() * 600);
      conf.rot[i] = Math.random() * Math.PI;
      conf.vr[i] = (Math.random() - 0.5) * 14;
      conf.w[i] = 6 + Math.random() * 6;
      conf.h[i] = 4 + Math.random() * 4;
      conf.c[i] = (Math.random() * CONF_COLORS.length) | 0;
    }
    cv.hidden = false;
    const DUR = 1500;
    const t0 = performance.now();
    let prev = t0;
    const frame = (now) => {
      const dt = Math.min(0.05, (now - prev) / 1000); prev = now;
      const age = (now - t0) / DUR;
      if (age >= 1) { confRaf = 0; stopConfetti(); return; }
      ctx.clearRect(0, 0, W, H);
      ctx.globalAlpha = age > 0.7 ? (1 - age) / 0.3 : 1;  // 最後の 0.45 秒でフェード
      for (let i = 0; i < CONF_N; i++) {
        conf.vy[i] += 1400 * dt;
        conf.vx[i] *= 0.985;
        conf.x[i] += conf.vx[i] * dt;
        conf.y[i] += conf.vy[i] * dt;
        conf.rot[i] += conf.vr[i] * dt;
        ctx.save();
        ctx.translate(conf.x[i], conf.y[i]);
        ctx.rotate(conf.rot[i]);
        ctx.fillStyle = CONF_COLORS[conf.c[i]];
        ctx.fillRect(-conf.w[i] / 2, -conf.h[i] / 2, conf.w[i], conf.h[i]);
        ctx.restore();
      }
      ctx.globalAlpha = 1;
      confRaf = requestAnimationFrame(frame);
    };
    confRaf = requestAnimationFrame(frame);
  }
  function isModalOpen() {
    return !els.modalTitle.hidden || !els.modalBriefing.hidden || !els.modalResult.hidden;
  }
  /** モーダルを開いた直後に主ボタン（無ければ最初の押せるボタン）へフォーカスを移す */
  function focusPrimary(modal) {
    const btns = [...modal.querySelectorAll('button')].filter((b) => !b.hidden && !b.disabled && b.offsetParent !== null);
    const b = btns.find((x) => x.classList.contains('btn-primary')) || btns[0];
    if (b) b.focus({ preventScroll: true });
  }
  /** 開いているモーダルの主ボタンを押す（Enter キー用） */
  function pressPrimary() {
    const open = [els.modalTitle, els.modalBriefing, els.modalResult].find((m) => !m.hidden);
    if (!open) return false;
    const b = [...open.querySelectorAll('.btn-primary')].find((x) => !x.hidden && !x.disabled && x.offsetParent !== null);
    if (b) { b.click(); return true; }
    return false;
  }

  /**
   * タイトル。progress[id] は { stars, score }（旧形式の数値も可）。
   * opts = { unlocked: Set<id>, totalStars, maxStars, nextLevel }
   *   totalStars / maxStars → 「★ 9 / 15」、nextLevel → 「次の実験: 03 混んでいる道路では」（全クリアなら null で省略）
   */
  function showTitle(levels = [], progress = {}, opts = {}) {
    hideModals();
    if (opts.unlocked !== undefined) setUnlocked(opts.unlocked);
    els.titleProgress.replaceChildren();
    for (const lv of levels) {
      const n = starsOf(progress[lv.id]);
      if (n == null) continue;
      const s = el('span', null, lv.no);
      const b = el('b', null, starsText(n));
      setStarsA11y(b, n);
      s.append(b);
      els.titleProgress.append(s);
    }
    const hasStars = Number.isFinite(opts.totalStars) && Number.isFinite(opts.maxStars);
    const next = opts.nextLevel || null;
    if (els.titleStatus) {
      els.titleStatus.hidden = !hasStars && !next;
      if (els.titleStars) {
        els.titleStars.hidden = !hasStars;
        setText(els.titleStars, hasStars ? `★ ${opts.totalStars} / ${opts.maxStars}` : '');
        els.titleStars.setAttribute('aria-label', hasStars ? `星 ${opts.totalStars} / ${opts.maxStars}` : '');
      }
      if (els.titleNext) {
        els.titleNext.hidden = !next;
        if (next) els.titleNext.replaceChildren(doc.createTextNode('次の実験: '), el('b', null, next.no), doc.createTextNode(next.title || ''));
        else els.titleNext.replaceChildren();
      }
    }
    els.modalTitle.hidden = false;
    focusPrimary(els.modalTitle);
  }

  /**
   * ブリーフィング。opts = { goals: string[3], durationSec } は省略可（level.goals / level.durationSec を使う）。
   * 「クリア条件」に 3 目標を ★1/★2/★3 のラベル付きで並べ、「★1 でクリア、★3 でパーフェクト」と制限時間を添える。
   */
  function showBriefing(level, meta = '', opts = {}) {
    hideModals();
    setText(els.briefNo, level.no);
    setText(els.briefTitle, level.title);
    setText(els.briefQuestion, level.question || '');
    els.briefBullets.replaceChildren(...(level.briefing || []).map((t) => el('li', null, t)));
    setText(els.briefHowto, level.howTo || '');
    const goals = Array.isArray(opts.goals) ? opts.goals : (level.goals || []);
    const dur = opts.durationSec !== undefined ? opts.durationSec : level.durationSec;
    els.briefGoalsBox.hidden = goals.length === 0;
    els.briefGoals.replaceChildren(...goals.map((t, i) => {
      const li = el('li', 'brief-goal');
      const tag = el('b', 'goal-tag', `★${i + 1}`);
      tag.setAttribute('aria-label', `星 ${i + 1}`);
      li.append(tag, el('span', null, typeof t === 'string' ? t : (t && t.text) || ''));
      return li;
    }));
    if (els.briefRule) els.briefRule.hidden = goals.length === 0;
    if (els.briefDuration) {
      const has = Number.isFinite(dur);
      els.briefDuration.hidden = !has;
      setText(els.briefDuration, has ? `制限時間 ${Math.round(dur)} 秒。時間内にどこまで満たせるかで星が決まります。` : '');
    }
    setText(els.briefMeta, meta);
    els.modalBriefing.hidden = false;
    focusPrimary(els.modalBriefing);
  }

  /** クイズ表示。回答後「結果を見る」で onDone(correct) */
  function showQuiz(level, quiz, onDone) {
    hideModals();
    setText(els.resNo, level.no);
    setText(els.resTitle, level.title);
    els.resBody.hidden = true;
    els.resQuiz.hidden = false;
    setText(els.quizQ, quiz.q);
    els.quizExplain.hidden = true;
    els.quizExplain.replaceChildren();
    els.quizDone.disabled = true;
    quizCorrect = null;
    quizCallback = onDone;
    const buttons = quiz.choices.map((c, i) => {
      const b = el('button', 'choice', `${String.fromCharCode(65 + i)}. ${c}`);
      b.type = 'button';
      b.addEventListener('click', () => {
        if (quizCorrect !== null) return;
        quizCorrect = i === quiz.answer;
        buttons.forEach((x, j) => {
          x.disabled = true;
          if (j === quiz.answer) x.classList.add('is-correct');
          else if (j === i) x.classList.add('is-wrong');
        });
        const verdict = el('span', 'quiz-verdict ' + (quizCorrect ? 'ok' : 'ng'), quizCorrect ? '正解！' : '惜しい。');
        els.quizExplain.replaceChildren(verdict, doc.createTextNode(quiz.explain || ''));
        els.quizExplain.hidden = false;
        els.quizDone.disabled = false;
        els.quizDone.focus();
      });
      return b;
    });
    els.quizChoices.replaceChildren(...buttons);
    els.modalResult.hidden = false;
    focusPrimary(els.modalResult); // 「結果を見る」は回答前は disabled なので最初の選択肢へ
  }

  /**
   * リザルト表示。
   * payload = { level, stars, headline, numbers: [{label, value, unit}], lines, lesson, completed, nextLabel,
   *             score, bestScore, isNewBest,          // score == null（FREE）ならスコア欄は出さない
   *             cleared, perfect, unlockedNext,       // バッジ（省略時は stars から: 3 = パーフェクト、1〜2 = クリア）/ 解放された次のレベル（or null）
   *             onTick(value), onStar(index), onDone } // 演出フック（任意・効果音用）
   * 星は 0.25 秒間隔でポップ（onStar(i) は i*250 ms）、スコアは 0.8 秒でカウントアップ（onTick は 60 ms 間引き）、
   * 3 星なら 3 つ目の星の直後に紙吹雪。onDone はカウントアップ完了時（score が無ければ即時）。
   */
  function showResult(p) {
    hideModals();
    setText(els.resNo, p.level.no);
    setText(els.resTitle, p.level.title);
    els.resQuiz.hidden = true;
    els.resBody.hidden = false;

    // バッジ: パーフェクト！（3★）/ クリア！（1〜2★）/ 未クリア — もう一度（0★）。hideModals で hidden にしてあるので再表示でポップが再生される
    const starsN = Math.max(0, Math.min(3, p.stars | 0));
    const perfect = p.perfect != null ? !!p.perfect : starsN === 3;
    const cleared = perfect || (p.cleared != null ? !!p.cleared : starsN >= 1);
    if (els.resBadge) {
      els.resBadge.className = `res-badge ${perfect ? 'is-perfect' : cleared ? 'is-clear' : 'is-fail'}`;
      setText(els.resBadge, perfect ? 'パーフェクト！' : cleared ? 'クリア！' : '未クリア — もう一度');
      els.resBadge.hidden = false;
    }
    if (els.resUnlock) {
      const nx = p.unlockedNext;
      els.resUnlock.hidden = !nx;
      setText(els.resUnlock, nx ? `実験 ${nx.no} が解放されました` : '');
    }

    // 星: 一度全部消してから再付与（アニメーション再生のため）。CSS の animation-delay と同じ 0.25 秒刻みで通知
    const spans = els.resStars.querySelectorAll('span');
    spans.forEach((s) => s.classList.remove('lit'));
    void els.resStars.offsetWidth;
    const nStars = Math.max(0, Math.min(3, p.stars | 0));
    spans.forEach((s, i) => {
      if (i >= nStars) return;
      s.classList.add('lit');
      if (p.onStar) resTimers.push(setTimeout(() => p.onStar(i), i * 250));
    });
    if (nStars === 3) resTimers.push(setTimeout(startConfetti, 3 * 250));
    setStarsA11y(els.resStars, p.stars);

    // スコア: 0 → 確定値。NEW BEST バッジはカウントアップ完了時に出す
    const hasScore = p.score != null && Number.isFinite(p.score);
    els.resScore.hidden = !hasScore;
    if (hasScore) {
      const target = Math.round(p.score);
      // 読み上げは確定値だけ（カウントアップ中の数字は読ませない）
      els.resScore.setAttribute('aria-label', `スコア ${target} 点${p.isNewBest ? '、ベスト更新' : ''}`);
      setText(els.resScoreBest, p.bestScore != null && Number.isFinite(p.bestScore) ? `ベスト ${Math.round(p.bestScore)}` : '');
      els.resScoreNew.hidden = true;
      const done = () => { if (p.isNewBest) els.resScoreNew.hidden = false; if (p.onDone) p.onDone(); };
      if (reducedMotion()) { setText(els.resScoreNum, String(target)); done(); }
      else { setText(els.resScoreNum, '0'); countUp(target, p.onTick, done); }
    } else if (p.onDone) {
      p.onDone();
    }
    setText(els.resStarsCap, ['まだ観察の途中。もう一度試してみよう。', 'まずは一歩。数字の意味を確かめよう。', 'よい観察。あと少しで満点。', '完璧な観察。渋滞の本質をつかんだ。'][Math.max(0, Math.min(3, p.stars))]);
    els.resIncomplete.hidden = p.completed !== false;

    setText(els.resHeadline, p.headline || '');
    els.resNumbers.replaceChildren(...(p.numbers || []).map((n) => {
      const c = el('div', 'cell');
      const v = el('div', 'v num', n.value);
      if (n.unit) v.append(el('small', null, n.unit));
      c.append(v, el('div', 'l', n.label));
      return c;
    }));
    els.resLines.replaceChildren(...(p.lines || []).map((t) => el('li', null, t)));

    const lesson = p.lesson;
    els.resLesson.hidden = !lesson;
    if (lesson) {
      setText(els.lessonTitle, lesson.title || '');
      els.lessonBody.replaceChildren(...(lesson.body || []).map((t) => el('p', null, t)));
      els.lessonFact.hidden = !lesson.fact;
      els.lessonFact.replaceChildren(el('b', null, 'FACT'), doc.createTextNode(lesson.fact || ''));
    }
    els.resNext.replaceChildren(doc.createTextNode(p.nextLabel || '次へ'));
    const kbd = el('kbd', null, 'Enter');
    els.resNext.append(kbd);
    els.modalResult.hidden = false;
    focusPrimary(els.modalResult);
  }

  const api = {
    els, chartCanvases,
    on(name, fn) { handlers.set(name, fn); return api; },
    setLevels, setActiveLevel, setLevelStars, setUnlocked, setGoals,
    setExperiment, setSliders, setMode, flashPulse,
    setTimer, setPaused, setSpeed, setInfluence, setCar, setBrakeState,
    setHudVisible, toggleSheet, toast,
    setViewMode, getViewMode, setMuted, setScore, showOnboarding, hideOnboarding,
    hideModals, isModalOpen, pressPrimary, showTitle, showBriefing, showQuiz, showResult,
  };
  return api;
}
