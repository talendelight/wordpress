# Backup and Data Protection Strategy

**Last Updated:** February 5, 2026  
**Status:** Critical - Implement Immediately

---

## What Went Wrong (February 5, 2026 Incident)

### Root Causes of Data Loss

1. **Ephemeral local database** - Used `podman-compose down -v` without backup
2. **No Elementor exports** - Pages built locally but never exported
3. **Production never populated** - Content never deployed to production
4. **No automated backups** - Manual process that was skipped
5. **Empty SQL init file** - Baseline didn't include actual content

### Data Lost

- All custom pages (Managers, Operators, Candidates, Employers, Scouts, etc.)
- All Elementor page designs
- All Forminator forms
- All test data and configurations

---

## Prevention Strategy

### 1. Local Development Database Backups

#### Automated Daily Backups

Create `infra/dev/backup-local-db.ps1`:

```powershell
# Automated local database backup
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$backupDir = "../../tmp/backups/local"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Exporting local database..."
podman exec wp-db bash -c "mariadb-dump -uroot -ppassword wordpress" | `
    Out-File -Encoding utf8 "$backupDir/$timestamp-local-db.sql"

$fileSize = (Get-Item "$backupDir/$timestamp-local-db.sql").Length / 1MB
Write-Host "✅ Backup saved: $timestamp-local-db.sql ($([math]::Round($fileSize, 2)) MB)"

# Keep only last 7 days of backups
Get-ChildItem $backupDir -Filter "*-local-db.sql" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
    Remove-Item -Force

Write-Host "✅ Old backups cleaned up (keeping last 7 days)"
```

**Run daily before starting work:**
```powershell
cd infra/dev
pwsh backup-local-db.ps1
```

#### Before Destructive Operations

**NEVER run `podman-compose down -v` without:**

```powershell
# 1. Backup database
pwsh infra/dev/backup-local-db.ps1

# 2. Export Elementor pages
pwsh infra/shared/scripts/export-elementor-pages.ps1

# 3. THEN reset
podman-compose down -v
```

---

### 2. Production Database Backups

#### Weekly Production Exports

Create `infra/shared/scripts/backup-prod-db.ps1`:

```powershell
# Weekly production database backup
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$backupDir = "../../tmp/backups/production"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Exporting production database via SSH..."
ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 `
    "mysqldump -h 127.0.0.1 -u u909075950_agpAD -pPxuqEe0Wln u909075950_GD9QX" | `
    Out-File -Encoding utf8 "$backupDir/$timestamp-prod-db.sql"

$fileSize = (Get-Item "$backupDir/$timestamp-prod-db.sql").Length / 1MB
Write-Host "✅ Production backup saved: $timestamp-prod-db.sql ($([math]::Round($fileSize, 2)) MB)"

# Keep last 4 weeks
Get-ChildItem $backupDir -Filter "*-prod-db.sql" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-28) } | 
    Remove-Item -Force
```

**Schedule weekly (e.g., Friday evenings):**
```powershell
pwsh infra/shared/scripts/backup-prod-db.ps1
```

#### Hostinger Automated Backups

1. **Enable in hPanel:**
   - Go to: https://hpanel.hostinger.com → Backups
   - Enable: Daily automatic backups
   - Retention: 7 days minimum (14 days recommended)

2. **Manual backup before deployments:**
   - hPanel → Backups → Create Backup
   - Download backup locally for extra safety

---

### 3. Elementor Content Protection

#### Backup Location

**Export location**: `tmp/backups/pages/$(date)/`  
**Working exports**: `tmp/elementor-exports/` (overwritten on each export)

#### Before ANY Container Restart

```powershell
# Always export Elementor pages before restarting containers
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
New-Item -ItemType Directory -Force -Path "tmp/backups/pages/$timestamp" | Out-Null

cd infra/shared/scripts
pwsh export-elementor-pages.ps1

