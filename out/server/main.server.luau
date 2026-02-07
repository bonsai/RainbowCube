-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
-- Rainbow Cube - Match-3 Game Server
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "node_modules", "@rbxts", "services").ReplicatedStorage
local GridManager = TS.import(script, game:GetService("ServerScriptService"), "Server", "grid").GridManager
local Match3Manager = TS.import(script, game:GetService("ServerScriptService"), "Server", "match3").Match3Manager
-- GridManagerとMatch3Managerを初期化
local gridManager = GridManager.new()
local match3Manager = Match3Manager.new(gridManager)
-- RemoteEventsを作成
local swapBlocksEvent = Instance.new("RemoteEvent")
swapBlocksEvent.Name = "SwapBlocksEvent"
swapBlocksEvent.Parent = ReplicatedStorage
local getGameStateEvent = Instance.new("RemoteFunction")
getGameStateEvent.Name = "GetGameStateEvent"
getGameStateEvent.Parent = ReplicatedStorage
local initGameEvent = Instance.new("RemoteEvent")
initGameEvent.Name = "InitGameEvent"
initGameEvent.Parent = ReplicatedStorage
-- ブロック交換イベント
swapBlocksEvent.OnServerEvent:Connect(function(player, ...)
	local args = { ... }
	local _binding = args[1]
	local gridPos1 = _binding.gridPos1
	local gridPos2 = _binding.gridPos2
	print(`[Server] SwapBlocks request from {player.Name}`)
	print(`  Position 1: ({gridPos1.x},{gridPos1.y},{gridPos1.z})`)
	print(`  Position 2: ({gridPos2.x},{gridPos2.y},{gridPos2.z})`)
	local cascadeResult = match3Manager:executeSwap(gridPos1, gridPos2)
	if cascadeResult then
		print(`[Server] Swap successful!`)
		print(`  Matches: {#cascadeResult.matchedGroups}`)
		print(`  Score: {cascadeResult.score}`)
		print(`  Cascade depth: {cascadeResult.cascadeDepth}`)
		-- ゲーム状態を全クライアントに送信
		local gameState = match3Manager:getGameState()
		print(`[Server] Total Score: {gameState.score}, Moves: {gameState.moves}, Matches: {gameState.matchCount}`)
	else
		print(`[Server] Swap failed (invalid move)`)
	end
end)
-- ゲーム状態取得
getGameStateEvent.OnServerInvoke = function()
	return match3Manager:getGameState()
end
-- ゲーム初期化イベント
initGameEvent.OnServerEvent:Connect(function(player)
	print(`[Server] InitGame request from {player.Name}`)
	match3Manager:initializeGame()
	print(`[Server] Game initialized with 9x9x9 grid`)
end)
-- サーバー起動
print("🌈 Rainbow Cube Match-3 Server Starting...")
-- [DEV] テスト用に自動的にゲームを初期化
print("[DEV] Auto-starting game for testing...")
task.wait(2)
match3Manager:initializeGame()
print("✓ Server ready!")
print("✓ Waiting for players to start the game...")
