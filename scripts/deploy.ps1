# RainbowCube - デプロイスクリプト
# Robloxにゲームをアップロード

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  🌈 RainbowCube - デプロイ準備" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# プロジェクトルートに移動
Set-Location "$PSScriptRoot\.."

# プロジェクトディレクトリの確認
if (-not (Test-Path "package.json")) {
    Write-Host "❌ package.json が見つかりません" -ForegroundColor Red
    Write-Host "   このスクリプトはプロジェクトのルートディレクトリで実行してください" -ForegroundColor Yellow
    Read-Host "Enterキーを押して終了"
    exit
}

# ========================================
# Step 1: ビルド
# ========================================
Write-Host "📦 Step 1: まずビルドします..." -ForegroundColor Green
Write-Host ""

# build.ps1を実行
& .\scripts\build.ps1

Write-Host ""

# ========================================
# Step 2: デプロイ方法の案内
# ========================================
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  📤 Roblox へのデプロイ方法" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Roblox にゲームを公開する方法:" -ForegroundColor Yellow
Write-Host ""
Write-Host "方法1: Roblox Studio から公開（推奨）" -ForegroundColor Green
Write-Host "  1. ビルドしたプレイスファイルを Roblox Studio で開く" -ForegroundColor White
Write-Host "  2. File → Publish to Roblox" -ForegroundColor White
Write-Host "  3. ゲーム名、説明を入力" -ForegroundColor White
Write-Host "  4. Create または Overwrite を選択" -ForegroundColor White
Write-Host "  5. 公開完了！" -ForegroundColor White
Write-Host ""

Write-Host "方法2: Rojo Upload（コマンドライン）" -ForegroundColor Green
Write-Host "  ⚠️  要設定: Roblox API キーが必要" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Roblox Studio で API キーを生成:" -ForegroundColor White
Write-Host "     - File → Settings → Security" -ForegroundColor Cyan
Write-Host "     - Generate API Key をクリック" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. 環境変数に設定:" -ForegroundColor White
Write-Host "     `$env:ROBLOX_COOKIE = 'your_api_key'" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. コマンド実行:" -ForegroundColor White
Write-Host "     rojo upload --asset_id PLACE_ID" -ForegroundColor Cyan
Write-Host ""

# ========================================
# オプション: Rojo Upload を試す
# ========================================
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Rojo Upload を試しますか？ (Y/N)" -ForegroundColor Yellow
Write-Host "※ 事前に API キーの設定が必要です" -ForegroundColor Cyan
$useRojoUpload = Read-Host

if ($useRojoUpload -eq "Y" -or $useRojoUpload -eq "y") {
    Write-Host ""
    Write-Host "Roblox Place ID を入力してください:" -ForegroundColor Yellow
    Write-Host "（例: 123456789）" -ForegroundColor Cyan
    $placeId = Read-Host

    if ($placeId -ne "") {
        Write-Host ""
        Write-Host "⏳ Roblox にアップロード中..." -ForegroundColor Cyan

        # Rojo uploadコマンド
        rojo upload --asset_id $placeId

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ アップロード完了！" -ForegroundColor Green
            Write-Host "   ゲームURL: https://www.roblox.com/games/$placeId" -ForegroundColor Cyan
        } else {
            Write-Host "❌ アップロードに失敗しました" -ForegroundColor Red
            Write-Host "   API キーが設定されているか確認してください" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  📚 参考リンク" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "- Roblox Studio でゲームを公開する方法:" -ForegroundColor White
Write-Host "  https://create.roblox.com/docs/production/publishing" -ForegroundColor Cyan
Write-Host ""
