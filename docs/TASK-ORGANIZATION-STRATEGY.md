# Task Organization Strategy

**Purpose:** Registry-based system for reusable commands and procedures  
**Created:** February 21, 2026  
**Status:** ✅ Implemented

---

## Solution: Two Registries + Script Dispatcher

Instead of complex folder restructuring, we use **two registries plus existing script dispatcher**:

### 1. **[COMMAND-REGISTRY.md](../.github/COMMAND-REGISTRY.md)** ✅ Already Connected
**Purpose:** Individual commands (one-liners)  
**Examples:**
- WP-CLI commands: `wp user list`, `wp plugin list`, `wp post get`
- SQL queries: `SELECT ID FROM wp_users WHERE user_login='admin'`
- Podman commands: `podman exec wp wp cache flush`

**When to use:** Need a single command for specific operation

---

### 2. **[wp-action.ps1](../.github/copilot-instructions.md#action-dispatcher-central-command-registry)** ✅ Already Connected
**Purpose:** Script dispatcher in infra/shared/scripts/  
**Examples:**
- `wp-action.ps1 backup` → backup-production.ps1
- `wp-action.ps1 verify` → verify-production.ps1
- `wp-action.ps1 restore` → restore-production.ps1
- `wp-action.ps1 apply-sql` → apply-sql-change.ps1

**When to use:** Need automation for complex/repetitive operations  
**Already documented:** See "Action Dispatcher (Central Command Registry)" section in copilot-instructions.md

---

### 3. **[TASK-REGISTRY.md](../.github/TASK-REGISTRY.md)** ✅ Now Connected
**Purpose:** Multi-step procedures and workflows  
**Examples:**
- Deploy New Release to Production (backup → deploy → verify → rollback)
- Production Cleanup Audit (audit → review → cleanup → verify)
- Apply Database Migration (create → test → commit → deploy)

**When to use:** Need step-by-step workflow for complex tasks

---

## Benefits

✅ **Simpler than folder restructuring** - No mass file moves, minimal disruption  
✅ **Faster discovery** - Check COMMAND-REGISTRY or TASK-REGISTRY, use wp-action.ps1 for scripts  
✅ **Clear categorization** - Commands vs Scripts (dispatcher) vs Tasks  
✅ **Easy maintenance** - Update registry entries, not file locations  
✅ **Cross-referenced** - Task uses wp-action.ps1 script uses Command  
✅ **Non-invasive** - Existing files stay where they are  
✅ **Already connected to context** - All three systems referenced in copilot-instructions.md

---

## Current Challenges (Resolved)

