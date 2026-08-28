#!/bin/bash

# =========================================================================
# Name:     Laravel Master Setup Script (Linux/macOS Edition)
# Purpose:  All-in-one Laravel installer, builder, and deployment tool.
#           Combines auto terminal automation, git setup best practices,
#           scaffolding, and complete build/deploy workflows.
# Author:   Antigravity
# =========================================================================

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- CONFIGURATION DEFAULTS ---
INSTALL_TEMPLATE="yes"
INSTALL_PLUGINS="yes"
INSTALL_DEBUGGER="yes"
INSTALL_DEVTOOLS="yes"
BUILD_ASSETS="yes"
RUN_MIGRATIONS="yes"
GENERATE_EXAMPLE="yes"

# --- HELPER FUNCTIONS ---

info() { echo -e "${CYAN}[*] $1${NC}"; }
success() { echo -e "${GREEN}[OK] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

check_prerequisites() {
    info "Checking system prerequisites..."
    local ok=0
    
    for cmd in php composer git; do
        if ! command -v "$cmd" &> /dev/null; then
            error "$cmd is not installed."
            ok=1
        else
            success "$cmd is present."
        fi
    done

    for cmd in node npm; do
        if ! command -v "$cmd" &> /dev/null; then
            warn "$cmd is not installed (needed for asset build)."
        else
            success "$cmd is present."
        fi
    done
    
    return $ok
}

configure_database() {
    local db_choice=$1
    local db_disp="SQLite"

    case $db_choice in
        1)
            info "Setting up SQLite..."
            touch database/database.sqlite
            sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
            # shellcheck disable=SC2046
            sed -i "s|^DB_DATABASE=.*|DB_DATABASE=\"$(pwd)/database/database.sqlite\"|" .env
            echo "/database/database.sqlite" >> .gitignore
            success "SQLite database configured."
            ;;
        2)
            db_disp="MySQL"
            info "Configuring MySQL..."
            read -rp "    Database name [laravel]: " db_name
            db_name=${db_name:-laravel}
            read -rp "    Database user [root]: " db_user
            db_user=${db_user:-root}
            read -rp "    Database password []: " db_pass
            
            sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$db_name/" .env
            sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$db_user/" .env
            sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$db_pass/" .env
            success "MySQL database configured."
            ;;
        3)
            db_disp="PostgreSQL"
            info "Configuring PostgreSQL..."
            read -rp "    Database name [laravel]: " db_name
            db_name=${db_name:-laravel}
            read -rp "    Database user [postgres]: " db_user
            db_user=${db_user:-postgres}
            read -rp "    Database password []: " db_pass
            
            sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=pgsql/' .env
            sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$db_name/" .env
            sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$db_user/" .env
            sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$db_pass/" .env
            success "PostgreSQL database configured."
            ;;
    esac

    # Enhanced gitignore
    echo -e "\n# IDE Helpers\n.phpstackbin\n_ide_helper.php\n_ide_helper_models.php\n.phpstorm.meta.php" >> .gitignore

    git add .env .gitignore
    git commit -m "config: database and gitignore setup" --quiet
    echo "$db_disp"
}

install_template() {
    local choice=$1
    case $choice in
        1|7) info "Skipping authentication template." ; return 0 ;;
        2)
            info "Installing Breeze (Blade + Alpine)..."
            composer require laravel/breeze --dev --quiet
            php artisan breeze:install blade --quiet
            ;;
        3)
            info "Installing Breeze (Vue + SSR)..."
            composer require laravel/breeze --dev --quiet
            php artisan breeze:install vue --ssr --quiet
            ;;
        4)
            info "Installing Breeze (React + SSR)..."
            composer require laravel/breeze --dev --quiet
            php artisan breeze:install react --ssr --quiet
            ;;
        5)
            info "Installing Jetstream (Inertia + Vue)..."
            composer require laravel/jetstream --dev --quiet
            php artisan jetstream:install inertia --quiet
            ;;
        6)
            info "Installing API (Sanctum)..."
            php artisan install:api
            ;;
    esac
    
    git add .
    git commit -m "feat: install authentication template" --quiet
    success "Authentication template installed."
}

