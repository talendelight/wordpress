# Copilot Instructions

## Rules

1. **Always request review before modifying files** - propose changes, don't implement them automatically
2. **Never make assumptions** - ask for clarification when requirements are ambiguous
3. **Pattern usage is mandatory** - see [Pattern Usage Rules](#pattern-usage-rules) below
4. **Page updates follow structured workflow** - see [Page Update & Deployment Workflow](#page-update--deployment-workflow) below
5. **Always return to develop branch after deployment** - After pushing to main, immediately switch back to develop branch
6. **Update task tracking on completion/scope change** - When tasks complete, work ends, or scope changes:
   - ✅ Update WORDPRESS-MVP-TASKS.csv (change status, dates, estimates)
   - ✅ Update WORDPRESS-MVP-TASKS.md (sync with CSV)
   - ✅ Update WORDPRESS-BACKLOG.md (when moving items to/from active work)
   - ✅ Update/close GitHub issues (mark done, add completion notes)
   - ✅ Update docs/PROJECT-TIMELINE.md (if milestones/dates/progress affected)
   - ✅ Update docs/FUNCTIONAL-TEST-CASES.md (update test status when features implemented/tested)
   - ⚠️ Ask user about updating: VERSION-HISTORY.md, feature docs (WP-*.md), SESSION-SUMMARY-*.md, OPEN-ACTIONS.md
   - 🗑️ Delete docs/ELEMENTOR-TO-GUTENBERG-MIGRATION.md after migration complete (PENG-070)
7. **ALWAYS check references before running commands:**
   - ✅ Check [Container Names](#container-names) - NEVER run `podman ps` or container discovery commands
   - ✅ Check [COMMAND-REGISTRY.md](COMMAND-REGISTRY.md) - Find proven commands for user management, database queries, backups, etc.
   - ✅ Check [Critical Patterns](COMMAND-REGISTRY.md#critical-patterns) - Use `--skip-plugins`, `-Encoding utf8`, avoid `2>$null` on Windows
   - ❌ DO NOT reinvent commands - if similar operation exists in registry, use it
   - ❌ DO NOT run discovery commands when references exist

## Known Issues & Solutions

### PowerShell Execution Policy Error

If user encounters `PSSecurityException: UnauthorizedAccess` error when running PowerShell scripts, suggest this one-time fix:

1. Open PowerShell as Administrator
2. Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine`
3. Confirm with `Y`, then re-run and confirm with `A`

This is a Windows security restriction and requires manual Administrator access. Cannot be automated.

### Hostinger Production Environment

See [docs/HOSTINGER.md](docs/HOSTINGER.md) for complete production environment details including:
- SSH access configuration and connection examples
- Database server details and management URLs
- FTP access information
- WordPress root paths and directory structure
- GitHub Actions secrets configuration

## Project Overview

This is a WordPress 6.9.0 (PHP 8.3) development environment managed via Podman Compose for local development, with production deployment to Hostinger via Git integration.

**Directory Structure:**
- **[infra/dev/](infra/dev/)** - Podman Compose config for local development environment
- **[infra/shared/scripts/](infra/shared/scripts/)** - Reusable automation scripts (backup, restore, verify, deployment)
- **[wp-content/](wp-content/)** - WordPress content (plugins, themes, uploads) - root level for Hostinger deployment
- **[config/](config/)** - Dev-specific configurations (wp-config.php, .htaccess, PHP settings)
- **[docs/](docs/)** - Project documentation (DATABASE, DEPLOYMENT, SECURITY, VERSION-HISTORY guides)
- **[tmp/](tmp/)** - Temporary working directory (not tracked in git, clean regularly)
- **[restore/](restore/)** - Backup storage (backups/, pages/, assets/)

**Version Management:**
- See [docs/VERSION-HISTORY.md](docs/VERSION-HISTORY.md) for complete version history and semantic versioning approach
- Current production version: v3.1.0 (deployed January 9, 2026)
- Current development version: v3.2.0 (Operators Dashboard Phase 1 - January 13-14, 2026)
- When asked about next release version, always read VERSION-HISTORY.md first

**Session Continuity:**
- Always check [docs/SESSION-SUMMARY-*.md](docs/) files for recent work context
- Current active session: [docs/SESSION-SUMMARY-JAN-23.md](docs/SESSION-SUMMARY-JAN-23.md) - Task management restructuring + MVP requirements
- Previous sessions: [JAN-18](docs/SESSION-SUMMARY-JAN-18.md), [JAN-13-14](docs/SESSION-SUMMARY-JAN-13-14.md), [JAN-11](docs/SESSION-SUMMARY-JAN-11.md)
- If user mentions laptop restart or lost context, read latest session summary first
- Progress tracking in [docs/COMPLIANCE-IMPLEMENTATION-GUIDE.md](docs/COMPLIANCE-IMPLEMENTATION-GUIDE.md)

**Task Management:**
- **Master Guide:** [TASK-MANAGEMENT-GUIDE.md](../../Documents/TASK-MANAGEMENT-GUIDE.md) - Complete task naming, estimation, workflow strategy
- **Current Execution:** [WORDPRESS-MVP-TASKS.csv](../../Documents/WORDPRESS-MVP-TASKS.csv) + [.md](../../Documents/WORDPRESS-MVP-TASKS.md) - Phase 0-4 tasks with dependencies
- **Future Features:** [WORDPRESS-BACKLOG.csv](../../Documents/WORDPRESS-BACKLOG.csv) - Feature-level, decompose to tasks when moved to active phase
- **Strategic View:** [WORDPRESS-BACKLOG.md](../../Documents/WORDPRESS-BACKLOG.md) - Comprehensive roadmap with all epics
- **MVP Requirements:** [WORDPRESS-MVP-REQUIREMENTS.md](../../Documents/WORDPRESS-MVP-REQUIREMENTS.md) - Detailed registration/approval workflows
- **ALWAYS reference TASK-MANAGEMENT-GUIDE.md before creating, estimating, or organizing tasks**

**Team & Working Constraints:**
- **Manager (user):** Technical & functional lead, 2 hours/day (1 calendar day = 2 hours work)
- **External contractors:** Lawyer (LFTC-002 GDPR), Accountant (financial tasks)
- **Future team:** Part-time assistant (Q2 2026), developer/designer for pre-launch polish
- **AI Tools:** GitHub Copilot for pair programming
- **Estimation:** Always use calendar days (not hours) to account for 2hrs/day constraint

**MVP Scope (v3.6.0 - April 5, 2026):**
- Registration workflows: Candidate, Employer, Scout, Employee (with consent)
- Approval logic: Public users (Operator OR Manager), Internal users (Manager ONLY)
- CV submission with consent (Scout/Operator/Manager)
- Employer request with consent (Operator/Manager)
- Company email provisioning (@talendelight.com → @hireaccord.com)
- 12 email notification templates (registration, assignment, approval, rejection)
- Rebrand: TalenDelight → HireAccord before public launch
- See [WORDPRESS-MVP-REQUIREMENTS.md](../../Documents/WORDPRESS-MVP-REQUIREMENTS.md) for complete workflows

**Deployment Strategy:**
- **Development**: Docker/Podman containers on local machine
- **Production**: Hostinger shared hosting with Git auto-deployment on push to `main` branch
- **Disaster Recovery**: Automated backup/restore system - see [DISASTER-RECOVERY-PLAN.md](docs/DISASTER-RECOVERY-PLAN.md)

**Key plugins**: WooCommerce, Elementor, Blocksy Companion, WPForms Lite, Akismet  
**Active theme**: Blocksy (primary)

## Container Names

**⚠️ ALWAYS use these container names - DO NOT run discovery commands**

- **`wp`** - WordPress 6.9.1 container (PHP 8.3, Apache)
- **`wp-db`** - MariaDB 12.2.2 database container
- **`wp-phpmyadmin`** - phpMyAdmin web interface (rarely used)

**Container access patterns:**
```powershell
# WordPress container (WP-CLI, PHP)
podman exec wp <command>
podman exec wp wp <wp-cli-command> --allow-root --skip-plugins

# Database container (SQL queries)
podman exec wp-db mariadb -u root -ppassword wordpress -e "<sql-query>"

# Interactive shell
podman exec -it wp bash
podman exec -it wp-db bash
```

## Common Commands Registry

**⚠️ ALWAYS check [COMMAND-REGISTRY.md](COMMAND-REGISTRY.md) before running commands**

**Complete command reference:** [.github/COMMAND-REGISTRY.md](COMMAND-REGISTRY.md)

The registry contains proven commands for:
- **User Management** - List, create, reset passwords, check existence
- **Database Queries** - Pages, plugins, roles, migrations, backups
- **WordPress Operations** - Plugins, themes, cache, permalinks, versions
- **Backup & Restore** - Production backups, verification, health checks
- **Page Management** - Export, get IDs, list pages
- **Container Management** - Start, stop, restart, reset, logs
- **Debugging** - PHP version, errors, connections, permissions

**Critical Patterns** (see [COMMAND-REGISTRY.md](COMMAND-REGISTRY.md) for details):
- ✅ Always use `--allow-root --skip-plugins` for wp-cli commands
- ✅ Use `-Encoding utf8` in PowerShell `Out-File` to prevent corruption
- ❌ NEVER use `2>$null` on Windows (creates C:\dev\null file)
- ❌ NEVER reinvent commands - check registry first

## Action Dispatcher (Central Command Registry)

**Use `wp-action.ps1` as the main entry point for all WordPress operations:**

```powershell
# Main dispatcher - maps actions to implementation scripts
pwsh infra/shared/scripts/wp-action.ps1 <action> [arguments]

# Available actions:
# - backup           → backup-production.ps1 (create timestamped backup)
# - verify           → verify-production.ps1 (check production state)
# - restore          → restore-production.ps1 (restore from backup)
# - export-elementor → export-elementor-pages.ps1 (export Elementor pages)
# - health-check     → verify-production-health.php (comprehensive health check)
# - apply-sql        → apply-sql-change.ps1 (apply SQL migration to local DB)
# - deploy           → show deployment workflow
# - help             → show help for any action

# Examples:
pwsh infra/shared/scripts/wp-action.ps1 backup
pwsh infra/shared/scripts/wp-action.ps1 verify
pwsh infra/shared/scripts/wp-action.ps1 health-check -Verbose
pwsh infra/shared/scripts/wp-action.ps1 apply-sql -SqlFilePath infra/shared/db/260131-1200-add-record-id-prsn-cmpy.sql
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
pwsh infra/shared/scripts/wp-action.ps1 help backup
```

**Why use wp-action.ps1:**
- ✅ Single entry point for all operations
- ✅ Consistent interface across all scripts
- ✅ Built-in help system
- ✅ Action registry prevents script name confusion
- ✅ Forwards all arguments to underlying scripts

**Critical Rules:**
- ❌ **DO NOT call scripts directly** - always use wp-action.ps1 unless debugging specific script
- ❌ **DO NOT create ad-hoc scripts in /tmp** - check wp-action.ps1 registry FIRST for existing scripts
- ❌ **DO NOT reinvent commands** - if similar operation exists in registry, use it
- ✅ **DO check registry before scripting:** `powershell infra\shared\scripts\wp-action.ps1 help` to see all available actions
- ✅ **DO add reusable scripts to registry** - move from /tmp to infra/shared/scripts/ and register in wp-action.ps1

## Page Update & Deployment Workflow

**⚠️ CRITICAL: All WordPress page updates must follow this workflow to prevent content corruption**

### Standard Process

1. **Develop in Local Environment**
   - Make all changes at https://wp.local/
   - Never edit production pages directly
   - Test thoroughly (buttons, links, styling, hover states)

2. **User Review & Approval**
   - User tests page in local
   - Get explicit confirmation: "This looks good, proceed to production"
   - Do NOT deploy without approval

3. **Create/Update Backup**
   ```powershell
   # Backup local page to restore/pages/
   podman exec wp bash -c "wp post get <LOCAL_ID> --field=post_content --allow-root 2>/dev/null" | Out-File -Encoding utf8 restore\pages\<page-name>-<LOCAL_ID>.html
   
   # Verify backup (should be >10KB, >200 lines for typical landing page)
   Get-Item restore\pages\<page-name>-<LOCAL_ID>.html | Select-Object Name, Length
   ```

4. **Deploy Complete Page to Production**
   ```powershell
   # Use PHP script method (NEVER use wp-cli stdin)
   scp -P 65002 -i "tmp\hostinger_deploy_key" "restore\pages\<page-name>-<LOCAL_ID>.html" u909075950@45.84.205.129:/tmp/candidates-local.html
   
   scp -P 65002 -i "tmp\hostinger_deploy_key" "tmp\restore-page-<PROD_ID>.php" u909075950@45.84.205.129:/home/u909075950/domains/talendelight.com/public_html/
   
   ssh -p 65002 -i "tmp\hostinger_deploy_key" u909075950@45.84.205.129 "cd /home/u909075950/domains/talendelight.com/public_html && php restore-page-<PROD_ID>.php && rm restore-page-<PROD_ID>.php && wp cache flush"
   ```

5. **Verify Deployment**
   - Check line count matches local (±5 lines acceptable)
   - Visual inspection on production URL
   - Test buttons and hover states
   - Verify footer elements

### Critical Rules

**✅ DO:**
- ✅ Always develop in local first
- ✅ Get user approval before production deployment
- ✅ Use complete page replacement (not partial updates)
- ✅ Use PHP scripts for page content updates (see restore-page-7.php template)
- ✅ Use `-Encoding utf8` in PowerShell
- ✅ Keep backups in restore/pages/

**❌ DON'T:**
- ❌ Never make changes directly in production
- ❌ Never use `wp post update --post_content=-` with stdin (causes corruption)
- ❌ Never use bash `echo` or `cat` pipes for large HTML
- ❌ Never deploy without user approval
- ❌ Never skip backup creation
- ❌ Never use partial page updates or sed replacements

**See [docs/PAGE-UPDATE-WORKFLOW.md](docs/PAGE-UPDATE-WORKFLOW.md) for complete workflow documentation**

**DO NOT call scripts directly** - always use wp-action.ps1 unless debugging specific script

## Pattern Usage Rules

**⚠️ CRITICAL: Always use actual pattern code as template when creating new pages**

**The Problem:** Pattern comments alone (e.g., `<!-- Pattern: blocksy-child/card-grid-3 -->`) are not enough. Writing HTML from memory causes missing styling attributes and design inconsistency.

**Mandatory Workflow:**

1. ✅ **Read the pattern file FIRST**
   ```bash
   cat wp-content/themes/blocksy-child/patterns/card-grid-3.php
   ```

2. ✅ **Copy the EXACT HTML structure** from the pattern file

3. ✅ **Modify ONLY content** (headings, paragraphs, button text, icons)

4. ✅ **Keep ALL styling attributes intact:**
   - `"border":{"radius":"12px"}` → Rounded corners
   - `"className":"is-style-card"` → Card styling
   - `"padding":{"top":"var:preset|spacing|48",...}` → Consistent spacing
   - `"dimensions":{"minHeight":"100%"}` → Equal card heights
   - `margin-top:0;margin-bottom:0` → Zero-gap layout

5. ✅ **Verify styling** before committing:
   ```bash
   grep "border-radius:12px" restore/pages/your-page.html
   grep "is-style-card" restore/pages/your-page.html
   ```

**Never Do This:**
- ❌ Write markup from memory
- ❌ Assume you know the structure
- ❌ Add pattern comment without using pattern code
- ❌ Skip reading the pattern file

**Available Patterns:** See [wp-content/themes/blocksy-child/patterns/](wp-content/themes/blocksy-child/patterns/)
- `card-grid-3.php` - 3 cards in single row
- `card-grid-2-2.php` - 2x2 grid (4 cards)
- `card-grid-3+1.php` - 3 cards + 1 centered
- `hero-single-cta.php` - Hero sections
- `cta-primary.php` - CTA sections
- `footer-trust-badges.php` - Footer badges

**Full Lesson:** See [docs/lessons/pattern-usage-consistency.md](docs/lessons/pattern-usage-consistency.md) for detailed explanation with before/after examples.

## 
## Critical Developer Workflows

### Starting the Development Environment

```bash
cd infra/dev
podman-compose up -d
```

Services exposed:
- WordPress: https://wp.local
- phpMyAdmin: http://localhost:8180  
- MariaDB: localhost:3306

### Database Management

- **Ephemeral database strategy**: Database resets to clean state on every fresh startup
- **Source of truth**: ALL SQL files in [infra/shared/db/](infra/shared/db/) combined (not just 000000-0000-init-db.sql alone)
  - [infra/shared/db/000000-0000-init-db.sql](infra/shared/db/000000-0000-init-db.sql) - Baseline WordPress schema
  - Delta files: `{yymmdd}-{HHmm}-{action}-{short.desc}.sql` - Incremental changes applied on top of baseline
  - Action verbs: add, update, remove, alter, insert, migrate, fix, enable, disable
  - **Combined baseline** = init file + all delta files applied sequentially
- Uses Podman named volume (destroyed with `podman-compose down -v`)
- To reset database: `podman-compose down -v && podman-compose up -d`
- See [WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md) for complete database workflow guide

**Database Comparison Rule**: When comparing current database state with "previous baseline", the baseline is the COMBINED state of ALL SQL files in `infra/shared/db/` (000000-0000-init-db.sql + all deltas), not just the init file alone.

**Delta File Creation Rules**:
- ✅ Delta files MUST contain ONLY incremental changes, NOT full exports
- ❌ NEVER include `DROP TABLE IF EXISTS` for existing tables in deltas
- ❌ NEVER include `CREATE TABLE` for tables that exist in baseline
- ✅ Use `TRUNCATE TABLE` + `INSERT` pattern for updating entire table data (e.g., wp_options)
- ✅ Use `ALTER TABLE` for schema modifications
- ✅ Use `INSERT INTO` for new records, `UPDATE` for modifications
- ✅ Extract only changed data sections from mysqldump exports, not entire database

### Using WP-CLI

All wp-cli commands must run inside the WordPress container:

```bash
podman exec -it wordpress wp plugin list
podman exec -it wordpress wp theme list --format=json
podman exec -it wordpress wp user create newuser email@example.com --role=editor
```

### File Upload Limits

PHP upload limits configured in [config/uploads.ini](config/uploads.ini):
- `upload_max_filesize = 64M`
- `post_max_size = 128M`
- `max_execution_time = 600`
- `memory_limit = 128M`

Changes require container restart: `podman-compose restart wordpress`

## Project-Specific Patterns

### Configuration Overlay Pattern

WordPress core files stay in the container. Only specific configs are mounted from host:
- [config/wp-config.php](config/wp-config.php) - uses `getenv_docker()` helper to read container env vars
- [config/.htaccess](config/.htaccess) - custom rewrite rules
- [config/uploads.ini](config/uploads.ini) - PHP upload/execution limits
- Sets `FS_METHOD = 'direct'` to allow direct plugin installation without FTP

**Why**: Keeps host filesystem lean while allowing config versioning and easy environment-specific overrides.

### Volume Mount Strategy

Dev compose mounts `wp-content/` from repository root into container:
- ✅ Plugin/theme changes persist and are version-controlled
- ✅ Uploads directory accessible from host (but excluded from git)
- ✅ Direct edit in IDE, instant reflection in container
- ❌ WordPress core files not directly editable from host (intentional)

### Git Deployment Strategy

Repository root contains only `wp-content/` for production deployment:
- Hostinger's Git integr & Disaster Recovery

### Standard Deployment Workflow

**CRITICAL: Always follow this sequence:**

```powershell
# 1. BACKUP (MANDATORY - before deployment)
pwsh infra/shared/scripts/wp-action.ps1 backup

# 2. DEPLOY (push to production)
git checkout main && git merge develop --no-edit && git push origin main
# Wait 30 seconds for Hostinger auto-deployment

# 3. VERIFY (MANDATORY - after deployment)
pwsh infra/shared/scripts/wp-action.ps1 verify

# 4. RESTORE (if verification fails)
pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages $true
```

### Disaster Recovery System

**When production has issues (pages missing, site broken):**

1. **Immediate Response**: See [DISASTER-RECOVERY-PLAN.md](docs/DISASTER-RECOVERY-PLAN.md) for incident-specific procedures
2. **Quick Restore**: Use [BACKUP-RESTORE-QUICKSTART.md](docs/BACKUP-RESTORE-QUICKSTART.md) for fast recovery
3. **Command Reference**: [QUICK-REFERENCE-DEPLOYMENT.md](docs/QUICK-REFERENCE-DEPLOYMENT.md) for copy-paste commands

**Available Recovery Scripts:**
- `backup-production.ps1` - Create timestamped backup (pages, options, theme, patterns, database)
- `verify-production.ps1` - Check production state (18+ validation checks)
- `restore-production.ps1` - Restore from any backup timestamp

**Backup Schedule:**
- Before every deployment (MANDATORY)
- Daily at 02:00 UTC (automated via Task Scheduler)
- Weekly with database (Sunday 02:00 UTC)
- Retention: Last 10 backups (configurable)

### Production Detailsation monitors `main` branch
- Auto-deploys `wp-content/` to `public_html/wp-content/` on push
- Excludes dev-only files via [.hostingerignore](.hostingerignore): `infra/`, `docs/`, `config/`, `tmp/`, `.github/`
- Hostinger manages WordPress core, `wp-config.php`, and server configuration
- Database changes require manual import via phpMyAdmin (future automation planned)

## Integration Points & Dependencies

- **MariaDB** - accessed via service name `wp-db` from within Podman network
- **phpMyAdmin** - pre-configured with `PMA_HOST: wp-db` (http://localhost:8180)
- All services use default Podman network created by compose (auto DNS resolution)
- External DB access: `mysql -h 127.0.0.1 -P 3306 -u root -ppassword wordpress`
- Database credentials: root/password (dev only)

## Database Philosophy

- Development uses **ephemeral databases** - always starts fresh from [infra/shared/db/000000-0000-init-db.sql](infra/shared/db/000000-0000-init-db.sql)
- Database changes are tracked as version-controlled SQL files, not live data
- To persist work across sessions: `podman-compose stop` (without `-v`)
- To reset completely: `podman-compose down -v && podman-compose up -d`
- **Schema parity rule**: Local database schema MUST match production exactly (including Hostinger plugin tables)
- **Content separation**: Local uses test data, production has real data - content is NEVER synced
- Production uses Hostinger's managed MySQL database
- See [docs/SYNC-STRATEGY.md](docs/SYNC-STRATEGY.md) for complete local/production sync approach

## When Working with Plugins/Themes

- Review [infra/dev/reports/plugins-themes-report.md](infra/dev/reports/plugins-themes-report.md) for compatibility notes
- Elementor and WooCommerce have large codebases - test thoroughly after PHP/WP version changes
- Blocksy Companion contains Freemius SDK - be aware of potential telemetry calls
- Test all changes locally before pushing to `main` branch (triggers production deployment)

## Production Deployment

- **Hosting**: Hostinger shared hosting (not containers)
- **Deployment method**: Git auto-deployment via Hostinger's built-in Git integration
- **Trigger**: Push to `main` branch
- **What deploys**: `wp-content/` directory only (themes, plugins, mu-plugins)
- **What doesn't deploy**: WordPress core (Hostinger provides), dev infrastructure, docs
- See [WORDPRESS-DEPLOYMENT.md](../../Documents/WORDPRESS-DEPLOYMENT.md) for complete Hostinger Git integration guide

## Release Management & Deployment Workflows

**⚠️ CRITICAL: Always follow established workflows. Do not deviate from defined processes.**

### Required Reference Files (Read These Before Any Release Work)

**Master Workflows:**
- **[docs/DEPLOYMENT-WORKFLOW.md](docs/DEPLOYMENT-WORKFLOW.md)** - Complete deployment journey including v3.1.0 implementation details, what changed, solutions implemented, and success metrics
- **[docs/RELEASE-NOTES-PROCESS.md](docs/RELEASE-NOTES-PROCESS.md)** - Release lifecycle workflow (development → pre-release → deployment → post-deployment archiving)

**Quick References:**
- **[docs/QUICK-REFERENCE-DEPLOYMENT.md](docs/QUICK-REFERENCE-DEPLOYMENT.md)** - One-page cheat sheet with copy-paste commands for exports, deployment, verification, rollback, and archiving
- **[docs/RELEASE-INSTRUCTIONS-FORMAT.md](docs/RELEASE-INSTRUCTIONS-FORMAT.md)** - JSON schema for machine-readable release files (.github/releases/*.json)

**Templates:**
- **[docs/templates/TEMPLATE-ELEMENTOR-DEPLOYMENT.md](docs/templates/TEMPLATE-ELEMENTOR-DEPLOYMENT.md)** - Step-by-step template for Elementor page deployments
- **[docs/templates/vX.Y.Z.json](docs/templates/vX.Y.Z.json)** - Machine-readable release metadata template
- **[docs/templates/RELEASE-NOTES-vX.Y.Z.md](docs/templates/RELEASE-NOTES-vX.Y.Z.md)** - Human-readable release notes template

**Active Working Files:**
- **[docs/RELEASE-NOTES-NEXT.md](docs/RELEASE-NOTES-NEXT.md)** - Living document for next planned release (human-readable manual steps)
- **[.github/releases/vX.Y.Z.json](.github/releases/)** - Machine-readable release instructions for GitHub Actions (find latest with `find -maxdepth 1`)

**Lessons Learned:**
- **[docs/lessons/](docs/lessons/)** - All lesson files (elementor-cli-deployment.md, powershell-encoding-corruption.md, etc.)
  - Review when encountering similar challenges
  - Reference patterns and anti-patterns documented from real issues

**Project Documentation (Documents workspace):**
- **[WORDPRESS-DEPLOYMENT.md](../../Documents/WORDPRESS-DEPLOYMENT.md)** - Hostinger deployment configuration, SSH keys, Git integration
- **[WORDPRESS-DATABASE.md](../../Documents/WORDPRESS-DATABASE.md)** - Database schema, migration strategy, backup/restore procedures
- **[WORDPRESS-TECHNICAL-DESIGN.md](../../Documents/WORDPRESS-TECHNICAL-DESIGN.md)** - Architecture, plugin choices, technical decisions
- **[WORDPRESS-BUSINESS-FUNCTIONALITY.md](../../Documents/WORDPRESS-BUSINESS-FUNCTIONALITY.md)** - Business requirements, user flows, feature specifications
- **[WORDPRESS-UI-DESIGN.md](../../Documents/WORDPRESS-UI-DESIGN.md)** - Design system, component library, styling guidelines
- **[COMMON-UI-DESIGN.md](../../Documents/COMMON-UI-DESIGN.md)** - Shared UI patterns across all applications
- **[WORDPRESS-SECURITY.md](../../Documents/WORDPRESS-SECURITY.md)** - Security policies, compliance requirements, access control
- **[WORDPRESS-PAGE-SYNC-MANIFEST.md](../../Documents/WORDPRESS-PAGE-SYNC-MANIFEST.md)** - Page synchronization strategy, ID mappings
- **[WORDPRESS-OPEN-ACTIONS.md](../../Documents/WORDPRESS-OPEN-ACTIONS.md)** - Active tasks, blockers, pending decisions
- **[WORDPRESS-BACKLOG.md](../../Documents/WORDPRESS-BACKLOG.md)** - Feature backlog, prioritization, roadmap
- **[WORDPRESS-WIREFRAMES-WORKFLOW.md](../../Documents/WORDPRESS-WIREFRAMES-WORKFLOW.md)** - Design-to-development workflow
- **[PERSON-APP-BACKLOG.md](../../Documents/PERSON-APP-BACKLOG.md)** - Related person app features and integration points

**When to Reference These Files:**
- **Before development:** Check BACKLOG, BUSINESS-FUNCTIONALITY, TECHNICAL-DESIGN, UI-DESIGN
- **During development:** Reference UI-DESIGN, COMMON-UI-DESIGN, lessons/ for patterns
- **Before deployment:** Review DEPLOYMENT, PAGE-SYNC-MANIFEST, SECURITY
- **After issues:** Consult lessons/, OPEN-ACTIONS, TECHNICAL-DESIGN
- **Database changes:** Always check DATABASE for schema and migration strategy

### Deployment Workflow Summary

**1. Export Elementor Pages (Local):**
```powershell
pwsh infra/shared/scripts/export-elementor-pages.ps1
```
- Uses `podman cp` to avoid PowerShell encoding corruption
- Outputs to `tmp/elementor-exports/*.json`

**2. Deploy Code (Automated via GitHub Actions):**
```bash
git push origin main  # Triggers .github/workflows/deploy.yml
```
- GitHub Actions reads latest `.github/releases/vX.Y.Z.json`
- Deploys wp-content/ to production
- Shows manual Elementor deployment instructions

**3. Deploy Elementor Pages (Manual):**
```bash
# Follow instructions from GitHub Actions output
scp -r tmp/elementor-exports/ production:~/
ssh production "cd public_html && wp eval-file ~/elementor-exports/import-elementor-pages.php"
```
- Import script: `infra/shared/scripts/import-elementor-pages.php`
- Direct database operations (bypasses WordPress API limitations)
- Supports dry-run: `ELEMENTOR_DRY_RUN=true wp eval-file ...`

**4. Post-Deployment Verification & Updates:**
- NEVER archive immediately after deployment
- Keep active release file (vX.Y.Z.json + RELEASE-NOTES-NEXT.md) for ongoing updates
- Update release files during production testing and issue fixes
- Archive ONLY when user explicitly confirms "this release is complete"

**5. Release Completion & Next Release Planning (User Confirmation Required):**
```powershell
# ONLY after user confirms "vX.Y.Z is complete"

# 1. Archive completed release (with timestamp)
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
Move-Item .github/releases/vX.Y.Z.json .github/releases/archive/vX.Y.Z.json -Force
Move-Item .github/releases/RELEASE-NOTES-vX.Y.Z.md ".github/releases/archive/RELEASE-NOTES-vX.Y.Z-$timestamp.md" -Force

# 2. Discuss with user:
#    - What should be included in next release?
#    - Recommend version number based on scope:
#      * Patch (X.Y.Z+1): Bug fixes, minor tweaks, styling corrections
#      * Minor (X.Y+1.0): New features, non-breaking changes
#      * Major (X+1.0.0): Breaking changes, major overhaul
#    - Get user confirmation on version number

# 3. Create next release files in .github/releases/ (e.g., v3.6.4 confirmed)
# Create new .github/releases/vX.Y.Z.json (machine-readable)
# Create new .github/releases/RELEASE-NOTES-vX.Y.Z.md (human-readable)
# Both files stay in .github/releases/ until that release is complete

# 4. Commit
git add .github/releases/
git commit -m "Archive v3.6.2 (complete), prepare v3.6.3"
git push origin main
```

### Key Patterns to Remember

**✅ Always Do:**
- Read DEPLOYMENT-WORKFLOW.md before any release work
- Keep updating active release files (vX.Y.Z.json + RELEASE-NOTES-vX.Y.Z.md in .github/releases/) during planning, deployment, and production fixes
- Archive ONLY when user explicitly confirms release is complete
- Discuss next release scope and recommend version number before creating new files
- Create both vX.Y.Z.json AND RELEASE-NOTES-vX.Y.Z.md in .github/releases/ for new releases
- Use 3-part semantic versioning (X.Y.Z)

**❌ Never Do:**
- Archive immediately after deployment (keep active for updates)
- Work on multiple releases in parallel (include hotfixes in current release)
- Use 4-part version numbers (3.6.2.1) - always use 3-part semantic versioning
- Create release notes in docs/ folder (they belong in .github/releases/)
- Modify archived release files (they're historical records)
- Create next release without user confirmation and scope discussion

### File Organization

```
.github/releases/
├── v3.6.3.json                     # Active release machine-readable (keep updating until complete)
├── RELEASE-NOTES-v3.6.3.md         # Active release human-readable (keep updating until complete)
├── README.md                       # Archive documentation
└── archive/
    ├── v3.6.2.json                 # Archived completed releases
    ├── v3.6.1.json
    ├── RELEASE-NOTES-v3.6.2-20260217-1840.md  # Archived with timestamp
    └── RELEASE-NOTES-20260213-2255.md

docs/
├── DEPLOYMENT-WORKFLOW.md          # Master workflow guide
├── RELEASE-NOTES-PROCESS.md        # Release lifecycle process
├── QUICK-REFERENCE-DEPLOYMENT.md   # Quick reference commands
├── PAGE-UPDATE-WORKFLOW.md         # Page deployment workflow
├── lessons/                        # Permanent lessons learned
│   ├── css-version-cache-busting.md
│   ├── powershell-encoding-corruption.md
│   └── pattern-usage-consistency.md
└── templates/
    └── TEMPLATE-ELEMENTOR-DEPLOYMENT.md
```

**Release File Lifecycle:**
1. Create `vX.Y.Z.json` + `RELEASE-NOTES-vX.Y.Z.md` **in .github/releases/** when starting new release
2. Keep updating same files during: planning, deployment, production testing, bug fixes
3. Archive ONLY when user confirms "this release is complete"
4. Discuss scope → recommend version → get confirmation → create next release files **in .github/releases/**
5. NEVER work on multiple releases in parallel (no 4-part versions, include hotfixes in current)

infra/shared/
└── scripts/
    ├── export-elementor-pages.ps1      # Export script (PowerShell)
    └── import-elementor-pages.php      # Import script (PHP)
```

**Release File Lifecycle:**
1. Create `vX.Y.Z.json` + `RELEASE-NOTES-NEXT.md` when starting new release
2. Keep updating same files during: planning, deployment, production testing, bug fixes
3. Archive ONLY when user confirms "this release is complete"
4. Discuss scope → recommend version → get confirmation → create next release files
5. NEVER work on multiple releases in parallel (no 4-part versions, include hotfixes in current)
└── templates/
    └── TEMPLATE-ELEMENTOR-DEPLOYMENT.md

infra/shared/
└── scripts/
    ├── export-elementor-pages.ps1      # Export script (PowerShell)
    └── import-elementor-pages.php      # Import script (PHP)
```
