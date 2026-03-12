#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy WordPress pages to production with ID mapping
.DESCRIPTION
    Deploys page content from restore/pages/ to hireaccord.com production
    Handles local-to-production ID mapping automatically
    Creates pages if they don't exist
.PARAMETER PageNames
    Array of page slugs to deploy (e.g., 'privacy-policy', 'cookie-policy')
    If not specified, prompts user to select from available pages
.PARAMETER DryRun
    Preview deployment without making changes
.EXAMPLE
    .\deploy-pages-production.ps1 -PageNames 'privacy-policy','cookie-policy'
.EXAMPLE
    .\deploy-pages-production.ps1 -DryRun
#>

param(
    [string[]]$PageNames,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Configuration
$SSH_USER = "u909075950"
$SSH_HOST = "45.84.205.129"
$SSH_KEY = "tmp/hostinger_deploy_key"
$WP_ROOT = "domains/hireaccord.com/public_html"
$PAGES_DIR = "restore/pages"
$MAPPING_FILE = "infra/shared/config/production-page-ids.json"

Write-Host "=== Production Page Deployment ===" -ForegroundColor Cyan
Write-Host "Target: hireaccord.com" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made`n" -ForegroundColor Yellow
}

# Load or create ID mapping
if (Test-Path $MAPPING_FILE) {
    Write-Host "Loading production page ID mappings..." -ForegroundColor Gray
    $idMapping = Get-Content $MAPPING_FILE | ConvertFrom-Json -AsHashtable
} else {
    Write-Host "No ID mapping file found, will query production..." -ForegroundColor Yellow
    $idMapping = @{}
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
    $availablePages | ForEach-Object { Write-Host "  • $($_.slug) (local ID: $($_.localId))" -ForegroundColor White }
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
    $localId = $page.localId
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
    Write-Host "  Local ID: $localId" -ForegroundColor Gray
    
    # Check if we have a production ID mapping
    $productionId = $null
    if ($idMapping.ContainsKey($slug)) {
        $productionId = $idMapping[$slug]
        Write-Host "  Production ID (mapped): $productionId" -ForegroundColor Gray
    }
    
    if (-not $DryRun) {
        # Create temporary PHP deployment script
        $deployScript = @"
<?php
chdir('$WP_ROOT');
require_once('wp-load.php');

`$slug = '$slug';
`$title = '$title';
`$production_id = $productionId;

// Check if page exists
`$page = get_page_by_path(`$slug, OBJECT, 'page');

if (`$page) {
    `$page_id = `$page->ID;
    echo "EXISTS:`$page_id\n";
} elseif (`$production_id) {
    // Check if mapped ID exists
    `$page = get_post(`$production_id);
    if (`$page && `$page->post_type === 'page') {
        `$page_id = `$production_id;
        echo "EXISTS:`$page_id\n";
    } else {
        echo "CREATE\n";
    }
} else {
    echo "CREATE\n";
}
?>
"@
        
        # Upload and execute check script
        $checkScriptPath = "/tmp/check-page-$slug.php"
        $deployScript | Out-File -FilePath "tmp/check-page-$slug.php" -Encoding UTF8 -NoNewline
        
        scp -P 65002 -i $SSH_KEY "tmp/check-page-$slug.php" "${SSH_USER}@${SSH_HOST}:$checkScriptPath" 2>$null
        $checkResult = ssh -i $SSH_KEY -p 65002 "$SSH_USER@$SSH_HOST" "cd $WP_ROOT && php $checkScriptPath && rm $checkScriptPath"
        
        Remove-Item "tmp/check-page-$slug.php" -Force
        
        if ($checkResult -match 'EXISTS:(\d+)') {
            $productionId = [int]$Matches[1]
            Write-Host "  Page exists in production: ID $productionId" -ForegroundColor Green
            
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
    'ID' => $productionId,
    'post_content' => `$content,
    'post_status' => 'publish'
));

if (`$result) {
    `$post = get_post($productionId);
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
                
                # Update mapping
                $idMapping[$slug] = $productionId
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
                
                # Update mapping
                $idMapping[$slug] = $newId
                $deployed++
            } else {
                Write-Host "  ❌ Creation failed: $createResult" -ForegroundColor Red
                $failed++
            }
        }
    } else {
        Write-Host "  [DRY RUN] Would deploy to production" -ForegroundColor Gray
        $deployed++
    }
    
    Write-Host ""
}

# Save updated mapping
if (-not $DryRun -and $deployed -gt 0) {
    $mappingDir = Split-Path $MAPPING_FILE -Parent
    if (-not (Test-Path $mappingDir)) {
        New-Item -ItemType Directory -Path $mappingDir -Force | Out-Null
    }
    
    $idMapping | ConvertTo-Json -Depth 5 | Out-File -FilePath $MAPPING_FILE -Encoding UTF8
    Write-Host "Updated production ID mappings: $MAPPING_FILE" -ForegroundColor Cyan
}

# Flush caches if any pages were deployed
if (-not $DryRun -and $deployed -gt 0) {
    Write-Host "Flushing production caches..." -ForegroundColor Yellow
    ssh -i $SSH_KEY -p 65002 "$SSH_USER@$SSH_HOST" "cd $WP_ROOT && wp cache flush --allow-root && wp litespeed-purge all --allow-root 2>/dev/null || true" | Out-Null
    Write-Host "✅ Caches flushed" -ForegroundColor Green
}

Write-Host "`n=== Deployment Summary ===" -ForegroundColor Cyan
Write-Host "Deployed: $deployed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })

if ($deployed -gt 0) {
    Write-Host "`nVerify at: https://hireaccord.com/" -ForegroundColor Yellow
}
