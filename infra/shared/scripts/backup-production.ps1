#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Automated production backup script
.DESCRIPTION
    Backs up WordPress pages, posts, options, and database to local restore/ folder
    Maintains timestamped backups with rotation
.PARAMETER MaxBackups
    Maximum number of backup sets to keep (default: 10)
.PARAMETER BackupDatabase
    Whether to backup full database (default: $true)
#>

param(
    [int]$MaxBackups = 10,
    [bool]$BackupDatabase = $true
)

$ErrorActionPreference = "Stop"

# Configuration
$SSH_USER = "u909075950"
$SSH_HOST = "45.84.205.129"
$WP_ROOT = "domains/talendelight.com/public_html"
$BACKUP_ROOT = "c:\data\lochness\talendelight\code\wordpress\restore"
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmm"
$BACKUP_DIR = Join-Path $BACKUP_ROOT "backups\$TIMESTAMP"

Write-Host "=== Production Backup Started ===" -ForegroundColor Cyan
Write-Host "Timestamp: $TIMESTAMP" -ForegroundColor Gray

# Create backup directory
New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
Write-Host "✓ Created backup directory: $BACKUP_DIR" -ForegroundColor Green

# Backup manifest
$manifest = @{
    timestamp = $TIMESTAMP
    date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    items = @()
}

