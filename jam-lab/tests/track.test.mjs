// shared/track.js の幾何・標高の整合性テスト（完成済みモジュールの回帰確認）
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LENGTH, RADIUS, STRAIGHT, wrap, forwardDistance, pointAt, elevationAt, gradeAt } from '../src/shared/track.js';

const near = (a, b, eps = 1e-6) => assert.ok(Math.abs(a - b) < eps, `${a} != ${b}`);

test('wrap / forwardDistance', () => {
  near(wrap(1000), 0);
  near(wrap(-1), 999);
  near(wrap(1234.5), 234.5);
  near(forwardDistance(990, 10), 20);  // 1 周またぎ
  near(forwardDistance(10, 990), 980);
  near(forwardDistance(5, 5), 0);
});

test('pointAt の代表点', () => {
  const p0 = pointAt(0);
  near(p0.x, RADIUS); near(p0.z, STRAIGHT / 2); near(p0.fx, 0); near(p0.fz, -1);
  const p300 = pointAt(300); // 右直線の終点 = 奥の半円の始点
  near(p300.x, RADIUS); near(p300.z, -STRAIGHT / 2); near(p300.fx, 0); near(p300.fz, -1);
  const p500 = pointAt(500); // 半円を抜けて左直線の始点
  near(p500.x, -RADIUS); near(p500.z, -STRAIGHT / 2); near(p500.fx, 0); near(p500.fz, 1);
  const pEnd = pointAt(1000);
  near(pEnd.x, p0.x); near(pEnd.z, p0.z); near(pEnd.fx, p0.fx); near(pEnd.fz, p0.fz);
});

test('曲線の連続性: 1 m ごとの隣接点の距離 ≈ 1 m、前方ベクトルは単位長', () => {
  let prev = pointAt(0);
  for (let s = 1; s <= LENGTH; s++) {
    const p = pointAt(s);
    const d = Math.hypot(p.x - prev.x, p.z - prev.z);
    assert.ok(Math.abs(d - 1) < 0.01, `s=${s} 隣接距離 ${d}`);
    near(Math.hypot(p.fx, p.fz), 1, 1e-9);
    near(p.heading, Math.atan2(p.fz, p.fx), 1e-12);
    prev = p;
  }
});

test('標高は区間境界 250/400/650 で連続、勾配は定義どおり', () => {
  for (const x of [250, 400, 650]) {
    const lo = elevationAt(x - 1e-6, true);
    const hi = elevationAt(x + 1e-6, true);
    assert.ok(Math.abs(lo - hi) < 1e-3, `s=${x} で標高が不連続: ${lo} vs ${hi}`);
  }
  near(elevationAt(0, true), 3.75);
  near(elevationAt(400, true), 0);
  near(elevationAt(700, true), 3.75);
  near(elevationAt(500, false), 0);
  near(gradeAt(300, true), -0.025);
  near(gradeAt(500, true), 0.015);
  near(gradeAt(100, true), 0);
  near(gradeAt(500, false), 0);
});
