# Quick Reference: Deployment Commands

**ðŸ“š See Also:** 
- [ID Management Strategy](ID-MANAGEMENT-STRATEGY.md) - How to handle IDs across environments
- [Deployment Workflow](DEPLOYMENT-WORKFLOW.md) - Complete deployment process
- [Post-Mortem v3.6.0](POST-MORTEM-V3.6.0-DEPLOYMENT-GAPS.md) - Lessons learned

---

## Prerequisites Check
- [ ] Local WordPress container running (`podman ps` shows `wp` container)
- [ ] SSH access to production configured (`ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129`)
- [ ] WP-CLI available on production
- [ ] Changes tested locally at https://wp.local
- [ ] Assets backed up to `restore/assets/` (if new images/logos added)
- [ ] Database migrations tested locally (if applicable)
- [ ] Required plugins available in `wp-content/plugins/`

---

## Deployment Workflow (Standard)

### 1. Pre-Deployment Health Check
```powershell
# Check production baseline before changes
pwsh infra/shared/scripts/wp-action.ps1 health-check
```

### 2. Backup Production (MANDATORY)
```powershell
pwsh infra/shared/scripts/wp-action.ps1 backup
```

### 3. Deploy Code
```bash
# Push to main branch (triggers GitHub Actions auto-deploy)
git push origin main
```

### 4. Deploy Database Migrations (if needed)

**Note:** Check release JSON file (`.github/releases/vX.Y.Z.json`) for the specific migrations required for each release.

**Available migrations** (in `infra/shared/db/`):
- `260117-1400-add-user-data-change-requests.sql` - User requests table (v3.4.0)
- `260118-1200-add-audit-log-table.sql` - Audit log table (v3.4.0)
- `260119-1400-add-role-and-audit-log.sql` - Role column and profile methods (v3.4.0)
- `260120-1945-alter-add-approver-comments.sql` - Approver tracking (v3.4.0)
- `260131-1200-add-record-id-prsn-cmpy.sql` - Request ID and Record ID (v3.6.0)
- `260131-1300-add-id-sequences-table.sql` - ID sequence generator (v3.6.0)
- `260131-1400-add-assigned-by-column.sql` - Assignment tracking (v3.6.0)

**Example for v3.6.0 (7 migrations):**
```bash
# Upload migration files
scp -i tmp/hostinger_deploy_key -P 65002 \
  infra/shared/db/260117-1400-add-user-data-change-requests.sql \
  infra/shared/db/260118-1200-add-audit-log-table.sql \
  infra/shared/db/260119-1400-add-role-and-audit-log.sql \
  infra/shared/db/260120-1945-alter-add-approver-comments.sql \
  infra/shared/db/260131-1200-add-record-id-prsn-cmpy.sql \
  infra/shared/db/260131-1300-add-id-sequences-table.sql \
  infra/shared/db/260131-1400-add-assigned-by-column.sql \
  u909075950@45.84.205.129:~/db-migrations/

# Execute migrations in order
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 \
  "cd domains/talendelight.com/public_html && \
   for f in ~/db-migrations/*.sql; do \
     echo \"Executing \$f...\"; \
     wp db query < \"\$f\" --allow-root; \
   done && \
   rm -rf ~/db-migrations"
```

**Quick single file upload:**
```bash
# Upload one SQL file
scp -i tmp/hostinger_deploy_key -P 65002 \
  infra/shared/db/*.sql \
  u909075950@45.84.205.129:~/db-migrations/
```

### 5. Activate New Plugins (if needed)
```bash
# Check plugin status
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 \
  "cd domains/talendelight.com/public_html && \
   wp plugin list --allow-root"

# Activate plugin
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 \
  "cd domains/talendelight.com/public_html && \
   wp plugin activate PLUGIN_SLUG --allow-root"
```

### 6. Clear Caches
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 \
  "cd domains/talendelight.com/public_html && \
   wp cache flush --allow-root && \
   wp rewrite flush --allow-root"
