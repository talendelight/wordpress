# Release Notes Archive

This directory contains historical release notes for all production deployments.

**File naming convention:** `RELEASE-NOTES-{yyyymmdd-HHmm}.md`

Example: `RELEASE-NOTES-20251230-1500.md` (December 30, 2025 at 3:00 PM)

---

## Active Releases

*No production releases yet. First release will be documented here after deployment.*

| Date | File | Description |
|------|------|-------------|
| TBD | TBD | First production release |

---

## Purpose

- **Historical record** of all production changes
- **Audit trail** for compliance and troubleshooting
- **Rollback reference** when issues occur
- **Team knowledge** sharing for future deployments

---

## Workflow

1. **During development**: Update `docs/RELEASE-NOTES-NEXT.md` with manual steps
2. **Before release**: Review and finalize RELEASE-NOTES-NEXT.md
3. **After release**: 
   - Copy to `docs/releases/RELEASE-NOTES-{yyyymmdd-HHmm}.md`
   - Mark deployment time and status
   - Reset RELEASE-NOTES-NEXT.md to template

---

**See:** [../RELEASE-NOTES-PROCESS.md](../RELEASE-NOTES-PROCESS.md) for complete workflow documentation
