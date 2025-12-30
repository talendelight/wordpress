# LiteSpeed Cache Configuration Guide

**Last Updated:** December 27, 2025

## Configuration Storage

LiteSpeed Cache stores its configuration in the **WordPress database** (`wp_options` table), NOT in files.

**Key Point:** Since database content is NOT synced between local and production (per [SYNC-STRATEGY.md](SYNC-STRATEGY.md)), **local configuration will NOT affect production**. Each environment can have independent settings.

```sql
-- Configuration stored as:
litespeed.conf.cache
litespeed.conf.cache-browser
litespeed.conf.cache-mobile
litespeed.conf.optimize
... and many more
```

---

## Development Environment Settings

**Goal:** Optimize for development workflow - disable aggressive caching, enable debugging

### Recommended Configuration

Access: http://localhost:8080/wp-admin/admin.php?page=litespeed

#### 1. Cache Settings (Dashboard → Cache)

**Disable or minimize caching during active development:**

- **Enable Cache**: OFF (or ON with low TTL if testing cache behavior)
- **Cache Logged-in Users**: OFF (always see fresh content)
- **Cache REST API**: OFF
- **Cache Mobile**: OFF (unless testing mobile specifically)

**If keeping cache ON for testing:**
- **Default Public Cache TTL**: 60 seconds (very low)
- **Default Private Cache TTL**: 30 seconds
- **Default Front Page TTL**: 60 seconds

#### 2. Purge Settings (Dashboard → Purge)

**Auto-purge on updates:**
- **Purge All On Upgrade**: ON
- **Auto Purge Rules for Publish/Update**: Enable all (ensures fresh content after changes)

#### 3. CDN Settings

**CDN**: OFF (not needed for local development)

#### 4. Image Optimization

**Image Optimization**: OFF (or ON if testing optimization features)
- Local development doesn't need optimized images
- Keeps original files intact

#### 5. Page Optimization

**CSS/JS Optimization**: OFF (easier debugging with unminified code)
- **CSS Minify**: OFF
- **CSS Combine**: OFF
- **JS Minify**: OFF
- **JS Combine**: OFF
- **Load CSS Asynchronously**: OFF
- **Load JS Deferred**: OFF

**If testing optimization:**
- Enable individually to isolate issues
- Use browser DevTools to debug

#### 6. Database Optimization

**Database**: OFF (local database is ephemeral, optimization not needed)

#### 7. Crawler

**Crawler**: OFF (no need to warm cache in development)

#### 8. Debug Settings (Dashboard → Toolbox → Debug)

**Enable Debug**: ON
- **Admin IPs**: Add `127.0.0.1` (your local IP)
- **Debug Level**: Basic or Advanced
- Shows cache status in HTML comments (`<!-- LiteSpeed Cache -->`)

**Debug Log**: ON (optional, for troubleshooting)
- Logs to: `wp-content/debug.log`

---

## Production Environment Settings

**Goal:** Maximize performance, enable aggressive caching, disable debug

### Recommended Configuration

Access: https://your-domain.com/wp-admin/admin.php?page=litespeed

#### 1. Cache Settings

**Enable aggressive caching:**

- **Enable Cache**: ON
- **Cache Logged-in Users**: OFF (security)
- **Cache REST API**: ON (if using headless/API)
- **Cache Mobile**: ON (separate mobile cache)

**Cache TTL (Time To Live):**
- **Default Public Cache TTL**: 604800 (7 days)
- **Default Private Cache TTL**: 1800 (30 minutes)
- **Default Front Page TTL**: 604800 (7 days)

#### 2. Purge Settings

**Auto-purge on updates:**
- **Purge All On Upgrade**: ON
- **Auto Purge Rules for Publish/Update**: Enable all

#### 3. CDN Settings

**CDN**: Configure if using CDN (Cloudflare, etc.)
- Set CDN URL
- Enable CDN mapping

#### 4. Image Optimization

**Image Optimization**: ON
- **Auto Request Cron**: ON
- **Optimize Original Images**: ON (or keep originals for safety)

#### 5. Page Optimization

**CSS/JS Optimization**: ON (enable carefully, test thoroughly)
- **CSS Minify**: ON
- **CSS Combine**: ON (test for conflicts)
- **JS Minify**: ON
- **JS Combine**: OFF initially (often causes issues, enable cautiously)
- **Load CSS Asynchronously**: ON (test with theme)
- **Load JS Deferred**: ON (test with theme/plugins)

**Testing approach:**
- Enable one at a time
- Test all pages/functionality
- Disable if issues occur

#### 6. Database Optimization

**Database**: ON (schedule weekly cleanup)
- **Auto Clean**: ON
- **Schedule**: Weekly

#### 7. Crawler

