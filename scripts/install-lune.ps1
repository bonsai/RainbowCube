# Install Lune for Windows
# Automatically downloads and installs Lune (Luau Runtime) to project .bin directory

$ErrorActionPreference = "Stop"

# プロジェクトルートの .bin ディレクトリをターゲットにする
$TARGET_DIR = Resolve-Path "$PSScriptRoot\..\.bin" -ErrorAction SilentlyContinue
if (-not $TARGET_DIR) {
    $TARGET_DIR = Join-Path "$PSScriptRoot\.." ".bin"
    New-Item -ItemType Directory -Path $TARGET_DIR -Force | Out-Null
    $TARGET_DIR = Resolve-Path $TARGET_DIR
}

# Constants
$LUNE_VERSION = "0.10.4"
$URL = "https://github.com/lune-org/lune/releases/download/v$LUNE_VERSION/lune-$LUNE_VERSION-windows-x86_64.zip"
$ZIP_NAME = Join-Path $TARGET_DIR "lune.zip"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  🌙 Lune Installer for Windows" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Version: $LUNE_VERSION" -ForegroundColor Green
Write-Host "Target: $TARGET_DIR" -ForegroundColor Green
Write-Host ""

try {
    # Download
    Write-Host "📥 Downloading Lune $LUNE_VERSION..." -ForegroundColor Yellow
    Write-Host "   URL: $URL" -ForegroundColor Gray

    Invoke-WebRequest -Uri $URL -OutFile $ZIP_NAME -UseBasicParsing
    Write-Host "✅ Download complete." -ForegroundColor Green
    Write-Host ""

    # Extract
    Write-Host "📦 Extracting..." -ForegroundColor Yellow
    # 一時ディレクトリに展開
    $tempDir = Join-Path $TARGET_DIR "temp_lune"
    Expand-Archive -Path $ZIP_NAME -DestinationPath $tempDir -Force
    Write-Host "✅ Extraction complete." -ForegroundColor Green
    Write-Host ""

    # Move to target
    $src = Join-Path $tempDir "lune.exe"
    $dst = Join-Path $TARGET_DIR "lune.exe"

    if (Test-Path $src) {
        Write-Host "📁 Installing to: $dst" -ForegroundColor Yellow

        # Check if destination exists, remove if so to overwrite
        if (Test-Path $dst) {
            try {
                Remove-Item $dst -Force
                Write-Host "   Removed existing lune.exe" -ForegroundColor Gray
            }
            catch {
                Write-Host "⚠️  Warning: Could not remove existing $dst" -ForegroundColor Yellow
                Write-Host "   It might be in use. Attempting to overwrite..." -ForegroundColor Yellow
            }
        }

        try {
            Move-Item $src $dst -Force
            Write-Host "✅ Successfully installed Lune!" -ForegroundColor Green
            Write-Host ""

            # Verify installation
            Write-Host "🔍 Verifying installation..." -ForegroundColor Yellow
            $version = & $dst --version 2>&1
            Write-Host "   Installed: $version" -ForegroundColor Green
            Write-Host ""
            Write-Host "================================================" -ForegroundColor Cyan
            Write-Host "  ✨ Installation Complete!" -ForegroundColor Green
            Write-Host "================================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Lune has been installed to the project's .bin directory." -ForegroundColor White
        }
        catch {
            Write-Host "❌ Error moving file: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "❌ Error: lune.exe not found in extracted files." -ForegroundColor Red
        Get-ChildItem $tempDir
    }

    # Cleanup
    Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
    if (Test-Path $ZIP_NAME) { Remove-Item $ZIP_NAME -Force }
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
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
}
