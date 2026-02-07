# RainbowCube - Start All
# 状態管理付き統合起動スクリプト

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$stateFile = ".\.rojo-state"

Write-Host "🌈 RainbowCube Development Environment" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 状態チェック
function Get-RojoStatus {
    if (Test-Path $stateFile) {
        try {
            $state = Get-Content $stateFile | ConvertFrom-Json
            $rojoProcess = Get-Process -Name "rojo" -ErrorAction SilentlyContinue
            if ($rojoProcess) {
                return @{
                    Running = $true
                    Port = $state.port
                    Started = $state.started
                }
            }
        } catch {}
    }
    return @{ Running = $false }
}

# メニュー表示
function Show-Menu {
    $status = Get-RojoStatus

    Write-Host ""
    Write-Host "Current Status:" -ForegroundColor Cyan
    if ($status.Running) {
        Write-Host "  Rojo Server: " -NoNewline
        Write-Host "RUNNING" -ForegroundColor Green
        Write-Host "  Port: $($status.Port)" -ForegroundColor Gray
        Write-Host "  Started: $($status.Started)" -ForegroundColor Gray
    } else {
        Write-Host "  Rojo Server: " -NoNewline
        Write-Host "STOPPED" -ForegroundColor Red
    }
    Write-Host ""

    Write-Host "Available Commands:" -ForegroundColor Cyan
    Write-Host "  [1] Build Project" -ForegroundColor White
    Write-Host "  [2] Start/Restart Rojo Server" -ForegroundColor White
    Write-Host "  [3] Open Roblox Studio" -ForegroundColor White
    Write-Host "  [4] Stop Rojo Server" -ForegroundColor White
    Write-Host "  [5] Deploy / Upload" -ForegroundColor White
    Write-Host "  [6] Check Environment" -ForegroundColor White
    Write-Host "  [7] Test Luau Execution (Lune)" -ForegroundColor White
    Write-Host "  [8] Install Lune (Luau Runtime)" -ForegroundColor White
    Write-Host "  [Q] Quit" -ForegroundColor Gray
    Write-Host ""
}

# メインループ
while ($true) {
    Show-Menu
    $choice = Read-Host "Select option"

    switch ($choice.ToUpper()) {
        "1" {
            Write-Host ""
            & ".\scripts\build.ps1"
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Write-Host ""
            & ".\scripts\serve.ps1"
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Write-Host ""
            & ".\scripts\open-studio.ps1"
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "4" {
            Write-Host ""
            Write-Host "Stopping Rojo server..." -ForegroundColor Yellow
            $rojoProcess = Get-Process -Name "rojo" -ErrorAction SilentlyContinue
            if ($rojoProcess) {
                Stop-Process -Name "rojo" -Force -ErrorAction SilentlyContinue
                if (Test-Path $stateFile) {
                    Remove-Item $stateFile -Force
                }
                Write-Host "✓ Server stopped" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Server not running" -ForegroundColor Yellow
            }
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" {
            Write-Host ""
            & ".\scripts\deploy.ps1"
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "6" {
            Write-Host ""
            & ".\scripts\check-environment.ps1"
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "7" {
            Write-Host ""
            & ".\scripts\test-luau.ps1"
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "8" {
            Write-Host ""
            & ".\scripts\install-lune.ps1"
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "Q" {
            exit
        }
    }
}
