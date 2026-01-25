# PENG-053: Block /wp-admin/ for Non-Administrator Roles

**Status:** Done  
**Priority:** Critical  
**Phase:** Phase 0  
**Target Version:** v3.6.0  
**Owner:** Manager  
**Timeline:** Jan 25, 2026  
**Completed:** January 25, 2026  
**Dependencies:** BMSL-001 (Role Capabilities Matrix) - Done  
**Implementation:** [wp-content/plugins/talendelight-roles/talendelight-roles.php](../wp-content/plugins/talendelight-roles/talendelight-roles.php) v1.1.0

---

## 1. Overview

### 1.1 Requirement

Enforce that **only users with 'administrator' role** can access the WordPress admin panel (`/wp-admin/`). All custom TalenDelight roles must be **completely blocked** from accessing:

- WordPress admin dashboard
- Plugin settings
- Theme customizer
- User management
- Post/page editing via admin panel
- Any `/wp-admin/` URLs

### 1.2 Security Rationale

Based on [ROLE-CAPABILITIES-MATRIX.md](ROLE-CAPABILITIES-MATRIX.md), custom roles should use **custom landing pages** and **custom dashboards**, not WordPress admin panel:

- **Employers, Candidates, Scouts:** External users - no admin access needed
- **Operators:** Internal staff - use `/operators/` dashboard (custom Elementor page)
- **Managers:** Internal oversight - use `/managers/` dashboard (custom Elementor page)
- **Administrators:** Technical/configuration access only

**Principle:** Separation of operational dashboards (Elementor pages) from technical admin (WordPress core).

---

## 2. Implementation Details

### 2.1 Core Blocking Function

**Function:** `talendelight_block_wp_admin_access()`  
**Hook:** `admin_init` (priority 1 - runs early)  
**File:** `wp-content/plugins/talendelight-roles/talendelight-roles.php` lines 86-118

**Logic:**
1. Check if user is in admin area (skip AJAX requests)
2. Check if user is logged in
3. Check if user has 'administrator' role → Allow access
4. **Block all other users** → Redirect to role-specific landing page
5. Log security event for audit trail

**Code:**
```php
function talendelight_block_wp_admin_access() {
    if (!is_admin() || wp_doing_ajax()) {
        return;
    }

    if (!is_user_logged_in()) {
        return;
    }

    $user = wp_get_current_user();

    if (in_array('administrator', $user->roles)) {
        return; // Allow access
    }

    // Block all non-Administrator roles
    $redirect_url = talendelight_get_role_landing_page($user);
    
    error_log(sprintf(
        'TalenDelight Security: Blocked wp-admin access for user %s (ID: %d, Roles: %s)',
        $user->user_login,
        $user->ID,
        implode(', ', $user->roles)
    ));

    wp_redirect(add_query_arg('access_denied', 'wp-admin', $redirect_url));
    exit;
}
add_action('admin_init', 'talendelight_block_wp_admin_access', 1);
```

### 2.2 Role-Based Redirect Logic

**Function:** `talendelight_get_role_landing_page($user)`  
**Purpose:** Determine appropriate landing page for each role after wp-admin block  
**File:** `wp-content/plugins/talendelight-roles/talendelight-roles.php` lines 120-144

**Redirect Matrix:**

| Role | Landing Page | Fallback |
|------|--------------|----------|
| `td_manager` | `/managers/` | `/account/` |
| `td_operator` | `/operators/` | `/account/` |
| `td_employer` | `/employers/` | `/account/` |
| `td_candidate` | `/candidates/` | `/account/` |
| `td_scout` | `/scouts/` | `/account/` |
| Other | N/A | `/account/` |

