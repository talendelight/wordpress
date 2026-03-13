# Hero & CTA Shortcode Implementation - Complete

**Status:** ✅ Fully Implemented and Tested  
**Date:** March 13, 2026  
**Version:** v3.7.4

## Summary

Successfully converted all WordPress pages from hard-coded HTML hero and CTA sections to centralized shortcode-based template system.

## Files Created

### Template Files
1. **wp-content/themes/blocksy-child/includes/hero-template.html**
   - Navy background hero section with placeholders
   - Supports optional CTA button via `{{CTA_SECTION}}` placeholder
   - Designed for Gutenberg block editor

2. **wp-content/themes/blocksy-child/includes/cta-template.html**
   - Navy background CTA section (H2 heading)
   - Same placeholder system as hero
   - Consistent styling across all pages

### Shortcode Functions
**File:** wp-content/themes/blocksy-child/functions.php

1. **td_hero_shortcode()** (Lines 430-516)
   - Loads hero-template.html
   - Replaces `{{title}}`, `{{subtitle}}`, `{{CTA_SECTION}}` placeholders
   - Optional CTA button (if `cta_display` empty, button is omitted)
   - Subtitle is optional (legal pages use title only)
   - Usage:
     ```
     [td_hero title="Page Title" subtitle="Description" cta_display="Button Text" cta_link="/path"]
     [td_hero title="Legal Page" subtitle=""]  <!-- No subtitle, no button -->
     ```

2. **td_cta_shortcode()** (Lines 518-576)
   - Same structure as hero but uses cta-template.html
   - H2 heading instead of H1
   - Slightly different button margin (48px vs var(--space-2xl))

## Pages Converted (13 Total)

### Public Pages with Hero + CTA (5 pages)
1. ✅ **about-us-6.html** - "Talent for today. Growth for tomorrow." + "Ready to get started?"
2. ✅ **candidates-21.html** - "Accelerate Your Career Growth" + "Ready to Take the Next Step?"
3. ✅ **employers-22.html** - "Hire vetted software engineers..." + "Ready to build your team?"
4. ✅ **scouts-23.html** - "Connect Talent with Opportunity" + "Ready to Start Scouting?"
5. ✅ **help-7.html** - "Help & Support" + "Need More Help?"

### Internal Pages with Hero Only (5 pages)
6. ✅ **managers-24.html** - "Manager's Dashboard" (has CTA)
7. ✅ **operators-25.html** - "Operator's Dashboard" (has CTA)
8. ✅ **manager-admin-26.html** - "Admin Operations" (no CTA)
9. ✅ **manager-actions-27.html** - "Manager Actions" (no CTA)
10. ✅ **operator-actions-49.html** - "Operator Actions" (no CTA)

### Legal Pages with Hero Only (3 pages)
11. ✅ **privacy-policy-3.html** - "Privacy Policy" (title only, no subtitle)
12. ✅ **terms-conditions-60.html** - "Terms & Conditions" (title only)
13. ✅ **cookie-policy-99.html** - "Cookie Policy" (title only)

## Pages Intentionally Skipped

- **403-forbidden-29.html** - Error page with custom gray background design, large "403" error number, and specialized layout. Does not match standard hero/CTA pattern.
- **about-us-6-test.html** - Test file, should be deleted after deployment

## Code Reduction

**Before:** Each hero section = 25+ lines of HTML  
**After:** Each hero section = 1 shortcode line

**Example Reduction:**
```html
<!-- BEFORE (24 lines) -->
<!-- wp:group {"align":"full","style":{...},"backgroundColor":"navy",...} -->
<div class="wp-block-group alignfull has-gray-off-white-color has-navy-background-color...">
    <h1 class="wp-block-heading has-text-align-center" style="font-size:48px;font-weight:700">
        Accelerate Your Career Growth
    </h1>
    <p class="has-text-align-center" style="...">
        Connect with top employers in the Baltic and Northern European markets...
    </p>
    <div class="wp-block-buttons" style="margin-top:var(--space-2xl)">
        <div class="wp-block-button is-style-fill">
            <a class="wp-block-button__link wp-element-button" href="/register">
                Create Your Profile
            </a>
        </div>
    </div>
</div>
<!-- /wp:group -->

<!-- AFTER (2 lines) -->
<!-- Hero Section - Centralized via shortcode -->
[td_hero title="Accelerate Your Career Growth" subtitle="Connect with top employers in the Baltic and Northern European markets. Build your profile, showcase your skills, and land your next great opportunity." cta_display="Create Your Profile" cta_link="/register"]
```

