# Complete Production Restoration Guide

**Date:** February 5, 2026  
**Source:** Production backup from January 30, 2026

## Overview

If production is lost, use this guide to restore from `restore/` folder and `infra/shared/db/` files.

## Restoration Order

Follow this order strictly for proper database relationships:

### 1. Users (Foundation)
```powershell
# Import users first (other data references user IDs)
Get-Content infra/shared/db/users-from-production-20260130.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content infra/shared/db/usermeta-from-production-20260130.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
```

**Result:** 10 users (admin + 9 test users)

### 2. Pages (Content Foundation)
```powershell
# Import all 16 pages
# Method: Use wp-cli or manual SQL import (pages already in current local DB)
# See restore/pages/ for individual page JSON files
```

**Result:** 16 pages including authentication, role pages, error pages

### 3. Forminator Form (Registration System)
```powershell
# Import form and dependencies
Get-Content restore/forms/forminator-form-80-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/forms/forminator-form-80-meta-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/forms/forminator-tables-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
```

**Result:** person-registration-form (ID 80) restored with all settings

### 4. Menus (Navigation)
```powershell
# Import menu structure
Get-Content restore/menu/menus-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-items-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-items-meta-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-relationships-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
```

**Result:** Main Navigation menu with all items and relationships

### 5. Site Configuration
```bash
# Set homepage
wp option update page_on_front 6
wp option update show_on_front page

# Verify site URL (adjust for environment)
wp option get siteurl
wp option get home
```

## Post-Restoration Verification

```powershell
# Check users
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT COUNT(*) FROM wp_users"
# Expected: 10

# Check pages  
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='page' AND post_status='publish'"
# Expected: 16 (plus Sample Page = 17)

# Check Forminator form
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='forminator_forms'"
# Expected: 1

# Check menus
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT COUNT(*) FROM wp_term_taxonomy WHERE taxonomy='nav_menu'"
# Expected: 1+

# Check menu items
podman exec wp-db mariadb -u root -ppassword wordpress -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='nav_menu_item'"
# Expected: 6+ items
```

## Known Missing Items (Created After Jan 30 Backup)

These items were created Feb 2-4, 2026 and are NOT in the backup:

### Manager Actions Page (ID 670)
- **Location:** /managers/actions/
- **Specification:** See `docs/SESSION-SUMMARY-FEB-02.md`
- **Features:** 5-tab interface (Submitted, Approved, Rejected, All, Archived)
- **Functionality:** User registration request approvals
- **Must recreate manually**

### Operator Actions Page (ID 666)
- **Location:** /operators/actions/
- **Specification:** See `docs/SESSION-SUMMARY-FEB-02.md`
- **Features:** Copy of Manager Actions with data filtering
- **Filtering:** Public roles only, own assignments only
- **Must recreate manually**

### Page Access Control (PublishPress Capabilities)
- Manager pages (386, 469, 670) → td_manager/administrator
- Operator pages (299, 666) → td_operator/administrator
- Redirect unauthorized to /403-forbidden/
- **Must reconfigure manually**

## Timeline Impact

With production backup restoration:
- **Recovered:** 16 pages, 1 form, menus, 10 users (~7 days of work)
- **Lost:** Manager/Operator Actions pages + access control (~3 days of work)
- **Net impact:** +3 days delay (vs +10 days if starting from scratch)
- **New MVP date:** April 8, 2026 (was April 5)

## File Locations Summary

```
restore/
├── forms/
│   ├── README.md (import instructions)
│   ├── forminator-form-80-from-production.sql ✅ USE THIS
│   ├── forminator-form-80-meta-from-production.sql ✅ USE THIS
│   └── forminator-tables-from-production.sql ✅ USE THIS
├── menu/
│   ├── README.md (import instructions)
│   ├── menus-from-production.sql ✅ USE THIS
│   ├── menu-items-from-production.sql ✅ USE THIS
│   ├── menu-items-meta-from-production.sql ✅ USE THIS
│   └── menu-relationships-from-production.sql ✅ USE THIS
└── pages/
    └── (16 pages × 2 files each = 32 JSON files)

infra/shared/db/
├── USERS-README.md (import instructions)
├── users-from-production-20260130.sql ✅ USE THIS
└── usermeta-from-production-20260130.sql ✅ USE THIS
```

