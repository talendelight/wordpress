#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update WordPress site logo and favicon
    
.DESCRIPTION
    Import new logo and favicon images and set them as WordPress custom_logo and site_icon.
    Supports both local (Podman) and production (Hostinger) environments.
    
.PARAMETER Environment
    Target environment: 'Local' or 'Production'
    
.PARAMETER LogoFile
    Logo image filename (should exist in restore/assets/images/hireaccord/)
    Supported formats: SVG, PNG, JPG
    Default: HireAccord_logo_original.png
    
.PARAMETER FaviconFile
    Site icon/favicon filename (should exist in restore/assets/images/hireaccord/)
    Recommended: 180x180 PNG for best compatibility
    Default: apple-touch-icon.png
    
.PARAMETER AdditionalFiles
    Array of additional favicon format filenames to import (optional)
    Default: @('favicon.ico', 'favicon-32.png', 'android-chrome-192.png', 'android-chrome-512.png')
    
.EXAMPLE
    .\update-logo-favicon.ps1 -Environment Local
    
.EXAMPLE
    .\update-logo-favicon.ps1 -Environment Production -LogoFile "HireAccord_logo_v2.png" -FaviconFile "favicon-180.png"
    
.NOTES
    Date: 2026-03-13
    Author: HireAccord Team
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Local', 'Production')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$LogoFile = "HireAccord_logo_original.png",
    
    [Parameter(Mandatory=$false)]
    [string]$FaviconFile = "apple-touch-icon.png",
    
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalFiles = @(
        'favicon.ico',
        'favicon-32.png',
        'android-chrome-192.png',
        'android-chrome-512.png'
    ),
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipAdditional
)

$ErrorActionPreference = "Stop"

# Configuration
$AssetsDir = "restore/assets/images/hireaccord"
$TempDir = "/tmp/hireaccord-assets"

# Production SSH configuration
$ProdSSHKey = "tmp/hostinger_deploy_key"
$ProdSSHPort = "65002"
$ProdSSHUser = "u909075950"
$ProdSSHHost = "45.84.205.129"
$ProdWPRoot = "/home/u909075950/domains/hireaccord.com/public_html"

Write-Host "`n=== HireAccord Logo & Favicon Update ===" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Logo File: $LogoFile" -ForegroundColor Yellow
Write-Host "Favicon File: $FaviconFile" -ForegroundColor Yellow
Write-Host ""

# Validate files exist
$LogoPath = Join-Path $AssetsDir $LogoFile
$FaviconPath = Join-Path $AssetsDir $FaviconFile

if (-not (Test-Path $LogoPath)) {
    Write-Error "Logo file not found: $LogoPath"
    exit 1
}

if (-not (Test-Path $FaviconPath)) {
    Write-Error "Favicon file not found: $FaviconPath"
    exit 1
}

Write-Host "✅ Files validated" -ForegroundColor Green
Write-Host ""

# Generate bash script content
$ScriptContent = @"
#!/bin/bash
set -e

echo "=== Importing Logo and Favicon ==="
echo ""

# Import logo
echo "1. Importing logo: $LogoFile..."
LOGO_ID=`$(wp media import $TempDir/$LogoFile \
  --title='HireAccord Logo' \
  --porcelain \
  --allow-root \
  --skip-plugins 2>/dev/null)

if [ -n "`$LOGO_ID" ]; then
  echo "   ✅ Logo imported: Attachment ID `$LOGO_ID"
  
  # Set as custom logo
  echo "2. Setting as custom logo..."
  wp theme mod set custom_logo "`$LOGO_ID" --allow-root --skip-plugins
  echo "   ✅ Custom logo set"
else
  echo "   ❌ Failed to import logo"
  exit 1
fi

echo ""

# Import favicon
echo "3. Importing favicon: $FaviconFile..."
ICON_ID=`$(wp media import $TempDir/$FaviconFile \
  --title='HireAccord Site Icon' \
  --porcelain \
  --allow-root \
  --skip-plugins 2>/dev/null)

if [ -n "`$ICON_ID" ]; then
  echo "   ✅ Favicon imported: Attachment ID `$ICON_ID"
  
  # Set as site icon
  echo "4. Setting as site icon..."
  wp option update site_icon "`$ICON_ID" --allow-root --skip-plugins
  echo "   ✅ Site icon set"
else
  echo "   ❌ Failed to import favicon"
  exit 1
fi

echo ""

"@

