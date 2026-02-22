# Page Update & Deployment Workflow

## Purpose
Prevent page content corruption and ensure consistent quality by following a structured workflow for all page changes in WordPress.

## Problem Statement
Partial page updates and wp-cli stdin methods have caused multiple page corruption incidents:
- Content reduced from 267 lines to 1 line
- UTF-8 encoding corruption (emojis showing as garbled characters)
- Inline styles overriding theme CSS
- Lost page content requiring multiple restoration attempts

## Standard Workflow

### Phase 1: Local Development
1. **Make changes in local environment only**
   - URL: https://wp.local/
   - Use WordPress admin editor or direct page content updates
   - Never make changes directly in production first

2. **Verify changes locally**
   - Test all functionality (buttons, links, forms)
   - Check responsive design (if applicable)
   - Verify styling matches design system
   - Test button hover states
   - Verify footer elements (emojis, badges)

### Phase 2: Review & Approval
3. **User testing**
   - User tests the page in local environment
   - Check all sections, content, styling
   - Verify button hover behavior
   - Check spacing and layout

4. **Agreement to proceed**
   - User explicitly confirms: "This looks good, proceed to production"
   - Do NOT deploy without explicit confirmation
   - Document any remaining issues/concerns

### Phase 3: Backup & Deployment Preparation
5. **Create/update backup in restore/pages/**
   ```powershell
   # Backup local page
   podman exec wp bash -c "wp post get <LOCAL_ID> --field=post_content --allow-root 2>/dev/null" | Out-File -Encoding utf8 restore\pages\<page-name>-<LOCAL_ID>.html
   
   # Verify backup file size and line count
   Get-Item restore\pages\<page-name>-<LOCAL_ID>.html | Select-Object Name, Length
   (Get-Content restore\pages\<page-name>-<LOCAL_ID>.html).Count
   ```

6. **Verify backup integrity**
   - Check file size is reasonable (>10KB for typical landing page)
   - Check line count is reasonable (>200 lines for typical landing page)
   - Verify emojis render correctly in backup file

### Phase 4: Production Deployment

7. **Increment theme CSS version (if CSS changes included)**
   ```powershell
   # Open wp-content/themes/blocksy-child/style.css
   # Update Version header: 1.0.X → 1.0.X+1
   # Example: Version: 1.0.0 → Version: 1.0.1
   
   # Deploy updated CSS
   scp -P 65002 -i "tmp\hostinger_deploy_key" "wp-content\themes\blocksy-child\style.css" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/themes/blocksy-child/style.css
   ```
   
   **Why:** Forces browser cache invalidation. Without version bump, browsers cache old CSS even after server cache is cleared.
   
   **See:** [docs/lessons/css-version-cache-busting.md](lessons/css-version-cache-busting.md) for complete explanation.

8. **Replace entire production page content**
   ```powershell
   # Use PHP script method (NEVER use wp-cli stdin)
   scp -P 65002 -i "tmp\hostinger_deploy_key" "restore\pages\<page-name>-<LOCAL_ID>.html" u909075950@45.84.205.129:/tmp/candidates-local.html
   
   scp -P 65002 -i "tmp\hostinger_deploy_key" "tmp\restore-page-<PROD_ID>.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/
   
   ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && php restore-page-<PROD_ID>.php && rm restore-page-<PROD_ID>.php && wp cache flush"
   ```

9. **Verify deployment**
   ```bash
   # Check line count matches local
   ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post get <PROD_ID> --field=post_content | wc -l"
   
   # Should match local line count (±5 lines acceptable)
   ```

10. **Clear all caches**
   ```powershell
   # Clear WordPress and LiteSpeed caches
   ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cache flush && wp litespeed-purge all 2>/dev/null"
   ```

11. **Post-deployment checks**
    - Visit production URL
    - Test all buttons and links
    - Verify button hover behavior
    - Check footer elements
    - Compare visually with local version
    - Test in Incognito mode (avoid cache issues)
    - If CSS changes: Check DevTools Network tab to verify new CSS version loaded

### Phase 5: Documentation
12. **Update session summary**
    - Document what changed
    - Note any issues encountered
    - Record deployment timestamp
    - Update backup file reference

## Critical Rules

### ✅ DO
- ✅ Always develop in local first
- ✅ Get user approval before production deployment
- ✅ Use complete page replacement (not partial updates)
- ✅ Use PHP scripts for page content updates
- ✅ Use `-Encoding utf8` in PowerShell for all file operations
- ✅ Verify backups before deployment
- ✅ Verify production deployment after completion
- ✅ Keep backup files in restore/pages/ directory

### ❌ DON'T
- ❌ Never make changes directly in production
- ❌ Never use `wp post update --post_content=-` with stdin
- ❌ Never use bash `echo` or `cat` pipes for large HTML content
- ❌ Never deploy without user approval
- ❌ Never skip backup creation
- ❌ Never skip post-deployment verification
- ❌ Never use partial page updates or sed replacements on production

## PHP Restoration Script Template

```php
<?php
/**
 * Page restoration script for page ID <PAGE_ID>
 * Usage: php restore-page-<PAGE_ID>.php
 */
