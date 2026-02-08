# Lesson: WordPress Permission Checks - Capabilities vs Roles

**Date Learned:** February 1, 2026  
**Context:** Manager Admin Page - Undo Action Authorization  
**Related Files:** 
- [wp-content/mu-plugins/user-requests-display.php](../../wp-content/mu-plugins/user-requests-display.php)
- [wp-content/themes/blocksy-child/functions.php](../../wp-content/themes/blocksy-child/functions.php)

---

## Problem Statement

**User Report:** "I'm getting Error: Unauthorized when doing Undo Approve"

**Context:**
- User logged in as Manager (custom role `td_manager`)
- Attempting to undo approval on a previously approved request
- AJAX handler returning "Unauthorized" error

**Expected Behavior:** Managers should have permission to undo approvals (same permission level as Approve/Reject actions).

---

## Root Cause Analysis

### The Capability-Based Check Trap

**Original Code (Administrator-Only):**
```php
function td_undo_approve_ajax() {
    // This only allows Administrators
    if (!current_user_can('manage_options')) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    
    // Rest of handler code...
}
```

**Why This Failed:**
- `manage_options` is a WordPress core capability
- **Only** the `administrator` role has this capability by default
- Custom roles (`td_manager`, `td_operator`) do NOT have `manage_options` unless explicitly granted
- Even though Managers have permission to approve requests, they cannot undo them

**Permission Inconsistency:**
```php
// Approve action (works for Manager)
function td_approve_request_ajax() {
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    if (!array_intersect($allowed_roles, $user->roles)) {
        // Permission denied
    }
    // Manager can approve ✅
}

// Undo Approve action (blocks Manager)
function td_undo_approve_ajax() {
    if (!current_user_can('manage_options')) {
        // Manager blocked ❌ (doesn't have manage_options)
    }
}
```

---

## Solution

### Role-Based Permission Check

**Fixed Code (Manager/Operator Access):**
```php
function td_undo_approve_ajax() {
    // Check if user has one of the allowed roles
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    
    // Rest of handler code...
}
```

**Applied to Both Undo Functions:**
```php
function td_undo_reject_ajax() {
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    
    // Handler logic...
}

function td_undo_approve_ajax() {
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    
    // Handler logic...
}
```

**Result:** ✅ Managers and Operators can now undo both approvals and rejections.

---

## Capabilities vs Roles: When to Use Which

### WordPress Permission System Overview

**Roles → Capabilities → Permissions**

```
Administrator Role
    ├─ manage_options (capability)
    ├─ edit_posts (capability)
    ├─ delete_users (capability)
    └─ ... (many more)

Manager Role (custom)
    ├─ read (capability)
    ├─ edit_posts (capability)
    └─ td_manage_requests (custom capability)
```

### Method 1: Capability-Based Check

**When to Use:**
- Checking for specific WordPress core capabilities
- Permission applies across multiple roles
- Using WordPress standard capabilities

**Example:**
```php
if (current_user_can('edit_posts')) {
    // Any role with edit_posts capability
    // Works for: Administrator, Editor, Author, Contributor
}

if (current_user_can('manage_options')) {
    // Administrator ONLY (by default)
}
```

**Limitations:**
- Custom roles need explicit capability assignment
- Doesn't work well with custom role-specific logic
- Less clear which roles are actually allowed

### Method 2: Role-Based Check

**When to Use:**
- Custom roles with specific business logic
- Need explicit control over which roles allowed
- Permission tied to organizational hierarchy
- Clear documentation of allowed roles

**Example:**
```php
$user = wp_get_current_user();
$allowed_roles = ['administrator', 'td_manager', 'td_operator'];

if (array_intersect($allowed_roles, $user->roles)) {
    // Explicitly allowed roles only
    // Clear and self-documenting
}
```

**Benefits:**
- ✅ Explicit and clear which roles allowed
- ✅ Works immediately with custom roles
- ✅ No capability mapping needed
- ✅ Self-documenting code

