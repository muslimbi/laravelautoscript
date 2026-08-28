@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: Name:     laravel-git-auto-setup
:: Purpose:  Setup Laravel environment with Git versioning & best practices
:: =========================================================================

echo -------------------------------------------------------
echo  LARAVEL + GIT AUTOMATED SETUP
echo -------------------------------------------------------

:: 1. Setup Project Name
set /p projectname="Enter project name [my-app]: "
if "%projectname%"=="" set projectname=my-app

:: 2. Create Laravel Project
echo [*] Creating Laravel project...
call composer create-project --prefer-dist laravel/laravel %projectname%
cd %projectname%

:: 3. Initialize Git
echo [*] Initializing Git Repository...
git init -b main
git add .
git commit -m "chore: initial laravel install"

:: 4. Database Setup (SQLite)
echo [*] Configuring Environment...
:: Create sqlite file if not exists
if not exist "database\database.sqlite" (
    copy /y NUL "database\database.sqlite" >nul
)

:: Update .env using PowerShell (more reliable than batch for strings)
powershell -Command "(gc .env) -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=sqlite' | Out-File -encoding ASCII .env"
powershell -Command "(gc .env) -replace 'DB_DATABASE=laravel', 'DB_DATABASE=%cd%\database\database.sqlite' | Out-File -encoding ASCII .env"

:: Ensure SQLite is ignored by Git to prevent data leaks
echo /database/database.sqlite >> .gitignore
git add .gitignore .env.example
git commit -m "config: switch to sqlite and update gitignore"

:: 5. Install Authentication (Breeze)
:: Note: Removed laravel/ui as Breeze is the modern standard for Git-based workflows
echo [*] Installing Laravel Breeze (Vue + SSR)...
call composer require laravel/breeze --dev
php artisan breeze:install vue --ssr --quiet
git add .
git commit -m "feat: install breeze auth (vue/ssr)"

:: 6. Install Developer Tools
echo [*] Installing Dev Tools (Debugbar, IDE Helper, Query Detector)...
call composer require barryvdh/laravel-debugbar barryvdh/laravel-ide-helper beyondcode/laravel-query-detector --dev
php artisan ide-helper:generate
php artisan ide-helper:meta
git add .
git commit -m "chore: install developer tools (debugbar, ide-helper)"

:: 7. Install Spatie Packages & Activity Log
echo [*] Installing Spatie Permission ^& ActivityLog...
call composer require spatie/laravel-permission spatie/laravel-activitylog
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations"
php artisan migrate
git add .
git commit -m "feat: install permission and activity log support"

:: 8. Code Generation (CrestApps)
echo [*] Installing CrestApps Code Generator...
call composer require crestapps/laravel-code-generator --dev
git add .
git commit -m "chore: install crestapps code generator"

:: Example Resource Generation
echo [*] Generating Sample Resources...
php artisan resource-file:create Department --fields="id,name,image,is_active"
php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration
php artisan migrate

git add .
git commit -m "feat: generate department crud"

:: 9. Frontend Build
echo [*] Compiling Assets (NPM)...
call npm install
call npm run build
git add .
git commit -m "build: compile initial frontend assets"

echo.
echo ======================================================
echo  SETUP COMPLETE!
echo ======================================================
echo  1. Your git history is clean and categorized.
echo  2. SQLite is configured and git-ignored.
echo  3. Run 'php artisan serve' to start.
echo ======================================================
pause