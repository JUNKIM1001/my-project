// src/ui/sound.js — 効果音（Web Audio 合成のみ・外部ファイルなし）。
// AudioContext は import 時に作らず、最初のユーザー操作で unlock() が呼ばれた時に遅延生成する
// （ブラウザの自動再生制限対策）。AudioContext が無い／例外を投げる環境では全メソッドが no-op。
// ミュート状態は localStorage['jamlab.muted'] に保存（読めない環境では既定 = 非ミュート）。
// どのメソッドも例外を外へ出さない。

const STORAGE_KEY = 'jamlab.muted';
const MASTER_GAIN = 0.25; // ≈ -12 dB。カジュアルゲームらしく控えめに

/** 音名（星は C5 / E5 / G5 の長三和音） */
const NOTE = { C5: 523.25, D5: 587.33, E5: 659.25, G5: 783.99, A5: 880.0, C6: 1046.5, E6: 1318.5 };

function readMuted() {
  try { return localStorage.getItem(STORAGE_KEY) === '1'; } catch { return false; }
}
function writeMuted(v) {
  try { localStorage.setItem(STORAGE_KEY, v ? '1' : '0'); } catch { /* 保存できなくても動作は継続 */ }
}

export function createSound() {
  let muted = readMuted();
  let ctx = null;          // AudioContext（遅延生成）
  let master = null;       // マスター GainNode
  let noiseBuf = null;     // ホワイトノイズ 1 秒分（1 回だけ生成して使い回す）
  let broken = false;      // AudioContext を作れなかった → 以後すべて no-op
  let disposed = false;
  let brakeNodes = null;   // ブレーキ持続音のノード群（再生中のみ非 null）

  /** ctx を用意する。作れなければ null（例外は握りつぶす） */
  function ensureCtx() {
    if (broken || disposed) return null;
    if (ctx) return ctx;
    try {
      const AC = globalThis.AudioContext || globalThis.webkitAudioContext;
      if (!AC) { broken = true; return null; }
      ctx = new AC();
      master = ctx.createGain();
      master.gain.value = MASTER_GAIN;
      master.connect(ctx.destination);
      // ノイズバッファ（click / tick / start / brake で共用）
      noiseBuf = ctx.createBuffer(1, ctx.sampleRate, ctx.sampleRate);
      const d = noiseBuf.getChannelData(0);
      for (let i = 0; i < d.length; i++) d[i] = Math.random() * 2 - 1;
      return ctx;
    } catch {
      broken = true; ctx = null; master = null; noiseBuf = null;
      return null;
    }
  }

  /** 再生可能な ctx（running 状態）を返す。ミュート中や未 unlock なら null */
  function ready() {
    if (muted || disposed) return null;
    const c = ensureCtx();
    if (!c) return null;
    // unlock() 前にサスペンド中なら鳴らさない（ユーザー操作なしの resume は効かないため）
    if (c.state !== 'running') { try { c.resume(); } catch { /* noop */ } return null; }
    return c;
  }

  // ---------- 合成の小部品 ----------

  /** 減衰エンベロープ付きの GainNode（t0 でアタック → t0+dur で無音） */
  function envGain(c, t0, peak, dur, attack = 0.005) {
    const g = c.createGain();
    g.gain.setValueAtTime(0.0001, t0);
    g.gain.linearRampToValueAtTime(peak, t0 + attack);
    g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
    g.connect(master);
    return g;
  }

  /** 単一オシレータの音。freqTo を与えると dur かけて周波数を滑らかに移動 */
  function tone(c, t0, { type = 'sine', freq, freqTo, dur, peak = 0.5, attack = 0.005 }) {
    const o = c.createOscillator();
    o.type = type;
    o.frequency.setValueAtTime(freq, t0);
    if (freqTo) o.frequency.exponentialRampToValueAtTime(freqTo, t0 + dur);
    o.connect(envGain(c, t0, peak, dur, attack));
    o.start(t0);
    o.stop(t0 + dur + 0.02);
  }

  /** ベル風（基音 + 弱い 2 倍音、指数減衰） — star1/2/3・fanfare・newBest で共用 */
  function bell(c, t0, freq, dur = 0.4, peak = 0.45) {
    tone(c, t0, { freq, dur, peak });
    tone(c, t0, { freq: freq * 2, dur: dur * 0.7, peak: peak * 0.3 });
  }

  /** フィルタ済みノイズ。filterTo を与えるとカットオフをスイープ */
  function noise(c, t0, { type = 'bandpass', freq, freqTo, q = 1, dur, peak = 0.5, attack = 0.003 }) {
    const src = c.createBufferSource();
    src.buffer = noiseBuf;
    const f = c.createBiquadFilter();
    f.type = type;
    f.Q.value = q;
    f.frequency.setValueAtTime(freq, t0);
    if (freqTo) f.frequency.exponentialRampToValueAtTime(freqTo, t0 + dur);
    src.connect(f).connect(envGain(c, t0, peak, dur, attack));
    src.start(t0);
    src.stop(t0 + dur + 0.02);
  }

  // ---------- 単発音の定義（名前 → 合成手順） ----------
  const ONESHOT = {
    // ボタン: 紙をはじくような極小のノイズ音（0.05 s）
    click(c, t) { noise(c, t, { freq: 2400, q: 2, dur: 0.05, peak: 0.5 }); },

    // レベル開始: 低→高へ上がるウーッシュ（ノイズのカットオフ 300→4000 Hz、0.4 s）
    start(c, t) {
      noise(c, t, { freq: 300, freqTo: 4000, q: 1.2, dur: 0.4, peak: 0.6, attack: 0.08 });
    },

    // 試行 1 点記録: 柔らかい「ポン」（サイン 660→880 Hz、0.15 s）
    trial(c, t) { tone(c, t, { freq: 660, freqTo: 880, dur: 0.15, peak: 0.45 }); },

    // カウントアップ 1 刻み: 高めの極短クリック（0.03 s）。15 Hz 連打でも濁らない
    tick(c, t) { noise(c, t, { freq: 4500, q: 4, dur: 0.03, peak: 0.35, attack: 0.001 }); },

    // 星 1/2/3: 同じベル音を C5 / E5 / G5 と 1 つずつ上げる（各 0.4 s）
    star1(c, t) { bell(c, t, NOTE.C5); },
    star2(c, t) { bell(c, t, NOTE.E5); },
    star3(c, t) { bell(c, t, NOTE.G5); },

    // 3 星ファンファーレ: C5-E5-G5-C6 の素早いアルペジオ（全体 0.6 s）
    fanfare(c, t) {
      [NOTE.C5, NOTE.E5, NOTE.G5, NOTE.C6].forEach((f, i) => bell(c, t + i * 0.09, f, 0.33, 0.4));
    },

    // ベスト更新: 2 音のチャイム（A5 → E6、計 0.5 s）
    newBest(c, t) {
      bell(c, t, NOTE.A5, 0.3, 0.4);
      bell(c, t + 0.14, NOTE.E6, 0.36, 0.4);
    },

    // トースト表示: 低音量の短いブリップ（三角波 D5、0.08 s）。注意を引きすぎない
    hint(c, t) { tone(c, t, { type: 'triangle', freq: NOTE.D5, dur: 0.08, peak: 0.2 }); },
  };

  // ---------- 公開 API ----------

  /** 最初の pointerdown / keydown で呼ぶ。何度呼んでも安全 */
  function unlock() {
    try {
      const c = ensureCtx();
      if (c && c.state === 'suspended') c.resume().catch(() => {});
    } catch { /* noop */ }
  }

  /** 単発音を鳴らす。未知の名前・ミュート・未 unlock は無音で戻る */
  function play(name) {
    try {
      const fn = ONESHOT[name];
      if (!fn) return;
      const c = ready();
      if (!c) return;
      fn(c, c.currentTime);
    } catch { /* noop */ }
  }

  /**
   * ブレーキ中の持続音（開始 / 停止）。
   * バンドパスノイズ（擦れる音）+ 低いサイン（車体のうなり）を ~80 ms のアタック／リリースで包む。
   * brake(true) の連打は重ねない。鳴っていない時の brake(false) は no-op。
   */
  function brake(on) {
    try {
      if (on) {
        if (brakeNodes) return;
        const c = ready();
        if (!c) return;
        const t = c.currentTime;
        const g = c.createGain();
        g.gain.setValueAtTime(0.0001, t);
        g.gain.linearRampToValueAtTime(0.35, t + 0.08);
        g.connect(master);

        const src = c.createBufferSource();
        src.buffer = noiseBuf;
        src.loop = true;
        const f = c.createBiquadFilter();
        f.type = 'bandpass';
        f.frequency.value = 900;
        f.Q.value = 1.5;
        src.connect(f).connect(g);
        src.start(t);

        const o = c.createOscillator();
        o.type = 'sine';
        o.frequency.value = 70;
        const og = c.createGain();
        og.gain.value = 0.5;
        o.connect(og).connect(g);
        o.start(t);

        brakeNodes = { g, src, o };
      } else {
        if (!brakeNodes) return;
        const { g, src, o } = brakeNodes;
        brakeNodes = null;
        const c = ctx;
        if (!c) return;
        const t = c.currentTime;
        g.gain.cancelScheduledValues(t);
        g.gain.setValueAtTime(g.gain.value, t);
        g.gain.linearRampToValueAtTime(0.0001, t + 0.08);
        src.stop(t + 0.1);
        o.stop(t + 0.1);
        setTimeout(() => { try { g.disconnect(); } catch { /* noop */ } }, 200);
      }
    } catch { brakeNodes = null; }
  }

  function setMuted(v) {
    muted = !!v;
    writeMuted(muted);
    if (muted) brake(false); // 鳴っている持続音は止める
  }

  /** ノードを止めて AudioContext を閉じる。以後すべて no-op */
  function dispose() {
    try { brake(false); } catch { /* noop */ }
    disposed = true;
    try { if (ctx) ctx.close().catch(() => {}); } catch { /* noop */ }
    ctx = null; master = null; noiseBuf = null;
  }

  return {
    unlock,
    play,
    brake,
    setMuted,
    get muted() { return muted; },
    dispose,
  };
}
