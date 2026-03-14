# Multi-Contact Database Design (Future Feature)

**Status**: Design Complete - Pending Implementation  
**Target Release**: v3.8.0 or later (after v3.7.4 Save/Archive deployment)  
**Created**: March 14, 2026  
**Priority**: Medium (needed before Profile Pages feature)

## Problem Statement

**Current State (v3.7.4)**:
- Registration: Single email, phone, LinkedIn URL per user
- Stored in `wp_td_user_data_change_requests` table
- After "Save" action: Data copied to WordPress user (email only, phone/LinkedIn in user meta)

**Future Requirement**:
- Profile Page: Users need to maintain MULTIPLE phones, emails, files
- Current structure cannot support one-to-many relationships
- Need normalized database design for scalability

## Recommended Design: Junction Tables

### 1. wp_td_user_phones - Multiple Phone Numbers

```sql
CREATE TABLE wp_td_user_phones (
    id BIGINT(20) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT(20) UNSIGNED NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    phone_type ENUM('mobile', 'work', 'home', 'other') DEFAULT 'mobile',
    is_primary TINYINT(1) DEFAULT 0,
    is_verified TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES wp_users(ID) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_primary (user_id, is_primary),
    UNIQUE KEY unique_user_phone (user_id, phone_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Features**:
- Multiple phone numbers per user
- Type categorization (mobile, work, home, other)
- Primary flag for default contact number
- Verification status tracking
- Prevent duplicate phone numbers for same user
- CASCADE delete removes all phones when user deleted
- Indexed for fast queries

### 2. wp_td_user_emails - Multiple Email Addresses

```sql
CREATE TABLE wp_td_user_emails (
    id BIGINT(20) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT(20) UNSIGNED NOT NULL,
    email_address VARCHAR(200) NOT NULL,
    email_type ENUM('personal', 'work', 'other') DEFAULT 'personal',
    is_primary TINYINT(1) DEFAULT 0,
    is_verified TINYINT(1) DEFAULT 0,
    verification_token VARCHAR(64),
    verified_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES wp_users(ID) ON DELETE CASCADE,
    UNIQUE KEY unique_email (email_address),
    INDEX idx_user_id (user_id),
    INDEX idx_primary (user_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Features**:
- Multiple email addresses per user
- Global uniqueness constraint (one email = one user)
- Type categorization (personal, work, other)
- Primary flag for default email
- Email verification workflow support
- Verification token for email confirmation
- Timestamp tracking for verification

### 3. wp_td_user_files - Multiple Documents

```sql
CREATE TABLE wp_td_user_files (
    id BIGINT(20) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT(20) UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type ENUM('cv', 'certification', 'id_citizenship', 'id_residence', 'passport', 'other') NOT NULL,
    file_size INT UNSIGNED,
    mime_type VARCHAR(100),
    is_current TINYINT(1) DEFAULT 0,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES wp_users(ID) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_file_type (user_id, file_type),
    INDEX idx_current (user_id, file_type, is_current)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Features**:
- Multiple files per user
- File type categorization
- Track file metadata (size, MIME type)
- `is_current` flag for versioning (e.g., latest CV)
- Support for multiple CV versions
- Identity documents tracking
- Certification storage

## Benefits of This Design

### ✅ Advantages
1. **One-to-Many**: Unlimited phones/emails/files per user
2. **Primary Designation**: Mark default contact methods
3. **Type Categorization**: Distinguish work vs personal
4. **Verification Tracking**: Know which contacts are verified
5. **Fast Queries**: "Find user by any phone/email"
6. **Data Integrity**: Foreign keys with CASCADE delete
7. **Audit Trail**: Created/updated timestamps
8. **File Versioning**: Track document history, mark current
9. **Scalability**: Add new types without schema changes
10. **Standard SQL**: Portable, no JSON parsing overhead

### ❌ Alternative Rejected: User Meta
```php
// WordPress user meta (NOT RECOMMENDED)
update_user_meta($user_id, 'td_phones', json_encode([
    ['number' => '123', 'type' => 'mobile', 'primary' => true]
]));
```

**Why rejected**:
- Cannot query "find users with phone 123-456-7890"
- No referential integrity
- JSON parsing overhead in every query
- Hard to validate data types
- No proper indexing
- Difficult to maintain uniqueness constraints

## Migration Strategy

### Phase 1: Table Creation (Next Release)
1. Create migration file: `260314-1800-create-user-contact-tables.sql`
2. Apply to local database
3. Deploy to production
4. Verify indexes and constraints

### Phase 2: Populate from Registration (Save Action)
When user is "Saved" from `wp_td_user_data_change_requests`:

```php
// After wp_insert_user() succeeds:

// 1. Copy registration email to emails table
$wpdb->insert($wpdb->prefix . 'td_user_emails', [
    'user_id' => $user_id,
    'email_address' => $request->email,
    'email_type' => 'personal',
    'is_primary' => 1,
    'is_verified' => 1, // Auto-verified from registration
    'verified_at' => current_time('mysql')
]);

// 2. Copy registration phone to phones table
$wpdb->insert($wpdb->prefix . 'td_user_phones', [
    'user_id' => $user_id,
    'phone_number' => $request->phone,
    'phone_type' => 'mobile',
    'is_primary' => 1,
    'is_verified' => 0
]);

// 3. Copy CV file
if (!empty($request->cv_file_path)) {
    $wpdb->insert($wpdb->prefix . 'td_user_files', [
        'user_id' => $user_id,
        'file_name' => basename($request->cv_file_path),
        'file_path' => $request->cv_file_path,
        'file_type' => 'cv',
        'is_current' => 1
    ]);
}

// 4. Copy ID files
if (!empty($request->citizenship_id_file)) {
    $wpdb->insert($wpdb->prefix . 'td_user_files', [
        'user_id' => $user_id,
        'file_name' => basename($request->citizenship_id_file),
        'file_path' => $request->citizenship_id_file,
        'file_type' => 'id_citizenship'
    ]);
}

if (!empty($request->residence_id_file)) {
    $wpdb->insert($wpdb->prefix . 'td_user_files', [
        'user_id' => $user_id,
        'file_name' => basename($request->residence_id_file),
        'file_path' => $request->residence_id_file,
        'file_type' => 'id_residence'
    ]);
}
```

### Phase 3: Profile Page Integration
- Display all phones/emails/files
- Add new contact methods
- Mark primary contact
- Upload new files (CV versions)
- Delete old files

## File Storage Structure

```
wp-content/uploads/user-files/
  ├── {user_id}/
  │   ├── cv/
  │   │   ├── john-doe-cv-2026-01-15.pdf
  │   │   └── john-doe-cv-2026-03-10.pdf (is_current=1)
  │   ├── certifications/
  │   │   ├── aws-cert-2025.pdf
  │   │   └── scrum-master-2026.pdf
  │   └── identity/
  │       ├── citizenship-front.jpg
  │       ├── citizenship-back.jpg
  │       └── residence-permit.pdf
```

**Database stores**:
- `file_path`: `user-files/7/cv/john-doe-cv-2026-03-10.pdf`
- `file_name`: `john-doe-cv-2026-03-10.pdf`
- `file_type`: `cv`
- `is_current`: `1`

**Benefits**:
- User-specific directories prevent filename conflicts
- Type-based subdirectories organize by purpose
- Path stored relative to wp-content/uploads/
- Easy to implement file access control

## Helper Functions (To Be Created)

### Phone Management
```php
td_add_user_phone($user_id, $phone, $type, $is_primary)
td_get_user_phones($user_id)
td_get_primary_phone($user_id)
td_update_phone($phone_id, $data)
td_delete_phone($phone_id)
td_set_primary_phone($phone_id)
```

### Email Management
```php
td_add_user_email($user_id, $email, $type, $is_primary)
td_get_user_emails($user_id)
td_get_primary_email($user_id)
td_verify_email($email_id, $token)
td_delete_email($email_id)
td_set_primary_email($email_id)
```

### File Management
```php
td_upload_user_file($user_id, $file, $type)
td_get_user_files($user_id, $type = null)
td_get_current_cv($user_id)
td_set_current_file($file_id)
td_delete_file($file_id)
td_get_file_url($file_id)
```

## Dependencies

**Required Before Implementation**:
- [ ] Profile Pages feature design (UI/UX)
- [ ] File upload handling (security, validation)
- [ ] Email verification system
- [ ] Phone verification system (optional)

**Related Tasks**:
- Create migration files (3 tables)
- Update `td_save_request_ajax()` in user-requests-display.php
- Create helper functions mu-plugin
- Create profile page shortcodes
- Implement file upload handling
- Add email verification workflow

## Security Considerations

1. **File Upload Validation**
   - Whitelist allowed file types
   - Validate MIME types server-side
   - Scan for malware
   - Limit file sizes (CV: 5MB, ID: 2MB)

2. **Email Uniqueness**
   - Enforce UNIQUE constraint on email_address
   - Prevent user from claiming another user's email
   - Require verification for new emails

3. **Access Control**
   - Users can only view/edit their own contacts
   - Managers/Operators can view candidate contacts
   - Proper nonce validation on all AJAX endpoints

4. **Data Privacy**
   - GDPR compliance: Users can download all data
   - Right to deletion: CASCADE removes all contacts
   - Audit logging for sensitive changes

## Testing Checklist

- [ ] Create user, add multiple phones (3+)
- [ ] Set different primary phone
- [ ] Add multiple emails, verify uniqueness constraint
- [ ] Upload multiple CVs, mark one as current
- [ ] Upload ID documents
- [ ] Delete user, verify CASCADE removes all contacts
- [ ] Query: Find user by secondary email
- [ ] Query: Find user by work phone
- [ ] Performance test: 1000 users with 5 contacts each

## Timeline Estimate

- **Design**: ✅ Complete (March 14, 2026)
- **Migration Scripts**: 1 day
- **Helper Functions**: 2 days
- **Update Save Logic**: 1 day
- **Profile Page UI**: 3-5 days
- **Testing**: 2 days
- **Total**: ~10 days (2 weeks at 2hrs/day)

## References

- [WP-PROFILE-PAGES.md](WP-PROFILE-PAGES.md) - Profile page requirements (to be created)
- [WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md) - Database strategy
- [WORDPRESS-SECURITY.md](../../Documents/WORDPRESS-SECURITY.md) - Security guidelines