# Copy to backup directory
Copy-Item ../../tmp/elementor-exports/*.json "../../tmp/backups/pages/$timestamp/"
Write-Host "✅ Elementor pages backed up to tmp/backups/pages/$timestamp/"

# Verify exports are not empty
Get-ChildItem "../../tmp/backups/pages/$timestamp/*.json" | 
    Where-Object { $_.Length -eq 0 } | 
    ForEach-Object { Write-Warning "⚠️ EMPTY FILE: $($_.Name)" }
```

#### Git-Commit Elementor Exports (for major milestones)

```powershell
# After completing major pages, commit exports to git
mkdir -p docs/elementor-snapshots/$(Get-Date -Format 'yyyyMMdd')
Copy-Item tmp/elementor-exports/*.json docs/elementor-snapshots/$(Get-Date -Format 'yyyyMMdd')/

git add docs/elementor-snapshots/
git commit -m "snapshot: Elementor pages backup $(Get-Date -Format 'yyyy-MM-dd')"
git push
```

---

### 4. Forminator Forms Backup

**Backup location**: `tmp/backups/forms/$(date)/`

#### Export Script

```powershell
# Export all Forminator forms
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
New-Item -ItemType Directory -Force -Path "tmp/backups/forms/$timestamp" | Out-Null

$formsOutput = podman exec wp wp eval '
    $forms = get_posts(["post_type" => "forminator_forms", "posts_per_page" => -1]);
    foreach ($forms as $form) {
        $meta = get_post_meta($form->ID, "forminator_form_meta", true);
        $data = [
            "id" => $form->ID,
            "title" => $form->post_title,
            "slug" => $form->post_name,
            "status" => $form->post_status,
            "meta" => $meta
        ];
        echo json_encode($data, JSON_PRETTY_PRINT) . "\n---FORM-SEPARATOR---\n";
    }
' --allow-root 2>$null

if (8formsOutput) {
    $formsOutput | Out-File -Encoding utf8 "tmp/backups/forms/$timestamp/forminator-forms.json"
    $formCount = ($formsOutput -split '---FORM-SEPARATOR---').Count - 1
    Write-Host "✅ Forminator forms backed up: $formCount form(s)"
} else {
    Write-Host "⚠️  No forms found"
}
```

**Retention**: Keep last 30 days (forms change less frequently than pages).

---

### 5. Configuration Files Backup

**Backup location**: `tmp/backups/config/$(date)/`

Configuration files are in git, but for quick disaster recovery:

```powershell
# Backup configuration files
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
New-Item -ItemType Directory -Force -Path "tmp/backups/config/$timestamp" | Out-Null

Copy-Item config/wp-config.php "tmp/backups/config/$timestamp/"
Copy-Item config/.htaccess "tmp/backups/config/$timestamp/"
Copy-Item config/uploads.ini "tmp/backups/config/$timestamp/"
Copy-Item infra/dev/compose.yml "tmp/backups/config/$timestamp/"

Write-Host "✅ Config files backed up to tmp/backups/config/$timestamp/"
```

---

### 6. Custom Plugins Backup

**Backup location**: `tmp/backups/plugins/$(date)/`

Custom plugins are already in git. Only backup before major plugin changes:

```powershell
# Backup custom plugins
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
New-Item -ItemType Directory -Force -Path "tmp/backups/plugins/$timestamp" | Out-Null

if (Test-Path wp-content/mu-plugins) {
    Copy-Item wp-content/mu-plugins -Recurse "tmp/backups/plugins/$timestamp/mu-plugins"
}
if (Test-Path wp-content/plugins/talendelight-roles) {
    Copy-Item wp-content/plugins/talendelight-roles -Recurse "tmp/backups/plugins/$timestamp/talendelight-roles"
}
if (Test-Path wp-content/plugins/forminator-upload-handler) {
    Copy-Item wp-content/plugins/forminator-upload-handler -Recurse "tmp/backups/plugins/$timestamp/forminator-upload-handler"
}

Write-Host "✅ Custom plugins backed up to tmp/backups/plugins/$timestamp/"
```

---

### 7. Baseline Database Updates

#### When Content is Stable

**Update the baseline SQL file** with actual content:

```powershell
# Export full local database
podman exec wp-db bash -c "mariadb-dump -uroot -ppassword wordpress" | `
    Out-File -Encoding utf8 tmp/new-baseline.sql

# Review and replace baseline
# IMPORTANT: Review first, don't blindly replace!
Copy-Item tmp/new-baseline.sql infra/shared/db/000000-0000-init-db.sql

git add infra/shared/db/000000-0000-init-db.sql
git commit -m "Update baseline database with current content"
```

**When to update baseline:**
- After completing a major feature (e.g., all MVP pages done)
- Before major releases
- Monthly (if significant content added)

---

### 5. Development Workflow Safeguards

#### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Check for empty Elementor exports if they exist

if [ -d "tmp/elementor-exports" ]; then
    empty_files=$(find tmp/elementor-exports -name "*.json" -size 0 2>/dev/null)
    if [ -n "$empty_files" ]; then
        echo "⚠️  WARNING: Empty Elementor export files detected:"
        echo "$empty_files"
        echo "Consider exporting pages before committing."
        echo "Run: pwsh infra/shared/scripts/export-elementor-pages.ps1"
    fi
fi
```

#### Deployment Checklist

Before every deployment, verify:

```powershell
# Deployment Pre-flight Checklist
Write-Host "=== Pre-Deployment Checklist ==="

# 1. Backup production
Write-Host "[ ] Production database backed up?"
Write-Host "    Run: pwsh infra/shared/scripts/backup-prod-db.ps1"

# 2. Verify pages exist locally
$pageCount = podman exec wp-db mariadb -uroot -ppassword wordpress `
    -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='page' AND post_status='publish';" -s -N
Write-Host "[ ] Local pages: $pageCount (should be > 10 for MVP)"

# 3. Check Elementor exports
$exportCount = (Get-ChildItem tmp/elementor-exports/*.json | Where-Object { $_.Length -gt 100 }).Count
Write-Host "[ ] Elementor exports: $exportCount (should match page count)"

# 4. Database migrations ready?
Write-Host "[ ] SQL delta files reviewed and tested?"

Write-Host "`n✅ All checks passed? Proceed with deployment."
```

---

### 9. Backup Directory Structure

```
tmp/
├── backups/
│   ├── local/              # Daily local database exports
│   │   ├── 20260205-0900-local-db.sql
│   │   ├── 20260204-0900-local-db.sql
│   │   └── ... (7 days retention)
│   ├── production/         # Weekly production database exports
│   │   ├── 20260202-1800-prod-db.sql
│   │   └── ... (28 days retention)
│   ├── pages/              # Elementor page exports
│   │   ├── 20260205-0900/
│   │   │   ├── homepage.json
│   │   │   ├── managers.json
│   │   │   └── ...
│   │   └── ... (7 days retention)
│   ├── forms/              # Forminator form exports
│   │   ├── 20260205-0900/
│   │   │   └── forminator-forms.json
│   │   └── ... (30 days retention)
│   ├── config/             # Configuration file snapshots
│   │   ├── 20260205-0900/
│   │   │   ├── wp-config.php
│   │   │   ├── .htaccess
│   │   │   └── ...
│   │   └── ... (30 days retention)
│   └── plugins/            # Custom plugin snapshots
│       ├── 20260205-0900/
│       │   ├── mu-plugins/
│       │   ├── talendelight-roles/
│       │   └── forminator-upload-handler/
│       └── ... (30 days retention)
├── elementor-exports/      # Latest Elementor page exports (overwritten)
│   ├── homepage.json
│   ├── managers.json
│   └── ...
└── snapshots/              # One-time snapshots before major changes
    └── 20260205-before-reset/
        ├── database.sql
        └── elementor-*.json

docs/
└── elementor-snapshots/    # Git-committed milestone snapshots
    ├── 20260120/
    │   ├── homepage.json
    │   └── managers.json
    └── 20260204/
        └── ... (major milestones only)
```

**Git ignore rules (`.gitignore`):**
```gitignore
# Exclude all backups (too large for git)
tmp/backups/
tmp/snapshots/
tmp/*-db.sql
tmp/*export*.sql

# But INCLUDE working Elementor exports (small, critical)
!tmp/elementor-exports/*.json

# Include milestone snapshots in docs
!docs/elementor-snapshots/**/*.json
```

---

### 10. Recovery Procedures

#### Restore Local Database from Backup

```powershell
# List available backups
Get-ChildItem tmp/backups/local/ | Sort-Object LastWriteTime -Descending | Select-Object -First 5

