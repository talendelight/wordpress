# Release Notes & Deployment Instructions

**Status:** 📋 Planning  
**Version:** v3.6.0  
**Target Date:** TBD

This document tracks all manual deployment steps required for the **next production release**.

**Purpose:** Ensure consistent, error-free deployments by documenting every manual step needed after Git push to main branch.

**📋 See Process:** [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) for workflow documentation

---

## v3.6.0 Release Summary

**Release Type:** Security & Infrastructure Improvements + Elementor Migration Completion  
**Deploy Date:** TBD (February 2026)

### Key Changes

**1. URL-Based Access Control (BREAKING CHANGE)**
- **What:** Migrate from page ID-based to URL pattern-based access control
- **Why:** Page IDs differ between local/production and change on database resets
- **Files:** `wp-content/themes/blocksy-child/functions.php`
- **Benefits:** Environment-agnostic, survives database resets, more maintainable
- **Impact:** No UI changes, improved reliability

**2. Login Form UX Improvements**
- **What:** Narrower login form (400px), centered button, improved styling
- **Files:** `wp-content/themes/blocksy-child/wpum-overrides.css`
- **Benefits:** Better visual consistency, matches hero button style
- **Impact:** Improved user experience on login page

**3. Managers Page Content Fix**
- **What:** Updated links from `/manager-admin/` to `/managers/admin/`
- **Files:** `restore/pages/managers-8.html`
- **Benefits:** Consistent URL structure (parent-child pages)
- **Impact:** Correct navigation links in Managers dashboard

**4. Elementor Migration - Operators Page**
- **What:** Migrated Operators dashboard from Elementor to Gutenberg blocks
- **Files:** `restore/pages/operators-9.html` (17,518 bytes)
- **Layout:** 2 rows with 3 cards each (Row 1: Needs Action, Manage Candidates, Manage Employers | Row 2: Manage Scouts, Performance, View Reports)
- **Benefits:** Zero Elementor dependencies, consistent design, easier maintenance
- **Impact:** Cleaner dashboard with better functional organization

**5. Elementor Migration - 403 Forbidden Page**
- **What:** Migrated 403 error page from Elementor to Gutenberg blocks
- **Files:** `restore/pages/403-forbidden-44.html` (10,344 bytes)
- **Benefits:** Zero Elementor dependencies, consistent styling
- **Impact:** Professional error page with consistent branding

**6. Record ID System (PENG-016)**
- **What:** Automatic request_id and record_id generation
- **Files:** `wp-content/mu-plugins/record-id-generator.php`, database migrations
- **Benefits:** Unique stable identifiers for all users
- **Impact:** Foundation for user tracking across systems

**7. API Security Hardening (PENG-054) ⚠️ CRITICAL**
- **What:** Comprehensive AJAX/REST API security enforcement
- **Files:** `wp-content/mu-plugins/td-api-security.php` (new), `docs/API-SECURITY-PATTERNS.md` (new)
- **Security Measures:**
  - REST API authentication enforcement (blocks unauthenticated access)
  - Custom role isolation (blocks access to WordPress admin API)
  - AJAX request monitoring and logging
  - XML-RPC disabled (common attack vector)
  - File editing disabled in admin
  - WordPress version hidden
- **Verified:** All 5 existing AJAX endpoints secured with nonce + role checks
- **Benefits:** Prevents privilege escalation, API abuse, unauthorized data access
- **Impact:** Production-ready security posture for MVP launch

**8. Plugin Removal**
- **What:** Remove PublishPress Capabilities plugin (if installed)
- **Why:** Access control now handled by custom code
- **Impact:** Reduced dependencies, simpler maintenance

### Files to Deploy

**Theme Files:**
- `wp-content/themes/blocksy-child/functions.php` (URL-based access control)
- `wp-content/themes/blocksy-child/wpum-overrides.css` (login form styling)

**MU-Plugins:**
- `wp-content/mu-plugins/record-id-generator.php` (PENG-016 - new file)
- `wp-content/mu-plugins/td-api-security.php` (PENG-054 - new file, CRITICAL)

**Database Migrations:**
- `infra/shared/db/260131-1200-add-record-id-prsn-cmpy.sql`
- `infra/shared/db/260131-1300-add-id-sequences-table.sql`
- `infra/shared/db/260131-1400-add-assigned-by-column.sql`
- `infra/shared/db/260204-0131-update-shortcodes-manager-operator-pages.sql`

