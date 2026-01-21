# Updated Deployment Instructions - January 21, 2026

## Critical Changes to Elementor Page Deployment

### Issue Resolved
Manager Admin page was deployed but appeared broken (missing Hero section, icon boxes, tabs) due to PowerShell encoding corruption of shortcode attributes in JSON data.

### What Changed

#### 1. Export Method - NO CHANGES NEEDED ✅

**Current export script is already correct:** `infra/shared/scripts/export-elementor-pages.ps1`

Uses safe `podman cp` method:
```powershell
# Export inside container (no PowerShell interference)
podman exec wp bash -c "wp post meta get $localId _elementor_data --allow-root > /tmp/page.json"

# Binary copy (preserves encoding)
podman cp "wp:/tmp/page.json" $outputFile
```

**Enhanced validation added:**
- JSON structure validation ✅ (already present)
- Encoding checks (BOM, UTF-16) ✅ (already present)
- **NEW:** Shortcode attribute escaping validation

#### 2. Deployment Method - UPDATED ⚠️

**Previous method** (could fail silently):
```php
update_post_meta($page_id, '_elementor_data', $json);
// Returns false if data identical - even if existing data is corrupt!
```

**New forced deployment method:**
```php
// Delete existing meta first
delete_post_meta($page_id, '_elementor_data');

// Add fresh data
add_post_meta($page_id, '_elementor_data', $json, true);

// Result: Always updates, even if data seems "identical"
```

**Why this matters:**
- Production had 13,796 bytes (corrupt JSON with unescaped quotes)
- Local had 13,821 bytes (valid JSON with escaped quotes)
- `update_post_meta()` returned false because it thought 13,796 was "close enough"
- Forced delete+add pattern ensures data is actually replaced

#### 3. Validation Checklist - EXPANDED ✅

**Before deployment, verify:**
- [ ] JSON is valid (`json_decode()` succeeds)
- [ ] Encoding is clean (no BOM, not UTF-16)
- [ ] **NEW:** Structure element count matches local
- [ ] **NEW:** Shortcode attributes are escaped (if page has shortcodes)
- [ ] **NEW:** Visual verification of all page sections after deployment

### Updated Files

1. **docs/lessons/elementor-json-corruption-shortcodes.md** (NEW)
   - Complete root cause analysis
   - Technical explanation of JSON corruption
   - Prevention checklist

2. **docs/QUICK-REFERENCE-DEPLOYMENT.md** (UPDATED)
   - Added warnings about PowerShell redirection
   - Enhanced verification steps
   - Added shortcode validation checks

3. **infra/shared/scripts/export-elementor-pages.ps1** (UPDATED)
   - Added shortcode attribute escaping validation
   - Enhanced error messages

4. **tmp/force-deploy-elementor.php** (NEW)
   - Forced deployment script using delete+add pattern
   - Structure validation
   - Shortcode counting and display

### Key Takeaways

#### ❌ NEVER DO:
```powershell
# Piping through PowerShell corrupts JSON
podman exec wp bash -c "wp ..." > file.json        # CORRUPTS
podman exec wp bash -c "wp ..." | Out-File file    # CORRUPTS
```

#### ✅ ALWAYS DO:
```powershell
# Export inside container, then copy
podman exec wp bash -c "wp ... > /tmp/file.json"   # Safe (inside container)
podman cp wp:/tmp/file.json local/file.json         # Safe (binary copy)
```

#### Validation Before Deployment:
```php
// 1. Check JSON validity
$decoded = json_decode($json, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    die("Invalid JSON: " . json_last_error_msg());
}

// 2. Check structure count
echo "Structure elements: " . count($decoded) . "\n";
// Compare with local - should match exactly

// 3. Check shortcodes (if applicable)
function find_shortcodes($data, &$result = []) {
    foreach ($data as $key => $value) {
        if ($key === 'shortcode' && strpos($value, '[') !== false) {
            $result[] = $value;
        }
        if (is_array($value)) {
            find_shortcodes($value, $result);
        }
    }
    return $result;
}
$shortcodes = find_shortcodes($decoded);
foreach ($shortcodes as $sc) {
    echo "Found: $sc\n";
}

// 4. Force deployment
delete_post_meta($page_id, '_elementor_data');
add_post_meta($page_id, '_elementor_data', $json, true);

// 5. Clear caches
\Elementor\Plugin::$instance->files_manager->clear_cache();
wp_cache_flush();
```

