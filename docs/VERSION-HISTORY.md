# WordPress Version History

**Purpose:** Track all production releases with semantic versioning, descriptions, and deployment dates.

**Versioning Convention:** `MAJOR.MINOR.PATCH`
- **MAJOR (x.0.0):** Breaking changes, major architectural shifts, significant feature overhauls
- **MINOR (x.x.0):** New features, backward-compatible additions, new pages/functionality
- **PATCH (x.x.x):** Bug fixes, small corrections, performance optimizations without new features

---

## Version 3.x.x - Custom Roles & RBAC Era

**Theme:** Authentication, authorization, role-based access control, landing pages for all roles

**Timeline Impact:** +10 days delay due to data loss on February 5, 2026 (Podman volume corruption)
- Original v3.6.0 MVP target: April 5, 2026
- Adjusted v3.6.0 MVP target: April 15, 2026

---

### v3.0.0 - Custom Roles & RBAC Foundation

**Deployed:** January 9, 2026 at 00:58  
**Status:** ✅ Production  
**Branch:** develop → main

**Description:** Major architectural change introducing custom WordPress roles with role-based access control, login redirects, and access restrictions for non-allowed roles.

**Major Features:**
- Custom WordPress roles: Employer, Candidate, Scout, Operator, Manager
- TalenDelight Custom Roles plugin (v1.0.0)
- Role-based login redirect (users redirect to role-specific pages after login)
- 403 Forbidden page with business-friendly messaging
- Access control: Block non-TalenDelight roles from accessing platform
- Employers landing page (/employers/)
- Performance optimizations (OPcache enabled, debug mode configured)
- Menu structure with Login/Logout Menu plugin
- Test users created for all roles

**Technical Changes:**
- Plugin: `talendelight-roles/` with role definitions and RBAC logic
- Page: `/403-forbidden/` with error handling
- Page: `/employers/` with 5 sections (Hero, How It Works, Specialties, Why TalenDelight, Final CTA)
- Redirect hooks: `login_redirect`, `wpum_login_redirect`, `wpum_after_login`
- Template redirect: Catch `/account/` page loads and redirect based on role

**Git Commit:**
```
Implement TalenDelight custom roles (v1.0.0), role-based login redirect, 403 forbidden page, performance optimizations (OPcache), menu structure with Login/Logout plugin
```

---

### v3.1.0 - Candidate & Scout Landing Pages

**Deployed:** January 11, 2026  
**Status:** ✅ Production  
**Branch:** develop → main

**Description:** Complete role landing pages set by adding Candidates and Scout pages, enabling all user types to access role-specific information and CTAs.

**Minor Features:**
- Candidates landing page (/candidates/)
  - Hero: "Launch Your Career with Confidence"
  - How It Works (3 steps for candidates)
  - What We Look For (4 qualities)
  - Why Choose TalenDelight (4 benefits - candidate-focused)
  - Final CTA: "Land Your Next Great Role" → "Share Your Profile" button
  - Button links to `/candidates/identify/` (form to be created separately)
- Scout landing page (/scouts/) - planned
  - Explain scout role (talent referrers)
  - Commission structure and benefits
  - Scout submission process
  - CTA: "Refer a Candidate"
- Operator/Manager landing pages (/operators/, /managers/) - planned
  - Internal role explanations
  - Links to admin dashboard
  - Or simple redirect to `/wp-admin/`

**Bug Fixes:**
- Hostinger Git auto-deployment investigation (if resolved)

