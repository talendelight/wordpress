#!/usr/bin/env pwsh
# Restore all page content from backups to local WordPress
# Matches pages by slug, not ID (IDs differ between local/production)
# 
# IMPORTANT: Some pages use custom templates stored in wp_postmeta
# See: docs/PAGE-TEMPLATES.md for template restoration guide
# See: docs/lessons/page-template-restoration.md for why this matters

$pageMapping = @(
    @{Slug='welcome'; Backup='welcome-6.html'},
    @{Slug='help'; Backup='help-110.html'},
    @{Slug='select-role'; Backup='select-role-49.html'},
    @{Slug='candidates'; Backup='candidates-7.html'},
    @{Slug='employers'; Backup='employers-64.html'},
    @{Slug='scouts'; Backup='scouts-76.html'},
    @{Slug='managers'; Backup='managers-8.html'},
    @{Slug='operators'; Backup='operators-9.html'},
    @{Slug='admin'; Backup='manager-admin-38.html'},
    @{Slug='actions'; Backup='manager-actions-84.html'},
    @{Slug='register-profile'; Backup='register-profile.html'},
    @{Slug='403-forbidden'; Backup='403-forbidden-44.html'},
    @{Slug='privacy-policy'; Backup='privacy-policy-3.html'}
)

$backupDir = "c:\data\lochness\talendelight\code\wordpress\restore\pages"
$restored = 0
$failed = 0

Write-Host "`nðŸ”„ Restoring page content from backups...`n" -ForegroundColor Cyan

foreach ($page in $pageMapping) {
    $backupFile = Join-Path $backupDir $page.Backup
    
    if (-not (Test-Path $backupFile)) {
        Write-Host "âš ï¸  Backup not found: $($page.Backup)" -ForegroundColor Yellow
        $failed++
        continue
    }
    
    # Get page ID by slug
    $pageId = podman exec wp bash -c "wp post list --post_type=page --name=$($page.Slug) --field=ID --allow-root --skip-plugins 2>/dev/null" 2>$null
    
    if (-not $pageId) {
        Write-Host "âš ï¸  Page not found in database: $($page.Slug)" -ForegroundColor Yellow
        $failed++
        continue
    }
    
    Write-Host "ðŸ“„ Restoring $($page.Slug) (ID: $pageId)..." -NoNewline
    
    # Upload content to container and update page
    Get-Content $backupFile -Raw | podman exec -i wp bash -c "cat > /tmp/page-$pageId.html && wp post update $pageId /tmp/page-$pageId.html --post_content --allow-root --skip-plugins 2>/dev/null && rm /tmp/page-$pageId.html" 2>$null | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        # Special handling for select-role page - requires custom template
        if ($page.Slug -eq 'select-role') {
            podman exec wp bash -c "wp post meta update $pageId _wp_page_template page-role-selection.php --allow-root --skip-plugins 2>/dev/null" 2>$null | Out-Null
        }
        
        Write-Host " âœ…" -ForegroundColor Green
        $restored++
    } else {
        Write-Host " âŒ" -ForegroundColor Red
        $failed++
    }
}

# Flush cache
Write-Host "`nðŸ§¹ Flushing WordPress cache..." -NoNewline
podman exec wp bash -c "wp cache flush --allow-root 2>/dev/null" 2>$null | Out-Null
Write-Host " âœ…" -ForegroundColor Green

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Restored: $restored pages" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "  Failed: $failed pages" -ForegroundColor Red
}

Write-Host "`nPages available at:" -ForegroundColor Cyan
Write-Host "  - Welcome: https://wp.local" -ForegroundColor Gray
Write-Host "  - Help: https://wp.local/help" -ForegroundColor Gray
Write-Host "  - Select Role: https://wp.local/select-role" -ForegroundColor Gray
Write-Host "  - Candidates: https://wp.local/candidates" -ForegroundColor Gray
Write-Host "  - Employers: https://wp.local/employers" -ForegroundColor Gray
Write-Host "  - Manager Admin: https://wp.local/admin" -ForegroundColor Gray
Write-Host "  - Register: https://wp.local/register-profile" -ForegroundColor Gray

