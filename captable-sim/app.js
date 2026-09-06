// captable-sim UI 層。計算はすべて calc.js に委譲する。
import {
  computeRound,
  sensitivityTable,
  valuationDiagnostics,
  preMoneySensitivity,
  exitAnalysis,
  practicalWarnings,
  parseNumeric as parseNum,
  TYPICAL_DILUTION_RANGE,
  ipoDilutionPosition,
} from "./calc.js";
import { normalizeSnapshot, searchCompanies, monthsBetween } from "./companies.js";

const $ = (id) => document.getElementById(id);

const HOLDER_COLORS = [
  "var(--holder-1)", "var(--holder-2)", "var(--holder-3)",
  "var(--holder-4)", "var(--holder-5)", "var(--holder-6)",
];
const REST_COLOR = "var(--holder-rest)";
const SENSITIVITY_MULTIPLIERS = [0.5, 0.75, 1, 1.25, 1.5];

let mode = "amount";
let holderSeq = 0;

// ---------- 入力の読み取り ----------

function readHolders() {
  return [...document.querySelectorAll("#holder-rows .holder-row")].map((row) => {
    const ratio = parseNum(row.querySelector("input.ratio").value);
    return {
      name: row.querySelector("input.name").value.trim() || "(名称未入力)",
      ratio: ratio === null ? NaN : ratio / 100,
    };
  });
}

function readInput() {
  const req = (v) => (v === null ? NaN : v); // 必須欄の未入力は NaN としてエラーに落とす
  const pre = parseNum($("pre-money").value);
  const prevPost = parseNum($("prev-post-money").value);
  const own = parseNum($("own-investment").value);
  const target = parseNum($("target-ratio").value);
  const other = parseNum($("other-investment").value);
  const pool = parseNum($("pool-ratio").value);
  const shares = parseNum($("existing-shares").value);
  return {
    preMoney: req(pre),
    prevPostMoney: prevPost, // 任意
    mode,
    ownInvestment: mode === "amount" ? req(own) : null,
    targetOwnRatio: mode === "ratio" ? (target === null ? NaN : target / 100) : null,
    otherInvestment: other === null ? 0 : other, // 未入力は 0 扱い
    poolRatio: pool === null ? 0 : pool / 100,
    existingShares: shares, // 任意
    holders: readHolders(),
    revenue: parseNum($("revenue").value),
    monthsSinceLastRound: parseNum($("months-since").value),
    refMultipleLow: parseNum($("ref-multiple-low").value),
    refMultipleHigh: parseNum($("ref-multiple-high").value),
    exitYears: parseNum($("exit-years").value),
    exitRevenue: parseNum($("exit-revenue").value),
    exitMultipleLow: parseNum($("exit-multiple-low").value),
    exitMultipleHigh: parseNum($("exit-multiple-high").value),
    futureDilution: (() => {
      const d = parseNum($("future-dilution").value);
      return d === null ? null : d / 100;
    })(),
    targetMultiple: parseNum($("target-multiple").value),
  };
}

// ---------- フォーマッタ ----------

const fmt = (n, digits = 1) =>
  n.toLocaleString("ja-JP", { minimumFractionDigits: digits, maximumFractionDigits: digits });
const fmtInt = (n) => Math.round(n).toLocaleString("ja-JP");
const pct = (r, digits = 1) => `${(r * 100).toFixed(digits)}%`;

function fmtMoney(millionYen) {
  // 百万円 → 「1,000百万円（10.0億円）」表記
  const oku = millionYen / 100;
  return oku >= 1
    ? `${fmt(millionYen, 0)}<span style="font-size:12px">百万円（${fmt(oku)}億円）</span>`
    : `${fmt(millionYen, 0)}<span style="font-size:12px">百万円</span>`;
}

function fmtPricePerShare(priceMillionYen) {
  const yen = priceMillionYen * 1_000_000;
  return `${fmtInt(yen)}円`;
}

const esc = (s) =>
  s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

