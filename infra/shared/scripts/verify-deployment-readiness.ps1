#Requires -Version 5.1

<#
.SYNOPSIS
    Pre-commit deployment verification checklist
.DESCRIPTION
    Analyzes git changes and provides deployment guidance
    Run this BEFORE committing to develop or main branches
.EXAMPLE
    powershell infra/shared/scripts/verify-deployment-readiness.ps1
#>

param(
    [switch]$Verbose
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Deployment Readiness Verification" -ForegroundColor Cyan  
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Analyzing changes for deployment requirements..."
Write-Host ""

# 1. Check new untracked files
Write-Host "=== New Untracked Files ===" -ForegroundColor Green
$newFilesRaw = git ls-files --others --exclude-standard 2>$null
$newFiles = $newFilesRaw | Where-Object { 
    $_ -match '(wp-content/(mu-plugins|themes|plugins)|restore/(pages|mu-plugins)|infra/shared/db)' 
}

$deployableNewFiles = @()
$manualNewFiles = @()

foreach ($file in $newFiles) {
    if ($file -match 'wp-content/(mu-plugins|themes/[^/]+/assets|themes/[^/]+/.*\.(php|css|js))') {
        Write-Host "   [AUTO-DEPLOY] $file" -ForegroundColor Green
        $deployableNewFiles += $file
    } elseif ($file -match 'restore/pages/.*\.html') {
        Write-Host "   [MANUAL] $file (page content)" -ForegroundColor Yellow
        $manualNewFiles += $file
    } elseif ($file -match 'restore/mu-plugins/.*\.php') {
        Write-Host "   [MANUAL] $file (needs copy to wp-content/mu-plugins/)" -ForegroundColor Yellow
        $manualNewFiles += $file
    } elseif ($file -match 'infra/shared/db/.*\.sql') {
        Write-Host "   [MANUAL] $file (database migration)" -ForegroundColor Yellow
        $manualNewFiles += $file
    } else {
        Write-Host "   [OTHER] $file" -ForegroundColor Gray
    }
}

if ($newFiles.Count -eq 0) {
    Write-Host "   (none)" -ForegroundColor Gray
}

# 2. Check modified tracked files
Write-Host ""
Write-Host "=== Modified Tracked Files ===" -ForegroundColor Yellow
$modifiedFilesRaw = git diff --name-only HEAD 2>$null
$modifiedFiles = $modifiedFilesRaw | Where-Object { 
    $_ -match '(wp-content/(mu-plugins|themes|plugins))' 
}

$deployableModifiedFiles = @()
foreach ($file in $modifiedFiles) {
    Write-Host "   [AUTO-DEPLOY] $file" -ForegroundColor Green
    $deployableModifiedFiles += $file
}

if ($modifiedFiles.Count -eq 0) {
    Write-Host "   (none)" -ForegroundColor Gray
}

# 3. Check recent page backups
Write-Host ""
Write-Host "=== Recent Page Content Changes ===" -ForegroundColor Magenta
$recentPages = Get-ChildItem restore\pages\ -Filter "*.html" -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-24) } |
    Sort-Object LastWriteTime -Descending

foreach ($page in $recentPages) {
    $pageId = "unknown"
    if ($page.Name -match '-(\d+)\.html$') { 
        $pageId = $matches[1]
    }
    $ageMinutes = [math]::Round(((Get-Date) - $page.LastWriteTime).TotalMinutes)
    Write-Host "   [PAGE $pageId] $($page.Name) ($ageMinutes minutes ago)" -ForegroundColor Cyan
}

if ($recentPages.Count -eq 0) {
    Write-Host "   (none in last 24 hours)" -ForegroundColor Gray
}

# 4. Summary and recommendations
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " DEPLOYMENT SUMMARY" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Auto-Deploy Files (add to git, push to main):" -ForegroundColor Green
$allAutoDeploy = $deployableNewFiles + $deployableModifiedFiles
if ($allAutoDeploy.Count -gt 0) {
    foreach ($file in $allAutoDeploy) {
        Write-Host "   * $file"
    }
    Write-Host ""
    Write-Host "   Command:" -ForegroundColor Gray
    Write-Host "   git add $($allAutoDeploy -join ' ')" -ForegroundColor White
} else {
    Write-Host "   (none)"
}