```

### 7. Post-Deployment Health Check (MANDATORY)
```powershell
# Verify all components after deployment
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
```

### 8. Rollback (if issues detected)
```powershell
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
```

---

## Health Check Commands

### Quick Health Check
```powershell
# Check production health via wp-action dispatcher
pwsh infra/shared/scripts/wp-action.ps1 health-check
```

### Verbose Health Check
```powershell
# Show all checks (passed and failed)
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
```

### Direct SSH Health Check
```bash
# Run health check script directly on production
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 \
  "cd domains/talendelight.com/public_html && \
   wp eval-file ~/verify-production-health.php --verbose --allow-root"
```

**Health Check Verifies:**
- âœ… Required pages exist (employers, candidates, scouts, managers, operators, help, welcome)
- âœ… Required plugins active (talendelight-roles, wp-user-manager, blocksy-companion)
- âœ… Required MU-plugins loaded (td-api-security, td-env-config, record-id-generator)
- âœ… Custom roles exist (td_candidate, td_employer, td_scout, td_operator, td_manager)
- âœ… Navigation menus configured
- âœ… Database tables exist (td_user_data_change_requests, td_audit_log, td_id_sequences)
- âœ… Security settings (XML-RPC disabled, file editing disabled)
- âœ… Environment constants defined

---

## Asset Deployment

**Assets are automatically deployed via Git** - themes, images, logos in `wp-content/themes/blocksy-child/assets/`

### Quick Asset Backup Before Deployment
```powershell
# Backup any new assets to restore folder
Copy-Item "wp-content/themes/blocksy-child/assets/images/*" "restore/assets/images/"
```

### Manual Asset Upload (Only if Git deployment fails)
```bash
# Upload specific asset
scp -i tmp/hostinger_deploy_key -P 65002 \
  wp-content/themes/blocksy-child/assets/images/eu-logo.svg \
  u909075950@45.84.205.129:~/public_html/wp-content/themes/blocksy-child/assets/images/

# Upload all assets
scp -i tmp/hostinger_deploy_key -P 65002 -r \
  wp-content/themes/blocksy-child/assets/ \
  u909075950@45.84.205.129:~/public_html/wp-content/themes/blocksy-child/
```

### Verify Assets on Production
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 \
  "ls -lh ~/public_html/wp-content/themes/blocksy-child/assets/images/"
```

---

## Export Pages (Local)

**âš ï¸ CRITICAL:** Use `podman cp` method to avoid PowerShell encoding corruption.

### Method 1: Automated Export (Recommended)

```powershell
# Run from repository root
pwsh infra/shared/scripts/export-elementor-pages.ps1
```

**Output:** `tmp/elementor-exports/*.json`

### Method 2: Manual Single Page Export (For Troubleshooting)

```powershell
# Step 1: Export inside container (avoids PowerShell encoding issues)
podman exec wp bash -c "wp post meta get PAGE_ID _elementor_data --allow-root > /tmp/page-export.json"

# Step 2: Copy using podman cp (binary-safe, no encoding conversion)
podman cp wp:/tmp/page-export.json tmp/elementor-exports/page-name.json
```

**âŒ NEVER DO THIS (Corrupts JSON):**
```powershell
# DON'T: PowerShell redirection corrupts JSON with shortcodes
podman exec wp bash -c "wp post meta get PAGE_ID _elementor_data --allow-root" > tmp/export.json

# DON'T: Piping through PowerShell corrupts encoding
podman exec wp bash -c "wp post meta get PAGE_ID _elementor_data --allow-root" | Out-File tmp/export.json
```

