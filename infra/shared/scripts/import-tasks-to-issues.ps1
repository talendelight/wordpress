<#
.SYNOPSIS
    Import tasks from CSV to GitHub Issues and link to Project

.DESCRIPTION
    Creates GitHub issues from WORDPRESS-MVP-TASKS.csv with proper labels,
    milestones, and metadata. Can optionally link to GitHub Project.

.NOTES
    Requires: gh CLI with repo permissions
    
.EXAMPLE
    # Dry run (all tasks)
    .\import-tasks-to-issues.ps1 -DryRun
    
    # Create only Todo tasks (65 tasks)
    .\import-tasks-to-issues.ps1 -TodoOnly
    
    # Create only Done tasks (12 tasks, will be closed)
    .\import-tasks-to-issues.ps1 -DoneOnly
    
    # Create all 77 tasks (Done will be auto-closed)
    .\import-tasks-to-issues.ps1
    
    # Create Phase 0 tasks only
    .\import-tasks-to-issues.ps1 -Phase "Phase 0" -TodoOnly
#>

param(
    [string]$Owner = "talendelight",
    [string]$Repo = "wordpress",
    [string]$CsvPath = "C:\Users\codes\OneDrive\Lochness\TalenDelight\Documents\WORDPRESS-MVP-TASKS.csv",
    [string]$Phase = $null,  # Filter by phase (e.g., "Phase 0")
    [switch]$DryRun,
    [switch]$TodoOnly,  # Only create Todo tasks (skip Done)
    [switch]$DoneOnly   # Only create Done tasks (will be closed immediately)
)

Write-Host "`n=== GitHub Issues Import Script ===" -ForegroundColor Cyan

# Import CSV
Write-Host "`nLoading CSV from: $CsvPath" -ForegroundColor Cyan
$tasks = Import-Csv $CsvPath -Delimiter ';'
Write-Host " Loaded $($tasks.Count) total tasks" -ForegroundColor Green

# Count by status
$doneCount = ($tasks | Where-Object { $_.Status -eq 'Done' }).Count
$todoCount = ($tasks | Where-Object { $_.Status -eq 'Todo' }).Count
Write-Host "  - Done: $doneCount tasks" -ForegroundColor Gray
Write-Host "  - Todo: $todoCount tasks" -ForegroundColor Gray

# Filter tasks
$filteredTasks = $tasks

if ($TodoOnly) {
    $filteredTasks = $filteredTasks | Where-Object { $_.Status -eq 'Todo' }
    Write-Host " Filtered to $($filteredTasks.Count) Todo tasks only" -ForegroundColor Green
}

if ($DoneOnly) {
    $filteredTasks = $filteredTasks | Where-Object { $_.Status -eq 'Done' }
    Write-Host " Filtered to $($filteredTasks.Count) Done tasks only (will be closed)" -ForegroundColor Green
}

if ($Phase) {
    $filteredTasks = $filteredTasks | Where-Object { $_.Phase -eq $Phase }
    Write-Host " Filtered to $($filteredTasks.Count) tasks in $Phase" -ForegroundColor Green
}

if ($filteredTasks.Count -eq 0) {
    Write-Host " No tasks to import" -ForegroundColor Red
    exit 0
}

# Group by phase
Write-Host "`nTasks to import:" -ForegroundColor Cyan
$filteredTasks | Group-Object Phase | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count) tasks" -ForegroundColor Gray
}

