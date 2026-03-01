<#
.SYNOPSIS
    Create standard labels for GitHub repository

.DESCRIPTION
    Creates priority, phase, epic, and group labels for task management.
    Skips labels that already exist.

.PARAMETER Owner
    Repository owner (default: talendelight)

.PARAMETER Repo
    Repository name (default: wordpress)

.EXAMPLE
    .\create-labels.ps1
#>

param(
    [string]$Owner = "talendelight",
    [string]$Repo = "wordpress"
)

Write-Host "`n=== Create GitHub Labels ===" -ForegroundColor Cyan
Write-Host "Repository: $Owner/$Repo" -ForegroundColor Yellow

# Define all labels
$labels = @(
    # Priority Labels
    @{ name = "Critical"; color = "d73a4a"; description = "Critical priority - blocking" }
    @{ name = "High"; color = "ff6b00"; description = "High priority" }
    @{ name = "Medium"; color = "fbca04"; description = "Medium priority" }
    @{ name = "Low"; color = "0e8a16"; description = "Low priority" }
    
    # Phase Labels
    @{ name = "Foundation"; color = "001f3f"; description = "Foundation phase (completed)" }
    @{ name = "Phase 0"; color = "006b75"; description = "Phase 0: Business foundations" }
    @{ name = "Phase 1"; color = "0075ca"; description = "Phase 1: Compliance + Intake" }
    @{ name = "Phase 2"; color = "5319e7"; description = "Phase 2: Manager & Operator Workflows" }
    @{ name = "Phase 3"; color = "c2e0c6"; description = "Phase 3: Data Handling & Audit" }
    @{ name = "Phase 4"; color = "bfdadc"; description = "Phase 4: Integration & Launch" }
    @{ name = "Post-MVP"; color = "cccccc"; description = "Post-MVP features" }
    @{ name = "Strategic"; color = "e99695"; description = "Strategic planning" }
    
    # Epic Labels
    @{ name = "PENG-00 Foundation & Infrastructure"; color = "1d76db"; description = "Engineering foundation tasks" }
    @{ name = "WP-01 Public Marketing"; color = "84b6eb"; description = "Public marketing pages" }
    @{ name = "WP-04 Auth & RBAC"; color = "0052cc"; description = "Authentication and role-based access" }
    @{ name = "WP-13 Automated Testing"; color = "1d76db"; description = "Automated testing with Playwright" }
    @{ name = "PENG-01 Registration & Approval"; color = "0e8a16"; description = "Registration and approval workflows" }
    @{ name = "BMSL/LFTC-00 Business Foundations"; color = "d93f0b"; description = "Business and legal foundations" }
    @{ name = "LFTC-00 Legal/Compliance"; color = "d93f0b"; description = "Legal and compliance tasks" }
    @{ name = "PADM-00 Admin"; color = "fbca04"; description = "Administrative tasks" }
    @{ name = "COPS-00 Operations"; color = "c5def5"; description = "Operational procedures" }
    @{ name = "PMAS-00 Program Control"; color = "bfd4f2"; description = "Program management" }
    @{ name = "MKTB-00 Brand"; color = "f9d0c4"; description = "Branding tasks" }
    
    # Group Labels
    @{ name = "G01"; color = "d4c5f9"; description = "Group 1: Legal/compliance" }
    @{ name = "G02"; color = "c2e0c6"; description = "Group 2: Foundation/infrastructure" }
    @{ name = "G03"; color = "fef2c0"; description = "Group 3: Workflows" }
    @{ name = "G04"; color = "bfdadc"; description = "Group 4: Admin/brand" }
    @{ name = "G05"; color = "f9d0c4"; description = "Group 5: Operations" }
    @{ name = "G06"; color = "d4c5f9"; description = "Group 6: Testing/polish" }
    
    # Special Labels
    @{ name = "external-contractor"; color = "e99695"; description = "Requires external contractor" }
    @{ name = "test-automation"; color = "0366d6"; description = "Test automation task" }
)

Write-Host "`nCreating $($labels.Count) labels..." -ForegroundColor Cyan

$created = 0
$skipped = 0
$failed = 0

foreach ($label in $labels) {
    Write-Host "`n[$($label.name)]" -ForegroundColor Yellow -NoNewline
    
    # Check if label exists
    $existing = gh label list --repo "$Owner/$Repo" --json name --jq ".[] | select(.name == `"$($label.name)`") | .name" 2>&1
    
    if ($existing -eq $label.name) {
        Write-Host " already exists" -ForegroundColor Gray
        $skipped++
        continue
    }
    
    # Create label
    $result = gh label create "$($label.name)" --color $label.color --description "$($label.description)" --repo "$Owner/$Repo" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " created" -ForegroundColor Green
        $created++
    } else {
        Write-Host " failed: $result" -ForegroundColor Red
        $failed++
    }
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "  Created: $created labels" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host "  Skipped (already exist): $skipped labels" -ForegroundColor Yellow
}
if ($failed -gt 0) {
    Write-Host "  Failed: $failed labels" -ForegroundColor Red
}

Write-Host "`nLabels: https://github.com/$Owner/$Repo/labels" -ForegroundColor Cyan
