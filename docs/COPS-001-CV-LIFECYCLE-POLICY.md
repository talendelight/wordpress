# COPS-001: CV Lifecycle Policy

**Status:** In Progress  
**Priority:** Critical  
**Phase:** Phase 0  
**Target Version:** v3.6.0  
**Owner:** Manager  
**Timeline:** Jan 25-26, 2026  
**Dependencies:** None  
**Blocks:** PENG-014 (Privacy Policy)

---

## 1. Executive Summary

This policy defines the complete lifecycle of CV files in the TalenDelight/HireAccord system, covering storage, access control, retention, deletion, and GDPR compliance. The policy ensures candidate privacy, operational efficiency, and regulatory compliance throughout the CV management process.

**Key Principles:**
- **Security First:** CVs accessible only via authenticated endpoints
- **GDPR Compliance:** Clear retention periods and right to erasure
- **Consent-Based:** Single consent checkbox covers storage and processing
- **Audit Trail:** Complete tracking of CV access and modifications

---

## 2. Storage Policy

### 2.1 Storage Location & Directory Structure

**Initial Upload (Temporary):**
- **Location:** WordPress uploads directory (Forminator-specific folder)
- **Path:** `wp-content/uploads/forminator/{form-id}/`
- **Purpose:** Temporary holding area for form submissions
- **Lifetime:** Until n8n job moves file to permanent storage (~5 minutes)

**Permanent Storage:**
- **Location:** Custom directory outside wp-content (protected from web access)
- **Path:** `/var/talendelight/cv-storage/{YYYY}/{MM}/`
- **Structure:** 
  ```
  /var/talendelight/cv-storage/
  ├── 2026/
  │   ├── 01/
  │   │   ├── CNDT-260125-1-1737800000.pdf
  │   │   ├── CNDT-260125-2-1737801234.docx
  │   │   └── EMPL-260125-1-1737802456.pdf
  │   └── 02/
  └── 2027/
  ```

### 2.2 File Naming Convention

**Format:** `{record_id}-{timestamp}.{original_extension}`

**Components:**
- **record_id:** Business entity ID (CNDT-260125-1, EMPL-260125-1, etc.)
- **timestamp:** Unix timestamp (seconds since epoch)
- **original_extension:** Preserved from uploaded file

**Examples:**
- `CNDT-260125-1-1737800000.pdf` - Candidate CV uploaded Jan 25, 2026
- `SCOT-260126-5-1737886400.docx` - Scout CV uploaded Jan 26, 2026
- `EMPL-260127-3-1737972800.jpg` - Employer company document

**Allowed Extensions:**
- Documents: `.pdf`, `.doc`, `.docx`, `.txt`, `.rtf`
- Images: `.jpg`, `.jpeg`, `.png` (for company documents)

### 2.3 File Movement Workflow

**Step 1: Form Submission (Forminator)**
```
User uploads CV → Forminator saves to wp-content/uploads/forminator/{form-id}/
```

**Step 2: n8n Automation Job**
```
n8n webhook triggered → Reads form data → Generates Record ID
→ Moves file to /var/talendelight/cv-storage/{YYYY}/{MM}/{record_id}-{timestamp}.{ext}
→ Deletes original file from wp-content/uploads/forminator/
→ Updates td_user_data_change_requests.cv_file_path with permanent path
```

**Step 3: Cleanup**
```
n8n verifies successful move → Removes temp file → Logs action
```

**Failure Handling:**
- If n8n job fails, temp file remains in uploads directory
- Daily cleanup job removes orphaned files older than 24 hours
- Alert sent to Operations team for manual review

### 2.4 Access Control & Authentication

**Access Levels:**

| Role | Access Rights | Authentication |
|------|---------------|----------------|
| **Scout** | Own submitted CVs only | WordPress login + session token |
| **Operator** | All CVs | WordPress login + `td_view_cvs` capability |
| **Manager** | All CVs | WordPress login + `td_view_cvs` capability |
| **Administrator** | All CVs | WordPress login + admin privileges |
| **Candidate** | Own CV only | WordPress login (post-approval) |
| **Employer** | None | N/A (CVs shared via separate matching process) |

