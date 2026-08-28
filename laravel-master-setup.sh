#!/bin/bash

# =========================================================================
# Name:     Laravel Master CI/CD & Setup Script (Ubuntu/Bash)
# Purpose:  Complete Laravel development workflow with templates, plugins,
#            debugger, and supporting tools for Linux environments.
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

# --- HELPER FUNCTIONS ---

info() { echo -e "${CYAN}[*] $1${NC}"; }
success() { echo -e "${GREEN}[OK] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

check_prerequisites() {
    info "Checking system prerequisites..."
    local ok=0
    
    for cmd in php composer git node npm; do
        if ! command -v "$cmd" &> /dev/null; then
            error "$cmd is not installed."
            ok=1
        else
            success "$cmd found: $("$cmd" --version | head -n 1)"
        fi
    done
    
    return $ok
}

configure_database() {
    local db_choice=$1
    case $db_choice in
        1)
            info "Setting up SQLite..."
            touch database/database.sqlite
            sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
            # Use | as sed delimiter to avoid escaping slashes in path
            # shellcheck disable=SC2046
            sed -i "s|^DB_DATABASE=.*|DB_DATABASE=\"$(pwd)/database/database.sqlite\"|" .env
            echo "/database/database.sqlite" >> .gitignore
            success "SQLite configured."
            ;;
        2)
            info "Configuring MySQL..."
            read -rp "    Database name [laravel]: " db_name
            db_name=${db_name:-laravel}
            read -rp "    Database user [root]: " db_user
            db_user=${db_user:-root}
            read -rp "    Database password []: " db_pass
            
            sed -i "s/^DB_DATABASE=.*/DB_DATABASE=$db_name/" .env
            sed -i "s/^DB_USERNAME=.*/DB_USERNAME=$db_user/" .env
            sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$db_pass/" .env
            success "MySQL configured."
            ;;
        3)
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
            success "PostgreSQL configured."
            ;;
    esac
    git add .env .gitignore
    git commit -m "config: database setup" --quiet
}

install_template() {
    local choice=$1
    case $choice in
        1) info "Skipping template (Standard Blade)." ;;
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
            info "Installing Jetstream (Inertia)..."
            composer require laravel/jetstream --dev --quiet
            php artisan jetstream:install inertia --quiet
            ;;
        6)
            info "Installing API (Sanctum)..."
            php artisan install:api
            ;;
        *) return 0 ;;
    esac
    
    git add .
    git commit -m "feat: install authentication template" --quiet
    success "Template installed."
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
    echo "  [5] Laravel Jetstream (Inertia)"
    echo "  [6] API Only (Sanctum)"
    echo "  [7] None (Manual)"
    read -rp "Enter choice [2]: " template_choice
    template_choice=${template_choice:-2}
    
    echo -e "\nSelect Database:"
    echo "  [1] SQLite (Development)"
    echo "  [2] MySQL"
    echo "  [3] PostgreSQL"
    read -rp "Enter choice [1]: " db_choice
    db_choice=${db_choice:-1}
    
    info "Creating Laravel project: $project_name"
    composer create-project --prefer-dist laravel/laravel "$project_name"
    
    cd "$project_name" || return
    
    info "Initializing Git..."
    git init -b main --quiet
    git add .
    git commit -m "chore: initial laravel installation" --quiet
    
    configure_database "$db_choice"
    install_template "$template_choice"
    
    if [ "$INSTALL_PLUGINS" == "yes" ]; then
        info "Installing Spatie (Permission, ActivityLog)..."
        composer require spatie/laravel-permission spatie/laravel-activitylog --quiet
        php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --force
        php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations" --force
        git add .
        git commit -m "feat: install spatie plugins" --quiet
    fi
    
    if [ "$INSTALL_DEBUGGER" == "yes" ]; then
        info "Installing Telescope & Debugbar..."
        composer require laravel/telescope barryvdh/laravel-debugbar --dev --quiet
        php artisan telescope:install --force
        git add .
        git commit -m "chore: install debugger tools" --quiet
    fi
    
    if [ "$INSTALL_DEVTOOLS" == "yes" ]; then
        info "Installing IDE Helper & Query Detector..."
        composer require barryvdh/laravel-ide-helper beyondcode/laravel-query-detector crestapps/laravel-code-generator --dev --quiet
        php artisan ide-helper:generate --quiet
        php artisan ide-helper:meta --quiet
        php artisan vendor:publish --provider="BeyondCode\QueryDetector\QueryDetectorServiceProvider" --force
        git add .
        git commit -m "chore: install dev tools" --quiet
    fi
    
    if [ "$BUILD_ASSETS" == "yes" ]; then
        info "Building frontend assets..."
        npm install --quiet
        npm run build --quiet
        git add .
        git commit -m "build: compile assets" --quiet
    fi
    
    if [ "$RUN_MIGRATIONS" == "yes" ]; then
        info "Running migrations..."
        php artisan migrate --force
    fi
    
    clear
    echo -e "${GREEN}====================================================${NC}"
    echo -e "${GREEN}           PROJECT SETUP COMPLETE!                   ${NC}"
    echo -e "${GREEN}====================================================${NC}"
    echo -e "\nProject:   $project_name"
    echo -e "Location:  \"$(pwd)\""
    echo -e "\nQuick Commands:"
    echo -e "  cd $project_name"
    echo -e "  php artisan serve"
    read -rp "Press enter to return to menu..."
    cd .. || exit
}

