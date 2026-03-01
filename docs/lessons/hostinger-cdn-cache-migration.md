# Lesson: Hostinger CDN Cache During Domain Migration

**Date:** March 1, 2026  
**Context:** Migrating talendelight.com to hireaccord.com on same Hostinger account  
**Issue:** Homepage showing old cached content despite successful server-side migration  
**Duration:** ~2 hours troubleshooting  
**Resolution:** Manual CDN cache purge via hPanel

---

## The Problem

After successfully migrating all files, database, and fixing WordPress settings, the homepage still showed old "Hello World" blog post when accessed via browser, despite server confirming Welcome page was correct.

---

## Root Cause

**Hostinger CDN (HCDN)** caches entire pages for **7 days** (604800 seconds). When domain content changes, the CDN edge servers continue serving cached versions until either:
1. Cache TTL expires (7 days)
2. Manual cache purge via hPanel
3. Cache-control headers force invalidation

**Key Indicators:**
```
x-hcdn-cache-status: HIT
x-hcdn-request-id: c0e8fb2675fd9ee6955d95aa009e5b87-bnk-edge3
Cache-Control: public, max-age=604800
Server: hcdn
```

---

## What Worked (Troubleshooting Journey)

### 1. Database Option Corruption ✅
**Problem:** `show_on_front` and `page_on_front` options weren't updating  
**Solution:** Delete and recreate options with autoload enabled

```bash
wp option delete show_on_front
wp option add show_on_front 'page' --autoload=yes
wp option delete page_on_front
wp option add page_on_front 6 --autoload=yes
```

**Lesson:** WordPress options can become corrupted during import. Delete+recreate is safer than update.

---

### 2. Persistent Object Cache ✅
**Problem:** Object cache (Redis/Memcached) serving stale option values  
**Solution:** Disable object cache temporarily

```bash
mv wp-content/object-cache.php wp-content/object-cache.php.disabled
wp cache flush
```

**Lesson:** Always disable persistent caching during major migrations.

---

### 3. LiteSpeed Cache .htaccess Rules ✅
**Problem:** .htaccess had cache rules even though plugin was inactive  
**Solution:** Remove LiteSpeed cache blocks from .htaccess

```bash
cp .htaccess .htaccess.backup
sed -i '/#.*BEGIN LSCACHE/,/#.*END LSCACHE/d' .htaccess
sed -i '/#.*BEGIN NON_LSCACHE/,/#.*END NON_LSCACHE/d' .htaccess
```

**Lesson:** Inactive plugins can leave cache rules in .htaccess. Always inspect after migration.

---

### 4. Diagnostic: Server vs Browser Test ✅
**Problem:** Server showed correct content, browser didn't  
**Solution:** Test with curl from server to isolate CDN issue

```bash
# From server (correct)
curl -sL https://hireaccord.com/ | grep "Welcome"

# From browser (cached)
Browser shows "Hello World"
```

**Lesson:** When server and browser differ, suspect CDN/proxy caching layer.

---

## What We Learned (Migration Procedure)

### Critical Migration Steps (Order Matters!)

