# Comprehensive Backup Summary

**Date**: February 5, 2026  
**Context**: After data loss incident and successful recovery using tmp/elementor-templates/

---

## What Can Be Backed Up

### 1. **Database** ✅ CRITICAL
- **Content**: All posts, pages, users, settings, custom tables
- **Local**: Daily via `infra/dev/backup-local-db.ps1`
- **Production**: Weekly via `infra/shared/scripts/backup-prod-db.ps1`
- **Location**: `tmp/backups/local/` and `tmp/backups/production/`
- **Retention**: 7 days (local), 28 days (production)
- **Size**: ~0.5-2 MB (varies with content)

### 2. **Elementor Pages** ✅ CRITICAL  
- **Content**: Page designs, layouts, widget configurations
- **Export script**: `infra/shared/scripts/export-elementor-pages.ps1`
- **Location**: `tmp/backups/pages/$(date)/`
- **Retention**: 7 days
- **Size**: ~5-15 KB per page
- **Note**: Database backup does NOT backup Elementor designs properly - explicit export required

### 3. **Forminator Forms** ✅ IMPORTANT
- **Content**: Form structures, fields, validation rules, settings
- **Backup via**: `infra/dev/backup-all-local.ps1` (included)
- **Location**: `tmp/backups/forms/$(date)/forminator-forms.json`
- **Retention**: 30 days
- **Size**: ~10-50 KB per form
- **Note**: Forms stored as post_meta in database but complex structure needs special export

### 4. **Configuration Files** ⚠️ MOSTLY IN GIT
- **Content**: wp-config.php, .htaccess, uploads.ini, compose.yml
- **Backup via**: `infra/dev/backup-all-local.ps1` (included)
- **Location**: `tmp/backups/config/$(date)/`
- **Retention**: 30 days
- **Size**: <100 KB total
- **Note**: Already in git, backup for quick disaster recovery only

### 5. **Custom Plugins** ⚠️ ALREADY IN GIT
- **Content**: mu-plugins/, talendelight-roles/, forminator-upload-handler/
- **Backup via**: `infra/dev/backup-all-local.ps1` (included)
- **Location**: `tmp/backups/plugins/$(date)/`
- **Retention**: 30 days
- **Size**: Variable (few MB typically)
- **Note**: Already in git, backup before major changes only

### 6. **Media Uploads** ⚠️ NOT IMPLEMENTED YET
- **Content**: wp-content/uploads/ (images, PDFs, attachments)
- **Current status**: NOT being backed up automatically
- **Recommendation**: Implement when uploads become significant
- **Hostinger**: Includes in automated backups
- **Local**: Would need separate script

### 7. **Theme Customizations** ✅ IN GIT
- **Content**: Blocksy theme settings, custom CSS
- **Storage**: Database (theme_mods) + wp-content/themes/ (if customized)
- **Backup**: Database backup includes settings
- **Note**: Theme files in git, database backup covers customizations

### 8. **Plugin Settings** ✅ IN DATABASE
- **Content**: WooCommerce settings, Elementor settings, etc.
- **Backup**: Database backup includes all plugin settings
- **Note**: No separate backup needed

### 9. **User-Generated Content** ✅ IN DATABASE
- **Content**: Comments, user profiles, WooCommerce orders (future)
- **Backup**: Database backup includes everything
- **Note**: Custom tables (td_user_data_change_requests) included in database backup

### 10. **Git Repository** ✅ ALREADY BACKED UP
- **Content**: All code, docs, configs, scripts
- **Storage**: GitHub remote repository
- **Additional**: Local git history
- **Note**: No backup script needed - push to GitHub regularly

---

## Backup Scripts Available

### Master Script: Complete Backup
```powershell
# Backs up everything: Database + Pages + Forms + Config + Plugins
pwsh infra/dev/backup-all-local.ps1
```

### Individual Scripts
```powershell
# Database only (local)
pwsh infra/dev/backup-local-db.ps1

# Database only (production)
pwsh infra/shared/scripts/backup-prod-db.ps1

# Elementor pages only
pwsh infra/shared/scripts/export-elementor-pages.ps1

# Everything via master script
pwsh infra/dev/backup-all-local.ps1
```

---

## What's NOT Being Backed Up (And Should Consider)

### Media Uploads (wp-content/uploads/)
**Status**: ⚠️ NOT implemented  
**Risk**: Low (currently minimal uploads)  
**Action**: Implement when uploads become significant  
**Solution**: 
```powershell
# Future backup script
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
Copy-Item wp-content/uploads -Recurse "tmp/backups/uploads/$timestamp/"
```

### WordPress Core Files
**Status**: ❌ NOT needed  
**Risk**: None (can reinstall from wordpress.org)  
**Note**: Container image has core files

### Third-Party Plugins
**Status**: ❌ NOT needed  
**Risk**: None (can reinstall from wordpress.org)  
**Note**: Listed in git, reinstallable

---

## Backup Frequency Recommendations

| Component | Frequency | Trigger | Script |
|-----------|-----------|---------|--------|
| **Local DB** | Daily | Before work starts | `backup-local-db.ps1` |
| **Production DB** | Weekly | Friday evening | `backup-prod-db.ps1` |
| **Elementor Pages** | Before changes | Before page edits | Included in `backup-all-local.ps1` |
| **Forms** | Weekly | Friday | Included in `backup-all-local.ps1` |
| **Config** | On change | Before config edits | Included in `backup-all-local.ps1` |
| **Plugins** | On change | Before plugin edits | Included in `backup-all-local.ps1` |
| **Complete** | Before `down -v` | Before reset | `backup-all-local.ps1` |
| **Hostinger** | Automatic | Daily | hPanel automated backups |

---

## Storage Requirements

### Current (MVP Phase)
- Local backups (7 days): ~50-100 MB
- Production backups (28 days): ~100-200 MB
- Pages/Forms/Config: <10 MB
- **Total**: ~200-300 MB

### Future (Production with Content)
- Database with user data: ~500 MB - 2 GB
- Media uploads: ~1-10 GB (estimate)
- **Total**: ~2-12 GB (long term)

**Recommendation**: Keep `tmp/backups/` on local machine only (not in git). Consider external backup storage (Google Drive, Dropbox) for long-term retention.

---

## Quick Reference

### Before Destructive Operations
```powershell
pwsh infra/dev/backup-all-local.ps1
```

### Before Deployment
```powershell
pwsh infra/dev/backup-all-local.ps1
pwsh infra/shared/scripts/backup-prod-db.ps1
```

### Daily Routine
```powershell
# Morning backup before starting work
pwsh infra/dev/backup-local-db.ps1

# Or complete backup
pwsh infra/dev/backup-all-local.ps1
```

### Weekly Routine
```powershell
# Friday evening - backup production
pwsh infra/shared/scripts/backup-prod-db.ps1

# Complete local backup
pwsh infra/dev/backup-all-local.ps1
```

---

## Related Documentation

- [docs/BACKUP-STRATEGY.md](BACKUP-STRATEGY.md) - Complete backup strategy and recovery procedures
- [docs/lessons/elementor-page-restoration.md](lessons/elementor-page-restoration.md) - Page restoration lesson
- [docs/lessons/powershell-encoding-corruption.md](lessons/powershell-encoding-corruption.md) - Encoding issues
- [infra/dev/backup-all-local.ps1](../infra/dev/backup-all-local.ps1) - Master backup script
- [tmp/README.md](../tmp/README.md) - Backup directory documentation
