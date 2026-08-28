# Architecture — LaravelAutoScript v2

LaravelAutoScript v2 is structured as a cross-platform **Laravel Application Platform Builder**.

## System Architecture

```text
LaravelAutoScript
│
├── master/                      # Execution entry points
│   ├── laravel-master-setup.bat # Windows CMD entry launcher
│   ├── laravel-master-setup.ps1 # PowerShell launcher
│   └── laravel-master-setup.sh  # Unix/Bash launcher
│
├── features/                    # Modular feature definitions & registry
│   ├── catalog.json             # Centralized feature catalog
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
├── profiles/                    # Predefined profile configurations
│   ├── admin-starter/
│   ├── saas/
│   ├── crm/
│   ├── erp/
│   ├── api-platform/
│   ├── ai-application/
│   └── minimal/
│
├── templates/                   # Code generation stubs & templates
├── scripts/                     # Platform execution engine (Node.js engine + shell scripts)
├── docs/                        # Architecture & usage documentation
└── .github/workflows/           # CI/CD pipelines
```

## Key Principles
1. **Cross-Platform**: Operates identically on Windows CMD, PowerShell, Linux, and macOS.
2. **Idempotency**: Detects existing package declarations, migrations, `.env` keys, and `.gitignore` entries to prevent duplicate configurations.
3. **Non-destructive**: Validates project paths and returns error exit codes rather than failing silently.
4. **Provider-Agnostic AI**: Configures AI foundation structures without exposing secrets or hardcoding specific vendors.
