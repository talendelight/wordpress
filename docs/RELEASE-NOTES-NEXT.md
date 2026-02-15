# Release Notes & Deployment Instructions

**Status:** 📋 Planning  
**Version:** v3.6.2  
**Target Date:** TBD

This document tracks all manual deployment steps required for the **next production release**.

**Purpose:** Ensure consistent, error-free deployments by documenting every manual step needed after Git push to main branch.

**📋 See Process:** [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) for workflow documentation

---

## v3.6.2 Release Summary

**Release Type:** Page Migration + Form Styling  
**Deploy Date:** TBD

### Key Changes

**Elementor to Gutenberg Migration:**
- ✅ Register Profile page (ID 79) migrated from Elementor to Gutenberg
- Integrated Forminator form [forminator_form id="80"] with role parameter capture
- Added trust badges section using footer-trust-badges pattern
- Implemented URL parameter capture (td_user_role) via JavaScript + Forminator prefill
- ✅ Manager Admin page (ID 10) migrated from Elementor to Gutenberg (Feb 12, 2026)
- Reduced to 4-tile dashboard layout (2x2 grid): User & Role Management, System Settings, Audit Logs, Platform Monitoring
- Added navy CTA section and trust badges footer for consistency
- ✅ Cards section horizontal padding fixed (40% column width with centered layout)
- ✅ Managers page Admin card now links to /managers/admin
- ✅ Manager Actions page (ID 84) migrated from Elementor to Gutenberg (Feb 12, 2026)
- Created tabbed interface (Submitted, Approved, Rejected, All) with "Under Development" placeholders
- Tab switching with JavaScript, matching design system

**Form Styling Standardization:**
- ✅ Standardized Select Role and Login forms to consistent styling
- Container: 500px max-width, 40px padding, 60px margin-top
- Buttons: Select Role (navy #063970), Login/Submit (blue #3498DB), pill shape (50px radius)
- Dropdowns: 50px min-height to prevent text cutoff
- Added glow effects and hover animations for better UX

**Role Parameter Capture:**
- ✅ Added hidden-1 field to Forminator form for td_user_role capture
- Implemented dual capture: Forminator built-in prefill + JavaScript fallback
- Verified working in database (entry_id 10 shows hidden-1=scout)

### Files to Deploy

**Theme Files:**
- `wp-content/themes/blocksy-child/page-role-selection.php` (updated styling)

**Custom CSS:**
- `config/custom-css/login.css` (back button removed, button styling)
- `config/custom-css/forminator-forms.css` (submit button styling added)

**Page Content:**
- Register Profile (ID 79) - Gutenberg content with Forminator shortcode and JavaScript
- Manager Admin (ID 10) - Gutenberg 4-tile dashboard layout with CTA and footer
- Manager Actions (ID 84) - Gutenberg tabbed interface with "Under Development" placeholders
- Managers (ID 8) - Updated Admin card to link to /managers/admin
- **Backup files:** `restore/pages/register-profile-79.html`, `restore/pages/manager-admin-10.html`, `restore/pages/manager-actions-84.html`, `restore/pages/managers-8.html`, `restore/pages/select-role-template.php`, `restore/pages/login-styling.css`, `restore/pages/forminator-forms-styling.css`
- Managers (ID 8) - Updated Admin card to link to /managers/admin
- **Backup files:** `restore/pages/register-profile-79.html`, `restore/pages/manager-admin-10.html`, `restore/pages/manager-actions-84.html`, `restore/pages/managers-8.html`, `restore/pages/select-role-template.php`, `restore/pages/login-styling.css`, `restore/pages/forminator-forms-styling.css`

**Database Migrations:**
- `infra/shared/db/260211-2345-forminator-form-80-role-field.sql` (documentation of hidden-1 field addition)
- **Note:** Hidden field added manually via WordPress admin, not SQL migration

**Form Backups:**
- `restore/forms/forminator-form-80-post.sql` (Forminator form post backup)

### Testing Required

**Pre-Deployment (Local):**
- [x] Register Profile page displays correctly with Forminator form
- [x] Select Role → Register Profile → Form submission flow works
- [x] Role parameter captured from URL and saved to database
- [x] Button styling consistent across all pages
- [x] Container dimensions match (500px, 40px padding)
- [x] Manager Admin page displays with 6 tiles in Gutenberg editor
- [x] All admin tiles rendered with correct icons and descriptions
- [x] Elementor metadata removed from Manager Admin page
- [x] Form submission saves all data including hidden-1 (role) field

**Post-Deployment (Production):**
- [ ] Verify Register Profile page loads (http://talendelight.com/register-profile/)
- [ ] Test Select Role → Register Profile redirect with td_user_role parameter
- [ ] Test form submission and verify role captured in production database
- [ ] Verify button styling matches (navy for Select Role, blue for Submit)
- [ ] Test form on mobile/tablet devices
- [ ] Verify trust badges section displays correctly

---

## Deployment Steps

### Prerequisites

✅ **Completed:**
- [ ] Archive v3.6.1.json to archive folder: `Move-Item .github/releases/v3.6.1.json .github/releases/archive/v3.6.1.json`
- [ ] All changes tested locally
- [ ] Database migrations tested in isolation
- [ ] Backup created: `pwsh infra/shared/scripts/wp-action.ps1 backup`

### Step 1: Deploy Code to Production

**Action:** Push to main branch (triggers Hostinger auto-deployment)

```bash
git checkout main
git merge develop --no-edit
git push origin main
git checkout develop
```

**Wait:** 30-60 seconds for Hostinger to auto-deploy

### Step 2: Verify Deployment

**Action:** Run production health check

```powershell
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
```

**Expected:** All checks pass ✅

### Step 3: Apply Database Migrations (if any)

**Action:** Apply migrations via SSH

```bash
# No migrations for this release yet
```

### Step 4: Update Page Content (if any)

**Action:** Import pages via wp-cli

```bash
# No page updates for this release yet
```

### Step 5: Final Verification

**Action:** Manual testing checklist

- [ ] No manual tests defined yet

---

## Rollback Plan

**If deployment fails:**

```bash
# 1. Restore from latest backup
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true

# 2. If needed, revert code
git checkout main
git revert HEAD
git push origin main
git checkout develop
```

---

## Post-Deployment

### Success Criteria
- [ ] No criteria defined yet

### Archive This Release

**After successful deployment:**

```powershell
# Archive release notes
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
Move-Item docs/RELEASE-NOTES-NEXT.md ".github/releases/archive/RELEASE-NOTES-$timestamp.md"

# Archive release JSON
Move-Item .github/releases/v3.6.2.json .github/releases/archive/v3.6.2.json

# Create next version
Copy-Item .github/releases/archive/v3.6.2.json .github/releases/v3.6.3.json
# Update version number in v3.6.3.json

# Commit archive
git add .github/releases/archive/ .github/releases/v3.6.3.json docs/RELEASE-NOTES-NEXT.md
git commit -m "Archive v3.6.2, prepare v3.6.3"
git push origin main
git checkout develop
git merge main --no-edit
git push origin develop
```

---

## Notes

- Add implementation notes here as work progresses
- Document any gotchas or special considerations
- Track dependencies between changes

---

## Change Log

| Date | Change | Status |
|------|--------|--------|
| 2026-02-11 | Created release notes for v3.6.2 | Planning |
