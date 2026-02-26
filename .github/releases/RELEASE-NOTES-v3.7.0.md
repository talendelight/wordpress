# Release Notes - v3.7.0

**Version:** 3.7.0 (MINOR)  
**Release Date:** March 9, 2026  
**Status:** 📋 Planned  
**Week Starting:** March 2, 2026

---

## 📦 Release Summary

**Theme:** Privacy Policy + Registration Request Foundation + Record ID System

This release establishes the legal and technical foundation for the registration approval workflow by adding comprehensive privacy policy, custom post type for registration requests, and automated Record ID generation system.

**Type:** MINOR (new features, backward-compatible)

---

## ✨ New Features

### 1. Privacy Policy Page (PENG-014)
**Priority:** CRITICAL | **Est:** 2.0 days | **Status:** Planned

**Description:**
Comprehensive privacy policy page covering all GDPR requirements and data handling practices.

**Sections:**
- Data collection practices (what we collect, why, legal basis)
- Processing purposes (recruitment, matching, compliance)
- Retention periods (based on LFTC-002 lawyer guidance)
- User rights (access, rectification, deletion, portability, objection)
- Cookie usage (technical, analytics, preferences)
- Third-party integrations (email providers, hosting, analytics)
- Data transfers (EU/EEA, adequacy decisions)
- Contact information for privacy inquiries

**Dependencies:**
- ⏳ **BLOCKED BY LFTC-002** (Lawyer GDPR retention policy - in progress)
- Must wait for lawyer guidance before finalizing retention periods section

**Deployment:**
- Manual page deployment via `restore-page-X.php` script
- Production page ID: 3 (existing Privacy Policy placeholder)
- Follow [POST-DEPLOYMENT-CHECKLIST.md](../docs/procedures/POST-DEPLOYMENT-CHECKLIST.md)

**Files:**
- `restore/pages/privacy-policy-3.html` (new backup)

---

### 2. Custom Post Type: td_registration_request (PENG-015)
**Priority:** CRITICAL | **Est:** 3.0 days | **Status:** Planned

**Description:**
New custom post type to store all registration request submissions before approval. Foundation for the registration approval workflow.

**Schema:**
```sql
-- Custom post type registered via WordPress
post_type = 'td_registration_request'
post_status = 'pending' | 'approved' | 'rejected'
post_title = '[Role] Request - [Name] - [Date]'
post_content = JSON of all form fields

-- Meta fields (wp_postmeta):
- _td_request_id (USRQ-YYMMDD-NNNN)
- _td_record_id (PRSN/CMPY-YYMMDD-NNNN after approval)
- _td_email
- _td_role (candidate|employer|scout)
- _td_submission_date
- _td_assigned_to (operator_user_id)
- _td_reviewed_by (operator/manager_user_id)
- _td_reviewed_date
- _td_notes (reviewer notes)
```

**Features:**
- Links to `td_user_requests` table via `request_id`
- Stores all submission data (form fields as JSON in post_content)
- Tracks approval workflow (pending → assigned → approved/rejected)
- One-to-one mapping with WordPress user (created on approval)

**Dependencies:**
- PENG-014 (Privacy Policy - conceptual)
- BMSL-001 (Business rules)
- PENG-001 (Record ID strategy v2.0)

**Deployment:**
- SQL migration file: `infra/shared/db/YYMMDD-HHmm-create-cpt-registration-request.sql`
- Deploy via phpMyAdmin or `wp-action.ps1 apply-sql`

**Files:**
- `wp-content/mu-plugins/td-registration-cpt.php` (CPT registration)
- SQL migration file (TBD)

---

### 3. Record ID Generation System (PENG-016)
**Priority:** CRITICAL | **Est:** 2.0 days | **Status:** Planned

**Description:**
Automated generation of Request IDs and Record IDs following PENG-001 v2.0 strategy.

**ID Types:**
1. **Request ID** (for all submissions):
   - Format: `USRQ-YYMMDD-NNNN`
   - Example: `USRQ-260302-0001`
   - Generated on form submission
   - Stored in CPT meta `_td_request_id`
   - Links to `td_user_requests.request_id`

2. **Record ID** (for approved entities):
   - Format: `PRSN-YYMMDD-NNNN` (people: Candidate, Scout, Operator, Manager)
   - Format: `CMPY-YYMMDD-NNNN` (companies: Employer)
   - Example: `PRSN-260305-0012`, `CMPY-260305-0003`
   - Generated on approval
   - Stored in CPT meta `_td_record_id`
   - Stored in `wp_users.user_login` (for people)
   - Stored in company custom fields (for employers)

**Enforcement Rules:**
- ✅ **One-to-one-to-one mapping:** 1 Email = 1 WP User = 1 Record ID = 1 Role
- ✅ Email must be unique across all submissions
- ✅ Record ID assigned only once (on first approval)
- ✅ Role change rejected (must delete and resubmit)
- ✅ Sequential numbering per day (0001, 0002, ...)

