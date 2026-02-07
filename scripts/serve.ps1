# RainbowCube - Rojo Server
# Rojoサーバー起動のみ

$ErrorActionPreference = "Stop"
# プロジェクトルートに移動
Set-Location "$PSScriptRoot\.."

# 状態ファイルのパス
$stateFile = ".\.rojo-state"
$port = 34872  # port番号

Write-Host "🚀 Starting Rojo Server..." -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# 既存のRojoプロセスを停止
$existingRojo = Get-Process -Name "rojo" -ErrorAction SilentlyContinue
if ($existingRojo) {
    Write-Host "Stopping existing Rojo server..." -ForegroundColor Yellow
    Stop-Process -Name "rojo" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Write-Host "✓ Existing server stopped" -ForegroundColor Green
}

# 状態ファイルをクリア
if (Test-Path $stateFile) {
    Remove-Item $stateFile -Force
}

try {
    # バックグラウンドでRojoサーバーを起動
    Write-Host "Starting Rojo server on port $port..." -ForegroundColor Yellow
    Start-Process -FilePath "rojo" -ArgumentList "serve --port $port" -WindowStyle Hidden
    Start-Sleep -Seconds 2

    # 状態ファイルに保存
    @{
        port = $port
        started = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    } | ConvertTo-Json | Out-File $stateFile -Encoding UTF8

    Write-Host "✓ Rojo server started!" -ForegroundColor Green
    Write-Host "  Server URL: http://localhost:$port/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host "✅ Server ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next: Connect in Roblox Studio" -ForegroundColor Cyan
    Write-Host "  Plugins → Rojo → Connect" -ForegroundColor White
    Write-Host "  Port: $port" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "✗ Server startup error: $_" -ForegroundColor Red
    exit 1
}