### Before: Scattered Content
- ❌ tmp/ (temporary but important files like PRODUCTION-CLEANUP-AUDIT.md)
- ❌ docs/ (60+ mixed files - hard to find what's reusable)
- ❌ No clear distinction between reusable vs one-time content

### After: Registry-Based Discovery
- ✅ Check wp-action.ps1 dispatcherd for one-liner commands
- ✅ Check SCRIPT-REGISTRY.md for automation scripts
- ✅ Check TASK-REGISTRY.md for multi-step procedures
- ✅ Everything else stays in place (reference docs, session summaries, release files)

---

## Simplified File Organization

**No folder restructuring needed!** Files stay where they are. Registries provide discovery layer.

```
wordpress/
├── .github/
│   ├── COMMAND-REGISTRY.md      # ✅ Registry 1: Individual commands (connected to context)
│   ├── TASK-REGISTRY.md         # ✅ Registry 2: Multi-step procedures (now connected to context)
│   ├── copilot-instructions.md  # References both registries + wp-action.ps1 dispatcher
│   └── releases/
│       ├── vX.Y.Z.json          # Active release metadata
│       ├── RELEASE-NOTES-vX.Y.Z.md  # Active release notes
│       └── archive/             # Completed releases
│
├── docs/
│   ├── *.md                     # Stay as is (reference docs, guides, plans)
│   ├── templates/               # File templates
│   ├── lessons/                 # Lessons learned
│   ├── features/                # Feature specifications
│   ├── patterns/                # Design patterns
│   ├── wireframes/              # Design wireframes
│   └── deprecated/              # Old/obsolete docs
│
├── infra/shared/scripts/
│   ├── wp-action.ps1            # Main dispatcher (documented in copilot-instructions.md)
│   ├── backup-production.ps1    # Called via wp-action.ps1 backup
│   ├── verify-production.ps1    # Called via wp-action.ps1 verify
│   └── ... (24 scripts total)   # All accessible via wp-action.ps1
│
├── tmp/
│   ├── DEPLOYMENT-READINESS-vX.Y.Z.md  # Release-specific (delete after deployment)
│   ├── PRODUCTION-CLEANUP-AUDIT.md     # Reusable (cataloged in TASK-REGISTRY.md)
│   └── ... (temporary working files)
│
└── restore/
    ├── pages/                   # Page backups (keep)
    ├── patterns/                # Pattern backups (keep)
    ├── forms/                   # Form exports (keep as archive) ✅ KEEP
    └── assets/                  # Asset backups (keep)

Documents/ workspace:
├── WORDPRESS-MVP-TASKS.csv/.md     # Active sprint tasks
├── WORDPRESS-BACKLOG.csv/.md       # Feature backlog
├── WORDPRESS-OPEN-ACTIONS.md       # Active issues/blockers
└── TASK-MANAGEMENT-GUIDE.md        # Task process documentation
```

---

## File Type Definitions

### 1. **Procedures** (docs/procedures/)

**What:** Reusable step-by-step operational checklists  
**When to use:** Recurring operations (cleanups, deployments, migrations)  
**Characteristics:**
- Contains commands ready to copy/paste
- Has checkboxes for tracking progress
- Can be run multiple times
- Updated when process changes

**Examples:**
- PRODUCTION-CLEANUP-AUDIT.md (run every major release)
- DISASTER-RECOVERY-RUNBOOK.md (run when issues occur)
- DATABASE-MIGRATION-PROCEDURE.md (run when schema changes)

**Update frequency:** When process changes (rare)

---

### 2. **SCRIPT-REGISTRY.md** (.github/)

**What:** Automation scripts in infra/shared/scripts/  
**When to use:** Need automated solution for complex/repetitive operations  
**Benefits:**
- Find existing scripts before writing new ones
- Understand script parameters and usage
- See related scripts for similar tasks
- Avoid creating duplicates in tmp/

**Examples:**
- backup-production.ps1: Create timestamped production backup
- verify-production.ps1: Run 18+ production health checks
- apply-sql-change.ps1: Apply database migration with safety checks
- restore-production.ps1: Restore from timestamped backup

**Entry Point:** Most scripts accessed via `wp-action.ps1` dispatcher

**Maintenance:** Update when new scripts added or parameters change

---

### 3. **TASK-REGISTRY.md** (.github/)

**What:** Multi-step procedures and workflows  
**When to use:** Need complete workflow for complex operations  
**Benefits:**
- Follow proven workflows instead of reinventing
- See prerequisites, commands, duration, frequency
- Cross-referenced to scripts and commands used
- Consistent process across team/time

**Examples:**
- Deploy New Release to Production: backup → deploy → verify → rollback
- Production Cleanup Audit: audit unused resources → review → cleanup → verify
- Apply Database Migration: create delta → test local → commit → deploy production
- Deploy WordPress Page: develop local → get approval → backup → deploy → verify

**Maintenance:** Update when workflows change or new procedures established
---

## Task Organization Workflow

### When Creating New Documentation

**Ask yourself:**

1. **"Will this be used more than once?"**
   - YES → procedures/ or templates/
   - NO → tmp/ (temporary) or release-specific

2. **"Does it contain commands to execute?"**
   - YES → procedures/ or guides/
   - NO → reference/ or sessions/

3. **"Is it tied to a specific release?"**
   - YES → .github/releases/ or tmp/
   - NO → docs/procedures/ or docs/reference/

4. **"Is it a historical record?"**
   - YES → sessions/ or lessons/ or deprecated/
   - NO → Active location based on type

### Examples

**Scenario 1:** Creating production cleanup audit steps
- Reusable? YES (every major release)
- Commands? YES (many WP-CLI commands)
- Release-specific? NO (generic procedure)
- Historical? NO
- **Location:** docs/procedures/PRODUCTION-CLEANUP-AUDIT.md

**Scenario 2:** Creating v3.6.3 deployment checklist
- Reusable? NO (specific to v3.6.3)
- Commands? YES (exact file IDs, versions)
- Release-specific? YES (v3.6.3)
- Historical? Becomes historical after deployment
- **Location:** tmp/DEPLOYMENT-READINESS-v3.6.3.md → docs/deprecated/ after deployment

**Scenario 3:** Documenting backup strategy
- Reusable? YES (applies to all backups)
- Commands? NO (explains concepts)
- Release-specific? NO (generic strategy)
- Historical? NO
- **Location:** docs/reference/BACKUP-STRATEGY.md

**Scenario 4:** Recording today's work
- Reusable? NO (one-time session)
- Commands? NO (narrative)
- Release-specific? NO (may span releases)
- Historical? YES (after session ends)
- **Location:** docs/sessions/SESSION-SUMMARY-FEB-21.md

---

## Maintenance Schedule

### Daily
- Update WORDPRESS-MVP-TASKS.csv with completed tasks
- Update WORDPRESS-OPEN-ACTIONS.md with new blockers/resolutions

### Weekly
- Review tmp/ folder, delete obsolete files
- Update active release files (.github/releases/vX.Y.Z.json)

### After Each Session
- Create session summary in docs/sessions/
- Update task CSVs with progress

### After Each Release
- Archive release files to .github/releases/archive/
- Move/delete release-specific checklists from tmp/
- Update VERSION-HISTORY.md
- Create next release files after scope discussion

### Monthly
- Review docs/ for outdated files → move to deprecated/
- Update procedures/ if processes changed
- Review backlog, adjust priorities

### Quarterly
- Audit all documentation for accuracy
- CDecision Tree: Where to Document

### When Creating New Reusable Content

```
Is it a single command (one-liner)?
├─ YES → Add to COMMAND-REGISTRY.md
└─ NO → Is it an automation script?
    ├─ YES → Add script to infra/shared/scripts/ + register in SCRIPT-REGISTRY.md
    └─ NO → Is it a multi-step procedure?wp-action.ps1
        ├─ YES → Add procedure to TASK-REGISTRY.md
        └─ NO → It's reference content, stays in docs/ (no registry needed)
```

### Examples

**Scenario 1:** Need command to list all users
- Single command? YES
- **Action:** Add to COMMAND-REGISTRY.md under "User Management" section

**Scenario 2:** Created script to backup production
- Single command? NO
- Automation script? YES
- **Action:** Save to infra/shared/scripts/, register in SCRIPT-REGISTRY.md
wp-action.ps1, document usage in copilot-instructions.md if neede
**Scenario 3:** Documenting production cleanup workflow
- Single command? NO
- Automation script? NO
- Multi-step procedure? YES
- **Action:** Add to TASK-REGISTRY.md with overview, commands, duration, frequency

**Scenario 4:** Explaining backup strategy philosophy
- Single command? NO
- Automation script? NO
- Multi-step procedure? NO
- **Action:** Create/update docs/BACKUP-STRATEGY.md (no registry needed)

**Scenario 5:** Creating v3.6.3 deployment checklist
- Single command? NO
- Automation script? NO
- Multi-step procedure? NO (release-specific, one-time use)
- **Action:** Create in tmp/, delete after deployment (no registry needed))

