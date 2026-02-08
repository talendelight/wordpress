# Deployment Instructions - v3.5.1

**Version:** v3.5.1  
**Date:** February 8, 2026  
**Type:** Patch Release  
**Risk Level:** Low (cosmetic changes only)

---

## Overview

This release migrates the Welcome page from Elementor to Gutenberg blocks and installs Better Font Awesome plugin for local icon hosting. All changes are cosmetic and do not affect business logic or database schema.

**What's Changing:**
- Welcome page content (post ID 6)
- Better Font Awesome plugin installation
- blocksy-child theme functions.php (removed CDN Font Awesome)

**What's NOT Changing:**
- No database schema changes
- No new tables
- No plugin updates (except new Better Font Awesome installation)

---

## Pre-Deployment Checklist

- [ ] Tested Welcome page locally at https://wp.local/welcome/
- [ ] Icons displaying correctly (cloud, globe, server, question)
- [ ] Buttons are pill-shaped (50px border-radius)
- [ ] Card spacing correct (32px between, 16px rows)
- [ ] All content matches original Elementor version
- [ ] Elementor meta fields deleted locally (verified)
- [ ] Backup created: restore/pages/welcome-6-gutenberg.* files

---

## Deployment Steps

### Step 1: Git Deployment (Automated)

```powershell
# From wordpress repository root
cd c:\data\lochness\talendelight\code\wordpress

# Ensure all changes committed
git status

# Commit any remaining changes
git add wp-content/themes/blocksy-child/functions.php
git add restore/pages/welcome-6-gutenberg.*
git add docs/VERSION-HISTORY.md
git add docs/DEPLOYMENT-INSTRUCTIONS-v3.5.1.md
git add docs/SESSION-SUMMARY-FEB-08.md
git commit -m "v3.5.1: Migrate Welcome page to Gutenberg, install Better Font Awesome"

# Push to main (triggers Hostinger auto-deployment)
git push origin main
```

**Expected Result:** Hostinger deploys wp-content/ changes in 10-30 seconds

### Step 2: Verify Better Font Awesome Plugin Deployed

**✅ Plugin is now in Git:** Better Font Awesome v2.0.4 deployed automatically via Hostinger Git integration.

**Quick Verification:**

```powershell
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 `
  "cd domains/talendelight.com/public_html && wp plugin list --name=better-font-awesome --allow-root"
```

**Expected Output:**
```
name                   status   version  update
better-font-awesome    inactive 2.0.4    none
```

**Activate the Plugin:**

```powershell
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 `
  "cd domains/talendelight.com/public_html && wp plugin activate better-font-awesome --allow-root"
```

**Expected Output:**
```
Plugin 'better-font-awesome' activated.
Success: Activated 1 of 1 plugins.
```

### Step 3: Update Welcome Page Content

**Export from Local:**

```powershell
# Already in restore/pages/welcome-6-gutenberg.html
# Use existing update script
scp -i tmp/hostinger_deploy_key -P 65002 `
  restore/pages/welcome-6-gutenberg.html `
  u909075950@45.84.205.129:~/welcome-content.html
```

**Create Update Script on Production:**

```powershell
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
```

Once connected, create script:

```bash
cd ~
cat > update-welcome-page.php << 'EOF'
<?php
require_once('/home/u909075950/domains/talendelight.com/public_html/wp-load.php');

$content = file_get_contents('/home/u909075950/welcome-content.html');

if ($content === false) {
    echo "Error: Could not read content file\n";
    exit(1);
}

$result = wp_update_post([
    'ID' => 6,
    'post_content' => $content
]);

if (is_wp_error($result)) {
    echo "Error: " . $result->get_error_message() . "\n";
    exit(1);
}

echo "✅ Success: Welcome page updated with Gutenberg content\n";
EOF

# Run the script
wp eval-file update-welcome-page.php --path=/home/u909075950/domains/talendelight.com/public_html
```

### Step 4: Delete Elementor Meta Fields

```bash
# Still in SSH session
cd domains/talendelight.com/public_html

wp post meta delete 6 _elementor_edit_mode --allow-root
wp post meta delete 6 _elementor_data --allow-root
wp post meta delete 6 _elementor_version --allow-root
```

**Expected Output:**
```
Success: Deleted custom field.
Success: Deleted custom field.
Success: Deleted custom field.
```

