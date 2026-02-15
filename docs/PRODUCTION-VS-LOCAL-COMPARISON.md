# Production vs Local - Data Comparison

**Production Backup Date:** January 30, 2026  
**Local Current Date:** February 5, 2026  
**Analysis Date:** February 5, 2026

---

## Page Comparison

### Production Backup (Jan 30, 2026) - 16 Published Pages

| ID  | Title | Slug | Status |
|-----|-------|------|--------|
| 14  | Welcome | /welcome/ | publish |
| 26  | Log In | /log-in/ | publish |
| 27  | Password Reset | /password-reset/ | publish |
| 28  | Register | /register/ | publish |
| 29  | Account | /account/ | publish |
| 30  | Profile | /profile/ | publish |
| 44  | Access Restricted | /403-forbidden/ | publish |
| 64  | Employers | /employers/ | publish |
| 75  | Candidates | /candidates/ | publish |
| 76  | Scouts | /scouts/ | publish |
| 77  | Operators Dashboard | /operators/ | publish |
| 78  | Select Role | /select-role/ | publish |
| 79  | Register Profile | /register-profile/ | publish |
| 86  | Manager Admin | /managers/admin/ | publish |
| 90  | Managers | /managers/ | publish |

### Current Local - 5 Published Pages

| ID  | Title | Slug | Status |
|-----|-------|------|--------|
| 6   | Welcome | /welcome/ | publish |
| 7   | Candidates | /candidates/ | publish |
| 8   | Managers | /managers/ | publish |
| 9   | Operators | /operators/ | publish |
| 10  | Manager Admin | /managers/admin/ | publish |

---

## Missing from Local (11 Pages)

### 🔐 Authentication Pages (5 pages)
- **Log In** (ID 26) - `/log-in/`
- **Password Reset** (ID 27) - `/password-reset/`
- **Register** (ID 28) - `/register/`
- **Account** (ID 29) - `/account/`
- **Profile** (ID 30) - `/profile/`

### 🚫 Error Pages (1 page)
- **Access Restricted / 403 Forbidden** (ID 44) - `/403-forbidden/`

### 📄 Role Pages (2 pages)
- **Employers** (ID 64) - `/employers/`
- **Scouts** (ID 76) - `/scouts/`

### 📝 Registration Flow (2 pages)
- **Select Role** (ID 78) - `/select-role/`
- **Register Profile** (ID 79) - `/register-profile/`

### 🔧 Sample Pages (1 page)
- **Sample Page** (ID 2) - Present in local, but different ID scheme

---

## ID Mapping Issues

**Problem:** Production and Local use different ID sequences

| Page Name | Production ID | Local ID | Status |
|-----------|---------------|----------|--------|
| Welcome | 14 | 6 | ✅ Exists both |
| Candidates | 75 | 7 | ✅ Exists both |
| Managers | 90 | 8 | ✅ Exists both |
| Operators | 77 | 9 | ✅ Exists both |
| Manager Admin | 86 | 10 | ✅ Exists both |
| Log In | 26 | - | ❌ Missing local |
| Password Reset | 27 | - | ❌ Missing local |
| Register | 28 | - | ❌ Missing local |
| Account | 29 | - | ❌ Missing local |
| Profile | 30 | - | ❌ Missing local |
| 403 Forbidden | 44 | - | ❌ Missing local |
| Employers | 64 | - | ❌ Missing local |
| Scouts | 76 | - | ❌ Missing local |
| Select Role | 78 | - | ❌ Missing local |
| Register Profile | 79 | - | ❌ Missing local |

---

## Pages Created AFTER Backup (Not in Production Backup)

**According to SESSION-SUMMARY-FEB-02.md:**

### Manager Actions (Expected ID 670)
- **URL:** `/managers/actions/`
- **Created:** February 2, 2026
- **Purpose:** User request approval workflows
- **Features:** 5-tab interface (Submitted, Approved, Rejected, All, Archived)
- **Status:** ❌ Lost in volume corruption, NOT in production backup

