# Release Notes & Deployment Instructions

**Status:** 🚧 Work in Progress (Next Release)

This document tracks all manual deployment steps required for the **next production release**.

**Purpose:** Ensure consistent, error-free deployments by documenting every manual step needed after Git push to main branch.

**Git Commit Summary:**
```
Remove WooCommerce, add Login/Logout Menu and WP User Manager plugins, restructure header navigation, create Help page, hide e-commerce pages, add employer flow documentation and wireframe template
```

**📋 See Process:** [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) for workflow documentation

---

## Release Information

**Target Release Date:** TBD (Next deployment)  
**Release Version:** 2.0.0  
**Branch:** develop → main

### Overview
- [ ] Navigation menu restructure with authentication support
- [ ] Plugin portfolio cleanup (removed WooCommerce/e-commerce functionality)
- [ ] User registration and email verification setup (foundation for employer flow)
- [ ] New Help page added
- [ ] WooCommerce pages hidden from navigation
- [x] Homepage CTA update: Single "Get Started" button with role-based smart routing (links to /log-in/)
- [x] Role rename: "Partner" → "Scout" (external talent referrer)
- [x] Test users created for all roles (local dev only)

---

## Pre-Deployment Checklist

- [ ] All changes committed to appropriate branch
- [ ] Local testing completed successfully
- [ ] Database delta files created and tested locally (if applicable)
- [ ] Elementor templates exported (if applicable)
- [ ] Release notes reviewed and finalized
- [ ] Required plugins verified active on production
- [ ] New Help page content finalized
- [ ] WP User Manager plugin added to production
- [ ] Login/Logout Menu plugin added to production
- [ ] WooCommerce confirmed not in use (safe to remove)
- [ ] Homepage "Get Started" button updated with smart routing logic
- [ ] Role-based redirect logic tested locally for all user roles

---

## Deployment Steps

### ⚠️ IMPORTANT: No Git Push Required

**ThStep 1: Determine Deployment Type

**Choose the appropriate deployment method:**

**Option A: Git Deployment (File Changes)**
- Use when: Pushing theme/plugin code changes
- Process: Git push → Hostinger auto-deploy → Manual steps below

**Option B: Database-Only Deployment (Elementor Content)**
- Use when: Creating pages via Elementor (no code changes)
- Process: Skip git push → Manual Elementor template import

---

### For Git Deployments:

#### Step 1: Git Push (if applicable)

```bash
git checkout main
git merge develop  # if using develop branch
git push origin main
```

**Result:** Hostinger automatically deploys `wp-content/` files

**⏱️ Wait 2-3 minutes for auto-deployment to complete**

#### Step 1: Remove WooCommerce (if still installed)

**⚠️ CRITICAL: Verify WooCommerce is not in use before removing**

1. Login to WordPress Admin: `https://talendelight.com/wp-admin/`
2. Navigate to: **Plugins → Installed Plugins**
3. Check if WooCommerce is installed:
   - If found and active → Deactivate first
   - Click "Delete" to uninstall WooCommerce
4. Verify removal: No e-commerce functionality should remain

**Why:** Removing WooCommerce and e-commerce features as they're not part of the TalenDelight business model.

---

#### Step 2: Install Required Plugins

**Login/Logout Menu (v1.5.2+):**
1. Navigate to: **Plugins → Add New Plugin**
2. Search: "Login Logout Menu"
3. Install and Activate
4. **Purpose:** Dynamic login/logout menu items based on user state

**WP User Manager (v2.9.13+):**
1. Navigate to: **Plugins → Add New Plugin**
2. Search: "WP User Manager"
3. Install and Activate
4. **Purpose:** Email verification and enhanced registration for employer flow

---

#### Step 3: Create Help Page


2. **Test header navigation:**
   - Verify menu shows: Welcome, About us, My account, Help, Login
   - Click each menu item - all should load correctly
   - Shop/Cart/Checkout pages should NOT appear in menu
   - When logged out: "Login" link visible
   - When logged in: "Logout" link visible

3. **Test Help page:**
   - Navigate to `/help/`
   - Page should load without errors
   - Content displays correctly

