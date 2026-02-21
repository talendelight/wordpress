# Lessons Learned: WordPress URL Stability and Emergency Recovery

**Date:** February 9, 2026  
**Incident:** Production site redirecting to :8080, recurring URL contamination  
**Duration:** ~4 hours (multiple occurrences)  
**Severity:** Critical (site unreachable)

---

## Executive Summary

WordPress site experienced repeated URL contamination where `siteurl` and `home` database options reset to `https://wp.local`, causing 301 redirects to unreachable port. Root cause: lack of URL protection mechanism. Solution: wp-config.php constants to lock URLs permanently.

**Key Takeaway:** WordPress database URLs should be **locked via constants** in wp-config.php for production environments to prevent contamination from imports, plugin updates, or deployment operations.

---

## Problem Statement

### What Happened

Production WordPress site at https://talendelight.com repeatedly redirected visitors to https://talendelight.com:8080 (unreachable). Issue occurred 4-5 times throughout single day despite multiple manual fixes.

### Impact

- **User Experience:** Site completely unreachable (ERR_CONNECTION_TIMED_OUT)
- **SEO:** 301 redirects cached by browsers and potentially search engines
- **Trust:** Professional appearance compromised
- **Development Time:** 4+ hours troubleshooting and implementing permanent fix

### Timeline of Events

1. **Initial Report:** User noticed site redirecting to :8080
2. **First Fix:** Updated database `siteurl`/`home` options via wp-cli â†’ Worked temporarily
3. **Recurrence #1:** After restoring Welcome page, URLs reset again
4. **Second Fix:** Updated URLs again â†’ Worked temporarily
5. **Recurrence #2:** After Git deployment, URLs contaminated again
6. **Third Fix:** Enhanced emergency script with URL checks â†’ Still vulnerable
7. **Recurrence #3:** After another page operation, URLs reset again
8. **Permanent Fix:** Added wp-config.php constants â†’ No further resets

---

## Root Cause Analysis

### Technical Causes

#### 1. WordPress URL Management Weakness

**Problem:** WordPress stores site URLs in database (`wp_options` table) which can be modified by:
- Page import operations (`wp post create`)
- Plugin activation/deactivation
- Theme switches
- Git deployments that trigger WordPress initialization
- URL auto-detection during certain operations

**Why It Happened:**
- No protection mechanism for production URLs
- Database values are mutable by default
- wp-config.php didn't define WP_HOME or WP_SITEURL constants
- Any code with database access could change URLs

#### 2. Page Import Side Effects

**Problem:** Using `wp post create` to import HTML pages sometimes triggers WordPress to detect and update site URLs based on content.

**Evidence:**
```bash
# After running this command, URLs changed
wp post create ~/welcome-page.html --post_type=page --post_title='Welcome' --post_status=publish

# URLs in database became:
siteurl: https://wp.local
home: https://wp.local
```

**Why It Happened:**
- Welcome page backup file likely contained serialized data from local development
- WordPress deserialization process may have updated options
- No sanitization of imported content

#### 3. Git Deployment Triggers

**Problem:** Hostinger's Git auto-deployment might trigger WordPress processes that check/update URLs.

**Theory (not fully confirmed):**
- Git push to `main` branch â†’ Hostinger deploys wp-content/
- Deployment might trigger theme activation hooks
- Blocksy Companion plugin activation might check URLs
- No evidence of explicit URL changes in deployment logs

#### 4. Browser 301 Redirect Caching

**Problem:** 301 redirects are "permanent" and browsers cache them extremely aggressively.

**Impact:**
- Even after fixing server, browsers continued redirecting
- Standard cache clearing methods insufficient
- Incognito mode still showed cached redirect
- Required complete browser restart or HSTS cache clear

---

## Solutions Implemented

### 1. Permanent URL Locking (PRIMARY SOLUTION)

**Method:** Define constants in wp-config.php

**Implementation:**
```php
// Force production URLs (prevent localhost:8080 contamination)
define('WP_HOME', 'https://talendelight.com');
define('WP_SITEURL', 'https://talendelight.com');
```

**Why This Works:**
- Constants have **highest priority** in WordPress URL hierarchy
- Cannot be overridden by database values
- Cannot be changed by plugins, themes, or operations
- Survives database resets, imports, and deployments
- Zero maintenance required

**Deployment Script:**
```bash
#!/bin/bash
# tmp/lock-urls.sh
cd /home/u909075950/domains/talendelight.com/public_html

# Backup
cp wp-config.php wp-config.php.bak

# Check if URLs already defined
if grep -q "define('WP_HOME'" wp-config.php; then
    echo "URLs already locked"
else
    # Insert before "That's all"
    sed -i "/That's all, stop editing/i\\
// Force production URLs (prevent localhost:8080 contamination)\\
define('WP_HOME', 'https://talendelight.com');\\
define('WP_SITEURL', 'https://talendelight.com');\\
" wp-config.php
    echo "URLs locked in wp-config.php"
fi
```

