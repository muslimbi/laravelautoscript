# Testing & Quality Gate — LaravelAutoScript v2

LaravelAutoScript v2 includes an automated testing and code quality pipeline.

## Pipeline Steps
1. Composer syntax & dependency validation (`composer validate`)
2. Code style checking (`vendor/bin/pint --test`)
3. Static analysis (`vendor/bin/phpstan analyse`)
4. Automated unit/feature tests (`php artisan test` or `vendor/bin/pest`)
5. Frontend linting (`npm run lint`)
6. Frontend build validation (`npm run build`)

## CLI Execution
```bash
laravelautoscript test --project ./my-app
# Strict mode (stops pipeline immediately on any failure)
laravelautoscript test --strict --project ./my-app
```
