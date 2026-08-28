@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: Name:     Laravel Master Setup Script (Ultimate Edition)
:: Purpose:  All-in-one Laravel installer, builder, and deployment tool.
::           Combines terminal automation, git best practices, and 
::           comprehensive build/deploy workflows.
:: Author:   Assistant
:: =========================================================================

:: --- COLORS ---
:: Note: Batch doesn't support ANSI easily on all Windows versions without 
:: registry tweaks, so we use standard formatting but keep structure clean.
set "RESET="
set "BOLD="
set "RED=[ERROR] "
set "GREEN=[OK] "
set "YELLOW=[*] "
set "BLUE=[INFO] "
set "CYAN="

:: --- CONFIGURATION DEFAULTS ---
set "PROJECT_NAME=laravel-app"
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
echo      LARAVEL MASTER SETUP - ULTIMATE EDITION        
echo ====================================================
echo.
echo  [1]  New Project Setup     - Create fresh Laravel with Best Practices
echo  [2]  Existing Project      - Build ^& optimize existing project
echo  [3]  Quick Build           - Install dependencies ^& build assets
echo  [4]  Local Deploy          - Deploy to local environment
echo  [5]  Server Deploy         - Deploy to remote server (Git/SSH)
echo  [6]  System Check          - Verify prerequisites
echo  [7]  Configure Options     - Customize installation settings
echo  [0]  Exit
echo.
echo Current Settings:
echo   Plugins: !INSTALL_PLUGINS!  ^|  Debugger: !INSTALL_DEBUGGER!  ^|  DevTools: !INSTALL_DEVTOOLS!
echo   Assets: !BUILD_ASSETS!   ^|  Migrate: !RUN_MIGRATIONS!
echo.
set /p choice="Select option [0-7]: "

if "%choice%"=="1" goto NEW_PROJECT
if "%choice%"=="2" goto EXISTING_PROJECT
if "%choice%"=="3" goto QUICK_BUILD
if "%choice%"=="4" goto LOCAL_DEPLOY
if "%choice%"=="5" goto SERVER_DEPLOY
if "%choice%"=="6" goto SYSTEM_CHECK
if "%choice%"=="7" goto CONFIGURE_OPTIONS
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

call :CHECK_PREREQUISITES
if %ERRORLEVEL% neq 0 (
    echo %RED%Prerequisites check failed. Please install missing tools.
    pause
    goto MENU
)

:ASK_PROJECT_NAME
set /p PROJECT_NAME="Enter project name [laravel-app]: "
if "%PROJECT_NAME%"=="" set PROJECT_NAME=laravel-app

if exist "%PROJECT_NAME%" (
    echo %RED%Directory '%PROJECT_NAME%' already exists.
    goto ASK_PROJECT_NAME
)

echo.
echo Select Authentication / Stack:
echo   [1]  Standard Laravel (Blade)
echo   [2]  Laravel Breeze (Blade + Alpine)
echo   [3]  Laravel Breeze (Vue + SSR)
echo   [4]  Laravel Breeze (React + SSR)
echo   [5]  Laravel Jetstream (Inertia + Vue)
echo   [6]  API Only (Sanctum)
set /p TEMPLATE_CHOICE="Enter choice [2]: "
if "%TEMPLATE_CHOICE%"=="" set TEMPLATE_CHOICE=2

echo.
echo Select Database:
echo   [1]  SQLite (Best for dev)
echo   [2]  MySQL
echo   [3]  PostgreSQL
set /p DB_CHOICE="Enter choice [1]: "
if "%DB_CHOICE%"=="" set DB_CHOICE=1

echo.
echo %CYAN%[*] Creating Laravel project: %PROJECT_NAME%...%RESET%
call composer create-project --prefer-dist laravel/laravel %PROJECT_NAME%
if %ERRORLEVEL% neq 0 (
    echo %RED%Failed to create Laravel project.
    pause
    goto MENU
)

cd %PROJECT_NAME%

:: PHASE 1: GIT INIT
echo.
echo [1/9] %YELLOW%Initializing Git repository...%RESET%
call git init -b main
call git add .
call git commit -m "chore: initial laravel installation"

:: PHASE 2: DATABASE CONFIG
echo.
echo [2/9] %YELLOW%Configuring database...%RESET%
call :CONFIGURE_DATABASE %DB_CHOICE%

:: PHASE 3: AUTH TEMPLATE
echo.
echo [3/9] %YELLOW%Installing authentication template...%RESET%
call :INSTALL_TEMPLATE %TEMPLATE_CHOICE%

:: PHASE 4: PLUGINS
if "%INSTALL_PLUGINS%"=="yes" (
    echo.
    echo [4/9] %YELLOW%Installing Spatie Permission ^& ActivityLog...%RESET%
    call :INSTALL_PLUGINS
)

:: PHASE 5: DEBUGGER
if "%INSTALL_DEBUGGER%"=="yes" (
    echo.
    echo [5/9] %YELLOW%Installing Telescope ^& Debugbar...%RESET%
    call :INSTALL_DEBUGGER
)

