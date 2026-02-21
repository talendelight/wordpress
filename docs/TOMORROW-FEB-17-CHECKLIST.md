# Tomorrow's Continuation Checklist - February 17, 2026

## Context
Session paused after UI consistency fixes and alert removal. All changes deployed to both local and production.

## Immediate Priority: Production Testing & Deviation Fixes

### Phase 1: Registration Workflow Testing (30 minutes)

**Test in Production:**
1. Visit https://talendelight.com/select-role/
2. Test button styling:
   - Default state: Navy #063970 ✓
   - Hover state: #0062e3 (no lift) ✓
   - Click state: Darker blue #2980B9 ✓
3. Select "Candidate" role, click "Next"
4. Verify redirect to /register-profile/ with td_user_role parameter
5. Fill out registration form with test data
6. Submit form
7. Check database:
   ```bash
   ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075900@45.84.205.129 'cd /home/u909075950/domains/talendelight.com/public_html && wp db query "SELECT id, first_name, email, role, status FROM td_user_data_change_requests ORDER BY id DESC LIMIT 1"'
   ```
8. Verify entry appears in Manager Actions (/managers/actions/)

**Test in Local:**
1. Visit http://localhost:8080/select-role/
2. Repeat steps 2-8 above
3. Compare results with production

**Expected Results:**
- Form submission syncs to td_user_data_change_requests within seconds
- Entry visible in Manager Actions "New" tab
- No errors in browser console
- Form ID constant working correctly (local=80, production=53)

---

### Phase 2: Manager Actions Approval Workflow (30 minutes)

**Test in Production:**
1. Login as td_manager user
2. Navigate to /managers/actions/
3. Select "New" tab
4. Test **Assign to Self** button:
   - Click Assign on any request
   - Click "Assign to Self" in modal
   - Verify NO alert shown ✓
   - Verify modal closes ✓
   - Verify page reloads within 500ms ✓
   - Check entry moved to "Assigned" tab ✓
5. Test **Approve** button:
   - Click Approve on assigned request
   - Verify NO alert shown ✓
   - Verify row fades out ✓
   - Check database: User account created
   - Check entry moved to "Approved" tab ✓
6. Test **Reject** button:
   - Click Reject on any request
   - Verify NO alert shown ✓
   - Verify row fades out ✓
   - Check entry moved to "Rejected" tab ✓

**Test in Local:**
- Repeat all steps above
- Compare behavior with production

**Expected Results:**
- No success alerts shown (removed Feb 16)
- Row fade-out provides visual feedback
- Error alerts still show if something fails
- Actions complete within 500ms

---

### Phase 3: Navigation & Menu Testing (15 minutes)

**Test in Production & Local:**
1. **Logged Out State:**
   - Verify "Register" menu item visible ✓
   - Verify "Login" menu item visible ✓
   - Verify "Profile" menu hidden ✓
   - Verify "Logout" menu hidden ✓

2. **Logged In State:**
   - Verify "Register" menu hidden ✓ (fixed Feb 16)
   - Verify "Login" menu hidden ✓
   - Verify "Profile" menu visible ✓
   - Verify "Logout" menu visible ✓

**Expected Results:**
- Production matches local behavior
- /select-role/ URL now properly triggers menu hiding

---

### Phase 4: Visual Comparison (30 minutes)

**Compare Production vs Local:**
1. **Homepage:**
   - Hero section styling
   - Button colors and hover states
   - Trust badges footer
   - Card grid layouts

2. **Authentication Pages:**
   - /select-role/ - Button styling ✓
   - /log-in/ - Form container and buttons
   - /register-profile/ - Form layout and styling

3. **Manager Pages:**
   - /managers/ - Card grid and navigation
   - /managers/admin/ - 4-tile dashboard
   - /managers/actions/ - 5-tab interface

4. **Footer Sections:**
   - Trust badges on all pages
   - Consistent styling

**Document Deviations:**
- Create list of any differences found
- Prioritize fixes (Critical / Medium / Low)
- Fix critical issues immediately

---

## Quick Commands Reference

### SSH Production
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129
```

### Production WP-CLI
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 'cd /home/u909075950/domains/talendelight.com/public_html && wp <command>'
```

### Deploy Single File
```powershell
scp -P 65002 -i "tmp\hostinger_deploy_key" "<local-path>" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/<remote-path>
```

### Check Latest Database Entry
```bash
# Production
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 'cd /home/u909075950/domains/talendelight.com/public_html && wp db query "SELECT * FROM td_user_data_change_requests ORDER BY id DESC LIMIT 1"'

# Local
podman exec -it wp-db mariadb -u root -ppassword wordpress -e "SELECT * FROM td_user_data_change_requests ORDER BY id DESC LIMIT 1"
```

### Check Forminator Entries
```bash
# Production
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 'cd /home/u909075950/domains/talendelight.com/public_html && wp db query "SELECT entry_id, form_id, date_created FROM wp_frmt_form_entry ORDER BY entry_id DESC LIMIT 5"'

# Local
podman exec -it wp-db mariadb -u root -ppassword wordpress -e "SELECT entry_id, form_id, date_created FROM wp_frmt_form_entry ORDER BY entry_id DESC LIMIT 5"
```

---

## Files Modified Feb 16 (Already Deployed)

✅ `wp-content/themes/blocksy-child/page-role-selection.php` (button styling)  
✅ `wp-content/mu-plugins/manager-actions-display.php` (alert removal)  
✅ `wp-content/themes/blocksy-child/functions.php` (menu hiding)  

**Status:** All deployed to production and local

---

## Documentation Updated Feb 16

✅ [docs/SESSION-SUMMARY-FEB-16.md](SESSION-SUMMARY-FEB-16.md) - Complete session summary  
✅ [docs/RELEASE-NOTES-NEXT.md](RELEASE-NOTES-NEXT.md) - Added Feb 16 changes  

---

## Success Criteria for Tomorrow

**Must Complete:**
- [ ] Registration workflow tested end-to-end (both environments)
- [ ] Manager Actions workflow tested (assign, approve, reject)
- [ ] No success alerts confirmed (only error alerts remain)
- [ ] Register menu hiding verified for logged-in users
- [ ] Production vs local deviation list created

**Nice to Have:**
- [ ] All found deviations fixed
- [ ] v3.6.2 release notes finalized
- [ ] Environment parity checklist created
- [ ] Consider scheduling next release

---

## Potential Issues to Watch For

1. **Form ID Mismatch:** Local=80, Production=53
   - Check forminator-custom-table.php uses TD_PERSON_REGISTRATION_FORM_ID constant
   - Verify constant defined in both wp-config.php files

2. **MU-Plugin Sync:** 
   - Verify manager-actions-display.php version matches (28KB)
   - Check forminator-custom-table.php present in both

3. **Page Template Sync:**
   - Verify page-role-selection.php template assigned correctly
   - Check page IDs match expected values

4. **Menu Configuration:**
   - Two Register menu items in production (ID 37, ID 8)
   - Verify both hide correctly for logged-in users

---

## Contact/Reference Info

**Production Server:** 45.84.205.129:65002  
**SSH User:** u909075950  
**SSH Key:** tmp/hostinger_deploy_key  
**WordPress Path:** /home/u909075950/domains/talendelight.com/public_html/  

**Local URLs:**
- WordPress: http://localhost:8080
- phpMyAdmin: http://localhost:8180
- MariaDB: localhost:3306

**Production URLs:**
- Website: https://talendelight.com
- WordPress Admin: https://talendelight.com/wp-admin

---

**Created:** February 16, 2026 (Evening)  
**For Session:** February 17, 2026 (Morning)
