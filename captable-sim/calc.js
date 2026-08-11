// captable-sim 計算ロジック（純粋関数のみ・DOM非依存）
// 金額の単位はすべて「百万円」。比率は 0〜1 の小数で扱う。

const RATIO_SUM_TOLERANCE = 0.0005; // 持分合計の許容誤差（±0.05%）
const FLAT_EPS = 1e-9;

// 1ラウンドあたりの希薄化率の一般的レンジ（実務慣行の目安: 10〜25%）
export const TYPICAL_DILUTION_RANGE = { low: 0.1, high: 0.25 };

/**
 * 入力欄の数値文字列をパースする（全角数字・全角小数点・全角マイナス・全角カンマを半角化、前後の空白のみ除去）。
 * カンマは3桁区切りの位置にある場合のみ受理する（"1,000" は可、"12,34" や "1,,000" は不可）。
 * 指数表記(1e3)・16進(0x10)・Infinity・内部空白などの紛らわしい表記は受け付けない。
 * 空文字は null（未入力）、解釈できない文字列は NaN を返す。
 */
export function parseNumeric(raw) {
  let s = String(raw)
    .replace(/[０-９．－，]/g, (c) =>
      c === "．" ? "." : c === "－" ? "-" : c === "，" ? "," : String.fromCharCode(c.charCodeAt(0) - 0xfee0)
    )
    .trim();
  if (s === "") return null;
  if (s.includes(",")) {
    if (!/^[+-]?\d{1,3}(,\d{3})+(\.\d+)?$/.test(s)) return NaN;
    s = s.replace(/,/g, "");
  } else if (!/^[+-]?(\d+\.?\d*|\.\d+)$/.test(s)) {
    return NaN;
  }
  return Number(s);
}

/**
 * 実務上まれな入力への注意喚起（計算は止めない）。
 * 戻り値: 警告メッセージの配列（なければ空配列）。
 */
export function practicalWarnings(input) {
  const warnings = [];
  if (
    input.mode === "ratio" &&
    typeof input.targetOwnRatio === "number" &&
    input.targetOwnRatio > 0.5
  ) {
    warnings.push(
      "目標取得割合が 50% を超えています。マイノリティ出資の範囲を超えるため、入力値をご確認ください。"
    );
  }
  if (typeof input.poolRatio === "number" && input.poolRatio > 0.3) {
    warnings.push(
      "オプションプールが 30% を超えています。一般的な水準（10〜20%程度）を大きく上回るため、入力値をご確認ください。"
    );
  }
  return warnings;
}

/**
 * 入力を検証し、エラーメッセージの配列を返す（空配列なら妥当）。
 * input = {
 *   preMoney,          // 今回ラウンドのプレマネー評価額（百万円, >0）
 *   prevPostMoney,     // 前回ラウンドのポストマネー評価額（百万円, >0）省略可: null
 *   mode,              // 'amount'（出資額を入力）| 'ratio'（目標取得割合を入力）
 *   ownInvestment,     // 自社出資額（百万円, >=0）mode='amount' のとき必須
 *   targetOwnRatio,    // 目標取得割合（ポスト基準, 0<t<1）mode='ratio' のとき必須
 *   otherInvestment,   // 他投資家の出資額（百万円, >=0）
 *   poolRatio,         // 今回設定するオプションプール（ポスト基準, 0<=p<1）
 *   existingShares,    // 発行済株式数（完全希薄化ベース, >0）省略可: null
 *   holders,           // [{name, ratio}] 既存株主の持分（合計 1）
 *   // ▼ バリュエーション妥当性チェック用（すべて省略可: null）
 *   revenue,           // 直近売上高（百万円, >0）
 *   monthsSinceLastRound, // 前回ラウンドからの経過月数（>0）
 *   refMultipleLow,    // 参考売上マルチプル下限（倍, >0）
 *   refMultipleHigh,   // 参考売上マルチプル上限（倍, >0, 下限以上）
 *   // ▼ Exit分析（VC法）用（すべて省略可: null）
 *   exitYears,         // Exitまでの想定年数（>0）
 *   exitRevenue,       // Exit想定年度の売上計画（百万円, >0）
 *   exitMultipleLow,   // Exitマルチプル下限（倍, >0）＝保守シナリオ
 *   exitMultipleHigh,  // Exitマルチプル上限（倍, >0, 下限以上）＝強気シナリオ
 *   futureDilution,    // 今後のラウンドで見込む追加希薄化（0<=d<1）未入力は 0 扱い
 *   targetMultiple,    // 目標リターン倍率（グロス MOIC, >1）
 * }
 */
