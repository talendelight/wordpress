# Disaster Recovery Manifest

**Last Updated:** February 14, 2026  
**Version:** v3.6.2  
**Purpose:** Complete inventory of critical files for disaster recovery

## Critical Files Checklist

### ✅ Database Schema & Data
**Location:** `infra/shared/db/`

- ✅ `000000-0000-init-db.sql` - Baseline WordPress schema
- ✅ `251227-1149-update-theme-versions.sql` - Theme version updates
- ✅ `251227-2055-add-production-plugin-tables.sql` - Plugin tables (Forminator, WPUM, etc.)
- ✅ `251230-2030-enable-elementor-blocksy.sql` - Theme activation
- ✅ `260117-1400-add-user-data-change-requests.sql` - Custom approval table
- ✅ `260118-1200-add-audit-log-table.sql` - Audit logging table
- ✅ `260119-1400-add-role-and-audit-log.sql` - Role fields + audit triggers
- ✅ `260120-1945-alter-add-approver-comments.sql` - Approval comments column
- ✅ `260131-1200-add-record-id-prsn-cmpy.sql` - Record ID generation
- ✅ `260131-1300-add-id-sequences-table.sql` - ID sequence tracking
- ✅ `260131-1400-add-assigned-by-column.sql` - Assignment tracking
- ✅ `260204-0131-update-shortcodes-manager-operator-pages.sql` - Manager page shortcodes
- ✅ `260211-2345-forminator-form-80-role-field.sql` - Registration form role capture
- ✅ `users-from-production-20260130.sql` - Production users backup
- ✅ `usermeta-from-production-20260130.sql` - Production user meta backup
- ✅ `welcome-page-restore.sql` - Welcome page content

**Total:** 16 SQL files

---

### ✅ Page Content Backups
**Location:** `restore/pages/`

- ✅ `welcome-6.html` - Welcome/Home page
- ✅ `candidates-7.html` - Candidates landing page
- ✅ `managers-8.html` - Managers landing page
- ✅ `operators-9.html` - Operators landing page
- ✅ `manager-admin-10.html` - Manager Admin dashboard
- ✅ `403-forbidden-44.html` - 403 Access Restricted page
- ✅ `employers-64.html` - Employers landing page
- ✅ `scouts-76.html` - Scouts landing page
- ✅ `register-profile-79.html` - Registration form page
- ✅ `manager-actions-84.html` - Manager Actions approval interface
- ✅ `help-110.html` - Help & Support page
- ✅ `privacy-policy-3.html` - Privacy Policy page (exported Feb 14, 2026)
- ✅ `register-profile.html` - Legacy backup (pre-ID naming)
- ✅ `manager-actions-84-backup-20260212-2311.html` - Timestamped backup
- ✅ `managers-8-backup-20260212-2311.html` - Timestamped backup

**Total:** 15 HTML files (12 active pages + 3 legacy/backup versions)

**Note on Select Role Page:**
- Select Role (ID 78, /select-role/) uses custom PHP template (page-role-selection.php), not Gutenberg/Elementor
- Page has empty post_content - functionality is in template file
- Template already backed up in theme files section (wp-content/themes/blocksy-child/page-role-selection.php)

---

### ✅ Form Configurations
**Location:** `restore/forms/`

- ✅ `forminator-form-80-post.sql` - Registration form (Form ID 80) with role capture field

**Note:** Additional forms may exist (CV submission, Employer request, Scout submission) but not yet backed up.

---

### ✅ Theme Files
**Location:** `wp-content/themes/blocksy-child/`

**PHP Files:**
- ✅ `functions.php` - Theme customizations, redirects, role-based access control
- ✅ `page-role-selection.php` - Custom template for Select Role page
- ❌ `logout-redirect.php` - **DELETED** (Feb 14, 2026 - merged into functions.php)

**CSS Files:**
- ✅ `style.css` - Design system variables, custom styles
- ✅ `custom-css/forminator-forms-styling.css` - Forminator form styling
- ✅ `custom-css/manager-actions-tabs.css` - Manager Actions tab interface
- ✅ `custom-css/manager-admin-dashboard.css` - Manager Admin dashboard styling
- ✅ `custom-css/register-profile-form.css` - Registration form styling

**Block Patterns:**
- ✅ `patterns/card-grid-3.php` - 3-card single row
- ✅ `patterns/card-grid-2-2.php` - 2x2 grid (4 cards)
- ✅ `patterns/card-grid-3+1.php` - 3 cards + 1 centered
- ✅ `patterns/hero-single-cta.php` - Hero sections
- ✅ `patterns/cta-primary.php` - CTA sections
- ✅ `patterns/footer-trust-badges.php` - Footer badges

**Total:** 2 PHP + 5 CSS + 6 patterns = 13 theme files

---

### ✅ Must-Use Plugins (MU-Plugins)
**Location:** `wp-content/mu-plugins/`

- ✅ `audit-logger.php` - Comprehensive audit logging for all approval actions
- ✅ `forminator-custom-table.php` - Forminator → td_user_data_change_requests sync
- ✅ `manager-actions-display.php` - Manager Actions approval interface AJAX handlers
- ✅ `record-id-generator.php` - PRSN/CMPY record ID generation (TD-PRSN-0001 format)
- ✅ `td-api-security.php` - REST API security and authentication
- ✅ `td-env-config.php` - Environment-specific configuration loader
- ✅ `td-notifications.php` - Email notification system (placeholder)
- ✅ `user-requests-display.php` - User requests display and management

**Total:** 8 MU-plugins (all critical for MVP functionality)

**Backup Status:** ✅ Files backed up in `restore/mu-plugins/` directory

---

### ✅ Configuration Files
**Location:** `config/`

