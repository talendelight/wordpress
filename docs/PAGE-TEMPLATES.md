# WordPress Page Templates - Important Reference

> **⚠️ Note:** This is about **Page Templates** (PHP files that override entire pages).  
> For **Block Patterns** (reusable Gutenberg content snippets), see [PATTERN-LIBRARY.md](PATTERN-LIBRARY.md)

## Problem We Encountered

**Issue:** Select Role page looked incorrect after restoration because the custom template wasn't assigned.

**Why:** WordPress pages can use **custom templates** stored in the theme folder. The template assignment is stored in `wp_postmeta` table with meta_key `_wp_page_template`, NOT in the page content itself.

## How Page Templates Work

1. **Page Content** (`post_content`) - Gutenberg blocks, HTML content (fallback)
2. **Page Template** (`_wp_page_template` meta) - PHP file that overrides default display
3. **If template is assigned:** WordPress uses the template file INSTEAD of content
4. **If template is missing:** WordPress displays the page content

## Pages Using Custom Templates

### Select Role Page (ID: 49 production, ID: 9 local)
- **Slug:** `select-role`
- **Template:** `page-role-selection.php`
- **Location:** `wp-content/themes/blocksy-child/page-role-selection.php`
- **Display:** Dropdown with 3 roles (Candidate, Employer, Scout)
- **Migration:** `260224-1800-set-select-role-template.sql`
- **Backup:** `restore/pages/select-role-49.html` (content is just fallback)

## How to Check for Template Usage

```powershell
# Production - Check all pages with custom templates
ssh production "wp db query 'SELECT p.post_name, pm.meta_value FROM wp_posts p JOIN wp_postmeta pm ON p.ID = pm.post_id WHERE p.post_type=\"page\" AND pm.meta_key=\"_wp_page_template\" AND pm.meta_value != \"default\"' --allow-root"

# Local - Check specific page template
podman exec wp wp post meta get <PAGE_ID> _wp_page_template --allow-root --skip-plugins

# Production - Get template for specific page
ssh production "wp post meta get <PAGE_ID> _wp_page_template --allow-root"
```

## How to Fix Missing Templates

### 1. Set Template Meta (Immediate Fix)
```powershell
podman exec wp wp post meta update <PAGE_ID> _wp_page_template <template-file.php> --allow-root --skip-plugins
```

### 2. Create SQL Migration (Permanent Fix)
```sql
-- Example: 260224-1800-set-select-role-template.sql
DELETE FROM wp_postmeta 
WHERE post_id IN (SELECT ID FROM wp_posts WHERE post_name = 'page-slug' AND post_type = 'page')
  AND meta_key = '_wp_page_template';

INSERT INTO wp_postmeta (post_id, meta_key, meta_value)
SELECT ID, '_wp_page_template', 'template-file.php'
FROM wp_posts 
WHERE post_name = 'page-slug' AND post_type = 'page';
```

### 3. Update Restore Script (Automation)
Add template assignment to `restore-all-pages.ps1`:
```powershell
# Special handling for pages that require custom templates
if ($page.Slug -eq 'select-role') {
    podman exec wp bash -c "wp post meta update $pageId _wp_page_template page-role-selection.php --allow-root --skip-plugins 2>/dev/null" 2>$null | Out-Null
}
```

## Best Practices

1. ✅ **Always check for template meta** when exporting pages
2. ✅ **Create SQL migration** for template assignments
3. ✅ **Update restore script** with special handling
4. ✅ **Test both content and template** after restoration
5. ✅ **Document template usage** in page backups

## Template Files Location

All custom templates are in:
- **Production:** `/home/u909075950/domains/talendelight.com/public_html/wp-content/themes/blocksy-child/`
- **Local:** `wp-content/themes/blocksy-child/`

Template files are version-controlled in git and auto-deploy with theme changes.

## Related Files

- Migration: [infra/shared/db/260224-1800-set-select-role-template.sql](../infra/shared/db/260224-1800-set-select-role-template.sql)
- Restore Script: [infra/shared/scripts/restore-all-pages.ps1](../infra/shared/scripts/restore-all-pages.ps1)
- Template File: [wp-content/themes/blocksy-child/page-role-selection.php](../wp-content/themes/blocksy-child/page-role-selection.php)
