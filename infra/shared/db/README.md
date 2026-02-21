# Database Initialization Files

## Purpose

This directory contains shared SQL initialization files used across all environments (dev, prod, staging).

## File Naming Convention

### `000000-0000-init-db.sql` 
**First deployment / environment setup only**
- Complete baseline database schema and initial configuration
- Includes all WordPress core tables, plugin tables, and essential settings
- Run automatically on first container startup when database volume is empty
- Version controlled in git
- Contains NO sensitive product data

### `{yymmdd}-{HHmm}-{action}-{short.desc}.sql`
**Incremental changes only - NOT full exports**
- Schema changes (ALTER TABLE, CREATE TABLE for NEW tables only)
- Configuration changes (TRUNCATE + INSERT for specific tables like wp_options)
- Data updates (UPDATE or INSERT for specific records)
- Version controlled in git
- Executed in chronological order during deployments
- Timestamp format: `{yymmdd}-{HHmm}` ensures proper ordering when multiple changes happen same day

**Action Verbs:**
- `add` - Adding new tables, columns, indexes, constraints
- `update` - Updating existing data, configurations, versions
- `remove` - Removing tables, columns, indexes, features
- `alter` - Modifying table structure (ALTER TABLE operations)
- `insert` - Inserting new records
- `migrate` - Data migration or transformation operations
- `fix` - Bug fixes or data corrections
- `enable` - Enabling features or settings
- `disable` - Disabling features or settings

**CRITICAL RULES:**
- ❌ NEVER include `DROP TABLE IF EXISTS` for existing tables
- ❌ NEVER include full table dumps with `CREATE TABLE` for baseline tables
- ❌ NEVER use `TRUNCATE TABLE` + full INSERT (loses data, use UPDATE instead)
- ✅ ONLY include actual changes/additions since previous combined baseline
- ✅ Use `UPDATE` for modifying specific records (preferred for wp_options)
- ✅ Use `ALTER TABLE` for schema modifications
- ✅ Use `INSERT INTO` for new records only

**IMPORTANT - wp_options Table:**
- ⚠️ `wp_options` contains critical site configuration (active theme, menus, plugins)
- ✅ Use targeted `UPDATE` statements for specific options
- ❌ NEVER use `TRUNCATE TABLE wp_options` (wipes all WordPress settings)
- ✅ Example: `UPDATE wp_options SET option_value = 'blocksy-child' WHERE option_name = 'stylesheet';`

Examples:
- `251222-1430-add-loyalty-points.sql` - adds loyalty_points column to users table (Dec 22, 2:30 PM)
- `251225-0915-create-orders-index.sql` - adds index for faster order queries (Dec 25, 9:15 AM)
- `251227-1149-fix-theme-settings.sql` - corrects active theme settings (UPDATE pattern) ✅
- `260101-1200-enable-woocommerce-features.sql` - activates specific WooCommerce options (Jan 1, 12:00 PM)

**⚠️ Historical Note:**
- Original file `251227-1149-update-theme-versions.sql` used `TRUNCATE TABLE wp_options` approach
- Caused loss of theme/menu settings when recreating database (Feb 19, 2026 incident)
- Moved to `deprecated/` and replaced with targeted UPDATE approach
- **Lesson:** Never use TRUNCATE on wp_options - use UPDATE for specific records

### Product Data (NOT in this directory)
**Sensitive product/customer data → stored in `/tmp/` directory**
- File pattern: `/tmp/{yymmdd}-{HHmm}-data.sql`
- Contains product catalogs, pricing, customer records, etc.
- **NEVER committed to git** (covered by .gitignore)
- Manually imported as needed for testing/development
- Excluded from production deployments

## Usage

### Development Environment

```powershell
cd infra/dev
podman-compose down -v
podman-compose up -d
```

Docker automatically imports files from `/docker-entrypoint-initdb.d/` in alphabetical order:
1. `000000-0000-init-db.sql` (baseline)
2. `251222-1430-add-feature.sql` (if exists)
3. `251225-0915-update-config.sql` (if exists)
...and so on

### Production Environment

Same pattern as dev, but only runs on **first deployment** to empty database:

```powershell
cd infra/prod
podman-compose up -d  # Init files imported only if volume is empty
```

### Applying New Changes to Existing Database

If database already exists and you need to apply new change files:

```powershell
# Method 1: Import via podman exec
Get-Content ../shared/db/251222-1430-add-feature.sql | podman exec -i wp-db mysql -u root -ppassword wordpress

# Method 2: Via WP-CLI
podman exec wordpress wp db query "$(Get-Content ../shared/db/251222-1430-add-feature.sql -Raw)"
```

## Creating New Change Files

### Example 1: Schema Change

```sql
-- File: infra/shared/db/251225-1430-add-member-tiers.sql
-- Purpose: Add membership tier support
-- Author: Developer Name
-- Date: 2025-12-25 14:30

ALTER TABLE wp_users 
ADD COLUMN member_tier VARCHAR(20) DEFAULT 'bronze' 
AFTER user_email;

CREATE INDEX idx_member_tier ON wp_users(member_tier);

-- Update existing users
UPDATE wp_users SET member_tier = 'bronze' WHERE member_tier IS NULL;
```

