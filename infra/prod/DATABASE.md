# Database Strategy for Production Environment

## Overview

Production uses a **persistent database strategy** where live customer data is stored in Docker named volumes and backed up regularly. Unlike development, production databases are never intentionally destroyed or reset.

## Core Principles

1. **Named volumes for persistence** - Database survives container restarts and redeployments
2. **No automatic imports** - 000000-init.sql and other init files only run on first deployment to empty volume
3. **Backup and restore procedures** - Regular automated backups to external storage
4. **Environment variable secrets** - No hardcoded passwords in compose files
5. **Dedicated database user** - WordPress uses limited-privilege user, not root

## Production Compose Configuration

The production [compose.yml](compose.yml) is configured for safety:

```yaml
db:
  image: mariadb:11.8.2-noble  # Pinned version
  volumes:
    - db_data:/var/lib/mysql   # Persistent named volume
    - ../shared/init:/docker-entrypoint-initdb.d  # First-run only, all SQL files
  environment:
    - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:?Root password must be set}
    - MYSQL_USER=${MYSQL_USER:-wordpress_user}
    - MYSQL_PASSWORD=${MYSQL_PASSWORD:?Database password must be set}
  ports:
    - "127.0.0.1:3306:3306"  # Only accessible from localhost
  restart: always
```

**Key security features:**
- Passwords loaded from `.env` file (not in git)
- Ports bound to localhost only
- Dedicated non-root database user
- Debug mode disabled

## First Deployment

### Prerequisites

1. Copy `.env.example` to `.env`:
   ```powershell
   cd infra/prod
   Copy-Item .env.example .env
   ```

2. Edit `.env` with strong passwords:
   ```bash
   MYSQL_ROOT_PASSWORD=<generate_secure_random_password>
   MYSQL_USER=wordpress_user
   MYSQL_PASSWORD=<generate_secure_random_password>
   WORDPRESS_DB_PASSWORD=<same_as_MYSQL_PASSWORD>
   ```

3. Prepare `../shared/init/` directory with baseline database:
   - `000000-init.sql`: Export from dev: `podman exec -it wp-db mysqldump -u root -ppassword wordpress > ../shared/init/000000-init.sql`
   - Any `{yymmdd}-change.sql` files for structural changes
   - Or use existing production backup
   - Update URLs in SQL for production domain
   - Do NOT include product/customer data (that goes in `/tmp/` for manual import)

### Deploy

```powershell
cd infra/prod
podman-compose up -d
```

All SQL files in `../shared/init/` will import automatically on first run (when volume is empty), in alphabetical order:
1. `000000-init.sql` (baseline)
2. `251222-change.sql` (if exists)
3. And so on...

## Routine Operations

### Starting/Stopping (Safe)

```powershell
cd infra/prod

# Stop containers (data persists)
podman-compose stop

# Start containers
podman-compose start

# Restart containers (data persists)
podman-compose restart

# Stop and remove containers (data persists in volumes)
podman-compose down
```

**NEVER use `podman-compose down -v` in production** - this destroys all data.

### Updating WordPress or MariaDB Version

```powershell
cd infra/prod

# 1. Backup database first (see Backup section below)

# 2. Update image tag in compose.yml
# Edit: image: wordpress:6.9.0-php8.2-apache

# 3. Pull new images
podman-compose pull

# 4. Recreate containers (data persists)
podman-compose up -d

# 5. Verify WordPress/database work correctly
# 6. If issues, rollback: restore compose.yml and `podman-compose up -d`
```

## Backup Procedures

### Manual Backup

**Full database export:**
```powershell
cd infra/prod

# Create timestamped backup
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
podman exec -it db mysqldump -u root -p${MYSQL_ROOT_PASSWORD} wordpress | `
  Out-File -Encoding utf8 "backups\wordpress-$timestamp.sql"
```

**Backup volumes:**
```powershell
# Stop containers first
podman-compose stop

# Backup database volume
podman run --rm `
  -v prod_db_data:/data `
  -v ${PWD}\backups:/backup `
  alpine tar czf /backup/db-data-backup.tar.gz /data

# Restart
podman-compose start
```

### Automated Backup Script

Create `backup-database.ps1`:

```powershell
#Requires -Version 7.0

param(
    [int]$RetentionDays = 30
)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "backups"
$backupFile = "wordpress-$timestamp.sql"

# Ensure backup directory exists
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

# Load environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}

# Export database
Write-Host "Backing up database to $backupFile..."
podman exec db mysqldump -u root -p$env:MYSQL_ROOT_PASSWORD wordpress | `
  Out-File -Encoding utf8 "$backupDir\$backupFile"

# Compress backup
Write-Host "Compressing backup..."
Compress-Archive -Path "$backupDir\$backupFile" -DestinationPath "$backupDir\$backupFile.zip"
Remove-Item "$backupDir\$backupFile"

# Remove old backups
Write-Host "Cleaning up backups older than $RetentionDays days..."
Get-ChildItem -Path $backupDir -Filter "*.zip" | `
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } | `
  Remove-Item -Force

Write-Host "Backup complete: $backupDir\$backupFile.zip"
```

**Schedule via Windows Task Scheduler:**
- Trigger: Daily at 2:00 AM
- Action: `powershell.exe -File C:\path\to\infra\prod\backup-database.ps1`

### Offsite Backup

After creating local backups, sync to cloud storage:

```powershell
# Example: Azure Blob Storage
az storage blob upload-batch --account-name mystorageaccount `
  --destination backups --source ./backups/

# Example: AWS S3
aws s3 sync ./backups/ s3://my-bucket/wordpress-backups/

# Example: Rsync to remote server
rsync -avz ./backups/ user@backup-server:/backups/wordpress/
```

