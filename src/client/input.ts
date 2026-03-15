// Rainbow Tower Builder - Input Handler

import { GridPosition, PlaceBlockArgs, DestroyBlockArgs } from "shared/types";

/** 入力処理クラス */
export class InputHandler {
	private player: Player;
	private mouse: Mouse;
	private selectedColorIndex = 0;
	private placeBlockEvent: RemoteEvent;
	private destroyBlockEvent: RemoteEvent;
	private worldToGridCallback?: (worldPos: Vector3) => GridPosition | undefined;

	constructor(player: Player) {
		this.player = player;
		this.mouse = player.GetMouse();

		// RemoteEventsを取得
		this.placeBlockEvent = game.ReplicatedStorage.WaitForChild("PlaceBlockEvent") as RemoteEvent;
		this.destroyBlockEvent = game.ReplicatedStorage.WaitForChild("DestroyBlockEvent") as RemoteEvent;

		this.setupInputHandlers();
	}

	/** 入力ハンドラーを設定 */
	private setupInputHandlers(): void {
		// 左クリック（ブロック配置）
		this.mouse.Button1Down.Connect(() => {
			this.onLeftClick();
		});

		// 右クリック（ブロック破壊）
		this.mouse.Button2Down.Connect(() => {
			this.onRightClick();
		});
	}

	/** 左クリック時の処理（ブロック配置） */
	private onLeftClick(): void {
		const hitPosition = this.mouse.Hit.Position;
		const gridPos = this.worldToGridCallback?.(hitPosition);

		if (gridPos) {
			print(`[Input] Left click at grid (${gridPos.x},${gridPos.y},${gridPos.z}) with color ${this.selectedColorIndex}`);

			const args: PlaceBlockArgs = {
				gridPos,
				colorIndex: this.selectedColorIndex,
			};

			this.placeBlockEvent.FireServer(args);
		} else {
			print(`[Input] Left click outside grid`);
		}
	}

	/** 右クリック時の処理（ブロック破壊） */
	private onRightClick(): void {
		const hitPosition = this.mouse.Hit.Position;
		const gridPos = this.worldToGridCallback?.(hitPosition);

		if (gridPos) {
			print(`[Input] Right click at grid (${gridPos.x},${gridPos.y},${gridPos.z})`);

			const args: DestroyBlockArgs = {
				gridPos,
			};

			this.destroyBlockEvent.FireServer(args);
		} else {
			print(`[Input] Right click outside grid`);
		}
	}

	/** 選択色を設定 */
	setSelectedColor(colorIndex: number): void {
		this.selectedColorIndex = colorIndex;
		print(`[Input] Selected color changed to ${colorIndex}`);
	}

	/** ワールド→グリッド座標変換コールバックを設定 */
	setWorldToGridCallback(callback: (worldPos: Vector3) => GridPosition | undefined): void {
		this.worldToGridCallback = callback;
	}
}