1. **Backup first** (always)
2. **Upload files** (exclude wp-config.php, .htaccess)
3. **Import database** to target database
4. **URL search-replace** (all variations: domain, http://localhost, https://wp.local)
5. **Fix WordPress settings** (siteurl, home, blogname)
6. **Delete default content** (Hello World post, sample page)
7. **Fix front page settings** (delete+recreate if corrupted)
8. **Disable object cache** (during migration)
9. **Remove old cache rules** (.htaccess cleanup)
10. **Flush all caches** (WordPress, rewrite rules)
11. **🚨 CRITICAL: Purge CDN cache** (Hostinger hPanel)
12. **Test from browser** (not just server-side curl)

---

## The Solution (CDN Cache Purge)

### Via Hostinger hPanel (Required for Hostinger sites)

1. Log in: https://hpanel.hostinger.com/
2. Navigate: Websites → hireaccord.com
3. Go to: **Performance** section
4. Find: **CDN** settings
5. Click: **"Flush Cache"** button
6. Wait: 1-2 minutes for propagation
7. Test: Hard refresh browser (Ctrl+Shift+R)

### Preventive Headers (.htaccess)

Add cache-busting headers for HTML/PHP files:

```apache
<IfModule mod_headers.c>
    <FilesMatch "\.(html|htm|php)$">
        Header set Cache-Control "no-cache, no-store, must-revalidate"
        Header set Pragma "no-cache"
        Header set Expires "0"
    </FilesMatch>
</IfModule>
```

**Note:** Reduces CDN effectiveness, use only temporarily during migration.

---

## Key Takeaways

### ✅ Do This

1. **Always test from actual browser**, not just CLI tools
2. **Check response headers** for CDN indicators (x-hcdn-*, cf-*, x-cache)
3. **Purge CDN cache immediately** after any domain/content migration
4. **Disable persistent caching** (object cache, page cache) during migration
5. **Clean up .htaccess** after plugin deactivation
6. **Delete+recreate corrupted options** instead of updating
7. **Test multiple variations** (http/https, www/non-www, different browsers)

### ❌ Don't Do This

1. ❌ Assume browser cache is the only cache layer
2. ❌ Trust wp-cli output alone when browser shows different content
3. ❌ Skip CDN cache purge after migration
4. ❌ Leave object-cache.php enabled during major changes
5. ❌ Assume `wp cache flush` clears CDN cache (it doesn't)
6. ❌ Test only from server (curl) - always verify browser experience
7. ❌ Forget to remove old LiteSpeed/cache rules from .htaccess

---

## Cache Hierarchy (Hostinger WordPress)

Understanding the layers (from browser to origin):

```
Browser Cache
    ↓
DNS Cache
    ↓
CDN Cache (HCDN) ← THIS WAS THE PROBLEM
    ↓
LiteSpeed Cache (.htaccess rules)
    ↓
Object Cache (Redis/Memcached)
    ↓
WordPress Cache (transients, wp_options)
    ↓
Origin Server (actual files/database)
```

**Lesson:** Must clear ALL layers, from bottom to top, during migration.

---

## Time Estimates

| Task | Expected Time | Actual Time (This Migration) |
|------|--------------|------------------------------|
| File upload | 5 minutes | 3 minutes (73MB) |
| Database import | 2 minutes | 1 minute (95KB) |
| URL search-replace | 5 minutes | 3 minutes |
| Settings configuration | 5 minutes | 2 minutes |
| Cache troubleshooting | 15 minutes | **2 hours** ⚠️ |
| **Total** | **30 minutes** | **~2.5 hours** |

**Lesson:** Budget extra time for cache troubleshooting on managed hosting with CDN.

---

## Related Issues

- **DNS Propagation:** Can take 1-48 hours if DNS changed (not our case)
- **SSL Certificate:** Hostinger usually auto-provisions in 5-15 minutes
- **File Permissions:** Hostinger sets automatically, no manual chmod needed
- **wp-config.php:** Must preserve database credentials from target site

---

## Prevention for Next Time

### Pre-Migration Checklist

- [ ] Document current CDN settings (enable/disable status)
- [ ] Temporarily disable CDN if possible (or plan for purge)
- [ ] Disable LiteSpeed Cache plugin before migration
- [ ] Export clean database (without object cache data)
- [ ] Note down database credentials for target site

### Post-Migration Checklist

- [ ] Purge CDN cache via hPanel (CRITICAL)
- [ ] Flush WordPress cache
- [ ] Flush rewrite rules
- [ ] Delete Hello World post
- [ ] Test from multiple browsers
- [ ] Test incognito mode
- [ ] Test from mobile device (different network)
- [ ] Verify response headers show `x-hcdn-cache-status: MISS` (first time) then `HIT` (with correct content)

---

## External References

- **Hostinger CDN Docs:** https://support.hostinger.com/en/articles/6753421-wordpress-how-to-clear-cache
- **Related Lesson:** [powershell-encoding-corruption.md](powershell-encoding-corruption.md) - File encoding during page exports
- **Related Lesson:** [pattern-usage-consistency.md](pattern-usage-consistency.md) - Using block patterns correctly

---

## Success Metrics

**Before Fix:**
- Browser: "Hello World" blog post ❌
- Server curl: Welcome page content ✅
- Status: Mismatch indicating CDN cache issue

**After Fix:**
- Browser: Welcome page with "Talent for today" hero ✅
- Server curl: Welcome page content ✅
- Response headers: `x-hcdn-cache-status: MISS` then `HIT` (with correct content) ✅
- Status: **Migration successful** 🎉

---

**Bottom Line:** On Hostinger, **ALWAYS purge CDN cache** after domain migrations or major content changes. No amount of WordPress cache clearing will help if CDN is serving stale content.