# Restore specific backup
$backupFile = "tmp/backups/local/20260204-1800-local-db.sql"
Get-Content $backupFile | podman exec -i wp-db mariadb -uroot -ppassword wordpress

# Update URLs for local
podman exec wp-db mariadb -uroot -ppassword wordpress -e `
    "UPDATE wp_options SET option_value = 'https://wp.local' WHERE option_name IN ('siteurl', 'home');"
```

#### Restore Elementor Pages from Backup

```powershell
# Find latest page backup
$latest = Get-ChildItem tmp/backups/pages/ -Directory | Sort-Object Name -Descending | Select-Object -First 1

# Transfer files safely (avoid encoding corruption)
podman exec wp mkdir -p /tmp/el-restore

foreach ($file in Get-ChildItem "$($latest.FullName)/*.json") {
    Get-Content $file.FullName -Raw -Encoding UTF8 | 
        podman exec -i wp bash -c "cat > /tmp/el-restore/$($file.Name)"
}

# Use import script (create tmp/import-pages.php based on import-direct-db.php from lessons)
podman exec wp wp eval-file tmp/import-pages.php --allow-root

Write-Host "✅ Pages restored from $($latest.Name)"
```

#### Restore Forminator Forms from Backup

```powershell
# Find latest form backup
$latest = Get-ChildItem tmp/backups/forms/ -Directory | Sort-Object Name -Descending | Select-Object -First 1
$formsJson = Get-Content "$($latest.FullName)/forminator-forms.json" -Raw

# Parse and restore each form
$forms = $formsJson -split '---FORM-SEPARATOR---' | Where-Object { $_.Trim() }

foreach ($formJson in $forms) {
    $form = $formJson | ConvertFrom-Json
    
    # Check if form exists
    $exists = podman exec wp wp post list --post_type=forminator_forms --name="$($form.slug)" --format=ids --allow-root
    
    if ($exists) {
        Write-Host "Form '$($form.title)' already exists, skipping"
        continue
    }
    
    # Create form
    $formId = podman exec wp wp post create --post_type=forminator_forms --post_title="$($form.title)" --post_name="$($form.slug)" --post_status=publish --porcelain --allow-root
    
    # Restore form meta
    $metaJson = $form.meta | ConvertTo-Json -Depth 100 -Compress
    podman exec wp wp post meta update $formId forminator_form_meta "$metaJson" --format=json --allow-root
    
    Write-Host "✅ Restored form '$($form.title)' (ID: $formId)"
}

Write-Host "✅ Forms restored from $($latest.Name)"
```