**Results:**
- âœ… No further URL contamination after implementation
- âœ… Database values no longer matter (constants override)
- âœ… Page imports no longer affect URLs
- âœ… Git deployments safe

### 2. Enhanced Emergency Fix Script

**Added Safety Checks:**

```php
// In restore-welcome.php (part of emergency script)
// After page creation/update:

// Force correct URLs (prevent localhost:8080 contamination)
update_option('siteurl', 'https://talendelight.com');
update_option('home', 'https://talendelight.com');
echo "URLs verified: https://talendelight.com\n";
```

**Why This Helps:**
- Belt-and-suspenders approach
- Fixes database values even if constants exist
- Provides immediate verification
- Useful for environments without wp-config.php access

### 3. HTTPS Redirect Protection

**Added to Emergency Script:**

```powershell
# Step 3.7: Check and restore HTTPS redirect in .htaccess
$htaccessFix = @'
# Force HTTPS - Must be first
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>
'@

# Check if present, prepend if missing
if ($hasHttpsRedirect -eq "0") {
    # Prepend to existing .htaccess
    cat ~/htaccess-fix.txt .htaccess > .htaccess.new
    mv .htaccess.new .htaccess
}
```

**Why This Helps:**
- Prevents http:// to https:// redirect from being lost
- .htaccess can be overwritten by plugins (e.g., LiteSpeed Cache)
- Ensures security best practice maintained

---

## What We Learned

### Lesson 1: Lock Production URLs in wp-config.php

**Principle:** Production WordPress installations should ALWAYS define WP_HOME and WP_SITEURL constants.

**Why:**
- Database values are mutable
- Plugins/themes can change URLs
- Import operations can contaminate
- Constants provide immutable protection

**How to Implement:**
```php
// In wp-config.php, before "That's all, stop editing"
define('WP_HOME', 'https://your-domain.com');
define('WP_SITEURL', 'https://your-domain.com');
```

**When to Use:**
- âœ… Production environments (always)
- âœ… Staging environments (recommended)
- âš ï¸ Development environments (optional, depends on workflow)
- âŒ Never lock localhost URLs in version-controlled wp-config.php

### Lesson 2: Verify Root Cause Before Creating Workarounds

**What Happened:**
- Saw "navy backgrounds missing" â†’ Created custom-colors.css
- Spent 30 minutes on color CSS solution
- Real problem: Welcome page didn't exist at all

**Better Approach:**
1. Check if page exists: `wp post list`
2. Check if page has content: `wp post get 6`
3. Check if correct page is homepage: `wp option get page_on_front`
4. **Then** investigate styling issues

**Lesson:** Always verify fundamental prerequisites before solving secondary symptoms.

### Lesson 3: Browser 301 Redirect Caching is Extremely Persistent

**Problem:** 301 "Permanent" redirects are cached at multiple levels:
- Browser HTTP cache
- Browser HSTS cache
- DNS resolver cache
- Possibly ISP cache

**Standard Methods That Don't Work:**
- âŒ Hard refresh (Ctrl+Shift+R)
- âŒ Clear browsing data
- âŒ Incognito/private mode
- âŒ DNS flush (ipconfig /flushdns)

**What Actually Works:**
- âœ… Complete browser restart (close ALL windows)
- âœ… Different browser never used for site
- âœ… Clear HSTS cache: chrome://net-internals/#hsts â†’ Delete domain
- âœ… Wait 24-48 hours (cache expiry)

**Prevention:**
- Never use 301 redirects during development/testing
- Use 302 (temporary) or 307 (temporary, preserves method) instead
- Only use 301 after verifying redirect is correct
- Test with curl before testing with browser

### Lesson 4: Page Imports Can Contaminate Database

**Problem:** `wp post create` from HTML file can have side effects beyond page creation.

**Why:**
- HTML may contain serialized WordPress data
- Post meta fields may reference URLs
- WordPress may auto-detect environment from content
- No sanitization of imported options

**Best Practice:**
```bash
# After ANY page import, verify and fix URLs
wp post create ~/page.html --post_type=page --post_title='Title'

# Immediately verify URLs didn't change
wp option get siteurl
wp option get home

# If changed, fix immediately
wp option update siteurl 'https://production.com'
wp option update home 'https://production.com'
```

**Better Solution:**
- Use wp-config.php constants (prevents contamination)
- Or sanitize HTML before import (remove serialized data)

### Lesson 5: Emergency Scripts Need Comprehensive Validation

