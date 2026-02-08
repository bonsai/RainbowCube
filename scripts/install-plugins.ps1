# ========================================
# Install/Update Plugins
# ========================================
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Ensure Rojo is available
if (-not (Get-Command "rojo" -ErrorAction SilentlyContinue)) {
    $rojoPath = "$env:APPDATA\npm\rojo.exe"
    if (Test-Path $rojoPath) {
        $env:Path += ";$env:APPDATA\npm"
        Write-Host "   ℹ️  Added Rojo to PATH temporarily." -ForegroundColor Gray
    } else {
        Write-Host "❌ Rojo not found. Please run 'check-environment' or 'Install Rojo' first." -ForegroundColor Red
        exit 1
    }
}

$PluginsDir = "$env:LOCALAPPDATA\Roblox\Plugins"
if (-not (Test-Path $PluginsDir)) {
    New-Item -ItemType Directory -Path $PluginsDir -Force | Out-Null
    Write-Host "   Created Plugins directory." -ForegroundColor Gray
}

Write-Host "🔌 Plugin Installation Started..." -ForegroundColor Cyan
Write-Host "   Target: $PluginsDir" -ForegroundColor Gray
Write-Host ""

# 1. Install Rojo Managed Plugin
Write-Host "📦 Installing Rojo Managed Plugin..." -ForegroundColor Green
try {
    # 'rojo plugin install' installs the plugin that allows Rojo to sync
    rojo plugin install
    Write-Host "   ✅ Rojo Managed Plugin installed/updated." -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Failed to install Rojo Managed Plugin: $_" -ForegroundColor Yellow
}

# 2. Build and Install Rainbow Debug Plugin
Write-Host "🌈 Installing Rainbow Debug Plugin..." -ForegroundColor Green
$DebugProject = "$PSScriptRoot\..\plugins\debug-plugin.project.json"
$DebugOutput = Join-Path $PluginsDir "RainbowDebugPlugin.rbxmx"

if (Test-Path $DebugProject) {
    try {
        rojo build "$DebugProject" --output "$DebugOutput"
        Write-Host "   ✅ Rainbow Debug Plugin built and installed." -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Failed to build Rainbow Debug Plugin: $_" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Debug plugin project file not found at: $DebugProject" -ForegroundColor Red
}

Write-Host ""
Write-Host "✨ Plugin installation complete!" -ForegroundColor Cyan
Write-Host "   Please restart Roblox Studio to load the new plugins." -ForegroundColor Cyan