require_once('wp-load.php');

$backup_file = '/tmp/candidates-local.html';
$page_id = <PAGE_ID>;

// Read backup file
$content = file_get_contents($backup_file);
if ($content === false) {
    die('Error: Cannot read backup file at ' . $backup_file . "\n");
}

echo "Read " . strlen($content) . " bytes from backup file\n";
echo "Content preview: " . substr($content, 0, 100) . "...\n";

// Update post
$result = wp_update_post([
    'ID' => $page_id,
    'post_content' => $content,
    'post_status' => 'publish'
], true);

if (is_wp_error($result)) {
    die('Error: ' . $result->get_error_message() . "\n");
}

echo "Success: Updated post $page_id with " . strlen($content) . " bytes\n";

// Verify update
$updated_post = get_post($page_id);
if ($updated_post && strlen($updated_post->post_content) > 1000) {
    echo "Verification: Post content is " . strlen($updated_post->post_content) . " bytes\n";
    echo "Restoration successful!\n";
} else {
    echo "Warning: Post content may not have updated correctly\n";
}
```

## Page ID Reference

| Page | Local ID | Production ID | Backup Location |
|------|----------|---------------|-----------------|
| Welcome | 6 | 6 | restore/pages/welcome-6.html |
| Candidates | 7 | 17 | restore/pages/candidates-7.html |
| Managers | 8 | 19 | restore/pages/managers-8.html |
| Operators | 9 | 20 | restore/pages/operators-9.html |
| Employers | 64 | 16 | restore/pages/employers-64.html |
| Scouts | 76 | 18 | restore/pages/scouts-76.html |

## Common Issues & Solutions

### Issue: wp-cli stdin corruption
**Symptoms:** Page content becomes 1 line after update
**Cause:** wp-cli `--post_content=-` fails with large HTML
**Solution:** Use PHP script method (see template above)

### Issue: UTF-8 encoding corruption
**Symptoms:** Emojis show as garbled characters (≡ƒöÆ, Γ£ô, ≡ƒñ¥)
**Cause:** PowerShell default encoding or bash pipe encoding
**Solution:** Always use `Out-File -Encoding utf8` in PowerShell

### Issue: Button hover not working
**Symptoms:** Buttons don't change to blue on hover
**Cause:** Using `backgroundColor/textColor` instead of style classes
**Solution:** Use `className:"is-style-fill"` format for buttons (see [SESSION-SUMMARY-FEB-17.md](SESSION-SUMMARY-FEB-17.md))

### Issue: Inline styles override CSS
**Symptoms:** CSS hover rules don't apply
**Cause:** WordPress color classes generate inline styles
**Solution:** Use button style classes, not color properties

## Deployment Checklist

Before deploying any page to production:

- [ ] Page developed and tested locally
- [ ] User has tested and approved
- [ ] Backup created in restore/pages/
- [ ] Backup file size verified (>10KB)
- [ ] Backup line count verified (>200 lines)
- [ ] PHP restoration script prepared
- [ ] Production backup created (optional, for safety)
- [ ] Full page replacement ready (not partial update)

After deployment:

- [ ] Line count verified on production
- [ ] Visual inspection completed
- [ ] Button hover tested
- [ ] All links tested
- [ ] Footer elements checked
- [ ] Mobile/responsive tested (if applicable)
- [ ] Session summary updated
- [ ] Backup file reference documented

## Related Documents

- [SESSION-SUMMARY-FEB-17.md](SESSION-SUMMARY-FEB-17.md) - Lessons learned from button hover and emoji fixes
- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Overall deployment process
- [BACKUP-RESTORE-QUICKSTART.md](BACKUP-RESTORE-QUICKSTART.md) - Quick reference for backup/restore commands
- [DISASTER-RECOVERY-PLAN.md](DISASTER-RECOVERY-PLAN.md) - Emergency recovery procedures

## Version History

- **2026-02-17**: Initial version - documented workflow after multiple page corruption incidents
