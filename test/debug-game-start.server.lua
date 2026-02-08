-- Debug Script: Monitor Game Start Event
-- Monitors the InitGameEvent and logs the result of cube generation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Configuration
local LOG_URL = "http://localhost:8081/log"
local InitGameEvent = ReplicatedStorage:WaitForChild("InitGameEvent")

-- Logger function
local function log(message)
	print("[TEST] " .. message)
	task.spawn(function()
		pcall(function()
			HttpService:PostAsync(LOG_URL, message, Enum.HttpContentType.TextPlain)
		end)
	end)
end

log("🧪 Debug Monitor Loaded: Waiting for 'InitGameEvent'...")

-- Listen for the game start event (Server-side)
InitGameEvent.OnServerEvent:Connect(function(player)
	log("🔵 [Event] Start Button Pressed by: " .. player.Name)

	-- 1. Check Pre-condition
	local startCubeCount = 0
	local gridFolder = workspace:FindFirstChild("Grid")
	if gridFolder then
		startCubeCount = #gridFolder:GetChildren()
	end
	log("   1️⃣ Pre-computation Cube Count: " .. startCubeCount)

	-- 2. Wait for generation logic (assuming it runs shortly after)
	log("   ⏳ Waiting for generation...")
	task.wait(2) -- Wait 2 seconds for cubes to generate

	-- 3. Check Post-condition
	local endCubeCount = 0
	gridFolder = workspace:FindFirstChild("Grid")
	if gridFolder then
		endCubeCount = #gridFolder:GetChildren()
	end
	log("   2️⃣ Post-computation Cube Count: " .. endCubeCount)

	-- 4. Validate
	if endCubeCount > startCubeCount then
		log("✅ SUCCESS: Cubes generated! (+ " .. (endCubeCount - startCubeCount) .. ")")
		log("   🧊 Total Cubes: " .. endCubeCount)
	else
		if endCubeCount > 0 then
             log("⚠️  WARNING: Cube count did not increase (already generated?). Count: " .. endCubeCount)
        else
             log("❌ FAILURE: No cubes found in Grid folder.")
        end
	end
    
    log("=== End of Test Case ===\n")
end)
