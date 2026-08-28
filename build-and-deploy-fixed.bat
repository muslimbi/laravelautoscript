@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: Name:     Laravel Build & Deploy Script
:: Purpose:  Complete Laravel development workflow with templates, plugins,
::            debugger, and supporting tools
:: Author:   Assistant
:: =========================================================================

:: --- CONFIGURATION ---
set "PROJECT_NAME="
set "DEPLOY_MODE=local"
set "INSTALL_TEMPLATE=yes"
set "INSTALL_PLUGINS=yes"
set "INSTALL_DEBUGGER=yes"
set "INSTALL_DEVTOOLS=yes"
set "BUILD_ASSETS=yes"
set "RUN_MIGRATIONS=yes"

:: ============================================================================

:: MAIN MENU
:: ============================================================================

:MENU
cls
echo.
echo ====================================================
echo           LARAVEL BUILD & DEPLOY SCRIPT             
echo ====================================================
echo.
echo  [1]  New Project Setup     - Create fresh Laravel installation
echo  [2]  Existing Project      - Build & deploy existing project
echo  [3]  Quick Build           - Build assets only
echo  [4]  Local Deploy          - Deploy to local environment
echo  [5]  Server Deploy         - Deploy to remote server
echo  [6]  Configure Options     - Customize installation settings
echo  [7]  System Check          - Verify prerequisites
echo  [0]  Exit
echo.
echo Current Settings:
echo   Template: !INSTALL_TEMPLATE!  |  Plugins: !INSTALL_PLUGINS!  |  Debugger: !INSTALL_DEBUGGER!
echo   DevTools: !INSTALL_DEVTOOLS!  |  Assets: !BUILD_ASSETS!  |  Migrate: !RUN_MIGRATIONS!
echo.
set /p choice="Select option [0-7]: "

if "%choice%"=="1" goto NEW_PROJECT
if "%choice%"=="2" goto EXISTING_PROJECT
if "%choice%"=="3" goto QUICK_BUILD
if "%choice%"=="4" goto LOCAL_DEPLOY
if "%choice%"=="5" goto SERVER_DEPLOY
if "%choice%"=="6" goto CONFIGURE_OPTIONS
if "%choice%"=="7" goto SYSTEM_CHECK
if "%choice%"=="0" goto EXIT
goto MENU

:: ============================================================================

:: OPTION 1: NEW PROJECT SETUP
:: ============================================================================

:NEW_PROJECT
cls
echo ====================================================
echo           NEW LARAVEL PROJECT SETUP                 
echo ====================================================
echo.

:: Check prerequisites first
call :CHECK_PREREQUISITES
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Prerequisites check failed.
    pause
    goto MENU
)

:: Get project name
:ASK_PROJECT_NAME
set /p PROJECT_NAME="Enter project name [laravel-app]: "
if "%PROJECT_NAME%"=="" set PROJECT_NAME=laravel-app

if exist "%PROJECT_NAME%" (
    echo [ERROR] Directory '%PROJECT_NAME%' already exists.
    goto ASK_PROJECT_NAME
)

:: Select authentication stack
echo.
echo Select Authentication Template:
echo   [1]  Standard Laravel (Blade)
echo   [2]  Laravel Breeze (Blade + Alpine)
echo   [3]  Laravel Breeze (Vue + SSR)
echo   [4]  Laravel Breeze (React + SSR)
echo   [5]  Laravel Jetstream (Inertia)
echo   [6]  API Only (Sanctum)
echo   [7]  None (Manual)
set /p TEMPLATE_CHOICE="Enter choice [2]: "
if "%TEMPLATE_CHOICE%"=="" set TEMPLATE_CHOICE=2

:: Select database
echo.
echo Select Database:
echo   [1]  SQLite (Development)
echo   [2]  MySQL
echo   [3]  PostgreSQL
set /p DB_CHOICE="Enter choice [1]: "
if "%DB_CHOICE%"=="" set DB_CHOICE=1

:: Create project
echo.
echo [*] Creating Laravel project: %PROJECT_NAME%
call composer create-project --prefer-dist laravel/laravel %PROJECT_NAME%
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to create Laravel project.
    pause
    goto MENU
)

cd %PROJECT_NAME%
echo.

:: ============================================================================

:: INSTALLATION PHASES
:: ============================================================================

:: Phase 1: Git Initialization
echo [1/6] Initializing Git repository...
call git init -b main
call git add .
call git commit -m "chore: initial laravel installation"
echo [OK] Git initialized

