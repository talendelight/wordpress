# Quick Reference: Elementor Page Deployment

**📚 See Also:** [ID Management Strategy](ID-MANAGEMENT-STRATEGY.md) - How to handle IDs across environments

---

## Prerequisites Check
- [ ] Local WordPress container running (`podman ps` shows `wp` container)
- [ ] SSH access to production configured (`ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129`)
- [ ] WP-CLI available on production
- [ ] Changes tested locally at http://localhost:8080

---

## Export Pages (Local)

```powershell
# Run from repository root
pwsh infra/shared/scripts/export-elementor-pages.ps1
```

**Output:** `tmp/elementor-exports/*.json`

**Verify Exports (CRITICAL - Always Run):**
```powershell
# Check file sizes
Get-ChildItem tmp/elementor-exports/*.json | ForEach-Object {
    Write-Host "$($_.Name): $($_.Length) bytes"
}

# Verify encoding (should see "OK" for each file)
Get-ChildItem tmp/elementor-exports/*.json | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $hasBOM = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $isUTF16LE = ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE)
    $isUTF16BE = ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF)
    
    if ($hasBOM -or $isUTF16LE -or $isUTF16BE) {
        Write-Host "❌ $($_.Name): ENCODING CORRUPTED" -ForegroundColor Red
    } else {
        try {
            $json = Get-Content $_.FullName -Raw | ConvertFrom-Json
            Write-Host "✓ $($_.Name): OK ($($json.Count) sections)" -ForegroundColor Green
        } catch {
            Write-Host "❌ $($_.Name): INVALID JSON" -ForegroundColor Red
        }
    }
}
```

**If any files show corruption, re-export using `podman cp`:**
```powershell
# Export inside container
podman exec wp bash -c "wp post meta get PAGE_ID _elementor_data --allow-root > /tmp/page.json"

# Copy directly (no PowerShell encoding)
podman cp wp:/tmp/page.json tmp/elementor-exports/page.json
```

---

## Deploy to Production

**⚠️ Important:** If pages reference forms or other content with IDs, use the [ID Management Strategy](ID-MANAGEMENT-STRATEGY.md) to handle ID replacements automatically.

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
- [ ] Unicode characters render (✅ ❌ not u2705/u274c)
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

**⚠️ Do this IMMEDIATELY after successful deployment**

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

# 4. Update manifest version
# Edit infra/shared/elementor-manifest.json - change "version": "3.2.0"

# 5. Commit and push
git add .github/releases/archive/
git add .github/releases/v3.2.0.json
git add docs/RELEASE-NOTES-NEXT.md
git add infra/shared/elementor-manifest.json
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
✓ Custom CSS deployed successfully
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
| Page mappings | `infra/shared/elementor-manifest.json` |
| Export output | `tmp/elementor-exports/*.json` |
| Lessons learned | `docs/lessons/*.md` |
| Deployment template | `docs/templates/TEMPLATE-ELEMENTOR-DEPLOYMENT.md` |
| Release format | `docs/RELEASE-INSTRUCTIONS-FORMAT.md` |

---

## PowerShell Commands to Remember

### ❌ NEVER DO THIS
```powershell
podman exec wp wp post meta get 248 _elementor_data > file.json  # Corrupts data
podman exec wp wp post meta get 248 _elementor_data | Out-File file.json  # Corrupts data
```

### ✅ ALWAYS DO THIS
```powershell
podman exec wp bash -c "wp post meta get 248 _elementor_data > /tmp/file.json"
podman cp wp:/tmp/file.json tmp/file.json
```

---

## Support

- **Full documentation:** `docs/DEPLOYMENT-WORKFLOW.md`
- **Template:** `docs/templates/TEMPLATE-ELEMENTOR-DEPLOYMENT.md`
- **Lessons learned:** `docs/lessons/`
