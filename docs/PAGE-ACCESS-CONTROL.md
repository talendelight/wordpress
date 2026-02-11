# Page Access Control - URL-Based

**Version:** v3.6.1  
**Last Updated:** February 11, 2026  
**Implementation:** `wp-content/plugins/talendelight-roles/talendelight-roles.php`  
**Purpose:** Role-based page access restrictions with consistent redirect behavior

---

## Overview

Page-level access control is implemented using dedicated restriction functions in the `talendelight-roles` plugin. Each landing page has its own access control function with consistent redirect behavior.

**Security Principle:** "Deny by default, allow by exception"
- Each role has access ONLY to their designated landing pages
- Unauthorized access redirects to login (not authenticated) or `/403-forbidden/` (wrong role)
- Administrators bypass all restrictions
- **Consistent behavior:** All unauthorized access attempts redirect to `/403-forbidden/` with URL change (no inline error pages)

---

## Page Access Matrix

| URL Pattern | Allowed Roles | Description |
|-------------|---------------|-------------|
| `/candidates/` | `td_candidate`, `administrator` | Candidate landing page |
| `/employers/` | `td_employer`, `administrator` | Employer landing page |
| `/scouts/` | `td_scout`, `administrator` | Scout landing page |
| `/managers/` | `td_manager`, `administrator` | Manager dashboard |
| `/operators/` | `td_operator`, `administrator` | Operator dashboard (Managers NOT allowed) |

**Access Denied Page:** `/403-forbidden/`  
**Login Redirect:** Not authenticated → WordPress login with `auth_redirect()`

---

## Implementation

Access control is implemented in `wp-content/plugins/talendelight-roles/talendelight-roles.php` with dedicated functions for each landing page:

- `talendelight_restrict_operators_page()` - Priority 5
- `talendelight_restrict_managers_page()` - Priority 5
- `talendelight_restrict_employers_page()` - Priority 5
- `talendelight_restrict_candidates_page()` - Priority 5
- `talendelight_restrict_scouts_page()` - Priority 5

**Consistent Redirect Behavior:**
```php
// All functions follow this pattern
if (!$has_access) {
    wp_redirect(home_url('/403-forbidden/'));
    exit;
}
```

**Key Benefits:**
- ✅ **Consistent user experience**: All unauthorized access attempts redirect to `/403-forbidden/` with URL change
- ✅ **No inline errors**: Eliminated `wp_die()` fallbacks that showed errors without URL change
- ✅ **Clean separation**: Each landing page has its own restriction function
- ✅ **Early execution**: Priority 5 ensures access checks run before page rendering
- ✅ **Maintainable**: Clear function names and single responsibility

---

## Redirect Behavior

### Before (v3.6.0 and earlier)
- **Operators page:** Showed inline `wp_die()` error if `/403-forbidden/` page not found (URL stayed as `/operators/`)
- **Other pages:** No access control - all users could access all landing pages

### After (v3.6.1+)
- **All landing pages:** Consistent redirect to `/403-forbidden/` with URL change
- **No fallbacks:** Direct redirect without checking if `/403-forbidden/` exists
- **Uniform experience:** Same behavior across all protected pages

---

## Data-Level Access Control (Separate from Page Access)

**Important:** Page access control is ONLY about which pages users can visit. Data filtering is handled separately in `user-requests-display.php`.

### Page Access (PublishPress Capabilities)
- ✅ Can Manager access `/managers/actions/` page? → YES
- ✅ Can Operator access `/managers/actions/` page? → NO (403 redirect)

### Data Access (Custom Code)
- ✅ What user requests does Manager see on `/managers/actions/`? → ALL requests
- ✅ What user requests does Operator see on `/operators/actions/`? → Only Candidate/Employer requests, only unassigned OR assigned-to-me

**See:** `wp-content/mu-plugins/user-requests-display.php` for data filtering logic

---

## Testing Checklist

### Test 1: Manager Role Access
- [ ] **Login as Manager**
  - Navigate to `/managers/` → ✅ Should load
  - Navigate to `/operators/` → ❌ Should redirect to `/403-forbidden/` (URL changes)
  - Navigate to `/employers/` → ❌ Should redirect to `/403-forbidden/` (URL changes)
- [ ] **Not Logged In**
  - Logout
  - Navigate to `/managers/` → ❌ Should redirect to login page
  - Login → ✅ Should access `/managers/`

### Test 2: Operator Role Access
- [ ] **Login as Operator**
  - Navigate to `/operators/` → ✅ Should load
  - Navigate to `/managers/` → ❌ Should redirect to `/403-forbidden/` (URL changes)
  - Navigate to `/candidates/` → ❌ Should redirect to `/403-forbidden/` (URL changes)

### Test 3: Employer/Candidate/Scout Access
- [ ] **Login as Employer**
  - Navigate to `/employers/` → ✅ Should load
  - Navigate to `/candidates/` → ❌ Should redirect to `/403-forbidden/` (URL changes)
  - Navigate to `/operators/` → ❌ Should redirect to `/403-forbidden/` (URL changes)