const holderColor = (i) => (i < HOLDER_COLORS.length ? HOLDER_COLORS[i] : REST_COLOR);

// ---------- 描画 ----------

function render() {
  const input = readInput();
  const r = computeRound(input);

  const errBox = $("errors");
  const body = $("results-body");
  updateHolderSum(input.holders);

  const warnBox = $("warnings");
  const warnings = practicalWarnings(input);
  warnBox.classList.toggle("hidden", warnings.length === 0);
  warnBox.innerHTML = warnings.map((w) => `<div>⚠ ${esc(w)}</div>`).join("");

  if (!r.ok) {
    errBox.classList.remove("hidden");
    errBox.innerHTML = r.errors.map((e) => `<div>⚠ ${esc(e)}</div>`).join("");
    body.classList.add("hidden");
    return;
  }
  errBox.classList.add("hidden");
  body.classList.remove("hidden");

  renderKpis(r);
  renderBars(r);
  renderCaptable(r);
  renderShares(r);
  renderValidity(input, r);
  renderExit(input);
  renderSensitivity(input);
  renderPreSensitivity(input);
}

function updateHolderSum(holders) {
  const sum = holders.reduce((a, h) => a + (Number.isFinite(h.ratio) ? h.ratio : 0), 0) * 100;
  const el = $("holder-sum");
  el.textContent = `合計 ${sum.toFixed(2)}%`;
  el.classList.toggle("bad", Math.abs(sum - 100) > 0.05);
}

function renderKpis(r) {
  let roundBadge = "";
  if (r.roundType) {
    const label = { up: "アップラウンド", down: "ダウンラウンド", flat: "フラット" }[r.roundType];
    roundBadge = `<span class="badge ${r.roundType}">${label}</span>`;
  }
  const kpis = [
    { label: "ポストマネー評価額", value: fmtMoney(r.postMoney) },
    {
      label: r.roundType ? "株価倍率（今回プレ ÷ 前回ポスト）" : "株価倍率",
      value: r.priceMultiple !== null ? `${r.priceMultiple.toFixed(2)}x${roundBadge}` : "—",
      sub: r.priceMultiple === null ? "前回ラウンドを入力すると判定します" : "",
    },
    {
      label: "自社取得割合",
      value: pct(r.ownRatio, 2),
      sub: `出資額 ${fmt(r.ownInvestment, 0)}百万円`,
    },
    {
      label: "新規投資家合計",
      value: pct(r.ownRatio + r.otherRatio, 2),
      sub: `調達総額 ${fmt(r.totalInvestment, 0)}百万円`,
    },
    {
      label: "既存株主の希薄化率",
      value: pct(r.existingDilution, 2),
      sub: `持分は従前の ${pct(r.existingFactor, 1)} に`,
    },
  ];
  $("kpis").innerHTML = kpis
    .map(
      (k) => `<div class="kpi">
        <div class="k-label">${k.label}</div>
        <div class="k-value">${k.value}</div>
        ${k.sub ? `<div class="k-sub">${k.sub}</div>` : ""}
      </div>`
    )
    .join("");
}

function segmentsAfter(r) {
  const segs = r.holders.map((h, i) => ({
    name: h.name, ratio: h.after, color: holderColor(i),
  }));
  if (r.poolRatio > 0) segs.push({ name: "オプションプール", ratio: r.poolRatio, color: "var(--series-pool)" });
  if (r.otherRatio > 0) segs.push({ name: "他投資家（新規）", ratio: r.otherRatio, color: "var(--series-other)" });
  if (r.ownRatio > 0) segs.push({ name: "自社（新規）", ratio: r.ownRatio, color: "var(--series-own)" });
  return segs;
}

function barHtml(segs) {
  return `<div class="bar">${segs
    .map(
      (s) => `<div class="seg" style="flex:${s.ratio} 0 0; background:${s.color}"
        title="${esc(s.name)}: ${pct(s.ratio)}">${s.ratio >= 0.08 ? `<span>${pct(s.ratio, 0)}</span>` : ""}</div>`
    )
    .join("")}</div>`;
}

