# Domain Migration Guide - Hostinger WordPress

**Purpose:** Migrate WordPress site from one domain to another on Hostinger shared hosting  
**Hosting Provider:** Hostinger (with CDN enabled)  
**Time Required:** 30 minutes (migration) + 15 minutes (CDN troubleshooting)  
**Difficulty:** Intermediate

---

## Prerequisites

Before starting migration:

- ✅ Source domain backup files (tar.gz format)
- ✅ Source domain database backup (sql.gz format)
- ✅ Target domain configured in Hostinger hPanel
- ✅ Target domain database created (note credentials from wp-config.php)
- ✅ SSH access configured (private key in tmp/hostinger_deploy_key)
- ✅ WP-CLI available on server
- ✅ 45 minutes of uninterrupted time

**⚠️ Critical:** Do NOT skip Step 14 (CDN Cache Purge) - it's the #1 reason migrations appear to fail.

---

## Migration Procedure

### Step 1: Upload Backup Files to Server

**Upload files archive:**
```powershell
# Upload website files (tar.gz)
scp -P 65002 -i "tmp\hostinger_deploy_key" "tmp\BACKUP.tar.gz" u909075950@45.84.205.129:/tmp/

# Upload database (sql.gz)
scp -P 65002 -i "tmp\hostinger_deploy_key" "tmp\BACKUP.sql.gz" u909075950@45.84.205.129:/tmp/
```

**Time:** 2-5 minutes (depending on backup size)

---

### Step 2: Extract and Sync Files

**Extract backup:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /tmp && tar -xzf BACKUP.tar.gz"
```

**Sync files to target domain (exclude wp-config.php and .htaccess):**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "rsync -av --exclude='wp-config.php' --exclude='.htaccess' /tmp/domains/OLDDOMAIN.com/public_html/ /home/u909075950/domains/NEWDOMAIN.com/public_html/"
```

**Why exclude?** Preserve target site's database connection and Apache configuration.

**Time:** 3-5 minutes

---

### Step 3: Import Database

**Get target database credentials:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "grep -E 'DB_NAME|DB_USER|DB_PASSWORD|DB_HOST' /home/u909075950/domains/NEWDOMAIN.com/public_html/wp-config.php | grep define"
```

**Example output:**
```
DB_NAME: u909075950_dKHfh
DB_USER: u909075950_Fkjrp
DB_PASSWORD: ajdawZS4fe
DB_HOST: 127.0.0.1
```

**Decompress and import:**
```bash
# Decompress SQL
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /tmp && gunzip BACKUP.sql.gz"

# Import to target database (replace credentials)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "mysql -h 127.0.0.1 -u DB_USER -pDB_PASSWORD DB_NAME < /tmp/BACKUP.sql"
```

**Time:** 1-2 minutes

---

### Step 4: URL Search-Replace (CRITICAL)

**Replace old domain with new domain in all database tables:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html && wp search-replace 'olddomain.com' 'newdomain.com' --all-tables --report-changed-only"
```

**Expected output:** ~100-150 replacements across multiple tables
```
Table   Column  Replacements    Type
wp_options      option_value    2       PHP
wp_posts        post_content    2       SQL
wp_posts        guid    64      SQL
Success: Made 119 replacements.
```

**Also replace local development URLs if present:**
```bash
# Replace localhost
wp search-replace 'http://localhost:8080' 'https://newdomain.com' --all-tables --report-changed-only

# Replace wp.local
wp search-replace 'https://wp.local' 'https://newdomain.com' --all-tables --report-changed-only
```

**Time:** 2-3 minutes

---

### Step 5: Update WordPress Site URLs

**Force update WordPress home and siteurl:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html && wp option update siteurl 'https://newdomain.com' && wp option update home 'https://newdomain.com'"
```

**Update site name and tagline:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html && wp option update blogname 'New Site Name' && wp option update blogdescription 'New Tagline'"
```

**Time:** 1 minute

---

### Step 6: Fix Front Page Settings (if corrupted)

**Problem:** Front page shows blog after import instead of static Welcome page

**Solution - Delete and recreate options:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html && wp option delete show_on_front && wp option add show_on_front 'page' --autoload=yes && wp option delete page_on_front && wp option add page_on_front 6 --autoload=yes"
```

**Verify:**
```bash
wp option get show_on_front   # Should return: page
wp option get page_on_front   # Should return: 6 (or your Welcome page ID)
wp post get 6 --field=post_title  # Verify page exists
```

**Time:** 1 minute

---

### Step 7: Disable Persistent Object Cache

**Temporarily disable during migration:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html/wp-content && mv object-cache.php object-cache.php.disabled"
```

**Why?** Object cache can serve stale options during migration.

**Time:** 30 seconds

---

### Step 8: Remove LiteSpeed Cache Rules from .htaccess

