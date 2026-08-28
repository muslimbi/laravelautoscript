# Rebuild laravel-master-setup (BAT, PS1, SH) — Combined Feature Set

Rebuild the three `laravel-master-setup` scripts by merging unique features from **4 source files** into a single unified "master" script per format.

## Source Files & Feature Matrix

| Feature | master-setup (existing) | auto terminal script | build-and-deploy-fixed | laravel-git-setup |
|---|:---:|:---:|:---:|:---:|
| Interactive menu loop | ✅ | ❌ | ✅ | ❌ |
| New project setup | ✅ | ✅ | ✅ | ✅ |
| Quick build | ✅ | ❌ | ✅ | ❌ |
| **Existing project build** | ❌ | ❌ | ✅ | ❌ |
| **Local deploy (with `artisan serve`)** | ❌ | ❌ | ✅ | ❌ |
| Server deploy (SSH) | ✅ | ❌ | ✅ | ❌ |
| System check (prerequisites) | ✅ | ✅ | ✅ | ❌ |
| **PHP extensions check** | ❌ | ❌ | ✅ | ❌ |
| **Version info display** | ❌ | ❌ | ✅ | ❌ |
| Toggle options menu | ✅ | ❌ | ✅ | ❌ |
| Template selection (7 choices) | ✅ | 5 choices | ✅ | Hardcoded |
| DB selection (SQLite/MySQL/PG) | ✅ | 2 choices | ✅ | SQLite only |
| Spatie packages | ✅ | ✅ | ✅ | ✅ |
| Telescope + Debugbar | ✅ | ✅ | ✅ | ✅ (Debugbar only) |
| IDE Helper + Query Detector | ✅ | ✅ | ✅ | ✅ |
| **Clockwork** | ❌ | ❌ | ✅ | ❌ |
| **Laravel Sail** | ❌ | ❌ | ✅ | ❌ |
| **Laravel Horizon** | ❌ | ❌ | ✅ | ❌ |
| **Laravel Sanctum (standalone)** | ❌ | ❌ | ✅ | ❌ |
| **Laravel Socialite** | ❌ | ❌ | ✅ | ❌ |
| **Intervention Image** | ❌ | ❌ | ✅ | ❌ |
| CrestApps code generator | ✅ | ❌ | ❌ | ✅ |
| **Example resource generation (Department)** | ❌ | ✅ | ❌ | ✅ |
| **Gitignore IDE helpers** | ❌ | ✅ | ❌ | ❌ |
| **Post-deploy cache commands** | ❌ | ❌ | ✅ | ❌ |
| **Summary with URLs** | ❌ | ✅ | ✅ | ❌ |
| Phased progress (1/8, 2/8...) | ❌ | ❌ | ✅ | ❌ |
| Error handling per phase | ❌ | ❌ | ✅ | ❌ |
| **Artisan `optimize:clear` + cache rebuild** | ❌ | ❌ | ✅ | ❌ |
| **Prompt to deploy after build** | ❌ | ❌ | ✅ | ❌ |

## Proposed Changes

All three scripts will be rebuilt with the same unified feature set, adapted to each format's idioms.

### New Menu Structure (9 options)

```
[1]  New Project Setup       - Fresh Laravel install with all features
[2]  Existing Project Build  - Build & optimize an existing project     ← NEW
[3]  Quick Build             - Install deps & build assets
[4]  Local Deploy            - Deploy locally + start artisan serve     ← NEW
[5]  Server Deploy           - Remote SSH deployment
[6]  System Check            - Verify prerequisites + PHP extensions    ← ENHANCED
[7]  Toggle Options          - Customize install settings
[0]  Exit
```

### New Project Setup — Combined Phases (1/8 through 8/8)

1. **Git Init** — same as existing
2. **Database Config** — same (SQLite / MySQL / PostgreSQL)
3. **Auth Template** — same 7 choices
4. **Plugins** — Spatie Permission + ActivityLog + **Socialite + Intervention Image** (from build-and-deploy-fixed)
5. **Debugger** — Telescope + Debugbar + **Clockwork** (from build-and-deploy-fixed)
6. **DevTools** — IDE Helper + Query Detector + CrestApps + **Sail + Horizon + Sanctum** (from build-and-deploy-fixed)
7. **Example Scaffold** — **Department CRUD generation** (from auto terminal + laravel-git-setup)
8. **Frontend Build** — npm install + build
9. **Migrations** — if enabled
10. **Summary** — project info + **Telescope/Debugbar/Clockwork URLs** + git history summary

### Enhanced Gitignore

From auto terminal script — add IDE helper files to `.gitignore`:
```
_ide_helper.php
_ide_helper_models.php
.phpstorm.meta.php
```

### Enhanced System Check

From build-and-deploy-fixed — add PHP extensions check + version display for each tool.

### Existing Project Build (NEW option)

From build-and-deploy-fixed option 2:
- Validate `artisan` file exists
- `composer install`
- Migrations (if enabled)
- Clear all caches (`config:clear`, `cache:clear`, `route:clear`, `view:clear`, `optimize:clear`)
- Build frontend
- Rebuild caches (`config:cache`, `route:cache`, `view:cache`, `optimize`)
- Prompt to deploy

### Local Deploy (NEW option)

From build-and-deploy-fixed option 4:
- `composer install --no-dev`
- Migrate + seed
- Clear caches
- Build assets
- Cache configs
- Start `php artisan serve`

### Enhanced Server Deploy

From build-and-deploy-fixed — add `--optimize-autoloader` flag and display live URL after deploy.

### Files to Modify

#### [MODIFY] [laravel-master-setup.bat](file:///c:/laravel/laravel-master-setup.bat)
Complete rewrite incorporating all combined features.

#### [MODIFY] [laravel-master-setup.ps1](file:///c:/laravel/laravel-master-setup.ps1)
Complete rewrite incorporating all combined features.

#### [MODIFY] [laravel-master-setup.sh](file:///c:/laravel/laravel-master-setup.sh)
Complete rewrite incorporating all combined features.

## Open Questions

> [!IMPORTANT]
> **Toggle for Example Scaffolding?** The Department CRUD scaffold from auto terminal & laravel-git-setup is an opinionated demo feature. Should it be:
> - **A)** Always included in New Project Setup (as it was in the source scripts)
> - **B)** Controlled by a new toggle option `GENERATE_EXAMPLE=yes/no` (recommended — more flexible)

> [!NOTE]
> The existing `auto terminal script.bat`, `build-and-deploy-fixed.bat`, and `laravel-git-setup.bat` will **not** be deleted — only the `laravel-master-setup.*` files will be rebuilt.

## Verification Plan

### Manual Verification
- Review each script for correct syntax
- Verify menu navigation works in each format
- Compare feature coverage against the matrix above to ensure nothing was missed