install_plugins() {
    info "Installing Spatie (Permission, ActivityLog), Socialite & Intervention Image..."
    composer require spatie/laravel-permission spatie/laravel-activitylog laravel/socialite intervention/image --quiet
    php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force
    php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations" --force
    git add .
    git commit -m "feat: install plugins (permission, activitylog, socialite, intervention image)" --quiet
    success "Plugins installed."
}

install_debugger() {
    info "Installing Telescope, Debugbar & Clockwork..."
    composer require laravel/telescope barryvdh/laravel-debugbar itsgoingd/clockwork --dev --quiet
    php artisan telescope:install --force
    git add .
    git commit -m "chore: install debugger tools (telescope, debugbar, clockwork)" --quiet
    success "Debugger tools installed."
}

install_devtools() {
    info "Installing IDE Helper, Query Detector, CrestApps, Sail, Horizon & Sanctum..."
    composer require barryvdh/laravel-ide-helper beyondcode/laravel-query-detector crestapps/laravel-code-generator laravel/sail laravel/horizon laravel/sanctum --dev --quiet
    php artisan ide-helper:generate --quiet
    php artisan ide-helper:meta --quiet
    php artisan vendor:publish --provider="BeyondCode\QueryDetector\QueryDetectorServiceProvider" --force
    php artisan vendor:publish --provider="Laravel\Horizon\HorizonServiceProvider" --force
    php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force
    git add .
    git commit -m "chore: install development tools (ide-helper, query-detector, crestapps, sail, horizon, sanctum)" --quiet
    success "DevTools installed."
}

generate_example_resource() {
    info "Generating Example Resource (Department CRUD)..."
    php artisan resource-file:create Department --fields="id,name,image,is_active" &> /dev/null
    php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration &> /dev/null
    git add .
    git commit -m "feat: generate example department resource" --quiet
    success "Example resource scaffolded."
}

build_frontend() {
    if ! command -v npm &> /dev/null; then
        warn "NPM not found. Skipping frontend build."
        return 1
    fi
    info "Building frontend assets..."
    npm install --quiet
    npm run build --quiet
    git add .
    git commit -m "build: compile assets" --quiet
    success "Frontend assets compiled."
}

# --- MAIN WORKFLOWS ---

