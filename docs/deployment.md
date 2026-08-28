# Deployment Engine — LaravelAutoScript v2

LaravelAutoScript v2 supports multiple deployment strategies.

## Deployment Strategies
1. **Local Deployment**:
   ```bash
   laravelautoscript deploy --strategy local
   ```
   Runs composer `--no-dev`, migrations with seed, asset compile, config cache, and starts `php artisan serve`.

2. **SSH Production Deployment**:
   ```bash
   laravelautoscript deploy --strategy ssh --host user@server-ip --remote-path /var/www/html --maintenance
   ```
   Performs git pull, production composer install, migrations, asset build, cache optimization, and optional zero-downtime maintenance toggle (`php artisan down` / `php artisan up`).

3. **Docker Deployment**:
   Integrates with Laravel Sail / Docker containers.

4. **GitHub Actions**:
   Automated deployment workflows via `.github/workflows/deploy.yml`.
