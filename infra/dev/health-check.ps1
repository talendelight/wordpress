# Daily development environment health check

Write-Host "=== WordPress Development Health Check ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

$issues = @()

# 1. Container status
Write-Host "📦 Container Status:" -ForegroundColor Yellow
$containers = podman ps --format "{{.Names}}: {{.Status}}" | Where-Object { $_ -match "wp|caddy" }
if ($containers) {
    $containers | ForEach-Object { Write-Host "   $_" }
} else {
    Write-Host "   ❌ No WordPress containers running!" -ForegroundColor Red
    $issues += "Containers not running"
}

# 2. Database connectivity
Write-Host "`n📊 Database:" -ForegroundColor Yellow
try {
    $tables = podman exec wp-db mariadb -uroot -ppassword wordpress -e "SHOW TABLES;" -s -N 2>$null | Measure-Object
    Write-Host "   Tables: $($tables.Count)"
    
    if ($tables.Count -lt 10) {
        Write-Host "   ⚠️  Low table count - database might be incomplete" -ForegroundColor Yellow
        $issues += "Low table count"
    }
} catch {
    Write-Host "   ❌ Cannot connect to database" -ForegroundColor Red
    $issues += "Database connection failed"
}

# 3. Page count
Write-Host "`n📄 Content:" -ForegroundColor Yellow
try {
    $pages = podman exec wp-db mariadb -uroot -ppassword wordpress `
        -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='page' AND post_status != 'auto-draft';" -s -N 2>$null
    Write-Host "   Pages: $pages"
    
    if ([int]$pages -lt 3) {
        Write-Host "   ⚠️  Very few pages - content may be missing" -ForegroundColor Yellow
        $issues += "Low page count"
    }
    
    $posts = podman exec wp-db mariadb -uroot -ppassword wordpress `
        -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='post' AND post_status = 'publish';" -s -N 2>$null
    Write-Host "   Posts: $posts"
} catch {
    Write-Host "   ❌ Cannot query content" -ForegroundColor Red
}

# 4. Custom tables
Write-Host "`n🔧 Custom Tables:" -ForegroundColor Yellow
try {
    $customTables = podman exec wp-db mariadb -uroot -ppassword wordpress `
        -e "SHOW TABLES LIKE '%td_%';" -s -N 2>$null | Measure-Object
    Write-Host "   Custom tables: $($customTables.Count)"
    
    $expectedTables = @('td_user_data_change_requests', 'td_id_sequences', 'td_audit_log')
    foreach ($table in $expectedTables) {
        $exists = podman exec wp-db mariadb -uroot -ppassword wordpress `
            -e "SHOW TABLES LIKE '$table';" -s -N 2>$null
        if ($exists) {
            Write-Host "   ✅ $table" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $table (missing)" -ForegroundColor Red
            $issues += "Missing table: $table"
        }
    }
} catch {
    Write-Host "   ⚠️  Cannot check custom tables" -ForegroundColor Yellow
}

# 5. Recent backup
Write-Host "`n💾 Backups:" -ForegroundColor Yellow
$latestBackup = Get-ChildItem tmp/backups/local/ -ErrorAction SilentlyContinue | 
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestBackup) {
    $age = (Get-Date) - $latestBackup.LastWriteTime
    $ageHours = [math]::Round($age.TotalHours, 1)
    
    if ($age.TotalHours -lt 24) {
        Write-Host "   Latest: $($latestBackup.Name) ($ageHours hours ago)" -ForegroundColor Green
    } elseif ($age.TotalHours -lt 48) {
        Write-Host "   Latest: $($latestBackup.Name) ($ageHours hours ago)" -ForegroundColor Yellow
        Write-Host "   ⚠️  Backup is over 24 hours old" -ForegroundColor Yellow
        $issues += "Backup older than 24 hours"
    } else {
        Write-Host "   Latest: $($latestBackup.Name) ($ageHours hours ago)" -ForegroundColor Red
        Write-Host "   ❌ Backup is very old!" -ForegroundColor Red
        $issues += "Backup very old"
    }
} else {
    Write-Host "   ❌ No backups found!" -ForegroundColor Red
    $issues += "No backups"
    Write-Host "   Run: pwsh infra/dev/backup-local-db.ps1"
}

# 6. Elementor exports
Write-Host "`n📦 Elementor Exports:" -ForegroundColor Yellow
$exports = Get-ChildItem tmp/elementor-exports/*.json -ErrorAction SilentlyContinue | 
    Where-Object { $_.Length -gt 100 }
Write-Host "   Valid exports: $($exports.Count) files"

$emptyExports = Get-ChildItem tmp/elementor-exports/*.json -ErrorAction SilentlyContinue | 
    Where-Object { $_.Length -eq 0 }
if ($emptyExports) {
    Write-Host "   ⚠️  $($emptyExports.Count) empty export file(s)" -ForegroundColor Yellow
    $issues += "Empty Elementor exports"
}

# 7. Site URL
Write-Host "`n🌐 Configuration:" -ForegroundColor Yellow
try {
    $siteurl = podman exec wp-db mariadb -uroot -ppassword wordpress `
        -e "SELECT option_value FROM wp_options WHERE option_name='siteurl';" -s -N 2>$null
    Write-Host "   Site URL: $siteurl"
    
    if ($siteurl -ne "https://wp.local") {
        Write-Host "   ⚠️  Expected: https://wp.local" -ForegroundColor Yellow
        $issues += "Incorrect site URL"
    }
} catch {
    Write-Host "   ⚠️  Cannot check site URL" -ForegroundColor Yellow
}

# Summary
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
if ($issues.Count -eq 0) {
    Write-Host "✅ All checks passed!" -ForegroundColor Green
    Write-Host "Your development environment is healthy." -ForegroundColor Green
} else {
    Write-Host "⚠️  Issues found: $($issues.Count)" -ForegroundColor Yellow
    Write-Host "`nIssues:" -ForegroundColor Yellow
    $issues | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    Write-Host "`nRecommended actions:" -ForegroundColor Cyan
    Write-Host "   1. Run backup: pwsh infra/dev/backup-local-db.ps1"
    Write-Host "   2. Export pages: pwsh infra/shared/scripts/export-elementor-pages.ps1"
    Write-Host "   3. Check documentation: docs/BACKUP-STRATEGY.md"
}

Write-Host ""
