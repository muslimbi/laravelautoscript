# =========================================================================
# Name:     Laravel Master Setup Script (Ultimate Edition)
# Purpose:  All-in-one Laravel installer, builder, and deployment tool.
#           Combines auto terminal automation, git setup best practices,
#           scaffolding, and complete build/deploy workflows.
# Author:   Antigravity
# =========================================================================

$Global:ProjectName = "laravel-app"
$Global:InstallPlugins = $true
$Global:InstallDebugger = $true
$Global:InstallDevTools = $true
$Global:BuildAssets = $true
$Global:RunMigrations = $true
$Global:GenerateExample = $true

function Show-Header {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "      LARAVEL MASTER SETUP - ULTIMATE EDITION        " -ForegroundColor Cyan
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host " [1]  New Project Setup       - Create fresh Laravel with Best Practices"
    Write-Host " [2]  Existing Project Build  - Build & optimize existing project"
    Write-Host " [3]  Quick Build             - Install dependencies & build assets"
    Write-Host " [4]  Local Deploy            - Deploy locally + start artisan serve"
    Write-Host " [5]  Server Deploy           - Deploy to remote server (Git/SSH)"
    Write-Host " [6]  System Check            - Verify prerequisites & PHP extensions"
    Write-Host " [7]  Toggle Options          - Customize installation settings"
    Write-Host " [0]  Exit"
    Write-Host ""
    Write-Host "Current Settings:"
    Write-Host " Plugins: $Global:InstallPlugins | Debugger: $Global:InstallDebugger | DevTools: $Global:InstallDevTools"
    Write-Host " Assets: $Global:BuildAssets | Migrate: $Global:RunMigrations | Example: $Global:GenerateExample"
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

    foreach ($tool in @("node", "npm")) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "[WARNING] $tool is not in PATH (needed for asset compilation)." -ForegroundColor Yellow
        } else {
            Write-Host "[OK] $tool is present." -ForegroundColor Green
        }
    }

    if ($missing) { return $false }
    return $true
}

function Configure-Database($choice) {
    $envFile = ".env"
    if (-not (Test-Path $envFile)) { return }
    $content = Get-Content $envFile
    $dbDisp = "SQLite"

    if ($choice -eq "1") {
        New-Item "database/database.sqlite" -ItemType File -Force | Out-Null
        $sqlitePath = (Resolve-Path "database/database.sqlite").Path
        $content = $content -replace 'DB_CONNECTION=mysql', 'DB_CONNECTION=sqlite'
        $content = $content -replace 'DB_DATABASE=.*', "DB_DATABASE=$sqlitePath"
        $content | Set-Content $envFile
        Add-Content .gitignore "`n/database/database.sqlite"
        Write-Host "[OK] SQLite database configured." -ForegroundColor Green
    } elseif ($choice -eq "2") {
        $dbDisp = "MySQL"
        $dbName = Read-Host "    DB Name [laravel]"
        if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = "laravel" }
        $dbUser = Read-Host "    DB User [root]"
        if ([string]::IsNullOrWhiteSpace($dbUser)) { $dbUser = "root" }
        $dbPass = Read-Host "    DB Password []"
        
        $content = $content -replace 'DB_DATABASE=.*', "DB_DATABASE=$dbName"
        $content = $content -replace 'DB_USERNAME=.*', "DB_USERNAME=$dbUser"
        $content = $content -replace 'DB_PASSWORD=.*', "DB_PASSWORD=$dbPass"
        $content | Set-Content $envFile
        Write-Host "[OK] MySQL database configured." -ForegroundColor Green
    } elseif ($choice -eq "3") {
        $dbDisp = "PostgreSQL"
        $dbName = Read-Host "    DB Name [laravel]"
        if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = "laravel" }
        $dbUser = Read-Host "    DB User [postgres]"
        if ([string]::IsNullOrWhiteSpace($dbUser)) { $dbUser = "postgres" }
        $dbPass = Read-Host "    DB Password []"
        
        $content = $content -replace 'DB_CONNECTION=.*', 'DB_CONNECTION=pgsql'
        $content = $content -replace 'DB_DATABASE=.*', "DB_DATABASE=$dbName"
        $content = $content -replace 'DB_USERNAME=.*', "DB_USERNAME=$dbUser"
        $content = $content -replace 'DB_PASSWORD=.*', "DB_PASSWORD=$dbPass"
        $content | Set-Content $envFile
        Write-Host "[OK] PostgreSQL database configured." -ForegroundColor Green
    }

    # Enhanced gitignore
    Add-Content .gitignore "`n# IDE Helpers`n.phpstackbin`n_ide_helper.php`n_ide_helper_models.php`n.phpstorm.meta.php"
    
    git add .env .gitignore 2>$null
    git commit -m "config: database and gitignore setup" 2>$null | Out-Null
    return $dbDisp
}