**Access Method:**
- ❌ **Direct URL access:** BLOCKED (files stored outside web root)
- ✅ **Authenticated endpoint:** `/api/cv/download?record_id={id}&request_id={req}`
- ✅ **Session validation:** WordPress `wp_verify_nonce()` + capability check
- ✅ **Audit logging:** All downloads logged to `td_cv_access_log` table

**Download Endpoint Logic:**
```php
function td_download_cv($record_id, $request_id) {
    // 1. Verify user logged in
    if (!is_user_logged_in()) {
        wp_die('Authentication required');
    }
    
    // 2. Check capability
    $user = wp_get_current_user();
    if (!current_user_can('td_view_cvs') && !is_admin()) {
        // Allow Scout to view own submissions
        if (!td_user_owns_submission($user->ID, $request_id)) {
            wp_die('Access denied');
        }
    }
    
    // 3. Retrieve file path
    $file_path = td_get_cv_path($record_id);
    if (!file_exists($file_path)) {
        wp_die('File not found');
    }
    
    // 4. Log access
    td_log_cv_access($user->ID, $record_id, $request_id);
    
    // 5. Serve file
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . basename($file_path) . '"');
    readfile($file_path);
    exit;
}
```

### 2.5 Encryption Requirements

**At Rest:**
- **Filesystem encryption:** Server-level disk encryption (LUKS or similar)
- **File-level encryption:** Optional (to be evaluated in LFTC-002)
- **Database encryption:** MySQL encryption for cv_file_path column (optional)

**In Transit:**
- **HTTPS required:** All CV downloads over TLS 1.2+
- **Certificate validation:** Production uses Hostinger managed SSL
- **No HTTP fallback:** Non-HTTPS requests rejected

**Backup Encryption:**
- Daily backups encrypted with GPG
- Keys stored separately from backup files
- 3-2-1 backup strategy (3 copies, 2 media types, 1 offsite)

---

## 3. Retention Policy

### 3.1 Active Candidates

**Definition:** Candidates who are:
- Recently registered (pending/approved within last 6 months)
- Actively being matched to employers
- In ongoing recruitment processes (interviews, offers)

**Retention Period:** ✅ **24 months from last activity OR 30 days after deletion request (whichever is earlier)**
- **Rationale:** Recruitment cycles can be long; employers may return to previous candidates
- **User Rights:** Deletion requests override retention period (honored within 30 days)

**Activity Indicators:**
- Last login date
- Last match attempt
- Last employer inquiry
- Last profile update

### 3.2 Inactive Candidates

**Definition:** Candidates who are:
- Rejected during registration approval
- No activity (logins, matches, responses) for 6+ months
- Unresponsive to outreach (3+ missed communications)

**Retention Period:** ✅ **12 months from last activity OR 30 days after deletion request (whichever is earlier)**
- **Rationale:** GDPR storage limitation + business need for historical data
- **User Rights:** Deletion requests override retention period (honored within 30 days)

**Rejected Candidates - Separate Archive:**
- **Location:** `/var/talendelight/cv-storage/archive/rejected/{YYYY}/{MM}/`
- **Automatically moved:** Upon rejection approval
- **Retention:** 12 months from rejection date OR 30 days after deletion request
- **Access:** Admin-only (Operator/Manager with td_view_cvs capability)
- **Database flag:** `cv_archived_date` timestamp, `archive_reason` = 'rejected'

### 3.3 Archival Triggers & Retention

**Archive Retention Period:** ✅ **12 months from archival date OR 30 days after deletion request (whichever is earlier)**
- **Rationale:** Grace period for potential reactivation, then permanent deletion
- **User Rights:** Deletion requests override retention period (honored within 30 days)

