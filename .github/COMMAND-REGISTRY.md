# WordPress Command Registry

**⚠️ USE THIS REGISTRY FIRST - Avoid reinventing commands**

This registry contains proven, tested commands for common WordPress operations. Always check here before creating new commands to avoid:
- ❌ Reinventing existing solutions
- ❌ Running discovery commands unnecessarily
- ❌ Creating commands with known issues (encoding, stderr handling, etc.)

**Environment Legend:**
- 🏠 **LOCAL** - Runs in local development (Podman containers)
- 🌐 **PRODUCTION** - Runs on Hostinger (SSH required)
- 🔄 **BOTH** - Separate commands for each environment

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
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, user_login, user_email, user_registered FROM wp_users"
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query 'SELECT ID, user_login, user_email, user_registered FROM wp_users'"
```

### Check specific user exists
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, user_login, user_email FROM wp_users WHERE user_login = '<username>'"
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query \"SELECT ID, user_login, user_email FROM wp_users WHERE user_login = '<username>'\""
```

### Reset user password
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
# Use --skip-plugins to avoid PHP warnings from wp-user-manager
podman exec wp wp user update <username> --user_pass="<password>" --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp user update <username> --user_pass='<password>' --allow-root --skip-plugins"
```

**Note:** Test users use password `Test123!` (capital T, exclamation mark)

### Get user details
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp user get <username> --allow-root --skip-plugins --format=json
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp user get <username> --allow-root --skip-plugins --format=json"
```

### Create new user
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp user create <username> <email> --role=<role> --user_pass="<password>" --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp user create <username> <email> --role=<role> --user_pass='<password>' --allow-root --skip-plugins"
```

---

## Database Queries

### Check pages exist
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, post_title, post_name, post_status FROM wp_posts WHERE post_type='page' ORDER BY ID"
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/hireaccord.com/public_html && wp db query 'SELECT ID, post_title, post_name, post_status FROM wp_posts WHERE post_type=\"page\" ORDER BY ID'"
```

### Check plugins activated
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT option_value FROM wp_options WHERE option_name = 'active_plugins'"
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query 'SELECT option_value FROM wp_options WHERE option_name = \"active_plugins\"'"
```

### Check custom roles
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT option_value FROM wp_options WHERE option_name = 'wp_user_roles'"
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query 'SELECT option_value FROM wp_options WHERE option_name = \"wp_user_roles\"'"
```

### Apply SQL migration
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
pwsh infra/shared/scripts/wp-action.ps1 apply-sql -SqlFilePath infra/shared/db/<filename>.sql
```

**Production:**
```bash
# Upload SQL file first
scp -P 65002 -i "tmp\hostinger_deploy_key" "infra/shared/db/<filename>.sql" u909075950@45.84.205.129:/tmp/

# Apply migration
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query < /tmp/<filename>.sql && rm /tmp/<filename>.sql"
```

### Backup database
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb-dump -u root -ppassword wordpress > tmp/backup-$(Get-Date -Format 'yyyyMMdd-HHmm').sql
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db export /tmp/backup-\$(date +%y%m%d-%H%M).sql" && scp -P 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129:/tmp/backup-*.sql tmp/
```

---

## WordPress Operations

### List plugins
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp plugin list --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin list --allow-root --skip-plugins"
```

### Activate plugin
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp plugin activate <plugin-name> --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin activate <plugin-name> --allow-root --skip-plugins"
```

### List themes
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp theme list --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp theme list --allow-root --skip-plugins"
```

### Clear cache
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp cache flush --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cache flush --allow-root --skip-plugins"
```

### Regenerate permalinks
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp rewrite flush --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp rewrite flush --allow-root --skip-plugins"
```

### Check WordPress version
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp core version --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp core version --allow-root --skip-plugins"
```

---

## Backup & Restore

### Backup production (MANDATORY before deployment)
**Environment:** 🌐 PRODUCTION

```powershell
pwsh infra/shared/scripts/wp-action.ps1 backup
```

**Note:** Creates timestamped backup in restore/backups/ with pages, options, theme files, and optionally database.

### Verify production state
**Environment:** 🌐 PRODUCTION

