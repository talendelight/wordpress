# Release Notes Archive

This directory contains:
- **Active releases:** Machine-readable JSON files for GitHub Actions automation
- **Archived releases:** Historical release notes in `archive/` folder

**File naming convention:** 
- Active: `vX.Y.Z.json` (e.g., `v3.2.0.json`)
- Archive: `archive/vX.Y.Z.json` and `archive/RELEASE-NOTES-{yyyymmdd-HHmm}.md`

---

## ⚠️ CURRENT RELEASE IDENTIFICATION (Added March 14, 2026)

**CRITICAL: Always check for `_currentRelease: true` flag to identify the active release**

**To find current release:**
```bash
grep -l "_currentRelease.*true" .github/releases/*.json
```

**Rules:**
- ✅ ONLY ONE release file should have `"_currentRelease": true` at any time
- ✅ ALL new work gets documented in the current release file
- ✅ When user says "update release documentation", update CURRENT release (not create new version)
- ❌ DO NOT create new version files until user confirms current release is complete

**As of March 14, 2026:**
- **Current Release:** v3.7.3 (_currentRelease: true)
- **Status:** local-testing (user testing in progress)
- **Scope:** Hero/CTA shortcode refactoring with button centering fix

**Example Mistake (March 14, 2026):**
- ❌ Agent created v3.7.4.json for additional shortcode work
- ✅ User corrected: "Current release is v3.7.3. Update v3.7.3, not create v3.7.4"
- **Lesson**: Check _currentRelease flag before creating new version files

---

## Release Lifecycle Stages

```
planning → in-progress → local-testing → deployed → archived
```

**Status Transitions:**
- **planning**: Release created, tasks identified
- **in-progress**: Active development
- **local-testing**: Deployed locally, user testing
- **deployed**: Released to production
- **archived**: Moved to archive/, next release active

**When to Create NEW Version:**
- ✅ User confirms "this release is complete"
- ✅ User says "start next release" or "create v3.X.X"
- ❌ DO NOT create for bug fixes during testing (add to current)
- ❌ DO NOT create for hot fixes (add to current, redeploy)

---

## Workflow

1. **During development**: 
   - Update `docs/RELEASE-NOTES-NEXT.md` with manual steps
   - Update `.github/releases/vX.Y.Z.json` with deployment config

2. **Before release**: 
   - Review and finalize both files
   - Export Elementor pages if needed

3. **After release**: 
   - Move `vX.Y.Z.json` to `archive/`
   - Copy RELEASE-NOTES-NEXT.md to `archive/RELEASE-NOTES-{yyyymmdd-HHmm}.md`
   - Create next version JSON
   - Reset RELEASE-NOTES-NEXT.md to template

---

**See:** 
- [../../docs/RELEASE-NOTES-PROCESS.md](../../docs/RELEASE-NOTES-PROCESS.md) - Complete workflow
- [../../docs/RELEASE-INSTRUCTIONS-FORMAT.md](../../docs/RELEASE-INSTRUCTIONS-FORMAT.md) - JSON schema