**Clean up old cache rules:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html && cp .htaccess .htaccess.backup && sed -i '/#.*BEGIN LSCACHE/,/#.*END LSCACHE/d' .htaccess && sed -i '/#.*BEGIN NON_LSCACHE/,/#.*END NON_LSCACHE/d' .htaccess"
```

**Time:** 30 seconds

---

### Step 9: Delete Default Content

**Remove default "Hello World" post:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html && wp post delete 1 --force"
```

**Time:** 30 seconds

---

### Step 10: Clear All WordPress Caches

**Flush WordPress cache and permalinks:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/NEWDOMAIN.com/public_html && wp cache flush && wp rewrite flush"
```

**Time:** 30 seconds

---

### Step 11: Cleanup Temporary Files

**Remove backup files from server:**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "rm -rf /tmp/*.tar.gz /tmp/*.sql /tmp/domains"
```

**Time:** 30 seconds

---

### Step 12: Verify Server-Side Content

**Test directly from server (bypasses CDN):**
```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "curl -sL https://newdomain.com/ | grep -i 'welcome' | head -3"
```

**Expected:** Should see Welcome page content

**Time:** 1 minute

---

### Step 13: Test CDN Cache Status (PowerShell)

**Check if CDN is serving cached content:**
```powershell
$response = Invoke-WebRequest -Uri "https://newdomain.com/" -UseBasicParsing
Write-Host "CDN Status: $($response.Headers['x-hcdn-cache-status'])"
Write-Host "Server: $($response.Headers['Server'])"
Write-Host "Cache-Control: $($response.Headers['Cache-Control'])"

# Check content
if ($response.Content -match "Welcome") { 
    Write-Host "✅ Correct content" 
} else { 
    Write-Host "❌ CDN serving cached content - PURGE REQUIRED" 
}
```

**CDN Cache Indicators:**
```
x-hcdn-cache-status: HIT          ← Serving from CDN cache
Server: hcdn                      ← Hostinger CDN active
Cache-Control: public, max-age=604800  ← Cached for 7 days
```

**If browser shows old content but server shows correct:** CDN cache issue → **Proceed to Step 14**

**Time:** 2 minutes

---

### Step 14: 🚨 PURGE CDN CACHE (CRITICAL - Manual)

**⚠️ MOST IMPORTANT STEP** - Without this, migration appears to fail even though server is correct.

**Manual CDN Purge via Hostinger hPanel:**

1. **Log in:** https://hpanel.hostinger.com/
2. **Navigate:** Websites → **newdomain.com** → **Manage**
3. **Go to:** **Performance** section
4. **Find:** **CDN** settings or **Cache Manager**
5. **Click:** **"Flush Cache"** or **"Purge CDN Cache"** button
6. **Confirm:** Wait for success message
7. **Wait:** 1-2 minutes for purge to propagate across edge servers

**Why this is necessary:**
- Hostinger CDN caches pages for **7 days** (604800 seconds)
- Standard WordPress cache clearing does NOT affect CDN
- CDN edge servers serve old domain content until manually purged
- Different users may hit different edge servers (inconsistent experience)

**Time:** 2-3 minutes

---

### Step 15: Final Browser Verification

**Test from actual browser:**

1. **Open incognito/private mode** (avoids browser cache)
2. **Visit:** https://newdomain.com/
3. **Hard refresh:** Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
4. **Verify:**
   - ✅ Welcome page loads (not blog)
   - ✅ All links use new domain
   - ✅ Images load correctly
   - ✅ No console errors
   - ✅ Page title correct

**Check response headers (browser DevTools → Network tab → Response Headers):**
```
x-hcdn-cache-status: MISS    ← First visit after purge
x-hcdn-cache-status: HIT     ← Subsequent visits (with correct content)
```

**Time:** 3-5 minutes

---

## Expected Results

✅ **Homepage:** Shows Welcome page (not blog)  
✅ **Pages:** All 19 pages accessible with new domain URLs  
✅ **Users:** All 6 users migrated (login works)  
✅ **Images:** Load correctly from new domain  
✅ **Links:** Internal links use new domain  
✅ **Database:** 119-126 URL replacements confirmed  
✅ **CDN:** Serving fresh content after purge

---

## Troubleshooting

### Issue 1: Browser Still Shows Old Content After CDN Purge

**Symptoms:** Step 14 completed but browser still shows Hello World or old domain

**Causes:**
- Browser DNS cache
- ISP DNS cache
- Browser-specific cache (even in incognito)

**Solutions:**
1. **Flush DNS cache:**
   - Windows: `ipconfig /flushdns`
   - Mac: `sudo dscacheutil -flushcache`
