@echo off
setlocal enabledelayedexpansion

echo ========================================
echo RLM Skill - Windows Installer
echo ========================================
echo.

REM Define installation directory
set "INSTALL_DIR=%USERPROFILE%\.claude\skills\rlm"

REM Create directory if it doesn't exist
if not exist "%INSTALL_DIR%" (
    echo Creating directory: %INSTALL_DIR%
    mkdir "%INSTALL_DIR%" 2>nul
    if errorlevel 1 (
        echo [ERROR] Failed to create directory
        pause
        exit /b 1
    )
)

REM Check if curl is available (Windows 10 1803+)
where curl >nul 2>nul
if errorlevel 1 (
    echo [ERROR] curl not found. Please install curl or use PowerShell script instead.
    pause
    exit /b 1
)

echo Downloading SKILL.md...
curl -fsSL "https://raw.githubusercontent.com/BowTiedSwan/rlm-skill/main/SKILL.md" -o "%INSTALL_DIR%\SKILL.md"
if errorlevel 1 (
    echo [ERROR] Failed to download SKILL.md
    pause
    exit /b 1
)

echo Downloading rlm.py...
curl -fsSL "https://raw.githubusercontent.com/BowTiedSwan/rlm-skill/main/rlm.py" -o "%INSTALL_DIR%\rlm.py"
if errorlevel 1 (
    echo [ERROR] Failed to download rlm.py
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Files installed to:
echo %INSTALL_DIR%
echo.
dir /b "%INSTALL_DIR%"
echo.
echo Usage:
echo - Trigger with: "analyze codebase", "scan all files", "RLM"
echo - Run Python tool: python "%INSTALL_DIR%\rlm.py" --help
echo.
pause
