# Database Restoration Procedure

**Last Updated:** February 23, 2026  
**Context:** Local WordPress development environment with Podman Compose

## Overview

Local development uses **ephemeral databases** - the database resets to a clean state whenever the volume is deleted. All database schema and data are defined in version-controlled SQL migration files in `infra/shared/db/`.

## When Do You Need This?

- After running `podman-compose down -v` (deletes database volume)
- When resetting to clean database state for testing
- After container crashes that corrupt the database
- When onboarding new developers

## Source of Truth

**All SQL files in `infra/shared/db/` combined = complete database state**

```
infra/shared/db/
├── 000000-0000-init-db.sql              # WordPress core schema
├── 251227-1149-fix-theme-settings.sql   # Theme configurations
├── 251227-2055-add-production-plugin-tables.sql
├── 260117-1400-add-user-data-change-requests.sql # Custom tables
├── 260118-1200-add-audit-log-table.sql
├── 260119-1400-add-role-and-audit-log.sql
├── 260120-1945-alter-add-approver-comments.sql
├── ...
└── 260219-2340-create-profile-logout-menu-items.sql
```

**Naming Convention:** `{YYMMDD}-{HHmm}-{action}-{brief-description}.sql`
- Action verbs: add, update, remove, alter, insert, migrate, fix, enable, disable, create

## Automatic Restoration

### Step 1: Delete Old Database (if needed)

```powershell
cd infra/dev
podman-compose down -v  # -v flag deletes volumes
```

**⚠️ WARNING:** `-v` flag **permanently deletes** the database. Use `podman-compose stop` instead to preserve data between restarts.

### Step 2: Start Fresh Environment

```powershell
podman-compose up -d
```

This creates a new empty database but **does NOT** run initialization scripts automatically (MariaDB entrypoint only runs .sql files on first-ever startup).

### Step 3: Run Initialization Script

```powershell
podman exec wp-db bash /docker-entrypoint-initdb.d/init-all-migrations.sh
```

This script:
1. Applies all `.sql` files in alphabetical order
2. Logs success/failure for each file  
3. Exits on first error (fail-fast)
4. Typically takes 10-15 seconds for full initialization

### Step 4: Restore Page Content

**⚠️ Note:** Some pages use custom templates. See [../PAGE-TEMPLATES.md](../PAGE-TEMPLATES.md) if pages look incorrect.

```powershell
# Restore all pages from backups (via action dispatcher)
pwsh infra/shared/scripts/wp-action.ps1 restore-pages

# Or direct script execution
powershell -ExecutionPolicy Bypass -File infra\shared\scripts\restore-all-pages.ps1
```

This restores actual content from `restore/pages/` to all placeholder pages:
- Welcome, Help, Privacy Policy
- Role landing pages: Candidates, Employers, Scouts, Managers, Operators
- Manager dashboards: Manager Admin, Manager Actions
- Registration: Register Profile, Select Role
- Error pages: 403 Forbidden

**Backup Versioning Rule for restore/pages/:**

The `restore/pages/` folder should contain ONLY the latest version of each page to avoid confusion.

