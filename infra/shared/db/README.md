# Database Initialization Files

## Purpose

This directory contains shared SQL initialization files used across all environments (dev, prod, staging).

## File Naming Convention

### `000000-00-init.sql` 
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
- ✅ ONLY include actual changes/additions since previous combined baseline
- ✅ Use `TRUNCATE TABLE` + `INSERT` when updating entire table data (e.g., wp_options)
- ✅ Use `ALTER TABLE` for schema modifications
- ✅ Use `INSERT INTO` for new records only

Examples:
- `251222-1430-add-loyalty-points.sql` - adds loyalty_points column to users table (Dec 22, 2:30 PM)
- `251225-0915-create-orders-index.sql` - adds index for faster order queries (Dec 25, 9:15 AM)
- `251227-1149-update-theme.versions.sql` - updates wp_options with theme configs (TRUNCATE + INSERT pattern)
- `260101-1200-enable-woocommerce-features.sql` - activates specific WooCommerce options (Jan 1, 12:00 PM)

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
1. `000000-00-init.sql` (baseline)
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
$baseline = Get-Content "infra\shared\db\000000-00-init.sql"
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