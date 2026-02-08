# RainbowCube - CICD Pipeline
# Automated Build, Test, and Deployment Pipeline

$ErrorActionPreference = "Stop"

# Configuration
$CICDConfig = @{
    BuildScript = ".\scripts\build.ps1"
    EvaluateScript = ".\scripts\evaluate-loop.ps1"
    DeployScript = ".\scripts\deploy.ps1"
    LogPath = ".\log\cicd-log.txt"
    ReportPath = ".\reports\cicd-report.json"
    MaxBuildAttempts = 3
    MaxDeployAttempts = 2
}

# Helper Functions
function Write-CICDLog {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    Write-Host $logEntry
    
    # Write to log file
    $logDir = Split-Path $CICDConfig.LogPath
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    Add-Content -Path $CICDConfig.LogPath -Value $logEntry
}

function Write-CICDReport {
    param([string]$Section, [string]$Status, [string]$Details = "")
    
    $report = @{
        Timestamp = Get-Date -Format "o"
        Section = $Section
        Status = $Status
        Details = $Details
    }
    
    # Write to report file
    $reportDir = Split-Path $CICDConfig.ReportPath
    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    
    # Append to report
    $reportJson = $report | ConvertTo-Json
    Add-Content -Path $CICDConfig.ReportPath -Value $reportJson
    
    # Also log to console
    if ($Status -eq "SUCCESS") {
        Write-CICDLog "✅ $Section: $Details" "SUCCESS"
    } elseif ($Status -eq "WARNING") {
        Write-CICDLog "⚠️  $Section: $Details" "WARNING"
    } else {
        Write-CICDLog "❌ $Section: $Details" "ERROR"
    }
}

function Test-Environment {
    Write-CICDLog "🔍 Checking development environment..." "INFO"
    
    $envIssues = @()
    
    # Check Node.js
    try {
        $nodeVersion = node --version
        Write-CICDLog "📦 Node.js: $nodeVersion" "INFO"
    } catch {
        $envIssues += "Node.js not found"
    }
    
    # Check npm
    try {
        $npmVersion = npm --version
        Write-CICDLog "📦 npm: $npmVersion" "INFO"
    } catch {
        $envIssues += "npm not found"
    }
    
    # Check Rojo
    try {
        $rojoVersion = rojo --version
        Write-CICDLog "🏗️  Rojo: $rojoVersion" "INFO"
    } catch {
        $envIssues += "Rojo not found"
    }
    
    # Check Roblox Studio
    try {
        $studioPath = Get-Command "RobloxStudioBeta.exe" -ErrorAction SilentlyContinue
        if ($studioPath) {
            Write-CICDLog "🎮 Roblox Studio: Found" "INFO"
        } else {
            $envIssues += "Roblox Studio not found"
        }
    } catch {
        $envIssues += "Roblox Studio not found"
    }
    
    if ($envIssues.Count -gt 0) {
        Write-CICDLog "⚠️  Environment issues detected: $($envIssues -join ', ')" "WARNING"
        return $false
    }
    
    Write-CICDLog "✅ Environment check passed" "SUCCESS"
    return $true
}

function Invoke-Build {
    param([int]$Attempt = 1)
    
    Write-CICDLog "🐷 Starting build attempt $Attempt..." "INFO"
    
    try {
        # Run the existing build script
        & $CICDConfig.BuildScript
        
        if ($LASTEXITCODE -eq 0) {
            Write-CICDLog "✅ Build completed successfully" "SUCCESS"
            Write-CICDReport "Build" "SUCCESS" "Build completed on attempt $Attempt"
            return $true
        } else {
            Write-CICDLog "❌ Build failed with exit code $LASTEXITCODE" "ERROR"
            Write-CICDReport "Build" "FAILURE" "Build failed on attempt $Attempt with exit code $LASTEXITCODE"
            
            if ($Attempt -lt $CICDConfig.MaxBuildAttempts) {
                $retryDelay = 5 # seconds
                Write-CICDLog "⏳ Retrying build in $retryDelay seconds..." "WARNING"
                Start-Sleep -Seconds $retryDelay
                return Invoke-Build -Attempt ($Attempt + 1)
            }
            
            return $false
        }
    }
    catch {
        Write-CICDLog "❌ Build exception: $($_.Exception.Message)" "ERROR"
        Write-CICDReport "Build" "FAILURE" "Build exception on attempt $Attempt: $($_.Exception.Message)"
        
        if ($Attempt -lt $CICDConfig.MaxBuildAttempts) {
            $retryDelay = 5 # seconds
            Write-CICDLog "⏳ Retrying build in $retryDelay seconds..." "WARNING"
            Start-Sleep -Seconds $retryDelay
            return Invoke-Build -Attempt ($Attempt + 1)
        }
        
        return $false
    }
}