:: PHASE 6: DEV TOOLS
if "%INSTALL_DEVTOOLS%"=="yes" (
    echo.
    echo [6/9] %YELLOW%Installing IDE Helpers ^& Code Generator...%RESET%
    call :INSTALL_DEVTOOLS
)

:: PHASE 7: EXAMPLE RESOURCE
echo.
echo [7/9] %YELLOW%Generating Example Department Resource...%RESET%
call php artisan resource-file:create Department --fields="id,name,image,is_active" 2>nul
call php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration 2>nul
if "%RUN_MIGRATIONS%"=="yes" (
    call php artisan migrate --force
)
call git add .
call git commit -m "feat: generate example department resource" 2>nul

:: PHASE 8: FRONTEND BUILD
if "%BUILD_ASSETS%"=="yes" (
    echo.
    echo [8/9] %YELLOW%Building frontend assets...%RESET%
    call :BUILD_FRONTEND
)

:: PHASE 9: FINAL OPTIMIZATION
echo.
echo [9/9] %YELLOW%Finalizing setup...%RESET%
call php artisan key:generate
call php artisan storage:link
call git add .
call git commit -m "chore: finalize project setup" 2>nul

cls
echo ====================================================
echo           PROJECT SETUP COMPLETE!                   
echo ====================================================
echo.
echo  Project:   %PROJECT_NAME%
echo  Location:  %CD%
echo  Database:  %DB_NAME_DISP%
echo.
echo  Installed Components:
echo   - Git (Categorized History)
if "%INSTALL_PLUGINS%"=="yes" echo   - Spatie (Permission, ActivityLog)
if "%INSTALL_DEBUGGER%"=="yes" echo   - Debugger (Telescope, Debugbar)
if "%INSTALL_DEVTOOLS%"=="yes" echo   - DevTools (IDE Helper, CrestApps Generator)
echo.
echo  Quick Commands:
echo   cd %PROJECT_NAME%
echo   php artisan serve
echo.
echo  URLs:
echo   - App:        http://127.0.0.1:8000
if "%INSTALL_DEBUGGER%"=="yes" echo   - Telescope:  http://127.0.0.1:8000/telescope
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
echo           EXISTING PROJECT - BUILD ^& OPTIMIZE        
echo ====================================================
echo.
set /p PROJECT_PATH="Enter project path or name [.]: "
if "%PROJECT_PATH%"=="" set PROJECT_PATH=.
cd /d "%PROJECT_PATH%"

if not exist "artisan" (
    echo %RED%No Laravel project found at '%CD%'.
    pause
    goto MENU
)

echo [*] Installing composer dependencies...
call composer install --prefer-dist
echo [*] Running migrations...
call php artisan migrate --force
echo [*] Clearing ^& rebuilding caches...
call php artisan optimize:clear
if "%BUILD_ASSETS%"=="yes" call :BUILD_FRONTEND
call php artisan optimize

echo.
echo %GREEN%Build complete!
pause
goto MENU

:: ============================================================================
:: OPTION 3: QUICK BUILD
:: ============================================================================

:QUICK_BUILD
cls
echo [*] Fast build: Composer + NPM + Migrate...
call composer install --no-interaction
call npm install
call npm run build
call php artisan migrate --force
call php artisan optimize
echo %GREEN%Quick build complete!
pause
goto MENU

:: ============================================================================
:: OPTION 4: LOCAL DEPLOY
:: ============================================================================

:LOCAL_DEPLOY
cls
echo [*] Local deployment sequence...
call composer install --no-dev --optimize-autoloader
call php artisan migrate --force --seed
call php artisan optimize:clear
call npm install
call npm run build
call php artisan config:cache
call php artisan route:cache
call php artisan view:cache
echo %GREEN%Local deploy successful. Starting server...
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
set /p SERVER_USER="Server username [root]: "
if "%SERVER_USER%"=="" set SERVER_USER=root
set /p SERVER_IP="Server IP: "
if "%SERVER_IP%"=="" (echo %RED%IP required. && pause && goto MENU)
set /p SERVER_PATH="Remote path [/var/www/html]: "
if "%SERVER_PATH%"=="" set SERVER_PATH=/var/www/html

echo [*] Pushing changes to main...
git add .
git commit -m "deploy: update before server sync" 2>nul
git push origin main

echo [*] Executing remote deployment via SSH...
ssh %SERVER_USER%@%SERVER_IP% "cd %SERVER_PATH% && git pull origin main && composer install --no-dev --optimize-autoloader && php artisan migrate --force && php artisan optimize && npm install && npm run build"

echo %GREEN%Server deployment complete!
pause
goto MENU

:: ============================================================================
:: OPTION 6: SYSTEM CHECK
:: ============================================================================

:SYSTEM_CHECK
cls
echo ====================================================
echo                  SYSTEM CHECK                       
echo ====================================================
echo.
call :CHECK_PREREQUISITES
echo.
echo [*] Versions:
php -v | findstr "PHP"
composer --version
node -v 2>nul || echo Node: Not found
npm -v 2>nul || echo NPM: Not found
git --version
echo.
pause
goto MENU

