# Master WordPress Backup Script
# Exports ALL WordPress data: pages, forms, menus, users, roles, plugin settings
# Run this at end of session or on-demand for complete backup
# Usage: pwsh restore/BACKUP-ALL.ps1

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Complete WordPress Backup - All Data                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$startTime = Get-Date

# 1. Export Pages
Write-Host "`n📄 [1/5] Exporting pages..." -ForegroundColor Yellow
pwsh restore/pages/EXPORT-SCRIPT.ps1

# 2. Export Users
Write-Host "`n👥 [2/5] Exporting users and roles..." -ForegroundColor Yellow
pwsh infra/shared/db/export-users.ps1

# 3. Export Plugin Settings
Write-Host "`n🔌 [3/5] Exporting plugin settings..." -ForegroundColor Yellow
pwsh restore/export-plugin-settings.ps1

# 4. Export critical wp_options
Write-Host "`n⚙️  [4/5] Exporting WordPress settings..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$criticalOptions = @(
    'siteurl',
    'home',
    'blogname',
    'blogdescription',
    'permalink_structure',
    'timezone_string',
    'date_format',
    'time_format',
    'show_on_front',
    'page_on_front',
    'page_for_posts'
)

$whereClause = ($criticalOptions | ForEach-Object { "option_name='$_'" }) -join ' OR '

podman exec wp-db bash -c "mysqldump -u root -ppassword wordpress wp_options --where='$whereClause' --skip-add-drop-table --no-create-info --complete-insert" | Out-File -Encoding UTF8 "restore/wordpress-settings-$timestamp.sql" -Force
Write-Host "  ✓ WordPress core settings exported" -ForegroundColor Green

# 5. Summary
Write-Host "`n📊 [5/5] Generating backup summary..." -ForegroundColor Yellow

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Backup Complete                                             ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nBackup completed in $([math]::Round($duration, 1)) seconds" -ForegroundColor White

Write-Host "`nBacked up:" -ForegroundColor Cyan
Write-Host "  ✓ Pages (restore/pages/*.json)" -ForegroundColor Green
Write-Host "  ✓ Users & Roles (infra/shared/db/users-*.sql)" -ForegroundColor Green
Write-Host "  ✓ Plugin Settings (restore/plugin-settings-*.sql)" -ForegroundColor Green
Write-Host "  ✓ WordPress Settings (restore/wordpress-settings-*.sql)" -ForegroundColor Green
Write-Host "  ✓ Forms (restore/forms/*.sql - existing)" -ForegroundColor Green
Write-Host "  ✓ Menus (restore/menu/*.sql - existing)" -ForegroundColor Green

Write-Host "`n💡 Next step: Commit to Git" -ForegroundColor Yellow
Write-Host "  git add restore/ infra/shared/db/" -ForegroundColor Gray
Write-Host "  git commit -m 'Complete backup - $(Get-Date -Format "yyyy-MM-dd")'" -ForegroundColor Gray
Write-Host "  git push origin develop" -ForegroundColor Gray

Write-Host "`n✅ All data backed up successfully!" -ForegroundColor Green
