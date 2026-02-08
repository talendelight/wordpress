# Disaster Recovery Plan

**Version**: 1.0  
**Last Updated**: February 8, 2026  
**Owner**: Technical Lead

## Overview

This document outlines procedures for recovering from production incidents including data loss, page disappearance, deployment failures, and database corruption.

## Incident Severity Levels

| Level | Description | Response Time | Example |
|-------|-------------|---------------|---------|
| **P0 - Critical** | Site down, data loss | Immediate | Database corrupted, all pages missing |
| **P1 - High** | Major functionality broken | 1 hour | Homepage missing, critical pages gone |
| **P2 - Medium** | Minor functionality impaired | 4 hours | Single page missing, asset missing |
| **P3 - Low** | Cosmetic issue | 1 day | Styling issue, non-critical content missing |

## Prevention: Automated Backup System

### Daily Automated Backups

Run daily at 02:00 UTC (before typical traffic):

```powershell
# Schedule via Windows Task Scheduler
pwsh c:\data\lochness\talendelight\code\wordpress\infra\shared\scripts\backup-production.ps1
```

**What Gets Backed Up:**
- ✅ All WordPress pages (JSON export)
- ✅ Critical options (homepage, theme, plugins)
- ✅ Theme files (functions.php, style.css, assets)
- ✅ Block patterns (all 10 patterns)
- ✅ Full database (optional, weekly recommended)

**Backup Retention:**
- Keeps last 10 backups (configurable via `-MaxBackups` parameter)
- Timestamped directories: `restore/backups/yyyyMMdd-HHmm/`
- Manifest file tracks what's in each backup

### Pre-Deployment Backup

**CRITICAL**: Always backup before deploying to production:

```powershell
# Run before git push to main
pwsh infra/shared/scripts/backup-production.ps1
```

This creates a recovery point to rollback if deployment causes issues.

## Detection: Production Monitoring

### Manual Verification

After each deployment:

```powershell
# Verify all critical items present
pwsh infra/shared/scripts/verify-production.ps1
```

**Checks Performed:**
- ✅ Critical pages exist (Welcome, Log In, Privacy Policy)
- ✅ Homepage setting correct (page_on_front)
- ✅ All 10 block patterns present
- ✅ Theme assets present (EU logo, functions.php)
- ✅ Theme activation (blocksy-child)
- ✅ Critical plugins active (WooCommerce, Better Font Awesome)

**Output:**
- Reports pass/fail for each check
- Saves issues report: `tmp/verification-issues-yyyyMMdd-HHmm.json`
- Exit code 0 = all passed, 1 = issues found

### Automated Monitoring (Future)

**Planned Enhancements:**
- Scheduled verification every 6 hours
- Email/Slack alerts on failures
- Dashboard showing production health
- Automatic restore on critical failures

## Recovery Procedures

### Scenario 1: Single Page Missing (P2)

**Example**: Welcome page disappeared (current incident)

**Detection:**
```powershell
# Check specific page
ssh u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp post list --post_type=page --name=welcome --allow-root"
```

**Recovery Steps:**

1. **Restore from latest backup**:
```powershell
# Restore all pages from latest backup
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $false
```

2. **Manual restore** (if automated fails):
```powershell
# Upload page content
scp tmp/welcome-page-clean.html u909075950@45.84.205.129:~/welcome-content.html

# Upload restore script
scp tmp/create-welcome-page.php u909075950@45.84.205.129:~/create-welcome-page.php

# Execute restore
ssh u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp eval-file ~/create-welcome-page.php --allow-root"
```

3. **Verify restoration**:
```powershell
pwsh infra/shared/scripts/verify-production.ps1
```

**Recovery Time**: 5-10 minutes

---

### Scenario 2: Multiple Pages Missing (P1)

**Example**: All custom pages gone, only Sample Page remains

**Detection:**
```powershell
# List all pages
ssh u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp post list --post_type=page --format=csv --allow-root"
```

**Recovery Steps:**

1. **Restore all pages and settings**:
```powershell
# Full content restore
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $true
```

2. **If backup unavailable, deploy from Git**:
```bash
# Re-trigger GitHub Actions deployment
git commit --allow-empty -m "Force deployment"
git push origin main
```

3. **Manually recreate pages** (last resort):
```bash
# Use local development as reference
# Copy content from tmp/welcome-page-clean.html, etc.
```

**Recovery Time**: 10-20 minutes

---

### Scenario 3: Database Corruption (P0)

**Example**: WordPress admin won't load, database errors in logs

**Detection:**
```bash
# Check database connectivity
ssh u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp db check --allow-root"
```

**Recovery Steps:**

1. **Contact Hostinger immediately**:
   - Phone: [Hostinger support number]
   - Email: support@hostinger.com
   - Request database restore from their backups

2. **If have recent backup**:
```powershell
# DESTRUCTIVE - Overwrites entire database
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestoreDatabase $true

# Will prompt for confirmation
# Type "YES" to proceed
```

3. **After restore, verify all content**:
```powershell
pwsh infra/shared/scripts/verify-production.ps1
```

4. **Check WordPress admin**:
   - Login: https://talendelight.com/wp-admin
   - Verify pages, plugins, settings