**Verify Exports (CRITICAL - Always Run):**
```powershell
# Check file sizes and JSON validity
Get-ChildItem tmp/elementor-exports/*.json | ForEach-Object {
    Write-Host "$($_.Name): $($_.Length) bytes" -NoNewline
    
    # Check for encoding issues
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $hasBOM = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $isUTF16LE = ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE)
    $isUTF16BE = ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF)
    
    if ($hasBOM -or $isUTF16LE -or $isUTF16BE) {
        Write-Host " - âŒ ENCODING CORRUPTED" -ForegroundColor Red
        return
    }
    
    # Validate JSON structure
    try {
        $json = Get-Content $_.FullName -Raw | ConvertFrom-Json
        $elementCount = $json.Count
        
        # Check for shortcodes (if page uses them)
        $content = Get-Content $_.FullName -Raw
        $shortcodeMatches = ([regex]'\"shortcode\":\"([^\"]+)\"').Matches($content)
        
        if ($shortcodeMatches.Count -gt 0) {
            # Verify shortcode attributes are properly escaped
            $hasUnescapedQuotes = $content -match '"shortcode":"\[user_requests_table status=(?![\\"])'
            if ($hasUnescapedQuotes) {
                Write-Host " - âŒ SHORTCODE QUOTES NOT ESCAPED" -ForegroundColor Red
                return
            }
            Write-Host " - âœ“ OK ($elementCount sections, $($shortcodeMatches.Count) shortcodes)" -ForegroundColor Green
        } else {
            Write-Host " - âœ“ OK ($elementCount sections)" -ForegroundColor Green
        }
    } catch {
        Write-Host " - âŒ INVALID JSON: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

**If any files show corruption, re-export using Method 2 (Manual Export) above.**

---

## Deploy to Production

**âš ï¸ Important:** If pages reference forms or other content with IDs, use the [ID Management Strategy](ID-MANAGEMENT-STRATEGY.md) to handle ID replacements automatically.

### Step 1: Upload Exports
```bash
scp -i tmp/hostinger_deploy_key -P 65002 -r tmp/elementor-exports/ u909075950@45.84.205.129:~/
```

**Verify Upload (on production):**
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "file ~/elementor-exports/*.json"
# Should show: "JSON data" or "ASCII text"
# Should NOT show: "UTF-8 Unicode (with BOM)" or "UTF-16"
```

### Step 2: Upload Import Script
```bash
scp -i tmp/hostinger_deploy_key -P 65002 infra/shared/scripts/import-elementor-pages.php u909075950@45.84.205.129:~/elementor-exports/
```

### Step 3: Test Import (Dry Run)
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && ELEMENTOR_DRY_RUN=true wp eval-file ~/elementor-exports/import-elementor-pages.php"
```

### Step 4: Execute Import
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp eval-file ~/elementor-exports/import-elementor-pages.php"
```

### Step 5: Clear Caches
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp elementor flush_css"
```

---

## Verification Checklist

- [ ] Homepage: https://talendelight.com/
- [ ] Employers: https://talendelight.com/employers/
- [ ] Candidates: https://talendelight.com/candidates/
- [ ] Scouts: https://talendelight.com/scouts/
- [ ] Access Restricted: https://talendelight.com/403-forbidden/

For each page:
- [ ] Page loads without errors
- [ ] Compliance footer visible (4 trust badges)
- [ ] Unicode characters render (âœ… âŒ not u2705/u274c)
- [ ] Buttons have correct styling
- [ ] Links work correctly
- [ ] Mobile responsive layout

---

## Rollback (If Needed)

```bash
# Restore from backup
ssh production "cd domains/talendelight.com/public_html && wp db import ~/backups/pre-deployment.sql"
```

---

## Common Issues

### Issue: "Container wp is not running"
**Solution:**
```bash
cd infra/dev
podman-compose up -d
```

### Issue: "Malformed UTF-8 characters"
**Cause:** PowerShell encoding corruption  
**Solution:** Use `podman cp` approach (export script handles this)

### Issue: "File not found"
**Check:**
```bash
ssh production "ls -lah ~/elementor-exports/"
```

### Issue: Pages show no content
**Check Elementor data:**
```bash
ssh production "cd domains/talendelight.com/public_html && wp post meta get 14 _elementor_data | wc -c"
```
Should be >5000 bytes

---

## Post-Deployment: Archive Release

**âš ï¸ Do this IMMEDIATELY after successful deployment**

```powershell
# Windows PowerShell (run from repo root)
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"

