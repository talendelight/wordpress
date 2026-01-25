<#
.SYNOPSIS
    Import ALL tasks from CSV (both Done and Todo) to GitHub Issues

.DESCRIPTION
    Convenience wrapper that imports all 77 tasks:
    - 12 Done tasks (Foundation) - created and closed immediately
    - 65 Todo tasks (Phase 0-4, Post-MVP, Strategic) - created as open issues

.NOTES
    Requires: gh CLI with repo permissions
    
.EXAMPLE
    # Dry run to preview
    .\import-all-tasks.ps1 -DryRun
    
    # Import all 77 tasks
    .\import-all-tasks.ps1
#>

param(
    [string]$Owner = "talendelight",
    [string]$Repo = "wordpress",
    [string]$CsvPath = "C:\Users\codes\OneDrive\Lochness\TalenDelight\Documents\WORDPRESS-MVP-TASKS.csv",
    [switch]$DryRun
)

Write-Host "`n=== Import ALL Tasks to GitHub Issues ===" -ForegroundColor Cyan
Write-Host "This will create 77 issues:" -ForegroundColor Yellow
Write-Host "  - 12 Done tasks (Foundation) - will be closed immediately" -ForegroundColor Gray
Write-Host "  - 65 Todo tasks (Phase 0-4, Post-MVP, Strategic) - open" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "`n=== DRY RUN MODE ===" -ForegroundColor Yellow
    
    # Run dry-run for Done tasks
    Write-Host "`n--- Foundation (Done) ---" -ForegroundColor Cyan
    & "$PSScriptRoot\import-tasks-to-issues.ps1" -Owner $Owner -Repo $Repo -CsvPath $CsvPath -DoneOnly -DryRun
    
    # Run dry-run for Todo tasks
    Write-Host "`n--- Active Tasks (Todo) ---" -ForegroundColor Cyan
    & "$PSScriptRoot\import-tasks-to-issues.ps1" -Owner $Owner -Repo $Repo -CsvPath $CsvPath -TodoOnly -DryRun
    
    Write-Host "`nTo execute, run without -DryRun flag" -ForegroundColor Yellow
    exit 0
}

# Confirm with user
Write-Host "`nThis will create 77 GitHub issues in $Owner/$Repo" -ForegroundColor Yellow
$confirm = Read-Host "Continue? (y/n)"

if ($confirm -ne 'y') {
    Write-Host "Cancelled by user" -ForegroundColor Yellow
    exit 0
}

# Step 1: Import Done tasks (Foundation)
Write-Host "`n=== Step 1: Creating Foundation (Done) Tasks ===" -ForegroundColor Cyan
& "$PSScriptRoot\import-tasks-to-issues.ps1" -Owner $Owner -Repo $Repo -CsvPath $CsvPath -DoneOnly

Write-Host "`nPausing for 5 seconds before importing Todo tasks..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Step 2: Import Todo tasks
Write-Host "`n=== Step 2: Creating Active (Todo) Tasks ===" -ForegroundColor Cyan
& "$PSScriptRoot\import-tasks-to-issues.ps1" -Owner $Owner -Repo $Repo -CsvPath $CsvPath -TodoOnly

Write-Host "`n=== Import Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Visit: https://github.com/$Owner/$Repo/issues" -ForegroundColor Gray
Write-Host "2. Create GitHub Project (Kanban board)" -ForegroundColor Gray
Write-Host "3. Add issues to project and organize by Phase" -ForegroundColor Gray
