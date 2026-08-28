# =========================================================================
# Name:     Laravel Master Setup Script (Ultimate Edition)
# Purpose:  All-in-one Laravel installer, builder, and deployment tool.
# Author:   Assistant
# =========================================================================

$Global:ProjectName = "laravel-app"
$Global:InstallPlugins = $true
$Global:InstallDebugger = $true
$Global:InstallDevTools = $true
$Global:BuildAssets = $true
$Global:RunMigrations = $true

function Show-Header {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "      LARAVEL MASTER SETUP - ULTIMATE EDITION        " -ForegroundColor Cyan -Object
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host " [1]  New Project Setup     - Create fresh Laravel with Best Practices"
    Write-Host " [2]  Existing Project      - Build & optimize existing project"
    Write-Host " [3]  Quick Build           - Install dependencies & build assets"
    Write-Host " [4]  Local Deploy          - Deploy to local environment"
    Write-Host " [5]  Server Deploy         - Deploy to remote server (Git/SSH)"
    Write-Host " [6]  System Check          - Verify prerequisites"
    Write-Host " [7]  Configure Options     - Customize installation settings"
    Write-Host " [0]  Exit"
    Write-Host ""
    Write-Host "Current Settings:"
    Write-Host " Plugins: $Global:InstallPlugins | Debugger: $Global:InstallDebugger | DevTools: $Global:InstallDevTools"
    Write-Host " Assets: $Global:BuildAssets | Migrate: $Global:RunMigrations"
    Write-Host ""
    $choice = Read-Host "Select option [0-7]"
    return $choice
}

function Check-Prerequisites {
    Write-Host "[*] Checking system prerequisites..." -ForegroundColor Yellow
    $missing = $false
    
    foreach ($tool in @("php", "composer", "git")) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "[ERROR] $tool is missing from PATH." -ForegroundColor Red
            $missing = $true
        } else {
            Write-Host "[OK] $tool is present." -ForegroundColor Green
        }
    }
    
    if ($missing) { return $false }
    return $true
}

function New-Project {
    Show-Header
    if (-not (Check-Prerequisites)) {
        Read-Host "Prerequisites failed. Press Enter to return to menu."
        return
    }

    $name = Read-Host "Enter project name [laravel-app]"
    if ([string]::IsNullOrWhiteSpace($name)) { $name = "laravel-app" }
    $Global:ProjectName = $name

    if (Test-Path $name) {
        Write-Host "[ERROR] Directory '$name' already exists." -ForegroundColor Red
        Read-Host "Press Enter to try again."
        return
    }

    Write-Host "`nSelect Authentication / Stack:"
    Write-Host " [1] Standard Laravel (Blade)"
    Write-Host " [2] Laravel Breeze (Blade + Alpine)"
    Write-Host " [3] Laravel Breeze (Vue + SSR)"
    Write-Host " [4] Laravel Breeze (React + SSR)"
    Write-Host " [5] Laravel Jetstream (Inertia + Vue)"
    Write-Host " [6] API Only (Sanctum)"
    $stack = Read-Host "Enter choice [2]"
    if ([string]::IsNullOrWhiteSpace($stack)) { $stack = "2" }

    Write-Host "`nSelect Database:"
    Write-Host " [1] SQLite (Best for dev)"
    Write-Host " [2] MySQL"
    Write-Host " [3] PostgreSQL"
    $db = Read-Host "Enter choice [1]"
    if ([string]::IsNullOrWhiteSpace($db)) { $db = "1" }

    Write-Host "`n[*] Creating Laravel project: $name..." -ForegroundColor Cyan
    composer create-project --prefer-dist laravel/laravel $name
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to create project." -ForegroundColor Red
        Read-Host "Press Enter to return."
        return
    }

    Set-Location $name

    # Phase 1: Git Init
    Write-Host "`n[1/9] Initializing Git..." -ForegroundColor Yellow
    git init -b main
    git add .
    git commit -m "chore: initial laravel installation"

    # Phase 2: DB Config
    Write-Host "`n[2/9] Configuring database..." -ForegroundColor Yellow
    Configure-Database $db

    # Phase 3: Auth Template
    Write-Host "`n[3/9] Installing authentication template..." -ForegroundColor Yellow
    Install-Template $stack

    # Phase 4: Plugins
    if ($Global:InstallPlugins) {
        Write-Host "`n[4/9] Installing Spatie Packages..." -ForegroundColor Yellow
        Install-Plugins
    }

    # Phase 5: Debugger
    if ($Global:InstallDebugger) {
        Write-Host "`n[5/9] Installing Debugger Tools..." -ForegroundColor Yellow
        Install-Debugger
    }

    # Phase 6: DevTools
    if ($Global:InstallDevTools) {
        Write-Host "`n[6/9] Installing Developer Tools..." -ForegroundColor Yellow
        Install-DevTools
    }

    # Phase 7: Example Resource
    Write-Host "`n[7/9] Generating Example Resource..." -ForegroundColor Yellow
    php artisan resource-file:create Department --fields="id,name,image,is_active"
    php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration
    if ($Global:RunMigrations) { php artisan migrate --force }
    git add .
    git commit -m "feat: generate example department resource"

    # Phase 8: Frontend Build
    if ($Global:BuildAssets) {
        Write-Host "`n[8/9] Building frontend assets..." -ForegroundColor Yellow
        Build-Frontend
    }

    # Phase 9: Finalize
    Write-Host "`n[9/9] Finalizing setup..." -ForegroundColor Yellow
    php artisan key:generate
    php artisan storage:link
    git add .
    git commit -m "chore: finalize project setup"

    Show-Header
    Write-Host "INSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "Project: $name"
    Write-Host "Location: $(Get-Location)"
    Write-Host "`nQuick Commands:"
    Write-Host " cd $name"
    Write-Host " php artisan serve"
    Read-Host "`nPress Enter to return to menu."
    Set-Location ..
}

