// captable-sim 計算ロジックの単体テスト
// 実行: node --test captable-sim/
import { test } from "node:test";
import assert from "node:assert/strict";
import {
  validateInput,
  computeRound,
  sensitivityTable,
  valuationDiagnostics,
  preMoneySensitivity,
  parseNumeric,
  practicalWarnings,
} from "./calc.js";

const HOLDERS = [
  { name: "経営陣", ratio: 0.6 },
  { name: "既存VC A", ratio: 0.25 },
  { name: "既存VC B", ratio: 0.15 },
];

function baseInput(overrides = {}) {
  return {
    preMoney: 900,
    prevPostMoney: 500,
    mode: "amount",
    ownInvestment: 100,
    targetOwnRatio: null,
    otherInvestment: 0,
    poolRatio: 0,
    existingShares: null,
    holders: HOLDERS,
    revenue: null,
    monthsSinceLastRound: null,
    refMultipleLow: null,
    refMultipleHigh: null,
    ...overrides,
  };
}

const approx = (a, b, eps = 1e-9) =>
  assert.ok(Math.abs(a - b) < eps, `expected ${a} ≈ ${b}`);

test("基本ケース: pre 900 + 出資100 → post 1000, 取得10%", () => {
  const r = computeRound(baseInput());
  assert.equal(r.ok, true);
  approx(r.postMoney, 1000);
  approx(r.ownRatio, 0.1);
  approx(r.existingFactor, 0.9);
  approx(r.holders[0].after, 0.54); // 経営陣 60% → 54%
  approx(r.holders[1].after, 0.225);
  approx(r.holders[2].after, 0.135);
  approx(r.existingDilution, 0.1);
});

test("目標取得割合モード: 10%狙い → 必要出資額100", () => {
  const r = computeRound(
    baseInput({ mode: "ratio", ownInvestment: null, targetOwnRatio: 0.1 })
  );
  assert.equal(r.ok, true);
  approx(r.ownInvestment, 100);
  approx(r.postMoney, 1000);
  approx(r.ownRatio, 0.1);
});

test("目標取得割合モード + 他投資家あり", () => {
  // pre 800, 他100, 目標10% → iOwn = 0.1×900/0.9 = 100, post 1000
  const r = computeRound(
    baseInput({
      preMoney: 800,
      mode: "ratio",
      ownInvestment: null,
      targetOwnRatio: 0.1,
      otherInvestment: 100,
    })
  );
  assert.equal(r.ok, true);
  approx(r.ownInvestment, 100);
  approx(r.postMoney, 1000);
  approx(r.ownRatio, 0.1);
  approx(r.otherRatio, 0.1);
  approx(r.existingFactor, 0.8);
});

test("オプションプール10%（ポスト基準）は既存株主のみを希薄化する", () => {
  const r = computeRound(baseInput({ poolRatio: 0.1 }));
  assert.equal(r.ok, true);
  approx(r.ownRatio, 0.1); // 新規投資家の持分は変わらない
  approx(r.existingFactor, 0.8);
  approx(r.holders[0].after, 0.48); // 60% × 0.8
});

test("株価倍率: アップラウンド判定（pre 900 vs 前回post 500 → 1.8x）", () => {
  const r = computeRound(baseInput());
  approx(r.priceMultiple, 1.8);
  assert.equal(r.roundType, "up");
});

test("株価倍率: ダウンラウンド / フラット判定", () => {
  const down = computeRound(baseInput({ prevPostMoney: 1200 }));
  assert.equal(down.roundType, "down");
  const flat = computeRound(baseInput({ prevPostMoney: 900 }));
  assert.equal(flat.roundType, "flat");
});

test("前回ラウンド未入力なら倍率は null", () => {
  const r = computeRound(baseInput({ prevPostMoney: null }));
  assert.equal(r.priceMultiple, null);
  assert.equal(r.roundType, null);
});

test("株式数モデル: プールなし", () => {
  const r = computeRound(baseInput({ existingShares: 10000 }));
  assert.equal(r.ok, true);
  approx(r.shares.pricePerShare, 0.09); // 900/10000 百万円 = 9万円/株
  approx(r.shares.ownNewShares, 100 / 0.09);
  approx(r.shares.totalPostShares, 10000 + 100 / 0.09);
  // 株数ベースの持分が金額ベースと一致すること
  approx(r.shares.ownNewShares / r.shares.totalPostShares, r.ownRatio);
});

