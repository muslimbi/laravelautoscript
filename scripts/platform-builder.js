#!/usr/bin/env node
/**
 * LaravelAutoScript v2 — Cross-Platform Laravel Application Platform Builder
 * 
 * Central engine providing interactive wizard, CLI subcommands, profile management,
 * feature marketplace, admin installers, AI platform configuration, quality gate,
 * and deployment orchestration.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const readline = require('readline');

const ROOT_DIR = path.resolve(__dirname, '..');
const CATALOG_PATH = path.join(ROOT_DIR, 'features', 'catalog.json');
const CATALOG = fs.existsSync(CATALOG_PATH)
    ? JSON.parse(fs.readFileSync(CATALOG_PATH, 'utf8'))
    : { features: {}, adminPanels: {}, starterKits: {}, databases: {}, authOptions: {}, profiles: {} };

const ARGS = process.argv.slice(2);
const IS_NON_INTERACTIVE = ARGS.includes('--yes') || ARGS.includes('--non-interactive');
const IS_DRY_RUN = ARGS.includes('--dry-run');

function out(msg = '') {
    console.log(msg);
}

function success(msg) {
    console.log(`[OK] ${msg}`);
}

function warn(msg) {
    console.warn(`[WARN] ${msg}`);
}

function error(msg) {
    console.error(`[ERROR] ${msg}`);
}

function info(msg) {
    console.log(`[INFO] ${msg}`);
}

function getArgValue(key, fallback = null) {
    const idx = ARGS.indexOf(`--${key}`);
    if (idx >= 0 && ARGS[idx + 1] && !ARGS[idx + 1].startsWith('--')) {
        return ARGS[idx + 1];
    }
    return fallback;
}

function shellQuote(str) {
    return `'${String(str).replace(/'/g, "'\\''")}'`;
}

function runCmd(bin, argv = [], cwd = process.cwd()) {
    const display = `${bin} ${argv.join(' ')}`;
    out(`$ ${display}`);
    if (IS_DRY_RUN) return true;

    const result = cp.spawnSync(bin, argv, {
        cwd,
        stdio: 'inherit',
        shell: process.platform === 'win32'
    });

    if (result.error || result.status !== 0) {
        error(`Command failed: ${display} (exit ${result.status !== null ? result.status : 'error'})`);
        return false;
    }
    return true;
}

function isAvailable(bin) {
    const res = cp.spawnSync(bin, ['--version'], {
        stdio: 'ignore',
        shell: process.platform === 'win32'
    });
    return res.status === 0;
}

function getProjectDir() {
    const p = getArgValue('project', process.cwd());
    return path.resolve(p);
}

function isLaravelApp(dir = getProjectDir()) {
    return fs.existsSync(path.join(dir, 'artisan')) && fs.existsSync(path.join(dir, 'composer.json'));
}

function readComposerJson(dir = getProjectDir()) {
    try {
        const file = path.join(dir, 'composer.json');
        return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : {};
    } catch {
        return {};
    }
}

function isPackageInstalled(pkgName, dir = getProjectDir()) {
    const composer = readComposerJson(dir);
    const req = composer.require || {};
    const reqDev = composer['require-dev'] || {};
    return Boolean(req[pkgName] || reqDev[pkgName]);
}

function parseYamlLike(text) {
    const res = {};
    let currentKey = null;
    const lines = text.split(/\r?\n/);

    for (const raw of lines) {
        const line = raw.replace(/#.*/, '');
        if (!line.trim()) continue;

        const keyValMatch = line.match(/^(\s*)([\w-]+):\s*(.*)$/);
        if (keyValMatch) {
            const indent = keyValMatch[1].length;
            const key = keyValMatch[2];
            const val = keyValMatch[3].trim();

            if (indent === 0) {
                if (val) {
                    res[key] = parseScalar(val);
                    currentKey = null;
                } else {
                    currentKey = key;
                    res[currentKey] = res[currentKey] || {};
                }
            } else if (currentKey) {
                if (typeof res[currentKey] === 'object' && !Array.isArray(res[currentKey])) {
                    res[currentKey][key] = parseScalar(val);
                }
            }
        } else {
            const listMatch = line.match(/^\s*-\s*(.+)$/);
            if (listMatch && currentKey) {
                if (!Array.isArray(res[currentKey])) {
                    res[currentKey] = [];
                }
                res[currentKey].push(parseScalar(listMatch[1].trim()));
            }
        }
    }
    return res;
}

