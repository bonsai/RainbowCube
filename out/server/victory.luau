-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
-- Rainbow Tower Builder - Victory Checker
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "node_modules", "@rbxts", "services").ReplicatedStorage
local _constants = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "constants")
local GRID_SIZE = _constants.GRID_SIZE
local BLOCKS_PER_LAYER = _constants.BLOCKS_PER_LAYER
--* 勝利判定クラス 
local VictoryChecker
do
	VictoryChecker = setmetatable({}, {
		__tostring = function()
			return "VictoryChecker"
		end,
	})
	VictoryChecker.__index = VictoryChecker
	function VictoryChecker.new(...)
		local self = setmetatable({}, VictoryChecker)
		return self:constructor(...) or self
	end
	function VictoryChecker:constructor(gridManager)
		self.gridManager = gridManager
		-- 勝利通知用のRemoteEventを作成
		self.victoryEvent = Instance.new("RemoteEvent")
		self.victoryEvent.Name = "VictoryEvent"
		self.victoryEvent.Parent = ReplicatedStorage
	end
	function VictoryChecker:checkLayer(y)
		local blocksAtY = self.gridManager:getBlocksAtY(y)
		-- ブロック数が足りない
		if #blocksAtY ~= BLOCKS_PER_LAYER then
			return false
		end
		-- 全ブロックが正しい色（Y層に対応する色）であるかチェック
		for _, blockData in blocksAtY do
			if blockData.colorIndex ~= y then
				return false
			end
		end
		return true
	end
	function VictoryChecker:checkVictory()
		for y = 0, GRID_SIZE - 1 do
			if not self:checkLayer(y) then
				return false
			end
		end
		return true
	end
	function VictoryChecker:onVictory()
		print("🌈 虹タワー完成！")
		-- 全クライアントに勝利を通知
		self.victoryEvent:FireAllClients()
	end
	function VictoryChecker:checkAndNotify()
		if self:checkVictory() then
			self:onVictory()
		end
	end
end
return {
	VictoryChecker = VictoryChecker,
}