try {
    # 1. Backup all pages
    Write-Host "`n1. Backing up WordPress pages..." -ForegroundColor Yellow
    
    $pagesDir = Join-Path $BACKUP_DIR "pages"
    New-Item -ItemType Directory -Path $pagesDir -Force | Out-Null
    
    # Get page list
    $pageListCmd = "cd $WP_ROOT && wp post list --post_type=page --format=csv --fields=ID,post_title,post_name,post_status --allow-root"
    $pageList = ssh "$SSH_USER@$SSH_HOST" $pageListCmd
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to get page list"
    }
    
    # Parse CSV and backup each page
    $pages = $pageList | ConvertFrom-Csv
    $pageCount = 0
    
    foreach ($page in $pages) {
        $pageId = $page.ID
        $pageName = $page.post_name
        
        # Export as JSON
        $jsonFile = Join-Path $pagesDir "$pageName-$pageId.json"
        $exportCmd = "cd $WP_ROOT && wp post get $pageId --format=json --allow-root"
        $jsonContent = ssh "$SSH_USER@$SSH_HOST" $exportCmd
        
        if ($LASTEXITCODE -eq 0) {
            $jsonContent | Out-File -FilePath $jsonFile -Encoding UTF8
            Write-Host "  ✓ $($page.post_title) (ID: $pageId)" -ForegroundColor Green
            $pageCount++
            
            $manifest.items += @{
                type = "page"
                id = $pageId
                title = $page.post_title
                name = $pageName
                file = "pages/$pageName-$pageId.json"
            }
        } else {
            Write-Host "  ✗ Failed to export $($page.post_title)" -ForegroundColor Red
        }
    }
    
    Write-Host "  Total pages backed up: $pageCount" -ForegroundColor Cyan
    
    # 2. Backup critical options
    Write-Host "`n2. Backing up WordPress options..." -ForegroundColor Yellow
    
    $optionsFile = Join-Path $BACKUP_DIR "options.json"
    $criticalOptions = @(
        'siteurl',
        'home',
        'blogname',
        'blogdescription',
        'show_on_front',
        'page_on_front',
        'page_for_posts',
        'active_plugins',
        'stylesheet',
        'template'
    )
    
    $optionsData = @{}
    foreach ($option in $criticalOptions) {
        $optionCmd = "cd $WP_ROOT && wp option get $option --format=json --allow-root"
        $value = ssh "$SSH_USER@$SSH_HOST" $optionCmd 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            $optionsData[$option] = $value | ConvertFrom-Json
            Write-Host "  ✓ $option" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $option (not found)" -ForegroundColor Yellow
        }
    }
    
    $optionsData | ConvertTo-Json -Depth 10 | Out-File -FilePath $optionsFile -Encoding UTF8
    $manifest.items += @{
        type = "options"
        count = $optionsData.Count
        file = "options.json"
    }
    
    # 3. Backup theme files
    Write-Host "`n3. Backing up theme files..." -ForegroundColor Yellow
    
    $themeDir = Join-Path $BACKUP_DIR "theme"
    New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
    
    $themeFiles = @(
        "wp-content/themes/blocksy-child/functions.php",
        "wp-content/themes/blocksy-child/style.css",
        "wp-content/themes/blocksy-child/assets/"
    )
    
    foreach ($file in $themeFiles) {
        $fileName = Split-Path $file -Leaf
        $destFile = Join-Path $themeDir $fileName
        
        $scpCmd = "scp -r '$SSH_USER@${SSH_HOST}:$WP_ROOT/$file' '$destFile'"
        Invoke-Expression $scpCmd 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $file" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $file (failed)" -ForegroundColor Yellow
        }
    }
    
    # 4. Backup patterns
    Write-Host "`n4. Backing up block patterns..." -ForegroundColor Yellow
    
    $patternsDir = Join-Path $BACKUP_DIR "patterns"
    $patternsSrc = "wp-content/themes/blocksy-child/patterns/"
    
    scp -r "$SSH_USER@${SSH_HOST}:$WP_ROOT/$patternsSrc" "$patternsDir" 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        $patternFiles = Get-ChildItem -Path $patternsDir -Filter "*.php"
        Write-Host "  ✓ Backed up $($patternFiles.Count) patterns" -ForegroundColor Green
        
        $manifest.items += @{
            type = "patterns"
            count = $patternFiles.Count
            file = "patterns/"
        }
    } else {
        Write-Host "  ⚠ Pattern backup failed" -ForegroundColor Yellow
    }
    
    # 5. Backup database (optional)
    if ($BackupDatabase) {
        Write-Host "`n5. Backing up database..." -ForegroundColor Yellow
        
        $dbFile = Join-Path $BACKUP_DIR "database.sql"
        $dbCmd = "cd $WP_ROOT && wp db export - --allow-root"
        
        ssh "$SSH_USER@$SSH_HOST" $dbCmd | Out-File -FilePath $dbFile -Encoding UTF8
        
        if ($LASTEXITCODE -eq 0) {
            $dbSize = (Get-Item $dbFile).Length / 1MB
            Write-Host "  ✓ Database exported ($([math]::Round($dbSize, 2)) MB)" -ForegroundColor Green
            
            $manifest.items += @{
                type = "database"
                size_mb = [math]::Round($dbSize, 2)
                file = "database.sql"
            }
        } else {
            Write-Host "  ✗ Database backup failed" -ForegroundColor Red
        }
    }
    
    # Save manifest
    $manifestFile = Join-Path $BACKUP_DIR "manifest.json"
    $manifest | ConvertTo-Json -Depth 10 | Out-File -FilePath $manifestFile -Encoding UTF8
    Write-Host "`n✓ Backup manifest saved" -ForegroundColor Green
    
    # Create latest symlink/marker
    $latestFile = Join-Path $BACKUP_ROOT "backups\LATEST.txt"
    $TIMESTAMP | Out-File -FilePath $latestFile -Encoding UTF8
    
    Write-Host "`n=== Backup Complete ===" -ForegroundColor Cyan
    Write-Host "Location: $BACKUP_DIR" -ForegroundColor Gray
    Write-Host "Items backed up: $($manifest.items.Count)" -ForegroundColor Gray
    
    # Cleanup old backups
    Write-Host "`nCleaning up old backups (keeping $MaxBackups)..." -ForegroundColor Yellow
    
    $allBackups = Get-ChildItem -Path (Join-Path $BACKUP_ROOT "backups") -Directory | 
                  Where-Object { $_.Name -match '^\d{8}-\d{4}$' } |
                  Sort-Object Name -Descending
    
    if ($allBackups.Count -gt $MaxBackups) {
        $toDelete = $allBackups | Select-Object -Skip $MaxBackups
        
        foreach ($old in $toDelete) {
            Remove-Item -Path $old.FullName -Recurse -Force
            Write-Host "  ✓ Removed old backup: $($old.Name)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n✓ Backup system ready" -ForegroundColor Green
    
    return 0
    
} catch {
    Write-Host "`n✗ Backup failed: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    return 1
}
