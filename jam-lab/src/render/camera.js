// カメラリグ: chase / overhead / overview / cockpit の 4 モード。
// playerPose = { x, y, z, fx, fz }（プレイヤー車の位置と進行方向の単位ベクトル、XZ 平面）。
// 座標規約: Y が上。車のローカル +X = 進行方向 (fx, fz)、ローカル +Z = 進行方向の右手 (-fz, fx)。
import * as THREE from '../../vendor/three.module.js';

export const CAMERA_MODES = ['chase', 'overhead', 'overview', 'cockpit'];

const BLEND_SEC = 0.6;      // モード切替の補間時間
const CHASE_TAU_POS = 0.25; // 追従カメラ位置の時定数（指数ラグ）
const CHASE_TAU_LOOK = 0.12;
const OVERVIEW_POS = new THREE.Vector3(0, 470, 300); // 周回路全体（z ±214 m）が fov 55° に収まる固定俯瞰

const smoothstep = (t) => t * t * (3 - 2 * t);

export function createCameraRig(camera) {
  let mode = 'chase';
  // 現在モードの目標、切替時のスナップショット、実際に適用した値
  const target = { pos: new THREE.Vector3(), look: new THREE.Vector3(), up: new THREE.Vector3(0, 1, 0) };
  const from = { pos: new THREE.Vector3(), look: new THREE.Vector3(), up: new THREE.Vector3(0, 1, 0) };
  const cur = { pos: new THREE.Vector3(0, 3.5, 9), look: new THREE.Vector3(), up: new THREE.Vector3(0, 1, 0) };
  let blend = 1; // 1 = 補間完了

  // chase の平滑化状態
  const chasePos = new THREE.Vector3();
  const chaseLook = new THREE.Vector3();
  let chaseReady = false;

  const P = new THREE.Vector3();
  const F = new THREE.Vector3();
  const R = new THREE.Vector3();
  const tmp = new THREE.Vector3();
  const dir = new THREE.Vector3();

  function computeTarget(pose, dt) {
    P.set(pose.x, pose.y, pose.z);
    F.set(pose.fx, 0, pose.fz).normalize();
    R.set(-pose.fz, 0, pose.fx).normalize(); // 進行方向の右手
    switch (mode) {
      case 'chase': {
        // 後方 9 m・高さ 3.5 m から、少し前方を見る。位置は指数ラグで追従
        tmp.copy(P).addScaledVector(F, -9).add(dir.set(0, 3.5, 0));
        const lookDesired = dir.copy(P).addScaledVector(F, 6).setY(P.y + 1.2);
        if (!chaseReady) {
          chasePos.copy(tmp);
          chaseLook.copy(lookDesired);
          chaseReady = true;
        } else {
          chasePos.lerp(tmp, 1 - Math.exp(-dt / CHASE_TAU_POS));
          chaseLook.lerp(lookDesired, 1 - Math.exp(-dt / CHASE_TAU_LOOK));
        }
        target.pos.copy(chasePos);
        target.look.copy(chaseLook);
        target.up.set(0, 1, 0);
        break;
      }
      case 'overhead':
        // 上空 60 m から真下。up を進行方向に取り、道路が画面上方向へ流れるようにする
        target.pos.copy(P).setY(P.y + 60);
        target.look.copy(P);
        target.up.copy(F);
        break;
      case 'overview':
        target.pos.copy(OVERVIEW_POS);
        target.look.set(0, 0, 0);
        target.up.set(0, 1, 0);
        break;
      case 'cockpit':
        // 右ハンドル: 車体中心のやや後ろ、右へ 0.35 m、目線高 1.1 m。わずかに下を見る
        target.pos.copy(P).addScaledVector(F, -0.15).addScaledVector(R, 0.35).setY(P.y + 1.1);
        target.look.copy(target.pos).addScaledVector(F, 20).setY(target.pos.y - 0.6);
        target.up.set(0, 1, 0);
        break;
    }
  }

  function setMode(m) {
    if (!CAMERA_MODES.includes(m) || m === mode) return;
    from.pos.copy(cur.pos);
    from.look.copy(cur.look);
    from.up.copy(cur.up);
    blend = 0;
    mode = m;
    chaseReady = false; // chase に戻ったときは目標位置から再スタート
  }

  /** 次の update で補間せず目標位置へ即移動（レベルリセット等の大ジャンプ用） */
  function snap() {
    chaseReady = false;
    blend = 1;
  }

  /**
   * dt はカメラ時間 [s]。呼び出し側は実時間 × ゲーム倍速を渡す（倍速でも追従距離を一定に保つ）。
   * 上限 1.0 s = 実時間上限 0.25 s × ×4
   */
  function update(pose, dtReal) {
    const dt = Math.min(Math.max(dtReal || 0, 0), 1.0);
    computeTarget(pose, dt);
    if (blend < 1) {
      blend = Math.min(1, blend + dt / BLEND_SEC);
      const t = smoothstep(blend);
      cur.pos.lerpVectors(from.pos, target.pos, t);
      cur.look.lerpVectors(from.look, target.look, t);
      cur.up.lerpVectors(from.up, target.up, t).normalize();
    } else {
      cur.pos.copy(target.pos);
      cur.look.copy(target.look);
      cur.up.copy(target.up);
    }
    // up が視線と平行に近いと lookAt が不定になるので保険
    dir.subVectors(cur.look, cur.pos).normalize();
    if (Math.abs(dir.dot(cur.up)) > 0.98) cur.up.set(0, 1, 0);
    camera.position.copy(cur.pos);
    camera.up.copy(cur.up);
    camera.lookAt(cur.look);
  }

  return {
    setMode,
    snap,
    update,
    get mode() { return mode; },
  };
}
