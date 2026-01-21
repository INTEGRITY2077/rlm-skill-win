@echo off
echo ========================================
echo RLM Skill - Installation Test
echo ========================================
echo.

set "INSTALL_DIR=%USERPROFILE%\.claude\skills\rlm"

echo Checking installation directory...
if exist "%INSTALL_DIR%" (
    echo [OK] Directory exists: %INSTALL_DIR%
) else (
    echo [FAIL] Directory not found: %INSTALL_DIR%
    echo Please run install-windows.bat first.
    pause
    exit /b 1
)

echo.
echo Checking SKILL.md...
if exist "%INSTALL_DIR%\SKILL.md" (
    echo [OK] SKILL.md found
) else (
    echo [FAIL] SKILL.md not found
)

echo.
echo Checking rlm.py...
if exist "%INSTALL_DIR%\rlm.py" (
    echo [OK] rlm.py found
) else (
    echo [FAIL] rlm.py not found
)

echo.
echo Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [WARN] Python not found in PATH
    echo RLM will work but Python CLI features unavailable
) else (
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo [OK] %%i
)

echo.
echo Testing rlm.py...
python "%INSTALL_DIR%\rlm.py" --help >nul 2>&1
if errorlevel 1 (
    echo [WARN] rlm.py test failed
) else (
    echo [OK] rlm.py runs successfully
)

echo.
echo ========================================
echo Test Complete!
echo ========================================
echo.
echo If all checks passed, RLM Skill is ready to use.
echo Trigger in Claude Code with: "RLM", "analyze codebase", etc.
echo.
pause