## Restore Procedures

### From SQL Backup

```powershell
cd infra/prod

# 1. Stop WordPress to prevent writes
podman-compose stop wordpress

# 2. Import SQL backup
$backupFile = "backups\wordpress-20251222-120000.sql"
Get-Content $backupFile | podman exec -i db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress

# 3. Restart all services
podman-compose start
```

### From Volume Backup

```powershell
cd infra/prod

# 1. Stop all services
podman-compose down

# 2. Remove old volume
podman volume rm prod_db_data

# 3. Restore from tar
podman run --rm `
  -v prod_db_data:/data `
  -v ${PWD}\backups:/backup `
  alpine tar xzf /backup/db-data-backup.tar.gz -C /

# 4. Start services
podman-compose up -d
```

## Database Migrations

### Schema Changes

When deploying features that require schema changes:

**Option 1: WordPress plugins**
- Use plugins like "WP Migrate DB" or "All-in-One WP Migration"
- Test in dev environment first

**Option 2: Shared init files (recommended for new deployments)**
- Add new `{yymmdd}-change.sql` to `../shared/init/`
- Test in dev: `podman-compose down -v && podman-compose up -d`
- Commit to git
- On production first deployment, all files import automatically
- For existing prod database, apply manually (see Option 3)

**Option 3: Manual SQL scripts (for existing databases)**
```powershell
cd infra/prod

# Backup first
.\backup-database.ps1

# Apply new migration from shared init
Get-Content ..\shared\init\251222-add-loyalty-points.sql | `
  podman exec -i db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress

# Verify
podman exec -it db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress `
  -e "DESCRIBE wp_users;"
```

**File naming pattern** (see [shared/init/README.md](../shared/init/README.md)):
- `000000-init.sql` - Baseline schema
- `{yymmdd}-change.sql` - Structural changes (ALTER TABLE, CREATE INDEX, etc.)
- `/tmp/{yymmdd}-data.sql` - Product data (manual import, not in git)

## Monitoring and Maintenance

### Check Database Size

```powershell
podman exec -it db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress `
  -e "SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)' FROM information_schema.TABLES WHERE table_schema = 'wordpress' ORDER BY (data_length + index_length) DESC;"
```

### Optimize Tables

```powershell
# Optimize all tables (run during low-traffic periods)
podman exec -it db mysqlcheck -u root -p${MYSQL_ROOT_PASSWORD} --optimize wordpress
```

### Check Replication Status (if using replication)

```powershell
podman exec -it db mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW SLAVE STATUS\G"
```

## Disaster Recovery

### Complete System Failure

1. **Provision new server**
2. **Restore from latest offsite backup:**
   ```powershell
   # Download backup from cloud
   az storage blob download --account-name mystorageaccount `
     --container backups --name wordpress-latest.sql.zip `
     --file latest-backup.sql.zip
   
   # Extract
   Expand-Archive latest-backup.sql.zip
   
   # Deploy fresh stack
   cd infra/prod
   Copy-Item .env.example .env
   # Edit .env with production credentials
   
   podman-compose up -d
   
   # Wait for services to start
   Start-Sleep -Seconds 30
   
   # Import backup
   Get-Content latest-backup.sql | podman exec -i db mysql -u root -p${MYSQL_ROOT_PASSWORD} wordpress
   ```

### Data Corruption

1. Stop services: `podman-compose down`
2. Identify last known good backup
3. Follow restore procedures above
4. Communicate with users about data loss window

## Best Practices

1. **Automate backups** - Schedule daily backups with offsite replication
2. **Test restores regularly** - Verify backups are valid and restorable
3. **Monitor disk space** - Database volumes can grow quickly
4. **Optimize regularly** - Run mysqlcheck monthly during maintenance windows
5. **Document changes** - Keep a log of schema migrations and major updates
6. **Use migrations** - Track database changes in version-controlled SQL scripts
7. **Separate backup storage** - Store backups on different physical/cloud infrastructure
8. **Encrypt backups** - Use encrypted storage for backup files
9. **Monitor performance** - Track slow queries and optimize indexes

## Security Checklist

- [ ] Strong passwords in `.env` (never in compose.yml or git)
- [ ] Database ports bound to localhost only
- [ ] Dedicated database user (not root) for WordPress
- [ ] Regular security updates for MariaDB image
- [ ] Encrypted backups stored offsite
- [ ] Limited SSH/remote access to production server
- [ ] Database connection logs monitored for suspicious activity
- [ ] WordPress debug mode disabled in production

## Troubleshooting

### Database Won't Start

Check logs:
```powershell
podman-compose logs db
```

Common issues:
- Corrupted volume: restore from backup
- Insufficient disk space: free up space or expand volume
- Port conflict: check if another service uses port 3306

### WordPress Can't Connect to Database

1. Verify database is running: `podman-compose ps`
2. Check credentials in `.env` match
3. Test connection:
   ```powershell
   podman exec -it db mysql -u wordpress_user -p${MYSQL_PASSWORD} wordpress
   ```

### Slow Database Performance

1. Check table sizes (see Monitoring section)
2. Optimize tables: `mysqlcheck --optimize`
3. Consider increasing MariaDB memory limits in compose.yml
4. Add database caching (Redis/Memcached)

## Contact and Escalation

For production database emergencies:
1. Check this documentation first
2. Review recent backup status
3. Contact hosting provider support if infrastructure issue
4. Escalate to senior developer for data corruption/loss scenarios

**Remember**: Production data is irreplaceable. Always backup before making changes.
