# Admin Panel System — LaravelAutoScript v2

LaravelAutoScript v2 includes a modular admin panel installer supporting popular frameworks.

## Supported Admin Panels

1. **Filament** (`filament/filament`)
   - Installation: `composer require filament/filament && php artisan filament:install --panels`
   - Scaffolding: Supports panel creation, admin user creation, resources, dashboards, widgets, and Spatie RBAC integration.

2. **Backpack** (`backpack/crud`)
   - Installation: `composer require backpack/crud && php artisan backpack:install`

3. **Orchid** (`orchid/platform`)
   - Installation: `composer require orchid/platform && php artisan orchid:install`

4. **MoonShine** (`moonshine/moonshine`)
   - Installation: `composer require moonshine/moonshine && php artisan moonshine:install`

5. **Laravel Nova** (Commercial)
   - Requires manual authentication configuration with commercial credentials. Handled gracefully without breaking the installer.

6. **None / Custom**
   - Skip automatic admin panel setup.
