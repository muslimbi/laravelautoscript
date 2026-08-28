# Master Prompt — LaravelAutoScript v2

You are the lead software architect and senior DevOps engineer responsible for upgrading this repository:

**GitHub repository:** `muslimbi/laravelautoscript`

## Mission

Transform the existing LaravelAutoScript project from a basic Laravel installer/build/deployment script into a **cross-platform Laravel Application Platform Builder**.

The tool must allow a developer to interactively create, configure, extend, build, test, optimize, and deploy Laravel applications from one unified CLI experience.

Do NOT create a separate unrelated project. Upgrade the existing repository while preserving backward compatibility wherever practical.

---

# 1. First: Inspect Before Editing

Before making changes:

1. Inspect the complete repository structure.
2. Read all existing:
   - `.bat`
   - `.ps1`
   - `.sh`
   - README files
   - GitHub Actions workflows
   - configuration files
   - documentation
   - tests
3. Understand the current implementation.
4. Identify duplicated logic between CMD, PowerShell and Bash.
5. Create a short internal implementation plan.
6. Do not blindly overwrite existing functionality.

The current master scripts already support:

- Laravel project creation
- Git initialization
- SQLite/MySQL/PostgreSQL
- authentication templates
- Breeze
- Jetstream
- API setup
- Spatie packages
- Telescope
- Debugbar
- Clockwork
- IDE helper
- Horizon
- Sanctum
- frontend build
- CRUD generation
- local deployment
- SSH deployment
- system checks

Preserve these capabilities unless they conflict with current Laravel best practices.

---

# 2. New Architecture

Refactor the project toward this architecture:

```text
LaravelAutoScript
│
├── master/
│   ├── laravel-master-setup.bat
│   ├── laravel-master-setup.ps1
│   └── laravel-master-setup.sh
│
├── features/
│   ├── admin-panels/
│   ├── authentication/
│   ├── database/
│   ├── api/
│   ├── permissions/
│   ├── media/
│   ├── search/
│   ├── realtime/
│   ├── queues/
│   ├── monitoring/
│   ├── billing/
│   ├── ai/
│   └── developer-tools/
│
├── profiles/
│   ├── admin-starter
│   ├── saas
│   ├── crm
│   ├── erp
│   ├── api-platform
│   ├── ai-application
│   └── minimal
│
├── templates/
│   ├── admin/
│   ├── crud/
│   ├── api/
│   ├── authentication/
│   └── deployment/
│
├── scripts/
│   ├── windows/
│   ├── powershell/
│   └── unix/
│
├── docs/
│
└── .github/
    └── workflows/
```

Do not duplicate the complete business logic three times if avoidable.

Create a centralized feature/catalog definition that can be consumed by the platform-specific launchers.

---

# 3. Main Interactive Wizard

Create a new master wizard with a menu similar to:

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

The wizard should support both:

- interactive mode
- non-interactive/automation mode

Example:

```text
laravelautoscript create
laravelautoscript configure
laravelautoscript profile saas
laravelautoscript admin filament
laravelautoscript build
laravelautoscript deploy
```

If a full CLI executable is impractical because the repository currently uses shell scripts, create a consistent command abstraction across `.bat`, `.ps1`, and `.sh`.

---

# 4. Laravel Version

Add Laravel version selection.

Example:

```text
Laravel Version

[1] Latest stable
[2] Laravel 13
[3] Laravel 12
[4] Custom version
```

Default to the latest stable compatible version.

Do not hard-code obsolete package versions unless necessary.

Use Composer/package constraints that are compatible with the selected Laravel version.

Before implementing package installation, verify current package compatibility.

---

# 5. Starter Kit

For new applications provide:

```text
Starter Kit

[1] React
[2] Vue
[3] Svelte
[4] Livewire
[5] Minimal / None
```

Also support authentication choices appropriate to the selected starter kit.

Do not make old Breeze/Jetstream workflows the only modern options.

Keep legacy options available when compatible.

---

# 6. Admin Panel System

This is a major new feature.

Create an interactive Admin Panel selector:

```text
============================================================
 ADMIN PANEL
============================================================

[1] Filament
[2] Backpack
[3] Orchid
[4] MoonShine
[5] Laravel Nova
[6] Custom / Manual
[7] None
```

Each admin panel must have its own installer module.

## Filament

Support:

- installation
- panel creation
- admin user creation
- authentication
- resources
- dashboards
- widgets
- navigation
- roles/permissions integration
- optional example CRUD

## Backpack

Support:

- installation
- CRUD setup
- authentication
- optional example CRUD

## Orchid

Support:

- installation
- platform setup
- optional example screen

## MoonShine

Support:

- installation
- dashboard setup
- optional resources

## Nova

Treat Nova separately because it is commercial/licensed.

Never attempt to bypass licensing.

Provide:

```text
Laravel Nova requires an authorized package source/license.

[1] Configure manually
[2] Skip Nova
```

The installer must not fail the entire project because Nova is unavailable.

## Important

Do NOT automatically install multiple admin panels unless explicitly requested.

Warn the user that multiple admin frameworks can introduce route, asset, authentication and dependency conflicts.

---

# 7. Admin Panel Profiles

Add predefined profiles:

## Admin Starter

```text
Filament
+ Spatie Permission
+ Activity Log
+ Media Library
+ Telescope/Pulse
+ Pest
+ Pint
```

## CRM

```text
Filament or Backpack
+ RBAC
+ Activity Log
+ Media Library
+ Search
+ Notifications
+ Queues
+ Realtime
```

## ERP

```text
Filament or Backpack
+ RBAC
+ Audit
+ Media
+ Search
+ Queue
+ Realtime
+ Reports
+ Notifications
```

## SaaS

```text
Filament
+ RBAC
+ Teams/organization architecture
+ Billing
+ API
+ Queue
+ Realtime
+ Search
+ Monitoring
```

## API Platform

```text
No admin OR Filament
+ Sanctum/Passport
+ API resources
+ validation
+ testing
+ documentation hooks
```

## AI Application

```text
Filament
+ RBAC
+ Activity Log
+ Laravel AI SDK
+ Queues
+ Search
+ Vector/embedding support
+ Monitoring
```

---

# 8. Authentication

Implement an authentication selection layer:

```text
[1] Starter Kit Authentication
[2] Sanctum API Authentication
[3] Passport OAuth2
[4] Session Authentication
[5] Custom
[6] None
```

Ensure incompatible authentication combinations produce warnings.

---

# 9. Database

Support:

```text
[1] SQLite
[2] MySQL
[3] PostgreSQL
[4] MariaDB
```

Provide:

- interactive DB name
- username
- password
- host
- port
- `.env` configuration
- connection test
- migration
- optional seeding

Never print database passwords to logs.

---

# 10. Application Feature Marketplace

Create a modular feature installer.

Menu:

```text
============================================================
 APPLICATION FEATURES
============================================================

[1] RBAC / Permissions
[2] Activity / Audit Log
[3] Media Management
[4] API
[5] Queue / Horizon
[6] Realtime / Reverb
[7] Search / Scout
[8] Notifications
[9] File Storage
[10] Billing
[11] Monitoring
[12] Scheduler
[13] Reporting
[14] Import / Export
[15] Localization
[16] Multi-tenancy
[17] Feature Flags
[18] Install Multiple Features
```

Every feature should be independently installable.

Each module should expose:

```text
name
description
package
requirements
install commands
publish commands
migration commands
environment variables
post-install tasks
validation
rollback/uninstall notes
```

---

# 11. Developer Tools

Add:

```text
[1] Pest
[2] PHPUnit
[3] Laravel Pint
[4] Larastan
[5] IDE Helper
[6] Debugbar
[7] Telescope
[8] Clockwork
[9] Query Detector
[10] Laravel Sail
[11] Docker
```

Create a developer profile:

```text
Pest + Pint + Larastan + IDE Helper + Debugging
```

---

# 12. AI Platform

Add a dedicated AI menu:

```text
============================================================
 AI FEATURES
============================================================

[1] Laravel AI SDK
[2] AI Agent foundation
[3] AI tools
[4] Embeddings
[5] Vector search
[6] RAG foundation
[7] AI job/queue processing
[8] AI configuration
[9] AI application profile
```