export function validateInput(input) {
  const errors = [];
  const isNum = (v) => typeof v === "number" && Number.isFinite(v);

  if (!isNum(input.preMoney) || input.preMoney <= 0) {
    errors.push("今回ラウンドのプレマネー評価額は正の数値で入力してください。");
  }
  if (input.prevPostMoney != null) {
    if (!isNum(input.prevPostMoney) || input.prevPostMoney <= 0) {
      errors.push("前回ラウンドのポストマネー評価額は正の数値で入力してください（未入力も可）。");
    }
  }
  if (input.mode !== "amount" && input.mode !== "ratio") {
    errors.push("入力モードが不正です。");
  }
  if (input.mode === "amount") {
    if (!isNum(input.ownInvestment) || input.ownInvestment < 0) {
      errors.push("自社出資額は 0 以上の数値で入力してください。");
    }
  }
  if (input.mode === "ratio") {
    if (!isNum(input.targetOwnRatio) || input.targetOwnRatio <= 0 || input.targetOwnRatio >= 1) {
      errors.push("目標取得割合は 0% より大きく 100% 未満で入力してください。");
    }
  }
  if (!isNum(input.otherInvestment) || input.otherInvestment < 0) {
    errors.push("他投資家の出資額は 0 以上の数値で入力してください。");
  }
  if (!isNum(input.poolRatio) || input.poolRatio < 0 || input.poolRatio >= 1) {
    errors.push("オプションプールは 0% 以上 100% 未満で入力してください。");
  }
  if (input.existingShares != null) {
    if (!isNum(input.existingShares) || input.existingShares <= 0) {
      errors.push("発行済株式数は正の数値で入力してください（未入力も可）。");
    }
  }

  if (input.revenue != null && (!isNum(input.revenue) || input.revenue <= 0)) {
    errors.push("直近売上高は正の数値で入力してください（未入力も可）。");
  }
  if (
    input.monthsSinceLastRound != null &&
    (!isNum(input.monthsSinceLastRound) || input.monthsSinceLastRound <= 0)
  ) {
    errors.push("前回ラウンドからの経過月数は正の数値で入力してください（未入力も可）。");
  }
  const refLow = input.refMultipleLow;
  const refHigh = input.refMultipleHigh;
  if (refLow != null && (!isNum(refLow) || refLow <= 0)) {
    errors.push("参考マルチプル下限は正の数値で入力してください（未入力も可）。");
  }
  if (refHigh != null && (!isNum(refHigh) || refHigh <= 0)) {
    errors.push("参考マルチプル上限は正の数値で入力してください（未入力も可）。");
  }
  if (
    isNum(refLow) && refLow > 0 &&
    isNum(refHigh) && refHigh > 0 &&
    refLow > refHigh
  ) {
    errors.push("参考マルチプルは下限 ≤ 上限で入力してください。");
  }

  if (input.exitYears != null && (!isNum(input.exitYears) || input.exitYears <= 0)) {
    errors.push("Exitまでの想定年数は正の数値で入力してください（未入力も可）。");
  }
  if (input.exitRevenue != null && (!isNum(input.exitRevenue) || input.exitRevenue <= 0)) {
    errors.push("Exit想定年度の売上計画は正の数値で入力してください（未入力も可）。");
  }
  const exLow = input.exitMultipleLow;
  const exHigh = input.exitMultipleHigh;
  if (exLow != null && (!isNum(exLow) || exLow <= 0)) {
    errors.push("Exitマルチプル下限は正の数値で入力してください（未入力も可）。");
  }
  if (exHigh != null && (!isNum(exHigh) || exHigh <= 0)) {
    errors.push("Exitマルチプル上限は正の数値で入力してください（未入力も可）。");
  }
  if (isNum(exLow) && exLow > 0 && isNum(exHigh) && exHigh > 0 && exLow > exHigh) {
    errors.push("Exitマルチプルは下限 ≤ 上限で入力してください。");
  }
  if (
    input.futureDilution != null &&
    (!isNum(input.futureDilution) || input.futureDilution < 0 || input.futureDilution >= 1)
  ) {
    errors.push("将来の追加希薄化は 0% 以上 100% 未満で入力してください（未入力も可）。");
  }
  if (
    input.targetMultiple != null &&
    (!isNum(input.targetMultiple) || input.targetMultiple <= 1)
  ) {
    errors.push("目標リターン倍率は 1 倍より大きい数値で入力してください（未入力も可）。");
  }

  if (!Array.isArray(input.holders) || input.holders.length === 0) {
    errors.push("既存株主を1件以上入力してください。");
  } else {
    let sum = 0;
    for (const h of input.holders) {
      if (!isNum(h.ratio) || h.ratio < 0) {
        errors.push(`株主「${h.name || "(名称未入力)"}」の持分は 0 以上の数値で入力してください。`);
      } else {
        sum += h.ratio;
      }
    }
    if (Math.abs(sum - 1) > RATIO_SUM_TOLERANCE) {
      errors.push(`既存株主の持分合計が 100% になっていません（現在 ${(sum * 100).toFixed(2)}%）。`);
    }
  }

  return errors;
}

