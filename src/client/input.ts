// Rainbow Cube - Input Handler (Match-3)

import { ReplicatedStorage } from "@rbxts/services";
import { GridPosition, SwapBlocksArgs } from "shared/types";

/** 入力処理クラス（ブロック選択＆交換） */
export class InputHandler {
	private player: Player;
	private mouse: Mouse;
	private swapBlocksEvent: RemoteEvent;
	private worldToGridCallback?: (worldPos: Vector3) => GridPosition | undefined;

	private selectedBlock1?: GridPosition;
	private selectedBlock2?: GridPosition;
	private selectionChangedCallback?: (pos1: GridPosition | undefined, pos2: GridPosition | undefined) => void;

	constructor(player: Player) {
		this.player = player;
		this.mouse = player.GetMouse();

		// RemoteEventを取得
		this.swapBlocksEvent = ReplicatedStorage.WaitForChild("SwapBlocksEvent") as RemoteEvent;

		this.setupInputHandlers();
	}

	/** 入力ハンドラーを設定 */
	private setupInputHandlers(): void {
		// 左クリック（ブロック選択）
		this.mouse.Button1Down.Connect(() => {
			this.onLeftClick();
		});

		// 右クリック（選択解除）
		this.mouse.Button2Down.Connect(() => {
			this.onRightClick();
		});
	}

	/** 左クリック時の処理（ブロック選択） */
	private onLeftClick(): void {
		const hitPosition = this.mouse.Hit.Position;
		const gridPos = this.worldToGridCallback?.(hitPosition);

		if (!gridPos) {
			print(`[Input] Click outside grid`);
			return;
		}

		// 1つ目のブロックを選択
		if (!this.selectedBlock1) {
			this.selectedBlock1 = gridPos;
			print(`[Input] Selected first block at (${gridPos.x},${gridPos.y},${gridPos.z})`);
			this.notifySelectionChanged();
			return;
		}

		// 同じブロックをクリックした場合は選択解除
		if (this.isSamePosition(this.selectedBlock1, gridPos)) {
			print(`[Input] Deselected first block`);
			this.selectedBlock1 = undefined;
			this.notifySelectionChanged();
			return;
		}

		// 2つ目のブロックを選択して交換実行
		this.selectedBlock2 = gridPos;
		print(`[Input] Selected second block at (${gridPos.x},${gridPos.y},${gridPos.z})`);
		this.notifySelectionChanged();

		// 交換リクエスト送信
		this.sendSwapRequest();
	}

	/** 右クリック時の処理（選択解除） */
	private onRightClick(): void {
		if (this.selectedBlock1 || this.selectedBlock2) {
			print(`[Input] Selection cleared`);
			this.selectedBlock1 = undefined;
			this.selectedBlock2 = undefined;
			this.notifySelectionChanged();
		}
	}

	/** 2つの位置が同じかチェック */
	private isSamePosition(pos1: GridPosition, pos2: GridPosition): boolean {
		return pos1.x === pos2.x && pos1.y === pos2.y && pos1.z === pos2.z;
	}

	/** 交換リクエストを送信 */
	private sendSwapRequest(): void {
		if (!this.selectedBlock1 || !this.selectedBlock2) {
			return;
		}

		print(`[Input] Sending swap request`);

		const args: SwapBlocksArgs = {
			gridPos1: this.selectedBlock1,
			gridPos2: this.selectedBlock2,
		};

		this.swapBlocksEvent.FireServer(args);

		// 選択をクリア
		this.selectedBlock1 = undefined;
		this.selectedBlock2 = undefined;
		this.notifySelectionChanged();
	}

	/** 選択変更を通知 */
	private notifySelectionChanged(): void {
		this.selectionChangedCallback?.(this.selectedBlock1, this.selectedBlock2);
	}

	/** ワールド→グリッド座標変換コールバックを設定 */
	setWorldToGridCallback(callback: (worldPos: Vector3) => GridPosition | undefined): void {
		this.worldToGridCallback = callback;
	}

	/** 選択変更コールバックを設定 */
	setSelectionChangedCallback(callback: (pos1: GridPosition | undefined, pos2: GridPosition | undefined) => void): void {
		this.selectionChangedCallback = callback;
	}

	/** 現在の選択状態を取得 */
	getSelection(): [GridPosition | undefined, GridPosition | undefined] {
		return [this.selectedBlock1, this.selectedBlock2];
	}
}
