// Rainbow Tower Builder - Grid Manager

import { GRID_SIZE, STUD_SIZE, RAINBOW_COLORS, GRID_CENTER_POSITION, COLOR_COUNT, MIN_MATCH_COUNT } from "shared/constants";
import { GridPosition, BlockData, MatchGroup } from "shared/types";

/** グリッド管理クラス */
export class GridManager {
	private blocks: Map<string, BlockData> = new Map();
	private gridFolder: Folder;

	constructor() {
		// Workspace内にグリッドフォルダを作成
		this.gridFolder = new Instance("Folder");
		this.gridFolder.Name = "RainbowGrid";
		this.gridFolder.Parent = game.Workspace;
	}

	/** グリッド座標をキー文字列に変換 */
	private gridToKey(gridPos: GridPosition): string {
		return `${gridPos.x},${gridPos.y},${gridPos.z}`;
	}

	/** グリッド座標 → ワールド座標変換 */
	gridToWorld(gridPos: GridPosition): Vector3 {
		const offsetX = (gridPos.x - (GRID_SIZE - 1) / 2) * STUD_SIZE;
		const offsetY = gridPos.y * STUD_SIZE;
		const offsetZ = (gridPos.z - (GRID_SIZE - 1) / 2) * STUD_SIZE;

		return GRID_CENTER_POSITION.add(new Vector3(offsetX, offsetY, offsetZ));
	}

	/** ワールド座標 → グリッド座標変換（スナップ） */
	worldToGrid(worldPos: Vector3): GridPosition | undefined {
		const relative = worldPos.sub(GRID_CENTER_POSITION);

		const x = math.floor(relative.X / STUD_SIZE + (GRID_SIZE - 1) / 2 + 0.5);
		const y = math.floor(relative.Y / STUD_SIZE + 0.5);
		const z = math.floor(relative.Z / STUD_SIZE + (GRID_SIZE - 1) / 2 + 0.5);

		// グリッド範囲チェック
		if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE && z >= 0 && z < GRID_SIZE) {
			return { x, y, z };
		}