**Automated Archival Triggers:**
- No activity for 12 months (inactive candidates → `/var/talendelight/cv-storage/archive/inactive/{YYYY}/{MM}/`)
- Registration request rejected (immediate → `/var/talendelight/cv-storage/archive/rejected/{YYYY}/{MM}/`)
- Candidate requested account deletion (immediate archival, then 30-day soft delete)

**Manual Archival Triggers:**
- Operator/Manager marks candidate as "closed" or "not pursuing"
- Candidate explicitly withdraws consent for data processing
- Legal/compliance requirement (GDPR Article 17 - right to erasure)

**Archival Process:**
```
1. Identify candidates meeting archival criteria (daily cron job)
2. Move CV file to appropriate archive subdirectory (inactive/ or rejected/)
3. Update td_user_to_record_mapping: cv_archived_date, archive_reason
4. Email notification to candidate (7-day notice before archival)
5. Log archival action in td_cv_access_log (action: 'archive')
6. After 12 months in archive OR deletion request: Initiate soft delete
```

### 3.4 GDPR Compliance

**Storage Limitation (GDPR Article 5.1.e):**
- CVs kept "no longer than necessary" for recruitment purposes
- Active retention: 24 months max (recommendation)
- Inactive retention: 12 months max before archival (recommendation)
- Archived retention: 6 months max before hard deletion (recommendation)

**Right to Erasure (GDPR Article 17):**
- Candidates can request CV deletion at any time
- Deletion executed within 30 days of request
- Confirmation email sent to candidate
- Audit log entry created (who deleted, when, reason)

**Data Minimization (GDPR Article 5.1.c):**
- Only collect CVs when necessary (Scout submission, Operator-assisted)
- CV upload optional for candidate self-registration (can add later)

**Accountability (GDPR Article 5.2):**
- Complete audit trail in `td_cv_access_log` and `td_audit_log`
- Annual GDPR compliance review
- Records of Processing Activities (ROPA) maintained

---

## 4. Deletion Policy

### 4.1 Automated Deletion

**Triggers:**
- ✅ CV archived for 12 months (hard delete)
- ✅ Candidate deletion request (30-day soft delete grace period, then hard delete)
- ✅ Consent withdrawn (immediate soft delete, 30-day grace, then hard delete)
- ✅ Retention period override: User deletion request honored within 30 days (regardless of archival date)

**Soft Delete Process:**
```
1. Mark cv_deleted_date in database
2. Move file to deletion queue: /var/talendelight/cv-deletion-queue/
3. Email notification to candidate: "Your CV will be permanently deleted in 30 days"
4. Candidate can undo deletion within 30 days (restore to previous location)
5. After 30 days, hard delete job runs automatically
```

**Hard Delete Process:**
```
1. Verify cv_deleted_date > 30 days ago
2. Securely delete file (shred -u or equivalent)
3. Remove database entry from td_user_to_record_mapping
4. Log deletion in td_audit_log (permanent record)
5. Cannot be undone
```

**Deletion Schedule:**
- **Daily job (02:00 UTC):** Identify candidates meeting deletion criteria
- **Weekly job (Sunday 03:00 UTC):** Execute hard deletes for files in queue > 30 days
- **Monthly audit:** Review deletion logs for compliance

### 4.2 Manual Deletion Triggers

**User-Initiated:**
- Candidate requests account deletion via UI
- Candidate withdraws consent via email to privacy@talendelight.com
- Scout requests removal of submitted CV (rare, requires Manager approval)

**Staff-Initiated:**
- Manager approves deletion request (e.g., duplicate submission, spam)
- Legal/compliance requirement (GDPR DSAR, court order)
- Data breach containment (immediate hard delete)

**Process:**
```
1. Deletion request submitted (UI or email)
2. Manager reviews request (approval required for Scout/Staff-initiated)
3. If approved: Initiate soft delete process
4. Email confirmation to requester
5. 30-day grace period (user-initiated) or immediate hard delete (legal/breach)
6. Audit log entry with reason
```

