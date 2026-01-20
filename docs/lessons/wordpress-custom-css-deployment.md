# Lesson: Deploying Custom CSS to Production

**Date:** January 20, 2026  
**Context:** Deploying CSS from `config/custom-css/` to WordPress Additional CSS (theme mods) on production  
**Outcome:** Successful deployment using PHP script via wp eval-file

---

## The Challenge

**Problem:** Custom CSS applied manually via WordPress Admin → Appearance → Customize → Additional CSS needs to be version-controlled and deployed programmatically.

**Requirements:**
1. Store CSS in version control (`config/custom-css/`)
2. Deploy to production without manual copy-paste
3. Apply to WordPress Additional CSS (stored in theme_mods)
4. Handle large CSS files (8KB+)

---

## Solution: PHP Script with wp eval-file

### Why Not wp-cli theme mod set?

**Failed Approach:**
```bash
wp theme mod set custom_css "$(cat ~/custom.css)"
```

**Problem:** Command substitution breaks with:
- Large files (8KB+)
- Special characters in CSS (braces, quotes)
- Shell parsing issues with multi-line content

### Working Solution: PHP Script

**Script:** `infra/shared/scripts/deploy-custom-css.php`

```php
<?php
$css_file = getenv('HOME') . '/custom.css';
$css_content = file_get_contents($css_file);

$theme_slug = get_option('stylesheet');
$mods = get_theme_mods();
$mods['custom_css'] = $css_content;
update_option("theme_mods_$theme_slug", $mods);

echo "✓ Custom CSS deployed successfully\n";
```

**Why it works:**
- PHP handles large files and special characters properly
- Direct WordPress API calls (get_theme_mods, update_option)
- No shell escaping issues
- Preserves CSS formatting exactly

---

## Deployment Workflow

### Step 1: Combine CSS Files

```powershell
$buttonCss = Get-Content config/custom-css/td-button.css -Raw
$pageCss = Get-Content config/custom-css/td-page.css -Raw
$combinedCss = $buttonCss + "`n`n" + $pageCss
Set-Content -Path tmp/combined-custom.css -Value $combinedCss
```

### Step 2: Upload Files

```bash
scp -i tmp/hostinger_deploy_key -P 65002 tmp/combined-custom.css u909075950@45.84.205.129:~/custom.css
scp -i tmp/hostinger_deploy_key -P 65002 infra/shared/scripts/deploy-custom-css.php u909075950@45.84.205.129:~/deploy-custom-css.php
```

### Step 3: Deploy via wp eval-file

```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp eval-file ~/deploy-custom-css.php"
```

**Output:**
```
✓ Custom CSS deployed successfully
Theme: blocksy-child
CSS length: 8606 bytes
```

---

## Key Learnings

### ✅ Use wp eval-file for Complex Data

**When to use:**
- Large data files (>1KB)
- Multi-line content
- Content with special characters
- Direct WordPress API operations needed

**Advantages:**
- No shell escaping required
- Handles any file size
- Full WordPress API access
- Clean error handling

### ✅ Theme Mods Storage

**How WordPress stores Additional CSS:**
```php
// Option name format
$option_name = "theme_mods_{$theme_slug}";

// Option value structure
$mods = [
    'custom_css' => '/* CSS content */',
    // ... other theme mods
];
```

### ❌ Avoid Command Substitution for Large Files

**Don't do this:**
```bash
wp theme mod set custom_css "$(cat large-file.css)"
```

**Problems:**
- ARG_MAX limits (typically 128KB but shells fail much earlier)
- Shell parsing breaks on special characters
- Poor error messages
- Unreliable with multi-line content

---

## Alternative Approaches (Not Used)

### 1. wp-cli stdin (Not Available)
```bash
# This doesn't exist
wp theme mod set custom_css < file.css
```
WP-CLI doesn't support stdin for theme mod values.

### 2. REST API (Overcomplicated)
```bash
curl -X POST https://site.com/wp-json/wp/v2/custom-css
```
Requires authentication, CORS headers, and custom endpoint creation.

### 3. Direct Database Update (Risky)
```sql
UPDATE wp_options 
SET option_value = '...' 
WHERE option_name = 'theme_mods_blocksy-child';
```
Requires manual serialization and risks corrupting option data.

---

## Files Modified

1. **infra/shared/scripts/deploy-custom-css.php** - Deployment script (created)
2. **config/custom-css/td-button.css** - Button styles (existing)
3. **config/custom-css/td-page.css** - Page styles (existing)
4. **tmp/combined-custom.css** - Combined CSS for deployment (temporary)

---

## Future Improvements

1. **Automate in GitHub Actions**
   - Add CSS deployment step to `.github/workflows/deploy.yml`
   - Run after code deployment completes

2. **Version Control Theme Mods Export**
   - Export current production theme mods
   - Store as JSON baseline in `infra/shared/theme-mods/`
   - Track changes over time

3. **CSS Minification**
   - Minify CSS before deployment to reduce size
   - Use PostCSS or cssnano in build pipeline

4. **Rollback Support**
   - Export current CSS before deployment
   - Store as backup: `tmp/css-backup-YYYYMMDD-HHmm.css`
   - Quick rollback command if needed

---

## Related Documentation

- [WordPress Customizer CSS vs Files](wordpress-customizer-css-vs-files.md) - When to use Additional CSS vs theme files
- [DEPLOYMENT-WORKFLOW.md](../DEPLOYMENT-WORKFLOW.md) - Overall deployment process
- [QUICK-REFERENCE-DEPLOYMENT.md](../QUICK-REFERENCE-DEPLOYMENT.md) - Command cheat sheet
