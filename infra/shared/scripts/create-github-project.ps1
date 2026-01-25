<#
.SYNOPSIS
    Create GitHub Project Kanban board from WORDPRESS-MVP-TASKS.csv

.DESCRIPTION
    This script creates a GitHub Project (v2) and populates it with issues
    from the WORDPRESS-MVP-TASKS.csv file. It creates proper columns and
    organizes tasks by phase and priority.

.NOTES
    Requires: gh CLI with 'project' and 'read:project' scopes
    Run: gh auth refresh -s project,read:project
#>

param(
    [string]$Owner = "talendelight",
    [string]$Repo = "wordpress",
    [string]$CsvPath = "C:\Users\codes\OneDrive\Lochness\TalenDelight\Documents\WORDPRESS-MVP-TASKS.csv",
    [switch]$DryRun
)

Write-Host "`n=== GitHub Project Creation Script ===" -ForegroundColor Cyan
Write-Host "Owner: $Owner" -ForegroundColor Yellow
Write-Host "Repo: $Repo" -ForegroundColor Yellow
Write-Host "CSV: $CsvPath" -ForegroundColor Yellow

# Import CSV
Write-Host "`nImporting CSV..." -ForegroundColor Cyan
$tasks = Import-Csv $CsvPath -Delimiter ';'
Write-Host "✓ Loaded $($tasks.Count) tasks" -ForegroundColor Green

# Filter out completed tasks
$todoTasks = $tasks | Where-Object { $_.Status -eq 'Todo' }
Write-Host "✓ Found $($todoTasks.Count) Todo tasks (excluding $($tasks.Count - $todoTasks.Count) Done)" -ForegroundColor Green

if ($DryRun) {
    Write-Host "`n=== DRY RUN MODE ===" -ForegroundColor Yellow
    Write-Host "Would create issues for the following tasks:`n"
    
    $todoTasks | Group-Object Phase | ForEach-Object {
        Write-Host "`n$($_.Name) ($($_.Count) tasks):" -ForegroundColor Cyan
        $_.Group | ForEach-Object {
            Write-Host "  - [$($_.'Task ID')] $($_.'Task Name')" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nTo execute, run without -DryRun flag" -ForegroundColor Yellow
    exit 0
}

# Create GitHub Project
Write-Host "`n=== Creating GitHub Project ===" -ForegroundColor Cyan
Write-Host "Running: gh project create --owner $Owner --title 'WordPress MVP - v3.6.0 (Jan-May 2026)'" -ForegroundColor Gray

try {
    $projectJson = gh project create --owner $Owner --title "WordPress MVP - v3.6.0 (Jan-May 2026)" --format json 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Failed to create project" -ForegroundColor Red
        Write-Host "Error: $projectJson" -ForegroundColor Red
        Write-Host "`nYou may need to refresh GitHub CLI authentication:" -ForegroundColor Yellow
        Write-Host "  gh auth refresh -s project,read:project" -ForegroundColor Yellow
        exit 1
    }
    
    $project = $projectJson | ConvertFrom-Json
    Write-Host "✓ Created project: $($project.title) (ID: $($project.id))" -ForegroundColor Green
    Write-Host "  URL: $($project.url)" -ForegroundColor Gray
    
} catch {
    Write-Host "✗ Error creating project: $_" -ForegroundColor Red
    exit 1
}

# Note: GitHub Projects v2 API requires GraphQL for field/column setup
# The following is a simplified version - full automation requires GraphQL

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Open project URL: $($project.url)"
Write-Host "2. Manually create columns:"
Write-Host "   - Foundation (Done)"
Write-Host "   - Phase 0 (Jan 23-25)"
Write-Host "   - Phase 1 (Jan 26 - Mar 01)"
Write-Host "   - Phase 2 (Mar 02 - Apr 12)"
Write-Host "   - Phase 3 (Apr 13 - Apr 26)"
Write-Host "   - Phase 4 (Apr 27 - May 03)"
Write-Host "   - Post-MVP"
Write-Host "   - Strategic"
Write-Host ""
Write-Host "3. Run import-tasks-to-project.ps1 to create issues"

Write-Host "`n✓ Project created successfully!" -ForegroundColor Green