**To docs/reference/:**
- DEPLOYMENT-WORKFLOW.md
- BACKUP-STRATEGY.md
- SYNC-STRATEGY.md
- ID-MANAGEMENT-STRATEGY.md
- DESIGN-SYSTEM.md

**To docs/guides/:**
- BACKUP-RESTORE-QUICKSTART.md
- QUICK-REFERENCE-DEPLOYMENT.md
- PAGE-UPDATE-WORKFLOW.md
- LOCAL-SSL-SETUP.md
- QUICK-DEPLOY-v3.5.1.md (or deprecate if obsolete)

**To docs/sessions/:**
- All SESSION-SUMMARY-*.md files

**To docs/deprecated/:**
- DEPLOYMENT-INSTRUCTIONS-v3.5.1.md (obsolete)
- DEPLOYMENT-INSTRUCTIONS-UPDATE-JAN-21.md (obsolete)
- POST-MORTEM-V3.6.0-DEPLOYMENT-GAPS.md (historical)
- v3.4.0-RELEASE-SUMMARY.md (historical)
- EMERGENCY-FIX-MANUAL.md (if obsolete)
- TOMORROW-FEB-17-CHECKLIST.md (obsolete)
- TOMORROW-FEB-18-CHECKLIST.md (obsolete)

### Phase 3: Update References

