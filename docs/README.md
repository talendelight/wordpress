# Documentation Index

## System Overview

This repository documents the **WordPress Primary Application** (Hostinger) used for marketing and candidate/employer intake while support applications are being built.

- **WordPress (Primary):** public pages + candidate CV intake (no mandatory login) + partner/employee-assisted submissions + role-based access.
- **Excel (Interim Ops):** operational tracking for candidate/employer/job pipelines (expected ~100 candidates/month; cycles up to ~9 months).
- **Person App (Future):** Angular + Java 25 + MySQL system of record for structured candidate profiles (work history, qualifications, search, dedupe).
- **CV Storage (Pattern 1):** CVs are staged on Hostinger initially, offloaded weekly to OneDrive/SharePoint, and cleaned up after a buffer window.

## Key Documents (WordPress)

### Business and UI
- [WORDPRESS-BUSINESS-FUNCTIONALITY.md](WORDPRESS-BUSINESS-FUNCTIONALITY.md) — business scope, roles, workflows, acceptance criteria
- [WORDPRESS-UI-DESIGN.md](WORDPRESS-UI-DESIGN.md) — UI specification + Figma production checklist
- [COMMON-UI-DESIGN.md](COMMON-UI-DESIGN.md) — shared design primitives + responsive breakpoints (placeholders)

### Technical and Operations
- [WORDPRESS-TECHNICAL-DESIGN.md](WORDPRESS-TECHNICAL-DESIGN.md) — architecture, custom plugin responsibilities, file handling, exports
- [WORDPRESS-DEPLOYMENT.md](WORDPRESS-DEPLOYMENT.md) — local/prod deployment + CV staging/offload/cleanup operational notes
- [WORDPRESS-SECURITY.md](WORDPRESS-SECURITY.md) — security hardening with CV/PII-specific controls
- [WORDPRESS-DATABASE.md](WORDPRESS-DATABASE.md) — DB management + PII-safe export policy
- [WORDPRESS-OPEN-ACTIONS.md](WORDPRESS-OPEN-ACTIONS.md) — open items split into Business and Technical

### Excel Templates
- [WORDPRESS-EXCEL-TEMPLATE-CANDIDATE-PIPELINE.csv](WORDPRESS-EXCEL-TEMPLATE-CANDIDATE-PIPELINE.csv) — semicolon-delimited EU CSV template

Welcome to the WordPress project documentation. This directory contains comprehensive guides for development, deployment, security, and maintenance.

## Prerequisites

### Windows PowerShell Setup

**Issue:** PowerShell scripts may be blocked with error:
```
File cannot be loaded because running scripts is disabled on this system.
PSSecurityException: UnauthorizedAccess
```

**Solution (One-time fix):**
1. Press **Windows** key, type "PowerShell"
2. Right-click → **Run as Administrator**
3. Execute:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
   ```
4. Type `Y` and press **Enter**
5. Re-run the command, type `A` and press **Enter**
6. Close PowerShell and reopen normally

**Verify fix:**
```powershell
Get-ExecutionPolicy -List
```
Should show `LocalMachine: RemoteSigned`

---

## Quick Links

- **[WORDPRESS-DATABASE.md](WORDPRESS-WORDPRESS-DATABASE.md)** - Database management for dev and production environments
- **[WORDPRESS-DEPLOYMENT.md](WORDPRESS-WORDPRESS-DEPLOYMENT.md)** - Deploy to Hostinger, VPS, or cloud platforms
- **[WORDPRESS-SECURITY.md](WORDPRESS-WORDPRESS-SECURITY.md)** - Vulnerability scanning, hardening, and best practices

---

## Document Summaries

### [WORDPRESS-DATABASE.md](WORDPRESS-WORDPRESS-DATABASE.md)

**Database Management Guide** - Covers SQL-based version control strategy for both ephemeral (dev) and persistent (prod) databases.

**Topics:**
- Ephemeral vs persistent database strategies
- SQL file naming conventions (`000000-00-init.sql`, `{yymmdd}-{HHmm}-{action}-{short.desc}.sql`)
- Action verbs: add, update, remove, alter, insert, migrate, fix, enable, disable
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

### [WORDPRESS-DEPLOYMENT.md](WORDPRESS-WORDPRESS-DEPLOYMENT.md)

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

### [WORDPRESS-SECURITY.md](WORDPRESS-WORDPRESS-SECURITY.md)

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
│   ├── WORDPRESS-DATABASE.md
│   ├── WORDPRESS-DEPLOYMENT.md
│   └── WORDPRESS-SECURITY.md
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

1. **Check relevant guide** - Start with WORDPRESS-DATABASE.md, WORDPRESS-DEPLOYMENT.md, or WORDPRESS-SECURITY.md
2. **Search project files** - Use file_search or grep_search tools
3. **Review logs** - `podman logs wordpress` or `podman logs wp-db`
4. **Consult external docs** - Links provided in each guide

For project-specific questions, refer to [.github/copilot-instructions.md](../.github/copilot-instructions.md).