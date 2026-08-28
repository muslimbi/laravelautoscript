@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: Name:     Laravel Master Setup Script (Ultimate Edition)
:: Purpose:  All-in-one Laravel installer, builder, and deployment tool.
::           Combines auto terminal automation, git setup best practices,
::           scaffolding, and complete build/deploy workflows.
:: Author:   Antigravity
:: =========================================================================

:: --- CONFIGURATION DEFAULTS ---
set "PROJECT_NAME=laravel-app"
set "INSTALL_TEMPLATE=yes"
set "INSTALL_PLUGINS=yes"
set "INSTALL_DEBUGGER=yes"
set "INSTALL_DEVTOOLS=yes"
set "BUILD_ASSETS=yes"
set "RUN_MIGRATIONS=yes"
set "GENERATE_EXAMPLE=yes"

:: --- FORMATTING PREFIXES ---
set "RED=[ERROR] "
set "GREEN=[OK] "
set "YELLOW=[*] "
set "BLUE=[INFO] "
set "CYAN=[CONFIG] "

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
echo  [1]  New Project Setup       - Create fresh Laravel with Best Practices
echo  [2]  Existing Project Build  - Build ^& optimize existing project
echo  [3]  Quick Build             - Install dependencies ^& build assets
echo  [4]  Local Deploy            - Deploy locally ^+ start artisan serve
echo  [5]  Server Deploy           - Deploy to remote server (Git/SSH)
echo  [6]  System Check            - Verify prerequisites ^& PHP extensions
echo  [7]  Toggle Options          - Customize installation settings
echo  [0]  Exit
echo.
echo Current Settings:
echo   Plugins: !INSTALL_PLUGINS!  ^|  Debugger: !INSTALL_DEBUGGER!  ^|  DevTools: !INSTALL_DEVTOOLS!
echo   Assets: !BUILD_ASSETS!   ^|  Migrate: !RUN_MIGRATIONS!    ^|  Example: !GENERATE_EXAMPLE!
echo.
set "choice="
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
set "PROJECT_NAME="
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
echo   [7]  None (Manual)
set "TEMPLATE_CHOICE="
set /p TEMPLATE_CHOICE="Enter choice [2]: "
if "%TEMPLATE_CHOICE%"=="" set TEMPLATE_CHOICE=2

echo.
echo Select Database:
echo   [1]  SQLite (Development - Zero Config)
echo   [2]  MySQL
echo   [3]  PostgreSQL
set "DB_CHOICE="
set /p DB_CHOICE="Enter choice [1]: "
if "%DB_CHOICE%"=="" set DB_CHOICE=1

echo.
echo %BLUE%[*] Creating Laravel project: %PROJECT_NAME%...
call composer create-project --prefer-dist laravel/laravel %PROJECT_NAME%
if %ERRORLEVEL% neq 0 (
    echo %RED%Failed to create Laravel project.
    pause
    goto MENU
)

cd %PROJECT_NAME%

:: PHASE 1: GIT INIT
echo.
echo [1/8] %YELLOW%Initializing Git repository...
call git init -b main
call git add .
call git commit -m "chore: initial laravel installation"

:: PHASE 2: DATABASE & GITIGNORE CONFIG
echo.
echo [2/8] %YELLOW%Configuring database and .gitignore...
call :CONFIGURE_DATABASE %DB_CHOICE%

:: PHASE 3: AUTH TEMPLATE
echo.
echo [3/8] %YELLOW%Installing authentication template...
call :INSTALL_TEMPLATE %TEMPLATE_CHOICE%

:: PHASE 4: PLUGINS & PACKAGES
if "%INSTALL_PLUGINS%"=="yes" (
    echo.
    echo [4/8] %YELLOW%Installing Spatie, Socialite ^& Intervention Image...
    call :INSTALL_PLUGINS
)

:: PHASE 5: DEBUGGER TOOLS
if "%INSTALL_DEBUGGER%"=="yes" (
    echo.
    echo [5/8] %YELLOW%Installing Telescope, Debugbar ^& Clockwork...
    call :INSTALL_DEBUGGER
)

