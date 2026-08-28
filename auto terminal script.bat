@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: Name:     Laravel Ultimate Setup Script
:: Purpose:  Interactive, Robust, and Feature-Rich Laravel Installer
:: Author:   Assistant
:: =========================================================================

:: --- COLORS ---
:: Removed ANSI color codes for Windows compatibility
set "RESET="
set "BOLD="
set "RED="
set "GREEN="
set "YELLOW="
set "BLUE="
set "CYAN="

cls
echo.
echo %BOLD%%CYAN%=====================================================%RESET%
echo %BOLD%%CYAN%   LARAVEL ULTIMATE SETUP SCRIPT                     %RESET%
echo %BOLD%%CYAN%   Interactive Installer with Best Practices         %RESET%
echo %BOLD%%CYAN%=====================================================%RESET%
echo.

:: --- 1. PREREQUISITE CHECK ---
echo %YELLOW%[*] Checking System Requirements...%RESET%

where php >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR] PHP is not installed or not in PATH.%RESET%
    pause
    exit /b 1
)

where composer >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR] Composer is not installed or not in PATH.%RESET%
    pause
    exit /b 1
)

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR] Git is not installed or not in PATH.%RESET%
    pause
    exit /b 1
)

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR] Node.js is not installed or not in PATH.%RESET%
    pause
    exit /b 1
)

where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR] NPM is not installed or not in PATH.%RESET%
    pause
    exit /b 1
)

echo %GREEN%[OK] All prerequisites found.%RESET%
echo.

:: --- 2. PROJECT SETUP ---
:PROMPT_NAME
set /p projectname="%BOLD%Enter project name [my-app]: %RESET%"
if "%projectname%"=="" set projectname=my-app

if exist "%projectname%" (
    echo %RED%[ERROR] Directory '%projectname%' already exists. Please choose another name.%RESET%
    goto PROMPT_NAME
)

echo.
echo %BOLD%Select Stack:%RESET%
echo   1. Standard Laravel (Blade)
echo   2. Laravel Breeze (Blade + Alpine)
echo   3. Laravel Breeze (Vue + SSR)
echo   4. Laravel Breeze (React + SSR)
echo   5. API Only
echo.
set /p stackchoice="%BOLD%Enter choice [1]: %RESET%"
if "%stackchoice%"=="" set stackchoice=1

echo.
echo %BOLD%Select Database:%RESET%
echo   1. SQLite (Zero Config)
echo   2. MySQL
echo.
set /p dbchoice="%BOLD%Enter choice [1]: %RESET%"
if "%dbchoice%"=="" set dbchoice=1

:: --- 3. CREATE PROJECT ---
echo.
echo %CYAN%[*] Creating Laravel Project...%RESET%
call composer create-project --prefer-dist laravel/laravel %projectname%
if %errorlevel% neq 0 (
    echo %RED%[ERROR] Failed to create project.%RESET%
    pause
    exit /b 1
)

cd %projectname%

:: --- 4. GIT INIT ---
echo.
echo %CYAN%[*] Initializing Git...%RESET%
call git init -b main
call git add .
call git commit -m "chore: initial laravel install"

:: --- 5. DATABASE CONFIGURATION ---
echo.
echo %CYAN%[*] Configuring Database...%RESET%

if "%dbchoice%"=="1" (
    echo %YELLOW%    - Setting up SQLite...%RESET%
    copy /y NUL database\database.sqlite >nul
    
    :: Use PowerShell for reliable .env replacement
    powershell -Command "(gc .env) -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=sqlite' | Out-File -encoding ASCII .env"
    powershell -Command "(gc .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=%cd%\database\database.sqlite' | Out-File -encoding ASCII .env"
    
    echo /database/database.sqlite >> .gitignore
) else (
    echo %YELLOW%    - Keeping MySQL config. Please ensure DB exists.%RESET%
    set /p dbname="Enter Database Name [laravel]: "
    if "!dbname!"=="" set dbname=laravel
    set /p dbuser="Enter Database User [root]: "
    if "!dbuser!"=="" set dbuser=root
    set /p dbpass="Enter Database Password []: "
    
    powershell -Command "(gc .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=!dbname!' | Out-File -encoding ASCII .env"
    powershell -Command "(gc .env) -replace 'DB_USERNAME=root', 'DB_USERNAME=!dbuser!' | Out-File -encoding ASCII .env"
    powershell -Command "(gc .env) -replace 'DB_PASSWORD=', 'DB_PASSWORD=!dbpass!' | Out-File -encoding ASCII .env"
)

