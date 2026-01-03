# WP-CLI Database Access - Technical Investigation

**Date**: December 30, 2025  
**Issue**: `wp db query` command fails with mysql binary error  
**Environment**: WordPress 6.9.0 in Podman container (custom image with WP-CLI)

---

## Problem

Attempting to run database queries via WP-CLI fails:

```bash
podman exec wp wp db query "SELECT ID, post_title FROM wp_posts WHERE ID = 3;" --allow-root
```

**Error:**
```
Error: Failed to get current SQL modes. Reason: env: 'mysql': No such file or directory
```

---

## Root Cause Analysis

### Container Binary Investigation

**WordPress container (wp):**
```bash
podman exec wp which mysql
# Exit code: 1 (not found)

podman exec wp which mariadb
# Exit code: 1 (not found)

podman exec wp ls -la /usr/bin/ | Select-String -Pattern "mysql|maria"
# No output - binaries NOT present
```

**Database container (wp-db):**
```bash
podman exec wp-db ls -la /usr/bin/ | Select-String -Pattern "mysql|maria"
# 30+ mariadb binaries found:
# - mariadb (client)
# - mariadb-dump
# - mariadb-admin
# - etc.
```

### Finding

**WordPress container does NOT include mysql/mariadb client binaries**

The official `wordpress:6.9.0-php8.3-apache` Docker image:
- ✅ Includes Apache, PHP, WordPress core
- ✅ Includes WP-CLI (in our custom image)
- ❌ Does NOT include mysql/mariadb client CLI tools

**Why?**
- Security: Reduces attack surface
- Size: Keeps image lightweight
- Architecture: Database should be separate container
- Principle: WordPress communicates with database via PHP mysqli/PDO, not CLI

---

## WP-CLI's Dependency on MySQL CLI

WP-CLI's `wp db query` command:
1. Reads database credentials from `wp-config.php`
2. **Spawns external `mysql` binary** to execute SQL
3. Captures output and returns to user

**This architectural choice fails when mysql binary is missing.**

---

## Workarounds

### ✅ Solution 1: Direct MariaDB Container Access (RECOMMENDED)

Execute queries directly in database container:

```bash
# Interactive session
podman exec -it wp-db mariadb -u root -ppassword -D wordpress

# One-liner query
podman exec wp-db mariadb -u root -ppassword -D wordpress -e "SELECT ID, post_title FROM wp_posts WHERE ID = 3;"
```

**Pros:**
- ✅ Works immediately (no changes needed)
- ✅ Direct access to all MariaDB features
- ✅ Better performance (no PHP overhead)
- ✅ Cleaner output formatting

**Cons:**
- ❌ Bypasses WP-CLI abstraction
- ❌ Requires manual database credentials
- ❌ Doesn't leverage wp-config.php settings

---

### Solution 2: Install MySQL Client in WordPress Container

**Approach A: Runtime Installation (temporary)**

```bash
podman exec -it wp bash
apt-get update
apt-get install -y mariadb-client
```

**Persistence issue:** Lost on container restart

---

**Approach B: Dockerfile Modification (permanent)**

Modify `infra/dev/Dockerfile`:

```dockerfile
FROM wordpress:6.9.0-php8.3-apache

# Install WP-CLI (existing)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# NEW: Install MariaDB client for wp db commands
RUN apt-get update && \
    apt-get install -y mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER www-data
```

Then rebuild:

```bash
cd infra/dev
podman-compose build --no-cache
podman-compose up -d
```

**Pros:**
- ✅ Enables `wp db query`, `wp db export`, `wp db import`
- ✅ Persistent across container restarts
- ✅ Maintains WP-CLI abstraction

**Cons:**
- ❌ Increases image size (~30-50 MB)
- ❌ Additional dependency to maintain
- ❌ Slower build times

---

### Solution 3: Use WP-CLI PHP Database Commands (Limited)

Some database operations available via PHP:

```bash
# These work WITHOUT mysql binary:
podman exec wp wp db tables --allow-root
podman exec wp wp db size --allow-root
podman exec wp wp db check --allow-root

# These FAIL without mysql binary:
podman exec wp wp db query "..." --allow-root
podman exec wp wp db export --allow-root
podman exec wp wp db import file.sql --allow-root
```

**Limitation:** Cannot execute arbitrary SQL queries

---

## Comparison: Direct MariaDB vs WP-CLI

| Feature | Direct MariaDB | WP-CLI |
|---------|---------------|--------|
| **Availability** | ✅ Works now | ❌ Requires mysql binary |
| **Credentials** | Manual (-u/-p) | Auto from wp-config.php |
| **Performance** | ⚡ Fast (native) | 🐢 Slower (PHP wrapper) |
| **Output Format** | Table/JSON/CSV | Table/JSON/CSV |
| **Error Handling** | MariaDB native | WP-CLI wrapped |
| **Maintenance** | Zero overhead | Requires client install |
| **Use Case** | Database admin | WordPress automation |

---

## Recommendation

**For this project: Use Direct MariaDB Access (Solution 1)**

**Rationale:**
1. **Works immediately** - no changes to Dockerfile or image rebuilds
2. **Development focus** - we're doing database exploration, not production automation
3. **Better for learning** - exposes raw database operations
4. **Performance** - direct access is faster for large queries
5. **Flexibility** - full access to MariaDB features (EXPLAIN, SHOW, etc.)

**When to use WP-CLI `wp db` instead:**
- **Production automation** where `wp-config.php` credentials must be used
- **WordPress-specific tasks** like search-replace URLs
- **CI/CD pipelines** where WP-CLI abstraction is valuable
- **Shared hosting** where database container isn't directly accessible

---

## Command Reference

### Direct MariaDB Access Patterns

```bash
# Count rows
podman exec wp-db mariadb -u root -ppassword -D wordpress -e "SELECT COUNT(*) FROM wp_posts;"

# Query with formatting
podman exec wp-db mariadb -u root -ppassword -D wordpress -e "SELECT ID, post_title, post_status FROM wp_posts ORDER BY ID;"

# Export database
podman exec wp-db mariadb-dump -u root -ppassword wordpress > backup.sql

# Import database
podman exec -i wp-db mariadb -u root -ppassword wordpress < backup.sql

# Interactive session
podman exec -it wp-db mariadb -u root -ppassword -D wordpress
```

### WP-CLI Alternative Commands (that DO work)

```bash
# List tables
podman exec wp wp db tables --allow-root

# Database size
podman exec wp wp db size --allow-root

# Check database
podman exec wp wp db check --allow-root

# Optimize database
podman exec wp wp db optimize --allow-root

# Search and replace (WordPress-aware)
podman exec wp wp search-replace 'http://old.com' 'https://new.com' --allow-root

# Export via mysqldump (requires mysql client)
podman exec wp wp db export --allow-root  # ❌ FAILS without mysql binary
```

---

## Related Documentation

- [WordPress Delete Lifecycle](wordpress-delete-lifecycle.md) - Uses direct MariaDB access for observation
- [WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md) - Database management strategies
- [WP-CLI Database Commands](https://developer.wordpress.org/cli/commands/db/) - Official WP-CLI reference

---

## Conclusion

The "mysql binary not found" error is **expected behavior** in lightweight WordPress container images. For local development database operations:

1. **Use direct MariaDB container access** for queries and administration
2. **Reserve WP-CLI** for WordPress-specific operations (search-replace, config management)
3. **Consider installing mysql client** only if automating WP-CLI database tasks is essential

This approach provides the best balance of simplicity, performance, and maintainability for local development workflows.
