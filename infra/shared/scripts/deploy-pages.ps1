#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy WordPress pages to any environment
.DESCRIPTION
    Unified script to deploy page content from restore/pages/ to Local or Production
    Finds pages by slug dynamically - no ID mapping needed
    Creates pages if they don't exist
.PARAMETER Environment
    Target environment: 'Local' or 'Production' (default: Local)
.PARAMETER PageNames
    Array of page slugs to deploy (e.g., 'privacy-policy', 'cookie-policy')
    If not specified, prompts user to select from available pages
.PARAMETER DryRun
    Preview deployment without making changes
.EXAMPLE
    .\deploy-pages.ps1 -Environment Production -PageNames 'privacy-policy','cookie-policy'
.EXAMPLE
    .\deploy-pages.ps1 -Environment Local -PageNames 'welcome'
.EXAMPLE
    .\deploy-pages.ps1 -DryRun
#>

param(
    [ValidateSet('Local', 'Production')]
    [string]$Environment = 'Local',
    
    [string[]]$PageNames,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Environment-specific configuration
$envConfig = @{
    'Local' = @{
        Name = 'Local WordPress'
        URL = 'https://wp.local'
        WpRoot = '/var/www/html'
        CacheFlush = { 
            podman exec wp bash -c "wp cache flush --allow-root 2>/dev/null" 2>$null | Out-Null
        }
    }
    'Production' = @{
        Name = 'hireaccord.com'
        URL = 'https://hireaccord.com'
        WpRoot = 'domains/hireaccord.com/public_html'
        SSHUser = 'u909075950'
        SSHHost = '45.84.205.129'
        SSHKey = 'tmp/hostinger_deploy_key'
        CacheFlush = {
            ssh -i $envConfig.Production.SSHKey -p 65002 "$($envConfig.Production.SSHUser)@$($envConfig.Production.SSHHost)" "cd $($envConfig.Production.WpRoot) && wp cache flush --allow-root && wp litespeed-purge all --allow-root 2>/dev/null || true" | Out-Null
        }
    }
}

$config = $envConfig[$Environment]
$PAGES_DIR = "restore/pages"

Write-Host "`n=== Page Deployment ===" -ForegroundColor Cyan
Write-Host "Target: $($config.Name)" -ForegroundColor Gray
Write-Host "Environment: $Environment" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made`n" -ForegroundColor Yellow
}

# Get available pages from restore/pages/
$availablePages = Get-ChildItem -Path $PAGES_DIR -Filter "*.html" | ForEach-Object {
    if ($_.Name -match '^(.+?)-(\d+)\.html$') {
        @{
            slug = $Matches[1]
            localId = [int]$Matches[2]
            file = $_.FullName
            name = $_.Name
        }
    }
}

if (-not $availablePages) {
    throw "No pages found in $PAGES_DIR"
}

# If no pages specified, show available and prompt
if (-not $PageNames) {
    Write-Host "`nAvailable pages:" -ForegroundColor Cyan
    $availablePages | ForEach-Object { Write-Host "  • $($_.slug)" -ForegroundColor White }
    Write-Host ""
    $response = Read-Host "Enter page slugs to deploy (comma-separated) or 'all'"
    
    if ($response -eq 'all') {
        $PageNames = $availablePages | ForEach-Object { $_.slug }
    } else {
        $PageNames = $response -split ',' | ForEach-Object { $_.Trim() }
    }
}

# Filter selected pages
$pagesToDeploy = $availablePages | Where-Object { $_.slug -in $PageNames }

if (-not $pagesToDeploy) {
    throw "No matching pages found for: $($PageNames -join ', ')"
}

Write-Host "`nPages to deploy:" -ForegroundColor Cyan
$pagesToDeploy | ForEach-Object { Write-Host "  • $($_.slug)" -ForegroundColor White }
Write-Host ""

# Deploy each page
$deployed = 0
$failed = 0

