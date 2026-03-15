// Rainbow Tower Builder - Client Main Script

import { UIManager } from "./ui";
import { InputHandler } from "./input";
import { GRID_SIZE, STUD_SIZE, GRID_CENTER_POSITION } from "shared/constants";
import { GridPosition } from "shared/types";

// プレイヤーを取得
const player = game.Players.LocalPlayer;

if (!player) {
	error("LocalPlayer not found!");
}

// UIとInputを初期化
const uiManager = new UIManager(player);
const inputHandler = new InputHandler(player);

// ワールド座標→グリッド座標変換（サーバーと同じロジック）
function worldToGrid(worldPos: Vector3): GridPosition | undefined {
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

// InputHandlerにワールド→グリッド変換関数を設定
inputHandler.setWorldToGridCallback(worldToGrid);

// UIManagerの色選択をInputHandlerに連携
uiManager.onColorSelected((colorIndex) => {
	inputHandler.setSelectedColor(colorIndex);
});

// 勝利イベントのリスナー
const victoryEvent = game.ReplicatedStorage.WaitForChild("VictoryEvent") as RemoteEvent;
victoryEvent.OnClientEvent.Connect(() => {
	print("[Client] Victory event received!");
	uiManager.showVictory();
});

print("🌈 Rainbow Tower Builder Client Started!");