function Invoke-Evaluation {
    Write-CICDLog "🧪 Running evaluation loop..." "INFO"
    
    try {
        # Run the existing evaluation script
        & $CICDConfig.EvaluateScript
        
        if ($LASTEXITCODE -eq 0) {
            Write-CICDLog "✅ Evaluation completed successfully" "SUCCESS"
            Write-CICDReport "Evaluation" "SUCCESS" "Evaluation passed"
            return $true
        } else {
            Write-CICDLog "⚠️  Evaluation completed with issues" "WARNING"
            Write-CICDReport "Evaluation" "WARNING" "Evaluation completed with issues"
            return $false
        }
    }
    catch {
        Write-CICDLog "❌ Evaluation exception: $($_.Exception.Message)" "ERROR"
        Write-CICDReport "Evaluation" "FAILURE" "Evaluation exception: $($_.Exception.Message)"
        return $false
    }
}

function Invoke-Deployment {
    param([int]$Attempt = 1)
    
    Write-CICDLog "📦 Starting deployment attempt $Attempt..." "INFO"
    
    try {
        # Run the existing deploy script
        & $CICDConfig.DeployScript
        
        if ($LASTEXITCODE -eq 0) {
            Write-CICDLog "✅ Deployment completed successfully" "SUCCESS"
            Write-CICDReport "Deployment" "SUCCESS" "Deployment completed on attempt $Attempt"
            return $true
        } else {
            Write-CICDLog "❌ Deployment failed with exit code $LASTEXITCODE" "ERROR"
            Write-CICDReport "Deployment" "FAILURE" "Deployment failed on attempt $Attempt with exit code $LASTEXITCODE"
            
            if ($Attempt -lt $CICDConfig.MaxDeployAttempts) {
                $retryDelay = 10 # seconds
                Write-CICDLog "⏳ Retrying deployment in $retryDelay seconds..." "WARNING"
                Start-Sleep -Seconds $retryDelay
                return Invoke-Deployment -Attempt ($Attempt + 1)
            }
            
            return $false
        }
    }
    catch {
        Write-CICDLog "❌ Deployment exception: $($_.Exception.Message)" "ERROR"
        Write-CICDReport "Deployment" "FAILURE" "Deployment exception on attempt $Attempt: $($_.Exception.Message)"
        
        if ($Attempt -lt $CICDConfig.MaxDeployAttempts) {
            $retryDelay = 10 # seconds
            Write-CICDLog "⏳ Retrying deployment in $retryDelay seconds..." "WARNING"
            Start-Sleep -Seconds $retryDelay
            return Invoke-Deployment -Attempt ($Attempt + 1)
        }
        
        return $false
    }
}

function Generate-Report {
    Write-CICDLog "📊 Generating comprehensive report..." "INFO"
    
    # Collect build artifacts
    $buildArtifacts = @()
    $buildFile = "RainbowCube.rbxlx"
    if (Test-Path $buildFile) {
        $buildArtifacts += @{
            Name = $buildFile
            Size = (Get-Item $buildFile).Length
            Created = (Get-Item $buildFile).CreationTime
        }
    }
    
    # Collect log files
    $logFiles = Get-ChildItem -Path ".\log\*.txt" -ErrorAction SilentlyContinue
    $logSummary = @()
    foreach ($logFile in $logFiles) {
        $logSummary += @{
            Name = $logFile.Name
            Size = $logFile.Length
            Created = $logFile.CreationTime
            Lines = (Get-Content $logFile).Count
        }
    }
    
    # Generate summary report
    $summaryReport = @{
        Timestamp = Get-Date -Format "o"
        Status = "COMPLETED"
        BuildArtifacts = $buildArtifacts
        LogFiles = $logSummary
        Environment = @{
            OS = $PSVersionTable.OS
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            WorkingDirectory = Get-Location
        }
    }
    
    # Save summary report
    $summaryPath = ".\reports\cicd-summary.json"
    $summaryDir = Split-Path $summaryPath
    if (-not (Test-Path $summaryDir)) {
        New-Item -ItemType Directory -Path $summaryDir -Force | Out-Null
    }
    
    $summaryReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $summaryPath -Encoding UTF8
    
    Write-CICDLog "✅ Report generated: $summaryPath" "SUCCESS"
}