After moving files, update references in:
- .github/copilot-instructions.md (update file path references)
- README.md (if it references moved files)
- Other docs that link to moved files

### Phase 4: Clean tmp/

Move/delete after v3.6.3 deployment:
- DEPLOYMENT-READINESS-v3.6.3.md → docs/deprecated/ (or delete)
- PRODUCTION-CLEANUP-AUDIT.md → docs/procedures/

---

## Benefits

1. **Faster file discovery** - Clear naming and location conventions
2. **Reduced clutter** - tmp/ stays clean, docs/ organized by purpose
3. **Better maintenance** - Clear update schedules per file type
4. **Reusability** - Procedures can be run multiple times confidently
5. **Historical record** - Sessions and lessons preserved separately
6. **Clearer lifecycle** - Know when to archive, update, or delete files

---

## Open Questions

1. Should session summaries older than 3 months be archived to separate folder?
2. Should we version procedures/ files (e.g., PRODUCTION-CLEANUP-AUDIT-v2.md)?
3. Should tmp/ have subdirectories (tmp/releases/, tmp/work/) or stay flat?
4. Should procedures/ have a naming convention (e.g., PROC-001-cleanup-audit.md)?

---

## Next Steps

**For v3.6.3 deployment:**
1. Move PRODUCTION-CLEANUP-AUDIT.md to docs/procedures/ (after deployment)
2. Archive DEPLOYMENT-READINESS-v3.6.3.md to docs/deprecated/ (after deployment)
3. Create SESSION-SUMMARY-FEB-21.md in docs/sessions/ (end of day)

**For long-term:**
1. Get user approval on proposed structure
2. Execute Phase 1-4 implementation
3. Update .github/copilot-instructions.md with new structure
4. Add procedures/README.md explaining when to create new procedures
Status

### ✅ Phase 1: Create Registries (COMPLETE)
- ✅ COMMAND-REGISTRY.md already existed (356 lines)
- ✅ SCRIPT-REGISTRY.md created (catalogs 24 scripts)
- ✅ TASK-REGISTRY.md created (catalogs 15+ procedures)

### Phase 2: Update References (Next Steps)

**Update .github/copilot-instructions.md:**
- Add references to all 3 registries
- Update "Command Registry" section to mention SCRIPT-REGISTRY and TASK-REGISTRY
- Add decision tree for when to check which registry

**Usage Pattern:**
```powershell
# Before writing any command/script/procedure, check:
1. COMMAND-REGISTRY.md - Does this command already exist?
2. SCRIPT-REGISTRY.md - Does a script already do this?
3. TASK-REGISTRY.md - Is there a procedure I should follow?
```

### Phase 3: Cleanup After v3.6.3 Deployment

**tmp/ folder:**
- Keep PRODUCTION-CLEANUP-AUDIT.md (reusable procedure - cataloged in TASK-REGISTRY)
- Delete DEPLOYMENT-READINESS-v3.6.3.md (release-specific, one-time use)

**No file moves needed** - registries provide discovery layer on top of existing structure