**Page Content:**
- `restore/pages/managers-8.html` (22,471 bytes - corrected links)
- `restore/pages/operators-9.html` (17,518 bytes - NEW, migrated from Elementor)
- `restore/pages/403-forbidden-44.html` (10,344 bytes - NEW, migrated from Elementor)

### Testing Required

- [ ] URL-based access control for all roles (Candidate, Employer, Scout, Operator, Manager)
- [ ] Login form styling (desktop + mobile)
- [ ] Managers page navigation links
- [ ] Operators page layout and navigation
- [ ] 403 error page display
- [ ] **API Security (PENG-054):**
  - [ ] AJAX endpoints require authentication (test unauthenticated request → 403)
  - [ ] AJAX endpoints validate roles (test wrong role → 403)
  - [ ] AJAX endpoints validate nonce (test invalid nonce → error)
  - [ ] REST API blocks unauthenticated access (test public route)
  - [ ] REST A65-80 minutes**

| Step | Task | Time |
|------|------|------|
| 1 | Check/remove PublishPress plugin | 2-3 min |
| 2 | Git push (auto-deploys wp-content/) | 5 min |
| 3 | Deploy 4 database migrations | 8-10 min |
| 4 | Update Managers page content | 3-4 min |
| 5 | Deploy Operators page (NEW) | 3-4 min |
| 6 | Deploy 403 page (NEW) | 3-4 min |
| 7 | Verify access control (5 roles × 5 pages) | 10-12 min |
| 8 | Test login form styling | 3-4 min |
| 9 | Test page navigation and links | 5-6 min |
| 10 | Verify record ID generation | 3-4 min |
| 11 | **Test API security (PENG-054 - CRITICAL)** | 10-12 min |
| 12 | Post-deployment health check | 5-6 min |

**Breakdown:**
- Pre-deployment: 2-3 min
- Code deployment: 5 min (automated)
- Database work: 8-10 min
- Page updates: 9-12 min (3 pages)
- Testing & verification: 41-50 min (includes API security tests)

**Critical Path:** Database migrations → Page updates → Access control testing → **API security verification**
**Breakdown:**
- Pre-deployment: 2-3 min
- Code deployment: 5 min (automated)
- Database work: 8-10 min
- Page updates: 9-12 min (3 pages)
- Testing & verification: 26-32 min

**Critical Path:** Database migrations → Page updates → Access control testing

---

## Planned Features

### v3.6.0 Features (In Development)

**URL-Based Access Control (Complete - February 10, 2026)**
- **Purpose:** Replace page ID-based access control with environment-agnostic URL pattern matching
- **Implementation:** [wp-content/themes/blocksy-child/functions.php](../wp-content/themes/blocksy-child/functions.php)
- **Documentation:** [docs/PAGE-ACCESS-CONTROL.md](PAGE-ACCESS-CONTROL.md) v3.6.0
- **Scope:**
  - URL prefix matching: `/candidates/*`, `/employers/*`, `/scouts/*`, `/managers/*`, `/operators/*`
  - Login redirect with return URL: `?redirect_to={original_url}`
  - Manager oversight access to operator pages
  - Environment-agnostic (works on local + production)
  - Survives database resets (no page ID dependencies)
- **Benefits:**
  - ✅ No page ID mapping between environments
  - ✅ More maintainable (URL patterns vs ID arrays)
  - ✅ Automatic coverage of subpages
  - ✅ Resilient to database resets

**Login Form UX Improvements (Complete - February 10, 2026)**
- **Purpose:** Improve login form visual consistency and user experience
- **Implementation:** [wp-content/themes/blocksy-child/wpum-overrides.css](../wp-content/themes/blocksy-child/wpum-overrides.css)
- **Scope:**
  - Form width: Reduced from 480px to 400px
  - Button width: Changed from 100% (full-width) to auto (min-width: 140px)
  - Button centering: `display: block` + `margin: 0 auto`
- **Benefits:**
  - ✅ Matches welcome page hero button style
  - ✅ More compact, professional appearance
  - ✅ Better visual hierarchy

**Managers Page Content Fix (Complete - February 10, 2026)**
- **Purpose:** Update Managers dashboard with correct navigation links
- **Implementation:** [restore/pages/managers-8.html](../restore/pages/managers-8.html)
- **Scope:**
  - Updated links from `/manager-admin/` to `/managers/admin/`
  - Consistent parent-child URL structure
  - 9 Quick Links for manager navigation
