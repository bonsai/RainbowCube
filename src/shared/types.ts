// Rainbow Tower Builder - Type Definitions

/** グリッド座標 */
export interface GridPosition {
	x: number;
	y: number;
	z: number;
}

/** ブロックデータ */
export interface BlockData {
	gridPos: GridPosition;
	colorIndex: number;
	part: Part;
}

/** RemoteEvent引数の型定義 */
export interface PlaceBlockArgs {
	gridPos: GridPosition;
	colorIndex: number;
}

export interface DestroyBlockArgs {
	gridPos: GridPosition;
}