### 4.3 Soft Delete vs Hard Delete

**Soft Delete (Default):**
- **Database:** `cv_deleted_date` timestamp set, `cv_file_path` unchanged
- **Filesystem:** File moved to `/var/talendelight/cv-deletion-queue/`
- **Grace Period:** ✅ **30 days** for user-initiated deletions (candidate can undo within this window)
- **Undo:** Candidate restores CV → file moved back to original location, cv_deleted_date cleared
- **Access:** File not accessible via download endpoint (shows "deleted" status)

**Hard Delete (Final):**
- **Database:** Row removed from `td_user_to_record_mapping`
- **Filesystem:** File securely deleted with `shred -u` (3-pass overwrite)
- **Audit Log:** Permanent record in `td_cv_access_log` (who, when, reason)
- **Irreversible:** Cannot be undone
- **Notification:** Final email sent: "Your CV has been permanently deleted"

**When Hard Delete Happens Immediately (No Grace Period):** ✅
- **Legal/court order** - Compliance with legal directive
- **Data breach containment** - Emergency security response
- **Compliance directive** - Regulatory requirement
- **Spam/malicious upload** - With Manager approval required

### 4.4 Audit Trail

**Database Table:** `td_cv_access_log`

```sql
CREATE TABLE td_cv_access_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    record_id VARCHAR(20) NOT NULL COMMENT 'CNDT/EMPL/SCOT-YYMMDD-seq',
    request_id VARCHAR(20) NOT NULL COMMENT 'USRQ-YYMMDD-seq',
    user_id BIGINT NOT NULL COMMENT 'WordPress user who accessed',
    action ENUM('download', 'view', 'upload', 'move', 'archive', 'soft_delete', 'hard_delete', 'restore') NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    reason TEXT COMMENT 'For deletions: user request, compliance, breach, etc.',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_record_id (record_id),
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Logged Actions:**
- **Upload:** CV uploaded via form (Forminator) or Operator-assisted
- **Move:** n8n job moved file to permanent storage
- **Download:** User downloaded CV via authenticated endpoint
- **View:** User viewed CV metadata (without download)
- **Archive:** CV moved to archive folder
- **Soft Delete:** CV marked for deletion (30-day grace)
- **Hard Delete:** CV permanently removed from filesystem
- **Restore:** Candidate restored CV within grace period

**Retention:**
- Audit logs kept for **7 years** (legal/compliance requirement)
- Logs NOT deleted when CV is deleted (permanent record)
- Annual export to secure archive storage

---

## 5. Consent & Compliance

### 5.1 Single Consent Checkbox Language

**For Candidate/Scout Self-Registration:**
```
☐ I consent to TalenDelight storing and processing my CV for recruitment purposes. 
   I understand that:
   - My CV will be shared with potential employers
   - My data will be stored securely and deleted after [XX] months of inactivity
   - I can withdraw consent and request deletion at any time via privacy@talendelight.com
   
   See our Privacy Policy for details: [link]
```

**For Operator/Manager-Assisted Registration:**
```
☐ I confirm that the candidate has provided verbal/written consent for TalenDelight 
   to store and process their CV for recruitment purposes.
   
   Operator Name: [auto-filled]
   Date: [auto-filled]
