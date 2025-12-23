# Database Strategy for Development Environment

## Overview

The development environment uses an **ephemeral database approach** where the database is reset to a clean state on every startup. This ensures consistent, reproducible development environments and treats the database as code via version-controlled SQL files.

## Core Principles

1. **000000-init.sql is the source of truth** - All baseline database state is stored in [../shared/init/000000-init.sql](../shared/init/000000-init.sql)
2. **Ephemeral by design** - Database data is NOT persisted between container lifecycles
3. **Clean slate on every startup** - `podman-compose up` always imports fresh data from shared init files
4. **Git-tracked database evolution** - Create separate SQL files in [../shared/init/](../shared/init/) as products/features are added
5. **Sensitive data excluded** - Product/customer data goes in [/tmp/](../../tmp/) directory and is NOT committed to git

## How It Works

### Named Volume Strategy

The [compose.yml](compose.yml) uses a Docker named volume instead of a bind mount:

```yaml
wp-db:
  volumes:
    - db-data:/var/lib/mysql              # Named volume (ephemeral)
    - ../shared/init:/docker-entrypoint-initdb.d  # Auto-imported on startup
```

**Key behaviors:**
- `podman-compose up -d` → Creates fresh database, imports all .sql files from shared/init/
- `podman-compose down -v` → Destroys all data (including database)
- `podman-compose down` → Preserves data until next `-v` or volume deletion
- `podman-compose restart` → Database persists (container restart, not recreation)
- Files imported in alphabetical order: 000000-init.sql, then all {yymmdd}-change.sql files

### Why Not Persistent Storage?

The previous approach used `../../blob/dev/db-data:/var/lib/mysql` which:
- ❌ Only imports SQL files on FIRST run (when folder is empty)
- ❌ Accumulates development data that's hard to track
- ❌ Creates inconsistent states across developer machines
- ❌ Requires manual deletion of `blob/dev/db-data/` to reset

The new approach using shared init:
- ✅ Always starts from a known clean state
- ✅ Forces discipline to document database changes in SQL files
- ✅ Faster to reset (just `podman-compose down -v && podman-compose up -d`)
- ✅ Database schema is version-controlled and portable
- ✅ All environments use same init files (dev, staging, prod)
- ✅ Clear separation: structural changes (git) vs data (not in git)

## Development Workflows

### Starting Fresh (Most Common)

```bash
cd infra/dev
podman-compose down -v    # Remove all containers and volumes
podman-compose up -d      # Start fresh, imports from ../shared/init/
```

### Preserving Data During Development Session

```bash
# Stop without destroying data
podman-compose stop

# Resume later with data intact
podman-compose start
```

### Accessing the Database

**Via phpMyAdmin:**
- URL: http://localhost:8180
- Server: `wp-db`
- Username: `root`
- Password: `password`

**Via MySQL CLI:**
```bash
# From host
mysql -h 127.0.0.1 -P 3306 -u root -ppassword wordpress

# From within container
podman exec -it wp-db mysql -u root -ppassword wordpress
```

**Via WP-CLI:**
```bash
podman exec -it wordpress wp db query "SELECT * FROM wp_options LIMIT 5"
podman exec -it wordpress wp db export /tmp/current.sql
```

## Managing Database Evolution

### SQL File Naming Convention (see [shared/init/README.md](../shared/init/README.md))

**`000000-init.sql`** - Baseline schema (first deployment only)
- Complete WordPress installation with all tables
- Essential configuration and admin user
- Version controlled in git

**`{yymmdd}-change.sql`** - Structural changes
- Schema modifications (ALTER TABLE, CREATE INDEX, etc.)
- Configuration updates (wp_options changes)
- Version controlled in git
- Example: `251222-add-loyalty-system.sql`

**`/tmp/{yymmdd}-data.sql`** - Product/customer data
- Sensitive business data (products, pricing, customers)
- **NOT version controlled** (in .gitignore)
- Manually imported when needed for testing
- Example: `/tmp/251222-data.sql`

### Adding New Products/Features