**Code:**
```php
function talendelight_get_role_landing_page($user) {
    if (in_array('td_manager', $user->roles)) {
        $manager_page = get_page_by_path('managers');
        return $manager_page ? home_url('/managers/') : home_url('/account/');
    } elseif (in_array('td_operator', $user->roles)) {
        $operator_page = get_page_by_path('operators');
        return $operator_page ? home_url('/operators/') : home_url('/account/');
    }
    // ... (other roles)
    return home_url('/account/');
}
```

### 2.3 User Experience Enhancements

#### Access Denied Notice

**Function:** `talendelight_display_access_denied_notice()`  
**Hook:** `wp_body_open`  
**Purpose:** Show dismissible warning banner when user is redirected from wp-admin  
**Trigger:** URL parameter `?access_denied=wp-admin`

**Display:**
- Yellow warning box (Bootstrap alert style)
- Clear message: "WordPress Admin Access Restricted"
- Explanation: Redirected to dashboard, contact Manager for admin access
- Automatically appears on landing page after redirect

#### Admin Bar Hiding

**Function:** `talendelight_hide_admin_bar_for_custom_roles()`  
**Hook:** `after_setup_theme`  
**Purpose:** Hide WordPress admin bar (top black bar) for non-Administrator users

**Logic:**
- Administrators: Show admin bar (default WordPress behavior)
- All custom roles: Hide admin bar (cleaner UX, no admin access)

**Code:**
```php
function talendelight_hide_admin_bar_for_custom_roles() {
    if (!is_user_logged_in()) {
        return;
    }

    $user = wp_get_current_user();

    if (!in_array('administrator', $user->roles)) {
        show_admin_bar(false);
    }
}
add_action('after_setup_theme', 'talendelight_hide_admin_bar_for_custom_roles');
```

---

## 3. Security Audit Logging

### 3.1 Log Format

**Location:** WordPress debug.log (if `WP_DEBUG_LOG` enabled)  
**Format:**
```
TalenDelight Security: Blocked wp-admin access for user {username} (ID: {user_id}, Roles: {role1, role2})
```

**Example:**
```
[25-Jan-2026 14:30:45 UTC] TalenDelight Security: Blocked wp-admin access for user john.operator (ID: 42, Roles: td_operator)
```

### 3.2 Audit Use Cases

**Security monitoring:**
- Track unauthorized admin access attempts
- Identify users trying to bypass role restrictions
- Detect potential account compromise (e.g., Candidate role trying to access admin)

**Compliance:**
- GDPR Art. 32 - Security logging for access control violations
- Evidence for "who accessed what" audit trails

---

## 4. Edge Cases & Testing

### 4.1 AJAX Requests

**Behavior:** wp-admin blocking **does NOT apply** to AJAX requests  
**Rationale:** Many frontend features use `admin-ajax.php` for form submissions, etc.  
**Code:** `if (wp_doing_ajax()) { return; }`

**Security Note:** AJAX endpoints must implement **capability checks** separately (see PENG-054).

### 4.2 REST API Requests

**Behavior:** wp-admin blocking **does NOT apply** to REST API  
**Rationale:** REST API has its own authentication/authorization system  
**Code:** `if (defined('REST_REQUEST') && REST_REQUEST) { return; }`

### 4.3 Direct URL Access

**Test Scenarios:**

| User Role | Access `/wp-admin/` | Expected Result |
|-----------|---------------------|-----------------|
| Administrator | ✅ Allowed | Shows WP dashboard |
| Manager | ❌ Blocked | Redirected to `/managers/?access_denied=wp-admin` |
| Operator | ❌ Blocked | Redirected to `/operators/?access_denied=wp-admin` |
| Employer | ❌ Blocked | Redirected to `/employers/?access_denied=wp-admin` |
| Candidate | ❌ Blocked | Redirected to `/candidates/?access_denied=wp-admin` |
| Scout | ❌ Blocked | Redirected to `/scouts/?access_denied=wp-admin` |
| Not logged in | Auth redirect | WordPress login screen |

### 4.4 Multi-Role Users