**Functions:**
- `td_generate_request_id()` - Generate USRQ-YYMMDD-NNNN
- `td_generate_record_id($entity_type)` - Generate PRSN/CMPY-YYMMDD-NNNN
- `td_check_email_exists($email)` - Enforce unique email
- `td_get_next_sequence($prefix, $date)` - Get next sequential number

**Dependencies:**
- PENG-001 (Record ID strategy v2.0)
- PENG-015 (CPT for storing IDs)

**Deployment:**
- Git auto-deploy: `wp-content/mu-plugins/record-id-generator.php`
- Verify with `wp-action.ps1 verify-deployment`

**Files:**
- `wp-content/mu-plugins/record-id-generator.php` (updated)

---

## 🔧 Technical Changes

### Database
- **New CPT:** `td_registration_request` with custom meta fields
- **Updated plugin:** `record-id-generator.php` with Request ID + Record ID functions

### WordPress Pages
- **Updated:** Privacy Policy (page ID 3) - comprehensive GDPR-compliant content

### Must-Use Plugins
- `wp-content/mu-plugins/td-registration-cpt.php` (NEW)
- `wp-content/mu-plugins/record-id-generator.php` (UPDATED)

---

## 📋 Deployment Instructions

### Prerequisites
- [ ] LFTC-002 completed (lawyer provides GDPR retention periods)
- [ ] BMSL-001 reviewed (business rules for approval workflow)
- [ ] All changes tested in local environment
- [ ] User approval obtained

### Standard Deployment Workflow

**1. Backup (MANDATORY)**
```powershell
powershell -File infra/shared/scripts/wp-action.ps1 backup
```

**2. Deploy Code**
```powershell
git checkout main
git merge develop --no-edit
git push origin main
```

**3. Wait for Hostinger Auto-Deployment**
```powershell
Start-Sleep -Seconds 30
```

**4. Verify Deployment (MANDATORY - NEW in v3.6.4)**
```powershell
powershell -File infra/shared/scripts/wp-action.ps1 verify-deployment
```

**Expected output:**
```
✅ Verified: 2
❌ Mismatches: 0
🚫 Missing: 0
✅ ALL FILES DEPLOYED SUCCESSFULLY
```

**If verification fails:** Follow manual deployment procedure in [POST-DEPLOYMENT-CHECKLIST.md](../docs/procedures/POST-DEPLOYMENT-CHECKLIST.md)

**5. Deploy Database Migration**
```powershell
# Upload SQL file
scp -P 65002 -i "tmp\hostinger_deploy_key" "infra\shared\db\YYMMDD-HHmm-create-cpt-registration-request.sql" u909075950@45.84.205.129:/tmp/

# Apply migration
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query < /tmp/YYMMDD-HHmm-create-cpt-registration-request.sql && rm /tmp/YYMMDD-HHmm-create-cpt-registration-request.sql"
```

**6. Deploy Privacy Policy Page**
```powershell
# Upload HTML content
scp -P 65002 -i "tmp\hostinger_deploy_key" "restore\pages\privacy-policy-3.html" u909075950@45.84.205.129:/tmp/

# Upload restore script
scp -P 65002 -i "tmp\hostinger_deploy_key" "tmp\restore-page-3.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/

# Execute restore
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && php restore-page-3.php && rm restore-page-3.php && wp cache flush --allow-root"
```

**7. Clear Production Cache**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cache flush --allow-root"
```

**8. Run Health Check**
```powershell
powershell -File infra/shared/scripts/wp-action.ps1 verify
```

**9. Functional Testing (User Required)**
- [ ] Visit Privacy Policy page: https://talendelight.com/privacy-policy/
- [ ] Verify all sections display correctly
- [ ] Check no PHP errors in logs: `ssh production "tail -50 ~/domains/talendelight.com/logs/error_log"`
- [ ] Test Record ID generation with sample submission
- [ ] Verify Request ID format: USRQ-YYMMDD-NNNN
- [ ] Verify Record ID format: PRSN-YYMMDD-NNNN (people), CMPY-YYMMDD-NNNN (companies)
- [ ] Confirm one-to-one-to-one mapping enforcement (duplicate email rejected)

---

## ✅ Verification Checklist

### Files Deployed
- [ ] `wp-content/mu-plugins/td-registration-cpt.php` exists on production
- [ ] `wp-content/mu-plugins/record-id-generator.php` updated on production
- [ ] File sizes match local workspace
- [ ] `verify-deployment.ps1` passes with no errors

### Database Changes
- [ ] CPT `td_registration_request` exists
- [ ] Meta fields schema matches documentation
- [ ] Sample submission creates CPT entry
- [ ] Request ID generated correctly
- [ ] Health check passes all 18+ checks

### Privacy Policy Page
- [ ] Page exists at https://talendelight.com/privacy-policy/
- [ ] All sections present (data collection, processing, retention, rights, cookies, transfers, contact)
- [ ] Retention periods match LFTC-002 lawyer guidance
- [ ] Line count matches local (±5 lines acceptable)
- [ ] Footer compliance badges display correctly

### Record ID System
- [ ] Request ID generated on form submission
- [ ] Format matches USRQ-YYMMDD-NNNN
- [ ] Record ID generated on approval
- [ ] Format matches PRSN-YYMMDD-NNNN or CMPY-YYMMDD-NNNN
- [ ] Duplicate email rejected with clear error message
- [ ] Sequential numbering works (0001, 0002, ...)

### Production Health
- [ ] No PHP errors in production logs
- [ ] No JavaScript console errors
- [ ] Health check passes (verify script)
- [ ] No 500 errors on any pages

---

## 🚨 Rollback Procedure

**If deployment fails or issues detected:**

```powershell
# Restore from latest backup
powershell -File infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true

