# Release Notes & Deployment Instructions

**Status:** 🔄 Ready for Deployment

This document tracks all manual deployment steps required for the **next production release**.

**Purpose:** Ensure consistent, error-free deployments by documenting every manual step needed after Git push to main branch.

**Git Commit Summary:**
```
Add Candidates and Scouts landing pages (v3.1.0), complete role-based navigation for external roles, document consent/legal section design pattern
```

**📋 See Process:** [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) for workflow documentation

---

## Release Information

**Target Deployment Date:** TBD  
**Release Version:** 3.2.0  
**Branch:** develop → main  
**Status:** 🔄 In Progress - Operator Dashboard Phase 1 Complete

### Overview
- [x] **Operator landing page (/operators/) - ✅ Phase 1 Complete (January 13-14, 2026)**
  - ✅ Page created and published (ID: 299, slug: operators)
  - ✅ Hero: "Operators Dashboard" with introduction
  - ✅ Needs Action section (placeholder for dynamic content from external app)
  - ✅ 5 navigation tiles: Needs Action (info), Candidates, Employers, Scouts, Reports
  - ✅ CTA: "Need Help?" with documentation link
  - ✅ Footer section with compliance badges
  - ✅ Role-based access control implemented (Operators, Managers, Admins only)
  - ✅ Login redirect: Operator users auto-redirect to `/operators/`
  - ✅ 403 Forbidden page for unauthorized access
  - ✅ Test user verified: operator_test → `/operators/` redirect working
  - ✅ Plugin updated: talendelight-roles v1.0.0 with page-specific access control
  - 📄 Feature spec: [WP-01.4-operator-landing-page.md](features/WP-01.4-operator-landing-page.md)
  - 📄 Build guide: [OPERATOR-PAGE-BUILD-GUIDE.md](OPERATOR-PAGE-BUILD-GUIDE.md)
  - ⏳ Phase 2: Dynamic "Needs Action" content (external app integration)
  - ⏳ Phase 3: Management pages (Candidates, Employers, Scouts, Reports)
  
- [ ] **Manager landing page (/managers/) - ⏳ Planned for v3.2.0**
  - Access control already implemented in talendelight-roles plugin
  - Awaiting page content creation
  - 📄 Feature spec: [WP-01.5-manager-landing-page.md](features/WP-01.5-manager-landing-page.md)
  
- [x] **Previous v3.1.0 features - ✅ Deployed (January 9, 2026)**
  - Candidates landing page (WP-01.3) - ✅ Complete
  - Scouts landing page (WP-01.3 - Scouts) - ✅ Complete
  - Design pattern documentation - ✅ Complete
  - Compliance & trust signals - ✅ Complete

---

## Pre-Deployment Checklist

**Code & Content:**
- [x] Operators page published locally ✅ (Page ID: 299)
- [x] Access control implemented and tested ✅
- [x] Login redirect configured ✅
- [x] Feature documentation updated ✅
- [x] Build guide created ✅
- [ ] Responsive design tested on mobile/tablet/desktop
- [ ] Test operator user created in production
- [ ] Manager page content (deferred to later in v3.2.0)

**Version Control:**
- [ ] Git commit created with all changes
- [ ] Branch merged to main (if using develop branch)
- [ ] VERSION-HISTORY.md updated with deployment date

**Production Readiness:**
- [ ] Candidates page content reviewed and approved
- [ ] Scouts page content reviewed and approved
- [ ] Commission structure details confirmed (or deferred to private communication)
- [ ] GDPR consent language approved by legal/business
- [ ] Test users strategy decided (create in production or not)
- [ ] Backup of production database created

**Optional (Can Defer to v3.2.0):**
- [ ] Operator landing page created
- [ ] Manager landing page created
- [ ] Export Elementor templates for documentation
- [ ] Design consistency audit across all pages

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

**Note:** v3.0.0 already deployed all plugins and infrastructure. This release only adds new pages.