/**
 * 資本政策シミュレーション本体。
 * 戻り値: { ok: true, ...結果 } または { ok: false, errors: [...] }
 *
 * モデル:
 * - ポストマネー = プレマネー + 出資総額
 * - 新規投資家の持分 = 出資額 / ポストマネー
 * - オプションプールは「ポストマネー基準の割合」で今回ラウンド前に設定され、既存株主のみを希薄化する
 *   （新規投資家の持分は出資額/ポストで固定。一般的なタームシート実務に合わせる）
 * - 既存株主の希薄化後持分 = 従前持分 × (1 − 新規投資家合計% − プール%)
 */
export function computeRound(input) {
  const errors = validateInput(input);
  if (errors.length > 0) return { ok: false, errors };

  const pre = input.preMoney;
  const iOth = input.otherInvestment;
  const pool = input.poolRatio;

  let iOwn;
  if (input.mode === "amount") {
    iOwn = input.ownInvestment;
  } else {
    // 目標取得割合 t（ポスト基準）から必要出資額を逆算:
    // t = iOwn / (pre + iOth + iOwn) → iOwn = t (pre + iOth) / (1 − t)
    const t = input.targetOwnRatio;
    iOwn = (t * (pre + iOth)) / (1 - t);
  }

  const totalInv = iOwn + iOth;
  const post = pre + totalInv;
  const ownRatio = post > 0 ? iOwn / post : 0;
  const otherRatio = post > 0 ? iOth / post : 0;

  const existingFactor = 1 - ownRatio - otherRatio - pool;
  if (existingFactor <= 0) {
    return {
      ok: false,
      errors: [
        `新規投資家の合計持分（${((ownRatio + otherRatio) * 100).toFixed(1)}%）とオプションプール（${(pool * 100).toFixed(1)}%）の合計が 100% 以上になり、既存株主の持分が残りません。条件を見直してください。`,
      ],
    };
  }

  const holders = input.holders.map((h) => ({
    name: h.name,
    before: h.ratio,
    after: h.ratio * existingFactor,
  }));

  // 前回ラウンド比較（今回プレマネー vs 前回ポストマネー）
  let priceMultiple = null;
  let roundType = null;
  if (input.prevPostMoney != null) {
    priceMultiple = pre / input.prevPostMoney;
    if (Math.abs(priceMultiple - 1) < FLAT_EPS) roundType = "flat";
    else roundType = priceMultiple > 1 ? "up" : "down";
  }

  // 株式数モデル（発行済株式数が入力されたときのみ）
  // プール株 P はプレマネーで発行: 株価 p = (pre − pool × post) / S
  // pre − pool×post = existingFactor × post であり、上の existingFactor > 0 チェックにより常に正。
  // 新株 N = 出資額 / p。端数は表示側で丸める（実務の端数調整は別途）。
  let shares = null;
  if (input.existingShares != null) {
    const S = input.existingShares;
    const price = (pre - pool * post) / S; // 百万円/株
    const ownNewShares = iOwn / price;
    const otherNewShares = iOth / price;
    const poolShares = (pool * post) / price;
    shares = {
      pricePerShare: price,
      existingShares: S,
      ownNewShares,
      otherNewShares,
      poolShares,
      totalPostShares: S + ownNewShares + otherNewShares + poolShares,
    };
  }

  return {
    ok: true,
    preMoney: pre,
    postMoney: post,
    ownInvestment: iOwn,
    otherInvestment: iOth,
    totalInvestment: totalInv,
    ownRatio,
    otherRatio,
    poolRatio: pool,
    existingFactor,
    existingDilution: 1 - existingFactor,
    holders,
    priceMultiple,
    roundType,
    shares,
  };
}