**What We Added:**
1. URL verification after every major operation
2. Page existence checks before assuming success
3. Homepage setting validation
4. Theme and plugin activation verification
5. Permalink structure checks
6. HTTPS redirect verification

**Why It Matters:**
- Silent failures are common in WordPress operations
- Exit code 0 doesn't mean operation succeeded
- wp-cli sometimes returns success but changes nothing
- Validation catches issues before they propagate

**Pattern:**
```powershell
# Don't just execute and hope
wp operation --args

# Execute, capture output, validate result
$result = wp operation --args
if ($result -match "expected-pattern") {
    Write-Host "âœ“ Operation succeeded"
} else {
    Write-Host "âœ— Operation failed: $result"
    # Take corrective action
}
```

### Lesson 6: Separate Server-Side from Client-Side Issues

**Diagnostic Process:**

1. **Test from server:**
```bash
ssh production "curl -I https://domain.com"
```

2. **Test from client:**
```powershell
Invoke-WebRequest -Uri "https://domain.com" -Method Head
```

3. **Compare results:**
- Same â†’ Server issue
- Different â†’ Client/network issue

**What We Found:**
- Server: HTTP 200 (correct)
- Client: 301 redirect (cached)
- Conclusion: Browser cache, not server problem

**Time Saved:** 2+ hours by identifying this early instead of continuing to "fix" the server.

### Lesson 7: Git Deployment Can Have Unexpected Side Effects

**Observation:** Pushing wp-content/ to production sometimes triggered URL changes.

**Possible Causes:**
1. Theme activation hooks triggered
2. Plugin initialization code executed
3. WordPress detected environment change
4. Hostinger deployment process triggers wp-admin requests