## Important Notes

1. **Old files:** Ignore any files WITHOUT "from-production" in the name
2. **Order matters:** Import users → pages → forms → menus (dependency order)
3. **Verification:** Always verify counts after each import step
4. **Local vs Production:** Adjust site URLs based on target environment
5. **Missing work:** Budget 3 days to recreate Manager/Operator Actions pages

## Quick All-in-One Import Script

```powershell
# WARNING: Only use on fresh database or you may get duplicate data
# Run from wordpress directory

Write-Host "1. Importing users..." -ForegroundColor Cyan
Get-Content infra/shared/db/users-from-production-20260130.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content infra/shared/db/usermeta-from-production-20260130.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress

Write-Host "2. Importing Forminator form..." -ForegroundColor Cyan
Get-Content restore/forms/forminator-form-80-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/forms/forminator-form-80-meta-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/forms/forminator-tables-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress

Write-Host "3. Importing menus..." -ForegroundColor Cyan
Get-Content restore/menu/menus-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-items-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-items-meta-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress
Get-Content restore/menu/menu-relationships-from-production.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress

Write-Host "4. Setting homepage..." -ForegroundColor Cyan
podman exec wp wp option update page_on_front 6 --allow-root
podman exec wp wp option update show_on_front page --allow-root

Write-Host "`n✅ Restoration complete! Verify the counts above." -ForegroundColor Green
```

---

## Option 4: Emergency Production Fix (URL Redirect + Missing Pages)

**Use Case:** Production site redirecting to wrong URL (e.g., `:8080`) or critical pages missing

**Requirements:**
- SSH access to production (Hostinger)
- Production WordPress at `/home/u909075950/domains/talendelight.com/public_html/`
- Backup files in `restore/pages/`

### Automated Fix Script

**If SSH accessible:**
```powershell
.\infra\shared\scripts\emergency-fix-production.ps1
```

**SSH Connection Details:**
- **Host:** 45.84.205.129
- **Port:** 65002 (not default 22)
- **User:** u909075950
- **Key:** tmp/hostinger_deploy_key (if available)
- **Password:** Available in Hostinger control panel

**Connection Test:**
```powershell
# With SSH key
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "echo 'SSH OK'"

# With password (interactive)
ssh -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp option get siteurl --allow-root"
```

### Manual Fix via Hostinger Control Panel

**If SSH connection fails or times out:**

#### Step 1: Log into Hostinger
- URL: https://hpanel.hostinger.com
- Navigate to your website → File Manager

#### Step 2: Upload Fix Scripts

Navigate to `/home/u909075950/` and create these files:

**File: `fix-urls.php`**
```php
<?php
require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');

// Fix site URL and home URL
update_option('siteurl', 'https://talendelight.com');
update_option('home', 'https://talendelight.com');

echo "URLs fixed:\n";
echo "  siteurl: " . get_option('siteurl') . "\n";
echo "  home: " . get_option('home') . "\n";

// Flush caches
wp_cache_flush();
echo "Cache flushed\n";
?>
```

**File: `restore-welcome.php`**
```php
<?php
require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');

$content = file_get_contents('/home/u909075950/welcome-content.html');
if (!$content) {
    echo "Error: Could not read welcome-content.html\n";
    exit(1);
}

// Check if Welcome page exists
$existing = get_page_by_path('welcome', OBJECT, 'page');

if ($existing) {
    // Update existing page
    $result = wp_update_post(array(
        'ID' => $existing->ID,
        'post_content' => $content,
    ));
    
    if (is_wp_error($result)) {
        echo "Error updating page: " . $result->get_error_message() . "\n";
        exit(1);
    }
    
    $page_id = $existing->ID;
    echo "Success: Welcome page updated (ID: $page_id)\n";
} else {
    // Create new page
    $page_id = wp_insert_post(array(
        'post_title' => 'Welcome',
        'post_name' => 'welcome',
        'post_content' => $content,
        'post_status' => 'publish',
        'post_type' => 'page',
        'comment_status' => 'closed',
        'ping_status' => 'closed',
    ));
    
    if (is_wp_error($page_id)) {
        echo "Error creating page: " . $page_id->get_error_message() . "\n";
        exit(1);
    }
    
    echo "Success: Welcome page created (ID: $page_id)\n";
}