function renderBars(r) {
  const before = r.holders.map((h, i) => ({ name: h.name, ratio: h.before, color: holderColor(i) }));
  const after = segmentsAfter(r);
  const legendItems = after.map(
    (s) => `<div class="item"><span class="swatch" style="background:${s.color}"></span>${esc(s.name)}</div>`
  );
  $("bars").innerHTML = `
    <div class="bar-block"><div class="bar-label">ラウンド前</div>${barHtml(before)}</div>
    <div class="bar-block"><div class="bar-label">ラウンド後</div>${barHtml(after)}</div>
    <div class="legend">${legendItems.join("")}</div>`;
}

function renderCaptable(r) {
  const rows = [];
  r.holders.forEach((h, i) => {
    const delta = h.after - h.before;
    rows.push(`<tr>
      <td><span class="dot" style="background:${holderColor(i)}"></span>${esc(h.name)}</td>
      <td class="num">${pct(h.before, 2)}</td>
      <td class="num">${pct(h.after, 2)}</td>
      <td class="num delta-down">${(delta * 100).toFixed(2)}pt</td>
    </tr>`);
  });
  if (r.poolRatio > 0) {
    rows.push(`<tr>
      <td><span class="dot" style="background:var(--series-pool)"></span>オプションプール</td>
      <td class="num">—</td><td class="num">${pct(r.poolRatio, 2)}</td>
      <td class="num delta-up">+${(r.poolRatio * 100).toFixed(2)}pt</td>
    </tr>`);
  }
  if (r.otherRatio > 0) {
    rows.push(`<tr>
      <td><span class="dot" style="background:var(--series-other)"></span>他投資家（新規）</td>
      <td class="num">—</td><td class="num">${pct(r.otherRatio, 2)}</td>
      <td class="num delta-up">+${(r.otherRatio * 100).toFixed(2)}pt</td>
    </tr>`);
  }
  rows.push(`<tr class="highlight">
    <td><span class="dot" style="background:var(--series-own)"></span>自社（新規）</td>
    <td class="num">—</td><td class="num">${pct(r.ownRatio, 2)}</td>
    <td class="num delta-up">+${(r.ownRatio * 100).toFixed(2)}pt</td>
  </tr>`);
  const totalAfter =
    r.holders.reduce((a, h) => a + h.after, 0) + r.poolRatio + r.otherRatio + r.ownRatio;
  rows.push(`<tr class="total">
    <td>合計</td><td class="num">100.00%</td>
    <td class="num">${pct(totalAfter, 2)}</td><td class="num"></td>
  </tr>`);
  $("captable").innerHTML = `<table>
    <thead><tr><th>株主</th><th class="num">ラウンド前</th><th class="num">ラウンド後</th><th class="num">増減</th></tr></thead>
    <tbody>${rows.join("")}</tbody></table>`;
}

function renderShares(r) {
  const card = $("shares-card");
  if (!r.shares) {
    card.classList.add("hidden");
    card.innerHTML = "";
    return;
  }
  card.classList.remove("hidden");
  const s = r.shares;
  const rows = [
    ["株価（1株あたり）", fmtPricePerShare(s.pricePerShare)],
    ["既存株式数", `${fmtInt(s.existingShares)}株`],
    ...(s.poolShares > 0 ? [["オプションプール新株", `約${fmtInt(s.poolShares)}株`]] : []),
    ["自社への新規発行", `約${fmtInt(s.ownNewShares)}株`],
    ...(s.otherNewShares > 0 ? [["他投資家への新規発行", `約${fmtInt(s.otherNewShares)}株`]] : []),
    ["ラウンド後発行済株式数", `約${fmtInt(s.totalPostShares)}株`],
  ];
  card.innerHTML = `<h2>株式数・株価</h2>
    <table><tbody>${rows
      .map(([k, v]) => `<tr><td>${k}</td><td class="num">${v}</td></tr>`)
      .join("")}</tbody></table>
    <div class="hint" style="font-size:11px;color:var(--text-muted);margin-top:8px">
      新規発行株数は概算です（端数調整は考慮していません）。</div>`;
}