foreach ($page in $pagesToDeploy) {
    $slug = $page.slug
    $htmlFile = $page.file
    
    Write-Host "Deploying $slug..." -ForegroundColor Yellow
    
    # Read page content
    $content = Get-Content $htmlFile -Raw -Encoding UTF8
    
    if (-not $content) {
        Write-Host "  ❌ Failed to read $($page.name)" -ForegroundColor Red
        $failed++
        continue
    }
    
    # Parse title from HTML (WordPress heading block)
    if ($content -match '<h1[^>]*>([^<]+)</h1>') {
        $title = $Matches[1]
    } else {
        # Fallback: convert slug to title
        $title = ($slug -split '-' | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) }) -join ' '
    }
    
    Write-Host "  Title: $title" -ForegroundColor Gray
    
    if (-not $DryRun) {
        if ($Environment -eq 'Local') {
            # Local deployment using WP-CLI via podman
            # Get page ID by slug
            $pageId = podman exec wp bash -c "wp post list --post_type=page --name=$slug --field=ID --allow-root --skip-plugins 2>/dev/null" 2>$null
            
            if ($pageId) {
                Write-Host "  Found in local: ID $pageId" -ForegroundColor Green
                
                # Update page content
                Get-Content $htmlFile -Raw | podman exec -i wp bash -c "cat > /tmp/page-$pageId.html && wp post update $pageId /tmp/page-$pageId.html --post_content --allow-root --skip-plugins 2>/dev/null && rm /tmp/page-$pageId.html" 2>$null | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅ Updated successfully" -ForegroundColor Green
                    $deployed++
                } else {
                    Write-Host "  ❌ Update failed" -ForegroundColor Red
                    $failed++
                }
            } else {
                # Create new page
                Write-Host "  Page does not exist, creating new..." -ForegroundColor Yellow
                
                $escapedTitle = $title -replace "'", "\'"
                $tempFile = "/tmp/page-$slug.html"
                
                Get-Content $htmlFile -Raw | podman exec -i wp bash -c "cat > $tempFile && wp post create $tempFile --post_type=page --post_title='$escapedTitle' --post_name=$slug --post_status=publish --allow-root --skip-plugins 2>/dev/null && rm $tempFile" 2>$null | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅ Created successfully" -ForegroundColor Green
                    $deployed++
                } else {
                    Write-Host "  ❌ Creation failed" -ForegroundColor Red
                    $failed++
                }
            }
            
        } else {
            # Production deployment using SSH + PHP scripts
            $SSH_USER = $config.SSHUser
            $SSH_HOST = $config.SSHHost
            $SSH_KEY = $config.SSHKey
            $WP_ROOT = $config.WpRoot
            
            # Check if page exists by slug
            $checkScript = @"
<?php
chdir('$WP_ROOT');
require_once('wp-load.php');

`$slug = '$slug';
`$page = get_page_by_path(`$slug, OBJECT, 'page');

if (`$page) {
    echo "EXISTS:" . `$page->ID . "\n";
} else {
    echo "CREATE\n";
}
?>
"@
            
            $checkScript | Out-File -FilePath "tmp/check-page-$slug.php" -Encoding UTF8 -NoNewline
            scp -P 65002 -i $SSH_KEY "tmp/check-page-$slug.php" "${SSH_USER}@${SSH_HOST}:/tmp/" 2>$null
            $checkResult = ssh -i $SSH_KEY -p 65002 "$SSH_USER@$SSH_HOST" "cd $WP_ROOT && php /tmp/check-page-$slug.php && rm /tmp/check-page-$slug.php"
            Remove-Item "tmp/check-page-$slug.php" -Force
            
            if ($checkResult -match 'EXISTS:(\d+)') {
                $pageId = [int]$Matches[1]
                Write-Host "  Found in production: ID $pageId" -ForegroundColor Green
                
                # Upload HTML and update
                $htmlRemotePath = "/tmp/$slug-content.html"
                scp -P 65002 -i $SSH_KEY $htmlFile "${SSH_USER}@${SSH_HOST}:$htmlRemotePath" 2>$null
                
                $updateScript = @"
<?php
chdir('$WP_ROOT');
require_once('wp-load.php');

`$content = file_get_contents('$htmlRemotePath');
if (`$content === false) {
    echo "ERROR: Failed to read content file\n";
    exit(1);
}

`$result = wp_update_post(array(
    'ID' => $pageId,
    'post_content' => `$content,
    'post_status' => 'publish'
));

if (`$result) {
    `$post = get_post($pageId);
    echo "UPDATED:" . strlen(`$post->post_content) . "\n";
} else {
    echo "ERROR: Update failed\n";
    exit(1);
}

unlink('$htmlRemotePath');
?>
"@
                
                $updateScript | Out-File -FilePath "tmp/update-page-$slug.php" -Encoding UTF8 -NoNewline
                scp -P 65002 -i $SSH_KEY "tmp/update-page-$slug.php" "${SSH_USER}@${SSH_HOST}:/tmp/" 2>$null
                $updateResult = ssh -i $SSH_KEY -p 65002 "$SSH_USER@$SSH_HOST" "cd $WP_ROOT && php /tmp/update-page-$slug.php && rm /tmp/update-page-$slug.php"
                Remove-Item "tmp/update-page-$slug.php" -Force
                
                if ($updateResult -match 'UPDATED:(\d+)') {
                    $bytes = $Matches[1]
                    Write-Host "  ✅ Updated successfully ($bytes bytes)" -ForegroundColor Green
                    $deployed++
                } else {
                    Write-Host "  ❌ Update failed: $updateResult" -ForegroundColor Red
                    $failed++
                }
                
            } elseif ($checkResult -match 'CREATE') {
                Write-Host "  Page does not exist, creating new..." -ForegroundColor Yellow
                
                # Upload HTML and create
                $htmlRemotePath = "/tmp/$slug-content.html"
                scp -P 65002 -i $SSH_KEY $htmlFile "${SSH_USER}@${SSH_HOST}:$htmlRemotePath" 2>$null
                
                $createScript = @"
<?php
chdir('$WP_ROOT');
require_once('wp-load.php');

`$content = file_get_contents('$htmlRemotePath');
if (`$content === false) {
    echo "ERROR: Failed to read content file\n";
    exit(1);
}

`$page_id = wp_insert_post(array(
    'post_title' => '$title',
    'post_content' => `$content,
    'post_status' => 'publish',
    'post_type' => 'page',
    'post_name' => '$slug'
));