```powershell
pwsh infra/shared/scripts/wp-action.ps1 verify
```

**Note:** Runs 18+ validation checks (pages, plugins, users, security, performance).

### Restore from backup
**Environment:** 🌐 PRODUCTION

```powershell
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
```

**Options:**
- `-BackupTimestamp` - Specific backup or 'latest'
- `-RestorePages` - Restore page content
- `-RestoreOptions` - Restore wp_options
- `-RestoreDatabase` - Full database restore

### Export Elementor pages
**Environment:** 🏠 LOCAL

```powershell
pwsh infra/shared/scripts/wp-action.ps1 export-elementor
```

**Note:** Exports Elementor page data to tmp/elementor-exports/ for deployment.

### Health check
**Environment:** 🌐 PRODUCTION

```powershell
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
```

**Note:** Comprehensive health check including security, performance, and configuration validation.

---

## Page Management

### Export page content
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp bash -c "wp post get <PAGE_ID> --field=post_content --allow-root 2>/dev/null" | Out-File -Encoding utf8 restore/pages/<page-name>-<ID>.html
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/hireaccord.com/public_html && wp post get <PAGE_ID> --field=post_content --allow-root --skip-plugins" > tmp/<page-name>-prod-<ID>.html
```

### Get page ID from slug
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT ID, post_title FROM wp_posts WHERE post_name = '<slug>' AND post_type = 'page'"
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/hireaccord.com/public_html && wp db query 'SELECT ID, post_title FROM wp_posts WHERE post_name = \"<slug>\" AND post_type = \"page\"'"
```

### List all pages
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp post list --post_type=page --allow-root --skip-plugins --format=table
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/hireaccord.com/public_html && wp post list --post_type=page --allow-root --skip-plugins --format=table"
```

### Deploy page content (Complete Workflow)

**✅ RECOMMENDED: Unified Deployment Script**

**Deploy to any environment with single script:**
```powershell
# Deploy to production
pwsh infra/shared/scripts/wp-action.ps1 deploy-pages -Environment Production -PageNames 'privacy-policy','cookie-policy'

# Deploy all pages to production
pwsh infra/shared/scripts/wp-action.ps1 deploy-pages -Environment Production

# Restore to local (development/testing)
pwsh infra/shared/scripts/wp-action.ps1 restore-pages -PageNames 'welcome'

# Dry run to preview changes
pwsh infra/shared/scripts/wp-action.ps1 deploy-pages -Environment Production -DryRun
```

**Features:**
- ✅ Single script for all environments (Local + Production)
- ✅ Finds pages by slug dynamically (no ID mapping needed)
- ✅ Creates pages if they don't exist
- ✅ Slug is stable identifier across environments
- ✅ Environment-specific execution (podman for Local, SSH for Production)
- ✅ Flushes caches automatically
- ✅ Supports dry-run mode

**Script:** [infra/shared/scripts/deploy-pages.ps1](../infra/shared/scripts/deploy-pages.ps1)  
**Task:** See [TASK-REGISTRY.md: Deploy WordPress Page to Production](TASK-REGISTRY.md#task-deploy-wordpress-page-to-production)

---

### Deploy page content (Manual Method - Legacy)
**⚠️ MANUAL METHOD - Use repeatable script above instead**

**Step 1: Create PHP deployment script**
```powershell
$pageId = 21  # Change to target page ID
$htmlFile = "register-profile-custom-form.html"  # Change to your HTML file

