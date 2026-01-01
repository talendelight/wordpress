# Elementor Page Building - Hands-On Learning

**Date**: December 30, 2025  
**Exercise**: Building and publishing a page with Elementor visual page builder  
**Page Created**: About Us (ID 15)

---

## Overview

This document captures hands-on learnings about Elementor page builder by observing database and filesystem changes through the page creation, editing, and publishing lifecycle.

**Key Focus Areas:**
1. Plugin activation impact on database
2. Page creation and auto-drafting
3. Elementor data storage architecture
4. Publishing and revision management
5. Permalink configuration

---

## Phase 1: Plugin Activation

### Before Activation (Baseline)

**System State:**
- **Tables**: 14 (core WordPress + LiteSpeed Cache)
- **wp_options**: 352 entries
- **Active plugins**: 1 (LiteSpeed Cache only)

### Blocksy Companion Activation

**Action**: Activated via WP Admin → Plugins

**Database Changes:**
```sql
-- Tables: No change (14 tables)
-- wp_options: 352 → 358 (+6 entries)
```

**New Options Added:**
- `blocksy_db_version: 2.1.23`
- 5 configuration/cache entries

**Key Insight:** Lightweight companion plugin, no schema changes.

---

### Elementor Activation

**Action**: Activated via WP Admin → Plugins

**Database Changes:**
```sql
-- Tables: 14 → 15 (+1 table)
-- wp_options: 358 → 384 (+26 entries)
```

**New Table Created:**
```sql
CREATE TABLE `wp_e_events` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_data` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
```

**Purpose:** Tracks Elementor usage events (analytics, feature usage)

**New Options Added (14 entries):**

| Option Name | Purpose |
|-------------|---------|
| `elementor_version` | Version tracking (3.34.0) |
| `elementor_active_kit` | Default design system post ID |
| `elementor_onboarded` | Setup wizard completion flag |
| `elementor_viewport_lg` | Large viewport breakpoint (1000px) |
| `elementor_viewport_md` | Medium viewport breakpoint (690px) |
| `elementor_disable_color_schemes` | Legacy color system disabled |
| `elementor_disable_typography_schemes` | Legacy typography disabled |
| `elementor_font_display` | Font loading strategy (swap) |
| `elementor_install_history` | Installation timestamp log |
| `elementor_events_db_version` | Events table version |
| `elementor_connect_site_key` | Unique site identifier |
| `elementor_landing_pages_activation` | Landing page feature flag |
| `elementor_checklist` | Onboarding checklist state (JSON) |
| `elementor_remote_info_feed_data` | News feed cache |

**Key Posts Created:**
- Post #8: "Default Kit" (elementor_library) - Global design system

---

## Phase 2: Page Creation & Editing

### Initial Page Creation

**Action**: Pages → Add New → Title: "About us"

**Database Changes:**
```sql
-- Before: 5 posts, 2 postmeta
-- After creation: 9 posts, 14 postmeta
```

**New Posts:**
- **Post #15**: "About us" page (draft status)
- **Post #8**: Default Kit (Elementor design system)
- **Post #11**: Custom Blocksy global styles
- **Post #10**: Auto-revision of page #15

**Initial Metadata for Page #15:**
```sql
_edit_last: 1                    -- Last user who edited
_edit_lock: timestamp:1          -- Edit session lock
_wp_page_template: default       -- Template selection
```

---

### Entering Elementor Editor

**Action**: Clicked "Edit with Elementor" button

**What Happens:**
1. Elementor loads visual editor interface
2. Creates initial auto-save
3. Adds Elementor-specific metadata

**No immediate database changes** - changes occur on first save/auto-save.

---

### Building Content (Editing Phase)

**Actions Performed:**
1. Added single-column section with heading widget
2. Styled heading (color, size, weight)
3. Added text editor widget
4. Created 3-column flexbox container
5. Added 3 icon box widgets
6. Added button widget with styling

**During Editing:**
- Multiple auto-saves triggered (every ~30 seconds)
- Each auto-save creates a revision post
- Revisions: Post #16, #17, #18, #19 (all inherit status, parent: 15)

**Auto-save Behavior:**
- Revisions have `post_type: revision`
- Revisions have `post_status: inherit`
- Revisions have `post_parent: 15` (links to original page)
- Revisions preserve full content snapshots

---

## Phase 3: Publishing

### Publish Action

**Action**: Clicked pink "PUBLISH" button (top-right)

**Database Changes:**
```sql
-- Posts: 9 → 12 (+3 from auto-saves during editing)
-- Postmeta: 14 → 31 (+17 entries for page 15)
```

**Post #15 Status Change:**
- `post_status`: draft → **publish**
- `post_name`: empty → **about-us** (slug generated)
- `post_modified`: Updated to publication time

**Final URL (with permalinks):** `/about-us/`  
**Without permalinks:** `/?page_id=15`

---

## Elementor Data Storage Architecture

### Critical Metadata for Page #15 (8 entries)

```sql
_edit_last: 1
_edit_lock: 1767093044:1
_wp_page_template: default