The system should create an extensible structure for AI features instead of hard-coding one provider.

Support environment configuration such as:

```text
AI_PROVIDER
AI_MODEL
AI_API_KEY
EMBEDDING_MODEL
VECTOR_STORE
```

Never commit secrets.

The AI layer must remain provider-agnostic where possible.

---

# 13. CRUD Generator

Upgrade the existing Department example into a generic CRUD generator.

Example:

```text
Create Resource

Name: Product

Fields:
- name:string
- sku:string
- price:decimal
- description:text
- image:image
- is_active:boolean

Generate:

Model
Migration
Factory
Seeder
Controller
Form Request
Policy
API Resource
Routes
Tests
Admin Resource
```

The user should be able to choose which layers are generated.

Example:

```text
[✓] Model
[✓] Migration
[✓] Factory
[✓] Seeder
[✓] Controller
[✓] Request
[✓] Policy
[✓] API Resource
[✓] Tests
[✓] Admin Resource
```

Admin Resource generation must depend on the selected admin framework.

---

# 14. Application Profiles

Create a profile engine.

Example:

```text
laravelautoscript profile saas
```

Profiles should define:

```text
profile.yaml
```

Example concept:

```yaml
name: saas

starter_kit: react
admin_panel: filament

features:
  - permission
  - activitylog
  - media
  - api
  - horizon
  - reverb
  - scout
  - billing
  - monitoring

developer:
  - pest
  - pint
  - larastan
```

Allow users to create custom profiles.

---

# 15. Build System

Upgrade build workflow:

```text
[1] Composer Install
[2] NPM Install
[3] Frontend Build
[4] Migrations
[5] Seed
[6] Clear Cache
[7] Optimize
[8] Config Cache
[9] Route Cache
[10] View Cache
[11] Storage Link
[12] Production Build
```

Add separate:

```text
development
staging
production
```

modes.

---

# 16. Testing & Quality Gate

Create a quality pipeline:

```text
Composer validation
↓
Pint
↓
Larastan
↓
Pest/PHPUnit
↓
NPM lint
↓
NPM build
↓
Laravel health check
```

The pipeline should stop on critical failures.

Provide a `--strict` option.

---

# 17. Deployment

Support:

```text
[1] Local
[2] SSH
[3] Git deployment
[4] Docker
[5] GitHub Actions
[6] Manual production
```

Production deployment should support:

```text
git pull
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan storage:link
npm ci
npm run build
php artisan optimize
```

Add optional maintenance mode:

```text
php artisan down
...
php artisan up
```

Never expose passwords or private SSH keys.

---

# 18. GitHub Actions

Create/update workflows:

```text
.github/workflows/

ci.yml
test.yml
build.yml
deploy.yml
release.yml
security.yml
```

CI should validate:

- PHP versions
- Laravel installation
- Composer dependencies
- migrations
- tests
- Pint
- Larastan
- frontend build

Use matrices where practical.

Deployment secrets must come from GitHub Secrets.

---

# 19. System Check

Expand system diagnostics.

Check:

```text
PHP
Composer
Git
Node
NPM
PNPM
Yarn
Docker
SSH
MySQL
PostgreSQL
SQLite
PHP extensions
Laravel
Composer packages
Git configuration
environment
```

Output should be human-readable:

```text
[OK] PHP 8.x
[OK] Composer
[OK] Git
[OK] Node.js
[WARN] Docker not installed
[OK] SQLite
[WARN] MySQL unavailable
```

Return meaningful exit codes.

---

# 20. Configuration File

Introduce a project configuration file:

```text
.laravelautoscript.yml
```

It should remember:

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
  - reverb

developer:
  pest: true
  pint: true
  larastan: true

deployment:
  strategy: ssh
