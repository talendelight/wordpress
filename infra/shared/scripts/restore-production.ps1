#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Restore production from backup
.DESCRIPTION
    Restores WordPress content from timestamped backup
    Can restore pages, options, theme files, patterns, or full database
.PARAMETER BackupTimestamp
    Timestamp of backup to restore (format: yyyyMMdd-HHmm)
    Use 'latest' for most recent backup
.PARAMETER RestorePages
    Restore WordPress pages (default: $true)
.PARAMETER RestoreOptions
    Restore WordPress options (default: $true)
.PARAMETER RestoreTheme
    Restore theme files (default: $false)
.PARAMETER RestoreDatabase
    Restore full database (default: $false, DESTRUCTIVE)
.PARAMETER DryRun
    Preview restore actions without executing (default: $false)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupTimestamp = "latest",
    
    [bool]$RestorePages = $true,
    [bool]$RestoreOptions = $true,
    [bool]$RestoreTheme = $false,
    [bool]$RestoreDatabase = $false,
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$SSH_USER = "u909075950"
$SSH_HOST = "45.84.205.129"
$WP_ROOT = "domains/hireaccord.com/public_html"
$BACKUP_ROOT = "c:\data\lochness\talendelight\code\wordpress\restore"

Write-Host "=== Production Restore Started ===" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}

# Find backup
if ($BackupTimestamp -eq "latest") {
    $latestFile = Join-Path $BACKUP_ROOT "backups\LATEST.txt"
    
    if (Test-Path $latestFile) {
        $BackupTimestamp = Get-Content $latestFile
        Write-Host "Using latest backup: $BackupTimestamp" -ForegroundColor Gray
    } else {
        throw "No latest backup marker found. Run backup-production.ps1 first."
    }
}

$BACKUP_DIR = Join-Path $BACKUP_ROOT "backups\$BackupTimestamp"

if (-not (Test-Path $BACKUP_DIR)) {
    throw "Backup not found: $BACKUP_DIR"
}

Write-Host "Backup location: $BACKUP_DIR" -ForegroundColor Gray

# Load manifest
$manifestFile = Join-Path $BACKUP_DIR "manifest.json"

if (-not (Test-Path $manifestFile)) {
    throw "Backup manifest not found: $manifestFile"
}

$manifest = Get-Content $manifestFile | ConvertFrom-Json
Write-Host "Backup date: $($manifest.date)" -ForegroundColor Gray
Write-Host "Items in backup: $($manifest.items.Count)" -ForegroundColor Gray

$restored = 0
$failed = 0

