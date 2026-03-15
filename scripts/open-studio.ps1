# Robster Rush - Open Studio
# 生成されたプレイスファイルをRoblox Studioで開きます

$ErrorActionPreference = "Stop"

# スクリプトのディレクトリに移動
Set-Location $PSScriptRoot

$placeFile = "robster-rush.rbxl"

if (-not (Test-Path $placeFile)) {
    Write-Host "❌ File not found: $placeFile" -ForegroundColor Red
    Write-Host "   Please run .\build.ps1 first." -ForegroundColor Yellow
    exit 1
}

Write-Host "🚀 Opening $placeFile in Roblox Studio..." -ForegroundColor Cyan

# Roblox Studioの実行ファイルを探す
$studioPaths = @(
    "$env:LOCALAPPDATA\Roblox\Versions\*\RobloxStudioBeta.exe",
    "C:\Program Files\Roblox\Versions\*\RobloxStudioBeta.exe",
    "C:\Program Files (x86)\Roblox\Versions\*\RobloxStudioBeta.exe"
)

$studioExe = $null
foreach ($pattern in $studioPaths) {
    $found = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($found) {
        $studioExe = $found.FullName
        break
    }
}

$fullPath = Resolve-Path $placeFile

if ($studioExe) {
    Write-Host "   Found Roblox Studio: $studioExe" -ForegroundColor Gray
    Start-Process -FilePath $studioExe -ArgumentList "`"$fullPath`""
    Write-Host "✅ Done" -ForegroundColor Green
} else {
    Write-Host "⚠️  Roblox Studio not found in standard locations" -ForegroundColor Yellow
    Write-Host "   Trying to open with default application..." -ForegroundColor Yellow

    try {
        Invoke-Item $placeFile
        Write-Host "✅ Done" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to open file" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please open the file manually:" -ForegroundColor Yellow
        Write-Host "   $fullPath" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Or install/reinstall Roblox Studio from:" -ForegroundColor Yellow
        Write-Host "   https://www.roblox.com/create" -ForegroundColor Cyan
    }
}
