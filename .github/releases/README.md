# Release Notes Archive

This directory contains:
- **Active releases:** Machine-readable JSON files for GitHub Actions automation
- **Archived releases:** Historical release notes in `archive/` folder

**File naming convention:** 
- Active: `vX.Y.Z.json` (e.g., `v3.2.0.json`)
- Archive: `archive/vX.Y.Z.json` and `archive/RELEASE-NOTES-{yyyymmdd-HHmm}.md`

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
