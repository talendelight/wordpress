#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Rebuild WordPress navigation menu with standard items
.DESCRIPTION
    Comprehensive script to recreate WordPress navigation menu:
    - Creates menu if not exists (by slug)
    - Cleans up all existing items
    - Adds standard navigation items (Welcome, Register, Help, Login)
    - Assigns menu to theme location
    - Verifies WP-CLI availability
.PARAMETER MenuSlug
    Menu slug/name (default: main-navigation)
.PARAMETER ThemeLocation
    Theme location identifier (default: header-menu-1 for Blocksy)
.PARAMETER Environment
    Target environment: local or production
.PARAMETER DryRun
    Preview changes without applying
.EXAMPLE
    .\rebuild-navigation-menu.ps1 -Environment production
    .\rebuild-navigation-menu.ps1 -DryRun
    .\rebuild-navigation-menu.ps1 -MenuSlug "primary-menu" -ThemeLocation "primary"
#>

param(
    [string]$MenuSlug = "main-navigation",
    [string]$ThemeLocation = "menu_1",  # Blocksy uses 'menu_1' for Header Menu 1
    [ValidateSet('local', 'production')]
    [string]$Environment = 'local',  # Default to local dev environment
    [switch]$DryRun,
    
    # Production SSH settings
    [string]$SshHost = "u909075950@45.84.205.129",
    [int]$SshPort = 65002,
    [string]$SshKey = "tmp/hostinger_deploy_key",
    [string]$WpPath = "/home/u909075950/domains/hireaccord.com/public_html"
)

$ErrorActionPreference = "Stop"

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "  WordPress Navigation Menu Rebuild" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Environment:     $Environment" -ForegroundColor Gray
Write-Host "Menu Slug:       $MenuSlug" -ForegroundColor Gray
Write-Host "Theme Location:  $ThemeLocation" -ForegroundColor Gray
Write-Host "Dry Run:         $DryRun" -ForegroundColor Gray
Write-Host ""

# Menu items configuration
# IMPORTANT: Use custom links with slug-based URLs to avoid page ID dependency
# This ensures menu works across environments regardless of page IDs
$MenuItems = @(
    @{ Type = 'custom'; Title = 'Welcome'; Url = '/' }
    @{ Type = 'custom'; Title = 'Register'; Url = '/select-role/' }
    @{ Type = 'custom'; Title = 'Help'; Url = '/help/' }
    @{ Type = 'custom'; Title = 'Login'; Url = '/log-in/' }
)

# Build WP-CLI command wrapper
function Invoke-WpCommand {
    param([string]$Command)
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] wp $Command" -ForegroundColor Yellow
        return $null
    }
    
    if ($Environment -eq 'local') {
        $result = podman exec wp wp $Command --allow-root 2>&1
    } else {
        $sshCommand = "cd $WpPath; wp $Command --allow-root"
        $result = ssh -p $SshPort -i $SshKey $SshHost $sshCommand 2>&1
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "WP-CLI command failed: $Command`n$result"
    }
    
    return $result
}

