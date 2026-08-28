# LaravelAutoScript v2 — Laravel Application Platform Builder

[![CI](https://github.com/muslimbi/laravelautoscript/actions/workflows/ci.yml/badge.svg)](https://github.com/muslimbi/laravelautoscript/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**LaravelAutoScript v2** transforms basic Laravel installation scripts into a powerful, cross-platform **Laravel Application Platform Builder**. It enables developers to interactively create, configure, extend, build, test, optimize, and deploy Laravel applications from one unified CLI experience across Windows (CMD & PowerShell), Linux, and macOS.

---

## Table of Contents
1. [Overview](#overview)
2. [Installation & Setup](#installation--setup)
3. [Supported Operating Systems](#supported-operating-systems)
4. [Quick Start](#quick-start)
5. [Interactive Master Wizard](#interactive-master-wizard)
6. [Admin Panel System](#admin-panel-system)
7. [Application Feature Marketplace](#application-feature-marketplace)
8. [Application Profiles](#application-profiles)
9. [CRUD Scaffolding Generator](#crud-scaffolding-generator)
10. [AI Platform Integration](#ai-platform-integration)
11. [Build & Optimization Pipeline](#build--optimization-pipeline)
12. [Testing & Quality Gate](#testing--quality-gate)
13. [Deployment Engine](#deployment-engine)
14. [GitHub Actions Workflows](#github-actions-workflows)
15. [Project Configuration File](#project-configuration-file)
16. [Troubleshooting](#troubleshooting)
17. [Security Practices](#security-practices)
18. [Contributing](#contributing)

---

## 1. Overview

LaravelAutoScript v2 is an all-in-one developer automation suite for Laravel applications. It abstracts repetitive configuration, package installation, environment setup, quality enforcement, and deployment procedures into modular workflows.

### Key Highlights
- **Unified Master CLI Wizard**: 19 interactive choices covering creation, configuration, profiles, features, testing, building, and deployment.
- **Cross-Platform Engine**: Native support for Windows CMD (`.bat`/`.cmd`), Windows PowerShell (`.ps1`), Linux/Unix (`.sh`), and Node.js (`scripts/platform-builder.js`).
- **Profile Architecture**: One-command stack creation for SaaS, CRM, ERP, API Platforms, and AI Applications.
- **Idempotency & Safety**: Validates paths, checks declared Composer packages, safely updates `.env` without printing secrets, and avoids duplicate entries.

---

## 2. Installation & Setup

Clone the repository to your local system:

```bash
git clone https://github.com/muslimbi/laravelautoscript.git
cd laravelautoscript
```

### Prerequisites
- **PHP**: 8.2 or higher
- **Composer**: 2.x
- **Git**: 2.x
- **Node.js**: 18.x or higher (npm included)

---

## 3. Supported Operating Systems

| OS / Shell | Script Entry Point | Command Example |
|---|---|---|
| **Windows CMD** | `laravel-master-setup.bat` | `laravel-master-setup.bat create --name my-app` |
| **Windows PowerShell** | `laravel-master-setup.ps1` | `.\laravel-master-setup.ps1 profile saas` |
| **Linux / macOS** | `laravel-master-setup.sh` | `./laravel-master-setup.sh build --mode production` |
| **Direct Node.js** | `scripts/platform-builder.js` | `node scripts/platform-builder.js system` |

---

## 4. Quick Start

### Interactive Launcher
Launch the master setup wizard interactively:
```bash
# Windows CMD
laravel-master-setup.bat

# Windows PowerShell
.\laravel-master-setup.ps1

# Linux / macOS
./laravel-master-setup.sh
```

### Non-Interactive Automation
Run automation commands directly from your terminal:
```bash
# Create a new SaaS platform application
node scripts/platform-builder.js create --name my-saas --starter react --database mysql

# Apply the SaaS profile
node scripts/platform-builder.js profile saas --project ./my-saas

# Run tests and quality gate
node scripts/platform-builder.js test --project ./my-saas

# Build for production
node scripts/platform-builder.js build --mode production --project ./my-saas
```

---

## 5. Interactive Master Wizard

```text
============================================================
 LaravelAutoScript v2
 Laravel Application Platform Builder
============================================================

[1] Create New Laravel Application
[2] Configure Existing Laravel Application
[3] Application Profiles
[4] Admin Panel
[5] Authentication
[6] Database
[7] API Platform
[8] Application Features
[9] AI Features
[10] Developer Tools
[11] Build & Optimize
[12] Test & Quality
[13] Local Deployment
[14] Production Deployment
[15] Docker
[16] Git / GitHub
[17] System Check
[18] Project Information
[19] Advanced Configuration
[0] Exit
```

---

## 6. Admin Panel System

Interactively select and install modern Laravel administration frameworks:

| Admin Panel | Package | Supported Features |
|---|---|---|
| **Filament** | `filament/filament` | Modern Livewire panels, resource scaffolding, widgets, RBAC |
| **Backpack** | `backpack/crud` | Modular CRUD generation, auth, custom filters |
| **Orchid** | `orchid/platform` | Screen-based back-office platform |
| **MoonShine** | `moonshine/moonshine` | Tailwind & Blade admin dashboard |
| **Laravel Nova** | `laravel/nova` | Handled gracefully with commercial licensing guidance |

---

## 7. Application Feature Marketplace

Install modular features on demand without manual composer copy-pasting:

- **RBAC / Permissions**: `spatie/laravel-permission`
- **Activity & Audit Log**: `spatie/laravel-activitylog`
- **Media Management**: `spatie/laravel-medialibrary`
- **API Platform**: `laravel/sanctum`
- **Queues & Worker Dashboard**: `laravel/horizon`
- **Realtime WebSockets**: `laravel/reverb`
- **Full-Text Search**: `laravel/scout`
- **Billing & Subscriptions**: `laravel/cashier`
- **Application Monitoring**: `laravel/pulse`
- **Feature Flags**: `laravel/pennant`
- **Developer Tools**: `pest`, `pint`, `larastan`, `ide-helper`, `debugbar`, `telescope`, `clockwork`, `query-detector`

---

## 8. Application Profiles

Apply curated multi-package profiles in a single operation:

```bash
node scripts/platform-builder.js profile <profile-name> --project ./my-app
```

- **`minimal`**: Clean Laravel application.
- **`admin-starter`**: Filament + Spatie RBAC + Activity Log + Media + Pulse + Pest + Pint.
- **`crm`**: Filament + RBAC + Activity Log + Media + Scout + Notifications + Horizon.
- **`erp`**: Filament + RBAC + Audit + Media + Search + Horizon + Reverb + Reports.
- **`saas`**: React/Inertia + Filament + RBAC + Media + Sanctum + Horizon + Reverb + Scout + Billing + Pulse.
- **`api-platform`**: Sanctum API + Spatie RBAC + Activity Log + Horizon.
- **`ai-application`**: Filament + RBAC + Activity Log + AI SDK + Horizon + Scout + Vector support.

---

## 9. CRUD Scaffolding Generator

Scaffold full-stack resources (Model, Migration, Factory, Controller, Requests, and Admin Resource) with a single command:

```bash
node scripts/platform-builder.js crud --name Product --fields "name:string,price:decimal,is_active:boolean" --project ./my-app
```

---

## 10. AI Platform Integration

Provider-agnostic AI foundation configuration for Laravel apps:

```bash
node scripts/platform-builder.js ai sdk --provider openai --model gpt-4o --project ./my-app
```

Configures environment parameters securely (`AI_PROVIDER`, `AI_MODEL`, `EMBEDDING_MODEL`, `VECTOR_STORE`) without exposing secrets.

---

## 11. Build & Optimization Pipeline

Supports `development`, `staging`, and `production` modes:
- Dependency installation (`composer install`)
- Asset compilation (`npm ci && npm run build`)
- Migration & seeding (`php artisan migrate`)
- Storage link creation (`php artisan storage:link`)
- Production cache generation (`config:cache`, `route:cache`, `view:cache`, `optimize`)

---

## 12. Testing & Quality Gate

Run automated quality checks:
```bash
node scripts/platform-builder.js test --strict --project ./my-app
```
Pipeline stages: Composer Validation -> Pint Code Formatting -> Larastan Static Analysis -> Unit/Feature Tests -> NPM Build Validation.

---

## 13. Deployment Engine

Deploy locally or remotely via SSH:
```bash
# Local serve
node scripts/platform-builder.js deploy --strategy local

# SSH Remote Server Deploy
node scripts/platform-builder.js deploy --strategy ssh --host user@server-ip --remote-path /var/www/html --maintenance
```

---

## 14. GitHub Actions Workflows

Pre-configured workflows in `.github/workflows/`:
- `ci.yml`: Multi-PHP version matrix validation.
- `test.yml`: Automated test execution.
- `build.yml`: Build validation.
- `deploy.yml`: Production SSH deployment via GitHub Secrets.
- `release.yml`: Automated release packaging.
- `security.yml`: Security diagnostic audit.

---

## 15. Project Configuration File

Every managed project maintains a `.laravelautoscript.yml` configuration:

```yaml
version: 2
laravel:
  version: latest
starter_kit: react
database:
  driver: mysql
admin:
  panel: filament
features:
  - permission
  - activitylog
  - media
  - horizon
developer:
  pest: true
  pint: true
  larastan: true
```

---

## 16. Troubleshooting

Run system diagnostics to verify your local environment:
```bash
node scripts/platform-builder.js system
```

Check [docs/troubleshooting.md](docs/troubleshooting.md) for solutions to common PATH, extension, or database issues.

---

## 17. Security Practices

- Passwords and SSH keys are never logged or exposed.
- Commercial software (such as Laravel Nova) requires manual license authentication.
- Environmental secrets are written to `.env` without printing sensitive values to stdout.

---

## 18. Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) and submit pull requests targeting the `main` branch.

---

## License

This software is open-source licensed under the [MIT License](LICENSE).
