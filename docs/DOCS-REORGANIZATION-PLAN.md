# Docs Folder Reorganization Plan

**Date:** March 13, 2026  
**Current Files:** 48 markdown files in docs/  
**Goal:** Reduce to ~25 files, move feature-specific to features/, consolidate related content

---

## 1. Move to docs/features/ (7 files)

These are feature-specific implementation guides that belong with other WP-* feature files:

### Ready to Move:
1. **PENG-001-CANDIDATEID-STRATEGY-V2.md** → `features/WP-RECORD-ID-STRATEGY.md`
   - Supersedes V1, comprehensive Record ID (PRSN/CMPY) strategy
   - Relates to registration and user management features

2. **PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md** → `features/WP-ADMIN-ACCESS-CONTROL.md`
   - Implementation details for blocking wp-admin access by role
   - Security feature documentation

3. **PENG-054-TESTING-CHECKLIST.md** → Keep in docs/ (cross-feature testing)
   - Actually applies to ALL features, not feature-specific
   - **Decision: Keep in docs/ root**

4. **MANAGER-ADMIN-PAGE-SETUP.md** → Merge into `features/WP-01.5.1-manager-admin-page.md`
   - Already has WP-01.5.1 file, merge setup guide into it

5. **MANAGER-ADMIN-TABS-IMPLEMENTATION.md** → Merge into `features/WP-01.5.1-manager-admin-page.md`
   - Same file as above

6. **OPERATOR-PAGE-BUILD-GUIDE.md** → Merge into `features/WP-01.4-operator-landing-page.md`
   - Build guide for operator page, merge with existing feature file

7. **WELCOME-PAGE-RESTORE-STEPS.md** → Delete (one-time recovery, no longer relevant)

---

## 2. Delete Obsolete/Temporary Files (16 files)

### Old Checklists & Context (5 files):
- ❌ **TOMORROW-FEB-17-CHECKLIST.md** - Old daily checklist from Feb
- ❌ **TOMORROW-FEB-18-CHECKLIST.md** - Old daily checklist from Feb
- ❌ **RESTART-CONTEXT-FEB-27.md** - Old restart context (Feb 27)
- ❌ **MIGRATION-LOG.md** - Old migration tracking
- ❌ **QUICK-ANSWER-PAGE-ID-DEPENDENCY.md** - Answered question/solved

### Superseded Strategy (1 file):
- ❌ **PENG-001-CANDIDATEID-STRATEGY.md** - V1, superseded by V2

### Old Analysis/Audits (3 files):
- ❌ **UI-DESIGN-FILES-ANALYSIS.md** - One-time analysis from Jan 26
- ❌ **DESIGN-AUDIT-LOCAL.md** - Old audit with outdated page IDs
- ❌ **DESIGN-POLISH-IMPLEMENTATION.md** - Implementation complete

### Outdated Deployment/Infrastructure (4 files):
- ❌ **POST-MORTEM-V3.6.0-DEPLOYMENT-GAPS.md** - Old post-mortem (Feb 15)
- ❌ **PRODUCTION-VS-LOCAL-COMPARISON.md** - Outdated comparison
- ❌ **SSH-CONNECTION-STATUS.md** - Old connection doc
- ❌ **HOSTINGER-TALENDELIGHT.md** - Legacy talendelight.com (keep HOSTINGER-HIREACCORD.md)

### Superseded by Documents Folder (3 files):
- ❌ **TASK-ORGANIZATION-STRATEGY.md** - Superseded by TASK-MANAGEMENT-GUIDE.md in Documents/
- ❌ **WELCOME-PAGE-RESTORE-STEPS.md** - One-time recovery procedure

---

## 3. Consolidate Related Files (2 → 1)

### Backup Documentation:
**Current:**
- BACKUP-COMPONENTS.md (7 KB) - Lists what can be backed up
- BACKUP-STRATEGY.md (19 KB) - Comprehensive strategy guide

**Action:**
- Keep BACKUP-STRATEGY.md (more comprehensive)
- Merge "What Can Be Backed Up" section from BACKUP-COMPONENTS.md
- Delete BACKUP-COMPONENTS.md

---

## 4. Create docs/procedures/ Folder (4 files)

Operational procedures that are referenced but not feature-specific:

1. **DISASTER-RECOVERY-MANIFEST.md** → `procedures/DISASTER-RECOVERY-MANIFEST.md`
2. **EMERGENCY-FIX-MANUAL.md** → `procedures/EMERGENCY-FIX-MANUAL.md`
3. **LOCAL-SSL-SETUP.md** → `procedures/LOCAL-SSL-SETUP.md`
4. **LITESPEED-CONFIG.md** → `procedures/LITESPEED-CONFIG.md`

---

## 5. Keep in docs/ Root (25 files)

### Core Documentation:
- ✅ README.md
- ✅ PROJECT-TIMELINE.md
- ✅ VERSION-HISTORY.md
- ✅ OPEN-ACTIONS.md