- [ ] **Login as Candidate**
  - Navigate to `/candidates/` → ✅ Should load
  - Navigate to `/employers/` → ❌ Should redirect to `/403-forbidden/` (URL changes)
- [ ] **Login as Scout**
  - Navigate to `/scouts/` → ✅ Should load
  - Navigate to `/managers/` → ❌ Should redirect to `/403-forbidden/` (URL changes)

### Test 4: Administrator Override
- [ ] **Login as Administrator**
  - Navigate to all protected URLs → ✅ All should load
  - `/managers/`, `/operators/`, `/candidates/`, `/employers/`, `/scouts/`

### Test 5: Consistent Redirect Behavior
- [ ] **Login as Manager**
  - Navigate to `/operators/` → ❌ Should redirect to `/403-forbidden/` (URL changes to `/403-forbidden/`)
  - Verify no inline error page (no `wp_die()` error)
  - Verify URL bar shows `/403-forbidden/` not `/operators/`
- [ ] **Login as Operator**  
  - Navigate to `/managers/` → ❌ Should redirect to `/403-forbidden/` (URL changes)
  - Verify consistent behavior across all protected pages

---

## Troubleshooting

### Issue: Manager can't access their pages

**Symptoms:** Manager role redirected to `/403-forbidden/` when accessing `/managers/` pages

**Solution:**
1. Verify user has `td_manager` role:
   ```bash
   wp user get {username} --field=roles
   ```
2. Check access control code in `functions.php` is active (search for `template_redirect`)
3. Verify URL pattern matching: URLs should start with `/managers/`
4. Test with administrator account to rule out page issues
5. Check WordPress permalink structure is set correctly (Settings → Permalinks)

### Issue: Operator can access Manager pages

**Symptoms:** Operator role can view `/managers/` pages (should be blocked)

**Solution:**
1. Verify URL pattern is `/managers/` (not `/manager-`)
2. Check `$role_pages` array in `functions.php` for typos
3. Clear browser cache and cookies
4. Test in incognito mode

### Issue: Login redirect loop

**Symptoms:** Redirects between login page and protected page repeatedly

**Solution:**
1. Verify `/log-in/` page exists and is accessible to all users
2. Check login page URL is NOT in protected patterns
3. Clear WordPress cache (if using caching plugin)
4. Check for conflicting plugins (try disabling temporarily)
5. Clear browser cookies and session data

### Issue: URL pattern not matching subpages

**Symptoms:** `/managers/` loads but `/managers/admin/` redirects

**Solution:**
1. Verify pattern uses `strpos($current_url, '/managers/') === 0` (prefix match)
2. Check for typos in URL (case-sensitive on some servers)
3. Verify permalink structure matches expected URLs
4. Check for URL rewrite conflicts in `.htaccess`

### Issue: Administrator redirected

**Symptoms:** Administrator account gets `/403-forbidden/` on protected pages

**Solution:**
1. Verify user has `administrator` role (not custom admin role)
2. Check `array_intersect` logic includes `'administrator'` in allowed roles
3. Clear all caches (WordPress, browser, server)
4. Check for role conflicts from other plugins

### Issue: Different behavior local vs production

**Symptoms:** Access control works locally but not on production

**Solution:**
1. Verify `functions.php` deployed correctly to production
2. Check PHP error logs for syntax errors
3. Verify WordPress version compatibility (PHP 7.4+)
4. Test URL patterns match production structure
5. Check server configuration (mod_rewrite enabled)

---

## Future Enhancements

**Planned Features:**
- [ ] Audit logging integration (track who accessed which pages when)
- [ ] Time-based access restrictions (e.g., Operators only access during business hours)
- [ ] IP-based restrictions for sensitive Manager pages
- [ ] Two-factor authentication for Manager role
- [ ] Rate limiting for failed access attempts

**Backlog Items:**
- WP-04.4: Advanced capability management (beyond page access)
- WP-07.5: Security headers (CSP, HSTS) for sensitive pages

---

## References

- **Related:** [PENG-053: Block /wp-admin/ access](PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md)
- **Related:** [ROLE-CAPABILITIES-MATRIX.md](ROLE-CAPABILITIES-MATRIX.md)
- **Backlog:** [WORDPRESS-BACKLOG.md](../../Documents/WORDPRESS-BACKLOG.md)

---

## Change Log

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-11 | v3.6.1 | Add access control for all landing pages with consistent redirect behavior (no wp_die fallbacks) | System |
| 2026-02-11 | v3.6.1 | Remove manager access to operators page (operators only) | System |
| 2026-02-10 | v3.6.0 | Migrate to URL-based access control (environment-agnostic) | System |
| 2026-02-02 | v3.5.0 | Initial documentation - page access control system | System |

---
