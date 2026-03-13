# Local SSL Setup with Caddy

## Overview

This guide documents the complete process of setting up HTTPS for local WordPress development using Caddy 2 as a reverse proxy with custom SSL certificates.

**Final Configuration:**
- Domain: `https://wp.local/`
- Reverse Proxy: Caddy 2
- Backend: WordPress container (Apache on port 80)
- Network: Podman `dev_default` bridge network

## Prerequisites

- Podman/Docker with compose
- Self-signed SSL certificates for `wp.local`
- Windows hosts file access (Administrator)

## Setup Steps

### 1. Generate SSL Certificates

Place certificates in `infra/dev/certs/`:
- `wp.local.pem` (certificate)
- `wp.local-key.pem` (private key)

### 2. Configure Hosts File

Add to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 wp.local
```

### 3. Create Caddyfile

Create `infra/dev/Caddyfile`:
```caddy
wp.local {
  reverse_proxy wp:80 {
    header_up X-Real-IP {remote_host}
    header_up X-Forwarded-For {remote_host}
    header_up X-Forwarded-Proto {scheme}
    header_up Host {host}
  }
  tls /etc/caddy/certs/wp.local.pem /etc/caddy/certs/wp.local-key.pem
}
```

**Critical Details:**
- Use correct container name `wp:80` (not `wordpress:80`)
- Include reverse proxy headers for WordPress to detect HTTPS
- TLS paths must match container mount point

### 4. Add Caddy Service to compose.yml

```yaml
services:
  # ... existing services ...
  
  caddy:
    image: caddy:2
    container_name: caddy
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./certs:/etc/caddy/certs:ro
    networks:
      - default
```

**Critical Details:**
- Set `container_name: caddy` for consistent naming
- Mount certificates as read-only (`:ro`)
- Use `restart: always` for auto-start
- Expose both ports 80 and 443

### 5. Update WordPress Site URLs

After starting containers, update WordPress to use `https://wp.local`:

```bash
podman exec -it wp wp option update home 'https://wp.local' --allow-root
podman exec -it wp wp option update siteurl 'https://wp.local' --allow-root
```

**Why This Matters:**
WordPress stores site URLs in database (`wp_options` table). If these don't match your access URL, stylesheets/scripts will load from wrong domain causing broken layouts.

### 6. Start Services

```bash
cd infra/dev
podman-compose up -d
```

## Troubleshooting: 502 Bad Gateway

### Symptom
- Browser shows "502 Bad Gateway" error
- HTTPS connection works (SSL handshake successful)
- Port 443 is accessible

### Root Cause
Caddyfile referenced wrong container hostname (`wordpress:80` instead of `wp:80`).

### Debugging Process

**1. Verify SSL/TLS is working:**
```bash
curl.exe -k -v https://wp.local/
```
- ✅ SSL handshake succeeds
- ❌ Returns HTTP/1.1 502 Bad Gateway
- **Conclusion:** Caddy is working, backend is unreachable

**2. Verify port accessibility:**
```powershell
Test-NetConnection localhost -Port 443
```
- ✅ TcpTestSucceeded: True
- **Conclusion:** Port 443 is accessible

**3. Verify containers on same network:**
```bash
podman inspect wp --format '{{.NetworkSettings.Networks}}'
podman inspect caddy --format '{{.NetworkSettings.Networks}}'
```
- ✅ Both on `dev_default` network
- **Conclusion:** Network isolation not the issue

**4. Check Caddy logs:**
```bash
podman logs caddy --tail 30
```
- ✅ No errors, certificate loaded, HTTP/3 enabled
- **Conclusion:** Caddy configuration valid, issue is backend connectivity

**5. Test DNS resolution from Caddy container:**
```bash
# Test configured hostname
podman exec caddy nslookup wordpress
# Result: NXDOMAIN - hostname doesn't exist ❌

# Test actual container name
podman exec caddy nslookup wp
# Result: 10.89.0.4 (wp.dns.podman) ✅
```
- **Root cause identified:** Caddyfile uses non-existent hostname

**6. Verify connectivity with correct hostname:**
```bash
podman exec caddy wget -qO- http://wp:80
# Result: Returns "<!doctype html>" HTML ✅
```
- **Confirmation:** Backend is reachable with correct hostname

### Solution
Change Caddyfile line 2 from `reverse_proxy wordpress:80` to `reverse_proxy wp:80`, then restart:
```bash
podman restart caddy
```

## Troubleshooting: Styles Not Loading

### Symptom
- Site loads but appears broken/unstyled
- Browser console shows mixed content warnings or 404s
- Layout completely broken

### Root Cause
WordPress generating wrong URLs (`https://localhost:8080/` instead of `https://wp.local/`).

### Debugging Process

**1. Check generated URLs in HTML:**
```bash
curl.exe -k https://wp.local/ 2>&1 | Select-String "href=|src="
```
- Shows: `href="https://localhost:8080/wp-content/themes/..."`
- **Conclusion:** WordPress doesn't know it's being accessed via `wp.local`

**2. Check WordPress site URLs:**
```bash
podman exec -it wp wp option get home --allow-root
podman exec -it wp wp option get siteurl --allow-root
```
- Shows: `https://localhost:8080`
- **Root cause identified:** Database has wrong URLs

### Solution

**Option A: Update via WP-CLI (Recommended):**
```bash
podman exec -it wp wp option update home 'https://wp.local' --allow-root
podman exec -it wp wp option update siteurl 'https://wp.local' --allow-root
```

