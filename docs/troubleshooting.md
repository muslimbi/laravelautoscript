# Troubleshooting — LaravelAutoScript v2

## Common Issues & Resolutions

### 1. PHP or Composer missing from PATH
Ensure PHP 8.2+ and Composer are installed and added to system environment PATH. Run `laravelautoscript system` to verify.

### 2. Node.js / NPM unavailable
Node.js is required for asset compilation (`npm run build`) and for running the cross-platform platform engine. Install Node.js v18+.

### 3. Database connection failure
Verify your credentials in `.env`. Ensure MySQL or PostgreSQL server is running. Use SQLite for zero-config local development.

### 4. Admin Panel package conflicts
Avoid installing multiple admin panels (e.g. Filament + Backpack) in the same project to prevent route, asset, and middleware collisions.

### 5. Deployment SSH Authentication Failure
Ensure your SSH key is added to the remote server's `authorized_keys` file before executing SSH deployments.