new_project() {
    clear
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo -e "${BOLD}${BLUE}           NEW LARAVEL PROJECT SETUP                 ${NC}"
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo
    
    if ! check_prerequisites; then
        error "Prerequisites check failed."
        read -rp "Press enter to return to menu..."
        return
    fi
    
    read -rp "Enter project name [laravel-app]: " project_name
    project_name=${project_name:-laravel-app}
    
    if [ -d "$project_name" ]; then
        error "Directory '$project_name' already exists."
        read -rp "Press enter to return to menu..."
        return
    fi
    
    echo -e "\nSelect Authentication Template:"
    echo "  [1] Standard Laravel (Blade)"
    echo "  [2] Laravel Breeze (Blade + Alpine)"
    echo "  [3] Laravel Breeze (Vue + SSR)"
    echo "  [4] Laravel Breeze (React + SSR)"
    echo "  [5] Laravel Jetstream (Inertia + Vue)"
    echo "  [6] API Only (Sanctum)"
    echo "  [7] None (Manual)"
    read -rp "Enter choice [2]: " template_choice
    template_choice=${template_choice:-2}
    
    echo -e "\nSelect Database:"
    echo "  [1] SQLite (Development - Zero Config)"
    echo "  [2] MySQL"
    echo "  [3] PostgreSQL"
    read -rp "Enter choice [1]: " db_choice
    db_choice=${db_choice:-1}
    
    info "Creating Laravel project: $project_name"
    composer create-project --prefer-dist laravel/laravel "$project_name"
    
    cd "$project_name" || return
    
    info "[1/8] Initializing Git repository..."
    git init -b main --quiet
    git add .
    git commit -m "chore: initial laravel installation" --quiet
    
    info "[2/8] Configuring database and gitignore..."
    db_disp=$(configure_database "$db_choice")
    
    info "[3/8] Installing authentication template..."
    install_template "$template_choice"
    
    if [ "$INSTALL_PLUGINS" == "yes" ]; then
        info "[4/8] Installing plugins..."
        install_plugins
    fi
    
    if [ "$INSTALL_DEBUGGER" == "yes" ]; then
        info "[5/8] Installing debugger tools..."
        install_debugger
    fi
    
    if [ "$INSTALL_DEVTOOLS" == "yes" ]; then
        info "[6/8] Installing development tools..."
        install_devtools
    fi
    
    if [ "$GENERATE_EXAMPLE" == "yes" ]; then
        info "[7/8] Generating example department CRUD..."
        generate_example_resource
    fi
    
    info "[8/8] Finalizing build and assets..."
    if [ "$RUN_MIGRATIONS" == "yes" ]; then
        info "Running database migrations..."
        php artisan migrate --force
    fi
    if [ "$BUILD_ASSETS" == "yes" ]; then
        build_frontend
    fi
    
    php artisan key:generate
    php artisan storage:link
    git add .
    git commit -m "chore: finalize project setup" --quiet
    
    clear
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}           PROJECT SETUP COMPLETE!                   ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "\nProject:   $project_name"
    echo -e "Location:  \"$(pwd)\""
    echo -e "Database:  $db_disp"
    echo -e "\nInstalled Components:"
    echo -e "  - Git (Categorized History & Enhanced .gitignore)"
    [ "$INSTALL_PLUGINS" == "yes" ] && echo -e "  - Plugins: Spatie (Permission, ActivityLog), Socialite, Intervention Image"
    [ "$INSTALL_DEBUGGER" == "yes" ] && echo -e "  - Debugger: Telescope, Debugbar, Clockwork"
    [ "$INSTALL_DEVTOOLS" == "yes" ] && echo -e "  - DevTools: IDE Helper, Query Detector, CrestApps, Sail, Horizon, Sanctum"
    [ "$GENERATE_EXAMPLE" == "yes" ] && echo -e "  - Example Resource: Department CRUD"
    
    echo -e "\nQuick Commands:"
    echo -e "  cd $project_name"
    echo -e "  php artisan serve"
    echo -e "\nUseful URLs:"
    echo -e "  - App:        http://127.0.0.1:8000"
    if [ "$INSTALL_DEBUGGER" == "yes" ]; then
        echo -e "  - Telescope:  http://127.0.0.1:8000/telescope"
        echo -e "  - Debugbar:   http://127.0.0.1:8000/_debugbar"
        echo -e "  - Clockwork:  http://127.0.0.1:8000/__clockwork"
    fi
    
    read -rp "Press enter to return to menu..."
    cd .. || exit
}

existing_project() {
    clear
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo -e "${BOLD}${BLUE}           EXISTING PROJECT - BUILD & OPTIMIZE      ${NC}"
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo
    
    read -rp "Enter project path [.]: " project_path
    project_path=${project_path:-.}
    
    if [ ! -f "$project_path/artisan" ]; then
        error "No Laravel project found at '$project_path'."
        read -rp "Press enter to return to menu..."
        return
    fi
    
    cd "$project_path" || return
    info "Working in: $(pwd)"
    
    info "Installing composer dependencies..."
    composer install --prefer-dist
    
    if [ "$RUN_MIGRATIONS" == "yes" ]; then
        info "Running migrations..."
        php artisan migrate --force
    fi
    
    info "Clearing all caches..."
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
    php artisan optimize:clear
    
    if [ "$BUILD_ASSETS" == "yes" ]; then
        build_frontend
    fi
    
    info "Rebuilding production caches..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan optimize
    
    success "Build & optimization complete!"
    read -rp "Do you want to deploy to server now? [y/N]: " deploy_now
    if [[ "$deploy_now" =~ ^[Yy]$ ]]; then
        server_deploy
    else
        read -rp "Press enter to return to menu..."
    fi
}