/**
 * バリュエーション妥当性の参考指標。
 * 妥当性の「判断」はせず、判断材料になる指標だけを機械的に計算する。
 * 戻り値: null（入力が不正で計算不能）または
 * {
 *   revenueMultiple,   // 今回プレマネー ÷ 売上高（売上高未入力なら null）
 *   impliedPreRange,   // 参考マルチプル×売上高から逆算したプレマネーレンジと現在値の位置
 *                      //   { low, high, verdict: 'below'|'within'|'above' } | null
 *   annualizedGrowth,  // 前回ポスト→今回プレの評価額成長率の年率換算（月数未入力なら null）
 *   dilutionVerdict,   // 既存株主の希薄化率の一般的レンジ（10〜25%）に対する位置
 *                      //   'low'|'typical'|'high'
 *   existingDilution,  // 参考: 希薄化率そのもの
 * }
 */
export function valuationDiagnostics(input) {
  const r = computeRound(input);
  if (!r.ok) return null;

  const pre = input.preMoney;

  const revenueMultiple =
    input.revenue != null ? pre / input.revenue : null;

  let impliedPreRange = null;
  if (
    input.revenue != null &&
    input.refMultipleLow != null &&
    input.refMultipleHigh != null
  ) {
    const low = input.revenue * input.refMultipleLow;
    const high = input.revenue * input.refMultipleHigh;
    const verdict = pre < low ? "below" : pre > high ? "above" : "within";
    impliedPreRange = { low, high, verdict };
  }

  let annualizedGrowth = null;
  if (input.prevPostMoney != null && input.monthsSinceLastRound != null) {
    // (今回プレ ÷ 前回ポスト)^(12/経過月数) − 1
    annualizedGrowth =
      Math.pow(pre / input.prevPostMoney, 12 / input.monthsSinceLastRound) - 1;
  }

  // 境界値（ちょうど10%/25%）が浮動小数点誤差でレンジ外に落ちないよう許容誤差を持たせる
  const d = r.existingDilution;
  const eps = 1e-9;
  const dilutionVerdict =
    d < TYPICAL_DILUTION_RANGE.low - eps
      ? "low"
      : d > TYPICAL_DILUTION_RANGE.high + eps
        ? "high"
        : "typical";

  return {
    revenueMultiple,
    impliedPreRange,
    annualizedGrowth,
    dilutionVerdict,
    existingDilution: d,
  };
}