### Architecture & Design:
- ✅ DESIGN-SYSTEM.md
- ✅ PATTERN-LIBRARY.md
- ✅ PAGE-TEMPLATES.md
- ✅ NAVIGATION-FLOW.md 
- ✅ API-SECURITY-PATTERNS.md
- ✅ CUSTOM-ROLES-PERSISTENCE.md
- ✅ ID-MANAGEMENT-STRATEGY.md
- ✅ PAGE-ACCESS-CONTROL.md
- ✅ ROLE-CAPABILITIES-MATRIX.md
- ✅ SYNC-STRATEGY.md

### Deployment & Infrastructure:
- ✅ HOSTINGER-HIREACCORD.md (current production)
- ✅ BACKUP-STRATEGY.md (after merging BACKUP-COMPONENTS)

### Testing & QA:
- ✅ FUNCTIONAL-TEST-CASES.md
- ✅ TEST-USERS.md
- ✅ PENG-054-TESTING-CHECKLIST.md (cross-feature)

### Release Management:
- ✅ RELEASE-NOTES-PROCESS.md
- ✅ RELEASE-INSTRUCTIONS-FORMAT.md

### Recent Documentation (v3.7.3):
- ✅ SHORTCODE-IMPLEMENTATION-COMPLETE.md
- ✅ WHY-FILES-WERE-MISSED.md

---

## 6. Implementation Script

```powershell
# Create procedures folder
New-Item -ItemType Directory -Path "docs\procedures" -Force

# Move feature files to features/
Move-Item "docs\PENG-001-CANDIDATEID-STRATEGY-V2.md" "docs\features\WP-RECORD-ID-STRATEGY.md"
Move-Item "docs\PENG-053-WPADMIN-BLOCK-IMPLEMENTATION.md" "docs\features\WP-ADMIN-ACCESS-CONTROL.md"

# Move procedures
Move-Item "docs\DISASTER-RECOVERY-MANIFEST.md" "docs\procedures\"
Move-Item "docs\EMERGENCY-FIX-MANUAL.md" "docs\procedures\"
Move-Item "docs\LOCAL-SSL-SETUP.md" "docs\procedures\"
Move-Item "docs\LITESPEED-CONFIG.md" "docs\procedures\"

# Merge and consolidate (manual step - merge BACKUP-COMPONENTS into BACKUP-STRATEGY)
# Then delete BACKUP-COMPONENTS.md

# Delete obsolete files
Remove-Item docs\TOMORROW-FEB-17-CHECKLIST.md
Remove-Item docs\TOMORROW-FEB-18-CHECKLIST.md
Remove-Item docs\RESTART-CONTEXT-FEB-27.md
Remove-Item docs\PENG-001-CANDIDATEID-STRATEGY.md
Remove-Item docs\UI-DESIGN-FILES-ANALYSIS.md
Remove-Item docs\DESIGN-AUDIT-LOCAL.md
Remove-Item docs\DESIGN-POLISH-IMPLEMENTATION.md
Remove-Item docs\POST-MORTEM-V3.6.0-DEPLOYMENT-GAPS.md
Remove-Item docs\PRODUCTION-VS-LOCAL-COMPARISON.md
Remove-Item docs\SSH-CONNECTION-STATUS.md
Remove-Item docs\HOSTINGER-TALENDELIGHT.md
Remove-Item docs\TASK-ORGANIZATION-STRATEGY.md
Remove-Item docs\MIGRATION-LOG.md
Remove-Item docs\QUICK-ANSWER-PAGE-ID-DEPENDENCY.md
Remove-Item docs\WELCOME-PAGE-RESTORE-STEPS.md
Remove-Item docs\BACKUP-COMPONENTS.md

# Merge feature guides (manual)
# 1. Merge MANAGER-ADMIN-PAGE-SETUP.md + MANAGER-ADMIN-TABS-IMPLEMENTATION.md into WP-01.5.1-manager-admin-page.md
# 2. Merge OPERATOR-PAGE-BUILD-GUIDE.md into WP-01.4-operator-landing-page.md
# 3. Delete original files after merge

Remove-Item docs\MANAGER-ADMIN-PAGE-SETUP.md
Remove-Item docs\MANAGER-ADMIN-TABS-IMPLEMENTATION.md
Remove-Item docs\OPERATOR-PAGE-BUILD-GUIDE.md
```

---

## 7. Summary

**Before:** 48 files  
**After:** ~25 files in docs/ + 2 in features/ + 4 in procedures/

**Benefits:**
- ✅ Easier to find documentation (less clutter)
- ✅ Feature-specific docs with related features
- ✅ Procedures organized separately
- ✅ Removed 16 obsolete/temporary files
- ✅ Consolidated backup documentation
- ✅ No information lost (merged content preserved)

**Next Steps:**
1. Review this plan
2. Manually merge content as needed
3. Execute reorganization script
4. Commit changes with clear commit message
5. Update any broken references in remaining docs