### Example 2: Configuration Change

```sql
-- File: infra/shared/db/260101-1200-enable-maintenance-mode.sql
-- Purpose: Configure site for scheduled maintenance
-- Author: Developer Name
-- Date: 2026-01-01 12:00

INSERT INTO wp_options (option_name, option_value, autoload)
VALUES ('maintenance_mode_enabled', '0', 'yes')
ON DUPLICATE KEY UPDATE option_value = '0';

UPDATE wp_options 
SET option_value = 'https://cdn.example.com/uploads'
WHERE option_name = 'upload_url_path';
```

## Best Practices

1. **Always add a header comment** with purpose, author, and date
2. **Make changes idempotent** - use `IF NOT EXISTS`, `ON DUPLICATE KEY UPDATE`, etc.
3. **Test in dev first** before committing to git
4. **Keep files focused** - one logical change per file
5. **Document dependencies** - note if file requires another file to run first
6. **Avoid destructive operations** in change files (DROP TABLE, TRUNCATE)
7. **Never include sensitive data** - use /tmp/ directory for that
8. **Use timestamp format** - `{yymmdd}-{HHmm}` ensures proper ordering

## Tools for Identifying Database Differences

### 1. VS Code Built-in Diff (Recommended for SQL Files)

**Best for:** Comparing two exported SQL files

```powershell
# Export baseline and current state
cd infra/dev
Get-Content ..\shared\db\000000-00-init.sql > ..\..\tmp\baseline-compare.sql
podman exec wp-db mariadb-dump -u root -ppassword wordpress > ..\..\tmp\current-compare.sql

# In VS Code: Right-click one file → "Select for Compare"
# Then right-click other file → "Compare with Selected"
```

### 2. PowerShell Compare-Object (Quick Text Diff)

**Best for:** Finding changed lines quickly

```powershell
$baseline = Get-Content "infra\shared\db\000000-0000-init-db.sql"
$current = Get-Content "tmp\251227-1149-baseline.sql"

Compare-Object $baseline $current | 
  Where-Object { $_.SideIndicator -eq '=>' } | 
  Select-Object -First 20 InputObject
```

### 3. MySQL Workbench (GUI Schema Comparison)

**Best for:** Visual schema diff, ALTER TABLE generation

1. Download: https://dev.mysql.com/downloads/workbench/
2. Connect to database: `localhost:3306`
3. Database → Synchronize Model
4. Compare schema between exports
5. Generate ALTER TABLE scripts

**Pros:** Visual, generates SQL automatically  
**Cons:** Requires separate installation

### 4. mysqldiff (Command-Line Schema Comparison)

**Best for:** Automated CI/CD pipelines

```bash
# Install MySQL Utilities (not included by default)
pip install mysql-utilities

# Compare two databases or SQL files
mysqldiff --server1=root:password@localhost:3306 \
  --changes-for=server2 \
  wordpress:wordpress

# Or compare SQL dumps
mysqldiff file1.sql file2.sql --difftype=sql
```

**Pros:** Scriptable, precise  
**Cons:** Requires installation, learning curve