/**
 * Exitマルチプル起点のバリュエーション妥当性評価（VC法 / ターゲット倍率法）。
 *
 * モデル:
 * - Exit時企業価値 E = Exit想定売上 × Exitマルチプル（下限=保守 / 上限=強気の2シナリオ）
 * - 将来ラウンドの追加希薄化後の残存率 ret = 1 − futureDilution
 * - 自社持分のExit時価値 = E × 今回取得割合 × ret
 * - MOIC = E × ret ÷ 今回ポストマネー（出資額に依存しない点がこの式の要）
 * - IRR = MOIC^(1/年数) − 1
 * - 目標倍率 M を満たす妥当ポストマネー上限 = E × ret ÷ M
 * - 今回ポストで目標達成に必要なExit企業価値 = ポスト × M ÷ ret（必要マルチプル = それ ÷ Exit売上）
 *
 * 必須: exitYears, exitRevenue, exitMultipleLow/High, targetMultiple（いずれか欠けると null）
 * futureDilution は未入力（null）なら 0 扱い。
 * 戻り値: null または {
 *   retention, exitYears, targetMultiple,
 *   scenarios: [{ label: 'conservative'|'aggressive', multiple, exitValue, ownExitValue, moic, irr }],
 *   fairPostRange: { low, high },   // 目標倍率を満たすポストマネー上限（保守〜強気）
 *   currentPost,
 *   verdict: 'below' | 'within' | 'above',  // below=保守でも目標達成 / within=強気なら達成 / above=強気でも未達
 *   requiredExitValue, requiredExitMultiple,
 * }
 */
export function exitAnalysis(input) {
  const r = computeRound(input);
  if (!r.ok) return null;
  if (
    input.exitYears == null ||
    input.exitRevenue == null ||
    input.exitMultipleLow == null ||
    input.exitMultipleHigh == null ||
    input.targetMultiple == null
  ) {
    return null;
  }

  const retention = 1 - (input.futureDilution ?? 0);
  const n = input.exitYears;
  const M = input.targetMultiple;
  const post = r.postMoney;

  const scenario = (label, multiple) => {
    const exitValue = input.exitRevenue * multiple;
    const moic = (exitValue * retention) / post;
    return {
      label,
      multiple,
      exitValue,
      ownExitValue: exitValue * retention * r.ownRatio,
      moic,
      irr: Math.pow(moic, 1 / n) - 1,
    };
  };
  const scenarios = [
    scenario("conservative", input.exitMultipleLow),
    scenario("aggressive", input.exitMultipleHigh),
  ];

  const fairPostRange = {
    low: (scenarios[0].exitValue * retention) / M,
    high: (scenarios[1].exitValue * retention) / M,
  };
  const verdict =
    post <= fairPostRange.low ? "below" : post <= fairPostRange.high ? "within" : "above";

  const requiredExitValue = (post * M) / retention;

  return {
    retention,
    exitYears: n,
    targetMultiple: M,
    scenarios,
    fairPostRange,
    currentPost: post,
    verdict,
    requiredExitValue,
    requiredExitMultiple: requiredExitValue / input.exitRevenue,
  };
}

/**
 * プレマネー評価額の感応度分析（バリュエーション交渉の材料）。
 * プレマネーに multipliers を掛けた各ケースで再計算する。
 * mode はそのまま維持する（出資額モード→取得割合が動く / 目標割合モード→必要出資額が動く）。
 * 戻り値: [{ multiplier, preMoney, postMoney, ownInvestment, ownRatio }]
 */
export function preMoneySensitivity(input, multipliers) {
  const rows = [];
  for (const m of multipliers) {
    const r = computeRound({ ...input, preMoney: input.preMoney * m });
    if (r.ok) {
      rows.push({
        multiplier: m,
        preMoney: r.preMoney,
        postMoney: r.postMoney,
        ownInvestment: r.ownInvestment,
        ownRatio: r.ownRatio,
      });
    }
  }
  return rows;
}

/**
 * 出資額の感応度分析。
 * base の自社出資額に multipliers を掛けた各ケースで取得割合を再計算する。
 * 戻り値: [{ multiplier, ownInvestment, ownRatio, postMoney, existingFactor }]
 * （計算不能なケースは除外される）
 */
export function sensitivityTable(input, multipliers) {
  const base = computeRound(input);
  if (!base.ok) return [];

  const rows = [];
  for (const m of multipliers) {
    const r = computeRound({
      ...input,
      mode: "amount",
      ownInvestment: base.ownInvestment * m,
      targetOwnRatio: null,
    });
    if (r.ok) {
      rows.push({
        multiplier: m,
        ownInvestment: r.ownInvestment,
        ownRatio: r.ownRatio,
        postMoney: r.postMoney,
        existingFactor: r.existingFactor,
      });
    }
  }
  return rows;
}