# 1. Archive human-readable release notes
Copy-Item docs/RELEASE-NOTES-NEXT.md ".github/releases/archive/RELEASE-NOTES-$timestamp.md"

# 2. Archive machine-readable JSON (example: v3.1.0)
Move-Item .github/releases/v3.1.0.json .github/releases/archive/v3.1.0.json

# 3. Create next version (v3.2.0)
Copy-Item .github/releases/archive/v3.1.0.json .github/releases/v3.2.0.json
Copy-Item docs/templates/RELEASE-NOTES-TEMPLATE.md docs/RELEASE-NOTES-NEXT.md

# 4. Commit and push
git add .github/releases/archive/
git add .github/releases/v3.2.0.json
git add docs/RELEASE-NOTES-NEXT.md
git commit -m "Archive v3.1.0, prepare v3.2.0"
git push origin main
```

**Linux/Mac:**
```bash
timestamp=$(date +%Y%m%d-%H%M)
cp docs/RELEASE-NOTES-NEXT.md ".github/releases/archive/RELEASE-NOTES-$timestamp.md"
mv .github/releases/v3.1.0.json .github/releases/archive/v3.1.0.json
cp .github/releases/archive/v3.1.0.json .github/releases/v3.2.0.json
cp docs/templates/RELEASE-NOTES-TEMPLATE.md docs/RELEASE-NOTES-NEXT.md
# Edit manifest, then git add/commit/push
```

---

## Custom CSS Deployment

**Combine and upload CSS files:**
```powershell
# Combine CSS
$buttonCss = Get-Content config/custom-css/td-button.css -Raw
$pageCss = Get-Content config/custom-css/td-page.css -Raw
$combinedCss = $buttonCss + "`n`n" + $pageCss
Set-Content -Path tmp/combined-custom.css -Value $combinedCss

# Upload to production
scp -i tmp/hostinger_deploy_key -P 65002 tmp/combined-custom.css u909075950@45.84.205.129:~/custom.css
scp -i tmp/hostinger_deploy_key -P 65002 infra/shared/scripts/deploy-custom-css.php u909075950@45.84.205.129:~/
```

**Deploy to WordPress Additional CSS:**
```bash
ssh -i tmp/hostinger_deploy_key -p 65002 u909075050@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp eval-file ~/deploy-custom-css.php"
```

**Expected Output:**
```
âœ“ Custom CSS deployed successfully
Theme: blocksy-child
CSS length: XXXX bytes
```

**See:** [wordpress-custom-css-deployment.md](lessons/wordpress-custom-css-deployment.md) for detailed explanation.

---

## Files Reference

| Purpose | Location |
|---------|----------|
| Export script | `infra/shared/scripts/export-elementor-pages.ps1` |
| Import script | `infra/shared/scripts/import-elementor-pages.php` |
| Export output | `tmp/elementor-exports/*.json` |
| Lessons learned | `docs/lessons/*.md` |
| Deployment template | `docs/templates/TEMPLATE-ELEMENTOR-DEPLOYMENT.md` |
| Release format | `docs/RELEASE-INSTRUCTIONS-FORMAT.md` |

---

## PowerShell Commands to Remember

### âŒ NEVER DO THIS
```powershell
podman exec wp wp post meta get 248 _elementor_data > file.json  # Corrupts data
podman exec wp wp post meta get 248 _elementor_data | Out-File file.json  # Corrupts data
```

### âœ… ALWAYS DO THIS
```powershell
podman exec wp bash -c "wp post meta get 248 _elementor_data > /tmp/file.json"
podman cp wp:/tmp/file.json tmp/file.json
```

---

## Support

- **Full documentation:** `DEPLOYMENT-WORKFLOW.md` (same directory)
- **Template:** `docs/templates/TEMPLATE-ELEMENTOR-DEPLOYMENT.md`
- **Lessons learned:** `docs/lessons/`