#### Restore Production from Hostinger Backup

1. **Via hPanel:**
   - Go to: Backups → Select date → Restore
   - Choose: Full Restore or Files Only

2. **Via downloaded backup:**
   - Upload SQL to Hostinger via phpMyAdmin
   - Or: `scp backup.sql u909075950@45.84.205.129:~/ && ssh ... "wp db import backup.sql"`

---

### 8. Monitoring and Alerts

#### Daily Health Check

Create `infra/dev/health-check.ps1`:

```powershell
# Daily development environment health check
Write-Host "=== WordPress Development Health Check ===" -ForegroundColor Cyan

# 1. Container status
Write-Host "`n📦 Container Status:"
podman ps --format "{{.Names}}: {{.Status}}" | Where-Object { $_ -match "wp|caddy" }

# 2. Database tables
$tables = podman exec wp-db mariadb -uroot -ppassword wordpress -e "SHOW TABLES;" -s -N | Measure-Object
Write-Host "📊 Database tables: $($tables.Count)"

# 3. Page count
$pages = podman exec wp-db mariadb -uroot -ppassword wordpress `
    -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='page' AND post_status != 'auto-draft';" -s -N
Write-Host "📄 Pages: $pages"

# 4. Recent backup
$latestBackup = Get-ChildItem tmp/backups/local/ -ErrorAction SilentlyContinue | 
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestBackup) {
    $age = (Get-Date) - $latestBackup.LastWriteTime
    $color = if ($age.TotalHours -lt 24) { "Green" } else { "Yellow" }
    Write-Host "💾 Latest backup: $($latestBackup.Name) ($([math]::Round($age.TotalHours, 1))h ago)" -ForegroundColor $color
} else {
    Write-Host "⚠️  No backups found!" -ForegroundColor Red
}

# 5. Elementor exports
$exports = Get-ChildItem tmp/elementor-exports/*.json -ErrorAction SilentlyContinue | 
    Where-Object { $_.Length -gt 100 }
Write-Host "📦 Elementor exports: $($exports.Count) valid files"

Write-Host "`n✅ Health check complete" -ForegroundColor Green
```

Run daily:
```powershell
cd infra/dev
pwsh health-check.ps1
```

---

## Quick Reference Commands

### Safe Container Restart (with backup)
```powershell
# Full backup before restart
pwsh infra/dev/backup-local-db.ps1
pwsh infra/shared/scripts/export-elementor-pages.ps1

