# Role Capabilities Matrix

**Version:** 1.0  
**Last Updated:** January 24, 2026  
**Task:** BMSL-001 - Define role capabilities & boundaries  
**Implementation:** [wp-content/plugins/talendelight-roles/talendelight-roles.php](../wp-content/plugins/talendelight-roles/talendelight-roles.php)

---

## Overview

TalenDelight uses a role-based access control (RBAC) system with 5 custom roles plus standard WordPress administrator. Each role has specific permissions aligned with business requirements.

**Role Categories:**
- **External Roles:** Employer, Candidate, Scout (public users with limited access)
- **Internal Roles:** Operator, Manager (staff with operational/oversight access)
- **System Role:** Administrator (technical/configuration access)

---

## External Roles (Public Users)

### 1. Employer (`td_employer`)

**Purpose:** External hiring companies requesting candidate matches

**CAN:**
- ✅ Register via public form with company details
- ✅ Submit candidate requests (job requirements, role details)
- ✅ View own candidate requests only
- ✅ Track status of own requests (pending, matched, fulfilled)
- ✅ View matched candidate profiles (after Operator/Manager approval)
- ✅ Approve/reject shortlisted candidates (Phase 2)
- ✅ Update own company profile
- ✅ Access `/employers/` landing page after login

**CANNOT:**
- ❌ View other employers' data or requests
- ❌ Access internal dashboards or reports
- ❌ See unmatched candidates in database
- ❌ View Scout submissions or Operator activities
- ❌ Approve own registration (requires Operator/Manager approval)
- ❌ Access candidate CVs without consent
- ❌ Export system data
- ❌ View Operator/Manager pages

**WordPress Capabilities:**
- `read` - Access WordPress frontend
- `td_view_own_requests` - View own candidate requests
- `td_request_candidates` - Submit candidate requests
- `td_view_request_status` - Check status of submissions

---

### 2. Candidate (`td_candidate`)

**Purpose:** External job seekers submitting profiles for placement

**CAN:**
- ✅ Register via public form with consent checkbox
- ✅ View own profile and submission status
- ✅ Update own profile information (per BMSL-002 policy)
- ✅ Upload/update CV file
- ✅ View application status (pending, matched, fulfilled)
- ✅ Withdraw consent or delete profile (via DSAR process)
- ✅ Access `/candidates/` landing page after login (Phase 1)

**CANNOT:**
- ❌ View other candidates' profiles or data
- ❌ Access employer requests or company details
- ❌ See Scout submissions or referral sources
- ❌ View internal dashboards or Operator activities
- ❌ Approve own registration (requires Operator/Manager approval)
- ❌ Export system data
- ❌ Submit candidates on behalf of others

**WordPress Capabilities:**
- `read` - Access WordPress frontend
- `td_view_own_profile` - View own profile/submission
- `td_update_own_profile` - Edit own information
- `td_upload_cv` - Upload/update CV file

---

### 3. Scout (`td_scout`)

**Purpose:** External talent referrers submitting candidates on behalf with consent

**CAN:**
- ✅ Register via public form (approval by Manager only)
- ✅ Submit candidates on behalf with consent attestation
- ✅ Upload CV files for candidates
- ✅ View own submissions only
- ✅ Track status of submitted candidates (pending, matched, fulfilled)
- ✅ Update own Scout profile
- ✅ Access `/scouts/` landing page after login (Phase 2)

**CANNOT:**
- ❌ View candidates submitted by other Scouts
- ❌ Access employer requests or company details
- ❌ View candidate profiles outside own submissions
- ❌ Approve own registration (requires Manager approval only)
- ❌ Access internal dashboards or reports
- ❌ View Operator/Manager activities
- ❌ Export system data
- ❌ Submit candidates without valid consent

**WordPress Capabilities:**
- `read` - Access WordPress frontend
- `td_submit_candidate` - Submit candidates on behalf
- `td_view_own_submissions` - View own submissions
- `td_upload_candidate_cv` - Upload CV for candidates

**Special Notes:**
- Scout role requires **Manager approval only** (not Operator)
- Must capture consent attestation: candidate name, email, timestamp, IP, consent version
- Consent must include: data processing, CV submission by Scout, contact by TalenDelight

---

## Internal Roles (Staff)

### 4. Operator (`td_operator`)

**Purpose:** Internal operations team managing day-to-day recruitment workflows

