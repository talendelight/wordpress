# WordPress Restore Templates

**Last Updated:** February 5, 2026  
**Source:** Production backup from January 30, 2026

This directory contains export templates for pages, forms, menus, and configurations that cannot be easily deployed via Git.

## 🚨 IMPORTANT: Use Production Backup Files

All subdirectories now contain exports from the **January 30, 2026 production backup**. These are the authoritative source for restoration.

## Directory Structure

```
restore/
├── pages/              # Elementor page exports (JSON) - 16 pages from production
├── menu/               # Navigation menu structure - See menu/README.md
├── forms/              # Forminator form exports - See forms/README.md
├── pages-inventory.csv # Complete list of pages
├── users-export.json   # Test user accounts (legacy)
└── site-config.txt     # Critical WordPress options
```

## What's Included

### Pages (`pages/`)

**All pages exported from production backup (Jan 30, 2026):**

**Authentication & Registration:**
- Log In (26), Password Reset (27), Register (28), Account (29), Profile (30)
- Select Role (78), Register Profile (79)

**Role-Specific Pages:**
- Welcome (6) - Homepage (Feb 4, 2026 - newest version)
- Candidates (7), Employers (64), Scouts (76)
- Operators (9), Managers (8)
- Manager Admin (10)

**Error Pages:**
- Access Restricted (44) - 403 forbidden page

Each page has 2 files: `{slug}-{id}.json` (page data) + `{slug}-{id}-elementor.json` (Elementor data)

### Menu (`menu/`)

**⚠️ See [menu/README.md](menu/README.md) for import instructions**

Production menu data exported:
- `menus-from-production.sql` - Menu terms and taxonomy
- `menu-items-from-production.sql` - Menu item posts
- `menu-items-meta-from-production.sql` - Menu item metadata
- `menu-relationships-from-production.sql` - Menu-to-item relationships

### Forms (`forms/`)

**⚠️ See [forms/README.md](forms/README.md) for import instructions**

Forminator form exported from production:
- `forminator-form-80-from-production.sql` - Form post (ID 80: person-registration-form)
- `forminator-form-80-meta-from-production.sql` - Form settings and fields
- `forminator-tables-from-production.sql` - Forminator plugin tables

### Users

**Users are stored in `infra/shared/db/` (SQL-based data)**

See [infra/shared/db/USERS-README.md](../infra/shared/db/USERS-README.md) for:
- `users-from-production-20260130.sql` - 10 production users
- `usermeta-from-production-20260130.sql` - User metadata

### Configuration Files
- `pages-inventory.csv` - List of all pages with IDs, titles, slugs
- `site-config.txt` - Critical site options (homepage ID, site name, URLs)

## Usage

### Verify Production State
Before restoring, check what exists in production:
```bash
# SSH into production
ssh production

# Check pages
wp post list --post_type=page --fields=ID,post_title,post_name

# Check menus
wp menu list
wp menu item list {menu-id}

# Check homepage setting
wp option get page_on_front
wp option get show_on_front
```

### Restore Pages to Production
```bash
# 1. Import page structure (without Elementor data)
wp post create --from-json=restore/pages/welcome-6.json

# 2. Update Elementor data (use import script or manual upload)
# See: infra/shared/scripts/import-elementor-pages.php
```

### Restore Menu to Production
```bash
# 1. Create menu
wp menu create "Main Navigation"

# 2. Add menu items (extract from main-navigation-items.json)
wp menu item add-custom main-navigation "Welcome" / --position=1
wp menu item add-custom main-navigation "Register" /register/ --position=2
wp menu item add-custom main-navigation "Profile" /profile/ --position=3
wp menu item add-custom main-navigation "Help" /help/ --position=4
wp menu item add-custom main-navigation "Login" /log-in/ --position=5
wp menu item add-custom main-navigation "Logout" /logout/ --position=6

# 3. Assign to location (depends on theme)
wp menu location assign main-navigation menu_1
```

### Restore Forminator Forms
```bash
# Import forms SQL dump
wp db import restore/forms/forminator-forms-dump.sql
```

### Restore Site Configuration
```bash
# Set homepage (Welcome page ID may differ in production)
wp option update page_on_front {welcome-page-id}
wp option update show_on_front page
```

## Production ID Mapping

**Important:** Page IDs differ between local and production environments.

Use `restore/pages-inventory.csv` to map local IDs to production IDs:

| Local ID | Page Name | Production ID (TBD) |
|----------|-----------|---------------------|
| 6 | Welcome | ? |
| 7 | Candidates | ? |
| 8 | Managers | ? |
| 9 | Operators | ? |
| 10 | Manager Admin | ? |

Update this table after verifying production state.

## Backup Strategy

### Automated Exports
Run this script to update restore templates:
```bash
pwsh infra/shared/scripts/export-restore-templates.ps1
```

### Manual Export
```bash
# Pages
wp post get {ID} --format=json > restore/pages/{slug}-{ID}.json
wp post meta get {ID} _elementor_data > restore/pages/{slug}-{ID}-elementor.json

# Menu
wp menu list --format=json > restore/menu/menus-list.json
wp menu item list {menu-id} --format=json > restore/menu/main-navigation-items.json

# Forms
mariadb-dump -u root -p wordpress wp_frmt_form_entry wp_frmt_form_entry_meta > restore/forms/forminator-forms-dump.sql
```

## Version Control

This `restore/` directory is **GIT-TRACKED** so templates are version-controlled and deployed to production.

Do NOT store sensitive data or production secrets here.

## Related Documentation

- [DEPLOYMENT-WORKFLOW.md](../docs/DEPLOYMENT-WORKFLOW.md) - Complete deployment process
- [QUICK-REFERENCE-DEPLOYMENT.md](../docs/QUICK-REFERENCE-DEPLOYMENT.md) - Quick command reference
- [WORDPRESS-PAGE-SYNC-MANIFEST.md](../../Documents/WORDPRESS-PAGE-SYNC-MANIFEST.md) - Page ID mapping strategy
- [WORDPRESS-DEPLOYMENT.md](../../Documents/WORDPRESS-DEPLOYMENT.md) - Hostinger deployment guide
