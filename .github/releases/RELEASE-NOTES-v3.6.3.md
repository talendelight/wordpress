# Release Notes - v3.6.3

**Version:** 3.6.3  
**Release Date:** February 17, 2026  
**Type:** Patch Release  
**Status:** ✅ Deployed to Production

---

## Overview

This patch release fixes button hover styling and footer emoji rendering issues across all landing pages (Welcome, Candidates, Scouts, Employers). Implements CSS version-based cache busting strategy to ensure styling changes propagate correctly to users.

---

## What's New

### Landing Pages - Button Hover & Emoji Fixes

**Pages Updated:**
- Welcome (`/`) - Page ID 6
- Candidates (`/candidates/`) - Page ID 17 (production)
- Scouts (`/scouts/`) - Page ID 18 (production)
- Employers (`/employers/`) - Page ID 16 (production)

**Changes:**
1. **Button Hover Styling**
   - Fixed button hover not working on production
   - Changed CSS from `var(--color-blue)` to direct color value `#0062e3`
   - Ensures consistent blue hover across all buttons
   - Fixed CTA buttons using wrong format (backgroundColor/textColor → is-style-fill)

2. **Footer Trust Badges**
   - Fixed corrupted UTF-8 emoji characters
   - Replaced: ≡ƒöÆ → 🔒 (GDPR Compliant)
   - Replaced: Γ£ô → ✓ (Secure & Reliable)
   - Replaced: ≡ƒñ¥ → 🤝 (Equal Opportunity)

3. **CSS Cache Busting**
   - Implemented version-based cache invalidation
   - Theme version: 1.0.0 → 1.0.3
   - Documented in `docs/lessons/css-version-cache-busting.md`
   - Added to PAGE-UPDATE-WORKFLOW.md as mandatory step

---

## Technical Changes

### Files Modified

**Theme CSS:**
- `wp-content/themes/blocksy-child/style.css`
  - Version bumped: 1.0.0 → 1.0.3
  - Button hover rules use direct color values
  - Backed up in: `restore/css/blocksy-child-style.css`

**Page Content:**
- Welcome page - Updated and backed up in `restore/pages/welcome-6.html`
- Scouts page - Fixed CTA button format and emojis in `restore/pages/scouts-76.html`

**Documentation:**
- Created `docs/lessons/css-version-cache-busting.md`
- Updated `docs/PAGE-UPDATE-WORKFLOW.md` - Added Step 7 (CSS version bump)
- Updated `docs/PAGE-UPDATE-WORKFLOW.md` - Added Step 10 (cache clearing)

### Deployment Method