✅ **DO:**
- Keep ONE file per page: `{page-slug}-{page-id}.html`
- Use correct page ID for the environment (local ID for local backups, production ID for production)
- REPLACE existing file when updating backup (don't create new timestamped versions)
- Example: `register-profile-28.html` (local) or `register-profile-50.html` (production)

❌ **DON'T:**
- Keep multiple versions of same page (register-profile-21.html AND register-profile-28.html)
- Use ambiguous names without ID (register-profile.html)
- Add timestamps to individual page files (manager-actions-84-backup-20260212-2311.html)

📝 **Note:** Timestamped backups belong in `restore/backups/{timestamp}/` for full system snapshots, NOT in restore/pages/ for individual page working copies.

🧹 **Cleanup:** Regularly remove old duplicate page files to avoid confusion about which file is current.

### Step 5: Restore WordPress Menus

```powershell
# Restore navigation menus (via action dispatcher)
pwsh infra/shared/scripts/wp-action.ps1 restore-menus

# Or direct script execution
powershell -ExecutionPolicy Bypass -File infra\shared\scripts\restore-menus.ps1
```

This restores the Primary Menu structure from production:
- Creates Primary Menu with 6 items (Welcome, Register, Profile, Help, Login, Logout)
- Assigns menu to all theme locations (footer, menu_1, menu_2, menu_mobile)
- Flushes WordPress cache

Verify menus were restored:
```powershell
podman exec wp wp menu list --allow-root --skip-plugins
podman exec wp wp menu item list primary-menu --allow-root --skip-plugins
```

### Step 6: Verify Database State

```powershell
# Check custom tables
podman exec wp-db mariadb -u root -ppassword wordpress -e "SHOW TABLES LIKE 'wp_td_%'"

# Expected output:
# wp_td_audit_log
# wp_td_id_sequences
# wp_td_user_data_change_requests

# Check pages
podman exec wp wp post list --post_type=page --format=table --allow-root --skip-plugins

# Check test users
podman exec wp wp user list --allow-root --skip-plugins

# Test site accessibility
Invoke-WebRequest -Uri "http://localhost:8080" -Method HEAD -UseBasicParsing
```

## Table Naming Convention (CRITICAL)

For local Docker/Podman development, SQL files **MUST** use full prefixed table names:

**✅ CORRECT (Local Development SQL):**
```sql
CREATE TABLE IF NOT EXISTS wp_td_user_data_change_requests (...);
ALTER TABLE wp_td_id_sequences ADD COLUMN ...;
```

**❌ WRONG (Will cause PHP/SQL mismatch):**
```sql
CREATE TABLE IF NOT EXISTS td_user_data_change_requests (...);
```

**Why:** MariaDB CLI executes SQL files directly without WordPress context. It doesn't know about `$table_prefix` setting. So we must use explicit full names.

**PHP Code Pattern:**
```php
global $wpdb;
// PHP uses dynamic prefix
$table = $wpdb->prefix . 'td_user_data_change_requests'; // → 'wp_td_user_data_change_requests'
$wpdb->get_row("SELECT * FROM {$table} WHERE id = 1");
```

## Troubleshooting

### Database Initialization Script Not Found

**Symptom:** `bash: /docker-entrypoint-initdb.d/init-all-migrations.sh: No such file or directory`

**Solution:** The script exists in the mounted directory. Check mount:
```powershell
podman exec wp-db ls -la /docker-entrypoint-initdb.d/ | grep init-all
```

If missing, check podman-compose.yml volume mount for wp-db service.

### SQL Migration Fails on Duplicate Table

**Symptom:** `ERROR 1050 (42S01): Table 'wp_xyz' already exists`

**Cause:** Running initialization script twice, or duplicate CREATE statements across SQL files.

**Solution:**
1. Always use `CREATE TABLE IF NOT EXISTS` in SQL files
2. OR drop database and restart: `podman-compose down -v && podman-compose up -d`

### Menu Items Creation Fails

**Symptom:** `ERROR 1048 (23000) at line 54: Column 'term_taxonomy_id' cannot be null`

**Impact:** Non-critical. Core functionality (registration, pages, users) still works.

**Cause:** Menu creation depends on WordPress term taxonomy which may not exist yet.

**Solution:** Either:
1. Ignore (menu items are cosmetic)
2. Create menu manually via WP admin
3. Fix SQL to check for term existence before insertion

### PHP Code Can't Find Tables

**Symptom:** WordPress errors: "Table 'wordpress.td_user_data_change_requests' doesn't exist"

**Cause:** SQL files created unprefixed tables (`td_*`) but PHP expects prefixed (`wp_td_*`)

**Solution:** Update SQL files to use full `wp_td_*` prefix. See [Table Naming Convention](#table-naming-convention-critical) above.

## When NOT to Use This

**DON'T delete database volume if:**
- You're just restarting containers: Use `podman-compose restart` or `podman-compose stop/start`
- You want to preserve test data you've manually created
- You're debugging and need to inspect current database state

**Use `podman-compose down -v` ONLY when:**
- You want a completely fresh start
- Database is corrupted and you need clean slate
- Testing initialization scripts
- Resetting environment for demos

## Related Documentation

- [WORDPRESS-DATABASE.md](../../../Documents/WORDPRESS-DATABASE.md) - Complete database workflow guide
- [database-table-naming-consistency.md](../lessons/database-table-naming-consistency.md) - Table naming patterns
- [COMMAND-REGISTRY.md](../COMMAND-REGISTRY.md) - Database query commands
- [TASK-REGISTRY.md](../../.github/TASK-REGISTRY.md) - Database management procedures

## Success Criteria

After successful restoration, you should have:

✅ WordPress accessible at https://wp.local  
✅ 3 custom tables: `wp_td_audit_log`, `wp_td_id_sequences`, `wp_td_user_data_change_requests`  
✅ 19+ pages including:
  - Core: Welcome (homepage), Help, Privacy Policy
  - Landing pages: Candidates, Employers, Scouts, Managers, Operators  
  - Manager tools: Manager Admin, Manager Actions
  - Auth: Log In, Register, Register Profile, Select Role, Password Reset, Account, Profile
  - Error: 403 Forbidden
✅ 6 users: wpadmin + 5 test users (candidate, employer, scout, operator, manager)  
✅ All WordPress core tables (50+ tables)  
✅ Admin login works: https://wp.local/wp-admin (wpadmin / password)  
✅ Registration form loads: https://wp.local/register-profile/
✅ Primary Menu active with 6 items (Welcome, Register, Profile, Help, Login, Logout)
✅ All landing pages accessible:
  - https://wp.local/candidates
  - https://wp.local/employers
  - https://wp.local/managers
  - https://wp.local/admin (Manager Admin dashboard)
## Essential Plugins (Keep These)

**Core functionality:**
- `talendelight-roles` - Custom user roles (td_candidate, td_employer, td_scout, td_operator, td_manager)
- `wp-user-manager` - Login/registration forms
- `blocksy-companion` - Theme companion
- `login-logout-menu` - Dynamic menu items
- `forminator` - Form builder (deprecated, may be removed in future)

**Must-use plugins (in wp-content/mu-plugins/):**
- `audit-logger.php` - Compliance logging
- `forminator-custom-table.php` - Form data handling
- `manager-actions-display.php` - Manager dashboard
- `record-id-generator.php` - ID generation (USRQ, PRSN, CMPY)
- `td-registration-handler.php` - Registration processing
- `user-requests-display.php` - Request management UI

**DO NOT INSTALL:**
- ❌ **wordpress-importer** - Not needed (we use direct wp-cli page updates)
- ❌ **wpforms-lite** - Not used
- ❌ **elementor** - Migrated to Gutenberg blocks