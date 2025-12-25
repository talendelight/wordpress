# Copilot Instructions

## Rules

1. **Always request review before modifying files** - propose changes, don't implement them automatically
2. **Never make assumptions** - ask for clarification when requirements are ambiguous

## Project Overview

This is a WordPress 6.8.2 (PHP 8.2) development environment managed via Podman Compose for local development, with production deployment to Hostinger via Git integration.

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
- [infra/shared/db/000000-init.sql](infra/shared/db/000000-init.sql) is the source of truth (version-controlled baseline)
- Uses Podman named volume (destroyed with `podman-compose down -v`)
- To reset database: `podman-compose down -v && podman-compose up -d`
- See [docs/DATABASE.md](docs/DATABASE.md) for complete database workflow guide

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

- Development uses **ephemeral databases** - always starts fresh from [infra/shared/db/000000-init.sql](infra/shared/db/000000-init.sql)
- Database changes are tracked as version-controlled SQL files, not live data
- To persist work across sessions: `podman-compose stop` (without `-v`)
- To reset completely: `podman-compose down -v && podman-compose up -d`
- Production uses Hostinger's managed MySQL database with manual SQL import workflow

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
