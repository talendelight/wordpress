# Local ↔ Production Sync Strategy

**Last Updated:** December 27, 2025

This document defines the synchronization approach between local development and production (Hostinger) environments.

---

## Core Philosophy

### Database: Schema Parity, Content Separation

**Database Structure (Schema):**
- ✅ **MUST be identical** between local and production
- ✅ **ALL tables** from production must exist locally (including Hostinger-specific plugin tables)
- ✅ Tracked in `infra/shared/db/` delta files
- ✅ Applied automatically on fresh container startup

**Database Content (Data):**
- ❌ **NOT synced** - local uses test/dummy data, production has real data
- ❌ Posts, pages, users, orders, form submissions stay separate
- ✅ Configuration stored in files (themes/plugins) is synced via Git

### Files: Selective Sync

**What IS Synced (via Git auto-deploy):**
- ✅ `wp-content/themes/` - All themes
- ✅ `wp-content/plugins/` - All plugins EXCEPT Hostinger suite
- ✅ `wp-content/mu-plugins/` (if exists)
- ✅ `wp-content/uploads/` (excluded via `.hostingerignore`, managed separately)

**What is NOT Synced:**
- ❌ Hostinger suite plugins (4 plugins: `hostinger/`, `hostinger-ai-assistant/`, `hostinger-easy-onboarding/`, `hostinger-reach/`)
- ❌ WordPress core files (managed by hosting provider)
- ❌ `infra/`, `docs/`, `config/`, `tmp/` (dev-only)

---

## Current State (Dec 27, 2025)

### Alignment Status

✅ **WordPress Core:** IDENTICAL
- Version: 6.9.0 both local and production
- Files: wp-admin (100 items), wp-includes (278 items), root files (16 core) - all match

✅ **Themes:** IDENTICAL
- blocksy, twentytwentyfive, twentytwentyfour, twentytwentythree

⚠️ **Plugins:** Partial (3/7 match = 42.9%)
- **Common:** akismet, litespeed-cache, wpforms-lite
- **Production missing:** blocksy-companion, elementor, woocommerce
- **Production only (stay excluded locally):** hostinger suite (4 plugins)

✅ **Database Schema:** ALIGNED (via delta files)
- Local: 12 core WP tables + delta-created tables
- Production: 25 tables (12 core + 13 plugin tables)
- Delta file [251227-2055-add-production-plugin-tables.sql](../infra/shared/db/251227-2055-add-production-plugin-tables.sql) creates all 13 production plugin tables locally

---

## Sync Rules

### Rule 1: Database Schema = Production Exact Match

**Goal:** Local database schema MUST mirror production exactly

**How:**
1. Production has plugin tables → Create them locally via delta files
2. Hostinger-specific plugins (hostinger suite) → Their tables still exist locally (schema parity)
3. Plugin files stay out of local `wp-content/plugins/`, but database tables exist

**Why:**
- Enables accurate testing of database migrations
- Prevents schema drift errors during deployment
- Ensures SQL queries work identically in both environments

**Example:**
```
Production has: wp_hostinger_reach_carts (from hostinger-reach plugin)
Local has: Same table (created via delta file)
Local does NOT have: hostinger-reach plugin files
Result: Schema parity maintained, plugin excluded from local wp-content
```

### Rule 2: Plugin Files = Selective Sync

**Included in Local & Production:**
- blocksy-companion (theme add-on)
- elementor (page builder)
- woocommerce (e-commerce)
- akismet (spam protection)
- litespeed-cache (performance)
- wpforms-lite (forms)

**Excluded from Local (Production only):**
- hostinger/ (hosting control panel integration)
- hostinger-ai-assistant/ (Hostinger AI features)
- hostinger-easy-onboarding/ (Hostinger setup wizard)
- hostinger-reach/ (Hostinger marketing tools)

**Reason:** Hostinger suite plugins are hosting-provider specific, not needed for development

### Rule 3: Content = Never Sync

**Local:** Test data only (dummy posts, test orders, fake users)  
**Production:** Real customer data (never pull to local)

**Exception:** Debugging production issues - manually export/sanitize specific records, not full database

### Rule 4: Configuration = Git-Tracked

**Auto-synced via Git:**
- Theme settings stored in theme files
- Plugin configuration files
- `.htaccess` rules (if needed)

**NOT synced:**
- wp-config.php (environment-specific, production vs dev credentials)
- Environment variables
- Server-specific PHP settings

---

## Development Workflow

### Standard Development Cycle (Local → Production)

```
┌─────────────────────────────────────────────────────────┐
│ 1. LOCAL DEVELOPMENT                                    │
├─────────────────────────────────────────────────────────┤
│ • Work in wp-content/ (themes/plugins/mu-plugins)       │
│ • Test with dummy data in local database                │
│ • Database schema matches production (via delta files)  │
│ • Hostinger plugins excluded, their tables present      │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 2. GIT COMMIT & PUSH                                    │
├─────────────────────────────────────────────────────────┤
│ • git add wp-content/                                   │
│ • git commit -m "Feature: description"                  │
│ • git push origin main                                  │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 3. HOSTINGER AUTO-DEPLOY                                │
├─────────────────────────────────────────────────────────┤
│ • Hostinger detects push to main branch                 │
│ • Deploys wp-content/ to public_html/wp-content/        │
│ • Excludes infra/, docs/, config/, tmp/                 │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│ 4. ACTIVATION (if new plugins added)                    │
├─────────────────────────────────────────────────────────┤
│ • Login to WordPress Admin on production                │
│ • Activate new plugins                                  │
│ • WordPress auto-creates plugin database tables         │
│ • Test functionality                                    │
└─────────────────────────────────────────────────────────┘
```

