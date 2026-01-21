# Release Notes & Deployment Instructions

**Status:** 📋 Planning  
**Version:** v3.4.0  
**Target Date:** TBD

This document tracks all manual deployment steps required for the **next production release**.

**Purpose:** Ensure consistent, error-free deployments by documenting every manual step needed after Git push to main branch.

**📋 See Process:** [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) for workflow documentation

---

## Planned Features

### v3.4.0 Features

**1. Manager Dashboard Page (Missing from v3.3.0 - HIGH PRIORITY)**
- **Issue:** Manager Dashboard page exists locally (ID 333) but was never deployed to production
- **Status:** Built locally on January 14, 2026, but missing from production
- **Feature Spec:** [WP-01.5-manager-landing-page.md](features/WP-01.5-manager-landing-page.md)
- **What to Deploy:**
  - Elementor page: `/managers/` (slug: `managers`)
  - 7 navigation tiles: Manage Operators, Manage Scouts, Manage Candidates, Manage Employers, Finance, Admin, Reports
  - Team Performance Overview section (placeholder)
  - Hero, CTA, and Footer sections
  - Access control already in plugin (Manager and Admin roles only)

**2. Manager Admin Operations Page (NEW)**
- **URL:** `/manager-admin/`
- **Page Title:** Manager Admin
- **Hero Heading:** Admin Operations
- **Navigation:** Managers Dashboard → Admin tile
- **Feature Spec:** [WP-01.6-user-request-approvals.md](features/WP-01.6-user-request-approvals.md)
- **Implementation Guide:** [MANAGER-ADMIN-TABS-IMPLEMENTATION.md](MANAGER-ADMIN-TABS-IMPLEMENTATION.md)
- **Purpose:** Centralized hub for system administration tasks including user request approvals, user management, system settings, and other admin operations
- **What to Deploy:**
  - Elementor page with tabbed interface (4 tabs: Submitted, Approved, Rejected, All)
  - User Request Approvals table with real-time database integration
  - Action buttons: Approve (✓), Reject (✗), Undo Rejection (↶)
  - Role-based display (Candidate, Employer, Scout, Operator, Manager)
  - Profile method support (LinkedIn + CV combined)
  - Generic audit logging system for compliance tracking
  - Database migrations:
    - `260117-impl-add-td_user_data_change_requests.sql` - User requests table
    - `260119-1400-add-role-and-audit-log.sql` - Role column, profile method updates, audit log table
  - New mu-plugins:
    - `user-requests-display.php` - Tabbed interface with AJAX actions
    - `audit-logger.php` - Generic audit logging helper
    - `forminator-custom-table.php` - Syncs Forminator form submissions to td_user_data_change_requests table
  - Forminator integration:
    - Hook: `forminator_form_after_save_entry` 
    - Form ID: 364 (Person Registration Form)
    - Uses Forminator_API::get_entry() for reliable data extraction
    - Auto-inserts submissions into td_user_data_change_requests with status='new'
  - Database migrations (added January 20):
    - `260120-1945-alter-add-approver-comments.sql` - Added approver_id and comments columns
  - Access control: Manager and Administrator only
- **Key Features:**
  - **Tabbed Interface:** 4 tabs (Submitted/Pending, Approved, Rejected, All) with counts
  - **Real-time Actions:** Approve/Reject pending requests, Undo rejected requests
  - **Audit Logging:** All status changes logged to `td_audit_log` table with user, timestamp, IP, and notes
  - **Role Display:** Shows role badge for each request (Candidate, Employer, Scout, etc.)
  - **Profile Methods:** Displays both LinkedIn and CV if provided (e.g., "🔗 LinkedIn + 📄 CV")
  - **Summary Metrics:** Total requests, request type distribution, reviewed today count
  - **Automatic Updates:** Rows removed from view after action without page refresh

### New Features for v3.4.0

**3. UI/UX Consistency Updates**

