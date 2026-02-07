# Roblox開発環境セットアップスクリプト
# roblox-ts + Rojo のインストール

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Roblox開発環境セットアップ" -ForegroundColor Cyan
Write-Host "  roblox-ts + Rojo" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 管理者権限チェック
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  このスクリプトは管理者権限で実行してください" -ForegroundColor Yellow
    Write-Host "   右クリック → '管理者として実行'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Enterキーを押して終了"
    exit
}

# ========================================
# 1. Node.js のインストール確認
# ========================================
Write-Host "📦 Step 1: Node.js のチェック..." -ForegroundColor Green

try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js インストール済み: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js がインストールされていません" -ForegroundColor Red
    Write-Host ""
    Write-Host "Node.js をインストールしますか？ (Y/N)" -ForegroundColor Yellow
    $install = Read-Host

    if ($install -eq "Y" -or $install -eq "y") {
        Write-Host "Node.js をダウンロード中..." -ForegroundColor Cyan

        # Chocolatey経由でインストール（推奨）
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install nodejs-lts -y
        } else {
            Write-Host "Chocolatey がインストールされていません" -ForegroundColor Yellow
            Write-Host "手動でインストールしてください: https://nodejs.org/" -ForegroundColor Yellow
            Start-Process "https://nodejs.org/"
            Read-Host "Node.js インストール後、Enterキーを押してください"
        }
    } else {
        Write-Host "⚠️  Node.js なしでは続行できません" -ForegroundColor Red
        Read-Host "Enterキーを押して終了"
        exit
    }
}

# npmバージョン確認
try {
    $npmVersion = npm --version
    Write-Host "✅ npm インストール済み: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm が見つかりません" -ForegroundColor Red
    exit
}

Write-Host ""

# ========================================
# 2. roblox-ts のインストール
# ========================================
Write-Host "📦 Step 2: roblox-ts のインストール..." -ForegroundColor Green

try {
    $rbxtscVersion = rbxtsc --version
    Write-Host "✅ roblox-ts インストール済み: $rbxtscVersion" -ForegroundColor Green
} catch {
    Write-Host "⏳ roblox-ts をインストール中..." -ForegroundColor Cyan
    npm install -g roblox-ts

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ roblox-ts インストール完了" -ForegroundColor Green
    } else {
        Write-Host "❌ roblox-ts のインストールに失敗しました" -ForegroundColor Red
        Read-Host "Enterキーを押して終了"
        exit
    }
}

Write-Host ""

# ========================================
# 3. Foreman のインストール（Rojo管理用）
# ========================================
Write-Host "📦 Step 3: Foreman のインストール..." -ForegroundColor Green

# Foreman がインストール済みかチェック
try {
    $foremanVersion = foreman --version
    Write-Host "✅ Foreman インストール済み: $foremanVersion" -ForegroundColor Green
} catch {
    Write-Host "⏳ Foreman をインストール中..." -ForegroundColor Cyan

    # Rustがインストールされているかチェック
    try {
        $rustVersion = cargo --version
        Write-Host "✅ Rust インストール済み: $rustVersion" -ForegroundColor Green

        # Foremanをcargoでインストール
        cargo install foreman

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Foreman インストール完了" -ForegroundColor Green
        } else {
            Write-Host "❌ Foreman のインストールに失敗しました" -ForegroundColor Red
        }
    } catch {
        Write-Host "⚠️  Rust がインストールされていません" -ForegroundColor Yellow
        Write-Host "   Foreman は手動でインストールしてください" -ForegroundColor Yellow
        Write-Host "   https://github.com/Roblox/foreman" -ForegroundColor Cyan
    }
}

Write-Host ""

# ========================================
# 4. Rojo のインストール
# ========================================
Write-Host "📦 Step 4: Rojo のインストール..." -ForegroundColor Green

