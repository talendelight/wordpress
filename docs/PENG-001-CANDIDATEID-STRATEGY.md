# PENG-001: CandidateID Strategy

**Status:** Done  
**Priority:** Critical  
**Phase:** Phase 0  
**Target Version:** v3.6.0  
**Owner:** Manager  
**Timeline:** Jan 25-26, 2026  
**Completed:** January 25, 2026  
**Dependencies:** None (foundation task)  
**Blocks:** PENG-015 (CPT), PENG-016 (Generation implementation), PENG-017 (Candidate form)

---

## 1. Overview

### 1.1 Purpose

Define a **unique, stable, human-readable identifier system** for all candidates that:
- ✅ Works across WordPress, Excel, and future Person app
- ✅ Survives WordPress → Person app migration
- ✅ Remains stable even if candidate changes email/phone/name
- ✅ Is easy to communicate verbally and in writing
- ✅ Maintains chronological order for operational efficiency

### 1.2 Business Context

**Problem:**
- Candidate email addresses can change
- LinkedIn URLs can be updated or deleted
- WordPress user IDs are WordPress-specific (won't transfer to Person app)
- Need a stable reference ID for cross-system tracking

**Solution:**
CandidateID serves as the **permanent unique identifier** that remains constant throughout the candidate lifecycle, regardless of profile updates or system migrations.

---

## 2. ID Format Specification

### 2.1 Format Definition

**Pattern:** `TD-YYYY-NNNN`

**Components:**
- **TD** - TalenDelight prefix (2 characters)
  - Fixed for MVP (pre-HireAccord rebrand)
  - Post-rebrand: Consider `HA-YYYY-NNNN` for HireAccord
  - Migration strategy: Keep TD- prefix for historical records, use HA- for new records post-rebrand
- **YYYY** - 4-digit year (submission year, not calendar year reset)
  - Example: 2026, 2027
  - Uses year of first submission (immutable)
- **NNNN** - 4-digit sequential number (0001-9999)
  - Resets to 0001 each calendar year
  - Zero-padded to 4 digits
  - Supports up to 9,999 candidates per year

**Examples:**
- `TD-2026-0001` - First candidate in 2026
- `TD-2026-0042` - 42nd candidate in 2026
- `TD-2026-9999` - 9,999th candidate in 2026
- `TD-2027-0001` - First candidate in 2027

### 2.2 Uniqueness Constraints

- **Global uniqueness:** Enforced across ALL candidate submissions (regardless of source)
- **Database constraint:** UNIQUE index on candidate_id column
- **Year boundary:** Sequential counter resets January 1 each year
- **Generation timing:** Assigned immediately upon form submission (pre-approval)
- **Immutability:** Once assigned, CandidateID NEVER changes (even if candidate resubmits)

### 2.3 Collision Handling

**Scenarios:**
1. **Same candidate submits multiple times:**
   - First submission gets CandidateID (e.g., TD-2026-0042)
   - Subsequent submissions detected by email match
   - Behavior: TBD - Create new registration request? Update existing? (See BMSL-002)

2. **Race condition (simultaneous submissions):**
   - Use database-level auto-increment with year boundary logic
   - Transaction safety ensures no duplicate numbers

3. **Year rollover edge case:**
   - Submission at 23:59:59 December 31 vs 00:00:01 January 1
   - Use submission timestamp year (not current server time)

---

## 3. Database Storage Strategy

### 3.1 Primary Storage Location

**Current Schema:** `td_user_data_change_requests` table  
**Status:** Handles registration requests for ALL roles (candidate, employer, scout, operator, manager)

**Problem:** This table is for **registration requests**, not approved candidates. CandidateID should be assigned to approved candidates only, or assigned at submission?

**Decision Point 1: When to Assign CandidateID?**

**Option A: Assign at Submission (Recommended)**
- ✅ Immediate unique reference for tracking (operators can say "check TD-2026-0042")
- ✅ ID survives approval/rejection (can reference rejected candidates)
- ✅ Simpler logic (no ID reassignment after approval)
- ❌ Non-candidates (employers, scouts) also in registration table - how to handle?

**Option B: Assign at Approval Only**
- ✅ CandidateID only exists for approved candidates
- ✅ Cleaner semantics (only real candidates have IDs)
- ❌ Can't reference unapproved submissions with stable ID
- ❌ Need temporary IDs for pre-approval tracking

**Recommended Approach: Option A with role-specific prefix** (see section 4.3)

### 3.2 Schema Design

**Option 1: Add candidate_id to td_user_data_change_requests (Quick MVP)**

```sql
ALTER TABLE td_user_data_change_requests 
ADD COLUMN candidate_id VARCHAR(20) NULL UNIQUE AFTER id,
ADD INDEX idx_candidate_id (candidate_id);
```

**Pros:**
- ✅ Fast implementation (1 column addition)
- ✅ CandidateID travels with registration record
- ✅ Available immediately for operator reference

**Cons:**
- ❌ Misnomer: Table name implies "user data changes" but candidate_id implies "candidate-specific"
- ❌ All roles share same table - need role-specific ID logic
- ❌ Not scalable if we need separate candidate master table later

**Option 2: Create dedicated td_candidates table (Future-proof)**

```sql
CREATE TABLE IF NOT EXISTS td_candidates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    candidate_id VARCHAR(20) NOT NULL UNIQUE,
    user_id BIGINT NULL COMMENT 'WordPress user ID if approved and account created',
    registration_request_id BIGINT NULL COMMENT 'Link to td_user_data_change_requests',
    full_name VARCHAR(300) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(50),
    linkedin_url VARCHAR(500),
    cv_file_path VARCHAR(500),
    status ENUM('pending', 'active', 'inactive', 'rejected') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_user_id (user_id),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_registration_request (registration_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Master candidate records with stable CandidateID';
```

**Pros:**
- ✅ Dedicated candidate master table (clean separation)
- ✅ Can link to registration requests via foreign key
- ✅ Supports candidate lifecycle beyond registration (active/inactive)
- ✅ Scalable for future features (interviews, placements, history)

**Cons:**
- ❌ More complex implementation (2-table workflow)
- ❌ Need to maintain sync between registration and candidate tables

**Option 3: Hybrid - Use CPT with candidate_id meta**

```php
// Register Custom Post Type
register_post_type('td_candidate', [
    'public' => false,
    'show_ui' => true,
    'supports' => ['title', 'custom-fields'],
]);

// Store CandidateID in post meta
add_post_meta($post_id, 'candidate_id', 'TD-2026-0001', true);
```

**Pros:**
- ✅ Leverages WordPress primitives (permissions, revisions, UI)
- ✅ Fast MVP implementation
- ✅ Meta queries available for searching

**Cons:**
- ❌ Meta queries slower at scale
- ❌ CSV export more complex
- ❌ Person app migration requires CPT → SQL extraction

### 3.3 Recommended Approach

**For MVP (v3.6.0):** Use **Option 1** - Add `candidate_id` column to `td_user_data_change_requests`

**Rationale:**
- Fastest implementation (single ALTER TABLE)
- CandidateID available immediately for operator reference
- Supports all registration types (candidate, employer, scout) with role-specific prefixes (see section 4.3)
- Can migrate to dedicated table in v3.7.0+ if needed

**For Post-MVP:** Refactor to **Option 2** when:
- Candidate record complexity increases (interview history, placement tracking)
- Performance issues with single table
- Person app migration requires clean candidate master table

---

## 4. ID Generation Logic

### 4.1 Generation Algorithm

**Pseudocode:**
```
function generate_candidate_id(submission_year):
    1. Get current max sequence number for submission_year
       SELECT MAX(CAST(SUBSTRING(candidate_id, 9, 4) AS UNSIGNED)) 
       FROM td_user_data_change_requests 
       WHERE candidate_id LIKE 'TD-{submission_year}-%'
    
    2. Increment sequence: next_seq = max_seq + 1
    
    3. Format: sprintf('TD-%04d-%04d', submission_year, next_seq)
    
    4. Return formatted ID
```

**PHP Implementation (Placeholder for PENG-016):**
```php
function td_generate_candidate_id($submission_date = null) {
    global $wpdb;
    
    $year = $submission_date ? date('Y', strtotime($submission_date)) : date('Y');
    $prefix = "TD-{$year}-";
    
    // Get max sequence for year
    $max_seq = $wpdb->get_var($wpdb->prepare(
        "SELECT MAX(CAST(SUBSTRING(candidate_id, 9, 4) AS UNSIGNED)) 
         FROM td_user_data_change_requests 
         WHERE candidate_id LIKE %s",
        $prefix . '%'
    ));
    
    $next_seq = ($max_seq === null) ? 1 : $max_seq + 1;
    
    // Format with zero padding
    return sprintf('%s%04d', $prefix, $next_seq);
}
```

### 4.2 Transaction Safety

**Race Condition Protection:**
- Use database transaction isolation
- Alternative: Use MySQL LAST_INSERT_ID() with helper table

**Helper Table Approach (Optional - More Robust):**
```sql
CREATE TABLE IF NOT EXISTS td_id_sequences (
    year YEAR PRIMARY KEY,
    last_sequence INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- Generation logic
START TRANSACTION;
INSERT INTO td_id_sequences (year, last_sequence) 
VALUES (2026, 1) 
ON DUPLICATE KEY UPDATE last_sequence = last_sequence + 1;

SELECT CONCAT('TD-', year, '-', LPAD(last_sequence, 4, '0')) AS candidate_id
FROM td_id_sequences WHERE year = 2026;
COMMIT;
```

### 4.3 Multi-Role ID System

**Challenge:** `td_user_data_change_requests` handles 5 role types (candidate, employer, scout, operator, manager), but CandidateID implies candidates only.

**Solution: Role-Specific Prefixes**

| Role | Prefix | Example | Notes |
|------|--------|---------|-------|
| **Candidate** | TD-YYYY-NNNN | TD-2026-0001 | Public users submitting for jobs |
| **Employer** | TE-YYYY-NNNN | TE-2026-0001 | Employer = TalenDelight Employer |
| **Scout** | TS-YYYY-NNNN | TS-2026-0001 | Scout = TalenDelight Scout |
| **Operator** | TO-YYYY-NNNN | TO-2026-0001 | Operator = TalenDelight Operator |
| **Manager** | TM-YYYY-NNNN | TM-2026-0001 | Manager = TalenDelight Manager |

**Column Rename:**
- Rename `candidate_id` → `td_user_id` (more accurate)
- Or keep `candidate_id` and use generic meaning (applies to all submission types)

**Decision:** Use `td_user_id` as column name, generate role-specific prefixes based on `role` column value.

**Updated Generation Logic:**
```php
function td_generate_user_id($role, $submission_date = null) {
    $role_prefixes = [
        'candidate' => 'TD',
        'employer' => 'TE',
        'scout' => 'TS',
        'operator' => 'TO',
        'manager' => 'TM',
    ];
    
    $prefix = $role_prefixes[$role] ?? 'TD';
    $year = $submission_date ? date('Y', strtotime($submission_date)) : date('Y');
    
    // Get max sequence for role + year
    $pattern = "{$prefix}-{$year}-%";
    $max_seq = $wpdb->get_var($wpdb->prepare(
        "SELECT MAX(CAST(SUBSTRING(td_user_id, 9, 4) AS UNSIGNED)) 
         FROM td_user_data_change_requests 
         WHERE td_user_id LIKE %s",
        $pattern
    ));
    
    $next_seq = ($max_seq === null) ? 1 : $max_seq + 1;
    
    return sprintf('%s-%04d-%04d', $prefix, $year, $next_seq);
}
```

**Examples:**
- Candidate registration → `TD-2026-0001`
- Employer registration → `TE-2026-0001`
- Scout registration → `TS-2026-0001`

---

## 5. Storage Implementation

### 5.1 Database Schema Change

**Current Table:** `td_user_data_change_requests` (created in 260117-impl)

**Required Change:**
```sql
ALTER TABLE td_user_data_change_requests 
ADD COLUMN td_user_id VARCHAR(20) NULL UNIQUE AFTER id,
ADD INDEX idx_td_user_id (td_user_id);
```

**Migration File:** `infra/shared/db/260125-{HHmm}-add-td-user-id.sql`

### 5.2 Timing of ID Assignment

**When:** Immediately after form submission, before status changes

**Trigger Points:**
1. **Forminator submission hook:** `forminator_form_after_save_entry`
   - Generate td_user_id based on role field
   - Update registration record with td_user_id
2. **Manual admin creation:** (if implemented later)
   - Generate td_user_id before INSERT
3. **CSV import:** (future Person app integration)
   - Preserve existing td_user_id from WordPress export

### 5.3 Null Handling

**Question:** Can td_user_id be NULL?

**Answer:** 
- **Transition period:** YES (existing records pre-PENG-001 may have NULL)
- **Post-deployment:** NO (all new submissions MUST have td_user_id)
- **Backfill strategy:** Run one-time migration to assign IDs to existing NULL records

**Backfill Script (Run Once After Deployment):**
```php
// WordPress admin page or WP-CLI command
function td_backfill_user_ids() {
    global $wpdb;
    
    $records = $wpdb->get_results(
        "SELECT id, role, submitted_date 
         FROM td_user_data_change_requests 
         WHERE td_user_id IS NULL 
         ORDER BY submitted_date ASC"
    );
    
    foreach ($records as $record) {
        $td_user_id = td_generate_user_id($record->role, $record->submitted_date);
        $wpdb->update(
            'td_user_data_change_requests',
            ['td_user_id' => $td_user_id],
            ['id' => $record->id],
            ['%s'],
            ['%d']
        );
    }
    
    return count($records);
}
```

---

## 6. Cross-System Mapping

### 6.1 WordPress → Excel → Person App

**Workflow:**

1. **Submission in WordPress:**
   - Registration form submitted
   - td_user_id generated: `TD-2026-0042`
   - Stored in `td_user_data_change_requests` table

2. **CSV Export to Excel:**
   - Column: `Candidate ID`
   - Value: `TD-2026-0042`
   - Excel template has Candidate ID column for tracking

3. **Person App Import (Future):**
   - Person app has `external_id` field
   - Maps WordPress `td_user_id` → Person app `external_id`
   - Enables lookups: "Find Person app record for TD-2026-0042"

### 6.2 ID Persistence Rules

**Immutable After Creation:**
- Once assigned, td_user_id NEVER changes
- Even if candidate:
  - Changes email
  - Updates phone
  - Resubmits CV
  - Changes name (marriage, etc.)

**Resubmission Strategy:**
- If candidate submits again with same email:
  - **Option A:** Create new registration request, link to existing td_user_id
  - **Option B:** Update existing registration request, preserve td_user_id
  - **Decision:** TBD in BMSL-002 (Candidate update policy)

### 6.3 Display & Communication

**Where Displayed:**
- Operator dashboard: Candidates table - first column
- Manager dashboard: Candidates table - first column
- Candidate detail page: Top-right corner or below name
- Email notifications: "Your submission (TD-2026-0042) has been..."
- CSV exports: First column

**Format in UI:**
- Always display with dashes: `TD-2026-0042`
- Clickable link to candidate detail page
- Copy-to-clipboard functionality (future UX enhancement)

---

## 7. Migration to Person App

### 7.1 ID Mapping Strategy

**Person App Schema (Future):**
```sql
CREATE TABLE persons (
    id UUID PRIMARY KEY,
    external_id VARCHAR(20) UNIQUE,  -- Stores TD-2026-0042
    source_system VARCHAR(50),       -- 'wordpress_talendelight'
    ...
);
```

**Mapping:**
- WordPress `td_user_id` → Person app `external_id`
- Person app has its own UUID primary key
- external_id enables lookups and data reconciliation

### 7.2 Migration Workflow

**Phase 1: CSV Export/Import (v3.6.0 - MVP)**
```csv
Candidate ID;Full Name;Email;Phone;LinkedIn;CV File;Status;Submitted Date
TD-2026-0001;John Doe;john@example.com;+1234567890;https://linkedin.com/in/john;TD-2026-0001_cv.pdf;Approved;2026-01-15 14:30:00
```

**Phase 2: API Integration (v3.7.0+)**
```http
POST /api/v1/persons/import
{
  "external_id": "TD-2026-0042",
  "source_system": "wordpress_talendelight",
  "email": "john@example.com",
  "full_name": "John Doe",
  ...
}
```

**Phase 3: Live Sync (v3.8.0+)**
- WordPress submits to Person app API on approval
- Person app returns UUID
- WordPress stores Person app UUID for bidirectional lookups

### 7.3 ID Stability Guarantee

**Contract:**
- WordPress td_user_id NEVER reused (even if record deleted)
- Person app external_id IMMUTABLE (no updates allowed)
- If duplicate found during migration, flag for manual reconciliation

---

## 8. Rebrand Considerations (TalenDelight → HireAccord)

### 8.1 Prefix Migration Strategy

**Current:** TD-YYYY-NNNN (TalenDelight)  
**Future:** HA-YYYY-NNNN (HireAccord)

**Options:**

**Option A: Hard Cutover (Recommended)**
- Keep TD- prefix for all records created before rebrand
- Switch to HA- prefix on rebrand date
- Historical records keep TD- (no retroactive changes)

**Option B: Retroactive Migration**
- Migrate all TD-YYYY-NNNN → HA-YYYY-NNNN
- Update database, exports, Person app
- Risk: Breaks existing references in Excel, emails, external systems

**Recommendation:** **Option A** (Hard Cutover)

**Implementation:**
```php
// Update generation function with brand-aware prefix
function td_get_brand_prefix($role, $submission_date = null) {
    $rebrand_date = '2026-04-05';  // MVP launch date
    $is_post_rebrand = $submission_date 
        ? (strtotime($submission_date) >= strtotime($rebrand_date))
        : (time() >= strtotime($rebrand_date));
    
    $role_prefixes = [
        'candidate' => $is_post_rebrand ? 'HA' : 'TD',
        'employer' => $is_post_rebrand ? 'HE' : 'TE',
        'scout' => $is_post_rebrand ? 'HS' : 'TS',
        'operator' => $is_post_rebrand ? 'HO' : 'TO',
        'manager' => $is_post_rebrand ? 'HM' : 'TM',
    ];
    
    return $role_prefixes[$role] ?? 'TD';
}
```

**Example Timeline:**
- Jan 2026: `TD-2026-0001`, `TD-2026-0002`, ...
- Apr 5, 2026 (rebrand): `HA-2026-0001`, `HA-2026-0002`, ...
- Historical: TD- records remain unchanged

### 8.2 UI Display

**After rebrand:**
- New submissions: Display as `HA-2026-NNNN`
- Historical submissions: Display as `TD-2026-NNNN` (original prefix preserved)
- Search: Support both TD- and HA- prefixes
- Export: Include both in CSV (historical TD- + new HA-)

---

## 9. Edge Cases & Validation

### 9.1 Invalid Submissions

**Scenarios:**
1. **Spam/bot submission:**
   - Still gets td_user_id (for tracking)
   - Marked as rejected
   - ID not reused

2. **Duplicate email:**
   - Check: Does email already exist in approved records?
   - If yes: Link to existing td_user_id OR generate new ID?
   - Decision: TBD in BMSL-002 (Candidate update policy)

3. **Test submissions:**
   - Dev environment: Use test data with TD-2025-XXXX range
   - Production: No special handling (real IDs for all submissions)

### 9.2 Validation Rules

**Format Validation:**
```php
function td_validate_user_id($td_user_id) {
    $pattern = '/^(TD|TE|TS|TO|TM|HA|HE|HS|HO|HM)-\d{4}-\d{4}$/';
    return preg_match($pattern, $td_user_id) === 1;
}
```

**Business Rules:**
- Year must be valid (2026-2035 range)
- Sequence must be 0001-9999
- Prefix must match role type
- No whitespace or special characters

### 9.3 Year Rollover

**December 31 → January 1 Transition:**
```
Dec 31, 2026 23:59:59 → TD-2026-9999
Jan 01, 2027 00:00:01 → TD-2027-0001
```

**Implementation:**
- Use submission timestamp year, not current server time
- Prevents timezone edge cases

---

## 10. Implementation Checklist

### Phase 0 (PENG-001 - This Document)
- [x] Define ID format: TD-YYYY-NNNN
- [x] Define role-specific prefixes (TD/TE/TS/TO/TM)
- [x] Choose storage strategy: Add to td_user_data_change_requests
- [x] Document generation algorithm
- [x] Document Person app mapping strategy
- [x] Document rebrand migration approach (TD → HA)
- [ ] **Review with user:** Confirm storage approach (column add vs dedicated table)
- [ ] **Review with user:** Confirm multi-role prefix strategy
- [ ] **Review with user:** Confirm assignment timing (submission vs approval)
- [ ] **Finalize:** Update WORDPRESS-DATABASE.md with schema decision
- [ ] **Finalize:** Create SQL migration file (260125-add-td-user-id.sql)

### Phase 1 (PENG-016 - Implementation)
- [ ] Create SQL migration file
- [ ] Implement PHP generation function
- [ ] Add Forminator hook to auto-assign on submission
- [ ] Create backfill script for existing records
- [ ] Add validation functions
- [ ] Write unit tests for generation logic
- [ ] Document in plugin README

### Phase 2 (PENG-017+ - Integration)
- [ ] Display td_user_id in operator dashboard tables
- [ ] Include td_user_id in email notifications
- [ ] Add td_user_id to CSV export (first column)
- [ ] Create UI for copying ID to clipboard
- [ ] Add search by td_user_id functionality

### Future (Person App Integration)
- [ ] Map td_user_id → Person app external_id
- [ ] Implement CSV import with ID preservation
- [ ] Create API endpoint for ID lookups
- [ ] Handle rebrand prefix migration (TD → HA)

---

## 11. Open Questions for Review

### Decision Points Requiring User Input:

1. **Storage Approach:**
   - ✅ Option 1: Add `td_user_id` column to `td_user_data_change_requests` (fast MVP)
   - ⏸️ Option 2: Create dedicated `td_candidates` table (future-proof)
   - **Recommendation:** Option 1 for MVP, refactor to Option 2 in v3.7.0+ if needed

2. **Column Naming:**
   - ✅ `td_user_id` (generic, applies to all roles)
   - ⏸️ `candidate_id` (traditional, but misnomer for employers/scouts)
   - **Recommendation:** `td_user_id` for accuracy

3. **Multi-Role Prefixes:**
   - ✅ Use role-specific prefixes: TD/TE/TS/TO/TM
   - ⏸️ Use TD- for everyone (simpler, but loses role visibility in ID)
   - **Recommendation:** Role-specific prefixes for clarity

4. **Assignment Timing:**
   - ✅ Assign at submission (before approval) - enables immediate tracking
   - ⏸️ Assign at approval (only approved users get IDs) - cleaner semantics
   - **Recommendation:** Assign at submission for operator reference

5. **Duplicate Email Handling:**
   - Deferred to BMSL-002 (Candidate update policy)
   - Options: Create new ID, reuse existing ID, block submission

6. **Helper Table for Sequences:**
   - ✅ Use helper table `td_id_sequences` for transaction safety
   - ⏸️ Use direct MAX() query with transaction (simpler, potential race condition)
   - **Recommendation:** Start with MAX() query, add helper table if race conditions detected

---

## 12. References

**Related Tasks:**
- BMSL-002: Candidate update policy (duplicate email handling)
- PENG-015: CPT td_registration_request (storage structure)
- PENG-016: Implement CandidateID generation system (PHP code)
- PENG-017: Forminator candidate registration form (integration point)
- COPS-001: CV lifecycle policy (CV filename uses td_user_id)

**Documentation:**
- [WORDPRESS-TECHNICAL-DESIGN.md](../../Documents/WORDPRESS-TECHNICAL-DESIGN.md) - Section 4.1 CandidateID generation
- [WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md) - Schema management
- [WORDPRESS-OPEN-ACTIONS.md](../../Documents/WORDPRESS-OPEN-ACTIONS.md) - CandidateID strategy decision
- [infra/shared/db/README.md](../infra/shared/db/README.md) - Delta file conventions

**Code References:**
- `infra/shared/db/260117-impl-add-td_user_data_change_requests.sql` - Current schema
- `infra/shared/db/260119-1400-add-role-and-audit-log.sql` - Added role column (enables role-specific IDs)

---

## 13. Next Steps

1. **User review this document** - Confirm decisions 1-6 from section 11
2. **Create SQL migration file** - Add td_user_id column to td_user_data_change_requests
3. **Update WORDPRESS-DATABASE.md** - Document final schema with td_user_id
4. **Update WORDPRESS-TECHNICAL-DESIGN.md** - Update section 4.3 field list with td_user_id
5. **Mark PENG-001 complete** - Update task status to Done
6. **Start PENG-016** - Implement PHP generation function (Phase 1 task)

---

**Document Version:** v1.0 (Draft for Review)  
**Created:** January 25, 2026  
**Last Updated:** January 25, 2026