:: PHASE 6: DEV TOOLS & SCAFFOLDING
if "%INSTALL_DEVTOOLS%"=="yes" (
    echo.
    echo [6/8] %YELLOW%Installing IDE Helpers, Sail, Horizon ^& Dev Tools...
    call :INSTALL_DEVTOOLS
)

:: PHASE 7: EXAMPLE RESOURCE SCAFFOLD
if "%GENERATE_EXAMPLE%"=="yes" (
    echo.
    echo [7/8] %YELLOW%Generating Example Department Resource...
    call :GENERATE_EXAMPLE_RESOURCE
)

:: PHASE 8: FRONTEND BUILD & FINALIZATION
echo.
echo [8/8] %YELLOW%Finalizing build and assets...
if "%RUN_MIGRATIONS%"=="yes" (
    echo %BLUE%[*] Running database migrations...
    call php artisan migrate --force
)
if "%BUILD_ASSETS%"=="yes" (
    echo %BLUE%[*] Compiling frontend assets...
    call :BUILD_FRONTEND
)
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
echo   - Git (Categorized History ^& Enhanced .gitignore)
if "%INSTALL_PLUGINS%"=="yes" echo   - Spatie (Permission, ActivityLog), Socialite, Intervention Image
if "%INSTALL_DEBUGGER%"=="yes" echo   - Debugger (Telescope, Debugbar, Clockwork)
if "%INSTALL_DEVTOOLS%"=="yes" echo   - DevTools (IDE Helper, Query Detector, CrestApps, Sail, Horizon, Sanctum)
if "%GENERATE_EXAMPLE%"=="yes" echo   - Example Scaffold (Department CRUD)
echo.
echo  Quick Commands:
echo   cd %PROJECT_NAME%
echo   php artisan serve
echo.
echo  URLs:
echo   - App:        http://127.0.0.1:8000
if "%INSTALL_DEBUGGER%"=="yes" (
    echo   - Telescope:  http://127.0.0.1:8000/telescope
    echo   - Debugbar:   http://127.0.0.1:8000/_debugbar
    echo   - Clockwork:  http://127.0.0.1:8000/__clockwork
)
echo.
pause
cd ..
goto MENU

:: ============================================================================
:: OPTION 2: EXISTING PROJECT BUILD
:: ============================================================================

:EXISTING_PROJECT
cls
echo ====================================================
echo           EXISTING PROJECT - BUILD ^& OPTIMIZE        
echo ====================================================
echo.
set "PROJECT_PATH="
set /p PROJECT_PATH="Enter project path or name [.]: "
if "%PROJECT_PATH%"=="" set PROJECT_PATH=.

if not exist "%PROJECT_PATH%\artisan" (
    echo %RED%No Laravel project found at '%PROJECT_PATH%'.
    pause
    goto MENU
)

cd /d "%PROJECT_PATH%"
echo %BLUE%[*] Working in: %CD%

if not exist "composer.json" (
    echo %RED%composer.json not found.
    pause
    goto MENU
)

echo %BLUE%[*] Installing composer dependencies...
call composer install --prefer-dist
if %ERRORLEVEL% neq 0 (
    echo %RED%Composer install failed.
    pause
    goto MENU
)

if "%RUN_MIGRATIONS%"=="yes" (
    echo %BLUE%[*] Running migrations...
    call php artisan migrate --force
)

echo %BLUE%[*] Clearing all caches...
call php artisan config:clear
call php artisan cache:clear
call php artisan route:clear
call php artisan view:clear
call php artisan optimize:clear

if "%BUILD_ASSETS%"=="yes" (
    echo %BLUE%[*] Building frontend assets...
    call :BUILD_FRONTEND
)

echo %BLUE%[*] Rebuilding production caches...
call php artisan config:cache
call php artisan route:cache
call php artisan view:cache
call php artisan optimize

echo.
echo %GREEN%Build ^& optimization complete!
echo.
set "DEPLOY_NOW="
set /p DEPLOY_NOW="Do you want to deploy to server now? [y/N]: "
if /i "%DEPLOY_NOW%"=="y" goto SERVER_DEPLOY

pause
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
set "PROJECT_PATH="
set /p PROJECT_PATH="Enter project path or name [.]: "
if "%PROJECT_PATH%"=="" set PROJECT_PATH=.

cd /d "%PROJECT_PATH%"