if ($DryRun) {
    Write-Host "`n=== DRY RUN MODE ===" -ForegroundColor Yellow
    Write-Host "`nWould create the following issues:`n"
    
    $filteredTasks | ForEach-Object {
        $labels = @($_.Priority, $_.Phase, $_.Epic.Split(';')[0])
        if ($_.'Group ID') { $labels += $_.'Group ID' }
        if ($_.Executor -eq 'Lawyer') { $labels += 'external-contractor' }
        
        Write-Host "[$($_.'Task ID')] $($_.'Task Name')" -ForegroundColor Cyan
        Write-Host "  Epic: $($_.Epic)" -ForegroundColor Gray
        Write-Host "  Priority: $($_.Priority)" -ForegroundColor Gray
        Write-Host "  Phase: $($_.Phase)" -ForegroundColor Gray
        Write-Host "  Labels: $($labels -join ', ')" -ForegroundColor Gray
        Write-Host "  Dependencies: $($_.Dependencies)" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "To execute, run without -DryRun flag" -ForegroundColor Yellow
    exit 0
}

# Create issues
Write-Host "`n=== Creating Issues ===" -ForegroundColor Cyan
$created = 0
$failed = 0

foreach ($task in $filteredTasks) {
    Write-Host "`nCreating [$($task.'Task ID')] $($task.'Task Name')..." -ForegroundColor Yellow
    
    # Build issue body
    $bodyParts = @()
    $bodyParts += "**Epic:** $($task.Epic)"
    $bodyParts += "**Feature:** $($task.'Feature Name') ($($task.'Feature ID'))"
    $bodyParts += "**Phase:** $($task.Phase) - $($task.'Suggested Window')"
    $bodyParts += "**Priority:** $($task.Priority)"
    $bodyParts += "**Status:** $($task.Status)"
    $bodyParts += "**Version:** $($task.Version)"
    $bodyParts += "**Executor:** $($task.Executor)"
    
    if ($task.'Group ID') {
        $bodyParts += "**Group ID:** $($task.'Group ID')"
    }
    
    if ($task.'Est (Days)') {
        $bodyParts += "**Est (Days):** $($task.'Est (Days)')"
    }
    
    # Add completion dates for Done tasks
    if ($task.Status -eq 'Done' -and $task.'Start Date' -and $task.'End Date') {
        $bodyParts += "**Started:** $($task.'Start Date')"
        $bodyParts += "**Completed:** $($task.'End Date')"
    }
    
    $bodyParts += ""
    $bodyParts += "---"
    $bodyParts += ""
    $bodyParts += "**Description:**"
    $bodyParts += $task.Notes
    
    if ($task.Dependencies) {
        $bodyParts += ""
        $bodyParts += "**Dependencies:**"
        $bodyParts += $task.Dependencies
    }
    
    if ($task.'Est Notes') {
        $bodyParts += ""
        $bodyParts += "**Est Notes:**"
        $bodyParts += $task.'Est Notes'
    }
    
    $bodyParts += ""
    $bodyParts += "---"
    $bodyParts += ""
    $bodyParts += "*Imported from WORDPRESS-MVP-TASKS.csv*"
    
    $body = $bodyParts -join "`n"

    # Build labels
    $labels = @($task.Priority, $task.Phase)
    
    # Add status label
    if ($task.Status -eq 'Done') {
        $labels += 'completed'
    }
    
    # Add epic as label (clean format)
    $epicLabel = $task.Epic -replace ';.*', '' -replace ' ', '-' -replace '/', '-'
    $labels += $epicLabel
    
    # Add Group ID
    if ($task.'Group ID') {
        $labels += $task.'Group ID'
    }
    
    # Add executor label
    if ($task.Executor -eq 'Lawyer') {
        $labels += 'external-contractor'
    } elseif ($task.Executor -eq 'You') {
        $labels += 'manager'
    }
    
    # Convert to comma-separated string
    $labelString = $labels -join ','
    
    # Create issue
    try {
        $title = "[$($task.'Task ID')] $($task.'Task Name')"
        
        # Try to create with labels, if fails retry without labels
        $issueJson = gh issue create `
            --repo "$Owner/$Repo" `
            --title $title `
            --body $body `
            --label $labelString `
            --assignee "@me" 2>&1
        
        # If label error, retry without labels
        if ($LASTEXITCODE -ne 0 -and $issueJson -match 'could not add label') {
            Write-Host "  ⚠ Labels not found, creating without labels..." -ForegroundColor Yellow
            $issueJson = gh issue create `
                --repo "$Owner/$Repo" `
                --title $title `
                --body $body `
                --assignee "@me" 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            # Extract issue number from URL in output
            if ($issueJson -match '#(\d+)') {
                $issueNumber = $Matches[1]
                $issueUrl = "https://github.com/$Owner/$Repo/issues/$issueNumber"
                Write-Host "  ✓ Created issue #${issueNumber}: $issueUrl" -ForegroundColor Green
            } else {
                Write-Host "  ✓ Created issue" -ForegroundColor Green
            }
            
            # Close issue if it's marked as Done
            if ($task.Status -eq 'Done' -and $issueNumber) {
                Write-Host "    Closing issue (marked as Done)..." -ForegroundColor Gray
                $closeResult = gh issue close $issueNumber --repo "$Owner/$Repo" --reason "completed" 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "     Issue closed" -ForegroundColor Green
                } else {
                    Write-Host "     Failed to close issue: $closeResult" -ForegroundColor Yellow
                }
            }
            
            $created++
        } else {
            Write-Host "   Failed to create issue" -ForegroundColor Red
            Write-Host "    Error: $issueJson" -ForegroundColor Red
            $failed++
        }
        
    } catch {
        Write-Host "   Error: $_" -ForegroundColor Red
        $failed++
    }
    
    # Rate limit protection
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host " Created: $created issues" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host " Failed: $failed issues" -ForegroundColor Red
}

Write-Host "`nNext: Link issues to GitHub Project via project UI" -ForegroundColor Yellow