```

**Technical Implementation:**
- Checkbox NOT pre-checked (GDPR requires explicit opt-in)
- Form submission blocked if unchecked
- Consent timestamp recorded in `td_user_data_change_requests.consent_date`
- Consent text versioned (in case policy changes, track which version user agreed to)

### 5.2 Legal Basis (GDPR Article 6)

**STATUS: OPEN QUESTION - Added to WORDPRESS-OPEN-ACTIONS.md**

**Option A: Consent (Article 6.1.a)** ✅ Recommended
- Requires explicit opt-in checkbox
- Allows consent withdrawal = CV deletion
- Clear and transparent
- Industry standard for recruitment

**Option B: Legitimate Interest (Article 6.1.f)**
- Requires Legitimate Interest Assessment (LIA)
- Must balance TalenDelight interests vs candidate privacy
- More complex to explain
- Still allows candidate objection (triggers deletion)

**Decision Needed:** Manager to decide before MVP launch (blocked by LFTC-002)

### 5.3 Scout Submission Consent & Responsibility

**Scout Responsibility:**
- Scout must obtain candidate consent BEFORE submitting CV
- Scout attests to consent via checkbox during submission
- Scout receives email reminder of consent obligations

**Attestation Checkbox (Scout Submission Form):**
```
☐ I confirm that I have obtained explicit consent from the candidate to submit 
   their CV to TalenDelight for recruitment purposes. I have informed them that:
   - Their CV will be stored and processed by TalenDelight
   - Their CV may be shared with potential employers
   - They can request deletion at any time
   
   I understand that I am responsible for ensuring valid consent.
```

**Email to Scout (After Submission):**
```
Subject: CV Submitted - Consent Reminder

Dear [Scout Name],

Thank you for submitting a candidate CV (Record ID: CNDT-260125-1).

REMINDER: You are responsible for ensuring the candidate provided valid consent 
for TalenDelight to store and process their CV. If the candidate did not consent, 
please notify us immediately at privacy@talendelight.com.

Candidate Consent Requirements:
- Explicit opt-in (not assumed)
- Informed of data processing purposes
- Informed of right to deletion

If you have questions, contact: operations@talendelight.com

