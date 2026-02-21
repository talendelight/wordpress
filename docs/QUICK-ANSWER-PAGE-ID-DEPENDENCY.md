# Page ID Dependency - Quick Answer

**Date:** February 19, 2026

## Question

> How did we lose these pages and menu item targets when we upgraded? How to avoid it in future? Is there a way to avoid or minimize page IDs and depend on slugs or something common between local and production?

---

## What Happened

### Root Cause

```powershell
podman-compose down -v  # ⚠️ Destroyed all database data
podman-compose up -d    # Recreated from baseline SQL only
```

**Baseline SQL (`000000-0000-init-db.sql`) contains:**
- Only 3 default WordPress pages (Sample Page, Privacy Policy)
- Does NOT include production pages (Welcome, Help, Log In, Select Role = 19 pages)

**Result:** Lost 16 pages that existed in production but not in baseline

### Why Menu Items Broke

WordPress menu items store **integer page IDs**, not slugs:
- Production: "Help" = page ID 21
- Local (after recreation): "Help" = page ID 11 (new auto-increment)
- Menu item pointing to "page_id=21" → 404 error in local

---

## Solutions Implemented

### 1. ✅ Create Core Pages in Delta File

**File:** `infra/shared/db/260219-1600-create-core-pages.sql`

```sql
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_status, post_name, post_type)
VALUES
(1, NOW(), NOW(), '', 'Welcome', 'publish', 'welcome', 'page'),
(1, NOW(), NOW(), '', 'Help', 'publish', 'help', 'page'),
(1, NOW(), NOW(), '', 'Log In', 'publish', 'log-in', 'page'),
(1, NOW(), NOW(), '', 'Select Role', 'publish', 'select-role', 'page');
```

**Result:** Core pages exist after fresh database creation (content restored separately)

### 2. ✅ Use Slug-Based Menu Items

**Updated:** `infra/shared/scripts/rebuild-navigation-menu.ps1`

```powershell
# OLD APPROACH (breaks when IDs change):
wp menu item add-post main-navigation 21 --title="Help"

# NEW  APPROACH (works across environments):
wp menu item add-custom main-navigation "Help" "/help/"
```

**Menu items now use relative URLs:**
- `/` → Welcome
- `/select-role/` → Register
- `/help/` → Help
- `/log-in/` → Login

### 3. ✅ Enable Clean Permalinks

**File:** `infra/shared/db/260127-1600-enable-permalinks.sql`

```sql
INSERT INTO wp_options (option_name, option_value, autoload)
VALUES ('permalink_structure', '/%postname%/', 'yes')
ON DUPLICATE KEY UPDATE option_value = '/%postname%/', autoload = 'yes';
```

**Result:** URLs work as `/help/` instead of `/?page_id=11`

---

## How to Avoid in Future

### After Database Recreation

```powershell
# 1. Start containers
podman-compose down -v && podman-compose up -d

# 2. Rebuild navigation menu (uses slug-based URLs)
pwsh infra/shared/scripts/wp-action.ps1 rebuild-menu

# 3. Restore page content from backups
Get-ChildItem restore\pages\*-*.html | ForEach-Object {
    # Parse page ID from filename
    $pageId = ($_.Name -split '-')[-1].Replace('.html', '')
    
    # Generate restore script
    @"
<?php
require_once('/var/www/html/wp-load.php');
\$content = file_get_contents('/tmp/$($_.Name)');
wp_update_post(['ID' => $pageId, 'post_content' => \$content]);
echo "Restored page $pageId\n";
"@ | Out-File -Encoding utf8 "tmp\restore-page-$pageId.php"
    
    # Copy content and script to container
    podman cp $_.FullName wp:/tmp/$($_.Name)
    podman cp "tmp\restore-page-$pageId.php" wp:/tmp/
    
    # Execute restore
    podman exec wp php "/tmp/restore-page-$pageId.php"
}

# 4. Verify
curl.exe -k -s https://wp.local/ | Select-String "TalenDelight"
```

### Prevention Checklist

Before `podman-compose down -v`:

- [ ] **Backup production pages:** Export to `restore/pages/` if not already done
- [ ] **Review delta files:** Ensure `260219-1600-create-core-pages.sql` exists
- [ ] **Check menu script:** Verify `rebuild-navigation-menu.ps1` uses custom links
- [ ] **Test full recreation:** Run upgrade in separate directory first

After database recreation:

- [ ] **Run menu rebuild:** `pwsh infra/shared/scripts/wp-action.ps1 rebuild-menu`
- [ ] **Verify pages exist:** https://wp.local/, /help/, /log-in/, /select-role/
- [ ] **Test navigation:** Click all menu items
- [ ] **Restore content:** Import from `restore/pages/` backups if needed

---

## Key Takeaways

### ✅ Do This

- Use **slug-based URLs** in menus: `/help/` instead of page ID references
- Create **core pages in delta files** so they exist after database recreation
- Store **page backups** in `restore/pages/` for content recovery
- Use **`wp-action.ps1 rebuild-menu`** after database recreation

### ❌ Don't Do This

- Don't use `wp menu item add-post` with page IDs (creates ID dependency)
- Don't assume baseline SQL contains production pages (it doesn't)
- Don't rely on page IDs matching between environments (they won't)
- Don't skip testing after `podman-compose down -v`

### Why Slug-Based Approach Works

**Slugs are consistent across environments:**
- Local: `/help/` → Finds page with `post_name='help'`
- Production: `/help/` → Finds page with `post_name='help'`
- Works regardless of page ID (11, 21, 42, etc.)

**WordPress handles slug resolution:**
- Permalink structure: `/%postname%/`
- Auto-redirects if slug changes
- Works with different domains (wp.local vs talendelight.com)

---

## Files Modified

1. **`infra/shared/db/260219-1600-create-core-pages.sql`** ← NEW
   - Creates Welcome, Help, Log In, Select Role pages in fresh database

2. **`infra/shared/scripts/rebuild-navigation-menu.ps1`** ← UPDATED
   - Changed from page references to slug-based custom links
   - Default environment: local (was production)
   - Default theme location: menu_1 (was header-menu-1)

3. **`infra/shared/db/README.md`** ← UPDATED
   - Added "Page ID Dependency Problem" section
   - Documents slug-based approach and prevention steps

4. **`docs/lessons/page-id-dependency-problem.md`** ← NEW
   - Complete lesson with timeline, technical details, implementation plan

---

## Quick Recovery

If menu breaks after future database recreation:

```powershell
# Rebuild menu with slug-based URLs (idempotent, safe to re-run)
cd c:\data\lochness\talendelight\code\wordpress
pwsh infra/shared/scripts/rebuild-navigation-menu.ps1

# Verify
curl.exe -k -s https://wp.local/ | Select-String 'menu-main-navigation' -Context 0,8
```

Done! 🎉