function renderValidity(input, r) {
  const card = $("validity-card");
  const d = valuationDiagnostics(input);
  if (!d) {
    card.classList.add("hidden");
    card.innerHTML = "";
    return;
  }
  const items = [];

  if (d.revenueMultiple !== null) {
    let rangeNote = "";
    if (d.impliedPreRange) {
      const { low, high, verdict } = d.impliedPreRange;
      const verdictText = {
        below: `<span class="badge up">レンジより低い</span>`,
        within: `<span class="badge flat">レンジ内</span>`,
        above: `<span class="badge down">レンジより高い</span>`,
      }[verdict];
      rangeNote = `参考マルチプル ${input.refMultipleLow}〜${input.refMultipleHigh}倍 → プレマネー相当 ${fmt(low, 0)}〜${fmt(high, 0)}百万円。今回プレマネー ${fmt(input.preMoney, 0)}百万円は ${verdictText}`;
    }
    items.push({
      label: "売上マルチプル（プレマネー ÷ 売上高）",
      value: `${d.revenueMultiple.toFixed(1)}倍`,
      note: rangeNote,
    });
  }

  if (d.annualizedGrowth !== null) {
    const g = d.annualizedGrowth;
    items.push({
      label: "評価額の成長率（前回ポスト → 今回プレ）",
      value: `年率 ${g >= 0 ? "+" : ""}${(g * 100).toFixed(1)}%`,
      note: `${input.monthsSinceLastRound}ヶ月で ${(input.preMoney / input.prevPostMoney).toFixed(2)}x`,
    });
  }

  const dilutionBadge = {
    low: `<span class="badge flat">一般的レンジより低い</span>`,
    typical: `<span class="badge up">一般的レンジ内</span>`,
    high: `<span class="badge down">一般的レンジより高い</span>`,
  }[d.dilutionVerdict];
  let ipoNote = "";
  const ipoPos = ipoDilutionPosition(d.existingDilution, ipoBench.data?.dilution_per_round);
  if (ipoPos) {
    const posLabel = { below: "実績分布より控えめ", within: "実績の四分位レンジ内", above: "実績分布より大きい希薄化" }[ipoPos.position];
    const s = ipoBench.data.stats || {};
    const med = (k, unit, digits = 1) => (s[k] && typeof s[k].median === "number" ? `${s[k].median.toFixed(digits)}${unit}` : "—");
    ipoNote = `<br>IPO企業実績（Ⅰの部 ${ipoBench.data.count}社・${ipoPos.n}ラウンド）: 1ラウンド希薄化 中央値 ${(ipoPos.median * 100).toFixed(1)}%（四分位 ${(ipoPos.q1 * 100).toFixed(1)}〜${(ipoPos.q3 * 100).toFixed(1)}%）→ <b>${posLabel}</b>`
      + `<br>上場時の実績中央値: 創業者持株 ${med("founder_pct", "%")} / VC ${med("vc_pct", "%")} / ラウンド数 ${med("rounds_count", "回", 1)} / 設立→IPO ${med("years_to_ipo", "年")}`;
  }
  items.push({
    label: "既存株主の希薄化率",
    value: `${pct(d.existingDilution, 1)} ${dilutionBadge}`,
    note: `1ラウンドあたり ${TYPICAL_DILUTION_RANGE.low * 100}〜${TYPICAL_DILUTION_RANGE.high * 100}% が一般的な目安${ipoNote}`,
  });

  card.classList.remove("hidden");
  card.innerHTML = `<h2>バリュエーション妥当性の参考指標</h2>
    ${items
      .map(
        (it) => `<div style="padding:8px 0; border-bottom:1px solid var(--grid)">
          <div style="font-size:11px;color:var(--text-muted)">${it.label}</div>
          <div style="font-size:16px;font-weight:700;margin-top:1px">${it.value}</div>
          ${it.note ? `<div style="font-size:12px;color:var(--text-secondary);margin-top:2px">${it.note}</div>` : ""}
        </div>`
      )
      .join("")}
    <div style="font-size:11px;color:var(--text-muted);margin-top:8px">
      妥当性の最終判断には類似企業・類似ステージの調達事例との比較が必要です。本指標は判断材料の提供にとどまります。</div>`;
}

