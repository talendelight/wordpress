# Lesson: Elementor Page Restoration from Templates

**Date**: February 5, 2026  
**Incident**: Lost all WordPress pages after database reset, successfully restored from tmp/elementor-templates/  
**Severity**: High (Complete content loss, but recovered)  
**Resolution Time**: 3 hours

## Problem Summary

After a database reset (`podman-compose down -v`), all WordPress pages were lost. Discovered that pages existed as Elementor template backups in `tmp/elementor-templates/` directory from January 20, 2026.

## Root Cause

1. **Primary**: Database was ephemeral and got destroyed with volume removal
2. **Secondary**: No automated backup strategy was in place
3. **Underlying**: Misunderstanding of MariaDB volume persistence behavior

## What Went Wrong

1. **Initial attempts failed** - `podman cp` corrupted JSON files:
   - PowerShell pipes changed encoding
   - JSON became malformed (e.g., `flex_direction` → `flex__direction`)
   - This is the documented PowerShell encoding corruption issue

2. **WP-CLI JSON import issues**:
   - `wp post meta update --format=json` failed on piped input
   - Shell escaping problems with large JSON payloads
   - Base64 encoding attempts also failed

3. **File transfer corruption**:
   - `podman cp` adds encoding markers
   - Binary `dd` transfer created binary output instead of text
   - Only `Get-Content -Raw -Encoding UTF8 | podman exec -i wp bash -c 'cat >'` worked

## What Worked

### Successful Import Method

```powershell
# 1. Transfer files safely (avoid encoding corruption)
foreach ($f in @('welcome-page.json', 'candidates-home.json', 'managers-home.json', 'operators-dashboard.json', 'manager-admin.json')) {
    Get-Content "tmp/elementor-templates/$f" -Raw -Encoding UTF8 | 
        podman exec -i wp bash -c "cat > /tmp/el-templates/$f"
}

# 2. Import via PHP WordPress API (not wp-cli)
podman exec wp wp eval-file import-direct-db.php --allow-root
```

### PHP Import Script Pattern

```php
global $wpdb;

// Delete existing meta first
$wpdb->delete(
    $wpdb->postmeta,
    ['post_id' => $page_id, 'meta_key' => '_elementor_data'],
    ['%d', '%s']
);

// Insert new data - store as raw JSON string
$wpdb->insert(
    $wpdb->postmeta,
    [
        'post_id' => $page_id,
        'meta_key' => '_elementor_data',
        'meta_value' => $json  // Raw JSON string, not PHP array
    ],
    ['%d', '%s', '%s']
);

// Set Elementor flags
update_post_meta($page_id, '_elementor_edit_mode', 'builder');
update_post_meta($page_id, '_wp_page_template', 'elementor_header_footer');
```

## Key Lessons

### 1. File Transfer in Containers

**❌ NEVER:**
```powershell
# This corrupts JSON files
podman cp file.json wp:/path/file.json
cat file.json | podman exec -i wp somecommand  # PowerShell pipes corrupt encoding
```

**✅ ALWAYS:**
```powershell
# Safe binary transfer
Get-Content file.json -Raw -Encoding UTF8 | podman exec -i wp bash -c 'cat > /path/file.json'
```

### 2. Elementor Data Storage

- Elementor stores page designs in `_elementor_data` post meta
- Data format: **Raw JSON string** (not serialized PHP, not base64)
- Must also set:
  - `_elementor_edit_mode` = `builder`
  - `_wp_page_template` = `elementor_header_footer`
  - `_elementor_template_type` = `wp-page`

### 3. Template Backups Are Critical

- Templates in `tmp/elementor-templates/` saved the day
- Created manually on January 20, 2026 after previous data loss incident
- These should be:
  - Exported after major page changes
  - Committed to git (in `docs/elementor-snapshots/` or similar)
  - Included in automated backups

### 4. WP-CLI Limitations

- `wp post meta update --format=json` is unreliable for large JSON payloads
- Shell escaping issues with special characters
- Better to use PHP `eval-file` with direct database operations

## Prevention Measures

### Implemented

1. ✅ Created `docs/BACKUP-STRATEGY.md` - comprehensive backup guide
2. ✅ Created `infra/dev/backup-local-db.ps1` - daily local backups
3. ✅ Created `infra/shared/scripts/backup-prod-db.ps1` - weekly production backups
4. ✅ Created `infra/dev/health-check.ps1` - daily environment health check
5. ✅ Documented safe file transfer patterns

### Recommended Next Steps

1. **Automate Elementor exports**:
   - Run `export-elementor-pages.ps1` before any database reset
   - Add to pre-commit hooks
   - Include in daily backup script

2. **Git-commit templates**:
   - Create `docs/elementor-snapshots/$(date)/` directories
   - Commit after each major page update
   - Version control the page designs

3. **Forminator form backups**:
   - Export Forminator forms to JSON
   - Store in `tmp/backups/forms/`
   - Include in backup strategy

4. **Baseline database updates**:
   - After content is stable, update `infra/shared/db/000000-0000-init-db.sql`
   - Include sample pages in baseline for faster dev environment reset

## Template Structure

### Working Template Format

```json
[
  {
    "id": "4475e4ef",
    "elType": "container",
    "settings": {
      "flex_direction": "column"
    },
    "elements": [...]
  }
]
```

**Not wrapped** in `{value: ...}` - direct array of Elementor elements.

### Template Files Restored

| File | Page | ID | Description |
|------|------|----|----|
| welcome-page.json | Welcome | 6 | Homepage with role selection |
| candidates-home.json | Candidates | 7 | Candidate dashboard |
| managers-home.json | Managers | 8 | Manager dashboard |
| operators-dashboard.json | Operators | 9 | Operator dashboard |
| manager-admin.json | Manager Admin | 10 | Admin panel with user requests table |

## Related Issues

- [powershell-encoding-corruption.md](powershell-encoding-corruption.md) - Root cause of file transfer issues
- [elementor-cli-deployment.md](elementor-cli-deployment.md) - Alternative deployment patterns
- [docs/BACKUP-STRATEGY.md](../BACKUP-STRATEGY.md) - Complete backup strategy

## Success Metrics

- ✅ All 5 pages restored successfully
- ✅ Elementor data intact (9,277+ characters per page)
- ✅ Pages render correctly in browser
- ✅ Editable in Elementor editor
- ✅ No manual page recreation required
- ⏱️ Recovery time: ~30 minutes once correct method identified

## Prevention Checklist

Before any `podman-compose down -v`:

- [ ] Run `infra/dev/backup-local-db.ps1`
- [ ] Verify backup file size > 1MB
- [ ] Export Elementor pages: `export-elementor-pages.ps1`
- [ ] Verify exports are not empty (>100 bytes each)
- [ ] Check `tmp/elementor-templates/` has recent templates
- [ ] Commit any uncommitted Elementor snapshots to git

## Quotes Worth Remembering

> "The JSON became malformed (e.g., `flex_direction` → `flex__direction`)" - This was the clue that PowerShell pipes were corrupting the data.

> "Template backups from January 20 saved the day" - Always maintain recent templates.

> "Use `Get-Content -Raw -Encoding UTF8 | podman exec -i` for safe transfer" - The only reliable method.