**Crawler**: ON (warms cache after purge)
- **Delay**: 500ms (balance between speed and server load)
- **Run Duration**: 400 seconds
- **Interval Between Runs**: 600 seconds

#### 8. Debug Settings

**Enable Debug**: OFF (disable in production)
- **Debug Level**: OFF
- **Debug Log**: OFF

---

## Configuration Workflow

### Initial Setup (Both Environments)

1. **Install & Activate Plugin**
   - Local: Already done ✓
   - Production: After Git push, activate via WordPress Admin

2. **Configure for Environment**
   - Local: Development settings (above)
   - Production: Production settings (above)

3. **Test Configuration**
   - Local: Verify development workflow not impacted
   - Production: Test cache behavior, page speed

### After Configuration

**Local:**
```bash
# Configuration saved to database
podman exec wp-db mariadb -u root -ppassword -D wordpress \
  -e "SELECT option_name, option_value FROM wp_options WHERE option_name LIKE 'litespeed.conf%' LIMIT 5;"
```

**Production:**
- Configuration stays in Hostinger's MySQL database
- NOT affected by local settings
- Manage via WordPress Admin only

---

## Important Notes

### ✅ Safe: Configuration Won't Sync

- **Database storage**: LiteSpeed config in `wp_options` table
- **Sync rule**: Database content NEVER syncs (per [SYNC-STRATEGY.md](SYNC-STRATEGY.md))
- **Result**: Local dev settings ≠ Production production settings
- **Management**: Configure each environment independently via WordPress Admin

### ⚠️ Files Created by LiteSpeed

**These files ARE synced via Git:**
- `wp-content/litespeed/` - Cache files (should add to `.gitignore`)
- `.htaccess` - May add LiteSpeed rules (review before committing)

**Recommendation:**
```bash
# Add to .gitignore
echo "wp-content/litespeed/" >> .gitignore
echo "wp-content/.litespeed_conf.dat" >> .gitignore
echo "wp-content/object-cache.php" >> .gitignore
```

### 🔍 Verifying Configuration

**Local:**
```bash
# Check cache status
curl -I http://localhost:8080 | grep -i "x-litespeed"

# Check configuration count
podman exec wp-db mariadb -u root -ppassword -D wordpress \
  -e "SELECT COUNT(*) FROM wp_options WHERE option_name LIKE 'litespeed.%';"
```

**Production:**
```bash
# Check cache status
curl -I https://your-domain.com | grep -i "x-litespeed"
```

---

## Quick Reference

| Setting | Development | Production |
|---------|-------------|------------|
| **Cache Enabled** | OFF or low TTL | ON with high TTL |
| **CSS/JS Minify** | OFF | ON |
| **Image Optimization** | OFF | ON |
| **Debug Mode** | ON | OFF |
| **Crawler** | OFF | ON |
| **Database Optimization** | OFF | ON |
| **Cache Logged-in Users** | OFF | OFF |

---

## Troubleshooting

### Issue: Seeing Stale Content in Development

**Solution:**
1. Disable cache: Dashboard → Cache → Enable Cache → OFF
2. Or purge all: Dashboard → Purge → Purge All
3. Or add query string to URL: `?nocache=1`

### Issue: CSS/JS Broken After Optimization

**Solution:**
1. Disable optimization: Dashboard → Page Optimization → Turn OFF problematic setting
2. Test one setting at a time to identify conflict
3. Check browser console for errors

### Issue: Can't Access LiteSpeed Settings

**Solution:**
1. Ensure plugin is activated
2. Check user has Administrator role
3. Access directly: `/wp-admin/admin.php?page=litespeed`

---

## Next Steps

After configuring LiteSpeed:

1. **Test local development workflow**
   - Make changes to themes/plugins
   - Verify you see updates immediately
   - Check debug output in HTML source

2. **Prepare for production deployment**
   - Review [SYNC-STRATEGY.md](SYNC-STRATEGY.md)
   - Add LiteSpeed cache files to `.gitignore`
   - Document production configuration plan

3. **Deploy to production**
   - Git push plugins to production
   - Activate LiteSpeed Cache on Hostinger
   - Configure production settings (separately from local)

4. **Verify production cache**
   - Test cache headers: `curl -I https://your-domain.com`
   - Check page load speed
   - Test cache purge on content updates

---

## Related Documentation

- [docs/SYNC-STRATEGY.md](SYNC-STRATEGY.md) - Local/production sync rules
- [WORDPRESS-DEPLOYMENT.md](../../Documents/WORDPRESS-DEPLOYMENT.md) - Hostinger Git deployment
- [WORDPRESS-OPEN-ACTIONS.md](../../Documents/WORDPRESS-OPEN-ACTIONS.md) - Current action items
- [Official LiteSpeed Cache Wiki](https://docs.litespeedtech.com/lscache/lscwp/overview/) - Complete documentation