- **Benefits:**
  - ✅ Correct URL structure throughout site
  - ✅ Functional dashboard navigation

**Elementor Migration - Operators Page (Complete - February 11, 2026)**
- **Purpose:** Migrate Operators dashboard from Elementor to Gutenberg blocks
- **Implementation:** [restore/pages/operators-9.html](../restore/pages/operators-9.html)
- **Scope:**
  - Page ID 9: Operators landing page
  - **Updated Layout:** 2 rows with 3 cards each (February 11 refinement)
    - Row 1: Needs Action, Manage Candidates, Manage Employers
    - Row 2: Manage Scouts, Performance, View Reports
    - 32px spacer between rows for proper visual separation
  - Hero, Quick Links (6 cards), CTA, Footer sections
  - Content: 20,450 bytes (updated)
- **Benefits:**
  - ✅ No Elementor dependency
  - ✅ Consistent with other landing pages
  - ✅ Easier maintenance
  - ✅ Better functional organization (people management in Row 1, operations in Row 2)

**Elementor Migration - 403 Forbidden Page (Complete - February 11, 2026)**
- **Purpose:** Migrate 403 error page from Elementor to Gutenberg blocks
- **Implementation:** [restore/pages/403-forbidden-44.html](../restore/pages/403-forbidden-44.html)
- **Scope:**
  - Page ID 44: Access Restricted error page
  - Hero with 403 message, information cards, CTA section
  - Content: 10,344 bytes
- **Benefits:**
  - ✅ No Elementor dependency
  - ✅ Consistent styling with other pages

**Migration Summary:**
- ✅ All 7 main pages migrated from Elementor to Gutenberg
- ✅ Welcome (6), Employers (64), Candidates (7), Scouts (76), Managers (8), Operators (9), 403 Forbidden (44)
- ✅ Zero Elementor dependencies
- ✅ Consistent block-based architecture

---

### Phase 0 Business Foundations (Complete - January 23-31, 2026)

**BMSL-001: Role Capabilities Matrix (Complete - January 24, 2026)**
- **Purpose:** Define role capabilities and access boundaries for all custom roles
- **Deliverable:** [docs/ROLE-CAPABILITIES-MATRIX.md](ROLE-CAPABILITIES-MATRIX.md)
- **Scope:**
  - 5 custom roles defined: Employer, Candidate, Scout, Operator, Manager
  - External vs Internal role categorization
  - Explicit CAN/CANNOT permission lists for each role
  - WordPress capabilities mapping
  - Admin panel access rules
  - Approval authority matrix (Operator vs Manager)
- **Benefits:**
  - ✅ Foundation for all RBAC enforcement
  - ✅ Unblocks PENG-053 (wp-admin blocking)
  - ✅ Unblocks PENG-054 (endpoint hardening)
  - ✅ Guides Phase 1-2 registration and approval workflows

**PENG-001: Record ID Strategy v2.0 (Complete - January 30, 2026)**
- **Purpose:** Define unique, stable identifier system for all users across WordPress, Excel, and future Person app
- **Deliverables:** 
  - [docs/PENG-001-CANDIDATEID-STRATEGY-V2.md](PENG-001-CANDIDATEID-STRATEGY-V2.md) - Comprehensive v2.0 strategy
  - [infra/shared/db/260131-1200-add-record-id-prsn-cmpy.sql](../infra/shared/db/260131-1200-add-record-id-prsn-cmpy.sql) - Database migration
- **Format:** Dual ID system (simplified format without zero-padding)
  - **Request ID:** USRQ-YYMMDD-N (generated on submission for all requests, e.g., USRQ-260131-1, USRQ-260131-42)
  - **Record ID:** PRSN/CMPY-YYMMDD-N (assigned post-approval, e.g., PRSN-260131-1, CMPY-260131-8)
    - PRSN = Person (candidate, scout, operator, manager, employee)
    - CMPY = Company (employer)
- **Major Simplification (v1.0 → v2.0):**
  - ❌ v1.0: 5 role-specific prefixes (TD/TE/TS/TO/TM)
  - ✅ v2.0: 2 entity-type prefixes (PRSN/CMPY)
  - ❌ v1.0: Zero-padded 4-digit sequences (0001, 0042)
  - ✅ v2.0: Natural sequence numbers (1, 42)
  - Reduced complexity: 60% fewer ID types to maintain
