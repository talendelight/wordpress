# Page Access Control - PublishPress Capabilities

**Version:** v3.5.0  
**Last Updated:** February 2, 2026  
**Plugin:** PublishPress Capabilities v2.31.0  
**Purpose:** Role-based page access restrictions for Manager and Operator dashboards

---

## Overview

This document describes how page-level access control is implemented using PublishPress Capabilities plugin to restrict Manager and Operator pages by role.

**Security Principle:** "Deny by default, allow by exception"
- Manager pages are ONLY accessible to `administrator` and `td_manager` roles
- Operator pages are ONLY accessible to `administrator` and `td_operator` roles
- All other roles get 403 Access Denied redirect

---

## Page Access Matrix

| Page ID | Page Name | URL | Allowed Roles |
|---------|-----------|-----|---------------|
| **469** | Managers (Dashboard) | /managers/ | administrator, td_manager |
| **386** | Manager Admin | /managers/admin/ | administrator, td_manager |
| **670** | Manager Actions | /managers/actions/ | administrator, td_manager |
| **299** | Operators (Dashboard) | /operators/ | administrator, td_operator |
| **666** | Operator Actions | /operators/actions/ | administrator, td_operator |

**Access Denied Page:** ID 152 - `/403-forbidden/`

---

## Configuration Steps (Manual - Production)

### Step 1: Access Plugin Settings

1. Login to WordPress admin as Administrator
2. Navigate to **Users → Capabilities**
3. Select the role to configure (e.g., "Manager")

### Step 2: Configure Page Restrictions

**For Manager Role:**
1. Go to **Capabilities → Page Restrictions**
2. Select pages to ALLOW access:
   - ✅ Managers (ID 469)
   - ✅ Manager Admin (ID 386)
   - ✅ Manager Actions (ID 670)
3. Set restriction mode: **"Allow only selected pages"**
4. Save settings

**For Operator Role:**
1. Go to **Capabilities → Page Restrictions**
2. Select pages to ALLOW access:
   - ✅ Operators (ID 299)
   - ✅ Operator Actions (ID 666)
3. Set restriction mode: **"Allow only selected pages"**
4. Save settings

**For Other Roles (Candidate, Employer, Scout):**
- No explicit page restrictions needed
- These roles don't have access to admin pages by design
- Already blocked by /wp-admin/ access control (PENG-053)

---

## Alternative: Programmatic Configuration (Optional)

If PublishPress Capabilities supports programmatic configuration, add to MU-plugin:

```php
<?php
/**
 * Plugin Name: TalenDelight Page Access Control
 * Description: Configure page restrictions via PublishPress Capabilities
 * Version: 1.0.0
 */

add_action('init', function() {
    if (function_exists('cme_update_page_restrictions')) {
        
        // Manager role restrictions
        cme_update_page_restrictions('td_manager', [
            'allowed_pages' => [469, 386, 670],
            'mode' => 'whitelist',
        ]);
        
        // Operator role restrictions
        cme_update_page_restrictions('td_operator', [
            'allowed_pages' => [299, 666],
            'mode' => 'whitelist',
        ]);
    }
});
```

**Note:** Check PublishPress Capabilities documentation for actual API if available.

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

### Test 1: Manager Page Access
- [ ] Login as Manager → Navigate to `/managers/admin/` → ✅ Should load
- [ ] Login as Manager → Navigate to `/managers/actions/` → ✅ Should load
- [ ] Login as Operator → Navigate to `/managers/admin/` → ❌ Should redirect to `/403-forbidden/`

### Test 2: Operator Page Access
- [ ] Login as Operator → Navigate to `/operators/` → ✅ Should load
- [ ] Login as Operator → Navigate to `/operators/actions/` → ✅ Should load
- [ ] Login as Manager → Navigate to `/operators/actions/` → ✅ Should load (Managers can access Operator pages)

### Test 3: Administrator Access
- [ ] Login as Administrator → Navigate to any page → ✅ Should always load (full access)

### Test 4: Unauthorized Roles
- [ ] Login as Candidate → Navigate to `/managers/admin/` → ❌ Should redirect to `/403-forbidden/`
- [ ] Login as Employer → Navigate to `/operators/` → ❌ Should redirect to `/403-forbidden/`
- [ ] Login as Scout → Navigate to `/managers/actions/` → ❌ Should redirect to `/403-forbidden/`

---

## Migration from Custom Code (v3.4.0 → v3.5.0)

**Previous Implementation (v3.4.0):**
```php
// blocksy-child/functions.php
add_action('template_redirect', function() {
    // Custom hook with hardcoded page IDs and role checks
});
```

**New Implementation (v3.5.0):**
- ✅ PublishPress Capabilities plugin handles page restrictions
- ✅ UI-based configuration (no code changes for new pages)
- ✅ Professional features (audit log, bulk operations, role cloning)
- ✅ Custom template_redirect hook removed

**Benefits:**
- Reduced maintenance burden (one less custom hook)
- Better UX for permission management (UI vs code)
- Community-tested security patterns
- Audit trail for permission changes

---

## Troubleshooting

### Issue: Manager can't access their pages
**Solution:** Check PublishPress Capabilities settings for `td_manager` role, ensure pages 469, 386, 670 are in allowed list

### Issue: Operator sees empty dashboard
**Solution:** This is a data filtering issue, not page access. Check `user-requests-display.php` data filtering logic

### Issue: Administrator blocked from pages
**Solution:** Administrator should NEVER be blocked. Check if page restrictions accidentally applied to Administrator role

### Issue: 403 page not showing properly
**Solution:** Verify page ID 152 exists and is published. Check Elementor template is properly configured

---

## Future Enhancements (Post-v3.5.0)

**Planned Features:**
- [ ] Audit logging integration (track who accessed which pages when)
- [ ] Time-based access restrictions (e.g., Operators only access during business hours)
- [ ] IP-based restrictions for sensitive Manager pages
- [ ] Two-factor authentication for Manager role

**Backlog Items:**
- WP-04.4: Advanced capability management (beyond page access)
- WP-07.5: Security headers (CSP, HSTS) for sensitive pages

---

## References

- **Plugin:** [PublishPress Capabilities](https://wordpress.org/plugins/capability-manager-enhanced/)
- **Documentation:** [PublishPress Capabilities Docs](https://publishpress.com/knowledge-base/capabilities/)
- **Related:** [PENG-053: Block /wp-admin/ access](PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md)
- **Related:** [ROLE-CAPABILITIES-MATRIX.md](ROLE-CAPABILITIES-MATRIX.md)
- **Backlog:** WP-04.3 (Replace custom template_redirect)

---

## Change Log

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-02 | 1.0.0 | Initial documentation - PublishPress Capabilities migration | System |
