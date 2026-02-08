# Assets Backup and Restore Guide

**Created:** February 8, 2026  
**Version:** v3.5.1+  
**Purpose:** Backup of all theme assets (images, logos, icons)

## Asset Inventory

### Theme Assets (blocksy-child)

#### Images
- **eu-logo.svg** (1.1 KB)
  - Location: `wp-content/themes/blocksy-child/assets/images/eu-logo.svg`
  - Used in: Welcome page footer (trust badges section)
  - Display size: 20px height
  - Backup: `restore/assets/images/eu-logo.svg`

## Font Awesome Icons

**Source:** Better Font Awesome plugin v2.0.4 (locally hosted)
- No backup needed - plugin provides all icons
- Icons used on Welcome page:
  - `fa-cloud` - Cloud Backend specialty
  - `fa-globe` - Fullstack specialty
  - `fa-server` - DevOps specialty
  - `fa-question` - Custom request card

## Restore Instructions

### Restore EU Logo

**Via File System:**
```bash
# Copy from backup to theme
cp restore/assets/images/eu-logo.svg wp-content/themes/blocksy-child/assets/images/
```

**Via Git:**
```bash
# EU logo is tracked in Git, so just checkout from branch
git checkout develop -- wp-content/themes/blocksy-child/assets/images/eu-logo.svg
```

**Via Container:**
```powershell
# Copy to container
podman cp restore/assets/images/eu-logo.svg wp:/var/www/html/wp-content/themes/blocksy-child/assets/images/
```

### Production Deployment

**EU Logo is included in Git deployment:**
1. Push to main branch → Hostinger auto-deploys
2. Asset automatically deployed to production
3. No manual upload needed

**Manual upload if needed:**
```bash
scp -i tmp/hostinger_deploy_key -P 65002 \
  restore/assets/images/eu-logo.svg \
  u909075950@45.84.205.129:~/public_html/wp-content/themes/blocksy-child/assets/images/
```

## Asset Management Best Practices

### When Adding New Assets

1. **Add to theme assets folder:**
   ```
   wp-content/themes/blocksy-child/assets/images/[asset-name]
   ```

2. **Backup immediately:**
   ```powershell
   Copy-Item "wp-content/themes/blocksy-child/assets/images/[asset-name]" "restore/assets/images/"
   ```

3. **Commit to Git:**
   ```bash
   git add wp-content/themes/blocksy-child/assets/images/[asset-name]
   git add restore/assets/images/[asset-name]
   git commit -m "Add [asset-name] to theme assets"
   ```

4. **Update this document** with asset details

### Asset Optimization

**SVG files (preferred):**
- Scalable, no resolution issues
- Small file size
- Keep source file in backup

**PNG files (fallback):**
- Use 2x size for retina displays
- Compress with TinyPNG or similar
- Keep uncompressed source in backup

**WebP (future consideration):**
- Better compression than PNG
- Not all browsers support (need fallback)
- Consider for large images only

## Dependencies

### Better Font Awesome Plugin
- Version: 2.0.4
- Source: Tracked in Git at `wp-content/plugins/better-font-awesome/`
- Icons: 6.5.1 (locally hosted, not CDN)
- No separate backup needed - entire plugin in Git

### Theme Requirements
- Blocksy parent theme (manages some assets)
- Blocksy child theme (custom assets here)
- Assets referenced via `get_stylesheet_directory_uri()`

## File Structure

```
restore/
├── assets/
│   └── images/
│       └── eu-logo.svg (1.1 KB)
└── ASSETS-RESTORE.md (this file)

wp-content/themes/blocksy-child/
├── assets/
│   └── images/
│       └── eu-logo.svg (1.1 KB)
├── patterns/ (10 pattern files)
├── functions.php
├── style.css
└── wpum-overrides.css
```

## Verification

**Check if asset exists locally:**
```powershell
Test-Path "wp-content/themes/blocksy-child/assets/images/eu-logo.svg"
```

**Check if asset exists in container:**
```bash
podman exec wp ls -lh /var/www/html/wp-content/themes/blocksy-child/assets/images/eu-logo.svg
```

**Check if asset exists on production:**
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 \
  "ls -lh ~/public_html/wp-content/themes/blocksy-child/assets/images/eu-logo.svg"
```

## Troubleshooting

### Asset Not Displaying

1. **Check file path:**
   - Correct: `/wp-content/themes/blocksy-child/assets/images/eu-logo.svg`
   - Wrong: `/assets/images/eu-logo.svg` (missing theme path)

2. **Check permissions:**
   ```bash
   chmod 644 wp-content/themes/blocksy-child/assets/images/eu-logo.svg
   ```

3. **Clear cache:**
   ```bash
   wp cache flush --allow-root
   ```

4. **Verify in page source:**
   - View page source in browser
   - Search for `eu-logo.svg`
   - Check if path resolves correctly

### Asset Not Deploying to Production

1. **Check if in Git:**
   ```bash
   git ls-files | grep eu-logo.svg
   ```

2. **Check .hostingerignore:**
   - Ensure `wp-content/themes/blocksy-child/assets/` NOT ignored

3. **Manual upload as fallback** (see commands above)

## Version History

### v3.5.1+ (February 8, 2026)
- Added EU Commission logo to footer
- Created assets backup structure
- Documented restore procedures

---

*Last Updated: February 8, 2026*  
*Part of Welcome Page Pattern Library Implementation*
