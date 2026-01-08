# Release Notes & Deployment Instructions

**Status:** 🚧 Work in Progress (Next Release)

This document tracks all manual deployment steps required for the **next production release**.

**Purpose:** Ensure consistent, error-free deployments by documenting every manual step needed after Git push to main branch.

**Git Commit Summary:**
```
Implement TalenDelight custom roles (v1.0.0), role-based login redirect, 403 forbidden page, performance optimizations (OPcache), menu structure with Login/Logout plugin
```

**📋 See Process:** [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) for workflow documentation

---

## Release Information

**Target Release Date:** TBD (Next deployment)  
**Release Version:** 3.0.0  
**Branch:** develop → main

### Overview
- [x] Custom WordPress roles implementation (WP-04.1) - ✅ Plugin active, all 5 roles created locally
- [x] 403 Forbidden access control (WP-04.1a) - ✅ Implemented in plugin with business-friendly error page
- [x] 403 Forbidden page created - ✅ /403-forbidden/ with Go to Home Page and Log Out buttons
- [x] Build Employers page (WP-01.2) - ✅ Complete and published in local (Hero, How It Works, Specialties, Why TalenDelight, Final CTA)
- [x] Role-based login redirect - ✅ Working via wpum_after_login hook (Employer→/employers/ confirmed)
- [x] Test users created locally - ✅ All 10 test users (5 custom + 4 default WP + wpadmin)
- [x] Access restricted to TalenDelight roles only - ✅ Editor/author roles now show 403 page
- [x] Menu structure configured - ✅ Welcome, Help, Profile, Log in/Log out (conditional)
- [x] Performance optimizations - ✅ OPcache enabled, debug disabled
- [ ] Navigation menu restructure with authentication support - Assign menu to header location  
- [ ] User registration and email verification setup - Configure WP User Manager email settings
- [ ] New Help page deployment - Deploy Help page to production
- [ ] Create test users in production

---

## Pre-Deployment Checklist

- [ ] All changes committed to appropriate branch
- [x] TalenDelight Custom Roles plugin tested locally ✅
- [x] Custom roles visible in Users → Add New User dropdown ✅ 
- [x] Test users created (10 users: 5 custom roles + 4 default WP roles + wpadmin) ✅
- [x] 403 access control tested with subscriber_test user ✅ Shows forbidden page correctly
- [x] 403 Forbidden page created and tested ✅ /403-forbidden/ with proper styling
- [x] Role-based redirect tested with employer_test user ✅ Redirects to /employers/ (wpum_after_login hook)
- [x] Plural URLs implemented ✅ /employers/, /candidates/, /scouts/, /operators/, /managers/
- [x] Menu structure configured ✅ Welcome, Help, Profile, Log in/Log out
- [x] Login/Logout Menu plugin configured ✅ Conditional menu display
- [x] Performance optimizations applied ✅ OPcache, debug disabled
- [x] Employers page published ✅ Page is live at /employers/
- [ ] Employers page responsive design tested (mobile/tablet/desktop)
- [ ] Employers page SEO metadata added
- [ ] Export Employers page Elementor template
- [ ] Export Welcome page Elementor template (for documentation update)
- [ ] Database delta files created and tested locally (if applicable)
- [ ] Release notes reviewed and finalized
- [ ] Help page ready for production deployment
- [ ] Menu display location verified in local dev

---

## Deployment Steps

### Step 1: Git Push

```bash
git checkout main
git merge develop  # if using develop branch
git push origin main
```

**Result:** Hostinger automatically deploys `wp-content/` files

**⏱️ Wait 2-3 minutes for auto-deployment to complete**

---

### Step 2: Activate TalenDelight Custom Roles Plugin (WP-04.1)

**Goal:** Install and activate custom plugin that creates 5 roles (Employer, Candidate, Scout, Operator, Manager)

**Why Plugin:** Git-tracked, theme-independent, proper lifecycle management

**Implementation:**

1. Login to WordPress Admin: `https://talendelight.com/wp-admin/`
2. Navigate to: **Plugins → Installed Plugins**
3. Find: **TalenDelight Custom Roles** (should already be present via Git auto-deploy)
4. Click: **Activate**
5. Verify activation:
   - Navigate to: **Users → Add New User**
   - Check **Role** dropdown - should see 5 new roles:
     - Employer
     - Candidate
     - Scout
     - Operator
     - Manager

