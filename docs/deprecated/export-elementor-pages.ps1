#!/usr/bin/env pwsh
<#
.SYNOPSIS
Export Elementor pages from local WordPress container for deployment.

.DESCRIPTION
Exports Elementor page data from local development environment to JSON files.
Uses podman cp to avoid PowerShell encoding corruption.

.PARAMETER OutputDir
Directory to save exported files. Default: tmp/elementor-exports

.PARAMETER ManifestPath
Path to manifest.json file defining page mappings. Default: infra/shared/elementor-manifest.json

.EXAMPLE
.\export-elementor-pages.ps1

.EXAMPLE
.\export-elementor-pages.ps1 -OutputDir releases/v3.1.0/elementor

.NOTES
Version: 1.0.0
Requires: Podman/Docker with WordPress container running
#>

param(
    [string]$OutputDir = "tmp/elementor-exports",
    [string]$ManifestPath = "infra/shared/elementor-manifest.json",
    [string]$ContainerName = "wp"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Elementor Page Export Script v1.0.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Validate container is running
Write-Host "`nChecking container status..." -ForegroundColor Yellow
$containerStatus = podman ps --filter "name=$ContainerName" --format "{{.Names}}"
if ($containerStatus -ne $ContainerName) {
    Write-Host "ERROR: Container '$ContainerName' is not running" -ForegroundColor Red
    Write-Host "Start it with: podman-compose up -d" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Container '$ContainerName' is running" -ForegroundColor Green

# Read manifest
Write-Host "`nReading manifest: $ManifestPath" -ForegroundColor Yellow
if (!(Test-Path $ManifestPath)) {
    Write-Host "ERROR: Manifest file not found: $ManifestPath" -ForegroundColor Red
    exit 1
}

$manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
Write-Host "✓ Manifest loaded: $($manifest.pages.Count) pages" -ForegroundColor Green

# Create output directory
Write-Host "`nCreating output directory: $OutputDir" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Write-Host "✓ Output directory ready" -ForegroundColor Green

# Export pages
Write-Host "`nExporting pages..." -ForegroundColor Yellow
$successCount = 0
$errorCount = 0

foreach ($page in $manifest.pages) {
    $localId = $page.local_id
    $name = $page.name
    $outputFile = Join-Path $OutputDir "$name.json"
    
    Write-Host "`n  Exporting: $($page.title) (ID: $localId)" -ForegroundColor Cyan
    
    # Export inside container (no PowerShell interference)
    $exportCmd = "wp post meta get $localId _elementor_data --allow-root 2>/dev/null > /tmp/$name.json"
    podman exec $ContainerName bash -c $exportCmd
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ERROR: Failed to export from container" -ForegroundColor Red
        $errorCount++
        continue
    }
    
    # Copy from container (binary copy)
    podman cp "${ContainerName}:/tmp/$name.json" $outputFile
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ERROR: Failed to copy from container" -ForegroundColor Red
        $errorCount++
        continue
    }
    
    # Verify file size
    $fileSize = (Get-Item $outputFile).Length
    if ($fileSize -eq 0) {
        Write-Host "    ERROR: Exported file is empty" -ForegroundColor Red
        $errorCount++
        continue
    }
    
    # Verify JSON validity
    $hasError = $false
    $jsonData = $null
    
    try {
        $jsonContent = Get-Content $outputFile -Raw
        $jsonData = $jsonContent | ConvertFrom-Json
    } catch {
        Write-Host "    ERROR: Invalid JSON in exported file: $_" -ForegroundColor Red
        $errorCount++
        $hasError = $true
    }
    
    if (-not $hasError) {
        # Check for BOM or encoding issues
        $bytes = [System.IO.File]::ReadAllBytes($outputFile)
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-Host "    WARNING: UTF-8 BOM detected - file may be corrupted" -ForegroundColor Yellow
        }
        if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            Write-Host "    ERROR: UTF-16 LE encoding detected - file is corrupted" -ForegroundColor Red
            $hasError = $true
        }
        if ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            Write-Host "    ERROR: UTF-16 BE encoding detected - file is corrupted" -ForegroundColor Red
            $hasError = $true
        }
        
        # Check for shortcode attribute escaping (critical for pages with shortcodes)
        $jsonContent = Get-Content $outputFile -Raw
        $shortcodeMatches = ([regex]'\"shortcode\":\"([^\"]+)\"').Matches($jsonContent)
        if ($shortcodeMatches.Count -gt 0) {
            # Verify shortcode attributes are properly escaped
            $hasUnescapedQuotes = $jsonContent -match '"shortcode":"\[[^\]]+\s+\w+="(?!\\")' 
            if ($hasUnescapedQuotes) {
                Write-Host "    ERROR: Shortcode attributes not properly escaped (quotes will break JSON)" -ForegroundColor Red
                Write-Host "          This happens when PowerShell piping corrupts the export" -ForegroundColor Red
                Write-Host "          Re-run export or file a bug report" -ForegroundColor Yellow
                $hasError = $true
            } else {
                Write-Host "    ✓ Validated $($shortcodeMatches.Count) shortcode(s)" -ForegroundColor Gray
            }
        }
    }
    
    if ($hasError) {
        $errorCount++
    } else {
        Write-Host "    ✓ Exported: $outputFile ($fileSize bytes, $($jsonData.Count) sections)" -ForegroundColor Green
        $successCount++
    }
}

# Copy manifest to output directory
Write-Host "`nCopying manifest to output directory..." -ForegroundColor Yellow
Copy-Item $ManifestPath (Join-Path $OutputDir "manifest.json") -Force
Write-Host "✓ Manifest copied" -ForegroundColor Green

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Export Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Success: $successCount" -ForegroundColor $(if ($successCount -gt 0) { "Green" } else { "Gray" })
Write-Host "Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Gray" })
Write-Host "Output: $OutputDir" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($errorCount -gt 0) {
    Write-Host "`nWARNING: Some pages failed to export" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✓ All pages exported successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Review exported files in $OutputDir" -ForegroundColor White
Write-Host "  2. Upload to production: scp -r $OutputDir production:~/" -ForegroundColor White
Write-Host "  3. Import on production: wp eval-file ~/elementor-exports/import-elementor-pages.php" -ForegroundColor White

exit 0