# Step 1: Check WP-CLI availability
Write-Host "Step 1: Checking WP-CLI availability..." -ForegroundColor Cyan
try {
    $wpVersion = Invoke-WpCommand "--version"
    if ($wpVersion) {
        Write-Host "  $wpVersion detected" -ForegroundColor Green
    } elseif ($DryRun) {
        Write-Host "  [DRY-RUN] WP-CLI check skipped" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ERROR: WP-CLI not available or not functioning" -ForegroundColor Red
    Write-Host "  Error details: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Get or create menu
Write-Host "`nStep 2: Get or create menu '$MenuSlug'..." -ForegroundColor Cyan
try {
    $menuListJson = Invoke-WpCommand "menu list --format=json"
    
    if ($menuListJson -and -not $DryRun) {
        $menus = $menuListJson | ConvertFrom-Json
        $existingMenu = $menus | Where-Object { $_.slug -eq $MenuSlug }
        
        if ($existingMenu) {
            $menuId = $existingMenu.term_id
            Write-Host "  Found existing menu ID: $menuId" -ForegroundColor Green
        } else {
            Write-Host "  Menu not found, creating new menu..." -ForegroundColor Yellow
            Invoke-WpCommand "menu create '$MenuSlug'" | Out-Null
            
            # Re-fetch to get new ID
            $menuListJson = Invoke-WpCommand "menu list --format=json"
            $menus = $menuListJson | ConvertFrom-Json
            $newMenu = $menus | Where-Object { $_.slug -eq $MenuSlug }
            $menuId = $newMenu.term_id
            Write-Host "  Created new menu ID: $menuId" -ForegroundColor Green
        }
    } elseif ($DryRun) {
        $menuId = 999
        Write-Host "  [DRY-RUN] Using placeholder menu ID: $menuId" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ERROR: Failed to get/create menu - $_" -ForegroundColor Red
    exit 1
}

# Step 3: Clean up existing menu items
Write-Host "`nStep 3: Cleaning up existing menu items..." -ForegroundColor Cyan
try {
    $itemIds = Invoke-WpCommand "menu item list $menuId --format=ids"
    
    if ($itemIds -and $itemIds.Trim() -ne '' -and -not $DryRun) {
        Write-Host "  Deleting existing items: $itemIds" -ForegroundColor Yellow
        Invoke-WpCommand "menu item delete $itemIds" | Out-Null
        Write-Host "  All existing items deleted" -ForegroundColor Green
    } elseif ($DryRun) {
        Write-Host "  [DRY-RUN] Would delete existing menu items" -ForegroundColor Yellow
    } else {
        Write-Host "  No existing items to delete" -ForegroundColor Green
    }
} catch {
    Write-Host "  WARNING: Could not clean up menu items - $_" -ForegroundColor Yellow
}

# Step 4: Add menu items
Write-Host "`nStep 4: Adding menu items..." -ForegroundColor Cyan
$addedCount = 0

foreach ($item in $MenuItems) {
    try {
        # Always use custom links to avoid page ID dependency issues
        # Slug-based URLs work across environments regardless of page IDs
        if (-not $DryRun) {
            Invoke-WpCommand "menu item add-custom $menuId '$($item.Title)' '$($item.Url)'" | Out-Null
        }
        Write-Host "  Added: $($item.Title) ($($item.Url))" -ForegroundColor Green
        $addedCount++
    } catch {
        Write-Host "  ERROR: Failed to add '$($item.Title)' - $_" -ForegroundColor Red
    }
}

Write-Host "  Total items added: $addedCount/$($MenuItems.Count)" -ForegroundColor Green

# Step 5: Assign menu to theme location
Write-Host "`nStep 5: Assigning menu to theme location '$ThemeLocation'..." -ForegroundColor Cyan
try {
    Invoke-WpCommand "menu location assign $MenuSlug $ThemeLocation" | Out-Null
    Write-Host "  Menu assigned to $ThemeLocation" -ForegroundColor Green
} catch {
    Write-Host "  WARNING: Could not assign menu location - $_" -ForegroundColor Yellow
    Write-Host "  You may need to assign manually in WordPress admin" -ForegroundColor Yellow
}

# Step 6: Verify menu items
Write-Host "`nStep 6: Verifying menu items..." -ForegroundColor Cyan
try {
    if (-not $DryRun) {
        $verifyItems = Invoke-WpCommand "menu item list $menuId --fields=title,url --format=table"
        Write-Host $verifyItems -ForegroundColor Gray
    } else {
        Write-Host "  [DRY-RUN] Verification skipped" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  WARNING: Could not verify items - $_" -ForegroundColor Yellow
}

# Step 7: Clear caches
Write-Host "`nStep 7: Clearing caches..." -ForegroundColor Cyan
try {
    Invoke-WpCommand "cache flush" | Out-Null
    Write-Host "  WordPress cache flushed" -ForegroundColor Green
} catch {
    Write-Host "  WARNING: Could not flush cache - $_" -ForegroundColor Yellow
}

# Summary
Write-Host "`n================================================================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "DRY-RUN COMPLETE - No changes made" -ForegroundColor Yellow
} else {
    Write-Host "MENU REBUILD COMPLETE" -ForegroundColor Green
}
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Menu Slug:       $MenuSlug" -ForegroundColor White
Write-Host "Menu ID:         $menuId" -ForegroundColor White
Write-Host "Theme Location:  $ThemeLocation" -ForegroundColor White
Write-Host "Items Added:     $addedCount/$($MenuItems.Count)" -ForegroundColor White
Write-Host ""

if (-not $DryRun) {
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Verify menu in WordPress admin (Appearance > Menus)" -ForegroundColor Gray
    Write-Host "2. Check frontend navigation display" -ForegroundColor Gray
    Write-Host "3. Configure role-based visibility if needed (via theme/plugin)" -ForegroundColor Gray
}
