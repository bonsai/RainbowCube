# Test Luau Execution using Lune
# Luneを使用してローカルでLuauを実行テストします

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\.."

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  🧪 Luau Execution Test" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Lune (Luau Runtime) のチェック
$luneExe = "lune"

# プロジェクトローカルの .bin をチェック
$localLune = Join-Path $PSScriptRoot "..\.bin\lune.exe"
if (Test-Path $localLune) {
    $luneExe = $localLune
}

try {
    $luneVersion = & $luneExe --version
    Write-Host "✅ Lune found: $luneVersion" -ForegroundColor Green
    if ($luneExe -ne "lune") {
        Write-Host "   Path: $luneExe" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Lune (Luau Runtime) が見つかりません。" -ForegroundColor Red
    Write-Host "   ローカルでLuauを実行するには Lune が必要です。" -ForegroundColor Yellow
    Write-Host "   インストールスクリプトを実行してください:" -ForegroundColor Cyan
    Write-Host "   > .\scripts\install-lune.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "   またはメニューから [8] Install Lune を選択してください。" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# 2. テスト用スクリプトの作成
$testFile = "test_execution.luau"
$content = @"
print("✨ Hello from Luau! The environment is working correctly.")
local x = 10
local y = 20
print("   Calculation check: " .. x .. " + " .. y .. " = " .. (x + y))

local function greet(name)
    return "   Greetings, " .. name .. "!"
end

print(greet("Developer"))
"@

# UTF8 (BOMなし) で保存
[System.IO.File]::WriteAllText("$PWD\$testFile", $content)

Write-Host "📝 テスト用ファイル作成: $testFile" -ForegroundColor Gray
Write-Host "🏃 実行中..." -ForegroundColor Cyan
Write-Host "------------------------------------------------" -ForegroundColor Gray

# 3. 実行
try {
    & $luneExe run $testFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "------------------------------------------------" -ForegroundColor Gray
        Write-Host "✅ Luauの実行テストに成功しました！" -ForegroundColor Green
    } else {
        Write-Host "------------------------------------------------" -ForegroundColor Gray
        Write-Host "❌ 実行エラーが発生しました" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ 実行に失敗しました: $_" -ForegroundColor Red
} finally {
    # 4. クリーンアップ
    if (Test-Path $testFile) {
        Remove-Item $testFile
        Write-Host "🧹 テストファイルを削除しました" -ForegroundColor Gray
    }
}
