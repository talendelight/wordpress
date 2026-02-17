# CSS Version Cache Busting

**Date:** February 17, 2026  
**Context:** Welcome page deployment - button hover not working after CSS deployment

## Problem

After deploying updated CSS to production with button hover fixes (`#0062e3`), the hover effect didn't work on production even though:
- ✅ CSS file was correctly deployed
- ✅ File timestamp was recent (Feb 17 06:41)
- ✅ Button HTML format was correct (`is-style-fill`)
- ✅ WordPress cache was flushed
- ✅ LiteSpeed cache was purged
- ✅ Direct inspection of CSS on server showed correct rules

**Root Cause:** Browser caching old CSS file based on version number in theme header.

## Technical Details

WordPress enqueues stylesheets with version parameter:
```html
<link rel="stylesheet" href="/wp-content/themes/blocksy-child/style.css?ver=1.0.0">
```

When the version stays the same (`1.0.0`), browsers cache the CSS file aggressively. Server-side cache clearing (WordPress cache, LiteSpeed cache) doesn't affect browser cache.

## Solution

**Always increment theme version number when deploying CSS changes:**

```css
/* Before */
Version: 1.0.0

/* After */
Version: 1.0.1
```

This forces WordPress to enqueue CSS with new version parameter:
```html
<link rel="stylesheet" href="/wp-content/themes/blocksy-child/style.css?ver=1.0.1">
```

Browsers see this as a new resource and bypass cache.

## Implementation Steps

1. **Update version in style.css header**
   ```css
   /*
   Theme Name: Blocksy Child
   Template: blocksy
   Version: 1.0.X  // Increment this
   Description: Custom child theme with unified design system for TalenDelight
   */
   ```

2. **Deploy CSS file to production**
   ```powershell
   scp -P 65002 -i "tmp\hostinger_deploy_key" "wp-content\themes\blocksy-child\style.css" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/themes/blocksy-child/style.css
   ```

3. **Clear all caches**
   ```powershell
   ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cache flush && wp litespeed-purge all 2>/dev/null"
   ```

4. **Verify in browser DevTools**
   - Open Network tab (F12)
   - Reload page
   - Check CSS file loads with new version: `style.css?ver=1.0.X`

## Version Numbering Strategy

Use semantic versioning for theme CSS:
- **Patch (1.0.X → 1.0.X+1):** Minor CSS tweaks, bug fixes, color adjustments
- **Minor (1.X.0 → 1.X+1.0):** New CSS components, significant styling changes
- **Major (X.0.0 → X+1.0.0):** Complete redesign, breaking changes

For daily development iterations, incrementing patch version is sufficient.

## Related Issues

- Button hover not working despite correct CSS deployment
- Color changes not reflecting in production
- Layout changes not appearing after deployment
- Any CSS-only changes that don't touch HTML/PHP

## Prevention

✅ **Add version bump to deployment workflow** - make it a mandatory step when deploying CSS changes  
✅ **Document current version** - keep track of deployed version in session notes  
✅ **Test in Incognito mode** - always verify CSS changes in private browsing first  
✅ **Check DevTools Network tab** - confirm new version is loading before declaring success

## When NOT to Bump Version

❌ PHP file changes (functions.php, templates)  
❌ Page content updates (HTML only)  
❌ Plugin updates  
❌ Database changes  

Version bump is specifically for CSS changes in the theme stylesheet.

## Files Affected

- `wp-content/themes/blocksy-child/style.css` - Must update Version header
- Browser cache - Automatically cleared when version changes
- CDN cache (if applicable) - May need separate purging

## Success Criteria

After version bump and deployment:
1. Hard refresh browser (Ctrl+Shift+R)
2. Check DevTools Network tab shows new version
3. CSS changes immediately visible
4. Works in both regular and Incognito mode
5. No need for users to clear their browser cache

## Historical Context

This issue occurred after:
- Deploying Welcome page with spacer removed
- Deploying CSS with button hover fix (`var(--color-blue)` → `#0062e3`)
- Multiple cache flushes that didn't resolve the issue

Version bump from 1.0.0 → 1.0.1 immediately resolved the issue.

## Related Documents

- [PAGE-UPDATE-WORKFLOW.md](../PAGE-UPDATE-WORKFLOW.md) - Updated to include version bump step
- [SESSION-SUMMARY-FEB-17.md](../SESSION-SUMMARY-FEB-17.md) - Full context of button hover fixes
- [powershell-encoding-corruption.md](./powershell-encoding-corruption.md) - Another deployment lesson
