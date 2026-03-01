#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('local', 'production')]
    [string]$Environment,
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$themesToRemove = @('twentytwentythree', 'twentytwentyfour', 'twentytwentyfive')
$localContainer = 'wp'
$localPath = '/var/www/html/wp-content/themes'
$sshKey = 'tmp\hostinger_deploy_key'
$sshHost = 'u909075950@45.84.205.129'
$sshPort = 65002
$prodPath = '/home/u909075950/domains/hireaccord.com/public_html/wp-content/themes'

Write-Host "`n=== WordPress Themes Cleanup ===" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Themes: $($themesToRemove -join ', ')" -ForegroundColor Yellow
if ($DryRun) { Write-Host "Mode: DRY RUN" -ForegroundColor Magenta }
Write-Host ""

$removed = 0
$notFound = 0

if ($Environment -eq 'local') {
    Write-Host "Target: Container at $localPath`n" -ForegroundColor Gray
    $running = podman ps --filter "name=$localContainer" --format "{{.Names}}" 2>$null
    if ($running -ne $localContainer) {
        Write-Host "ERROR: Container not running" -ForegroundColor Red
        exit 1
    }
    foreach ($theme in $themesToRemove) {
        $path = "$localPath/$theme"
        $exists = podman exec $localContainer test -d $path 2>$null
        if ($LASTEXITCODE -eq 0) {
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would remove: $theme" -ForegroundColor Cyan
            } else {
                podman exec $localContainer rm -rf $path 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Removed: $theme" -ForegroundColor Green
                    $removed++
                } else {
                    Write-Host "  ✗ Failed: $theme" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "  ⚠ Not found: $theme" -ForegroundColor Yellow
            $notFound++
        }
    }
} else {
    Write-Host "Target: Production at $prodPath`n" -ForegroundColor Gray
    if (-not (Test-Path $sshKey)) {
        Write-Host "ERROR: SSH key not found" -ForegroundColor Red
        exit 1
    }
    foreach ($theme in $themesToRemove) {
        $themePath = "$prodPath/$theme"
        if ($DryRun) {
           $cmd = "test -d '$themePath' ; echo `$?"
            $result = ssh -p $sshPort -i $sshKey $sshHost $cmd 2>$null
            if ($result -eq '0') {
                Write-Host "  [DRY RUN] Would remove: $theme" -ForegroundColor Cyan
            } else {
                Write-Host "  ⚠ Not found: $theme" -ForegroundColor Yellow
                $notFound++
            }
        } else {
            $cmd = "cd '$prodPath' ; rm -rf '$theme' 2>/dev/null ; echo `$?"
            $result = ssh -p $sshPort -i $sshKey $sshHost $cmd 2>$null
            if ($result -eq '0') {
                Write-Host "  ✓ Removed: $theme" -ForegroundColor Green
                $removed++
            } else {
                Write-Host "  ⚠ Not found: $theme" -ForegroundColor Yellow
                $notFound++
            }
        }
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "Dry run complete" -ForegroundColor Magenta
} else {
    Write-Host "Removed: $removed" -ForegroundColor Green
}
Write-Host "Not found: $notFound" -ForegroundColor Yellow
Write-Host ""
