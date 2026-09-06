// 共有トラック定義 — sim / render / ui が同じ数値を参照する唯一の場所。
// 1D シミュレーション座標 s（m, 0 <= s < LENGTH）と、3D 描画側の閉曲線の対応を決める。
// DOM / three.js に依存しない純粋モジュール（node --test で読めること）。

/** 周回路の全長 [m] */
export const LENGTH = 1000;

/** 車両の全長 [m]（バンパー間の空間ギャップ計算に使う。全車共通） */
export const CAR_LENGTH = 4.6;

/** 車線数（本作は 1 車線固定） */
export const LANES = 1;

/** 直線区間の長さ [m]（2 本） */
export const STRAIGHT = 300;
/** 半円の半径 [m]（半円周 200 m × 2 → 直線 600 + 曲線 400 = 1000） */
export const RADIUS = 200 / Math.PI; // ≒ 63.66

/** s を [0, LENGTH) に正規化 */
export function wrap(s) {
  let x = s % LENGTH;
  if (x < 0) x += LENGTH;
  return x;
}

/** 進行方向に沿った a→b の距離（b が a の前方にあるとして 0 <= d < LENGTH） */
export function forwardDistance(a, b) {
  return wrap(b - a);
}

/**
 * サグ部（下り→上りの谷）プロファイル。s に対する標高 [m]。
 * sag=false なら常に 0（平坦）。levels がサグ有効時に true を渡す。
 *   0〜250 m: 高台（3.75 m）
 *   250〜400 m: 下り -2.5%（3.75 → 0）
 *   400〜650 m: 上り +1.5%（0 → 3.75）
 *   650〜1000 m: 高台（3.75 m）
 * 渋滞学で「サグ部渋滞」と呼ばれる形状の単純化。上りで無自覚に速度が落ちる。
 */
export function elevationAt(s, sag = false) {
  if (!sag) return 0;
  const x = wrap(s);
  if (x < 250) return 3.75;
  if (x < 400) return 3.75 - (x - 250) * 0.025;
  if (x < 650) return (x - 400) * 0.015;
  return 3.75;
}

/**
 * 勾配 [無次元, 上りが正]。sim はこれを重力抵抗 -g*grade として加速度に加える。
 * render は elevationAt で道路メッシュを持ち上げる。両者は同じ区間定義から導く。
 */
export function gradeAt(s, sag = false) {
  if (!sag) return 0;
  const x = wrap(s);
  if (x >= 250 && x < 400) return -0.025;
  if (x >= 400 && x < 650) return 0.015;
  return 0;
}

/**
 * 閉曲線の平面座標（スタジアム形: 直線 2 本 + 半円 2 つ）。
 * three.js の XZ 平面（y が上）を使う。
 * 戻り値 {x, z, fx, fz, heading}
 *   (x, z)   : 車線中心の位置
 *   (fx, fz) : 進行方向の単位ベクトル
 *   heading  : Math.atan2(fz, fx)（ラジアン）。render は heading から車の向きを決めてよいし
 *              (fx, fz) を lookAt に使ってもよい。
 * 進行は反時計回り（上から見て）: 右側直線を z 減少方向へ → 奥の半円 → 左側直線を z 増加方向へ → 手前の半円。
 * s=0 は右側直線の始点 (x=+R, z=+STRAIGHT/2)。
 */
export function pointAt(s) {
  const x = wrap(s);
  const semi = Math.PI * RADIUS; // 200
  let px, pz, fx, fz;
  if (x < STRAIGHT) {
    px = RADIUS; pz = STRAIGHT / 2 - x; fx = 0; fz = -1;
  } else if (x < STRAIGHT + semi) {
    const th = (x - STRAIGHT) / RADIUS; // 0 → π
    px = Math.cos(th) * RADIUS; pz = -STRAIGHT / 2 - Math.sin(th) * RADIUS;
    fx = -Math.sin(th); fz = -Math.cos(th);
  } else if (x < 2 * STRAIGHT + semi) {
    const d = x - STRAIGHT - semi;
    px = -RADIUS; pz = -STRAIGHT / 2 + d; fx = 0; fz = 1;
  } else {
    const th = (x - 2 * STRAIGHT - semi) / RADIUS; // 0 → π
    px = -Math.cos(th) * RADIUS; pz = STRAIGHT / 2 + Math.sin(th) * RADIUS;
    fx = Math.sin(th); fz = Math.cos(th);
  }
  return { x: px, z: pz, fx, fz, heading: Math.atan2(fz, fx) };
}
