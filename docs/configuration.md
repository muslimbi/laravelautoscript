# Project Configuration — LaravelAutoScript v2

LaravelAutoScript v2 generates a project configuration file in the root of every managed Laravel app: `.laravelautoscript.yml`.

## Example Configuration

```yaml
version: 2
laravel:
  version: latest
starter_kit: react
database:
  driver: mysql
  host: 127.0.0.1
  port: 3306
  database: my_app
  username: root
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

This configuration enables idempotent re-runs of build, test, and deploy operations.
