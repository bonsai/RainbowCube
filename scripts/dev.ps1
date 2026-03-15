# RainbowCube - Development Startup Script
# ビルド → サーバー起動 → Studio起動を自動実行

# スクリプトのディレクトリに移動
Set-Location -Path $PSScriptRoot

Write-Host "🌈 RainbowCube Development Startup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# 1. ビルド
Write-Host "[1/3] Building project..." -ForegroundColor Yellow
try {
    rojo build -o "RainbowCube.rbxlx"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Build successful!" -ForegroundColor Green
    } else {
        Write-Host "✗ Build failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Build error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Rojoサーバー起動
Write-Host "[2/3] Starting Rojo server..." -ForegroundColor Yellow
try {
    # バックグラウンドでRojoサーバーを起動
    Start-Process -FilePath "rojo" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
    Write-Host "✓ Rojo server started in background!" -ForegroundColor Green
    Write-Host "   Server URL: http://localhost:34872/" -ForegroundColor Gray
} catch {
    Write-Host "✗ Server startup error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 3. Roblox Studio起動
Write-Host "[3/3] Opening Roblox Studio..." -ForegroundColor Yellow
try {
    Start-Process -FilePath ".\RainbowCube.rbxlx"
    Write-Host "✓ Roblox Studio opened!" -ForegroundColor Green
} catch {
    Write-Host "✗ Studio open error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "🎮 Development environment ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps in Roblox Studio:" -ForegroundColor Cyan
Write-Host "  1. Plugins → Rojo → Connect" -ForegroundColor White
Write-Host "  2. Connect to port 34872" -ForegroundColor White
Write-Host "  3. Press Play button to test" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
