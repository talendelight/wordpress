# SSH Connection Status - February 9, 2026

## Current Situation

**Problem:** Production site redirecting to `https://talendelight.com:8080/` (unreachable) + Welcome page missing

**Resolution Status:** Emergency fix scripts ready, but SSH requires interactive password authentication

## SSH Connection Details (From HOSTINGER.md)

- **Host:** 45.84.205.129
- **Port:** 65002 (not default port 22) ✅ **CORRECT**
- **User:** u909075950
- **SSH Key:** `tmp/hostinger_deploy_key` ❌ **MISSING**
- **Password:** Available in Hostinger control panel ✅

## What Works

✅ SSH connection reaches server (prompts for password)  
✅ Correct port (65002) now configured in scripts  
✅ Emergency fix scripts created and ready  
✅ Manual fix option documented in COMPLETE-RESTORE-GUIDE.md

## What's Blocking

❌ SSH key file missing (`tmp/hostinger_deploy_key` not found)  
❌ PowerShell terminal non-interactive (cannot enter password)  
❌ Previous attempts used wrong port (22 instead of 65002)

## Resolution Options

### Option 1: Interactive SSH Session (RECOMMENDED - Quick Fix)

Open a separate PowerShell terminal and run commands manually:

```powershell
cd c:\data\lochness\talendelight\code\wordpress

# Test connection (will prompt for password)
ssh -p 65002 u909075950@45.84.205.129

# Once logged in, run these commands:
cd domains/talendelight.com/public_html

# Fix URLs
wp option update siteurl 'https://talendelight.com' --allow-root
wp option update home 'https://talendelight.com' --allow-root

# Check if Welcome page exists
wp post list --post_type=page --format=csv --fields=ID,post_title,post_name --allow-root

# If Welcome page missing, you'll need to upload the HTML content
# See Option 2 below for file upload method
```

**Estimated Time:** 5-10 minutes

### Option 2: Hostinger File Manager (NO SSH REQUIRED)

1. **Log into Hostinger Control Panel**
   - URL: https://hpanel.hostinger.com
   - Navigate to: Files → File Manager

2. **Upload Fix Scripts**
   - Go to: `/home/u909075950/`
   - Create new file: `fix-urls.php` (see COMPLETE-RESTORE-GUIDE.md for code)
   - Create new file: `restore-welcome.php` (see COMPLETE-RESTORE-GUIDE.md for code)
   - Upload file: `welcome-content.html` (from `restore/pages/welcome-page-clean.html`)

3. **Execute via Terminal**
   - In File Manager, click "Terminal" button
   - Run:
     ```bash
     cd ~
     php fix-urls.php
     php restore-welcome.php
     rm fix-urls.php restore-welcome.php
     ```

4. **Verify**
   - Visit: https://talendelight.com
   - Should load without :8080 redirect
   - Should show Welcome page

**Estimated Time:** 10-15 minutes

### Option 3: Retrieve SSH Key from Hostinger

1. **Check Hostinger for SSH Key**
   - URL: https://hpanel.hostinger.com/websites/talendelight.com/advanced/ssh-access
   - Download private key if available

2. **Save to Project**
   ```powershell
   # Save key content to tmp/hostinger_deploy_key
   # Set permissions: chmod 600 (on Linux/Mac) or equivalent on Windows
   ```

3. **Re-run Emergency Script**
   ```powershell
   .\infra\shared\scripts\emergency-fix-production.ps1
   ```

**Estimated Time:** 15-20 minutes (if key available)

### Option 4: Generate New SSH Key

1. **Generate New Key Pair**
   ```powershell
   ssh-keygen -t rsa -b 4096 -f tmp/hostinger_deploy_key -N ""
   ```

2. **Upload Public Key to Hostinger**
   - Go to: https://hpanel.hostinger.com/websites/talendelight.com/advanced/ssh-access
   - Add public key: `tmp/hostinger_deploy_key.pub`

3. **Re-run Emergency Script**
   ```powershell
   .\infra\shared\scripts\emergency-fix-production.ps1
   ```

**Estimated Time:** 20-30 minutes

## Recommendation

**Use Option 1 (Interactive SSH) for fastest resolution:**

1. Open new PowerShell window
2. SSH into production: `ssh -p 65002 u909075950@45.84.205.129`
3. Fix URLs: `wp option update siteurl 'https://talendelight.com' --allow-root`
4. Fix URLs: `wp option update home 'https://talendelight.com' --allow-root`
5. Test site: https://talendelight.com

Then handle Welcome page restoration separately if needed.

## After Fix Complete

1. **Create Backup**
   ```powershell
   .\infra\shared\scripts\wp-action.ps1 backup
   ```

2. **Verify Production**
   ```powershell
   .\infra\shared\scripts\wp-action.ps1 verify
   ```

3. **Generate/Retrieve SSH Key** (to enable automated scripts for future)

## Files Referenced

- **Emergency Script:** `infra/shared/scripts/emergency-fix-production.ps1`
- **Complete Guide:** `restore/COMPLETE-RESTORE-GUIDE.md` (includes Option 4)
- **Manual Steps:** `docs/EMERGENCY-FIX-MANUAL.md`
- **SSH Details:** `docs/HOSTINGER.md`
- **Welcome Page Backup:** `restore/pages/welcome-page-clean.html`
