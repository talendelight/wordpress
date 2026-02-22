# Lesson: Stdin Method Corrupts Complex HTML Pages

**Date:** February 21, 2026  
**Incident:** Registration form page went blank after update attempt

## The Problem

Using `wp post update --post_content=-` with PowerShell stdin pipeline **corrupts complex HTML content** with inline JavaScript/CSS:

```powershell
# ❌ THIS CORRUPTED THE PAGE (reduced 25KB to 6 bytes containing just "-")
Get-Content tmp\page.html -Raw | podman exec -i wp wp post update 21 --post_content=- --allow-root
```

**Result:** Page content became a single dash character "-", completely wiping out the registration form.

## Root Cause

1. PowerShell's `Get-Content -Raw` with pipe to stdin
2. Complex HTML with inline `<script>` tags containing special characters
3. Cross-platform encoding issues (Windows PowerShell → Linux container stdin)
4. wp-cli's stdin processing of large multi-line content

## The Solution

**Use PHP script method instead** (from PAGE-UPDATE-WORKFLOW.md):

```powershell
# ✅ SAFE METHOD: Copy file to container, use PHP script
podman cp tmp\page-fixed.html wp:/tmp/page-local.html

# Create PHP script (see restore-page-21.php template):
podman cp tmp\restore-page.php wp:/var/www/html/

# Execute safely
podman exec wp php /var/www/html/restore-page.php

# Clean up
podman exec wp rm /var/www/html/restore-page.php
```

**PHP Script Template:** [tmp/restore-page-21.php](../../tmp/restore-page-21.php)

## Prevention Rules

**✅ DO:**
- Use PHP script method for pages with inline JavaScript/CSS
- Use `podman cp` to transfer files, then PHP to update database
- Include content validation (size checks) in restore scripts
- Keep backups in `restore/pages/` before any page updates

**❌ DON'T:**
- Use stdin pipe (`--post_content=-`) for complex HTML
- Update pages directly via wp-cli stdin on Windows
- Trust that stdin encoding will work across platform boundaries
- Skip backup creation before page updates

## Recovery Process

When page is corrupted:

1. **Check backup:** `Get-Item restore\pages\*page-name*.html`
2. **Copy to temp:** `Copy-Item restore\pages\xyz.html tmp\xyz-fixed.html`
3. **Apply fixes:** Edit tmp file as needed
4. **Use PHP method:** Follow safe restoration workflow above
5. **Verify:** Check page loads and content size matches backup

## References

- **Workflow:** [docs/procedures/PAGE-UPDATE-WORKFLOW.md](PAGE-UPDATE-WORKFLOW.md)
- **This incident:** [docs/SESSION-SUMMARY-FEB-21.md](SESSION-SUMMARY-FEB-21.md)
- **PHP template:** [tmp/restore-page-21.php](../../tmp/restore-page-21.php)
- **Recovered page:** Page 21 (Register Profile) - 25,103 bytes restored

## Related Lessons

- [powershell-encoding-corruption.md](powershell-encoding-corruption.md) - Similar encoding issues with Elementor JSON
- [elementor-json-corruption-shortcodes.md](elementor-json-corruption-shortcodes.md) - Shortcode corruption in JSON exports

---

**Status:** ✅ RESOLVED - Page restored successfully using PHP script method  
**Impact:** 15 minutes downtime (page blank during investigation/fix)  
**Prevention:** Always use PHP script method for pages with inline scripts