### Operator Actions (Expected ID 666)
- **URL:** `/operators/actions/`
- **Created:** February 2, 2026
- **Purpose:** Copy of Manager Actions with data filtering
- **Features:** Same UI, different backend filtering
- **Status:** ❌ Lost in volume corruption, NOT in production backup

---

## Recovery Options

### Option 1: Import All Pages from Production Backup ⭐ RECOMMENDED
**Pros:**
- ✅ Restores 11 missing pages instantly
- ✅ Proven production data (tested and deployed)
- ✅ Correct page IDs matching production
- ✅ Elementor data intact
- ✅ All authentication flow pages restored

**Cons:**
- ⚠️ Local page IDs will change (6→14, 7→75, etc.)
- ⚠️ Need to update homepage setting (page_on_front = 14)
- ⚠️ Need to update menu links if hardcoded
- ⚠️ Still need to recreate Manager/Operator Actions pages (not in backup)

**Steps:**
```bash
# 1. Backup current local database
podman exec wp-db mariadb-dump -u root -ppassword wordpress > tmp/local-before-import.sql

# 2. Import only wp_posts and wp_postmeta from production
# (selective import to avoid overwriting users, options, etc.)

# 3. Update page_on_front option
podman exec wp wp option update page_on_front 14 --allow-root

# 4. Verify pages
podman exec wp wp post list --post_type=page --allow-root
```

### Option 2: Recreate Missing Pages Manually
**Pros:**
- ✅ Keep current local IDs (6, 7, 8, 9, 10)
- ✅ More control over content
- ✅ Can reference docs/SESSION-SUMMARY-* files

**Cons:**
- ❌ Time-consuming (~3-5 days work)
- ❌ Need to rebuild Elementor layouts
- ❌ May miss subtle details from production
- ❌ Still different IDs from production (causes deployment issues)

### Option 3: Hybrid Approach
**Steps:**
1. Import production wp_posts to see ALL page content
2. Export specific pages we want (authentication, error pages)
3. Import those pages to current local database
4. Keep current IDs for main dashboard pages

**Pros:**
- ✅ Best of both worlds
- ✅ Selective restoration

**Cons:**
- ⚠️ Complex, more steps
- ⚠️ ID mapping still an issue

---

## Recommendation

**✅ Option 1: Full Import from Production Backup**

**Rationale:**
1. Production is source of truth
2. We need ID parity for deployment consistency
3. Missing pages are critical (authentication, registration flow)
4. Faster recovery (hours vs days)
5. Manager/Operator Actions pages (Feb 2 work) need recreation anyway

**Timeline Impact:**
- Import production backup: ~2 hours
- Recreate Manager/Operator Actions: ~2 days
- Testing and verification: ~1 day
- **Total: 3 days** (vs 10 days original estimate)

**Updated Timeline:**
- v3.5.0 Recreation: February 8, 2026 (was Feb 15)
- v3.6.0 MVP: April 8, 2026 (was April 15)
- **Saved: 7 days**

---

## Next Steps (Recommended)

1. **Tomorrow (Feb 6):**
   - Backup current local database
   - Import production wp_posts and wp_postmeta
   - Update homepage/menu configuration
   - Verify all pages load correctly
   
2. **Feb 7:**
   - Recreate Manager Actions page (ID 670)
   - Recreate Operator Actions page (ID 666)
   - Reinstall PublishPress Capabilities plugin
   
3. **Feb 8:**
   - Test complete workflow
   - Update documentation
   - Deploy v3.5.0 to production

---

## Production Backup Contents

**Database:** `wordpress_prod_backup` (temporary)
**Source File:** `tmp/u909075950_GD9QX.talendelight-com.20260130124736.sql.gz`
**Extracted To:** `tmp/production-backup-20260130.sql`
**Imported:** February 5, 2026

**Tables Available:**
- ✅ wp_posts (all pages, posts)
- ✅ wp_postmeta (Elementor data, custom fields)
- ✅ wp_users (production users)
- ✅ wp_usermeta
- ✅ wp_options (site configuration)
- ✅ td_user_data_change_requests (user approval data)
- ✅ td_audit_log (audit trail)
- ✅ All other WordPress tables

**Ready for selective or full import.**