(Note: Some may already be deleted, that's OK)

### Step 5: Clear Cache

```bash
# Still in SSH session
wp cache flush --allow-root

# If LiteSpeed Cache is active
wp litespeed-purge all --allow-root
```

### Step 6: Exit SSH

```bash
exit
```

---

## Post-Deployment Verification

### Automated Checks

Run from local machine:

```powershell
# Check plugin installed
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 `
  "cd domains/talendelight.com/public_html && wp plugin list --status=active --allow-root | grep better-font-awesome"

# Expected: better-font-awesome   active  2.0.4

# Check Elementor meta deleted
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 `
  "cd domains/talendelight.com/public_html && wp post meta list 6 --allow-root | grep elementor"

# Expected: No results (all Elementor meta deleted)
```

### Manual Verification

**Desktop Testing:**

1. Browse to: https://talendelight.com/welcome/
2. Hard refresh: Ctrl+Shift+R (clear cache)
3. Check:
   - [ ] Icons display correctly (cloud, globe, server, question mark)
   - [ ] Buttons are pill-shaped with proper styling
   - [ ] Card spacing looks correct (32px gaps)
   - [ ] All text content matches original
   - [ ] Hero section displays correctly
   - [ ] Footer trust badges visible

**Mobile Testing (Primary Goal):**

1. Open on actual mobile device
2. Navigate to: https://talendelight.com/welcome/
3. Check responsive design:
   - [ ] Cards stack vertically on mobile
   - [ ] Buttons are touch-friendly
   - [ ] Text is readable (font sizes appropriate)
   - [ ] Icons display correctly
   - [ ] No horizontal scrolling
   - [ ] Spacing looks balanced

**Browser Console Check:**

1. Open Developer Tools (F12)
2. Console tab - look for Font Awesome errors
3. Network tab - verify Font Awesome files loading locally (not from CDN)
4. Expected: No 404 errors, all resources from talendelight.com domain

---

## Rollback Procedure

If issues are discovered after deployment:

### Rollback Step 1: Restore Elementor Content

```powershell
# From local machine
scp -i tmp/hostinger_deploy_key -P 65002 `
  restore/pages/welcome-6-elementor.json `
  u909075950@45.84.205.129:~/
```

```bash
# SSH to production
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129

# Restore Elementor data
cd domains/talendelight.com/public_html
wp post meta update 6 _elementor_data "$(cat ~/welcome-6-elementor.json | jq -r .meta._elementor_data[0])" --allow-root
wp post meta update 6 _elementor_edit_mode builder --allow-root
wp cache flush --allow-root
```

### Rollback Step 2: Deactivate Better Font Awesome (Optional)

```bash
wp plugin deactivate better-font-awesome --allow-root
```

### Rollback Step 3: Verify

Browse to: https://talendelight.com/welcome/  
Should show original Elementor version

---

## Known Issues & Workarounds

**Issue 1: Font Awesome Icons Not Displaying**
- **Symptoms:** Rectangles or blank spaces instead of icons
- **Cause:** Plugin not installed or not activated
- **Fix:** Verify plugin status: `wp plugin list --status=active --allow-root | grep better`

**Issue 2: Buttons Not Pill-Shaped**
- **Symptoms:** Rectangular buttons instead of rounded
- **Cause:** CSS not loading or being overridden
- **Fix:** Check blocksy-child theme is active, clear all caches

**Issue 3: Spacing Issues**
- **Symptoms:** Cards too close or too far apart
- **Cause:** Inline styles not applying
- **Fix:** Hard refresh browser (Ctrl+Shift+R), clear server cache

---

## Success Criteria

✅ **All Must Pass:**

1. Welcome page loads without errors (200 response)
2. All 4 icons display correctly (not rectangles or blanks)
3. Buttons are pill-shaped (50px border-radius visible)
4. Card spacing matches design (visually balanced)
5. Mobile responsive (cards stack, no horizontal scroll)
6. No console errors in browser Developer Tools
7. Page loads faster than Elementor version (baseline: ~2s)

---

## Timeline

**Deployment Window:** Evening/Weekend (low traffic)  
**Estimated Duration:** 15-20 minutes  
**Rollback Time:** 5 minutes (if needed)

---

## Communication

**Before Deployment:**
- No user notification needed (cosmetic change)

**After Deployment:**
- Monitor analytics for bounce rate changes
- Test mobile across different devices
- Collect feedback on design improvements

---

## Related Documentation

- [VERSION-HISTORY.md](VERSION-HISTORY.md) - Full version history
- [SESSION-SUMMARY-FEB-08.md](SESSION-SUMMARY-FEB-08.md) - Development session notes
- [restore/pages/](../restore/pages/) - Backup files
- [QUICK-REFERENCE-DEPLOYMENT.md](QUICK-REFERENCE-DEPLOYMENT.md) - General deployment commands

---

## Deployment Checklist

**Pre-Deployment:**
- [ ] All code committed and pushed to main
- [ ] Backup files in restore/pages/ updated
- [ ] VERSION-HISTORY.md updated
- [ ] Session summary created
- [ ] Local testing complete

**Deployment:**
- [ ] Git push completed (Hostinger auto-deployed)
- [ ] Better Font Awesome plugin installed
- [ ] Welcome page content updated
- [ ] Elementor meta fields deleted
- [ ] Cache cleared

**Post-Deployment:**
- [ ] Desktop verification passed
- [ ] Mobile verification passed (PRIMARY GOAL)
- [ ] Console errors checked
- [ ] Performance verified (page load time)
- [ ] Version confirmed in production

**Sign-Off:**
- Deployed by: _______________
- Date/Time: _______________
- Issues: _______________

---

**Next Release:** v3.6.0 (MVP - April 15, 2026)