quick_build() {
    clear
    info "Quick Build starting..."
    read -rp "Enter project path [.]: " project_path
    project_path=${project_path:-.}
    cd "$project_path" || return
    
    info "Installing dependencies & compiling assets..."
    composer install --prefer-dist --no-interaction
    npm install
    npm run build
    
    if [ "$RUN_MIGRATIONS" == "yes" ]; then
        php artisan migrate --force
    fi
    
    php artisan optimize
    success "Quick build complete!"
    read -rp "Press enter to return..."
}

local_deploy() {
    clear
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo -e "${BOLD}${BLUE}                  LOCAL DEPLOYMENT                  ${NC}"
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo
    
    read -rp "Enter project path [.]: " project_path
    project_path=${project_path:-.}
    cd "$project_path" || return
    
    info "Running local deployment sequence..."
    composer install --prefer-dist --no-dev --optimize-autoloader
    php artisan migrate --force --seed
    php artisan optimize:clear
    npm install
    npm run build
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    success "Local deployment complete! Starting development server..."
    php artisan serve
}

server_deploy() {
    clear
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo -e "${BOLD}${BLUE}                  SERVER DEPLOYMENT                  ${NC}"
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo
    
    read -rp "Server username [root]: " server_user
    server_user=${server_user:-root}
    read -rp "Server IP address: " server_ip
    if [ -z "$server_ip" ]; then
        error "Server IP is required."
        read -rp "Press enter to return..."
        return
    fi
    read -rp "Remote path [/var/www/html]: " server_path
    server_path=${server_path:-/var/www/html}
    read -rp "Git branch [main]: " git_branch
    git_branch=${git_branch:-main}
    
    info "Committing local changes..."
    git add .
    read -rp "Commit message [Auto-deploy]: " commit_msg
    commit_msg=${commit_msg:-Auto-deploy}
    git commit -m "$commit_msg" --quiet
    
    info "Pushing to remote branch: $git_branch..."
    git push origin "$git_branch"
    
    info "Executing remote SSH deployment..."
    # shellcheck disable=SC2029
    ssh "$server_user@$server_ip" "cd \"$server_path\" && git pull origin \"$git_branch\" && composer install --no-dev --optimize-autoloader && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache && npm install && npm run build"
    
    success "Server deployment complete!"
    echo -e "${GREEN}Your application should be live at: http://$server_ip${NC}"
    read -rp "Press enter to return..."
}

system_check() {
    clear
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo -e "${BOLD}${BLUE}                  SYSTEM CHECK                       ${NC}"
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo
    
    check_prerequisites
    
    info "Checking PHP Extensions..."
    if php -m | grep -Ei "pdo|json|mbstring|xml|gd|curl" &> /dev/null; then
        success "Required PHP extensions found (pdo, json, mbstring, xml, gd, curl)."
    else
        warn "Some required PHP extensions may be missing."
    fi
    
    echo
    info "Tool Versions:"
    php -v | head -n 1
    composer --version 2> /dev/null || error "Composer: Not found"
    git --version 2> /dev/null || error "Git: Not found"
    node -v 2> /dev/null || warn "Node.js: Not found"
    npm -v 2> /dev/null || warn "NPM: Not found"
    
    echo
    read -rp "Press enter to return..."
}

# --- MAIN MENU ---