if (`$page_id) {
    echo "CREATED:`$page_id:" . strlen(`$content) . "\n";
} else {
    echo "ERROR: Creation failed\n";
    exit(1);
}

unlink('$htmlRemotePath');
?>
"@
                
                $createScript | Out-File -FilePath "tmp/create-page-$slug.php" -Encoding UTF8 -NoNewline
                scp -P 65002 -i $SSH_KEY "tmp/create-page-$slug.php" "${SSH_USER}@${SSH_HOST}:/tmp/" 2>$null
                $createResult = ssh -i $SSH_KEY -p 65002 "$SSH_USER@$SSH_HOST" "cd $WP_ROOT && php /tmp/create-page-$slug.php && rm /tmp/create-page-$slug.php"
                Remove-Item "tmp/create-page-$slug.php" -Force
                
                if ($createResult -match 'CREATED:(\d+):(\d+)') {
                    $newId = [int]$Matches[1]
                    $bytes = $Matches[2]
                    Write-Host "  ✅ Created successfully (ID: $newId, $bytes bytes)" -ForegroundColor Green
                    $deployed++
                } else {
                    Write-Host "  ❌ Creation failed: $createResult" -ForegroundColor Red
                    $failed++
                }
            }
        }
    } else {
        Write-Host "  [DRY RUN] Would deploy to $Environment" -ForegroundColor Gray
        $deployed++
    }
    
    Write-Host ""
}

# Flush caches if any pages were deployed
if (-not $DryRun -and $deployed -gt 0) {
    Write-Host "Flushing caches..." -ForegroundColor Yellow
    & $config.CacheFlush
    Write-Host "✅ Caches flushed" -ForegroundColor Green
}

Write-Host "`n=== Deployment Summary ===" -ForegroundColor Cyan
Write-Host "Deployed: $deployed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })

if ($deployed -gt 0) {
    Write-Host "`nVerify at: $($config.URL)" -ForegroundColor Yellow
}