test("株式数モデル: プールあり（p = (pre − pool×post)/S）", () => {
  const r = computeRound(baseInput({ existingShares: 10000, poolRatio: 0.1 }));
  assert.equal(r.ok, true);
  approx(r.shares.pricePerShare, 0.08); // (900 − 0.1×1000)/10000
  approx(r.shares.poolShares / r.shares.totalPostShares, 0.1);
  approx(r.shares.ownNewShares / r.shares.totalPostShares, r.ownRatio);
  approx(
    (r.shares.existingShares / r.shares.totalPostShares) * HOLDERS[0].ratio,
    r.holders[0].after
  );
});

test("バリデーション: 持分合計が100%でないとエラー", () => {
  const errors = validateInput(
    baseInput({ holders: [{ name: "A", ratio: 0.5 }, { name: "B", ratio: 0.3 }] })
  );
  assert.ok(errors.some((e) => e.includes("100%")));
});

test("バリデーション: 負値・ゼロ・不正モードを拒否", () => {
  assert.ok(validateInput(baseInput({ preMoney: 0 })).length > 0);
  assert.ok(validateInput(baseInput({ ownInvestment: -1 })).length > 0);
  assert.ok(validateInput(baseInput({ otherInvestment: -5 })).length > 0);
  assert.ok(validateInput(baseInput({ poolRatio: 1 })).length > 0);
  assert.ok(validateInput(baseInput({ mode: "x" })).length > 0);
  assert.ok(
    validateInput(
      baseInput({ mode: "ratio", ownInvestment: null, targetOwnRatio: 1 })
    ).length > 0
  );
  assert.ok(validateInput(baseInput({ existingShares: 0 })).length > 0);
  assert.ok(validateInput(baseInput({ prevPostMoney: -100 })).length > 0);
});

test("既存持分が残らない条件はエラーを返す", () => {
  // 出資が巨大 + プールで existingFactor ≤ 0
  const r = computeRound(
    baseInput({ ownInvestment: 100000, poolRatio: 0.5 })
  );
  assert.equal(r.ok, false);
  assert.ok(r.errors[0].includes("100% 以上"));
});

test("プール過大（pre − pool×post = 0）も existingFactor チェックで捕捉される", () => {
  // pre 900, inv 9100 → post 10000, pool 0.09 → existingFactor = 0
  const r = computeRound(
    baseInput({ ownInvestment: 9100, poolRatio: 0.09, existingShares: 1000 })
  );
  assert.equal(r.ok, false);
  assert.ok(r.errors[0].includes("100% 以上"));
});

test("感応度分析: 出資額に倍率を掛けたケースを返す", () => {
  const rows = sensitivityTable(baseInput(), [0.5, 1, 1.5]);
  assert.equal(rows.length, 3);
  approx(rows[0].ownInvestment, 50);
  approx(rows[0].ownRatio, 50 / 950);
  approx(rows[1].ownRatio, 0.1);
  approx(rows[2].ownInvestment, 150);
  approx(rows[2].ownRatio, 150 / 1050);
});

test("感応度分析: 目標割合モードでも逆算出資額を基準に動く", () => {
  const rows = sensitivityTable(
    baseInput({ mode: "ratio", ownInvestment: null, targetOwnRatio: 0.1 }),
    [1, 2]
  );
  approx(rows[0].ownInvestment, 100);
  approx(rows[1].ownInvestment, 200);
});

test("不正入力なら感応度分析は空配列", () => {
  const rows = sensitivityTable(baseInput({ preMoney: -1 }), [1]);
  assert.deepEqual(rows, []);
});

// ---------- バリュエーション妥当性チェック ----------

test("妥当性: 売上マルチプルと逆算プレマネーレンジ（レンジ内）", () => {
  const d = valuationDiagnostics(
    baseInput({ revenue: 300, refMultipleLow: 2, refMultipleHigh: 4 })
  );
  approx(d.revenueMultiple, 3); // 900 / 300
  approx(d.impliedPreRange.low, 600);
  approx(d.impliedPreRange.high, 1200);
  assert.equal(d.impliedPreRange.verdict, "within");
});

test("妥当性: レンジ上抜け / 下抜けの判定", () => {
  const above = valuationDiagnostics(
    baseInput({ revenue: 100, refMultipleLow: 2, refMultipleHigh: 4 })
  );
  assert.equal(above.impliedPreRange.verdict, "above"); // pre 900 > 400
  const below = valuationDiagnostics(
    baseInput({ revenue: 1000, refMultipleLow: 2, refMultipleHigh: 4 })
  );
  assert.equal(below.impliedPreRange.verdict, "below"); // pre 900 < 2000
});

