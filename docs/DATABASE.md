# Database Management Guide

This guide covers database strategies for both development and production environments. The core principle is **SQL-based version control** - database schema and structure are tracked in git via SQL files.

## Quick Reference

| Environment | Strategy | Data Persistence | Reset Method |
|-------------|----------|------------------|--------------|
| **Development** | Ephemeral | Reset on `down -v` | `podman-compose down -v && up -d` |
| **Production** | Persistent | Survives restarts | Never use `-v` flag |

## Core Concepts

### SQL File Strategy

All environments use [infra/shared/db/](../infra/shared/db/) as the source of truth:

- **`000000-00-init.sql`** - Baseline WordPress schema (complete installation)
- **`{yymmdd}-change.sql`** - Structural changes (ALTER TABLE, CREATE INDEX, etc.)
- **`/tmp/{yymmdd}-data.sql`** - Sensitive product/customer data (not in git)

See [infra/shared/db/README.md](../infra/shared/db/README.md) for detailed naming conventions.

### How It Works

**First deployment** (empty database volume):
1. MariaDB container starts
2. All `.sql` files in `/docker-entrypoint-initdb.d/` are executed alphabetically
3. `000000-00-init.sql` creates baseline schema
4. All `{yymmdd}-change.sql` files apply structural updates
5. WordPress is ready

**Subsequent restarts** (existing data):
- Dev: Volume destroyed on `down -v`, reimports all SQL files
- Prod: Volume persists, SQL files are ignored (already initialized)

---

## Development Environment

### Philosophy

Development uses **ephemeral databases** - every `podman-compose down -v` destroys all data and the next `up` starts fresh from SQL files. This ensures:

✅ Consistent baseline across all developers  
✅ Database changes are code (version-controlled SQL)  
✅ Fast reset for testing: `podman-compose down -v && up -d`  
✅ No data drift or accumulated test garbage

### Configuration

[infra/dev/compose.yml](../infra/dev/compose.yml) uses a named volume:

```yaml
wp-db:
  volumes:
    - db-data:/var/lib/mysql              # Ephemeral named volume
    - ../shared/db:/docker-entrypoint-initdb.d  # Auto-imported on startup
```

### Common Workflows

#### Starting Fresh (Most Common)

```powershell
cd infra/dev
podman-compose down -v    # Destroy containers and volumes
podman-compose up -d      # Start fresh, imports all SQL from ../shared/db/
```

#### Preserving Data During Development Session

```powershell
# Stop without destroying data
podman-compose stop

# Resume later with data intact
podman-compose start

# Restart containers (data persists)
podman-compose restart
```

#### Accessing the Database

**phpMyAdmin:**
- URL: http://localhost:8180
- Server: `wp-db`
- Username: `root`
- Password: `password`

**MySQL CLI from host:**
```powershell
mysql -h 127.0.0.1 -P 3306 -u root -ppassword wordpress
```

**MySQL CLI from container:**
```powershell
podman exec -it wp-db mysql -u root -ppassword wordpress
```

**WP-CLI queries:**
```powershell
podman exec -it wordpress wp db query "SELECT * FROM wp_options LIMIT 5"
podman exec -it wordpress wp db export /tmp/current.sql
```

### Making Database Changes

### Database Change Workflow

When developing features that require database modifications:

#### Step 1: Export Current State to tmp/

Always export database snapshots to the tmp/ folder for comparison:

```powershell
cd infra/dev

# Export complete database with timestamp
$timestamp = Get-Date -Format 'yyMMdd-HHmm'
podman exec -it wp-db mysqldump -u root -ppassword wordpress | `
  Out-File -Encoding utf8 ..\..\tmp\$timestamp-change.sql