When developing features that require database changes:

1. **Start from baseline**: Ensure you're using a fresh database
2. **Make changes via WordPress admin**: Add products, configure settings, etc.
3. **Export the structural changes**: 
   - For schema: Create new `{yymmdd}-change.sql` in `../shared/init/`
   - For products: Export to `/tmp/{yymmdd}-data.sql`
4. **Test the import**: `podman-compose down -v && podman-compose up -d`
5. **Commit structural changes to git**: Only files in `../shared/init/`

Example directory structure:
```
infra/shared/init/
├── 000000-init.sql              # Baseline (auto-imported)
├── 251222-add-loyalty-system.sql # Schema change (auto-imported)
├── 251225-woo-tax-settings.sql   # Config change (auto-imported)
└── README.md

tmp/
├── 251222-data.sql              # Product data (manual import, not in git)
└── README.md
```

MariaDB executes files in `/docker-entrypoint-initdb.d/` **in alphabetical order**.
All files in `../shared/init/` are mounted and imported automatically.

### Exporting Current State

**Method 1: phpMyAdmin (for structural changes)**
1. Navigate to http://localhost:8180
2. Select `wordpress` database → Export → Structure only
3. Save to `../shared/init/{yymmdd}-change.sql`
4. Add header comment describing the change
5. Commit to git

**Method 2: phpMyAdmin (for product data)**
1. Navigate to http://localhost:8180
2. Select specific tables (wp_posts, wp_postmeta for products)
3. Export → Data only
4. Save to `/tmp/{yymmdd}-data.sql`
5. Do NOT commit (already in .gitignore)

**Method 3: WP-CLI**
```bash
# Linux/Mac - Full database
podman exec -it wordpress wp db export /tmp/snapshot.sql
podman cp wordpress:/tmp/snapshot.sql ../shared/init/251222-change.sql

# Windows PowerShell - Full database
podman exec -it wordpress wp db export /tmp/snapshot.sql
podman cp wordpress:/tmp/snapshot.sql ..\shared\init\251222-change.sql
```

**Method 4: mysqldump (structural only)**
```bash
# Linux/Mac
podman exec -it wp-db mysqldump -u root -ppassword --no-data wordpress > ../shared/init/251222-schema.sql

# Windows PowerShell
podman exec -it wp-db mysqldump -u root -ppassword --no-data wordpress | Out-File -Encoding utf8 ..\shared\init\251222-schema.sql
```

**Method 5: Export products only to /tmp**
```powershell
# Export WooCommerce products to tmp (not committed)
podman exec -it wp-db mysqldump -u root -ppassword wordpress `
  --tables wp_posts wp_postmeta wp_terms wp_term_relationships `
  --where="post_type IN ('product', 'product_variation')" `
  | Out-File -Encoding utf8 ..\..\tmp\251222-data.sql
```

### Creating Initial 000000-init.sql from Existing Setup

If you have an existing WordPress installation with data you want to preserve:

**Option 1: Export from running database**
```powershell
# From the dev environment
cd infra/dev
podman exec -it wp-db mysqldump -u root -ppassword wordpress | Out-File -Encoding utf8 ..\shared\init\000000-init.sql
```

**Option 2: Import from hosting provider**
1. Download database backup from your hosting provider (cPanel, phpMyAdmin, etc.)
2. Save as `infra/shared/init/000000-init.sql`
3. Search and replace URLs if needed:
   ```sql
   -- Add at top of 000000-init.sql
   UPDATE wp_options SET option_value = 'http://localhost:8080' WHERE option_name = 'siteurl';
   UPDATE wp_options SET option_value = 'http://localhost:8080' WHERE option_name = 'home';
   ```

**Option 3: Convert raw datadir to SQL (legacy migration)**
```powershell
# If you have existing blob/dev/db-data/ raw files
cd infra/dev

