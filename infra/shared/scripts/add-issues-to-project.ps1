<#
.SYNOPSIS
    Add all repository issues to a GitHub Project

.DESCRIPTION
    Adds all issues from talendelight/wordpress to the specified GitHub Project.
    Uses GitHub GraphQL API via gh CLI.

.PARAMETER ProjectNumber
    The project number from the URL (e.g., 1 from /projects/1/)

.PARAMETER Owner
    The owner of the project (default: talendelight)

.PARAMETER Repo
    The repository name (default: wordpress)

.EXAMPLE
    # Add all issues to project #1
    .\add-issues-to-project.ps1 -ProjectNumber 1
#>

param(
    [Parameter(Mandatory=$true)]
    [int]$ProjectNumber,
    [string]$Owner = "talendelight",
    [string]$Repo = "wordpress"
)

Write-Host "`n=== Add Issues to GitHub Project ===" -ForegroundColor Cyan
Write-Host "Project: #$ProjectNumber" -ForegroundColor Yellow
Write-Host "Repository: $Owner/$Repo" -ForegroundColor Yellow

# Step 1: Get the project ID
Write-Host "`nStep 1: Getting project ID..." -ForegroundColor Cyan

$projectQuery = @"
query {
  user(login: \"$Owner\") {
    projectV2(number: $ProjectNumber) {
      id
      title
    }
  }
}
"@

$projectResult = gh api graphql -f query="$projectQuery" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host " Failed to get project" -ForegroundColor Red
    Write-Host "Error: $projectResult" -ForegroundColor Red
    exit 1
}

$projectData = $projectResult | ConvertFrom-Json
$projectId = $projectData.data.user.projectV2.id
$projectTitle = $projectData.data.user.projectV2.title

Write-Host " Found project: $projectTitle" -ForegroundColor Green
Write-Host "  Project ID: $projectId" -ForegroundColor Gray

# Step 2: Get all issues from the repository
Write-Host "`nStep 2: Getting repository issues..." -ForegroundColor Cyan

$issues = gh issue list --repo "$Owner/$Repo" --limit 1000 --state all --json number,title | ConvertFrom-Json

if ($LASTEXITCODE -ne 0 -or -not $issues) {
    Write-Host " Failed to get issues" -ForegroundColor Red
    exit 1
}

Write-Host " Found $($issues.Count) issues" -ForegroundColor Green

# Step 3: Add each issue to the project
Write-Host "`nStep 3: Adding issues to project..." -ForegroundColor Cyan

$added = 0
$failed = 0
$skipped = 0

foreach ($issue in $issues) {
    Write-Host "`nAdding issue #$($issue.number): $($issue.title)" -ForegroundColor Yellow
    
    # Get the issue node ID
    $issueData = gh api repos/$Owner/$Repo/issues/$($issue.number) --jq '.node_id' 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   Failed to get issue node ID" -ForegroundColor Red
        $failed++
        continue
    }
    
    $issueNodeId = $issueData
    
    # Add issue to project using GraphQL mutation
    $addMutation = @"
mutation {
  addProjectV2ItemById(input: {projectId: \"$projectId\", contentId: \"$issueNodeId\"}) {
    item {
      id
    }
  }
}
"@
    
    $addResult = gh api graphql -f query="$addMutation" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Added to project" -ForegroundColor Green
        $added++
    } elseif ($addResult -match "already exists") {
        Write-Host "   Already in project" -ForegroundColor Yellow
        $skipped++
    } else {
        Write-Host "   Failed: $addResult" -ForegroundColor Red
        $failed++
    }
    
    # Rate limit protection
    Start-Sleep -Milliseconds 200
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host " Added: $added issues" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host " Skipped (already in project): $skipped issues" -ForegroundColor Yellow
}
if ($failed -gt 0) {
    Write-Host " Failed: $failed issues" -ForegroundColor Red
}

Write-Host "`nProject URL: https://github.com/users/$Owner/projects/$ProjectNumber" -ForegroundColor Cyan

