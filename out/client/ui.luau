-- Compiled with roblox-ts v3.0.0
-- Rainbow Cube - UI Manager (Match-3)
--* UI管理クラス（ゲーム状態表示） 
local UIManager
do
	UIManager = setmetatable({}, {
		__tostring = function()
			return "UIManager"
		end,
	})
	UIManager.__index = UIManager
	function UIManager.new(...)
		local self = setmetatable({}, UIManager)
		return self:constructor(...) or self
	end
	function UIManager:constructor(player)
		-- ScreenGuiを作成
		self.screenGui = Instance.new("ScreenGui")
		self.screenGui.Name = "RainbowCubeUI"
		self.screenGui.ResetOnSpawn = false
		self.screenGui.Parent = player:WaitForChild("PlayerGui")
		-- 各UIラベルを作成
		self.scoreLabel = self:createGameStateUI()
		self.movesLabel = self:createMovesUI()
		self.matchesLabel = self:createMatchesUI()
		self.instructionLabel = self:createInstructionUI()
		self.startButton = self:createStartButton()
	end
	function UIManager:createGameStateUI()
		local label = Instance.new("TextLabel")
		label.Name = "ScoreLabel"
		label.Size = UDim2.new(0, 200, 0, 50)
		label.Position = UDim2.new(0, 20, 0, 20)
		label.BackgroundColor3 = Color3.new(0, 0, 0)
		label.BackgroundTransparency = 0.5
		label.BorderSizePixel = 0
		label.Text = "Score: 0"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextSize = 24
		label.Font = Enum.Font.SourceSansBold
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = self.screenGui
		return label
	end
	function UIManager:createMovesUI()
		local label = Instance.new("TextLabel")
		label.Name = "MovesLabel"
		label.Size = UDim2.new(0, 200, 0, 40)
		label.Position = UDim2.new(0, 20, 0, 75)
		label.BackgroundColor3 = Color3.new(0, 0, 0)
		label.BackgroundTransparency = 0.5
		label.BorderSizePixel = 0
		label.Text = "Moves: 0"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextSize = 20
		label.Font = Enum.Font.SourceSans
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = self.screenGui
		return label
	end
	function UIManager:createMatchesUI()
		local label = Instance.new("TextLabel")
		label.Name = "MatchesLabel"
		label.Size = UDim2.new(0, 200, 0, 40)
		label.Position = UDim2.new(0, 20, 0, 120)
		label.BackgroundColor3 = Color3.new(0, 0, 0)
		label.BackgroundTransparency = 0.5
		label.BorderSizePixel = 0
		label.Text = "Matches: 0"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextSize = 20
		label.Font = Enum.Font.SourceSans
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = self.screenGui
		return label
	end
	function UIManager:createInstructionUI()
		local label = Instance.new("TextLabel")
		label.Name = "InstructionLabel"
		label.Size = UDim2.new(0, 400, 0, 80)
		label.Position = UDim2.new(1, -420, 1, -100)
		label.BackgroundColor3 = Color3.new(0, 0, 0)
		label.BackgroundTransparency = 0.5
		label.BorderSizePixel = 0
		label.Text = "Left Click: Select blocks to swap\nRight Click: Clear selection"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextSize = 18
		label.Font = Enum.Font.SourceSans
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.Parent = self.screenGui
		return label
	end
	function UIManager:updateGameState(gameState)
		self.scoreLabel.Text = `Score: {gameState.score}`
		self.movesLabel.Text = `Moves: {gameState.moves}`
		self.matchesLabel.Text = `Matches: {gameState.matchCount}`
	end
	function UIManager:updateSelectionInfo(selectedCount)
		if selectedCount == 0 then
			self.instructionLabel.Text = "Left Click: Select blocks to swap\nRight Click: Clear selection"
		elseif selectedCount == 1 then
			self.instructionLabel.Text = "Select second block to swap\nRight Click: Clear selection"
		else
			self.instructionLabel.Text = "Swapping blocks...\nRight Click: Clear selection"
		end
	end
	function UIManager:createStartButton()
		local button = Instance.new("TextButton")
		button.Name = "StartButton"
		button.Size = UDim2.new(0, 300, 0, 80)
		button.Position = UDim2.new(0.5, -150, 0.5, -40)
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		button.BorderSizePixel = 0
		button.Text = "🌈 ゲームスタート 🌈"
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextSize = 32
		button.Font = Enum.Font.SourceSansBold
		button.ZIndex = 10
		button.Visible = true
		button.Parent = self.screenGui
		-- ボタンのホバー効果
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(0, 230, 120)
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		end)
		-- クリックイベント
		button.MouseButton1Click:Connect(function()
			self:onStartGame()
		end)
		return button
	end
	function UIManager:onStartGame()
		-- ボタンを非表示
		self.startButton.Visible = false
		-- コールバック呼び出し
		local _result = self.onStartGameCallback
		if _result ~= nil then
			_result()
		end
		print("[UI] Game started!")
	end
	function UIManager:setOnStartGameCallback(callback)
		self.onStartGameCallback = callback
	end
	function UIManager:showStartButton()
		self.startButton.Visible = true
	end
	function UIManager:hideStartButton()
		self.startButton.Visible = false
	end
end
return {
	UIManager = UIManager,
}
