# Welcome Page Restoration - Production

**Status**: Page ID 6 missing from production (confirmed not renamed/trashed)  
**Created**: February 8, 2026  
**Current Issue**: SSH connection timeout to production server

## Quick Restore Steps

Once SSH connection is restored, run these commands:

### 1. Upload Content and Script

```powershell
# Upload HTML content
scp tmp/welcome-page-clean.html u909075950@45.84.205.129:~/welcome-content.html

# Upload creation script
scp tmp/create-welcome-page.php u909075950@45.84.205.129:~/create-welcome-page.php
```

### 2. Create Welcome Page

```bash
# SSH to production
ssh u909075950@45.84.205.129

# Navigate to WordPress root
cd domains/talendelight.com/public_html

# Create/restore the page
wp eval-file ~/create-welcome-page.php --allow-root
```

**Expected Output:**
```
Creating new Welcome page...
Success: Welcome page ready (ID: X)
Set as homepage (page_on_front = X)
Cache flushed
```

### 3. Verify

```bash
# Check page exists
wp post list --post_type=page --format=csv --allow-root

# Check homepage setting
wp option get page_on_front --allow-root

# Open in browser
https://talendelight.com
```

## Files Prepared

| File | Purpose | Size | Location |
|------|---------|------|----------|
| `welcome-page-clean.html` | Page content with EU logo | ~13KB | `tmp/` |
| `create-welcome-page.php` | WP-CLI script to create page | ~1.5KB | `tmp/` |

## Content Features

✅ **EU Logo Integration**: Footer uses `/wp-content/themes/blocksy-child/assets/images/eu-logo.svg`  
✅ **Pattern-Based Structure**: Content follows pattern library design system  
✅ **Production-Ready**: 64px section spacing, Font Awesome icons, equal-height cards

## Troubleshooting

### SSH Connection Timeout

**Symptoms**: `ssh: connect to host 45.84.205.129 port 22: Connection timed out`

**Possible Causes**:
1. Hostinger rate-limiting (too many connections in short time)
2. Temporary network issue
3. Firewall blocking connections
4. Server maintenance

**Solutions**:
1. Wait 5-10 minutes and retry
2. Check Hostinger control panel for service status
3. Use Hostinger File Manager as alternative upload method
4. Contact Hostinger support if persists

### Alternative: Hostinger File Manager

If SSH remains unavailable:

1. Log in to Hostinger control panel
2. Open File Manager
3. Navigate to `domains/talendelight.com/public_html`
4. Upload `welcome-page-clean.html` and `create-welcome-page.php` to home directory
5. Open Terminal in File Manager
6. Run: `wp eval-file ~/create-welcome-page.php --allow-root`

### JSON Restore Failed

**Previous Attempt**: Using `welcome-6-production.json` failed with JSON parsing error

**Root Cause**: JSON file appears to have all content on single line (no formatting), possibly corrupted during export or contains Windows line endings

**Why HTML Method Better**:
- Direct content insertion (no JSON parsing)
- Verified content from local WordPress (working version)
- Includes EU logo integration
- Simpler error handling

## Investigation Notes

### Timeline

1. **Earlier Feb 8**: Welcome page created during v3.5.1 deployment (ID 6)
2. **Current Session**: Page missing, only 2 pages exist (Sample Page, Privacy Policy)
3. **First Restore Attempt**: JSON method failed (parsing error)
4. **Second Restore Attempt**: HTML method prepared (SSH timeout)

### What Happened to Original Page?

**Unknown** - Page completely disappeared between sessions. Possible causes:
- Database rollback to older backup
- Manual deletion (no trash record)
- Hosting issue/database reset
- Different database than expected

### Production State Before Restoration

- **Pages**: Only 2 exist (Sample Page ID 2, Privacy Policy ID 3)
- **Homepage**: Not set (page_on_front = 0)
- **Patterns**: All 10 deployed ✅
- **Assets**: EU logo deployed ✅
- **Theme**: blocksy-child active ✅

## Next Steps After Restoration

1. **Verify Page Loads**: Open https://talendelight.com and confirm content displays
2. **Check EU Logo**: Verify logo renders in footer trust badges
3. **Test Navigation**: Ensure "Get Started" buttons link to `/log-in/`
4. **Export New Backup**: Save restored version for future reference
5. **Update Documentation**: Record restore date and new page ID

## Backup Files Available

If current method fails, these alternatives exist:

| File | Format | Source | Notes |
|------|--------|--------|-------|
| `welcome-6-production.json` | JSON | WP-CLI export | Parsing failed (corrupted?) |
| `welcome-6-gutenberg-64px.html` | HTML | Elementor export | Older version (pre-EU logo) |
| `welcome-post-6.sql` | SQL | mysqldump | Direct database insert |
| `welcome-page-clean.html` | HTML | Current local | **Recommended** (includes EU logo) |

## Related Documentation

- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Full deployment process
- [QUICK-REFERENCE-DEPLOYMENT.md](QUICK-REFERENCE-DEPLOYMENT.md) - Quick commands
- [restore/pages/RESTORE-WELCOME-PAGE.md](../restore/pages/RESTORE-WELCOME-PAGE.md) - Complete restore guide
- [PATTERN-LIBRARY.md](PATTERN-LIBRARY.md) - Pattern library documentation
- [ASSETS-RESTORE.md](../restore/ASSETS-RESTORE.md) - Asset backup/restore

## Success Criteria

✅ Welcome page created on production  
✅ Page set as homepage (page_on_front)  
✅ EU logo displays in footer  
✅ All sections render correctly  
✅ Homepage loads at https://talendelight.com  
✅ Cache flushed  

---

**Last Updated**: February 8, 2026  
**Status**: Awaiting SSH connection restoration
