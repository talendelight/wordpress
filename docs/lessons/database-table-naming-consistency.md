# Lesson: Database Table Naming Consistency

**Date:** February 23, 2026  
**Context:** WordPress v3.6.3 registration flow deployment  
**Issue:** Production deployment failures due to hardcoded table names without WordPress prefix

## The Problem

During v3.6.3 deployment, registration form submissions failed with "Registration submission failed" errors. Root cause analysis revealed three separate MU plugins using hardcoded table names (`td_user_data_change_requests`, `td_id_sequences`) without dynamic WordPress prefix handling.

### What Went Wrong

1. **Local development maskedthe issue:**
   - Local SQL schemas define tables WITHOUT `wp_` prefix: `CREATE TABLE td_user_data_change_requests`
   - WordPress automatically adds `wp_` prefix at RUNTIME via `$wpdb` methods
   - Developers see `wp_td_user_data_change_requests` in database but reference `td_user_data_change_requests` in code
   - This worked ONLY because we used `$wpdb->insert()` ORM methods in some places

2. **Production had renamed tables:**
   - Earlier migration renamed `td_*` tables to `wp_td_*` format
   - Code referencing unprefixed names failed to find tables
   - Three files affected:
     - `record-id-generator.php` - ID generation failed (5 SQL queries)
     - `td-registration-handler.php` - Registration insert failed (2 queries)
     - `user-requests-display.php` - Manager dashboard showed "table not found" (20+ queries)

3. **Inconsistent patterns caused confusion:**
   ```php
   // WRONG - Won't work with raw SQL
   $wpdb->get_var("SELECT * FROM td_user_data_change_requests");
   
   // PARTIAL - Works with ORM but inconsistent
   $wpdb->insert('td_user_data_change_requests', $data);
   
   // CORRECT - Works everywhere
   $wpdb->get_var("SELECT * FROM {$wpdb->prefix}td_user_data_change_requests");
   $wpdb->insert($wpdb->prefix . 'td_user_data_change_requests', $data);
   ```

### Impact

- **3 production deployments** required to fix all affected files
- **User testing blocked** for ~2 hours while debugging
- **Multiple SSH sessions** needed for emergency fixes
- **Cache clears** required after each deployment
- **Manual SCP uploads** to bypass slow GitHub auto-sync

## The Solution

### Correct Pattern for WordPress Table Names

**In SQL Migration Files (source of truth):**
```sql
-- Define tables WITHOUT wp_ prefix (WordPress convention)
CREATE TABLE IF NOT EXISTS td_user_data_change_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_id VARCHAR(20) UNIQUE NOT NULL,
    ...
);
```

**In PHP Code (dynamic prefix):**

```php
global $wpdb;

// For raw SQL queries - use interpolation
$result = $wpdb->get_var("SELECT * FROM {$wpdb->prefix}td_user_data_change_requests WHERE id = 1");

// For $wpdb ORM methods - use concatenation
$wpdb->insert($wpdb->prefix . 'td_user_data_change_requests', $data);

// For table variable
$table = $wpdb->prefix . 'td_user_data_change_requests';
$wpdb->get_var("SELECT COUNT(*) FROM {$table}");
```

**Critical Rules:**
1. ✅ SQL schemas define tables WITHOUT `wp_` prefix (WordPress standard)
2. ✅ PHP code ALWAYS uses `$wpdb->prefix` for table references
3. ✅ Use `{$wpdb->prefix}table_name` in double-quoted SQL strings
4. ✅ Use `$wpdb->prefix . 'table_name'` for ORM method parameters
5. ❌ NEVER hardcode `wp_` prefix (not portable across WordPress installations)
6. ❌ NEVER reference unprefixed table names in raw SQL

### Files Fixed

**Commit 0c0599d4:** `record-id-generator.php`
- Changed 5 SQL queries from `td_id_sequences` to `{$wpdb->prefix}td_id_sequences`
- Functions: `td_generate_request_id()`, `td_generate_record_id()`, `td_get_sequence_stats()`

**Commit 19bf728f:** `td-registration-handler.php`
- Line 67: SELECT query for duplicate email check
- Line 204: INSERT query for new registration
- Changed to use `{$wpdb->prefix}td_user_data_change_requests` and `$wpdb->prefix . 'td_user_data_change_requests'`

**Commit aea1393f:** `user-requests-display.php`
- Changed 20+ table references across management shortcodes
- Fixed both SHOW TABLES checks and all SELECT/UPDATE/INSERT queries

## Prevention Strategy

### Pre-Deployment Checklist

**Before ANY database code deployment:**

1. **Search for unprefixed table references:**
   ```powershell
   Select-String -Path "wp-content\mu-plugins\*.php" -Pattern "FROM td_|INTO td_|UPDATE td_|LIKE 'td_" | Select-Object Path, LineNumber
   ```

2. **Verify SQL migration consistency:**
   - SQL files define tables WITHOUT prefix: `CREATE TABLE td_*`
   - PHP files reference tables WITH dynamic prefix: `{$wpdb->prefix}td_*`
   - No hardcoded `wp_` anywhere in custom table references

3. **Test with fresh database:**
   ```powershell
   podman-compose down -v
   podman-compose up -d
   # Verify all table operations work
   ```

4. **Check production table names BEFORE deploying code:**
   ```bash
   ssh production "wp db query 'SHOW TABLES' | grep td"
   ```

### Code Review Patterns

**Red flags to catch:**
- `FROM td_user_data_change_requests` without `$wpdb->prefix`
- `INSERT INTO td_id_sequences` without dynamic prefix
- `SHOW TABLES LIKE 'td_%'` without prefix handling
- Any reference to custom tables that doesn't use `$wpdb->prefix`

**Green patterns to encourage:**
- `FROM {$wpdb->prefix}td_` in double-quoted SQL
- `$wpdb->prefix . 'td_'` for ORM method parameters
- Consistent pattern across all database operations

### Testing Workflow

1. **Local testing:** Use ephemeral database (reset between tests)
2. **Production testing:** Create test script to verify table access
3. **Emergency fix workflow:**
   - Commit fix to develop
   - Merge to main  
   - Manual SCP upload (don't wait for GitHub auto-sync)
   - Clear cache immediately
   - Test with fresh page load
   - Verify browser console for errors

## Key Takeaways

1. **Local is source of truth** - SQL schemas define table names (unprefixed)
2. **WordPress adds prefix at runtime** - Code must use `$wpdb->prefix` dynamically
3. **Different patterns for different contexts:**
   - Raw SQL: `{$wpdb->prefix}td_*`
   - ORM methods: `$wpdb->prefix . 'td_*'`
4. **Testing alone isn't enough** - Must verify actual SQL queries work in production
5. **Manual verification critical** - Check production database state BEFORE deploying code changes

## Related Documentation

- [WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md) - Database strategy
- [SYNC-STRATEGY.md](docs/SYNC-STRATEGY.md) - Local/production sync approach
- [COMMAND-REGISTRY.md](.github/COMMAND-REGISTRY.md) - Database query commands
- [TASK-REGISTRY.md](.github/TASK-REGISTRY.md) - Database migration procedures

## Prevention Automation (Future)

Consider adding:
1. Pre-commit hook to scan for unprefixed table references
2. CI/CD lint check for database code patterns
3. Automated test that runs all database queries against both local and production-like schemas
4. Documentation generator that extracts table names from SQL files and verifies PHP usage