try {
    # 1. Restore pages
    if ($RestorePages) {
        Write-Host "`n1. Restoring WordPress pages..." -ForegroundColor Yellow
        
        $pagesDir = Join-Path $BACKUP_DIR "pages"
        
        if (Test-Path $pagesDir) {
            $pageFiles = Get-ChildItem -Path $pagesDir -Filter "*.json"
            
            foreach ($pageFile in $pageFiles) {
                $pageData = Get-Content $pageFile.FullName | ConvertFrom-Json
                
                Write-Host "  Restoring: $($pageData.post_title) (ID: $($pageData.ID))" -ForegroundColor Gray
                
                if (-not $DryRun) {
                    # Upload page JSON to production
                    scp $pageFile.FullName "$SSH_USER@${SSH_HOST}:~/restore-page-temp.json" 2>&1 | Out-Null
                    
                    if ($LASTEXITCODE -ne 0) {
                        Write-Host "    âœ— Upload failed" -ForegroundColor Red
                        $failed++
                        continue
                    }
                    
                    # Create restore script
                    $restoreScript = @"
<?php
require_once('$WP_ROOT/wp-load.php');

`$json = file_get_contents('/home/$SSH_USER/restore-page-temp.json');
`$data = json_decode(`$json, true);

if (!`$data) {
    echo 'Error: Could not parse JSON';
    exit(1);
}

// Check if page exists
`$existing = get_page_by_path(`$data['post_name'], OBJECT, 'page');

if (`$existing) {
    // Update existing
    `$result = wp_update_post([
        'ID' => `$existing->ID,
        'post_content' => `$data['post_content'],
        'post_title' => `$data['post_title'],
        'post_status' => `$data['post_status'],
    ]);
    
    echo `$existing->ID;
} else {
    // Create new
    `$post_id = wp_insert_post([
        'post_title' => `$data['post_title'],
        'post_name' => `$data['post_name'],
        'post_content' => `$data['post_content'],
        'post_status' => `$data['post_status'],
        'post_type' => 'page',
        'comment_status' => `$data['comment_status'],
        'ping_status' => `$data['ping_status'],
    ]);
    
    if (is_wp_error(`$post_id)) {
        echo 'Error: ' . `$post_id->get_error_message();
        exit(1);
    }
    
    echo `$post_id;
}
"@
                    
                    $restoreScript | Out-File -FilePath "$env:TEMP\restore-page.php" -Encoding UTF8
                    scp "$env:TEMP\restore-page.php" "$SSH_USER@${SSH_HOST}:~/restore-page.php" 2>&1 | Out-Null
                    
                    # Execute restore
                    $result = ssh "$SSH_USER@$SSH_HOST" "php ~/restore-page.php"
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "    âœ“ Restored (ID: $result)" -ForegroundColor Green
                        $restored++
                    } else {
                        Write-Host "    âœ— Restore failed: $result" -ForegroundColor Red
                        $failed++
                    }
                } else {
                    Write-Host "    [DRY RUN] Would restore" -ForegroundColor Cyan
                }
            }
        } else {
            Write-Host "  âš  No pages found in backup" -ForegroundColor Yellow
        }
    }
    
    # 2. Restore options
    if ($RestoreOptions) {
        Write-Host "`n2. Restoring WordPress options..." -ForegroundColor Yellow
        
        $optionsFile = Join-Path $BACKUP_DIR "options.json"
        
        if (Test-Path $optionsFile) {
            $options = Get-Content $optionsFile | ConvertFrom-Json
            
            foreach ($prop in $options.PSObject.Properties) {
                $optionName = $prop.Name
                $optionValue = $prop.Value
                
                Write-Host "  Setting: $optionName" -ForegroundColor Gray
                
                if (-not $DryRun) {
                    # Escape value for shell
                    $valueJson = $optionValue | ConvertTo-Json -Compress
                    $cmd = "cd $WP_ROOT && wp option update $optionName '$valueJson' --format=json --allow-root"
                    
                    ssh "$SSH_USER@$SSH_HOST" $cmd 2>&1 | Out-Null
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "    âœ“ Updated" -ForegroundColor Green
                        $restored++
                    } else {
                        Write-Host "    âœ— Failed" -ForegroundColor Red
                        $failed++
                    }
                } else {
                    Write-Host "    [DRY RUN] Would update" -ForegroundColor Cyan
                }
            }
        } else {
            Write-Host "  âš  No options found in backup" -ForegroundColor Yellow
        }
    }
    
    # 3. Restore theme files
    if ($RestoreTheme) {
        Write-Host "`n3. Restoring theme files..." -ForegroundColor Yellow
        
        $themeDir = Join-Path $BACKUP_DIR "theme"
        
        if (Test-Path $themeDir) {
            $themeFiles = Get-ChildItem -Path $themeDir -Recurse -File
            
            foreach ($file in $themeFiles) {
                $relativePath = $file.FullName.Substring($themeDir.Length + 1)
                Write-Host "  Uploading: $relativePath" -ForegroundColor Gray
                
                if (-not $DryRun) {
                    $destPath = "wp-content/themes/blocksy-child/$relativePath"
                    scp $file.FullName "$SSH_USER@${SSH_HOST}:$WP_ROOT/$destPath" 2>&1 | Out-Null
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "    âœ“ Uploaded" -ForegroundColor Green
                        $restored++
                    } else {
                        Write-Host "    âœ— Upload failed" -ForegroundColor Red
                        $failed++
                    }
                } else {
                    Write-Host "    [DRY RUN] Would upload" -ForegroundColor Cyan
                }
            }
        } else {
            Write-Host "  âš  No theme files found in backup" -ForegroundColor Yellow
        }
    }
    
    # 4. Restore database (DESTRUCTIVE)
    if ($RestoreDatabase) {
        Write-Host "`n4. Restoring database..." -ForegroundColor Yellow
        Write-Host "  âš  WARNING: This will overwrite the entire database!" -ForegroundColor Red
        
        if (-not $DryRun) {
            $confirm = Read-Host "  Type 'YES' to confirm database restore"
            
            if ($confirm -ne "YES") {
                Write-Host "  Database restore cancelled" -ForegroundColor Yellow
            } else {
                $dbFile = Join-Path $BACKUP_DIR "database.sql"
                
                if (Test-Path $dbFile) {
                    Write-Host "  Uploading database dump..." -ForegroundColor Gray
                    scp $dbFile "$SSH_USER@${SSH_HOST}:~/restore-database.sql" 2>&1 | Out-Null
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "  Importing database..." -ForegroundColor Gray
                        $cmd = "cd $WP_ROOT && wp db import ~/restore-database.sql --allow-root"
                        ssh "$SSH_USER@$SSH_HOST" $cmd
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "  âœ“ Database restored" -ForegroundColor Green
                            $restored++
                        } else {
                            Write-Host "  âœ— Database import failed" -ForegroundColor Red
                            $failed++
                        }
                    } else {
                        Write-Host "  âœ— Database upload failed" -ForegroundColor Red
                        $failed++
                    }
                } else {
                    Write-Host "  âš  No database dump found in backup" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "  [DRY RUN] Would restore database (DESTRUCTIVE)" -ForegroundColor Cyan
        }
    }
    
    # Flush cache
    if (-not $DryRun) {
        Write-Host "`nFlushing cache..." -ForegroundColor Yellow
        ssh "$SSH_USER@$SSH_HOST" "cd $WP_ROOT && wp cache flush --allow-root" 2>&1 | Out-Null
        Write-Host "âœ“ Cache flushed" -ForegroundColor Green
    }
    
    # Summary
    Write-Host "`n=== Restore Summary ===" -ForegroundColor Cyan
    Write-Host "Items restored: $restored" -ForegroundColor Green
    Write-Host "Items failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
    
    if ($DryRun) {
        Write-Host "`nDRY RUN complete - no changes made" -ForegroundColor Yellow
    } else {
        Write-Host "`nâœ“ Restore complete" -ForegroundColor Green
    }
    
    return $(if ($failed -eq 0) { 0 } else { 1 })
    
} catch {
    Write-Host "`nâœ— Restore failed: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    return 1
}
