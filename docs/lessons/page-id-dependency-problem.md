# Lesson: Page ID Dependency Problem

**Date:** February 19, 2026  
**Issue:** Lost menu items and pages after database recreation  
**Root Cause:** WordPress uses auto-increment IDs that differ between environments

---

## What Happened

### The Timeline

1. **Before upgrade**: Production had 19 pages (IDs 2-50), local dev was working with older database
2. **During upgrade**: We ran `podman-compose down -v` which **destroyed all database data**
3. **After upgrade**: Fresh database created from `000000-0000-init-db.sql` (only 5 posts/pages)
4. **Result**: Lost pages 6-50 that existed in production but not in baseline SQL

### Page Comparison

**Baseline SQL (000000-0000-init-db.sql):**
```
ID 1: "Hello world!" (post)
ID 2: "Sample Page" (default WordPress)
ID 3: "Privacy Policy" (default WordPress draft)
ID 4: "Auto Draft"
ID 5: "Navigation" (wp_navigation)
```

**Production:**
```
ID 6: Welcome
ID 11: Log In
ID 12: Password Reset
ID 13: Register
ID 14: Account
ID 15: Profile
ID 16-21: Role pages (Employers, Candidates, Scouts, Managers, Operators, Help)
ID 43: Manager Actions
ID 44: Manager Admin
ID 49: Select Role
ID 50: Register Profile
+ default pages (2, 3)
```

**Local after recreation:**
```
ID 2: Sample Page
ID 3: Privacy Policy
ID 6: Welcome (manually restored)
ID 11: Help (manually restored)
ID 12: Log In (manually restored)
ID 13: Select Role (manually restored)
```

### The Core Problem: Auto-Increment IDs

**WordPress uses auto-increment integer IDs for everything:**
- Pages: `wp_posts.ID`
- Menu items: `wp_posts.ID` (nav_menu_item post type)
- Menu item references: `wp_postmeta` with `meta_key='_menu_item_object_id'`

**This causes environment drift:**
- Production page "Help" = ID 21
- Local page "Help" = ID 11 (created later in different order)
- Menu item referencing "page_id=21" breaks in local

---

## Why It's Hard to Fix

### WordPress Architecture Limitations

1. **No built-in UUID system** - WordPress doesn't use UUIDs or global identifiers
2. **Hard-coded ID references** - Menu items store `object_id` integers, not slugs
3. **Cross-table relationships** - IDs link across multiple tables (posts, postmeta, term_relationships)
4. **Plugin dependencies** - Many plugins assume stable IDs and store references

### Current Workarounds

**Option 1: Slug-based menu items (RECOMMENDED)**
- Use custom links with slug URLs: `/help/`, `/log-in/`, `/select-role/`
- ✅ Works across environments
- ✅ Survives database recreation
- ❌ Doesn't auto-update if slug changes
- ❌ Requires manual menu creation

**Option 2: Maintain ID parity in delta files**
- Create SQL files that INSERT pages with specific IDs
- ✅ Menu items with page references work
- ❌ Fragile - breaks if pages created in different order
- ❌ Hard to maintain as production evolves

**Option 3: Export/import with WP-CLI**
- Use `wp export/import` to preserve IDs
- ❌ Not compatible with SQL-based initialization
- ❌ Doesn't work for "database from scratch" approach

---

## Recommended Solution

### 1. Create Core Pages in Delta Files

Create delta SQL file with essential pages that must exist in local:

```sql
-- File: infra/shared/db/260219-1600-create-core-pages.sql

-- Insert Welcome page (ID will be assigned dynamically)
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES
(1, NOW(), NOW(), '', 'Welcome', '', 'publish', 'closed', 'open', '', 'welcome', '', '', NOW(), NOW(), '', 0, '', 0, 'page', '', 0),
(1, NOW(), NOW(), '', 'Help', '', 'publish', 'closed', 'open', '', 'help', '', '', NOW(), NOW(), '', 0, '', 0, 'page', '', 0),
(1, NOW(), NOW(), '', 'Log In', '', 'publish', 'closed', 'open', '', 'log-in', '', '', NOW(), NOW(), '', 0, '', 0, 'page', '', 0),
(1, NOW(), NOW(), '', 'Select Role', '', 'publish', 'closed', 'open', '', 'select-role', '', '', NOW(), NOW(), '', 0, '', 0, 'page', '', 0);

-- Set Welcome as homepage
UPDATE wp_options SET option_value = (SELECT ID FROM wp_posts WHERE post_name = 'welcome' LIMIT 1) WHERE option_name = 'page_on_front';
UPDATE wp_options SET option_value = 'page' WHERE option_name = 'show_on_front';
```

**Problem with this approach:** IDs will still differ from production. Production has ID 21 for Help, local will get next available ID.

### 2. Use Slug-Based Menu Items (BEST PRACTICE)

**Create menu with custom links instead of page references:**

```bash
# Delete old menu items (they reference page IDs)
wp menu item delete 8 9 10 --allow-root

# Add custom links using slugs (environment-agnostic)
wp menu item add-custom main-navigation "Welcome" "https://wp.local/" --porcelain --allow-root
wp menu item add-custom main-navigation "Register" "/select-role/" --porcelain --allow-root
wp menu item add-custom main-navigation "Help" "/help/" --porcelain --allow-root
wp menu item add-custom main-navigation "Login" "/log-in/" --porcelain --allow-root

# Flush cache
wp cache flush --allow-root
```

