#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Get WordPress page IDs by relative URL/slug from production
.DESCRIPTION
    Query production WordPress to find page IDs using relative URLs or slugs.
    Supports both direct SSH access and WP-CLI commands.
.EXAMPLE
    .\get-page-ids.ps1 -RelativeUrl "/welcome/"
    .\get-page-ids.ps1 -Slug "welcome"
    .\get-page-ids.ps1 -ListAll
#>

param(
    [Parameter(ParameterSetName='ByUrl')]
    [string]$RelativeUrl,
    
    [Parameter(ParameterSetName='BySlug')]
    [string]$Slug,
    
    [Parameter(ParameterSetName='ListAll')]
    [switch]$ListAll,
    
    [string]$SshHost = "u909075950@45.84.205.129",
    [int]$SshPort = 65002,
    [string]$SshKey = "tmp/hostinger_deploy_key",
    [string]$WpPath = "/home/u909075950/domains/hireaccord.com/public_html"
)

$ErrorActionPreference = "Stop"

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "  WordPress Page ID Lookup" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# Convert relative URL to slug
if ($RelativeUrl) {
    $Slug = $RelativeUrl -replace '^/', '' -replace '/$', ''
    Write-Host "`nLooking up page by URL: $RelativeUrl" -ForegroundColor Yellow
    Write-Host "Converted to slug: $Slug" -ForegroundColor Gray
}

# Build WP-CLI command
if ($ListAll) {
    Write-Host "`nFetching all pages from production..." -ForegroundColor Yellow
    $wpCommand = "cd $WpPath; wp post list --post_type=page --format=json --fields=ID,post_name,post_title,post_status --allow-root"
} else {
    Write-Host "`nLooking up page: $Slug" -ForegroundColor Yellow
    $wpCommand = "cd $WpPath; wp post list --post_type=page --name=$Slug --format=json --fields=ID,post_name,post_title,post_status --allow-root"
}

# Execute SSH command
try {
    $result = ssh -p $SshPort -i $SshKey $SshHost $wpCommand 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nSSH command failed" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
    
    # Parse JSON result
    $pages = $result | ConvertFrom-Json
    
    if ($pages.Count -eq 0) {
        Write-Host "`nNo pages found" -ForegroundColor Yellow
        exit 0
    }
    
    # Display results
    Write-Host "`nFound $($pages.Count) page(s):`n" -ForegroundColor Green
    
    if ($ListAll) {
        $pages | Format-Table -Property @{
            Label = "ID"; Expression = {$_.ID}; Width = 6
        }, @{
            Label = "Slug"; Expression = {$_.post_name}; Width = 30
        }, @{
            Label = "Title"; Expression = {$_.post_title}; Width = 40
        }, @{
            Label = "Status"; Expression = {$_.post_status}; Width = 10
        } -AutoSize
    } else {
        foreach ($page in $pages) {
            Write-Host "   ID:     $($page.ID)" -ForegroundColor White
            Write-Host "   Slug:   $($page.post_name)" -ForegroundColor Gray
            Write-Host "   Title:  $($page.post_title)" -ForegroundColor Gray
            Write-Host "   Status: $($page.post_status)" -ForegroundColor Gray
            Write-Host ""
        }
    }
    
    # Output copy-paste command
    if (-not $ListAll -and $pages.Count -eq 1) {
        Write-Host "Copy-paste command:" -ForegroundColor Cyan
        Write-Host "   Production ID: $($pages[0].ID)" -ForegroundColor White
        Write-Host ""
    }
    
} catch {
    Write-Host "`nError occurred: $_" -ForegroundColor Red
    exit 1
}
