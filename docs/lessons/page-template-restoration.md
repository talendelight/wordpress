# Lesson: WordPress Page Templates Override Content

**Date:** February 24, 2026  
**Context:** Select Role page restoration  
**Issue:** Page looked incorrect after content restoration  
**Resolution:** Template meta assignment was missing

---

## What Happened

After restoring the Select Role page content from backup, the page still looked wrong:
- **Expected:** Clean dropdown form with 3 roles (Candidate, Employer, Scout)
- **Actual:** Basic button layout with 4 roles (including Employee)
- **Root Cause:** Missing `_wp_page_template` meta assignment

## The Problem: Two-Layer Page System

WordPress pages have **TWO** ways to display content:

### Layer 1: Page Content (`post_content`)
- Gutenberg blocks stored in `wp_posts.post_content`
- **Fallback** used when no template is assigned
- ✅ Restored by `restore-all-pages.ps1`

### Layer 2: Page Template (`_wp_page_template` meta)
- PHP file in theme folder (e.g., `page-role-selection.php`)
- **Overrides** page content completely when assigned
- Stored in `wp_postmeta` table
- ❌ **NOT** restored by content backup alone

## Why This Failed

Our restoration workflow:
1. ✅ Exported page content (Gutenberg blocks) → `restore/pages/select-role-49.html`
2. ✅ Imported content to local database → Updated `post_content`
3. ❌ **Forgot to check** if page uses custom template
4. ❌ Missing template meta → WordPress showed fallback content instead of template

## The Fix

### Immediate (Command Line)
```powershell
# Set template meta
podman exec wp wp post meta update 9 _wp_page_template page-role-selection.php --allow-root --skip-plugins
```

### Permanent (SQL Migration)
```sql
-- infra/shared/db/260224-1800-set-select-role-template.sql
DELETE FROM wp_postmeta 
WHERE post_id IN (SELECT ID FROM wp_posts WHERE post_name = 'select-role' AND post_type = 'page')
  AND meta_key = '_wp_page_template';

INSERT INTO wp_postmeta (post_id, meta_key, meta_value)
SELECT ID, '_wp_page_template', 'page-role-selection.php'
FROM wp_posts 
WHERE post_name = 'select-role' AND post_type = 'page';
```

### Automated (Restore Script)
```powershell
# restore-all-pages.ps1
if ($page.Slug -eq 'select-role') {
    podman exec wp bash -c "wp post meta update $pageId _wp_page_template page-role-selection.php --allow-root --skip-plugins 2>/dev/null" 2>$null | Out-Null
}
```

## How to Detect Template Usage

### Check Production
```powershell
# Single page
ssh production "wp post meta get <PAGE_ID> _wp_page_template --allow-root"

# All pages with templates
ssh production "wp post meta list --format=csv --allow-root" | Select-String "_wp_page_template" | Where-Object { $_ -notmatch "default" }
```

### Check Local
```powershell
podman exec wp wp post meta get <PAGE_ID> _wp_page_template --allow-root --skip-plugins
```

## Prevention Strategy

1. **When exporting pages**, always check for template meta:
   ```powershell
   wp post meta get <ID> _wp_page_template
   ```

2. **Document template usage** in page backup files:
   ```html
   <!-- Template: page-role-selection.php -->
   ```

3. **Create SQL migration** for template assignments

4. **Update restore script** with special handling for template pages

5. **Add to checklist**: "Does this page use a custom template?"

## Pages Currently Using Templates

| Page | Slug | Template | Migration |
|------|------|----------|-----------|
| Select Role | `select-role` | `page-role-selection.php` | `260224-1800-set-select-role-template.sql` |

## Related Documentation

- **Reference:** [docs/PAGE-TEMPLATES.md](../PAGE-TEMPLATES.md) - Complete guide
- **Workflow:** [docs/procedures/DATABASE-RESTORATION.md](procedures/DATABASE-RESTORATION.md#step-4-restore-page-content)
- **Instructions:** [.github/copilot-instructions.md](.github/copilot-instructions.md#pattern-usage-rules)

## Key Takeaway

**Content ≠ Display**

When troubleshooting page display issues, always check:
1. ❓ Does production use a custom template?
2. ❓ Is the template meta assigned locally?
3. ❓ Does the template file exist in local theme?

Don't assume content restoration is sufficient!
