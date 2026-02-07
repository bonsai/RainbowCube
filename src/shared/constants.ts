// Rainbow Tower Builder - Constants

/** グリッドのサイズ (9x9x9) */
export const GRID_SIZE = 9;

/** 1ブロックのスタッドサイズ */
export const STUD_SIZE = 5;

/** レインボーカラー定義 (7色) */
export const RAINBOW_COLORS = [
	Color3.fromRGB(255, 0, 0), // 赤
	Color3.fromRGB(255, 165, 0), // オレンジ
	Color3.fromRGB(255, 255, 0), // 黄
	Color3.fromRGB(0, 255, 0), // 緑
	Color3.fromRGB(0, 127, 255), // 青
	Color3.fromRGB(148, 0, 211), // 紫
	Color3.fromRGB(255, 192, 203), // ピンク
];

/** カラー名（日本語） */
export const COLOR_NAMES = ["赤", "オレンジ", "黄", "緑", "青", "紫", "ピンク"];

/** 色の数 */
export const COLOR_COUNT = 7;

/** マッチに必要な最小ブロック数 */
export const MIN_MATCH_COUNT = 3;

/** プレイヤーが届く最大の高さ（Y座標） */
export const MAX_REACH_HEIGHT = 4;

/** 各層のブロック数 (9x9) */
export const BLOCKS_PER_LAYER = GRID_SIZE * GRID_SIZE;

/** グリッド中心のワールド座標 */
export const GRID_CENTER_POSITION = new Vector3(0, 0, 0);