2. **Test from mobile device** (cellular network, not WiFi)
3. **Wait 10-15 minutes** for DNS propagation
4. **Try different browser** (Edge, Chrome, Firefox)
5. **Check exact URL** - test https://newdomain.com/ (no www, with https)

---

### Issue 2: Images Broken / 404 Errors

**Symptoms:** Homepage loads but images show broken or 404

**Cause:** URL search-replace didn't catch all image references

**Solution:**
```bash
# Additional search-replace for assets
wp search-replace 'olddomain.com/wp-content/uploads' 'newdomain.com/wp-content/uploads' --all-tables --report-changed-only

# Check for hardcoded paths
wp search-replace '/home/u909075950/domains/olddomain.com' '/home/u909075950/domains/newdomain.com' --all-tables --report-changed-only
```

---

### Issue 3: Front Page Shows Blog Instead of Welcome

**Symptoms:** Homepage shows blog posts instead of static Welcome page

**Cause:** Database option corruption during import

**Solution:**
```bash
# Delete and recreate front page options
wp option delete show_on_front
wp option add show_on_front 'page' --autoload=yes
wp option delete page_on_front
wp option add page_on_front 6 --autoload=yes

# Clear cache
wp cache flush
wp rewrite flush
```

**Verify:**
```bash
wp option get show_on_front   # Must return: page
wp option get page_on_front   # Must return: 6 (or your page ID)
```

---

### Issue 4: Server Shows Correct, Browser Shows Old

**Symptoms:**
- Server-side curl test shows Welcome page ✅
- Browser shows Hello World ❌

**Cause:** **CDN cache** - most common migration issue

**Diagnosis:**
```powershell
$response = Invoke-WebRequest -Uri "https://newdomain.com/" -UseBasicParsing
$response.Headers['x-hcdn-cache-status']  # Shows: HIT
$response.Headers['Server']               # Shows: hcdn
```

**Solution:** **Return to Step 14** - Purge CDN cache via hPanel

**Confirmation:** After purge, `x-hcdn-cache-status` will show `MISS` first visit, then `HIT` with correct content

---

## Post-Migration Checklist

After successful migration:

- [ ] Test all major pages (Home, Register, Login, Profile, About)
- [ ] Test form submissions (registration, contact)
- [ ] Verify email sending works
- [ ] Check SSL certificate (should be auto-provisioned by Hostinger)
- [ ] Update external services (analytics, DNS, email providers)
- [ ] Monitor error logs for 24 hours
- [ ] Set up 301 redirects from old domain (if needed)
- [ ] Update social media links
- [ ] Notify users of domain change (if applicable)
- [ ] Re-enable object cache (if it was working well before):
  ```bash
  mv wp-content/object-cache.php.disabled wp-content/object-cache.php
  ```

---

## Time Breakdown

| Step | Duration | Critical |
|------|----------|----------|
| 1. Upload files | 2-5 min | ✅ |
| 2. Extract & sync | 3-5 min | ✅ |
| 3. Import database | 1-2 min | ✅ |
| 4. URL search-replace | 2-3 min | 🚨 CRITICAL |
| 5. Update site URLs | 1 min | ✅ |
| 6. Fix front page | 1 min | If needed |
| 7. Disable object cache | 30 sec | ✅ |
| 8. Remove cache rules | 30 sec | ✅ |
| 9. Delete default content | 30 sec | Optional |
| 10. Clear caches | 30 sec | ✅ |
| 11. Cleanup | 30 sec | ✅ |
| 12. Server verification | 1 min | ✅ |
| 13. Test CDN | 2 min | ✅ |
| 14. **Purge CDN cache** | **2-3 min** | **🚨 CRITICAL** |
| 15. Browser test | 3-5 min | ✅ |
| **Total** | **30-45 min** | |

**Note:** Budget 45 minutes total. If you skip Step 14, add 1-2 hours troubleshooting.

---

## Related Documentation

- **Lesson Learned:** [hostinger-cdn-cache-migration.md](../lessons/hostinger-cdn-cache-migration.md) - Troubleshooting journey and root cause analysis
- **Commands:** [COMMAND-REGISTRY.md](../../.github/COMMAND-REGISTRY.md) - Individual command building blocks
- **Tasks:** [TASK-REGISTRY.md](../../.github/TASK-REGISTRY.md) - Quick task overview

---

## Success Criteria

Migration is successful when:

1. ✅ Homepage displays Welcome page (not blog)
2. ✅ All internal links use new domain
3. ✅ Images and assets load correctly
4. ✅ User login works
5. ✅ Forms submit successfully
6. ✅ CDN serves correct content (x-hcdn-cache-status: HIT with correct page)
7. ✅ No console errors in browser
8. ✅ SSL certificate valid (Hostinger auto-provisions)

**Most Common Mistake:** Skipping Step 14 (CDN cache purge). Always purge CDN via hPanel after domain migrations on Hostinger.