**What the plugin does:**
- Registers 5 custom WordPress roles with appropriate capabilities
- Implements 403 Forbidden access control for non-allowed roles
- Implements role-based login redirect via:
  - `login_redirect` filter (priority 100) for standard WordPress login
  - `wpum_login_redirect` filter (priority 100) for WP User Manager compatibility
  - `wpum_after_login` action hook (priority 10) - primary redirect mechanism for WPUM custom login form
- Implements template_redirect to catch /account/ page loads and redirect based on role
- Adds all custom capabilities to Administrator role

**If plugin is missing:**
- Check Git deployment completed successfully
- Verify `wp-content/plugins/talendelight-roles/` directory exists
- Re-run git push if needed

**Documentation:** See `wp-content/plugins/talendelight-roles/README.md` for complete role definitions and capabilities

**Time:** 2-3 minutes

---

### Step 3: Create 403 Forbidden Page

**Goal:** Create user-friendly access restriction page for users without allowed roles

**Implementation:**

1. Navigate to: **Pages → Add New Page**
2. Set title: **Access Restricted**
3. Set slug: **403-forbidden** (click Edit next to permalink)
4. Build page in Elementor:
   - **Section 1 - Hero:**
     - Container: Center aligned, padding 60px top/bottom
     - Icon widget: Warning icon, red color (#dc3545), size 120px
     - Heading: "Access Restricted" (H1, 48px, Navy #1a1a1a)
     - Text: "Your account does not have permission to access this platform."
     - Text: "This platform is exclusively for registered employers, candidates, and talent scouts."
   - **Section 2 - Buttons:**
     - Button 1: "Go to Home Page", Link: `/`, Primary Navy style (#0066cc), width: 220px
     - Button 2: "Log Out", Link: Dynamic Tags → WordPress → Logout URL, Grey style (#6c757d), width: 220px
   - **Section 3 - Help:**
     - Heading: "Need Help?" (H3, 20px)
     - Text: "If you believe you should have access, contact us:"
     - Text with link: "📧 support@talendelight.com"
5. Click **Publish**
6. Verify page loads at: `/403-forbidden/`

**Alternative (Simple HTML):**
- Switch to Code Editor mode and paste provided HTML from deployment notes

**Testing:**
- Login as subscriber/editor/author user (non-TalenDelight role)
- Should automatically redirect to /403-forbidden/ page
- Verify both buttons work (Home, Log Out)

**Time:** 10-15 minutes

---

### Step 4: Create Test Users with Custom Roles

**Goal:** Create test users for all custom roles to verify login redirect and access control

**Via WordPress Admin:**
1. Navigate to: **Users → Add New User**
2. Create users with following details:

| Username | Email | Role | Password |
|----------|-------|------|----------|
| employer_test | employer@test.local | Employer | Test123! |
| candidate_test | candidate@test.local | Candidate | Test123! |
| scout_test | scout@test.local | Scout | Test123! |
| operator_test | operator@test.local | Operator | Test123! |
| manager_test | manager@test.local | Manager | Test123! |
| subscriber_test | subscriber@test.local | Subscriber | Test123! |
| editor_test | editor@test.local | Editor | Test123! |
| author_test | author@test.local | Author | Test123! |
| contributor_test | contributor@test.local | Contributor | Test123! |

3. For each user:
   - Fill in Username
   - Fill in Email
   - Set Password (uncheck "Send user notification")
   - Select appropriate Role
   - Click **Add New User**

**Via WP-CLI (faster alternative, if SSH access available):**
```bash
# Create custom role users
wp user create employer_test employer@test.local --role=td_employer --user_pass=Test123!
wp user create candidate_test candidate@test.local --role=td_candidate --user_pass=Test123!
wp user create scout_test scout@test.local --role=td_scout --user_pass=Test123!
wp user create operator_test operator@test.local --role=td_operator --user_pass=Test123!
wp user create manager_test manager@test.local --role=td_manager --user_pass=Test123!

# Create WordPress default role users (for 403 testing)
wp user create subscriber_test subscriber@test.local --role=subscriber --user_pass=Test123!
wp user create editor_test editor@test.local --role=editor --user_pass=Test123!
wp user create author_test author@test.local --role=author --user_pass=Test123!
wp user create contributor_test contributor@test.local --role=contributor --user_pass=Test123!
```

**Verification:**
- Navigate to: **Users → All Users**
- Verify 9 test users created with correct roles
- Test login redirect:
  - Login as `employer_test` → should redirect to `/employers/`
  - Login as `subscriber_test` → should redirect to `/403-forbidden/`

**Time:** 10-15 minutes (WordPress Admin) or 5 minutes (WP-CLI)

---

### Step 5: Remove About Us Page

**Goal:** Clean up redundant About us page since home page already contains company information

**Via WordPress Admin:**
1. Navigate to: **Pages → All Pages**
2. Find: "About us" page
3. Move to Trash (or Delete Permanently if already in trash)

**Via WP-CLI (alternative, if SSH access available):**
```bash
# Find About us page ID
wp post list --post_type=page --name=about-us --fields=ID,post_title

# Delete page (force delete, bypass trash)
wp post delete <ID> --force
```

**Time:** 2-3 minutes

---

### Step 6: Configure Navigation Menu with Login/Logout Plugin

**Goal:** Set up dynamic menu that shows Log in/Log out based on authentication state

**Prerequisites:** Install and activate "Login/Logout Menu" plugin (if not already)

1. Navigate to: **Plugins → Add New**
2. Search: "Login/Logout Menu"
3. Install and activate plugin
4. Navigate to: **Appearance → Menus**
5. Select: "Header Menu" (or primary menu)
6. Configure menu items:
   - Welcome (link to /)
   - Help (link to /help/)
   - Profile (link to /account/ or use "WP User Manager - Account" page)
   - **Add Special Item:** Login/Logout Menu → Log in / Log out
     - This creates conditional menu item (shows "Log in" when logged out, "Log out" when logged in)
7. Set login link destination:
   - Plugin settings or menu item: Point to `/log-in/` (WP User Manager custom login page)
8. Remove "About us" menu item if present
9. Save menu
10. Assign to header location:
    - Find "Display location" section
    - Check appropriate Blocksy theme location
    - Save

**Menu Structure (Final):**
- Welcome
- Help
- Profile (visible when logged in)
- Log in (visible when logged out) → points to /log-in/
- Log out (visible when logged in) → logs out user

**Note:** "My" dropdown removed for simplicity. Profile kept at top level. About us page removed as redundant.

**Time:** 10-15 minutes

---

### Step 7: Configure Header Menu Display

**⚠️ Deferred from v2.0.0 - Menu exists but not visible**

1. Login to WordPress Admin: `https://talendelight.com/wp-admin/`
2. Navigate to: **Appearance → Menus**
3. Select: "Header Menu" (already created in v2.0.0)
4. Assign menu to display location:
   - Find "Display location" section
   - Check box for appropriate Blocksy theme location (investigate which one)
   - Save menu
5. Verify menu appears in website header

**Alternative (if location unclear):**
1. Go to **Appearance → Customize → Menus**
2. Use theme customizer to assign menu to header
3. Preview and publish

**Time:** 5-7 minutes

---

### Step 3: Deploy Help Page

**Method A: Create via Admin (Recommended)**
1. Navigate to: **Pages → Add New Page**
2. Title: "Help"
3. Build page content (copy from local dev or use Elementor template)
4. Publish
5. Note the page ID for menu configuration

**Method B: Import Elementor Template**
1. Export Help page template from local dev
2. Import template in production
3. Apply to new page titled "Help"
4. Publish

**Time:** 5-10 minutes

---

### Step 4: Deploy About Us Page to Production

**Note:** About us page exists in local dev but not in production

1. Export Elementor template from local: Pages → About us → Edit with Elementor → Export
2. Production: Navigate to Pages → Add New Page
3. Title: "About us"
4. Import Elementor template
5. Publish page

**Time:** 5 minutes

---

### Step 5: Configure WP User Manager Settings

**Deferred from v2.0.0 - Basic setup**

1. Navigate to: **WPUM → Settings**
2. **General Tab:**
   - Registration: Verify enabled
   - Email verification: Enable (if not already)
   - After login redirect: Configure role-based redirect URLs (see Step 6)
3. **Emails Tab:**
   - Customize email templates for professional appearance
   - Update sender name/email
4. **Redirects Tab:**
   - After login: Configure per-role redirects
   - After logout: Set to `/log-in/` (not wp-login.php)
5. Save all settings

**Time:** 10-15 minutes

---

### Step 7: Verify Role-Based Login Redirect

**Goal:** Confirm TalenDelight Custom Roles plugin is handling login redirects correctly

**What to check:**
- Plugin already implements role-based redirect logic
- No additional code needed (handled by plugin)
- Redirect behavior:
  - Administrator → `/wp-admin/`
  - Manager → `/managers/` (fallback: `/account/`)
  - Operator → `/operators/` (fallback: `/account/`)
  - Employer → `/employers/` (fallback: `/account/`)
  - Candidate → `/candidates/` (fallback: `/account/`)
  - Scout → `/scouts/` (fallback: `/account/`)
  - **Non-allowed roles (editor, author, subscriber, contributor)** → `/403-forbidden/`

**Testing:**
- Test with employer_test - should redirect to `/employers/` or `/account/`
- Test with candidate_test - should redirect to `/candidates/` or `/account/`

**Note:** 
- Requires Employers page (WP-01.2) to be built first
- Until role-specific pages exist, users fallback to `/account/`
- This is already implemented in the plugin, no manual configuration needed

**Time:** 2 minutes (verification only)

---

### Step 8: Create Remaining Test Users

**Deferred from v2.0.0 - Only 2 of 4 created**

Create via WordPress Admin:

1. Navigate to: **Users → Add New User**
2. Create `scout_test`:
   - Username: scout_test
   - Email: scout@test.local
   - Role: **Scout** (custom role)
   - Password: Test123!
3. Create `operator_test`:
   - Username: operator_test
   - Email: operator@test.local
   - Role: **Operator** (custom role)
   - Password: Test123!
4. Create `manager_test`:
   - Username: manager_test
   - Email: manager@test.local
   - Role: **Manager** (custom role)
   - Password: Test123!

**Time:** 5 minutes

---
### Verification Steps

1. **Visit production site:** `https://talendelight.com/`

2. **Verify custom roles plugin:**
   - Navigate to: **Plugins → Installed Plugins**
   - Verify "TalenDelight Custom Roles" is Active
   - Navigate to: **Users → Add New User**
   - Verify Role dropdown shows 5 new custom roles (Employer, Candidate, Scout, Operator, Manager)

3. **Test header navigation:**
   - Verify menu is visible in header
   - Menu should show: Welcome, About us, My account, Help, Login/Logout
   - Click each menu item - all should load correctly
   - When logged out: "Login" link visible
   - When logged in: "Logout" link visible

3. **Test Help page:**
   - Navigate to `/help/`
   - Page should load without errors
   - Content displays correctly

4. **Test About us page:**
   - Navigate to `/about-us/`
   - Page loads successfully
   - Content matches local dev version

5. **Test role-based login redirect:**
   - **Important:** Use the custom login page `/log-in/` (WP User Manager), not `/wp-login.php`
   - Test with employer_test: Login → Should redirect to `/employers/` (if page exists, else `/account/`)
   - Test with candidate_test: Login → Should redirect to `/candidates/` (if page exists, else `/account/`)
   - Test with scout_test: Login → Should redirect to `/scouts/` (if page exists, else `/account/`)
   - Test with operator_test: Login → Should redirect to `/operators/` (if page exists, else `/account/`)
   - Test with manager_test: Login → Should redirect to `/managers/` (if page exists, else `/account/`)
   - Test with administrator: Login → Should redirect to `/wp-admin/`
   - Verify each user lands on correct page based on custom role
   - **Note:** Redirect uses `wpum_after_login` hook - works with WP User Manager custom login form

6. **Test 403 Forbidden access control:**
   - Login as subscriber_test (default WordPress subscriber role)
   - Should automatically redirect to `/403-forbidden/` page
   - Verify page displays:
     - "Access Restricted" heading
     - Explanation text
     - "Go to Home Page" button (works)
     - "Log Out" button (works)
     - Support email contact
   - Test with editor_test, author_test - should also show 403 page
   - **Only allowed roles:** td_employer, td_candidate, td_scout, td_operator, td_manager, administrator
   - All other WordPress default roles (editor, author, contributor, subscriber) are now blocked

7. **Test "Get Started" button:**
   - As logged-out user: Click "Get Started" → Should redirect to login page
   - After login: User should be redirected to role-appropriate page (not generic /account/)

7. **Test Logout:**
   - Click "Logout" link → Should redirect to `/log-in/` (not wp-login.php)
   - Verify user is logged out

8. **Verify WP User Manager settings:**
   - WPUM → Settings: Confirm email verification enabled
   - Test registration flow (optional)

9. **Browser console:** Verify no JavaScript errors

10. **Mobile responsive:** Test header menu on mobile devices---

## Time Estimate

**Total deployment time:** ~50-70 minutes

| Step | Estimated Time |
|------|----------------|
| Git deployment | 5 min |
| Activate custom roles plugin | 2-3 min |
| Update test user roles | 3-5 min |
| Configure header menu display | 5-7 min |
| Deploy Help page | 5-10 min |
| Deploy About us page | 5 min |
| Verify role-based redirect | 2 min |
| Create remaining test users | 5 min |
| Configure WP User Manager | 10-15 min |
| Verification | 15-20 min |
| **Total** | **~57-77 min** |

---

## Deployment Metadata