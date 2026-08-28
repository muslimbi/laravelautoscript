@echo off
setlocal
set "ROOT=%~dp0..\.."
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is required to run LaravelAutoScript v2.
    exit /b 1
)
node "%ROOT%\scripts\platform-builder.js" %*
exit /b %ERRORLEVEL%
