// Rainbow Cube - Match3 Game Manager

import { GridManager } from "./grid";
import { GridPosition, GameState, CascadeResult, MatchGroup } from "shared/types";
import { MAX_REACH_HEIGHT } from "shared/constants";

/** Match-3ゲームロジック管理 */
export class Match3Manager {
	private gridManager: GridManager;
	private gameState: GameState;

	constructor(gridManager: GridManager) {
		this.gridManager = gridManager;
		this.gameState = {
			score: 0,
			moves: 0,
			matchCount: 0,
		};
	}

	/** ゲーム状態を取得 */
	getGameState(): GameState {
		return this.gameState;
	}

	/** スコアをリセット */
	resetScore(): void {
		this.gameState.score = 0;
		this.gameState.moves = 0;
		this.gameState.matchCount = 0;
	}

	/** 2つのブロックが隣接しているかチェック */
	private areAdjacent(pos1: GridPosition, pos2: GridPosition): boolean {
		const dx = math.abs(pos1.x - pos2.x);
		const dy = math.abs(pos1.y - pos2.y);
		const dz = math.abs(pos1.z - pos2.z);

		// 1軸だけが1つ離れている場合のみ隣接
		return (dx === 1 && dy === 0 && dz === 0) || (dx === 0 && dy === 1 && dz === 0) || (dx === 0 && dy === 0 && dz === 1);
	}

	/** ブロックが手の届く範囲内かチェック */
	private isWithinReach(gridPos: GridPosition): boolean {
		return gridPos.y < MAX_REACH_HEIGHT;
	}

	/** 交換可能かチェック */
	canSwap(pos1: GridPosition, pos2: GridPosition): boolean {
		// 両方のブロックが存在するか
		if (!this.gridManager.hasBlockAt(pos1) || !this.gridManager.hasBlockAt(pos2)) {
			return false;
		}

		// 隣接しているか
		if (!this.areAdjacent(pos1, pos2)) {
			return false;
		}

		// 両方が手の届く範囲か
		if (!this.isWithinReach(pos1) || !this.isWithinReach(pos2)) {
			return false;
		}

		return true;
	}

	/** ブロック交換を実行 */
	executeSwap(pos1: GridPosition, pos2: GridPosition): CascadeResult | undefined {
		if (!this.canSwap(pos1, pos2)) {
			return undefined;
		}

		// 交換実行
		this.gridManager.swapBlocks(pos1, pos2);
		this.gameState.moves++;

		// カスケード処理
		const cascadeResult = this.processCascade();

		// マッチがなければ交換を戻す
		if (cascadeResult.matchedGroups.size() === 0) {
			this.gridManager.swapBlocks(pos1, pos2);
			this.gameState.moves--;
			return undefined;
		}

		return cascadeResult;
	}

	/** カスケード処理（マッチ→削除→重力→補充を繰り返す） */
	processCascade(): CascadeResult {
		const allMatchedGroups: MatchGroup[] = [];
		let totalScore = 0;
		let cascadeDepth = 0;

		while (true) {
			// マッチ検出
			const matches = this.gridManager.detectMatches();

			if (matches.size() === 0) {
				break;
			}

			cascadeDepth++;

			// マッチしたブロックを削除
			for (const matchGroup of matches) {
				this.gridManager.removeBlocks(matchGroup.positions);
				allMatchedGroups.push(matchGroup);

				// スコア計算（長いほど高得点、カスケードボーナス）
				const baseScore = matchGroup.positions.size() * 10;
				const cascadeBonus = cascadeDepth * 5;
				totalScore += baseScore + cascadeBonus;
			}

			// 重力適用
			this.gridManager.applyGravity();

			// 空いた場所を補充
			this.gridManager.fillEmpty();

			// 少し待機（アニメーション用）
			task.wait(0.3);
		}

		// ゲーム状態更新
		this.gameState.score += totalScore;
		this.gameState.matchCount += allMatchedGroups.size();

		return {
			matchedGroups: allMatchedGroups,
			score: totalScore,
			cascadeDepth,
		};
	}

	/** ゲーム初期化 */
	initializeGame(): void {
		print("[Match3Manager] Initializing game...");
		this.gridManager.initializeGrid();
		print("[Match3Manager] Grid initialized!");
		this.resetScore();

		// 初期状態でマッチがある場合は解消（最大10回試行）
		let attempts = 0;
		const maxAttempts = 10;

		while (attempts < maxAttempts) {
			const matches = this.gridManager.detectMatches();
			print(`[Match3Manager] Found ${matches.size()} initial matches, attempt ${attempts + 1}`);

			if (matches.size() === 0) {
				break;
			}

			// マッチを解消（ランダムに色を変更）
			for (const matchGroup of matches) {
				for (const pos of matchGroup.positions) {
					const newColor = math.floor(math.random() * 7);
					this.gridManager.setColorAt(pos, newColor);
				}
			}

			attempts++;
		}

		print(`[Match3Manager] Game initialized! Total blocks: ${this.gridManager.getAllBlocks().size()}`);
	}
}