:: Phase 2: Database Configuration
echo.
echo [2/6] Configuring database...
call :CONFIGURE_DATABASE %DB_CHOICE%
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Database configuration failed.
    pause
    goto MENU
)

:: Phase 3: Install Authentication Template
echo.
echo [3/6] Installing authentication template...
call :INSTALL_TEMPLATE %TEMPLATE_CHOICE%
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Template installation failed.
    pause
    goto MENU
)

:: Phase 4: Install Plugins & Packages
if "%INSTALL_PLUGINS%"=="yes" (
    echo.
    echo [4/6] Installing plugins and packages...
    call :INSTALL_PLUGINS
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Plugin installation failed.
        pause
    )
)

:: Phase 5: Install Debugger & DevTools
if "%INSTALL_DEBUGGER%"=="yes" (
    echo.
    echo [5/6] Installing debugger and development tools...
    call :INSTALL_DEBUGGER
)

if "%INSTALL_DEVTOOLS%"=="yes" (
    call :INSTALL_DEVTOOLS
)

:: Phase 6: Build Assets
if "%BUILD_ASSETS%"=="yes" (
    echo.
    echo [6/6] Building frontend assets...
    call :BUILD_FRONTEND
)

:: Run migrations if enabled
if "%RUN_MIGRATIONS%"=="yes" (
    echo.
    echo [*] Running migrations...
    call php artisan migrate --force
)

:: Final commit
call git add .
call git commit -m "build: complete project setup" 2>nul

:: ============================================================================

:: SUMMARY
:: ============================================================================

cls
echo ====================================================
echo           PROJECT SETUP COMPLETE!                   
echo ====================================================
echo.
echo  Project:   %PROJECT_NAME%
echo  Location:  %CD%
echo  Database:  SQLite
echo.
echo  Installed Components:
echo   - Laravel Framework
echo   - Authentication: Breeze (%TEMPLATE_CHOICE%)
if "%INSTALL_PLUGINS%"=="yes" echo   - Plugins: Spatie (Permission, ActivityLog)
if "%INSTALL_DEBUGGER%"=="yes" echo   - Debugger: Telescope, Debugbar
if "%INSTALL_DEVTOOLS%"=="yes" echo   - DevTools: IDE Helper, Query Detector
echo.
echo  Quick Commands:
echo   cd %PROJECT_NAME%
echo   php artisan serve
echo.
echo  Useful URLs:
echo   - App:        http://127.0.0.1:8000
if "%INSTALL_DEBUGGER%"=="yes" echo   - Telescope:  http://127.0.0.1:8000/telescope
if "%INSTALL_DEBUGGER%"=="yes" echo   - Debugbar:   http://127.0.0.1:8000/_debugbar
echo.
pause
cd ..
goto MENU

:: ============================================================================

:: OPTION 2: EXISTING PROJECT
:: ============================================================================

:EXISTING_PROJECT
cls
echo ====================================================
echo           EXISTING PROJECT - BUILD & DEPLOY           
echo ====================================================
echo.

set /p PROJECT_PATH="Enter project path or name [.]: "
if "%PROJECT_PATH%"=="" set PROJECT_PATH=.

if not exist "%PROJECT_PATH%\artisan" (
    echo [ERROR] No Laravel project found at '%PROJECT_PATH%'
    pause
    goto MENU
)

cd /d "%PROJECT_PATH%"
echo [*] Working in: %CD%

:: Check for composer.json
if not exist "composer.json" (
    echo [ERROR] composer.json not found.
    pause
    goto MENU
)

echo.
echo [*] Installing composer dependencies...
call composer install --prefer-dist
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Composer install failed.
    pause
    goto MENU
)

:: Run migrations
if "%RUN_MIGRATIONS%"=="yes" (
    echo.
    echo [*] Running migrations...
    call php artisan migrate --force
)

:: Clear and rebuild caches
echo.
echo [*] Clearing and rebuilding caches...
call php artisan config:clear
call php artisan cache:clear
call php artisan route:clear
call php artisan view:clear
call php artisan optimize:clear

:: Build frontend
if "%BUILD_ASSETS%"=="yes" (
    echo.
    echo [*] Building frontend assets...
    call :BUILD_FRONTEND
)

:: Optimize for production
echo.
echo [*] Optimizing for production...
call php artisan config:cache
call php artisan route:cache
call php artisan view:cache
call php artisan optimize