**Completed:**
- ✅ Candidates page published (January 10, 2026)
- ✅ Role-based redirect tested and working for candidates
- ✅ Content changed from employer-focused to candidate-focused
- ✅ Final CTA updated with appropriate messaging
- ✅ Scout landing page published (January 11, 2026)
- ✅ Consent/Legal section design pattern documented
- ✅ Compliance footer sections added to ALL pages (January 11, 2026):
  - Scouts, Employers, Candidates, Homepage, Access Restricted
  - 4 trust badges: GDPR, Secure & Encrypted, Equal Opportunity, Serving Markets
  - Grey background (#ECECEC), inline layout
- ✅ Login page custom CSS styling (January 11, 2026)
  - Button matches Elementor page styles
  - CSS file: config/custom-css/login.css
- ✅ Access Restricted page footer compliance section (January 11, 2026)

**Git Commit:**
```
Add Candidates and Scout landing pages (v3.1.0), compliance footer sections, login page styling, complete role-based navigation for external roles
```

---

### v3.2.0 - Operators Dashboard (Phase 1)

**Deployed:** January 14, 2026 at 01:00  
**Status:** ✅ Production  
**Branch:** develop → main

**Description:** Add Operators Dashboard landing page with role-based access control, enabling operators to access centralized navigation for candidate/employer/scout management.

**Minor Features:**
- Operators landing page (/operators/)
  - Hero: "Operators Dashboard" with subtitle and "View Reports" button
  - Needs Action section (placeholder for dynamic content from external app)
  - 5 navigation tiles: Needs Action (info), Candidates, Employers, Scouts, Reports
  - CTA: "Need Help?" with documentation link
  - Footer section with compliance badges
  - Design: Navy hero, alternating white/grey sections, Blocksy theme colors
- Role-based access control enhancements:
  - Page-specific restrictions for `/operators/` (Operators, Managers, Admins only)
  - Future-ready restrictions for `/managers/` page
  - 403 redirects for unauthorized users
  - Login redirect: Operator users → `/operators/`
- Test user: `operator_test` created and verified

**Technical Changes:**
- Plugin: `talendelight-roles` v1.0.0 updated with page-specific access functions
- Function: `talendelight_restrict_operators_page()` - page access control
- Function: `talendelight_restrict_managers_page()` - future-ready access control
- Page: `/operators/` (ID: 299, template: Elementor Canvas)
- Documentation: OPERATOR-PAGE-BUILD-GUIDE.md, SESSION-SUMMARY-JAN-13-14.md

**Future Phases (Deferred to v3.3.0+):**
- Phase 2: Dynamic "Needs Action" content (external app/API integration)
- Phase 3: Management pages (Candidates, Employers, Scouts, Reports)
- Phase 4: Detail pages for candidates/employers

**Git Commit:**
```
Add Operators Dashboard with role-based access control (v3.2.0 Phase 1)
```

---

### v3.3.0 - User Registration Flow

**Deployed:** January 18, 2026 at 20:00  
**Status:** ✅ Production  
**Branch:** develop → main

**Description:** Complete user registration flow with custom role selection page, Forminator form integration, and data change request tracking system.

**Minor Features:**
- Select Role page (/select-role/)
  - Custom PHP template: `page-role-selection.php`
  - Role cards: Candidate, Employer, Scout (self-registration only)
  - Manager and Operator accounts created by admin separately
  - Next button routes to /register-profile/?role={selected_role}
  - Back button returns to /welcome/
  - Login and password reset links
- Register Profile page (/register-profile/)
  - Forminator form integration (Form ID: 80 - "Person Registration Form")
  - Elementor page with form shortcode widget
  - Submission redirects to /welcome/ page
  - Form appears correctly after fixing shortcode ID mismatch
- Blocksy Child theme:
  - Theme: `blocksy-child` activated in production
  - Functions: Login redirects (/register → /select-role/), logout redirects
  - Template: `page-role-selection.php` for custom role selection page
  - Template: `logout-redirect.php` for logout handling
  - Stylesheet: Basic child theme styles
- Database changes:
  - Table: `wp_td_user_data_change_requests` (22 columns)
  - Tracks user registration/profile change requests
  - Fields: user_id, request_type, first_name, email, phone, profile_method, linkedin_url, cv_file_path, citizenship_id_file, status, etc.

**Bug Fixes:**
- Forminator plugin deployment: Plugin wasn't deployed initially, manually uploaded and activated
- Form ID mismatch: Changed from ID 364 (local) to ID 80 (production) in Elementor data
- WordPress root path: Corrected from ~/public_html to ~/domains/talendelight.com/public_html
- Shortcode display issue: Fixed by updating both Gutenberg block module_id and shortcode id

**Lessons Learned:**
- Hostinger Git deployment deploys to ~/public_html/wp-content/, but WordPress root is at ~/domains/talendelight.com/public_html/
- New plugins must be explicitly included in deployment workflow (not auto-deployed by Git integration)
- Forminator form IDs differ between local and production (requires manual ID mapping)
- GitHub Actions deploy.yml enhanced with plugin deployment support

**Git Commit:**
```
Add User Registration flow with role selection, Forminator integration, blocksy-child theme, database tracking table (v3.3.0)
```

---

### v3.4.0 - Manager Admin & User Registration Request Approvals

**Deployed:** January 20, 2026  
**Status:** ✅ Production  
**Branch:** develop → main

**Description:** Complete user request approval workflow with Manager Admin page, Forminator integration, and database schema for approval tracking with audit trail.

**Minor Features:**
- Manager Admin page (/manager-admin/)
  - Tabbed interface: New, Pending, Approved, Rejected, All
  - Real-time database integration with td_user_data_change_requests table
  - Action buttons: Approve (✓), Reject (✗), Undo Rejection (↶)
  - Role-based display (Candidate, Employer, Scout, Operator, Manager)
  - Profile method support (LinkedIn + CV combined)
  - Responsive table with sorting and filtering
  - Access control: Manager and Admin roles only
- Forminator integration:
  - MU-plugin: `forminator-custom-table.php`
  - Hook: `forminator_form_after_save_entry` for Form ID 364
  - Auto-sync: Registration form submissions → td_user_data_change_requests table
  - Uses Forminator_API::get_entry() for reliable data extraction
  - Field mapping: Name, email, phone, profile method, uploads, consent
- Generic audit logging system:
  - MU-plugin: `audit-logger.php`
  - Tracks all user approval actions for compliance
  - Table: td_audit_log (user_id, action, entity_type, entity_id, details, timestamp)
- Conditional menu display:
  - Login menu item hidden when user logged in
  - Logout menu item hidden when user logged out
  - Implemented in blocksy-child theme functions.php

**Technical Changes:**
- Database tables:
  - `td_user_data_change_requests`: 26 columns including approver_id, comments
  - `td_audit_log`: Generic audit trail for compliance tracking
- MU-Plugins:
  - `user-requests-display.php`: Shortcode [user_requests_table status="new|pending|approved|rejected|all"]
  - `audit-logger.php`: Helper function td_log_audit_action()
  - `forminator-custom-table.php`: Forminator form sync to custom table
- Child theme enhancements:
  - Conditional menu item display (wp_nav_menu_objects filter)
  - Logout redirect to home page
  - Form submission redirect with behavior='redirect'
- Utility scripts:
  - `cleanup-forminator-entries.php`: Clean redundant Forminator data (dry-run by default)
  - `diagnose-forminator.php`: Diagnostic tool for data flow debugging

**Database Migrations:**
- `260117-impl-add-td_user_data_change_requests.sql`: User requests table creation
- `260119-1400-add-role-and-audit-log.sql`: Role column, profile method, audit log
- `260120-1945-alter-add-approver-comments.sql`: Approver tracking and comments

**Bug Fixes:**
- Fixed Forminator hook issue: Changed from forminator_custom_form_after_save_entry to forminator_form_after_save_entry
- Fixed meta_data extraction: Direct array access instead of loop iteration
- Fixed file path extraction from nested upload arrays

**Lessons Learned:**
- Forminator module_slug is 'form' not 'custom_form' for custom forms
- Meta data structure is associative array not numeric array
- Entry ID not always in response - fetch from database as fallback
- Upload fields contain nested arrays ['file']['file_path']

**Git Commit:**
```
Add Manager Admin page with user registration request approvals, Forminator integration, audit logging system (v3.4.0)
```

---

### v3.5.0 - Environment Config Automation

**Deployed:** February 2, 2026  
**Status:** ✅ Production  
**Branch:** develop → main

**Description:** Automate environment-specific configuration deployment by relocating env-config.php to mu-plugins for automatic Git-based deployment.

**Minor Features:**
- Environment configuration automation:
  - Move `config/env-config.php` → `wp-content/mu-plugins/td-env-config.php`
  - Auto-deploys via Git (no manual uploads needed)
  - Update `wp-config.php` loader path
  - Documentation updated

**Benefits:**
- ✅ No manual file uploads for config changes
- ✅ Version controlled and auto-deployed
- ✅ Production and local use identical file
- ✅ Form IDs, page IDs auto-detect environment

**Technical Changes:**
- File relocation: `config/env-config.php` → `wp-content/mu-plugins/td-env-config.php`
- Update: `wp-config.php` loader path
- Documentation: Update ENVIRONMENT-CONFIG.md with new location

**Git Commit:**
```
Automate environment config deployment via mu-plugins (v3.5.0)
```

---

### v3.5.1 - Welcome Page Gutenberg Migration

**Deployed:** TBD  
**Status:** 🚧 Ready for Deployment  
**Branch:** develop → main

**Description:** Migrate Welcome page from Elementor to Gutenberg blocks with improved design system application and Font Awesome icon integration.

**Patch Features:**
- Welcome page Gutenberg migration:
  - Converted from Elementor to native Gutenberg blocks
  - Deleted Elementor meta fields (_elementor_edit_mode, _elementor_data, _elementor_version)
  - Preserved all original content and sections
  - Applied design system styles consistently
- Font Awesome integration:
  - Installed Better Font Awesome plugin (v2.0.4) for local icon hosting
  - Resolved CDN loading issues with self-signed SSL certificates
  - 4 specialty card icons: cloud, globe, server, question mark
  - Icons in single HTML blocks with titles for precise spacing control
- Design refinements:
  - Pill-shaped buttons (50px border-radius with !important overrides)
  - Card spacing: 32px between cards, 16px between rows, 48px internal padding
  - Equal-height cards via CSS flexbox
  - Typography: 24px navy titles, 14px #666666 body text
  - Icon-title spacing: 8px controlled spacing
  - Section heading spacing: 48px margin-bottom

**Benefits:**
- ✅ Reduced page dependencies (1 less plugin used - Elementor on this page)
- ✅ Faster page load (native blocks vs Elementor overhead)
- ✅ Better mobile responsiveness (Gutenberg native)
- ✅ Improved maintainability (standard WordPress editor)
- ✅ Font Awesome icons work with self-signed SSL (local hosting)

**Technical Changes:**
- Plugin: Better Font Awesome (v2.0.4) installed and activated
- Theme: blocksy-child/functions.php - removed CDN Font Awesome enqueue
- Page: Welcome (ID 6) - migrated to Gutenberg blocks
- Backup: restore/pages/welcome-6-gutenberg.html + welcome-6-gutenberg.json

**Bug Fixes:**
- Fixed Font Awesome icon display issue (rectangles showing instead of icons)
- Fixed icon-title spacing (combined into single HTML blocks)
- Fixed Gutenberg inline style overrides (used !important in CSS)

**Lessons Learned:**
- Self-signed SSL certificates block external CDN font downloads
- Use WordPress plugins for local web font hosting
- Gutenberg blocks add uncontrollable spacing between separate blocks
- Combine related elements in single wp:html blocks for precise control
- CSS variables don't always work in inline style attributes
- Use !important to override Gutenberg inline styles

**Migration Status:**
- ✅ 1 of 23 pages migrated (Welcome page)
- ⏸️ 22 pages remaining on Elementor

**Git Commit:**
```
Migrate Welcome page to Gutenberg, install Better Font Awesome plugin, refine spacing and design (v3.5.1)
```

**Deployment Notes:**
- Plugin installation required: Better Font Awesome (v2.0.4) must be uploaded to wp-content/plugins/
- Use: `wp plugin install better-font-awesome --activate --allow-root`
- Or manually upload via hPanel File Manager

---

### v3.0.1 - Hotfixes (If Needed)

**Status:** Not Created  
**Use Case:** Critical bug fixes for v3.0.0 without adding new features

**Reserved for:**
- Production-breaking bugs
- Security patches
- Critical performance issues
- Deployment fixes

---

## Version 2.x.x - Navigation & Authentication Era

**Theme:** Public marketing site, navigation restructure, WooCommerce removal, authentication setup

---

### v2.0.0 - Navigation Restructure & Authentication Plugins

**Deployed:** ~January 1-2, 2026  
**Status:** ✅ Production (superseded by v3.0.0)

**Description:** Major navigation overhaul, removed WooCommerce e-commerce functionality, added authentication plugins (WP User Manager, Login/Logout Menu).

**Major Features:**
- Removed WooCommerce entirely (plugins + pages)
- Added Login/Logout Menu plugin (v1.5.2)
- Added WP User Manager plugin (v2.9.13)
- Navigation restructure: Welcome, About us, My account, Help, Login/Logout
- Help page created
- Hidden e-commerce pages (Shop, Cart, Checkout)
- Local HTTPS setup with Caddy reverse proxy

**Technical Changes:**
- Plugin cleanup: Removed WooCommerce, Hello Dolly
- Config: `wp-config.php` debug settings
- Local: Caddy reverse proxy with SSL certificates
- Database: Updated URLs to https://wp.local/

---

## Version 1.x.x - Homepage Launch Era

**Theme:** Initial public website launch

---

### v1.0.0 - Homepage Launch

**Deployed:** December 31, 2025  
**Status:** ✅ Production (superseded by v2.0.0)

**Description:** Initial homepage launch with public marketing website.

**Major Features:**
- Home page with value proposition
- Hero section with dual CTAs
- Specialties grid (Java, Fullstack, DevOps, Cloud)
- How It Works section (4 steps)
- Final CTA section
- Blocksy theme configured
- Elementor page builder

---

## Future Major Versions (Planning)

### v4.0.0 - Forms & Data Capture (Planned)

**Target:** Q1 2026  
**Theme:** Candidate submission forms, employer request forms, data persistence

**Planned Features:**
- Candidate submission form (`/candidates/identify/`)
- Employer request form integration
- CV upload functionality
- Custom Post Type: `td_employer_request`
- Custom Post Type: `td_candidate_submission`
- Email notifications
- CandidateID generation (`TD-YYYY-NNNN`)

---

### v5.0.0 - Portal Dashboards (Planned)

**Target:** Q2 2026  
**Theme:** User portals with dashboards, submission history, status tracking

**Planned Features:**
- Employer portal: "My Requests" dashboard
- Candidate portal: Submission status tracking
- Scout portal: Referral tracking and commission
- Operator dashboard: Internal submission management

---

## Version Query Reference

**To determine next version:**
1. Read this file (`VERSION-HISTORY.md`)
2. Find current MAJOR version group (currently v3.x.x)
3. Find highest deployed version in that group
4. Apply logic:
   - **New features/pages:** Increment MINOR (x.1.0 → x.2.0)
   - **Bug fixes only:** Increment PATCH (x.1.0 → x.1.1)
   - **Breaking changes:** Increment MAJOR (3.x.x → 4.0.0)

**Current Production Version:** v3.2.0  
**Next Planned Version:** v3.3.0 (Manager Dashboard or Operators Phase 2)

---

## Notes for AI Assistant

When asked "What is the next production release version?":
1. Read this file first
2. Identify current production version
3. Check what's in progress (✅ completed vs 🔄 in progress vs ❌ not started)
4. Determine if changes are MAJOR/MINOR/PATCH
5. Suggest appropriate version number
6. Ask user if confused about scope of changes

When updating this file:
1. Mark versions as ✅ Production when deployed
2. Update deployment dates
3. Add actual Git commit messages
4. Move planned items to new version section if not deployed
5. Keep version groups organized (v3.x.x together, v4.x.x together)
