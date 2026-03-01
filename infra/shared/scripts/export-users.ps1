# Export WordPress Users and Roles
# Creates SQL exports of users, usermeta, and role assignments
# Usage: pwsh infra/shared/db/export-users.ps1

Write-Host "`nâ•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—" -ForegroundColor Cyan
Write-Host "â•‘  WordPress Users & Roles Export                              â•‘" -ForegroundColor Cyan
Write-Host "â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd"
$outputDir = "infra/shared/db"

Write-Host "`nðŸ“¦ Exporting users..." -ForegroundColor Yellow

# Export wp_users table
Write-Host "  Exporting wp_users table..." -ForegroundColor Gray
podman exec wp-db bash -c "mysqldump -u root -ppassword wordpress wp_users --skip-add-drop-table --no-create-info --complete-insert" | Out-File -Encoding UTF8 "$outputDir/users-$timestamp.sql" -Force

if (Test-Path "$outputDir/users-$timestamp.sql") {
    $size = [math]::Round((Get-Item "$outputDir/users-$timestamp.sql").Length/1KB, 1)
    Write-Host "  âœ“ users-$timestamp.sql ($size KB)" -ForegroundColor Green
} else {
    Write-Host "  âœ— Failed to export users" -ForegroundColor Red
}

# Export wp_usermeta table
Write-Host "  Exporting wp_usermeta table..." -ForegroundColor Gray
podman exec wp-db bash -c "mysqldump -u root -ppassword wordpress wp_usermeta --skip-add-drop-table --no-create-info --complete-insert" | Out-File -Encoding UTF8 "$outputDir/usermeta-$timestamp.sql" -Force

if (Test-Path "$outputDir/usermeta-$timestamp.sql") {
    $size = [math]::Round((Get-Item "$outputDir/usermeta-$timestamp.sql").Length/1KB, 1)
    Write-Host "  âœ“ usermeta-$timestamp.sql ($size KB)" -ForegroundColor Green
} else {
    Write-Host "  âœ— Failed to export usermeta" -ForegroundColor Red
}

# Get user count
$userCount = podman exec wp bash -c "wp user list --format=count --allow-root" 2>&1 | Select-String -Pattern "^\d+" | ForEach-Object { $_.Matches.Value }

Write-Host "`nâ•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—" -ForegroundColor Green
Write-Host "â•‘  Export Summary                                              â•‘" -ForegroundColor Green
Write-Host "â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Green

Write-Host "`nUsers exported: $userCount" -ForegroundColor White
Write-Host "Files created:" -ForegroundColor Cyan
Write-Host "  â€¢ $outputDir/users-$timestamp.sql" -ForegroundColor White
Write-Host "  â€¢ $outputDir/usermeta-$timestamp.sql" -ForegroundColor White

Write-Host "`nðŸ’¡ To import:" -ForegroundColor Yellow
Write-Host "  Get-Content $outputDir/users-$timestamp.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress" -ForegroundColor Gray
Write-Host "  Get-Content $outputDir/usermeta-$timestamp.sql | podman exec -i wp-db mariadb -u root -ppassword wordpress" -ForegroundColor Gray

Write-Host "`nâœ… Export complete!" -ForegroundColor Green