// Set as homepage
update_option('show_on_front', 'page');
update_option('page_on_front', $page_id);

echo "Set as homepage (page_on_front = $page_id)\n";

// Flush caches
wp_cache_flush();
echo "Cache flushed\n";

// Cleanup
unlink('/home/u909075950/welcome-content.html');
?>
```

**File: `welcome-content.html`**
- Upload content from `restore/pages/welcome-page-clean.html`

#### Step 3: Execute via Terminal

In Hostinger File Manager, open Terminal and run:
```bash
cd ~
php fix-urls.php
php restore-welcome.php
```

#### Step 4: Verify Fix
```bash
cd domains/talendelight.com/public_html
wp option get siteurl --allow-root
wp option get home --allow-root
wp option get page_on_front --allow-root
wp post list --post_type=page --format=csv --fields=ID,post_title,post_name --allow-root
```

#### Step 5: Test Site
- Visit: https://talendelight.com
- Verify: No wrong port redirect
- Verify: Welcome page displays as homepage

#### Step 6: Cleanup
```bash
rm ~/fix-urls.php
rm ~/restore-welcome.php
```

### Alternative: Via phpMyAdmin (Risky)

**Only if File Manager method fails:**

1. Open phpMyAdmin from Hostinger control panel
2. Select WordPress database (`u909075950_GD9QX`)
3. Run SQL:
   ```sql
   UPDATE wp_options SET option_value = 'https://talendelight.com' WHERE option_name = 'siteurl';
   UPDATE wp_options SET option_value = 'https://talendelight.com' WHERE option_name = 'home';
   ```
4. For page restoration, use File Manager method above

### Post-Fix Actions

**After emergency fix complete:**

1. **Verify Homepage Set to Welcome:**
   ```powershell
   ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp option get show_on_front --allow-root && wp option get page_on_front --allow-root && wp post list --post_type=page --name=welcome --format=csv --fields=ID,post_title --allow-root"
   # show_on_front should be 'page'
   # page_on_front should match Welcome page ID
   # If not set: wp option update show_on_front page --allow-root && wp option update page_on_front <ID> --allow-root
   ```

2. **Verify Theme Active:**
   ```powershell
   ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp theme list --status=active --allow-root"
   # Should show 'blocksy', if not: wp theme activate blocksy --allow-root
   ```

2. **Verify HTTPS Redirect:**
   ```powershell
   ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "curl -I http://talendelight.com 2>&1 | grep -i 'HTTP\|Location'"
   # Should show: HTTP/1.1 301 Moved Permanently + Location: https://talendelight.com/
   ```

3. **Create Backup:**
   ```powershell
   .\infra\shared\scripts\wp-action.ps1 backup
   ```

4. **Verify Production:**
   ```powershell
   .\infra\shared\scripts\wp-action.ps1 verify
   ```

5. **Document Incident:**
   - Update `docs/lessons/` with incident details
   - Document root cause and resolution
   - Update disaster recovery procedures if needed

### Common Post-Restore Issues

**Issue: Homepage showing posts instead of Welcome page**
- **Cause:** `show_on_front` set to 'posts' or `page_on_front` not set to Welcome page ID
- **Fix:** 
  ```bash
  WELCOME_ID=$(wp post list --post_type=page --name=welcome --field=ID --allow-root)
  wp option update show_on_front page --allow-root
  wp option update page_on_front $WELCOME_ID --allow-root
  wp cache flush --allow-root
  ```

**Issue: Styles not loading**
- **Cause:** Wrong theme active (twentytwentyfive instead of blocksy)
- **Fix:** `wp theme activate blocksy --allow-root && wp cache flush --allow-root`

**Issue: HTTP not redirecting to HTTPS**
- **Cause:** .htaccess HTTPS rules missing or in wrong position
- **Fix:** Ensure HTTPS redirect rules are at TOP of .htaccess (before LiteSpeed rules)

**Issue: SSL certificate warning**
- **Cause:** Certificate not installed or browser cache
- **Fix:** Check Hostinger SSL settings, clear browser cache, flush DNS (ipconfig /flushdns)

**See also:** [docs/EMERGENCY-FIX-MANUAL.md](../docs/EMERGENCY-FIX-MANUAL.md) for detailed emergency procedures
