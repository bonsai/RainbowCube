---
name: "fix-encoding"
description: "Fixes character encoding issues (mojibake) in files, particularly PowerShell scripts and Japanese text. Invoke when user mentions 'mojibake', 'garbled text', or encoding errors."
---

# Fix Encoding (Mojibake Repair)

This skill helps diagnose and fix character encoding issues, commonly known as "mojibake", especially in Windows PowerShell environments involving Japanese text.

## Common Issues & Fixes

### 1. PowerShell Script Output (Japanese characters are garbled)
**Symptoms:** `Write-Host` output shows `???` or strange characters.
**Fix:**
Add this line to the top of the `.ps1` script:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

### 2. File Encoding for PowerShell 5.1
**Symptoms:** Scripts fail to run or display text incorrectly even with the output encoding fix.
**Fix:**
PowerShell 5.1 often requires files to be saved as **UTF-8 with BOM**.
Use the following PowerShell command to convert a file:
```powershell
$Content = Get-Content -Path "path/to/file.ps1" -Raw
$Content | Set-Content -Path "path/to/file.ps1" -Encoding UTF8
```
*(Note: In PowerShell 5.1, `-Encoding UTF8` adds the BOM by default, which is what we want.)*

### 3. Reading Files with Specific Encoding
If `Get-Content` is reading garbage:
```powershell
Get-Content "path/to/file.txt" -Encoding UTF8
# or for Shift-JIS
Get-Content "path/to/file.txt" -Encoding Default
```

## Workflow for the Assistant

1.  **Identify the file** causing issues.
2.  **Check current encoding** if possible (or assume UTF-8 without BOM is causing issues in legacy PS).
3.  **Apply Fix:**
    *   If it's a script outputting text: Add `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`.
    *   If it's a script file itself: Re-save with UTF-8 BOM.
4.  **Verify** by running the script or checking the file content.