**Advantages:**
- ✅ Works regardless of page IDs
- ✅ Survives database recreation
- ✅ Can be scripted in delta files or rebuild scripts
- ✅ URLs work in both local and production (with different domains)

**Disadvantages:**
- ⚠️ Breaks if page slug changes (but WP auto-redirects old slugs)
- ⚠️ Requires domain substitution (wp.local vs talendelight.com)

### 3. Domain-Agnostic URLs in Menu

**Use root-relative URLs instead of absolute URLs:**

```sql
-- File: infra/shared/db/260219-1630-create-slug-based-menu.sql

-- Create nav menu
INSERT INTO wp_terms (name, slug, term_group) VALUES ('Main Navigation', 'main-navigation', 0);
SET @menu_id = LAST_INSERT_ID();
INSERT INTO wp_term_taxonomy (term_id, taxonomy, description, parent, count) VALUES (@menu_id, 'nav_menu', '', 0, 4);

-- Add menu items as custom links with relative URLs
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES
(1, NOW(), NOW(), '', 'Welcome', '', 'publish', 'closed', 'closed', '', uuid(), '', '', NOW(), NOW(), '', 0, '', 1, 'nav_menu_item', '', 0),
(1, NOW(), NOW(), '', 'Register', '', 'publish', 'closed', 'closed', '', uuid(), '', '', NOW(), NOW(), '', 0, '', 2, 'nav_menu_item', '', 0),
(1, NOW(), NOW(), '', 'Help', '', 'publish', 'closed', 'closed', '', uuid(), '', '', NOW(), NOW(), '', 0, '', 3, 'nav_menu_item', '', 0),
(1, NOW(), NOW(), '', 'Login', '', 'publish', 'closed', 'closed', '', uuid(), '', '', NOW(), NOW(), '', 0, '', 4, 'nav_menu_item', '', 0);

-- Add postmeta for each menu item (custom links)
INSERT INTO wp_postmeta (post_id, meta_key, meta_value)
SELECT ID, '_menu_item_type', 'custom' FROM wp_posts WHERE post_type = 'nav_menu_item' AND post_title = 'Welcome'
UNION ALL
SELECT ID, '_menu_item_url', '/' FROM wp_posts WHERE post_type = 'nav_menu_item' AND post_title = 'Welcome'
UNION ALL
SELECT ID, '_menu_item_menu_item_parent', '0' FROM wp_posts WHERE post_type = 'nav_menu_item' AND post_title = 'Welcome';

-- Repeat for other menu items...
```

**⚠️ Warning:** Raw SQL for nav menus is complex and error-prone. Better to use scripts.

---

## Implementation Plan

### Short-term (Current Session)

1. ✅ **Created pages manually** - Help, Log In, Select Role now exist in local
2. ✅ **Replaced menu items** - Changed from custom links to page references
3. ✅ **Enabled permalinks** - Set structure to `/%postname%/` for clean URLs
4. ✅ **Created delta file** - `260127-1600-enable-permalinks.sql` persists setting

### Medium-term (Next Database Recreation)

1. **Create core pages delta file** - Add SQL to create Welcome, Help, Log In, Select Role pages
2. **Use rebuild-navigation-menu.ps1** - Script already exists, needs to use custom links
3. **Update script** - Modify to create slug-based menu items instead of page references
4. **Document required pages** - List which pages are "infrastructure" vs "content"

### Long-term (Production Parity)

1. **Page inventory** - Document all pages in WORDPRESS-PAGE-SYNC-MANIFEST.md
2. **Categorize pages**:
   - **Core pages** (must exist in local): Welcome, Help, Log In, Select Role, Register Profile
   - **Content pages** (production-only): Employers, Candidates, Scouts, Managers, Operators
   - **Admin pages** (production-only): Manager Actions, Manager Admin
3. **Export strategy** - Periodically sync page content from production to local
4. **Backup strategy** - Already exists (restore/pages/), ensure coverage

---

## Prevention Checklist

Before next database recreation:

- [ ] Review `infra/shared/db/` files to ensure core pages are included
- [ ] Update `rebuild-navigation-menu.ps1` to use custom links (slug-based)
- [ ] Test database recreation: `podman-compose down -v && podman-compose up -d`
- [ ] Verify menu works after fresh start
- [ ] Document which pages are required vs optional
- [ ] Consider exporting production pages to `restore/pages/` before upgrade

---

## Key Takeaways

1. **WordPress IDs are not portable** - Auto-increment IDs differ between environments
2. **Slug-based references are safer** - Use `/page-slug/` URLs instead of page IDs
3. **Database recreation is destructive** - Always backup before `podman-compose down -v`
4. **Baseline SQL is vanilla WordPress** - Doesn't include production pages
5. **Delta files can't enforce ID parity** - New pages get next available ID regardless
6. **Menu items need special handling** - Either use custom links or sync pages first

**Best Practice:** Use slug-based menu items (`/help/`, `/log-in/`) instead of page references to avoid ID dependency issues.
