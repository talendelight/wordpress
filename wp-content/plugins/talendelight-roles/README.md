# TalenDelight Custom Roles Plugin

**Version:** 1.0.0  
**Location:** `wp-content/plugins/talendelight-roles/talendelight-roles.php`  
**Purpose:** Register custom WordPress roles for TalenDelight recruitment platform with access control

---

## Custom Roles

### 1. Employer (`td_employer`)
**Type:** External role for hiring companies

**Capabilities:**
- `read` - Access WordPress frontend
- `td_view_own_requests` - View own candidate requests
- `td_request_candidates` - Submit candidate requests
- `td_view_request_status` - Check status of submissions

**Landing Page:** `/employers/`  
**Access Level:** Can only view/manage own data

---

### 2. Candidate (`td_candidate`)
**Type:** External role for job seekers

**Capabilities:**
- `read` - Access WordPress frontend
- `td_view_own_profile` - View own profile/submission
- `td_update_own_profile` - Edit own information
- `td_upload_cv` - Upload/update CV file

**Landing Page:** `/candidates/` (WP-01.3, future)  
**Access Level:** Can only view/manage own data

---

### 3. Scout (`td_scout`)
**Type:** External role for talent referrers (renamed from "Partner")

**Capabilities:**
- `read` - Access WordPress frontend
- `td_submit_candidate` - Submit candidates on behalf
- `td_view_own_submissions` - View own submissions
- `td_upload_candidate_cv` - Upload CV for candidates

**Landing Page:** `/scout/` (WP-03, future)  
**Access Level:** Can only view own submissions

---

### 4. Operator (`td_operator`)
**Type:** Internal role for operations team

**Capabilities:**
- `read` - Access WordPress frontend
- `edit_posts` - Edit posts (operational content)
- `edit_pages` - Edit pages (operational content)
- `td_manage_submissions` - View/edit all submissions
- `td_manage_candidates` - Manage candidate data
- `td_manage_employers` - Manage employer data
- `td_view_all_data` - Access all system data
- `td_export_data` - Export CSV/reports
- `td_update_candidate_status` - Change workflow status

**Landing Page:** `/operator/` (future)  
**Access Level:** Full operational access to all data

---

### 5. Manager (`td_manager`)
**Type:** Internal role for management/oversight

**Capabilities:**
- `read` - Access WordPress frontend
- `edit_posts` - Edit posts
- `edit_pages` - Edit pages
- `td_view_all_data` - Access all system data
- `td_view_analytics` - View analytics/metrics
- `td_view_reports` - Generate reports
- `td_manage_operators` - Oversee operator activities
- `td_export_data` - Export CSV/reports

**Landing Page:** `/manager/` (future)  
**Access Level:** Read-only operational oversight + analytics

---

## Default WordPress Roles

**Allowed Roles:** Administrator, Editor, Author  
**Behavior:** These roles can access the system normally (not blocked by 403 control)

**Blocked Roles:** Subscriber, Contributor, or any custom role not in the allowed list  
**Behavior:** Logged-in users with these roles are shown 403 Forbidden page

---

## Features

### 1. Custom Role Registration
- Roles are registered on plugin activation
- Uses WordPress `add_role()` API with custom capabilities
- One-time registration (tracked via `talendelight_roles_registered` option)
- Administrators automatically receive all custom capabilities

### 2. 403 Access Control
- Enforced via `template_redirect` hook
- Checks if logged-in users have allowed roles
- Redirects to `/403-forbidden/` page if exists, otherwise shows `wp_die()` error
- **Exceptions:**
  - Admin area (`/wp-admin/`)
  - AJAX requests
  - REST API requests
  - Logged-out users (can view public pages)

### 3. Role-Based Login Redirect
- Implemented via `login_redirect` filter
- Routes users to appropriate landing page after login
- **Priority order:**
  1. Administrator → `/wp-admin/`
  2. Manager → `/manager/` (fallback: `/account/`)
  3. Operator → `/operator/` (fallback: `/account/`)
  4. Employer → `/employers/` (fallback: `/account/`)
  5. Candidate → `/candidates/` (fallback: `/account/`)
  6. Scout → `/scout/` (fallback: `/account/`)
  7. Default → `/account/`
- Checks if target page exists before redirecting
- Falls back to `/account/` if role-specific page not yet created

---

## Installation

### Local Development
1. Plugin already exists at: `wp-content/plugins/talendelight-roles/talendelight-roles.php`
2. Activate via: **Plugins → Installed Plugins → TalenDelight Custom Roles → Activate**

### Production Deployment
1. Commit plugin to git: `git add wp-content/plugins/talendelight-roles/`
2. Push to trigger Hostinger auto-deploy: `git push origin main`
3. Login to WordPress Admin: `https://talendelight.com/wp-admin/`
4. Navigate to: **Plugins → Installed Plugins**
5. Find "TalenDelight Custom Roles" and click **Activate**

---

## Usage

### Assigning Roles to Users

**Via WordPress Admin:**
1. Navigate to: **Users → All Users**
2. Click user to edit
3. Change **Role** dropdown to desired custom role
4. Click **Update User**

