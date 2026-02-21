# WordPress Command Registry

**⚠️ USE THIS REGISTRY FIRST - Avoid reinventing commands**

This registry contains proven, tested commands for common WordPress operations. Always check here before creating new commands to avoid:
- ❌ Reinventing existing solutions
- ❌ Running discovery commands unnecessarily
- ❌ Creating commands with known issues (encoding, stderr handling, etc.)

## Container Names Reference

**Always use these container names - NEVER run discovery commands:**

- **`wp`** - WordPress 6.9.1 container (PHP 8.3, Apache)
- **`wp-db`** - MariaDB 12.2.2 database container
- **`wp-phpmyadmin`** - phpMyAdmin web interface (rarely used)

**Container access patterns:**
```powershell
# WordPress container (WP-CLI, PHP)
podman exec wp <command>
podman exec wp wp <wp-cli-command> --allow-root --skip-plugins

# Database container (SQL queries)
podman exec wp-db mariadb -u root -ppassword wordpress -e "<sql-query>"

# Interactive shell
podman exec -it wp bash
podman exec -it wp-db bash
```

---

## User Management

### List all users
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, user_login, user_email, user_registered FROM wp_users"
```

### Check specific user exists
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, user_login, user_email FROM wp_users WHERE user_login = '<username>'"
```

### Reset user password
```powershell
# Use --skip-plugins to avoid PHP warnings from wp-user-manager
podman exec wp wp user update <username> --user_pass="<password>" --allow-root --skip-plugins
```
**Note:** Test users use password `Test123!` (capital T, exclamation mark)

### Get user details
```powershell
podman exec wp wp user get <username> --allow-root --skip-plugins --format=json
```

### Create new user
```powershell
podman exec wp wp user create <username> <email> --role=<role> --user_pass="<password>" --allow-root --skip-plugins
```

---

## Database Queries

### Check pages exist
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, post_title, post_name, post_status FROM wp_posts WHERE post_type='page' ORDER BY ID"
```

### Check plugins activated
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT option_value FROM wp_options WHERE option_name = 'active_plugins'"
```

### Check custom roles
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT option_value FROM wp_options WHERE option_name = 'wp_user_roles'"
```

### Apply SQL migration
```powershell
pwsh infra/shared/scripts/wp-action.ps1 apply-sql -SqlFilePath infra/shared/db/<filename>.sql
```

### Backup database
```powershell
podman exec wp-db mariadb-dump -u root -ppassword wordpress > tmp/backup-$(Get-Date -Format 'yyyyMMdd-HHmm').sql
```

---

## WordPress Operations

### List plugins
```powershell
podman exec wp wp plugin list --allow-root --skip-plugins
```

### Activate plugin
```powershell
podman exec wp wp plugin activate <plugin-name> --allow-root --skip-plugins
```

### List themes
```powershell
podman exec wp wp theme list --allow-root --skip-plugins
```

### Clear cache
```powershell
podman exec wp wp cache flush --allow-root --skip-plugins
```

### Regenerate permalinks
```powershell
podman exec wp wp rewrite flush --allow-root --skip-plugins
```

### Check WordPress version
```powershell
podman exec wp wp core version --allow-root --skip-plugins
```

---

## Backup & Restore

### Backup production (MANDATORY before deployment)
```powershell
pwsh infra/shared/scripts/wp-action.ps1 backup
```

### Verify production state
```powershell
pwsh infra/shared/scripts/wp-action.ps1 verify
```

### Restore from backup
```powershell
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
```

### Export Elementor pages
```powershell
pwsh infra/shared/scripts/wp-action.ps1 export-elementor
```

### Health check
```powershell
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
```

---

## Page Management

### Export page content
```powershell
podman exec wp bash -c "wp post get <PAGE_ID> --field=post_content --allow-root 2>/dev/null" | Out-File -Encoding utf8 restore/pages/<page-name>-<ID>.html
```

### Get page ID from slug
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, post_title FROM wp_posts WHERE post_name = '<slug>' AND post_type = 'page'"
```

### List all pages
```powershell
podman exec wp wp post list --post_type=page --allow-root --skip-plugins --format=table
```

---

## Container Management

### Start containers
```powershell
cd infra/dev && podman-compose up -d
```

### Stop containers (preserves data)
```powershell
cd infra/dev && podman-compose stop
```

### Restart containers
```powershell
cd infra/dev && podman-compose restart
```

### Reset database (destroys volume)
```powershell
cd infra/dev && podman-compose down -v && podman-compose up -d
```

### View logs
```powershell
podman logs wp
podman logs wp-db
```

---

## Debugging

### Check PHP version
```powershell
podman exec wp php -v
```

### Check for PHP errors
```powershell
podman logs wp 2>&1 | Select-String "error|warning|fatal" -Context 2
```

### Test database connection
```powershell
podman exec wp-db mariadb -u root -ppassword -e "SHOW DATABASES;"
```

### Check file permissions
```powershell
podman exec wp ls -la wp-content/
```

### WP-CLI info
```powershell
podman exec wp wp cli info --allow-root --skip-plugins
```

---

## Critical Patterns

### ✅ Always Do:
- Use `--allow-root` for wp-cli commands in containers
- Use `--skip-plugins` to avoid PHP deprecation warnings from wp-user-manager
- Use `2>/dev/null` or `2>&1` for stderr handling in bash
- Use `-Encoding utf8` in PowerShell `Out-File` to prevent corruption
- Quote passwords and special characters in SQL queries

### ❌ Never Do:
- NEVER use `wp-cli` stdin pipes for large content (causes corruption)
- NEVER use `2>$null` on Windows (creates C:\dev\null file) - use bash wrapper instead
- NEVER run `podman ps` or container discovery commands (use container names above)
- NEVER reinvent commands - check this registry first

---

## Usage Notes

### When to Check This Registry:
- ✅ Before writing any podman/wp-cli command
- ✅ When troubleshooting user/password issues
- ✅ When querying database
- ✅ When managing pages/plugins/themes
- ✅ Before creating new scripts

### Command Patterns:
All WP-CLI commands follow this pattern:
```powershell
podman exec wp wp <command> --allow-root --skip-plugins [additional-flags]
```

All database queries follow this pattern:
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "<sql-query>"
```

### Adding New Commands:
When you discover a new useful command pattern:
1. Add it to the appropriate section in this file
2. Include usage notes and known issues
3. Test it thoroughly before adding
4. Document any critical flags or patterns
