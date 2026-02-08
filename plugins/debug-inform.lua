print("=== 🌈 Rainbow Cube Debug Check ===")

local function check(label, parent, name)
    if not parent then
        print("❌ " .. label .. ": Parent is nil!")
        return
    end
    local target = parent:FindFirstChild(name)
    if target then
        print("✅ " .. label .. ": Found (" .. target.ClassName .. ")")
        if target.ClassName == "ModuleScript" or target.ClassName == "Script" then
             print("   -> Source length: " .. string.len(target.Source))
        end
    else
        print("❌ " .. label .. ": NOT Found in " .. parent.Name)
    end
end

-- 1. ServerScriptService の確認
local sss = game:GetService("ServerScriptService")
local serverFolder = sss:FindFirstChild("Server")

if serverFolder then
    print("📂 Found 'Server' folder in ServerScriptService")
    check("Grid Module", serverFolder, "grid")
    check("Main Script", serverFolder, "main")
    
    print("   --- Contents of ServerScriptService.Server ---")
    for _, c in pairs(serverFolder:GetChildren()) do
        print("   - " .. c.Name .. " (" .. c.ClassName .. ")")
    end
else
    print("❓ 'Server' folder not found in ServerScriptService")
    print("   --- Contents of ServerScriptService ---")
    for _, c in pairs(sss:GetChildren()) do
        print("   - " .. c.Name .. " (" .. c.ClassName .. ")")
    end
end

-- 2. ReplicatedStorage の確認
local rs = game:GetService("ReplicatedStorage")
check("rbxts_include", rs, "rbxts_include")
check("SwapBlocksEvent", rs, "SwapBlocksEvent")

print("=== Check Complete ===")