test("妥当性: 評価額成長率の年率換算", () => {
  const d12 = valuationDiagnostics(baseInput({ monthsSinceLastRound: 12 }));
  approx(d12.annualizedGrowth, 0.8); // 1.8x / 12ヶ月
  const d24 = valuationDiagnostics(baseInput({ monthsSinceLastRound: 24 }));
  approx(d24.annualizedGrowth, Math.sqrt(1.8) - 1);
});

test("妥当性: 希薄化率のレンジ判定（低め/レンジ内/高め）", () => {
  // own 50, other 0 → 希薄化 50/950 ≈ 5.3% → low
  assert.equal(
    valuationDiagnostics(baseInput({ ownInvestment: 50, otherInvestment: 0 }))
      .dilutionVerdict,
    "low"
  );
  // own 100, other 100 → 希薄化 200/1100 ≈ 18.2% → typical
  assert.equal(
    valuationDiagnostics(baseInput({ otherInvestment: 100 })).dilutionVerdict,
    "typical"
  );
  // own 300, other 100 → 希薄化 400/1300 ≈ 30.8% → high
  assert.equal(
    valuationDiagnostics(baseInput({ ownInvestment: 300, otherInvestment: 100 }))
      .dilutionVerdict,
    "high"
  );
});

test("妥当性: 任意項目未入力なら該当指標は null / 前提が不正なら全体 null", () => {
  const d = valuationDiagnostics(baseInput());
  assert.equal(d.revenueMultiple, null);
  assert.equal(d.impliedPreRange, null);
  assert.equal(d.annualizedGrowth, null);
  assert.equal(d.dilutionVerdict, "typical"); // 100/1000 = 10% は境界値 → レンジ内扱い
  assert.equal(valuationDiagnostics(baseInput({ preMoney: -1 })), null);
});

test("妥当性: 参考マルチプルは片方だけの入力ではレンジ判定しない", () => {
  const d = valuationDiagnostics(baseInput({ revenue: 300, refMultipleLow: 2 }));
  approx(d.revenueMultiple, 3);
  assert.equal(d.impliedPreRange, null);
});

test("妥当性バリデーション: 不正値と下限>上限を拒否", () => {
  assert.ok(validateInput(baseInput({ revenue: 0 })).length > 0);
  assert.ok(validateInput(baseInput({ monthsSinceLastRound: -3 })).length > 0);
  assert.ok(
    validateInput(baseInput({ refMultipleLow: 5, refMultipleHigh: 2 })).length > 0
  );
});

test("プレマネー感応度: 出資額モードでは取得割合が動く", () => {
  const rows = preMoneySensitivity(baseInput(), [0.8, 1, 1.2]);
  assert.equal(rows.length, 3);
  approx(rows[0].preMoney, 720);
  approx(rows[0].ownRatio, 100 / 820);
  approx(rows[1].ownRatio, 0.1);
  approx(rows[2].ownRatio, 100 / 1180);
  approx(rows[0].ownInvestment, 100); // 出資額は固定
});

// ---------- 数値パーサ（レビュー指摘 P1 対応） ----------

test("parseNumeric: 通常表記・カンマ・全角を受理する", () => {
  assert.equal(parseNumeric("1,000"), 1000);
  assert.equal(parseNumeric("1,234,567.89"), 1234567.89);
  assert.equal(parseNumeric("１２．５"), 12.5);
  assert.equal(parseNumeric("１2．5"), 12.5); // 全角半角混在
  assert.equal(parseNumeric("１，０００"), 1000);
  assert.equal(parseNumeric("－5"), -5);
  assert.equal(parseNumeric("-5"), -5);
  assert.equal(parseNumeric(".5"), 0.5);
  assert.equal(parseNumeric("+3"), 3);
  assert.equal(parseNumeric("007"), 7); // 先頭ゼロは受理
  assert.equal(parseNumeric(" 42 "), 42);
  assert.equal(parseNumeric(""), null);
  assert.equal(parseNumeric("  "), null);
});

test("parseNumeric: 指数・16進・Infinity 等の紛らわしい表記は NaN", () => {
  assert.ok(Number.isNaN(parseNumeric("1e3")));
  assert.ok(Number.isNaN(parseNumeric("0x10")));
  assert.ok(Number.isNaN(parseNumeric("Infinity")));
  assert.ok(Number.isNaN(parseNumeric("-Infinity")));
  assert.ok(Number.isNaN(parseNumeric("1.2.3")));
  assert.ok(Number.isNaN(parseNumeric("abc")));
  assert.ok(Number.isNaN(parseNumeric("10%")));
  assert.ok(Number.isNaN(parseNumeric("+-5")));
});