echo.
echo [SUCCESS] Build complete!
echo.
set /p DEPLOY_NOW="Do you want to deploy now? [y/N]: "
if /i "%DEPLOY_NOW%"=="y" goto SERVER_DEPLOY

goto MENU

:: ============================================================================

:: OPTION 3: QUICK BUILD
:: ============================================================================

:QUICK_BUILD
cls
echo ====================================================
echo                    QUICK BUILD                      
echo ====================================================
echo.

set /p PROJECT_PATH="Enter project path or name [.]: "
if "%PROJECT_PATH%"=="" set PROJECT_PATH=.

cd /d "%PROJECT_PATH%"

echo [*] Installing dependencies...
call composer install --prefer-dist --no-interaction

echo [*] Installing NPM packages...
call npm install

echo [*] Building assets...
call npm run build

echo [*] Running migrations...
call php artisan migrate --force

echo [*] Optimizing...
call php artisan optimize

echo.
echo [SUCCESS] Quick build complete!
pause
goto MENU

:: ============================================================================

:: OPTION 4: LOCAL DEPLOY
:: ============================================================================

:LOCAL_DEPLOY
cls
echo ====================================================
echo                  LOCAL DEPLOYMENT                   
echo ====================================================
echo.

set /p PROJECT_PATH="Enter project path or name [.]: "
if "%PROJECT_PATH%"=="" set PROJECT_PATH=.

cd /d "%PROJECT_PATH%"

echo [*] Running composer install...
call composer install --prefer-dist --no-dev

echo [*] Running migrations...
call php artisan migrate --force --seed

echo [*] Clearing caches...
call php artisan optimize:clear

echo [*] Building assets...
call npm run build

echo [*] Caching configurations...
call php artisan config:cache
call php artisan route:cache
call php artisan view:cache

echo.
echo [SUCCESS] Local deployment complete!
echo [*] Starting development server...
echo.
call php artisan serve
goto MENU

:: ============================================================================

:: OPTION 5: SERVER DEPLOY
:: ============================================================================

:SERVER_DEPLOY
cls
echo ====================================================
echo                  SERVER DEPLOYMENT                  
echo ====================================================
echo.

:: Server configuration
set /p SERVER_USER="Server username [root]: "
if "%SERVER_USER%"=="" set SERVER_USER=root

set /p SERVER_IP="Server IP address: "

set /p SERVER_PATH="Remote path [/var/www/html]: "
if "%SERVER_PATH%"=="" set SERVER_PATH=/var/www/html

set /p GIT_BRANCH="Git branch [main]: "
if "%GIT_BRANCH%"=="" set GIT_BRANCH=main

echo.
echo [*] Committing changes to Git...
git add .
set /p COMMIT_MSG="Commit message [Auto-deploy]: "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Auto-deploy
git commit -m "%COMMIT_MSG%"

echo [*] Pushing to remote...
git push origin %GIT_BRANCH%

echo [*] Connecting to server and deploying...
ssh %SERVER_USER%@%SERVER_IP% "cd %SERVER_PATH% && git pull origin %GIT_BRANCH% && composer install --no-dev --optimize-autoloader && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache && npm install && npm run build"

echo.
echo [SUCCESS] Server deployment complete!
echo Your app should be live at http://%SERVER_IP%
pause
goto MENU

:: ============================================================================

:: OPTION 6: CONFIGURE OPTIONS
:: ============================================================================

:CONFIGURE_OPTIONS
cls
echo ====================================================
echo                  CONFIGURE OPTIONS                  
echo ====================================================
echo.

echo Current Settings:
echo.
echo   [1]  Install Template:     !INSTALL_TEMPLATE!
echo   [2]  Install Plugins:      !INSTALL_PLUGINS!
echo   [3]  Install Debugger:     !INSTALL_DEBUGGER!
echo   [4]  Install DevTools:     !INSTALL_DEVTOOLS!
echo   [5]  Build Assets:         !BUILD_ASSETS!
echo   [6]  Run Migrations:       !RUN_MIGRATIONS!
echo.
echo   [0]  Back to Main Menu
echo.

set /p OPTION_CHOICE="Select option to toggle: "