# Add additional files import (if not skipped)
if (-not $SkipAdditional -and $AdditionalFiles.Count -gt 0) {
    $ScriptContent += @"
# Import additional favicon formats
echo "5. Importing additional favicon formats..."

"@
    
    foreach ($file in $AdditionalFiles) {
        $additionalPath = Join-Path $AssetsDir $file
        if (Test-Path $additionalPath) {
            $ScriptContent += @"
wp media import $TempDir/$file \
  --title='HireAccord Favicon - $file' \
  --allow-root \
  --skip-plugins 2>/dev/null && echo "   ✅ $file imported" || echo "   ⚠️  $file import failed (may not be critical)"

"@
        }
    }
    
    $ScriptContent += "`necho """"`n"
}

# Add cache clearing and cleanup
$ScriptContent += @"
# Clear cache
echo "6. Clearing WordPress cache..."
wp cache flush --allow-root --skip-plugins
echo "   ✅ Cache cleared"

echo ""

# Clean up temp files
echo "7. Cleaning up temporary files..."
rm -rf $TempDir
echo "   ✅ Cleanup complete"

echo ""
echo "=== Update Complete ==="
echo ""
echo "Logo Attachment ID: `$LOGO_ID"
echo "Icon Attachment ID: `$ICON_ID"
"@

# Save script to temp file with Unix line endings
$TempScriptPath = "tmp/update-logo-favicon-temp.sh"
# Convert Windows line endings to Unix
$ScriptContent = $ScriptContent -replace "`r`n", "`n"
$ScriptContent = $ScriptContent -replace "`r", "`n"
$FullTempPath = Join-Path $PWD $TempScriptPath
[System.IO.File]::WriteAllText($FullTempPath, $ScriptContent, [System.Text.UTF8Encoding]::new($false))

Write-Host "[*] Script generated" -ForegroundColor Green
Write-Host ""

# Execute based on environment
if ($Environment -eq 'Local') {
    Write-Host "[*] Deploying to Local WordPress (Podman)..." -ForegroundColor Cyan
    Write-Host ""
    
    # Create temp directory in container
    podman exec wp mkdir -p $TempDir
    
    # Copy files to container
    Write-Host "Uploading files to container..."
    podman cp $LogoPath "wp:$TempDir/$LogoFile"
    podman cp $FaviconPath "wp:$TempDir/$FaviconFile"
    
    if (-not $SkipAdditional) {
        foreach ($file in $AdditionalFiles) {
            $filePath = Join-Path $AssetsDir $file
            if (Test-Path $filePath) {
                podman cp $filePath "wp:$TempDir/$file"
            }
        }
    }
    
    # Copy and execute script
    podman cp $TempScriptPath "wp:/tmp/update-logo-favicon.sh"
    podman exec wp bash /tmp/update-logo-favicon.sh
    
    Write-Host ""
    Write-Host "✅ Local deployment complete!" -ForegroundColor Green
    Write-Host "Visit: https://wp.local/?v=$((Get-Date).Ticks)" -ForegroundColor Yellow
    
} elseif ($Environment -eq 'Production') {
    Write-Host "[*] Deploying to Production (Hostinger)..." -ForegroundColor Cyan
    Write-Host ""
    
    # Upload files to production
    Write-Host "Uploading files to production server..."
    
    $SSHConnection = "$ProdSSHUser@$ProdSSHHost"
    
    # Create temp directory on production
    ssh -i $ProdSSHKey -p $ProdSSHPort $SSHConnection "mkdir -p $TempDir"
    
    # Upload logo, favicon, and additional files
    $FilesToUpload = @($LogoFile, $FaviconFile)
    if (-not $SkipAdditional) {
        $FilesToUpload += $AdditionalFiles | Where-Object { Test-Path (Join-Path $AssetsDir $_) }
    }
    
    foreach ($file in $FilesToUpload) {
        $localPath = Join-Path $AssetsDir $file
        if (Test-Path $localPath) {
            scp -P $ProdSSHPort -i $ProdSSHKey $localPath "${SSHConnection}:$TempDir/"
            Write-Host "  ✅ Uploaded: $file" -ForegroundColor Green
        }
    }
    
    # Upload and execute script
    Write-Host ""
    Write-Host "Executing update script on production..."
    scp -P $ProdSSHPort -i $ProdSSHKey $TempScriptPath "${SSHConnection}:/tmp/update-logo-favicon.sh"
    ssh -i $ProdSSHKey -p $ProdSSHPort $SSHConnection "cd $ProdWPRoot ; bash /tmp/update-logo-favicon.sh ; rm /tmp/update-logo-favicon.sh"
    
    # Clear LiteSpeed cache
    Write-Host ""
    Write-Host "Clearing LiteSpeed cache..."
    ssh -i $ProdSSHKey -p $ProdSSHPort $SSHConnection "cd $ProdWPRoot ; wp litespeed-purge all --allow-root"
    
    Write-Host ""
    Write-Host "✅ Production deployment complete!" -ForegroundColor Green
    Write-Host "Visit: https://hireaccord.com/?v=$((Get-Date).Ticks)" -ForegroundColor Yellow
}

# Cleanup local temp script
Remove-Item $TempScriptPath -Force

Write-Host ""
Write-Host "Success! Logo and favicon update complete." -ForegroundColor Green
Write-Host ""
