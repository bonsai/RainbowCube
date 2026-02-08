# Roblox開発環境チェックスクリプト
# 現在の環境状態を確認します

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  🔍 Roblox開発環境チェック" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# ========================================
# Node.js チェック
# ========================================
Write-Host "📦 Node.js のチェック..." -ForegroundColor Green

try {
    $nodeVersion = node --version
    Write-Host "  ✅ Node.js インストール済み: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Node.js がインストールされていません" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# ========================================
# npm チェック
# ========================================
Write-Host "📦 npm のチェック..." -ForegroundColor Green

try {
    $npmVersion = npm --version
    Write-Host "  ✅ npm インストール済み: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ npm がインストールされていません" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# ========================================
# roblox-ts チェック
# ========================================
Write-Host "📦 roblox-ts のチェック..." -ForegroundColor Green

try {
    $rbxtscVersion = rbxtsc --version
    Write-Host "  ✅ roblox-ts インストール済み: $rbxtscVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ roblox-ts がインストールされていません" -ForegroundColor Red
    Write-Host "     インストール: npm install -g roblox-ts" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

# ========================================
# Rojo チェック
# ========================================
Write-Host "📦 Rojo のチェック..." -ForegroundColor Green

try {
    $rojoVersion = rojo --version
    Write-Host "  ✅ Rojo インストール済み: $rojoVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Rojo がインストールされていません" -ForegroundColor Red
    Write-Host "     インストールスクリプトを実行してください:" -ForegroundColor Yellow
    Write-Host "     > .\scripts\install-rojo.ps1" -ForegroundColor Cyan
    $allGood = $false
}

Write-Host ""

# ========================================
# Roblox Studio チェック
# ========================================
Write-Host "📦 Roblox Studio のチェック..." -ForegroundColor Green

$robloxStudioPaths = @(
    "$env:LOCALAPPDATA\Roblox\Versions\*\RobloxStudioBeta.exe",
    "C:\Program Files (x86)\Roblox\Versions\*\RobloxStudioBeta.exe",
    "C:\Program Files\Roblox\Versions\*\RobloxStudioBeta.exe"
)

$studioPath = $null
foreach ($path in $robloxStudioPaths) {
    $found = Get-Item $path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $studioPath = $found.FullName
        break
    }
}

if ($studioPath) {
    Write-Host "  ✅ Roblox Studio インストール済み" -ForegroundColor Green
    Write-Host "     場所: $studioPath" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ Roblox Studio が見つかりませんでした" -ForegroundColor Red
    Write-Host "     ダウンロード: https://www.roblox.com/create" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

# ========================================
# Rojoプラグイン チェック
# ========================================
Write-Host "📦 Rojoプラグイン のチェック..." -ForegroundColor Green

$pluginPaths = @(
    "$env:USERPROFILE\Downloads\Rojo.rbxm",
    "$env:LOCALAPPDATA\Roblox\InstalledPlugins\Rojo.rbxm",
    "$env:LOCALAPPDATA\Roblox\Plugins\RojoManagedPlugin.rbxm"
)

$pluginFound = $false
foreach ($pluginPath in $pluginPaths) {
    if (Test-Path $pluginPath) {
        Write-Host "  ✅ Rojoプラグイン 見つかりました" -ForegroundColor Green
        Write-Host "     場所: $pluginPath" -ForegroundColor Cyan
        $pluginFound = $true
        break
    }
}

if (-not $pluginFound) {
    Write-Host "  ⚠️  Rojoプラグイン が見つかりませんでした" -ForegroundColor Yellow
    Write-Host "     ダウンロード: https://github.com/rojo-rbx/rojo/releases/latest/download/Rojo.rbxm" -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# プロジェクトチェック（オプション）
# ========================================
Write-Host "📦 Robloxプロジェクト のチェック..." -ForegroundColor Green

$projectPaths = @(
    "J:\My Drive\ROB",
    "c:\Users\dance\zone\ROB"
)

$projects = @()
foreach ($path in $projectPaths) {
    if (Test-Path $path) {
        $found = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | Where-Object {
            Test-Path (Join-Path $_.FullName "package.json")
        }
        if ($found) {
            $projects += $found
        }
    }
}

if ($projects.Count -gt 0) {
    Write-Host "  ✅ Robloxプロジェクト 見つかりました: $($projects.Count) 個" -ForegroundColor Green
    foreach ($project in $projects) {
        Write-Host "     - $($project.Name) ($($project.Parent.FullName))" -ForegroundColor Cyan
    }
} else {
    Write-Host "  ⚠️  Robloxプロジェクト が見つかりませんでした" -ForegroundColor Yellow
    Write-Host "     作成: npm init roblox-ts" -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# Git チェック（オプション）
# ========================================
Write-Host "📦 Git のチェック（オプション）..." -ForegroundColor Green

try {
    $gitVersion = git --version
    Write-Host "  ✅ Git インストール済み: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Git がインストールされていません（オプション）" -ForegroundColor Yellow
    Write-Host "     インストール: https://git-scm.com/downloads" -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# VS Code チェック（オプション）
# ========================================
Write-Host "📦 VS Code のチェック（オプション）..." -ForegroundColor Green

try {
    $codeVersion = code --version
    Write-Host "  ✅ VS Code インストール済み" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  VS Code がインストールされていません（オプション）" -ForegroundColor Yellow
    Write-Host "     インストール: https://code.visualstudio.com/" -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# サマリー
# ========================================
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  📊 チェック結果サマリー" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if ($allGood) {
    Write-Host "🎉 すべての必須ツールがインストールされています！" -ForegroundColor Green
    Write-Host "   Roblox開発を始める準備が整っています。" -ForegroundColor Green
    Write-Host ""
    Write-Host "次のステップ:" -ForegroundColor Yellow
    Write-Host "  1. 新規プロジェクト作成: npm init roblox-ts" -ForegroundColor White
    Write-Host "  2. 開発環境起動: .\start-dev.ps1" -ForegroundColor White
    Write-Host "  3. Roblox Studio で接続: PLUGINS → Rojo → Connect" -ForegroundColor White
} else {
    Write-Host "⚠️  一部のツールがインストールされていません" -ForegroundColor Yellow
    Write-Host "   上記のエラーメッセージを確認してください。" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "セットアップスクリプトを実行:" -ForegroundColor Yellow
    Write-Host "  .\setup-roblox-dev.ps1" -ForegroundColor White
}

Write-Host ""

# ========================================
# 詳細情報
# ========================================
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ℹ️  環境詳細情報" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "OS情報:" -ForegroundColor Magenta
Write-Host "  - OS: $([System.Environment]::OSVersion.VersionString)" -ForegroundColor White
Write-Host "  - ユーザー: $env:USERNAME" -ForegroundColor White
Write-Host "  - コンピューター名: $env:COMPUTERNAME" -ForegroundColor White
Write-Host ""

Write-Host "パス情報:" -ForegroundColor Magenta
Write-Host "  - 作業ディレクトリ: $PWD" -ForegroundColor White
Write-Host "  - ホームディレクトリ: $env:USERPROFILE" -ForegroundColor White
Write-Host ""

Write-Host "PowerShell情報:" -ForegroundColor Magenta
Write-Host "  - バージョン: $($PSVersionTable.PSVersion)" -ForegroundColor White
Write-Host ""

# ========================================
# 便利なコマンド一覧
# ========================================
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  🔧 便利なコマンド一覧" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "セットアップ:" -ForegroundColor Yellow
Write-Host "  .\setup-roblox-dev.ps1        # 開発環境セットアップ" -ForegroundColor White
Write-Host ""

Write-Host "プロジェクト作成:" -ForegroundColor Yellow
Write-Host "  npm init roblox-ts            # 新規プロジェクト作成" -ForegroundColor White
Write-Host ""

Write-Host "開発:" -ForegroundColor Yellow
Write-Host "  .\start-dev.ps1               # 開発環境起動" -ForegroundColor White
Write-Host "  npm run watch                 # TypeScript監視" -ForegroundColor White
Write-Host "  rojo serve                    # Rojo起動" -ForegroundColor White
Write-Host ""

Write-Host "ビルド:" -ForegroundColor Yellow
Write-Host "  .\build.ps1                   # ビルド実行" -ForegroundColor White
Write-Host "  npm run build                 # TypeScriptコンパイル" -ForegroundColor White
Write-Host "  rojo build -o game.rbxl       # プレイスファイル生成" -ForegroundColor White
Write-Host ""

Write-Host "デプロイ:" -ForegroundColor Yellow
Write-Host "  .\deploy.ps1                  # デプロイ（Roblox公開）" -ForegroundColor White
Write-Host ""

Read-Host "Enterキーを押して終了"
