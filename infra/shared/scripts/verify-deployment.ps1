#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verify production deployment matches local workspace
    
.DESCRIPTION
    Compares wp-content/ files between local and production to detect deployment failures.
    Useful after git push to main to confirm Hostinger auto-deploy succeeded.
    
.PARAMETER FilePattern
    Git pattern to check specific files (default: wp-content/**/*.php)
    
.PARAMETER Commit
    Git commit to compare (default: HEAD)
    
.EXAMPLE
    pwsh infra/shared/scripts/verify-deployment.ps1
    # Check all wp-content PHP files from latest commit
    
.EXAMPLE
    pwsh infra/shared/scripts/verify-deployment.ps1 -FilePattern "wp-content/mu-plugins/*.php"
    # Check only mu-plugins
    
.EXAMPLE
    pwsh infra/shared/scripts/verify-deployment.ps1 -Commit c7722e8f
    # Check specific commit
#>

param(
    [string]$FilePattern = "wp-content/**/*.php",
    [string]$Commit = "HEAD",
    [string]$SshKey = "tmp\hostinger_deploy_key",
    [string]$SshUser = "u909075950",
    [string]$SshHost = "45.84.205.129",
    [int]$SshPort = 65002,
    [string]$ProdPath = "/home/u909075950/domains/talendelight.com/public_html"
)

$ErrorActionPreference = "Stop"

Write-Host "🔍 Deployment Verification" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "Commit:  $Commit"
Write-Host "Pattern: $FilePattern"
Write-Host ""

# Get files changed in wp-content/ from commit
Write-Host "📋 Getting changed files from commit..." -ForegroundColor Yellow
$changedFiles = git show $Commit --name-only --format="" | Where-Object { 
    $_ -like "wp-content/*" -and $_ -like "*.php" 
}

if (-not $changedFiles) {
    Write-Host "✅ No wp-content/ PHP files changed in commit $Commit" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($changedFiles.Count) changed file(s):" -ForegroundColor Cyan
$changedFiles | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }
Write-Host ""

# Verify each file
$mismatches = @()
$missing = @()
$verified = @()

foreach ($file in $changedFiles) {
    $localPath = Join-Path $PSScriptRoot ".." ".." ".." $file
    $remotePath = "$ProdPath/$($file -replace '\\', '/')"
    
    Write-Host "🔎 Checking: $file" -ForegroundColor Cyan
    
    # Check if local file exists
    if (-not (Test-Path $localPath)) {
        Write-Host "  ⚠️  Local file not found (deleted?)" -ForegroundColor Yellow
        continue
    }
    
    # Get local file size
    $localSize = (Get-Item $localPath).Length
    Write-Host "  📏 Local: $localSize bytes" -ForegroundColor Gray
    
    # Get production file size
    $sshCmd = "ssh -p $SshPort -i `"$SshKey`" ${SshUser}@${SshHost}"
    $prodStat = Invoke-Expression "$sshCmd `"stat -c '%s' '$remotePath' 2>/dev/null || echo 'MISSING'`""
    
    if ($prodStat -eq "MISSING") {
        Write-Host "  ❌ Production: FILE MISSING" -ForegroundColor Red
        $missing += $file
        continue
    }
    
    $prodSize = [int]$prodStat
    Write-Host "  📏 Production: $prodSize bytes" -ForegroundColor Gray
    
    # Compare sizes
    if ($localSize -eq $prodSize) {
        Write-Host "  ✅ MATCH" -ForegroundColor Green
        $verified += $file
    } else {
        Write-Host "  ❌ SIZE MISMATCH" -ForegroundColor Red
        $mismatches += @{
            File = $file
            LocalSize = $localSize
            ProdSize = $prodSize
            Diff = $prodSize - $localSize
        }
    }
    Write-Host ""
}

# Summary
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Verified: $($verified.Count)" -ForegroundColor Green
Write-Host "❌ Mismatches: $($mismatches.Count)" -ForegroundColor $(if ($mismatches.Count -gt 0) { "Red" } else { "Gray" })
Write-Host "🚫 Missing: $($missing.Count)" -ForegroundColor $(if ($missing.Count -gt 0) { "Red" } else { "Gray" })
Write-Host ""

# Report issues
if ($mismatches.Count -gt 0) {
    Write-Host "❌ SIZE MISMATCHES DETECTED:" -ForegroundColor Red
    foreach ($m in $mismatches) {
        Write-Host "  • $($m.File)" -ForegroundColor Yellow
        Write-Host "    Local: $($m.LocalSize) bytes | Production: $($m.ProdSize) bytes | Diff: $($m.Diff)" -ForegroundColor Gray
    }
    Write-Host ""
}

if ($missing.Count -gt 0) {
    Write-Host "🚫 MISSING FILES IN PRODUCTION:" -ForegroundColor Red
    foreach ($f in $missing) {
        Write-Host "  • $f" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "💡 Deploy manually:" -ForegroundColor Cyan
    foreach ($f in $missing) {
        $localFile = $f -replace '/', '\'
        Write-Host "scp -P $SshPort -i `"$SshKey`" `"$localFile`" ${SshUser}@${SshHost}:$ProdPath/$f" -ForegroundColor Gray
    }
    Write-Host ""
}

# Exit code
if ($mismatches.Count -gt 0 -or $missing.Count -gt 0) {
    Write-Host "❌ DEPLOYMENT VERIFICATION FAILED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ ALL FILES DEPLOYED SUCCESSFULLY" -ForegroundColor Green
    exit 0
}
