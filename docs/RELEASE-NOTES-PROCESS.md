# Release Notes Process & Workflow

**Purpose:** Standardized approach to tracking manual deployment steps and maintaining deployment history.

**Related Documentation:**
- [Deployment Workflow](DEPLOYMENT-WORKFLOW.md) - Complete deployment process and lessons learned
- [ID Management Strategy](ID-MANAGEMENT-STRATEGY.md) - Slug-based ID lookups for cross-environment deployments
- [Quick Reference](QUICK-REFERENCE-DEPLOYMENT.md) - Command cheat sheet

---

## File Structure

```
docs/
├── RELEASE-NOTES-NEXT.md           # Active: Next planned release
└── RELEASE-NOTES-PROCESS.md        # This file: Process documentation

.github/releases/
├── README.md                       # Archive index
├── v3.2.0.json                     # Active: Machine-readable next release
└── archive/
    ├── v3.1.0.json                 # Historical: Archived JSON
    ├── RELEASE-NOTES-20251230-1500.md
    └── RELEASE-NOTES-20260115-0930.md
```

---

## The Three-File System

### 1. `RELEASE-NOTES-NEXT.md` (Living Document)

**Purpose:** Working document for the next production release

**Lifecycle:**
- ✏️ Updated continuously during development
- 📝 Refined before release
- 📦 Archived after deployment
- 🔄 Reset to template for next release

**Who Updates:** Developers and DevOps during feature development

**Content:**
- Manual deployment steps
- Database migrations
- Configuration changes
- Verification checklists
- Rollback procedures

---

### 2. `RELEASE-NOTES-{yyyymmdd-HHmm}.md` (Historical Archive)

**Purpose:** Permanent record of completed deployments

**Created:** Immediately after successful production deployment

**Naming Convention:**
- Format: `RELEASE-NOTES-{yyyymmdd-HHmm}.md`
- Example: `RELEASE-NOTES-20251230-1500.md` = December 30, 2025 at 3:00 PM
- Time: Deployment completion time (not start time)

**Content:**
- ✅ Finalized deployment steps (what was actually done)
- ✅ Deployment metadata (who, when, duration)
- ✅ Issues encountered and resolutions
- ✅ Verification results
- ⚠️ Post-deployment notes

**Who Creates:** DevOps/Release Manager after deployment

**Never Modified:** Once archived, these files are read-only (historical record)

---

### 3. `RELEASE-NOTES-PROCESS.md` (This File)

**Purpose:** Process documentation and best practices

**Updated:** When release process changes

**Content:**
- Workflow documentation
- Naming conventions
- Best practices
- Process evaluation

---

## Workflow: Release Lifecycle

### Phase 1: Development (Days/Weeks)

**Document:** `RELEASE-NOTES-NEXT.md`

```bash
# Developer makes changes requiring manual steps
1. Code feature that needs database migration
2. Add migration steps to RELEASE-NOTES-NEXT.md
3. Add verification steps
4. Commit both code and release notes
```

**Key Actions:**
- Add each manual step as work progresses
- Include SQL scripts, WP Admin actions, config changes
- Document verification queries
- Update rollback procedures

**Team Collaboration:**
- Multiple developers can contribute
- DevOps reviews for completeness
- QA adds test scenarios

---

### Phase 2: Pre-Release (Hours Before)

**Document:** `RELEASE-NOTES-NEXT.md`

```bash
# Final review and preparation
1. Review all manual steps for accuracy
2. Test entire deployment locally (dry run)
3. Update timing estimates
4. Confirm all prerequisites met
5. Get team sign-off
```

**Checklist:**
- [ ] All database deltas tested locally
- [ ] SQL scripts syntax-checked
- [ ] Manual steps have clear instructions
- [ ] Verification queries prepared
- [ ] Rollback plan documented
- [ ] Team notified of deployment window

---

### Phase 3: Deployment (Minutes)

**Document:** `RELEASE-NOTES-NEXT.md` (being executed)

```bash
# Execute deployment
1. Follow RELEASE-NOTES-NEXT.md step-by-step
2. Document actual execution time for each step
3. Note any deviations from plan
4. Run all verification checks
5. Record deployment completion time
```

**During Deployment:**
- ✍️ Mark steps as completed
- ⏱️ Track actual duration vs estimates
- 📝 Note any issues or deviations
- ✅ Run verification after each major step