function renderPreSensitivity(input) {
  const rows = preMoneySensitivity(input, [0.8, 0.9, 1, 1.1, 1.2]);
  $("pre-sensitivity").innerHTML = `<table>
    <thead><tr><th>ケース</th><th class="num">プレマネー</th><th class="num">自社出資額</th>
      <th class="num">取得割合</th><th class="num">ポストマネー</th></tr></thead>
    <tbody>${rows
      .map(
        (row) => `<tr${row.multiplier === 1 ? ' class="highlight"' : ""}>
        <td>${row.multiplier === 1 ? "現在の条件" : `×${row.multiplier}`}</td>
        <td class="num">${fmt(row.preMoney, 0)}百万円</td>
        <td class="num">${fmt(row.ownInvestment, 0)}百万円</td>
        <td class="num">${pct(row.ownRatio, 2)}</td>
        <td class="num">${fmt(row.postMoney, 0)}百万円</td>
      </tr>`
      )
      .join("")}</tbody></table>
    <div style="font-size:11px;color:var(--text-muted);margin-top:8px">
      ${input.mode === "ratio" ? "目標取得割合を維持したまま、必要出資額の変化を表示しています。" : "自社出資額を維持したまま、取得割合の変化を表示しています。"}</div>`;
}

function renderExit(input) {
  const card = $("exit-card");
  const a = exitAnalysis(input);
  if (!a) {
    card.classList.add("hidden");
    card.innerHTML = "";
    return;
  }
  card.classList.remove("hidden");

  const verdictBadge = {
    below: `<span class="badge up">保守シナリオでも目標達成圏</span>`,
    within: `<span class="badge flat">強気シナリオなら目標達成圏</span>`,
    above: `<span class="badge down">強気シナリオでも目標未達</span>`,
  }[a.verdict];

  const scenarioLabel = { conservative: "保守", aggressive: "強気" };
  const rows = a.scenarios.map(
    (s) => `<tr>
      <td>${scenarioLabel[s.label]}（${s.multiple}倍）</td>
      <td class="num">${fmt(s.exitValue, 0)}百万円</td>
      <td class="num">${fmt(s.ownExitValue, 0)}百万円</td>
      <td class="num">${s.moic.toFixed(1)}x</td>
      <td class="num">${(s.irr * 100).toFixed(1)}%</td>
    </tr>`
  );

  card.innerHTML = `<h2>Exitマルチプル妥当性（VC法）</h2>
    <div style="padding:6px 0 10px">
      <div style="font-size:11px;color:var(--text-muted)">目標 ${a.targetMultiple}x を満たすポストマネー上限（将来希薄化 ${((1 - a.retention) * 100).toFixed(0)}% 考慮）</div>
      <div style="font-size:18px;font-weight:700;margin-top:2px">
        ${fmt(a.fairPostRange.low, 0)}〜${fmt(a.fairPostRange.high, 0)}百万円 ${verdictBadge}
      </div>
      <div style="font-size:12px;color:var(--text-secondary);margin-top:2px">
        今回ポストマネー: ${fmt(a.currentPost, 0)}百万円</div>
    </div>
    <table>
      <thead><tr><th>シナリオ</th><th class="num">Exit企業価値</th><th class="num">自社持分価値</th>
        <th class="num">MOIC</th><th class="num">IRR（${a.exitYears}年）</th></tr></thead>
      <tbody>${rows.join("")}</tbody>
    </table>
    <div style="font-size:12px;color:var(--text-secondary);margin-top:10px">
      今回の条件で目標 ${a.targetMultiple}x を達成するには、Exit時企業価値 ${fmt(a.requiredExitValue, 0)}百万円
      （Exit想定売上の ${a.requiredExitMultiple.toFixed(1)}倍）が必要です。
    </div>
    <div style="font-size:11px;color:var(--text-muted);margin-top:6px">
      MOIC = Exit企業価値 × 残存率 ÷ ポストマネー（優先分配・清算優先権は考慮しない普通株換算の概算）。</div>`;
}

