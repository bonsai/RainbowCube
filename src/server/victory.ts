// Rainbow Tower Builder - Victory Checker

import { ReplicatedStorage } from "@rbxts/services";
import { GRID_SIZE, BLOCKS_PER_LAYER } from "shared/constants";
import { GridManager } from "./grid";

/** 勝利判定クラス */
export class VictoryChecker {
	private gridManager: GridManager;
	private victoryEvent: RemoteEvent;

	constructor(gridManager: GridManager) {
		this.gridManager = gridManager;

		// 勝利通知用のRemoteEventを作成
		this.victoryEvent = new Instance("RemoteEvent");
		this.victoryEvent.Name = "VictoryEvent";
		this.victoryEvent.Parent = ReplicatedStorage;
	}

	/** 指定Y層のチェック（正しい色で全て埋まっているか） */
	checkLayer(y: number): boolean {
		const blocksAtY = this.gridManager.getBlocksAtY(y);

		// ブロック数が足りない
		if (blocksAtY.size() !== BLOCKS_PER_LAYER) {
			return false;
		}

		// 全ブロックが正しい色（Y層に対応する色）であるかチェック
		for (const blockData of blocksAtY) {
			if (blockData.colorIndex !== y) {
				return false;
			}
		}

		return true;
	}

	/** 全層の勝利判定 */
	checkVictory(): boolean {
		for (let y = 0; y < GRID_SIZE; y++) {
			if (!this.checkLayer(y)) {
				return false;
			}
		}

		return true;
	}

	/** 勝利時の処理 */
	onVictory(): void {
		print("🌈 虹タワー完成！");

		// 全クライアントに勝利を通知
		this.victoryEvent.FireAllClients();
	}

	/** ブロック配置/破壊後にチェック */
	checkAndNotify(): void {
		if (this.checkVictory()) {
			this.onVictory();
		}
	}
}
