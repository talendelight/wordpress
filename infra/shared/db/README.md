# Database Initialization Files

## Purpose

This directory contains shared SQL initialization files used across all environments (dev, prod, staging).

## File Naming Convention

### `000000-init.sql` 
**First deployment / environment setup only**
- Complete baseline database schema and initial configuration
- Includes all WordPress core tables, plugin tables, and essential settings
- Run automatically on first container startup when database volume is empty
- Version controlled in git
- Contains NO sensitive product data

### `{yymmdd}-change.sql`
**Structural changes and metadata updates**
- Schema changes (ALTER TABLE, CREATE TABLE, DROP TABLE)
- Plugin/theme activation state changes
- Configuration changes (wp_options updates)
- Version controlled in git
- Executed in chronological order during deployments

Examples:
- `251222-add-loyalty-points.sql` - adds loyalty_points column to users table
- `251225-create-orders-index.sql` - adds index for faster order queries
- `260101-enable-woocommerce-features.sql` - activates specific WooCommerce options

### Product Data (NOT in this directory)
**Sensitive product/customer data → stored in `/tmp/` directory**
- File pattern: `/tmp/{yymmdd}-data.sql`
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
1. `000000-init.sql` (baseline)
2. `251222-change.sql` (if exists)
3. `251225-change.sql` (if exists)
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
Get-Content ../shared/db/251222-change.sql | podman exec -i wp-db mysql -u root -ppassword wordpress

# Method 2: Via WP-CLI
podman exec wordpress wp db query "$(Get-Content ../shared/db/251222-change.sql -Raw)"
```

## Creating New Change Files

### Example 1: Schema Change

```sql
-- File: infra/shared/db/251225-add-member-tiers.sql
-- Purpose: Add membership tier support
-- Author: Developer Name
-- Date: 2025-12-25

ALTER TABLE wp_users 
ADD COLUMN member_tier VARCHAR(20) DEFAULT 'bronze' 
AFTER user_email;

CREATE INDEX idx_member_tier ON wp_users(member_tier);

-- Update existing users
UPDATE wp_users SET member_tier = 'bronze' WHERE member_tier IS NULL;
```

### Example 2: Configuration Change

```sql
-- File: infra/shared/db/260101-enable-maintenance-mode.sql
-- Purpose: Configure site for scheduled maintenance
-- Author: Developer Name
-- Date: 2026-01-01

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

## Migration Checklist

Before creating a new change file:

- [ ] Tested change in local dev environment
- [ ] Change is idempotent (can run multiple times safely)
- [ ] No sensitive data included
- [ ] Header comment added with context
- [ ] File named with correct pattern: `{yymmdd}-descriptive-name.sql`
- [ ] Saved in `infra/shared/db/`
- [ ] Committed to version control

## See Also

- [docs/DATABASE.md](../../../docs/DATABASE.md) - Complete database management guide (dev and prod)
