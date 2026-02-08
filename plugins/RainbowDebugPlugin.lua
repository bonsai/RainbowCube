-- RainbowCube Debug Tools - Lua Plugin
-- All-in-one debugging and development tools for Roblox/Lua

local Plugin = {}
local Tools = {}

-- Configuration
Plugin.Config = {
    Port = 8081,
    LogFile = "./log/debug-log.txt",
    LunePath = "./bin/lune.exe",
    StateFile = ".rojo-state"
}

-- Initialize
function Plugin:Initialize()
    print("🌈 RainbowCube Debug Tools Initialized")
    print("📋 Available Tools:")
    print("  1. Luau Execution Test")
    print("  2. Development Loop Evaluation")
    print("  3. Log Server")
    print("  4. Environment Check")
end

-- Tool 1: Luau Execution Test
function Tools:TestLuau()
    print("🧪 Luau Execution Test")
    print("=========================")
    
    -- Check Lune
    local lunePath = Plugin.Config.LunePath
    if not fs.fileExists(lunePath) then
        print("❌ Lune not found: " .. lunePath)
        print("💡 Please run install-lune.ps1 first")
        return
    end
    
    print("✅ Lune found: " .. lunePath)
    
    -- Create test file
    local testFile = "test_execution.luau"
    local content = [[
print("✨ Hello from Luau! The environment is working correctly.")
local x = 10
local y = 20
print("   Calculation check: " .. x .. " + " .. y .. " = " .. (x + y))

local function greet(name)
    return "   Greetings, " .. name .. "!"
end

print(greet("Developer"))
]]
    
    local success = fs.write(testFile, content)
    if not success then
        print("❌ Failed to create test file")
        return
    end
    
    print("📝 Created test file: " .. testFile)
    print("🏃 Running test...")
    
    -- Execute test
    local result = os.execute("lune run " .. testFile)
    
    if result == 0 then
        print("✅ Luau execution test successful!")
    else
        print("❌ Execution failed")
    end
    
    -- Cleanup
    fs.delete(testFile)
    print("🧹 Test file deleted")
end

-- Tool 2: Development Loop Evaluation
function Tools:EvaluateLoop()
    print("📊 Development Loop Evaluation")
    print("=================================")
    
    -- Specification
    local specs = {
        GridSize = "9x9x9",
        Colors = "7 Rainbow Colors",
        Action = "Start Button Click -> Cube Generation",
        LogSuccessPattern = "✅ SUCCESS"
    }
    
    print("\n1. 📝 Specification (Expectation)")
    print("   - Grid: " .. specs.GridSize)
    print("   - Trigger: " .. specs.Action)
    print("   - Success Criteria: Log contains '" .. specs.LogSuccessPattern .. "'")
    
    -- Code Analysis
    local codeStatus = {
        GridSize = "Not checked",
        AutoStart = "Not checked"
    }
    
    -- Check main.server.ts
    local mainServerPath = "./src/server/main.server.ts"
    if fs.fileExists(mainServerPath) then
        local content = fs.read(mainServerPath)
        if string.find(content, "9x9x9") then
            codeStatus.GridSize = "Confirmed 9x9x9 in comments/logs"
        end
        if string.find(content, "AUTO_START_GAME") then
            codeStatus.AutoStart = "Configured (Shared Constant)"
        end
    end
    
    print("\n2. 💻 Code (Implementation)")
    print("   - Grid Check: " .. (codeStatus.GridSize or "Not found"))
    print("   - Auto-Start: " .. (codeStatus.AutoStart or "Not found"))
    
    -- Log Analysis
    local logPath = Plugin.Config.LogFile
    local logResult = {
        Status = "No Log Found",
        LastRun = nil,
        Details = nil
    }
    
    if fs.fileExists(logPath) then
        local logContent = fs.read(logPath)
        logResult.LastRun = os.date("%Y-%m-%d %H:%M:%S", fs.lastModified(logPath))
        
        local successCount = select(2, string.gsub(logContent, specs.LogSuccessPattern, ""))
        local failureCount = select(2, string.gsub(logContent, "❌ FAILURE", ""))
        
        if successCount > 0 then
            logResult.Status = "PASS"
            logResult.Details = "Found " .. successCount .. " success entries."
        elseif failureCount > 0 then
            logResult.Status = "FAIL"
            logResult.Details = "Found " .. failureCount .. " failure entries."
        else
            logResult.Status = "UNKNOWN"
            logResult.Details = "Log exists but no clear pass/fail pattern found."
        end
    end
    
    print("\n3. 🧪 Test Results (Reality)")
    local color = "[37m" -- white
    if logResult.Status == "PASS" then
        color = "[32m" -- green
    elseif logResult.Status == "FAIL" then
        color = "[31m" -- red
    else
        color = "[90m" -- gray
    end
    print("   - Status: " .. color .. logResult.Status .. "[0m")
    print("   - Details: " .. (logResult.Details or "N/A"))
    print("   - Log File: " .. logPath)
    
    -- Final Verdict
    print("\n🏁 Verdict & Next Steps")
    if logResult.Status == "PASS" then
        print("   ✅ Loop Closed: Implementation matches Specification.")
        print("   👉 Next: Add more features or new test cases.")
    elseif logResult.Status == "FAIL" then
        print("   ❌ Loop Broken: Test failed.")
        print("   👉 Next: Check log details and fix the code.")
    else
        print("   ⚠️  Loop Open: No valid test result found.")
        print("   👉 Next: Run the game in Roblox Studio and press the Start Button.")
    end
    print("\n")