Write-Host ""
Write-Host "Manual Deployment Required:" -ForegroundColor Yellow
if ($manualNewFiles.Count -gt 0 -or $recentPages.Count -gt 0) {
    foreach ($file in $manualNewFiles) {
        if ($file -match 'restore/pages/(.+)-(\d+)\.html') {
            $pageName = $matches[1]
            $pageId = $matches[2]
            Write-Host "   [Page $pageId] ($pageName): Use restore-page-${pageId}.php script"
        } elseif ($file -match 'restore/mu-plugins/(.+)') {
            Write-Host "   [MU Plugin] Copy $file to wp-content/mu-plugins/, then git add"
        } elseif ($file -match 'infra/shared/db/(.+)') {
            Write-Host "   [Database] Apply $file via wp-cli or phpMyAdmin"
        } else {
            Write-Host "   * $file"
        }
    }
    foreach ($page in $recentPages) {
        if ($page.Name -match '(.+)-(\d+)\.html') {
            $pageName = $matches[1]
            $pageId = $matches[2]
            Write-Host "   [Page $pageId] ($pageName): Content changed, needs deployment"
        }
    }
} else {
    Write-Host "   (none)"
}

# 5. Review questions
Write-Host ""
Write-Host "REVIEW QUESTIONS (discuss with team):" -ForegroundColor Cyan

$hasNewJS = $deployableNewFiles | Where-Object { $_ -match '\.js$' }
if ($hasNewJS) {
    Write-Host "   [?] New JavaScript files detected:" -ForegroundColor Yellow
    Write-Host "       - Are they properly enqueued (wp_enqueue_scripts)?"
    Write-Host "       - Version number set for cache busting?"
    Write-Host "       - Loaded on correct pages only?"
}

$hasNewMUPlugin = $deployableNewFiles | Where-Object { $_ -match 'wp-content/mu-plugins/.*\.php$' }
if ($hasNewMUPlugin) {
    Write-Host "   [?] New MU plugins detected:" -ForegroundColor Yellow
    Write-Host "       - Auto-activate behavior documented?"
    Write-Host "       - Dependencies checked?"
    Write-Host "       - Tested in local environment?"
}

$hasModifiedMUPlugin = $deployableModifiedFiles | Where-Object { $_ -match 'wp-content/mu-plugins/.*\.php$' }
if ($hasModifiedMUPlugin) {
    Write-Host "   [!] Modified MU plugins detected:" -ForegroundColor Yellow
    Write-Host "       - Backward compatible changes?"
    Write-Host "       - Breaking changes coordinated?"
}

if ($recentPages.Count -gt 0) {
    Write-Host "   [!] Page content changes detected:" -ForegroundColor Yellow
    Write-Host "       - Restore scripts created?"
    Write-Host "       - Page IDs documented in release notes?"
    Write-Host "       - Deployment instructions updated?"
}

# 6. Next steps
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "   1. Review the files above"
Write-Host "   2. Answer review questions"
Write-Host "   3. Add files to git: git add [files]"
Write-Host "   4. Update release notes with manual steps"
Write-Host "   5. Commit with descriptive message"
Write-Host "   6. Push to develop, then merge to main"
Write-Host ""
Write-Host "   See: docs/procedures/DEPLOYMENT-WORKFLOW.md"
Write-Host ""

# Exit with status code
if ($manualNewFiles.Count -gt 0 -or $recentPages.Count -gt 0) {
    Write-Host "[!] Manual deployment steps required - review before proceeding" -ForegroundColor Yellow
    Write-Host ""
    exit 1
} else {
    Write-Host "[OK] All changes are auto-deployable - safe to commit and push" -ForegroundColor Green
    Write-Host ""
    exit 0
}