Best regards,
TalenDelight Operations Team
```

**Email Recipients:**
- **To:** Scout email
- **CC:** operations@talendelight.com (TalenDelight Operations team)

### 5.4 Cross-Border Transfer

**Current Status:** All employers EU-based ✅
- No cross-border data transfer issues
- No need for Standard Contractual Clauses (SCCs)
- GDPR applies to all data processing

**Future Considerations (Post-MVP):**
If expanding to non-EU employers:
1. Implement Standard Contractual Clauses (EU Commission approved)
2. Conduct Transfer Impact Assessment (TIA)
3. Document adequacy decisions (if employer in "adequate" country)
4. Update Privacy Policy with cross-border transfer language

**Open Action:** Added to WORDPRESS-OPEN-ACTIONS.md
- "Evaluate SCCs if expanding to non-EU employers (post-MVP)"
- "Conduct Transfer Impact Assessment (TIA) before non-EU expansion"

---

## 6. Technical Implementation

### 6.1 WordPress Integration (Forminator Upload)

**Form Configuration:**
- **Plugin:** Forminator Pro (file upload field)
- **Upload Directory:** `wp-content/uploads/forminator/{form-id}/`
- **File Size Limit:** 10MB (configurable in `config/uploads.ini`)
- **Allowed Extensions:** `.pdf`, `.doc`, `.docx`, `.txt`, `.rtf`, `.jpg`, `.jpeg`, `.png`

**Security:**
- File MIME type validation (not just extension check)
- Virus scanning via ClamAV (optional, to be evaluated in PENG-053/054)
- Filename sanitization (remove special characters, spaces)

### 6.2 n8n Automation Workflow

**Trigger:** Forminator webhook on form submission

**Workflow Steps:**
```
1. Receive webhook from Forminator (form data + file path)
2. Validate submission (check required fields, consent checkbox)
3. Generate Request ID (USRQ-YYMMDD-seq)
4. Generate Record ID (CNDT/EMPL/SCOT-YYMMDD-seq based on role)
5. Construct permanent file path: /var/talendelight/cv-storage/{YYYY}/{MM}/{record_id}-{timestamp}.{ext}
6. Move file from wp-content/uploads/forminator/ to permanent storage
7. Update database: td_user_data_change_requests.cv_file_path
8. Log action: td_cv_access_log (action: 'upload', then 'move')
9. Delete original file from Forminator directory
10. Send confirmation email to candidate (with Request ID)
```

**Error Handling:**
- If file move fails: Log error, alert Operations team, leave file in uploads directory
- If database update fails: Rollback file move, log error, alert Operations
- Daily cleanup job: Remove orphaned files in uploads directory (older than 24 hours)

**n8n Workflow File:** `infra/n8n/workflows/cv-upload-handler.json` (to be created in PENG-016)

### 6.3 Authenticated Download Endpoint

**Endpoint:** `/wp-json/talendelight/v1/cv/download`

**Parameters:**
- `record_id` (required): Business entity ID (CNDT-260125-1)
- `request_id` (optional): Request ID for audit trail
- `nonce` (required): WordPress nonce for CSRF protection

**Authentication:**
1. Verify WordPress user logged in (`is_user_logged_in()`)
2. Verify nonce (`wp_verify_nonce()`)
3. Check capability (`current_user_can('td_view_cvs')`)
4. If Scout: Verify owns submission (`td_user_owns_submission()`)
5. If Candidate: Verify owns CV (`record_id` matches user's record)

**Response:**
- **Success:** File download (Content-Type: application/octet-stream)
- **Error 401:** Not authenticated
- **Error 403:** Access denied (capability or ownership check failed)
- **Error 404:** File not found
- **Error 410:** File deleted (soft or hard delete)

**Audit Logging:**
- Every download logged to `td_cv_access_log`
- Includes: user_id, record_id, request_id, IP address, user agent, timestamp

### 6.4 Role-Based Access Control

**Capability Mapping (from ROLE-CAPABILITIES-MATRIX.md):**

| Role | Capability | CV Access |
|------|-----------|-----------|
| Administrator | All capabilities | All CVs |
| Manager | `td_view_cvs`, `td_manage_users` | All CVs |
| Operator | `td_view_cvs`, `td_manage_registrations` | All CVs |
| Scout | `td_submit_candidates` | Own submitted CVs only |
| Candidate | `read` (standard WP) | Own CV only (post-approval) |
| Employer | `read` (standard WP) | None (CVs shared via matching process) |

**Access Check Function:**
```php
function td_user_can_access_cv($user_id, $record_id, $request_id = null) {
    $user = get_userdata($user_id);
    
    // Admin always has access
    if (in_array('administrator', $user->roles)) {
        return true;
    }
    
    // Manager/Operator: Check td_view_cvs capability
    if (current_user_can('td_view_cvs')) {
        return true;
    }
    
    // Scout: Check ownership
    if (in_array('td_scout', $user->roles)) {
        return td_user_owns_submission($user_id, $request_id);
    }
    
    // Candidate: Check ownership
    if (in_array('td_candidate', $user->roles)) {
        $candidate_record = td_get_record_by_user_id($user_id);
        return ($candidate_record && $candidate_record->record_id === $record_id);
    }
    
    return false; // Default deny
}
```

### 6.5 Backup & Recovery

**Backup Strategy (3-2-1):**
- **3 Copies:** Production, daily backup, weekly offsite backup
- **2 Media Types:** Filesystem + cloud storage (S3 or equivalent)
- **1 Offsite:** AWS S3 or Backblaze B2

**Daily Backup (Automated):**
```bash
#!/bin/bash
# Daily backup script (cron: 01:00 UTC)

BACKUP_DIR="/var/backups/talendelight/cv-storage"
DATE=$(date +%Y%m%d)

# Create encrypted tarball
tar -czf - /var/talendelight/cv-storage/ | \
  gpg --encrypt --recipient backup@talendelight.com > \
  $BACKUP_DIR/cv-storage-$DATE.tar.gz.gpg

# Upload to S3
aws s3 cp $BACKUP_DIR/cv-storage-$DATE.tar.gz.gpg \
  s3://talendelight-backups/cv-storage/