-- ELEMENTOR-SPECIFIC:
_elementor_data: [JSON]              -- Complete page design
_elementor_edit_mode: builder        -- Editor type
_elementor_template_type: wp-page    -- Content type
_elementor_version: 3.34.0           -- Version used
_elementor_page_assets: [serialized] -- CSS dependencies
```

### The `_elementor_data` JSON Structure

**Storage Format:** JSON array of element objects

**Example Structure:**
```json
[
  {
    "id": "f7b1ba4",
    "elType": "container",
    "settings": {
      "flex_direction": "column"
    },
    "elements": [
      {
        "id": "abc123",
        "elType": "widget",
        "widgetType": "heading",
        "settings": {
          "title": "Welcome to TalenDelight",
          "header_size": "h1",
          "color": "#2C3E50"
        }
      }
    ]
  }
]
```

**Key Properties:**
- `id` - Unique element identifier
- `elType` - Element type (container, section, column, widget)
- `widgetType` - Specific widget (heading, text-editor, icon-box, button)
- `settings` - All customization (text, colors, spacing, etc.)
- `elements` - Nested child elements (recursive structure)

**Size:** Can be large (10KB - 500KB+ for complex pages)

---

## Key Learnings

### 1. Elementor Uses Postmeta-Only Storage

**No separate content tables** - everything stored in `wp_postmeta`:
- ✅ Scalable with WordPress
- ✅ Works with standard WordPress backups
- ✅ Compatible with caching plugins
- ❌ Large JSON blobs in postmeta (performance consideration)

**Contrast with other builders:**
- Some builders create custom tables (more complex)
- Elementor relies on WordPress core architecture

---

### 2. Revision System During Editing

**WordPress auto-revisions work with Elementor:**
- Every auto-save = new revision post
- Complete page snapshots (including `_elementor_data`)
- Restoration possible via revisions panel

**Revision Cleanup:**
```php
// In wp-config.php
define('WP_POST_REVISIONS', 5);  // Limit to 5 revisions
define('WP_POST_REVISIONS', false);  // Disable completely
```

**Database Impact:**
- Each revision = 1 row in `wp_posts`
- Each revision = ~8-17 rows in `wp_postmeta` (duplicates all Elementor data)
- Can cause database bloat on high-traffic sites

---

### 3. Plugin Activation Impact

| Action | Tables Added | Options Added | Time |
|--------|--------------|---------------|------|
| Blocksy Companion | 0 | 6 | <1 sec |
| Elementor | 1 (`wp_e_events`) | 26 | ~2 sec |
| **Total** | **1** | **32** | **~3 sec** |

**Production Consideration:** Both plugins are lightweight on activation. Elementor's `wp_e_events` table stays small (analytics only).

---

### 4. Permalink Configuration Necessity

**Problem:** Without permalinks, pages use query strings:
- ❌ `/?page_id=15` (ugly, not SEO-friendly)

**Solution:** Set permalink structure:
- ✅ `/about-us/` (clean, SEO-optimized)

**Database Changes:**
```sql
-- Option added/updated:
permalink_structure: '/%postname%/'

-- Rewrite rules generated (large serialized array):
rewrite_rules: [serialized array of URL patterns]
```

**WordPress generates mod_rewrite rules in `.htaccess`:**
```apache
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```

**One-time setup** - persists across deployments.

---

### 5. Widget Asset Dependencies

**`_elementor_page_assets` Metadata:**

Tracks which widget CSS files to load:
```php
a:2:{
  s:6:"styles";
  a:2:{
    i:0;s:14:"widget-heading";
    i:1;s:15:"widget-icon-box";
  }
  s:7:"scripts";a:0:{}
}
```

**Purpose:** Performance optimization
- Only loads CSS for widgets actually used on the page
- Reduces frontend payload
- Dynamic asset loading system

---

## Practical Implications

### For Developers

**1. Database Queries:**
```sql
-- Get all Elementor pages:
SELECT p.ID, p.post_title, pm.meta_value 
FROM wp_posts p
JOIN wp_postmeta pm ON p.ID = pm.post_id
WHERE pm.meta_key = '_elementor_edit_mode' 
  AND pm.meta_value = 'builder';

