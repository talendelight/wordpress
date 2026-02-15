# Functional Test Cases

**Project:** TalenDelight WordPress MVP  
**Version:** v3.6.2  
**Last Updated:** February 14, 2026  
**Test Environment:** https://wp.local (local), https://talendelight.com (production)

## Test Suite Overview

| Test Suite ID | Test Suite Name | Test Case Count | Priority |
|---------------|-----------------|-----------------|----------|
| TS-001 | Registration Flow | 8 | Critical |
| TS-002 | Manager Pages | 12 | High |
| TS-003 | Simple Content Pages | 6 | Medium |
| TS-004 | Form Functionality | 10 | High |
| TS-005 | Navigation & Redirects | 6 | High |
| TS-006 | Authentication | 8 | Critical |
| **TOTAL** | | **50** | |

---

## TS-001: Registration Flow

### TC-001-001: Select Role Page Load
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Verify Select Role page loads correctly with all role cards visible  
**Description:** This test validates that the Select Role page, which is the entry point for user registration, loads successfully and displays all four role options (Candidate, Employer, Scout, Operator) with proper styling and responsive design.

**Steps:**
1. Navigate to `/select-role/`
2. Wait for page to fully load

**Acceptance Criteria:**
- ✅ Page loads without errors (status 200)
- ✅ Page title is "Select Your Role"
- ✅ 4 role cards are visible: Candidate, Employer, Scout, Operator
- ✅ Each card has icon, title, description, and "Get Started" button
- ✅ All buttons have navy background (#1A365D)
- ✅ Page is responsive (mobile, tablet, desktop)

**Automation Notes:**
- Selector: `.wp-block-group .is-style-card` (4 cards expected)
- Button selector: `.wp-block-button__link` (navy background)

---

### TC-001-002: Select Role - Candidate Registration Flow
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Candidate role selection and redirect to registration with role parameter  
**Description:** Validates the complete flow from selecting the Candidate role card to being redirected to the Register Profile page with the correct role parameter captured in the URL and hidden form field.

**Steps:**
1. Navigate to `/select-role/`
2. Click "Get Started" button under **Candidate** card
3. Verify redirect to Register Profile page
4. Check URL contains parameter

**Acceptance Criteria:**
- ✅ Redirects to `/register-profile/?role=candidate`
- ✅ Register Profile page loads successfully
- ✅ Forminator form displays (form ID 80)
- ✅ Role parameter is captured in hidden field

**Automation Notes:**
- Button selector: First `.wp-block-button__link` in Candidate card
- URL check: `page.url().includes('/register-profile/?role=candidate')`
- Form check: `page.locator('form.forminator-ui-form').isVisible()`

---

### TC-001-003: Select Role - Employer Registration Flow
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Employer role selection and redirect to registration with role parameter  
**Description:** Validates the complete flow from selecting the Employer role card to being redirected to the Register Profile page with the correct role parameter captured in the URL and hidden form field.

**Steps:**
1. Navigate to `/select-role/`
2. Click "Get Started" button under **Employer** card
3. Verify redirect to Register Profile page
4. Check URL contains parameter

**Acceptance Criteria:**
- ✅ Redirects to `/register-profile/?role=employer`
- ✅ Register Profile page loads successfully
- ✅ Forminator form displays
- ✅ Role parameter is captured in hidden field

**Automation Notes:**
- Button selector: Second `.wp-block-button__link` in Employer card
- URL assertion: `expect(page).toHaveURL(/\/register-profile\/\?role=employer/)`

---

### TC-001-004: Select Role - Scout Registration Flow
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Scout role selection and redirect to registration with role parameter  
**Description:** Validates the complete flow from selecting the Scout role card to being redirected to the Register Profile page with the correct role parameter captured in the URL and hidden form field.

**Steps:**
1. Navigate to `/select-role/`
2. Click "Get Started" button under **Scout** card
3. Verify redirect to Register Profile page
4. Check URL contains parameter

**Acceptance Criteria:**
- ✅ Redirects to `/register-profile/?role=scout`
- ✅ Register Profile page loads successfully
- ✅ Forminator form displays
- ✅ Role parameter is captured in hidden field

**Automation Notes:**
- Button selector: Third `.wp-block-button__link` in Scout card

---

### TC-001-005: Select Role - Operator Registration Flow
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Operator role selection and redirect to registration with role parameter  
**Description:** Validates the complete flow from selecting the Operator role card to being redirected to the Register Profile page with the correct role parameter captured in the URL and hidden form field.

**Steps:**
1. Navigate to `/select-role/`
2. Click "Get Started" button under **Operator** card
3. Verify redirect to Register Profile page
4. Check URL contains parameter

**Acceptance Criteria:**
- ✅ Redirects to `/register-profile/?role=operator`
- ✅ Register Profile page loads successfully
- ✅ Forminator form displays
- ✅ Role parameter is captured in hidden field

**Automation Notes:**
- Button selector: Fourth `.wp-block-button__link` in Operator card

---

### TC-001-006: Register Profile - Form Display
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** Navigate to `/register-profile/?role=candidate`  
**Summary:** Verify Register Profile form displays correctly with all required fields  
**Description:** Tests that the Forminator registration form loads properly with all required fields (email, username, password) and that the hidden role field is populated correctly from the URL parameter.

**Steps:**
1. Verify page loads
2. Check form elements are visible
3. Verify hidden role field exists

**Acceptance Criteria:**
- ✅ Forminator form (ID 80) displays
- ✅ Form contains required fields: email, username, password
- ✅ Hidden field `hidden-1` exists with value matching URL role parameter
- ✅ Submit button has primary blue styling (#0073AA)
- ✅ Form validation messages display on empty submit

**Automation Notes:**
- Form selector: `form.forminator-ui-form`
- Hidden field: `input[name="hidden-1"]` should have value="candidate"
- Submit button: `.forminator-button-submit`

---

### TC-001-007: Register Profile - Successful Submission
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** Valid test credentials  
**Summary:** Test complete registration flow with valid credentials and database record creation  
**Description:** Validates the end-to-end registration process including form submission, user creation in WordPress, and data change request creation in the custom table with pending approval status.

**Steps:**
1. Navigate to `/register-profile/?role=candidate`
2. Fill in email: `test-{timestamp}@example.com`
3. Fill in username: `testuser{timestamp}`
4. Fill in password: `TestPass123!`
5. Confirm password: `TestPass123!`
6. Click Submit
7. Wait for processing

**Acceptance Criteria:**
- ✅ Form submits without errors
- ✅ Success message displays
- ✅ User record created in `wp_users` table
- ✅ User meta created in `wp_usermeta` table
- ✅ Data change request created in `td_user_data_change_requests` table with role="candidate"
- ✅ Request has status="pending_approval"

**Automation Notes:**
- Use dynamic timestamp for unique emails
- Database validation query: `SELECT * FROM td_user_data_change_requests WHERE email='{email}'`
- Check `requested_data` JSON contains `"role":"candidate"`

---

### TC-001-008: Register Profile - Role Parameter Persistence
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Verify role parameter persists through page refresh and JavaScript fallback  
**Description:** Tests the dual role capture mechanism (Forminator prefill + JavaScript fallback) to ensure the role parameter is reliably captured from the URL and persists through page interactions.

**Steps:**
1. Navigate to `/register-profile/?role=employer`
2. Inspect hidden field value (browser DevTools or Playwright)
3. Fill form partially (don't submit)
4. Refresh page
5. Check hidden field value again

**Acceptance Criteria:**
- ✅ Hidden field `hidden-1` has value="employer" on initial load
- ✅ JavaScript fallback sets value if prefill fails
- ✅ Value persists through page refresh (from URL parameter)
- ✅ Console logs show "Role set from URL" or "Role set from prefill"

**Automation Notes:**
- Use `page.evaluate()` to check `document.querySelector('input[name="hidden-1"]').value`
- Check console logs: `page.on('console', msg => ...)`

---

## TS-002: Manager Pages

### TC-002-001: Managers Landing Page Load
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Verify Managers landing page displays with Admin and Actions cards  
**Description:** Tests that the Managers landing page loads correctly with two navigation cards (Admin and Actions) that provide access to manager-specific functionality.

**Steps:**
1. Navigate to `/managers/`
2. Wait for page to load

**Acceptance Criteria:**
- ✅ Page loads successfully (status 200)
- ✅ Page title is "Managers"
- ✅ 2 cards visible: Admin and Actions
- ✅ Both cards have icon, title, description, and "Access" button
- ✅ Buttons have primary blue styling
- ✅ Cards are clickable (entire card acts as link)

**Automation Notes:**
- Card selector: `.wp-block-group .is-style-card` (2 cards)
- Admin card link: `a[href*="/admin"]` or `a[href*="/managers/admin"]`
- Actions card link: `a[href*="/actions"]` or `a[href*="/managers/actions"]`

---

### TC-002-002: Managers Landing - Admin Card Click
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Admin card navigation to Manager Admin dashboard  
**Description:** Validates that clicking the Admin card (entire card is clickable) redirects to the Manager Admin page with the dashboard tiles.

**Steps:**
1. Navigate to `/managers/`
2. Click on **Admin** card (anywhere on the card)
3. Verify redirect

**Acceptance Criteria:**
- ✅ Redirects to `/admin` (or `/managers/admin`)
- ✅ Manager Admin page loads successfully
- ✅ Dashboard tiles are visible

**Automation Notes:**
- Click selector: First `.wp-block-group .is-style-card` or specific Admin card
- URL assertion: `expect(page).toHaveURL(/\/admin/)`

---

### TC-002-003: Managers Landing - Actions Card Click
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Actions card navigation to Manager Actions page  
**Description:** Validates that clicking the Actions card redirects to the Manager Actions page with the tabbed interface for approval workflows.

**Steps:**
1. Navigate to `/managers/`
2. Click on **Actions** card (anywhere on the card)
3. Verify redirect

**Acceptance Criteria:**
- ✅ Redirects to `/actions` (or `/managers/actions`)
- ✅ Manager Actions page loads successfully
- ✅ Tab navigation is visible

**Automation Notes:**
- Click selector: Second `.wp-block-group .is-style-card` or specific Actions card
- URL assertion: `expect(page).toHaveURL(/\/actions/)`

---

### TC-002-004: Manager Admin Page Load
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role  
**Summary:** Verify Manager Admin dashboard loads with 4 management tiles  
**Description:** Tests that the Manager Admin page loads correctly with four dashboard tiles (User & Role Management, System Settings, Audit Logs, Platform Monitoring) with proper spacing and responsive layout.

**Steps:**
1. Navigate to `/admin`
2. Wait for page to load

**Acceptance Criteria:**
- ✅ Page loads successfully (status 200)
- ✅ Page title is "Manager Admin"
- ✅ 4 dashboard tiles visible:
  - User & Role Management
  - System Settings
  - Audit Logs
  - Platform Monitoring
- ✅ Each tile has icon, title, and description
- ✅ Tiles are centered with 40% column width
- ✅ Horizontal padding correct (no overflow)

**Automation Notes:**
- Tile selector: `.wp-block-group .is-style-card` (4 tiles)
- Column width check: `.wp-block-column` should have `flex-basis:40%` or similar
- Responsive check: Test at viewports 375px, 768px, 1920px

---

### TC-002-005: Manager Admin - Role-Based Access Control
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** User NOT logged in OR logged in as non-Manager role  
**Summary:** Test access restriction for non-Manager users  
**Description:** Validates that the Manager Admin page is protected and only accessible to users with Manager role, redirecting unauthorized users to login or 403 page.

**Steps:**
1. Navigate to `/admin` without authentication
2. Verify access restriction

**Acceptance Criteria:**
- ✅ Redirects to login page OR shows access denied message
- ✅ Dashboard tiles are NOT visible to non-managers
- ✅ URL protection active (cannot bypass with direct URL)

**Automation Notes:**
- Test with different roles: Candidate, Employer, Scout, Operator
- Use WPUM role check or custom auth middleware
- Expected redirect: `/login` or `/403-forbidden`

---

### TC-002-006: Manager Actions Page Load
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role  
**Summary:** Verify Manager Actions page loads with tabbed interface  
**Description:** Tests that the Manager Actions page displays correctly with four tabs (Submitted, Approved, Rejected, All) showing placeholder content until approval workflows are implemented.

**Steps:**
1. Navigate to `/actions`
2. Wait for page to load

**Acceptance Criteria:**
- ✅ Page loads successfully (status 200)
- ✅ Page title is "Manager Actions"
- ✅ 4 tab buttons visible: Submitted, Approved, Rejected, All
- ✅ All tabs show "Under Development" placeholder content
- ✅ Tab styling matches design system (navy for active, gray for inactive)

**Automation Notes:**
- Tab selector: `.tab-navigation button` (4 buttons)
- Active tab selector: `.tab-navigation button.active` or `[aria-selected="true"]`
- Content area: `.tab-content` should show "Under Development" text

---

### TC-002-007: Manager Actions - Tab Switching (Submitted)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role, on `/actions`  
**Summary:** Test default Submitted tab is active on page load  
**Description:** Validates that the Submitted tab is the default active tab when the Manager Actions page loads, with proper styling and placeholder content displayed.

**Steps:**
1. Verify default tab is "Submitted"
2. Check active tab styling
3. Verify content area shows "Submitted" placeholder

**Acceptance Criteria:**
- ✅ "Submitted" tab has active styling (navy background, white text)
- ✅ Other tabs have inactive styling (gray background)
- ✅ Content area shows "Submitted Requests - Under Development"
- ✅ AJAX endpoint NOT called (feature not implemented yet)

**Automation Notes:**
- Active tab: `page.locator('.tab-navigation button:has-text("Submitted")')`
- Check `aria-selected="true"` or `.active` class
- Content check: `expect(page.locator('.tab-content')).toContainText('Submitted')`

---

### TC-002-008: Manager Actions - Tab Switching (Approved)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role, on `/actions`  
**Summary:** Test Approved tab activation and content display  
**Description:** Validates that clicking the Approved tab switches the active tab state, updates the content area, and applies proper styling transitions.

**Steps:**
1. Click "Approved" tab
2. Verify tab becomes active
3. Check content area updates

**Acceptance Criteria:**
- ✅ "Approved" tab becomes active (navy styling)
- ✅ "Submitted" tab becomes inactive (gray styling)
- ✅ Content area shows "Approved Requests - Under Development"
- ✅ Tab URL parameter updates (if implemented): `?tab=approved`

**Automation Notes:**
- Click: `page.locator('.tab-navigation button:has-text("Approved")').click()`
- Wait for transition: `await page.waitForTimeout(300)` or CSS animation
- Content assertion: `toContainText('Approved')`

---

### TC-002-009: Manager Actions - Tab Switching (Rejected)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role, on `/actions`  
**Summary:** Test Rejected tab activation and content display  
**Description:** Validates that clicking the Rejected tab switches the active tab state, updates the content area, and applies proper styling transitions.

**Steps:**
1. Click "Rejected" tab
2. Verify tab becomes active
3. Check content area updates

**Acceptance Criteria:**
- ✅ "Rejected" tab becomes active
- ✅ Previous tab becomes inactive
- ✅ Content area shows "Rejected Requests - Under Development"

**Automation Notes:**
- Similar pattern to TC-002-008

---

### TC-002-010: Manager Actions - Tab Switching (All)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role, on `/actions`  
**Summary:** Test All tab activation and content display  
**Description:** Validates that clicking the All tab switches the active tab state, updates the content area, and applies proper styling transitions.

**Steps:**
1. Click "All" tab
2. Verify tab becomes active
3. Check content area updates

**Acceptance Criteria:**
- ✅ "All" tab becomes active
- ✅ Previous tab becomes inactive
- ✅ Content area shows "All Requests - Under Development"

**Automation Notes:**
- Similar pattern to TC-002-008

---

### TC-002-011: Manager Actions - Tab Persistence on Refresh
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role  
**Summary:** Test active tab state persistence through page refresh  
**Description:** Validates whether the active tab state persists through page refresh (if URL parameters are used) or defaults back to Submitted tab.

**Steps:**
1. Navigate to `/actions`
2. Click "Approved" tab
3. Refresh page (F5 or Ctrl+R)
4. Verify active tab

**Acceptance Criteria:**
- ✅ Active tab persists after refresh (if URL parameter used)
- ✅ OR defaults back to "Submitted" tab (if no persistence)
- ✅ Content area matches active tab

**Automation Notes:**
- Use `page.reload()` to test refresh behavior
- Check URL for `?tab=approved` parameter
- If no URL params, expect default "Submitted" to be active

---

### TC-002-012: Manager Actions - Responsive Design
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager role  
**Summary:** Test Manager Actions page responsive behavior across viewports  
**Description:** Validates that the Manager Actions page layout adapts correctly to mobile, tablet, and desktop viewports with proper tab stacking or scrolling.

**Steps:**
1. Navigate to `/actions`
2. Test at mobile viewport (375px)
3. Verify tab navigation stacks or scrolls horizontally
4. Test at tablet viewport (768px)
5. Test at desktop viewport (1920px)

**Acceptance Criteria:**
- ✅ Mobile: Tabs stack vertically OR scroll horizontally
- ✅ Tablet: Tabs display in single row
- ✅ Desktop: Tabs display with comfortable spacing
- ✅ Content area remains readable at all viewports
- ✅ No horizontal overflow

**Automation Notes:**
- Use `page.setViewportSize({ width: 375, height: 667 })`
- Check for horizontal scroll: `page.evaluate(() => document.body.scrollWidth > window.innerWidth)`

---

## TS-003: Simple Content Pages

### TC-003-001: Help Page Load
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Verify Help page loads with complete content structure  
**Description:** Tests that the Help page loads correctly with all sections (hero, cards, FAQ, CTA, trust badges) using Gutenberg block patterns.

**Steps:**
1. Navigate to `/help/`
2. Wait for page to load

**Acceptance Criteria:**
- ✅ Page loads successfully (status 200)
- ✅ Page title is "Help & Support"
- ✅ Hero section visible with heading and description
- ✅ "How Can We Help?" section with 3 cards:
  - Getting Started
  - Account Management
  - Technical Support
- ✅ FAQ section with 4 questions in 2x2 grid
- ✅ "Need More Help?" CTA section with button
- ✅ Trust badges footer visible

**Automation Notes:**
- Hero selector: `.wp-block-group.hero-section`
- Cards: `.wp-block-columns .is-style-card` (3 cards)
- FAQ grid: `.wp-block-group.faq-section .wp-block-columns` (2 columns)
- CTA button: `.wp-block-button__link` in CTA section

---

### TC-003-002: Help Page - Card Grid Layout
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Help page card grid displays with proper styling  
**Description:** Validates that the 3-card grid in the Help page uses the card-grid-3 pattern with equal heights, rounded corners, and consistent spacing.

**Steps:**
1. Navigate to `/help/`
2. Scroll to "How Can We Help?" section
3. Verify card layout

**Acceptance Criteria:**
- ✅ 3 cards display in single row on desktop
- ✅ Cards have equal height (100% minHeight)
- ✅ Cards have rounded corners (12px border-radius)
- ✅ Cards have consistent padding
- ✅ Icons display correctly in each card

**Automation Notes:**
- Card selector: `.is-style-card`
- CSS check: `border-radius: 12px`
- Height check: All cards should have equal `offsetHeight`

---

### TC-003-003: 403 Forbidden Page Load
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Verify 403 Access Restricted page displays correctly  
**Description:** Tests that the 403 Forbidden page loads successfully with Gutenberg blocks (not Elementor) and provides clear access restriction messaging.

**Steps:**
1. Navigate to `/403-forbidden/`
2. Wait for page to load

**Acceptance Criteria:**
- ✅ Page loads successfully (status 200, not actual 403)
- ✅ Page title is "Access Restricted" or similar
- ✅ Error message explains access restriction
- ✅ Styled with block patterns (not plain text)
- ✅ Navigation back to home is available

**Automation Notes:**
- Check for Gutenberg blocks: `.wp-block-group`
- Verify NOT Elementor: `.elementor` should NOT exist
- Back to home link: `a[href="/"]` or `a[href="/welcome"]`

---

### TC-003-004: Privacy Policy Page Load
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** Privacy Policy page is published (status=publish)  
**Summary:** Verify Privacy Policy page is published and accessible  
**Description:** Tests that the Privacy Policy page is published (not draft) and loads successfully with Gutenberg content for GDPR compliance.

**Steps:**
1. Navigate to `/privacy-policy/`
2. Wait for page to load

**Acceptance Criteria:**
- ✅ Page loads successfully (status 200, NOT 404)
- ✅ Page title is "Privacy Policy"
- ✅ Page content displays (not empty)
- ✅ Uses Gutenberg blocks (not Elementor)
- ✅ GDPR-compliant content structure

**Automation Notes:**
- Status check: Ensure `wp post get 3 --field=post_status` returns "publish"
- Content check: Page should have substantive text (>500 characters)
- Block check: `.wp-block-group` or `.wp-block-paragraph` exists

---

### TC-003-005: Privacy Policy - Footer Link
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Privacy Policy link in footer navigates correctly  
**Description:** Validates that the Privacy Policy link exists in the site footer and correctly navigates to the Privacy Policy page.

**Steps:**
1. Navigate to any page (e.g., `/welcome/`)
2. Scroll to footer
3. Locate "Privacy Policy" link
4. Click link
5. Verify redirect

**Acceptance Criteria:**
- ✅ Privacy Policy link exists in footer
- ✅ Link points to `/privacy-policy/`
- ✅ Clicking link navigates to Privacy Policy page
- ✅ Page loads successfully (not 404)

**Automation Notes:**
- Footer selector: `footer` or `.site-footer`
- Link selector: `footer a[href*="privacy-policy"]`
- Use `page.click()` and verify URL change

---

### TC-003-006: Sample Page Deleted
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Verify Sample Page has been deleted from WordPress  
**Description:** Tests that the default WordPress Sample Page has been removed from the database and returns a 404 error when accessed.

**Steps:**
1. Navigate to `/sample-page/`
2. Verify 404 response

**Acceptance Criteria:**
- ✅ Page returns 404 error
- ✅ Sample page (ID 2) does NOT exist in database
- ✅ WordPress shows "Page Not Found" message

**Automation Notes:**
- Response check: `expect(page).toHaveURL(/404/)`
- Database check: `wp post get 2` should fail
- 404 page selector: `.error-404` or `body.error404`

---

## TS-004: Form Functionality

### TC-004-001: Forminator Form 80 - Field Validation (Email)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** Navigate to `/register-profile/?role=candidate`  
**Summary:** Test email field validation with empty, invalid, and valid inputs  
**Description:** Validates that the email field in the registration form correctly validates empty inputs, malformed email addresses, and accepts valid email formats.

**Steps:**
1. Leave email field empty
2. Click Submit
3. Verify error message
4. Enter invalid email: `notanemail`
5. Click Submit
6. Verify error message
7. Enter valid email: `test@example.com`
8. Verify no error

**Acceptance Criteria:**
- ✅ Empty email shows "This field is required"
- ✅ Invalid email shows "Please enter a valid email address"
- ✅ Valid email removes error message
- ✅ Error styling applied (red border, red text)

**Automation Notes:**
- Email field: `input[name="email-1"]` or `input[type="email"]`
- Error selector: `.forminator-error` or `.forminator-field-error`
- Valid email pattern: `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`

---

### TC-004-002: Forminator Form 80 - Field Validation (Username)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** Navigate to `/register-profile/?role=candidate`  
**Summary:** Test username field validation with various inputs  
**Description:** Validates that the username field correctly validates empty inputs, checks minimum length requirements, and accepts valid usernames.

**Steps:**
1. Leave username field empty
2. Click Submit
3. Verify error message
4. Enter short username: `ab`
5. Click Submit
6. Verify error message (if min length validation exists)
7. Enter valid username: `testuser123`
8. Verify no error

**Acceptance Criteria:**
- ✅ Empty username shows "This field is required"
- ✅ Short username shows min length error (if configured)
- ✅ Valid username removes error message

**Automation Notes:**
- Username field: `input[name="text-1"]` or similar
- Check WPUM username requirements (min 3 chars, alphanumeric)

---

### TC-004-003: Forminator Form 80 - Field Validation (Password)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** Navigate to `/register-profile/?role=candidate`  
**Summary:** Test password field validation and strength requirements  
**Description:** Validates that the password field enforces strength requirements (minimum length, complexity) and verifies password confirmation matching.

**Steps:**
1. Leave password field empty
2. Click Submit
3. Verify error message
4. Enter weak password: `123`
5. Click Submit
6. Verify error message
7. Enter strong password: `TestPass123!`
8. Verify no error

**Acceptance Criteria:**
- ✅ Empty password shows "This field is required"
- ✅ Weak password shows strength requirement error
- ✅ Strong password removes error message
- ✅ Password confirmation field validates match

**Automation Notes:**
- Password field: `input[name="password-1"]` or `input[type="password"]`
- Confirm password: `input[name="password-2"]` or similar
- Check password mismatch: Enter different values in both fields

---

### TC-004-004: Forminator Form 80 - Hidden Field Prefill
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** Navigate to `/register-profile/?role=employer`  
**Summary:** Test hidden role field is populated from URL parameter  
**Description:** Validates that the hidden-1 field is correctly populated with the role parameter from the URL and is included in form submission.

**Steps:**
1. Inspect hidden field `hidden-1`
2. Verify value matches URL parameter

**Acceptance Criteria:**
- ✅ Hidden field `hidden-1` exists
- ✅ Hidden field value is "employer" (matches URL parameter)
- ✅ Field is NOT visible to user
- ✅ Field is included in form submission

**Automation Notes:**
- Field selector: `input[name="hidden-1"]`
- Value check: `await page.locator('input[name="hidden-1"]').inputValue()` equals "employer"
- Visibility check: `await page.locator('input[name="hidden-1"]').isHidden()` returns true

---

### TC-004-005: Forminator Form 80 - JavaScript Fallback
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** Navigate to `/register-profile/?role=scout`  
**Summary:** Test JavaScript fallback mechanism for role capture  
**Description:** Validates that the custom JavaScript fallback correctly captures the role parameter from the URL if Forminator's built-in prefill mechanism fails.

**Steps:**
1. Open browser console
2. Check for "Role set from URL" console log
3. Inspect hidden field value

**Acceptance Criteria:**
- ✅ Console log shows "Role set from URL: scout" or "Role set from prefill: scout"
- ✅ Hidden field value is "scout"
- ✅ JavaScript runs without errors

**Automation Notes:**
- Console listener: `page.on('console', msg => console.log(msg.text()))`
- Check for specific log message pattern
- Verify no JavaScript errors in console

---

### TC-004-006: Forminator Form 80 - Successful Registration
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** Valid test data  
**Summary:** Test complete registration submission and database record creation  
**Description:** Validates the end-to-end registration process including form submission, WordPress user creation, and pending approval record in td_user_data_change_requests table.

**Steps:**
1. Navigate to `/register-profile/?role=candidate`
2. Fill email: `autotest-{timestamp}@example.com`
3. Fill username: `autotest{timestamp}`
4. Fill password: `AutoTest123!`
5. Confirm password: `AutoTest123!`
6. Click Submit
7. Wait for success response

**Acceptance Criteria:**
- ✅ Form submits successfully (no errors)
- ✅ Success message displays
- ✅ User created in `wp_users` table
- ✅ User meta created in `wp_usermeta`
- ✅ Data change request created in `td_user_data_change_requests`:
  - `email` = submitted email
  - `requested_data` JSON contains `"role":"candidate"`
  - `status` = "pending_approval"
  - `request_type` = "profile_registration"

**Automation Notes:**
- Success selector: `.forminator-response-message.forminator-success`
- Database validation: Query `td_user_data_change_requests` table
- JSON validation: Parse `requested_data` column, check `role` field

---

### TC-004-007: Forminator Form 80 - Duplicate Email
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** Existing user with email `duplicate@example.com`  
**Summary:** Test registration fails with duplicate email address  
**Description:** Validates that the registration form correctly prevents duplicate email registration and displays an appropriate error message.

**Steps:**
1. Navigate to `/register-profile/?role=candidate`
2. Fill email: `duplicate@example.com`
3. Fill username: `newuser123`
4. Fill password: `TestPass123!`
5. Confirm password: `TestPass123!`
6. Click Submit
7. Verify error

**Acceptance Criteria:**
- ✅ Form submission fails
- ✅ Error message: "This email address is already registered"
- ✅ No new user created in database
- ✅ No duplicate data change request created

**Automation Notes:**
- Error selector: `.forminator-error` or `.forminator-response-message.forminator-error`
- Pre-create test user with known email
- Cleanup: Delete test user after test completes

---

### TC-004-008: Forminator Form 80 - Duplicate Username
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** Existing user with username `existinguser`  
**Summary:** Test registration fails with duplicate username  
**Description:** Validates that the registration form correctly prevents duplicate username registration and displays an appropriate error message.

**Steps:**
1. Navigate to `/register-profile/?role=candidate`
2. Fill email: `newemail@example.com`
3. Fill username: `existinguser`
4. Fill password: `TestPass123!`
5. Confirm password: `TestPass123!`
6. Click Submit
7. Verify error

**Acceptance Criteria:**
- ✅ Form submission fails
- ✅ Error message: "This username is already taken"
- ✅ No new user created in database

**Automation Notes:**
- Similar to TC-004-007
- Pre-create test user with known username

---

### TC-004-009: Form Styling - Select Role Button
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** Navigate to `/select-role/`  
**Summary:** Test Select Role buttons have correct navy styling  
**Description:** Validates that all "Get Started" buttons on the Select Role page use the navy color scheme (#1A365D) with proper hover states.

**Steps:**
1. Inspect "Get Started" button on any role card
2. Verify CSS styling

**Acceptance Criteria:**
- ✅ Button background color is navy (#1A365D)
- ✅ Button text color is white (#FFFFFF)
- ✅ Button has consistent padding
- ✅ Hover state changes background (darker navy or opacity change)
- ✅ Button is full-width within card

**Automation Notes:**
- Button selector: `.wp-block-button__link`
- CSS check: `await page.locator('.wp-block-button__link').evaluate(el => getComputedStyle(el).backgroundColor)`
- Expected RGB: `rgb(26, 54, 93)` for #1A365D

---

### TC-004-010: Form Styling - Register Profile Submit Button
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** Navigate to `/register-profile/?role=candidate`  
**Summary:** Test Register Profile submit button has correct blue styling  
**Description:** Validates that the registration form submit button uses the primary blue color scheme (#0073AA) with proper hover and disabled states.

**Steps:**
1. Inspect Submit button
2. Verify CSS styling

**Acceptance Criteria:**
- ✅ Button background color is primary blue (#0073AA or #2271B1)
- ✅ Button text color is white
- ✅ Button has consistent padding with Select Role buttons
- ✅ Hover state changes background
- ✅ Disabled state is visually distinct (gray background)

**Automation Notes:**
- Submit button: `.forminator-button-submit`
- Check hover: Use `page.hover()` then inspect styles
- Check disabled: Add `disabled` attribute, verify gray background

---

## TS-005: Navigation & Redirects

### TC-005-001: Welcome Page to Select Role
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test navigation from Welcome page to Select Role page  
**Description:** Validates that the CTA button on the Welcome page correctly redirects users to the Select Role page to begin registration.

**Steps:**
1. Navigate to `/welcome/`
2. Locate "Get Started" or similar CTA button
3. Click button
4. Verify redirect

**Acceptance Criteria:**
- ✅ Redirects to `/select-role/`
- ✅ Select Role page loads successfully
- ✅ 4 role cards are visible

**Automation Notes:**
- CTA selector: `.wp-block-button__link` in hero or CTA section
- URL assertion: `expect(page).toHaveURL(/\/select-role/)`

---

### TC-005-002: Select Role to Register Profile (All Roles)
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test all role buttons redirect correctly with role parameters  
**Description:** Validates that all four role selection buttons correctly redirect to the Register Profile page with their respective role parameters properly captured.

**Steps:**
1. Test all 4 role buttons on `/select-role/`
2. Verify each redirects correctly with role parameter

**Acceptance Criteria:**
- ✅ Candidate → `/register-profile/?role=candidate`
- ✅ Employer → `/register-profile/?role=employer`
- ✅ Scout → `/register-profile/?role=scout`
- ✅ Operator → `/register-profile/?role=operator`
- ✅ All pages load successfully
- ✅ Role parameter captured in hidden field for all

**Automation Notes:**
- Loop through all 4 buttons
- Use `page.goto()` to reset between tests
- Validate URL and hidden field for each role

---

### TC-005-003: Managers Landing to Admin
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test navigation from Managers landing to Admin page  
**Description:** Validates that clicking the Admin card on the Managers landing page correctly redirects to the Manager Admin dashboard.

**Steps:**
1. Navigate to `/managers/`
2. Click Admin card
3. Verify redirect

**Acceptance Criteria:**
- ✅ Redirects to `/admin` (or `/managers/admin`)
- ✅ Manager Admin page loads
- ✅ Dashboard tiles visible

**Automation Notes:**
- Card click: Entire card should be clickable, not just button
- Test both card click and button click

---

### TC-005-004: Managers Landing to Actions
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test navigation from Managers landing to Actions page  
**Description:** Validates that clicking the Actions card on the Managers landing page correctly redirects to the Manager Actions interface.

**Steps:**
1. Navigate to `/managers/`
2. Click Actions card
3. Verify redirect

**Acceptance Criteria:**
- ✅ Redirects to `/actions` (or `/managers/actions`)
- ✅ Manager Actions page loads
- ✅ Tab navigation visible

**Automation Notes:**
- Similar to TC-005-003

---

### TC-005-005: Direct URL Access (Protected Pages)
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User NOT logged in  
**Summary:** Test protected pages redirect unauthenticated users  
**Description:** Validates that attempting to access Manager-only pages without authentication properly redirects to login or displays access denied.

**Steps:**
1. Navigate directly to `/admin` (without authentication)
2. Verify access restriction
3. Try `/actions` (without authentication)
4. Verify access restriction

**Acceptance Criteria:**
- ✅ Redirects to login page (`/login` or WPUM login)
- ✅ OR shows 403 Forbidden page
- ✅ Dashboard content NOT visible to unauthenticated users
- ✅ After login, redirects back to original page (optional)

**Automation Notes:**
- Clear cookies before test: `await context.clearCookies()`
- Check for login page: `.wpum-login-form` or similar
- Check for 403: `.error-403` or status code 403

---

### TC-005-006: Help Page - CTA Button Redirect
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test Help page CTA button navigation  
**Description:** Validates that the "Need More Help?" CTA button on the Help page correctly redirects to the contact form or support page.

**Steps:**
1. Navigate to `/help/`
2. Scroll to "Need More Help?" section
3. Click "Contact Support" button (or similar)
4. Verify redirect

**Acceptance Criteria:**
- ✅ Redirects to contact form page OR external support URL
- ✅ If contact form, form loads successfully
- ✅ If external URL, opens in new tab (optional)

**Automation Notes:**
- CTA button: `.wp-block-button__link` in CTA section
- Check for new tab: Use `page.waitForEvent('popup')`
- If same page: verify URL change

---

## TS-006: Authentication

### TC-006-001: Login Page Load
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Verify login page displays correctly with WPUM form  
**Description:** Tests that the WordPress User Manager login page loads successfully with all required fields and custom styling applied.

**Steps:**
1. Navigate to `/login/`
2. Wait for page to load

**Acceptance Criteria:**
- ✅ Page loads successfully (status 200)
- ✅ WPUM login form displays
- ✅ Form has username/email field and password field
- ✅ "Remember Me" checkbox (optional)
- ✅ Submit button visible
- ✅ "Forgot Password?" link visible
- ✅ Custom CSS applied (consistent with design system)

**Automation Notes:**
- Form selector: `.wpum-login-form` or `form[name="wpum-login"]`
- Username field: `input[name="username"]` or `input[name="log"]`
- Password field: `input[name="password"]` or `input[name="pwd"]`

---

### TC-006-002: Login - Successful Authentication (Manager)
**Priority:** Critical  
**Status:** Not Started  
**Prerequisites:** Existing user with Manager role (username: `manager1`, password: `ManagerPass123!`)  
**Summary:** Test successful login flow for Manager role user  
**Description:** Validates that a Manager user can successfully log in, receive session cookies, and access Manager-only pages.

**Steps:**
1. Navigate to `/login/`
2. Enter username: `manager1`
3. Enter password: `ManagerPass123!`
4. Click Submit
5. Wait for redirect

**Acceptance Criteria:**
- ✅ Login successful (no errors)
- ✅ Redirects to dashboard or welcome page
- ✅ User session cookie set
- ✅ User can access `/admin` page (Manager-only)
- ✅ Logout link visible in header/menu

**Automation Notes:**
- Success check: URL changes from `/login/`
- Cookie check: `await context.cookies()` should include WordPress auth cookie
- Role check: Access protected page to confirm Manager role

---

### TC-006-003: Login - Invalid Credentials
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test login fails with incorrect credentials  
**Description:** Validates that attempting to log in with invalid username or password displays appropriate error message and denies access.

**Steps:**
1. Navigate to `/login/`
2. Enter username: `nonexistentuser`
3. Enter password: `WrongPassword123!`
4. Click Submit
5. Verify error message

**Acceptance Criteria:**
- ✅ Login fails
- ✅ Error message displays: "Invalid username or password" or similar
- ✅ User remains on login page
- ✅ No session cookie set
- ✅ Cannot access protected pages

**Automation Notes:**
- Error selector: `.wpum-error` or `.login-error`
- Verify URL still contains `/login/`
- Verify no auth cookies set

---

### TC-006-004: Login - Empty Fields
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** None  
**Summary:** Test login form validation with empty fields  
**Description:** Validates that the login form prevents submission when required fields are empty and displays appropriate validation messages.

**Steps:**
1. Navigate to `/login/`
2. Leave username and password empty
3. Click Submit
4. Verify validation error

**Acceptance Criteria:**
- ✅ Form validation prevents submission
- ✅ Error message: "Username is required" and "Password is required"
- ✅ User remains on login page

**Automation Notes:**
- Check for HTML5 validation: `required` attribute on fields
- Check for custom validation: `.forminator-error` or similar

---

### TC-006-005: Logout - Successful Logout
**Priority:** High  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager  
**Summary:** Test successful logout and session termination  
**Description:** Validates that clicking the logout link successfully terminates the user session, clears cookies, and redirects appropriately.

**Recent Fixes:**
- ✅ Logout redirect fixed (Feb 14, 2026) - now redirects to Welcome page
- ✅ functions.php updated to redirect to /welcome/ instead of home page

**Steps:**
1. Locate logout link (header, menu, or user profile)
2. Click logout link
3. Verify redirect to Welcome page (/welcome/)
4. Verify session cleared

**Acceptance Criteria:**
- ✅ Redirects to Welcome page (/welcome/)
- ✅ Session cookie cleared
- ✅ User cannot access protected pages (e.g., `/admin`)
- ✅ Login form visible on auth pages

**Automation Notes:**
- Logout link: `a[href*="logout"]` or `a[href*="wp-login.php?action=logout"]`
- Expected redirect: https://wp.local/welcome/
- Cookie check: Auth cookies should be removed
- Protected page check: Try accessing `/admin`, should redirect to login

---

### TC-006-006: Session Persistence
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** User logged in as Manager with "Remember Me" checked  
**Summary:** Test session persistence across browser restarts  
**Description:** Validates that selecting "Remember Me" during login creates a persistent session that survives browser closure and restart.

**Steps:**
1. Login with "Remember Me" checked
2. Close browser (terminate Playwright browser context)
3. Open new browser context with same storage state
4. Navigate to `/admin`
5. Verify still logged in

**Acceptance Criteria:**
- ✅ User remains logged in across browser sessions
- ✅ Can access protected pages without re-login
- ✅ Session cookie has long expiration (14 days or similar)

**Automation Notes:**
- Save storage state: `await context.storageState({ path: 'auth.json' })`
- Load storage state: `context = await browser.newContext({ storageState: 'auth.json' })`
- Check cookie expiration in storage state file

---

### TC-006-007: Password Reset Flow
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** Existing user email `test@example.com`  
**Summary:** Test password reset request and email delivery  
**Description:** Validates the complete password reset flow including form submission, email generation, and reset link functionality.

**Steps:**
1. Navigate to `/login/`
2. Click "Forgot Password?" link
3. Verify redirect to password reset page
4. Enter email: `test@example.com`
5. Click Submit
6. Verify success message

**Acceptance Criteria:**
- ✅ Redirects to `/password-reset/` or similar
- ✅ Password reset form displays
- ✅ Success message: "Password reset email sent"
- ✅ Email received (check mail logs or use Mailhog)
- ✅ Reset link in email is valid (clickable, not expired)

**Automation Notes:**
- Forgot password link: `a[href*="password-reset"]` or `a[href*="lostpassword"]`
- Email validation: Use Mailhog API or check SMTP logs
- Reset link format: `/.../reset-password?key=...&login=...`

---

### TC-006-008: Role-Based Dashboard Redirect
**Priority:** Medium  
**Status:** Not Started  
**Prerequisites:** Multiple users with different roles (Manager, Candidate, Employer)  
**Summary:** Test role-based redirects after successful login  
**Description:** Validates that users are redirected to appropriate role-specific pages after login based on their assigned role (Manager, Candidate, Employer, etc.).

**Steps:**
1. Login as Manager
2. Verify redirects to `/admin` or manager-specific page
3. Logout
4. Login as Candidate
5. Verify redirects to candidate-specific page OR welcome page
6. Logout
7. Login as Employer
8. Verify redirects to employer-specific page OR welcome page

**Acceptance Criteria:**
- ✅ Managers → `/admin` or `/managers/`
- ✅ Candidates → `/candidates/` or `/welcome/`
- ✅ Employers → `/employers/` or `/welcome/`
- ✅ Each role sees appropriate navigation menu items
- ✅ Each role has access to their specific pages only

**Automation Notes:**
- Use role-specific test users
- Check redirect URL after successful login
- Verify navigation menu changes based on role

---

## Test Execution Notes

### Prerequisites for Automation
- Local WordPress environment running at `https://wp.local`
- Test database with clean slate (or use transactions for rollback)
- Test users created with specific roles:
  - `manager1` / `ManagerPass123!` (Manager role)
  - `candidate1` / `CandidatePass123!` (Candidate role)
  - `employer1` / `EmployerPass123!` (Employer role)
- Mail server (Mailhog or similar) for email testing
- Database access for validation queries

### Playwright Configuration Recommendations
```typescript
// playwright.config.ts
export default defineConfig({
  baseURL: 'https://wp.local',
  testDir: './tests/wordpress',
  timeout: 30000,
  retries: 2,
  use: {
    ignoreHTTPSErrors: true, // For self-signed SSL
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'mobile',
      use: { ...devices['iPhone 13'] },
    },
  ],
});
```

### Test Data Factory
Create reusable test data generators for:
- Unique emails: `test-${Date.now()}@example.com`
- Unique usernames: `testuser${Date.now()}`
- Random passwords: `Test${randomString(8)}!`

### Database Helpers
Create utilities for:
- Querying `td_user_data_change_requests` table
- Validating JSON in `requested_data` column
- Cleaning up test data after execution
- Creating test users with specific roles

### Future Test Suites (Post-MVP)
- **TS-007:** Approval Workflows (assign, approve, reject, undo)
- **TS-008:** CV Submission & Management
- **TS-009:** Employer Request Workflow
- **TS-010:** Scout Partner Integration
- **TS-011:** Email Notifications (12 templates)
- **TS-012:** Accessibility (WCAG 2.1 AA)
- **TS-013:** Performance (page load <3s)
- **TS-014:** Security (SQL injection, XSS, CSRF)

---

**End of Test Cases**  
**Total:** 50 test cases across 6 test suites  
**Last Updated:** February 14, 2026  
**Next Review:** After v3.7.0 deployment (Candidates, Employers, Scouts, Operators pages migration)
