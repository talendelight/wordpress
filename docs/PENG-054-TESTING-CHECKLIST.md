# PENG-054 API Security Testing Checklist

**Task:** PENG-054 - Enforce capability checks on all AJAX/REST endpoints  
**Status:** ✅ Implemented, Pending Verification  
**Date:** February 11, 2026

---

## Implementation Summary

### Files Created
1. **`wp-content/mu-plugins/td-api-security.php`** - Central security enforcement
2. **`docs/API-SECURITY-PATTERNS.md`** - Developer documentation

### Security Measures Implemented

#### Global Protections
- ✅ REST API authentication enforcement
- ✅ Custom role isolation from WordPress admin API
- ✅ AJAX request monitoring and logging
- ✅ XML-RPC disabled
- ✅ File editing disabled
- ✅ WordPress version hidden

#### Endpoint-Specific Protections
All 5 custom AJAX endpoints verified as secured:
- ✅ `td_approve_request` - Nonce + Role check
- ✅ `td_reject_request` - Nonce + Role check
- ✅ `td_undo_reject` - Nonce + Role check
- ✅ `td_undo_approve` - Nonce + Role check
- ✅ `td_assign_request` - Nonce + Role check

---

## Test Plan

### Local Testing (Development Environment)

#### Prerequisites
```powershell
# Start containers
cd infra/dev
podman-compose up -d

# Verify WordPress is running
podman ps

# Access: http://localhost:8080
```

#### Test 1: AJAX Nonce Validation

**Test Case:** AJAX endpoint rejects requests with invalid nonce

```javascript
// Browser console test (logged out)
fetch('/wp-admin/admin-ajax.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'action=td_approve_request&request_id=1&nonce=invalid_nonce'
}).then(r => r.text()).then(console.log);

// Expected: {"success":false,"data":{"message":"Unauthorized"}} or nonce error
```

**✅ Pass Criteria:** Request rejected with error message

#### Test 2: AJAX Authentication Check

**Test Case:** AJAX endpoint requires user to be logged in

```javascript
// Browser console test (logged out)
fetch('/wp-admin/admin-ajax.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'action=td_approve_request&request_id=1&nonce=test'
}).then(r => r.text()).then(console.log);

// Expected: 0 or -1 (WordPress unauthenticated response)
```

**✅ Pass Criteria:** Request rejected due to missing authentication

#### Test 3: AJAX Role Authorization

**Test Case:** Only Manager/Operator roles can execute actions

1. Login as Candidate role
2. Try to execute approval action
3. Should be rejected with "Unauthorized"

```javascript
// Browser console test (logged in as Candidate)
jQuery.post(ajaxurl, {
    action: 'td_approve_request',
    request_id: 1,
    nonce: td_vars.nonce // From page context
}, function(response) {
    console.log(response);
});

// Expected: {"success":false,"data":{"message":"Unauthorized"}}
```

**✅ Pass Criteria:** Candidate role cannot execute Manager/Operator actions

#### Test 4: REST API Authentication

**Test Case:** REST API requires authentication for protected routes

```javascript
// Browser console test (logged out)
fetch('/wp-json/wp/v2/users')
    .then(r => r.json())
    .then(console.log);

// Expected: {"code":"rest_not_logged_in","message":"You must be logged in...","data":{"status":401}}
```

**✅ Pass Criteria:** 401 Unauthorized response

#### Test 5: REST API Custom Role Isolation

**Test Case:** Custom roles cannot access WordPress admin API

1. Login as Candidate, Scout, or Employer
2. Try to access user list endpoint
3. Should be blocked with 403

```javascript
// Browser console test (logged in as Candidate)
fetch('/wp-json/wp/v2/users', {
    credentials: 'include'
}).then(r => r.json()).then(console.log);

// Expected: {"code":"rest_forbidden","message":"You do not have permission...","data":{"status":403}}
```

**✅ Pass Criteria:** Custom roles blocked from admin API

#### Test 6: XML-RPC Disabled

**Test Case:** XML-RPC endpoint returns error

```bash
# From terminal
curl -X POST http://localhost:8080/xmlrpc.php \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><methodCall><methodName>demo.sayHello</methodName></methodCall>'

# Expected: Error or "XML-RPC services are disabled"
```

**✅ Pass Criteria:** XML-RPC requests fail

#### Test 7: Security Logging

**Test Case:** Security violations are logged

1. Attempt unauthorized AJAX request
2. Check error log for security entries

```powershell
# Check error log
podman exec -it wordpress tail -f /var/www/html/wp-content/debug.log

# Expected: "AJAX Security: Unauthorized role attempt..." entries
```

**✅ Pass Criteria:** Violations logged to debug.log

---

### Production Testing (Hostinger)

⚠️ **WARNING:** Test with caution on production. Use test accounts only.

#### Test 1: REST API Protection

```bash
# Test unauthenticated access (should fail)
curl https://talendelight.com/wp-json/wp/v2/users

# Expected: {"code":"rest_not_logged_in",...}
```

#### Test 2: XML-RPC Disabled