**Followed PAGE-UPDATE-WORKFLOW.md:**
1. ✅ Developed and tested in local environment (https://wp.local)
2. ✅ User approval obtained before each deployment
3. ✅ Created backups in restore/pages/ directory
4. ✅ Used PHP restoration scripts (no wp-cli stdin)
5. ✅ Incremented theme CSS version before deployment
6. ✅ Deployed complete page content
7. ✅ Verified deployment (line count, visual check)
8. ✅ Cleared all caches (WordPress + LiteSpeed + file cache)
9. ✅ Post-deployment verification in production
10. ✅ Documentation updated

---

## Deployment Steps

### Prerequisites
- [x] All changes tested in local environment
- [x] User approval obtained
- [x] Backups created in restore/ folder
- [x] PAGE-UPDATE-WORKFLOW.md followed

### Deployment Commands

**1. CSS Deployment (with version bump):**
```powershell
# Version already bumped to 1.0.3 in style.css
scp -P 65002 -i "tmp\hostinger_deploy_key" "wp-content\themes\blocksy-child\style.css" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/themes/blocksy-child/style.css
```

**2. Clear All Caches:**
```powershell
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cache flush && wp litespeed-purge all 2>/dev/null && rm -rf wp-content/cache/* 2>/dev/null"
```

**3. Verify Button Format (All Pages):**
```powershell
# Check all pages have correct button format
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post get 6 --field=post_content | grep -c 'is-style-fill'"  # Welcome
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post get 17 --field=post_content | grep -c 'is-style-fill'"  # Candidates  
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post get 18 --field=post_content | grep -c 'is-style-fill'"  # Scouts
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post get 16 --field=post_content | grep -c 'is-style-fill'"  # Employers
# Expected: 4 buttons each
```

---

## Verification

### Production URLs
- [Welcome Page](https://talendelight.com/)
- [Candidates Page](https://talendelight.com/candidates/)
- [Scouts Page](https://talendelight.com/scouts/)
- [Employers Page](https://talendelight.com/employers/)

### Test Checklist
- [x] Button hover shows blue (#0062e3) on all pages
- [x] Footer emojis render correctly (🔒 ✓ 🤝)
- [x] Hard refresh (Ctrl+Shift+R) loads new CSS version
- [x] Incognito mode shows correct styling
- [x] DevTools confirms style.css?ver=1.0.3 loading

---

## Issues Resolved

### Button Hover Not Working
- **Root Cause:** CSS variable `var(--color-blue)` not resolving correctly
- **Solution:** Changed to direct color value `#0062e3 !important`
- **Impact:** Fixed on all landing pages

### CSS Changes Not Reflecting
- **Root Cause:** Browser caching old CSS based on version number
- **Solution:** Implemented version bump workflow (1.0.0 → 1.0.3)
- **Documentation:** `docs/lessons/css-version-cache-busting.md`
- **Prevention:** Added mandatory step to PAGE-UPDATE-WORKFLOW.md

### CTA Button Format Inconsistency
- **Root Cause:** Some buttons using backgroundColor/textColor format instead of is-style-fill
- **Solution:** Standardized all buttons to use is-style-fill class
- **Impact:** Consistent hover behavior across all buttons

### Footer Emoji Corruption
- **Root Cause:** UTF-8 encoding corruption during page updates
- **Solution:** Replaced with proper Unicode emojis using PowerShell -Encoding utf8
- **Prevention:** Always use -Encoding utf8 in PowerShell (documented in workflow)

---

## Lessons Learned

**New Documentation Created:**
1. `docs/lessons/css-version-cache-busting.md`
   - Problem: Browser caching old CSS despite server cache clearing
   - Solution: Always increment theme version when deploying CSS changes
   - Prevention: Added to deployment workflow

**Workflow Updates:**
1. `docs/PAGE-UPDATE-WORKFLOW.md`
   - Added Step 7: CSS version bump (if CSS changes)
   - Added Step 10: Clear all caches after deployment
   - Updated step numbers throughout document

---

## Backup Files

**CSS:**
- `restore/css/blocksy-child-style.css` - Version 1.0.3 (11,430 bytes)

**Pages:**
- `restore/pages/welcome-6.html` - 14,134 bytes, 181 lines
- `restore/pages/candidates-7.html` - 21,362 bytes, 267 lines (local backup)
- `restore/pages/scouts-76.html` - 21,329 bytes, 270 lines

---

## Database Changes
None - This release only modifies CSS and page content.

---

## Known Issues
None

---

## Next Release Planning

**Version 3.6.4 (Planned):**
- Test and fix remaining landing pages (Operators, Managers)
- Complete registration workflow testing
- Any additional button/emoji fixes discovered during testing

See `docs/TOMORROW-FEB-18-CHECKLIST.md` for testing plan.

---

## Related Documents
- [PAGE-UPDATE-WORKFLOW.md](PAGE-UPDATE-WORKFLOW.md) - Complete deployment workflow
- [css-version-cache-busting.md](lessons/css-version-cache-busting.md) - CSS caching lesson
- [SESSION-SUMMARY-FEB-17.md](SESSION-SUMMARY-FEB-17.md) - Detailed session notes
- [TOMORROW-FEB-18-CHECKLIST.md](TOMORROW-FEB-18-CHECKLIST.md) - Next testing steps
- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Master deployment guide
