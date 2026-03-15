// Rainbow Tower Builder - Server Main Script

import { GridManager } from "./grid";
import { VictoryChecker } from "./victory";
import { PlaceBlockArgs, DestroyBlockArgs } from "shared/types";

// GridManagerとVictoryCheckerを初期化
const gridManager = new GridManager();
const victoryChecker = new VictoryChecker(gridManager);

// RemoteEventsを作成
const placeBlockEvent = new Instance("RemoteEvent");
placeBlockEvent.Name = "PlaceBlockEvent";
placeBlockEvent.Parent = game.ReplicatedStorage;

const destroyBlockEvent = new Instance("RemoteEvent");
destroyBlockEvent.Name = "DestroyBlockEvent";
destroyBlockEvent.Parent = game.ReplicatedStorage;

// ブロック配置イベント
placeBlockEvent.OnServerEvent.Connect((player, args: PlaceBlockArgs) => {
	const { gridPos, colorIndex } = args;

	print(`[Server] PlaceBlock request from ${player.Name} at (${gridPos.x},${gridPos.y},${gridPos.z}) color=${colorIndex}`);

	const success = gridManager.placeBlock(gridPos, colorIndex);

	if (success) {
		print(`[Server] Block placed successfully`);
		// 配置後に勝利判定
		victoryChecker.checkAndNotify();
	} else {
		print(`[Server] Block placement failed (already exists)`);
	}
});

// ブロック破壊イベント
destroyBlockEvent.OnServerEvent.Connect((player, args: DestroyBlockArgs) => {
	const { gridPos } = args;

	print(`[Server] DestroyBlock request from ${player.Name} at (${gridPos.x},${gridPos.y},${gridPos.z})`);

	const success = gridManager.destroyBlock(gridPos);

	if (success) {
		print(`[Server] Block destroyed successfully`);
	} else {
		print(`[Server] Block destruction failed (does not exist)`);
	}
});

print("🌈 Rainbow Tower Builder Server Started!");