**Key Points:**
- ✅ No manual database imports needed for regular development
- ✅ WordPress auto-handles plugin version updates in database
- ✅ Plugin activation auto-creates needed tables
- ✅ Theme/plugin settings auto-sync via files

---

## Monthly Production Check (Production → Local)

**Frequency:** Last Friday of each month (or as needed)

**Goal:** Detect production changes made by Hostinger or via production WordPress admin

### Procedure

**Step 1: Export Production Database**
```
1. Login to Hostinger phpMyAdmin
2. Export database: u909075950_GD9QX
3. Save to tmp/ folder: tmp/{yymmdd}-prod-check.sql
```

**Step 2: Request Comparison**
```
Ask GitHub Copilot: "Compare production with local - monthly check"
Provide file: tmp/{yymmdd}-prod-check.sql
```

**Step 3: Review Findings**

Copilot will report:
- ✅ Plugin version changes (Hostinger auto-updates)
- ✅ Theme version changes
- ✅ New Hostinger-added plugins/tables
- ✅ Schema changes requiring delta files
- ⚠️ Configuration drift (wp-config.php changes)

**Step 4: Take Action**

Based on findings:
- **New plugin tables** → Create delta file, add to `infra/shared/db/`
- **Hostinger updates** → Document in changelog, update local if needed
- **Schema changes** → Review, create delta if structural changes needed
- **No action needed** → Document "checked, no changes"

---

## Exception Scenarios

### When to Import Production Database

❌ **Never for regular development**  
✅ **Only in these cases:**

1. **Debugging production-specific issues**
   - Export production table (sanitize sensitive data)
   - Import to local for testing
   - Fix issue locally, deploy fix to production

2. **Major structural changes from Hostinger**
   - Hostinger upgrades WordPress core with schema changes
   - Export production schema
   - Update baseline or create delta file

3. **Initial project setup** (already done)
   - Bootstrap local environment from production snapshot
   - Not needed after initial setup

### When to Push Database Changes to Production

❌ **Never via SQL imports during normal development**  
✅ **Only via WordPress mechanisms:**

1. **Plugin/theme activation** - WordPress creates tables automatically
2. **Plugin updates** - WordPress runs update routines
3. **WordPress core updates** - Hostinger manages this

❌ **Do NOT manually import SQL to production** unless:
- Migrating entire site to new hosting
- Disaster recovery from backup
- Approved by senior developer

---

## File Reference

### Documentation
- [docs/DATABASE.md](DATABASE.md) - Database management workflows
- [docs/DEPLOYMENT.md](DEPLOYMENT.md) - Hostinger Git deployment
- [docs/HOSTINGER.md](HOSTINGER.md) - Production credentials
- [docs/OPEN-ACTIONS.md](OPEN-ACTIONS.md) - Current TODO items

### Database Files
- [infra/shared/db/000000-00-init.sql](../infra/shared/db/000000-00-init.sql) - Baseline schema
- [infra/shared/db/251227-1149-update-theme.versions.sql](../infra/shared/db/251227-1149-update-theme.versions.sql) - Theme config delta
- [infra/shared/db/251227-2055-add-production-plugin-tables.sql](../infra/shared/db/251227-2055-add-production-plugin-tables.sql) - Production plugin tables delta
- [infra/shared/db/README.md](../infra/shared/db/README.md) - Delta file naming conventions

---

## Quick Command Reference

### Local Development
```bash
# Start fresh (resets database from SQL files)
cd infra/dev
podman-compose down -v && podman-compose up -d

# Check plugin status locally
podman exec -it wordpress wp plugin list

# Activate plugin locally
podman exec -it wordpress wp plugin activate plugin-name

# Export local database for comparison
podman exec wordpress mysqldump -u root -ppassword wordpress > tmp/local-export.sql
```

### Production (Hostinger)
```bash
# Export via phpMyAdmin (manual)
# Login: https://hpanel.hostinger.com
# Navigate: Databases > phpMyAdmin > Export

# After Git push, activate plugins:
# WordPress Admin > Plugins > Activate
```

### Monthly Check
```bash
# 1. Export production DB to tmp/{yymmdd}-prod-check.sql
# 2. Ask Copilot: "Compare production with local - monthly check"
```

---

## Summary

✅ **Database Schema:** MUST match production exactly (including Hostinger plugin tables)  
❌ **Database Content:** Never sync (local = test data, production = real data)  
✅ **Plugin Files:** Sync all EXCEPT Hostinger suite (excluded from local)  
✅ **Plugin Tables:** ALL tables exist locally (schema parity), even for excluded plugins  
✅ **Deployment:** Git auto-deploy handles file sync, WordPress handles database updates  
✅ **Monthly Check:** Compare production vs local, update deltas if needed  

**Core Principle:** Schema parity enables accurate testing, content separation protects production data.