if "%OPTION_CHOICE%"=="1" (
    if "%INSTALL_TEMPLATE%"=="yes" (set "INSTALL_TEMPLATE=no") else (set "INSTALL_TEMPLATE=yes")
    goto CONFIGURE_OPTIONS
)
if "%OPTION_CHOICE%"=="2" (
    if "%INSTALL_PLUGINS%"=="yes" (set "INSTALL_PLUGINS=no") else (set "INSTALL_PLUGINS=yes")
    goto CONFIGURE_OPTIONS
)
if "%OPTION_CHOICE%"=="3" (
    if "%INSTALL_DEBUGGER%"=="yes" (set "INSTALL_DEBUGGER=no") else (set "INSTALL_DEBUGGER=yes")
    goto CONFIGURE_OPTIONS
)
if "%OPTION_CHOICE%"=="4" (
    if "%INSTALL_DEVTOOLS%"=="yes" (set "INSTALL_DEVTOOLS=no") else (set "INSTALL_DEVTOOLS=yes")
    goto CONFIGURE_OPTIONS
)
if "%OPTION_CHOICE%"=="5" (
    if "%BUILD_ASSETS%"=="yes" (set "BUILD_ASSETS=no") else (set "BUILD_ASSETS=yes")
    goto CONFIGURE_OPTIONS
)
if "%OPTION_CHOICE%"=="6" (
    if "%RUN_MIGRATIONS%"=="yes" (set "RUN_MIGRATIONS=no") else (set "RUN_MIGRATIONS=yes")
    goto CONFIGURE_OPTIONS
)
if "%OPTION_CHOICE%"=="0" goto MENU

goto CONFIGURE_OPTIONS

:: ============================================================================

:: OPTION 7: SYSTEM CHECK
:: ============================================================================

:SYSTEM_CHECK
cls
echo ====================================================
echo                  SYSTEM CHECK                       
echo ====================================================
echo.

call :CHECK_PREREQUISITES

echo.
echo [*] Checking PHP extensions...
php -m | findstr /i "pdo json mbstring xml gd curl" >nul
if %ERRORLEVEL% equ 0 (
    echo [OK] Required PHP extensions found
) else (
    echo [WARNING] Some extensions may be missing
)

echo.
echo [*] Checking Node.js version...
node --version
echo [*] Checking NPM version...
npm --version
echo [*] Checking Composer version...
composer --version 2>nul || echo [ERROR] Composer not found

echo.
pause
goto MENU

:: ============================================================================

:: SUB-ROUTINES
:: ============================================================================

:CHECK_PREREQUISITES
echo [*] Checking system prerequisites...
echo.

set "ALL_OK=1"

where php >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] PHP is not installed or not in PATH
    set "ALL_OK=0"
) else (
    echo [OK] PHP
)

where composer >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Composer is not installed or not in PATH
    set "ALL_OK=0"
) else (
    echo [OK] Composer
)

where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not installed or not in PATH
    set "ALL_OK=0"
) else (
    echo [OK] Git
)

where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Node.js not found (for frontend build)
) else (
    echo [OK] Node.js
)

where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [WARNING] NPM not found (for frontend build)
) else (
    echo [OK] NPM
)

if "%ALL_OK%"=="0" exit /b 1
exit /b 0

:CONFIGURE_DATABASE
set "DB_CHOICE=%~1"

if "%DB_CHOICE%"=="1" (
    echo     - Setting up SQLite...
    if not exist "database\database.sqlite" (
        copy /y NUL "database\database.sqlite" >nul
    )
    powershell -Command "(Get-Content .env) -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=sqlite' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=%CD%\database\database.sqlite' | Set-Content .env"
    echo /database/database.sqlite >> .gitignore
    echo [OK] SQLite configured
)
if "%DB_CHOICE%"=="2" (
    echo     - Configuring MySQL...
    set /p DB_NAME="    Database name [laravel]: "
    if "!DB_NAME!"=="" set DB_NAME=laravel
    set /p DB_USER="    Database user [root]: "
    if "!DB_USER!"=="" set DB_USER=root
    set /p DB_PASS="    Database password []: "
    powershell -Command "(Get-Content .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=!DB_NAME!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_USERNAME=root', 'DB_USERNAME=!DB_USER!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_PASSWORD=', 'DB_PASSWORD=!DB_PASS!' | Set-Content .env"
    echo [OK] MySQL configured
)
if "%DB_CHOICE%"=="3" (
    echo     - Configuring PostgreSQL...
    set /p DB_NAME="    Database name [laravel]: "
    if "!DB_NAME!"=="" set DB_NAME=laravel
    set /p DB_USER="    Database user [postgres]: "
    if "!DB_USER!"=="" set DB_USER=postgres
    set /p DB_PASS="    Database password []: "
    powershell -Command "(Get-Content .env) -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=pgsql' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=!DB_NAME!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_USERNAME=root', 'DB_USERNAME=!DB_USER!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_PASSWORD=', 'DB_PASSWORD=!DB_PASS!' | Set-Content .env"
    echo [OK] PostgreSQL configured
)

