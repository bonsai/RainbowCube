# Install Rojo for Windows
# Automatically downloads and installs Rojo to npm directory

$ErrorActionPreference = "Stop"

# Constants
$ROJO_VERSION = "7.6.1"
$URL = "https://github.com/rojo-rbx/rojo/releases/download/v$ROJO_VERSION/rojo-$ROJO_VERSION-windows-x86_64.zip"
$TARGET_DIR = "$env:APPDATA\npm"
$ZIP_NAME = "rojo.zip"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Rojo Installer for Windows" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Version: $ROJO_VERSION" -ForegroundColor Green
Write-Host "Target: $TARGET_DIR" -ForegroundColor Green
Write-Host ""

try {
    # Download
    Write-Host "📥 Downloading Rojo $ROJO_VERSION..." -ForegroundColor Yellow
    Write-Host "   URL: $URL" -ForegroundColor Gray

    Invoke-WebRequest -Uri $URL -OutFile $ZIP_NAME -UseBasicParsing
    Write-Host "✅ Download complete." -ForegroundColor Green
    Write-Host ""

    # Extract
    Write-Host "📦 Extracting..." -ForegroundColor Yellow
    Expand-Archive -Path $ZIP_NAME -DestinationPath "." -Force
    Write-Host "✅ Extraction complete." -ForegroundColor Green
    Write-Host ""

    # Move to target
    $src = "rojo.exe"
    $dst = Join-Path $TARGET_DIR "rojo.exe"

    if (Test-Path $src) {
        Write-Host "📁 Installing to: $dst" -ForegroundColor Yellow

        # Check if destination exists, remove if so to overwrite
        if (Test-Path $dst) {
            try {
                Remove-Item $dst -Force
                Write-Host "   Removed existing rojo.exe" -ForegroundColor Gray
            }
            catch {
                Write-Host "⚠️  Warning: Could not remove existing $dst" -ForegroundColor Yellow
                Write-Host "   It might be in use. Attempting to overwrite..." -ForegroundColor Yellow
            }
        }

        try {
            Move-Item $src $dst -Force
            Write-Host "✅ Successfully installed Rojo!" -ForegroundColor Green
            Write-Host ""

            # Verify installation
            Write-Host "🔍 Verifying installation..." -ForegroundColor Yellow
            $version = & rojo --version 2>&1
            Write-Host "   Installed: $version" -ForegroundColor Green
            Write-Host ""
            Write-Host "================================================" -ForegroundColor Cyan
            Write-Host "  ✨ Installation Complete!" -ForegroundColor Green
            Write-Host "================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "You can now use 'rojo' from any directory." -ForegroundColor White
        }
        catch {
            Write-Host "❌ Error moving file: $_" -ForegroundColor Red
            Write-Host ""
            Write-Host "Fallback: Rojo is currently in $PWD" -ForegroundColor Yellow
            Write-Host "Please manually move rojo.exe to: $TARGET_DIR" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "❌ Error: rojo.exe not found in extracted files." -ForegroundColor Red
    }

    # Cleanup
    Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
    if (Test-Path $ZIP_NAME) {
        Remove-Item $ZIP_NAME -Force
    }
    Write-Host "✅ Cleanup complete." -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "  ❌ An error occurred" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try:" -ForegroundColor Yellow
    Write-Host "  1. Check your internet connection" -ForegroundColor White
    Write-Host "  2. Close any programs using rojo.exe" -ForegroundColor White
    Write-Host "  3. Run PowerShell as Administrator" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Read-Host "Press Enter to exit"
