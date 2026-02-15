# Unified backup script - Local environment
# Backs up: Database + Elementor pages + Forminator forms + Configs

$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$baseDir = "../../tmp/backups"

Write-Host "=== Complete Local Backup ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp"
Write-Host ""

# Check if containers are running
$wpRunning = podman ps --format "{{.Names}}" | Select-String -Pattern "^wp$"
if (-not $wpRunning) {
    Write-Host "❌ Error: wp container is not running" -ForegroundColor Red
    Write-Host "Start containers with: podman-compose up -d"
    exit 1
}

# 1. Database Backup
Write-Host "📊 Backing up database..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$baseDir/local" | Out-Null

try {
    podman exec wp-db bash -c "mariadb-dump -uroot -ppassword wordpress" | `
        Out-File -Encoding utf8 "$baseDir/local/$timestamp-local-db.sql"
    
    $fileSize = (Get-Item "$baseDir/local/$timestamp-local-db.sql").Length / 1MB
    Write-Host "  ✅ Database: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Database backup failed: $_" -ForegroundColor Red
}

# 2. Elementor Pages
Write-Host "`n📄 Backing up Elementor pages..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$baseDir/pages/$timestamp" | Out-Null

try {
    # Export pages
    & "$PSScriptRoot/../../infra/shared/scripts/export-elementor-pages.ps1"
    
    # Copy to backup directory
    $exported = Copy-Item tmp/elementor-exports/*.json "$baseDir/pages/$timestamp/" -PassThru
    Write-Host "  ✅ Pages: $($exported.Count) files" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Page backup failed: $_" -ForegroundColor Red
}

# 3. Forminator Forms
Write-Host "`n📋 Backing up Forminator forms..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$baseDir/forms/$timestamp" | Out-Null

try {
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
    
    if ($formsOutput) {
        $formsOutput | Out-File -Encoding utf8 "$baseDir/forms/$timestamp/forminator-forms.json"
        $formCount = ($formsOutput -split '---FORM-SEPARATOR---').Count - 1
        Write-Host "  ✅ Forms: $formCount form(s)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  No forms found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ Form backup failed: $_" -ForegroundColor Red
}

# 4. Configuration Files (optional, mostly in git)
Write-Host "`n⚙️  Backing up config files..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$baseDir/config/$timestamp" | Out-Null

try {
    Copy-Item config/wp-config.php "$baseDir/config/$timestamp/" -ErrorAction Stop
    Copy-Item config/.htaccess "$baseDir/config/$timestamp/" -ErrorAction Stop
    Copy-Item config/uploads.ini "$baseDir/config/$timestamp/" -ErrorAction Stop
    Copy-Item infra/dev/compose.yml "$baseDir/config/$timestamp/" -ErrorAction Stop
    Write-Host "  ✅ Config: 4 files" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Config backup partial: $_" -ForegroundColor Yellow
}

# 5. Custom Plugins (optional, already in git)
Write-Host "`n🔌 Backing up custom plugins..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$baseDir/plugins/$timestamp" | Out-Null

try {
    if (Test-Path wp-content/mu-plugins) {
        Copy-Item wp-content/mu-plugins -Recurse "$baseDir/plugins/$timestamp/mu-plugins" -ErrorAction Stop
    }
    if (Test-Path wp-content/plugins/talendelight-roles) {
        Copy-Item wp-content/plugins/talendelight-roles -Recurse "$baseDir/plugins/$timestamp/talendelight-roles" -ErrorAction Stop
    }
    if (Test-Path wp-content/plugins/forminator-upload-handler) {
        Copy-Item wp-content/plugins/forminator-upload-handler -Recurse "$baseDir/plugins/$timestamp/forminator-upload-handler" -ErrorAction Stop
    }
    Write-Host "  ✅ Plugins: Custom plugins backed up" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Plugin backup failed: $_" -ForegroundColor Yellow
}

# Cleanup old backups (keep last 7 days)
Write-Host "`n🗑️  Cleaning old backups..." -ForegroundColor Yellow
$cutoffDate = (Get-Date).AddDays(-7)

$deleted = @()
$deleted += Get-ChildItem "$baseDir/local" -Filter "*.sql" | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -PassThru
$deleted += Get-ChildItem "$baseDir/pages" -Directory | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -Recurse -PassThru
$deleted += Get-ChildItem "$baseDir/forms" -Directory | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -Recurse -PassThru
$deleted += Get-ChildItem "$baseDir/config" -Directory | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -Recurse -PassThru
$deleted += Get-ChildItem "$baseDir/plugins" -Directory | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -Recurse -PassThru

if ($deleted.Count -gt 0) {
    Write-Host "  Removed $($deleted.Count) old backup(s)" -ForegroundColor Gray
}

# Summary
Write-Host "`n=== Backup Summary ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp"
Write-Host "Location: tmp/backups/"

# Calculate total size
$totalSize = 0
Get-ChildItem "$baseDir/local/$timestamp-local-db.sql" -ErrorAction SilentlyContinue | ForEach-Object { $totalSize += $_.Length }
Get-ChildItem "$baseDir/pages/$timestamp" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $totalSize += $_.Length }
Get-ChildItem "$baseDir/forms/$timestamp" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $totalSize += $_.Length }
Get-ChildItem "$baseDir/config/$timestamp" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $totalSize += $_.Length }
Get-ChildItem "$baseDir/plugins/$timestamp" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $totalSize += $_.Length }

Write-Host "Total size: $([math]::Round($totalSize / 1MB, 2)) MB"
Write-Host ""
Write-Host "✅ Complete backup finished!" -ForegroundColor Green
Write-Host ""
Write-Host "Backed up:"
Write-Host "  - Database → tmp/backups/local/$timestamp-local-db.sql"
Write-Host "  - Pages → tmp/backups/pages/$timestamp/"
Write-Host "  - Forms → tmp/backups/forms/$timestamp/"
Write-Host "  - Config → tmp/backups/config/$timestamp/"
Write-Host "  - Plugins → tmp/backups/plugins/$timestamp/"
