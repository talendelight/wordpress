# PENG-001: Record ID Generation Strategy (v2.0)

**Status:** In Review (Jan 30, 2026 - Simplified PRSN/CMPY System)  
**Priority:** Critical  
**Phase:** Phase 0  
**Original Completion:** January 25, 2026 (v1.0 with TD-YYYY-NNNN → CNDT/EMPL/SCOT/OPER/MNGR evolution)  
**Major Revision:** January 30, 2026 (v2.0 simplified to PRSN/CMPY system)

## Table of Contents
1. [Introduction & Simplification Rationale](#1-introduction--simplification-rationale)
2. [ID Format Specification](#2-id-format-specification)
3. [Database Storage Strategy](#3-database-storage-strategy)
4. [ID Generation Logic](#4-id-generation-logic)
5. [Storage Implementation](#5-storage-implementation)
6. [Cross-System Mapping](#6-cross-system-mapping)
7. [Migration to Person App](#7-migration-to-person-app)
8. [Rebrand Considerations](#8-rebrand-considerations)
9. [Edge Cases & Validation](#9-edge-cases--validation)
10. [Implementation Checklist](#10-implementation-checklist)
11. [Open Questions for Review](#11-open-questions-for-review)
12. [References](#12-references)
13. [Version History](#13-version-history)

---

## 1. Introduction & Simplification Rationale

### 1.1 Purpose

Define a **unique, stable, human-readable identifier system** for all WordPress registration submissions (people and companies). The identifier:
- **Survives email changes** - does not change even if user updates email
- **Enables cross-system tracking** - can reference submissions across WordPress, Excel exports, Person app
- **Human-friendly** - operators can say "check PRSN-260125-0042" instead of "user ID 1234567"
- **Immutable** - once assigned, never changes or reused
- **Entity-typed** - distinguishes between people and companies at a glance

### 1.2 Simplification from v1.0 to v2.0

**v1.0 System (Original - TD-YYYY-NNNN → Role-Specific Prefixes):**
- Started with TD-YYYY-NNNN (TalenDelight prefix, 4-digit year, 4-digit sequence)
- Evolved to 5 role-specific prefixes:
  - CNDT-YYMMDD-seq (Candidate)
  - EMPL-YYMMDD-seq (Employer)
  - SCOT-YYMMDD-seq (Scout)
  - OPER-YYMMDD-seq (Operator)
  - MNGR-YYMMDD-seq (Manager)
- Maintained dual ID system: USRQ-YYMMDD-seq (Request ID for all submissions) + role-specific Record ID

**v2.0 System (Simplified - Entity-Type Prefixes):**
- **Reduced to 2 entity-type prefixes** (instead of 5 role-specific):
  - **PRSN-YYMMDD-NNNN** - All people (candidates, scouts, operators, managers, employees)
  - **CMPY-YYMMDD-NNNN** - All companies (employers, clients)
- **Maintained dual ID system**: USRQ-YYMMDD-NNNN (Request ID unchanged) + PRSN/CMPY (Record ID simplified)
- Date format: YYMMDDInstead of YYYY for consistency with Request ID pattern
- Sequence: 4-digit NNNN (0001-9999) for scalability

**Rationale for Simplification:**
- ✅ **Fewer ID types to manage** - 2 instead of 5 reduces cognitive load
- ✅ **Clearer categorization** - Entity type (person vs company) more fundamental than role
- ✅ **Future-proof** - New roles (e.g., "consultant") automatically fit under PRSN without new prefix
- ✅ **Easier to understand** - "PRSN = Person, CMPY = Company" simpler than remembering 5 role codes
- ✅ **Simpler generation logic** - One function per entity type instead of five
- ✅ **Reduced maintenance** - Fewer ID patterns in documentation, code, tests

### 1.3 Scope

**This document covers:**
- Record ID format (PRSN/CMPY-YYMMDD-NNNN) - assigned after approval
- Request ID format (USRQ-YYMMDD-NNNN) - unchanged from v1.0
- Dual ID system mapping (1:1:1 rule: 1 Email = 1 WP User = 1 Request ID = 1 Record ID = 1 Role)
- Database storage strategy (td_user_data_change_requests table)
- Generation algorithms (entity-type detection logic)

**This document does NOT cover:**
- WordPress user ID (`wp_users.ID`) - auto-increment integer managed by WordPress core
- CandidateID terminology - **deprecated** (now "Record ID" to reflect all entity types)
- CV file naming - covered in COPS-001-CV-LIFECYCLE-POLICY.md
- Person app UUID mapping - covered in section 7

---

## 2. ID Format Specification

### 2.1 Format Definition

**Request ID (Pre-Approval):**
```
USRQ-YYMMDD-NNNN
```
- **USRQ** - User Request (unchanged from v1.0)
- **YYMMDD** - Submission date (2-digit year, 2-digit month, 2-digit day)
- **NNNN** - 4-digit sequential number (0001-9999, resets annually on Jan 1)

**Record ID (Post-Approval) - SIMPLIFIED:**
```
PRSN-YYMMDD-NNNN  (for all people: candidates, scouts, operators, managers, employees)
CMPY-YYMMDD-NNNN  (for all companies: employers, clients)
```
- **PRSN** - Person entity type (replaces CNDT/SCOT/OPER/MNGR)
- **CMPY** - Company entity type (replaces EMPL)
- **YYMMDD** - Approval date (2-digit year, 2-digit month, 2-digit day)
- **NNNN** - 4-digit sequential number (0001-9999, resets annually on Jan 1)

### 2.2 Examples

**People (PRSN prefix):**
- PRSN-260125-0001 - First person approved Jan 25, 2026 (could be candidate)
- PRSN-260125-0042 - 42nd person approved Jan 25, 2026 (could be scout)
- PRSN-260125-9999 - 9,999th person approved Jan 25, 2026
- PRSN-270101-0001 - First person approved Jan 1, 2027 (sequence reset)

**Companies (CMPY prefix):**
- CMPY-260125-0001 - First company approved Jan 25, 2026
- CMPY-260125-0042 - 42nd company approved Jan 25, 2026

**Request IDs (Pre-Approval):**
- USRQ-260125-0001 - First submission Jan 25, 2026 (entity type unknown until approved)

### 2.3 Uniqueness Constraints

**Global Uniqueness:**
- PRSN-YYMMDD-NNNN sequence is independent from CMPY-YYMMDD-NNNN sequence
- Both can have PRSN-260125-0001 and CMPY-260125-0001 simultaneously
- USRQ-YYMMDD-NNNN sequence is independent from both (shared across all entity types)

**Date Boundary:**
- Sequence resets to 0001 on January 1 of each year
- Example: PRSN-261231-9999 → PRSN-270101-0001

**Immutability:**
- Once assigned, Record ID NEVER changes
- Even if:
  - User changes email
  - User updates profile
  - User changes role (candidate → operator)
  - Company changes name

### 2.4 Collision Handling

**Scenario 1: Duplicate sequence (race condition)**
```sql
-- Transaction safety ensures no duplicates
START TRANSACTION;
-- Generate next sequence atomically
COMMIT;
```

**Scenario 2: Date rollover edge case**
```
Submission: Dec 31, 2026 23:59:59 → USRQ-261231-9999
Approval: Jan 1, 2027 00:00:01 → PRSN-270101-0001 (uses approval date, not submission date)
```

**Scenario 3: Year boundary at 9999 sequence**
```
If 9999 reached before year end: ERROR (admin must manually intervene)
Mitigation: Monitor daily volume, alert if >8000/day
```

---

## 3. Database Storage Strategy

### 3.1 Current Table Schema

**Table:** `td_user_data_change_requests` (created in 260117-impl)

```sql
CREATE TABLE IF NOT EXISTS td_user_data_change_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id VARCHAR(20) NULL UNIQUE COMMENT 'USRQ-YYMMDD-NNNN for all submissions',
    record_id VARCHAR(20) NULL UNIQUE COMMENT 'PRSN/CMPY-YYMMDD-NNNN for approved entities',
    user_id BIGINT NULL COMMENT 'WordPress user ID (wp_users.ID)',
    role ENUM('candidate', 'employer', 'scout', 'operator', 'manager', 'employee') NOT NULL,
    email VARCHAR(200) NOT NULL,
    full_name VARCHAR(300),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    submitted_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    approved_date DATETIME NULL,
    -- ... other fields
    INDEX idx_request_id (request_id),
    INDEX idx_record_id (record_id),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Key Points:**
- `request_id` - Assigned immediately on submission (USRQ-YYMMDD-NNNN)
- `record_id` - Assigned on approval (PRSN/CMPY-YYMMDD-NNNN based on role → entity type mapping)
- `role` - Determines whether to generate PRSN or CMPY prefix

### 3.2 Entity Type Mapping

```javascript
// Role → Entity Type Mapping (Simplified from v1.0's 5 prefixes)
const ENTITY_TYPE_MAP = {
    // People (PRSN)
    'candidate': 'PRSN',
    'scout': 'PRSN',
    'operator': 'PRSN',
    'manager': 'PRSN',
    'employee': 'PRSN',    // Future role
    
    // Companies (CMPY)
    'employer': 'CMPY'
};

function getEntityType(role) {
    return ENTITY_TYPE_MAP[role] || 'PRSN';  // Default to PRSN if unknown role
}
```

### 3.3 Timing of ID Assignment

**Request ID (USRQ):**
- **When:** Immediately after form submission, before approval
- **Trigger:** Forminator submission hook `forminator_form_after_save_entry`
- **Purpose:** Enable tracking of unapproved submissions

**Record ID (PRSN/CMPY):**
- **When:** On approval (status change from 'pending' → 'approved')
- **Trigger:** Admin approval action OR automated approval rule
- **Purpose:** Permanent identifier for approved entities only

---

## 4. ID Generation Logic

### 4.1 Entity-Type Detection Algorithm

**Pseudocode:**
```javascript
function generateRecordId(role, approvalDate = null) {
    // Step 1: Determine entity type
    const entityType = (role === 'employer') ? 'CMPY' : 'PRSN';
    
    // Step 2: Get approval date (defaults to today)
    const date = approvalDate ? new Date(approvalDate) : new Date();
    const yy = String(date.getFullYear()).slice(-2);
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const dd = String(date.getDate()).padStart(2, '0');
    const dateStr = `${yy}${mm}${dd}`;
    
    // Step 3: Get next sequence for entity type + date
    const prefix = `${entityType}-${dateStr}-`;
    const maxSeq = getMaxSequence(entityType, dateStr);  // Query database
    const nextSeq = (maxSeq === null) ? 1 : maxSeq + 1;
    
    // Step 4: Format with zero padding
    return `${prefix}${String(nextSeq).padStart(4, '0')}`;
}
```

### 4.2 PHP Implementation

```php
/**
 * Generate Record ID (PRSN/CMPY) based on role and approval date
 * @param string $role WordPress role (candidate, employer, scout, operator, manager, employee)
 * @param string|null $approval_date Optional approval date (defaults to today)
 * @return string Record ID (e.g., PRSN-260125-0042)
 */
function td_generate_record_id($role, $approval_date = null) {
    global $wpdb;
    
    // Step 1: Determine entity type
    $entity_type = ($role === 'employer') ? 'CMPY' : 'PRSN';
    
    // Step 2: Format date
    $date = $approval_date ? strtotime($approval_date) : time();
    $yy = date('y', $date);
    $mm = date('m', $date);
    $dd = date('d', $date);
    $date_str = $yy . $mm . $dd;
    
    // Step 3: Get max sequence for entity type + date
    $prefix = $entity_type . '-' . $date_str . '-%';
    $max_seq = $wpdb->get_var($wpdb->prepare(
        "SELECT MAX(CAST(SUBSTRING(record_id, 14, 4) AS UNSIGNED)) 
         FROM td_user_data_change_requests 
         WHERE record_id LIKE %s",
        $prefix
    ));
    
    $next_seq = ($max_seq === null) ? 1 : $max_seq + 1;
    
    // Step 4: Format with zero padding
    return sprintf('%s-%s-%04d', $entity_type, $date_str, $next_seq);
}

/**
 * Generate Request ID (USRQ) based on submission date
 * @param string|null $submission_date Optional submission date (defaults to today)
 * @return string Request ID (e.g., USRQ-260125-0042)
 */
function td_generate_request_id($submission_date = null) {
    global $wpdb;
    
    // Format date
    $date = $submission_date ? strtotime($submission_date) : time();
    $yy = date('y', $date);
    $mm = date('m', $date);
    $dd = date('d', $date);
    $date_str = $yy . $mm . $dd;
    
    // Get max sequence for date
    $prefix = 'USRQ-' . $date_str . '-%';
    $max_seq = $wpdb->get_var($wpdb->prepare(
        "SELECT MAX(CAST(SUBSTRING(request_id, 14, 4) AS UNSIGNED)) 
         FROM td_user_data_change_requests 
         WHERE request_id LIKE %s",
        $prefix
    ));
    
    $next_seq = ($max_seq === null) ? 1 : $max_seq + 1;
    
    return sprintf('USRQ-%s-%04d', $date_str, $next_seq);
}
```

### 4.3 Transaction Safety

**Race Condition Protection:**
```php
// Option A: Database transaction (recommended for low-medium volume)
global $wpdb;
$wpdb->query('START TRANSACTION');
$record_id = td_generate_record_id($role, $approval_date);
// ... insert/update record ...
$wpdb->query('COMMIT');

// Option B: Helper table with atomic increment (for high volume)
// See section 4.4 below
```

### 4.4 Helper Table Approach (Optional - More Robust)

```sql
CREATE TABLE IF NOT EXISTS td_id_sequences (
    entity_type ENUM('PRSN', 'CMPY', 'USRQ') NOT NULL,
    date_str CHAR(6) NOT NULL COMMENT 'YYMMDD',
    last_sequence INT NOT NULL DEFAULT 0,
    PRIMARY KEY (entity_type, date_str)
) ENGINE=InnoDB;

-- Generation logic with atomic increment
START TRANSACTION;
INSERT INTO td_id_sequences (entity_type, date_str, last_sequence) 
VALUES ('PRSN', '260125', 1) 
ON DUPLICATE KEY UPDATE last_sequence = last_sequence + 1;

SELECT CONCAT(entity_type, '-', date_str, '-', LPAD(last_sequence, 4, '0')) AS record_id
FROM td_id_sequences WHERE entity_type = 'PRSN' AND date_str = '260125';
COMMIT;
```

---

## 5. Storage Implementation

### 5.1 Database Migration

**Migration File:** `infra/shared/db/260130-1500-simplify-record-id-to-prsn-cmpy.sql`

```sql
-- PENG-001 v2.0: Simplify Record ID system from 5 prefixes to 2 entity types
-- Date: January 30, 2026
-- Status: Pending Review

-- Step 1: Add comment to clarify new format (no schema change needed)
ALTER TABLE td_user_data_change_requests 
MODIFY COLUMN record_id VARCHAR(20) NULL UNIQUE 
COMMENT 'PRSN/CMPY-YYMMDD-NNNN for approved entities (Person/Company)';

-- Step 2: Backfill existing NULL record_ids (if any pre-PENG-001 records exist)
-- This script will be run manually after deployment to convert any old CNDT/EMPL/SCOT/OPER/MNGR IDs
-- See backfill script in section 5.2 below
```

### 5.2 Backfill Strategy

**If migrating from v1.0 (CNDT/EMPL/SCOT/OPER/MNGR) to v2.0 (PRSN/CMPY):**

```php
/**
 * One-time backfill script: Convert old 5-prefix system to new 2-prefix system
 * Run via WP-CLI or admin page after deployment
 * WARNING: This changes historical Record IDs - coordinate with Excel exports!
 */
function td_backfill_record_ids_to_v2() {
    global $wpdb;
    
    $records = $wpdb->get_results(
        "SELECT id, record_id, role, approved_date 
         FROM td_user_data_change_requests 
         WHERE record_id LIKE 'CNDT-%' 
            OR record_id LIKE 'EMPL-%' 
            OR record_id LIKE 'SCOT-%' 
            OR record_id LIKE 'OPER-%' 
            OR record_id LIKE 'MNGR-%'
         ORDER BY approved_date ASC"
    );
    
    foreach ($records as $record) {
        // Extract date and sequence from old format (CNDT-260125-42 → 260125-0042)
        preg_match('/[A-Z]{4}-(\d{6})-(\d+)/', $record->record_id, $matches);
        $date_str = $matches[1];
        $old_seq = $matches[2];
        
        // Generate new Record ID with entity type
        $entity_type = ($record->role === 'employer') ? 'CMPY' : 'PRSN';
        $new_record_id = sprintf('%s-%s-%04d', $entity_type, $date_str, (int)$old_seq);
        
        // Update record
        $wpdb->update(
            'td_user_data_change_requests',
            ['record_id' => $new_record_id],
            ['id' => $record->id],
            ['%s'],
            ['%d']
        );
        
        error_log("Migrated: {$record->record_id} → {$new_record_id}");
    }
    
    return count($records);
}
```

**Migration Decision:**
- ✅ **Option A (Recommended):** Hard cutover - Keep old IDs for historical records, use PRSN/CMPY for new records starting from v2.0 deployment date
- ⏸️ **Option B:** Backfill migration - Convert all existing IDs to new format (breaks Excel export references, requires coordination)

---

## 6. Cross-System Mapping

### 6.1 WordPress → Excel → Person App

**Workflow:**

1. **Submission in WordPress:**
   - Registration form submitted
   - Request ID generated: `USRQ-260125-0042`
   - Stored in `td_user_data_change_requests` table

2. **Approval in WordPress:**
   - Admin approves submission
   - Record ID generated: `PRSN-260125-0042` (if person) or `CMPY-260125-0001` (if company)
   - Status updated to 'approved', `approved_date` set

3. **CSV Export to Excel:**
   - Column: `Request ID` - Value: `USRQ-260125-0042`
   - Column: `Record ID` - Value: `PRSN-260125-0042`
   - Excel template has both columns for tracking

4. **Person App Import (Future):**
   - Person app has `external_id` field
   - Maps WordPress `record_id` → Person app `external_id`
   - Enables lookups: "Find Person app record for PRSN-260125-0042"

### 6.2 ID Persistence Rules

**Immutable After Creation:**
- Once assigned, Record ID NEVER changes
- Even if person:
  - Changes email
  - Updates phone
  - Resubmits CV
  - Changes name (marriage, etc.)
  - Changes role (candidate → operator)

**Resubmission Strategy:**
- If person submits again with same email:
  - **Option A:** Create new Request ID, link to existing Record ID (update existing record)
  - **Option B:** Reject submission with "Email already registered" message
  - **Decision:** TBD in BMSL-002 (Candidate update policy)

### 6.3 Display & Communication

**Where Displayed:**
- Operator dashboard: Candidates table - first column (Record ID)
- Manager dashboard: Candidates table - first column (Record ID)
- Candidate detail page: Top-right corner or below name
- Email notifications: "Your submission (PRSN-260125-0042) has been..."
- CV file naming: `PRSN-260125-0042-1737800000.pdf` (Record ID + timestamp)

**Format in UI:**
- Always display with dashes: `PRSN-260125-0042`
- Clickable link to detail page
- Copy-to-clipboard functionality (future UX enhancement)

---

## 7. Migration to Person App

### 7.1 ID Mapping Strategy

**Person App Schema (Future):**
```sql
CREATE TABLE persons (
    id UUID PRIMARY KEY,
    external_id VARCHAR(20) UNIQUE,  -- Stores PRSN-260125-0042
    source_system VARCHAR(50),       -- 'wordpress_talendelight'
    entity_type ENUM('person', 'company'),
    ...
);
```

**Mapping:**
- WordPress `record_id` → Person app `external_id`
- Person app has its own UUID primary key
- `external_id` enables lookups and data reconciliation
- `entity_type` derived from prefix (PRSN → person, CMPY → company)

### 7.2 Migration Workflow

**Phase 1: CSV Export/Import (v3.6.0 - MVP)**
```csv
Request ID;Record ID;Entity Type;Full Name;Email;Phone;LinkedIn;CV File;Status;Submitted Date;Approved Date
USRQ-260125-0001;PRSN-260125-0001;person;John Doe;john@example.com;+1234567890;https://linkedin.com/in/john;PRSN-260125-0001-1737800000.pdf;Approved;2026-01-25 14:30:00;2026-01-25 15:00:00
USRQ-260125-0002;CMPY-260125-0001;company;TechCorp Ltd;contact@techcorp.com;+9876543210;;;Approved;2026-01-25 14:45:00;2026-01-25 15:15:00
```

**Phase 2: API Integration (v3.7.0+)**
```http
POST /api/v1/entities/import
{
  "external_id": "PRSN-260125-0042",
  "entity_type": "person",
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
- WordPress Record ID NEVER reused (even if record deleted)
- Person app `external_id` IMMUTABLE (no updates allowed)
- If duplicate found during migration, flag for manual reconciliation

---

## 8. Rebrand Considerations (TalenDelight → HireAccord)

### 8.1 Prefix Migration Strategy

**Current (Development):** PRSN/CMPY  
**Future (Post-Rebrand):** HA-PRSN/HA-CMPY? OR Keep PRSN/CMPY?

**Options:**

**Option A: No Change (Recommended)**
- Keep PRSN/CMPY prefixes unchanged after rebrand
- Rationale:
  - PRSN/CMPY are generic entity types, not brand-specific
  - No migration complexity
  - Historical records keep same IDs
  - External references (Excel, emails) remain valid

**Option B: Add Brand Prefix**
- Pre-rebrand: PRSN-260125-0001, CMPY-260125-0001
- Post-rebrand: HA-PRSN-260125-0001, HA-CMPY-260125-0001
- Rationale:
  - Clear brand association
  - Distinguishes TalenDelight vs HireAccord records
- Issues:
  - Longer IDs (22 characters vs 17)
  - More complex migration
  - Database VARCHAR(20) would need increase to VARCHAR(25)

**Recommendation:** **Option A** (No Change) - PRSN/CMPY are entity types, not brand identifiers

### 8.2 UI Display After Rebrand

**Logo/Branding:**
- Update "TalenDelight" → "HireAccord" in UI
- Update company email domain: @talendelight.com → @hireaccord.com
- Keep Record ID format unchanged: PRSN-260125-0001, CMPY-260125-0001

---

## 9. Edge Cases & Validation

### 9.1 Invalid Submissions

**Scenarios:**
1. **Spam/bot submission:**
   - Still gets Request ID (USRQ) for tracking
   - Marked as rejected
   - No Record ID assigned (remains NULL)
   - Request ID not reused

2. **Duplicate email:**
   - Check: Does email already exist in approved records?
   - If yes: Reject submission OR link to existing Record ID
   - Decision: TBD in BMSL-002 (Candidate update policy)

3. **Test submissions:**
   - Dev environment: Use test data with 250101-XXXX range (year 2025 for test data)
   - Production: Real IDs for all submissions

### 9.2 Validation Rules

**Format Validation:**
```php
function td_validate_record_id($record_id) {
    // PRSN-YYMMDD-NNNN or CMPY-YYMMDD-NNNN
    $pattern = '/^(PRSN|CMPY)-\d{6}-\d{4}$/';
    return preg_match($pattern, $record_id) === 1;
}

function td_validate_request_id($request_id) {
    // USRQ-YYMMDD-NNNN
    $pattern = '/^USRQ-\d{6}-\d{4}$/';
    return preg_match($pattern, $request_id) === 1;
}
```

**Business Rules:**
- Date must be valid (260101-269999 range for 2026-2099)
- Sequence must be 0001-9999
- Prefix must match entity type (role mapping)
- No whitespace or special characters

### 9.3 Year Rollover

**December 31 → January 1 Transition:**
```
Dec 31, 2026 23:59:59 → PRSN-261231-9999
Jan 01, 2027 00:00:01 → PRSN-270101-0001 (sequence reset)
```

**Implementation:**
- Use approval timestamp date, not current server time
- Prevents timezone edge cases

---

## 10. Implementation Checklist

### Phase 0 (PENG-001 v2.0 - This Document)
- [x] Define simplified ID format: PRSN/CMPY-YYMMDD-NNNN
- [x] Document entity type mapping (PRSN for people, CMPY for companies)
- [x] Choose storage strategy: Continue using td_user_data_change_requests
- [x] Document generation algorithm (simplified from 5 functions to 2)
- [x] Document Person app mapping strategy
- [x] Document rebrand migration approach (no change needed)
- [ ] **Review with user:** Confirm entity type approach (PRSN/CMPY vs old CNDT/EMPL/SCOT/OPER/MNGR)
- [ ] **Review with user:** Confirm migration strategy (hard cutover vs backfill)
- [ ] **Finalize:** Update WORDPRESS-DATABASE.md with schema decision
- [ ] **Finalize:** Create SQL migration file (260130-1500-simplify-record-id-to-prsn-cmpy.sql)
- [ ] **Finalize:** Update COPS-001 CV file naming convention

### Phase 1 (PENG-016 - Implementation)
- [ ] Update PHP generation functions (td_generate_record_id simplified)
- [ ] Update Forminator hooks for Request ID generation (unchanged)
- [ ] Update approval hooks for Record ID generation (simplified entity type logic)
- [ ] Create/update backfill script (if needed)
- [ ] Update validation functions (PRSN/CMPY patterns)
- [ ] Write unit tests for generation logic (2 entity types)
- [ ] Document in plugin README

### Phase 2 (PENG-017+ - Integration)
- [ ] Update operator dashboard tables (display Record ID)
- [ ] Update email notifications (PRSN/CMPY examples)
- [ ] Update CSV export columns (Record ID format)
- [ ] Update UI for copying ID to clipboard
- [ ] Add search by Record ID functionality
- [ ] Update CV file naming logic (COPS-001)

### Future (Person App Integration)
- [ ] Map Record ID → Person app external_id
- [ ] Implement CSV import with ID preservation
- [ ] Create API endpoint for ID lookups
- [ ] Handle entity type mapping (PRSN → person, CMPY → company)

---

## 11. Open Questions for Review

### Decision Points Requiring User Input:

1. **Entity Type Approach:**
   - ✅ **Confirmed:** Use PRSN (person) / CMPY (company) entity types (simpler than 5 role-specific prefixes)
   - Pending: Formal user approval of v2.0 simplification

2. **Migration Strategy (v1.0 → v2.0):**
   - ⏸️ **Option A:** Hard cutover - Keep old CNDT/EMPL/SCOT/OPER/MNGR IDs for historical records, use PRSN/CMPY for new records starting from deployment date
   - ⏸️ **Option B:** Backfill migration - Convert all existing IDs to PRSN/CMPY format (requires Excel export coordination)
   - **Recommendation:** Option A (hard cutover) for simplicity

3. **Rebrand Prefix Strategy:**
   - ✅ **Recommended:** No change - Keep PRSN/CMPY after TalenDelight → HireAccord rebrand (entity types, not brand identifiers)
   - ⏸️ Alternative: Add HA- prefix (HA-PRSN, HA-CMPY) to distinguish post-rebrand records

4. **Duplicate Email Handling:**
   - Deferred to BMSL-002 (Candidate update policy)
   - Options: Create new Request ID + link to existing Record ID, OR block submission

5. **Helper Table for Sequences:**
   - ✅ Start with direct MAX() query with transaction
   - ⏸️ Add helper table (td_id_sequences) if race conditions detected in production

---

## 12. References

**Related Tasks:**
- BMSL-002: Candidate update policy (duplicate email handling)
- PENG-015: CPT td_registration_request (storage structure) - **NOTE:** May be superseded by table-based approach
- PENG-016: Implement Record ID generation system (PHP code) - **Update needed for PRSN/CMPY**
- PENG-017: Forminator candidate registration form (integration point)
- COPS-001: CV lifecycle policy (CV filename uses Record ID) - **Update needed for PRSN/CMPY**

**Documentation:**
- [WORDPRESS-TECHNICAL-DESIGN.md](../../Documents/WORDPRESS-TECHNICAL-DESIGN.md) - Section 4.1 CandidateID generation - **Update needed**
- [WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md) - Schema management - **Update needed**
- [WORDPRESS-OPEN-ACTIONS.md](../../Documents/WORDPRESS-OPEN-ACTIONS.md) - CandidateID strategy decision - **Update needed**
- [infra/shared/db/README.md](../infra/shared/db/README.md) - Delta file conventions

**Code References:**
- `infra/shared/db/260117-impl-add-td_user_data_change_requests.sql` - Current schema
- `infra/shared/db/260119-1400-add-role-and-audit-log.sql` - Added role column (enables entity type detection)
- `infra/shared/db/260130-1500-simplify-record-id-to-prsn-cmpy.sql` - **To be created** for v2.0 migration

---

## 13. Version History

**v1.0 (January 25, 2026):**
- Initial strategy document
- Defined TD-YYYY-NNNN format (TalenDelight prefix, 4-digit year, 4-digit sequence)
- Evolved to 5 role-specific prefixes: CNDT/EMPL/SCOT/OPER/MNGR-YYMMDD-seq
- Maintained dual ID system: USRQ (Request ID) + role-specific Record ID
- Database storage in td_user_data_change_requests
- Status: Completed (Jan 25, 2026)

**v2.0 (January 30, 2026 - CURRENT):**
- **Major simplification:** Reduced from 5 role-specific prefixes to 2 entity-type prefixes
- **New format:** PRSN-YYMMDD-NNNN (people) and CMPY-YYMMDD-NNNN (companies)
- **Rationale:** Fewer ID types, clearer categorization, future-proof, easier to understand, simpler maintenance
- **Migration strategy:** Hard cutover (keep old IDs for historical records, use new format going forward)
- **Date format change:** YYYY → YYMMDD for consistency with Request ID pattern
- **Status:** In Review (awaiting user confirmation)
- **Breaking change:** Yes - new Record IDs will use PRSN/CMPY format (backward compatible with v1.0 for historical records)

**Next Steps:**
1. User review and approval of v2.0 simplification
2. Create SQL migration file (260130-1500-simplify-record-id-to-prsn-cmpy.sql)
3. Update WORDPRESS-DATABASE.md with final schema
4. Update COPS-001-CV-LIFECYCLE-POLICY.md with PRSN/CMPY file naming
5. Update WORDPRESS-TECHNICAL-DESIGN.md with entity type approach
6. Update WORDPRESS-OPEN-ACTIONS.md with simplified dual ID system description
7. Mark PENG-001 v2.0 complete
8. Start PENG-016 (PHP implementation with PRSN/CMPY logic)

---

**Document Version:** v2.0 (Major Revision - Simplified to PRSN/CMPY)  
**Created:** January 25, 2026 (v1.0)  
**Major Revision:** January 30, 2026 (v2.0)  
**Last Updated:** January 30, 2026  
**Supersedes:** PENG-001 v1.0 (TD-YYYY-NNNN → CNDT/EMPL/SCOT/OPER/MNGR system)
