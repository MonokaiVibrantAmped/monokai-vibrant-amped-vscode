@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

REM Verify Node.js / npx is available
where npx >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 'npx' was not found in your PATH.
    echo Please install Node.js from https://nodejs.org/ to build the extension.
    echo.
    exit /b 1
)

REM Locate VSCode path
REM Not sure why you're running this without VSCode
set "VSCODE_CMD="
for /f "delims=" %%I in ('where code.cmd 2^>nul') do (
    if not defined VSCODE_CMD set "VSCODE_CMD=%%~fI"
)

if not defined VSCODE_CMD (
    if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" (
        set "VSCODE_CMD=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
    ) else if exist "%ProgramFiles%\Microsoft VS Code\bin\code.cmd" (
        set "VSCODE_CMD=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
    ) else if exist "%ProgramFiles(x86)%\Microsoft VS Code\bin\code.cmd" (
        set "VSCODE_CMD=%ProgramFiles(x86)%\Microsoft VS Code\bin\code.cmd"
    ) else (
        for /f "delims=" %%I in ('where code 2^>nul') do (
            if not defined VSCODE_CMD set "VSCODE_CMD=%%~fI"
        )
    )
)

if not defined VSCODE_CMD (
    echo [ERROR] Visual Studio Code CLI 'code' was not found in PATH or standard install locations.
    echo Please ensure Visual Studio Code is installed.
    echo.
    exit /b 1
)

REM Package extension
echo [1/2] Packaging extension VSIX with @vscode/vsce...
call npx --yes @vscode/vsce package --no-git-tag-version --allow-missing-repository --out MonokaiVibrantAmped.vsix
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Failed to package the VSIX extension.
    echo.
    exit /b %ERRORLEVEL%
)

REM Install extension
echo.
echo [2/2] Installing into Visual Studio Code...
call "%VSCODE_CMD%" --install-extension MonokaiVibrantAmped.vsix --force
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Failed to install the extension into Visual Studio Code.
    echo.
    exit /b %ERRORLEVEL%
)
