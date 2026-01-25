# Lesson: Elementor Data Export/Import with Shortcodes

**Date:** January 21, 2026  
**Issue:** Manager Admin page deployed with broken Elementor structure - missing Hero section, icon boxes, and tabs despite having "correct" data size

## Problem Summary

After deploying Elementor data to production using standard export method (`wp post meta get`), the page appeared broken:
- ❌ No Hero section
- ❌ No icon boxes (6 tiles)
- ❌ No tabs component
- Production data size: 13,796 bytes
- Local data size: 13,821 bytes
- Only 25-byte difference seemed minimal

## Root Cause

**PowerShell piping corrupts JSON encoding** when exporting Elementor data that contains shortcodes with quoted attributes.

### What Happened:

1. **Initial export attempt** (BROKEN):
   ```powershell
   podman exec wp bash -c "wp post meta get 386 _elementor_data --allow-root" > tmp/export.json
   ```
   - PowerShell's `>` operator processes the stream and changes encoding
   - Result: `{"shortcode":"[user_requests_table status="new"]"}` (unescaped quotes)
   - JSON structure broken - quotes inside shortcode terminate the string prematurely
   - WordPress couldn't parse the Elementor data → rendered blank sections

2. **Proper export method** (WORKS):
   ```bash
   # Step 1: Export inside container to avoid PowerShell
   podman exec wp bash -c "wp post meta get 386 _elementor_data --allow-root > /tmp/export.json"
   
   # Step 2: Copy using podman cp (binary-safe)
   podman cp wp:/tmp/export.json tmp/manager-admin-proper.json
   ```
   - Result: `{"shortcode":"[user_requests_table status=\"new\"]"}` (properly escaped)
   - JSON is valid and parseable
   - Elementor renders all sections correctly

## Key Learnings

### ✅ DO:
1. **Always use `podman cp` for JSON exports** - it's binary-safe and preserves encoding
2. **Export to file inside container first**, then copy out to host
3. **Verify JSON validity** with `json_decode()` before deployment
4. **Force deployment** by deleting existing meta before adding new:
   ```php
   delete_post_meta($page_id, '_elementor_data');
   add_post_meta($page_id, '_elementor_data', $json, true);
   ```
   - `update_post_meta()` returns false when data is identical (even if corrupted)

5. **Validate deployment** by checking structure element count:
   ```php
   $decoded = json_decode($elementor_json, true);
   echo "Structure elements: " . count($decoded) . "\n";
   ```

### ❌ DON'T:
1. **Never pipe JSON through PowerShell** - `>` and `|` corrupt encoding
2. **Never trust file size alone** - 13,796 vs 13,821 bytes seemed close but one was completely broken
3. **Don't rely on `update_post_meta()` return value** for validation - it returns false for "no change" even if existing data is corrupt
4. **Don't assume small byte differences are acceptable** - even 25 bytes can mean completely broken JSON structure

## Technical Details

### Why PowerShell Corrupts JSON

PowerShell's stream redirection (`>`) and pipeline (`|`):
- Converts bytes to Unicode strings
- May apply BOM (Byte Order Mark)
- Processes special characters differently
- Can convert quote characters (`"` to `"` or smart quotes)
- Result: JSON with unescaped quotes that break parsing

### Why `podman cp` Works

`podman cp`:
- Binary transfer (no encoding conversion)
- Direct file copy from container filesystem
- Preserves exact byte sequences
- No character interpretation

### JSON Structure Issue

**Broken JSON** (from PowerShell pipeline):
```json
{"shortcode":"[user_requests_table status="new"]"}
                                           ^    ^
                                           |    |
                                           These quotes terminate the string
```

**Valid JSON** (from podman cp):
```json
{"shortcode":"[user_requests_table status=\"new\"]"}
                                           ^^    ^^
                                           ||    ||
                                           Properly escaped
```

## Deployment Checklist

When deploying Elementor pages with shortcodes:

- [ ] Export using `podman cp` method (not PowerShell redirection)
- [ ] Validate JSON with `json_decode()` before deployment
- [ ] Check structure element count matches local
- [ ] Search for shortcode widgets and verify attribute escaping
- [ ] Use delete + add pattern for forced deployment
- [ ] Clear all caches (Elementor, WordPress, LiteSpeed if applicable)
- [ ] Verify visually that all sections render

## Files Reference

**Working export script:**
```bash
# Inside Copilot instructions (docs/ directory)
# Export Elementor page data safely
podman exec wp bash -c "wp post meta get PAGE_ID _elementor_data --allow-root > /tmp/page-export.json"
podman cp wp:/tmp/page-export.json tmp/page-export.json
```

**Deployment script:** `tmp/force-deploy-elementor.php`
- Uses `getcwd()` for current directory (not `__DIR__` which points to wp-cli phar)
- Validates JSON before deployment
- Deletes existing meta for forced update
- Counts structure elements
- Lists all shortcodes found

## Impact

**Before fix:** Page completely broken (blank sections)
**After fix:** All sections render correctly:
- ✅ Hero section (Admin Operations)
- ✅ 6 icon boxes (User Registration Request Approvals, User Management, System Settings, Audit Logs, Role Management, Platform Monitoring)
- ✅ Tabs component with 5 tabs (New, Submitted, Approved, Rejected, All)
- ✅ Shortcodes render data tables
- ✅ Help section
- ✅ Footer with compliance icons

## Related Documentation

- [docs/lessons/powershell-encoding-corruption.md](powershell-encoding-corruption.md) - Original PowerShell encoding issue with Elementor exports
- [docs/QUICK-REFERENCE-DEPLOYMENT.md](../QUICK-REFERENCE-DEPLOYMENT.md) - Update with new safe export method
- [docs/DEPLOYMENT-WORKFLOW.md](../DEPLOYMENT-WORKFLOW.md) - Add JSON validation steps

## Prevention

**Update all Elementor export scripts** to use the safe method:
1. Export to file inside container
2. Copy using `podman cp`
3. Validate JSON before deployment
4. Force update by deleting existing meta first

**Add to pre-deployment checks:**
- JSON validation test
- Structure element count verification
- Shortcode attribute escaping check