- **Scope:**
  - Storage: `request_id` and `record_id` columns in `td_user_data_change_requests`
  - Generation: Auto-assign request_id on submission, record_id on approval
  - Entity-based categorization (not role-based)
  - Migration path: WordPress → Excel → Person app via external_id mapping
  - Rebrand-proof: PRSN/CMPY prefixes are not brand-specific (no TD→HA migration needed)
- **Benefits:**
  - ✅ Simpler system: 2 entity types vs 5 role types
  - ✅ Future-proof: New roles automatically map to PRSN or CMPY
  - ✅ Clearer semantics: Entity-based, not role-based
  - ✅ Easier maintenance and communication
  - ✅ Stable reference ID independent of email/phone changes
- **Next:** PENG-016 implementation in Phase 1

**COPS-001: CV Lifecycle Policy (Complete - January 25, 2026)**
- **Purpose:** Define CV storage, archiving, and deletion policies for GDPR compliance
- **Deliverable:** [Documents/deliverables/COPS-001-CV-LIFECYCLE-POLICY.md](../../../Documents/deliverables/COPS-001-CV-LIFECYCLE-POLICY.md)
- **Scope:**
  - CV storage location and naming conventions
  - Retention periods aligned with GDPR requirements
  - Archiving and deletion workflows
  - Consent capture requirements
- **Benefits:**
  - ✅ GDPR Art. 5(1)(e) compliance (storage limitation)
  - ✅ Unblocks PENG-041 (CV upload system)
  - ✅ Foundation for LFTC-002 (retention policy)

**PENG-053: Block /wp-admin/ Access (Complete - January 25, 2026)**
- **Purpose:** Enforce Administrator-only access to WordPress admin panel
- **Implementation:** [wp-content/plugins/talendelight-roles/talendelight-roles.php](../wp-content/plugins/talendelight-roles/talendelight-roles.php) v1.1.0
- **Documentation:** [docs/PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md](PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md)
- **Scope:**
  - Block all non-Administrator roles from `/wp-admin/` URLs
  - Role-based redirects to appropriate landing pages
  - User-friendly access denied notices
  - Hide admin bar for non-Administrators
  - Security audit logging for blocked attempts
- **Benefits:**
  - ✅ Critical security hardening
  - ✅ Enforces separation between operational dashboards and technical admin
  - ✅ Prevents unauthorized configuration changes
  - ✅ Audit trail for access attempts