**Via WP-CLI:**
```bash
wp user set-role employer_test td_employer
wp user set-role candidate_test td_candidate
wp user set-role scout_test td_scout
wp user set-role operator_test td_operator
wp user set-role manager_test td_manager
```

### Creating Test Users with Custom Roles

**Via WordPress Admin:**
1. Navigate to: **Users → Add New User**
2. Fill in username, email, password
3. Select custom role from **Role** dropdown
4. Click **Add New User**

**Via WP-CLI:**
```bash
wp user create employer_test employer@test.local --role=td_employer --user_pass=Test123!
wp user create candidate_test candidate@test.local --role=td_candidate --user_pass=Test123!
wp user create scout_test scout@test.local --role=td_scout --user_pass=Test123!
wp user create operator_test operator@test.local --role=td_operator --user_pass=Test123!
wp user create manager_test manager@test.local --role=td_manager --user_pass=Test123!
```

---

## Testing

### Test 403 Access Control
1. Create test user with "Subscriber" role (no custom role)
2. Login as subscriber
3. Navigate to any frontend page
4. Should see 403 Forbidden page/message
5. Verify administrators/editors can still access

### Test Role-Based Redirect
1. Login as `employer_test` → should redirect to `/employers/` (or `/account/` if page doesn't exist)
2. Login as `candidate_test` → should redirect to `/candidates/` (or `/account/` if page doesn't exist)
3. Login as `scout_test` → should redirect to `/scout/` (or `/account/` if page doesn't exist)
4. Login as `operator_test` → should redirect to `/operator/` (or `/account/` if page doesn't exist)
5. Login as `manager_test` → should redirect to `/manager/` (or `/account/` if page doesn't exist)
6. Login as administrator → should redirect to `/wp-admin/`

### Test Custom Capabilities
1. Assign custom role to test user
2. Use `current_user_can()` to check capabilities in custom code
3. Example: `if (current_user_can('td_manage_submissions')) { ... }`

---

## Plugin Lifecycle

### Activation
- Deletes `talendelight_roles_registered` option to force re-registration
- Registers all 5 custom roles
- Adds custom capabilities to administrator role
- Flushes rewrite rules

### Deactivation
- Flushes rewrite rules
- **Note:** Roles are NOT removed to preserve user assignments
- To manually remove roles: `remove_role('td_employer')`, etc.

### Uninstall
- Not implemented (roles persist)
- Manual cleanup required if plugin is permanently removed

---

## Custom Capabilities Reference

### Employer Capabilities
- `td_view_own_requests` - View own candidate requests
- `td_request_candidates` - Submit candidate requests
- `td_view_request_status` - Check submission status

### Candidate Capabilities
- `td_view_own_profile` - View own profile
- `td_update_own_profile` - Edit own information
- `td_upload_cv` - Upload/update CV

### Scout Capabilities
- `td_submit_candidate` - Submit candidates
- `td_view_own_submissions` - View own submissions
- `td_upload_candidate_cv` - Upload CVs for candidates

### Operator Capabilities
- `td_manage_submissions` - View/edit all submissions
- `td_manage_candidates` - Manage candidate data
- `td_manage_employers` - Manage employer data
- `td_view_all_data` - Access all system data
- `td_export_data` - Export CSV/reports
- `td_update_candidate_status` - Change workflow status

### Manager Capabilities
- `td_view_all_data` - Access all system data
- `td_view_analytics` - View analytics/metrics
- `td_view_reports` - Generate reports
- `td_manage_operators` - Oversee operators
- `td_export_data` - Export CSV/reports

---

## Troubleshooting

### Roles not appearing in dropdown
- Deactivate and reactivate plugin
- Check error logs: `wp-content/debug.log`
- Verify option: `wp option get talendelight_roles_registered`

### 403 error for valid users
- Check user role: **Users → Edit User → Role**
- Verify role is in allowed list (custom roles or admin/editor/author)
- Check if user has at least one allowed role

### Redirect not working
- Clear browser cache
- Check if target page exists (e.g., `/employers/`)
- Verify login_redirect filter is not overridden by another plugin
- Check WP User Manager settings for redirect conflicts

### Custom capabilities not working
- Verify role has capability: `$role = get_role('td_employer'); print_r($role->capabilities);`
- Re-activate plugin to ensure administrator has all capabilities
- Use `current_user_can('capability_name')` in code to check

---

## Future Enhancements

1. **Custom 403 Page:** Create branded `/403-forbidden/` page with support contact
2. **Role Management UI:** Admin interface to manage custom capabilities
3. **Capability Groups:** Bundle related capabilities for easier management
4. **Audit Log:** Track role changes and access attempts
5. **Multi-role Support:** Allow users to have multiple custom roles
6. **Dynamic Redirect:** Configure redirect URLs via admin settings

---

## Related Documentation

- [WORDPRESS-TECHNICAL-DESIGN.md](../../../Documents/WORDPRESS-TECHNICAL-DESIGN.md) - Section 6: Authentication and Roles
- [WORDPRESS-BACKLOG.md](../../../Documents/WORDPRESS-BACKLOG.md) - WP-04.1 and WP-04.1a
- [RELEASE-NOTES-NEXT.md](../../docs/RELEASE-NOTES-NEXT.md) - v3.0.0 deployment steps