---

### Step 2: Verify Pages Deployed via Git

**Goal:** Confirm Candidates and Scouts pages are present in production

**Check:**
1. Login to WordPress Admin: `https://talendelight.com/wp-admin/`
2. Navigate to: **Pages → All Pages**
3. Verify pages exist:
   - **Candidates** (should be in Draft or published depending on export)
   - **Scouts** (should be in Draft or published depending on export)

**If pages are missing:**
- Pages may need manual recreation via Elementor (if Elementor templates not exported)
- Or import from local database export
- See "Alternative: Manual Page Creation" section below

**Time:** 2-3 minutes

---

### Step 3: Publish Candidates Page

**Goal:** Make Candidates landing page publicly accessible

**Implementation:**

1. Navigate to: **Pages → All Pages**
2. Find **"Candidates"** page
3. If status is Draft, click **"Edit"**
4. Change status from **"Draft"** to **"Publish"**
5. Verify slug is set to: **`candidates`**
6. Click **"Publish"** or **"Update"**
7. Verify page loads at: `https://talendelight.com/candidates/`

**Content verification:**
- Hero: "Launch Your Career with Confidence"
- 6 sections total
- Final CTA button links to `/candidates/identify/` (will 404 until form created)
- All content is candidate-focused (not employer-focused)

**Time:** 2-3 minutes

---

### Step 4: Publish Scouts Page

**Goal:** Make Scouts landing page publicly accessible

**Implementation:**

1. Navigate to: **Pages → All Pages**
2. Find **"Scouts"** page
3. If status is Draft, click **"Edit"**
4. Change status from **"Draft"** to **"Publish"**
5. Verify slug is set to: **`scouts`**
6. Click **"Publish"** or **"Update"**
7. Verify page loads at: `https://talendelight.com/scouts/`

**Content verification:**
- Hero: "Refer Top Tech Talent, Earn Rewards"
- 6 sections total including Consent & Ethics section
- Final CTA button links to `/scouts/introduce/candidates` (will 404 until form created)
- Consent language includes GDPR requirements

**Time:** 2-3 minutes

---

### Step 5: Test Role-Based Redirects

**Goal:** Verify users redirect to correct landing pages after login

**Test Cases:**

**Test 1: Employer Redirect** (Already tested in v3.0.0)
1. Logout from admin
2. Login as: `employer_test` / `Test123!`
3. **Expected:** Redirect to `/employers/`
4. **Result:** ✅ Should work (tested in v3.0.0)

**Test 2: Candidate Redirect** (New in v3.1.0)
1. Logout
2. Login as: `candidate_test` / `Test123!`
3. **Expected:** Redirect to `/candidates/`
4. **Result:** Should redirect to new Candidates page

**Test 3: Scout Redirect** (New in v3.1.0)
1. Logout
2. Login as: `scout_test` / `Test123!`
3. **Expected:** Redirect to `/scouts/`
4. **Result:** Should redirect to new Scouts page

**If redirect fails:**
- Check TalenDelight Custom Roles plugin is active
- Check page exists and slug is correct
- Review plugin code for redirect logic
- Check for conflicts with other plugins

**Time:** 5-10 minutes

---

### Step 6: Optional - Add SEO Metadata

**Goal:** Improve search engine visibility and social sharing

**For Candidates Page:**
1. Edit Candidates page
2. Scroll to SEO section (Yoast/RankMath if installed)
3. Set **Meta Title**: "Candidates - TalenDelight | Launch Your Tech Career in Baltics"
4. Set **Meta Description**: "Submit your CV and get matched with top tech companies in Latvia, Lithuania, Estonia. Technical screening by experts. Direct introductions to hiring managers."
5. Set **Focus Keyword**: "tech jobs baltics" or similar