$phpScript = @"
<?php
require_once('/var/www/html/wp-load.php');
`$post_id = $pageId;
`$content = file_get_contents('/tmp/$htmlFile');
`$result = wp_update_post(array(
    'ID' => `$post_id,
    'post_content' => `$content
));
if (`$result) {
    echo "Successfully updated page `$post_id\n";
    echo "Content size: " . strlen(`$content) . " bytes\n";
} else {
    echo "Failed to update page\n";
}
"@

$phpScript | Out-File -Encoding utf8 tmp/update-page.php -Force
```

**Step 2: Deploy to database**
```powershell
# Copy HTML and PHP script to container
podman cp tmp/$htmlFile wp:/tmp/
podman cp tmp/update-page.php wp:/tmp/

# Execute deployment
podman exec wp php /tmp/update-page.php

# Flush cache
podman exec wp wp cache flush --allow-root --skip-plugins
```

**Step 3: Update backup**
```powershell
Copy-Item tmp/$htmlFile restore/pages/<page-name>-<ID>.html -Force

# Verify backup
Get-FileHash restore/pages/<page-name>-<ID>.html | Select-Object Algorithm, Hash, @{Name="Size";Expression={(Get-Item $_.Path).Length}}
```

**One-Liner (All Steps Combined):**
```powershell
# Set variables
$pageId = 21; $htmlFile = "register-profile-custom-form.html"; $backupFile = "register-profile.html"

# Create PHP script
$phpScript = @"
<?php
require_once('/var/www/html/wp-load.php');
`$post_id = $pageId;
`$content = file_get_contents('/tmp/$htmlFile');
`$result = wp_update_post(array('ID' => `$post_id, 'post_content' => `$content));
echo (`$result ? "✓ Updated page `$post_id\n" : "✗ Failed\n");
echo "Size: " . strlen(`$content) . " bytes\n";
"@
$phpScript | Out-File -Encoding utf8 tmp/update-page.php -Force

# Deploy + Cache + Backup
Copy-Item tmp/$htmlFile restore/pages/$backupFile -Force; podman cp tmp/$htmlFile wp:/tmp/; podman cp tmp/update-page.php wp:/tmp/; podman exec wp php /tmp/update-page.php; podman exec wp wp cache flush --allow-root --skip-plugins
```

**Why This Approach:**
- ✅ Uses `wp_update_post()` - reliable WordPress API
- ✅ Handles large files without corruption
- ✅ Avoids wp-cli stdin issues
- ✅ UTF-8 encoding preserved
- ✅ Atomic operation (all-or-nothing)
- ❌ NEVER use: `wp post update --post_content=-` with stdin (causes corruption)

---

## Container Management

### Start containers
**Environment:** 🏠 LOCAL ONLY

```powershell
cd infra/dev && podman-compose up -d
```

### Stop containers (preserves data)
**Environment:** 🏠 LOCAL ONLY

```powershell
cd infra/dev && podman-compose stop
```

### Restart containers
**Environment:** 🏠 LOCAL ONLY

```powershell
cd infra/dev && podman-compose restart
```

### Reset database (destroys volume)
**Environment:** 🏠 LOCAL ONLY

```powershell
cd infra/dev && podman-compose down -v && podman-compose up -d
```

### View logs
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman logs wp
podman logs wp-db
```

**Production:**
```bash
# View Apache error log
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "tail -100 /home/u909075950/domains/talendelight.com/logs/error_log"

# View PHP error log (if configured)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "tail -100 /home/u909075950/domains/talendelight.com/public_html/wp-content/debug.log"
```

---

## Cleanup & Maintenance

### Remove unused themes
**Environment:** 🔄 BOTH (via script)

**Local:**
```powershell
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment local -DryRun
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment local
```

**Production:**
```powershell
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment production -DryRun
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment production
```

**What it removes:**
- twentytwentythree
- twentytwentyfour
- twentytwentyfive

**Disk space saved:** ~13.6 MB

**Note:** Production cleanup runs automatically via GitHub Actions on deployment

---

## Debugging

### Check PHP version
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp php -v
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "php -v"
```

### Check for PHP errors
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman logs wp 2>&1 | Select-String "error|warning|fatal" -Context 2
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "tail -100 /home/u909075950/domains/talendelight.com/logs/error_log | grep -E 'error|warning|fatal' -i"
```

### Test database connection
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp-db mariadb -u root -ppassword -e "SHOW DATABASES;"
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db check"
```

### Check file permissions
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp ls -la wp-content/
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "ls -la /home/u909075950/domains/talendelight.com/public_html/wp-content/"
```

### WP-CLI info
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION

**Local:**
```powershell
podman exec wp wp cli info --allow-root --skip-plugins
```

**Production:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cli info --allow-root --skip-plugins"
```

---

## Domain Migration & Cache Management

### URL search-replace (all tables)
**Purpose:** Replace old domain with new domain across entire database  
**Environment:** 🌐 PRODUCTION  
**Example:**
```bash
wp search-replace 'olddomain.com' 'newdomain.com' --all-tables --report-changed-only
```
**Success:** Reports 100-150 replacements across wp_options, wp_posts, wp_postmeta, td_user_data_change_requests tables

### Fix WordPress site URLs
**Purpose:** Force update siteurl and home options  
**Environment:** 🌐 PRODUCTION  
**Example:**
```bash
wp option update siteurl 'https://newdomain.com' && wp option update home 'https://newdomain.com'
```

### Fix corrupted front page options (delete+recreate)
**Purpose:** Recreate front page settings when database import corrupts options  
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION  
**Example:**
```bash
# Delete corrupted options
wp option delete show_on_front && wp option delete page_on_front
# Recreate with autoload
wp option add show_on_front 'page' --autoload=yes
wp option add page_on_front 6 --autoload=yes
```
**Why delete+recreate:** Update doesn't work with corrupted serialized data during import

### Disable persistent object cache
**Purpose:** Prevent stale cache serving old option values during migration  
**Environment:** 🏠 LOCAL | 🌐 PRODUCTION  
**Example:**
```bash
# Local
podman exec wp bash -c "cd /var/www/html/wp-content && mv object-cache.php object-cache.php.disabled"
# Production
ssh production "cd public_html/wp-content && mv object-cache.php object-cache.php.disabled"
```

### Remove LiteSpeed cache rules from .htaccess
**Purpose:** Clean up cache directives from deactivated plugins  
**Environment:** 🌐 PRODUCTION  
**Example:**
```bash
cp .htaccess .htaccess.backup
sed -i '/#.*BEGIN LSCACHE/,/#.*END LSCACHE/d' .htaccess
sed -i '/#.*BEGIN NON_LSCACHE/,/#.*END NON_LSCACHE/d' .htaccess
```

### Test CDN cache status (response headers)
**Purpose:** Check if CDN is serving cached content  
**Environment:** PowerShell  
**Example:**
```powershell
$response = Invoke-WebRequest -Uri "https://domain.com/" -UseBasicParsing
$response.Headers['x-hcdn-cache-status']  # HIT=cached, MISS=fresh
$response.Headers['Server']               # hcdn=Hostinger CDN
$response.Headers['Cache-Control']        # max-age TTL
```

### Verify actual content served (not just settings)
**Purpose:** Confirm real HTML response matches expected content  
**Environment:** PowerShell or bash  
**Example:**
```powershell
$response = Invoke-WebRequest -Uri "https://domain.com/" -UseBasicParsing
$response.Content -match "Welcome page hero text"  # True=correct, False=cached old
```
**Critical:** Server-side curl bypasses CDN, always test from browser/PowerShell

**Related Guide:** [DOMAIN-MIGRATION-HOSTINGER.md](../docs/procedures/DOMAIN-MIGRATION-HOSTINGER.md) - Complete 15-step migration procedure

---

## Critical Patterns

### ✅ Always Do:
- Use `--allow-root` for wp-cli commands in containers
- Use `--skip-plugins` to avoid PHP deprecation warnings from wp-user-manager
- Use `2>/dev/null` or `2>&1` for stderr handling in bash
- Use `-Encoding utf8` in PowerShell `Out-File` to prevent corruption
- Quote passwords and special characters in SQL queries
- **Purge CDN cache via hPanel** after domain migrations (Hostinger)
- **Test from browser**, not just server-side curl/wp-cli
- **Check response headers** for CDN cache indicators (x-hcdn-*, cf-*)
- **Delete+recreate corrupted options** instead of updating during migrations

### ❌ Never Do:
- NEVER use `wp-cli` stdin pipes for large content (causes corruption)
- NEVER use `2>$null` on Windows (creates C:\dev\null file) - use bash wrapper instead
- NEVER run `podman ps` or container discovery commands (use container names above)
- NEVER reinvent commands - check this registry first
- NEVER assume `wp cache flush` clears CDN cache (it doesn't)
- NEVER skip CDN cache purge after domain/content migrations
- NEVER trust server-side tests alone when browser shows different content

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
