# RainbowCube - Open Studio
# Roblox Studio起動のみ

$ErrorActionPreference = "Stop"
# プロジェクトルートに移動
Set-Location "$PSScriptRoot\.."

Write-Host "🎮 Opening Roblox Studio..." -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

$placeFile = "RainbowCube.rbxlx"

# プレイスファイルの存在確認
if (-not (Test-Path $placeFile)) {
    Write-Host "✗ Place file not found: $placeFile" -ForegroundColor Red
    Write-Host "  Run './scripts/build.ps1' first to build the project" -ForegroundColor Yellow
    exit 1
}

# Roblox Studioの実行ファイルを探す
$studioExe = $null
$studioPath1 = "$env:LOCALAPPDATA\Roblox\Versions\*\RobloxStudioBeta.exe"
$studioPath2 = "C:\Program Files\Roblox\Versions\*\RobloxStudioBeta.exe"
$studioPath3 = "C:\Program Files (x86)\Roblox\Versions\*\RobloxStudioBeta.exe"

$found = Get-ChildItem -Path $studioPath1 -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($found) { $studioExe = $found.FullName }

if (-not $studioExe) {
    $found = Get-ChildItem -Path $studioPath2 -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($found) { $studioExe = $found.FullName }
}

if (-not $studioExe) {
    $found = Get-ChildItem -Path $studioPath3 -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($found) { $studioExe = $found.FullName }
}

$fullPath = Resolve-Path $placeFile

if ($studioExe) {
    Write-Host "Found Roblox Studio: $studioExe" -ForegroundColor Gray
    Start-Process -FilePath $studioExe -ArgumentList "`"$fullPath`""
    Write-Host "✓ Roblox Studio opened!" -ForegroundColor Green
    Write-Host ""

    # 状態ファイルから情報読み取り
    $stateFile = ".\.rojo-state"
    if (Test-Path $stateFile) {
        $state = Get-Content $stateFile | ConvertFrom-Json
        Write-Host "=========================" -ForegroundColor Cyan
        Write-Host "📡 Rojo Server Info:" -ForegroundColor Cyan
        Write-Host "  Port: $($state.port)" -ForegroundColor White
        Write-Host "  Started: $($state.started)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Next steps in Studio:" -ForegroundColor Cyan
        Write-Host "  1. Plugins → Rojo → Connect" -ForegroundColor White
        Write-Host "  2. Port: $($state.port)" -ForegroundColor White
        Write-Host "  3. Press Play button" -ForegroundColor White
    } else {
        Write-Host "⚠️  Rojo server may not be running" -ForegroundColor Yellow
        Write-Host "   Run './scripts/serve.ps1' to start the server" -ForegroundColor Gray
    }
    Write-Host ""
} else {
    Write-Host "✗ Roblox Studio not found!" -ForegroundColor Red
    Write-Host "  Install from: https://www.roblox.com/create" -ForegroundColor Yellow
    exit 1
}