function Install-Template($choice) {
    if ($choice -eq "1" -or $choice -eq "7") { return }

    Write-Host "[*] Installing Breeze / Jetstream / API..." -ForegroundColor Yellow
    composer require laravel/breeze --dev --quiet 2>$null
    switch ($choice) {
        "2" { php artisan breeze:install blade --quiet 2>$null }
        "3" { php artisan breeze:install vue --ssr --quiet 2>$null }
        "4" { php artisan breeze:install react --ssr --quiet 2>$null }
        "5" { 
            composer require laravel/jetstream --quiet 2>$null
            php artisan jetstream:install inertia --quiet 2>$null
        }
        "6" { php artisan install:api 2>$null }
    }
    git add . 2>$null
    git commit -m "feat: install authentication template" 2>$null | Out-Null
    Write-Host "[OK] Authentication template installed." -ForegroundColor Green
}

function Install-Plugins {
    Write-Host "[*] Installing Spatie Packages, Socialite & Intervention Image..." -ForegroundColor Yellow
    composer require spatie/laravel-permission spatie/laravel-activitylog laravel/socialite intervention/image --quiet 2>$null
    php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force 2>$null
    php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations" --force 2>$null
    git add . 2>$null
    git commit -m "feat: install plugins (permission, activitylog, socialite, intervention image)" 2>$null | Out-Null
    Write-Host "[OK] Plugins installed." -ForegroundColor Green
}

function Install-Debugger {
    Write-Host "[*] Installing Telescope, Debugbar & Clockwork..." -ForegroundColor Yellow
    composer require laravel/telescope barryvdh/laravel-debugbar itsgoingd/clockwork --dev --quiet 2>$null
    php artisan telescope:install --force 2>$null
    git add . 2>$null
    git commit -m "chore: install debugger tools (telescope, debugbar, clockwork)" 2>$null | Out-Null
    Write-Host "[OK] Debugger tools installed." -ForegroundColor Green
}

function Install-DevTools {
    Write-Host "[*] Installing IDE Helpers, Sail, Horizon & Sanctum..." -ForegroundColor Yellow
    composer require barryvdh/laravel-ide-helper beyondcode/laravel-query-detector crestapps/laravel-code-generator laravel/sail laravel/horizon laravel/sanctum --dev --quiet 2>$null
    php artisan ide-helper:generate 2>$null
    php artisan ide-helper:meta 2>$null
    php artisan vendor:publish --provider="BeyondCode\QueryDetector\QueryDetectorServiceProvider" --force 2>$null
    php artisan vendor:publish --provider="Laravel\Horizon\HorizonServiceProvider" --force 2>$null
    php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force 2>$null
    git add . 2>$null
    git commit -m "chore: install development tools (ide-helper, query-detector, crestapps, sail, horizon, sanctum)" 2>$null | Out-Null
    Write-Host "[OK] DevTools installed." -ForegroundColor Green
}

function Generate-ExampleResource {
    Write-Host "[*] Generating Example Resource (Department CRUD)..." -ForegroundColor Yellow
    php artisan resource-file:create Department --fields="id,name,image,is_active" 2>$null
    php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration 2>$null
    git add . 2>$null
    git commit -m "feat: generate example department resource" 2>$null | Out-Null
    Write-Host "[OK] Example resource scaffolded." -ForegroundColor Green
}

function Build-Frontend {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "[WARNING] NPM not found. Skipping frontend build." -ForegroundColor Yellow
        return
    }
    Write-Host "[*] Compiling frontend assets..." -ForegroundColor Yellow
    npm install 2>$null
    npm run build 2>$null
    git add . 2>$null
    git commit -m "build: compile assets" 2>$null | Out-Null
    Write-Host "[OK] Assets compiled." -ForegroundColor Green
}

