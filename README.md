# Laravel AutoScript

Cross-platform, interactive automation for creating, building, and deploying Laravel applications. The repository provides equivalent master setup scripts for Windows Command Prompt, PowerShell, and Linux/macOS shells, plus GitHub Actions workflows for validation, testing, deployment, and release packaging.

## What it does

The master setup scripts provide a menu-driven workflow for:

- creating a new Laravel project with Git initialization;
- configuring SQLite, MySQL, or PostgreSQL;
- installing an authentication stack: standard Laravel, Breeze (Blade, Vue SSR, or React SSR), Jetstream, API-only, or none;
- optionally installing packages, debugging tools, developer tools, frontend assets, migrations, and an example `Department` CRUD scaffold;
- building and optimizing an existing Laravel project;
- running a quick build or local deployment;
- committing, pushing, and deploying to a remote server over SSH; and
- checking required tools, PHP extensions, and version information.

## Requirements

- PHP and Composer
- Git
- Node.js and npm for frontend asset builds
- An SSH client and a configured Git remote for server deployment

The system check also looks for PHP support for `pdo`, `json`, `mbstring`, `xml`, `gd`, and `curl`.

## Run a master setup script

Run the version for your operating system from this repository directory:

```powershell
# Windows PowerShell
.\laravel-master-setup.ps1
```

```bat
:: Windows Command Prompt
laravel-master-setup.bat
```

```bash
# Linux or macOS
chmod +x laravel-master-setup.sh
./laravel-master-setup.sh
```

The menu offers these actions:

| Option | Action |
| --- | --- |
| 1 | Create and configure a new Laravel project |
| 2 | Build and optimize an existing Laravel project |
| 3 | Install dependencies and build assets |
| 4 | Perform a local deployment and start `php artisan serve` |
| 5 | Push and deploy to a remote server over SSH |
| 6 | Check prerequisites, PHP extensions, and versions |
| 7 | Toggle optional installation and build steps |

## New-project options

By default, the scripts can install the following components. Use **Toggle Options** before starting a new project to disable any you do not want.

- Packages: Spatie Permission, Spatie Activitylog, Laravel Socialite, and Intervention Image
- Debugging: Laravel Telescope, Debugbar, and Clockwork
- Development tools: Laravel IDE Helper, Query Detector, CrestApps Code Generator, Sail, Horizon, and Sanctum
- Example scaffold: a `Department` resource with model, migration, and CRUD resources
- Database migrations and an npm production build

The scripts add IDE-helper files to the generated project's `.gitignore` and create Git commits at major setup stages.

## Deployment notes

The **Existing Project Build** workflow installs Composer dependencies, optionally migrates the database, clears and rebuilds Laravel caches, and builds frontend assets.

The **Local Deploy** workflow uses production Composer dependencies, runs migrations with seeders, builds assets, caches configuration/routes/views, and starts Laravel's local server.

The **Server Deploy** workflow stages and commits local changes, pushes the selected branch, and executes a remote SSH command. Before using it, confirm the target host, remote path, branch, repository access, environment file, database credentials, and server permissions. Review the command shown in the relevant script for your deployment requirements.

## CI/CD

GitHub Actions workflows are stored in [`.github/workflows`](.github/workflows):

- `ci-cd.yml` runs ShellCheck against the Bash script, conditionally builds/tests a Laravel project when `composer.json` and `package.json` are present, deploys the main branch through SSH secrets, and packages release artifacts.
- `laravel.yml` runs a Laravel-oriented test workflow on pushes and pull requests to `main`.

For the automated deployment workflow, configure these repository secrets as appropriate: `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY`, `SSH_PASSPHRASE`, and `REMOTE_PATH`.

## Repository layout

```text
laravel-master-setup.bat   Windows Command Prompt master script
laravel-master-setup.ps1   Windows PowerShell master script
laravel-master-setup.sh    Linux/macOS Bash master script
build-and-deploy-fixed.bat Earlier Windows build/deploy helper
auto terminal script.bat   Earlier Windows project setup helper
laravel-git-setup.bat      Earlier Git-focused setup helper
.github/workflows/         GitHub Actions workflows
```

## Security

Do not commit `.env` files, private keys, or deployment credentials. Treat remote deployment as a production-impacting action and validate server configuration before running it. See [SECURITY.md](SECURITY.md) for the repository security policy.

## Contributing and license

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidance. This project is licensed under the [MIT License](LICENSE).
