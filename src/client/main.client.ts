// Rainbow Cube - Client Main Script (Match-3)

import { Players, ReplicatedStorage, RunService } from "@rbxts/services";
import { UIManager } from "./ui";
import { InputHandler } from "./input";
import { GRID_SIZE, STUD_SIZE, GRID_CENTER_POSITION } from "shared/constants";
import { GridPosition, GameState } from "shared/types";

// プレイヤーを取得
const player = Players.LocalPlayer;

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

// 選択変更時にUIを更新
inputHandler.setSelectionChangedCallback((pos1, pos2) => {
	const selectedCount = (pos1 ? 1 : 0) + (pos2 ? 1 : 0);
	uiManager.updateSelectionInfo(selectedCount);
});

// RemoteEventsを取得
const getGameStateEvent = ReplicatedStorage.WaitForChild("GetGameStateEvent") as RemoteFunction;
const initGameEvent = ReplicatedStorage.WaitForChild("InitGameEvent") as RemoteEvent;

// スタートボタンクリック時の処理
uiManager.setOnStartGameCallback(() => {
	print("[Client] Sending init game request...");
	initGameEvent.FireServer();
});

// ゲーム状態を定期的にポーリング
RunService.Heartbeat.Connect(() => {
	// 1秒に1回更新
	if (tick() % 1 < 0.016) {
		const [success, gameState] = pcall(() => {
			return getGameStateEvent.InvokeServer() as GameState;
		});

		if (success && gameState) {
			uiManager.updateGameState(gameState);
		}
	}
});

print("🌈 Rainbow Cube Match-3 Client Started!");