function renderSensitivity(input) {
  const rows = sensitivityTable(input, SENSITIVITY_MULTIPLIERS);
  $("sensitivity").innerHTML = `<table>
    <thead><tr><th>ケース</th><th class="num">自社出資額</th><th class="num">取得割合</th>
      <th class="num">ポストマネー</th><th class="num">既存株主の残存率</th></tr></thead>
    <tbody>${rows
      .map(
        (row) => `<tr${row.multiplier === 1 ? ' class="highlight"' : ""}>
        <td>${row.multiplier === 1 ? "現在の条件" : `×${row.multiplier}`}</td>
        <td class="num">${fmt(row.ownInvestment, 0)}百万円</td>
        <td class="num">${pct(row.ownRatio, 2)}</td>
        <td class="num">${fmt(row.postMoney, 0)}百万円</td>
        <td class="num">${pct(row.existingFactor, 1)}</td>
      </tr>`
      )
      .join("")}</tbody></table>`;
}

// ---------- startup-finder 連携 ----------
// スナップショット JSON を読み、企業選択→「反映」ボタンの明示操作でのみ入力欄へ転記する。
// DB値は報道・推計ベースの参考値のため、反映欄には要確認マーク（.autofilled）を付け、
// 利用者が手で編集した時点で解除する。

const finder = { companies: [], generatedAt: null, selected: null };
// IPO企業の資本政策ベンチマーク（startup-finder の Ⅰの部抽出から生成したスナップショット）
const ipoBench = { data: null };

async function loadIpoBenchmarks() {
  try {
    const res = await fetch("data/ipo_benchmarks.json", { cache: "no-cache" });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const j = await res.json();
    if (j && typeof j === "object" && j.dilution_per_round) ipoBench.data = j;
  } catch {
    ipoBench.data = null; // 無くても手入力・一般目安で動く
  }
}
let programmaticFill = false;

async function loadCompanies() {
  const status = $("finder-status");
  try {
    const res = await fetch("data/companies.json", { cache: "no-cache" });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const snap = normalizeSnapshot(await res.json());
    finder.companies = snap.companies;
    finder.generatedAt = snap.generatedAt;
    const date = snap.generatedAt ? snap.generatedAt.slice(0, 10) : "不明";
    status.textContent = `${snap.companies.length}社（評価額あり）・スナップショット: ${date}時点`;
  } catch {
    status.textContent = "企業データを読み込めませんでした（手入力は通常どおり使えます）。";
  }
}

function renderFinderResults() {
  // 検索語が変わったら旧選択を破棄する（画面上の結果一覧と選択中企業の不一致を防ぐ）
  finder.selected = null;
  renderCompanyDetail();
  const q = $("company-search").value;
  const hits = searchCompanies(finder.companies, q);
  $("company-results").innerHTML = hits
    .map(
      (c, i) => `<button type="button" class="company-result" data-idx="${i}">
        ${esc(c.name)}
        <span class="meta">｜${esc(c.stage ?? "ステージ不明")}｜評価額 ${fmt(c.valuationOku)}億円</span>
      </button>`
    )
    .join("");
  [...$("company-results").querySelectorAll("button")].forEach((btn, i) => {
    btn.addEventListener("click", () => {
      finder.selected = hits[i];
      renderCompanyDetail();
    });
  });
}

function currentYm() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}