```

The user should be able to rerun the setup without answering every question.

---

# 21. Safety & Idempotency

This is critical.

The scripts must:

- detect whether a package is already installed
- detect whether migrations already exist
- avoid duplicate `.env` entries
- avoid duplicate `.gitignore` entries
- avoid duplicate Composer packages
- avoid destructive commands without confirmation
- validate project paths
- handle spaces in Windows paths
- quote shell arguments correctly
- never expose secrets
- return errors instead of silently ignoring failures

Do not use patterns such as:

```text
2>nul
|| true
```

to hide important installation failures.

Errors must be visible and actionable.

---

# 22. Cross-platform Requirement

The same feature must behave consistently on:

```text
Windows CMD
Windows PowerShell
Linux
macOS
```

Where platform differences exist, isolate them behind helper functions.

Use:

```text
detect_os
detect_shell
detect_package_manager
detect_php
detect_node
```

Do not assume:

```text
grep
sed
awk
find
bash
```

exist on Windows CMD.

---

# 23. Documentation

Update the README extensively.

Include:

1. What LaravelAutoScript is
2. Installation
3. Supported operating systems
4. Quick start
5. Interactive wizard
6. Admin panels
7. Feature marketplace
8. Application profiles
9. CRUD generator
10. AI features
11. Build
12. Testing
13. Deployment
14. GitHub Actions
15. Configuration
16. Troubleshooting
17. Security
18. Contributing

Create:

```text
docs/
├── architecture.md
├── admin-panels.md
├── features.md
├── profiles.md
├── crud-generator.md
├── ai.md
├── deployment.md
├── testing.md
├── configuration.md
└── troubleshooting.md
```

---

# 24. Tests

Add tests for the script logic where practical.

At minimum validate:

- menu selection
- invalid selections
- Laravel detection
- package detection
- admin panel selection
- profile loading
- configuration loading
- database configuration
- idempotent execution
- error handling
- non-interactive mode

Do not require an actual production server to run the test suite.

---

# 25. Git Workflow

After implementation:

1. Inspect `git status`.
2. Review all changes.
3. Run formatting/linting.
4. Run available tests.
5. Run shell syntax checks where possible.
6. Validate PowerShell syntax.
7. Validate batch syntax as far as the environment allows.
8. Validate YAML.
9. Update documentation.
10. Create a clear commit.

Do not modify unrelated files.

Do not delete existing functionality simply to simplify implementation.

---

# 26. Final Acceptance Criteria

The upgrade is complete only if:

### Core

- [ ] Existing installer still works
- [ ] New wizard works
- [ ] Existing project configuration works
- [ ] Interactive mode works
- [ ] Non-interactive mode works

### Admin

- [ ] Filament
- [ ] Backpack
- [ ] Orchid
- [ ] MoonShine
- [ ] Nova graceful/manual handling
- [ ] None

### Features

- [ ] RBAC
- [ ] Activity log
- [ ] Media
- [ ] API
- [ ] Horizon
- [ ] Reverb
- [ ] Scout
- [ ] Billing
- [ ] Monitoring
- [ ] AI
- [ ] Testing
- [ ] Static analysis

### Profiles

- [ ] Minimal
- [ ] Admin Starter
- [ ] CRM
- [ ] ERP
- [ ] SaaS
- [ ] API Platform
- [ ] AI Application
- [ ] Custom

### Platform

- [ ] Windows CMD
- [ ] PowerShell
- [ ] Linux
- [ ] macOS

### DevOps

- [ ] Build
- [ ] Test
- [ ] Git
- [ ] SSH deployment
- [ ] Docker
- [ ] GitHub Actions
- [ ] Release packaging

---

# 27. Important Engineering Rule

Do not implement this as one enormous 2,000+ line shell script.

The goal is:

**Master CLI/Wizard → Feature Registry → Feature Modules → Profiles → Project Configuration → Build/Test/Deploy**

The architecture must be modular so new packages/features can be added later without rewriting the master installer.

Think of the system as a small **Laravel Application OS** rather than a simple installation script.

When finished, report:

```text
1. Architecture changes
2. New files
3. Modified files
4. Admin panels implemented
5. Features implemented
6. Profiles implemented
7. CLI commands
8. Cross-platform support
9. Tests executed
10. Known limitations
11. Recommended next steps
```

Do not stop at analysis. Implement the changes in the repository.