end

-- Tool 3: Log Server
function Tools:StartLogServer()
    print("📡 Starting Log Server...")
    print("===========================")
    
    local port = Plugin.Config.Port
    local logFile = Plugin.Config.LogFile
    
    -- Ensure log directory exists
    local logDir = fs.getDir(logFile)
    if not fs.dirExists(logDir) then
        fs.makeDir(logDir)
    end
    
    -- Create/Clear log file
    fs.write(logFile, "=== Log Server Started: " .. os.date() .. " ===\n")
    
    print("📡 Log Server running on port " .. port)
    print("   Log File: " .. logFile)
    print("   Press Ctrl+C to stop.")
    print("")
    
    -- Simple HTTP server
    local server = http.createServer(function(req, res)
        if req.method == "POST" then
            local body = req:readAll()
            local timestamp = os.date("%H:%M:%S")
            local logEntry = "[" .. timestamp .. "] " .. body
            
            -- Write to console and file
            print(logEntry)
            fs.append(logFile, logEntry .. "\n")
            
            -- Send response
            res:write("OK")
            res:close()
        else
            res.status = 404
            res:close()
        end
    end)
    
    server:listen(port)
    
    print("🚀 Server started!")
    print("")
    
    -- Keep server running
    while true do
        task.wait(1)
    end
end

-- Tool 4: Environment Check
function Tools:CheckEnvironment()
    print("🔍 Environment Check")
    print("===================")
    
    local allGood = true
    
    -- Node.js Check
    print("\n📦 Node.js Check...")
    local nodeVersion = os.execute("node --version")
    if nodeVersion == 0 then
        print("✅ Node.js installed")
    else
        print("❌ Node.js not found")
        allGood = false
    end
    
    -- npm Check
    print("\n📦 npm Check...")
    local npmVersion = os.execute("npm --version")
    if npmVersion == 0 then
        print("✅ npm installed")
    else
        print("❌ npm not found")
        allGood = false
    end
    
    -- Rojo Check
    print("\n📦 Rojo Check...")
    local rojoVersion = os.execute("rojo --version")
    if rojoVersion == 0 then
        print("✅ Rojo installed")
    else
        print("❌ Rojo not found")
        allGood = false
    end
    
    -- Roblox Studio Check
    print("\n📦 Roblox Studio Check...")
    local studioPath = nil
    local paths = {
        "$env:LOCALAPPDATA\Roblox\Versions\*\RobloxStudioBeta.exe",
        "C:\Program Files (x86)\Roblox\Versions\*\RobloxStudioBeta.exe",
        "C:\Program Files\Roblox\Versions\*\RobloxStudioBeta.exe"
    }
    
    for _, path in ipairs(paths) do
        local found = os.execute("Get-ChildItem -Path '" .. path .. "' -ErrorAction SilentlyContinue | Select-Object -First 1")
        if found == 0 then
            studioPath = path
            break
        end
    end
    
    if studioPath then
        print("✅ Roblox Studio found")
    else
        print("❌ Roblox Studio not found")
        allGood = false
    end
    
    print("\n📊 Summary")
    print("=======")
    if allGood then
        print("✅ All required tools installed!")
        print("🎯 Ready for Roblox development.")
    else
        print("⚠️  Some tools missing")
        print("💡 Please install missing dependencies.")
    end
end

-- Main function
function Plugin:Run(toolName)
    if not toolName then
        print("💡 Please specify a tool name")
        print("Available tools:")
        print("  test-luau")
        print("  evaluate-loop")
        print("  log-server")
        print("  check-environment")
        return
    end
    
    if toolName == "test-luau" then
        Tools:TestLuau()
    elseif toolName == "evaluate-loop" then
        Tools:EvaluateLoop()
    elseif toolName == "log-server" then
        Tools:StartLogServer()
    elseif toolName == "check-environment" then
        Tools:CheckEnvironment()
    else
        print("❌ Unknown tool: " .. toolName)
        print("Available tools:")
        print("  test-luau")
        print("  evaluate-loop")
        print("  log-server")
        print("  check-environment")
    end
end

-- Export
return Plugin