**CAN:**
- ✅ View all submissions (candidates, employers, scouts)
- ✅ View candidate data (read-only for submitted data)
- ✅ View employer data (read-only for submitted data)
- ✅ Assign registration requests to self or other Operators/Managers
- ✅ Reassign work to other Operators/Managers
- ✅ Approve **public user** registrations (Candidate, Employer only)
- ✅ Update candidate workflow status (screening, matched, fulfilled)
- ✅ Export data and generate reports
- ✅ Edit WordPress posts and pages (for operational content)
- ✅ Access `/operators/` landing page after login (Phase 1)
- ✅ View all CVs and submissions (with consent)
- ✅ Match candidates to employer requests
- ✅ Send email notifications to candidates/employers

**CANNOT:**
- ❌ Edit candidate submitted data (name, email, CV, LinkedIn) - user must resubmit
- ❌ Edit employer submitted data (company name, requests) - user must resubmit
- ❌ Approve **internal user** registrations (Scout, Operator, Manager) - Manager only
- ❌ Approve Operator registrations (Manager only)
- ❌ View analytics dashboard (Manager only)
- ❌ View strategic metrics and KPIs (Manager only)
- ❌ Manage other Operators' activities
- ❌ Access WordPress admin panel (`/wp-admin/`)
- ❌ Edit WordPress core settings, plugins, themes
- ❌ Delete system data (requires Manager approval)
- ❌ Override GDPR retention policies

**WordPress Capabilities:**
- `read` - Access WordPress frontend
- `edit_posts` - Edit posts (for operational content)
- `edit_pages` - Edit pages (for operational content)
- `td_manage_submissions` - View all submissions (read-only for user data)
- `td_view_candidates` - View candidate data (read-only)
- `td_view_employers` - View employer data (read-only)
- `td_view_all_data` - Access all system data (read-only for user submissions)
- `td_export_data` - Export CSV/reports
- `td_update_candidate_status` - Change workflow status only (not user data) - Operator + Manager

**Special Notes:**
- Operators can approve Candidate and Employer registrations only (public users)
- Manager approval required for Scout, Operator, and Manager registrations
- Operators cannot approve other Operator accounts (Manager only)
- Operators can assign/reassign tasks to themselves, other Operators, or Managers
- **Read-only access** to submitted candidate/employer data - users must resubmit to update
- Can update workflow status (pending, screening, matched, fulfilled) but not user data

---

### 5. Manager (`td_manager`)

**Purpose:** Internal management and oversight with analytics access

**CAN:**
- ✅ View all submissions (candidates, employers, scouts) - read-only
- ✅ Assign registration requests to self or other Operators/Managers
- ✅ Reassign work to other Operators/Managers
- ✅ Approve **ALL** registration types:
  - ✅ Candidate (Operator or Manager)
  - ✅ Employer (Operator or Manager)
  - ✅ Scout - **Manager only**
  - ✅ Operator - **Manager only**
  - ✅ Manager - **Manager only** (bootstrap: Admin creates first Manager)
- ✅ View analytics dashboard and metrics
- ✅ Generate strategic reports (conversion rates, pipeline metrics)
- ✅ View operational KPIs (PMAS-001)
- ✅ Manage Operator activities (oversight, review)
- ✅ Export all system data (within GDPR compliance)
- ✅ Access `/managers/` landing page after login (Phase 1)
- ✅ Approve data deletion requests (DSAR)
- ✅ Override Operator decisions (with audit trail)

**CANNOT:**
- ❌ Edit candidate submitted data (name, email, CV, LinkedIn) - user must resubmit
- ❌ Edit employer submitted data (company name, requests) - user must resubmit
- ❌ Edit WordPress core settings (Administrator only)
- ❌ Manage plugins and themes (Administrator only)
- ❌ Access plugin configuration (Administrator only)
- ❌ Delete Operator accounts (Administrator only)
- ❌ Override GDPR retention policies (Lawyer defines, Manager executes)

**WordPress Capabilities:**
- `read` - Access WordPress frontend
- `edit_posts` - Edit posts
- `edit_pages` - Edit pages
- `td_view_all_data` - Access all system data (read-only for user submissions)
- `td_update_candidate_status` - Change workflow status only (not user data)
- `td_view_analytics` - View analytics/metrics
- `td_view_reports` - Generate reports
- `td_manage_operators` - Oversee operator activities
- `td_export_data` - Export CSV/reports
- `td_approve_all_registrations` - Approve all registration types

**Special Notes:**
- Manager is the **only role** that can approve Scout, Operator, and Manager registrations
- Operators can only approve Candidate and Employer registrations (public users)
- Bootstrap rule: Administrator creates first Manager, then Manager-only thereafter
- **Submitted profile data (read-only):** Cannot edit candidate/employer name, email, CV, LinkedIn, company details - user must resubmit
- **Workflow fields (editable):** Can update status, assignment, internal notes/tags, next action date, match decisions (operational oversight)
- Manager has same workflow editing capability as Operator (uses td_update_candidate_status)
- Manager can view analytics and strategic reports (Operators cannot)
- Manager approves DSAR (data subject access/deletion requests)
- **Post-MVP:** Manager can override Operator decisions on registration requests (see WORDPRESS-BACKLOG.md)

