# Open Action Items

This document tracks all open action items and TODO tasks for the WordPress project.

**Last Updated:** December 27, 2025

---

## High Priority

### 1. Local Environment Setup

**Status:** In Progress  
**Related Files:** 
- [infra/shared/db/251227-2055-add-production-plugin-tables.sql](../infra/shared/db/251227-2055-add-production-plugin-tables.sql)
- [docs/SYNC-STRATEGY.md](SYNC-STRATEGY.md)
- [infra/shared/db/README.md](../infra/shared/db/README.md)

**Goal:** Establish local development environment with production schema parity

**Strategy:**
- ✅ Database schema MUST match production exactly (including Hostinger plugin tables)
- ✅ Plugin files selectively synced (exclude Hostinger suite from local wp-content)
- ✅ Delta file [251227-2055-add-production-plugin-tables.sql](../infra/shared/db/251227-2055-add-production-plugin-tables.sql) creates 13 production tables locally
- ❌ Content (posts/pages/users) NOT synced - local uses test data only

**Tasks:**
- [x] Create delta file for production plugin tables ✅ **COMPLETE** (Dec 27, 2025)
  - File: 251227-2055-add-production-plugin-tables.sql (23.69 KB)
  - Tables: Action Scheduler (4), Hostinger Reach (3), LiteSpeed (2), WPForms (4)
  - Status: Ready for import on fresh database startup

- [x] Install LiteSpeed Cache plugin ✅ **INSTALLED** (Dec 27, 2025)
  - Version: 7.7
  - Size: 3.37 MB
  
- [x] **Activate LiteSpeed Cache plugin** ✅ **ACTIVATED** (Dec 27, 2025)
  - Activated via WordPress Admin → Plugins
  - Files created: `wp-content/litespeed/` (cache directory with 6 files)
  - Note: WP-CLI not available in official WordPress Docker image

- [x] **Configure LiteSpeed Cache for development environment** ✅ **CONFIGURED** (Dec 27, 2025)
  - Cache: DISABLED (fresh content on every request)
  - Debug: ENABLED (Level 2 - shows cache info in HTML comments)
  - CSS/JS Minify: DISABLED (easier debugging)
  - CSS/JS Combine: DISABLED (avoid conflicts)
  - Crawler: DISABLED (not needed locally)
  - Configuration stored in local database only (won't affect production)
  - See: [docs/LITESPEED-CONFIG.md](LITESPEED-CONFIG.md) for details

- [ ] **Push local plugins to production** (blocksy-companion, elementor, woocommerce)
  - Git push to main branch triggers Hostinger auto-deploy
  - Activate plugins via WordPress Admin after deployment
  - WordPress auto-creates plugin tables on activation

**Benefits:**
- Database schema parity enables accurate testing
- Plugin ecosystem ready for local development
- Production deployment process validated

---

## Medium Priority

### 2. Monthly Production Sync Check

**Status:** Scheduled (Monthly)  
**Related Files:**
- [docs/SYNC-STRATEGY.md](SYNC-STRATEGY.md)
- [docs/HOSTINGER.md](HOSTINGER.md)
- [tmp/](../tmp/) (production exports)

**Goal:** Monitor production environment for changes and maintain sync with local

**Schedule:** Last Friday of each month (or as needed)

**Procedure:**
1. Export production database via Hostinger phpMyAdmin
2. Save to `tmp/{yymmdd}-prod-check.sql`
3. Request comparison: "Compare production with local - monthly check"
4. Review findings (plugin updates, schema changes, new tables)
5. Create delta files if structural changes detected
6. Update documentation

**What to Check:**
- [ ] Plugin version changes (Hostinger auto-updates)
- [ ] Theme version changes
- [ ] New Hostinger-added plugins/tables
- [ ] Schema changes requiring delta files
- [ ] Configuration drift (wp-config.php changes)

**Action Items:**
- If new plugin tables: Create delta file in `infra/shared/db/`
- If Hostinger updates: Document in changelog
- If schema changes: Review and create delta if needed
- If no changes: Document "checked, no changes"

**Benefits:**
- Catch Hostinger-initiated changes early
- Maintain schema parity between environments
- Prevent deployment surprises
- Document production evolution

---

### 3. Automation & CI/CD - mysqldiff Integration

**Status:** Open  
**Related Files:**
- [infra/shared/db/README.md](../infra/shared/db/README.md)
- [docs/DATABASE.md](DATABASE.md)

**Goal:** Automate database schema validation and change detection in CI/CD pipeline

**Tasks:**
- [ ] Install `mysql-utilities` in CI/CD environment
- [ ] Create pre-deployment script to compare production schema with delta files
- [ ] Add automated tests to validate delta files don't contain DROP/CREATE for existing tables
- [ ] Integrate with Hostinger Git deployment workflow
- [ ] Add rollback scripts for emergency schema reversions
- [ ] Document production database change approval process

**Benefits:**
- Catch schema conflicts before production deployment
- Automated validation of incremental delta rules
- Safer production deployments with pre-deployment checks
- Audit trail of all database changes

**Reference:** See `mysqldiff` tool documentation in [infra/shared/db/README.md](../infra/shared/db/README.md)

---

### 4. Automated Database Migrations

**Status:** Open  
**Related Files:**
- [docs/DEPLOYMENT.md](DEPLOYMENT.md)

**Goal:** Automate SQL file application on deployment to Hostinger

**Current State:** Database changes require manual phpMyAdmin import

**Tasks:**
- [ ] Research Hostinger deployment hook capabilities
- [ ] Enable remote MySQL access or SSH tunneling
- [ ] Create deployment script (`.hostinger-deploy.sh` or webhook-triggered)
- [ ] Implement migration tracking (applied migrations table)
- [ ] Add safe rollback mechanism
- [ ] Test with staging environment
- [ ] Document usage in DEPLOYMENT.md

**Proposed Approach:**
- Script detects new SQL files in `infra/shared/db/`
- Connects to Hostinger database via SSH tunnel or MySQL remote access
- Applies migrations automatically
- Logs applied migrations to prevent re-running
- Integration with Hostinger's deployment hooks (if available)

**Benefits:**
- No manual phpMyAdmin uploads
- Faster deployments
- Reduced human error
- Consistent migration tracking

---

## Completed Items

_(No completed items yet)_

---

## Notes

- All action items are tracked with checkboxes `[ ]`
- Update this file when completing tasks
- Move completed items to the "Completed Items" section with completion date
- Add new action items as they arise during development