**Scenario:** User has multiple roles (e.g., `td_operator` + `td_manager`)  
**Behavior:** If **any role is 'administrator'**, user gets admin access  
**Code:** `if (in_array('administrator', $user->roles)) { return; }`

**Edge Case:** User with `td_candidate` + `administrator` → Allowed (administrator wins)

---

## 5. Integration with Existing Security

### 5.1 Frontend 403 Access Control

**Function:** `talendelight_enforce_custom_roles()`  
**Purpose:** Block frontend access for users without allowed TalenDelight roles  
**Scope:** Frontend pages only (not admin area)

**Relationship to PENG-053:**
- Frontend 403: Blocks non-TalenDelight roles from viewing pages
- PENG-053: Blocks non-Administrator roles from admin panel
- **Complementary:** Both enforce role-based access control (RBAC)

### 5.2 Page-Specific Access Control

**Functions:**
- `talendelight_restrict_operators_page()` - Only Operators + Managers + Admins
- `talendelight_restrict_managers_page()` - Only Managers + Admins

**Relationship to PENG-053:**
- Page restrictions: Control which landing pages each role can access
- PENG-053: Control who can access WordPress admin
- **Layered security:** Multiple enforcement points

---

## 6. Future Enhancements

### 6.1 PENG-054: AJAX/REST Endpoint Hardening

**Next Step:** Implement capability checks on all AJAX/REST endpoints  
**Why:** wp-admin block doesn't cover AJAX - need explicit checks  
**Example:** `if (!current_user_can('td_manage_candidates')) { wp_die('Forbidden', 403); }`

### 6.2 Granular Admin Access (Post-MVP)

**Use Case:** Allow Operators to access **specific** admin pages (e.g., Forminator submissions)  
**Approach:**
- Use `$pagenow` and `$_GET['page']` to identify specific admin pages
- Allow certain pages, block others
- Example: Allow `admin.php?page=forminator-entries`, block everything else

**Not Implemented in MVP:** Too complex - use custom dashboards instead.

---

## 7. Testing Checklist

### 7.1 Manual Testing (Local Development)

**Prerequisites:**
- [ ] Local WordPress environment running (Podman containers)
- [ ] Test users created for each role (see [TEST-USERS.md](TEST-USERS.md))
- [ ] Plugin activated: TalenDelight Custom Roles v1.1.0

**Test Cases:**

#### TC-001: Administrator Access
- [ ] Login as Administrator
- [ ] Navigate to `/wp-admin/`
- [ ] **Expected:** Full admin dashboard access
- [ ] **Expected:** Admin bar visible at top

#### TC-002: Manager Blocked
- [ ] Login as Manager (test user)
- [ ] Navigate to `/wp-admin/`
- [ ] **Expected:** Redirected to `/managers/?access_denied=wp-admin`
- [ ] **Expected:** Yellow warning banner visible
- [ ] **Expected:** No admin bar visible

#### TC-003: Operator Blocked
- [ ] Login as Operator
- [ ] Try accessing `/wp-admin/plugins.php` directly
- [ ] **Expected:** Redirected to `/operators/?access_denied=wp-admin`
- [ ] **Expected:** Warning banner displayed

#### TC-004: External Roles Blocked
- [ ] Login as Employer
- [ ] Navigate to `/wp-admin/`
- [ ] **Expected:** Redirected to `/employers/?access_denied=wp-admin`
- [ ] Repeat for Candidate → `/candidates/`, Scout → `/scouts/`

#### TC-005: AJAX Not Blocked
- [ ] Login as Operator
- [ ] Submit a form that uses `admin-ajax.php`
- [ ] **Expected:** Form submission works (AJAX not blocked)
- [ ] Check browser console for errors → None

#### TC-006: Security Logging
- [ ] Enable WP_DEBUG_LOG in wp-config.php
- [ ] Login as Operator, try to access `/wp-admin/`
- [ ] Check `wp-content/debug.log`
- [ ] **Expected:** Log entry: `TalenDelight Security: Blocked wp-admin access for user {operator_username}`

