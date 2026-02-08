# Rainbow Cube Project Launcher
# This script launches the development environment for Rainbow Cube from the zone root.

$projectPath = Join-Path $PSScriptRoot "ROB\虹のキューブ"
$startScript = Join-Path $projectPath "start.ps1"

if (Test-Path $startScript) {
    Write-Host "🚀 Launching Rainbow Cube..." -ForegroundColor Cyan
    Set-Location -Path $projectPath
    & ".\start.ps1"
} else {
    Write-Host "Error: Could not find start.ps1 at $startScript" -ForegroundColor Red
}