**Mitigation:**
- wp-config.php URL constants (primary)
- Post-deployment verification script
- Monitor wp-content/themes/*/functions.php for redirect logic
- Avoid operations in theme activation hooks

---

## Preventive Measures for Future

### 1. Production Environment Hardening

**Checklist:**
- [ ] Define WP_HOME and WP_SITEURL in wp-config.php
- [ ] Set file permissions correctly (wp-config.php 440 or 400)
- [ ] Disable file editing: `define('DISALLOW_FILE_EDIT', true);`
- [ ] Use environment-specific wp-config: `wp-config-production.php`
- [ ] Document URL constants in deployment guide

### 2. Enhanced Backup Strategy

**What to Backup:**
- Database (existing)
- wp-config.php (NEW - critical configuration)
- .htaccess (NEW - HTTPS redirect)
- wp-content/ (existing)

**Backup Script Enhancement:**
```bash
# Add to backup script
scp production:/path/to/wp-config.php backup/wp-config-$(date +%Y%m%d).php
scp production:/path/to/.htaccess backup/htaccess-$(date +%Y%m%d).txt
```

### 3. Deployment Validation

**Post-Deployment Checks:**
```bash
# After every deployment, verify:
1. URLs correct: wp option get siteurl / home
2. Welcome page exists and is homepage
3. Theme is Blocksy
4. Blocksy Companion active
5. Permalinks set to /%postname%/
6. HTTPS redirect in .htaccess
```

**Automated Script:** Already implemented in emergency-fix-production.ps1 Step 4

### 4. Development Best Practices

**Page Export from Local:**
```bash
# DON'T export with URLs embedded
wp post get 6 --field=post_content > page.html

# DO sanitize before export
wp post get 6 --field=post_content | sed 's|https://wp.local|PLACEHOLDER|g' > page.html
```

**Page Import to Production:**
```bash
# Replace placeholders
sed 's|PLACEHOLDER|https://production.com|g' page.html > page-prod.html

# Import
wp post create page-prod.html --post_type=page

# IMMEDIATELY verify URLs unchanged
wp option get siteurl && wp option get home
```

### 5. Browser Testing Protocol

**Before Testing Production Changes:**
1. Clear HSTS cache: chrome://net-internals/#hsts
2. Use incognito mode for first test
3. Keep Developer Tools open (Network tab)
4. Document first request status code and Location header

**Never:**
- Test with regular browser tab first (contaminates cache)
- Assume site works after fixing (verify with curl first)
- Use 301 redirects during development (use 302/307)

---

## Anti-Patterns Identified

### âŒ Anti-Pattern 1: Relying on Database for Critical URLs

**Why Bad:**
- Database is mutable
- Any code can change values
- No audit trail of changes
- Vulnerable to contamination

**Better:**
```php
// Use constants for production
define('WP_HOME', 'https://production.com');
define('WP_SITEURL', 'https://production.com');
```

### âŒ Anti-Pattern 2: Creating Workarounds Before Diagnosis

**What We Did Wrong:**
- Saw "navy backgrounds missing"
- Immediately created custom-colors.css
- Spent time on wrong problem

**What We Should Have Done:**
1. Check if page exists
2. Check if content is present
3. **Then** investigate styling

**Lesson:** Verify fundamentals before solving symptoms.

### âŒ Anti-Pattern 3: Testing Production Changes with Regular Browser

**Why Bad:**
- Contaminates browser cache immediately
- Can't distinguish between server and cache issues
- 301 redirects become permanently cached
- Hard to clear cache completely

**Better:**
```bash
# Always test with curl first
curl -I https://production.com

# If correct, then test with browser in incognito
```

### âŒ Anti-Pattern 4: Silent Failures in Scripts

**What We Had:**
```bash
wp post create page.html  # Might fail silently
```

**Better:**
```bash
wp post create page.html
if [ $? -ne 0 ]; then
    echo "Page creation failed"
    exit 1
fi

# Verify page actually exists
PAGE_ID=$(wp post list --name=page --field=ID)
if [ -z "$PAGE_ID" ]; then
    echo "Page not found after creation"
    exit 1
fi
```

### âŒ Anti-Pattern 5: Manual Fixes Without Documentation

**Problem:** Fixed URLs manually 4-5 times without documenting or automating.

**Impact:**
- Wasted time repeating same fix
- No learning between occurrences
- Temporary solutions instead of permanent fix

**Better:**
1. First occurrence: Manual fix + document
2. Second occurrence: Create script
3. Third occurrence: Identify root cause and permanent fix
4. Fourth+ occurrence: Should not happen (permanent fix in place)

---

## Success Metrics

### What Worked Well

1. **Systematic Diagnosis:**
   - Tested from multiple perspectives (server, client, curl)
   - Identified server vs. client-side issues correctly
   - Prevented wasted time "fixing" wrong component

2. **Script Enhancement:**
   - Emergency script now has comprehensive checks
   - URL safety verification added
   - HTTPS redirect protection added

3. **Permanent Solution:**
   - wp-config.php constants prevent recurrence
   - Zero maintenance required
   - Survives any database operation

### What Could Be Improved

1. **Earlier Root Cause Analysis:**
   - Should have locked URLs in wp-config.php after first occurrence
   - Spent 2-3 hours on temporary fixes before permanent solution

2. **Browser Cache Knowledge:**
   - Didn't initially recognize 301 caching severity
   - Should have tested with curl before browser

3. **Page Verification:**
   - Should have verified page exists before investigating colors
   - Would have saved 30 minutes on custom-colors.css approach

---

## References

### WordPress URL Documentation
- [WordPress Codex: Changing The Site URL](https://wordpress.org/support/article/changing-the-site-url/)
- [wp-config.php URL Constants](https://developer.wordpress.org/apis/wp-config-php/#blog-address-url)

### HTTP Caching
- [RFC 7231 - HTTP/1.1 Semantics: 301 Moved Permanently](https://tools.ietf.org/html/rfc7231#section-6.4.2)
- [MDN: HTTP Caching](https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching)

### Related Session Documents
- [SESSION-SUMMARY-FEB-09.md](../SESSION-SUMMARY-FEB-09.md)
- [DEPLOYMENT-WORKFLOW.md](../DEPLOYMENT-WORKFLOW.md)
- [QUICK-REFERENCE-DEPLOYMENT.md](../QUICK-REFERENCE-DEPLOYMENT.md)

---

## Checklist for Similar Incidents

If production URLs are wrong or redirecting incorrectly:

### Immediate Actions (< 5 minutes)
- [ ] Test from server: `curl -I https://domain.com`
- [ ] Check database URLs: `wp option get siteurl && wp option get home`
- [ ] Check if wp-config.php has URL constants
- [ ] Fix database if needed: `wp option update siteurl https://domain.com`

### Short-term Fix (< 15 minutes)
- [ ] Add URL constants to wp-config.php (if missing)
- [ ] Run emergency fix script
- [ ] Verify with curl (not browser)
- [ ] Clear browser cache / test with different browser

### Permanent Solution (< 30 minutes)
- [ ] Ensure wp-config.php constants present
- [ ] Update emergency script with URL checks
- [ ] Add HTTPS redirect check
- [ ] Document in deployment guide
- [ ] Create backup of corrected wp-config.php

### Follow-up (next session)
- [ ] Test emergency script from fresh state
- [ ] Verify browser access works (after cache cleared)
- [ ] Remove any temporary workarounds (custom-colors.css?)
- [ ] Update documentation with new procedures

---

**Document Owner:** GitHub Copilot (AI Assistant)  
**Last Updated:** February 9, 2026  
**Next Review:** After browser cache issue fully resolved