function renderCompanyDetail() {
  const c = finder.selected;
  const box = $("company-detail");
  if (!c) {
    box.innerHTML = "";
    return;
  }
  const round = [
    c.lastRoundName ? esc(c.lastRoundName) : null,
    c.lastRoundDate ? esc(c.lastRoundDate) : null,
    c.lastRoundAmountOku !== null ? `${fmt(c.lastRoundAmountOku)}億円` : null,
  ].filter(Boolean).join(" / ") || "—";
  const links = c.sources
    .map((u, i) => `<a href="${esc(u)}" target="_blank" rel="noopener noreferrer">出典${i + 1}</a>`)
    .join("・");
  box.innerHTML = `<div class="company-detail">
    <strong>${esc(c.name)}</strong>
    <dl>
      <dt>ステージ</dt><dd>${esc(c.stage ?? "—")}</dd>
      <dt>評価額（参考）</dt><dd>${fmt(c.valuationOku)}億円</dd>
      <dt>直近ラウンド</dt><dd>${round}</dd>
      <dt>評価額の出典</dt><dd>${c.valuationSource ? esc(c.valuationSource) : "—"}</dd>
      <dt>参照リンク</dt><dd>${links || "—"}</dd>
      <dt>最終検証</dt><dd>${esc(c.lastVerified ?? "—")}</dd>
    </dl>
    <button type="button" class="apply" id="apply-company">前回ラウンド欄に反映（要確認値）</button>
    <div class="caution">評価額は報道・推計ベースの参考値で、厳密な前回ラウンドのポストマネーとは限りません。
      出典を確認し、必要に応じて手で修正してください。</div>
  </div>`;
  $("apply-company").addEventListener("click", applyCompany);
}

function applyCompany() {
  const c = finder.selected;
  if (!c) return;
  const months = monthsBetween(c.lastRoundDate, currentYm());
  programmaticFill = true;
  try {
    const setField = (id, value) => {
      const el = $(id);
      el.value = value;
      el.classList.toggle("autofilled", value !== "");
      el.dispatchEvent(new Event("input", { bubbles: true }));
    };
    setField("prev-post-money", fmt(c.valuationOku * 100, 0));
    // 経過月数: 1ヶ月以上なら転記。同月(0)やラウンド日不明の場合は、
    // 前の企業の値が残らないようクリアする（年率換算には1ヶ月以上が必要）
    setField("months-since", months !== null && months > 0 ? String(months) : "");
  } finally {
    programmaticFill = false;
  }
}

// 反映値をユーザーが手で編集したら要確認マークを外す
for (const id of ["prev-post-money", "months-since"]) {
  $(id).addEventListener("input", () => {
    if (!programmaticFill) $(id).classList.remove("autofilled");
  });
}

$("company-search").addEventListener("input", renderFinderResults);
loadCompanies();

loadIpoBenchmarks();
// ---------- 株主行の管理 ----------

function addHolderRow(name = "", ratio = "") {
  const row = document.createElement("div");
  row.className = "holder-row";
  const id = holderSeq++;
  row.innerHTML = `
    <input type="text" class="name" placeholder="株主名" value="${esc(name)}" aria-label="株主名">
    <input type="text" class="ratio" inputmode="decimal" value="${esc(String(ratio))}" aria-label="持分比率(%)">
    <span class="pct">%</span>
    <button type="button" class="del" title="削除" aria-label="株主を削除">×</button>`;
  row.querySelector("button.del").addEventListener("click", () => {
    row.remove();
    render();
  });
  row.dataset.id = id;
  $("holder-rows").appendChild(row);
}

// ---------- 初期化 ----------

function setMode(next) {
  mode = next;
  $("mode-amount").classList.toggle("active", mode === "amount");
  $("mode-ratio").classList.toggle("active", mode === "ratio");
  $("field-own-investment").classList.toggle("hidden", mode !== "amount");
  $("field-target-ratio").classList.toggle("hidden", mode !== "ratio");
  render();
}

$("mode-amount").addEventListener("click", () => setMode("amount"));
$("mode-ratio").addEventListener("click", () => setMode("ratio"));
$("add-holder").addEventListener("click", () => {
  addHolderRow();
  render();
});
document.querySelector(".container").addEventListener("input", render);

addHolderRow("経営陣", 60);
addHolderRow("既存VC A", 25);
addHolderRow("既存VC B", 15);
render();
