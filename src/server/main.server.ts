// Rainbow Cube - Match-3 Game Server

import { ReplicatedStorage } from "@rbxts/services";
import { GridManager } from "./grid";
import { Match3Manager } from "./match3";
import { SwapBlocksArgs } from "shared/types";

// GridManagerとMatch3Managerを初期化
const gridManager = new GridManager();
const match3Manager = new Match3Manager(gridManager);

// RemoteEventsを作成
const swapBlocksEvent = new Instance("RemoteEvent");
swapBlocksEvent.Name = "SwapBlocksEvent";
swapBlocksEvent.Parent = ReplicatedStorage;

const getGameStateEvent = new Instance("RemoteFunction");
getGameStateEvent.Name = "GetGameStateEvent";
getGameStateEvent.Parent = ReplicatedStorage;

const initGameEvent = new Instance("RemoteEvent");
initGameEvent.Name = "InitGameEvent";
initGameEvent.Parent = ReplicatedStorage;

// ブロック交換イベント
swapBlocksEvent.OnServerEvent.Connect((player, ...args) => {
	const { gridPos1, gridPos2 } = args[0] as SwapBlocksArgs;

	print(`[Server] SwapBlocks request from ${player.Name}`);
	print(`  Position 1: (${gridPos1.x},${gridPos1.y},${gridPos1.z})`);
	print(`  Position 2: (${gridPos2.x},${gridPos2.y},${gridPos2.z})`);

	const cascadeResult = match3Manager.executeSwap(gridPos1, gridPos2);

	if (cascadeResult) {
		print(`[Server] Swap successful!`);
		print(`  Matches: ${cascadeResult.matchedGroups.size()}`);
		print(`  Score: ${cascadeResult.score}`);
		print(`  Cascade depth: ${cascadeResult.cascadeDepth}`);

		// ゲーム状態を全クライアントに送信
		const gameState = match3Manager.getGameState();
		print(`[Server] Total Score: ${gameState.score}, Moves: ${gameState.moves}, Matches: ${gameState.matchCount}`);
	} else {
		print(`[Server] Swap failed (invalid move)`);
	}
});

// ゲーム状態取得
getGameStateEvent.OnServerInvoke = () => {
	return match3Manager.getGameState();
};

// ゲーム初期化イベント
initGameEvent.OnServerEvent.Connect((player) => {
	print(`[Server] InitGame request from ${player.Name}`);
	match3Manager.initializeGame();
	print(`[Server] Game initialized with 9x9x9 grid`);
});

// サーバー起動
print("🌈 Rainbow Cube Match-3 Server Starting...");

// [DEV] テスト用に自動的にゲームを初期化
print("[DEV] Auto-starting game for testing...");
task.wait(2); // サーバー起動待ち
match3Manager.initializeGame();

print("✓ Server ready!");
print("✓ Waiting for players to start the game...");
