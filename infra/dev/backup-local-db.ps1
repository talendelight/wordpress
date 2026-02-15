# Automated local database backup script
# Run daily before starting work

$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$backupDir = "../../tmp/backups/local"

# Create backup directory
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "=== Local Database Backup ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp"

# Check if containers are running
$wpDbRunning = podman ps --format "{{.Names}}" | Select-String -Pattern "wp-db"
if (-not $wpDbRunning) {
    Write-Host "❌ Error: wp-db container is not running" -ForegroundColor Red
    Write-Host "Start containers with: podman-compose up -d"
    exit 1
}

# Export database
Write-Host "`nExporting database..."
try {
    podman exec wp-db bash -c "mariadb-dump -uroot -ppassword wordpress" | `
        Out-File -Encoding utf8 "$backupDir/$timestamp-local-db.sql"
    
    $fileSize = (Get-Item "$backupDir/$timestamp-local-db.sql").Length / 1MB
    Write-Host "✅ Backup saved: $timestamp-local-db.sql ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
    
    # Verify backup is not empty
    if ((Get-Item "$backupDir/$timestamp-local-db.sql").Length -lt 1KB) {
        Write-Host "⚠️  WARNING: Backup file is suspiciously small!" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error during backup: $_" -ForegroundColor Red
    exit 1
}

# Clean up old backups (keep last 7 days)
Write-Host "`nCleaning old backups..."
$deleted = Get-ChildItem $backupDir -Filter "*-local-db.sql" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }

if ($deleted) {
    $deleted | Remove-Item -Force
    Write-Host "✅ Removed $($deleted.Count) old backup(s)" -ForegroundColor Green
} else {
    Write-Host "No old backups to clean"
}

# Show backup summary
Write-Host "`n=== Backup Summary ===" -ForegroundColor Cyan
$backups = Get-ChildItem $backupDir -Filter "*-local-db.sql" | 
    Sort-Object LastWriteTime -Descending
Write-Host "Total backups: $($backups.Count)"
Write-Host "Latest: $($backups[0].Name)"
Write-Host "Oldest: $($backups[-1].Name)"
Write-Host "Total size: $([math]::Round(($backups | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB"

Write-Host "`n✅ Backup complete!" -ForegroundColor Green
