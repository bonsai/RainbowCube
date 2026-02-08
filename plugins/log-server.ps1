# ========================================
# Simple Log Server for Roblox Debugging
# ========================================
# Listens on http://localhost:8081/log
# Appends received data to debug-log.txt

$Port = 8081
$LogDir = "$PSScriptRoot\..\log"
$LogFile = Join-Path $LogDir "debug-log.txt"

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

$Listener = New-Object System.Net.HttpListener
$Listener.Prefixes.Add("http://localhost:$Port/")

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "📡 Log Server running on port $Port" -ForegroundColor Cyan
Write-Host "   Log File: $LogFile" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host ""

try {
    $Listener.Start()
} catch {
    Write-Host "❌ Failed to start listener. Port $Port might be in use." -ForegroundColor Red
    exit 1
}

# Create/Clear log file
"=== Log Server Started: $(Get-Date) ===" | Set-Content $LogFile -Encoding utf8

while ($Listener.IsListening) {
    $Context = $Listener.GetContext()
    $Request = $Context.Request
    $Response = $Context.Response

    if ($Request.HttpMethod -eq "POST") {
        $Reader = New-Object System.IO.StreamReader($Request.InputStream, $Request.ContentEncoding)
        $Body = $Reader.ReadToEnd()
        $Reader.Close()

        $Timestamp = Get-Date -Format "HH:mm:ss"
        $LogEntry = "[$Timestamp] $Body"
        
        # Write to console and file
        Write-Host $LogEntry -ForegroundColor Green
        $LogEntry | Out-File -FilePath $LogFile -Append -Encoding utf8

        # Send response
        $ResponseBytes = [System.Text.Encoding]::UTF8.GetBytes("OK")
        $Response.ContentLength64 = $ResponseBytes.Length
        $Response.OutputStream.Write($ResponseBytes, 0, $ResponseBytes.Length)
    }
    else {
        $Response.StatusCode = 404
    }

    $Response.Close()
}
