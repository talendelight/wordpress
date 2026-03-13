# Why Files Were Missed & How to Prevent It

**Date:** March 13, 2026  
**Issue:** 35 files modified/created but not properly committed during v3.7.4 release

---

## What Was Missed

### Committed Files (4 only - emergency fix)
✅ wp-content/themes/blocksy-child/functions.php  
✅ wp-content/themes/blocksy-child/includes/hero-template.html  
✅ wp-content/themes/blocksy-child/includes/cta-template.html  
✅ wp-content/themes/blocksy-child/includes/footer-badges.html  

### Stashed Files (24 files - NEVER REVIEWED!)
❌ .github/COMMAND-REGISTRY.md  
❌ .github/copilot-instructions.md (Rule #15!)  
❌ .github/releases/README.md  
❌ .github/releases/RELEASE-NOTES-v3.7.3.md  
❌ .github/releases/v3.7.3.json  
❌ 2 SQL migration files  
❌ 5 brand asset images (logos, favicons)  
❌ 13 page HTML files with shortcode updates  

### Untracked Files (7 files - NEVER ADDED!)
❌ docs/SHORTCODE-IMPLEMENTATION-COMPLETE.md  
❌ infra/shared/db/260313-1800-update-logo-favicon-hireaccord.sql  
❌ infra/shared/scripts/get-menu-ids.ps1  
❌ **infra/shared/scripts/update-logo-favicon.ps1** ← The reusable script you requested!  
❌ 2 additional favicon formats (android-chrome PNG files)  
❌ wp-content/themes/blocksy-child/assets/js/tab-switching.js  

---

## Why This Happened

### 1. **Tunnel Vision on Emergency**
I was laser-focused on fixing the broken shortcodes (functions.php) and lost sight of the bigger release scope.

### 2. **No Pre-Commit Checklist**
I never ran `git status --short` to see ALL modified/untracked files before committing.

### 3. **Stashing Without Review**
I stashed files to checkout `main`, then NEVER went back to review what was stashed. Those files included:
- Rule #15 I added at your request
- 13 page updates
- Brand assets
- Documentation updates

### 4. **Unclear Versioning**
The work was labeled "v3.7.4" in documentation but I never created a formal v3.7.4.json release file, so I had no master list to check against.

### 5. **Assumed Creation = Committed**
I created update-logo-favicon.ps1 and assumed it was tracked, but it was never added to git.

---

## Root Cause Analysis

**The Pattern:**
1. Work on feature (create files, modify code)
2. Emergency issue appears → tunnel vision
3. Stash "non-critical" files to fix emergency
4. Push emergency fix
5. Forget to review stashed files
6. Work on next task
7. **Result:** Files scattered across stash, untracked, uncommitted

**Missing Safety Net:**
- No systematic `git status` check before releases
- No rule requiring file review before marking complete
- No release scope document created BEFORE work begins

---

## Solution: Rule #16 (Now Added)

**New Rule in copilot-instructions.md:**

> **16. Check git status before releases and commits** - ALWAYS verify all modified/untracked files before creating releases:
> - ✅ Before creating release files: Run `git status --short` to see ALL changes
> - ✅ Review each file: Determine if it belongs in the release scope
> - ✅ Check for untracked files: New scripts, documentation, assets, SQL migrations
> - ✅ Review stashed changes: If you stashed files earlier, check what's in the stash
> - ✅ Use git diff: `git diff HEAD` shows uncommitted changes
> - ✅ Document in release JSON: List ALL modified/stashed/untracked files
> - ❌ DO NOT commit only "critical" files and leave others behind
> - ❌ DO NOT assume files are committed just because you created them

---

## How You Can Help Me

### 1. **Remind Me to Check Status**
When I finish a feature or prepare for deployment:
- Ask: "Have you checked git status?"
- Ask: "What files are untracked or stashed?"
- Ask: "Did you create any new scripts or docs?"

### 2. **Request Release Scope FIRST**
Before I start work on a release:
- Request: "Create v3.X.X.json FIRST with planned tasks and files"
- This gives me a checklist to follow

### 3. **Stop Me Before Final Commit**
When I say "ready to commit":
- Stop me: "Wait - run git status and show me the list"
- Review together before pushing

### 4. **Point Out Pattern Recognition**
If you see me:
- Creating files in tmp/ without moving them
- Creating scripts without adding to git
- Updating docs without committing
→ Remind me: "That file needs to be tracked/committed"

### 5. **Enforce Rule #16**
Reference the rule: "Per Rule #16, please check git status before proceeding"

---

## Git Commands I Should Use

### Before Any Release
```bash
# See all modified files (tracked)
git status --short

# See all untracked files
git ls-files --others --exclude-standard

# See what's in the stash
git stash list
git stash show 'stash@{0}' --name-status

# See uncommitted changes
git diff HEAD --name-status

# See what's staged
git diff --cached --name-status
```

### Release Workflow (Following Rule #16)
```bash
# 1. Check status
git status --short

# 2. Review each file
# - Is this part of the release? → Stage it
# - Is this temporary? → Add to .gitignore or delete
# - Is this unrelated? → Stash for later

# 3. Stage files systematically
git add <file1> <file2> ...

# 4. Verify staged files
git diff --cached --name-status

# 5. Commit with comprehensive message
git commit -m "Release v3.X.X: [description]

- File 1 purpose
- File 2 purpose
- etc"

# 6. Double-check nothing left behind
git status --short  # Should be clean or show only unrelated files
```

---

## Action Items

### Immediate (Your Decision Required)
1. **Review v3.7.4.json** - I created this listing ALL missed files. Confirm scope is correct.
2. **Decide on stashed files** - Should I commit them or discard?
3. **Decide on untracked files** - Which ones should be committed?

### After Your Approval
1. Unstash and commit release documentation files
2. Add and commit untracked files (script, SQL, docs, assets)
3. Update TASK-REGISTRY.md with proper procedure
4. Test git status workflow on next release

---

## Example: How Rule #16 Would Have Prevented This

**What I Did:**
```bash
# (Created update-logo-favicon.ps1)
# (Modified 13 pages)
# (Added Rule #15)
# Emergency: functions.php broken!
git add functions.php includes/
git commit -m "Emergency fix"
git push
# Done! (WRONG - 31 files left behind)
```

**What I SHOULD Have Done (Rule #16):**
```bash
# (Created update-logo-favicon.ps1)
# (Modified 13 pages)
# (Added Rule #15)

# STOP - Check status first
git status --short
# Output shows:
# M  .github/copilot-instructions.md (Rule #15!)
# M  restore/pages/candidates-21.html (page updates!)
# ?? infra/shared/scripts/update-logo-favicon.ps1 (the script!)
# ... 32 more files

# Review list with user: "I see 35 files changed. Should all be in v3.7.4?"
# Get confirmation on scope
# Stage ALL related files together
git add <all-related-files>
git commit -m "Release v3.7.4: Hero/CTA Shortcodes + Logo/Favicon Update"
# Verify nothing left behind
git status --short
# Output: clean or only unrelated files
```

---

## Lessons Learned

1. **Emergency ≠ Skip Process** - Even in emergencies, take 30 seconds to check `git status`
2. **Created ≠ Committed** - New files are untracked by default
3. **Stash ≠ Archive** - Stashed files need review and proper commits
4. **One Task ≠ One File** - Releases often touch 10-30 files; commit them together
5. **Success Message ≠ Complete** - Deployment success doesn't mean all files committed

---

## Trust Recovery

I understand this created extra work and confusion. Going forward:

✅ **I WILL** run `git status --short` before every commit  
✅ **I WILL** review stashed files before moving to next task  
✅ **I WILL** create release scope document FIRST  
✅ **I WILL** ask you to confirm file list before committing  
✅ **I WILL** follow Rule #16 on every release  

❌ **I WILL NOT** commit only "critical" files  
❌ **I WILL NOT** stash and forget  
❌ **I WILL NOT** assume files are tracked  
❌ **I WILL NOT** mark releases complete without your verification (Rule #15)  

---

**Next Steps:**
1. Please review [.github/releases/v3.7.4.json](.github/releases/v3.7.4.json)
2. Confirm which files should be committed
3. I'll commit them systematically following Rule #16
4. We'll verify together that nothing is left behind