---

## System Role

### 6. Administrator (`administrator`)

**Purpose:** WordPress system administration and technical configuration

**CAN:**
- ✅ All WordPress administrative capabilities
- ✅ Install/configure plugins and themes
- ✅ Manage user accounts (all roles)
- ✅ Edit WordPress core settings
- ✅ Access `/wp-admin/` panel
- ✅ Configure hosting and deployment
- ✅ Manage database and backups
- ✅ Configure email and SMTP settings
- ✅ Technically can approve registrations (has all capabilities)

**CANNOT (Policy):**
- ❌ Approve business-level registrations (policy: use Manager role for operational work)
- ❌ Override GDPR policies (Lawyer defines, Manager executes)

**Special Notes:**
- Used only for technical/system administration
- For operational work, Administrator should log in as Manager or Operator
- Administrator has technical capability for all actions but policy restricts operational use
- Separate technical access from business operations

---

## Registration Approval Logic

### Public Users (Operator OR Manager can approve):
- **Candidate** - Job seeker registration
- **Employer** - Hiring company registration

### Internal Users (Manager ONLY can approve):
- **Scout** - External partner/referrer registration (Manager only)
- **Operator** - Internal operations staff registration (Manager only)
- **Manager** - Internal management registration (Manager only; bootstrap: Admin creates first Manager, then Manager-only thereafter)

**Rationale:**
- Public users (Candidate, Employer): Lower risk, high volume → Operator efficiency
- Internal users (Scout, Operator, Manager): Higher trust, system access → Manager oversight only
- Operators cannot approve other Operators (prevents privilege escalation)

**Note:** "Employee" is a generic term for Operator or Manager, not a separate role.

---

## Access Control Enforcement

### Frontend Access (Non-Admin Pages)

**Allowed Roles:** `td_employer`, `td_candidate`, `td_scout`, `td_operator`, `td_manager`, `administrator`

**Blocked Roles:** Any other WordPress role (e.g., Subscriber, Contributor, Editor without custom role)

**Enforcement:** `template_redirect` hook checks user roles before rendering pages

**Response:**
1. If custom 403 page exists → redirect to `/403-forbidden/`
2. Otherwise → Display styled error message with home/logout links

### Login Redirects

After successful login, users are automatically redirected to role-specific landing pages:

| Role | Redirect URL | Status |
|------|-------------|--------|
| Administrator | `/wp-admin/` | ✅ Active |
| Manager | `/managers/` | ✅ Active (v3.3.0) |
| Operator | `/operators/` | ✅ Active (v3.2.0) |
| Employer | `/employers/` | ✅ Active (v3.1.0) |
| Candidate | `/candidates/` | 🔄 Phase 1 (v3.6.0) |
| Scout | `/scouts/` | 🔄 Phase 2 (v3.6.0) |

---

## Data Access Boundaries

### Own Data Only (Isolated Access):
- **Employer:** Can only view/edit own company profile and requests
- **Candidate:** Can only view/edit own profile and CV
- **Scout:** Can only view own submissions

### All Data Access (System-Wide):
- **Operator:** 
  - **Submitted profile data (read-only):** Candidate name, email, CV, LinkedIn, Employer company name, requests
  - **Workflow fields (editable):** Status, assignment, internal notes, tags, screening outcomes, match decisions
- **Manager:** 
  - **Submitted profile data (read-only):** Candidate name, email, CV, LinkedIn, Employer company name, requests (same as Operator)
  - **Workflow fields (editable):** Status, assignment, internal notes/tags, next action date, match decisions (operational oversight)
- **Administrator:** Full system access (technical use only)

### Special Cases:
- **CV Access:** Only with valid consent + GDPR compliance
- **Consent Logs:** Operator/Manager can view for audit purposes
- **Analytics:** Manager only (conversion rates, KPIs, pipeline metrics)
- **DSAR Requests:** Manager approves, Operator executes

---

## Permission Matrix (Quick Reference)

| Permission | Employer | Candidate | Scout | Operator | Manager | Admin |
|------------|----------|-----------|-------|----------|---------|-------|
| **View Own Data** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Edit Own Data** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **View All Candidates** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **View All Employers** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **View All Submissions** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Approve Candidate/Employer** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Approve Scout/Operator/Manager** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **View Analytics** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Export Data** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Manage WordPress** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## Canonical Capability Names (v1 - MVP)

**Purpose:** Single source of truth for WordPress custom capabilities to prevent implementation drift across files.