**Option B: Update via Database:**
```sql
UPDATE wp_options SET option_value='https://wp.local' WHERE option_name='home';
UPDATE wp_options SET option_value='https://wp.local' WHERE option_name='siteurl';
```

**Option C: Update via WordPress Admin:**
1. Navigate to Settings → General
2. Update "WordPress Address (URL)" and "Site Address (URL)"
3. Save changes

## Lessons Learned

### 1. Container Name Consistency Matters
**Lesson:** Podman/Docker container names become DNS hostnames within the network. Configuration files must reference **actual** container names.

**Best Practice:**
- Always use `container_name` in compose.yml for predictability
- Verify container names: `podman ps --format "{{.Names}}"`
- Test DNS resolution from within containers when debugging

### 2. 502 Bad Gateway = Backend Unreachable
**Lesson:** 502 specifically means reverse proxy cannot reach backend. This narrows debugging scope significantly.

**Not 502 Issues:**
- SSL/TLS problems (those cause connection errors)
- Port accessibility (causes connection refused)
- Frontend configuration (causes 4xx errors)

**502 Debugging Checklist:**
1. ✅ Is backend container running?
2. ✅ Are containers on same network?
3. ✅ Can proxy resolve backend hostname? (`nslookup`)
4. ✅ Can proxy reach backend directly? (`wget`/`curl`)

### 3. WordPress Needs Explicit URL Configuration
**Lesson:** WordPress is not automatically aware of reverse proxy domains. It generates URLs based on database values, not request headers.

**Why Headers Alone Aren't Enough:**
- `X-Forwarded-Proto` tells WordPress the request used HTTPS
- But WordPress still generates URLs using `home` and `siteurl` options
- These must match your access domain

**Best Practice:**
- Always update WordPress URLs after changing access domain
- Use WP-CLI for scriptable updates
- Include in setup documentation/automation

### 4. Reverse Proxy Headers Are Required
**Lesson:** WordPress needs specific headers to detect it's behind HTTPS proxy.

**Required Headers:**
```caddy
header_up X-Real-IP {remote_host}
header_up X-Forwarded-For {remote_host}
header_up X-Forwarded-Proto {scheme}
header_up Host {host}
```

**What Each Does:**
- `X-Real-IP` / `X-Forwarded-For`: Client's real IP address
- `X-Forwarded-Proto`: Original protocol (http/https)
- `Host`: Original hostname from request

**WordPress Response:**
wp-config.php contains logic to set `$_SERVER['HTTPS'] = 'on'` when detecting these headers, preventing redirect loops and mixed content.

### 5. Systematic Debugging Saves Time
**Lesson:** Methodically eliminating possibilities is faster than random changes.

**Effective Debug Strategy:**
1. **Isolate the layer** - Frontend? Network? Backend? Database?
2. **Test from inside out** - Start at backend, work toward frontend
3. **One variable at a time** - Change one thing, test, repeat
4. **Use native tools** - `nslookup`, `wget`, `curl` inside containers shows exactly what containers see

**This Session's Approach:**
```
SSL handshake ✅ → Port access ✅ → Network ✅ → DNS ❌ → Fix → Test ✅
Backend serving ✅ → URLs in HTML ❌ → Database config ❌ → Fix → Test ✅
```

### 6. Documentation After Success
**Lesson:** Document troubleshooting steps **after** confirming fixes work, not during debugging.

**Why:**
- Debugging involves many failed attempts
- Only successful path matters for documentation
- Can consolidate lessons learned retrospectively
- User confirms working state before committing documentation

## Quick Reference

### Start HTTPS Development
```bash
cd infra/dev
podman-compose up -d
# Access at https://wp.local/
```

### Restart Caddy After Config Changes
```bash
podman restart caddy
```

### Check WordPress URLs
```bash
podman exec -it wp wp option get home --allow-root
podman exec -it wp wp option get siteurl --allow-root
```

### Update WordPress URLs
```bash
podman exec -it wp wp option update home 'https://wp.local' --allow-root
podman exec -it wp wp option update siteurl 'https://wp.local' --allow-root
```

### Debug Connectivity From Caddy
```bash
# Test DNS resolution
podman exec caddy nslookup wp

# Test HTTP connectivity
podman exec caddy wget -qO- http://wp:80

# Check Caddy logs
podman logs caddy --tail 30
```

### Common Issues

| Symptom | Likely Cause | Solution |
|---------|-------------|----------|
| Connection refused | Caddy not running | `podman-compose up -d` |
| 502 Bad Gateway | Wrong hostname in Caddyfile | Verify container name, update Caddyfile |
| Certificate error | Wrong cert paths or permissions | Check mount paths, file permissions |
| Styles not loading | Wrong WordPress URLs | Update `home` and `siteurl` options |
| Redirect loop | Missing proxy headers | Add `X-Forwarded-Proto` header |

## Production Considerations

**This setup is for LOCAL DEVELOPMENT ONLY.**

For production (Hostinger):
- ✅ Hostinger provides LiteSpeed with built-in SSL
- ✅ No reverse proxy needed
- ✅ WordPress URLs managed via Hostinger control panel
- ❌ Do NOT deploy Caddy configuration to production
- ❌ Do NOT commit SSL certificates to git

## Related Documentation

- [WORDPRESS-DEPLOYMENT.md](../../Documents/WORDPRESS-DEPLOYMENT.md) - Hostinger Git deployment
- [SYNC-STRATEGY.md](SYNC-STRATEGY.md) - Local/production sync approach
- [compose.yml](../infra/dev/compose.yml) - Complete container configuration

## Changelog

- **2026-01-01**: Initial setup with Caddy 2, documented 502 and styling issues, lessons learned
