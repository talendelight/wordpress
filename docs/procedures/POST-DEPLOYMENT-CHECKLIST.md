# Post-Deployment Checklist

**Purpose:** Verify production deployment completed successfully after `git push origin main`

**Time Required:** 5-10 minutes

**When to Use:** After EVERY deployment to production (no exceptions)

---

## 🚦 Quick Verification (2 minutes)

**Run immediately after `git push origin main`:**

```powershell
# 1. Wait for Hostinger auto-deployment (30 seconds)
Start-Sleep -Seconds 30

# 2. Verify deployment
pwsh infra/shared/scripts/verify-deployment.ps1

# 3. Check production health
pwsh infra/shared/scripts/wp-action.ps1 verify
```

**✅ Success Criteria:**
- All files show "✅ MATCH"
- No "❌ SIZE MISMATCH" or "🚫 MISSING" errors
- Health check passes (pages exist, plugins active)

**❌ If verification fails:** Proceed to Manual Deployment below

---

## 🔧 Manual Deployment (When Auto-Deploy Fails)

### Step 1: Identify Missing Files

```powershell
# Get list of changed wp-content/ files from latest commit
git show HEAD --name-status --format="" | Where-Object {$_ -match '^[AM].*wp-content/'}
```

### Step 2: Deploy Files via SCP

```powershell
# Template (adjust file path):
scp -P 65002 -i "tmp\hostinger_deploy_key" "wp-content\mu-plugins\your-file.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/mu-plugins/

# Example (multiple files):
scp -P 65002 -i "tmp\hostinger_deploy_key" "wp-content\mu-plugins\operator-actions-display.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/mu-plugins/
scp -P 65002 -i "tmp\hostinger_deploy_key" "wp-content\mu-plugins\manager-actions-display.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/mu-plugins/
```

### Step 3: Clear Production Cache

```bash
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cache flush --allow-root"
```

### Step 4: Re-verify Deployment

```powershell
# Run verification again
pwsh infra/shared/scripts/verify-deployment.ps1
```

---

## 📋 Complete Verification Checklist

Use this after deployment completes (auto or manual):

### File Verification

- [ ] All wp-content/ PHP files deployed (verify-deployment.ps1 passes)
- [ ] File sizes match local workspace
- [ ] No "MISSING" files in production
- [ ] Cache cleared (`wp cache flush`)

### Functional Testing

**For Plugin Changes:**
- [ ] Visit admin dashboard (https://talendelight.com/wp-admin)
- [ ] Check Plugins page (verify no errors)
- [ ] Test shortcodes render correctly
- [ ] Check browser console for JavaScript errors

**For Page Changes:**
- [ ] Visit affected pages in browser
- [ ] Test interactive elements (buttons, tabs, forms)
- [ ] Check mobile responsiveness (Chrome DevTools)
- [ ] Verify footer elements present

**For Database Changes:**
- [ ] Run `wp-action.ps1 verify` (checks essential tables)
- [ ] Query production database for expected data
- [ ] Verify no SQL errors in logs

### Production Health

- [ ] HomePage loads: https://talendelight.com/
- [ ] Admin accessible: https://talendelight.com/wp-admin
- [ ] No PHP errors: `ssh production "tail -50 /home/.../error_log"`
- [ ] Key pages work: /candidates/, /employers/, /managers/, /operators/

---

## 🚨 Rollback Procedure

**If deployment causes production issues:**

```powershell
# 1. Restore from latest backup
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true

# 2. Verify rollback successful
pwsh infra/shared/scripts/wp-action.ps1 verify

# 3. Investigate issue in local environment
# Fix the problem, test thoroughly, then re-deploy
```

**See:** [DISASTER-RECOVERY-PLAN.md](DISASTER-RECOVERY-PLAN.md) for detailed rollback procedures

---

## 📊 Deployment Tracking

**After successful deployment, update:**

1. **Release notes:** `.github/releases/RELEASE-NOTES-vX.Y.Z.md` - Mark as deployed
2. **Version history:** `docs/VERSION-HISTORY.md` - Add deployment timestamp
3. **Timeline:** `docs/PROJECT-TIMELINE.md` - Update milestone status
4. **Tasks:** Mark related tasks complete in WORDPRESS-ALL-TASKS.csv

---

## 🔍 Common Deployment Issues

### Issue: "File missing in production"

**Cause:** Hostinger Git auto-deployment doesn't handle new files reliably

**Solution:** 
1. Deploy manually via SCP (Step 2 above)
2. Run verify-deployment.ps1 to confirm

### Issue: "Size mismatch"

**Cause:** Partial upload, encoding corruption, or different file versions

**Solution:**
1. Re-deploy file via SCP with `-C` flag (compression): `scp -C -P 65002 ...`
2. Verify file hash: `ssh production "md5sum /path/to/file"`
3. Compare with local: `Get-FileHash -Algorithm MD5 local\file.php`

### Issue: "Changes not visible on website"

**Cause:** Cache not cleared

**Solution:**
1. Clear WordPress cache: `ssh production "wp cache flush --allow-root"`
2. Clear LiteSpeed cache (if enabled): See [LITESPEED-CONFIG.md](../LITESPEED-CONFIG.md)
3. Clear browser cache (Ctrl+Shift+R)

### Issue: "Plugin causes fatal error"

**Cause:** PHP syntax error, missing dependency, or version incompatibility

**Solution:**
1. **Immediate:** Restore previous version via SCP
2. **Fix:** Test in local environment with same PHP version
3. **Verify:** Run `php -l file.php` to check syntax
4. **Re-deploy:** After fixing and testing

---

## 📚 Related Documentation

- **[DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md)** - Complete deployment process
- **[DISASTER-RECOVERY-PLAN.md](DISASTER-RECOVERY-PLAN.md)** - Rollback procedures
- **[BACKUP-RESTORE-QUICKSTART.md](BACKUP-RESTORE-QUICKSTART.md)** - Quick recovery commands
- **[TASK-REGISTRY.md](../../.github/TASK-REGISTRY.md)** - Deployment task reference
- **[COMMAND-REGISTRY.md](../../.github/COMMAND-REGISTRY.md)** - Command reference

---

## 🎯 Success Metrics

**Deployment considered successful when:**

✅ All files deployed (verify-deployment.ps1 passes)  
✅ Functional tests pass (checklist above completed)  
✅ Production health check passes (wp-action.ps1 verify)  
✅ No errors in production logs (error_log empty or only warnings)  
✅ User testing confirms expected behavior

**Time to verify:** 5-10 minutes  
**Time to rollback:** 2-5 minutes (if needed)

---

**Last Updated:** February 26, 2026  
**Related Release:** v3.6.4 (Operators deployment lesson learned)