echo %BLUE%[*] Fast build: Composer + NPM + Migrate...
call composer install --prefer-dist --no-interaction
call npm install
call npm run build
if "%RUN_MIGRATIONS%"=="yes" call php artisan migrate --force
call php artisan optimize

echo.
echo %GREEN%Quick build complete!
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
set "PROJECT_PATH="
set /p PROJECT_PATH="Enter project path or name [.]: "
if "%PROJECT_PATH%"=="" set PROJECT_PATH=.

cd /d "%PROJECT_PATH%"

echo %BLUE%[*] Local deployment sequence...
call composer install --prefer-dist --no-dev --optimize-autoloader
call php artisan migrate --force --seed
call php artisan optimize:clear
call npm install
call npm run build
call php artisan config:cache
call php artisan route:cache
call php artisan view:cache

echo.
echo %GREEN%Local deployment complete! Starting development server...
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
set "SERVER_USER="
set /p SERVER_USER="Server username [root]: "
if "%SERVER_USER%"=="" set SERVER_USER=root

set "SERVER_IP="
set /p SERVER_IP="Server IP address: "
if "%SERVER_IP%"=="" (
    echo %RED%Server IP is required.
    pause
    goto MENU
)

set "SERVER_PATH="
set /p SERVER_PATH="Remote path [/var/www/html]: "
if "%SERVER_PATH%"=="" set SERVER_PATH=/var/www/html

set "GIT_BRANCH="
set /p GIT_BRANCH="Git branch [main]: "
if "%GIT_BRANCH%"=="" set GIT_BRANCH=main

echo.
echo %BLUE%[*] Committing local changes...
call git add .
set "COMMIT_MSG="
set /p COMMIT_MSG="Commit message [Auto-deploy]: "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Auto-deploy
call git commit -m "%COMMIT_MSG%" 2>nul

echo %BLUE%[*] Pushing to remote branch: %GIT_BRANCH%...
call git push origin %GIT_BRANCH%

echo %BLUE%[*] Executing remote SSH deployment...
ssh %SERVER_USER%@%SERVER_IP% "cd %SERVER_PATH% && git pull origin %GIT_BRANCH% && composer install --no-dev --optimize-autoloader && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache && npm install && npm run build"

echo.
echo %GREEN%Server deployment complete!
echo %GREEN%Your application should be live at: http://%SERVER_IP%
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
echo %BLUE%[*] Checking PHP Extensions...
php -m | findstr /i "pdo json mbstring xml gd curl" >nul
if %ERRORLEVEL% equ 0 (
    echo %GREEN%Required PHP extensions found (pdo, json, mbstring, xml, gd, curl).
) else (
    echo %RED%Some required PHP extensions may be missing!
)

echo.
echo %BLUE%[*] Checking Tool Versions:
php -v | findstr /i "PHP"
composer --version 2>nul || echo %RED%Composer: Not found
git --version 2>nul || echo %RED%Git: Not found
node -v 2>nul || echo %RED%Node.js: Not found
npm -v 2>nul || echo %RED%NPM: Not found

echo.
pause
goto MENU

:: ============================================================================
:: OPTION 7: CONFIGURE OPTIONS
:: ============================================================================

:CONFIGURE_OPTIONS
cls
echo ====================================================
echo                  CONFIGURE OPTIONS                  
echo ====================================================
echo.
echo Current Settings:
echo  [1] Plugins (Spatie, Socialite, Image): !INSTALL_PLUGINS!
echo  [2] Debugger (Telescope, Debugbar, Clockwork): !INSTALL_DEBUGGER!
echo  [3] DevTools (IDE Helper, Query Detector, Sail, Horizon, Sanctum): !INSTALL_DEVTOOLS!
echo  [4] Assets (NPM Build): !BUILD_ASSETS!
echo  [5] Migrate (DB Migrations): !RUN_MIGRATIONS!
echo  [6] Example Scaffold (Department CRUD): !GENERATE_EXAMPLE!
echo  [0] Back to Main Menu
echo.
set "opt="
set /p opt="Toggle option [0-6]: "

