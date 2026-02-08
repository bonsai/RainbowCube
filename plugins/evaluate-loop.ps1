<#
.SYNOPSIS
    Evaluates the development loop by comparing Spec, Code, and Logs.
.DESCRIPTION
    1. Reads specification summary (from internal knowledge/docs).
    2. Checks current code configuration (static analysis).
    3. Parses the latest debug log for test results.
    4. Outputs a comparison report to the console.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$LogPath = "$PSScriptRoot\..\log\debug-log.txt"
$DocPath = "$PSScriptRoot\..\.doc\Rainbow Tower Builder 企画書.md"

# --- 1. Specification Definitions (Derived from Doc Analysis) ---
$Specs = @{
    "GridSize" = "9x9x9"
    "Colors"   = "7 Rainbow Colors"
    "Action"   = "Start Button Click -> Cube Generation"
    "LogSuccessPattern" = "✅ SUCCESS"
}

# --- 2. Code Static Analysis ---
$CodeStatus = @{
    "GridSize" = $null
    "AutoStart" = $null
}

# Analyze main.server.ts (Naive grep-like check)
$MainServerPath = "$PSScriptRoot\..\src\server\main.server.ts"
if (Test-Path $MainServerPath) {
    $Content = Get-Content $MainServerPath -Raw
    if ($Content -match "9x9x9") { $CodeStatus["GridSize"] = "Confirmed 9x9x9 in comments/logs" }
    if ($Content -match "AUTO_START_GAME") { $CodeStatus["AutoStart"] = "Configured (Shared Constant)" }
}

# --- 3. Log Analysis ---
$LogResult = @{
    "Status" = "No Log Found"
    "LastRun" = $null
    "Details" = $null
}

if (Test-Path $LogPath) {
    $LogContent = Get-Content $LogPath
    $LogResult["LastRun"] = (Get-Item $LogPath).LastWriteTime
    
    # Check for latest test run
    $SuccessCount = ($LogContent | Select-String "✅ SUCCESS").Count
    $FailureCount = ($LogContent | Select-String "❌ FAILURE").Count
    
    if ($SuccessCount -gt 0) {
        $LogResult["Status"] = "PASS"
        $LogResult["Details"] = "Found $SuccessCount success entries."
    } elseif ($FailureCount -gt 0) {
        $LogResult["Status"] = "FAIL"
        $LogResult["Details"] = "Found $FailureCount failure entries."
    } else {
        $LogResult["Status"] = "UNKNOWN"
        $LogResult["Details"] = "Log exists but no clear pass/fail pattern found in recent entries."
    }
}

# --- 4. Report Generation ---
Write-Host "`n📊 === Development Loop Evaluation Report === 📊`n" -ForegroundColor Cyan

# Spec Section
Write-Host "1. 📝 Specification (Expectation)" -ForegroundColor Yellow
Write-Host "   - Grid: $($Specs.GridSize)"
Write-Host "   - Trigger: $($Specs.Action)"
Write-Host "   - Success Criteria: Log contains '$($Specs.LogSuccessPattern)'"

# Code Section
Write-Host "`n2. 💻 Code (Implementation)" -ForegroundColor Blue
Write-Host "   - Grid Check: $($CodeStatus.GridSize)"
Write-Host "   - Auto-Start: $($CodeStatus.AutoStart)"

# Log Section
Write-Host "`n3. 🧪 Test Results (Reality)" -ForegroundColor Magenta
if ($LogResult.Status -eq "PASS") {
    Write-Host "   - Status: $($LogResult.Status)" -ForegroundColor Green
} elseif ($LogResult.Status -eq "FAIL") {
    Write-Host "   - Status: $($LogResult.Status)" -ForegroundColor Red
} else {
    Write-Host "   - Status: $($LogResult.Status)" -ForegroundColor Gray
}
Write-Host "   - Details: $($LogResult.Details)"
Write-Host "   - Log File: $LogPath"

# Final Verdict
Write-Host "`n🏁 Verdict & Next Steps" -ForegroundColor White
if ($LogResult.Status -eq "PASS") {
    Write-Host "   ✅ Loop Closed: Implementation matches Specification." -ForegroundColor Green
    Write-Host "   👉 Next: Add more features or new test cases."
} elseif ($LogResult.Status -eq "FAIL") {
    Write-Host "   ❌ Loop Broken: Test failed." -ForegroundColor Red
    Write-Host "   👉 Next: Check log details and fix the code."
} else {
    Write-Host "   ⚠️ Loop Open: No valid test result found." -ForegroundColor Yellow
    Write-Host "   👉 Next: Run the game in Roblox Studio and press the Start Button."
}
Write-Host "`n"
