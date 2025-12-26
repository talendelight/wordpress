# Documentation Index

Welcome to the WordPress project documentation. This directory contains comprehensive guides for development, deployment, security, and maintenance.

## Quick Links

- **[DATABASE.md](DATABASE.md)** - Database management for dev and production environments
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deploy to Hostinger, VPS, or cloud platforms
- **[SECURITY.md](SECURITY.md)** - Vulnerability scanning, hardening, and best practices

---

## Document Summaries

### [DATABASE.md](DATABASE.md)

**Database Management Guide** - Covers SQL-based version control strategy for both ephemeral (dev) and persistent (prod) databases.

**Topics:**
- Ephemeral vs persistent database strategies
- SQL file naming conventions (`000000-00-init.sql`, `{yymmdd}-{HHmm}-change-{short.desc}.sql`)
- Development workflows (starting fresh, exporting changes)
- Production backups and restore procedures
- Database migrations and troubleshooting
- Best practices for version-controlled database evolution

**Use when:**
- Setting up new development environment
- Making database schema changes
- Backing up production database
- Troubleshooting database issues

---

### [DEPLOYMENT.md](DEPLOYMENT.md)

**Deployment Guide** - Instructions for deploying WordPress to various hosting platforms.

**Topics:**
- Container-based deployment (VPS, cloud servers)
- Traditional shared hosting (Hostinger, Bluehost)
- VPS with Docker (DigitalOcean, AWS, Linode)
- Hostinger-specific optimizations
- Post-deployment tasks (security, performance, monitoring)
- Rollback procedures
- Hosting provider comparison

**Use when:**
- Deploying to production for first time
- Migrating to new hosting provider
- Troubleshooting deployment issues
- Choosing hosting platform

---

### [SECURITY.md](SECURITY.md)

**Security Guide** - Comprehensive security practices including vulnerability scanning and hardening.

**Topics:**
- WPScan vulnerability scanning setup
- Running security scans (manual and automated)
- Production security hardening (compose.yml, wp-config.php, .htaccess)
- Plugin and theme security management
- Access control (database, WordPress admin, FTP)
- Security monitoring and log analysis
- Incident response procedures
- Security checklists for dev and prod

**Use when:**
- Scanning for vulnerabilities
- Hardening production environment
- Responding to security incident
- Performing regular security audits

---

## Project Structure Reference

```
wordpress/
├── .github/
│   └── copilot-instructions.md  # AI assistant context and rules
├── config/
│   ├── uploads.ini              # Shared PHP configuration
│   └── dev/wp/httpd/            # Dev-specific WordPress configs
├── docs/                        # This directory
│   ├── README.md
│   ├── DATABASE.md
│   ├── DEPLOYMENT.md
│   └── SECURITY.md
├── infra/
│   ├── dev/
│   │   └── compose.yml          # Development Podman Compose config
│   ├── prod/
│   │   ├── compose.yml          # Production Podman Compose config
│   │   └── .env.example         # Production environment template
│   └── shared/
│       ├── init/                # SQL initialization files
│       │   ├── 000000-00-init.sql  # Baseline database schema
│       │   └── README.md        # SQL file naming conventions
│       └── tools/               # WPScan and vulnerability scanning
├── tmp/                         # Sensitive product data (gitignored)
└── wp-data/
    └── wp-content/              # WordPress content (plugins, themes, uploads)
```

---

## Common Tasks

### Starting Development Environment

```powershell
cd infra/dev
podman-compose up -d
```

Access:
- WordPress: http://localhost:8080
- phpMyAdmin: http://localhost:8180

### Resetting Development Database

```powershell
cd infra/dev
podman-compose down -v  # Destroys all data
podman-compose up -d    # Starts fresh from SQL files
```

### Running Security Scan

```powershell
cd infra/shared/tools
podman-compose up wpscan
```

View results: `infra/shared/tools/reports/`

### Backing Up Production Database

```powershell
cd infra/prod
podman exec -it db mysqldump -u root -p${MYSQL_ROOT_PASSWORD} wordpress | `
  Out-File -Encoding utf8 "backups\wordpress-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql"
```

### Updating Plugins/Themes

```powershell
podman exec -it wordpress wp plugin update --all
podman exec -it wordpress wp theme update --all
```

---

## Additional Resources

### Project Files

- [.github/copilot-instructions.md](../.github/copilot-instructions.md) - Project overview for AI assistants
- [infra/shared/db/README.md](../infra/shared/db/README.md) - SQL file naming conventions
- [infra/dev/reports/plugins-themes-report.md](../infra/dev/reports/plugins-themes-report.md) - Plugin/theme inventory
- [infra/shared/tools/README.md](../infra/shared/tools/README.md) - WPScan setup details

### External Documentation

- WordPress Codex: https://codex.wordpress.org/
- WooCommerce Docs: https://woocommerce.com/documentation/
- Elementor Docs: https://elementor.com/help/
- WPScan Documentation: https://github.com/wpscanteam/wpscan
- Podman Documentation: https://docs.podman.io/

---

## Getting Help

1. **Check relevant guide** - Start with DATABASE.md, DEPLOYMENT.md, or SECURITY.md
2. **Search project files** - Use file_search or grep_search tools
3. **Review logs** - `podman logs wordpress` or `podman logs wp-db`
4. **Consult external docs** - Links provided in each guide

For project-specific questions, refer to [.github/copilot-instructions.md](../.github/copilot-instructions.md).
