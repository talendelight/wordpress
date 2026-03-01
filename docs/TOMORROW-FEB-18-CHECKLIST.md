# Tomorrow Checklist - February 18, 2026

## Priority 1: Test Other Landing Pages

### Employers Page
- [ ] **Production:** https://talendelight.com/employers/ (ID 16)
- [ ] **Local:** https://wp.local/employers/ (ID 64)
- [ ] Check button hover styling (should be blue #0062e3)
- [ ] Verify footer trust badges (emojis rendering correctly)
- [ ] Compare content between local and production
- [ ] Test all CTA button links

### Scouts Page
- [ ] **Production:** https://talendelight.com/scouts/ (ID 18)
- [ ] **Local:** https://wp.local/scouts/ (ID 76)
- [ ] Check button hover styling
- [ ] Verify footer trust badges
- [ ] Compare content
- [ ] Test CTA links

### Operators Page
- [ ] **Production:** https://talendelight.com/operators/ (ID 20)
- [ ] **Local:** https://wp.local/operators/ (ID 9)
- [ ] Check button hover styling
- [ ] Verify footer trust badges
- [ ] Compare content
- [ ] Test CTA links

### Managers Page
- [ ] **Production:** https://talendelight.com/managers/ (ID 19)
- [ ] **Local:** https://wp.local/managers/ (ID 8)
- [ ] Check button hover styling
- [ ] Verify footer trust badges
- [ ] Compare content
- [ ] Test CTA links

## Priority 2: Registration Workflow Testing

### Candidate Registration
- [ ] Click "Create Your Profile" button on candidates page
- [ ] Fill out registration form (test data)
- [ ] Verify form submission
- [ ] Check Manager Actions page for new approval request
- [ ] Test approve/reject workflow

### Employer Registration
- [ ] Test employer registration flow
- [ ] Verify approval workflow
- [ ] Check notification emails

### Scout Registration
- [ ] Test scout registration flow
- [ ] Verify approval workflow

## Priority 3: Fix Other Pages if Needed

### Common Issues to Check
- [ ] Button hover not working → Change to `is-style-fill` class
- [ ] Footer emojis corrupted → Replace with proper Unicode
- [ ] Page content inconsistencies → Use PHP restoration script

### Quick Fix Commands

**Check button format:**
```bash
# Production
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post get <ID> --field=post_content 2>/dev/null | grep -A2 'wp:button'"

# Local
podman exec wp bash -c "wp post get <ID> --field=post_content --allow-root 2>/dev/null | grep -A2 'wp:button'"
```

**Fix button format (if needed):**
```powershell
# Replace backgroundColor/textColor with is-style-fill
$content = Get-Content tmp\page-content.html -Raw
$content = $content -replace '<!-- wp:button \{"backgroundColor":"white","textColor":"navy".*?\} -->\s*<div class="wp-block-button"><a class="wp-block-button__link has-navy-color has-white-background-color.*?" href="([^"]+)".*?>([^<]+)</a></div>', '<!-- wp:button {"className":"is-style-fill"} -->`n        <div class="wp-block-button is-style-fill"><a class="wp-block-button__link wp-element-button" href="$1">$2</a></div>'
$content | Out-File -Encoding utf8 tmp\page-fixed.html
```

**Restore page with PHP script:**
```bash
# Use tmp/restore-page-7.php as template
# Change ID from 7 to target page ID
# Deploy and run on server
```

## Priority 4: Documentation Updates

### Task Management
- [ ] Review WORDPRESS-ALL-TASKS.csv - update status for completed tasks
- [ ] Check if any tasks blocked by testing results
- [ ] Update task dates if needed

### Release Notes
- [ ] Review RELEASE-NOTES-NEXT.md
- [ ] Add any findings from landing page testing
- [ ] Document any new issues discovered

## Quick Reference

### Page IDs
| Page | Local ID | Production ID |
|------|----------|---------------|
| Welcome | 6 | 6 |
| Candidates | 7 | 17 |
| Managers | 8 | 19 |
| Operators | 9 | 20 |
| Employers | 64 | 16 |
| Scouts | 76 | 18 |

### SSH Commands
```bash
# Connect to production
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129

# Production WordPress root
cd /home/u909075950/domains/talendelight.com/public_html

# Get page content
wp post get <ID> --field=post_content

# Update page (use PHP script method, NOT stdin)
php restore-page-<ID>.php

# Flush cache
wp cache flush
```

### Backup Commands
```powershell
# Backup local page
podman exec wp bash -c "wp post get <ID> --field=post_content --allow-root 2>/dev/null" | Out-File -Encoding utf8 restore\pages\<page-name>-<ID>.html

# Backup production page
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "wp post get <ID> --field=post_content 2>/dev/null" | Out-File -Encoding utf8 restore\pages\<page-name>-<ID>-production.html
```

## Known Issues Reference

### Issue 1: Button Hover Not Working
**Symptoms:** Buttons don't change to blue (#0062e3) on hover

**Cause:** Button using `backgroundColor/textColor` format instead of style class

**Solution:** Change button to use `className:"is-style-fill"` (see fix commands above)

### Issue 2: Footer Emojis Corrupted
**Symptoms:** Trust badges show garbled characters instead of emojis

**Cause:** UTF-8 encoding corruption during page updates

**Solution:** Replace corrupted text with proper Unicode emojis:
- 🔒 GDPR Compliant
- ✓ Secure & Reliable  
- 🤝 Equal Opportunity
- 🇪🇺 EU Markets (uses SVG image)

### Issue 3: Page Content Corruption
**Symptoms:** Page content becomes 1 line after update attempt

**Cause:** wp-cli stdin method fails with large HTML content

**Solution:** Use PHP script method with `wp_update_post()` (see restore-page-7.php template)

## Testing Checklist Template

For each page tested:

```markdown
### [Page Name] Page Testing Results

**Date:** YYYY-MM-DD
**Tester:** [Name]
**Environment:** Local / Production

#### Visual Checks
- [ ] Hero section displays correctly
- [ ] Card grid layout proper (3 cards or 2x2)
- [ ] Images/icons load correctly
- [ ] Footer trust badges show proper emojis

#### Button Hover
- [ ] Hero button: Navy → Blue on hover
- [ ] CTA button: Navy/White → Blue on hover
- [ ] Transition smooth (0.3s)
- [ ] Box shadow appears on hover

#### Functionality
- [ ] All buttons link to correct pages
- [ ] Page loads without errors
- [ ] Responsive on mobile (if applicable)

#### Issues Found
- [List any issues]

#### Actions Taken
- [List fixes applied]
```

## Success Criteria

All landing pages should have:
1. ✅ Consistent button hover behavior (blue #0062e3)
2. ✅ Proper footer emoji rendering
3. ✅ Working CTA links
4. ✅ Local/production content parity
5. ✅ No console errors

## Notes
- Use browser Incognito mode to avoid cache issues
- Hard refresh (Ctrl+Shift+F5) after changes
- Keep backup of working pages before making changes
- Test one page at a time to isolate issues
