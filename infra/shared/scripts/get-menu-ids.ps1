#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Get WordPress menu item IDs by title or menu location
.DESCRIPTION
    Query WordPress (local or production) to find menu item IDs by title.
    Useful for parameterizing SQL migrations that update menu items.
.EXAMPLE
    # Get menu IDs from local WordPress
    .\get-menu-ids.ps1 -Environment Local -MenuLocation "primary-menu"
    
    # Get specific menu item ID by title
    .\get-menu-ids.ps1 -Environment Local -MenuLocation "primary-menu" -Title "About Us"
    
    # Get menu IDs from production
    .\get-menu-ids.ps1 -Environment Production -MenuLocation "primary-menu"
    
    # Output as SQL variables for use in migrations
    .\get-menu-ids.ps1 -Environment Local -MenuLocation "primary-menu" -OutputFormat SQL
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Local', 'Production')]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [string]$MenuLocation,
    
    [string]$Title,
    
    [ValidateSet('Table', 'CSV', 'JSON', 'SQL')]
    [string]$OutputFormat = 'Table',
    
    # Production SSH settings
    [string]$SshHost = "u909075950@45.84.205.129",
    [int]$SshPort = 65002,
    [string]$SshKey = "tmp/hostinger_deploy_key",
    [string]$WpPath = "/home/u909075950/domains/hireaccord.com/public_html"
)

$ErrorActionPreference = "Stop"

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "  WordPress Menu Item ID Lookup" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Gray
Write-Host "Menu Location: $MenuLocation" -ForegroundColor Gray
if ($Title) {
    Write-Host "Filter by Title: $Title" -ForegroundColor Gray
}
Write-Host ""

# Build WP-CLI command
$fields = "db_id,title,menu_order,url"
$format = if ($OutputFormat -eq 'SQL') { 'json' } else { $OutputFormat.ToLower() }

$wpCommand = "wp menu item list $MenuLocation --fields=$fields --format=$format --allow-root --skip-plugins"

# Execute command based on environment
if ($Environment -eq 'Local') {
    Write-Host "Querying local WordPress container..." -ForegroundColor Yellow
    
    $result = podman exec wp bash -c $wpCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to query local WordPress. Exit code: $LASTEXITCODE"
        exit 1
    }
} else {
    Write-Host "Querying production WordPress via SSH..." -ForegroundColor Yellow
    
    $sshCommand = "cd $WpPath && $wpCommand"
    $result = ssh -i $SshKey -p $SshPort $SshHost $sshCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to query production WordPress via SSH. Exit code: $LASTEXITCODE"
        exit 1
    }
}

# Filter by title if specified
if ($Title -and $OutputFormat -ne 'Table') {
    # Parse JSON and filter
    $menuItems = $result | ConvertFrom-Json
    $menuItems = $menuItems | Where-Object { $_.title -eq $Title }
    
    if ($menuItems.Count -eq 0) {
        Write-Warning "No menu items found with title: $Title"
        exit 1
    }
    
    $result = $menuItems | ConvertTo-Json
}

# Output results
if ($OutputFormat -eq 'SQL') {
    Write-Host "`nSQL Variable Declarations:" -ForegroundColor Green
    Write-Host "-- Copy these to your SQL migration file" -ForegroundColor Gray
    Write-Host "-- Replace IDs with variables in your UPDATE statements" -ForegroundColor Gray
    Write-Host ""
    
    $menuItems = $result | ConvertFrom-Json
    
    foreach ($item in $menuItems) {
        # Clean title for variable name (remove spaces, special chars)
        $varName = $item.title -replace '[^a-zA-Z0-9]', '_' -replace '_+', '_'
        $varName = $varName.ToLower().Trim('_')
        
        Write-Host "SET @menu_item_$varName = $($item.db_id);  -- $($item.title)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Example UPDATE statement:" -ForegroundColor Gray
    Write-Host "UPDATE wp_posts SET menu_order = 1 WHERE ID = @menu_item_about_us;" -ForegroundColor DarkGray
} elseif ($OutputFormat -eq 'Table' -and $Title) {
    # For table format with title filter, manually parse and filter
    $lines = $result -split "`n"
    $header = $lines[0]
    $filtered = @($header)
    
    foreach ($line in $lines[1..($lines.Length-1)]) {
        if ($line -match $Title) {
            $filtered += $line
        }
    }
    
    if ($filtered.Count -eq 1) {
        Write-Warning "No menu items found with title: $Title"
        exit 1
    }
    
    $filtered | Out-String
} else {
    $result
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Lookup complete" -ForegroundColor Green
Write-Host "================================================================`n" -ForegroundColor Cyan