:: ============================================================================
:: OPTION 7: CONFIGURE OPTIONS
:: ============================================================================

:CONFIGURE_OPTIONS
cls
echo Current Settings:
echo  [1] Plugins:  !INSTALL_PLUGINS!
echo  [2] Debugger: !INSTALL_DEBUGGER!
echo  [3] DevTools: !INSTALL_DEVTOOLS!
echo  [4] Assets:   !BUILD_ASSETS!
echo  [5] Migrate:  !RUN_MIGRATIONS!
echo  [0] Back
set /p opt="Toggle option: "
if "%opt%"=="1" (if "!INSTALL_PLUGINS!"=="yes" (set INSTALL_PLUGINS=no) else (set INSTALL_PLUGINS=yes))
if "%opt%"=="2" (if "!INSTALL_DEBUGGER!"=="yes" (set INSTALL_DEBUGGER=no) else (set INSTALL_DEBUGGER=yes))
if "%opt%"=="3" (if "!INSTALL_DEVTOOLS!"=="yes" (set INSTALL_DEVTOOLS=no) else (set INSTALL_DEVTOOLS=yes))
if "%opt%"=="4" (if "!BUILD_ASSETS!"=="yes" (set BUILD_ASSETS=no) else (set BUILD_ASSETS=yes))
if "%opt%"=="5" (if "!RUN_MIGRATIONS!"=="yes" (set RUN_MIGRATIONS=no) else (set RUN_MIGRATIONS=yes))
if "%opt%"=="0" goto MENU
goto CONFIGURE_OPTIONS

:: ============================================================================
:: SUB-ROUTINES
:: ============================================================================

:CHECK_PREREQUISITES
set "MISSING=0"
where php >nul 2>nul || (echo %RED%PHP missing && set MISSING=1)
where composer >nul 2>nul || (echo %RED%Composer missing && set MISSING=1)
where git >nul 2>nul || (echo %RED%Git missing && set MISSING=1)
if %MISSING% equ 1 exit /b 1
echo %GREEN%PHP, Composer, and Git are present.
exit /b 0

:CONFIGURE_DATABASE
set "DB_CHOICE=%~1"
set "DB_NAME_DISP=SQLite"
if "%DB_CHOICE%"=="1" (
    copy /y NUL database\database.sqlite >nul
    powershell -Command "(gc .env) -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=sqlite' | Out-File -encoding ASCII .env"
    powershell -Command "(gc .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=%cd%\database\database.sqlite' | Out-File -encoding ASCII .env"
    echo /database/database.sqlite >> .gitignore
) else if "%DB_CHOICE%"=="2" (
    set "DB_NAME_DISP=MySQL"
    set /p DB_NAME="    DB Name [laravel]: "
    if "!DB_NAME!"=="" set DB_NAME=laravel
    powershell -Command "(gc .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=!DB_NAME!' | Out-File -encoding ASCII .env"
) else (
    set "DB_NAME_DISP=PostgreSQL"
    powershell -Command "(gc .env) -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=pgsql' | Out-File -encoding ASCII .env"
)
call git add .env .gitignore
call git commit -m "config: database setup" 2>nul
exit /b 0

:INSTALL_TEMPLATE
set "T=%~1"
if "%T%"=="1" exit /b 0
call composer require laravel/breeze --dev --quiet
if "%T%"=="2" call php artisan breeze:install blade --quiet
if "%T%"=="3" call php artisan breeze:install vue --ssr --quiet
if "%T%"=="4" call php artisan breeze:install react --ssr --quiet
if "%T%"=="5" (
    call composer require laravel/jetstream --quiet
    call php artisan jetstream:install inertia --quiet
)
if "%T%"=="6" call php artisan install:api
call git add .
call git commit -m "feat: install authentication template" 2>nul
exit /b 0

:INSTALL_PLUGINS
call composer require spatie/laravel-permission spatie/laravel-activitylog --quiet
call php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force
call php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations" --force
call git add .
call git commit -m "feat: install spatie permissions ^& activity logs" 2>nul
exit /b 0

:INSTALL_DEBUGGER
call composer require laravel/telescope barryvdh/laravel-debugbar --dev --quiet
call php artisan telescope:install --force
call git add .
call git commit -m "chore: install telescope ^& debugbar" 2>nul
exit /b 0

:INSTALL_DEVTOOLS
call composer require barryvdh/laravel-ide-helper beyondcode/laravel-query-detector crestapps/laravel-code-generator --dev --quiet
call php artisan ide-helper:generate
call php artisan ide-helper:meta
call php artisan vendor:publish --provider="BeyondCode\QueryDetector\QueryDetectorServiceProvider" --force
call git add .
call git commit -m "chore: install ide-helpers ^& code generator" 2>nul
exit /b 0

:BUILD_FRONTEND
where npm >nul 2>nul || (echo %RED%NPM missing, skipping build. && exit /b 1)
call npm install
call npm run build
call git add .
call git commit -m "build: compile assets" 2>nul
exit /b 0

:EXIT
echo.
echo Thank you for using Laravel Master Setup!
echo.
pause
exit /b 0