- ✅ `wp-config.php` - WordPress configuration (uses env vars via `getenv_docker()`)
- ✅ `.htaccess` - Apache rewrite rules
- ✅ `uploads.ini` - PHP upload limits (64M files, 128M posts, 600s execution)
- ✅ `env-config.php` - Environment variable configuration

**Note:** Sensitive values (DB credentials, API keys) are in environment variables, NOT in version control.

---

### ✅ Deployment Instructions
**Location:** `.github/releases/`

**Active Release Files:**
- ✅ `v3.6.2.json` - Current release deployment instructions
- ✅ `v3.6.1.json` - Previous release (archived reference)

**Archived Releases:**
- ✅ `archive/RELEASE-NOTES-*.md` - Historical release notes

**Release File Contents:**
- Version metadata
- Change descriptions
- Deployment steps (pre-checks, main steps, post-checks)
- Rollback procedures
- Backup file inventory
- Notes and warnings

---

## Completeness Assessment

### ✅ Complete & Up-to-Date
1. **Database schema** - All 16 migration files present
2. **Theme files** - Functions, styles, patterns all backed up
3. **MU-plugins** - All 8 plugins backed up
4. **Configuration** - wp-config, .htaccess, uploads.ini
5. **Deployment docs** - Release JSON files with instructions

### ⚠️ Needs Attention
1. **Page backups** - Missing 2 pages:
   - Privacy Policy (ID 3, /privacy-policy/)
   - Select Role (ID 78, /select-role/)
2. **Form backups** - Only Form 80 (Registration) backed up
   - Missing: CV submission form, Employer request form, Scout submission form
3. **Release file backup inventory** - v3.6.2.json backup_files list is incomplete

### 🔴 Missing Critical Data
1. **Production user data** - Last backup: Jan 30, 2026 (15 days old)
   - **ACTION REQUIRED:** Export current production users
2. **Plugin settings** - Forminator forms, WPUM settings not in SQL format
   - **ACTION REQUIRED:** Use `restore/export-plugin-settings.ps1`
3. **Menu configuration** - Navigation menus not backed up
   - **ACTION REQUIRED:** Export menus to `restore/menu/`

---

## Recovery Priority

### 🔥 P0: Critical (Cannot operate without)
- Database schema (all 16 SQL files)
- MU-plugins (all 8 files)
- Theme functions.php
- wp-config.php

### ⚠️ P1: High (Significant functionality loss)
- Page content backups (all 11 active pages)
- Block patterns (6 files)
- CSS styling files (5 files)
- Form configurations (Forminator Form 80)

### 📋 P2: Medium (Degraded experience)
- Plugin settings exports
- Menu configurations
- User data backups
- Assets (images, uploads)

---

## Backup Automation Status

**Automated Backups:**
- ✅ Daily backup script: `restore/BACKUP-ALL.ps1`
- ✅ Pre-deployment backup: Automated via deployment workflow
- ✅ Database delta tracking: Automatic via SQL file naming convention

**Manual Backups Required:**
- ⚠️ Production user data export (monthly recommended)
- ⚠️ Plugin settings export (after configuration changes)
- ⚠️ New page content (after page creation/major edits)

---

## Recovery Testing

**Last Tested:** February 5, 2026 (after data loss incident)  
**Test Result:** ✅ **SUCCESSFUL** - Restored from production backup in 30 minutes

**Test Coverage:**
- ✅ Database restore from SQL files
- ✅ Page content import
- ✅ Theme activation
- ✅ Plugin installation
- ✅ User data recovery
- ❌ Full system test from zero (not yet tested)

**Next Test:** March 1, 2026 (scheduled quarterly)

---

## Action Items (February 14, 2026)

### Immediate (Today)
1. ✅ Fix logout redirect to /welcome/ (DONE)
2. ✅ Export Privacy Policy page (ID 3) - DONE (5610 bytes)
3. ✅ Update v3.6.2.json backup_files list - DONE (50 files)
4. ⏳ Test logout functionality

### Short-term (This Week)
1. Export production user data (refresh 15-day-old backup)
2. Export plugin settings (Forminator, WPUM)
3. Export navigation menus
4. Document CV submission form (when implemented)
5. Create backup verification script

### Medium-term (This Month)
1. Automate page content export (daily)
2. Automate plugin settings export (weekly)
3. Set up off-site backup storage (cloud)
4. Conduct full disaster recovery drill

---

## Verification Commands

**Check page backups:**
```bash
Get-ChildItem restore/pages/*.html | Select-Object Name, LastWriteTime
```

**Check database files:**
```bash
Get-ChildItem infra/shared/db/*.sql | Select-Object Name, Length
```

**Check MU-plugins:**
```bash
Get-ChildItem wp-content/mu-plugins/*.php | Select-Object Name, Length
```

**Check theme files:**
```bash
Get-ChildItem wp-content/themes/blocksy-child -Recurse -File | Measure-Object | Select-Object Count
```

**Verify deployment JSON completeness:**
```bash
Get-Content .github/releases/v3.6.2.json | ConvertFrom-Json | Select-Object -ExpandProperty backup_files
```

---

## Related Documentation

- [DISASTER-RECOVERY-PLAN.md](DISASTER-RECOVERY-PLAN.md) - Complete recovery procedures
- [BACKUP-RESTORE-QUICKSTART.md](BACKUP-RESTORE-QUICKSTART.md) - Quick recovery guide
- [BACKUP-STRATEGY.md](BACKUP-STRATEGY.md) - Backup philosophy and retention
- [restore/README.md](../restore/README.md) - Restore folder documentation
- [restore/COMPLETE-RESTORE-GUIDE.md](../restore/COMPLETE-RESTORE-GUIDE.md) - Detailed restore steps

---

**Emergency Contact:** Review this document immediately after any data loss or before major deployments.
