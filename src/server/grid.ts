// Rainbow Tower Builder - Grid Manager

import { GRID_SIZE, STUD_SIZE, RAINBOW_COLORS, GRID_CENTER_POSITION } from "shared/constants";
import { GridPosition, BlockData } from "shared/types";

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
}