function New-Project {
    Show-Header
    if (-not (Check-Prerequisites)) {
        Read-Host "Prerequisites check failed. Press Enter to return to menu."
        return
    }

    $name = Read-Host "Enter project name [laravel-app]"
    if ([string]::IsNullOrWhiteSpace($name)) { $name = "laravel-app" }
    $Global:ProjectName = $name

    if (Test-Path $name) {
        Write-Host "[ERROR] Directory '$name' already exists." -ForegroundColor Red
        Read-Host "Press Enter to return."
        return
    }

    Write-Host "`nSelect Authentication / Stack:"
    Write-Host " [1] Standard Laravel (Blade)"
    Write-Host " [2] Laravel Breeze (Blade + Alpine)"
    Write-Host " [3] Laravel Breeze (Vue + SSR)"
    Write-Host " [4] Laravel Breeze (React + SSR)"
    Write-Host " [5] Laravel Jetstream (Inertia + Vue)"
    Write-Host " [6] API Only (Sanctum)"
    Write-Host " [7] None (Manual)"
    $stack = Read-Host "Enter choice [2]"
    if ([string]::IsNullOrWhiteSpace($stack)) { $stack = "2" }

    Write-Host "`nSelect Database:"
    Write-Host " [1] SQLite (Development - Zero Config)"
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
    Write-Host "`n[1/8] Initializing Git repository..." -ForegroundColor Yellow
    git init -b main 2>$null
    git add . 2>$null
    git commit -m "chore: initial laravel installation" 2>$null | Out-Null

    # Phase 2: Database & Gitignore
    Write-Host "`n[2/8] Configuring database and gitignore..." -ForegroundColor Yellow
    $dbNameDisp = Configure-Database $db

    # Phase 3: Auth Template
    Write-Host "`n[3/8] Installing authentication template..." -ForegroundColor Yellow
    Install-Template $stack

    # Phase 4: Plugins
    if ($Global:InstallPlugins) {
        Write-Host "`n[4/8] Installing Plugins & Production Packages..." -ForegroundColor Yellow
        Install-Plugins
    }

    # Phase 5: Debugger
    if ($Global:InstallDebugger) {
        Write-Host "`n[5/8] Installing Debugger Tools..." -ForegroundColor Yellow
        Install-Debugger
    }

    # Phase 6: DevTools
    if ($Global:InstallDevTools) {
        Write-Host "`n[6/8] Installing Developer Tools..." -ForegroundColor Yellow
        Install-DevTools
    }

    # Phase 7: Example Resource
    if ($Global:GenerateExample) {
        Write-Host "`n[7/8] Generating Example Resource Scaffold..." -ForegroundColor Yellow
        Generate-ExampleResource
    }

    # Phase 8: Finalization & Assets
    Write-Host "`n[8/8] Finalizing project setup..." -ForegroundColor Yellow
    if ($Global:RunMigrations) {
        Write-Host "[*] Running migrations..." -ForegroundColor Yellow
        php artisan migrate --force
    }
    if ($Global:BuildAssets) {
        Build-Frontend
    }
    php artisan key:generate 2>$null
    php artisan storage:link 2>$null
    git add . 2>$null
    git commit -m "chore: finalize project setup" 2>$null | Out-Null

    Show-Header
    Write-Host "PROJECT SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "Project:   $name"
    Write-Host "Location:  $((Get-Location).Path)"
    Write-Host "Database:  $dbNameDisp"
    Write-Host "`nInstalled Components:"
    Write-Host " - Git (Categorized History & Enhanced .gitignore)"
    if ($Global:InstallPlugins)  { Write-Host " - Plugins: Spatie (Permission, ActivityLog), Socialite, Intervention Image" }
    if ($Global:InstallDebugger) { Write-Host " - Debugger: Telescope, Debugbar, Clockwork" }
    if ($Global:InstallDevTools) { Write-Host " - DevTools: IDE Helper, Query Detector, CrestApps, Sail, Horizon, Sanctum" }
    if ($Global:GenerateExample) { Write-Host " - Example Resource: Department CRUD" }
    
    Write-Host "`nQuick Commands:"
    Write-Host " cd $name"
    Write-Host " php artisan serve"
    Write-Host "`nUseful URLs:"
    Write-Host " - App:        http://127.0.0.1:8000"
    if ($Global:InstallDebugger) {
        Write-Host " - Telescope:  http://127.0.0.1:8000/telescope"
        Write-Host " - Debugbar:   http://127.0.0.1:8000/_debugbar"
        Write-Host " - Clockwork:  http://127.0.0.1:8000/__clockwork"
    }

    Read-Host "`nPress Enter to return to menu."
    Set-Location ..
}

