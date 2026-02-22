# Deployment & Restoration: Quick Start

**Created**: February 8, 2026  
**Last Updated**: February 8, 2026  
**Incident**: Welcome page disappeared from production, leading to comprehensive DR system implementation

This guide consolidates the robust deployment and restoration mechanism established after the Welcome page disappearance incident on February 8, 2026.

## Core Principles

1. **Always backup before deployment**
2. **Verify after every deployment**
3. **Keep multiple backup versions**
4. **Test restore procedures regularly**
5. **Automate everything possible**

---

## Daily Workflow

### Before Any Production Change

```powershell
# 1. Backup production (MANDATORY)
pwsh infra/shared/scripts/backup-production.ps1

# Output: restore/backups/yyyyMMdd-HHmm/
# Includes: pages, options, theme, patterns
```

### Deploy Changes

```bash
# 2. Merge and push (triggers Hostinger deployment)
git checkout main
git merge develop --no-edit
git push origin main

# 3. Wait 30 seconds for Hostinger auto-deployment
```

### After Deployment

```powershell
# 4. Verify deployment (MANDATORY)
pwsh infra/shared/scripts/verify-production.ps1

# Exit code 0 = success
# Exit code 1 = issues found (see tmp/verification-issues-*.json)
```

### If Issues Found

```powershell
# 5. Restore from pre-deployment backup
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp [timestamp] -RestorePages $true

# Or restore everything
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $true -RestoreTheme $true
```

---

## Automated Scripts

### 1. backup-production.ps1

**Purpose**: Create timestamped backup of production

**What it backs up**:
- ✅ All WordPress pages (JSON exports)
- ✅ Critical options (homepage, theme, plugins)
- ✅ Theme files (functions.php, style.css, assets)
- ✅ Block patterns (all 10 patterns)
- ✅ Full database (optional, use `-BackupDatabase $true`)

**Usage**:
```powershell
# Standard backup (default: no database)
pwsh infra/shared/scripts/backup-production.ps1

# With database (weekly recommended)
pwsh infra/shared/scripts/backup-production.ps1 -BackupDatabase $true

# Custom retention (default: 10 backups)
pwsh infra/shared/scripts/backup-production.ps1 -MaxBackups 20
```

**Output**:
```
restore/backups/yyyyMMdd-HHmm/
├── manifest.json           # What's in this backup
├── pages/                  # All pages as JSON
│   ├── welcome-6.json
│   ├── log-in-123.json
│   └── ...
├── options.json            # Critical WordPress options
├── theme/                  # Theme files
│   ├── functions.php
│   ├── style.css
│   └── assets/
├── patterns/               # Block patterns
│   └── *.php
└── database.sql            # Full DB (if -BackupDatabase $true)
```

**Retention**: Keeps last 10 backups (configurable), deletes older automatically

---

### 2. verify-production.ps1

**Purpose**: Check production state matches expectations

**What it checks**:
- ✅ Critical pages exist (Welcome, Log In, Privacy Policy)
- ✅ Homepage setting correct (`page_on_front`)
- ✅ All 10 block patterns present
- ✅ Theme assets present (EU logo, etc.)
- ✅ Theme activation (blocksy-child)
- ✅ Critical plugins active (WooCommerce, Better Font Awesome, etc.)

**Usage**:
```powershell
# Run verification
pwsh infra/shared/scripts/verify-production.ps1

# With auto-fix (future feature)
pwsh infra/shared/scripts/verify-production.ps1 -Fix
```

**Output**:
```
=== Verification Summary ===
Total checks: 18
Passed: 18
Failed: 0

✓ All verification checks passed
```

**If issues found**:
- Creates report: `tmp/verification-issues-yyyyMMdd-HHmm.json`
- Lists missing items by category (pages, patterns, assets, settings, plugins)
- Returns exit code 1

---

### 3. restore-production.ps1

**Purpose**: Restore production from timestamped backup

**What it can restore**:
- ✅ Pages (recreates or updates)
- ✅ Options (homepage, theme settings)
- ✅ Theme files (functions.php, assets)
- ✅ Patterns (block patterns)
- ✅ Full database (DESTRUCTIVE)

**Usage**:
```powershell
# Restore pages from latest backup
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true

# Restore pages and options
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $true

# Restore specific backup
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp 20260208-1430 -RestorePages $true

# Dry run (preview without changes)
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -DryRun

# Full restore including database (DESTRUCTIVE)
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $true -RestoreTheme $true -RestoreDatabase $true
```

**Parameters**:
| Parameter | Default | Description |
|-----------|---------|-------------|
| `BackupTimestamp` | *required* | Timestamp or `latest` |
| `RestorePages` | `$true` | Restore all pages |
| `RestoreOptions` | `$true` | Restore WordPress options |
| `RestoreTheme` | `$false` | Restore theme files |
| `RestoreDatabase` | `$false` | Restore full DB (DESTRUCTIVE) |
| `DryRun` | `$false` | Preview only, no changes |

**Output**:
```
=== Restore Summary ===
Items restored: 8
Items failed: 0

✓ Restore complete
```

---

## Common Scenarios

### Scenario: Single Page Missing

**Example**: Welcome page disappeared

```powershell
# 1. Verify what's missing
pwsh infra/shared/scripts/verify-production.ps1

# 2. Restore pages from latest backup
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true

# 3. Verify restoration
pwsh infra/shared/scripts/verify-production.ps1
```

**Recovery Time**: 5-10 minutes

---

### Scenario: Deployment Broke Something

**Example**: After push, site shows errors