function Configure-Database($choice) {
    $envFile = ".env"
    $content = Get-Content $envFile
    
    if ($choice -eq "1") {
        New-Item "database/database.sqlite" -ItemType File -Force | Out-Null
        $content = $content -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=sqlite'
        $content = $content -replace 'DB_DATABASE=laravel', "DB_DATABASE=$((Get-Item .).FullName)/database/database.sqlite"
        $content | Set-Content $envFile
        Add-Content .gitignore "`n/database/database.sqlite"
    } elseif ($choice -eq "2") {
        $dbName = Read-Host "    DB Name [laravel]"
        if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = "laravel" }
        $content = $content -replace 'DB_DATABASE=laravel', "DB_DATABASE=$dbName"
        $content | Set-Content $envFile
    } elseif ($choice -eq "3") {
        $content = $content -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=pgsql'
        $content | Set-Content $envFile
    }
    
    git add .env .gitignore
    git commit -m "config: database setup"
}

function Install-Template($choice) {
    if ($choice -eq "1") { return }
    
    composer require laravel/breeze --dev --quiet
    switch ($choice) {
        "2" { php artisan breeze:install blade --quiet }
        "3" { php artisan breeze:install vue --ssr --quiet }
        "4" { php artisan breeze:install react --ssr --quiet }
        "5" { 
            composer require laravel/jetstream --quiet
            php artisan jetstream:install inertia --quiet 
        }
        "6" { php artisan install:api }
    }
    git add .
    git commit -m "feat: install authentication template"
}

function Install-Plugins {
    composer require spatie/laravel-permission spatie/laravel-activitylog --quiet
    php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force
    php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations" --force
    git add .
    git commit -m "feat: install spatie permissions & activity logs"
}

function Install-Debugger {
    composer require laravel/telescope barryvdh/laravel-debugbar --dev --quiet
    php artisan telescope:install --force
    git add .
    git commit -m "chore: install telescope & debugbar"
}

function Install-DevTools {
    composer require barryvdh/laravel-ide-helper beyondcode/laravel-query-detector crestapps/laravel-code-generator --dev --quiet
    php artisan ide-helper:generate
    php artisan ide-helper:meta
    php artisan vendor:publish --provider="BeyondCode\QueryDetector\QueryDetectorServiceProvider" --force
    git add .
    git commit -m "chore: install ide-helpers & code generator"
}

function Build-Frontend {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "[WARNING] NPM not found. Skipping build." -ForegroundColor Yellow
        return
    }
    npm install
    npm run build
    git add .
    git commit -m "build: compile assets"
}

# --- SCRIPT EXECUTION ---
do {
    $ans = Show-Menu
    switch ($ans) {
        "1" { New-Project }
        "2" { 
            $path = Read-Host "Project path [.]"
            if ([string]::IsNullOrWhiteSpace($path)) { $path = "." }
            Set-Location $path
            composer install; php artisan migrate --force; php artisan optimize:clear; Build-Frontend; php artisan optimize
            Read-Host "Done. Press Enter."
        }
        "3" { composer install; npm install; npm run build; php artisan migrate --force; Read-Host "Done. Press Enter." }
        "4" { composer install --no-dev; php artisan migrate --force; npm install; npm run build; php artisan serve }
        "6" { Check-Prerequisites; Read-Host "Press Enter." }
        "7" { 
            $Global:InstallPlugins = !$Global:InstallPlugins
            Write-Host "Toggled Plugins to $Global:InstallPlugins"
            Read-Host "Press Enter."
        }
        "0" { exit }
    }
} while ($true)