git add .env .gitignore
git commit -m "config: database setup" 2>nul
exit /b 0

:INSTALL_TEMPLATE
set "TEMPLATE_CHOICE=%~1"

if "%TEMPLATE_CHOICE%"=="1" (
    echo     - Skipping template (Standard Blade)
)
if "%TEMPLATE_CHOICE%"=="2" (
    echo     - Installing Breeze (Blade + Alpine)...
    call composer require laravel/breeze --dev --quiet
    call php artisan breeze:install blade --quiet
)
if "%TEMPLATE_CHOICE%"=="3" (
    echo     - Installing Breeze (Vue + SSR)...
    call composer require laravel/breeze --dev --quiet
    call php artisan breeze:install vue --ssr --quiet
)
if "%TEMPLATE_CHOICE%"=="4" (
    echo     - Installing Breeze (React + SSR)...
    call composer require laravel/breeze --dev --quiet
    call php artisan breeze:install react --ssr --quiet
)
if "%TEMPLATE_CHOICE%"=="5" (
    echo     - Installing Jetstream (Inertia)...
    call composer require laravel/jetstream --dev
    call php artisan jetstream:install inertia
)
if "%TEMPLATE_CHOICE%"=="6" (
    echo     - Installing API (Sanctum)...
    call php artisan install:api
)
if "%TEMPLATE_CHOICE%"=="7" (
    echo     - Skipping authentication template
    exit /b 0
)

if not "%TEMPLATE_CHOICE%"=="1" if not "%TEMPLATE_CHOICE%"=="7" (
    git add .
    git commit -m "feat: install authentication template" 2>nul
)
echo [OK] Template installed
exit /b 0

:INSTALL_PLUGINS
echo     - Installing Spatie packages...
call composer require spatie/laravel-permission spatie/laravel-activitylog --quiet 2>nul

echo     - Publishing Spatie configs...
call php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force 2>nul
call php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations" --force 2>nul

echo     - Installing additional packages...
call composer require laravel/socialite intervention/image --quiet 2>nul

git add .
git commit -m "feat: install plugins (permission, activitylog, uuid)" 2>nul

echo [OK] Plugins installed
exit /b 0

:INSTALL_DEBUGGER
echo     - Installing Telescope...
call composer require laravel/telescope --dev --quiet 2>nul
call php artisan telescope:install --force 2>nul

echo     - Installing Debugbar...
call composer require barryvdh/laravel-debugbar --dev --quiet 2>nul

echo     - Installing Clockwork...
call composer require itsgoingd/clockwork --dev --quiet 2>nul

git add .
git commit -m "chore: install debugger tools (telescope, debugbar, clockwork)" 2>nul

echo [OK] Debugger tools installed
exit /b 0

:INSTALL_DEVTOOLS
echo     - Installing IDE Helper...
call composer require barryvdh/laravel-ide-helper beyondcode/laravel-query-detector --dev --quiet 2>nul

echo     - Generating IDE helpers...
call php artisan ide-helper:generate 2>nul
call php artisan ide-helper:meta 2>nul
call php artisan vendor:publish --provider="BeyondCode\QueryDetector\QueryDetectorServiceProvider" --force 2>nul

echo     - Installing Laravel Sail (optional)...
call composer require laravel/sail --dev --quiet 2>nul

echo     - Installing Horizon (queue dashboard)...
call composer require laravel/horizon --dev --quiet 2>nul
call php artisan vendor:publish --provider="Laravel\Horizon\HorizonServiceProvider" --force 2>nul

echo     - Installing Sanctum...
call composer require laravel/sanctum --quiet 2>nul
call php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force 2>nul

git add .
git commit -m "chore: install development tools" 2>nul

echo [OK] DevTools installed
exit /b 0

:BUILD_FRONTEND
echo     - Installing NPM dependencies...
call npm install
if %ERRORLEVEL% neq 0 (
    echo [ERROR] NPM install failed
    exit /b 1
)

echo     - Building frontend assets...
call npm run build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] NPM build failed
    exit /b 1
)

git add .
git commit -m "build: compile frontend assets" 2>nul

echo [OK] Frontend built
exit /b 0

:: ============================================================================

:: EXIT
:: ============================================================================

:EXIT
cls
echo.
echo Thank you for using Laravel Build & Deploy Script!
echo.
exit /b 0