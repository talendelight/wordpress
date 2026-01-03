# WordPress Delete Lifecycle - Hands-On Learning

**Date**: December 30, 2025  
**Exercise**: Observing WordPress page deletion behavior through database queries  
**Target**: Privacy Policy page (ID 3)

---

## Overview

This document captures hands-on learnings about WordPress content deletion mechanics by observing database and filesystem changes through three deletion phases:

1. **Active Content** - Normal page in draft status
2. **Soft Delete (Trash)** - Reversible deletion with restoration metadata
3. **Hard Delete (Permanent)** - Irreversible cascade deletion

---

## Phase 1: Initial State (Active Page)

**Database State:**
- `wp_posts`: 6 rows
- `wp_postmeta`: 4 rows
- `wp-content/uploads/`: 443 files

**Post ID 3 Details:**
```sql
ID: 3
post_title: Privacy Policy
post_name: privacy-policy
post_status: draft
post_type: page
```

**Post ID 3 Metadata (2 entries):**
- `_edit_lock`: User session timestamp
- `_wp_page_template`: default

---

## Phase 2: Soft Delete (Move to Trash)

### Action Taken
User clicked "Move to Trash" in WordPress admin (Pages → All Pages)

### Database Changes

**wp_posts: 6 → 7 rows (+1)**

| Change | Details |
|--------|---------|
| **Post ID 3 Modified** | `post_status`: draft → **trash**<br>`post_name`: privacy-policy → **privacy-policy__trashed** |
| **Post ID 7 Created** | NEW revision record<br>`post_type`: revision<br>`post_parent`: 3<br>`post_status`: inherit |

**wp_postmeta: 4 → 7 rows (+3)**

Post ID 3 gained 3 new restoration metadata keys:

| meta_key | meta_value | Purpose |
|----------|------------|---------|
| `_wp_desired_post_slug` | privacy-policy | Original slug for restoration |
| `_wp_trash_meta_status` | draft | Original status for restoration |
| `_wp_trash_meta_time` | 1767080011 | Unix timestamp of trash action |

Additionally:
- `_edit_lock` updated with new timestamp
- `_wp_page_template` retained: default

**Total Post ID 3 metadata: 5 entries**

**Filesystem Changes:**
- No changes to `wp-content/uploads/` (443 files remain)

---

## Phase 3: Hard Delete (Permanent Deletion)

### Action Taken
User clicked "Delete Permanently" in WordPress admin (Pages → Trash)

### Database Changes

**wp_posts: 7 → 5 rows (-2)**

| Removed | Details |
|---------|---------|
| **Post ID 3** | Privacy Policy page completely deleted |
| **Post ID 7** | Associated revision cascade deleted |

**Remaining Posts (5):**
1. Hello world! (post, publish)
2. Sample Page (page, publish)
4. Auto Draft (post, auto-draft)
5. Navigation (wp_navigation, publish)
6. Custom Styles (wp_global_styles, publish)

**wp_postmeta: 7 → 2 rows (-5)**

All 5 metadata entries for Post ID 3 removed:
- ❌ `_edit_lock`
- ❌ `_wp_desired_post_slug`
- ❌ `_wp_page_template`
- ❌ `_wp_trash_meta_status`
- ❌ `_wp_trash_meta_time`

**Remaining metadata (2 entries, both for Post ID 2 - Sample Page):**
- `_edit_lock`
- `_wp_page_template`

**Filesystem Changes:**
- No changes to `wp-content/uploads/` (443 files remain)

---

## Key Learnings

### 1. Soft Delete (Trash) Strategy

WordPress implements **safe, reversible deletion** with full restoration capability:

**Slug Management:**
- Original slug: `privacy-policy`
- Trashed slug: `privacy-policy__trashed`
- **Purpose**: Frees original URL for immediate reuse while preserving uniqueness

**Restoration Metadata:**
Three special keys enable complete restoration:
- `_wp_desired_post_slug` → Original URL
- `_wp_trash_meta_status` → Original publication state
- `_wp_trash_meta_time` → Audit trail timestamp

**Automatic Revision Creation:**
- WordPress creates revision (post_type: revision) before trashing
- Acts as safety backup linked via `post_parent`
- Preserves content snapshot at deletion time

### 2. Hard Delete (Permanent) Strategy

WordPress implements **cascade deletion** pattern:

**Parent-Child Cascade:**
- Deleting parent post (ID 3) automatically deletes child revision (ID 7)
- No orphaned revisions remain in database