4. **Verify WooCommerce removal:**
   - Check Plugins page - WooCommerce should not be listed
   - No e-commerce functionality visible
   - No cart icon or shop pages in navigation
   - Pages → All Pages: Only 8 pages remain (Welcome, About us, Help, + 5 WPUM pages)
   - WooCommerce pages deleted (My account, Shop, Cart, Checkout, etc.)

5. **Test new plugins:**
   - Plugins → Installed Plugins
   - Verify active: Login/Logout Menu, WP User Manager
   - No PHP errors/warnings in admin

6. **Test "Get Started" button:**
   - As logged-out user: Click "Get Started" → Should redirect to login page
   - As logged-in user: Click "Get Started" → Should redirect to My Account
   - Verify button text is "Get Started" (not "For Employers"/"For Candidates")
   - Test both Hero section button and Final CTA button

7. **Browser console:** Verify no JavaScript errors

7. **Mobile responsive:** Test header menu on mobile devices

8. **Performance:** Optional Lighthouse audit
5. Note the page ID for menu configuration

**Alternative (faster):**
```bash
# Via SSH/WP-CLI on Hostinger
wp post create --post_type=page --post_title='Help' --post_status=publish --user=1
```

---

#### Step 4: Delete WooCommerce Leftover Pages

**⚠️ IMPORTANT: Delete these pages permanently - they conflict with WP User Manager pages**

Delete the following pages created by WooCommerce (no longer needed):

1. Navigate to: **Pages → All Pages**
2. Find and permanently delete:
   - **My account** (WooCommerce version - conflicts with WPUM "Account" page)
   - Shop
   - Cart
   - Checkout
   - Refund and Returns Policy
   - Sample Page
3. Hover over each page → Click **Trash** → Go to **Trash** → Click **Delete Permanently**

**⚠️ DO NOT DELETE these WP User Manager pages:**
- Log In ✅
- Register ✅
- Account ✅
- Profile ✅
- Password Reset ✅

**Alternative (faster via WP-CLI):**
```bash
# Via SSH on Hostinger - Find page IDs first
wp post list --post_type=page --fields=ID,post_title,post_status

# Delete WooCommerce pages (adjust IDs based on production)
wp post delete [MY_ACCOUNT_ID] [SHOP_ID] [CART_ID] [CHECKOUT_ID] [REFUND_ID] [SAMPLE_ID] --force

# Example (use actual IDs from your production):
# wp post delete 62 59 60 61 63 2 --force
```

**Why delete instead of draft?**
- WooCommerce "My account" page conflicts with WPUM "Account" page
- Clean up reduces confusion and potential routing conflicts
- These pages serve no purpose without WooCommerce

---

#### Step 5: Verify Page Cleanup

1. Navigate to: **Pages → All Pages**
2. Verify only these pages exist:
   - Welcome (Home) ✅
   - About us ✅
   - Help ✅
   - Log In (WPUM) ✅
   - Register (WPUM) ✅
   - Account (WPUM) ✅
   - Profile (WPUM) ✅
   - Password Reset (WPUM) ✅
3. Check **Trash** - should be empty or contain only deleted pages

---

#### Step 6: Configure Header Menu

1. Navigate to: **Appearance → Menus**
2. Create new menu: "Header Menu" (if not exists)
3. Add menu items in this order:
   - Welcome (homepage)
   - About us
   - My account
   - Help (newly created page)
   - Login/Logout (special menu item type from Login/Logout Menu plugin)
4. Assign menu to location: **Header Menu 1** (or appropriate theme location)
5. Save menu

**Alternative (WP-CLI):**
```bash
# Create menu
wp menu create "Header Menu"

# Add pages (adjust IDs based on production)
wp menu item add-post "Header Menu" 20  # Welcome
wp menu item add-post "Header Menu" 15  # About us
wp menu item add-post "Header Menu" 62  # My account
wp menu item add-post "Header Menu" [HELP_PAGE_ID]  # Help (use actual ID)

# Add Login/Logout item (must be done via UI - special menu type)

# Assign to location
wp menu location assign "Header Menu" menu_1
```

