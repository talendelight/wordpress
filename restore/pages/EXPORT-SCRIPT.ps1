# WordPress Pages Export Script
# Run this at the END of every development session
# Purpose: Capture all page changes to restore/pages/ folder (Git-tracked backup)

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  WordPress Pages Export - End of Session Backup             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Get all page IDs
Write-Host "`n📋 Getting all pages..." -ForegroundColor Yellow
$pageIds = podman exec wp bash -c "wp post list --post_type=page --format=ids --allow-root" 2>&1 | Select-String -Pattern "^\d" | Out-String
$pageIds = $pageIds.Trim().Split(' ') | Where-Object { $_ -ne "" }

Write-Host "Found $($pageIds.Count) pages to export" -ForegroundColor Green

# Export each page
$exported = 0
$errors = 0

foreach ($id in $pageIds) {
    try {
        Write-Host "  Exporting page $id..." -ForegroundColor Gray
        
        # Get page info for filename
        $pageJson = podman exec wp bash -c "wp post get $id --format=json --allow-root" 2>&1
        $pageInfo = $pageJson | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        if ($pageInfo) {
            $slug = $pageInfo.post_name
            
            # Export page metadata
            $pageJson | Out-File -Encoding UTF8 "restore/pages/${slug}-${id}.json" -Force
            
            # Export Elementor data
            podman exec wp bash -c "wp post meta get $id _elementor_data --allow-root" 2>&1 | Out-File -Encoding UTF8 "restore/pages/${slug}-${id}-elementor.json" -Force
            
            $exported++
            Write-Host "    ✓ ${slug}-${id}.json" -ForegroundColor Green
        } else {
            Write-Host "    ✗ Failed to get page info for ID $id" -ForegroundColor Red
            $errors++
        }
    } catch {
        Write-Host "    ✗ Error exporting page $id : $_" -ForegroundColor Red
        $errors++
    }
}

# Verification
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Export Summary                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nPages exported: $exported of $($pageIds.Count)" -ForegroundColor White
Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })

$fileCount = (Get-ChildItem restore/pages/*.json | Measure-Object).Count
$expectedCount = $pageIds.Count * 2  # metadata + elementor for each page

Write-Host "`nFiles in restore/pages/: $fileCount" -ForegroundColor White
Write-Host "Expected: $expectedCount (pages × 2)" -ForegroundColor Gray

if ($fileCount -ge $expectedCount) {
    Write-Host "`n✅ Export complete!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  File count mismatch - verify exports" -ForegroundColor Yellow
}

# Show recent files
Write-Host "`nRecently modified files:" -ForegroundColor Cyan
Get-ChildItem restore/pages/*.json | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | Select-Object Name, @{N="Size KB";E={[math]::Round($_.Length/1KB,1)}}, LastWriteTime | Format-Table -AutoSize

Write-Host "`n💡 Next step: Commit changes to Git" -ForegroundColor Yellow
Write-Host "   git add restore/pages/" -ForegroundColor Gray
Write-Host "   git commit -m 'Update page exports - [session date]'" -ForegroundColor Gray
Write-Host "   git push origin develop" -ForegroundColor Gray