# Start temporary MariaDB using the raw datadir
podman run -d --name temp-db `
  -v ${PWD}\..\..\blob\dev\db-data:/var/lib/mysql `
  -e MYSQL_ROOT_PASSWORD=password `
  mariadb:11.8.2-noble

# Wait for database to start (check logs)
podman logs -f temp-db

# Export to SQL
podman exec temp-db mysqldump -u root -ppassword wordpress | Out-File -Encoding utf8 ..\shared\init\000000-init.sql

# Clean up temporary container
podman stop temp-db
podman rm temp-db
```

## Migration Path

### Current State (To Be Removed After Testing)

The `blob/dev/db-data/` directory still exists but is **no longer used** by the updated compose.yml. Once you've validated the ephemeral approach:

1. Verify clean startup works: `podman-compose down -v && podman-compose up -d`
2. Test WordPress functionality with baseline data
3. Manually delete: `rmdir /s blob\dev\db-data` (Windows) or `rm -rf blob/dev/db-data` (Linux/Mac)
4. Update `.gitignore` if needed

### Production Considerations

Production uses a **different strategy** (see `infra/prod/DATABASE.md`):
- Persistent storage for live data (named volumes, not destroyed on restart)
- Automated backups (hosting provider managed or cron jobs)
- Weekly/monthly SQL exports tracked in git for disaster recovery
- Init SQL files only imported on FIRST deployment
- Database migrations managed via plugins (WP Migrate DB, All-in-One WP Migration) or manual SQL scripts

**Key difference from dev:**
- Dev: `podman-compose down -v` is safe and encouraged (clean slate)
- Prod: **NEVER** use `podman-compose down -v` (destroys live customer data)

## Troubleshooting

### Database Not Resetting

**Symptom**: Changes from previous session persist after restart

**Cause**: Volumes not destroyed

**Solution**:
```bash
podman-compose down -v    # Note the -v flag
podman volume ls          # Should NOT show wp-db volume
podman-compose up -d
```

### Init SQL Files Not Importing

**Symptom**: WordPress shows installation wizard

**Causes**:
1. SQL files are malformed (check SQL syntax)
2. Volume already has data (MariaDB only imports on empty database)
3. Files not visible in container mount

**Solutions**:
```bash
# Force complete cleanup
podman-compose down -v
podman volume prune       # Remove all unused volumes
podman-compose up -d

# Verify files are mounted
podman exec -it wp-db ls -la /docker-entrypoint-initdb.d/

# Check 000000-init.sql syntax
podman exec -it wp-db mysql -u root -ppassword wordpress < ../shared/init/000000-init.sql
```

### Slow Startup

**Symptom**: Database takes 30+ seconds to become ready

**Cause**: Large 000000-init.sql or many change files

**Optimization**: 
- Keep 000000-init.sql minimal (essential baseline only)
- Split large data into `/tmp/*.sql` for manual import
- Remove unnecessary test data, logs, transients from init files

## Best Practices

1. **Keep 000000-init.sql minimal** - Only include essential baseline schema and admin user
2. **Version control structural changes** - Commit all files in `../shared/init/` to git
3. **Exclude sensitive data** - Product/customer data goes in `/tmp/` (not committed)
4. **Use descriptive file names** - `{yymmdd}-add-loyalty-points.sql` not `update1.sql`
5. **Add header comments** - Explain purpose, author, date in each change file
6. **Make changes idempotent** - Use `IF NOT EXISTS`, `ON DUPLICATE KEY UPDATE`
7. **Test clean startup regularly** - Verify `podman-compose down -v && podman-compose up -d` works
8. **Document SQL file purpose** - See [shared/init/README.md](../shared/init/README.md) for patterns
9. **Don't commit test data** - Use `/tmp/` for data that changes frequently

## Quick Reference

| Command | Effect |
|---------|--------|
| `podman-compose up -d` | Start with fresh database (if no volume exists) |
| `podman-compose down -v` | Stop and destroy database completely |
| `podman-compose restart` | Restart containers, keep database data |
| `podman-compose stop` | Pause containers, keep data |
| `podman volume ls` | List all volumes (check if db-data exists) |
| `podman volume rm infra_db-data` | Manually remove database volume |
