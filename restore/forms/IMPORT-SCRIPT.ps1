# WordPress Forms Import Script
# Import Forminator forms from restore/forms/ folder
# Usage: pwsh restore/forms/IMPORT-SCRIPT.ps1

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  WordPress Forms Import - Restore Forminator Forms          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Check if Forminator plugin is active
Write-Host "`n📋 Checking Forminator plugin..." -ForegroundColor Yellow
$pluginStatus = podman exec wp bash -c "wp plugin status forminator --allow-root" 2>&1

if ($pluginStatus -match "Active") {
    Write-Host "✓ Forminator is active" -ForegroundColor Green
} else {
    Write-Host "❌ Forminator plugin not active. Activating..." -ForegroundColor Red
    podman exec wp bash -c "wp plugin activate forminator --allow-root" 2>&1
}

# Import forms
Write-Host "`n📦 Importing forms..." -ForegroundColor Cyan

$sqlFiles = Get-ChildItem restore/forms/*.sql | Where-Object { $_.Name -notmatch "tables" }
$imported = 0
$errors = 0

foreach ($file in $sqlFiles) {
    try {
        Write-Host "  Importing $($file.Name)..." -ForegroundColor Gray
        Get-Content $file.FullName | podman exec -i wp-db mariadb -u root -ppassword wordpress 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $($file.Name)" -ForegroundColor Green
            $imported++
        } else {
            Write-Host "  ✗ Failed to import $($file.Name)" -ForegroundColor Red
            $errors++
        }
    } catch {
        Write-Host "  ✗ Error importing $($file.Name): $_" -ForegroundColor Red
        $errors++
    }
}

# Import Forminator tables if needed
$tablesFile = "restore/forms/forminator-tables-from-production.sql"
if (Test-Path $tablesFile) {
    Write-Host "`n  Importing Forminator tables..." -ForegroundColor Gray
    Get-Content $tablesFile | podman exec -i wp-db mariadb -u root -ppassword wordpress 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Forminator tables imported" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Forminator tables import issue (may already exist)" -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Import Summary                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nForms imported: $imported" -ForegroundColor White
Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })

if ($imported -gt 0) {
    Write-Host "`n✅ Forms import complete!" -ForegroundColor Green
    Write-Host "`n💡 Verify at: https://wp.local/wp-admin/admin.php?page=forminator" -ForegroundColor Yellow
}
