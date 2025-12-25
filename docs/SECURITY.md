# Security Guide

This guide covers security practices for the WordPress project, including vulnerability scanning, hardening, and monitoring.

## Quick Start: Vulnerability Scanning

Run a basic scan against your development environment:

```powershell
cd infra/shared/tools
podman-compose up wpscan
```

Results are saved to [infra/shared/tools/reports/](../infra/shared/tools/reports/).

---

## Vulnerability Scanning with WPScan

### What is WPScan?

WPScan is the industry-standard WordPress vulnerability scanner. It checks for:
- WordPress core vulnerabilities
- Plugin vulnerabilities
- Theme vulnerabilities
- Insecure configurations
- Username enumeration
- Directory listings

### Free Tier

WPScan offers free scanning with:
- 25 API requests per day
- Basic vulnerability database access
- Core, plugin, and theme checks

For unlimited scans: https://wpscan.com/pricing

### Getting an API Token (Recommended)

1. Register at https://wpscan.com/register
2. Get your free token from https://wpscan.com/profile
3. Use in scans:

```powershell
# Set in environment
$env:WPSCAN_API_TOKEN="your_api_token_here"

# Or pass directly
podman-compose run wpscan --url http://wordpress --api-token your_api_token_here
```

### Running Scans

**Basic scan:**
```powershell
cd infra/shared/tools
podman-compose up wpscan
```

**Using PowerShell script:**
```powershell
cd infra/shared/tools
.\scan-vulnerabilities.ps1 -Environment dev
.\scan-vulnerabilities.ps1 -Environment prod -Verbose
```

**Manual scans:**

```powershell
# Scan specific URL
podman-compose run wpscan --url http://wordpress:8080

# Enumerate plugins only
podman-compose run wpscan --url http://wordpress:8080 --enumerate p

# Enumerate themes only
podman-compose run wpscan --url http://wordpress:8080 --enumerate t

# Enumerate users
podman-compose run wpscan --url http://wordpress:8080 --enumerate u

# Full aggressive scan
podman-compose run wpscan --url http://wordpress:8080 --enumerate ap,at,u --plugins-detection aggressive
```

### Interpreting Results

**[!] Critical** - Requires immediate attention  
**[+] Informational** - Useful findings  
**[i] Info** - General information

Common findings:
1. **Outdated WordPress version** → Update WordPress core
2. **Vulnerable plugins** → Update or remove affected plugins
3. **Vulnerable themes** → Update or replace themes
4. **Username enumeration** → Disable author archives
5. **XML-RPC enabled** → Disable if not needed

### Output Files

Scan results are saved to `infra/shared/tools/reports/`:
- `wpscan-YYYYMMDD-HHMMSS.txt` - Full scan output with timestamp
- `wpscan-latest.txt` - Most recent scan (symlink)

### Troubleshooting Scans

**"Connection refused":**
- Ensure containers running: `podman ps`
- Check network connectivity between containers

**"Rate limit exceeded":**
- Hit free tier limit (25/day)
- Wait 24 hours or upgrade to paid plan
- Use `--no-update` to skip database updates

**"SSL certificate problem":**
- For local testing: `--disable-tls-checks`
- Not recommended for production

---

## Security Hardening

### Production Compose Security

[infra/prod/compose.yml](../infra/prod/compose.yml) includes security best practices:

**Environment variables for secrets:**
```yaml
environment:
  - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:?Required}
  - MYSQL_PASSWORD=${MYSQL_PASSWORD:?Required}
```

**Dedicated database user:**
```yaml
MYSQL_USER=${MYSQL_USER:-wordpress_user}  # Not root
```

**Localhost port binding:**
```yaml
ports:
  - "127.0.0.1:3306:3306"  # Only accessible from localhost
```

**No debug mode:**
- Remove phpMyAdmin from production
- Set `WP_DEBUG=false` in wp-config.php

### WordPress Configuration Security

[config/wp-config.php](../config/wp-config.php) hardening:

**Secure salts and keys:**
```php
define('AUTH_KEY',         getenv_docker('WORDPRESS_AUTH_KEY', 'put your unique phrase here'));
define('SECURE_AUTH_KEY',  getenv_docker('WORDPRESS_SECURE_AUTH_KEY', 'put your unique phrase here'));
// ... etc
```

Generate new salts: https://api.wordpress.org/secret-key/1.1/salt/

**Disable file editing:**
```php
define('DISALLOW_FILE_EDIT', true);  // Prevents editing plugins/themes from admin
```

**Force SSL for admin:**
```php
define('FORCE_SSL_ADMIN', true);  // Requires HTTPS for wp-admin
```

### Apache/HTTPD Security

[config/.htaccess](../config/.htaccess) protections:

**Disable directory listing:**
```apache
Options -Indexes
```

**Protect wp-config.php:**
```apache
<files wp-config.php>
order allow,deny
deny from all
</files>
```

**Limit access to xmlrpc.php** (if not needed):
```apache
<files xmlrpc.php>
order deny,allow
deny from all
</files>
```

### PHP Configuration Security

[config/uploads.ini](../config/uploads.ini) limits:

```ini
memory_limit = 128M
upload_max_filesize = 64M
post_max_size = 128M
max_execution_time = 600
```

Adjust based on requirements, but keep reasonable limits to prevent abuse.

---

## Plugin and Theme Security

### Current Installation

See [infra/dev/reports/plugins-themes-report.md](../infra/dev/reports/plugins-themes-report.md) for full inventory.

**Installed plugins:**
- Akismet 5.4 (spam protection)
- Blocksy Companion 2.1.9 (theme features)
- Elementor 3.31.3 (page builder)
- WooCommerce 10.1.2 (e-commerce)
- WPForms Lite 1.9.7.3 (forms)

**Active theme:**
- Blocksy 2.1.9

### Plugin Security Best Practices

1. **Keep plugins updated** - Run WPScan weekly, update immediately
2. **Remove unused plugins** - Delete, don't just deactivate
3. **Vet before installing** - Check reviews, last update date, downloads
4. **Limit plugin count** - Fewer plugins = smaller attack surface
5. **Avoid nulled/pirated plugins** - Often contain malware

### Managing Updates

**Via WP-CLI:**
```powershell
# List available updates
podman exec -it wordpress wp plugin list --update=available

# Update specific plugin
podman exec -it wordpress wp plugin update akismet

# Update all plugins
podman exec -it wordpress wp plugin update --all

# Same for themes
podman exec -it wordpress wp theme list --update=available
podman exec -it wordpress wp theme update --all
```

**Via WordPress admin:**
- Dashboard → Updates → Check all plugins/themes
- Review changelog before updating
- Test in dev environment first

---

## Access Control

### Database Access

**Development:**
- Root password: `password` (hardcoded, dev only)
- phpMyAdmin: http://localhost:8180 (root/password)
- Port 3306 exposed to host

**Production:**
- Root password: Strong random password in `.env`
- No phpMyAdmin (removed from compose)
- Port 3306 bound to localhost only
- WordPress uses dedicated `wordpress_user` (not root)

### WordPress Admin Access

**Strong passwords required:**
```powershell
# Create admin user with strong password
podman exec -it wordpress wp user create newadmin email@example.com \
  --role=administrator \
  --user_pass=$(New-Guid)
```

**Limit admin accounts:**
- Remove default "admin" username
- Use unique usernames (not "admin", "administrator")
- Implement least privilege (Editor, Author, etc.)

**Two-factor authentication:**
- Install plugin: "Two Factor Authentication"
- Require for all administrator accounts

### FTP Access (Development Only)

Development environment includes FTP server for plugin updates:
- User: `ftp_user`
- Password: `ftp_password`
- Ports: 20-21, 30000-30009

**Production:**
- No FTP server (use `FS_METHOD='direct'`)
- All uploads via WordPress admin or WP-CLI
- SSH/SFTP access managed by hosting provider

---

## Monitoring and Auditing

### Security Scan Schedule

**Development:**
- Run WPScan before major releases
- Scan after adding new plugins/themes

**Production:**
- Weekly automated scans
- Immediate scan after any plugin/theme updates
- Monthly comprehensive scan with aggressive detection

