# Copilot Instructions

## Rules

1. **Always request review before modifying files** - propose changes, don't implement them automatically
2. **Never make assumptions** - ask for clarification when requirements are ambiguous

## Project Overview

This is a WordPress 6.8.2 (PHP 8.2) development environment managed via Podman Compose. The project separates concerns into distinct directories:

- **[infra/](infra/)** - Podman Compose configs for dev/prod environments
- **[wp-data/wp-content/](wp-data/wp-content/)** - WordPress content (plugins, themes, uploads) - mounted into containers
- **[config/dev/wp/httpd/](config/dev/wp/httpd/)** - Custom WordPress config and .htaccess mounted as overlays
- **[blob/dev/db-data/](blob/dev/db-data/)** - Persistent MariaDB data (not version-controlled, exists locally)

**Key plugins**: WooCommerce, Elementor, Blocksy Companion, WPForms Lite, Akismet  
**Active themes**: Blocksy (primary), Twenty Twenty-Three/Four/Five

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
- FTP server: ports 20-21, 30000-30009

### Database Management

- **Ephemeral database strategy**: Database resets to clean state on every fresh startup
- [infra/shared/init/000000-init.sql](infra/shared/init/000000-init.sql) is the source of truth (version-controlled baseline)
- Uses Podman named volume (destroyed with `podman-compose down -v`)
- To reset database: `podman-compose down -v && podman-compose up -d`
- See [infra/dev/DATABASE.md](infra/dev/DATABASE.md) for complete database workflow guide

### Using WP-CLI

All wp-cli commands must run inside the WordPress container:

```bash
podman exec -it wordpress wp plugin list
podman exec -it wordpress wp theme list --format=json
podman exec -it wordpress wp user create newuser email@example.com --role=editor
```

### File Upload Limits

PHP upload limits configured in [infra/dev/uploads.ini](infra/dev/uploads.ini):
- `upload_max_filesize = 64M`
- `post_max_size = 64M`
- `max_execution_time = 600`

Changes require container restart: `podman-compose restart wordpress`

## Project-Specific Patterns

### Configuration Overlay Pattern

WordPress core files stay in the container. Only specific configs are mounted from host:
- [config/dev/wp/httpd/wp-config.php](config/dev/wp/httpd/wp-config.php) - uses `getenv_docker()` helper to read container env vars
- [config/dev/wp/httpd/.htaccess](config/dev/wp/httpd/.htaccess) - custom rewrite rules
- Sets `FS_METHOD = 'direct'` to allow direct plugin installation without FTP

**Why**: Keeps host filesystem lean while allowing config versioning and easy environment-specific overrides.

### Volume Mount Strategy

Dev compose mounts only `wp-content/` from host ([wp-data/wp-content/](wp-data/wp-content/)), not the entire WordPress installation. This means:
- ✅ Plugin/theme changes persist and are version-controlled
- ✅ Uploads directory is accessible from host
- ❌ WordPress core files not directly editable from host (intentional)

### FTP Server for Plugin Management

The [infra/dev/compose.yml](infra/dev/compose.yml#L4-L21) includes `wp-ftp` service (pure-ftpd) configured with:
- User: `ftp_user` / Pass: `ftp_password`
- UID/GID: 33 (www-data) - matches Apache user in WordPress container
- Access to `/wp-content` only

**Usage**: Some WordPress plugins/themes require FTP credentials for updates. Use these credentials when prompted.

## Integration Points & Dependencies

- **MariaDB** - accessed via service name `wp-db` from within Podman network
- **phpMyAdmin** - pre-configured with `PMA_HOST: wp-db` (http://localhost:8180)
- All services use default Podman network created by compose (auto DNS resolution)
- External DB access: `mysql -h 127.0.0.1 -P 3306 -u root -ppassword wordpress`
- Database credentials: root/password (dev only)

## Database Philosophy

- Development uses **ephemeral databases** - always starts fresh from [infra/shared/init/000000-init.sql](infra/shared/init/000000-init.sql)
- Database changes are tracked as version-controlled SQL files, not live data
- To persist work across sessions: `podman-compose stop` (without `-v`)
- To reset completely: `podman-compose down -v && podman-compose up -d`
- Production will use persistent storage managed by hosting provider

## When Working with Plugins/Themes

- Review [infra/dev/reports/plugins-themes-report.md](infra/dev/reports/plugins-themes-report.md) for compatibility notes
- Elementor and WooCommerce have large codebases - test thoroughly after PHP/WP version changes
- Blocksy Companion contains Freemius SDK - be aware of potential telemetry calls

## Production vs Development

- [infra/prod/compose.yml](infra/prod/compose.yml) uses latest WordPress image (no FTP, no phpMyAdmin)
- Dev environment uses pinned versions: `wordpress:6.8.2-php8.2-apache`, `mariadb:11.8.2-noble`
- Production config should use env-specific volume paths and secrets management
