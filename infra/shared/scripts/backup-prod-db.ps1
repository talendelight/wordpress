# Production database backup script
# Run weekly (e.g., Friday evenings)

$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$backupDir = "../../tmp/backups/production"

# Create backup directory
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "=== Production Database Backup ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp"
Write-Host "Server: talendelight.com (Hostinger)"

# Check SSH key exists
$sshKey = "tmp/hostinger_deploy_key"
if (-not (Test-Path $sshKey)) {
    Write-Host "❌ Error: SSH key not found at $sshKey" -ForegroundColor Red
    exit 1
}

# Export production database
Write-Host "`nConnecting to production server..."
try {
    ssh -i $sshKey -p 65002 u909075950@45.84.205.129 `
        "mysqldump -h 127.0.0.1 -u u909075950_agpAD -pPxuqEe0Wln u909075950_GD9QX" | `
        Out-File -Encoding utf8 "$backupDir/$timestamp-prod-db.sql"
    
    $fileSize = (Get-Item "$backupDir/$timestamp-prod-db.sql").Length / 1MB
    Write-Host "✅ Production backup saved: $timestamp-prod-db.sql ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
    
    # Verify backup is not empty
    if ((Get-Item "$backupDir/$timestamp-prod-db.sql").Length -lt 100KB) {
        Write-Host "⚠️  WARNING: Backup file is suspiciously small!" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error during backup: $_" -ForegroundColor Red
    exit 1
}

# Clean up old backups (keep last 4 weeks)
Write-Host "`nCleaning old backups..."
$deleted = Get-ChildItem $backupDir -Filter "*-prod-db.sql" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-28) }

if ($deleted) {
    $deleted | Remove-Item -Force
    Write-Host "✅ Removed $($deleted.Count) old backup(s)" -ForegroundColor Green
} else {
    Write-Host "No old backups to clean"
}

# Show backup summary
Write-Host "`n=== Backup Summary ===" -ForegroundColor Cyan
$backups = Get-ChildItem $backupDir -Filter "*-prod-db.sql" | 
    Sort-Object LastWriteTime -Descending
Write-Host "Total backups: $($backups.Count)"
if ($backups.Count -gt 0) {
    Write-Host "Latest: $($backups[0].Name) ($(($backups[0].LastWriteTime).ToString('yyyy-MM-dd HH:mm')))"
    Write-Host "Oldest: $($backups[-1].Name) ($(($backups[-1].LastWriteTime).ToString('yyyy-MM-dd HH:mm')))"
    Write-Host "Total size: $([math]::Round(($backups | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB"
}

Write-Host "`n✅ Production backup complete!" -ForegroundColor Green
Write-Host "`nNext steps:"
Write-Host "  1. Verify backup integrity: Import to test database"
Write-Host "  2. Consider downloading to external storage"
Write-Host "  3. Verify Hostinger automated backups are also running"