- **Testing:** Manual testing required (see [PENG-053 documentation](PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md#7-testing-checklist))
- **Deployment:** Plugin v1.1.0 must be deployed to production

**PENG-016: Record ID Generation Implementation (Complete - January 31, 2026)**
- **Purpose:** Implement automatic ID generation for request_id and record_id columns
- **Deliverables:**
  - [infra/shared/db/260131-1300-add-id-sequences-table.sql](../infra/shared/db/260131-1300-add-id-sequences-table.sql) - Helper table for atomic sequence management
  - [wp-content/mu-plugins/record-id-generator.php](../wp-content/mu-plugins/record-id-generator.php) - Generation functions (new file, ~250 lines)
  - Modified: [wp-content/mu-plugins/forminator-custom-table.php](../wp-content/mu-plugins/forminator-custom-table.php) - Generate request_id on submission
  - Modified: [wp-content/mu-plugins/user-requests-display.php](../wp-content/mu-plugins/user-requests-display.php) - Generate record_id on approval
- **Scope:**
  - Helper table `td_id_sequences` with composite primary key (entity_type, date_str) for daily-reset sequences
  - 3 entity types: USRQ (user requests), PRSN (persons), CMPY (companies)
  - `td_generate_request_id()` - Called on every form submission
  - `td_generate_record_id($role)` - Called only on first approval
  - Atomic sequence increment using `ON DUPLICATE KEY UPDATE`
  - Transaction safety with START TRANSACTION / COMMIT / ROLLBACK
  - Format: Natural sequences without zero-padding (USRQ-260131-1, PRSN-260131-42)
- **Business Logic:**
  - request_id: Generated on every submission (new registrations AND updates), tracks audit trail
  - record_id: Generated once on first approval, becomes permanent user identifier
  - Resubmissions: New request_id, same record_id
- **Benefits:**
  - ✅ Automatic ID assignment - no manual intervention
  - ✅ Race-condition safe with database-level locking
  - ✅ Daily reset for manageable sequence numbers
  - ✅ Complete audit trail of all submission attempts
  - ✅ Stable permanent IDs for approved users
- **Testing Status:** Ready for testing (not yet tested with real form submissions)
- **Deployment Requirements:**
  - Apply both SQL migrations: 260131-1200 and 260131-1300
  - Deploy new mu-plugin: record-id-generator.php
  - Deploy modified mu-plugins: forminator-custom-table.php, user-requests-display.php

**RESTful URL Restructure (Complete - January 31, 2026 - Deployed in v3.5.0)**
- **Purpose:** Implement standard RESTful URL hierarchy for registration pages
- **Status:** ✅ Already deployed to production
- **Breaking Change:** URL paths changed, requires page updates in production
- **Old URLs:**
  - `/select-role/` - Role selection
  - `/register-profile/` - Person registration form
- **New URLs:**
  - `/roles/select/` - Role selection (ID 379, parent 657)
  - `/persons/register/` - Person registration form (ID 365, parent 659)
  - `/companies/register/` - Company registration placeholder (ID 656, parent 658)
- **Parent Pages Created:**
  - `/roles/` (ID 657) - Parent for role-related pages
  - `/persons/` (ID 659) - Parent for person-related pages
  - `/companies/` (ID 658) - Parent for company-related pages
- **Modified Files:**
  - [wp-content/themes/blocksy-child/page-role-selection.php](../wp-content/themes/blocksy-child/page-role-selection.php) - Updated routing logic
  - [wp-content/themes/blocksy-child/functions.php](../wp-content/themes/blocksy-child/functions.php) - Fixed redirect to not intercept child pages
- **Routing Logic:**
  - Employer role → `/companies/register/?td_user_role=employer`
  - All other roles → `/persons/register/?td_user_role={role}`
- **Bug Fixes:**
  - Fixed: Form submission preventing redirect (changed `<form>` to `<div>`)
  - Fixed: `is_page('register')` matching child pages (added `post_parent == 0` check)
- **Benefits:**
  - ✅ Standard RESTful convention
  - ✅ Clear organizational hierarchy
  - ✅ Future-proof for additional resources (e.g., `/roles/list/`, `/persons/profile/`)
  - ✅ Separates company and person workflows
- **Deployment Requirements:**
  - Create 3 parent pages: roles, persons, companies
  - Update existing pages with new slugs and parent relationships
  - Update page ID 379 (select-role): slug='select', parent=657
  - Update page ID 365 (person-register): slug='register', parent=659
  - Update page ID 656 (company-register): slug='register', parent=658
  - Flush permalinks after page updates
  - Deploy theme changes: page-role-selection.php, functions.php

**Design System Compliance Audit (Complete - January 22-23, 2026 - Deployed in v3.5.0)**
- **Purpose:** Ensure all Elementor pages follow consistent design standards for mobile responsiveness
- **Status:** ✅ Already deployed to production
- **Scope:** 10 Elementor-built pages audited and corrected
- **Standards Applied:**
  - Hero H1 mobile typography: 42px (explicitly set via responsive controls)
  - CTA title mobile typography: 42px (where CTA sections exist)
  - Icon box standardization: 48px icon, 24px/700 title, 16px description
  - Footer mobile spacing: 60px (space_between_mobile)
  - CTA padding: 20px all sides (outer section)
- **Pages Completed:**
  - Homepage (Welcome) - ID 20
  - Employers - ID 93
  - Candidates - ID 229
  - Scouts - ID 248
  - Operators Dashboard - ID 299
  - Managers Dashboard - ID 469
  - Manager Admin - ID 386
  - 403 Forbidden - ID 152
  - Register Profile - ID 365
- **Documentation:** [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) updated with implementation status
- **Benefits:**
  - ✅ Consistent mobile experience across all pages
  - ✅ Design standards documented and verified
  - ✅ Future page creation follows established patterns

**Content Updates (Complete - Deployed in v3.4.0 and v3.5.0)**
- **Status:** ✅ Already deployed to production
- Manager Admin page title/form updated: "User Request Approvals" → "User Registration Request Approvals"
- Manager Admin sub-heading updated to reflect: Users, Roles, and System Settings

**4. Manager Admin Interface Enhancements (February 1, 2026)**

**PENG-055: Undo Approve Functionality**
- **Purpose:** Allow Administrators to reverse mistaken approvals, matching Undo Reject capability
- **File Modified:** [wp-content/mu-plugins/user-requests-display.php](../wp-content/mu-plugins/user-requests-display.php)
- **Implementation:**
  - New AJAX handler: `td_undo_approve_ajax()` - mirrors undo reject logic
  - New button: "Undo Approve" (↶ icon, amber #ff9800) in Approved and All tabs
  - Status flow: `approved` → `pending` (keeps `assigned_to`, updates `assigned_by` to current user)
  - Permission: Administrator only (`manage_options` capability)
  - Audit logging via `TD_Audit_Logger`
- **Button Specifications:**
  - Class: `.td-undo-approve-btn`
  - Size: 28×28px, padding: 6px, line-height: 1
  - Color: Amber #ff9800
  - Icon: ↶ (Unicode U+21B6)
  - Tooltip: "Undo Approval"
- **Benefits:**
  - ✅ Reversibility for all actions (approve, reject, assign)
  - ✅ Maintains accountability (preserves original assignee)
  - ✅ Administrator-only safeguard prevents misuse
  - ✅ Full audit trail of undo operations

**PENG-056: Direct Action Workflow (UX Improvement)**
- **Purpose:** Streamline user actions by removing confirmation dialogs, relying on notifications only
- **Changes:**
  - Removed confirmation modals for approve/reject/undo actions
  - Actions execute immediately on button click
  - Success/failure feedback via floating notifications (`tdShowNotification()`)
  - Assignment modal retained and improved (works well for multi-step process)
- **Assignment Modal Improvements:**
  - Fixed centering on long pages using absolute positioning: `top: 50%; left: 50%; transform: translate(-50%, -50%)`
  - Added `width: 90%` for responsive mobile support
  - Modal now centers in viewport, not page document
  - Always visible regardless of scroll position
- **Error Handling Improvements:**
  - Added `.fail()` handlers to all AJAX calls for network error detection
  - Fallback notification function if main system unavailable
  - Console logging for debugging AJAX failures
  - Null-safe error messages: `response.data ? response.data.message : 'Unknown error'`
- **Benefits:**
  - ✅ Faster workflow (one click vs two)
  - ✅ More reliable (eliminates modal display issues)
  - ✅ Better error visibility with console logging
  - ✅ Graceful degradation with fallback alerts
  - ✅ Assignment modal always visible on long tables
  - ✅ Responsive across devices

**Code Quality Improvements:**
- CSS class consolidation: `.td-undo-btn` → `.td-undo-reject-btn` for clarity
- JavaScript handlers aligned with semantic class names
- Better error handling and fallback mechanisms
- Console logging for debugging production issues

**Testing Required:**
- [ ] Test Undo Approve on approved requests
- [ ] Verify Administrator-only access to undo actions
- [ ] Test notification system on production environment
- [ ] Verify AJAX error handling with network interruptions
- [ ] Test modal centering on mobile devices

*Add additional features here as development progresses.*

---

## Deployment Checklist

### Pre-Deployment
- [ ] All code changes committed to `develop` branch
- [ ] Local testing completed
- [ ] Database migrations tested locally
- [ ] `.github/releases/v3.6.0.json` created/updated with deployment steps
- [ ] **If new SQL files in `infra/shared/db/`:** Add filenames to `deploy_database.config.sql_files` array in release JSON
- [ ] If Elementor pages: Run `pwsh infra/shared/scripts/export-elementor-pages.ps1`
- [ ] If new plugins: Add to `deploy_plugins` step in release JSON

### Critical Files to Deploy (v3.6.0)

**Theme Files (wp-content/themes/blocksy-child/):**
- [ ] `functions.php` - URL-based access control implementation (v3.6.0)
- [ ] `wpum-overrides.css` - Login form styling improvements (v3.6.0)

**Page Content (restore/pages/):**
- [ ] `managers-8.html` - Functional dashboard with corrected `/managers/admin` links (v3.6.0)
- [ ] `operators-9.html` - Migrated from Elementor, 6 Quick Links (v3.6.0 NEW)
- [ ] `403-forbidden-44.html` - Migrated from Elementor, access denied page (v3.6.0 NEW)
- [ ] `scouts-76.html` - Migrated from Elementor (if updated)

**Database Migrations (infra/shared/db/):**
- [ ] `260131-1200-add-record-id-prsn-cmpy.sql` - Record ID columns
- [ ] `260131-1300-add-id-sequences-table.sql` - ID sequence tracking
- [ ] `260131-1400-add-assigned-by-column.sql` - Assigned by tracking
- [ ] `260204-0131-update-shortcodes-manager-operator-pages.sql` - Shortcode updates

**MU-Plugins (wp-content/mu-plugins/):**
- [ ] `record-id-generator.php` - PENG-016 implementation
- [ ] `td-notifications.php` - Notification system (if updated)

**Plugin Updates:**
- [ ] `talendelight-roles/talendelight-roles.php` - PENG-053 wp-admin blocking

**Plugin Removals:**
- [ ] **Remove PublishPress Capabilities** (not installed locally, check production)

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
- [ ] Manager Admin table at /managers/admin/: Name column font 13px (matches other cells)

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

**5. Test User Registration Request Approvals Functionality:**

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
# - Go to /managers/admin/
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
- [ ] Manager Admin page (/managers/admin/):
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

### Step 1: Remove PublishPress Capabilities Plugin (Production Only)

**Goal:** Remove PublishPress Capabilities plugin if installed (access control now handled by custom code)

**SSH to production:**
```bash
ssh -i ~/.ssh/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
cd public_html
```

**Check if plugin exists:**
```bash
wp plugin list | grep -i publishpress
# or
wp plugin list | grep -i capability
```

**If plugin exists, deactivate and delete:**
```bash
wp plugin deactivate publishpress-capabilities --allow-root
wp plugin delete publishpress-capabilities --allow-root
```

**Verify removal:**
```bash
wp plugin list | grep -i publishpress
# Should return nothing
```

**Time:** 2-3 minutes

---

### Step 2: Git Push (Auto-Deploy wp-content/)

```bash
git checkout main
git merge develop  # if using develop branch
git push origin main
```

**Result:** Hostinger automatically deploys `wp-content/` files including:
- `themes/blocksy-child/functions.php` (URL-based access control)
- `themes/blocksy-child/wpum-overrides.css` (login form styling)
- `mu-plugins/record-id-generator.php` (PENG-016)
- `plugins/talendelight-roles/` (PENG-053 updates if any)

**⏱️ Wait 2-3 minutes for auto-deployment to complete**

---

### Step 3: Deploy Database Migrations

**Goal:** Apply new database schema changes for Record ID system

**SSH to production:**
```bash
ssh -i ~/.ssh/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
cd public_html
```

**Apply migrations (in order):**
```bash
# 1. Add record_id columns
wp db query < infra/shared/db/260131-1200-add-record-id-prsn-cmpy.sql

# 2. Add ID sequences table
wp db query < infra/shared/db/260131-1300-add-id-sequences-table.sql

# 3. Add assigned_by column
wp db query < infra/shared/db/260131-1400-add-assigned-by-column.sql

# 4. Update shortcodes (if needed)
wp db query < infra/shared/db/260204-0131-update-shortcodes-manager-operator-pages.sql
```

**Verify migrations:**
```bash
# Check record_id columns exist
wp db query "DESCRIBE td_user_data_change_requests" | grep record_id

# Check sequences table exists
wp db query "SHOW TABLES LIKE 'td_id_sequences'"

# Check assigned_by column
wp db query "DESCRIBE td_user_data_change_requests" | grep assigned_by
```

**Time:** 5-10 minutes

---

### Step 4: Update Managers Page Content

**Goal:** Update Managers page with corrected `/managers/admin` links

**From local machine:**
```bash
# Copy updated page content to production
scp -i ~/.ssh/hostinger_deploy_key -P 65002 restore/pages/managers-8.html u909075950@45.84.205.129:~/
```

**SSH to production:**
```bash
ssh -i ~/.ssh/hostinger_deploy_key -p 65002 u909075950@45.84.205.129
cd public_html
```

**Update page content:**
```bash
# Get Managers page ID (should be 8 or similar)
MANAGERS_PAGE_ID=$(wp post list --post_type=page --name=managers --field=ID)

# Update page content
cat ~/managers-8.html | wp post update $MANAGERS_PAGE_ID --post_content=-

# Verify update
wp post get $MANAGERS_PAGE_ID --field=post_content | grep -o "/managers/admin"
# Should show: /managers/admin (not /manager-admin)
```

**Time:** 3-5 minutes

---

### Step 5: Verify Manager Admin Page Slug

**Goal:** Ensure Manager Admin page has correct parent-child URL structure

**Check current structure:**
```bash
# Get Manager Admin page details
wp post list --post_type=page --name=admin --fields=ID,post_title,post_name,post_parent --format=table

# Verify parent is Managers page (ID 8)
# Verify slug is "admin"
# URL should be: /managers/admin/
```

**If parent is incorrect:**
```bash
ADMIN_PAGE_ID=<id from above command>
MANAGERS_PAGE_ID=8  # or actual Managers page ID

wp post update $ADMIN_PAGE_ID --post_parent=$MANAGERS_PAGE_ID
```

**Verify URL:**
```bash
curl -I https://talendelight.com/managers/admin/
# Should return: HTTP/2 200
```

**Time:** 2-3 minutes

---

### Step 6: Test Access Control

**Goal:** Verify URL-based access control works correctly on production

**Test 1: Manager Access to /managers/**
1. Login as Manager user
2. Navigate to `https://talendelight.com/managers/` → ✅ Should load
3. Navigate to `https://talendelight.com/managers/admin/` → ✅ Should load
4. Navigate to `https://talendelight.com/operators/` → ✅ Should load (oversight access)

**Test 2: Operator Access**
1. Login as Operator user
2. Navigate to `https://talendelight.com/operators/` → ✅ Should load
3. Navigate to `https://talendelight.com/managers/` → ❌ Should redirect to `/403-forbidden/`

**Test 3: Candidate/Employer/Scout Access**
1. Login as Candidate → Navigate to `/candidates/` → ✅ Should load
2. Login as Candidate → Navigate to `/employers/` → ❌ Should redirect to `/403-forbidden/`
3. Repeat for Employer and Scout roles

**Test 4: Unauthenticated Redirect**
1. Logout completely
2. Navigate to `https://talendelight.com/managers/` → ❌ Should redirect to `/log-in/?redirect_to=/managers/`
3. Login → ✅ Should redirect back to `/managers/`

**Time:** 10-15 minutes

---

### Step 7: Test Login Form Styling

**Goal:** Verify login form has improved styling (narrower, centered button)

**Visual Check:**
1. Navigate to: `https://talendelight.com/log-in/`
2. Verify form width is narrower (~400px)
3. Verify login button is centered (not full-width)
4. Verify button has minimum 140px width
5. Check responsive behavior on mobile

**Time:** 2-3 minutes

---

### Step 8: Test Record ID Generation

**Goal:** Verify PENG-016 record ID generation works on production

**Test Scenario:**
1. Create a test user registration request
2. Verify `request_id` is auto-generated (format: `USRQ-YYMMDD-N`)
3. Approve request as Manager
4. Verify `record_id` is auto-generated (format: `PRSN-YYMMDD-N` or `CMPY-YYMMDD-N`)

**Check sequence tracking:**
```bash
ssh production
wp db query "SELECT * FROM td_id_sequences ORDER BY last_updated DESC LIMIT 5"
```

**Time:** 5-10 minutes

---

### Step 9: Verify Manager Admin Page Links

**Goal:** Ensure all internal links use correct `/managers/admin/` format

**Pages to Check:**
1. **Managers Dashboard** (`/managers/`):
   - Hero "Go to Dashboard" button → Should link to `/managers/admin`
   - CTA "Go to Dashboard" button → Should link to `/managers/admin`

2. **Manager Admin** (`/managers/admin/`):
   - Should load without errors
   - Tabbed interface should work
   - User registration requests table should display

**Time:** 3-5 minutes

---

### Step 10: Post-Deployment Verification

**Comprehensive Checks:**

**✅ Plugin Status:**
```bash
wp plugin list | grep -E "(talendelight-roles|publishpress)"
# Should show: talendelight-roles active
# Should NOT show: publishpress-capabilities
```

**✅ Database Schema:**
```bash
wp db query "DESCRIBE td_user_data_change_requests" | grep -E "(request_id|record_id|assigned_by)"
# Should show all three columns
```

**✅ Page URLs:**
- `/managers/` → 200 OK
- `/managers/admin/` → 200 OK
- `/operators/` → 200 OK
- `/candidates/` → 200 OK
- `/employers/` → 200 OK
- `/scouts/` → 200 OK

**✅ Access Control:**
- Manager can access `/managers/*` ✓
- Manager can access `/operators/*` ✓ (oversight)
- Operator CANNOT access `/managers/*` ✓
- Unauthenticated users redirect to `/log-in/` ✓

**✅ Theme Files:**
```bash
# Verify URL-based access control code exists
grep -n "strpos(\$current_url" wp-content/themes/blocksy-child/functions.php

# Should show URL pattern matching code
```

**Time:** 5-10 minutes

**Total Deployment Time:** ~45-60 minutes

---

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