**Complete Metadata Cleanup:**
- All `wp_postmeta` entries for deleted post removed
- No metadata orphans remain

**ID Retirement:**
- Post IDs 3 and 7 permanently retired from sequence
- **IDs are NEVER reused** in WordPress
- Next new post will use ID 8+

### 3. Comparison: Soft vs Hard Delete

| Aspect | Soft Delete (Trash) | Hard Delete (Permanent) |
|--------|---------------------|-------------------------|
| **Reversibility** | ✅ Fully reversible | ❌ Irreversible |
| **Post Status** | Changed to "trash" | Completely removed |
| **Slug** | Modified `__trashed` suffix | N/A (deleted) |
| **Metadata** | Adds 3 restoration keys | Removes all metadata |
| **Revisions** | Creates new revision | Cascade deletes revisions |
| **Database Impact** | Rows retained, data added | Rows completely removed |
| **ID Reuse** | ID preserved | ID retired permanently |

### 4. Filesystem Behavior

**No filesystem changes observed across all deletion phases** (443 files remained constant)

**Why?**
- Page had no featured image or media attachments
- WordPress only deletes media files when:
  - Attachment post_type is deleted
  - User explicitly deletes from Media Library
  - Plugin cleanup occurs

**Conclusion**: Content deletion ≠ Media deletion

### 5. Database Consistency

WordPress maintains perfect referential integrity:

✅ No orphaned revisions after parent deletion  
✅ No orphaned metadata after post deletion  
✅ Clean cascade pattern prevents database bloat  
✅ Trash mechanism provides safety net for accidental deletions

---

## SQL Commands Used

### Query All Posts
```sql
SELECT ID, post_title, post_name, post_status, post_type 
FROM wp_posts 
ORDER BY ID;
```

### Count Totals
```sql
SELECT COUNT(*) as total_posts FROM wp_posts;
SELECT COUNT(*) as total_postmeta FROM wp_postmeta;
```

### Query All Metadata
```sql
SELECT post_id, meta_key, LEFT(meta_value, 50) as meta_value_preview 
FROM wp_postmeta 
ORDER BY post_id, meta_key;
```

### Execution Method
```bash
podman exec wp-db mariadb -u root -ppassword -D wordpress -e "SQL_QUERY"
```

---

## Practical Implications

### For Developers

1. **Trash is not instant deletion** - budget for storage of trashed content
2. **Restoration requires metadata** - never manually delete restoration keys
3. **IDs never recycle** - don't hardcode post IDs in code
4. **Revisions auto-create** - consider revision limits for large sites
5. **Cascade deletes are automatic** - trust WordPress cleanup patterns

### For Database Management

1. **Trash cleanup strategy needed** - trashed posts accumulate over time
2. **Monitor `_wp_trash_meta_*` keys** - indicator of trash volume
3. **Revision control important** - revisions can bloat database
4. **Metadata cleanup automatic** - don't write manual cleanup scripts
5. **Sequential IDs leave gaps** - normal behavior, not corruption

### For Content Strategy

1. **30-day trash retention** - WordPress default (can be configured)
2. **Trash empties automatically** - via WP-Cron (if enabled)
3. **Restoration is complete** - URL, status, content all restored
4. **Media persists after delete** - requires separate Media Library cleanup
5. **Permanent deletion warning** - no technical recovery possible

---

## Related WordPress Constants

```php
// wp-config.php configurations

// Disable post revisions entirely
define('WP_POST_REVISIONS', false);

// Limit revisions per post
define('WP_POST_REVISIONS', 3);

// Trash retention period (days)
define('EMPTY_TRASH_DAYS', 30); // Default: 30 days

// Disable trash (immediate permanent delete)
define('EMPTY_TRASH_DAYS', 0);
```

---

## Conclusion

WordPress implements a **two-stage deletion model**:

1. **Trash (Soft Delete)** - Safety net with full restoration capability
2. **Permanent (Hard Delete)** - Complete cascade removal with ID retirement

This design prioritizes **user safety** (accidental deletion recovery) while maintaining **database integrity** (automatic cascade cleanup). The `__trashed` slug suffix pattern enables immediate URL reuse without conflicts.

**Bottom Line**: Trust WordPress deletion patterns - they're well-designed and battle-tested across millions of installations.

---

## Test Environment

- **WordPress Version**: 6.9.0
- **PHP Version**: 8.3
- **Database**: MariaDB 11.8.3
- **Environment**: Podman containers (local development)
- **Container Names**: wp (WordPress), wp-db (MariaDB)