show_menu() {
    clear
    echo -e "${BOLD}${CYAN}====================================================${NC}"
    echo -e "${BOLD}${CYAN}      LARAVEL MASTER SETUP - ULTIMATE EDITION        ${NC}"
    echo -e "${BOLD}${CYAN}====================================================${NC}"
    echo
    echo -e "  [1]  ${BOLD}New Project Setup${NC}       - Fresh Laravel install with Best Practices"
    echo -e "  [2]  ${BOLD}Existing Project Build${NC}  - Build & optimize existing project"
    echo -e "  [3]  ${BOLD}Quick Build${NC}             - Install dependencies & build assets"
    echo -e "  [4]  ${BOLD}Local Deploy${NC}            - Deploy locally + start artisan serve"
    echo -e "  [5]  ${BOLD}Server Deploy${NC}           - Remote SSH deployment"
    echo -e "  [6]  ${BOLD}System Check${NC}            - Verify prerequisites & PHP extensions"
    echo -e "  [7]  ${BOLD}Toggle Options${NC}          - Customize installation settings"
    echo -e "  [0]  Exit"
    echo
    echo -e "Current Settings:"
    echo -ne "  Plugins: ${YELLOW}$INSTALL_PLUGINS${NC} | Debugger: ${YELLOW}$INSTALL_DEBUGGER${NC} | DevTools: ${YELLOW}$INSTALL_DEVTOOLS${NC}\n"
    echo -ne "  Assets: ${YELLOW}$BUILD_ASSETS${NC} | Migrate: ${YELLOW}$RUN_MIGRATIONS${NC} | Example: ${YELLOW}$GENERATE_EXAMPLE${NC}\n"
    echo
    read -rp "Select option [0-7]: " choice
}

toggle_options() {
    while true; do
        clear
        echo -e "${BOLD}Configure Installation Options:${NC}\n"
        echo "  [1] Install Plugins (Spatie, Socialite, Image):  $INSTALL_PLUGINS"
        echo "  [2] Install Debugger (Telescope, Debugbar, Clockwork): $INSTALL_DEBUGGER"
        echo "  [3] Install DevTools (IDE Helper, Sail, Horizon, Sanctum): $INSTALL_DEVTOOLS"
        echo "  [4] Build Assets (NPM Build):             $BUILD_ASSETS"
        echo "  [5] Run Migrations (DB Migrations):         $RUN_MIGRATIONS"
        echo "  [6] Example Scaffold (Department CRUD):     $GENERATE_EXAMPLE"
        echo "  [0] Back to Menu"
        read -rp "Choice: " opt
        case $opt in
            1) [[ $INSTALL_PLUGINS == "yes" ]] && INSTALL_PLUGINS="no" || INSTALL_PLUGINS="yes" ;;
            2) [[ $INSTALL_DEBUGGER == "yes" ]] && INSTALL_DEBUGGER="no" || INSTALL_DEBUGGER="yes" ;;
            3) [[ $INSTALL_DEVTOOLS == "yes" ]] && INSTALL_DEVTOOLS="no" || INSTALL_DEVTOOLS="yes" ;;
            4) [[ $BUILD_ASSETS == "yes" ]] && BUILD_ASSETS="no" || BUILD_ASSETS="yes" ;;
            5) [[ $RUN_MIGRATIONS == "yes" ]] && RUN_MIGRATIONS="no" || RUN_MIGRATIONS="yes" ;;
            6) [[ $GENERATE_EXAMPLE == "yes" ]] && GENERATE_EXAMPLE="no" || GENERATE_EXAMPLE="yes" ;;
            0) break ;;
        esac
    done
}

# --- PRIMARY LOOP ---

while true; do
    show_menu
    case $choice in
        1) new_project ;;
        2) existing_project ;;
        3) quick_build ;;
        4) local_deploy ;;
        5) server_deploy ;;
        6) system_check ;;
        7) toggle_options ;;
        0) exit 0 ;;
        *) warn "Invalid option." && sleep 1 ;;
    esac
done