# Verify rollback successful
powershell -File infra/shared/scripts/wp-action.ps1 verify

# Check production
# Visit https://talendelight.com/ and test key pages
```

**See:** [DISASTER-RECOVERY-PLAN.md](../docs/procedures/DISASTER-RECOVERY-PLAN.md) for detailed rollback procedures

---

## 📊 Task Breakdown

| Task ID | Task Name | Priority | Est (Days) | Status | Dependencies |
|---------|-----------|----------|------------|--------|--------------|
| PENG-014 | Privacy Policy Page | CRITICAL | 2.0 | Planned | LFTC-002 |
| PENG-015 | CPT td_registration_request | CRITICAL | 3.0 | Planned | PENG-014, BMSL-001, PENG-001 |
| PENG-016 | Record ID Generation System | CRITICAL | 2.0 | Planned | PENG-001, PENG-015 |
| **TOTAL** | | | **7.0 days** | | |

**Effort:** 7.0 calendar days (14 hours of focused work at 2 hours/day)  
**Timeline:** Week of March 2-9, 2026  
**Blocked By:** LFTC-002 (Lawyer GDPR retention policy - must complete first)

---

## 📚 Related Documentation

**Strategy & Design:**
- [PENG-001-CANDIDATEID-STRATEGY-V2.md](../../docs/PENG-001-CANDIDATEID-STRATEGY-V2.md) - Record ID strategy (simplified)
- [COPS-001-CV-LIFECYCLE-POLICY.md](../../deliverables/COPS-001-CV-LIFECYCLE-POLICY.md) - CV handling and consent
- [LFTC-002-GDPR-RETENTION-POLICY.md](../../deliverables/LFTC-002-GDPR-RETENTION-POLICY.md) - Retention policy (pending)

**Deployment:**
- [DEPLOYMENT-WORKFLOW.md](../../docs/procedures/DEPLOYMENT-WORKFLOW.md) - Complete deployment process
- [POST-DEPLOYMENT-CHECKLIST.md](../../docs/procedures/POST-DEPLOYMENT-CHECKLIST.md) - Verification checklist
- [TASK-REGISTRY.md](../TASK-REGISTRY.md) - Deployment task procedures

**Recovery:**
- [DISASTER-RECOVERY-PLAN.md](../../docs/procedures/DISASTER-RECOVERY-PLAN.md) - Rollback procedures
- [BACKUP-RESTORE-QUICKSTART.md](../../docs/procedures/BACKUP-RESTORE-QUICKSTART.md) - Quick recovery commands

**Lessons Learned:**
- [hostinger-auto-deployment-limitations.md](../../docs/lessons/hostinger-auto-deployment-limitations.md) - v3.6.4 deployment failure

---

## 🔄 Version History Context

**Previous Release:** v3.6.4 (February 24-26, 2026)
- Operators Landing Page (PENG-073)
- Operator Actions Dashboard (PENG-072)
- BUG-001 fix (role showing N/A)
- Deployment verification system
- Backup system updates

**This Release:** v3.7.0 (March 2-9, 2026)
- Privacy Policy page (PENG-014)
- Registration Request CPT (PENG-015)
- Record ID generation (PENG-016)

**Next Target:** v3.8.0+ (March-April 2026)
- Registration forms with approval workflow
- Email notification templates
- Dashboard enhancements
- MVP completion by April 15, 2026

---

## 🎯 Success Criteria

Release considered successful when:

✅ Privacy Policy page published with all GDPR-required sections  
✅ CPT `td_registration_request` created and tested  
✅ Record ID generation working for all entity types  
✅ One-to-one-to-one mapping enforced (duplicate email rejected)  
✅ All verification checks pass  
✅ No errors in production logs  
✅ User testing confirms expected behavior  

**Deployment Time:** ~30 minutes (with verification)  
**Rollback Time:** ~5 minutes (if needed)

---

**Status:** 📋 PLANNED - Awaiting LFTC-002 completion  
**Target Week:** w/s March 2, 2026  
**Release Manager:** You (Solo Manager)
