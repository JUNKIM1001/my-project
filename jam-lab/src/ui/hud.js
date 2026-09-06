// src/ui/hud.js — HUD の DOM バインディング。
// index.html にある静的マークアップへ値を流し込むだけの薄い層。
// 毎フレームの更新は textContent の差分書き込みのみ（innerHTML の再構築はしない）。
// ゲームロジックは持たず、ユーザー操作は on(name, fn) で登録されたハンドラへ通知する。

const CAMERA_LABEL = { chase: '追従', overhead: '上空', overview: '全景', cockpit: '運転席' };
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
    btnPulse: $('btn-pulse'), manualHint: $('manual-hint'), btnRestart: $('btn-restart'), btnFinish: $('btn-finish'),
    sliders: $('sliders'),
    infAffected: $('inf-affected'), infLoss: $('inf-loss'), infWave: $('inf-wave'),
    infStopped: $('inf-stopped'), infMean: $('inf-mean'), infFlow: $('inf-flow'), flowDensity: $('flow-density'),
    carSpeedWrap: $('car-speed-wrap'), carSpeed: $('car-speed'), carGap: $('car-gap'), carGapTime: $('car-gaptime'),
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
  };

  const chartCanvases = {
    timeline: $('chart-timeline'),
    spaceTime: $('chart-spacetime'),
    minimap: $('chart-minimap'),
  };

  // ---------------------------------------------------------------
  // 静的なイベント結線（1 回だけ）
  // ---------------------------------------------------------------
  const click = (elm, name, ...args) => elm && elm.addEventListener('click', (e) => { e.currentTarget.blur(); emit(name, ...args); });
  click(els.btnPulse, 'pulse');
  click($('touch-pulse'), 'pulse');
  click(els.btnRestart, 'restart');
  click(els.btnFinish, 'finish');
  click($('btn-camera'), 'camera');
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
    input.addEventListener('input', () => { show(); if (param !== 'carCount') emit('slider', param, Number(input.value)); });
    input.addEventListener('change', () => { show(); if (param === 'carCount') emit('slider', param, Number(input.value)); input.blur(); });
  }
  for (const row of els.sliders.querySelectorAll('.check')) {
    const input = row.querySelector('input');
    input.addEventListener('change', () => { emit('toggle', row.dataset.toggle, input.checked); input.blur(); });
  }

  // タッチ長押し（アクセル / ブレーキ）
  const bindHold = (id, which) => {
    const b = $(id);
    if (!b) return;
    const down = (e) => { e.preventDefault(); emit('hold', which, true); };
    const up = () => emit('hold', which, false);
    b.addEventListener('pointerdown', down);
    b.addEventListener('pointerup', up);
    b.addEventListener('pointercancel', up);
    b.addEventListener('pointerleave', up);
    b.addEventListener('contextmenu', (e) => e.preventDefault());
  };
  bindHold('touch-throttle', 'throttle');
  bindHold('touch-brake', 'brake');

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
  function setLevels(levels, progress = {}) {
    els.tabs.replaceChildren();
    tabById.clear();
    for (const lv of levels) {
      const b = el('button', 'tab');
      b.type = 'button';
      b.dataset.id = lv.id;
      b.title = lv.title;
      b.append(doc.createTextNode(lv.no));
      const st = el('span', 'tab-stars');
      b.append(st);
      b.addEventListener('click', () => { b.blur(); emit('selectLevel', lv.id); });
      els.tabs.append(b);
      tabById.set(lv.id, { b, st });
      if (progress[lv.id] != null) setLevelStars(lv.id, progress[lv.id]);
    }
  }
  function setActiveLevel(id) {
    for (const [lid, t] of tabById) t.b.classList.toggle('is-active', lid === id);
  }
  function setLevelStars(id, stars) {
    const t = tabById.get(id);
    if (!t) return;
    setText(t.st, stars == null ? '' : starsText(stars));
    setStarsA11y(t.st, stars);
  }

  // ---------------------------------------------------------------
  // 左パネル（実験）
  // ---------------------------------------------------------------
  function setExperiment(level, { free = false, mode = 'auto' } = {}) {
    setText(els.expNo, level.no);
    setText(els.expTitle, level.title);
    setText(els.expQuestion, level.question || '');
    setText(els.expHowto, level.howTo || '');
    els.btnPulse.hidden = !(mode === 'auto' || free);
    els.manualHint.hidden = mode !== 'manual';
    els.btnFinish.hidden = free;
    setMode(mode);
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
  }

  /** 操作モードに応じてタッチボタンの種類を切替 */
  function setMode(mode) {
    hud.classList.toggle('mode-manual', mode === 'manual');
    hud.classList.toggle('mode-auto', mode !== 'manual');
  }

  function flashPulse() {
    els.btnPulse.classList.remove('is-flash');
    // reflow を挟んでアニメーションを再開
    void els.btnPulse.offsetWidth;
    els.btnPulse.classList.add('is-flash');
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
    els.modalTitle.hidden = true;
    els.modalBriefing.hidden = true;
    els.modalResult.hidden = true;
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

  function showTitle(levels = [], progress = {}) {
    hideModals();
    els.titleProgress.replaceChildren();
    for (const lv of levels) {
      if (progress[lv.id] == null) continue;
      const s = el('span', null, lv.no);
      const b = el('b', null, starsText(progress[lv.id]));
      setStarsA11y(b, progress[lv.id]);
      s.append(b);
      els.titleProgress.append(s);
    }
    els.modalTitle.hidden = false;
    focusPrimary(els.modalTitle);
  }

  function showBriefing(level, meta = '') {
    hideModals();
    setText(els.briefNo, level.no);
    setText(els.briefTitle, level.title);
    setText(els.briefQuestion, level.question || '');
    els.briefBullets.replaceChildren(...(level.briefing || []).map((t) => el('li', null, t)));
    setText(els.briefHowto, level.howTo || '');
    const goals = level.goals || [];
    els.briefGoalsBox.hidden = goals.length === 0;
    els.briefGoals.replaceChildren(...goals.map((t) => el('li', null, t)));
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
   * payload = { level, stars, headline, numbers: [{label, value, unit}], lines, lesson, completed, nextLabel }
   */
  function showResult(p) {
    hideModals();
    setText(els.resNo, p.level.no);
    setText(els.resTitle, p.level.title);
    els.resQuiz.hidden = true;
    els.resBody.hidden = false;

    // 星: 一度全部消してから再付与（アニメーション再生のため）
    const spans = els.resStars.querySelectorAll('span');
    spans.forEach((s) => s.classList.remove('lit'));
    void els.resStars.offsetWidth;
    spans.forEach((s, i) => { if (i < p.stars) s.classList.add('lit'); });
    setStarsA11y(els.resStars, p.stars);
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
    setLevels, setActiveLevel, setLevelStars,
    setExperiment, setSliders, setMode, flashPulse,
    setTimer, setPaused, setSpeed, setInfluence, setCar,
    setHudVisible, toggleSheet, toast,
    hideModals, isModalOpen, pressPrimary, showTitle, showBriefing, showQuiz, showResult,
  };
  return api;
}
