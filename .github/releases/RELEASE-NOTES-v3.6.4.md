# Release Notes - v3.6.4

**Release Date:** February 24, 2026  
**Type:** Patch  
**Status:** In Development

## Overview

This release introduces the Operator Actions page for managing user registration requests, and completes style fixes for footer icons across all landing pages.

## Scope

### Primary Features
1. **Operator Actions Page** - Display and manage user registration requests with status tabs
2. **Footer Icon Fixes** - SVG icons deployed across all landing pages (✅ COMPLETE)

### Components

**Backend:**
- `operator-actions-display.php` - MU plugin for operator request management
- `operator-actions-tabs.js` - Tab functionality for status filtering
- Role-based database queries (operators see public users only)

**Frontend:**
- Operator Actions page (production ID 20)
- Hierarchical URL: `/operators/actions/`
- Tab interface: New | In Progress | Approved | Rejected

**Style Fixes (✅ COMPLETE - Feb 24):**
- Candidates page (ID 17) - Footer emojis → SVG icons (21,396 bytes)
- Employers page (ID 16) - Footer emojis → SVG icons (29,968 bytes)
- Scouts page (ID 18) - Footer emojis → SVG icons (21,363 bytes)
- Managers page (ID 19) - Footer emojis → SVG icons (22,598 bytes)

**SVG Icons Used:**
- `shield-grey-border.svg` - GDPR Compliant badge
- `padlock-lock-grey.svg` - Secure & Reliable badge
- `balance-scale-yellow.svg` - Equal Opportunity badge
- `eu-logo.svg` - EU Markets badge

## Development Tasks

### 1. Create Operator Actions Display Plugin
**File:** `wp-content/mu-plugins/operator-actions-display.php`

```php
// Similar to manager-actions-display.php but filtered for operators
// Query: WHERE assigned_role IN ('td_candidate', 'td_employer', 'td_scout')
// (Operators handle public users only, not internal operators/managers)
```

### 2. Create JavaScript for Tabs
**File:** `wp-content/themes/blocksy-child/assets/js/operator-actions-tabs.js`

```javascript
// Tab switching logic
// Status filtering (new, in_progress, approved, rejected)
// Action buttons (Approve, Reject, Assign to Me)
```

### 3. Create Operator Actions Page
**Local:** Create page with custom template
**Content:** Tab interface + PHP shortcode/MU plugin output
**Template:** Similar to Manager Actions page structure

### 4. Update Operators Landing Page
**Add link:** "Operator Actions" → `/operators/actions/`

## Deployment Steps

### Step 1: Development (Local)
```bash
# Create operator-actions-display.php
# Create operator-actions-tabs.js
# Create Operator Actions page
# Test locally with operator user
```

### Step 2: Export & Stage
```powershell
# Export Operator Actions page
podman exec wp bash -c "wp post get <LOCAL_ID> --field=post_content --allow-root 2>/dev/null" | Out-File -Encoding utf8 restore\pages\operator-actions-<LOCAL_ID>.html

# Verify backup
Get-Item restore\pages\operator-actions-*.html | Select-Object Name, Length
```

### Step 3: Deploy to Production
```bash
# Upload MU plugin
scp -P 65002 -i "tmp\hostinger_deploy_key" \
  "wp-content\mu-plugins\operator-actions-display.php" \
  u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/mu-plugins/

# Upload JavaScript
scp -P 65002 -i "tmp\hostinger_deploy_key" \
  "wp-content\themes\blocksy-child\assets\js\operator-actions-tabs.js" \
  u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/themes/blocksy-child/assets/js/

# Deploy page content (ID 20 production)
scp -P 65002 -i "tmp\hostinger_deploy_key" \
  "restore\pages\operator-actions-<LOCAL_ID>.html" \
  u909075950@45.84.205.129:/tmp/page-20.html

# Update page via wp-cli
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 \
  "cd /home/u909075950/domains/talendelight.com/public_html && \
   wp eval-file update-operator-actions.php && \
   rm update-operator-actions.php /tmp/page-20.html"
```

### Step 4: Configure Hierarchical URLs
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 \
  "cd /home/u909075950/domains/talendelight.com/public_html && \
   wp post update <ACTIONS_ID> --post_parent=20 && \
   wp rewrite flush && \
   wp cache flush"
```

## Verification Checklist

### Operator Actions Page
- [ ] Page accessible at `/operators/actions/`
- [ ] Tabs display correctly (New, In Progress, Approved, Rejected)
- [ ] Requests display in appropriate tabs based on status
- [ ] Action buttons work (Approve, Reject, Assign)
- [ ] Role filtering correct (only public users visible)
- [ ] No "Database Table Not Found" error
- [ ] JavaScript console shows no errors

### Footer Icons (✅ Already Verified)
- [x] Candidates page - SVG icons displaying
- [x] Employers page - SVG icons displaying
- [x] Scouts page - SVG icons displaying
- [x] Managers page - SVG icons displaying
- [x] No emoji characters visible
- [x] All 4 icons render correctly

## Rollback Plan

If deployment fails:

1. **Remove MU plugin:**
   ```bash
   ssh production "rm /path/to/operator-actions-display.php"
   ```

2. **Restore page content:**
   ```bash
   # Use previous backup or revert via wp-cli
   ssh production "wp post update 20 --post_content='...previous...'"
   ```

3. **Clear cache:**
   ```bash
   ssh production "wp cache flush"
   ```

## Post-Deployment

After successful deployment and verification:

1. Update v3.6.4.json status to "deployed"
2. Document any issues encountered
3. Update testing_progress with results
4. Consider archiving if complete, or keep for updates during testing phase

## Notes

- Operator Actions follows same pattern as Manager Actions (proven architecture)
- Footer icon fixes already deployed and verified (no further action needed)
- Clean separation: Operators handle public users, Managers handle all users
- Database table already exists: `wp_td_user_data_change_requests`
- Role-based filtering ensures operators see only relevant requests

---

**Previous Release:** v3.6.3 (Registration system complete with 6 critical fixes)  
**Next Release:** TBD (possibly v3.6.5 for additional polish or v3.7.0 for new feature)