---

### Phase 4: Post-Deployment (Immediately After)

**Documents:** Archive both JSON and MD files, create next version

**⚠️ IMPORTANT:** Archive files are created ONLY after production deployment completes.

#### Step 1: Archive Human-Readable Release Notes

```bash
# Archive this release (DO THIS AFTER DEPLOYMENT, NOT BEFORE)
cp docs/RELEASE-NOTES-NEXT.md .github/releases/archive/RELEASE-NOTES-$(date +%Y%m%d-%H%M).md

# Example: 
cp docs/RELEASE-NOTES-NEXT.md .github/releases/archive/RELEASE-NOTES-20251230-1500.md
```

**Update Archived Copy:**
1. Add deployment metadata:
   ```markdown
   ## Deployment History
   - Deployed by: John Doe
   - Deployment start: 2025-12-30 14:45
   - Deployment complete: 2025-12-30 15:00
   - Status: ✅ Success
   - Issues: None
   ```

2. Mark any steps that were skipped or modified

3. Add post-deployment observations

#### Step 2: Archive Machine-Readable Release JSON

```bash
# Move JSON to archive (e.g., for v3.1.0)
mv .github/releases/v3.1.0.json .github/releases/archive/v3.1.0.json

# Or on Windows PowerShell:
Move-Item .github/releases/v3.1.0.json .github/releases/archive/v3.1.0.json
```

**Why move instead of copy?**
- Prevents GitHub Actions from reading archived releases
- Keeps active releases/ folder clean
- GitHub Actions uses `find -maxdepth 1` to exclude archive/

#### Step 3: Create Next Version Files

```bash
# Create next version JSON (e.g., v3.2.0)
cp .github/releases/archive/v3.1.0.json .github/releases/v3.2.0.json

# Edit v3.2.0.json:
# - Update version number
# - Clear description and changelog
# - Reset steps to placeholders
# - Update elementor_manifest_version if needed
```

```bash
# Reset RELEASE-NOTES-NEXT.md
cp docs/templates/RELEASE-NOTES-TEMPLATE.md docs/RELEASE-NOTES-NEXT.md

# Update target version:
# - Release Version: v3.2.0
# - Target Release Date: TBD
```

#### Step 4: Update Related References

**Update manifest version:**
- Edit `infra/shared/elementor-manifest.json`
- Change `version` field to match next release (e.g., "3.2.0")

**Commit archive:**
```bash
git add .github/releases/archive/v3.1.0.json
git add .github/releases/archive/RELEASE-NOTES-20251230-1500.md
git add .github/releases/v3.2.0.json
git add docs/RELEASE-NOTES-NEXT.md
git add infra/shared/elementor-manifest.json
git commit -m "Archive v3.1.0 release, prepare v3.2.0"
git push origin main
```

---

## Release Frequency Strategy

**Adopted:** January 26, 2026  
**Philosophy:** Small, frequent releases over large, infrequent ones

### Target Cadence

**Frequency:** Every 3-5 days with 2-4 completed tasks  
**Working Hours:** 2 hours/day (1 calendar day = 2 hours work)

**Benefits:**
- ✅ Keeps scope manageable and testable
- ✅ Faster feedback from production environment
- ✅ Easier rollback if issues arise
- ✅ Maintains project momentum
- ✅ Reduces risk of deployment conflicts
- ✅ Enables iterative improvements

### Release Composition Guidelines

#### Minimum Requirements for a Release:
1. **At least one deployable code change** (plugin update, theme change, etc.)
   - OR: Critical documentation that changes operational procedures
2. **Clear, testable acceptance criteria**
3. **Documented rollback procedure**
4. **Verification steps defined**

#### Optimal Release Scope:

**Small Release (3-5 days):**
- 1-2 code changes
- Supporting documentation
- Single feature area (e.g., security, forms, UI)

**Example - v3.5.0 (Security Focus):**
```
✅ PENG-053: Block /wp-admin/ (code change)
📄 BMSL-001: Role Capabilities Matrix (documentation)
📄 PENG-001: CandidateID Strategy (documentation)
📄 COPS-001: CV Lifecycle Policy (documentation)
```

**Medium Release (5-7 days):**
- 2-4 code changes
- Related feature set
- Multiple interconnected tasks

#### Release Grouping Strategies:

**Strategy 1: Security Bundle**
- Group related security tasks together
- Example: PENG-053 (wp-admin block) + PENG-054 (endpoint hardening)

**Strategy 2: Policy Complete**
- Group all policy/documentation tasks
- Example: COPS-002 + PMAS-001 + BMSL-002

**Strategy 3: Feature Vertical**
- Complete one user journey end-to-end
- Example: Registration form + validation + email + dashboard display

**Strategy 4: Technical Foundations**
- Infrastructure and tooling improvements
- Example: Database schema + helper functions + test fixtures

### What NOT to Include in One Release:

❌ **Avoid:**
- Mixing unrelated features (e.g., security + forms + email in one release)
- Incomplete feature implementations (no half-done work)
- Tasks still in progress or blocked
- Database changes without tested rollback
- More than 5-7 discrete changes at once

### Release Naming Convention:

**Semantic Versioning:** MAJOR.MINOR.PATCH (e.g., 3.5.0)

**Increment Rules:**
- **MAJOR (3.x.x):** Breaking changes, major architecture shifts
- **MINOR (x.5.x):** New features, enhancements, non-breaking changes
- **PATCH (x.x.1):** Bug fixes, small corrections, documentation updates

**For MVP Development (v3.x.x):**
- Use MINOR version for all feature releases
- Reserve PATCH for production hotfixes only
- MAJOR version reserved for major milestones (v4.0.0 = post-MVP features)

---

## Process Evaluation

### ✅ Benefits of This Approach

**1. Living Documentation**
- Release notes evolve with development
- No scrambling to write docs before deployment
- Reduces forgotten manual steps

**2. Historical Audit Trail**
- Complete record of all production changes
- Troubleshooting reference ("What changed on Dec 30?")
- Compliance and accountability

**3. Knowledge Transfer**
- New team members can review past deployments
- Patterns emerge (common steps, recurring issues)
- Institutional knowledge preserved

**4. Process Improvement**
- Compare estimated vs actual deployment times
- Identify bottlenecks in deployment process
- Refine rollback procedures based on experience

**5. Reduced Risk**
- Checklist reduces human error
- Pre-tested steps increase confidence
- Rollback procedures readily available

---

### ⚠️ Potential Challenges

**1. Maintenance Overhead**
- Requires discipline to update during development
- Can be forgotten if not part of PR checklist
- Risk of documentation drift

**Mitigation:**
- Make RELEASE-NOTES-NEXT.md updates required in PR template
- Code review includes release notes review
- Automated checks (CI/CD) for missing manual steps

**2. Archive Bloat**
- Many archived files over time
- Search becomes harder

**Mitigation:**
- Annual archive consolidation (move old files to yearly folders)
- Clear naming convention aids searchability
- Index file (`releases/README.md`) provides quick reference

**3. Synchronization Issues**
- RELEASE-NOTES-NEXT.md may diverge from actual code
- Features get removed but notes remain

**Mitigation:**
- Review release notes during sprint planning
- Clean up notes for abandoned features
- Link notes to specific commits/PRs

---

### 🔄 Process Improvements

**Future Enhancements:**

1. **Automated Archiving**
   ```bash
   # Post-deployment script
   ./scripts/archive-release-notes.sh
   ```

2. **Release Notes Linting**
   - CI/CD check for required sections
   - Validate SQL syntax in migration scripts
   - Ensure verification queries present

3. **Integration with Issue Tracker**
   - Link manual steps to Jira/GitHub issues
   - Automatic generation from issue labels

4. **Deployment Automation**
   - Parse RELEASE-NOTES-NEXT.md for automation opportunities
   - Generate deployment scripts from manual steps
   - Reduce manual intervention over time

5. **Metrics Tracking**
   - Track deployment frequency
   - Measure deployment duration trends
   - Monitor rollback rate

---

## Best Practices

### Writing Good Release Notes

**DO:**
- ✅ Be specific and actionable
- ✅ Include exact commands to run
- ✅ Provide verification queries
- ✅ Document why each step is needed
- ✅ Include rollback steps
- ✅ Link to related documentation

**DON'T:**
- ❌ Use vague instructions ("update database")
- ❌ Skip verification steps
- ❌ Assume prior knowledge
- ❌ Forget to update after testing reveals issues
- ❌ Mix multiple releases in one document

---

### Example: Good vs Bad Release Notes