function Existing-Project {
    Show-Header
    Write-Host "EXISTING PROJECT - BUILD & OPTIMIZE" -ForegroundColor Cyan
    Write-Host ""
    $path = Read-Host "Enter project path or name [.]"
    if ([string]::IsNullOrWhiteSpace($path)) { $path = "." }

    if (-not (Test-Path "$path/artisan")) {
        Write-Host "[ERROR] No Laravel project found at '$path'." -ForegroundColor Red
        Read-Host "Press Enter to return to menu."
        return
    }

    Set-Location $path
    Write-Host "[*] Working in: $((Get-Location).Path)" -ForegroundColor Yellow

    Write-Host "[*] Installing Composer dependencies..." -ForegroundColor Yellow
    composer install --prefer-dist
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Composer install failed." -ForegroundColor Red
        Read-Host "Press Enter to return."
        return
    }

    if ($Global:RunMigrations) {
        Write-Host "[*] Running migrations..." -ForegroundColor Yellow
        php artisan migrate --force
    }

    Write-Host "[*] Clearing all caches..." -ForegroundColor Yellow
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
    php artisan optimize:clear

    if ($Global:BuildAssets) {
        Build-Frontend
    }

    Write-Host "[*] Rebuilding production caches..." -ForegroundColor Yellow
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan optimize

    Write-Host "`n[SUCCESS] Build & optimization complete!" -ForegroundColor Green
    $deploy = Read-Host "Do you want to deploy to server now? [y/N]"
    if ($deploy -eq "y" -or $deploy -eq "Y") {
        Server-Deploy
    } else {
        Read-Host "Press Enter to return to menu."
    }
}

function Quick-Build {
    Show-Header
    Write-Host "QUICK BUILD" -ForegroundColor Cyan
    Write-Host ""
    $path = Read-Host "Enter project path or name [.]"
    if ([string]::IsNullOrWhiteSpace($path)) { $path = "." }
    Set-Location $path

    Write-Host "[*] Installing dependencies & compiling assets..." -ForegroundColor Yellow
    composer install --prefer-dist --no-interaction
    npm install
    npm run build
    if ($Global:RunMigrations) { php artisan migrate --force }
    php artisan optimize

    Write-Host "`n[SUCCESS] Quick build complete!" -ForegroundColor Green
    Read-Host "Press Enter to return."
}

function Local-Deploy {
    Show-Header
    Write-Host "LOCAL DEPLOYMENT" -ForegroundColor Cyan
    Write-Host ""
    $path = Read-Host "Enter project path or name [.]"
    if ([string]::IsNullOrWhiteSpace($path)) { $path = "." }
    Set-Location $path

    Write-Host "[*] Local deployment sequence..." -ForegroundColor Yellow
    composer install --prefer-dist --no-dev --optimize-autoloader
    php artisan migrate --force --seed
    php artisan optimize:clear
    npm install
    npm run build
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache

    Write-Host "`n[SUCCESS] Local deployment complete! Starting server..." -ForegroundColor Green
    php artisan serve
}