# Example: tmp/251226-1430-change.sql
```

#### Step 2: Decide on Change Type

You'll be asked: **Replace baseline or create delta?**

**Option A: Replace Baseline** (for major changes or fresh baseline)
- Replace `infra/shared/db/000000-00-init.sql` with tmp snapshot
- Use when: Starting fresh, major schema overhaul, or initial setup

**Option B: Create Delta File** (for incremental changes)
- Compare baseline with tmp snapshot
- Extract only the differences (new tables, altered columns, new data)
- Save to `infra/shared/db/{yymmdd}-{HHmm}-change-{short.desc}.sql`
- Use when: Adding features, schema changes, configuration updates

#### Step 3: Create Delta (if Option B chosen)

```powershell
# Manual approach: Use diff tool or mysqldiff
# Compare infra/shared/db/000000-00-init.sql with tmp/{yymmdd}-{HHmm}-baseline.sql

# Extract only new/changed elements:
# - New CREATE TABLE statements
# - ALTER TABLE statements
# - New INSERT INTO wp_options (for settings)
# - New wp_posts entries (for pages/products)

# Save delta to infra/shared/db/{yymmdd}-{HHmm}-change-{short.desc}.sql
```

#### Step 4: Test Import

```powershell
# Reset and test from clean state
podman-compose down -v
podman-compose up -d

# Verify both baseline and deltas imported
podman exec -it wordpress wp db check
```

#### Step 5: Commit Changes

```powershell
# For delta files
git add infra/shared/db/{yymmdd}-{HHmm}-change-{short.desc}.sql
git commit -m "feat: add loyalty points feature"

# For baseline replacement
git add infra/shared/db/000000-00-init.sql
git commit -m "chore: update database baseline"
```

### Legacy Export Methods

**For schema-only exports** (commit to git):
```powershell
# Export structure only
podman exec -it wp-db mysqldump -u root -ppassword --no-data wordpress | `
  Out-File -Encoding utf8 ..\shared\db\251225-add-loyalty-tables.sql
```

**For product data** (manual import, not in git):
```powershell
# Export WooCommerce products to /tmp
podman exec -it wp-db mysqldump -u root -ppassword wordpress `
  --tables wp_posts wp_postmeta `
  --where="post_type='product'" | `
  Out-File -Encoding utf8 ..\..\tmp\251225-data.sql
```

### Exporting Current Database

**Method 1: Full export via mysqldump**
```powershell
podman exec -it wp-db mysqldump -u root -ppassword wordpress | `
  Out-File -Encoding utf8 ..\shared\db\000000-00-init.sql
```

**Method 2: phpMyAdmin export**
1. Navigate to http://localhost:8180
2. Select `wordpress` database → Export
3. Structure only for schema, Data only for products
4. Save to appropriate location (../shared/db/ or /tmp/)

**Method 3: WP-CLI**
```powershell
podman exec -it wordpress wp db export /tmp/snapshot.sql
podman cp wordpress:/tmp/snapshot.sql ..\\shared\\db\\251225-snapshot.sql
```

### Troubleshooting Dev Database

**Database not resetting:**
```powershell
podman-compose down -v    # Note the -v flag!
podman volume ls          # Should NOT show dev_db-data
podman-compose up -d
```

**Init SQL files not importing:**
```powershell
# Verify files are mounted
podman exec -it wp-db ls -la /docker-entrypoint-initdb.d/

# Check SQL syntax
podman exec -it wp-db mysql -u root -ppassword < ../shared/db/000000-00-init.sql
```

**Slow startup:**
- Keep `000000-00-init.sql` minimal (baseline only)
- Move large product data to `/tmp/*.sql` for manual import

---

## Production Environment

### Philosophy

Production uses **persistent databases** - live customer data survives container restarts and redeployments. SQL init files only run on first deployment to an empty volume.

⚠️ **NEVER use `podman-compose down -v` in production** - this destroys all live data.

### Configuration

[infra/prod/compose.yml](../infra/prod/compose.yml) with environment-based secrets:

