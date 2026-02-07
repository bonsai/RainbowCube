# RainbowCube - Build Script
# TypeScriptコンパイルとRojoビルドを一括で行います

$ErrorActionPreference = "Stop"

# プロジェクトルートに移動
Set-Location "$PSScriptRoot\.."

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  🌈 RainbowCube - Build" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# 1. 依存関係のチェック (node_modules)
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ npm install failed" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# 2. TypeScript コンパイル
Write-Host "🔨 Compiling TypeScript..." -ForegroundColor Green
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ TypeScript compilation failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 3. Rojo ビルド
Write-Host "🏗️  Building Place file..." -ForegroundColor Green
$outputFile = "RainbowCube.rbxlx"
rojo build -o $outputFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Rojo build failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "✅ Build Complete: $outputFile" -ForegroundColor Cyan
Write-Host "   Run .\scripts\open-studio.ps1 to open in Roblox Studio" -ForegroundColor Gray