**For Scouts Page:**
1. Edit Scouts page
2. Set **Meta Title**: "Scouts - TalenDelight | Refer Tech Talent, Earn Commission"
3. Set **Meta Description**: "Join our talent scout network. Refer skilled engineers to top companies in the Baltics and earn competitive commission for successful placements."
4. Set **Focus Keyword**: "tech talent referral" or similar

**Time:** 5-10 minutes (optional)

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

**Note:** `operator_test` user required for v3.2.0 to test Operators Dashboard

---

## v3.2.0 Specific Deployment Steps

### Step 7: Publish Operators Page

**Goal:** Make Operators Dashboard accessible to Operator users

**Implementation:**

1. Navigate to: **Pages → All Pages**
2. Find **"Operators Dashboard"** page
3. If status is Draft, click **"Edit"**
4. Change status from **"Draft"** to **"Publish"**
5. Verify slug is set to: **`operators`**
6. Verify template is: **Elementor Canvas** (full width)
7. Click **"Publish"** or **"Update"**
8. Verify page loads at: `https://talendelight.com/operators/`

**Content verification:**
- Hero: "Operators Dashboard"
- "Needs Action" section with placeholder text
- 5 navigation tiles: Needs Action, Candidates, Employers, Scouts, Reports
- CTA: "Need Help?"
- Footer with compliance badges

**Access control verification:**
- ✅ Operator users can access
- ✅ Manager users can access
- ✅ Administrator users can access
- ❌ Employer/Candidate/Scout users see 403 Forbidden
- ❌ Non-logged-in users redirected to login

**Time:** 3-5 minutes

---

### Step 8: Verify Access Control & Redirects

**Goal:** Confirm role-based access control and login redirects work correctly

**Test Operator Login Redirect:**
1. Logout from admin
2. Navigate to: `https://talendelight.com/wp-login.php`
3. Login as: `operator_test` / Test123!
4. ✅ Should auto-redirect to: `https://talendelight.com/operators/`
5. ✅ Should see Operators Dashboard page

**Test Unauthorized Access (403 Forbidden):**
1. Logout
2. Login as: `employer_test` / Test123! (or any non-operator role)
3. Manually navigate to: `https://talendelight.com/operators/`
4. ✅ Should see 403 Forbidden page with message:
   - "Access Denied"
   - "You do not have permission to access the Operators Dashboard"
   - Buttons: "Go to Home Page" and "Go to My Account"

**Test Unauthenticated Access:**
1. Logout completely (open incognito/private browser)
2. Navigate to: `https://talendelight.com/operators/`
3. ✅ Should redirect to login page

**Plugin verification:**
- Navigate to: **Plugins → Installed Plugins**
- Verify: **TalenDelight Custom Roles** plugin is **Active**
- Version: 1.0.0

**Time:** 5-10 minutes

---

### Step 9: Verify Plugin Code Deployment

**Goal:** Confirm talendelight-roles plugin updates deployed correctly

**Check via FTP/File Manager:**
1. Navigate to: `public_html/wp-content/plugins/talendelight-roles/`
2. Open: `talendelight-roles.php`
3. Search for function: `talendelight_restrict_operators_page`
4. ✅ Should exist (added in v3.2.0)
5. Search for function: `talendelight_restrict_managers_page`
6. ✅ Should exist (added in v3.2.0, future-ready)

**Check via WordPress Admin:**
1. Navigate to: **Plugins → Plugin Editor**
2. Select: **TalenDelight Custom Roles**
3. Verify file contains access control functions

**If functions missing:**
- Plugin file not deployed via Git
- Manually upload updated `talendelight-roles.php` via FTP
- Or re-deploy via Git (check .hostingerignore exclusions)

**Time:** 2-3 minutes

---

### Step 10: Optional - Test Manager Page Access Control (Future)

**Goal:** Verify Manager page access control is ready (when page is created)

**Current Status:** 
- ⏳ Manager page (`/managers/`) not yet created
- ✅ Access control code already in plugin (future-ready)