```yaml
db:
  image: mariadb:11.8.3-noble
  volumes:
    - db_data:/var/lib/mysql   # Persistent named volume
    - ../shared/db:/docker-entrypoint-initdb.d  # First-run only
  environment:
    - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:?Required}
    - MYSQL_USER=${MYSQL_USER:-wordpress_user}
    - MYSQL_PASSWORD=${MYSQL_PASSWORD:?Required}
  ports:
    - "127.0.0.1:3306:3306"  # Localhost only
  restart: always
```

**Security features:**
- Passwords from `.env` file (not in git)
- Ports bound to localhost only
- Dedicated non-root database user
- Debug mode disabled

### First Deployment

1. **Create `.env` file:**
   ```powershell
   cd infra/prod
   Copy-Item .env.example .env
   # Edit with strong passwords
   ```

2. **Prepare baseline SQL:**
   - Export from dev: `podman exec -it wp-db mysqldump -u root -ppassword wordpress > ../shared/db/000000-00-init.sql`
   - Or use existing backup
   - Update URLs for production domain

3. **Deploy:**
   ```powershell
   podman-compose up -d
   ```
   All SQL files in `../shared/db/` import automatically on first run.

### Routine Operations

**Safe operations** (data persists):
```powershell
podman-compose stop      # Pause containers
podman-compose start     # Resume containers
podman-compose restart   # Restart containers
podman-compose down      # Stop and remove containers (volume persists)
```

**Updating WordPress/MariaDB:**
```powershell
# 1. Backup first (see Backup section)
# 2. Update image tag in compose.yml
# 3. Pull new images
podman-compose pull
# 4. Recreate containers (data persists)
podman-compose up -d
```

### Backup Procedures

**Manual backup:**
```powershell
cd infra/prod
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
podman exec -it db mysqldump -u root -p${MYSQL_ROOT_PASSWORD} wordpress | `
  Out-File -Encoding utf8 "backups\wordpress-$timestamp.sql"
```

**Backup volume data:**
```powershell
podman-compose stop
podman run --rm `
  -v prod_db_data:/data `
  -v ${PWD}\backups:/backup `
  alpine tar czf /backup/db-data-backup.tar.gz /data
podman-compose start
```

**Automated backup script** (`backup-database.ps1`):
```powershell
param([int]$RetentionDays = 30)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "backups"

# Export database
podman exec db mysqldump -u root -p$env:MYSQL_ROOT_PASSWORD wordpress | `
  Out-File -Encoding utf8 "$backupDir\wordpress-$timestamp.sql"

# Compress
Compress-Archive -Path "$backupDir\wordpress-$timestamp.sql" `
  -DestinationPath "$backupDir\wordpress-$timestamp.sql.zip"
Remove-Item "$backupDir\wordpress-$timestamp.sql"

# Cleanup old backups
Get-ChildItem -Path $backupDir -Filter "*.zip" | `
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } | `
  Remove-Item -Force
```

**Schedule with Windows Task Scheduler:**
- Trigger: Daily at 2:00 AM
- Action: `powershell.exe -File C:\path\to\infra\prod\backup-database.ps1`

**Offsite backup:**
```powershell
# Azure Blob Storage
az storage blob upload-batch --account-name mystorageaccount `
  --destination backups --source ./backups/

# AWS S3
aws s3 sync ./backups/ s3://my-bucket/wordpress-backups/

# Rsync to remote server
rsync -avz ./backups/ user@backup-server:/backups/wordpress/
```

### Restore Procedures

**From SQL backup:**
```powershell
cd infra/prod
podman-compose stop wordpress  # Prevent writes
Get-Content backups\wordpress-20251222-120000.sql | `
  podman exec -i db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress
podman-compose start
```

**From volume backup:**
```powershell
podman-compose down
podman volume rm prod_db_data
podman run --rm `
  -v prod_db_data:/data `
  -v ${PWD}\backups:/backup `
  alpine tar xzf /backup/db-data-backup.tar.gz -C /