-- Check page Elementor version:
SELECT meta_value FROM wp_postmeta 
WHERE post_id = 15 AND meta_key = '_elementor_version';

-- Get page design JSON:
SELECT meta_value FROM wp_postmeta 
WHERE post_id = 15 AND meta_key = '_elementor_data';
```

**2. Backup Strategy:**
- Standard WordPress backup includes all Elementor data ✅
- No need for separate Elementor exports (unless migrating)
- Database exports automatically include `_elementor_data`

**3. Migration Considerations:**
- Elementor data is portable (stored in standard WP tables)
- Export/import via WordPress XML includes Elementor pages
- URL search-replace tools work (data stored as text/JSON)

---

### For Content Management

**1. Revision Control:**
- Limit revisions to prevent bloat: `WP_POST_REVISIONS: 3-5`
- Clean old revisions periodically
- Monitor `wp_posts` table size

**2. Page Duplication:**
- Right-click page in Elementor → Duplicate
- Creates new post with cloned `_elementor_data`
- Fast way to create template variations

**3. Version Tracking:**
- Every page tracks `_elementor_version` used
- Important for compatibility during Elementor upgrades
- Can identify pages needing migration

---

### For Database Management

**1. Metadata Overhead:**

For Page #15 (simple page):
- **8 postmeta entries** per page
- **+4 entries per revision** (×4 revisions = 16 more)
- **Total: 24 postmeta rows** for one simple page

For complex pages:
- 10-20 postmeta entries base
- 50+ entries with many revisions
- Monitor `wp_postmeta` table growth

**2. JSON Storage Optimization:**
- `_elementor_data` stored as TEXT (not LONGTEXT)
- No indexing needed (queried by `post_id` only)
- Consider compression for very large pages

**3. Event Tracking:**
- `wp_e_events` grows slowly (~10-50 rows/day)
- Can be truncated periodically (analytics only)
- Not critical for site functionality

---

## Comparison: Elementor vs Classic Editor

| Aspect | Classic Editor | Elementor |
|--------|----------------|-----------|
| **Content Storage** | `post_content` column | `_elementor_data` postmeta |
| **Metadata Entries** | 2-5 | 8-20 |
| **Revisions** | Full content | Full design JSON |
| **Learning Curve** | Low | Medium |
| **Design Control** | Limited | Extensive |
| **Performance** | Faster (less overhead) | Slower (more assets) |
| **Flexibility** | Text-focused | Visual design-focused |

---

## Deployment Checklist

When deploying Elementor-built pages to production:

- [ ] Activate Elementor plugin
- [ ] Configure permalinks (one-time)
- [ ] Set revision limits in `wp-config.php`
- [ ] Test page loads (`/about-us/` should work)
- [ ] Check browser console for JavaScript errors
- [ ] Verify responsive design (mobile/tablet views)
- [ ] Test "Edit with Elementor" button for editors

---

## Related Documentation

- [RELEASE-NOTES.md](../RELEASE-NOTES.md) - Production deployment guide
- [251230-2030-enable-elementor-blocksy.sql](../../infra/shared/db/251230-2030-enable-elementor-blocksy.sql) - Database delta
- [WordPress Delete Lifecycle](wordpress-delete-lifecycle.md) - Related database patterns

---

## Test Environment

- **WordPress Version**: 6.9.0
- **PHP Version**: 8.3
- **Elementor Version**: 3.34.0
- **Blocksy Companion Version**: 2.1.23
- **Database**: MariaDB 11.8.3
- **Environment**: Podman containers (local development)

---

## Conclusion

Elementor is a **metadata-heavy page builder** that stores all design data as JSON in `wp_postmeta`. This approach:

✅ **Pros:**
- WordPress-native storage (no custom tables except analytics)
- Compatible with standard backup tools
- Portable and migration-friendly
- Powerful visual design capabilities

❌ **Cons:**
- Metadata bloat (many postmeta entries per page)
- Revision overhead (duplicates design JSON)
- Larger database queries (TEXT parsing)
- Performance considerations on high-traffic sites

**Bottom Line:** Elementor trades database simplicity for design flexibility. Proper revision management and monitoring are essential for long-term database health.

---

**Key Takeaway for Production:** Elementor pages are fully self-contained in `wp_postmeta`. Once plugins are activated and permalinks configured, pages automatically work across environments with standard WordPress export/import workflows.