# Delete local backup older than 7 days
find $BACKUP_DIR -name "cv-storage-*.tar.gz.gpg" -mtime +7 -delete
```

**Recovery Process:**
```bash
# 1. Download backup from S3
aws s3 cp s3://talendelight-backups/cv-storage/cv-storage-20260125.tar.gz.gpg .

# 2. Decrypt
gpg --decrypt cv-storage-20260125.tar.gz.gpg > cv-storage-20260125.tar.gz

# 3. Extract
tar -xzf cv-storage-20260125.tar.gz -C /var/talendelight/

# 4. Verify file count and permissions
ls -lR /var/talendelight/cv-storage/ | wc -l
```

**Backup Retention:**
- Daily backups: 7 days
- Weekly backups: 4 weeks
- Monthly backups: 12 months
- Annual backups: 7 years (compliance requirement)

---

## 7. Open Questions (Retention & Deletion)

**TO BE DECIDED (blocking COPS-001 completion):**

### Retention Periods

**Q1: Active Candidate Retention**
How long should CVs be kept for actively matched candidates?
- **Recommendation:** 24 months from last activity
- **Decision:** [PENDING]

**Q2: Inactive Candidate Retention**
How long should CVs be kept for rejected/inactive candidates?
- **Recommendation:** 12 months from last activity, then archive
- **Decision:** [PENDING]

**Q3: Archived CV Retention**
How long should archived CVs be kept before hard deletion?
- **Recommendation:** 6 months in archive, then hard delete
- **Decision:** [PENDING]

### Deletion Approach

**Q4: Soft Delete Grace Period**
How long should soft-deleted CVs be recoverable?
- **Recommendation:** 30 days for user-initiated deletions
- **Decision:** [PENDING]

**Q5: Immediate Hard Delete Triggers**
Which scenarios warrant immediate hard delete (no grace period)?
- **Recommendation:** Legal/court order, data breach, compliance directive, spam (Manager approval)
- **Decision:** [PENDING]

---

## 8. Implementation Checklist

**Phase 0 (Specification):**
- [x] Define storage location and directory structure
- [x] Define file naming convention
- [x] Document file movement workflow (Forminator → n8n → permanent)
- [x] Define access control and authentication requirements
- [x] Define encryption requirements (at rest, in transit, backup)
- [x] Document consent language (single checkbox)
- [x] Document Scout submission consent & email notification
- [x] Decide retention periods (active, inactive, archived) - ✅ **COMPLETED**
  - Active: 24 months OR 30 days after deletion request
  - Inactive: 12 months OR 30 days after deletion request
  - Archived: 12 months OR 30 days after deletion request
  - Rejected: Separate archive location (archive/rejected/)
- [x] Decide deletion approach (soft vs hard, grace periods) - ✅ **COMPLETED**
  - Soft delete: 30-day grace period (user can undo)
  - Hard delete triggers: Legal/court order, data breach, compliance, spam (Manager approval)
  - Deletion requests override retention periods (max 30 days)
- [ ] Decide GDPR legal basis (Consent vs Legitimate Interest) - **BLOCKED by LFTC-002**
- [x] Document audit trail requirements

**Phase 1 (Implementation - PENG-016 or separate task):**
- [ ] Create `/var/talendelight/cv-storage/` directory structure
- [ ] Create `td_cv_access_log` database table
- [ ] Implement authenticated download endpoint (`/wp-json/talendelight/v1/cv/download`)
- [ ] Implement role-based access control (`td_user_can_access_cv()`)
- [ ] Create n8n workflow for CV file movement
- [ ] Implement daily cleanup job (orphaned files in uploads directory)
- [ ] Implement weekly hard delete job (soft-deleted files > 30 days)
- [ ] Implement backup script (daily encrypted backup to S3)
- [ ] Configure Forminator upload limits and allowed file types
- [ ] Test end-to-end workflow (upload → move → download → delete)

**Phase 2 (Compliance - LFTC-002, PENG-014):**
- [ ] Finalize retention periods with legal review
- [ ] Finalize deletion approach with legal review
- [ ] Decide GDPR legal basis (Consent vs Legitimate Interest)
- [ ] Update Privacy Policy with CV lifecycle details
- [ ] Create DSAR (Data Subject Access Request) process for CV access/deletion
- [ ] Conduct annual GDPR compliance review

---

## 9. Related Tasks

**Dependencies:**
- None (COPS-001 can proceed independently)

**Blocks:**
- **PENG-014:** Privacy Policy creation (needs CV lifecycle policy details)
- **LFTC-002:** GDPR retention & deletion policy (legal review of retention periods)

**Related:**
- **PENG-001:** Record ID generation (used in CV file naming)
- **PENG-016:** Implement Record ID generation system (includes CV file movement n8n workflow)
- **LFTC-001:** Partner consent attestation (Scout submission consent)
- **LFTC-004:** Finalize consent text blocks (CV consent checkbox language)
- **COPS-002:** EU CSV export specification (may include CV file paths in export)
- **PENG-053/054:** Security hardening (may include virus scanning for CV uploads)

**Future Enhancements (Post-MVP):**
- Virus scanning integration (ClamAV)
- File-level encryption (in addition to filesystem encryption)
- Automated GDPR compliance reporting dashboard
- Self-service CV deletion (Candidate portal)
- CV version history (track updates to candidate CVs)

---

## 10. Compliance Recommendations (For WORDPRESS-OPEN-ACTIONS.md)

### GDPR Legal Basis Decision

**Task ID:** COPS-003 (to be added)

**Recommendation: Use Consent (GDPR Article 6.1.a)**

**Pros:**
- Clear and explicit
- Easy to explain to candidates
- Aligns with single consent checkbox approach
- Right to withdraw consent = easy deletion workflow
- Industry standard for recruitment

**Cons:**
- Must allow consent withdrawal (requires deletion workflow - already planned)
- Cannot process CVs after consent withdrawn (acceptable for recruitment)
- Requires explicit opt-in (cannot pre-check checkbox - GDPR compliant)

**Alternative: Legitimate Interest (GDPR Article 6.1.f)**
- Requires Legitimate Interest Assessment (LIA)
- More flexibility but more complex
- Still allows candidate objection (triggers deletion)

**Decision Required:** Before MVP launch (blocked by LFTC-002)

### Cross-Border Transfer Preparation

**Task ID:** COPS-004 (to be added)

**Current Status:** All employers EU-based (no issues)

**Future Safeguards (if expanding to non-EU employers):**
1. Implement Standard Contractual Clauses (SCCs) - EU Commission approved
2. Conduct Transfer Impact Assessment (TIA)
3. Document adequacy decisions (if employer in "adequate" country like UK, Japan)
4. Update Privacy Policy with cross-border transfer language

**Priority:** Post-MVP (only if business expands to non-EU employers)

---

**Document Status:** ✅ **Complete**  
**Created:** January 25, 2026  
**Last Updated:** January 25, 2026  
**Version:** v1.0 (Final)

**Decisions Made:**
- Active candidate retention: 24 months OR 30 days after deletion request
- Inactive candidate retention: 12 months OR 30 days after deletion request  
- Archived CV retention: 12 months OR 30 days after deletion request
- Rejected CVs: Separate archive location (archive/rejected/)
- Soft delete grace: 30 days (candidate can undo)
- Hard delete triggers: Legal/court order, data breach, compliance, spam (Manager approval)
- **Key principle:** User deletion requests override all retention periods (honored within 30 days)

**Next Steps:**
1. ✅ Mark COPS-001 as Done in WORDPRESS-MVP-TASKS.csv
2. Add post-MVP implementation features to WORDPRESS-BACKLOG.csv
3. Proceed to LFTC-001 (Partner consent attestation)
