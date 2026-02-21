# Documentation Index

## System Overview

This repository documents the **WordPress Primary Application** (Hostinger) used for marketing and candidate/employer intake while support applications are being built.

- **WordPress (Primary):** public pages + candidate CV intake (no mandatory login) + scout and staff-assisted submissions (with consent) + role-based access.
- **Excel (Interim Ops):** operational tracking for candidate/employer/job pipelines (expected ~100 candidates/month; cycles up to ~9 months).
- **Person App (Future):** Angular + Java 25 + MySQL system of record for structured candidate profiles (work history, qualifications, search, dedupe).
- **CV Storage (Pattern 1):** CVs are staged on Hostinger initially, offloaded weekly to OneDrive/SharePoint, and cleaned up after a buffer window.

## Key Documents (WordPress)

### Business and UI
- [WORDPRESS-BUSINESS-FUNCTIONALITY.md](WORDPRESS-BUSINESS-FUNCTIONALITY.md) â€” business scope, roles, workflows, acceptance criteria
- [WORDPRESS-UI-DESIGN.md](WORDPRESS-UI-DESIGN.md) â€” UI specification + Figma production checklist
- [COMMON-UI-DESIGN.md](COMMON-UI-DESIGN.md) â€” shared design primitives + responsive breakpoints (placeholders)

### Technical and Operations
- [WORDPRESS-TECHNICAL-DESIGN.md](WORDPRESS-TECHNICAL-DESIGN.md) â€” architecture, custom plugin responsibilities, file handling, exports
- [WORDPRESS-DEPLOYMENT.md](WORDPRESS-DEPLOYMENT.md) â€” local/prod deployment + CV staging/offload/cleanup operational notes
- [WORDPRESS-SECURITY.md](WORDPRESS-SECURITY.md) â€” security hardening with CV/PII-specific controls
- [WORDPRESS-DATABASE.md](WORDPRESS-DATABASE.md) â€” DB management + PII-safe export policy
- [WORDPRESS-OPEN-ACTIONS.md](WORDPRESS-OPEN-ACTIONS.md) â€” open items split into Business and Technical

### Excel Templates
- [WORDPRESS-EXCEL-TEMPLATE-CANDIDATE-PIPELINE.csv](WORDPRESS-EXCEL-TEMPLATE-CANDIDATE-PIPELINE.csv) â€” semicolon-delimited EU CSV template

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
2. Right-click â†’ **Run as Administrator**
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

### Deployment & Operations
- **[DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md)** - Complete deployment process and lessons learned
- **[ID-MANAGEMENT-STRATEGY.md](ID-MANAGEMENT-STRATEGY.md)** - Slug-based ID lookups for cross-environment deployments
- **[QUICK-REFERENCE-DEPLOYMENT.md](QUICK-REFERENCE-DEPLOYMENT.md)** - Command cheat sheet for deployments
- **[RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md)** - Release lifecycle workflow

### Core Documentation
- **[WORDPRESS-DATABASE.md](WORDPRESS-WORDPRESS-DATABASE.md)** - Database management for dev and production environments
- **[WORDPRESS-DEPLOYMENT.md](WORDPRESS-WORDPRESS-DEPLOYMENT.md)** - Deploy to Hostinger, VPS, or cloud platforms
- **[WORDPRESS-SECURITY.md](WORDPRESS-WORDPRESS-SECURITY.md)** - Vulnerability scanning, hardening, and best practices

---

## Document Summaries

### [WORDPRESS-DATABASE.md](WORDPRESS-WORDPRESS-DATABASE.md)

**Database Management Guide** - Covers SQL-based version control strategy for both ephemeral (dev) and persistent (prod) databases.

**Topics:**
- Ephemeral vs persistent database strategies
- SQL file naming conventions (`000000-0000-init-db.sql`, `{yymmdd}-{HHmm}-{action}-{short.desc}.sql`)
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
â”œâ”€â”€ .github/
â”‚   â””â”€â”€ copilot-instructions.md  # AI assistant context and rules
â”œâ”€â”€ config/
â”‚   â”œâ”€â”€ uploads.ini              # Shared PHP configuration
â”‚   â””â”€â”€ dev/wp/httpd/            # Dev-specific WordPress configs
â”œâ”€â”€ docs/                        # This directory
â”‚   â”œâ”€â”€ README.md
â”‚   â”œâ”€â”€ WORDPRESS-DATABASE.md
â”‚   â”œâ”€â”€ WORDPRESS-DEPLOYMENT.md
â”‚   â””â”€â”€ WORDPRESS-SECURITY.md
â”œâ”€â”€ infra/
â”‚   â”œâ”€â”€ dev/
â”‚   â”‚   â””â”€â”€ compose.yml          # Development Podman Compose config
â”‚   â”œâ”€â”€ prod/
â”‚   â”‚   â”œâ”€â”€ compose.yml          # Production Podman Compose config
â”‚   â”‚   â””â”€â”€ .env.example         # Production environment template
â”‚   â””â”€â”€ shared/
â”‚       â”œâ”€â”€ init/                # SQL initialization files
â”‚       â”‚   â”œâ”€â”€ 000000-0000-init-db.sql  # Baseline database schema
â”‚       â”‚   â””â”€â”€ README.md        # SQL file naming conventions
â”‚       â””â”€â”€ tools/               # WPScan and vulnerability scanning
â”œâ”€â”€ tmp/                         # Sensitive product data (gitignored)
â””â”€â”€ wp-data/
    â””â”€â”€ wp-content/              # WordPress content (plugins, themes, uploads)
```

---

## Common Tasks

### Starting Development Environment

```powershell
cd infra/dev
podman-compose up -d
```

Access:
- WordPress: https://wp.local
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