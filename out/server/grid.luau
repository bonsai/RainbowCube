-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
-- Rainbow Tower Builder - Grid Manager
local _constants = TS.import(script, game:GetService("ReplicatedStorage"), "Shared", "constants")
local GRID_SIZE = _constants.GRID_SIZE
local STUD_SIZE = _constants.STUD_SIZE
local RAINBOW_COLORS = _constants.RAINBOW_COLORS
local GRID_CENTER_POSITION = _constants.GRID_CENTER_POSITION
local COLOR_COUNT = _constants.COLOR_COUNT
local MIN_MATCH_COUNT = _constants.MIN_MATCH_COUNT
--* グリッド管理クラス 
local GridManager
do
	GridManager = setmetatable({}, {
		__tostring = function()
			return "GridManager"
		end,
	})
	GridManager.__index = GridManager
	function GridManager.new(...)
		local self = setmetatable({}, GridManager)
		return self:constructor(...) or self
	end
	function GridManager:constructor()
		self.blocks = {}
		-- Workspace内にグリッドフォルダを作成
		self.gridFolder = Instance.new("Folder")
		self.gridFolder.Name = "RainbowGrid"
		self.gridFolder.Parent = game.Workspace
	end
	function GridManager:gridToKey(gridPos)
		return `{gridPos.x},{gridPos.y},{gridPos.z}`
	end
	function GridManager:gridToWorld(gridPos)
		local offsetX = (gridPos.x - (GRID_SIZE - 1) / 2) * STUD_SIZE
		local offsetY = gridPos.y * STUD_SIZE
		local offsetZ = (gridPos.z - (GRID_SIZE - 1) / 2) * STUD_SIZE
		local _vector3 = Vector3.new(offsetX, offsetY, offsetZ)
		return GRID_CENTER_POSITION + _vector3
	end
	function GridManager:worldToGrid(worldPos)
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
	function GridManager:placeBlock(gridPos, colorIndex)
		local key = self:gridToKey(gridPos)
		-- 既にブロックが存在する場合は配置しない
		if self.blocks[key] ~= nil then
			return false
		end
		-- ブロックパーツを作成
		local part = Instance.new("Part")
		part.Size = Vector3.new(STUD_SIZE, STUD_SIZE, STUD_SIZE)
		part.Position = self:gridToWorld(gridPos)
		part.Anchored = true
		part.Color = RAINBOW_COLORS[colorIndex + 1]
		part.Material = Enum.Material.SmoothPlastic
		part.Name = `Block_{key}`
		part.Parent = self.gridFolder
		-- データ保存
		local blockData = {
			gridPos = gridPos,
			colorIndex = colorIndex,
			part = part,
		}
		self.blocks[key] = blockData
		return true
	end
	function GridManager:destroyBlock(gridPos)
		local key = self:gridToKey(gridPos)
		local blockData = self.blocks[key]
		if not blockData then
			return false
		end
		-- パーツを削除
		blockData.part:Destroy()
		self.blocks[key] = nil
		return true
	end
	function GridManager:getBlocksAtY(y)
		local result = {}
		for _, blockData in self.blocks do
			if blockData.gridPos.y == y then
				table.insert(result, blockData)
			end
		end
		return result
	end
	function GridManager:getAllBlocks()
		return self.blocks
	end
	function GridManager:initializeGrid()
		print(`[GridManager] Starting grid initialization...`)
		-- 既存ブロックをクリア
		for _, blockData in self.blocks do
			blockData.part:Destroy()
		end
		table.clear(self.blocks)
		-- 9x9x9グリッドをランダムな色で埋める
		local blockCount = 0
		for x = 0, GRID_SIZE - 1 do
			for y = 0, GRID_SIZE - 1 do
				for z = 0, GRID_SIZE - 1 do
					local randomColor = math.floor(math.random() * COLOR_COUNT)
					local success = self:placeBlock({
						x = x,
						y = y,
						z = z,
					}, randomColor)
					if success then
						blockCount += 1
					end
				end
			end
		end
		print(`[GridManager] Grid initialization complete! Created {blockCount} blocks`)
		local _result = self.gridFolder.Parent
		if _result ~= nil then
			_result = _result.Name
		end
		print(`[GridManager] Grid folder parent: {_result}`)
	end
	function GridManager:getColorAt(gridPos)
		local key = self:gridToKey(gridPos)
		local blockData = self.blocks[key]
		local _result = blockData
		if _result ~= nil then
			_result = _result.colorIndex
		end
		return _result
	end
	function GridManager:setColorAt(gridPos, colorIndex)
		local key = self:gridToKey(gridPos)
		local blockData = self.blocks[key]
		if not blockData then
			return false
		end
		blockData.colorIndex = colorIndex
		blockData.part.Color = RAINBOW_COLORS[colorIndex + 1]
		return true
	end
	function GridManager:swapBlocks(gridPos1, gridPos2)
		local color1 = self:getColorAt(gridPos1)
		local color2 = self:getColorAt(gridPos2)
		if color1 == nil or color2 == nil then
			return false
		end
		self:setColorAt(gridPos1, color2)
		self:setColorAt(gridPos2, color1)
		return true
	end
	function GridManager:detectMatches()
		local matchGroups = {}
		-- X軸方向のチェック
		for y = 0, GRID_SIZE - 1 do
			for z = 0, GRID_SIZE - 1 do
				local currentColor = nil
				local matchPositions = {}
				for x = 0, GRID_SIZE - 1 do
					local color = self:getColorAt({
						x = x,
						y = y,
						z = z,
					})
					if color ~= nil and color == currentColor then
						local _matchPositions = matchPositions
						local _arg0 = {
							x = x,
							y = y,
							z = z,
						}
						table.insert(_matchPositions, _arg0)
					else
						-- マッチ判定
						if #matchPositions >= MIN_MATCH_COUNT then
							local _arg0 = {
								positions = matchPositions,
								colorIndex = currentColor,
							}
							table.insert(matchGroups, _arg0)
						end
						-- 新しいシーケンス開始
						currentColor = color
						matchPositions = if color ~= nil then { {
							x = x,
							y = y,
							z = z,
						} } else {}
					end
				end
				-- 最後のシーケンスチェック
				if #matchPositions >= MIN_MATCH_COUNT then
					local _arg0 = {
						positions = matchPositions,
						colorIndex = currentColor,
					}
					table.insert(matchGroups, _arg0)
				end
			end
		end
		-- Y軸方向のチェック
		for x = 0, GRID_SIZE - 1 do
			for z = 0, GRID_SIZE - 1 do
				local currentColor = nil
				local matchPositions = {}
				for y = 0, GRID_SIZE - 1 do
					local color = self:getColorAt({
						x = x,
						y = y,
						z = z,
					})
					if color ~= nil and color == currentColor then
						local _matchPositions = matchPositions
						local _arg0 = {
							x = x,
							y = y,
							z = z,
						}
						table.insert(_matchPositions, _arg0)
					else
						if #matchPositions >= MIN_MATCH_COUNT then
							local _arg0 = {
								positions = matchPositions,
								colorIndex = currentColor,
							}
							table.insert(matchGroups, _arg0)
						end
						currentColor = color
						matchPositions = if color ~= nil then { {
							x = x,
							y = y,
							z = z,
						} } else {}
					end
				end
				if #matchPositions >= MIN_MATCH_COUNT then
					local _arg0 = {
						positions = matchPositions,
						colorIndex = currentColor,
					}
					table.insert(matchGroups, _arg0)
				end
			end
		end
		-- Z軸方向のチェック
		for x = 0, GRID_SIZE - 1 do
			for y = 0, GRID_SIZE - 1 do
				local currentColor = nil
				local matchPositions = {}
				for z = 0, GRID_SIZE - 1 do
					local color = self:getColorAt({
						x = x,
						y = y,
						z = z,
					})
					if color ~= nil and color == currentColor then
						local _matchPositions = matchPositions
						local _arg0 = {
							x = x,
							y = y,
							z = z,
						}
						table.insert(_matchPositions, _arg0)
					else
						if #matchPositions >= MIN_MATCH_COUNT then
							local _arg0 = {
								positions = matchPositions,
								colorIndex = currentColor,
							}
							table.insert(matchGroups, _arg0)
						end
						currentColor = color
						matchPositions = if color ~= nil then { {
							x = x,
							y = y,
							z = z,
						} } else {}
					end
				end
				if #matchPositions >= MIN_MATCH_COUNT then
					local _arg0 = {
						positions = matchPositions,
						colorIndex = currentColor,
					}
					table.insert(matchGroups, _arg0)
				end
			end
		end
		return matchGroups
	end
	function GridManager:removeBlocks(positions)
		for _, pos in positions do
			self:destroyBlock(pos)
		end
	end
	function GridManager:applyGravity()
		local anyMoved = false
		-- 下から上へ、各X-Z列で処理
		for x = 0, GRID_SIZE - 1 do
			for z = 0, GRID_SIZE - 1 do
				-- この列の空き詰め
				local writeY = 0
				for readY = 0, GRID_SIZE - 1 do
					local color = self:getColorAt({
						x = x,
						y = readY,
						z = z,
					})
					if color ~= nil then
						if readY ~= writeY then
							-- ブロックを下に移動
							self:destroyBlock({
								x = x,
								y = readY,
								z = z,
							})
							self:placeBlock({
								x = x,
								y = writeY,
								z = z,
							}, color)
							anyMoved = true
						end
						writeY += 1
					end
				end
			end
		end
		return anyMoved
	end
	function GridManager:fillEmpty()
		for x = 0, GRID_SIZE - 1 do
			for z = 0, GRID_SIZE - 1 do
				for y = 0, GRID_SIZE - 1 do
					local color = self:getColorAt({
						x = x,
						y = y,
						z = z,
					})
					if color == nil then
						local randomColor = math.floor(math.random() * COLOR_COUNT)
						self:placeBlock({
							x = x,
							y = y,
							z = z,
						}, randomColor)
					end
				end
			end
		end
	end
	function GridManager:hasBlockAt(gridPos)
		local key = self:gridToKey(gridPos)
		return self.blocks[key] ~= nil
	end
end
return {
	GridManager = GridManager,
}