### Log Monitoring

**WordPress debug log:**
```php
// In wp-config.php (dev only)
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
```

Logs saved to `wp-content/debug.log`.

**Apache access logs:**
```powershell
podman logs wordpress | grep -E "POST|wp-login|xmlrpc"
```

Watch for:
- Repeated failed login attempts
- Unusual POST requests to admin pages
- xmlrpc.php abuse
- 404 errors on common exploit paths

**Database access logs:**
```powershell
podman logs wp-db | grep -i "access denied"
```

### Security Headers

Add to `.htaccess` or Apache config:

```apache
# Prevent clickjacking
Header always set X-Frame-Options "SAMEORIGIN"

# XSS protection
Header always set X-XSS-Protection "1; mode=block"

# Prevent MIME sniffing
Header always set X-Content-Type-Options "nosniff"

# Referrer policy
Header always set Referrer-Policy "strict-origin-when-cross-origin"

# Content Security Policy (adjust as needed)
Header always set Content-Security-Policy "default-src 'self'"
```

---

## Incident Response

### Suspected Compromise

1. **Isolate immediately:**
   ```powershell
   podman-compose down
   ```

2. **Preserve evidence:**
   - Backup current state: `podman exec -it db mysqldump -u root -p wordpress > compromised-backup.sql`
   - Copy logs: `podman logs wordpress > wordpress-logs.txt`

3. **Investigate:**
   - Check file modifications: Compare wp-content with clean install
   - Review database: Look for suspicious admin users, posts, options
   - Scan for malware: Use WPScan and manual inspection

4. **Remediate:**
   - Restore from known-good backup
   - Update all passwords (database, WordPress admin, FTP)
   - Update all plugins/themes
   - Rescan with WPScan

5. **Prevent recurrence:**
   - Identify attack vector
   - Apply security patches
   - Implement additional hardening

### WordPress Backdoors

Common locations:
- `wp-content/uploads/*.php` - PHP files in uploads directory
- Theme functions.php - eval() or base64_decode() calls
- Plugin files - check against official versions
- Root directory - unusual .php files

**Scan for backdoors:**
```powershell
# Look for suspicious PHP in uploads
podman exec -it wordpress find wp-content/uploads -name "*.php"

# Search for common backdoor functions
podman exec -it wordpress grep -r "eval(" wp-content/
podman exec -it wordpress grep -r "base64_decode" wp-content/
```

---

## Security Checklist

### Development

- [ ] Regular vulnerability scans (weekly)
- [ ] Strong local passwords (even if exposed)
- [ ] No production data in dev database
- [ ] Debug mode enabled for troubleshooting
- [ ] FTP access only for local testing

### Production

- [ ] All secrets in `.env` file (not in git)
- [ ] Database ports bound to localhost only
- [ ] Dedicated non-root database user
- [ ] No phpMyAdmin in production compose
- [ ] WordPress debug mode disabled
- [ ] Strong unique passwords for all accounts
- [ ] SSL/TLS certificates valid and enforced
- [ ] Regular automated backups (daily)
- [ ] Offsite backup storage (encrypted)
- [ ] Weekly WPScan vulnerability scans
- [ ] Two-factor authentication enabled
- [ ] File permissions locked down (755 dirs, 644 files)
- [ ] wp-config.php permissions 400
- [ ] All plugins/themes up to date
- [ ] Unused plugins/themes removed
- [ ] Security headers configured
- [ ] Log monitoring active
- [ ] Firewall rules configured (hosting provider)

---

## Additional Resources

- WPScan GitHub: https://github.com/wpscanteam/wpscan
- WPScan Vulnerability Database: https://wpscan.com/
- WordPress Security Guide: https://wordpress.org/support/article/hardening-wordpress/
- OWASP WordPress Security: https://owasp.org/www-project-wordpress-security/
- Plugin Security Tracker: https://wpscan.com/plugins
- [infra/shared/tools/README.md](../infra/shared/tools/README.md) - WPScan setup details
- [docs/DATABASE.md](DATABASE.md) - Backup and disaster recovery
