# Export WordPress Users and Roles
# Creates SQL exports of users, usermeta, and role assignments
# Usage: pwsh infra/shared/db/export-users.ps1

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  WordPress Users & Roles Export                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd"
$outputDir = "infra/shared/db"

Write-Host "`n📦 Exporting users..." -ForegroundColor Yellow

# Export wp_users table
Write-Host "  Exporting wp_users table..." -ForegroundColor Gray
podman exec wp-db bash -c "mysqldump -u root -ppassword wordpress wp_users --skip-add-drop-table --no-create-info --complete-insert" | Out-File -Encoding UTF8 "$outputDir/users-$timestamp.sql" -Force

if (Test-Path "$outputDir/users-$timestamp.sql") {
    $size = [math]::Round((Get-Item "$outputDir/users-$timestamp.sql").Length/1KB, 1)
    Write-Host "  ✓ users-$timestamp.sql ($size KB)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Failed to export users" -ForegroundColor Red
}

# Export wp_usermeta table
Write-Host "  Exporting wp_usermeta table..." -ForegroundColor Gray
podman exec wp-db bash -c "mysqldump -u root -ppassword wordpress wp_usermeta --skip-add-drop-table --no-create-info --complete-insert" | Out-File -Encoding UTF8 "$outputDir/usermeta-$timestamp.sql" -Force

if (Test-Path "$outputDir/usermeta-$timestamp.sql") {
    $size = [math]::Round((Get-Item "$outputDir/usermeta-$timestamp.sql").Length/1KB, 1)
    Write-Host "  ✓ usermeta-$timestamp.sql ($size KB)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Failed to export usermeta" -ForegroundColor Red
}

# Get user count
$userCount = podman exec wp bash -c "wp user list --format=count --allow-root" 2>&1 | Select-String -Pattern "^\d+" | ForEach-Object { $_.Matches.Value }

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Export Summary                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nUsers exported: $userCount" -ForegroundColor White
Write-Host "Files created:" -ForegroundColor Cyan
Write-Host "  • $outputDir/users-$timestamp.sql" -ForegroundColor White
Write-Host "  • $outputDir/usermeta-$timestamp.sql" -ForegroundColor White

Write-Host "`n💡 To import:" -ForegroundColor Yellow
Write-Host "  Get-Content $outputDir/users-$timestamp.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress" -ForegroundColor Gray
Write-Host "  Get-Content $outputDir/usermeta-$timestamp.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress" -ForegroundColor Gray

Write-Host "`n✅ Export complete!" -ForegroundColor Green