# Rojoがインストール済みかチェック
try {
    $rojoVersion = rojo --version
    Write-Host "✅ Rojo インストール済み: $rojoVersion" -ForegroundColor Green
} catch {
    Write-Host "⏳ Rojo をインストール中..." -ForegroundColor Cyan

    # Foreman経由でインストール
    if (Get-Command foreman -ErrorAction SilentlyContinue) {
        foreman install

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Rojo インストール完了" -ForegroundColor Green
        } else {
            Write-Host "❌ Rojo のインストールに失敗しました" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  Foreman がインストールされていません" -ForegroundColor Yellow
        Write-Host "   Rojo を手動でインストールしてください" -ForegroundColor Yellow
        Write-Host "   https://rojo.space/docs/v7/getting-started/installation/" -ForegroundColor Cyan

        # 直接ダウンロードを試みる
        Write-Host ""
        Write-Host "Rojo を直接ダウンロードしますか？ (Y/N)" -ForegroundColor Yellow
        $downloadRojo = Read-Host

        if ($downloadRojo -eq "Y" -or $downloadRojo -eq "y") {
            $rojoUrl = "https://github.com/rojo-rbx/rojo/releases/latest/download/rojo-win64.zip"
            $rojoZip = "$env:TEMP\rojo.zip"
            $rojoDir = "$env:LOCALAPPDATA\Rojo"

            Write-Host "⏳ Rojo をダウンロード中..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $rojoUrl -OutFile $rojoZip

            Write-Host "⏳ 解凍中..." -ForegroundColor Cyan
            Expand-Archive -Path $rojoZip -DestinationPath $rojoDir -Force

            # PATHに追加
            $env:Path += ";$rojoDir"
            [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)

            Write-Host "✅ Rojo ダウンロード完了" -ForegroundColor Green
            Write-Host "   場所: $rojoDir" -ForegroundColor Cyan
        }
    }
}

Write-Host ""

# ========================================
# 5. Rojo Roblox Studioプラグインのダウンロード
# ========================================
Write-Host "📦 Step 5: Rojo プラグインのダウンロード..." -ForegroundColor Green

$pluginUrl = "https://github.com/rojo-rbx/rojo/releases/latest/download/Rojo.rbxm"
$pluginPath = "$env:USERPROFILE\Downloads\Rojo.rbxm"

