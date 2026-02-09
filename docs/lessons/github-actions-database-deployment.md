# Lesson: GitHub Actions Unintentional Database Deployment

**Date:** February 9, 2026  
**Context:** Production database was being completely reset on every Git push to main branch  
**Severity:** CRITICAL - Complete data loss on every deployment

---

## Problem

Every Git push to `main` branch triggered complete WordPress database reset:
- All themes reverted to `twentytwentyfive` (default)
- All plugins deactivated
- All pages deleted (except WordPress defaults)
- All menus deleted
- All customizer settings lost
- Homepage reset to blog mode

Emergency restoration required after each deployment (~30 seconds recovery time).

---

## Root Cause

**GitHub Actions workflow bug in `.github/workflows/deploy.yml`:**

```yaml
# Line 195 - WRONG: Uploads ALL SQL files regardless of release config
- name: Upload and Execute Database Changes
  uses: appleboy/scp-action@v0.1.7
  with:
    source: "infra/shared/db/*.sql"  # ❌ Wildcard uploads everything
    target: "~/db-deploy/"

# Lines 211-215 - Executes ALL uploaded files
for sql_file in ~/db-deploy/*.sql; do
  wp db query < "$sql_file"  # ❌ Runs 000000-0000-init-db.sql
done
```

**The fatal file: `infra/shared/db/000000-0000-init-db.sql`**
- Contains `DROP TABLE IF EXISTS` for all WordPress core tables
- Designed for LOCAL development (ephemeral database strategy)
- Should NEVER run on production
- Workflow uploaded it regardless of empty `sql_files: []` in release JSON

**Workflow logic error:**
1. Release JSON had `"sql_files": []` (empty - no database changes)
2. Workflow checked for `deploy_database` step existence (not empty array)
3. Set `database_deployed=true` even when no files specified
4. Uploaded ALL `*.sql` files (not just those in array)
5. Executed all files in alphabetical order
6. `000000-0000-init-db.sql` ran first → complete database wipe

---

## Investigation Journey

**Initial symptoms:**
- Browser redirect to `:8080` (301 cache)
- Styling broken (parent theme active)
- Menu missing
- Homepage showing blog

**False leads:**
- Hostinger Git deployment (no Git repo found on server)
- `.cpanel.yml` hooks (file doesn't exist)
- Post-receive hooks (not found)
- LiteSpeed cache corruption (cache inactive)
- Automated backups with restore (not configured)

**Breakthrough:**
- Checked `gh run list` - saw workflow running on every push
- Examined workflow code - found wildcard upload
- Confirmed `000000-0000-init-db.sql` contains DROP TABLE statements
- Pattern: Database reset happened EXACTLY after each Git push

**Timeline:**
- 6 pushes during session
- 3 confirmed database resets observed
- Likely all 6 pushes caused resets

---

## Solution

**Modified `.github/workflows/deploy.yml`:**

```yaml
- name: Deploy Database Changes
  run: |
    # Extract SQL files from release config
    jq -r '.steps[] | select(.type == "deploy_database") | .config.sql_files[]' "$RELEASE_FILE" > db_files.txt
    
    # ✅ NEW: Check if any SQL files are actually specified
    if [ ! -s db_files.txt ]; then
      echo "No SQL files specified in release config - skipping database deployment"
      exit 0
    fi

- name: Upload Database Changes
  run: |
    mkdir -p db-staging
    
    # ✅ NEW: Copy ONLY files listed in db_files.txt
    while IFS= read -r sql_file; do
      if [ -f "$sql_file" ]; then
        cp "$sql_file" db-staging/
      fi
    done < db_files.txt

- name: Upload Staged Database Files to Production
  uses: appleboy/scp-action@v0.1.7
  with:
    source: "db-staging/*.sql"  # ✅ Only staged files, not entire directory
```

**Key changes:**
1. Exit early if `sql_files` array is empty
2. Stage files explicitly listed in release config
3. Upload staged directory (not wildcard from source)
4. Never upload `000000-0000-init-db.sql` unless explicitly requested

---

## Verification

**Test deployment after fix:**
```bash
git push origin main
# Wait 60 seconds for deployment

# Check database state
wp theme list --status=active  # ✓ blocksy-child (not default)
wp plugin list --status=active  # ✓ 1 active
wp option get show_on_front     # ✓ page (not posts)
wp menu list                    # ✓ 1 menu exists
wp menu item list 2             # ✓ 4 items (Welcome, Register, Help, Login)
```

**Result:** ✅ Database intact, all content preserved

---

## Prevention for Future

**Release configuration pattern:**

```json
{
  "steps": [
    {
      "type": "deploy_database",
      "config": {
        "sql_files": []  // ✅ Explicitly empty - no database changes
      },
      "description": "No database changes in this release"
    }
  ]
}
```

**When database changes ARE needed:**

```json
{
  "steps": [
    {
      "type": "deploy_database",
      "config": {
        "sql_files": [
          "infra/shared/db/260209-1430-add-new-column.sql",
          "infra/shared/db/260209-1445-update-roles.sql"
        ]
      },
      "description": "Add new column and update roles"
    }
  ]
}
```

**Never include:**
- `000000-0000-init-db.sql` (drops all tables)
- Full database dumps
- Files with `TRUNCATE` or `DELETE FROM` for core tables

---

## Key Takeaways

1. **Wildcard uploads are dangerous** - Always explicitly list files for production deployment
2. **Test configuration logic** - Empty array should mean "skip", not "deploy everything"
3. **Separate dev and prod SQL** - Init files belong in `infra/dev/`, not `infra/shared/`
4. **Monitor deployments** - Use `gh run list` to track what actually runs
5. **Emergency procedures work** - Automated recovery script saved hours of manual work
6. **Database changes require explicit opt-in** - Default should be NO database deployment

---

## Related Files

- **Workflow:** `.github/workflows/deploy.yml`
- **Release config:** `.github/releases/v3.*.json`
- **Emergency recovery:** `infra/shared/scripts/emergency-fix-production.ps1`
- **Init file:** `infra/shared/db/000000-0000-init-db.sql` (should move to `infra/dev/`)

---

## Impact

**Before fix:**
- Development workflow broken
- Every code change required manual recovery
- 3+ emergency script executions in one session
- Database content not persistent

**After fix:**
- Safe to push code changes
- Database preserved across deployments
- Normal development workflow restored
- Menu creation successful and persistent
