# WordPress Menus Import Script
# Import menus from restore/menu/ folder
# Usage: pwsh restore/menu/IMPORT-SCRIPT.ps1

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  WordPress Menus Import - Restore Navigation Menus          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📦 Importing menus..." -ForegroundColor Cyan

$imported = 0
$errors = 0

# Import in correct order (dependencies)
$importOrder = @(
    "menus-from-production.sql",
    "menu-items-from-production.sql",
    "menu-items-meta-from-production.sql",
    "menu-relationships-from-production.sql"
)

foreach ($filename in $importOrder) {
    $file = "restore/menu/$filename"
    
    if (Test-Path $file) {
        try {
            Write-Host "  Importing $filename..." -ForegroundColor Gray
            Get-Content $file | podman exec -i wp-db mariadb -u root -ppassword wordpress 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ $filename" -ForegroundColor Green
                $imported++
            } else {
                Write-Host "  ✗ Failed to import $filename" -ForegroundColor Red
                $errors++
            }
        } catch {
            Write-Host "  ✗ Error importing $filename : $_" -ForegroundColor Red
            $errors++
        }
    } else {
        Write-Host "  ⚠ File not found: $filename" -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Import Summary                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nMenu files imported: $imported of $($importOrder.Count)" -ForegroundColor White
Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })

if ($imported -gt 0) {
    Write-Host "`n✅ Menus import complete!" -ForegroundColor Green
    Write-Host "`n💡 Verify at: https://wp.local/wp-admin/nav-menus.php" -ForegroundColor Yellow
}
