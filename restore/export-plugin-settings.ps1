# Export WordPress Plugin Settings
# Creates SQL export of wp_options table entries for active plugins
# Usage: pwsh restore/export-plugin-settings.ps1

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  WordPress Plugin Settings Export                            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$outputFile = "restore/plugin-settings-$timestamp.sql"

Write-Host "`n📦 Exporting plugin settings from wp_options..." -ForegroundColor Yellow

# Get active plugins
$activePlugins = podman exec wp bash -c "wp plugin list --status=active --field=name --allow-root" 2>&1

Write-Host "`nActive plugins:" -ForegroundColor Cyan
$activePlugins -split "`n" | Where-Object { $_ } | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }

# Export wp_options entries for common plugin prefixes
$pluginPrefixes = @(
    'forminator_%',
    'elementor_%',
    'wpum_%',
    'litespeed%',
    'blocksy_%',
    'talendelight_%'
)

Write-Host "`n  Exporting plugin options..." -ForegroundColor Gray

$whereClause = ($pluginPrefixes | ForEach-Object { "option_name LIKE '$_'" }) -join ' OR '

podman exec wp-db bash -c "mysqldump -u root -ppassword wordpress wp_options --where='$whereClause' --skip-add-drop-table --no-create-info --complete-insert" | Out-File -Encoding UTF8 $outputFile -Force

if (Test-Path $outputFile) {
    $size = [math]::Round((Get-Item $outputFile).Length/1KB, 1)
    Write-Host "  ✓ plugin-settings-$timestamp.sql ($size KB)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Failed to export plugin settings" -ForegroundColor Red
    exit 1
}

# Also export active_plugins option
Write-Host "  Exporting active plugins list..." -ForegroundColor Gray
$activePluginsFile = "restore/active-plugins-$timestamp.sql"

podman exec wp-db bash -c "mysqldump -u root -ppassword wordpress wp_options --where='option_name=\"active_plugins\"' --skip-add-drop-table --no-create-info --complete-insert" | Out-File -Encoding UTF8 $activePluginsFile -Force

if (Test-Path $activePluginsFile) {
    $size = [math]::Round((Get-Item $activePluginsFile).Length/1KB, 1)
    Write-Host "  ✓ active-plugins-$timestamp.sql ($size KB)" -ForegroundColor Green
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Export Summary                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nFiles created:" -ForegroundColor Cyan
Write-Host "  • $outputFile" -ForegroundColor White
Write-Host "  • $activePluginsFile" -ForegroundColor White

Write-Host "`n💡 To import:" -ForegroundColor Yellow
Write-Host "  Get-Content $outputFile | podman exec -i wp-db mariadb -u root -ppassword wordpress" -ForegroundColor Gray

Write-Host "`n✅ Export complete!" -ForegroundColor Green