test("parseNumeric: カンマは3桁区切り位置のみ受理、内部空白は拒否", () => {
  assert.ok(Number.isNaN(parseNumeric("12,34")));
  assert.ok(Number.isNaN(parseNumeric("1,,000")));
  assert.ok(Number.isNaN(parseNumeric("1 2")));
  assert.ok(Number.isNaN(parseNumeric(",100")));
  assert.ok(Number.isNaN(parseNumeric("1,000.5.5")));
  assert.equal(parseNumeric("1,000.5"), 1000.5);
});

// ---------- 実務上限の警告（レビュー指摘 P2 対応） ----------

test("practicalWarnings: 目標割合50%超とプール30%超で警告", () => {
  assert.equal(practicalWarnings(baseInput()).length, 0);
  assert.equal(
    practicalWarnings(
      baseInput({ mode: "ratio", ownInvestment: null, targetOwnRatio: 0.51 })
    ).length,
    1
  );
  assert.equal(practicalWarnings(baseInput({ poolRatio: 0.31 })).length, 1);
  assert.equal(
    practicalWarnings(
      baseInput({
        mode: "ratio",
        ownInvestment: null,
        targetOwnRatio: 0.6,
        poolRatio: 0.35,
      })
    ).length,
    2
  );
  // 境界ちょうどは警告しない
  assert.equal(
    practicalWarnings(
      baseInput({ mode: "ratio", ownInvestment: null, targetOwnRatio: 0.5, poolRatio: 0.3 })
    ).length,
    0
  );
});

// ---------- 境界値（レビュー指摘 P2 対応） ----------

test("境界値: 持分合計の許容誤差 ±0.05% の受理/拒否", () => {
  const mk = (total) => [
    { name: "A", ratio: 0.6 },
    { name: "B", ratio: total - 0.6 },
  ];
  // 100.05%（誤差ちょうど）→ 受理
  assert.equal(validateInput(baseInput({ holders: mk(1.0005) })).length, 0);
  // 100.06% → 拒否
  assert.ok(validateInput(baseInput({ holders: mk(1.0006) })).length > 0);
  // 99.95%（誤差ちょうど）→ 受理
  assert.equal(validateInput(baseInput({ holders: mk(0.9995) })).length, 0);
  // 99.94% → 拒否
  assert.ok(validateInput(baseInput({ holders: mk(0.9994) })).length > 0);
});

test("境界値: 目標取得割合の 0 直上・1 直下は受理、0 と 1 は拒否", () => {
  const ratioInput = (t) =>
    baseInput({ mode: "ratio", ownInvestment: null, targetOwnRatio: t });
  assert.equal(validateInput(ratioInput(1e-9)).length, 0);
  assert.equal(validateInput(ratioInput(0.999)).length, 0);
  assert.ok(validateInput(ratioInput(0)).length > 0);
  assert.ok(validateInput(ratioInput(1)).length > 0);
  // 1 直下は計算も成立する（existingFactor 極小の正）
  const r = computeRound(ratioInput(0.999));
  assert.equal(r.ok, true);
  approx(r.ownRatio, 0.999);
  assert.ok(r.existingFactor > 0 && r.existingFactor < 0.002);
});

test("境界値: プール比率の 1 直下は検証を通り、existingFactor 判定で止まる", () => {
  assert.equal(validateInput(baseInput({ poolRatio: 0.9999 })).length, 0);
  assert.ok(validateInput(baseInput({ poolRatio: 1 })).length > 0);
  const r = computeRound(baseInput({ poolRatio: 0.9999 }));
  assert.equal(r.ok, false); // own 10% + pool 99.99% > 100%
});

test("境界値: existingFactor が極小の正でも一貫した結果を返す", () => {
  // own 100, pool 89.9% → factor = 1 − 0.1 − 0.899 = 0.001
  const r = computeRound(baseInput({ poolRatio: 0.899, existingShares: 10000 }));
  assert.equal(r.ok, true);
  approx(r.existingFactor, 0.001);
  approx(
    r.holders.reduce((a, h) => a + h.after, 0) + r.poolRatio + r.ownRatio,
    1
  );
  assert.ok(r.shares.pricePerShare > 0);
});

test("プレマネー感応度: 目標割合モードでは必要出資額が動く", () => {
  const rows = preMoneySensitivity(
    baseInput({ mode: "ratio", ownInvestment: null, targetOwnRatio: 0.1 }),
    [1, 1.2]
  );
  approx(rows[0].ownRatio, 0.1);
  approx(rows[1].ownRatio, 0.1); // 割合は固定
  approx(rows[0].ownInvestment, 100);
  approx(rows[1].ownInvestment, (0.1 * 1080) / 0.9); // 120
});