**⚠️ Login/Logout Menu Item:**
Must be added via WordPress Admin UI:
1. In menu editor, look for "Login/Logout" in available menu items
2. Add to menu
3. Save

---

#### Step 7: Configure WP User Manager (Basic Setup)

1. Navigate to: **WPUM → Settings**
2. **General Tab:**
   - Registration: Enable user registration
   - Email verification: Enable (recommended)
3. **Emails Tab:**
   - Customize email templates (optional for MVP)
4. Save settings

**Note:** Full configuration for Employer registration flow will come in a future release (WP-01.2 implementation).

---

#### Step 8: Update Homepage "Get Started" Button (WP-01.9)

**Change:** Replace dual CTAs ("For Employers" / "For Candidates") with single "Get Started" button that routes based on authentication and role.

**Implementation Options:**

**Option A: Export/Import Elementor Template (Recommended)**
1. Local: Open Home page in Elementor
2. Update both Hero and Final CTA buttons to "Get Started"
3. Export template: Elementor → Templates → Export
4. Production: Elementor → Templates → Import Template
5. Apply imported template to Home page
6. Publish changes

**Option B: Manual Edit in Production**
1. Login to WordPress Admin: `https://talendelight.com/wp-admin/`
2. Navigate to: **Pages → Home → Edit with Elementor**
3. **Hero Section:**
   - Select Button widget(s)
   - Change text to "Get Started"
   - Update button URL/link (see logic below)
4. **Final CTA Section:**
   - Select Button widget
   - Change text to "Get Started"
   - Update button URL/link (see logic below)
5. Click **Update** to publish

**Smart Routing Logic Implementation:**

*Initial MVP approach - Manual role detection:*
- For now: Set button to link to `/wp-login.php` with redirect parameter
- Button URL: `/wp-login.php?redirect_to=/my-account/`
- My Account page can then route users based on their role

*Future enhancement (Phase 2 - requires custom code):*
- Add JavaScript to detect logged-in status
- Query user role via AJAX
- Dynamically set button href:
  - Not logged in: `/wp-login.php`
  - Employer: `/employers/`
  - Candidate: `/candidates/`
  - Partner: `/partner/submit-candidate/`
  - Operator/Admin: `/wp-admin/`

**For MVP (this release):**
- Set button URL to: `/log-in/` (WP User Manager login page)
- User logs in and is redirected to `/account/` page
- Future iterations will add dynamic role-based routing to appropriate pages
- ✅ **COMPLETE**: Local implementation done, button links to `/log-in/`

**Time:** 5-10 minutes (manual edit) or 3-5 minutes (template import)

---

### Verification Steps

1. **Visit production site:** `https://talendelight.com/`
2. **Check functionality:** Test all changed features
3. **Browser console:** Verify no JavaScript errors
4. **Mobile responsive:** Test on multiple screen sizes
5. **Performance:** Optiona~35 minutes

| Step | Estimated Time |
|------|----------------|
| Git deployment | 5 min |
| Remove WooCommerce | 3 min |
| Install plugins (2) | 5 min |
| Create Help page | 2 min |
| Hide WooCommerce pages | 3 min |
| Configure header menu | 7 min |
| Configure WP User Manager | 5 min |
| Re-enable LiteSpeed Cache | 2 min |
| Verification | 10 min |
| **Total** | **~42ssue
   - Revert recent changes (git revert or UI changes)
   - Restore database backup if needed

2. **Communication:**
   - Update `WORDPRESS-OPEN-ACTIONS.md` with issue details
   - Notify stakeholders

3. **Fix and redeploy:**
   - Reproduce locally
   - Fix and test
   - Re-deploy following this process

---

## Time Estimate

**Total deployment time:** ~45-50 minutes

| Step | Estimated Time |
|------|----------------|
| Git deployment | 5 min |
| Remove WooCommerce | 3 min |
| Install plugins (2) | 5 min |
| Create Help page | 2 min |
| Delete WooCommerce pages | 3 min |
| Verify page cleanup | 1 min |
| Configure header menu | 7 min |
| Configure WP User Manager | 5 min |
| Update "Get Started" button | 5-10 min |
| Verification | 10 min |
| **Total** | **~46-51 min** |

---

## Deployment Metadata