**Recovery Time**: 30-60 minutes (depends on Hostinger response)

---

### Scenario 4: Deployment Failure (P1)

**Example**: Git push succeeded but production showing errors

**Detection:**
- GitHub Actions deployment failed
- Production verification failed
- Site showing 500 errors

**Recovery Steps:**

1. **Rollback Git deployment**:
```bash
# Revert to previous commit
git revert HEAD
git push origin main

# Wait for Hostinger auto-deployment (30 seconds)
```

2. **If revert fails, restore from backup**:
```powershell
# Restore theme files to previous version
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp [previous-timestamp] -RestoreTheme $true
```

3. **Clear all caches**:
```bash
ssh u909075950@45.84.205.129 "cd domains/talendelight.com/public_html && wp cache flush --allow-root"
```

4. **Investigate root cause**:
```bash
# Check error logs
ssh u909075950@45.84.205.129 "tail -n 100 domains/talendelight.com/logs/error_log"
```

**Recovery Time**: 15-30 minutes

---

### Scenario 5: Theme/Assets Missing (P2)

**Example**: EU logo not loading, patterns missing

**Detection:**
```bash
# Check files exist
ssh u909075950@45.84.205.129 "ls -lh domains/talendelight.com/public_html/wp-content/themes/blocksy-child/assets/images/"
```

**Recovery Steps:**

1. **Re-deploy from Git**:
```bash
# Force re-deployment
git commit --allow-empty -m "Redeploy assets"
git push origin main
```

2. **Manual upload** (if Git fails):
```powershell
# Upload assets
scp -r wp-content/themes/blocksy-child/assets u909075950@45.84.205.129:domains/talendelight.com/public_html/wp-content/themes/blocksy-child/

# Upload patterns
scp -r wp-content/themes/blocksy-child/patterns u909075950@45.84.205.129:domains/talendelight.com/public_html/wp-content/themes/blocksy-child/
```

3. **Restore from backup**:
```powershell
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestoreTheme $true
```

**Recovery Time**: 5-10 minutes

---

## Testing & Validation

### Quarterly DR Drills

**Schedule**: First Saturday of each quarter

**Test Scenarios:**
1. Restore single page from backup
2. Full database restore to staging environment
3. Deployment rollback procedure
4. Asset restoration

**Documentation**: Record results in `docs/lessons/dr-drill-YYYY-QN.md`

### Backup Verification

**Monthly**: Verify backup integrity

```powershell
# Test restore to local environment
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -DryRun
```

## Communication Plan

### Internal Team

**Incident Response**:
1. Manager notified immediately (P0/P1)
2. Update status in Slack/Teams
3. Document incident in `docs/lessons/incident-YYYYMMDD.md`
4. Post-mortem within 48 hours

### External (Customers)

**P0/P1 Incidents Only**:
1. Status page update (if available)
2. Email notification to active users
3. Homepage banner during recovery

**Template**:
```
We're currently experiencing technical difficulties. 
Our team is working to restore service. 
Expected resolution: [timeframe]
```

## Backup Schedule

| Frequency | What | When | Retention |
|-----------|------|------|-----------|
| **Daily** | Pages, options, patterns, assets | 02:00 UTC | 10 days |
| **Weekly** | Full database | Sunday 02:00 UTC | 4 weeks |
| **Pre-deployment** | Full backup | Before git push | Until next deployment |
| **Monthly** | Archive backup | 1st of month | 6 months |

## Key Contacts

| Role | Contact | Availability |
|------|---------|--------------|
| **Manager/Lead** | [Your contact] | 24/7 for P0/P1 |
| **Hostinger Support** | support@hostinger.com | 24/7 |
| **Hostinger Phone** | [Support number] | 24/7 |
| **Database Admin** | [If separate] | Business hours |

## Tools & Access

**Required Access:**
- SSH to production: `u909075950@45.84.205.129`
- Hostinger control panel: https://hpanel.hostinger.com
- GitHub repository: github.com/talendelight/wordpress
- WP-CLI on production: Available via SSH

**Required Tools:**
- PowerShell 7+
- OpenSSH client (scp, ssh)
- Git client
- Local WordPress (for testing restores)

## Post-Incident Checklist

After resolving any incident:

- [ ] Document incident in `docs/lessons/incident-YYYYMMDD.md`
- [ ] Update DR plan with lessons learned
- [ ] Verify backup system working
- [ ] Run verification script: `verify-production.ps1`
- [ ] Create fresh backup: `backup-production.ps1`
- [ ] Review and update monitoring alerts
- [ ] Schedule post-mortem meeting (P0/P1 only)
- [ ] Update team on resolution

## Related Documentation

- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Normal deployment process
- [QUICK-REFERENCE-DEPLOYMENT.md](QUICK-REFERENCE-DEPLOYMENT.md) - Quick command reference
- [BACKUP-RESTORE-PROCEDURES.md](BACKUP-RESTORE-PROCEDURES.md) - Detailed backup/restore steps
- [WELCOME-PAGE-RESTORE-STEPS.md](WELCOME-PAGE-RESTORE-STEPS.md) - Current incident response

---

**Remember**: When in doubt, always backup first, then restore. Never skip backups before making changes.

**Next Review**: May 8, 2026
