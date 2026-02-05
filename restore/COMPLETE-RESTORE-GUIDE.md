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