:: Gitignore Tweaks
echo. >> .gitignore
echo # IDE Helpers >> .gitignore
echo .phpstackbin >> .gitignore
echo _ide_helper.php >> .gitignore
echo _ide_helper_models.php >> .gitignore
echo .phpstorm.meta.php >> .gitignore

call git add .
call git commit -m "config: database and gitignore setup"

:: --- 6. STACK INSTALLATION ---
if "%stackchoice%"=="1" (
    echo %YELLOW%[*] Skipping specific stack installation (Standard Blade).%RESET%
)

if "%stackchoice%"=="2" (
    echo %CYAN%[*] Installing Breeze (Blade)...%RESET%
    call composer require laravel/breeze --dev
    call php artisan breeze:install blade --quiet
)

if "%stackchoice%"=="3" (
    echo %CYAN%[*] Installing Breeze (Vue + SSR)...%RESET%
    call composer require laravel/breeze --dev
    call php artisan breeze:install vue --ssr --quiet
)

if "%stackchoice%"=="4" (
    echo %CYAN%[*] Installing Breeze (React + SSR)...%RESET%
    call composer require laravel/breeze --dev
    call php artisan breeze:install react --ssr --quiet
)

if "%stackchoice%"=="5" (
    echo %CYAN%[*] Configuring API Only...%RESET%
    call php artisan install:api
)

:: Commit after stack
if not "%stackchoice%"=="1" (
    call git add .
    call git commit -m "feat: install chosen stack"
)

:: --- 7. DEV TOOLS ---
echo.
echo %CYAN%[*] Installing Developer Tools...%RESET%
call composer require laravel/telescope barryvdh/laravel-debugbar barryvdh/laravel-ide-helper beyondcode/laravel-query-detector crestapps/laravel-code-generator --dev
call php artisan telescope:install
call php artisan ide-helper:generate
call php artisan ide-helper:meta
call php artisan vendor:publish --provider=BeyondCode\QueryDetector\QueryDetectorServiceProvider

call git add .
call git commit -m "chore: install dev tools (telescope, debugbar, ide-helper)"

:: --- 8. PRODUCTION PACKAGES ---
echo.
echo %CYAN%[*] Installing Production Packages (Spatie, UUID)...%RESET%
call composer require spatie/laravel-permission spatie/laravel-activitylog
call php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
call php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations"

call php artisan migrate --force

call git add .
call git commit -m "feat: install spatie packages and migrate"

:: --- 9. SCAFFOLDING EXAMPLE ---
echo.
echo %CYAN%[*] Generating Example Resource (Department)...%RESET%
call php artisan resource-file:create Department --fields="id,name,image,is_active"
call php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration
call php artisan migrate --force

call git add .
call git commit -m "feat: generate example department resource"

:: --- 10. FRONTEND BUILD ---
echo.
echo %CYAN%[*] Building Frontend Assets...%RESET%
call npm install
call npm run build

call git add .
call git commit -m "build: compile assets"

:: --- 11. SUMMARY ---
cls
echo %GREEN%=====================================================%RESET%
echo %GREEN%   INSTALLATION COMPLETE SUCCESSFUL!                 %RESET%
echo %GREEN%=====================================================%RESET%
echo.
echo  %BOLD%Project:%RESET%   %projectname%
echo  %BOLD%Location:%RESET%  %cd%
echo  %BOLD%Database:%RESET%  (Check .env)
echo.
echo  %YELLOW%Next Steps:%RESET%
echo  1. cd %projectname%
echo  2. php artisan serve
echo.
echo  %YELLOW%URLs:%RESET%
echo  - App: http://127.0.0.1:8000
echo  - Telescope: http://127.0.0.1:8000/telescope
echo.
pause