		return undefined;
	}

	/** ブロック配置 */
	placeBlock(gridPos: GridPosition, colorIndex: number): boolean {
		const key = this.gridToKey(gridPos);

		// 既にブロックが存在する場合は配置しない
		if (this.blocks.has(key)) {
			return false;
		}

		// ブロックパーツを作成
		const part = new Instance("Part");
		part.Size = new Vector3(STUD_SIZE, STUD_SIZE, STUD_SIZE);
		part.Position = this.gridToWorld(gridPos);
		part.Anchored = true;
		part.Color = RAINBOW_COLORS[colorIndex];
		part.Material = Enum.Material.SmoothPlastic;
		part.Name = `Block_${key}`;
		part.Parent = this.gridFolder;

		// データ保存
		const blockData: BlockData = {
			gridPos,
			colorIndex,
			part,
		};
		this.blocks.set(key, blockData);

		return true;
	}

	/** ブロック破壊 */
	destroyBlock(gridPos: GridPosition): boolean {
		const key = this.gridToKey(gridPos);
		const blockData = this.blocks.get(key);

		if (!blockData) {
			return false;
		}

		// パーツを削除
		blockData.part.Destroy();
		this.blocks.delete(key);

		return true;
	}

	/** 指定Y層の全ブロックを取得 */
	getBlocksAtY(y: number): BlockData[] {
		const result: BlockData[] = [];

		for (const [_, blockData] of this.blocks) {
			if (blockData.gridPos.y === y) {
				result.push(blockData);
			}
		}

		return result;
	}

	/** 全ブロックを取得 */
	getAllBlocks(): Map<string, BlockData> {
		return this.blocks;
	}

	/** グリッド初期化（9x9x9をランダムな色で埋める） */
	initializeGrid(): void {
		print(`[GridManager] Starting grid initialization...`);

		// 既存ブロックをクリア
		for (const [_, blockData] of this.blocks) {
			blockData.part.Destroy();
		}
		this.blocks.clear();

		// 9x9x9グリッドをランダムな色で埋める
		let blockCount = 0;
		for (let x = 0; x < GRID_SIZE; x++) {
			for (let y = 0; y < GRID_SIZE; y++) {
				for (let z = 0; z < GRID_SIZE; z++) {
					const randomColor = math.floor(math.random() * COLOR_COUNT);
					const success = this.placeBlock({ x, y, z }, randomColor);
					if (success) {
						blockCount++;
					}
				}
			}
		}

		print(`[GridManager] Grid initialization complete! Created ${blockCount} blocks`);
		print(`[GridManager] Grid folder parent: ${this.gridFolder.Parent?.Name}`);
	}

	/** 指定位置の色を取得 */
	getColorAt(gridPos: GridPosition): number | undefined {
		const key = this.gridToKey(gridPos);
		const blockData = this.blocks.get(key);
		return blockData?.colorIndex;
	}

	/** 指定位置の色を設定 */
	setColorAt(gridPos: GridPosition, colorIndex: number): boolean {
		const key = this.gridToKey(gridPos);
		const blockData = this.blocks.get(key);

		if (!blockData) {
			return false;
		}

		blockData.colorIndex = colorIndex;
		blockData.part.Color = RAINBOW_COLORS[colorIndex];
		return true;
	}

	/** ブロック入れ替え */
	swapBlocks(gridPos1: GridPosition, gridPos2: GridPosition): boolean {
		const color1 = this.getColorAt(gridPos1);
		const color2 = this.getColorAt(gridPos2);

		if (color1 === undefined || color2 === undefined) {
			return false;
		}

		this.setColorAt(gridPos1, color2);
		this.setColorAt(gridPos2, color1);
		return true;
	}

	/** マッチ検出（3つ以上揃っている箇所を見つける） */
	detectMatches(): MatchGroup[] {
		const matchGroups: MatchGroup[] = [];

		// X軸方向のチェック
		for (let y = 0; y < GRID_SIZE; y++) {
			for (let z = 0; z < GRID_SIZE; z++) {
				let currentColor: number | undefined = undefined;
				let matchPositions: GridPosition[] = [];

				for (let x = 0; x < GRID_SIZE; x++) {
					const color = this.getColorAt({ x, y, z });

					if (color !== undefined && color === currentColor) {
						matchPositions.push({ x, y, z });
					} else {
						// マッチ判定
						if (matchPositions.size() >= MIN_MATCH_COUNT) {
							matchGroups.push({
								positions: matchPositions,
								colorIndex: currentColor!,
							});
						}

						// 新しいシーケンス開始
						currentColor = color;
						matchPositions = color !== undefined ? [{ x, y, z }] : [];
					}
				}

				// 最後のシーケンスチェック
				if (matchPositions.size() >= MIN_MATCH_COUNT) {
					matchGroups.push({
						positions: matchPositions,
						colorIndex: currentColor!,
					});
				}
			}
		}

		// Y軸方向のチェック
		for (let x = 0; x < GRID_SIZE; x++) {
			for (let z = 0; z < GRID_SIZE; z++) {
				let currentColor: number | undefined = undefined;
				let matchPositions: GridPosition[] = [];

				for (let y = 0; y < GRID_SIZE; y++) {
					const color = this.getColorAt({ x, y, z });

					if (color !== undefined && color === currentColor) {
						matchPositions.push({ x, y, z });
					} else {
						if (matchPositions.size() >= MIN_MATCH_COUNT) {
							matchGroups.push({
								positions: matchPositions,
								colorIndex: currentColor!,
							});
						}

						currentColor = color;
						matchPositions = color !== undefined ? [{ x, y, z }] : [];
					}
				}

				if (matchPositions.size() >= MIN_MATCH_COUNT) {
					matchGroups.push({
						positions: matchPositions,
						colorIndex: currentColor!,
					});
				}
			}
		}

		// Z軸方向のチェック
		for (let x = 0; x < GRID_SIZE; x++) {
			for (let y = 0; y < GRID_SIZE; y++) {
				let currentColor: number | undefined = undefined;
				let matchPositions: GridPosition[] = [];

				for (let z = 0; z < GRID_SIZE; z++) {
					const color = this.getColorAt({ x, y, z });

					if (color !== undefined && color === currentColor) {
						matchPositions.push({ x, y, z });
					} else {
						if (matchPositions.size() >= MIN_MATCH_COUNT) {
							matchGroups.push({
								positions: matchPositions,
								colorIndex: currentColor!,
							});
						}

						currentColor = color;
						matchPositions = color !== undefined ? [{ x, y, z }] : [];
					}
				}

				if (matchPositions.size() >= MIN_MATCH_COUNT) {
					matchGroups.push({
						positions: matchPositions,
						colorIndex: currentColor!,
					});
				}
			}
		}

		return matchGroups;
	}

	/** マッチしたブロックを削除 */
	removeBlocks(positions: GridPosition[]): void {
		for (const pos of positions) {
			this.destroyBlock(pos);
		}
	}

	/** 重力適用（空いた場所に上のブロックを落とす） */
	applyGravity(): boolean {
		let anyMoved = false;

		// 下から上へ、各X-Z列で処理
		for (let x = 0; x < GRID_SIZE; x++) {
			for (let z = 0; z < GRID_SIZE; z++) {
				// この列の空き詰め
				let writeY = 0;

				for (let readY = 0; readY < GRID_SIZE; readY++) {
					const color = this.getColorAt({ x, y: readY, z });

					if (color !== undefined) {
						if (readY !== writeY) {
							// ブロックを下に移動
							this.destroyBlock({ x, y: readY, z });
							this.placeBlock({ x, y: writeY, z }, color);
							anyMoved = true;
						}
						writeY++;
					}
				}
			}
		}

		return anyMoved;
	}

	/** 空いた上部を新しいブロックで埋める */
	fillEmpty(): void {
		for (let x = 0; x < GRID_SIZE; x++) {
			for (let z = 0; z < GRID_SIZE; z++) {
				for (let y = 0; y < GRID_SIZE; y++) {
					const color = this.getColorAt({ x, y, z });

					if (color === undefined) {
						const randomColor = math.floor(math.random() * COLOR_COUNT);
						this.placeBlock({ x, y, z }, randomColor);
					}
				}
			}
		}
	}

	/** 指定位置にブロックが存在するかチェック */
	hasBlockAt(gridPos: GridPosition): boolean {
		const key = this.gridToKey(gridPos);
		return this.blocks.has(key);
	}
}