function parseScalar(val) {
    if (val === 'true') return true;
    if (val === 'false') return false;
    if (!isNaN(val) && val.trim() !== '') return Number(val);
    if (val.startsWith('[') && val.endsWith(']')) {
        return val.slice(1, -1).split(',').map(s => s.trim().replace(/^['"]|['"]$/g, '')).filter(Boolean);
    }
    return val.replace(/^['"]|['"]$/g, '');
}

function dumpYamlLike(obj, level = 0) {
    let str = '';
    const indent = ' '.repeat(level);

    for (const [key, val] of Object.entries(obj)) {
        if (val === undefined || val === null) continue;
        if (Array.isArray(val)) {
            if (val.length === 0) {
                str += `${indent}${key}: []\n`;
            } else {
                str += `${indent}${key}:\n`;
                for (const item of val) {
                    str += `${indent}  - ${item}\n`;
                }
            }
        } else if (typeof val === 'object') {
            str += `${indent}${key}:\n${dumpYamlLike(val, level + 2)}`;
        } else {
            str += `${indent}${key}: ${val}\n`;
        }
    }
    return str;
}

function saveProjectConfig(dir = getProjectDir(), patch = {}) {
    const configFile = path.join(dir, '.laravelautoscript.yml');
    let existing = {};
    if (fs.existsSync(configFile)) {
        existing = parseYamlLike(fs.readFileSync(configFile, 'utf8'));
    }
    const merged = { version: 2, ...existing, ...patch };
    fs.writeFileSync(configFile, dumpYamlLike(merged));
    success(`Updated ${configFile}`);
}

function promptChoiceSync(questionText, options) {
    out(`\n${questionText}`);
    options.forEach(([key, label]) => out(`  [${key}] ${label}`));

    if (IS_NON_INTERACTIVE) {
        const defaultOption = options[0] ? options[0][0] : '1';
        info(`Non-interactive mode: selecting default [${defaultOption}]`);
        return defaultOption;
    }

    const fd = fs.openSync(process.platform === 'win32' ? '\\\\.\\pipe\\conin$' : '/dev/tty', 'r');
    let input = '';
    const buf = Buffer.alloc(1024);

    while (!input.includes('\n') && !input.includes('\r')) {
        const bytesRead = fs.readSync(fd, buf, 0, buf.length, null);
        if (bytesRead > 0) {
            input += buf.toString('utf8', 0, bytesRead);
        }
    }
    fs.closeSync(fd);

    const selected = input.trim();
    const valid = options.some(opt => opt[0] === selected);
    return valid ? selected : options[0][0];
}

function promptInputSync(questionText, defaultVal = '') {
    out(`\n${questionText}${defaultVal ? ` [${defaultVal}]` : ''}: `);
    if (IS_NON_INTERACTIVE) {
        info(`Non-interactive mode: using default '${defaultVal}'`);
        return defaultVal;
    }

    const fd = fs.openSync(process.platform === 'win32' ? '\\\\.\\pipe\\conin$' : '/dev/tty', 'r');
    let input = '';
    const buf = Buffer.alloc(1024);

    while (!input.includes('\n') && !input.includes('\r')) {
        const bytesRead = fs.readSync(fd, buf, 0, buf.length, null);
        if (bytesRead > 0) {
            input += buf.toString('utf8', 0, bytesRead);
        }
    }
    fs.closeSync(fd);

    const res = input.trim();
    return res || defaultVal;
}

// ============================================================================
// CORE WORKFLOW HANDLERS
// ============================================================================

function cmdCreate() {
    out('\n============================================================');
    out('  1. Create New Laravel Application');
    out('============================================================');

    const name = getArgValue('name') || promptInputSync('Enter application name', 'laravel-app');
    const targetDir = path.resolve(process.cwd(), name);

    if (fs.existsSync(targetDir)) {
        error(`Directory '${name}' already exists at ${targetDir}`);
        return false;
    }

    const laravelVersion = getArgValue('laravel') || promptChoiceSync('Select Laravel Version:', [
        ['latest', 'Latest stable'],
        ['13', 'Laravel 13'],
        ['12', 'Laravel 12'],
        ['custom', 'Custom version']
    ]);

    const starterKit = getArgValue('starter') || promptChoiceSync('Select Starter Kit:', [
        ['minimal', 'Minimal / Blade'],
        ['react', 'React (Inertia)'],
        ['vue', 'Vue (Inertia)'],
        ['svelte', 'Svelte'],
        ['livewire', 'Livewire']
    ]);

    const dbDriver = getArgValue('database') || promptChoiceSync('Select Database Driver:', [
        ['sqlite', 'SQLite (Zero Config)'],
        ['mysql', 'MySQL'],
        ['pgsql', 'PostgreSQL'],
        ['mariadb', 'MariaDB']
    ]);

    info(`Creating Laravel application '${name}'...`);
    const pkgSpec = laravelVersion === 'latest' ? 'laravel/laravel' : `laravel/laravel:^${laravelVersion}`;
    if (!runCmd('composer', ['create-project', '--prefer-dist', pkgSpec, name])) {
        error('Failed to create Laravel project via Composer.');
        return false;
    }

    if (!runCmd('git', ['init', '-b', 'main'], targetDir)) {
        warn('Git init failed or git not available.');
    }

    // Enhanced .gitignore entries
    const gitignoreFile = path.join(targetDir, '.gitignore');
    if (fs.existsSync(gitignoreFile)) {
        fs.appendFileSync(gitignoreFile, '\n# IDE Helpers\n.phpstackbin\n_ide_helper.php\n_ide_helper_models.php\n.phpstorm.meta.php\n');
    }

    // Database setup
    cmdConfigure(targetDir, { driver: dbDriver });

    saveProjectConfig(targetDir, {
        laravel: { version: laravelVersion },
        starter_kit: starterKit,
        database: { driver: dbDriver }
    });

    success(`Laravel application created successfully at ${targetDir}`);
    return true;
}

function cmdConfigure(targetDir = getProjectDir(), overrideDb = {}) {
    out('\n============================================================');
    out('  2. Configure Existing Laravel Application');
    out('============================================================');

    if (!isLaravelApp(targetDir)) {
        error(`No valid Laravel project found at ${targetDir}`);
        return false;
    }

    const driver = overrideDb.driver || getArgValue('driver') || promptChoiceSync('Select Database Connection:', [
        ['sqlite', 'SQLite'],
        ['mysql', 'MySQL'],
        ['pgsql', 'PostgreSQL'],
        ['mariadb', 'MariaDB']
    ]);

    const envFile = path.join(targetDir, '.env');
    if (!fs.existsSync(envFile)) {
        const envExample = path.join(targetDir, '.env.example');
        if (fs.existsSync(envExample)) {
            fs.copyFileSync(envExample, envFile);
            runCmd('php', ['artisan', 'key:generate'], targetDir);
        }
    }

    let dbHost = '127.0.0.1';
    let dbPort = driver === 'pgsql' ? '5432' : '3306';
    let dbName = 'laravel';
    let dbUser = driver === 'pgsql' ? 'postgres' : 'root';

    if (driver === 'sqlite') {
        const sqlitePath = path.join(targetDir, 'database', 'database.sqlite');
        if (!fs.existsSync(sqlitePath)) {
            fs.mkdirSync(path.dirname(sqlitePath), { recursive: true });
            fs.writeFileSync(sqlitePath, '');
        }
        dbName = sqlitePath;
        if (fs.existsSync(path.join(targetDir, '.gitignore'))) {
            fs.appendFileSync(path.join(targetDir, '.gitignore'), '\n/database/database.sqlite\n');
        }
    } else {
        dbName = getArgValue('database') || promptInputSync('Database name', 'laravel');
        dbUser = getArgValue('username') || promptInputSync('Database user', dbUser);
    }

    if (fs.existsSync(envFile)) {
        let text = fs.readFileSync(envFile, 'utf8');
        const replacements = {
            DB_CONNECTION: driver,
            DB_HOST: dbHost,
            DB_PORT: dbPort,
            DB_DATABASE: dbName,
            DB_USERNAME: dbUser
        };

        for (const [key, val] of Object.entries(replacements)) {
            const regex = new RegExp(`^${key}=.*$`, 'm');
            text = regex.test(text) ? text.replace(regex, `${key}=${val}`) : `${text.trimEnd()}\n${key}=${val}\n`;
        }
        fs.writeFileSync(envFile, text);
        success('Database configuration updated in .env securely (passwords unprinted).');
    }

    saveProjectConfig(targetDir, {
        database: { driver, host: dbHost, port: dbPort, database: dbName, username: dbUser }
    });

    if (ARGS.includes('--migrate') || promptChoiceSync('Run migrations now?', [['yes', 'Yes'], ['no', 'No']]) === 'yes') {
        runCmd('php', ['artisan', 'migrate', '--force'], targetDir);
    }

    return true;
}

function cmdProfile(profileName = ARGS[1]) {
    out('\n============================================================');
    out('  3. Application Profiles');
    out('============================================================');

    const selectedProfile = profileName || promptChoiceSync('Select Application Profile:', [
        ['saas', 'SaaS Platform (React, Filament, RBAC, Billing, API, Realtime)'],
        ['admin-starter', 'Admin Starter (Filament, RBAC, ActivityLog, Media, Pulse)'],
        ['crm', 'CRM Application (Filament, RBAC, ActivityLog, Media, Search, Notifications)'],
        ['erp', 'ERP Application (Filament, RBAC, Audit, Search, Queues, Reports)'],
        ['api-platform', 'API Platform (Sanctum API, RBAC, Horizon)'],
        ['ai-application', 'AI Application (Filament, RBAC, AI SDK, Horizon, Scout)'],
        ['minimal', 'Minimal Laravel']
    ]);

    const profileFile = path.join(ROOT_DIR, 'profiles', selectedProfile, 'profile.yaml');
    if (!fs.existsSync(profileFile)) {
        error(`Profile '${selectedProfile}' not found at ${profileFile}`);
        return false;
    }

    const profileData = parseYamlLike(fs.readFileSync(profileFile, 'utf8'));
    const targetDir = getProjectDir();

    if (!isLaravelApp(targetDir)) {
        error(`No Laravel application found at ${targetDir}`);
        return false;
    }

    info(`Applying profile '${profileData.name || selectedProfile}'...`);

    if (profileData.admin_panel && profileData.admin_panel !== 'none') {
        cmdAdmin(profileData.admin_panel, targetDir);
    }

    const features = profileData.features || [];
    for (const featureId of features) {
        cmdInstallFeature(featureId, targetDir);
    }

    const devTools = profileData.developer || [];
    for (const devId of devTools) {
        cmdInstallFeature(devId, targetDir);
    }

    saveProjectConfig(targetDir, {
        profile: selectedProfile,
        starter_kit: profileData.starter_kit || 'minimal',
        features,
        developer: devTools
    });

    success(`Applied profile '${selectedProfile}' successfully!`);
    return true;
}

function cmdAdmin(adminId = ARGS[1], targetDir = getProjectDir()) {
    out('\n============================================================');
    out('  4. Admin Panel Setup');
    out('============================================================');

    const selected = adminId || promptChoiceSync('Select Admin Panel Framework:', [
        ['filament', 'Filament (Modern Livewire Admin)'],
        ['backpack', 'Backpack (CRUD Framework)'],
        ['orchid', 'Orchid (Back-office Platform)'],
        ['moonshine', 'MoonShine (Tailwind & Blade)'],
        ['nova', 'Laravel Nova (Commercial / Manual)'],
        ['custom', 'Custom / Manual'],
        ['none', 'None']
    ]);

    if (selected === 'none' || selected === 'custom') {
        info(`Admin panel choice set to '${selected}'.`);
        saveProjectConfig(targetDir, { admin: { panel: selected } });
        return true;
    }

    if (selected === 'nova') {
        warn('Laravel Nova is a commercial package requiring license credentials in auth.json.');
        info('Configure composer repository and run `composer require laravel/nova` manually.');
        saveProjectConfig(targetDir, { admin: { panel: 'nova' } });
        return true;
    }

    const panelInfo = CATALOG.adminPanels[selected];
    if (!panelInfo) {
        error(`Unknown admin panel '${selected}'`);
        return false;
    }

    if (!isLaravelApp(targetDir)) {
        error(`No Laravel application found at ${targetDir}`);
        return false;
    }

    // Warning check for multiple admin panels
    const composer = readComposerJson(targetDir);
    const installedAdmins = Object.keys(CATALOG.adminPanels).filter(k =>
        CATALOG.adminPanels[k].package && isPackageInstalled(CATALOG.adminPanels[k].package, targetDir)
    );

    if (installedAdmins.length > 0 && !installedAdmins.includes(selected)) {
        warn(`Existing admin panel (${installedAdmins.join(', ')}) detected! Installing multiple admin panels may cause route/asset conflicts.`);
    }

    info(`Installing ${panelInfo.name || selected}...`);
    if (panelInfo.package && !isPackageInstalled(panelInfo.package, targetDir)) {
        if (!runCmd('composer', ['require', panelInfo.package], targetDir)) {
            error(`Failed to install ${panelInfo.package}`);
            return false;
        }
    } else {
        info(`[SKIP] ${panelInfo.package} is already installed.`);
    }

    if (panelInfo.artisan) {
        runCmd('php', ['artisan', ...panelInfo.artisan.split(' ')], targetDir);
    }

    saveProjectConfig(targetDir, { admin: { panel: selected } });
    success(`${panelInfo.name || selected} admin panel setup complete!`);
    return true;
}

function cmdInstallFeature(featureId = ARGS[1], targetDir = getProjectDir()) {
    if (!featureId) {
        out('\n============================================================');
        out('  8. Application Feature Marketplace');
        out('============================================================');
        featureId = promptChoiceSync('Select Feature to Install:', [
            ['permission', 'RBAC / Permissions (Spatie)'],
            ['activitylog', 'Activity / Audit Log (Spatie)'],
            ['media', 'Media Management (Spatie)'],
            ['api', 'API Platform (Sanctum)'],
            ['horizon', 'Queue / Horizon Dashboard'],
            ['reverb', 'Realtime WebSockets (Reverb)'],
            ['scout', 'Search Engine (Scout)'],
            ['billing', 'Billing (Cashier)'],
            ['monitoring', 'Monitoring (Pulse)'],
            ['pest', 'Pest Testing'],
            ['pint', 'Laravel Pint'],
            ['larastan', 'Larastan Static Analysis'],
            ['ide-helper', 'IDE Helper']
        ]);
    }

    const feat = CATALOG.features[featureId];
    if (!feat) {
        error(`Unknown feature '${featureId}'`);
        return false;
    }

    if (!isLaravelApp(targetDir)) {
        error(`No Laravel app found at ${targetDir}`);
        return false;
    }

    info(`Installing feature '${feat.name}'...`);

    if (feat.package) {
        if (isPackageInstalled(feat.package, targetDir)) {
            info(`[SKIP] Package '${feat.package}' is already installed.`);
        } else {
            const composerArgs = ['require', feat.package];
            if (feat.dev) composerArgs.push('--dev');
            if (!runCmd('composer', composerArgs, targetDir)) {
                error(`Failed composer require for ${feat.package}`);
                return false;
            }
        }
    }

    if (feat.artisan) {
        runCmd('php', ['artisan', ...feat.artisan.split(' ')], targetDir);
    }

    if (feat.publish) {
        const pubArgs = ['artisan', 'vendor:publish', `--provider=${feat.publish}`, '--force'];
        if (feat.publishTag) pubArgs.push(`--tag=${feat.publishTag}`);
        runCmd('php', pubArgs, targetDir);
    }

    success(`Feature '${feat.name}' configured.`);
    return true;
}

function cmdAi() {
    out('\n============================================================');
    out('  9. AI Features & Platform Configuration');
    out('============================================================');

    const sub = ARGS[1] || promptChoiceSync('Select AI Capability:', [
        ['sdk', 'Laravel AI SDK Foundation'],
        ['agent', 'AI Agent Foundation'],
        ['tools', 'AI Tools & Function Calling'],
        ['embeddings', 'Embeddings Support'],
        ['vector', 'Vector Search Engine'],
        ['rag', 'RAG (Retrieval-Augmented Generation)'],
        ['queue', 'AI Async Job Processing'],
        ['config', 'Configure AI Credentials'],
        ['profile', 'Apply AI Application Profile']
    ]);

    const targetDir = getProjectDir();

    if (sub === 'profile') {
        return cmdProfile('ai-application');
    }

    const provider = getArgValue('provider') || promptInputSync('AI Provider (e.g. openai, anthropic, ollama)', 'openai');
    const model = getArgValue('model') || promptInputSync('Default Model', 'gpt-4o');
    const embeddingModel = getArgValue('embedding-model') || promptInputSync('Embedding Model', 'text-embedding-3-small');
    const vectorStore = getArgValue('vector-store') || promptInputSync('Vector Store', 'pgvector');

    if (isLaravelApp(targetDir)) {
        const envFile = path.join(targetDir, '.env');
        if (fs.existsSync(envFile)) {
            let text = fs.readFileSync(envFile, 'utf8');
            const aiVars = {
                AI_PROVIDER: provider,
                AI_MODEL: model,
                EMBEDDING_MODEL: embeddingModel,
                VECTOR_STORE: vectorStore
            };
            for (const [k, v] of Object.entries(aiVars)) {
                const regex = new RegExp(`^${k}=.*$`, 'm');
                text = regex.test(text) ? text.replace(regex, `${k}=${v}`) : `${text.trimEnd()}\n${k}=${v}\n`;
            }
            fs.writeFileSync(envFile, text);
            success('AI environment configuration updated securely (API keys unprinted).');
        }
    }

    cmdInstallFeature('ai-sdk', targetDir);
    saveProjectConfig(targetDir, {
        ai: { provider, model, embedding_model: embeddingModel, vector_store: vectorStore }
    });
    return true;
}

function cmdScaffold(moduleType = ARGS[1]) {
    out('\n============================================================');
    out('  Domain & Feature Module Scaffolder');
    out('============================================================');

    const selectedModule = moduleType || promptChoiceSync('Select Domain Module to Scaffold:', [
        ['user-permissions', 'User & Roles / Permissions Module (Spatie RBAC + User Scaffolding)'],
        ['products-categories', 'Products & Categories Module (Catalog, SKUs, Pricing, Stock)'],
        ['employees', 'Employees & Departments Module (HR Directory, Positions, Salaries)'],
        ['orders', 'Orders & Order Items Module (E-commerce Order Management)'],
        ['customers', 'Customer Management Module (CRM Contacts & Accounts)'],
        ['custom', 'Custom Model / CRUD Resource Generator']
    ]);

    const targetDir = getProjectDir();
    if (!isLaravelApp(targetDir)) {
        error(`No valid Laravel application found at ${targetDir}`);
        return false;
    }

    if (selectedModule === 'custom') {
        return cmdCrud();
    }

    info(`Scaffolding domain module '${selectedModule}'...`);

    if (selectedModule === 'user-permissions') {
        cmdInstallFeature('permission', targetDir);
        runCmd('php', ['artisan', 'make:model', 'Role', '-m'], targetDir);
        runCmd('php', ['artisan', 'make:model', 'Permission', '-m'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'UserController', '--resource', '--requests'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'RoleController', '--resource', '--requests'], targetDir);
        if (isPackageInstalled('filament/filament', targetDir)) {
            runCmd('php', ['artisan', 'make:filament-resource', 'User', '--generate'], targetDir);
        }
        success('User & Roles / Permissions domain module scaffolded.');
        return true;
    }

    if (selectedModule === 'products-categories') {
        info('Scaffolding Category model and stack...');
        runCmd('php', ['artisan', 'make:model', 'Category', '-mf'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'CategoryController', '--resource', '--requests'], targetDir);

        info('Scaffolding Product model and stack...');
        runCmd('php', ['artisan', 'make:model', 'Product', '-mf'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'ProductController', '--resource', '--requests'], targetDir);

        if (isPackageInstalled('filament/filament', targetDir)) {
            runCmd('php', ['artisan', 'make:filament-resource', 'Category', '--generate'], targetDir);
            runCmd('php', ['artisan', 'make:filament-resource', 'Product', '--generate'], targetDir);
        }
        success('Products & Categories domain module scaffolded.');
        return true;
    }

    if (selectedModule === 'employees') {
        info('Scaffolding Department model and stack...');
        runCmd('php', ['artisan', 'make:model', 'Department', '-mf'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'DepartmentController', '--resource', '--requests'], targetDir);

        info('Scaffolding Employee model and stack...');
        runCmd('php', ['artisan', 'make:model', 'Employee', '-mf'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'EmployeeController', '--resource', '--requests'], targetDir);

        if (isPackageInstalled('filament/filament', targetDir)) {
            runCmd('php', ['artisan', 'make:filament-resource', 'Department', '--generate'], targetDir);
            runCmd('php', ['artisan', 'make:filament-resource', 'Employee', '--generate'], targetDir);
        }
        success('Employees & Departments domain module scaffolded.');
        return true;
    }

    if (selectedModule === 'orders') {
        info('Scaffolding Order model and stack...');
        runCmd('php', ['artisan', 'make:model', 'Order', '-mf'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'OrderController', '--resource', '--requests'], targetDir);

        info('Scaffolding OrderItem model and stack...');
        runCmd('php', ['artisan', 'make:model', 'OrderItem', '-mf'], targetDir);

        if (isPackageInstalled('filament/filament', targetDir)) {
            runCmd('php', ['artisan', 'make:filament-resource', 'Order', '--generate'], targetDir);
        }
        success('Orders & Order Items domain module scaffolded.');
        return true;
    }

    if (selectedModule === 'customers') {
        info('Scaffolding Customer model and stack...');
        runCmd('php', ['artisan', 'make:model', 'Customer', '-mf'], targetDir);
        runCmd('php', ['artisan', 'make:controller', 'CustomerController', '--resource', '--requests'], targetDir);

        if (isPackageInstalled('filament/filament', targetDir)) {
            runCmd('php', ['artisan', 'make:filament-resource', 'Customer', '--generate'], targetDir);
        }
        success('Customer Management domain module scaffolded.');
        return true;
    }

    error(`Unknown domain module '${selectedModule}'`);
    return false;
}

function cmdCrud() {
    out('\n============================================================');
    out('  13. Generic CRUD Generator');
    out('============================================================');

    const name = getArgValue('name') || promptInputSync('Resource Model Name', 'Product');
    const fields = getArgValue('fields') || promptInputSync('Fields (name:type format)', 'name:string,price:decimal,is_active:boolean');
    const targetDir = getProjectDir();

    if (!isLaravelApp(targetDir)) {
        error(`No Laravel application found at ${targetDir}`);
        return false;
    }

    info(`Generating model, migration, factory, controller, requests for '${name}'...`);
    runCmd('php', ['artisan', 'make:model', name, '-mf'], targetDir);
    runCmd('php', ['artisan', 'make:controller', `${name}Controller`, '--resource', '--requests'], targetDir);

    // Generate Filament resource if Filament is selected
    const composer = readComposerJson(targetDir);
    if (isPackageInstalled('filament/filament', targetDir)) {
        info('Filament detected: generating Filament Resource...');
        runCmd('php', ['artisan', 'make:filament-resource', name, '--generate'], targetDir);
    }

    success(`CRUD scaffolding generated for '${name}'. Fields: ${fields}`);
    return true;
}

function cmdBuild() {
    out('\n============================================================');
    out('  11. Build & Optimize Pipeline');
    out('============================================================');

    const targetDir = getProjectDir();
    if (!isLaravelApp(targetDir)) {
        error(`No Laravel project found at ${targetDir}`);
        return false;
    }

    const mode = getArgValue('mode') || promptChoiceSync('Select Build Mode:', [
        ['development', 'Development Build'],
        ['staging', 'Staging Build'],
        ['production', 'Production Build']
    ]);

    info(`Executing build sequence in ${mode} mode...`);

    if (!runCmd('composer', ['install', '--prefer-dist', ...(mode === 'production' ? ['--no-dev', '--optimize-autoloader'] : [])], targetDir)) {
        return false;
    }

    if (isAvailable('npm')) {
        runCmd('npm', ['ci'], targetDir) || runCmd('npm', ['install'], targetDir);
        runCmd('npm', ['run', 'build'], targetDir);
    }

    runCmd('php', ['artisan', 'migrate', '--force'], targetDir);
    runCmd('php', ['artisan', 'storage:link'], targetDir);
    runCmd('php', ['artisan', 'optimize:clear'], targetDir);

    if (mode === 'production' || mode === 'staging') {
        runCmd('php', ['artisan', 'config:cache'], targetDir);
        runCmd('php', ['artisan', 'route:cache'], targetDir);
        runCmd('php', ['artisan', 'view:cache'], targetDir);
        runCmd('php', ['artisan', 'optimize'], targetDir);
    }

    success(`Build complete for ${mode} mode!`);
    return true;
}

function cmdQuality() {
    out('\n============================================================');
    out('  12. Test & Quality Gate Pipeline');
    out('============================================================');

    const targetDir = getProjectDir();
    const isStrict = ARGS.includes('--strict');
    if (!isLaravelApp(targetDir)) {
        error(`No Laravel project found at ${targetDir}`);
        return false;
    }

    const steps = [
        { name: 'Composer Validation', bin: 'composer', args: ['validate', '--strict'] },
        { name: 'Pint Code Style', bin: 'vendor/bin/pint', args: ['--test'] },
        { name: 'Larastan Analysis', bin: 'vendor/bin/phpstan', args: ['analyse'] },
        { name: 'Automated Tests', bin: 'php', args: ['artisan', 'test'] },
        { name: 'NPM Build Test', bin: 'npm', args: ['run', 'build'] }
    ];

    let passed = 0;
    let total = 0;

    for (const step of steps) {
        total++;
        const executable = step.bin.split('/')[0];
        if (step.bin.includes('/') && !fs.existsSync(path.join(targetDir, step.bin))) {
            info(`[SKIP] ${step.name} (${step.bin} not installed)`);
            continue;
        }

        info(`Running ${step.name}...`);
        const ok = runCmd(step.bin, step.args, targetDir);
        if (ok) {
            passed++;
        } else if (isStrict) {
            error(`Quality gate failed at step: ${step.name} (Strict mode enabled)`);
            return false;
        }
    }

    success(`Quality pipeline complete (${passed}/${total} checks passed).`);
    return true;
}

function cmdDeploy() {
    out('\n============================================================');
    out('  14. Deployment Orchestration');
    out('============================================================');

    const strategy = getArgValue('strategy') || promptChoiceSync('Select Deployment Strategy:', [
        ['local', 'Local Deployment (Artisan serve)'],
        ['ssh', 'SSH Remote Server Deployment'],
        ['docker', 'Docker / Sail Container Deployment'],
        ['github', 'GitHub Actions Automated Deployment'],
        ['manual', 'Manual Production Deploy']
    ]);

    const targetDir = getProjectDir();

    if (strategy === 'local') {
        cmdBuild();
        info('Starting local development server...');
        return runCmd('php', ['artisan', 'serve'], targetDir);
    }

    if (strategy === 'ssh') {
        const host = getArgValue('host') || promptInputSync('Server SSH Host (user@ip)');
        if (!host) {
            error('SSH host is required for SSH deployment.');
            return false;
        }
        const remotePath = getArgValue('remote-path') || promptInputSync('Remote Path', '/var/www/html');
        const branch = getArgValue('branch') || promptInputSync('Git Branch', 'main');
        const withMaint = ARGS.includes('--maintenance');

        runCmd('git', ['add', '.'], targetDir);
        runCmd('git', ['commit', '-m', 'deploy: automated deploy sync'], targetDir);
        runCmd('git', ['push', 'origin', branch], targetDir);

        const remoteCmd = `cd ${shellQuote(remotePath)} && git pull origin ${branch} && composer install --no-dev --optimize-autoloader && php artisan migrate --force && php artisan storage:link && npm ci && npm run build && php artisan optimize${withMaint ? ' && php artisan down && php artisan up' : ''}`;

        info(`Executing remote SSH deployment to ${host}...`);
        return runCmd('ssh', [host, remoteCmd], targetDir);
    }

    if (strategy === 'docker') {
        info('Docker Deployment: Make sure Laravel Sail is installed (`laravelautoscript developer sail`).');
        return runCmd('./vendor/bin/sail', ['up', '-d'], targetDir);
    }

    info(`Deployment strategy '${strategy}' documented integration hook. See docs/deployment.md.`);
    return true;
}

function cmdSystem() {
    out('\n============================================================');
    out('  17. System Check & Environment Diagnostics');
    out('============================================================');

    const tools = ['php', 'composer', 'git', 'node', 'npm', 'pnpm', 'yarn', 'docker', 'ssh', 'mysql', 'psql', 'sqlite3'];
    let coreMissing = false;

    for (const t of tools) {
        const ok = isAvailable(t);
        out(`${ok ? '[OK]' : '[WARN]'} ${t.padEnd(10)} : ${ok ? 'Available' : 'Not installed / Not in PATH'}`);
        if (['php', 'composer', 'git'].includes(t) && !ok) {
            coreMissing = true;
        }
    }

    if (isAvailable('php')) {
        out('\nChecking PHP Extensions:');
        const res = cp.spawnSync('php', ['-m'], { encoding: 'utf8' });
        const modules = res.stdout || '';
        const reqExts = ['pdo', 'json', 'mbstring', 'xml', 'gd', 'curl', 'pdo_sqlite'];
        reqExts.forEach(ext => {
            const has = new RegExp(ext, 'i').test(modules);
            out(`${has ? '[OK]' : '[WARN]'} Extension ${ext}`);
        });
    }

    if (coreMissing) {
        error('One or more core prerequisites (php, composer, git) are missing.');
        return false;
    }
    success('Core system prerequisites satisfied.');
    return true;
}

function cmdInfo() {
    out('\n============================================================');
    out('  18. Project Information');
    out('============================================================');

    const targetDir = getProjectDir();
    const isApp = isLaravelApp(targetDir);
    out(`Repository Root : ${ROOT_DIR}`);
    out(`Target Path     : ${targetDir}`);
    out(`Is Laravel App  : ${isApp}`);
    out(`OS Platform     : ${process.platform}`);

    if (isApp) {
        const composer = readComposerJson(targetDir);
        out(`App Name        : ${composer.name || 'unnamed'}`);
        const configFile = path.join(targetDir, '.laravelautoscript.yml');
        if (fs.existsSync(configFile)) {
            out('\nConfig (.laravelautoscript.yml):\n' + fs.readFileSync(configFile, 'utf8'));
        }
    }
    return true;
}

function cmdTestSuite() {
    out('\n============================================================');
    out('  Running LaravelAutoScript v2 Self-Test Suite');
    out('============================================================');

    let passed = 0;
    let failed = 0;

    function test(name, fn) {
        try {
            fn();
            success(`PASS: ${name}`);
            passed++;
        } catch (e) {
            error(`FAIL: ${name} (${e.message})`);
            failed++;
        }
    }

    test('Catalog Loading', () => {
        if (!CATALOG.features || !CATALOG.adminPanels) throw new Error('Catalog is missing sections');
    });

    test('YAML Parser & Dumper', () => {
        const original = { name: 'test', count: 5, items: ['a', 'b'], nested: { flag: true } };
        const dumped = dumpYamlLike(original);
        const parsed = parseYamlLike(dumped);
        if (parsed.name !== 'test' || parsed.count !== 5) throw new Error('YAML roundtrip mismatch');
    });

    test('Path & Quote Utility', () => {
        const q = shellQuote("hello 'world'");
        if (!q.includes("hello")) throw new Error('Quote utility error');
    });

    test('Profile Validation', () => {
        const saasPath = path.join(ROOT_DIR, 'profiles', 'saas', 'profile.yaml');
        if (!fs.existsSync(saasPath)) throw new Error('SaaS profile missing');
    });

    test('Domain Modules Catalog', () => {
        if (!CATALOG.domainModules || !CATALOG.domainModules['user-permissions']) {
            throw new Error('Domain modules missing from catalog');
        }
    });

    out(`\nSelf-Test Suite Complete: ${passed} passed, ${failed} failed.`);
    return failed === 0;
}

function displayMasterWizard() {
    out('\n============================================================');
    out(' LaravelAutoScript v2');
    out(' Laravel Application Platform Builder');
    out('============================================================');
    out('');
    out(' [1]  Create New Laravel Application');
    out(' [2]  Configure Existing Laravel Application');
    out(' [3]  Application Profiles');
    out(' [4]  Admin Panel');
    out(' [5]  Authentication');
    out(' [6]  Database');
    out(' [7]  API Platform');
    out(' [8]  Application Features');
    out(' [9]  AI Features');
    out(' [10] Domain & Module Scaffolding (User & Permissions, Products & Categories, Employees)');
    out(' [11] Developer Tools');
    out(' [12] Build & Optimize');
    out(' [13] Test & Quality');
    out(' [14] Local Deployment');
    out(' [15] Production Deployment');
    out(' [16] Docker');
    out(' [17] Git / GitHub');
    out(' [18] System Check');
    out(' [19] Project Information');
    out(' [20] Advanced Configuration');
    out(' [0]  Exit');
    out('');

    const choice = promptChoiceSync('Select option [0-20]:', [
        ['1', 'Create New Laravel Application'],
        ['2', 'Configure Existing Laravel Application'],
        ['3', 'Application Profiles'],
        ['4', 'Admin Panel'],
        ['5', 'Authentication'],
        ['6', 'Database'],
        ['7', 'API Platform'],
        ['8', 'Application Features'],
        ['9', 'AI Features'],
        ['10', 'Domain & Module Scaffolding (User & Permissions, Products & Categories, Employees)'],
        ['11', 'Developer Tools'],
        ['12', 'Build & Optimize'],
        ['13', 'Test & Quality'],
        ['14', 'Local Deployment'],
        ['15', 'Production Deployment'],
        ['16', 'Docker'],
        ['17', 'Git / GitHub'],
        ['18', 'System Check'],
        ['19', 'Project Information'],
        ['20', 'Advanced Configuration'],
        ['0', 'Exit']
    ]);

    switch (choice) {
        case '1': cmdCreate(); break;
        case '2': cmdConfigure(); break;
        case '3': cmdProfile(); break;
        case '4': cmdAdmin(); break;
        case '5': cmdInstallFeature('sanctum'); break;
        case '6': cmdConfigure(); break;
        case '7': cmdInstallFeature('api'); break;
        case '8': cmdInstallFeature(); break;
        case '9': cmdAi(); break;
        case '10': cmdScaffold(); break;
        case '11': cmdInstallFeature('pest'); break;
        case '12': cmdBuild(); break;
        case '13': cmdQuality(); break;
        case '14': cmdDeploy(); break;
        case '15': cmdDeploy(); break;
        case '16': info('Docker / Sail Integration'); break;
        case '17': runCmd('git', ['status'], getProjectDir()); break;
        case '18': cmdSystem(); break;
        case '19': cmdInfo(); break;
        case '20': info('Advanced config stored in .laravelautoscript.yml.'); break;
        case '0': process.exit(0); break;
    }
}

// MAIN DISPATCHER
const subcommand = ARGS.find(arg => !arg.startsWith('--'));

switch (subcommand) {
    case 'create': cmdCreate(); break;
    case 'configure': cmdConfigure(); break;
    case 'profile': cmdProfile(ARGS[1]); break;
    case 'admin': cmdAdmin(ARGS[1]); break;
    case 'feature': cmdInstallFeature(ARGS[1]); break;
    case 'ai': cmdAi(); break;
    case 'scaffold': cmdScaffold(ARGS[1]); break;
    case 'domain': cmdScaffold(ARGS[1]); break;
    case 'developer': cmdInstallFeature(ARGS[1]); break;
    case 'build': cmdBuild(); break;
    case 'test': cmdQuality(); break;
    case 'test-suite': cmdTestSuite(); break;
    case 'deploy': cmdDeploy(); break;
    case 'system': cmdSystem(); break;
    case 'crud': cmdCrud(); break;
    case 'info': cmdInfo(); break;
    default:
        displayMasterWizard();
        break;
}
