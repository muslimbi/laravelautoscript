@echo off
setlocal
set "ROOT=%~dp0.."
node "%ROOT%\scripts\platform-builder.js" %*
exit /b %ERRORLEVEL%