**When Manager page is created:**
1. Create page with slug: `managers`
2. Publish page
3. Login as `manager_test` user
4. ✅ Should auto-redirect to `/managers/`
5. ✅ Manager page should be accessible
6. Test unauthorized access (non-manager users should see 403)

**Time:** N/A (deferred to future release)

---

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
---
### Verification Steps

1. **Visit production site:** `https://talendelight.com/`

2. **Verify pages deployed:**
   - Navigate to: **Pages → All Pages**
   - Verify "Candidates" page exists (should be published or ready to publish)
   - Verify "Scouts" page exists (should be published or ready to publish)

3. **Test Candidates page:**
   - Navigate to `/candidates/`
   - Page should load without errors
   - Hero: "Launch Your Career with Confidence"
   - 6 sections display correctly
   - Final CTA button "Share Your Profile" links to `/candidates/identify/` (expect 404)
   - Responsive design works on mobile/tablet
   
4. **Test Scouts page:**
   - Navigate to `/scouts/`
   - Page should load without errors
   - Hero: "Refer Top Tech Talent, Earn Rewards"
   - 6 sections display correctly including Consent & Ethics section
   - Final CTA button "Start Your Referral Journey" links to `/scouts/introduce/candidates` (expect 404)
   - Responsive design works on mobile/tablet

5. **Test role-based login redirect:**
   - **Important:** Use the custom login page `/log-in/` (WP User Manager), not `/wp-login.php`
   - Test with employer_test: Login → Should redirect to `/employers/`
   - Test with candidate_test: Login → Should redirect to `/candidates/` ✅ NEW in v3.1.0
   - Test with scout_test: Login → Should redirect to `/scouts/` ✅ NEW in v3.1.0
   - Test with operator_test: Login → Should redirect to `/wp-admin/` (until Operator page created)
   - Test with manager_test: Login → Should redirect to `/wp-admin/` (until Manager page created)
   - Test with administrator: Login → Should redirect to `/wp-admin/`
   - Verify each user lands on correct page based on custom role

6. **Test 403 Forbidden access control:** (Already tested in v3.0.0)
   - Login as subscriber_test (default WordPress subscriber role)
   - Should automatically redirect to `/403-forbidden/` page
   - Verify "Go to Home Page" and "Log Out" buttons work

7. **Expected 404s (Not errors):**
   - `/candidates/identify/` - Form page not yet created (planned for v3.2.0)
   - `/scouts/introduce/candidates` - Form page not yet created (planned for v3.2.0)
   - Document these as known missing pages, not bugs

8. **Browser console:** Verify no JavaScript errors

9. **Mobile responsive:** Test both pages on mobile devices

---

## Time Estimate

**Total deployment time:** ~20-30 minutes

| Step | Estimated Time |
|------|----------------|
| Git deployment | 5 min |
| Publish Candidates page | 2-3 min |
| Publish Scouts page | 2-3 min |
| Test role-based redirects | 5-10 min |
| Optional SEO metadata | 5-10 min |
| Verification | 5-7 min |
| **Total** | **~24-38 min** |

**Note:** Significantly faster than v3.0.0 deployment (57-77 min) because:
- No plugin activation required
- No test users to create
- No 403 page to create
- Only publishing 2 new pages

---

## Deployment Metadata

- **Deployment Date:** [To be filled during deployment]
- **Git Branch:** `main`
- **Git Commit:** [SHA to be added]
- **Deployed By:** [Your name]
- **WordPress Version:** 6.9.0
- **PHP Version:** 8.3
- **Theme:** Blocksy v2.1.23
- **New Pages:** Candidates (ID TBD), Scouts (ID TBD)

---

## Post-Deployment

### Immediate Actions (First 24 hours)

1. **Monitor page traffic:**
   - Check analytics for `/candidates/` and `/scouts/` page views
   - Monitor bounce rate and time on page
   - Track CTA button clicks (expect 404s to `/candidates/identify/` and `/scouts/introduce/candidates`)