function Cleanup-TempFiles {
    Write-CICDLog "🧹 Cleaning up temporary files..." "INFO"
    
    # Remove temporary build files
    $tempFiles = @(
        ".\out\*",
        ".\*.tmp",
        ".\*.log"
    )
    
    foreach ($tempFile in $tempFiles) {
        Remove-Item -Path $tempFile -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-CICDLog "✅ Cleanup completed" "SUCCESS"
}

# Main CICD Pipeline
Write-Host "
🚀 RainbowCube CICD Pipeline
======================================
" -ForegroundColor Cyan

# Initialize
$startTime = Get-Date
$overallStatus = "SUCCESS"

try {
    # Step 1: Environment Check
    Write-CICDLog "🚀 Starting CICD pipeline..." "INFO"
    Write-CICDLog "📋 Pipeline Configuration:" "INFO"
    Write-CICDLog "   Build Script: $($CICDConfig.BuildScript)" "INFO"
    Write-CICDLog "   Evaluate Script: $($CICDConfig.EvaluateScript)" "INFO"
    Write-CICDLog "   Deploy Script: $($CICDConfig.DeployScript)" "INFO"
    Write-CICDLog "   Max Build Attempts: $($CICDConfig.MaxBuildAttempts)" "INFO"
    Write-CICDLog "   Max Deploy Attempts: $($CICDConfig.MaxDeployAttempts)" "INFO"
    
    # Environment Check
    $envCheck = Test-Environment
    if (-not $envCheck) {
        $overallStatus = "FAILURE"
        throw "Environment check failed"
    }
    
    # Step 2: Build
    Write-CICDLog "🔨 Step 1: Building project..." "INFO"
    $buildSuccess = Invoke-Build
    if (-not $buildSuccess) {
        $overallStatus = "FAILURE"
        throw "Build failed after $($CICDConfig.MaxBuildAttempts) attempts"
    }
    
    # Step 3: Evaluation
    Write-CICDLog "🧪 Step 2: Running evaluation loop..." "INFO"
    $evalSuccess = Invoke-Evaluation
    if (-not $evalSuccess) {
        Write-CICDLog "⚠️  Evaluation completed with issues, continuing..." "WARNING"
    }
    
    # Step 4: Deployment
    Write-CICDLog "📦 Step 3: Deploying to Roblox Studio..." "INFO"
    $deploySuccess = Invoke-Deployment
    if (-not $deploySuccess) {
        Write-CICDLog "⚠️  Deployment completed with issues" "WARNING"
    }
    
    # Step 5: Reporting
    Write-CICDLog "📊 Step 4: Generating reports..." "INFO"
    Generate-Report
    
    # Step 6: Cleanup
    Write-CICDLog "🧹 Step 5: Cleaning up..." "INFO"
    Cleanup-TempFiles
    
    # Final Summary
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host "
🎉 CICD Pipeline Summary
===========================" -ForegroundColor Green
    Write-Host "   Status: $overallStatus" -ForegroundColor Green
    Write-Host "   Duration: $($duration.Hours)h $($duration.Minutes)m $($duration.Seconds)s" -ForegroundColor Gray
    Write-Host "   Start Time: $startTime" -ForegroundColor Gray
    Write-Host "   End Time: $endTime" -ForegroundColor Gray
    Write-Host "   Build Artifacts: RainbowCube.rbxlx" -ForegroundColor Cyan
    Write-Host "   Reports: cicd-summary.json, cicd-report.json" -ForegroundColor Cyan
    Write-Host "   Logs: cicd-log.txt" -ForegroundColor Cyan
    
    Write-CICDLog "🎉 CICD pipeline completed with status: $overallStatus" "SUCCESS"
    
} catch {
    $overallStatus = "FAILURE"
    Write-CICDLog "❌ CICD pipeline failed: $($_.Exception.Message)" "ERROR"
    Write-Host "
❌ CICD Pipeline Failed
=======================" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Status: $overallStatus" -ForegroundColor Red
    
    # Generate failure report
    Generate-Report
}

# Exit with appropriate code
if ($overallStatus -eq "SUCCESS") {
    exit 0
} else {
    exit 1
}