-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
-- Rainbow Cube - Input Handler (Match-3)
local ReplicatedStorage = TS.import(script, game:GetService("ReplicatedStorage"), "node_modules", "@rbxts", "services").ReplicatedStorage
--* 入力処理クラス（ブロック選択＆交換） 
local InputHandler
do
	InputHandler = setmetatable({}, {
		__tostring = function()
			return "InputHandler"
		end,
	})
	InputHandler.__index = InputHandler
	function InputHandler.new(...)
		local self = setmetatable({}, InputHandler)
		return self:constructor(...) or self
	end
	function InputHandler:constructor(player)
		self.player = player
		self.mouse = player:GetMouse()
		-- RemoteEventを取得
		self.swapBlocksEvent = ReplicatedStorage:WaitForChild("SwapBlocksEvent")
		self:setupInputHandlers()
	end
	function InputHandler:setupInputHandlers()
		-- 左クリック（ブロック選択）
		self.mouse.Button1Down:Connect(function()
			self:onLeftClick()
		end)
		-- 右クリック（選択解除）
		self.mouse.Button2Down:Connect(function()
			self:onRightClick()
		end)
	end
	function InputHandler:onLeftClick()
		local hitPosition = self.mouse.Hit.Position
		local _gridPos = self.worldToGridCallback
		if _gridPos ~= nil then
			_gridPos = _gridPos(hitPosition)
		end
		local gridPos = _gridPos
		if not gridPos then
			print(`[Input] Click outside grid`)
			return nil
		end
		-- 1つ目のブロックを選択
		if not self.selectedBlock1 then
			self.selectedBlock1 = gridPos
			print(`[Input] Selected first block at ({gridPos.x},{gridPos.y},{gridPos.z})`)
			self:notifySelectionChanged()
			return nil
		end
		-- 同じブロックをクリックした場合は選択解除
		if self:isSamePosition(self.selectedBlock1, gridPos) then
			print(`[Input] Deselected first block`)
			self.selectedBlock1 = nil
			self:notifySelectionChanged()
			return nil
		end
		-- 2つ目のブロックを選択して交換実行
		self.selectedBlock2 = gridPos
		print(`[Input] Selected second block at ({gridPos.x},{gridPos.y},{gridPos.z})`)
		self:notifySelectionChanged()
		-- 交換リクエスト送信
		self:sendSwapRequest()
	end
	function InputHandler:onRightClick()
		if self.selectedBlock1 or self.selectedBlock2 then
			print(`[Input] Selection cleared`)
			self.selectedBlock1 = nil
			self.selectedBlock2 = nil
			self:notifySelectionChanged()
		end
	end
	function InputHandler:isSamePosition(pos1, pos2)
		return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
	end
	function InputHandler:sendSwapRequest()
		if not self.selectedBlock1 or not self.selectedBlock2 then
			return nil
		end
		print(`[Input] Sending swap request`)
		local args = {
			gridPos1 = self.selectedBlock1,
			gridPos2 = self.selectedBlock2,
		}
		self.swapBlocksEvent:FireServer(args)
		-- 選択をクリア
		self.selectedBlock1 = nil
		self.selectedBlock2 = nil
		self:notifySelectionChanged()
	end
	function InputHandler:notifySelectionChanged()
		local _result = self.selectionChangedCallback
		if _result ~= nil then
			_result(self.selectedBlock1, self.selectedBlock2)
		end
	end
	function InputHandler:setWorldToGridCallback(callback)
		self.worldToGridCallback = callback
	end
	function InputHandler:setSelectionChangedCallback(callback)
		self.selectionChangedCallback = callback
	end
	function InputHandler:getSelection()
		return { self.selectedBlock1, self.selectedBlock2 }
	end
end
return {
	InputHandler = InputHandler,
}
