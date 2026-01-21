# RLM Skill - PowerShell Installer for Windows
# More robust than batch script, with better error handling

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RLM Skill - Windows Installer (PowerShell)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define installation directory
$installDir = Join-Path $env:USERPROFILE ".claude\skills\rlm"

# Create directory if it doesn't exist
if (-not (Test-Path $installDir)) {
    Write-Host "Creating directory: $installDir" -ForegroundColor Yellow
    try {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Write-Host "[OK] Directory created" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to create directory: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}
else {
    Write-Host "[OK] Directory already exists: $installDir" -ForegroundColor Green
}

# Download files
$files = @{
    "SKILL.md" = "https://raw.githubusercontent.com/BowTiedSwan/rlm-skill/main/SKILL.md"
    "rlm.py"   = "https://raw.githubusercontent.com/BowTiedSwan/rlm-skill/main/rlm.py"
}

foreach ($file in $files.GetEnumerator()) {
    $fileName = $file.Key
    $url = $file.Value
    $outputPath = Join-Path $installDir $fileName

    Write-Host "Downloading $fileName..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
        $fileSize = (Get-Item $outputPath).Length
        Write-Host "[OK] Downloaded $fileName ($fileSize bytes)" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to download $fileName : $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files installed to:" -ForegroundColor White
Write-Host "  $installDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Installed files:" -ForegroundColor White
Get-ChildItem $installDir | ForEach-Object {
    Write-Host "  - $($_.Name) ($($_.Length) bytes)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  - Trigger with: 'analyze codebase', 'scan all files', 'RLM'" -ForegroundColor Gray
Write-Host "  - Run Python tool: python `"$installDir\rlm.py`" --help" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to exit"