```powershell
# 1. Immediate rollback via Git
git revert HEAD
git push origin main

# 2. If Git rollback fails, restore from pre-deployment backup
# (You DID create backup before deployment, right?)
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp [timestamp-before-deploy] -RestorePages $true -RestoreOptions $true -RestoreTheme $true

# 3. Verify restoration
pwsh infra/shared/scripts/verify-production.ps1
```

**Recovery Time**: 15-30 minutes

---

### Scenario: Test Restore Procedure

**Example**: Monthly DR drill

```powershell
# 1. Dry run restore (no changes)
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -DryRun

# Output shows what WOULD be restored without making changes
```

**Recovery Time**: 2 minutes

---

## Backup Schedule

| Frequency | Command | What | Retention |
|-----------|---------|------|-----------|
| **Before deployment** | `backup-production.ps1` | Pages, options, theme, patterns | Until next deployment |
| **Daily** | `backup-production.ps1` | Same as above | 10 days |
| **Weekly** | `backup-production.ps1 -BackupDatabase $true` | Everything + database | 4 weeks |
| **Monthly** | Manual archive | Copy to external storage | 6 months |

**Automate daily backup** (Windows Task Scheduler):
```powershell
# Task: Run daily at 2 AM UTC
pwsh c:\data\lochness\talendelight\code\wordpress\infra\shared\scripts\backup-production.ps1
```

---

## Troubleshooting

### SSH Connection Timeout

**Symptoms**: `ssh: connect to host 45.84.205.129 port 22: Connection timed out`

**Causes**:
- Rate limiting (too many connections)
- Network issue
- Hostinger maintenance

**Solutions**:
1. Wait 5-10 minutes and retry
2. Check Hostinger control panel for service status
3. Use Hostinger File Manager as alternative

### Backup Script Fails

**Symptoms**: Script exits with error

**Common Issues**:
- SSH key missing/expired → Regenerate in Hostinger control panel
- WP-CLI not available → Contact Hostinger support
- Disk space full → Clean up old backups manually

### Restore Script Fails

**Symptoms**: "Error: Could not parse JSON backup"

**Causes**:
- JSON file corruption
- Encoding issues
- File upload corruption

**Solutions**:
1. Try different backup timestamp
2. Try manual restore (see WELCOME-PAGE-RESTORE-STEPS.md)
3. Check backup manifest.json for integrity

### Verification Fails After Restore

**Symptoms**: verify-production.ps1 still reports issues

**Solutions**:
1. Clear production cache: `wp cache flush --allow-root`
2. Check issues report: `tmp/verification-issues-*.json`
3. Try restore with all flags: `-RestorePages -RestoreOptions -RestoreTheme`
4. Contact Hostinger if persists (may be hosting issue)

---

## What Was Implemented

### System Components

**1. Action Dispatcher** (`wp-action.ps1`)
- Central command registry for all operations
- Single entry point with consistent interface
- Built-in help system
- Argument forwarding to underlying scripts

**2. Backup System** (`backup-production.ps1`, 343 lines)
- Timestamped backups in `restore/backups/yyyyMMdd-HHmm/`
- Backs up: pages, options, theme, patterns, database (optional)
- Automatic 10-backup rotation
- Manifest file tracking

**3. Verification System** (`verify-production.ps1`, 214 lines)
- 18+ validation checks via SSH + WP-CLI
- Categories: pages, patterns, assets, settings, plugins
- Issues report generation
- Exit codes for automation

**4. Restore System** (`restore-production.ps1`, 402 lines)
- Restore from any backup timestamp
- Granular control (pages/options/theme/database)
- Dry-run mode
- Automatic cache flushing

### Key Benefits

**Before This System:**
- Manual backups (often forgotten)
- No verification after deployment
- No standard restore procedures
- Recovery time: hours or unknown

**After This System:**
- Automated backups (mandatory workflow)
- Post-deployment verification (18+ checks)
- One-command restore procedures
- Recovery time: 5-10 minutes

### Impact Metrics

- **Backup Coverage**: 100% (pages, options, theme, patterns, database)
- **Recovery Time**: Reduced from hours to 5-10 minutes
- **Verification**: Automated 18+ checks vs. manual spot-checking
- **Documentation**: 4 comprehensive guides created
- **Workspace Cleanup**: Reduced tmp/ from 100+ files to 3 directories

---

## Related Documentation

| Document | Purpose |
|----------|---------|
| [DISASTER-RECOVERY-PLAN.md](DISASTER-RECOVERY-PLAN.md) | Complete DR procedures, incident response |
| [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) | Full deployment process |
| [QUICK-REFERENCE-DEPLOYMENT.md](QUICK-REFERENCE-DEPLOYMENT.md) | Command cheat sheet |
| [WELCOME-PAGE-RESTORE-STEPS.md](WELCOME-PAGE-RESTORE-STEPS.md) | Current incident response |

---

## Quick Command Reference

```powershell
# === BACKUP ===
pwsh infra/shared/scripts/backup-production.ps1
pwsh infra/shared/scripts/backup-production.ps1 -BackupDatabase $true

# === VERIFY ===
pwsh infra/shared/scripts/verify-production.ps1

# === RESTORE ===
# Pages only
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true

# Pages + options
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $true

# Everything except database
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $true -RestoreTheme $true

# Dry run (no changes)
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -DryRun

# === DEPLOY ===
git checkout main && git merge develop --no-edit && git push origin main

# === ROLLBACK ===
git revert HEAD && git push origin main
```

---

**Remember**: Backup before deploy, verify after deploy, restore if needed. Always.