function Server-Deploy {
    Show-Header
    Write-Host "SERVER DEPLOYMENT" -ForegroundColor Cyan
    Write-Host ""

    $serverUser = Read-Host "Server username [root]"
    if ([string]::IsNullOrWhiteSpace($serverUser)) { $serverUser = "root" }

    $serverIp = Read-Host "Server IP address"
    if ([string]::IsNullOrWhiteSpace($serverIp)) {
        Write-Host "[ERROR] Server IP is required." -ForegroundColor Red
        Read-Host "Press Enter to return."
        return
    }

    $serverPath = Read-Host "Remote path [/var/www/html]"
    if ([string]::IsNullOrWhiteSpace($serverPath)) { $serverPath = "/var/www/html" }

    $gitBranch = Read-Host "Git branch [main]"
    if ([string]::IsNullOrWhiteSpace($gitBranch)) { $gitBranch = "main" }

    Write-Host "`n[*] Committing local changes..." -ForegroundColor Yellow
    git add .
    $msg = Read-Host "Commit message [Auto-deploy]"
    if ([string]::IsNullOrWhiteSpace($msg)) { $msg = "Auto-deploy" }
    git commit -m "$msg" 2>$null

    Write-Host "[*] Pushing to remote branch: $gitBranch..." -ForegroundColor Yellow
    git push origin $gitBranch

    Write-Host "[*] Executing remote SSH deployment..." -ForegroundColor Yellow
    ssh "$serverUser@$serverIp" "cd $serverPath && git pull origin $gitBranch && composer install --no-dev --optimize-autoloader && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache && npm install && npm run build"

    Write-Host "`n[SUCCESS] Server deployment complete!" -ForegroundColor Green
    Write-Host "Application live at: http://$serverIp" -ForegroundColor Green
    Read-Host "Press Enter to return to menu."
}

function System-Check {
    Show-Header
    Write-Host "SYSTEM CHECK" -ForegroundColor Cyan
    Write-Host ""
    Check-Prerequisites | Out-Null

    Write-Host "`n[*] Checking PHP Extensions..." -ForegroundColor Yellow
    $extensions = php -m
    $required = @("pdo", "json", "mbstring", "xml", "gd", "curl")
    $missingExt = @()
    foreach ($ext in $required) {
        if ($extensions -notmatch "(?i)$ext") {
            $missingExt += $ext
        }
    }
    if ($missingExt.Count -eq 0) {
        Write-Host "[OK] Required PHP extensions present ($($required -join ', '))." -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Missing extensions: $($missingExt -join ', ')" -ForegroundColor Red
    }

    Write-Host "`n[*] Tool Versions:" -ForegroundColor Yellow
    php -v | Select-Object -First 1
    composer --version 2>$null
    git --version 2>$null
    if (Get-Command node -ErrorAction SilentlyContinue) { node -v } else { Write-Host "Node.js: Not found" }
    if (Get-Command npm -ErrorAction SilentlyContinue) { npm -v } else { Write-Host "NPM: Not found" }

    Write-Host ""
    Read-Host "Press Enter to return to menu."
}

function Configure-Options {
    do {
        Show-Header
        Write-Host "CONFIGURE OPTIONS" -ForegroundColor Cyan
        Write-Host ""
        Write-Host " [1]  Plugins (Spatie, Socialite, Image):  $Global:InstallPlugins"
        Write-Host " [2]  Debugger (Telescope, Debugbar, Clockwork): $Global:InstallDebugger"
        Write-Host " [3]  DevTools (IDE Helper, Sail, Horizon, Sanctum): $Global:InstallDevTools"
        Write-Host " [4]  Assets (NPM Build):             $Global:BuildAssets"
        Write-Host " [5]  Migrate (DB Migrations):         $Global:RunMigrations"
        Write-Host " [6]  Example Scaffold (Department):  $Global:GenerateExample"
        Write-Host " [0]  Back to Main Menu"
        Write-Host ""
        $opt = Read-Host "Select option to toggle [0-6]"
        switch ($opt) {
            "1" { $Global:InstallPlugins = !$Global:InstallPlugins }
            "2" { $Global:InstallDebugger = !$Global:InstallDebugger }
            "3" { $Global:InstallDevTools = !$Global:InstallDevTools }
            "4" { $Global:BuildAssets = !$Global:BuildAssets }
            "5" { $Global:RunMigrations = !$Global:RunMigrations }
            "6" { $Global:GenerateExample = !$Global:GenerateExample }
            "0" { return }
        }
    } while ($true)
}

# --- PRIMARY LOOP ---
do {
    $ans = Show-Menu
    switch ($ans) {
        "1" { New-Project }
        "2" { Existing-Project }
        "3" { Quick-Build }
        "4" { Local-Deploy }
        "5" { Server-Deploy }
        "6" { System-Check }
        "7" { Configure-Options }
        "0" { exit }
    }
} while ($true)
