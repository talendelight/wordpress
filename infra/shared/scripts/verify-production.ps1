#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verify production deployment state
.DESCRIPTION
    Checks that all expected pages, patterns, assets, and settings are present on production
    Reports differences and missing items
.PARAMETER Fix
    Attempt to fix issues automatically (default: $false)
#>

param(
    [switch]$Fix = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$SSH_USER = "u909075950"
$SSH_HOST = "45.84.205.129"
$WP_ROOT = "domains/talendelight.com/public_html"
$LOCAL_ROOT = "c:\data\lochness\talendelight\code\wordpress"

Write-Host "=== Production Verification Started ===" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

$issues = @()
$checks = 0
$passed = 0

function Test-ProductionItem {
    param(
        [string]$Name,
        [string]$Command,
        [string]$Expected,
        [string]$Category
    )
    
    $script:checks++
    
    try {
        $result = ssh "$SSH_USER@$SSH_HOST" "cd $WP_ROOT && $Command" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            if ($Expected -and $result -ne $Expected) {
                $script:issues += @{
                    category = $Category
                    name = $Name
                    status = "mismatch"
                    expected = $Expected
                    actual = $result
                }
                Write-Host "  ✗ $Name (mismatch)" -ForegroundColor Red
                return $false
            } else {
                $script:passed++
                Write-Host "  ✓ $Name" -ForegroundColor Green
                return $true
            }
        } else {
            $script:issues += @{
                category = $Category
                name = $Name
                status = "missing"
                error = $result
            }
            Write-Host "  ✗ $Name (missing/error)" -ForegroundColor Red
            return $false
        }
    } catch {
        $script:issues += @{
            category = $Category
            name = $Name
            status = "error"
            error = $_.Exception.Message
        }
        Write-Host "  ✗ $Name (check failed)" -ForegroundColor Red
        return $false
    }
}

# 1. Check critical pages
Write-Host "`n1. Checking critical pages..." -ForegroundColor Yellow

$expectedPages = @(
    @{ Name = "Welcome"; Slug = "welcome" },
    @{ Name = "Log In"; Slug = "log-in" },
    @{ Name = "Privacy Policy"; Slug = "privacy-policy" }
)

foreach ($page in $expectedPages) {
    $cmd = "wp post list --post_type=page --name=$($page.Slug) --format=count --allow-root"
    $result = Test-ProductionItem -Name $page.Name -Command $cmd -Expected "1" -Category "pages"
}

# Check homepage setting
$cmd = "wp option get page_on_front --allow-root"
Test-ProductionItem -Name "Homepage (page_on_front)" -Command $cmd -Expected "" -Category "settings" | Out-Null

# 2. Check block patterns
Write-Host "`n2. Checking block patterns..." -ForegroundColor Yellow

$expectedPatterns = @(
    "hero-single-cta.php",
    "icon-card.php",
    "card-grid-3+1.php",
    "cta-primary.php",
    "how-it-works-3.php",
    "alert-success.php",
    "alert-warning.php",
    "alert-error.php",
    "alert-info.php",
    "legal-header.php"
)

foreach ($pattern in $expectedPatterns) {
    $cmd = "test -f wp-content/themes/blocksy-child/patterns/$pattern && echo 'exists' || echo 'missing'"
    Test-ProductionItem -Name "Pattern: $pattern" -Command $cmd -Expected "exists" -Category "patterns" | Out-Null
}

# 3. Check assets
Write-Host "`n3. Checking theme assets..." -ForegroundColor Yellow

$expectedAssets = @(
    "wp-content/themes/blocksy-child/assets/images/eu-logo.svg",
    "wp-content/themes/blocksy-child/functions.php",
    "wp-content/themes/blocksy-child/style.css"
)

foreach ($asset in $expectedAssets) {
    $cmd = "test -f $asset && echo 'exists' || echo 'missing'"
    Test-ProductionItem -Name "Asset: $(Split-Path $asset -Leaf)" -Command $cmd -Expected "exists" -Category "assets" | Out-Null
}

# 4. Check theme activation
Write-Host "`n4. Checking theme settings..." -ForegroundColor Yellow

Test-ProductionItem -Name "Active theme" -Command "wp option get stylesheet --allow-root" -Expected "blocksy-child" -Category "settings" | Out-Null
Test-ProductionItem -Name "Parent theme" -Command "wp option get template --allow-root" -Expected "blocksy" -Category "settings" | Out-Null

# 5. Check critical plugins
Write-Host "`n5. Checking critical plugins..." -ForegroundColor Yellow

$criticalPlugins = @(
    "woocommerce",
    "blocksy-companion",
    "better-font-awesome"
)

foreach ($plugin in $criticalPlugins) {
    $cmd = "wp plugin is-active $plugin --allow-root && echo 'active' || echo 'inactive'"
    Test-ProductionItem -Name "Plugin: $plugin" -Command $cmd -Expected "active" -Category "plugins" | Out-Null
}

# Summary
Write-Host "`n=== Verification Summary ===" -ForegroundColor Cyan
Write-Host "Total checks: $checks" -ForegroundColor Gray
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $($checks - $passed)" -ForegroundColor $(if ($checks -eq $passed) { "Green" } else { "Red" })

if ($issues.Count -gt 0) {
    Write-Host "`n=== Issues Found ===" -ForegroundColor Red
    
    $issuesByCategory = $issues | Group-Object -Property category
    
    foreach ($group in $issuesByCategory) {
        Write-Host "`n$($group.Name.ToUpper()):" -ForegroundColor Yellow
        
        foreach ($issue in $group.Group) {
            Write-Host "  • $($issue.name)" -ForegroundColor Red
            Write-Host "    Status: $($issue.status)" -ForegroundColor Gray
            
            if ($issue.expected) {
                Write-Host "    Expected: $($issue.expected)" -ForegroundColor Gray
                Write-Host "    Actual: $($issue.actual)" -ForegroundColor Gray
            }
            
            if ($issue.error) {
                Write-Host "    Error: $($issue.error)" -ForegroundColor Gray
            }
        }
    }
    
    # Save issues report
    $reportFile = Join-Path $LOCAL_ROOT "tmp\verification-issues-$(Get-Date -Format 'yyyyMMdd-HHmm').json"
    $issues | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`n✓ Issues report saved: $reportFile" -ForegroundColor Gray
    
    if ($Fix) {
        Write-Host "`n=== Attempting Automatic Fixes ===" -ForegroundColor Yellow
        Write-Host "⚠ Fix mode not yet implemented - please restore from backup" -ForegroundColor Yellow
    } else {
        Write-Host "`nRun with -Fix flag to attempt automatic repairs" -ForegroundColor Yellow
    }
    
    return 1
} else {
    Write-Host "`n✓ All verification checks passed" -ForegroundColor Green
    return 0
}