2. **Monitor error logs:**
   - Check for PHP errors: `/public_html/wp-content/debug.log` (if WP_DEBUG enabled)
   - Check server error logs in Hostinger control panel
   - Monitor for JavaScript console errors

3. **Test on multiple devices:**
   - Desktop (Windows, Mac, Linux)
   - Mobile (iOS Safari, Android Chrome)
   - Tablet (iPad, Android tablet)

4. **Collect user feedback:**
   - Test with real Candidate users if available
   - Test with real Scout users if available
   - Document any UX issues or confusion points

### Known Issues to Monitor

1. **Expected 404s:**
   - `/candidates/identify/` - Form page not yet created
   - `/scouts/introduce/candidates` - Form page not yet created
   - **Action:** Document as "coming soon" in internal tracker
   - **Timeline:** Plan for v3.2.0 release

2. **SEO metadata (if skipped):**
   - Pages may have generic meta titles/descriptions
   - **Action:** Add SEO metadata within 7 days post-deployment
   - Use Yoast/RankMath if installed

3. **Operator/Manager redirects:**
   - operator_test and manager_test users redirect to `/wp-admin/` (not role-specific pages)
   - **Status:** This is intentional until Operator/Manager pages are created
   - **Timeline:** Lower priority, may defer to v3.2.0 or v4.0.0

### Follow-Up Tasks (Within 7 days)

- [ ] Add SEO metadata to both pages (if not done during deployment)
- [ ] Submit new pages to Google Search Console for indexing
- [ ] Update sitemap.xml if using SEO plugin
- [ ] Test Scout role-based redirect if not tested during deployment
- [ ] Create tracking for form page traffic (to measure 404 impact)
- [ ] Plan v3.2.0 release with Candidate/Scout form pages

### Success Metrics

- [x] Zero PHP fatal errors
- [x] Pages load in < 3 seconds
- [x] Mobile responsive design works
- [x] Role-based redirects function correctly
- [ ] Positive user feedback on page content
- [ ] Analytics show engagement (time on page > 30 seconds)

---

## Communication

### Internal Team

**Deployment announcement:**
```
✅ v3.1.0 Deployed - Candidates & Scouts Landing Pages

New pages live:
- /candidates/ - Candidate landing page
- /scouts/ - Scout referral landing page

Features:
- Role-based redirect now works for Candidates and Scouts
- Consent & ethics section added to Scout page
- Both pages optimized for mobile

Known limitations:
- Form pages (/candidates/identify/ and /scouts/introduce/candidates) return 404 (coming in v3.2.0)

Next: Build submission forms for both roles
```

### External Users (if applicable)

**Marketing announcement (optional):**
```
🎉 New: Join TalenDelight as Candidate or Scout

We've launched dedicated pages for:
- Job seekers looking for tech roles in the Baltics
- Talent scouts who want to refer candidates and earn commission

Visit:
- Candidates: https://talendelight.com/candidates/
- Scouts: https://talendelight.com/scouts/

Application forms coming soon!
```

---

## Rollback Executed (If Needed)

**Document if rollback was necessary:**

- **Rollback Date:** [Date]
- **Reason:** [Description of issue]
- **Method Used:** [Git revert / Manual unpublish]
- **Result:** [Success / Partial / Failed]
- **Lessons Learned:** [What to do differently next time]

---

## Notes

- All v3.0.0 infrastructure (custom roles plugin, 403 page, test users) remains active and unchanged
- This release is purely additive (new pages only)
- No database schema changes required
- No plugin updates required
- Git deployment strategy continues to work well
- Template duplication approach (Candidates → Scouts) saved 50% development time

**Next Release Planning:**
- v3.2.0: Candidate identification form + Scout submission form (High Priority)
- v3.2.0 or v3.3.0: Operator/Manager landing pages (Low Priority)
- Future: Design system audit and standardization