if "%opt%"=="1" (if "!INSTALL_PLUGINS!"=="yes" (set "INSTALL_PLUGINS=no") else (set "INSTALL_PLUGINS=yes"))
if "%opt%"=="2" (if "!INSTALL_DEBUGGER!"=="yes" (set "INSTALL_DEBUGGER=no") else (set "INSTALL_DEBUGGER=yes"))
if "%opt%"=="3" (if "!INSTALL_DEVTOOLS!"=="yes" (set "INSTALL_DEVTOOLS=no") else (set "INSTALL_DEVTOOLS=yes"))
if "%opt%"=="4" (if "!BUILD_ASSETS!"=="yes" (set "BUILD_ASSETS=no") else (set "BUILD_ASSETS=yes"))
if "%opt%"=="5" (if "!RUN_MIGRATIONS!"=="yes" (set "RUN_MIGRATIONS=no") else (set "RUN_MIGRATIONS=yes"))
if "%opt%"=="6" (if "!GENERATE_EXAMPLE!"=="yes" (set "GENERATE_EXAMPLE=no") else (set "GENERATE_EXAMPLE=yes"))
if "%opt%"=="0" goto MENU

goto CONFIGURE_OPTIONS

:: ============================================================================
:: SUB-ROUTINES
:: ============================================================================

:CHECK_PREREQUISITES
echo %BLUE%[*] Checking system prerequisites...
set "MISSING=0"

where php >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo %RED%PHP is not installed or not in PATH.
    set "MISSING=1"
) else (
    echo %GREEN%PHP is installed.
)

where composer >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo %RED%Composer is not installed or not in PATH.
    set "MISSING=1"
) else (
    echo %GREEN%Composer is installed.
)

where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo %RED%Git is not installed or not in PATH.
    set "MISSING=1"
) else (
    echo %GREEN%Git is installed.
)

where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo %RED%Node.js is not installed or not in PATH.
) else (
    echo %GREEN%Node.js is installed.
)

where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo %RED%NPM is not installed or not in PATH.
) else (
    echo %GREEN%NPM is installed.
)

if "%MISSING%"=="1" exit /b 1
exit /b 0

:CONFIGURE_DATABASE
set "DB_CHOICE=%~1"
set "DB_NAME_DISP=SQLite"

if "%DB_CHOICE%"=="1" (
    echo     - Setting up SQLite database...
    if not exist "database\database.sqlite" (
        copy /y NUL "database\database.sqlite" >nul
    )
    powershell -Command "(Get-Content .env) -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=sqlite' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_DATABASE=.*', ('DB_DATABASE=' + (Resolve-Path 'database/database.sqlite').Path) | Set-Content .env"
    echo /database/database.sqlite >> .gitignore
    echo %GREEN%SQLite configured.
) else if "%DB_CHOICE%"=="2" (
    set "DB_NAME_DISP=MySQL"
    echo     - Configuring MySQL...
    set "DB_NAME="
    set /p DB_NAME="    DB Name [laravel]: "
    if "!DB_NAME!"=="" set DB_NAME=laravel
    set "DB_USER="
    set /p DB_USER="    DB User [root]: "
    if "!DB_USER!"=="" set DB_USER=root
    set "DB_PASS="
    set /p DB_PASS="    DB Password []: "
    powershell -Command "(Get-Content .env) -replace 'DB_DATABASE=.*', 'DB_DATABASE=!DB_NAME!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_USERNAME=.*', 'DB_USERNAME=!DB_USER!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_PASSWORD=.*', 'DB_PASSWORD=!DB_PASS!' | Set-Content .env"
    echo %GREEN%MySQL configured.
) else (
    set "DB_NAME_DISP=PostgreSQL"
    echo     - Configuring PostgreSQL...
    set "DB_NAME="
    set /p DB_NAME="    DB Name [laravel]: "
    if "!DB_NAME!"=="" set DB_NAME=laravel
    set "DB_USER="
    set /p DB_USER="    DB User [postgres]: "
    if "!DB_USER!"=="" set DB_USER=postgres
    set "DB_PASS="
    set /p DB_PASS="    DB Password []: "
    powershell -Command "(Get-Content .env) -replace 'DB_CONNECTION=.*', 'DB_CONNECTION=pgsql' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_DATABASE=.*', 'DB_DATABASE=!DB_NAME!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_USERNAME=.*', 'DB_USERNAME=!DB_USER!' | Set-Content .env"
    powershell -Command "(Get-Content .env) -replace 'DB_PASSWORD=.*', 'DB_PASSWORD=!DB_PASS!' | Set-Content .env"
    echo %GREEN%PostgreSQL configured.
)