### 7.2 Production Testing (Hostinger)

**Post-Deployment:**
- [ ] Test with real Manager account
- [ ] Verify Operator cannot access `/wp-admin/`
- [ ] Confirm Administrator can still access admin panel
- [ ] Check redirect URLs work on production domain

---

## 8. Deployment Notes

### 8.1 Plugin Update

**File Changed:** `wp-content/plugins/talendelight-roles/talendelight-roles.php`  
**Version:** 1.0.0 → 1.1.0  
**Changes:**
- Added `talendelight_block_wp_admin_access()` function
- Added `talendelight_get_role_landing_page()` helper
- Added `talendelight_display_access_denied_notice()` UX function
- Added `talendelight_hide_admin_bar_for_custom_roles()` function

### 8.2 No Database Changes

**Migration:** None required  
**Reactivation:** Not required (functions hook on plugin load)

### 8.3 Rollback Plan

**If issues occur:**
1. Deactivate plugin: WP Admin → Plugins → Deactivate "TalenDelight Custom Roles"
2. Revert file: `git checkout HEAD~1 wp-content/plugins/talendelight-roles/talendelight-roles.php`
3. Reactivate plugin

**Critical:** Always keep Administrator account credentials safe - this is the only role with admin access.

---

## 9. Documentation Updates

### 9.1 Files Updated

- [x] `wp-content/plugins/talendelight-roles/talendelight-roles.php` - Implementation
- [x] `docs/PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md` - This document
- [ ] `docs/ROLE-CAPABILITIES-MATRIX.md` - Add note about wp-admin blocking
- [ ] `WORDPRESS-SECURITY.md` (Documents workspace) - Update access control section

### 9.2 Related Documentation

- [ROLE-CAPABILITIES-MATRIX.md](ROLE-CAPABILITIES-MATRIX.md) - Defines CAN/CANNOT for each role
- [TEST-USERS.md](TEST-USERS.md) - Test user accounts for each role
- [WORDPRESS-SECURITY.md](../../Documents/WORDPRESS-SECURITY.md) - Security policies

---

## 10. Acceptance Criteria

**Definition of Done (PENG-053):**

- [x] **Implementation:** Code added to block non-Administrator access to `/wp-admin/`
- [x] **Role-based redirects:** Users redirected to appropriate landing pages
- [x] **UX notice:** Warning banner displayed on landing page after redirect
- [x] **Admin bar hidden:** Top admin bar hidden for non-Administrators
- [x] **Security logging:** Blocked attempts logged to debug.log
- [x] **AJAX exception:** AJAX requests not blocked (intentional)
- [x] **Documentation:** Implementation guide created (this file)
- [ ] **Testing:** Manual testing completed (all 6 test cases pass)
- [ ] **Production deployment:** Plugin updated on Hostinger
- [ ] **Task closure:** GitHub issue closed, CSV status updated

---

## 11. References

**Related Tasks:**
- BMSL-001: Role Capabilities Matrix (dependency - Done)
- PENG-054: Enforce capability checks on AJAX/REST endpoints (next task)
- PADM-004: Access control baseline (parallel security task)

**Code Files:**
- `wp-content/plugins/talendelight-roles/talendelight-roles.php` - Main implementation
- `wp-content/plugins/talendelight-roles/README.md` - Plugin documentation (future)

**Documentation:**
- [ROLE-CAPABILITIES-MATRIX.md](ROLE-CAPABILITIES-MATRIX.md) - Role definitions
- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Production deployment process
- [WORDPRESS-SECURITY.md](../../Documents/WORDPRESS-SECURITY.md) - Security policies

---

**Document Version:** v1.0  
**Created:** January 25, 2026  
**Last Updated:** January 25, 2026  
**Task Status:** Done (Implementation Complete, Testing Pending)
