-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
-- Rainbow Cube - Client Main Script (Match-3)
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local RunService = _services.RunService
local UIManager = TS.import(script, script.Parent, "ui").UIManager
local InputHandler = TS.import(script, script.Parent, "input").InputHandler
local _constants = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "constants")
local GRID_SIZE = _constants.GRID_SIZE
local STUD_SIZE = _constants.STUD_SIZE
local GRID_CENTER_POSITION = _constants.GRID_CENTER_POSITION
-- プレイヤーを取得
local player = Players.LocalPlayer
if not player then
	error("LocalPlayer not found!")
end
-- UIとInputを初期化
local uiManager = UIManager.new(player)
local inputHandler = InputHandler.new(player)
-- ワールド座標→グリッド座標変換（サーバーと同じロジック）
local function worldToGrid(worldPos)
	local relative = worldPos - GRID_CENTER_POSITION
	local x = math.floor(relative.X / STUD_SIZE + (GRID_SIZE - 1) / 2 + 0.5)
	local y = math.floor(relative.Y / STUD_SIZE + 0.5)
	local z = math.floor(relative.Z / STUD_SIZE + (GRID_SIZE - 1) / 2 + 0.5)
	-- グリッド範囲チェック
	if x >= 0 and x < GRID_SIZE and y >= 0 and y < GRID_SIZE and z >= 0 and z < GRID_SIZE then
		return {
			x = x,
			y = y,
			z = z,
		}
	end
	return nil
end
-- InputHandlerにワールド→グリッド変換関数を設定
inputHandler:setWorldToGridCallback(worldToGrid)
-- 選択変更時にUIを更新
inputHandler:setSelectionChangedCallback(function(pos1, pos2)
	local selectedCount = (if pos1 then 1 else 0) + (if pos2 then 1 else 0)
	uiManager:updateSelectionInfo(selectedCount)
end)
-- RemoteEventsを取得
local getGameStateEvent = ReplicatedStorage:WaitForChild("GetGameStateEvent")
local initGameEvent = ReplicatedStorage:WaitForChild("InitGameEvent")
-- スタートボタンクリック時の処理
uiManager:setOnStartGameCallback(function()
	print("[Client] Sending init game request...")
	initGameEvent:FireServer()
end)
-- ゲーム状態を定期的にポーリング
RunService.Heartbeat:Connect(function()
	-- 1秒に1回更新
	if tick() % 1 < 0.016 then
		local success, gameState = pcall(function()
			return getGameStateEvent:InvokeServer()
		end)
		if success and gameState then
			uiManager:updateGameState(gameState)
		end
	end
end)
print("🌈 Rainbow Cube Match-3 Client Started!")