:: Gitignore Enhancements (from auto terminal script)
echo. >> .gitignore
echo # IDE Helpers >> .gitignore
echo .phpstackbin >> .gitignore
echo _ide_helper.php >> .gitignore
echo _ide_helper_models.php >> .gitignore
echo .phpstorm.meta.php >> .gitignore

call git add .env .gitignore
call git commit -m "config: database and gitignore setup" 2>nul
exit /b 0

:INSTALL_TEMPLATE
set "T=%~1"
if "%T%"=="1" (
    echo     - Skipping auth template (Standard Blade)
    exit /b 0
)
if "%T%"=="7" (
    echo     - Skipping auth template
    exit /b 0
)

echo     - Installing authentication template...
call composer require laravel/breeze --dev --quiet 2>nul
if "%T%"=="2" call php artisan breeze:install blade --quiet 2>nul
if "%T%"=="3" call php artisan breeze:install vue --ssr --quiet 2>nul
if "%T%"=="4" call php artisan breeze:install react --ssr --quiet 2>nul
if "%T%"=="5" (
    call composer require laravel/jetstream --quiet 2>nul
    call php artisan jetstream:install inertia --quiet 2>nul
)
if "%T%"=="6" call php artisan install:api 2>nul

call git add .
call git commit -m "feat: install authentication template" 2>nul
echo %GREEN%Authentication template installed.
exit /b 0

:INSTALL_PLUGINS
echo     - Installing Spatie Permission, ActivityLog, Socialite ^& Intervention Image...
call composer require spatie/laravel-permission spatie/laravel-activitylog laravel/socialite intervention/image --quiet 2>nul
call php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force 2>nul
call php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations" --force 2>nul
call git add .
call git commit -m "feat: install plugins (permission, activitylog, socialite, intervention image)" 2>nul
echo %GREEN%Plugins installed.
exit /b 0

:INSTALL_DEBUGGER
echo     - Installing Telescope, Debugbar ^& Clockwork...
call composer require laravel/telescope barryvdh/laravel-debugbar itsgoingd/clockwork --dev --quiet 2>nul
call php artisan telescope:install --force 2>nul
call git add .
call git commit -m "chore: install debugger tools (telescope, debugbar, clockwork)" 2>nul
echo %GREEN%Debugger tools installed.
exit /b 0

:INSTALL_DEVTOOLS
echo     - Installing IDE Helper, Query Detector, Code Generator, Sail, Horizon ^& Sanctum...
call composer require barryvdh/laravel-ide-helper beyondcode/laravel-query-detector crestapps/laravel-code-generator laravel/sail laravel/horizon laravel/sanctum --dev --quiet 2>nul
call php artisan ide-helper:generate 2>nul
call php artisan ide-helper:meta 2>nul
call php artisan vendor:publish --provider="BeyondCode\QueryDetector\QueryDetectorServiceProvider" --force 2>nul
call php artisan vendor:publish --provider="Laravel\Horizon\HorizonServiceProvider" --force 2>nul
call php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force 2>nul
call git add .
call git commit -m "chore: install development tools (ide-helper, query-detector, crestapps, sail, horizon, sanctum)" 2>nul
echo %GREEN%DevTools installed.
exit /b 0

:GENERATE_EXAMPLE_RESOURCE
echo     - Generating Example Resource (Department)...
call php artisan resource-file:create Department --fields="id,name,image,is_active" 2>nul
call php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration 2>nul
call git add .
call git commit -m "feat: generate example department resource" 2>nul
echo %GREEN%Example resource scaffolded.
exit /b 0

:BUILD_FRONTEND
where npm >nul 2>nul || (echo %RED%NPM missing, skipping asset build. && exit /b 1)
call npm install 2>nul
call npm run build 2>nul
call git add .
call git commit -m "build: compile assets" 2>nul
echo %GREEN%Frontend assets compiled.
exit /b 0

:EXIT
echo.
echo Thank you for using Laravel Master Setup!
echo.
pause
exit /b 0