podman-compose up -d
```

### Database Migrations

**Option 1: WordPress plugins**
- Use "WP Migrate DB" or "All-in-One WP Migration"
- Test in dev first

**Option 2: Shared db files** (for new deployments)
- Add `{yymmdd}-change.sql` to `../shared/db/`
- Test in dev: `podman-compose down -v && up -d`
- Commit to git
- Imports automatically on first production deployment

**Option 3: Manual SQL scripts** (for existing databases)
```powershell
cd infra/prod
.\backup-database.ps1  # Always backup first!

Get-Content ..\shared\db\251222-add-loyalty-points.sql | `
  podman exec -i db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress

# Verify
podman exec -it db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress `
  -e "DESCRIBE wp_loyalty_points;"
```

### Monitoring

**Check database size:**
```powershell
podman exec -it db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress `
  -e "SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)' FROM information_schema.TABLES WHERE table_schema = 'wordpress' ORDER BY (data_length + index_length) DESC;"
```

**Optimize tables:**
```powershell
podman exec -it db mysqlcheck -u root -p${MYSQL_ROOT_PASSWORD} --optimize wordpress
```

### Disaster Recovery

1. Provision new server
2. Download latest offsite backup
3. Deploy fresh stack with `.env` credentials
4. Import backup: `Get-Content backup.sql | podman exec -i db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress`

### Production Best Practices

✅ Automate daily backups with offsite replication  
✅ Test restore procedures monthly  
✅ Monitor disk space (database volumes grow quickly)  
✅ Optimize tables monthly during maintenance windows  
✅ Track schema changes in version-controlled SQL files  
✅ Encrypt backup storage  
✅ Monitor slow queries and optimize indexes  

### Security Checklist

- [ ] Strong passwords in `.env` (never in compose.yml or git)
- [ ] Database ports bound to localhost only
- [ ] Dedicated database user (not root) for WordPress
- [ ] Regular security updates for MariaDB image
- [ ] Encrypted backups stored offsite
- [ ] Limited SSH/remote access
- [ ] Database connection logs monitored
- [ ] WordPress debug mode disabled

### Troubleshooting Production

**Database won't start:**
```powershell
podman-compose logs db
```
Common causes: corrupted volume, disk space, port conflict

**WordPress can't connect:**
1. Verify database running: `podman-compose ps`
2. Check credentials in `.env`
3. Test connection: `podman exec -it db mysql -u wordpress_user -p${MYSQL_PASSWORD} wordpress`

**Slow performance:**
1. Check table sizes (see Monitoring section)
2. Optimize: `mysqlcheck --optimize`
3. Consider Redis/Memcached caching

---

## Best Practices (All Environments)

1. **Keep 000000-00-init.sql minimal** - Baseline schema and admin user only
2. **Version control structural changes** - Commit `../shared/db/*.sql` to git
3. **Exclude sensitive data** - Product/customer data goes in `/tmp/` (gitignored)
4. **Use descriptive filenames** - `251222-add-loyalty-points.sql` not `update1.sql`
5. **Add header comments** - Document purpose, author, date in each SQL file
6. **Make changes idempotent** - Use `IF NOT EXISTS`, `ON DUPLICATE KEY UPDATE`
7. **Test in dev first** - Always validate with `podman-compose down -v && up -d`
8. **Separate structure from data** - Schema in git, data in `/tmp/` or backups

---

## Additional Resources

- [infra/shared/db/README.md](../infra/shared/db/README.md) - SQL file naming conventions
- [infra/dev/compose.yml](../infra/dev/compose.yml) - Development configuration
- [infra/prod/compose.yml](../infra/prod/compose.yml) - Production configuration
- [docs/SECURITY.md](SECURITY.md) - Security scanning and hardening
- [docs/DEPLOYMENT.md](DEPLOYMENT.md) - Deployment to external hosting