**All custom capabilities use `td_` prefix:**

### Data Access Capabilities
- `td_view_own_requests` - View own candidate requests (Employer)
- `td_view_own_profile` - View own profile/submission (Candidate)
- `td_view_own_submissions` - View own submissions (Scout)
- `td_view_all_data` - Access all system data (Operator, Manager)
- `td_view_candidates` - View candidate data (Operator)
- `td_view_employers` - View employer data (Operator)

### Action Capabilities
- `td_request_candidates` - Submit candidate requests (Employer)
- `td_submit_candidate` - Submit candidates on behalf (Scout)
- `td_upload_cv` - Upload/update CV file (Candidate)
- `td_upload_candidate_cv` - Upload CV for candidates (Scout)
- `td_update_own_profile` - Edit own information (Candidate)
- `td_view_request_status` - Check submission status (Employer)

### Management Capabilities
- `td_manage_submissions` - View all submissions, read-only for user data (Operator)
- `td_manage_candidates` - Manage candidate workflow (Operator)
- `td_manage_employers` - Manage employer workflow (Operator)
- `td_manage_operators` - Oversee operator activities (Manager)

### Workflow & Status Capabilities
- `td_update_candidate_status` - Change workflow status only, not user data (Operator, Manager)

### Reports & Analytics Capabilities
- `td_view_analytics` - View analytics/metrics (Manager)
- `td_view_reports` - Generate reports (Manager)
- `td_export_data` - Export CSV/reports (Operator, Manager)

### Approval Capabilities
- `td_approve_all_registrations` - Approve all registration types (Manager)

**Standard WordPress Capabilities Used:**
- `read` - Access WordPress frontend (all custom roles)
- `edit_posts` - Edit posts for operational content (Operator, Manager)
- `edit_pages` - Edit pages for operational content (Operator, Manager)

---

## Implementation Notes

### Custom Capabilities Reference

**⚠️ IMPORTANT:** Use canonical capability names from section above. Do not define alternate capability schemas in other files.

### Access Control Rules

1. **Frontend Block:** Logged-in users without custom roles → 403 Forbidden
2. **Admin Area:** `/wp-admin/` accessible to **Administrator role only** (PENG-053: Block all custom roles from WordPress admin)
3. **AJAX/REST:** Capability checks enforced on all endpoints (PENG-054: No endpoint relies on `is_user_logged_in()` alone)
4. **Public Pages:** Always accessible (logged-out users)

**Implementation Status:**
- ✅ Frontend block: Active (v1.0.0 - talendelight-roles plugin)
- 🔄 Admin area block: Planned (PENG-053, Phase 0)
- 🔄 AJAX/REST hardening: Planned (PENG-054, Phase 0)

### Testing Checklist

- [ ] Employer can view only own requests
- [ ] Candidate can view only own profile
- [ ] Scout can view only own submissions
- [ ] Operator can view all submissions (Candidate, Employer, Scout)
- [ ] Operator can approve Candidate/Employer registrations
- [ ] Operator CANNOT approve Scout/Operator/Manager registrations
- [ ] Manager can approve ALL registration types
- [ ] Manager can view analytics (Operator cannot)
- [ ] Subscriber role → 403 Forbidden on frontend
- [ ] Administrator has full WordPress access

---

## Related Tasks & Documentation

**Blocked Tasks (Dependent on BMSL-001):**
- **BMSL-002:** Candidate update approach (which fields can be updated post-approval)
- **PENG-015:** CPT: td_registration_request (role-specific fields)
- **LFTC-004:** Consent text blocks (role-specific consent language)

**Related Documentation:**
- [WORDPRESS-TECHNICAL-DESIGN.md](../../Documents/WORDPRESS-TECHNICAL-DESIGN.md) - Section 6: Authentication and Roles
- [WORDPRESS-SECURITY.md](../../Documents/WORDPRESS-SECURITY.md) - Section 4: RBAC Requirements
- [WORDPRESS-MVP-REQUIREMENTS.md](../../Documents/WORDPRESS-MVP-REQUIREMENTS.md) - Registration workflows by role
- [wp-content/plugins/talendelight-roles/talendelight-roles.php](../wp-content/plugins/talendelight-roles/talendelight-roles.php) - Implementation

**Version History:**
- v1.0.0 (Jan 9, 2026) - Initial implementation (PENG-005)
- v1.0.0 (Jan 24, 2026) - Documentation (BMSL-001)

---

**Status:** ✅ Complete  
**Task:** BMSL-001 - Define role capabilities & boundaries  
**Date:** January 24, 2026  
**Next Task:** BMSL-002 - Candidate update approach (requires this document)