# Now safe to restart
podman-compose restart
```

### Safe Full Reset (with backup)
```powershell
# Backup everything
pwsh infra/dev/backup-local-db.ps1
pwsh infra/shared/scripts/export-elementor-pages.ps1

# Create snapshot
$snapshot = "tmp/snapshots/$(Get-Date -Format 'yyyyMMdd-HHmm')"
New-Item -ItemType Directory -Force -Path $snapshot
Copy-Item tmp/backups/local/*.sql $snapshot/ -ErrorAction SilentlyContinue
Copy-Item tmp/elementor-exports/*.json $snapshot/ -ErrorAction SilentlyContinue

# Reset
podman-compose down -v
podman-compose up -d

# Restore if needed
# Get-Content $snapshot/latest-backup.sql | podman exec -i wp-db mariadb -uroot -ppassword wordpress
```

---

## Automation Schedule

**Daily (before starting work):**
- Run `health-check.ps1`
- Run `backup-local-db.ps1` if working on content

**Before any container operations:**
- Export Elementor pages
- Backup database

**Weekly (Friday):**
- Run `backup-prod-db.ps1`
- Verify Hostinger automated backups are running
- Review and clean old backups

**Monthly:**
- Update baseline SQL if content is stable
- Commit Elementor snapshot to git
- Test restore procedures

---

## Implementation Checklist

- [ ] Create backup directories: `mkdir -p tmp/backups/{local,production}`
- [ ] Create backup scripts (backup-local-db.ps1, backup-prod-db.ps1)
- [ ] Create health-check.ps1
- [ ] Update .gitignore for backup exclusions
- [ ] Enable Hostinger automated backups
- [ ] Test restore procedure once
- [ ] Add daily backup to workflow
- [ ] Document in team onboarding materials
- [ ] Schedule weekly production backups
- [ ] Set calendar reminder for monthly baseline updates

---

## Notes

- **Backups are worthless if never tested** - Test restore procedure monthly
- **Automate everything** - Manual processes will be skipped under pressure
- **Multiple backup locations** - Local + Production + Git snapshots
- **Version control != backup** - Git tracks code, not user-generated content
- **Retention policy** - Balance between storage cost and recovery needs

---

**Remember:** The 30 minutes spent on backups today saves 30 hours of rebuilding tomorrow.
