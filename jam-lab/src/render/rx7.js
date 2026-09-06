// プレイヤー車: マツダ RX-7 (FD3S)。
// ユーザー提供のマルチビューイラストを画像→3D 生成にかけた GLB（assets/rx7-fd3s.glb）を読み込む。
// 元データは 5 つのビューが 5 台として出力されていたため、1 台（3/4 前方ビュー由来）だけを抽出し、
// 「前方 = +X / 上 = +Y / 原点 = 車体中心の接地点 / 実寸（ホイールベース 2.425 m）」へ整列済み。
// さらに頂点クラスタリングで 509k → 130k 三角形に軽量化し、テクスチャは 8K → 2K/512 に縮小、
// テールランプだけを残した発光テクスチャ（emissiveMap）を追加してある。生成手順は README を参照。
//
// 読み込みは非同期なので、createRX7() は空の Group を即座に返し、到着後に中身を差し込む。
// 読み込み前・失敗時は carkit の簡易セダンを白で表示して、ゲームが破綻しないようにする。
import * as THREE from '../../vendor/three.module.js';
import { GLTFLoader } from '../../vendor/GLTFLoader.js';
import { createTrafficCar } from './carkit.js';

/** タイヤ半径 [m]（scene.js の転がり計算と一致させる。GLB 実測値） */
export const WHEEL_R = 0.315;
/** モデルの寸法（実測）: 全長 4.48 / 全幅 1.88 / 全高 1.17 m（ウィング・フェンダー込み） */
export const RX7 = { LENGTH: 4.48, WIDTH: 1.88, HEIGHT: 1.17, WHEELBASE: 2.425, TIRE_R: WHEEL_R };

const MODEL_URL = new URL('../../assets/rx7-fd3s.glb', import.meta.url).href;
/** ブレーキ時 / 通常時のテールランプ発光強度 */
const EMISSIVE_IDLE = 0.6, EMISSIVE_BRAKE = 7.0;

let cached = null;   // 読み込み済み gltf.scene（2 台目以降は clone する）

function applyToScene(group, root) {
  const wheels = group.userData.wheels;
  root.traverse((o) => {
    if (!o.isMesh) return;
    o.castShadow = true;
    o.receiveShadow = false;   // 自己影は形状が細かく破綻しやすいので切る
    o.frustumCulled = false;   // 追従カメラで車体が消えないように
    const m = o.material;
    if (m && !group.userData.tailMaterial) {
      // emissiveMap はテールランプ以外が黒いので、強度だけでブレーキ点灯を表現できる
      m.emissiveIntensity = EMISSIVE_IDLE;
      m.envMapIntensity = 1.1;
      group.userData.tailMaterial = m;
      group.userData.tailMaterials = [m];
      group.userData.paintMaterial = m;
      group.userData.emissiveLevels = { idle: EMISSIVE_IDLE, brake: EMISSIVE_BRAKE };
    }
  });
  for (const name of ['wheel_FL', 'wheel_FR', 'wheel_RL', 'wheel_RR']) {
    const w = root.getObjectByName(name);
    if (w) wheels.push(w);
  }
  group.add(root);
  group.userData.loaded = true;
}

/**
 * RX-7 (FD3S) を生成。userData:
 *   tailMaterial / tailMaterials  ブレーキで emissiveIntensity を上げる材（carkit.setBrake が使う）
 *   wheels   4 輪のノード（rotation.z を回すと転がる。読み込み完了までは空配列）
 *   loaded   GLB 読み込み済みか
 *   kind     'rx7'
 */
export function createRX7() {
  const group = new THREE.Group();
  group.name = 'rx7';
  group.userData = {
    kind: 'rx7', wheels: [], tailMaterial: null, tailMaterials: [], paintMaterial: null, brakeOn: false, loaded: false,
    sharedGeometry: true,   // GLB を clone して使うのでジオメトリは carkit.disposeCar で解放しない
  };
  // 読み込み前のプレースホルダ（白い簡易セダン）
  const placeholder = createTrafficCar(0xe9eaea);
  group.add(placeholder);

  const finish = (root) => {
    group.remove(placeholder);
    applyToScene(group, root);
  };
  if (cached) {
    finish(cached.clone(true));
  } else {
    new GLTFLoader().load(MODEL_URL, (gltf) => {
      cached = gltf.scene;
      finish(cached.clone(true));
    }, undefined, (err) => {
      console.error('jam-lab: RX-7 モデルを読み込めませんでした。簡易表示のまま続行します。', err);
    });
  }
  return group;
}
