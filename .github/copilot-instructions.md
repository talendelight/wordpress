# Copilot Instructions

## Rules

1. **Always request review before modifying files** - propose changes, don't implement them automatically
2. **Never make assumptions** - ask for clarification when requirements are ambiguous

## Known Issues & Solutions

### PowerShell Execution Policy Error

If user encounters `PSSecurityException: UnauthorizedAccess` error when running PowerShell scripts, suggest this one-time fix:

1. Open PowerShell as Administrator
2. Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine`
3. Confirm with `Y`, then re-run and confirm with `A`

This is a Windows security restriction and requires manual Administrator access. Cannot be automated.

## Project Overview

This is a WordPress 6.9.0 (PHP 8.3) development environment managed via Podman Compose for local development, with production deployment to Hostinger via Git integration.

**Directory Structure:**
- **[infra/dev/](infra/dev/)** - Podman Compose config for local development environment
- **[wp-content/](wp-content/)** - WordPress content (plugins, themes, uploads) - root level for Hostinger deployment
- **[config/](config/)** - Dev-specific configurations (wp-config.php, .htaccess, PHP settings)
- **[docs/](docs/)** - Project documentation (DATABASE, DEPLOYMENT, SECURITY guides)
- **[tmp/](tmp/)** - Sensitive data and manual SQL imports (not tracked in git)

**Deployment Strategy:**
- **Development**: Docker/Podman containers on local machine
- **Production**: Hostinger shared hosting with Git auto-deployment on push to `main` branch

**Key plugins**: WooCommerce, Elementor, Blocksy Companion, WPForms Lite, Akismet  
**Active theme**: Blocksy (primary)

## Critical Developer Workflows

### Starting the Development Environment

```bash
cd infra/dev
podman-compose up -d
```

Services exposed:
- WordPress: http://localhost:8080
- phpMyAdmin: http://localhost:8180  
- MariaDB: localhost:3306

### Database Management

- **Ephemeral database strategy**: Database resets to clean state on every fresh startup
- **Source of truth**: ALL SQL files in [infra/shared/db/](infra/shared/db/) combined (not just 000000-00-init.sql alone)
  - [infra/shared/db/000000-00-init.sql](infra/shared/db/000000-00-init.sql) - Baseline WordPress schema
  - Delta files: `{yymmdd}-{HHmm}-{action}-{short.desc}.sql` - Incremental changes applied on top of baseline
  - Action verbs: add, update, remove, alter, insert, migrate, fix, enable, disable
  - **Combined baseline** = init file + all delta files applied sequentially
- Uses Podman named volume (destroyed with `podman-compose down -v`)
- To reset database: `podman-compose down -v && podman-compose up -d`
- See [docs/DATABASE.md](docs/DATABASE.md) for complete database workflow guide

**Database Comparison Rule**: When comparing current database state with "previous baseline", the baseline is the COMBINED state of ALL SQL files in `infra/shared/db/` (000000-00-init.sql + all deltas), not just the init file alone.

**Delta File Creation Rules**:
- ✅ Delta files MUST contain ONLY incremental changes, NOT full exports
- ❌ NEVER include `DROP TABLE IF EXISTS` for existing tables in deltas
- ❌ NEVER include `CREATE TABLE` for tables that exist in baseline
- ✅ Use `TRUNCATE TABLE` + `INSERT` pattern for updating entire table data (e.g., wp_options)
- ✅ Use `ALTER TABLE` for schema modifications
- ✅ Use `INSERT INTO` for new records, `UPDATE` for modifications
- ✅ Extract only changed data sections from mysqldump exports, not entire database

### Using WP-CLI

All wp-cli commands must run inside the WordPress container:

```bash
podman exec -it wordpress wp plugin list
podman exec -it wordpress wp theme list --format=json
podman exec -it wordpress wp user create newuser email@example.com --role=editor
```

### File Upload Limits

PHP upload limits configured in [config/uploads.ini](config/uploads.ini):
- `upload_max_filesize = 64M`
- `post_max_size = 128M`
- `max_execution_time = 600`
- `memory_limit = 128M`

Changes require container restart: `podman-compose restart wordpress`

## Project-Specific Patterns

### Configuration Overlay Pattern

WordPress core files stay in the container. Only specific configs are mounted from host:
- [config/wp-config.php](config/wp-config.php) - uses `getenv_docker()` helper to read container env vars
- [config/.htaccess](config/.htaccess) - custom rewrite rules
- [config/uploads.ini](config/uploads.ini) - PHP upload/execution limits
- Sets `FS_METHOD = 'direct'` to allow direct plugin installation without FTP

**Why**: Keeps host filesystem lean while allowing config versioning and easy environment-specific overrides.

### Volume Mount Strategy

Dev compose mounts `wp-content/` from repository root into container:
- ✅ Plugin/theme changes persist and are version-controlled
- ✅ Uploads directory accessible from host (but excluded from git)
- ✅ Direct edit in IDE, instant reflection in container
- ❌ WordPress core files not directly editable from host (intentional)

### Git Deployment Strategy

Repository root contains only `wp-content/` for production deployment:
- Hostinger's Git integration monitors `main` branch
- Auto-deploys `wp-content/` to `public_html/wp-content/` on push
- Excludes dev-only files via [.hostingerignore](.hostingerignore): `infra/`, `docs/`, `config/`, `tmp/`, `.github/`
- Hostinger manages WordPress core, `wp-config.php`, and server configuration
- Database changes require manual import via phpMyAdmin (future automation planned)

## Integration Points & Dependencies

- **MariaDB** - accessed via service name `wp-db` from within Podman network
- **phpMyAdmin** - pre-configured with `PMA_HOST: wp-db` (http://localhost:8180)
- All services use default Podman network created by compose (auto DNS resolution)
- External DB access: `mysql -h 127.0.0.1 -P 3306 -u root -ppassword wordpress`
- Database credentials: root/password (dev only)

## Database Philosophy

- Development uses **ephemeral databases** - always starts fresh from [infra/shared/db/000000-00-init.sql](infra/shared/db/000000-00-init.sql)
- Database changes are tracked as version-controlled SQL files, not live data
- To persist work across sessions: `podman-compose stop` (without `-v`)
- To reset completely: `podman-compose down -v && podman-compose up -d`
- **Schema parity rule**: Local database schema MUST match production exactly (including Hostinger plugin tables)
- **Content separation**: Local uses test data, production has real data - content is NEVER synced
- Production uses Hostinger's managed MySQL database
- See [docs/SYNC-STRATEGY.md](docs/SYNC-STRATEGY.md) for complete local/production sync approach

## When Working with Plugins/Themes

- Review [infra/dev/reports/plugins-themes-report.md](infra/dev/reports/plugins-themes-report.md) for compatibility notes
- Elementor and WooCommerce have large codebases - test thoroughly after PHP/WP version changes
- Blocksy Companion contains Freemius SDK - be aware of potential telemetry calls
- Test all changes locally before pushing to `main` branch (triggers production deployment)

## Production Deployment

- **Hosting**: Hostinger shared hosting (not containers)
- **Deployment method**: Git auto-deployment via Hostinger's built-in Git integration
- **Trigger**: Push to `main` branch
- **What deploys**: `wp-content/` directory only (themes, plugins, mu-plugins)
- **What doesn't deploy**: WordPress core (Hostinger provides), dev infrastructure, docs
- See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for complete Hostinger Git integration guide