**Button Standardization:**
- **File:** `config/custom-css/elementor-button.css`
- **Updates:**
  - Global button sizing: 180px min-width (reduced from 240px), 14px/22px padding, 50px border-radius
  - Button variants: `btn-blue` (#3498DB with blue shadow), `btn-grey` (#ECECEC with subtle shadow)
  - WP User Manager login button: Blue button with matching styles
  - Select Role page buttons: Next (blue), Back (grey), heading (navy #063970)
  - Action button exceptions: Manager Admin approve/reject/undo buttons maintain 28x28px size
- **Deployment:** Manually copy entire file to WordPress Customizer → Additional CSS

**Forminator Form Styling:**
- **File:** `config/custom-css/td-page.css` (NEW)
- **Purpose:** Match Person Registration Form (Forminator ID 364) to WP User Manager login page aesthetic
- **Styles:**
  - Form container: 900px max-width, white background, 8px border-radius, subtle shadow
  - Form title: Navy (#063970), 32px, bold, centered
  - Field labels: Navy (#063970), 14px, bold
  - Input fields: Consistent padding (12px 16px), border (#E0E0E0), focus state with navy outline
  - Submit button: Blue (#3498DB), rounded (50px), shadow effect, centered, auto width
  - Required indicators: Red (#dc3545)
  - Success/error messages: Color-coded borders and backgrounds
  - Responsive design: Mobile breakpoints for smaller screens
- **Deployment:** Manually copy entire file to WordPress Customizer → Additional CSS

**Manager Admin Table Typography:**
- **File:** `wp-content/mu-plugins/user-requests-display.php`
- **Change:** Added `font-size: 13px` to Name column cell (line 287) to match other table cells
- **Deployment:** Automatically deployed via Git push (file already in wp-content/)

**Post-Registration Redirect:**
- **File:** `wp-content/themes/blocksy-child/functions.php`
- **Change:** Added Forminator form redirect filter to redirect users to Welcome page after Person Registration Form submission
- **Hook:** `forminator_custom_form_submit_response` filter for form ID 364
- **Deployment:** Automatically deployed via Git push (file already in wp-content/)

**4. Navigation Menu Conditional Display (January 20, 2026)**

**Conditional Login/Logout Display:**
- **File:** `wp-content/themes/blocksy-child/functions.php`
- **Change:** Added `wp_nav_menu_items` filter to conditionally display Login/Logout menu items
- **Logic:** 
  - Hide "Log In" menu item (ID 149) when user is logged in
  - Hide "Log Out" menu item (ID 150) when user is logged out
- **Implementation:** Uses `preg_replace` to remove entire `<li>` elements based on menu item class
- **Deployment:** Automatically deployed via Git push (file already in wp-content/)

**5. Forminator Form Integration (January 20, 2026)**

**User Registration Data Flow:**
- **Plugin:** `wp-content/plugins/td-user-data-change-requests.php`
- **Purpose:** Copy Forminator Person Registration Form (ID 364) submissions to custom approval table
- **Hook:** `forminator_custom_form_after_handle_submit`
- **Field Mapping:**
  - name-1/2/3 → first_name/middle_name/last_name
  - email-1 → email, phone-1 → phone
  - checkbox-1 → profile_method (linkedin/cv)
  - upload-1/2/3 → file paths (CV, citizenship ID, residence ID)
  - radio-1 → ids_are_same flag
  - consent-1 → consent
- **Table:** `td_user_data_change_requests` (no wp_ prefix)
- **Role:** Hardcoded to 'candidate' for form 364
- **Deployment:** Automatically deployed via Git push

**Cleanup Script:**
- **File:** `infra/shared/scripts/cleanup-forminator-entries.php`
- **Purpose:** Delete redundant Forminator entries (optional)
- **Usage:** WP-CLI only, dry-run by default
- **Deployment:** Local dev tool only

**6. Elementor Template Backups (January 20, 2026)**
- **Location:** `tmp/elementor-templates/`
- **Templates:** 5 main pages backed up after Manager page corruption incident
- **Documentation:** Full restoration guide in README.md
- **Deployment:** Local-only, NOT deployed to production

*Document additional features here as development progresses.*

---

## Deployment Checklist

### Pre-Deployment
- [ ] All code changes committed to `develop` branch
- [ ] Local testing completed
- [ ] Database migrations tested locally
- [ ] `.github/releases/v3.4.0.json` created with deployment steps
- [ ] If Elementor pages: Run `pwsh infra/shared/scripts/export-elementor-pages.ps1`
- [ ] If new plugins: Add to `deploy_plugins` step in release JSON

### Git Workflow
```bash
# Merge develop to main to trigger deployment
git checkout main
git merge develop
git push origin main

# Switch back to develop branch for continued work
git checkout develop
```

### Post-Deployment (Automated via GitHub Actions)
- [ ] Code deployed to ~/public_html/wp-content/ (auto)
- [ ] Database migrations executed (auto if configured)
- [ ] Themes activated (auto if configured)
- [ ] Plugins activated (auto if configured)
- [ ] Caches cleared (auto)

### Manual Steps (If Required)

**1. CSS Workflow & Synchronization (CRITICAL):**

**⚠️ CSS Management Strategy:**

WordPress with Elementor requires CSS to be in **WordPress Customizer → Additional CSS** to work correctly. File-based CSS in the repository serves only as version control reference.

**CSS Files to Sync:**
- `config/custom-css/elementor-button.css` - Global button standards, login button, Select Role buttons
- `config/custom-css/td-page.css` - Forminator form styling, Select Role heading
- `config/custom-css/login.css` - WPUM login page styling (no changes this release)

**Manual Sync Process (MUST be done on production):**

**Step 1: Copy elementor-button.css**
```bash
# On local machine, copy content
cat config/custom-css/elementor-button.css
```
- Navigate to WordPress Admin → Appearance → Customize → Additional CSS
- Find section: `/* Global Button Standards (elementor-button.css) */`
- Replace entire section with copied content
- Verify includes: `.btn-blue`, `.btn-grey`, `.wpum-form input[type="submit"]`, `#td-role-next`, `#td-role-back`

**Step 2: Copy td-page.css**
```bash
# On local machine, copy content
cat config/custom-css/td-page.css
```
- In same Customizer Additional CSS area
- Find section: `/* Forminator & Page-Specific Styles (td-page.css) */` (or add new section if first time)
- Replace entire section with copied content
- Verify includes: `.forminator-custom-form`, `.forminator-button-submit`, `.td-role-selection-container h2`

**Step 3: Publish Changes**
- Click "Publish" button in WordPress Customizer
- Verify changes saved successfully

**Testing After CSS Sync:**
- [ ] Login page button displays blue (#3498DB) with shadow at /log-in/
- [ ] Select Role page at /select-role/: Next button blue, Back button grey, heading navy
- [ ] Person Registration Form at /register-profile/ displays properly:
  - [ ] Form container 900px max-width, centered
  - [ ] Labels navy (#063970), 14px, bold
  - [ ] Input fields consistent padding and borders
  - [ ] Submit button auto width, centered, blue styling
  - [ ] Required indicators red (#dc3545)
- [ ] Manager Admin table at /manager-admin/: Name column font 13px (matches other cells)

**2. Deploy Manager Dashboard Page (v3.3.0 Backlog):**

```powershell
# Step 1: Export Manager Dashboard from local
cd c:\data\lochness\talendelight\code\wordpress
pwsh infra/shared/scripts/export-elementor-pages.ps1
# Output: tmp/elementor-exports/managers.json

# Step 2: Upload to production
scp -i tmp/hostinger_deploy_key -P 65002 tmp/elementor-exports/managers.json u909075950@45.84.205.129:~/

# Step 3: Import via SSH
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
cd ~/domains/talendelight.com/public_html

# Create page
wp post create --post_type=page --post_status=publish --post_title="Managers" --post_name=managers --page_template="elementor_canvas"

# Get page ID
MANAGER_PAGE_ID=$(wp post list --post_type=page --name=managers --field=ID)
echo "Manager Page ID: $MANAGER_PAGE_ID"

# Import Elementor data (manual JSON import via Elementor UI or wp-cli)
# ... import steps here

# Step 4: Set Page Layout
# - Login to WordPress Admin
# - Edit Managers page
# - Sidebar → Blocksy → Page Layout: Set to "Default"
# - Update page

# Step 5: Test Access
# - Login as manager_test user
# - Should redirect to /managers/
# - Verify all 7 tiles visible
# - Test unauthorized access (should show 403)
```

**2. Deploy Manager Admin Page with Tabbed Interface:**

```powershell
# Local: Export page
pwsh infra/shared/scripts/export-elementor-pages.ps1
# Output: tmp/elementor-exports/manager-admin.json

# Upload to production
scp -i tmp/hostinger_deploy_key -P 65002 tmp/elementor-exports/manager-admin.json u909075950@45.84.205.129:~/

# SSH to production
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
cd ~/domains/talendelight.com/public_html

# Create page
wp post create --post_type=page --post_status=publish --post_title="Manager Admin" --post_name=manager-admin --page_template="elementor_canvas"

# Get page ID
ADMIN_PAGE_ID=$(wp post list --post_type=page --name=manager-admin --field=ID)
echo "Manager Admin Page ID: $ADMIN_PAGE_ID"

# Import Elementor data (follow standard import process)
# Set Blocksy layout to "Default"

# Test tabbed interface and action buttons
```

**3. Apply Database Migrations:**

```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
cd ~/domains/talendelight.com/public_html

# Upload both SQL migrations
# From local:
scp -i tmp/hostinger_deploy_key -P 65002 infra/shared/db/260117-impl-add-td_user_data_change_requests.sql u909075950@45.84.205.129:~/
scp -i tmp/hostinger_deploy_key -P 65002 infra/shared/db/260119-1400-add-role-and-audit-log.sql u909075950@45.84.205.129:~/

# Apply migrations in order
wp db query < ~/260117-impl-add-td_user_data_change_requests.sql
wp db query < ~/260119-1400-add-role-and-audit-log.sql

# Verify tables created
wp db query "SHOW TABLES LIKE 'td_user_data_change_requests';"
wp db query "SHOW TABLES LIKE 'td_audit_log';"
wp db query "DESCRIBE td_user_data_change_requests;" # Check role, has_linkedin, has_cv columns
wp db query "DESCRIBE td_audit_log;"

# ✅ Local migrations applied January 20, 2026
# - td_user_data_change_requests created
# - td_audit_log created
# - Ready for production
```

**4. Deploy plugins:**

```bash
# Verify mu-plugins:
cd ~/domains/talendelight.com/public_html
ls -la wp-content/mu-plugins/ | grep -E "(user-requests-display|audit-logger)"

# Verify and activate regular plugin:
wp plugin list | grep td-user-data-change-requests
wp plugin activate td-user-data-change-requests

# ✅ Local status January 20, 2026:
# - td-user-data-change-requests.php active and working
# - user-requests-display.php deployed
# - audit-logger.php deployed
```

**5. Test User Request Approvals Functionality:**

```bash
# Test shortcode rendering
wp eval "echo do_shortcode('[user_requests_table status=\"pending\"]');" | head -50

# Test AJAX endpoints availability
wp eval "echo has_action('wp_ajax_td_approve_request') ? 'OK' : 'MISSING';"
wp eval "echo has_action('wp_ajax_td_reject_request') ? 'OK' : 'MISSING';"
wp eval "echo has_action('wp_ajax_td_undo_reject') ? 'OK' : 'MISSING';"

# Insert test data (optional)
wp db query "INSERT INTO td_user_data_change_requests (user_id, role, request_type, prefix, first_name, last_name, email, phone, profile_method, has_linkedin, has_cv, citizenship_id_file, status) VALUES (1, 'candidate', 'register', 'Mr', 'Test', 'User', 'test@example.com', '+1-555-000-0000', 'linkedin', 1, 1, '/test.pdf', 'pending');"

# Test via browser
# - Login as manager
# - Go to /manager-admin/
# - Verify tabs work (Submitted, Approved, Rejected, All)
# - Test approve/reject actions
# - Check rejected tab for undo button
# - Verify audit log entries
wp db query "SELECT * FROM td_audit_log ORDER BY changed_at DESC LIMIT 5;"
```

**See Also:** [ID-MANAGEMENT-STRATEGY.md](ID-MANAGEMENT-STRATEGY.md) for cross-environment deployment patterns

---

## Git Commit Template

```
[Brief description of main feature/change] (vX.X.X)

- Feature 1
- Feature 2
- Bug fix
```

---

## Testing Verification

### Functional Tests
- [ ] Manager Dashboard: Login button displays blue styling with shadow
- [ ] Login page (/log-in/): Submit button has blue color (#3498DB) and shadow effect
- [ ] Select Role page (/select-role/):
  - [ ] "Select Your Role" heading is navy (#063970)
  - [ ] Next button is blue with shadow
  - [ ] Back button is grey with subtle shadow
- [ ] Person Registration Form (/register-profile/):
  - [ ] Form container displays at 900px max-width, centered
  - [ ] Form title is navy (#063970), 32px, bold, centered
  - [ ] Field labels are navy, 14px, bold
  - [ ] Input fields have consistent padding and borders
  - [ ] Submit button is blue, centered, auto width (not 100% wide)
  - [ ] Required indicators display in red
  - [ ] After successful submission, redirects to /welcome/
- [ ] Manager Admin page (/manager-admin/):
  - [ ] Name column font size matches other table cells (13px)
  - [ ] Tab switching works (Submitted, Approved, Rejected, All)
  - [ ] Approve/Reject actions work
  - [ ] Undo button appears in Rejected tab
  - [ ] Audit log records status changes
- [ ] Redirect flow:
  - [ ] After logout: redirects to /welcome/
  - [ ] From /register: redirects to /select-role/
  - [ ] After form submission: redirects to /welcome/

### Performance Tests
- [ ] Page load times acceptable
- [ ] No console errors
- [ ] Mobile responsive

---

## Post-Deployment Cleanup

After successful deployment and verification, clean up temporary files from `tmp/` folder:

### Delete Exported Data
```powershell
# Delete Elementor exports
Remove-Item tmp/elementor-exports/*.json -ErrorAction SilentlyContinue

# Delete stale exports (JSON, HTML, CSS)
cd c:\data\lochness\talendelight\code\wordpress
Remove-Item tmp/*-from-container.json, tmp/*-elementor.json, tmp/local-*.json, tmp/prod-*.json, tmp/local-*.html, tmp/operator-*.html, tmp/manager-*.html, tmp/*.css, tmp/*-raw.txt, tmp/*-formatted.json -ErrorAction SilentlyContinue
```

### Delete One-Time Fixes
```powershell
# Delete one-time fix scripts (already applied)
Remove-Item tmp/fix-*.php, tmp/update-*.php, tmp/check-*.php, tmp/test-*.php -ErrorAction SilentlyContinue
```

### Delete Temporary Deployment Files
```powershell
# Delete deployment comparison and temporary scripts
Remove-Item tmp/deployment-comparison-report.md, tmp/deploy-*.php, tmp/create-*.php, tmp/enable-*.php, tmp/force-*.php, tmp/import-*.php -ErrorAction SilentlyContinue
```

### Keep Essential Files
**DO NOT DELETE** these reusable scripts and keys:
- `hostinger_deploy_key` / `hostinger_deploy_key.pub` - SSH deployment keys
- `verify-deployment.php` - Production verification script
- `add-env-config-loader.php` - Config loader script
- `env-config-production.php` - Production environment config template
- `test-env.php` - Environment detection test script
- `force-deploy-elementor.php` - Elementor deployment script
- `regenerate-elementor-css.php` - CSS regeneration script
- `backfill-forminator-submissions.php` - Data migration script
- `sample-user-requests.sql` - Test data script

### Cleanup Checklist
- [ ] Delete exported Elementor JSON files
- [ ] Delete stale exports (JSON, HTML, CSS)
- [ ] Delete one-time fix scripts
- [ ] Delete temporary deployment files
- [ ] Verify essential scripts preserved
- [ ] Commit cleanup to develop branch

---

## Rollback Plan

If deployment fails:
1. Check GitHub Actions logs for specific error
2. SSH to production: `ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129`
3. Investigate error: `cd domains/talendelight.com/public_html && wp plugin list`
4. If critical: Revert main branch to previous release tag
5. Document issue in docs/lessons/

---

## Notes

*Add any additional context, warnings, or considerations here.*

---

## Release Information

**Target Deployment Date:** TBD  
**Release Version:** 3.3.0  
**Branch:** develop → main  
**Status:** 🔄 Planning

### Overview

**v3.2.0 Deployment Complete:** ✅ January 14, 2026 at 01:00 AM
- Operators Dashboard (Phase 1) successfully deployed to production
- Role-based access control active
- See [VERSION-HISTORY.md](VERSION-HISTORY.md) for complete v3.2.0 details

**Next Release (v3.3.0) - Options:**
- [ ] **Option A: Manager Dashboard** - Create `/managers/` landing page
  - Similar structure to Operators Dashboard
  - Access control already implemented in plugin
  - Target for executive/management role
  - Feature spec: [WP-01.5-manager-landing-page.md](features/WP-01.5-manager-landing-page.md)

- [ ] **Option B: Operators Phase 2** - Dynamic "Needs Action" content
  - External app/API integration
  - Working dropdown filter (Today/7 days/All)
  - Real-time data display
  - Requires API contract design

- [ ] **Option C: Management Pages** - Operators sub-pages
  - Create `/operators/candidates/` page (search, filter, table)
  - Create `/operators/employers/` page
  - Create `/operators/scouts/` page
  - Create `/operators/reports/` page

**Decision Pending:** Select Option A, B, or C based on business priority

---

## Issues from v3.2.0 (Resolved)

### ✅ Operators Page Title/Menu Issue (RESOLVED)

**Problem:** Operators Dashboard missing page title and top menu in production

**Root Cause:** Blocksy theme's "Page Layout" setting was not set to "Default"

**Resolution:** Changed Page Layout to "Default" (January 14, 2026)
- ✅ Page title now visible
- ✅ Top navigation menu now visible
- ✅ Page integrated with site navigation

**Standard for All Pages:**
- **Blocksy Page Layout:** Set to "Default"
- **Elementor Template:** Can use "Elementor Full Width" or "Elementor Canvas" as needed
- **Applies to:** All role landing pages (Employers, Candidates, Scouts, Operators, Managers)

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

## Candidate Submission Form (Forminator) - Implementation Steps

### Step 1: Install and Activate Forminator
- Installed Forminator plugin v1.49.2 via WP CLI
- Verified plugin is active in WordPress admin

### Step 2: Update Documentation
- Updated WP-02.1 feature spec to use Forminator syntax and features
- Documented field IDs, notification templates, and CandidateID logic for Forminator

### Step 3: Create Candidate Submission Form in Forminator
- Created new form: "Candidate Submission Form"
- Added fields: First Name (required), Middle Name (optional), Last Name (required), Email, Phone, LinkedIn Profile (optional), CV Upload (optional), Location, Current Role, Years of Experience, Primary Skills, Privacy Consent (required)
- Configured file upload: PDF/DOC/DOCX only, 10MB max
- Set up notifications: Candidate confirmation and internal team alert
- Enabled anti-spam (reCAPTCHA/hCaptcha, honeypot)
- Published form and copied shortcode

### Step 4: Configure Conditional Validation (LinkedIn OR CV Required)
- Planned custom validation: Either LinkedIn or CV must be provided, cannot submit without one
- Will implement via Forminator's custom validation hook or JavaScript (see WP-02.1 spec)

### Step 5: Next Steps
- Create /candidates/identify/ page and embed form shortcode
- Add CandidateID generation code to talendelight-roles plugin
- Test form submission, notifications, and file upload

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
   - Password: Test123!

**Via WP-CLI (faster alternative, if SSH access available):**
```bash
# Create remaining test users
wp user create scout_test scout@test.local --role=td_scout --user_pass=Test123!
wp user create operator_test operator@test.local --role=td_operator --user_pass=Test123!
wp user create manager_test manager@test.local --role=td_manager --user_pass=Test123!
```

**Time:** 5 minutes

---

## Verification Steps

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

---

## Database & Backend Changes (v3.3.0)

### 1. New Table: td_user_data_change_requests
- Added SQL schema for td_user_data_change_requests to support user registration, profile changes, and approval workflow for all roles.
- See: infra/shared/db/260117-impl-add-td_user_data_change_requests.sql
- Columns: id, user_id, request_type (register, update, disable), name fields, email, phone, profile method, LinkedIn/CV, citizenship/residence ID, consent, captcha, status, assigned_to, timestamps.

### 2. Automation Scripts for SQL Changes
- PowerShell script for local dev: infra/shared/scripts/apply-sql-change.ps1
- Bash script for CI/CD/production: infra/shared/scripts/apply-sql-change.sh
- Scripts apply SQL files to MariaDB/MySQL using release instructions.
- Open action: Integrate bash script into CI/CD pipeline for automated production database changes.

### 3. Backend Workflow Updates
- Registration and profile changes now use td_user_data_change_requests for all user roles.
- Manager approval, ID verification, and audit trail logic implemented.
- OTP verification required for email/phone changes.
- All changes logged for compliance and audit.

---