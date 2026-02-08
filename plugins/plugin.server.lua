-- Rainbow Cube Debugger Plugin
local toolbar = plugin:CreateToolbar("Rainbow Cube Debug")
local checkButton = toolbar:CreateButton("Check", "Check Project Structure", "rbxassetid://4458901886")
local testButton = toolbar:CreateButton("Run Tests", "Run Auto Tests & Log", "rbxassetid://4458901886")

local HttpService = game:GetService("HttpService")
local LOG_SERVER_URL = "http://localhost:8081/log"

local function log(message)
	print(message)
	-- Try to send to local log server
	task.spawn(function()
		pcall(function()
			HttpService:PostAsync(LOG_SERVER_URL, message, Enum.HttpContentType.TextPlain)
		end)
	end)
end

local function runTests()
	log("\n=== 🧪 Starting Auto Tests: " .. os.date("%X") .. " ===")

	-- TEST 1: Environment Check
	local success, err = pcall(function()
		local sss = game:GetService("ServerScriptService")
		local serverFolder = sss:FindFirstChild("Server")
		if not serverFolder then
			log("❌ TEST 1 FAILED: 'Server' folder missing in ServerScriptService")
			return
		end
		
		if not serverFolder:FindFirstChild("main") then
			log("❌ TEST 1 FAILED: 'main' script missing in Server/ServerScriptService")
			return
		end
		
		log("✅ TEST 1 PASSED: Environment Structure OK")
	end)
	if not success then log("❌ TEST 1 ERROR: " .. tostring(err)) end

	-- TEST 2: Cube Generation Check (Wait for runtime)
	-- Note: This test works best when the game is RUNNING.
	local runService = game:GetService("RunService")
	if runService:IsRunMode() then
		log("ℹ️  Game is running. Checking Workspace...")
		
		-- Wait a bit for generation
		task.wait(2)
		
		local gridFolder = workspace:FindFirstChild("Grid")
		if gridFolder then
			local children = gridFolder:GetChildren()
			local cubeCount = 0
			for _, child in pairs(children) do
				if child.Name == "Cube" then
					cubeCount = cubeCount + 1
				end
			end
			
			log("📊 Grid Folder Found. Child Count: " .. #children)
			log("🧊 Cube Count: " .. cubeCount)
			
			if cubeCount > 0 then
				log("✅ TEST 2 PASSED: Cubes exist!")
			else
				log("❌ TEST 2 FAILED: Grid exists but NO Cubes found.")
			end
		else
			log("❌ TEST 2 FAILED: 'Grid' folder not found in Workspace.")
		end
	else
		log("⚠️  TEST 2 SKIPPED: Game is not running (Edit Mode). Please press Play to test cube generation.")
	end

    -- TEST 3: HTTP Enabled
    local successHttp, enabled = pcall(function() return HttpService.HttpEnabled end)
    if successHttp and enabled then
        log("✅ TEST 3 PASSED: HttpEnabled is true")
    else
        log("❌ TEST 3 FAILED: HttpEnabled is false or inaccessible")
    end

	log("=== 🏁 Auto Tests Complete ===\n")
end

checkButton.Click:Connect(function()
    log("Checking Structure...")
    -- (Existing check logic reused or simplified if needed, keeping it separate for now)
    -- For now, just logging that we clicked check
end)

testButton.Click:Connect(runTests)