> 📋 **Open Action Item:** See [WORDPRESS-OPEN-ACTIONS.md](../../../../Documents/WORDPRESS-OPEN-ACTIONS.md#3-automation--cicd---mysqldiff-integration) for mysqldiff CI/CD integration tasks.

### 5. WP-CLI + jq (Structured Data Comparison)

**Best for:** Comparing specific WordPress options/settings

```powershell
# Export wp_options as JSON
podman exec wordpress wp option list --format=json > tmp\options-before.json
# ... make changes ...
podman exec wordpress wp option list --format=json > tmp\options-after.json

# Compare with jq (install: choco install jq)
jq --slurp 'map(from_entries) | .[0] - .[1]' tmp\options-before.json tmp\options-after.json
```

**Pros:** WordPress-aware, structured output  
**Cons:** Requires jq for JSON diff

### 6. Git Diff (Track Changes Over Time)

**Best for:** Seeing what changed since last commit

```powershell
# Compare current SQL with committed version
git diff infra/shared/db/000000-00-init.sql

# Compare two commits
git diff HEAD~1 HEAD -- infra/shared/db/
```

**Pros:** Free, already have it  
**Cons:** Only works with committed files

### Recommended Workflow

1. **Export current database** to tmp/
2. **Use VS Code diff** to visually compare with combined baseline
3. **Identify changed sections** (look for INSERT, UPDATE patterns)
4. **Extract changes** using PowerShell regex or manual selection
5. **Create incremental delta** with only differences
6. **Test delta** by importing baseline + delta on fresh database

## Migration Checklist

Before creating a new change file:

- [ ] Tested change in local dev environment
- [ ] Change is idempotent (can run multiple times safely)
- [ ] No sensitive data included
- [ ] Used diff tool to verify only intended changes included
- [ ] Delta contains NO DROP TABLE or CREATE TABLE for existing tables
- [ ] Header comment added with context
- [ ] File named with correct pattern: `{yymmdd}-{HHmm}-{action}-{short.desc}.sql`
- [ ] Action verb chosen from approved list (add, update, remove, alter, insert, migrate, fix, enable, disable)
- [ ] Saved in `infra/shared/db/`
- [ ] Committed to version control

## See Also

- [WORDPRESS-DATABASE.md](../../../../Documents/WORDPRESS-DATABASE.md) - Complete database management guide (dev and prod)
- [WORDPRESS-OPEN-ACTIONS.md](../../../../Documents/WORDPRESS-OPEN-ACTIONS.md) - All open action items and TODO tasks

---

## Page ID Dependency Problem

### The Issue

WordPress uses auto-increment integer IDs (`wp_posts.ID`) which differ between environments:
- **Production:** Pages created organically over time (IDs 6, 11, 21, 49, etc.)
- **Local:** Fresh database starts from baseline, new pages get next available IDs (6, 11, 12, 13)
- **Result:** Menu items referencing `page_id=21` (Help in production) break in local where Help is `page_id=11`

### When This Occurs

**Database recreation destroys all data:**
```powershell
podman-compose down -v  # ⚠️ Destroys volume and all database data
podman-compose up -d    # Recreates from baseline SQL only
```

**Baseline SQL (`000000-0000-init-db.sql`) contains:**
- Vanilla WordPress installation (3 default posts/pages)
- Does NOT include production pages (Welcome, Help, Log In, Select Role, etc.)

**Production has 19+ pages that don't exist in baseline:**
- Core pages: Welcome, Help, Log In, Select Role
- Role pages: Employers, Candidates, Scouts, Managers, Operators
- Admin pages: Manager Actions, Manager Admin

### Solution Implemented

**1. Create core pages in delta file** (`260219-1600-create-core-pages.sql`):
- Adds placeholder pages: Welcome, Help, Log In, Select Role
- Sets Welcome as homepage
- Content restored separately from `restore/pages/` backups

**2. Use slug-based menu items** (rebuild-navigation-menu.ps1):
```powershell
# ✅ CORRECT: Use custom links with slug-based URLs
wp menu item add-custom main-navigation "Help" "/help/"

# ❌ WRONG: Use page references (breaks when IDs change)
wp menu item add-post main-navigation 21 --title="Help"
```

**3. Navigation menu uses relative URLs:**
- `/` (Welcome - works as both / and /welcome/)
- `/select-role/` (Register)
- `/help/` (Help)
- `/log-in/` (Login)

### Prevention

**Before database recreation:**
- [ ] Review `infra/shared/db/` to ensure core pages included
- [ ] Update `rebuild-navigation-menu.ps1` if menu structure changed
- [ ] Test full recreation: `podman-compose down -v && podman-compose up -d`
- [ ] Verify menu works: Load https://wp.local/ and click all menu items
- [ ] Check page content restored from `restore/pages/` backups

**Script registry action:**
```powershell
# Rebuild menu after database recreation
pwsh infra/shared/scripts/wp-action.ps1 rebuild-menu
```

**Key Takeaway:** Use slug-based URLs (`/help/`) instead of page IDs (21) for environment-agnostic navigation.

**Full details:** See [docs/lessons/page-id-dependency-problem.md](../../../docs/lessons/page-id-dependency-problem.md)

---

## Custom Roles & Test Users Persistence

### The Issue

WordPress plugin activation and user data are stored in the database, NOT in code. When you run `podman-compose down -v`, everything is lost:
- ❌ Plugin activation status (talendelight-roles becomes inactive)
- ❌ Custom role registration (td_candidate, td_employer, etc. disappear)
- ❌ Test users with custom roles

### Solution

**1. Plugin Activation:** [260219-1630-activate-talendelight-roles.sql](260219-1630-activate-talendelight-roles.sql)
```sql
UPDATE wp_options 
SET option_value = 'a:1:{i:0;s:45:"talendelight-roles/talendelight-roles.php";}' 
WHERE option_name = 'active_plugins';
```

**2. Test Users (Optional):** [260219-1640-create-test-users.sql](260219-1640-create-test-users.sql)
- Creates 5 test users (all password: `Test123!`)
- Uses custom roles: td_candidate, td_employer, td_scout, td_operator, td_manager
- Idempotent with `ON DUPLICATE KEY UPDATE`

**3. Verification:**
```powershell
podman exec wp wp role list --allow-root --format=table
# Should show: Employer, Candidate, Scout, Operator, Manager

podman exec wp wp user list --allow-root --format=table
# Should show: candidate-test, employer-test, scout-test, operator-test, manager-test
```

**Full details:** See [docs/CUSTOM-ROLES-PERSISTENCE.md](../../../docs/CUSTOM-ROLES-PERSISTENCE.md)

