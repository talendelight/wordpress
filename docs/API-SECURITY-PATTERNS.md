# API Security Enforcement Patterns (PENG-054)

**Status:** ✅ Implemented  
**Version:** 1.0.0  
**Date:** February 11, 2026

## Overview

This document defines mandatory security patterns for all AJAX and REST API endpoints in the TalenDelight WordPress application. These patterns prevent privilege escalation, unauthorized data access, and API abuse.

---

## Security Architecture

### Three-Layer Defense

1. **Perimeter Defense** - `td-api-security.php` (global checks)
2. **Endpoint Defense** - Individual handler validation
3. **Business Logic Defense** - Data ownership and operation validation

---

## AJAX Security Pattern

### Mandatory Implementation

Every AJAX handler MUST implement ALL of the following:

```php
function td_custom_action_ajax() {
    // LAYER 1: Nonce verification (CSRF protection)
    check_ajax_referer('td_request_action', 'nonce');
    
    // LAYER 2: Authentication check
    if (!is_user_logged_in()) {
        wp_send_json_error(['message' => 'Authentication required']);
        return;
    }
    
    // LAYER 3: Role/capability authorization
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        error_log("Unauthorized AJAX attempt: {$user->user_email} for action td_custom_action");
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    
    // LAYER 4: Input validation
    $resource_id = isset($_POST['resource_id']) ? intval($_POST['resource_id']) : 0;
    
    if ($resource_id <= 0) {
        wp_send_json_error(['message' => 'Invalid resource ID']);
        return;
    }
    
    // LAYER 5: Resource ownership validation (if applicable)
    global $wpdb;
    $resource = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM td_custom_table WHERE id = %d",
        $resource_id
    ));
    
    if (!$resource) {
        wp_send_json_error(['message' => 'Resource not found']);
        return;
    }
    
    // LAYER 6: Business logic with prepared statements
    $wpdb->update(
        'td_custom_table',
        ['status' => 'updated'],
        ['id' => $resource_id],
        ['%s'],
        ['%d']
    );
    
    // LAYER 7: Audit logging
    TD_Audit_Logger::log(
        'td_custom_table',
        $resource_id,
        'update',
        $resource->status,
        'updated',
        'status',
        'Updated by ' . $user->display_name
    );
    
    // Success response
    wp_send_json_success(['message' => 'Action completed']);
}

// Register handler (authenticated users only)
add_action('wp_ajax_td_custom_action', 'td_custom_action_ajax');
```

### Security Checklist

Before deploying any AJAX endpoint, verify:

- [ ] `check_ajax_referer()` called first
- [ ] User authentication verified
- [ ] Role/capability authorization enforced
- [ ] Input sanitization applied (`intval()`, `sanitize_text_field()`, etc.)
- [ ] Database queries use prepared statements (`$wpdb->prepare()`)
- [ ] Resource ownership validated (if applicable)
- [ ] Actions logged via `TD_Audit_Logger`
- [ ] No sensitive data in error messages
- [ ] `wp_ajax_nopriv_` NOT used (unless intentionally public)

---

## REST API Security Pattern

### Mandatory Implementation

All custom REST API routes MUST use permission callbacks:

```php
function td_register_custom_rest_route() {
    register_rest_route('td/v1', '/resource/(?P<id>\d+)', [
        'methods'  => 'POST',
        'callback' => 'td_rest_update_resource',
        'permission_callback' => 'td_rest_resource_permission_check',
        'args' => [
            'id' => [
                'required' => true,
                'validate_callback' => function($param, $request, $key) {
                    return is_numeric($param) && $param > 0;
                }
            ]
        ]
    ]);
}

function td_rest_resource_permission_check($request) {
    // LAYER 1: Authentication
    if (!is_user_logged_in()) {
        return new WP_Error(
            'rest_forbidden',
            __('Authentication required.'),
            ['status' => 401]
        );
    }
    
    // LAYER 2: Authorization (role check)
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        error_log("Unauthorized REST attempt: {$user->user_email} for td/v1/resource");
        return new WP_Error(
            'rest_forbidden',
            __('You do not have permission to access this resource.'),
            ['status' => 403]
        );
    }
    
    // LAYER 3: Resource ownership (if applicable)
    $resource_id = $request->get_param('id');
    global $wpdb;
    
    $resource = $wpdb->get_row($wpdb->prepare(
        "SELECT * FROM td_custom_table WHERE id = %d",
        $resource_id
    ));
    
    if (!$resource) {
        return new WP_Error(
            'rest_not_found',
            __('Resource not found.'),
            ['status' => 404]
        );
    }
    
    // Only Manager can modify resources
    if (!in_array('td_manager', $user->roles) && !in_array('administrator', $user->roles)) {
        return new WP_Error(
            'rest_forbidden',
            __('Only Managers can modify this resource.'),
            ['status' => 403]
        );
    }
    
    return true;
}

function td_rest_update_resource($request) {
    $resource_id = $request->get_param('id');
    
    // Business logic here (permission already verified)
    global $wpdb;
    
    $wpdb->update(
        'td_custom_table',
        ['status' => 'updated'],
        ['id' => $resource_id],
        ['%s'],
        ['%d']
    );
    
    // Audit log
    TD_Audit_Logger::log(
        'td_custom_table',
        $resource_id,
        'update',
        'old_value',
        'updated',
        'status',
        'Updated via REST API by ' . wp_get_current_user()->display_name
    );
    
    return new WP_REST_Response(['success' => true], 200);
}

add_action('rest_api_init', 'td_register_custom_rest_route');
```

### REST API Checklist

Before deploying any REST endpoint, verify:

- [ ] `permission_callback` defined (NEVER use `__return_true`)
- [ ] Authentication verified in permission callback
- [ ] Role/capability authorization enforced
- [ ] Input validation via `args` parameter
- [ ] Prepared statements for database queries
- [ ] Resource ownership validated
- [ ] Actions logged via `TD_Audit_Logger`
- [ ] Proper HTTP status codes (401, 403, 404, 200)
- [ ] No sensitive data in error messages

---

## Role-Based Access Control (RBAC)

### Role Hierarchy

| Role | Access Level | AJAX Access | REST Access | Admin Area |
|------|--------------|-------------|-------------|------------|
| **Administrator** | Full system access | ✅ All | ✅ All | ✅ Full |
| **td_manager** | Operations management | ✅ All TD endpoints | ✅ TD namespace only | ❌ Blocked |
| **td_operator** | Operations execution | ✅ All TD endpoints | ✅ TD namespace only | ❌ Blocked |
| **td_scout** | CV submission only | ❌ None | ❌ None | ❌ Blocked |
| **td_employer** | Job posting only | ❌ None (future) | ❌ None (future) | ❌ Blocked |
| **td_candidate** | Profile management | ❌ None (future) | ❌ None (future) | ❌ Blocked |

### Capability Mapping

```php
// Manager capabilities
$manager_caps = [
    'approve_user_requests',
    'reject_user_requests',
    'assign_user_requests',
    'view_audit_logs',
    'manage_scouts',
    'manage_employers',
];

// Operator capabilities
$operator_caps = [
    'approve_user_requests',
    'reject_user_requests',
    'assign_user_requests',
    'view_assigned_requests',
];

// Check capability in handler
if (!current_user_can('approve_user_requests')) {
    wp_send_json_error(['message' => 'Unauthorized']);
}
```

---

## Global Security Measures

### Implemented in `td-api-security.php`

1. **REST API Authentication Enforcement**
   - All REST routes require authentication by default
   - Public routes explicitly whitelisted
   - Custom roles blocked from WordPress admin API

2. **AJAX Request Monitoring**
   - All TD AJAX actions logged
   - Invalid nonce attempts logged
   - Unauthorized role attempts logged

3. **Attack Surface Reduction**
   - XML-RPC disabled (common attack vector)
   - WordPress version hidden (information disclosure)
   - File editing disabled in admin (code injection)

4. **Security Headers** (handled by server/Hostinger)
   - X-Frame-Options
   - X-Content-Type-Options
   - Strict-Transport-Security

---

## Testing Procedures

### Manual Testing

Test each endpoint with:

1. **Unauthenticated request** → Should return 401
2. **Wrong role** → Should return 403
3. **Invalid nonce** → Should die with error
4. **Invalid resource ID** → Should return error
5. **Non-existent resource** → Should return not found
6. **Valid request** → Should succeed + log audit entry

### Automated Testing (Future - Phase 1)

```javascript
// Playwright test example
test('AJAX endpoint requires authentication', async ({ page }) => {
    const response = await page.evaluate(async () => {
        return fetch('/wp-admin/admin-ajax.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=td_approve_request&request_id=1&nonce=invalid'
        });
    });
    
    expect(response.status).toBe(403);
});
```

---

## Security Incident Response

### Suspected Breach

1. Check error logs: `wp-content/debug.log`
2. Check audit logs: `td_audit_log` table
3. Review failed authentication attempts
4. Check user role escalation attempts

### Suspicious Patterns

```bash
# Search for unauthorized attempts
grep "AJAX Security" wp-content/debug.log

# Search for REST API violations
grep "REST API access denied" wp-content/debug.log

# Check recent approvals by specific user
SELECT * FROM td_audit_log 
WHERE action = 'approve' 
  AND changed_by = 'suspect_user_id' 
ORDER BY created_at DESC;
```

---

## Maintenance

### When Adding New AJAX Endpoint

1. Copy pattern from this document
2. Implement all 7 security layers
3. Add to monitored actions in `td-api-security.php`
4. Add test cases
5. Document in this file

### When Adding New REST Endpoint

1. Copy pattern from this document
2. Define strict `permission_callback`
3. Add to allowed namespaces (if needed)
4. Add test cases
5. Document in this file

---

## Current Endpoint Inventory

### AJAX Endpoints (Secured ✅)

| Action | Handler | Roles | Nonce | Status |
|--------|---------|-------|-------|--------|
| `td_approve_request` | `user-requests-display.php:23` | Manager, Operator | `td_request_action` | ✅ Secured |
| `td_reject_request` | `user-requests-display.php:96` | Manager, Operator | `td_request_action` | ✅ Secured |
| `td_undo_reject` | `user-requests-display.php:148` | Manager, Operator | `td_request_action` | ✅ Secured |
| `td_undo_approve` | `user-requests-display.php:196` | Manager, Operator | `td_request_action` | ✅ Secured |
| `td_assign_request` | `user-requests-display.php:253` | Manager, Operator | `td_request_action` | ✅ Secured |

### REST Endpoints (None Custom)

No custom REST API endpoints currently registered.

Third-party endpoints handled by their own security:
- WPForms: `/wpforms/v1/*` - Built-in capability checks
- Akismet: `/akismet/v1/*` - Built-in capability checks
- GenerateBlocks: `/generateblocks/v1/*` - Editor-only
- Blocksy: `/blocksy/v1/search` - Public (intentional)

---

## Compliance & Standards

### OWASP Top 10 Coverage

- ✅ **A01: Broken Access Control** - Role-based checks on all endpoints
- ✅ **A02: Cryptographic Failures** - Prepared statements, nonce validation
- ✅ **A03: Injection** - SQL injection prevention via `$wpdb->prepare()`
- ✅ **A05: Security Misconfiguration** - XML-RPC disabled, file edit disabled
- ✅ **A07: Authentication Failures** - Nonce + session validation
- ✅ **A08: Data Integrity Failures** - Audit logging for all mutations

### WordPress Security Best Practices

- ✅ Capability checks instead of role checks (where applicable)
- ✅ Nonce validation for CSRF protection
- ✅ Prepared statements for SQL queries
- ✅ Input sanitization and output escaping
- ✅ No direct file access checks (`defined('ABSPATH')`)

---

## References

- [WordPress AJAX API](https://developer.wordpress.org/plugins/javascript/ajax/)
- [WordPress REST API Handbook](https://developer.wordpress.org/rest-api/)
- [WordPress Security White Paper](https://wordpress.org/about/security/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)

---

**Document Owner:** Technical Lead  
**Last Reviewed:** February 11, 2026  
**Next Review:** March 2026 (after MVP Phase 1)