quick_build() {
    clear
    info "Quick Build starting..."
    read -rp "Enter project path [.]: " project_path
    project_path=${project_path:-.}
    cd "$project_path" || return
    
    info "Installing dependencies..."
    composer install --prefer-dist --no-interaction
    npm install
    npm run build
    
    if [ "$RUN_MIGRATIONS" == "yes" ]; then
        php artisan migrate --force
    fi
    
    php artisan optimize
    success "Quick build complete!"
    read -rp "Press enter to return..."
    cd - > /dev/null || exit
}

server_deploy() {
    clear
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo -e "${BOLD}${BLUE}                  SERVER DEPLOYMENT                  ${NC}"
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    
    read -rp "Server username [root]: " server_user
    server_user=${server_user:-root}
    read -rp "Server IP address: " server_ip
    read -rp "Remote path [/var/www/html]: " server_path
    server_path=${server_path:-/var/www/html}
    read -rp "Git branch [main]: " git_branch
    git_branch=${git_branch:-main}
    
    info "Committing and pushing changes..."
    git add .
    read -rp "Commit message [Auto-deploy]: " commit_msg
    commit_msg=${commit_msg:-Auto-deploy}
    git commit -m "$commit_msg"
    git push origin "$git_branch"
    
    # shellcheck disable=SC2029
    ssh "$server_user@$server_ip" "cd \"$server_path\" && git pull origin \"$git_branch\" && composer install --no-dev --optimize-autoloader && php artisan migrate --force && php artisan config:cache && php artisan route:cache && php artisan view:cache && npm install && npm run build"
    
    success "Server deployment complete!"
    read -rp "Press enter to return..."
}

# --- MAIN MENU ---

show_menu() {
    clear
    echo -e "${BOLD}${CYAN}====================================================${NC}"
    echo -e "${BOLD}${CYAN}   LARAVEL BASH MASTER (UBUNTU Edition)              ${NC}"
    echo -e "${BOLD}${CYAN}====================================================${NC}"
    echo
    echo -e "  [1]  ${BOLD}New Project Setup${NC}     - Fresh Laravel install"
    echo -e "  [2]  ${BOLD}Quick Build${NC}           - Install deps & build assets"
    echo -e "  [3]  ${BOLD}Server Deploy${NC}         - Remote SSH deployment"
    echo -e "  [4]  ${BOLD}System Check${NC}          - Verify prerequisites"
    echo -e "  [5]  ${BOLD}Toggle Options${NC}        - Customize install settings"
    echo -e "  [0]  Exit"
    echo
    echo -e "Current Settings:"
    echo -ne "  Template: ${YELLOW}$INSTALL_TEMPLATE${NC} | Plugins: ${YELLOW}$INSTALL_PLUGINS${NC} | Debug: ${YELLOW}$INSTALL_DEBUGGER${NC}\n"
    echo -ne "  DevTools: ${YELLOW}$INSTALL_DEVTOOLS${NC} | Assets: ${YELLOW}$BUILD_ASSETS${NC} | Migrate: ${YELLOW}$RUN_MIGRATIONS${NC}\n"
    echo
    read -rp "Select option [0-5]: " choice
}

toggle_options() {
    while true; do
        clear
        echo -e "${BOLD}Configure Installation Options:${NC}\n"
        echo "  [1] Install Template:  $INSTALL_TEMPLATE"
        echo "  [2] Install Plugins:   $INSTALL_PLUGINS"
        echo "  [3] Install Debugger:  $INSTALL_DEBUGGER"
        echo "  [4] Install DevTools:  $INSTALL_DEVTOOLS"
        echo "  [5] Build Assets:      $BUILD_ASSETS"
        echo "  [6] Run Migrations:    $RUN_MIGRATIONS"
        echo "  [0] Back to Menu"
        read -rp "Choice: " opt
        case $opt in
            1) [[ $INSTALL_TEMPLATE == "yes" ]] && INSTALL_TEMPLATE="no" || INSTALL_TEMPLATE="yes" ;;
            2) [[ $INSTALL_PLUGINS == "yes" ]] && INSTALL_PLUGINS="no" || INSTALL_PLUGINS="yes" ;;
            3) [[ $INSTALL_DEBUGGER == "yes" ]] && INSTALL_DEBUGGER="no" || INSTALL_DEBUGGER="yes" ;;
            4) [[ $INSTALL_DEVTOOLS == "yes" ]] && INSTALL_DEVTOOLS="no" || INSTALL_DEVTOOLS="yes" ;;
            5) [[ $BUILD_ASSETS == "yes" ]] && BUILD_ASSETS="no" || BUILD_ASSETS="yes" ;;
            6) [[ $RUN_MIGRATIONS == "yes" ]] && RUN_MIGRATIONS="no" || RUN_MIGRATIONS="yes" ;;
            0) break ;;
        esac
    done
}

# --- PRIMARY LOOP ---

while true; do
    show_menu
    case $choice in
        1) new_project ;;
        2) quick_build ;;
        3) server_deploy ;;
        4) check_prerequisites && read -rp "Press enter..." ;;
        5) toggle_options ;;
        0) exit 0 ;;
        *) warn "Invalid option." && sleep 1 ;;
    esac
done