### Testing Checklist

After deploying Elementor pages with shortcodes:

- [ ] Hero section displays
- [ ] All icon boxes/tiles render
- [ ] Navigation tabs work
- [ ] Shortcodes render data (not raw shortcode text)
- [ ] Responsive layout works (mobile/tablet)
- [ ] LiteSpeed cache cleared (if applicable)

### Impact Summary

**Manager Admin Page:**
- **Before:** Broken (blank sections, no content)
- **After:** Fully functional
  - ✅ Hero section (Admin Operations)
  - ✅ 6 icon boxes
  - ✅ Tabs component (5 tabs)
  - ✅ Shortcodes render tables
  - ✅ Help section
  - ✅ Footer

**Root Cause:** PowerShell encoding corruption
**Solution:** Use podman cp (already implemented in export script)
**Prevention:** Enhanced validation in export script

### Migration Path for Existing Broken Pages

If you discover a page is broken after deployment:

1. **Re-export from local:**
   ```powershell
   podman exec wp bash -c "wp post meta get PAGE_ID _elementor_data --allow-root > /tmp/page.json"
   podman cp wp:/tmp/page.json tmp/page-fixed.json
   ```

2. **Validate JSON:**
   ```powershell
   $json = Get-Content tmp/page-fixed.json -Raw | ConvertFrom-Json
   Write-Host "Structure elements: $($json.Count)"
   ```

3. **Force deploy:**
   - Upload `tmp/page-fixed.json` to production
   - Use force-deploy script with delete+add pattern
   - Verify visually

### Critical Configuration: MU-Plugin Form ID Mapping

**Issue:** MU-plugins may reference local form IDs (e.g., 364) instead of production form IDs (e.g., 80)

**Solution:** Update `forminator-custom-table.php` to support both environments:

```php
function td_forminator_to_custom_table($form_id, $response) {
    // Form ID: 364 (local dev), 80 (production)
    $target_form_ids = [364, 80];
    if (!in_array((int) $form_id, $target_form_ids, true)) {
        return;
    }
    // ... rest of function
}
```

**After updating:**
1. Redeploy MU-plugin to production
2. Run backfill script to sync existing Forminator submissions
3. Future submissions will sync automatically

### Questions?

- **Q: How do I know if a page is affected?**
  - A: Visit the page - if Hero section, tiles, or tabs are missing, it's affected

- **Q: Will re-exporting fix old exports?**
  - A: Yes, use Method 2 (Manual Export) from QUICK-REFERENCE-DEPLOYMENT.md

- **Q: Can I trust file size as indicator?**
  - A: No - 13,796 vs 13,821 bytes looked "close" but one was completely broken

- **Q: Why did update_post_meta return false?**
  - A: WordPress thinks data is identical when sizes are close, even if content differs

- **Q: Why aren't form submissions showing in Manager Admin?**
  - A: Check that MU-plugin has correct production form ID (not just local ID)

### Direct Database Update Method (Most Reliable)

If `delete_post_meta()` + `add_post_meta()` still fails (WordPress modifies data on save), use direct database update:

```php
global $wpdb;

// Get meta_id
$meta_row = $wpdb->get_row($wpdb->prepare(
    "SELECT meta_id FROM {$wpdb->postmeta} WHERE post_id = %d AND meta_key = '_elementor_data'",
    $page_id
));

// Direct update
$result = $wpdb->update(
    $wpdb->postmeta,
    ['meta_value' => $json],
    ['meta_id' => $meta_row->meta_id],
    ['%s'],
    ['%d']
);

// Clear caches
wp_cache_flush();
clean_post_cache($page_id);
\Elementor\Plugin::$instance->files_manager->clear_cache();
```

**Why this works:**
- Bypasses WordPress meta API completely
- No data modification during save
- Guaranteed exact byte match

### Related Documentation

- [lessons/elementor-json-corruption-shortcodes.md](lessons/elementor-json-corruption-shortcodes.md) - Full technical analysis
- [QUICK-REFERENCE-DEPLOYMENT.md](QUICK-REFERENCE-DEPLOYMENT.md) - Updated deployment procedures
- [lessons/powershell-encoding-corruption.md](lessons/powershell-encoding-corruption.md) - Original PowerShell encoding issue
