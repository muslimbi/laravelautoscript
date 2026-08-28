# Application Profiles — LaravelAutoScript v2

LaravelAutoScript v2 provides predefined application profiles for instant multi-package stack setup.

## Available Profiles

1. **minimal**: Fresh Laravel application without extra packages.
2. **admin-starter**: Filament + Spatie RBAC + Activity Log + Media + Pulse + Pest + Pint.
3. **crm**: Filament + RBAC + Activity Log + Media + Scout Search + Notifications + Horizon queues.
4. **erp**: Filament + RBAC + Audit + Media + Search + Horizon + Reverb + Reports + Notifications.
5. **saas**: React/Inertia + Filament + RBAC + Activity Log + Media + Sanctum API + Horizon + Reverb + Scout + Billing + Pulse.
6. **api-platform**: Sanctum API + Spatie RBAC + Activity Log + Horizon queues.
7. **ai-application**: Filament + RBAC + Activity Log + Laravel AI SDK + Horizon + Scout + Monitoring.

## Custom Profiles
Create a custom profile by placing a YAML file at `profiles/my-profile/profile.yaml`:

```yaml
name: my-profile
description: My custom application profile
starter_kit: react
admin_panel: filament
features:
  - permission
  - activitylog
  - horizon
developer:
  - pest
  - pint
```

Apply via CLI:
```bash
laravelautoscript profile my-profile --project ./my-app
```
