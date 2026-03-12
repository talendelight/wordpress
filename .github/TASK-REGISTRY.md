# WordPress Task Registry

**⚠️ CHECK HERE FOR REUSABLE PROCEDURES**

This registry catalogs multi-step operational procedures and workflows. Use this to:
- ✅ Find proven procedures before creating new ones
- ✅ Follow tested workflows for complex operations
- ✅ See related procedures for similar tasks
- ❌ Avoid reinventing established processes

**Quick Links:**
- **[COMMAND-REGISTRY.md](COMMAND-REGISTRY.md)** - Individual commands (one-liners)
- **[Action Dispatcher](copilot-instructions.md#script-dispatcher)** - wp-action.ps1 script dispatcher
- **[docs/procedures/](../docs/procedures/)** - Detailed procedure files

---

## Production Deployment Tasks

### Task: Verify Deployment Readiness (Pre-Commit)
**Environment:** 🔧 LOCAL  
**File:** [docs/procedures/DEPLOYMENT-WORKFLOW.md](../docs/procedures/DEPLOYMENT-WORKFLOW.md#pre-commit-deployment-verification)  
**Script:** [infra/shared/scripts/verify-deployment-readiness.ps1](../infra/shared/scripts/verify-deployment-readiness.ps1)  
**Frequency:** Before every commit to develop/main (every deployment)  
**Duration:** 2-5 minutes

**Overview:**
Automated analysis of git changes before committing to catch missing deployment files and prevent production issues.

1. Run verification script to analyze new/modified files
2. Review auto-deployable files (git add & push)
3. Review manual deployment requirements (pages, database, MU plugins)
4. Answer review questions (enqueuing, versioning, compatibility)
5. Update release notes with manual steps
6. Commit with deployment instructions

**Prerequisites:**
- All changes complete and tested locally
- User approval obtained for changes

**Key Commands:**
```powershell
# Run deployment verification
powershell infra/shared/scripts/verify-deployment-readiness.ps1

# Script analyzes:
# - New untracked files (git ls-files --others)
# - Modified tracked files (git diff --name-only HEAD)
# - Recent page backups (last 24 hours)

# Script categorizes as:
# - [AUTO-DEPLOY] wp-content/(mu-plugins|themes|plugins) files
# - [MANUAL] restore/pages/*.html (page content)
# - [MANUAL] restore/mu-plugins/*.php (copy first)
# - [MANUAL] infra/shared/db/*.sql (database migrations)

# After review, commit auto-deploy files:
git add wp-content/mu-plugins/td-*.php
git add wp-content/themes/blocksy-child/assets/
git commit -m "feat: description"

# Document manual steps in release notes
```

**Review Questions (script asks based on detected changes):**
- **New JavaScript files?** Are they enqueued? Version set? Page-specific?
- **New MU plugins?** Auto-activate documented? Dependencies checked?
- **Modified MU plugins?** Backward compatible? Breaking changes?
- **Page content changes?** Restore scripts ready? IDs documented?

**Exit Codes:**
- `0` = All changes auto-deployable (safe to commit)
- `1` = Manual deployment steps required (review needed)

**Related:**
- TASK: Deploy New Release to Production (next step after commit)
- TASK: Deploy WordPress Page to Production (for page deployments)
- SCRIPT-REGISTRY: wp-action.ps1 backup/verify/restore

---

### Task: Deploy New Release to Production
**Environment:** 🌐 PRODUCTION  
**File:** [docs/procedures/DEPLOYMENT-WORKFLOW.md](../docs/procedures/DEPLOYMENT-WORKFLOW.md)  
**Frequency:** Every release (weekly to monthly)  
**Duration:** 15-30 minutes

**Overview:**
1. Create production backup (mandatory)
2. Deploy code to main branch (triggers Hostinger auto-deploy)
3. Deploy pages using PHP restoration scripts
4. Deploy database migrations (if any)
5. Verify deployment (18+ checks)
6. Rollback if verification fails

**Prerequisites:**
- All changes tested in local environment
- User approval obtained
- **Pre-commit verification completed** (see TASK: Verify Deployment Readiness)
- Release files prepared (vX.Y.Z.json, RELEASE-NOTES-vX.Y.Z.md)

**Key Commands:**
```powershell
# 1. Backup
pwsh infra/shared/scripts/wp-action.ps1 backup

# 2. Deploy
git checkout main && git merge develop --no-edit && git push origin main

# 3. Verify (wait 30s for Hostinger deployment)
pwsh infra/shared/scripts/wp-action.ps1 verify

# 4. Rollback if needed
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
```

**Related:**
- **TASK: Verify Deployment Readiness (Pre-Commit)** - prerequisite step
- **TASK: Verify Production Deployment (Post-Deploy)** - mandatory verification after deployment
- SCRIPT-REGISTRY: backup-production.ps1, verify-production.ps1, restore-production.ps1
- TASK: Deploy WordPress Page to Production
- TASK: Rollback Failed Deployment

---

### Task: Verify Production Deployment (Post-Deploy)
**Environment:** 🌐 PRODUCTION  
**File:** [docs/procedures/POST-DEPLOYMENT-CHECKLIST.md](../docs/procedures/POST-DEPLOYMENT-CHECKLIST.md)  
**Script:** [infra/shared/scripts/verify-deployment.ps1](../infra/shared/scripts/verify-deployment.ps1)  
**Frequency:** After EVERY deployment to production (mandatory, no exceptions)  
**Duration:** 2-5 minutes

**Overview:**
Automated verification that compares local workspace files with production to detect deployment failures. Prevents silent failures where Hostinger Git auto-deployment doesn't deploy new files or modifications.

1. Wait 30 seconds for Hostinger auto-deployment
2. Run verify-deployment.ps1 to compare file sizes
3. If verification fails → Manual deployment via SCP
4. Clear production cache
5. Run health check (wp-action.ps1 verify)
6. Functional testing (user confirmation)

**Prerequisites:**
- Deployment completed (git push origin main executed)
- SSH access to production configured

**Key Commands:**
```powershell
# Wait for Hostinger auto-deployment
Start-Sleep -Seconds 30

# Verify all wp-content/ files deployed
powershell -File infra/shared/scripts/wp-action.ps1 verify-deployment

# If files missing → Manual deployment
scp -P 65002 -i "tmp\hostinger_deploy_key" "wp-content\mu-plugins\your-file.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/wp-content/mu-plugins/

# Clear cache
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp cache flush --allow-root"

# Health check
powershell -File infra/shared/scripts/wp-action.ps1 verify
```

**Exit Codes:**
- `0` = All files deployed successfully (production matches local)
- `1` = Deployment failure detected (missing files or size mismatch)

**Common Issues (Script Detects):**
- **Missing files** → New files not created by Hostinger Git deployment
- **Size mismatch** → Partial upload or encoding corruption
- **Outdated files** → Modified files not updated

**Manual Deployment Procedure (When Auto-Deploy Fails):**
See [POST-DEPLOYMENT-CHECKLIST.md](../docs/procedures/POST-DEPLOYMENT-CHECKLIST.md) Section: "Manual Deployment"

**Related:**
- **TASK: Deploy New Release to Production** - deployment procedure (includes this verification step)
- SCRIPT-REGISTRY: verify-deployment.ps1, backup-production.ps1, restore-production.ps1
- LESSON: ../docs/lessons/hostinger-auto-deployment-limitations.md (v3.6.4 deployment failure analysis)
- TASK: Rollback Failed Deployment

---

### Task: Deploy WordPress Page to Production
**Environment:** 🔄 BOTH (develop local, deploy to any environment)  
**Script:** [infra/shared/scripts/deploy-pages.ps1](../infra/shared/scripts/deploy-pages.ps1)  
**Frequency:** Every page update (multiple times per week)  
**Duration:** 5-10 minutes

**Overview:**
1. Develop page in local environment (https://wp.local/)
2. Get user approval after testing
3. Create/update backup in restore/pages/
4. Deploy using unified script (supports Local or Production)
5. Verify deployment (line count, visual inspection, functionality)

**Critical Rules:**
- ✅ Always develop in local first
- ✅ Get user approval before production deployment
- ✅ Use unified deploy-pages.ps1 script with -Environment parameter
- ✅ Script queries by slug (stable identifier across environments)
- ✅ Script creates pages if they don't exist
- ❌ Never create temporary scripts in tmp/ for deployments
- ❌ Never use hardcoded IDs - always query by slug
- ❌ Never deploy to production without backup

**Key Commands:**
```powershell
# 1. Backup page from local
podman exec wp bash -c "wp post get <LOCAL_ID> --field=post_content --allow-root 2>/dev/null" | Out-File -Encoding utf8 restore\pages\<page-name>-<LOCAL_ID>.html

# 2. Deploy to production (RECOMMENDED)
pwsh infra/shared/scripts/wp-action.ps1 deploy-pages -Environment Production -PageNames "privacy-policy","cookie-policy"

# Or deploy all pages to production
pwsh infra/shared/scripts/wp-action.ps1 deploy-pages -Environment Production

# Deploy to local (for testing/restoring)
pwsh infra/shared/scripts/wp-action.ps1 restore-pages -PageNames "welcome"

# Dry run to preview
pwsh infra/shared/scripts/wp-action.ps1 deploy-pages -Environment Production -DryRun

# 3. Verify
ssh -p 65002 -i "tmp/hostinger_deploy_key" u909075950@45.84.205.129 "cd domains/hireaccord.com/public_html && wp post list --post_type=page --fields=ID,post_title,post_status"
```

**How It Works:**
1. Script reads page HTML from restore/pages/ (e.g., privacy-policy-3.html)
2. Extracts slug from filename (privacy-policy)
3. Queries target environment by slug using get_page_by_path() - no ID mapping needed
4. If page exists → updates it
5. If page doesn't exist → creates it with correct slug
6. Flushes all caches automatically (environment-specific)

**Environment Support:**
- **Local**: Uses `podman exec wp` + WP-CLI commands
- **Production**: Uses SSH + remote PHP scripts (avoids encoding issues)

**Related:**
- PATTERN: Pattern Usage Rules (always read pattern file before using)
- TASK: Deploy New Release to Production
- LESSON: ../docs/lessons/powershell-encoding-corruption.md

---

### Task: Production Cleanup Audit
**Environment:** 🌐 PRODUCTION  
**File:** [docs/procedures/PRODUCTION-CLEANUP-AUDIT.md](../docs/procedures/PRODUCTION-CLEANUP-AUDIT.md)  
**Frequency:** Every major release or quarterly  
**Duration:** 30-60 minutes

**Overview:**
1. Audit unused pages (drafts, test pages, duplicates)
2. Audit unused plugins (inactive plugins)
3. Audit unused themes (keep only Blocksy + 1 default)
4. Audit orphaned forms (Forminator/WPForms tables)
5. Audit test users (delete test accounts)
6. Audit unused media files
7. Audit plugin database tables (safe to drop after plugin removal)
8. Execute cleanup (after manual review)
9. Verify site still works

**Prerequisites:**
- Production backup created (mandatory)
- Audit results reviewed by user

**Key Commands:**
```powershell
# Audit pages
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp post list --post_type=page --format=table --fields=ID,post_title,post_status,post_date"

# Audit plugins
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin list --status=inactive --format=table"

# Cleanup example (after review)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin delete forminator wpforms-lite"
```

**Related:**
- SCRIPT-REGISTRY: backup-production.ps1, verify-production.ps1
- TASK: Remove WordPress Plugin Safely
- TASK: Remove Unused WordPress Themes

---

### Task: Remove Unused WordPress Themes
**Environment:** 🔄 BOTH (via script - local or production)  
**Script:** [infra/shared/scripts/cleanup-themes.ps1](../infra/shared/scripts/cleanup-themes.ps1)  
**Frequency:** Every deployment (automated) | Manual as needed  
**Duration:** 1-2 minutes

**Overview:**
Remove unused default WordPress themes (twentytwentythree, twentytwentyfour, twentytwentyfive) that consume ~13.6 MB of disk space. This task runs automatically via GitHub Actions after code deployment but can also be executed manually.

**Environment Support:**
- 🏠 **Local:** Removes themes from Podman container
- 🌐 **Production:** Removes themes via SSH from Hostinger

**Key Commands:**
```powershell
# Dry run (preview what would be removed)
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment local -DryRun
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment production -DryRun

# Execute cleanup
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment local
powershell -File infra/shared/scripts/cleanup-themes.ps1 -Environment production
```

**Automated in CI/CD:**
- GitHub Actions workflow runs this automatically on production after code deployment
- See [.github/workflows/deploy.yml](../../.github/workflows/deploy.yml) "Clean Up Unused Themes" step

**Prerequisites:**
- For production: SSH key must exist at `tmp\hostinger_deploy_key`
- For local: Container `wp` must be running

**Related:**
- COMMAND-REGISTRY: Container Management, Cleanup & Maintenance
- TASK: Production Cleanup Audit
- WORKFLOW: GitHub Actions Deploy

---

## Disaster Recovery Tasks

### Task: Rollback Failed Deployment
**Environment:** 🌐 PRODUCTION  
**File:** [docs/procedures/DISASTER-RECOVERY-PLAN.md](../docs/procedures/DISASTER-RECOVERY-PLAN.md)  
**Frequency:** Emergency only  
**Duration:** 5-15 minutes

**Overview:**
1. Identify issue (pages missing, site broken, errors)
2. Locate latest backup (restore/backups/backup-YYYYMMDD-HHmm/)
3. Restore affected components (pages, options, database)
4. Verify restoration
5. Investigate root cause

**Quick Recovery:**
```powershell
# Restore pages from latest backup
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true

# Restore everything from latest backup
pwsh infra/shared/scripts/restore-production.ps1 -BackupTimestamp latest -RestorePages $true -RestoreOptions $true -RestoreDatabase $true
```

**Related:**
- ACTION-DISPATCHER: emergency-fix-production.ps1, restore-production.ps1, verify-production.ps1
- TASK: Deploy New Release to Production
- FILE: ../docs/procedures/BACKUP-RESTORE-QUICKSTART.md

---

### Task: Restore Production from Backup
**Environment:** 🌐 PRODUCTION  
**File:** [docs/procedures/BACKUP-RESTORE-QUICKSTART.md](../docs/procedures/BACKUP-RESTORE-QUICKSTART.md)  
**Frequency:** Emergency or testing  
**Duration:** 10-20 minutes

**Overview:**
1. List available backups
2. Select backup to restore
3. Validate backup integrity
4. Choose components to restore (pages, options, database)
5. Execute restoration
6. Verify restoration
7. Clear caches

**Key Commands:**
```powershell
# List backups
ls restore\backups\ | Sort-Object LastWriteTime -Descending

# Validate backup
ls restore\backups\backup-20260220-1430\

# Restore
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp 20260220-1430 -RestorePages $true
```

**Related:**
- ACTION-DISPATCHER: restore-production.ps1, backup-production.ps1, verify-production.ps1
- TASK: Rollback Failed Deployment

---

## Database Management Tasks

### Task: Apply Database Migration
**Environment:** 🔄 BOTH (test local, deploy to production)  
**File:** [docs/DATABASE.md](../../../Documents/WORDPRESS-DATABASE.md)  
**Frequency:** When schema changes needed  
**Duration:** 10-30 minutes

**Overview:**
1. Create delta SQL file in infra/shared/db/ (naming: YYMMDD-HHmm-<action>-<description>.sql)
2. Test in local environment (apply-sql-change.ps1)
3. Verify schema changes (compare tables, columns)
4. Commit delta file to repository
5. Deploy to production (manual import via phpMyAdmin or SSH)
6. Verify production schema matches local

**Naming Convention:**
- Format: `YYMMDD-HHmm-<action>-<short-desc>.sql`
- Actions: add, update, remove, alter, insert, migrate, fix, enable, disable
- Example: `260131-1200-add-record-id-prsn-cmpy.sql`

**Key Commands:**
```powershell
# Apply to local
pwsh infra/shared/scripts/wp-action.ps1 apply-sql -SqlFilePath infra/shared/db/260220-1500-add-new-table.sql

# Verify local
podman exec wp-db mariadb -u root -ppassword wordpress -e "SHOW TABLES LIKE 'wp_td_%'"

# Apply to production (after testing)
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp db query < /tmp/260220-1500-add-new-table.sql"
```

**Related:**
- ACTION-DISPATCHER: apply-sql-change.ps1, backup-prod-db.ps1
- FILE: ../infra/shared/db/000000-0000-init-db.sql
- FILE: WORDPRESS-DATABASE.md (Documents workspace)

---

### Task: Reset Local Database
**Environment:** 🏠 LOCAL ONLY  
**File:** [docs/procedures/ENVIRONMENT-CONFIG.md](../docs/procedures/ENVIRONMENT-CONFIG.md)  
**Frequency:** When local database corrupted or needs fresh start  
**Duration:** 2-5 minutes

**Overview:**
1. Stop containers
2. Remove database volume
3. Restart containers (auto-applies all SQL files from infra/shared/db/)
4. Verify schema matches production

**Key Commands:**
```powershell
cd infra\dev
podman-compose down -v
podman-compose up -d
```

**Note:** Database reset applies COMBINED state of ALL SQL files in infra/shared/db/ (init + all deltas)

**Related:**
- TASK: Apply Database Migration
- FILE: ../infra/shared/db/000000-0000-init-db.sql

---

## Plugin Management Tasks

### Task: Remove WordPress Plugin Safely
**Environment:** 🌐 PRODUCTION  
**File:** [docs/procedures/PRODUCTION-CLEANUP-AUDIT.md](../docs/procedures/PRODUCTION-CLEANUP-AUDIT.md)  
**Frequency:** When plugin no longer needed  
**Duration:** 5-10 minutes

**Overview:**
1. Create production backup (mandatory)
2. Export plugin data (if applicable)
3. Deactivate plugin
4. Delete plugin
5. Verify functionality not broken
6. Optionally drop plugin database tables (after backup)

**Two Methods:**

**Option A: Automated (WP-CLI)**
```powershell
ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && wp plugin deactivate <plugin-slug> && wp plugin delete <plugin-slug>"
```

**Option B: Manual (WordPress Admin)**
1. Login to https://talendelight.com/wp-admin/
2. Navigate to Plugins → Installed Plugins
3. Find plugin, click "Deactivate"
4. After deactivation, click "Delete"
5. Confirm deletion

**Related:**
- ACTION-DISPATCHER: backup-production.ps1
- TASK: Production Cleanup Audit

---

## Local Development Tasks

### Task: Start Development Environment
**Environment:** 🏠 LOCAL ONLY  
**File:** [README.md](../README.md)  
**Frequency:** Daily (start of work session)  
**Duration:** 1-2 minutes

**Overview:**
1. Navigate to infra/dev/
2. Start containers with podman-compose
3. Wait for services to be ready
4. Access WordPress at https://wp.local/

**Key Commands:**
```powershell
cd infra\dev
podman-compose up -d

# Verify containers running
podman ps

# Check WordPress ready
curl -k https://wp.local
```

**Related:**
- TASK: Reset Local Database
- FILE: ../docs/LOCAL-SSL-SETUP.md

---

### Task: Stop Development Environment
**Environment:** 🏠 LOCAL ONLY  
**File:** [README.md](../README.md)  
**Frequency:** End of work session (optional)  
**Duration:** 30 seconds

**Overview:**
1. Stop containers (preserves database)
2. Or stop and remove volumes (fresh start next time)

**Key Commands:**
```powershell
# Stop and preserve database
cd infra\dev
podman-compose stop

# Stop and reset database (fresh start)
cd infra\dev
podman-compose down -v
```

**Related:**
- TASK: Start Development Environment
- TASK: Reset Local Database

---

### Task: Restore Page Content to Local
**Environment:** 🏠 LOCAL ONLY  
**File:** [docs/procedures/DATABASE-RESTORATION.md](../docs/procedures/DATABASE-RESTORATION.md)  
**Script:** [infra/shared/scripts/restore-all-pages.ps1](../infra/shared/scripts/restore-all-pages.ps1)  
**Frequency:** After database reset or fresh container start  
**Duration:** 1-2 minutes

**Overview:**
Restores all WordPress page content from backups to local environment. Maps pages by slug (not ID) since IDs differ between local and production.

1. Run restore script to restore 13 pages from backups
2. Script uploads HTML content to container
3. Script updates each page via wp-cli
4. Cache is flushed automatically

**Key Commands:**
```powershell
# Via action dispatcher (recommended)
pwsh infra/shared/scripts/wp-action.ps1 restore-pages

# Direct script execution
pwsh infra/shared/scripts/restore-all-pages.ps1

# Verify pages restored
podman exec wp wp post list --post_type=page --post_status=publish --format=table --allow-root --skip-plugins
```

**Pages Restored:**
- Welcome, Help, Privacy Policy
- Role landing pages: Candidates, Employers, Scouts, Managers, Operators
- Manager dashboards: Manager Admin (/admin), Manager Actions (/actions)
- Registration: Register Profile, Select Role
- Error pages: 403 Forbidden

**Prerequisites:**
- Containers running (wp, wp-db)
- Database initialized with all migrations
- Backup files exist in restore/pages/

**Common Issues:**
- ❌ "Page not found in database" → Run SQL migrations first (init-all-migrations.sh)
- ❌ "Backup not found" → Check restore/pages/ directory has HTML files
- ❌ "Page looks incorrect" → Check if page uses custom template (see [docs/PAGE-TEMPLATES.md](../docs/PAGE-TEMPLATES.md))

**Related:**
- TASK: Reset Local Database (run migrations first)
- TASK: Restore Menus to Local (run after restoring pages)
- SCRIPT-REGISTRY: wp-action.ps1 restore-pages

---

### Task: Restore Menus to Local
**Environment:** 🏠 LOCAL ONLY  
**File:** [docs/procedures/DATABASE-RESTORATION.md](../docs/procedures/DATABASE-RESTORATION.md)  
**Script:** [infra/shared/scripts/restore-menus.ps1](../infra/shared/scripts/restore-menus.ps1)  
**Frequency:** After database reset or fresh container start  
**Duration:** 30 seconds

**Overview:**
Restores WordPress navigation menu structure from production. Creates Primary Menu with 6 items and assigns to all theme locations.

1. Run restore script to create menu
2. Script adds 6 menu items via wp-cli
3. Script assigns menu to theme locations
4. Cache is flushed automatically

**Key Commands:**
```powershell
# Via action dispatcher (recommended)
pwsh infra/shared/scripts/wp-action.ps1 restore-menus

# Direct script execution
pwsh infra/shared/scripts/restore-menus.ps1

# Verify menu restored
podman exec wp wp menu list --allow-root --skip-plugins
podman exec wp wp menu item list primary-menu --allow-root --skip-plugins
```

**Menu Structure:**
- **Primary Menu** (assigned to: footer, menu_1, menu_2, menu_mobile)
  1. Welcome (/)
  2. Register (/select-role/)
  3. Profile (/profile/)
  4. Help (/help/)
  5. Login (/log-in/)
  6. Logout (logout action)

**Prerequisites:**
- Containers running (wp, wp-db)
- WordPress core initialized
- Pages exist in database (run restore-pages first)

**Common Issues:**
- ❌ Menu items link to missing pages → Run restore-pages first
- ⚠️ Menu doesn't display on frontend → Check theme location assignments

**Related:**
- TASK: Restore Page Content to Local (run before restoring menus)
- TASK: Reset Local Database (full database restoration workflow)
- SCRIPT-REGISTRY: wp-action.ps1 restore-menus

---

## Verification Tasks

### Task: Verify Production Health
**Environment:** 🌐 PRODUCTION  
**File:** [docs/procedures/QUICK-REFERENCE-DEPLOYMENT.md](../docs/procedures/QUICK-REFERENCE-DEPLOYMENT.md)  
**Frequency:** After every deployment or weekly  
**Duration:** 2-5 minutes

**Overview:**
1. Run verify-production.ps1 (18+ checks)
2. Optionally run verify-production-health.php (comprehensive health check)
3. Review results (all should be ✅)
4. Investigate any ❌ failures

**Key Commands:**
```powershell
# Quick verification
pwsh infra/shared/scripts/wp-action.ps1 verify

# Comprehensive health check
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
```

**Related:**
- ACTION-DISPATCHER: verify-production.ps1, verify-production-health.php, verify-security.php
- TASK: Deploy New Release to Production

---

## Pattern Usage Tasks

### Task: Use Pattern in New Page
**Environment:** 🏠 LOCAL ONLY  
**File:** [.github/copilot-instructions.md](../PATTERN-USAGE-RULES) (Pattern Usage Rules section)  
**Frequency:** Every new page or page update  
**Duration:** 5-10 minutes

**Overview:**
1. Read pattern file FIRST (wp-content/themes/blocksy-child/patterns/<pattern-name>.php)
2. Copy EXACT HTML structure from pattern file
3. Modify ONLY content (headings, paragraphs, button text, icons)
4. Keep ALL styling attributes intact
5. Verify styling before committing

**Critical Rules:**
- ❌ Never write markup from memory
- ❌ Never assume you know the structure
- ✅ Always read pattern file before using
- ✅ Keep all CSS classes, inline styles, data attributes

**Available Patterns:**
- card-grid-3.php - 3 cards in single row
- card-grid-2-2.php - 2x2 grid (4 cards)
- card-grid-3+1.php - 3 cards + 1 centered
- hero-single-cta.php - Hero sections
- cta-primary.php - CTA sections
- footer-trust-badges.php - Footer badges

**Related:**
- LESSON: ../docs/lessons/pattern-usage-consistency.md
- FILE: ../wp-content/themes/blocksy-child/patterns/
- TASK: Deploy WordPress Page to Production

---

## Release Management Tasks

### Task: Prepare New Release
**Environment:** 🔄 BOTH (development local, archive/plan for deployment)  
**File:** [docs/RELEASE-NOTES-PROCESS.md](../docs/RELEASE-NOTES-PROCESS.md)  
**Frequency:** When starting new release (weekly to monthly)  
**Duration:** 30-60 minutes

**Overview:**
1. Archive completed release (vX.Y.Z.json → archive/)
2. Discuss next release scope with user
3. Recommend version number (patch/minor/major)
4. Get user confirmation on version
5. Create vX.Y.Z.json in .github/releases/
6. Create RELEASE-NOTES-vX.Y.Z.md in .github/releases/
7. Keep updating both files throughout release lifecycle
8. Archive ONLY when user confirms "release complete"

**Version Number Rules:**
- Patch (X.Y.Z+1): Bug fixes, styling tweaks, minor corrections
- Minor (X.Y+1.0): New features, non-breaking changes
- Major (X+1.0.0): Breaking changes, major overhaul

**Key Commands:**
```powershell
# Archive completed release (after user confirmation)
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
Move-Item .github/releases/vX.Y.Z.json .github/releases/archive/vX.Y.Z.json -Force
Move-Item .github/releases/RELEASE-NOTES-vX.Y.Z.md ".github/releases/archive/RELEASE-NOTES-vX.Y.Z-$timestamp.md" -Force

# Create next release files (after scope discussion)
Copy-Item docs/templates/vX.Y.Z.json .github/releases/v3.6.3.json
Copy-Item docs/templates/RELEASE-NOTES-vX.Y.Z.md .github/releases/RELEASE-NOTES-v3.6.3.md
```

**Related:**
- FILE: ../docs/templates/vX.Y.Z.json
- FILE: ../docs/templates/RELEASE-NOTES-vX.Y.Z.md
- TASK: Deploy New Release to Production

---

### Task: Update Release Files During Development
**Environment:** 🔄 BOTH (local work, files tracked for deployment)  
**File:** [docs/RELEASE-NOTES-PROCESS.md](../docs/RELEASE-NOTES-PROCESS.md)  
**Frequency:** Throughout release lifecycle (multiple times per day)  
**Duration:** 5-15 minutes per update

**Overview:**
1. Keep active release files in .github/releases/ (vX.Y.Z.json + RELEASE-NOTES-vX.Y.Z.md)
2. Update both files during: planning, development, deployment, production testing, bug fixes
3. Never archive during active release
4. Archive ONLY when user confirms "this release is complete"

**What to Update:**
- pages section: New/modified pages with changes list
- code section: MU plugins, theme changes, breaking changes
- assets section: New icons, images, CSS files
- deployment section: Commands, manual steps, verification
- issues_addressed: Bugs fixed, improvements made
- future_work: Items deferred to next release

**Related:**
- FILE: .github/releases/vX.Y.Z.json (active release)
- FILE: .github/releases/RELEASE-NOTES-vX.Y.Z.md (active release)
- TASK: Prepare New Release

---

### Task: Migrate WordPress Site to New Domain (Hostinger)
**Environment:** 🌐 PRODUCTION  
**Frequency:** Rarely (domain changes, rebrand)  
**Duration:** 30-45 minutes  

**Overview:**  
Complete WordPress site migration from one domain to another on Hostinger shared hosting.

**High-Level Steps:**
1. Upload backup files (tar.gz + sql.gz) to server
2. Extract and sync files to new domain (exclude wp-config.php)
3. Import database with target credentials
4. URL search-replace (old → new domain, typically 100-150 replacements)
5. Update WordPress site URLs (siteurl, home, blogname)
6. Disable persistent object cache + remove LiteSpeed rules
7. Clear all WordPress caches
8. **🚨 CRITICAL: Purge CDN cache via hPanel** (most common failure point)

**⚠️ Common Issue:**  
Hostinger CDN caches old domain content for 7 days. Must manually purge via hPanel → Performance → CDN → Flush Cache.

**Related:**
- **GUIDE:** [DOMAIN-MIGRATION-HOSTINGER.md](../docs/procedures/DOMAIN-MIGRATION-HOSTINGER.md) - Complete 15-step procedure
- **LESSON:** [hostinger-cdn-cache-migration.md](../docs/lessons/hostinger-cdn-cache-migration.md) - Troubleshooting and root cause
- **COMMANDS:** Domain Migration & Cache Management section in COMMAND-REGISTRY.md

---

## Task Categories Summary

### Daily Tasks
- ✅ Start Development Environment
- ✅ Deploy WordPress Page to Production (as needed)
- ✅ Update Release Files During Development

### Weekly Tasks
- ✅ Verify Production Health
- ✅ Deploy New Release to Production

### Monthly/Quarterly Tasks
- ✅ Production Cleanup Audit
- ✅ Prepare New Release (when previous complete)

### Emergency Tasks
- 🚨 Rollback Failed Deployment
- 🚨 Restore Production from Backup

### As-Needed Tasks
- Apply Database Migration (when schema changes)
- Remove WordPress Plugin Safely (when plugin no longer needed)
- Reset Local Database (when corrupted)
- Use Pattern in New Page (every page creation)

---

## Adding New Tasks/Procedures

When documenting a new reusable procedure:

1. **Determine location:**
   - Complex/detailed → Create standalone file in docs/procedures/
   - Simple/quick → Document inline in this registry

2. **Include these sections:**
   - Overview (what it does, why it matters)
   - Frequency (how often used)
   - Duration (expected time)
   - Prerequisites (what's needed before starting)
   - Key Commands (copy/paste ready)
   - Related (links to scripts, commands, other tasks)

3. **Update this registry** with new task entry

4. **Cross-reference:**
   - Link from Action Dispatcher (wp-action.ps1) if task uses specific scripts
   - Link from COMMAND-REGISTRY.md if task uses specific commands
   - Reference in .github/copilot-instructions.md if critical workflow

---

## See Also

- **[COMMAND-REGISTRY.md](COMMAND-REGISTRY.md)** - Individual WP-CLI and SQL commands
- **[Action Dispatcher](copilot-instructions.md#script-dispatcher)** - wp-action.ps1 script dispatcher
- **[docs/procedures/DEPLOYMENT-WORKFLOW.md](../docs/procedures/DEPLOYMENT-WORKFLOW.md)** - Master deployment workflow
- **[docs/procedures/DISASTER-RECOVERY-PLAN.md](../docs/procedures/DISASTER-RECOVERY-PLAN.md)** - Emergency procedures
- **[docs/procedures/PAGE-UPDATE-WORKFLOW.md](../docs/procedures/PAGE-UPDATE-WORKFLOW.md)** - Page deployment workflow
