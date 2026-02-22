# Production Cleanup Audit Script

**Purpose:** Identify unused resources in production for cleanup during v3.6.3 deployment  
**Date:** February 20, 2026  
**Status:** Ready for execution

---

## Quick Audit Commands

### 1. Pages Audit
```powershell
# List all pages with status
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post list --post_type=page --format=table --fields=ID,post_title,post_status,post_date"

# Expected pages in production:
# - ID 6: Welcome
# - ID 17: Candidates
# - ID 18: Scouts
# - ID 16: Employers
# - ID 19: Managers
# - ID 20: Operators
# - ID 36: Manager Actions
# - ID 38: Manager Admin
# - NEW: Register Profile, Select Role, Help, Log In

# Pages to DELETE:
# - Any "Sample Page", "Test Page", draft pages not in menu
```

### 2. Plugins Audit
```powershell
# Active plugins
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin list --status=active --format=table"

# Inactive plugins (candidates for deletion)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin list --status=inactive --format=table"

# Essential plugins (KEEP):
# - Blocksy Companion
# - LiteSpeed Cache
# - Akismet Anti-Spam
# - Classic Editor (if used)

# Plugins to REMOVE (after v3.6.3 deployment):
# - Forminator (replaced by custom form)
# - WPForms Lite (never used)
# - Any other inactive plugins
```

### 3. Themes Audit
```powershell
# List all themes
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp theme list --format=table"

# Active theme (KEEP):
# - Blocksy (parent)
# - Blocksy Child (active)

# Keep ONE default theme as backup:
# - Twenty Twenty-Four OR Twenty Twenty-Three

# Themes to DELETE:
# - All other inactive default themes (Twenty Twenty-Two, Twenty Twenty-One, etc.)
```

### 4. Forms Audit (Forminator/WPForms)
```powershell
# Check Forminator tables
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query 'SHOW TABLES LIKE \"wp_frmt_%\"'"

# Check WPForms tables
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query 'SHOW TABLES LIKE \"wp_wpforms_%\"'"

# After plugin removal, these tables can be dropped (OPTIONAL - keep for historical data):
# - wp_frmt_form_entry
# - wp_frmt_form_entry_meta
# - wp_frmt_form_views
# - wp_wpforms_* (if any)
```

### 5. Users Audit
```powershell
# List all users
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp user list --format=table --fields=ID,user_login,user_email,roles"

# Expected users:
# - ID 1: wpadmin (Administrator)
# - Real Manager/Operator accounts (if any created)

# Users to DELETE:
# - Test users (e.g., testuser, test-candidate, test-manager)
# - Users created during development/testing
# - Users with 'pending' status (if any exist before v3.6.3 deployment)
```

### 6. Media/Uploads Audit
```powershell
# Check uploads directory structure
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && du -sh wp-content/uploads/*"

# Check for test files
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && find wp-content/uploads/ -name '*test*' -o -name '*sample*'"

# Files to DELETE:
# - Test images/documents uploaded during development
# - Unused media files not linked to any page/post
```

### 7. Database Tables Audit
```powershell
# List all tables
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query 'SHOW TABLES' --skip-column-names"

# WordPress core tables (KEEP):
# - wp_posts, wp_postmeta, wp_users, wp_usermeta
# - wp_options, wp_links, wp_comments, wp_terms, etc.

# Custom tables (KEEP):
# - wp_td_user_data_change_requests
# - wp_td_id_sequences

# Plugin tables (REVIEW):
# - wp_frmt_* (Forminator - can delete after plugin removal)
# - wp_wpforms_* (WPForms - can delete if exists)
# - wp_litespeed_* (LiteSpeed Cache - KEEP)
# - wp_actionscheduler_* (WooCommerce/Blocksy - KEEP if needed)
```

---

## Cleanup Execution Commands

⚠️ **WARNING:** Review audit results before executing cleanup commands!

### Delete Unused Pages
```powershell
# Example: Delete page ID 42 (replace with actual ID found in audit)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post delete 42 --force"
```

### Delete Inactive Plugins
```powershell
# Delete specific inactive plugin
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin delete <plugin-slug>"
```

### Delete Inactive Themes
```powershell
# Delete specific theme (e.g., twentytwentytwo)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp theme delete twentytwentytwo"
```

### Delete Test Users
```powershell
# Delete user by ID (e.g., ID 12)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp user delete 12 --yes"
```

### Drop Plugin Database Tables (OPTIONAL)
```powershell
# Drop Forminator tables (after plugin removed and data backed up)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query 'DROP TABLE IF EXISTS wp_frmt_form_entry, wp_frmt_form_entry_meta, wp_frmt_form_views'"
```

---

## Cleanup Checklist

**Before Cleanup:**
- [ ] Run all audit commands
- [ ] Review audit results
- [ ] Create production backup (mandatory)
- [ ] Identify specific items to delete

**Safe to Delete:**
- [ ] Draft/test pages not in navigation
- [ ] Forminator plugin (after v3.6.3 deployment)
- [ ] WPForms Lite plugin (after v3.6.3 deployment)
- [ ] Inactive themes (keep 1 default)
- [ ] Test user accounts
- [ ] Forminator/WPForms database tables (optional)

**DO NOT Delete:**
- [ ] Any published page in navigation menu
- [ ] Active plugins (Blocksy Companion, LiteSpeed Cache, Akismet)
- [ ] Active themes (Blocksy + Blocksy Child)
- [ ] WordPress core tables
- [ ] Custom tables (wp_td_*)
- [ ] wpadmin user account

**After Cleanup:**
- [ ] Verify site still works
- [ ] Check all navigation links
- [ ] Test registration flow
- [ ] Clear all caches

---

## Safety Notes

1. **Always backup before cleanup** - Run backup-production.ps1 first
2. **Review before delete** - Don't blindly delete based on names
3. **Keep historical data** - Plugin tables can be kept even after plugin removal (they won't hurt)
4. **Test after cleanup** - Verify all functionality still works
5. **Document what was deleted** - Add notes to this file for future reference

---

## Post-Cleanup Documentation

**Items Deleted:** (Fill in after cleanup)
- Pages: 
- Plugins: 
- Themes: 
- Users: 
- Database tables: 
- Media files: 

**Cleanup Date:** _______________  
**Performed By:** _______________  
**Issues Encountered:** _______________