Write-Host "⏳ Rojoプラグインをダウンロード中..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $pluginUrl -OutFile $pluginPath
    Write-Host "✅ プラグインダウンロード完了" -ForegroundColor Green
    Write-Host "   場所: $pluginPath" -ForegroundColor Cyan
} catch {
    Write-Host "❌ プラグインのダウンロードに失敗しました" -ForegroundColor Red
    Write-Host "   手動でダウンロード: https://rojo.space/docs/v7/getting-started/installation/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📌 次のステップ（手動）:" -ForegroundColor Yellow
Write-Host "   1. Roblox Studio を開く" -ForegroundColor White
Write-Host "   2. PLUGINS タブ → Manage Plugins" -ForegroundColor White
Write-Host "   3. 「Load Plugin」をクリック" -ForegroundColor White
Write-Host "   4. ダウンロードした Rojo.rbxm を選択" -ForegroundColor White
Write-Host "      ($pluginPath)" -ForegroundColor Cyan
Write-Host ""

# ========================================
# 6. サンプルプロジェクトの作成（オプション）
# ========================================
Write-Host "📦 Step 6: サンプルプロジェクト作成（オプション）" -ForegroundColor Green
Write-Host "サンプルプロジェクトを作成しますか？ (Y/N)" -ForegroundColor Yellow
$createProject = Read-Host

if ($createProject -eq "Y" -or $createProject -eq "y") {
    $projectName = Read-Host "プロジェクト名を入力してください（例: my-roblox-game）"
    $projectPath = "j:\My Drive\ROB\$projectName"

    Write-Host "⏳ プロジェクト作成中: $projectPath" -ForegroundColor Cyan

    # roblox-tsプロジェクト初期化
    if (Test-Path $projectPath) {
        Write-Host "⚠️  フォルダが既に存在します: $projectPath" -ForegroundColor Yellow
    } else {
        New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
        Set-Location $projectPath

        # npm init
        npm init -y

        # roblox-ts インストール
        npm install --save-dev roblox-ts
        npm install --save-dev @rbxts/types

        # フォルダ構造作成
        New-Item -ItemType Directory -Path "src\client" -Force | Out-Null
        New-Item -ItemType Directory -Path "src\server" -Force | Out-Null
        New-Item -ItemType Directory -Path "src\shared" -Force | Out-Null

        # サンプルファイル作成
        @"
print("Hello from client!");
"@ | Out-File -FilePath "src\client\main.client.ts" -Encoding UTF8

        @"
print("Hello from server!");
"@ | Out-File -FilePath "src\server\main.server.ts" -Encoding UTF8

        # tsconfig.json作成
        @"
{
  "compilerOptions": {
    "outDir": "out",
    "rootDir": "src",
    "module": "commonjs",
    "strict": true,
    "moduleResolution": "node",
    "typeRoots": ["node_modules/@rbxts"],
    "types": ["@rbxts/types"]
  },
  "include": ["src/**/*"]
}
"@ | Out-File -FilePath "tsconfig.json" -Encoding UTF8

        # default.project.json作成（Rojo設定）
        @"
{
  "name": "$projectName",
  "tree": {
    "`$className": "DataModel",
    "ReplicatedStorage": {
      "`$className": "ReplicatedStorage",
      "TS": {
        "`$path": "out/shared"
      }
    },
    "ServerScriptService": {
      "`$className": "ServerScriptService",
      "TS": {
        "`$path": "out/server"
      }
    },
    "StarterPlayer": {
      "`$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "`$className": "StarterPlayerScripts",
        "TS": {
          "`$path": "out/client"
        }
      }
    }
  }
}
"@ | Out-File -FilePath "default.project.json" -Encoding UTF8

        # package.jsonにスクリプト追加
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        $packageJson.scripts = @{
            "build" = "rbxtsc"
            "watch" = "rbxtsc -w"
            "serve" = "rojo serve"
        }
        $packageJson | ConvertTo-Json -Depth 10 | Out-File "package.json" -Encoding UTF8

        Write-Host "✅ プロジェクト作成完了: $projectPath" -ForegroundColor Green
        Write-Host ""
        Write-Host "📌 次のステップ:" -ForegroundColor Yellow
        Write-Host "   1. cd `"$projectPath`"" -ForegroundColor White
        Write-Host "   2. npm run watch（別ターミナル）" -ForegroundColor White
        Write-Host "   3. npm run serve（別ターミナル）" -ForegroundColor White
        Write-Host "   4. Roblox Studio でRojoプラグイン → Connect" -ForegroundColor White
    }
}

Write-Host ""

# ========================================
# 完了
# ========================================
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ✅ セットアップ完了！" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "インストール済み:" -ForegroundColor Green
Write-Host "  ✓ Node.js & npm" -ForegroundColor White
Write-Host "  ✓ roblox-ts" -ForegroundColor White
Write-Host "  ✓ Rojo" -ForegroundColor White
Write-Host "  ✓ Rojoプラグイン（ダウンロード済み）" -ForegroundColor White
Write-Host ""
Write-Host "📚 参考リンク:" -ForegroundColor Cyan
Write-Host "  - roblox-ts ドキュメント: https://roblox-ts.com/" -ForegroundColor White
Write-Host "  - Rojo ドキュメント: https://rojo.space/" -ForegroundColor White
Write-Host ""
Write-Host "🎮 ハッカソン頑張ってください！" -ForegroundColor Magenta
Write-Host ""

Read-Host "Enterキーを押して終了"
