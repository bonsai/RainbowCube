// Rainbow Tower Builder - Constants

/** グリッドのサイズ (9x9x9) */
export const GRID_SIZE = 9;

/** 1ブロックのスタッドサイズ */
export const STUD_SIZE = 5;

/** レインボーカラー定義 (各Y層に対応) */
export const RAINBOW_COLORS = [
	Color3.fromRGB(255, 0, 0), // Y=0: 赤
	Color3.fromRGB(255, 165, 0), // Y=1: オレンジ
	Color3.fromRGB(255, 255, 0), // Y=2: 黄
	Color3.fromRGB(0, 255, 0), // Y=3: 緑
	Color3.fromRGB(0, 127, 255), // Y=4: 青
	Color3.fromRGB(75, 0, 130), // Y=5: 藍
	Color3.fromRGB(148, 0, 211), // Y=6: 紫
	Color3.fromRGB(255, 192, 203), // Y=7: ピンク
	Color3.fromRGB(255, 255, 255), // Y=8: 白
];

/** カラー名（日本語） */
export const COLOR_NAMES = ["赤", "オレンジ", "黄", "緑", "青", "藍", "紫", "ピンク", "白"];

/** 各層のブロック数 (9x9) */
export const BLOCKS_PER_LAYER = GRID_SIZE * GRID_SIZE;

/** グリッド中心のワールド座標 */
export const GRID_CENTER_POSITION = new Vector3(0, 0, 0);