**❌ Bad:**
```markdown
## Deployment Steps
1. Update database
2. Activate plugins
3. Test site
```

**✅ Good:**
```markdown
## Deployment Steps

### 2. Database Migration (Manual - 5 minutes)

**Action:** Execute Elementor schema delta

**Via phpMyAdmin:**
1. Login: https://hpanel.hostinger.com/databases/phpmyadmin
2. Select database: `u909075950_GD9QX`
3. Click **SQL** tab
4. Paste content from: `infra/shared/db/251230-2030-enable-elementor-blocksy.sql`
5. Click **Go** button

**Expected Result:**
- ✅ Table created: `wp_e_events`
- ✅ 26 new options in wp_options

**Verification:**
```sql
-- Check table exists
SHOW TABLES LIKE 'wp_e_events';

-- Count Elementor options (should be 14)
SELECT COUNT(*) FROM wp_options WHERE option_name LIKE 'elementor%';
```

**Troubleshooting:**
- If "table already exists" → Safe to proceed (idempotent)
- If syntax error → Check MySQL version (requires 5.7+)
```

---

## Templates

### RELEASE-NOTES-NEXT.md Template

See: [RELEASE-NOTES-NEXT.md](RELEASE-NOTES-NEXT.md) (current template)

### Archived Release Template

After deployment, add this section to the archived copy:

```markdown
---

## DEPLOYMENT RECORD

**Deployed by:** [Name]  
**Deployment start:** [YYYY-MM-DD HH:MM timezone]  
**Deployment complete:** [YYYY-MM-DD HH:MM timezone]  
**Duration:** [X minutes]  
**Status:** ✅ Success / ⚠️ Partial / ❌ Rollback

### Actual Steps Performed

- [X] Step 1: Completed successfully
- [X] Step 2: Modified (explain why)
- [ ] Step 3: Skipped (explain why)

### Issues Encountered

1. **Issue:** Brief description
   - **Resolution:** How it was resolved
   - **Time Impact:** +5 minutes

### Post-Deployment Notes

Any observations, lessons learned, or future improvements.

---
```

---

## Common Mistakes to Avoid

### ❌ DO NOT Create Ad-Hoc Deployment Summary Files

**Wrong:**
```bash
# Creating standalone deployment summary files outside the established workflow
docs/DEPLOYMENT-SUMMARY-JAN-3-2026.md
docs/DEPLOYMENT-NOTES.md
docs/RELEASE-SUMMARY.md
```

**Why Wrong:**
- Violates established three-file system
- Creates confusion about source of truth
- Requires manual cleanup
- Breaks historical archive pattern

**Correct Approach:**
```bash
# ALWAYS follow the three-file system:
1. Work in: docs/RELEASE-NOTES-NEXT.md (during development/deployment)
2. Archive to: .github/releases/archive/RELEASE-NOTES-{yyyymmdd-HHmm}.md (after deployment)
3. Reference: docs/RELEASE-NOTES-PROCESS.md (this file)
```

**Lesson Learned (2026-01-03):**
- AI assistant created `DEPLOYMENT-SUMMARY-JAN-3-2026.md` in docs/ instead of following release notes process
- Required manual deletion and recreation in proper location
- **Remember:** The workflow exists for consistency - follow it even when it seems easier to create a quick summary file

### ✅ Always Use the Established Workflow

1. **During deployment:** Update RELEASE-NOTES-NEXT.md with actual steps
2. **After deployment:** Copy to releases/ with timestamp
3. **Never:** Create standalone summary/notes files in docs/ root

---

## Version History

| Date | Change | Author |
|------|--------|--------|
| 2025-12-30 | Initial process documentation | System |
| 2026-01-03 | Added "Common Mistakes to Avoid" section | System |

---

## Related Documentation

- [RELEASE-NOTES-NEXT.md](RELEASE-NOTES-NEXT.md) - Active release notes
- [releases/](releases/) - Historical archive
- [WORDPRESS-DATABASE.md](../Documents/WORDPRESS-DATABASE.md) - Database management
- [WORDPRESS-DEPLOYMENT.md](../Documents/WORDPRESS-DEPLOYMENT.md) - Deployment guide

---

**Conclusion:** This three-file system provides a structured, maintainable approach to deployment documentation that balances real-time collaboration with historical record-keeping. The process is designed to reduce deployment risk while maintaining institutional knowledge.