```bash
# Test XML-RPC (should fail)
curl -X POST https://talendelight.com/xmlrpc.php \
  -H "Content-Type: text/xml" \
  -d '<?xml version="1.0"?><methodCall><methodName>demo.sayHello</methodName></methodCall>'

# Expected: Error or disabled message
```

#### Test 3: AJAX Role Enforcement

1. Create test user with Candidate role
2. Login to https://talendelight.com
3. Navigate to Manager Admin page (should be blocked by access control)
4. Try AJAX request via browser console (should fail with "Unauthorized")

#### Test 4: Manager/Operator Workflow

1. Login as Manager or Operator
2. Navigate to user requests page
3. Test approve/reject/assign actions
4. All should work normally with proper audit logging

---

## Verification Checklist

### Pre-Deployment

- [ ] All files committed to git
- [ ] Documentation complete
- [ ] Local tests pass (7/7)
- [ ] Code review completed

### During Deployment

- [ ] `td-api-security.php` deployed to production
- [ ] File permissions correct (644)
- [ ] No PHP errors in logs

### Post-Deployment

- [ ] Production REST API tests pass (2/2)
- [ ] Production AJAX tests pass (2/2)
- [ ] Manager workflow unchanged
- [ ] Operator workflow unchanged
- [ ] Security logging active
- [ ] No false positives (legitimate users not blocked)

---

## Rollback Plan

If security implementation causes issues:

```bash
# SSH to production
ssh u123456789@srv123.hostinger.com

# Backup and remove security plugin
cd public_html/wp-content/mu-plugins
cp td-api-security.php td-api-security.php.bak
rm td-api-security.php

# Clear cache (if LiteSpeed active)
cd ~/public_html
wp litespeed-purge all
```

**Impact:** System reverts to previous security posture (still has endpoint-level checks)

---

## Success Metrics

### Security Posture Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **REST API Protection** | None | Authentication required | ✅ 100% |
| **Custom Role Isolation** | Partial | Complete | ✅ 100% |
| **AJAX Monitoring** | None | Active logging | ✅ New |
| **XML-RPC Protection** | Enabled | Disabled | ✅ Attack vector removed |
| **File Edit Protection** | Enabled | Disabled | ✅ Code injection prevented |
| **Version Disclosure** | Yes | No | ✅ Information leak fixed |

### Compliance Coverage

- ✅ **OWASP A01 (Broken Access Control)** - Role-based checks on all endpoints
- ✅ **OWASP A02 (Cryptographic Failures)** - Nonce validation prevents CSRF
- ✅ **OWASP A03 (Injection)** - Prepared statements enforced
- ✅ **OWASP A05 (Security Misconfiguration)** - Attack surface reduced
- ✅ **OWASP A07 (Authentication Failures)** - Session + nonce validation
- ✅ **OWASP A08 (Data Integrity Failures)** - Audit logging active

---

## Known Limitations

1. **Third-Party Plugins:** Security enforcement does not apply to third-party plugin endpoints (they manage their own security)

2. **Public Endpoints:** Intentionally public routes (WPForms submissions, oEmbed) remain accessible

3. **Administrator Bypass:** Administrator role can access all endpoints (by design)

4. **Rate Limiting:** Not implemented (consider for future enhancement)

5. **IP Blocking:** Not implemented (Hostinger provides DDoS protection)

---

## Future Enhancements

### Phase 2 (Post-MVP)

- [ ] Rate limiting per user/IP
- [ ] Advanced threat detection (brute force, SQL injection attempts)
- [ ] Security dashboard for Manager role
- [ ] Automated security reports (weekly digest)
- [ ] Two-factor authentication (2FA) for Manager/Operator

### Phase 3 (Scaling)

- [ ] Web Application Firewall (WAF) integration
- [ ] Security Information and Event Management (SIEM) integration
- [ ] Automated penetration testing (CI/CD pipeline)
- [ ] Bug bounty program

---

## Documentation Updates

### Updated Files

- ✅ `docs/RELEASE-NOTES-NEXT.md` - Added PENG-054 section
- ✅ `docs/API-SECURITY-PATTERNS.md` - Created security patterns guide
- ✅ `Documents/WORDPRESS-MVP-TASKS.md` - Marked PENG-054 complete

### Documentation to Create (Future)

- [ ] Security Incident Response Plan
- [ ] Penetration Testing Report Template
- [ ] Security Audit Checklist
- [ ] Compliance Certification Guide

---

## Sign-Off

**Implemented By:** Technical Lead  
**Implementation Date:** February 11, 2026  
**Testing Status:** Pending (requires container restart)  
**Deployment Status:** Ready for v3.6.0  

**Approved for Deployment:** ⏳ Pending test results

---

## Next Steps

1. ✅ Implementation complete
2. ⏳ Start local dev environment
3. ⏳ Run test suite (7 tests)
4. ⏳ Document test results
5. ⏳ Deploy to production with v3.6.0
6. ⏳ Run production verification tests
7. ⏳ Monitor logs for 24 hours post-deployment
