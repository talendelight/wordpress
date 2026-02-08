# WordPress Pages Import Script
# Import pages from restore/pages/ folder JSON files
# Usage: pwsh restore/pages/IMPORT-SCRIPT.ps1 [page-ID or "all"]

param(
    [string]$PageId = "all"
)

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  WordPress Pages Import - Restore from Backup               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Get all page JSON files
$pageFiles = Get-ChildItem restore/pages/*.json -Exclude "*-elementor.json"

if ($PageId -ne "all") {
    # Import specific page
    $pageFiles = $pageFiles | Where-Object { $_.Name -match "-$PageId\.json$" }
    if (-not $pageFiles) {
        Write-Host "`n❌ No page found with ID: $PageId" -ForegroundColor Red
        Write-Host "Available pages:" -ForegroundColor Yellow
        Get-ChildItem restore/pages/*.json -Exclude "*-elementor.json" | ForEach-Object {
            if ($_.Name -match '-(\d+)\.json$') {
                Write-Host "  ID: $($Matches[1]) - $($_.Name)" -ForegroundColor Gray
            }
        }
        exit 1
    }
    Write-Host "`n📋 Importing page ID: $PageId" -ForegroundColor Yellow
} else {
    Write-Host "`n📋 Importing all $($pageFiles.Count) pages" -ForegroundColor Yellow
}

$imported = 0
$updated = 0
$errors = 0

foreach ($file in $pageFiles) {
    try {
        # Extract page ID from filename
        if ($file.Name -match '-(\d+)\.json$') {
            $id = $Matches[1]
            $slug = $file.BaseName -replace "-$id$", ""
            
            Write-Host "`n  Processing: $slug (ID: $id)" -ForegroundColor Cyan
            
            # Read page data
            $pageData = Get-Content $file.FullName -Raw | ConvertFrom-Json
            
            # Check if page exists
            $exists = podman exec wp bash -c "wp post exists $id --allow-root" 2>&1
            
            if ($exists -match "Success") {
                # Update existing page
                Write-Host "    Updating existing page..." -ForegroundColor Gray
                
                # Create temporary JSON file in container
                $pageJson = $pageData | ConvertTo-Json -Depth 100
                $pageJson | podman exec -i wp bash -c "cat > /tmp/page-$id.json"
                
                # Update via wp-cli
                $result = podman exec wp bash -c "wp post update $id --post_content='$(($pageData.post_content -replace "'", "\'"))' --post_title='$($pageData.post_title)' --post_status='$($pageData.post_status)' --allow-root" 2>&1
                
                if ($result -match "Success") {
                    Write-Host "    ✓ Page updated" -ForegroundColor Green
                    $updated++
                } else {
                    Write-Host "    ✗ Failed to update page" -ForegroundColor Red
                    $errors++
                    continue
                }
            } else {
                # Create new page
                Write-Host "    Creating new page..." -ForegroundColor Gray
                
                $result = podman exec wp bash -c "wp post create --post_type=page --post_title='$($pageData.post_title)' --post_name='$($pageData.post_name)' --post_content='$(($pageData.post_content -replace "'", "\'"))' --post_status='$($pageData.post_status)' --post_parent=$($pageData.post_parent) --menu_order=$($pageData.menu_order) --import_id=$id --allow-root" 2>&1
                
                if ($result -match "Success|Created post") {
                    Write-Host "    ✓ Page created" -ForegroundColor Green
                    $imported++
                } else {
                    Write-Host "    ✗ Failed to create page" -ForegroundColor Red
                    $errors++
                    continue
                }
            }
            
            # Import Elementor data if exists
            $elementorFile = "restore/pages/${slug}-${id}-elementor.json"
            if (Test-Path $elementorFile) {
                Write-Host "    Importing Elementor data..." -ForegroundColor Gray
                
                $elementorData = Get-Content $elementorFile -Raw
                # Remove JSON formatting if it's wrapped
                if ($elementorData -match '^\[') {
                    $elementorData = ($elementorData | ConvertFrom-Json)
                }
                
                # Escape for shell
                $elementorDataEscaped = $elementorData -replace "'", "'\\''"
                
                $result = podman exec wp bash -c "wp post meta update $id _elementor_data '$elementorDataEscaped' --allow-root" 2>&1
                
                if ($result -match "Success|Updated") {
                    Write-Host "    ✓ Elementor data imported" -ForegroundColor Green
                } else {
                    Write-Host "    ⚠ Elementor import issue (non-critical)" -ForegroundColor Yellow
                }
            }
            
        }
    } catch {
        Write-Host "    ✗ Error: $_" -ForegroundColor Red
        $errors++
    }
}

# Summary
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Import Summary                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nNew pages created: $imported" -ForegroundColor White
Write-Host "Existing pages updated: $updated" -ForegroundColor White
Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })

if ($imported -gt 0 -or $updated -gt 0) {
    Write-Host "`n✅ Import complete!" -ForegroundColor Green
    Write-Host "`n💡 Next steps:" -ForegroundColor Yellow
    Write-Host "   - Verify pages at https://wp.local/wp-admin/edit.php?post_type=page" -ForegroundColor Gray
    Write-Host "   - Flush permalinks: podman exec wp wp rewrite flush --allow-root" -ForegroundColor Gray
}
