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

export interface SwapBlocksArgs {
	gridPos1: GridPosition;
	gridPos2: GridPosition;
}

/** マッチグループ */
export interface MatchGroup {
	positions: GridPosition[];
	colorIndex: number;
}

/** カスケード結果 */
export interface CascadeResult {
	matchedGroups: MatchGroup[];
	score: number;
	cascadeDepth: number;
}

/** ゲーム状態 */
export interface GameState {
	score: number;
	moves: number;
	matchCount: number;
}