**Total Lines Saved:** ~300+ lines across all pages  
**Maintenance Impact:** Update 1 template file → affects all 13 pages instantly

## Testing Results

**Test File:** tmp/test-hero-cta-shortcodes.php

✅ Test 1: Hero with CTA button - All checks passed  
✅ Test 2: Hero without CTA (legal page) - All checks passed  
✅ Test 3: CTA section - All checks passed  
✅ Test 4: Footer badges - All checks passed  

All shortcodes generate correct HTML structure with:
- Navy background
- Proper heading levels (H1 for hero, H2 for CTA)
- Escaped content (esc_html, esc_url)
- Gutenberg block comments preserved
- Optional CTA button logic working

## Benefits

### Centralized Management
- Update hero styling: Edit 1 template file → affects all pages
- Update CTA styling: Edit 1 template file → affects all pages
- No need to edit individual page HTML

### Consistency
- All heroes use identical navy background, typography, spacing
- All CTAs use identical styling
- Button styling consistent across all pages

### Maintainability
- Easier to update: Change template file instead of 13 page files
- Less error-prone: Single source of truth
- Faster updates: 1 file vs 13 files

### Developer Experience
- Clear shortcode syntax
- Self-documenting with attributes
- Easy to add new pages with standard sections
- Template placeholder system is simple (str_replace)

## Next Steps

### Immediate (Pre-Deployment)
1. ⏳ Deploy to local WordPress and test page rendering
2. ⏳ Verify responsive design on mobile/tablet
3. ⏳ Check browser console for JavaScript errors
4. ⏳ Test all CTA button links

### Deployment
1. ⏳ Git commit all changes
2. ⏳ Deploy to production via deploy-pages.ps1
3. ⏳ Clear production cache
4. ⏳ Verify on production site
5. ⏳ Delete about-us-6-test.html test file

### Future Enhancements (Optional)
1. Create additional shortcodes for card grids, feature sections
2. Add more template variations (e.g., light hero, gradient CTA)
3. Add custom CSS class parameter for specialized pages
4. Create shortcode pattern library documentation

## Related Files

- **Template Guide:** docs/SHORTCODE-USAGE.md (to be created)
- **Background Work:** SQL parameterization, menu ID automation (completed earlier)
- **Previous Session:** Footer badges shortcode implementation

## Technical Notes

### Template Placeholder System
- Uses simple `str_replace()` for placeholder substitution
- Placeholders: `{{title}}`, `{{subtitle}}`, `{{CTA_SECTION}}`
- CTA section conditionally generated based on `cta_display` parameter
- Empty subtitle allowed for legal pages (validation fixed)

### Security
- All user input escaped with `esc_html()` and `esc_url()`
- Template files loaded from controlled directory
- File existence checks prevent fatal errors

### Error Handling
- Missing template file: Returns HTML comment with error
- Missing title: Returns HTML comment (logged to error_log)
- Invalid paths: Error logged, comment returned

## Session Context

Started with SQL parameterization and menu ID automation. User requested: "continue to create hero and CTA template files. And apply them to all pages"

Completed shortcode implementation systematically:
1. Created template files
2. Refactored shortcode functions from inline PHP to template-based
3. Applied to role pages (candidates, employers, scouts, managers, operators)
4. Applied to internal pages (manager-admin, manager-actions, operator-actions)
5. Applied to legal pages (privacy, terms, cookie)
6. Applied to help and about-us pages
7. Fixed empty subtitle validation for legal pages
8. Tested all shortcodes successfully

**Status:** Ready for deployment and testing on local WordPress instance.
