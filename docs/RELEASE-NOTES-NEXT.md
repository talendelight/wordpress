# Release Notes & Deployment Instructions

**Status:** 📋 Planning  
**Version:** v3.6.2  
**Target Date:** TBD

This document tracks all manual deployment steps required for the **next production release**.

**Purpose:** Ensure consistent, error-free deployments by documenting every manual step needed after Git push to main branch.

**📋 See Process:** [RELEASE-NOTES-PROCESS.md](RELEASE-NOTES-PROCESS.md) for workflow documentation

---

## v3.6.2 Release Summary

**Release Type:** TBD  
**Deploy Date:** TBD

### Key Changes

*No changes yet - add changes here as they are implemented*

### Files to Deploy

**Theme Files:**
- None yet

**Plugins:**
- None yet

**MU-Plugins:**
- None yet

**Database Migrations:**
- None yet

**Page Content:**
- None yet

### Testing Required

**Pre-Deployment (Local):**
- [ ] No changes to test yet

**Post-Deployment (Production):**
- [ ] No changes to verify yet

---

## Deployment Steps

### Prerequisites

✅ **Completed:**
- [ ] All changes tested locally
- [ ] Database migrations tested in isolation
- [ ] Backup created: `pwsh infra/shared/scripts/wp-action.ps1 backup`

### Step 1: Deploy Code to Production

**Action:** Push to main branch (triggers Hostinger auto-deployment)

```bash
git checkout main
git merge develop --no-edit
git push origin main
git checkout develop
```

**Wait:** 30-60 seconds for Hostinger to auto-deploy

### Step 2: Verify Deployment

**Action:** Run production health check

```powershell
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
```

**Expected:** All checks pass ✅

### Step 3: Apply Database Migrations (if any)

**Action:** Apply migrations via SSH

```bash
# No migrations for this release yet
```

### Step 4: Update Page Content (if any)

**Action:** Import pages via wp-cli

```bash
# No page updates for this release yet
```

### Step 5: Final Verification

**Action:** Manual testing checklist

- [ ] No manual tests defined yet

---

## Rollback Plan

**If deployment fails:**

```bash
# 1. Restore from latest backup
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true

# 2. If needed, revert code
git checkout main
git revert HEAD
git push origin main
git checkout develop
```

---

## Post-Deployment

### Success Criteria
- [ ] No criteria defined yet

### Archive This Release

**After successful deployment:**

```powershell
# Archive release notes
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
Move-Item docs/RELEASE-NOTES-NEXT.md ".github/releases/archive/RELEASE-NOTES-$timestamp.md"

# Archive release JSON
Move-Item .github/releases/v3.6.2.json .github/releases/archive/v3.6.2.json

# Create next version
Copy-Item .github/releases/archive/v3.6.2.json .github/releases/v3.6.3.json
# Update version number in v3.6.3.json

# Commit archive
git add .github/releases/archive/ .github/releases/v3.6.3.json docs/RELEASE-NOTES-NEXT.md
git commit -m "Archive v3.6.2, prepare v3.6.3"
git push origin main
git checkout develop
git merge main --no-edit
git push origin develop
```

---

## Notes

- Add implementation notes here as work progresses
- Document any gotchas or special considerations
- Track dependencies between changes

---

## Change Log

| Date | Change | Status |
|------|--------|--------|
| 2026-02-11 | Created release notes for v3.6.2 | Planning |