**Limitations:**
- ❌ Less flexible (can't grant permission via capability alone)
- ❌ Requires code change to add new role

---

## Best Practices

### 1. Choose Consistent Permission Strategy

**For Custom Business Logic:**
```php
// ✅ RECOMMENDED: Role-based for custom workflows
function td_approve_request_ajax() {
    $user = wp_get_current_user();
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    
    if (!array_intersect($allowed_roles, $user->roles)) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    // ...
}
```

**For WordPress Standard Actions:**
```php
// ✅ RECOMMENDED: Capability-based for WordPress standards
function custom_edit_post_action() {
    if (!current_user_can('edit_posts')) {
        wp_die('Unauthorized');
    }
    // ...
}
```

### 2. Define Permission Constants

**Centralized Role Management:**
```php
// In functions.php or dedicated config file
class TD_Permissions {
    const APPROVAL_ROLES = ['administrator', 'td_manager', 'td_operator'];
    const ADMIN_ONLY_ROLES = ['administrator'];
    const EXTERNAL_ROLES = ['td_employer', 'td_candidate', 'td_scout'];
    
    public static function can_approve_requests($user = null) {
        if (!$user) {
            $user = wp_get_current_user();
        }
        return array_intersect(self::APPROVAL_ROLES, $user->roles);
    }
    
    public static function can_manage_users($user = null) {
        if (!$user) {
            $user = wp_get_current_user();
        }
        return array_intersect(self::ADMIN_ONLY_ROLES, $user->roles);
    }
}

// Usage in AJAX handlers
function td_approve_request_ajax() {
    if (!TD_Permissions::can_approve_requests()) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    // ...
}
```

**Benefits:**
- Single source of truth for role permissions
- Easy to update allowed roles
- Reusable across codebase
- Self-documenting with method names

### 3. Document Permission Requirements

**In Function DocBlocks:**
```php
/**
 * Undo approval for a user request.
 * 
 * @since 1.0.0
 * @permission td_manager, td_operator, administrator
 * @ajax_action td_undo_approve
 */
function td_undo_approve_ajax() {
    // ...
}
```

**In Permission Matrix Documentation:**
- Create [ROLE-CAPABILITIES-MATRIX.md](../ROLE-CAPABILITIES-MATRIX.md)
- Document all custom actions and required roles
- Keep updated as permissions evolve

### 4. Consistent Permission Levels Across Related Actions

**Anti-Pattern (Inconsistent):**
```php
// Approve: Manager/Operator allowed
function td_approve_request_ajax() {
    $allowed_roles = ['administrator', 'td_manager', 'td_operator'];
    // ...
}

// Undo Approve: Administrator ONLY
function td_undo_approve_ajax() {
    if (!current_user_can('manage_options')) {
        // Only Administrator
    }
}
```

**Best Practice (Consistent):**
```php
// Define permission level once
const APPROVAL_ACTION_ROLES = ['administrator', 'td_manager', 'td_operator'];

// Apply consistently
function td_approve_request_ajax() {
    if (!TD_Permissions::can_approve_requests()) {
        wp_send_json_error(['message' => 'Unauthorized']);
    }
}

function td_undo_approve_ajax() {
    if (!TD_Permissions::can_approve_requests()) {
        wp_send_json_error(['message' => 'Unauthorized']);
    }
}
```

---

## Common Capability Traps

### Trap 1: `manage_options` is Administrator-Only

**Assumption:** "Managers should have manage_options"  
**Reality:** Only Administrators have this by default, and it grants access to Settings pages.

**Fix:** Use role-based check for custom Manager permissions.

### Trap 2: Custom Roles Without Capabilities

**Problem:**
```php
// Create custom role
add_role('td_manager', 'Manager', [
    'read' => true,
    // Forgot to add other capabilities
]);

// Later in code
if (!current_user_can('edit_posts')) {
    // Manager blocked! ❌
}
```

**Solution:** Either grant explicit capabilities or use role-based checks.

### Trap 3: Multiple Roles Not Checked

**Problem:**
```php
$user = wp_get_current_user();
if ($user->roles[0] === 'td_manager') {
    // Assumes roles[0] is primary role
    // Fails if user has multiple roles
}
```

**Solution:**
```php
$user = wp_get_current_user();
if (in_array('td_manager', $user->roles)) {
    // Checks all roles
}

// Or better:
if (array_intersect(['td_manager', 'administrator'], $user->roles)) {
    // Checks for any of multiple allowed roles
}
```

### Trap 4: Forgetting to Check Permissions at All

**Problem:**
```php
function td_delete_user_ajax() {
    $user_id = $_POST['user_id'];
    wp_delete_user($user_id);  // ❌ No permission check!
    wp_send_json_success();
}
```

**Solution:**
```php
function td_delete_user_ajax() {
    // ALWAYS check permissions first
    if (!TD_Permissions::can_manage_users()) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    
    $user_id = absint($_POST['user_id']);  // Sanitize input
    wp_delete_user($user_id);
    wp_send_json_success();
}
```

---

## Testing Permission Checks

### Test Case Template

```php
/**
 * Test: Manager can undo approvals
 */
function test_manager_undo_approval() {
    // Setup
    wp_set_current_user($this->manager_user_id);
    $request_id = $this->create_approved_request();
    
    // Execute
    $_POST['request_id'] = $request_id;
    $_POST['nonce'] = wp_create_nonce('td_undo_approve_' . $request_id);
    
    ob_start();
    td_undo_approve_ajax();
    $response = json_decode(ob_get_clean(), true);
    
    // Assert
    $this->assertTrue($response['success'], 'Manager should be able to undo approval');
}

/**
 * Test: Candidate cannot undo approvals
 */
function test_candidate_cannot_undo_approval() {
    // Setup
    wp_set_current_user($this->candidate_user_id);
    $request_id = $this->create_approved_request();
    
    // Execute
    $_POST['request_id'] = $request_id;
    $_POST['nonce'] = wp_create_nonce('td_undo_approve_' . $request_id);
    
    ob_start();
    td_undo_approve_ajax();
    $response = json_decode(ob_get_clean(), true);
    
    // Assert
    $this->assertFalse($response['success'], 'Candidate should NOT be able to undo approval');
    $this->assertEquals('Unauthorized', $response['data']['message']);
}
```

### Manual Testing Checklist

**For Each AJAX Handler:**

1. **Allowed Roles:**
   - [ ] Login as Administrator → Action succeeds
   - [ ] Login as Manager → Action succeeds
   - [ ] Login as Operator → Action succeeds

2. **Blocked Roles:**
   - [ ] Login as Employer → Action blocked
   - [ ] Login as Candidate → Action blocked
   - [ ] Login as Scout → Action blocked

3. **Edge Cases:**
   - [ ] No user logged in → Action blocked
   - [ ] User deleted mid-session → Action blocked
   - [ ] User role changed mid-session → Correct permission applied

---

## Implementation Checklist

### When Adding New AJAX Handler

- [ ] Define which roles should have access
- [ ] Add permission check as first logic in handler
- [ ] Use role-based check for custom roles
- [ ] Use capability check for WordPress standard actions
- [ ] Return consistent error message: `wp_send_json_error(['message' => 'Unauthorized'])`
- [ ] Add @permission tag in function DocBlock
- [ ] Update ROLE-CAPABILITIES-MATRIX.md
- [ ] Write test cases for allowed and blocked roles

### When Creating Custom Role

- [ ] Define role in code with explicit capabilities
- [ ] Document role purpose and permissions
- [ ] Create test user for each custom role
- [ ] Test all AJAX handlers with new role
- [ ] Update permission constants/config
- [ ] Add to ROLE-CAPABILITIES-MATRIX.md

---

## Related Security Patterns

### 1. Nonce Verification (Always Required)

```php
function td_approve_request_ajax() {
    // 1. Verify nonce FIRST
    $request_id = absint($_POST['request_id']);
    if (!wp_verify_nonce($_POST['nonce'], 'td_approve_' . $request_id)) {
        wp_send_json_error(['message' => 'Invalid security token']);
        return;
    }
    
    // 2. Check permissions SECOND
    if (!TD_Permissions::can_approve_requests()) {
        wp_send_json_error(['message' => 'Unauthorized']);
        return;
    }
    
    // 3. Process action LAST
    // ...
}
```

### 2. Input Sanitization

```php
function td_approve_request_ajax() {
    // Sanitize all inputs
    $request_id = absint($_POST['request_id']);  // Force integer
    $notes = sanitize_textarea_field($_POST['notes']);  // Clean text
    $email = sanitize_email($_POST['email']);  // Validate email
    
    // Then process...
}
```

### 3. Audit Logging

```php
function td_approve_request_ajax() {
    // After permission check passes
    if (TD_Permissions::can_approve_requests()) {
        $user = wp_get_current_user();
        TD_Audit_Logger::log([
            'action' => 'approve_request',
            'user_id' => $user->ID,
            'user_role' => $user->roles[0],
            'request_id' => $request_id,
            'timestamp' => current_time('mysql')
        ]);
        
        // Process action...
    }
}
```

---

## References

- **Session Summary:** [SESSION-SUMMARY-FEB-01.md](../SESSION-SUMMARY-FEB-01.md)
- **File Modified:** [user-requests-display.php](../../wp-content/mu-plugins/user-requests-display.php) (lines 139-235)
- **Role Capabilities Matrix:** [ROLE-CAPABILITIES-MATRIX.md](../ROLE-CAPABILITIES-MATRIX.md)
- **WordPress Roles & Capabilities:** [WordPress Developer Docs](https://developer.wordpress.org/plugins/users/roles-and-capabilities/)
- **current_user_can() Reference:** [WordPress Function Reference](https://developer.wordpress.org/reference/functions/current_user_can/)

---

**Lesson Status:** ✅ Documented  
**Applied To:** Manager Admin Page (user-requests-display.php)  
**Key Takeaway:** Use role-based checks for custom business logic, capability checks for WordPress standards  
**Impact:** Enables Manager/Operator access to undo actions (consistent permissions)
