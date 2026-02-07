-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
-- Rainbow Cube - Match3 Game Manager
local MAX_REACH_HEIGHT = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "constants").MAX_REACH_HEIGHT
--* Match-3ゲームロジック管理 
local Match3Manager
do
	Match3Manager = setmetatable({}, {
		__tostring = function()
			return "Match3Manager"
		end,
	})
	Match3Manager.__index = Match3Manager
	function Match3Manager.new(...)
		local self = setmetatable({}, Match3Manager)
		return self:constructor(...) or self
	end
	function Match3Manager:constructor(gridManager)
		self.gridManager = gridManager
		self.gameState = {
			score = 0,
			moves = 0,
			matchCount = 0,
		}
	end
	function Match3Manager:getGameState()
		return self.gameState
	end
	function Match3Manager:resetScore()
		self.gameState.score = 0
		self.gameState.moves = 0
		self.gameState.matchCount = 0
	end
	function Match3Manager:areAdjacent(pos1, pos2)
		local dx = math.abs(pos1.x - pos2.x)
		local dy = math.abs(pos1.y - pos2.y)
		local dz = math.abs(pos1.z - pos2.z)
		-- 1軸だけが1つ離れている場合のみ隣接
		return (dx == 1 and dy == 0 and dz == 0) or (dx == 0 and dy == 1 and dz == 0) or (dx == 0 and dy == 0 and dz == 1)
	end
	function Match3Manager:isWithinReach(gridPos)
		return gridPos.y < MAX_REACH_HEIGHT
	end
	function Match3Manager:canSwap(pos1, pos2)
		-- 両方のブロックが存在するか
		if not self.gridManager:hasBlockAt(pos1) or not self.gridManager:hasBlockAt(pos2) then
			return false
		end
		-- 隣接しているか
		if not self:areAdjacent(pos1, pos2) then
			return false
		end
		-- 両方が手の届く範囲か
		if not self:isWithinReach(pos1) or not self:isWithinReach(pos2) then
			return false
		end
		return true
	end
	function Match3Manager:executeSwap(pos1, pos2)
		if not self:canSwap(pos1, pos2) then
			return nil
		end
		-- 交換実行
		self.gridManager:swapBlocks(pos1, pos2)
		self.gameState.moves += 1
		-- カスケード処理
		local cascadeResult = self:processCascade()
		-- マッチがなければ交換を戻す
		if #cascadeResult.matchedGroups == 0 then
			self.gridManager:swapBlocks(pos1, pos2)
			self.gameState.moves -= 1
			return nil
		end
		return cascadeResult
	end
	function Match3Manager:processCascade()
		local allMatchedGroups = {}
		local totalScore = 0
		local cascadeDepth = 0
		while true do
			-- マッチ検出
			local matches = self.gridManager:detectMatches()
			if #matches == 0 then
				break
			end
			cascadeDepth += 1
			-- マッチしたブロックを削除
			for _, matchGroup in matches do
				self.gridManager:removeBlocks(matchGroup.positions)
				table.insert(allMatchedGroups, matchGroup)
				-- スコア計算（長いほど高得点、カスケードボーナス）
				local baseScore = #matchGroup.positions * 10
				local cascadeBonus = cascadeDepth * 5
				totalScore += baseScore + cascadeBonus
			end
			-- 重力適用
			self.gridManager:applyGravity()
			-- 空いた場所を補充
			self.gridManager:fillEmpty()
			-- 少し待機（アニメーション用）
			task.wait(0.3)
		end
		-- ゲーム状態更新
		self.gameState.score += totalScore
		self.gameState.matchCount += #allMatchedGroups
		return {
			matchedGroups = allMatchedGroups,
			score = totalScore,
			cascadeDepth = cascadeDepth,
		}
	end
	function Match3Manager:initializeGame()
		print("[Match3Manager] Initializing game...")
		self.gridManager:initializeGrid()
		print("[Match3Manager] Grid initialized!")
		self:resetScore()
		-- 初期状態でマッチがある場合は解消（最大10回試行）
		local attempts = 0
		local maxAttempts = 10
		while attempts < maxAttempts do
			local matches = self.gridManager:detectMatches()
			print(`[Match3Manager] Found {#matches} initial matches, attempt {attempts + 1}`)
			if #matches == 0 then
				break
			end
			-- マッチを解消（ランダムに色を変更）
			for _, matchGroup in matches do
				for _1, pos in matchGroup.positions do
					local newColor = math.floor(math.random() * 7)
					self.gridManager:setColorAt(pos, newColor)
				end
			end
			attempts += 1
		end
		-- ▼ ReadonlyMap.size ▼
		local _size = 0
		for _ in self.gridManager:getAllBlocks() do
			_size += 1
		end
		-- ▲ ReadonlyMap.size ▲
		print(`[Match3Manager] Game initialized! Total blocks: {_size}`)
	end
end
return {
	Match3Manager = Match3Manager,
}
