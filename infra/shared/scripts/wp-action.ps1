#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Main action dispatcher for WordPress operations
.DESCRIPTION
    Central registry mapping actions to their corresponding scripts.
    Use this as the single entry point for all WordPress deployment, backup, restore, and verification operations.
.EXAMPLE
    .\wp-action.ps1 backup
    .\wp-action.ps1 verify
    .\wp-action.ps1 restore -BackupTimestamp latest
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet(
        'backup',
        'verify', 
        'restore',
        'export-elementor',
        'health-check',
        'apply-sql',
        'deploy',
        'help'
    )]
    [string]$Action,
    
    [Parameter(ValueFromRemainingArguments=$true)]
    $RemainingArgs
)

$ErrorActionPreference = "Stop"

# Script registry - maps actions to their implementation scripts
$SCRIPT_REGISTRY = @{
    'backup' = @{
        script = 'backup-production.ps1'
        description = 'Create timestamped backup of production'
        usage = 'wp-action backup [-BackupDatabase $true] [-MaxBackups 10]'
        examples = @(
            'wp-action backup',
            'wp-action backup -BackupDatabase $true'
        )
    }
    
    'verify' = @{
        script = 'verify-production.ps1'
        description = 'Verify production state matches expectations'
        usage = 'wp-action verify [-Fix]'
        examples = @(
            'wp-action verify'
        )
    }
    
    'restore' = @{
        script = 'restore-production.ps1'
        description = 'Restore production from timestamped backup'
        usage = 'wp-action restore -BackupTimestamp TIMESTAMP [-RestorePages] [-DryRun]'
        examples = @(
            'wp-action restore -BackupTimestamp latest -RestorePages $true',
            'wp-action restore -BackupTimestamp latest -DryRun'
        )
    }
    
    'export-elementor' = @{
        script = 'export-elementor-pages.ps1'
        description = 'Export Elementor pages from local WordPress container'
        usage = 'wp-action export-elementor'
        examples = @(
            'wp-action export-elementor'
        )
    }
    
    'health-check' = @{
        script = 'verify-production-health.php'
        description = 'Run comprehensive health check on production'
        usage = 'wp-action health-check [-Verbose]'
        examples = @(
            'wp-action health-check',
            'wp-action health-check -Verbose'
        )
    }
    
    'apply-sql' = @{
        script = 'apply-sql-change.ps1'
        description = 'Apply SQL migration file to local database'
        usage = 'wp-action apply-sql -SqlFilePath <path-to-sql-file>'
        examples = @(
            'wp-action apply-sql -SqlFilePath infra/shared/db/260131-1200-add-record-id-prsn-cmpy.sql'
        )
    }
    
    'deploy' = @{
        script = $null
        description = 'Show deployment workflow'
        usage = 'wp-action deploy'
    }
}

# Help display
function Show-Help {
    param([string]$SpecificAction = $null)
    
    if ($SpecificAction -and $SCRIPT_REGISTRY.ContainsKey($SpecificAction)) {
        $info = $SCRIPT_REGISTRY[$SpecificAction]
        
        Write-Host "`n=== Action: $SpecificAction ===" -ForegroundColor Cyan
        Write-Host "`nDescription:" -ForegroundColor Yellow
        Write-Host "  $($info.description)"
        
        if ($info.script) {
            Write-Host "`nScript:" -ForegroundColor Yellow
            Write-Host "  infra/shared/scripts/$($info.script)"
        }
        
        Write-Host "`nUsage:" -ForegroundColor Yellow
        Write-Host "  $($info.usage)"
        
        Write-Host "`nExamples:" -ForegroundColor Yellow
        foreach ($example in $info.examples) {
            Write-Host "  .\wp-action.ps1 $example" -ForegroundColor Gray
        }
        
    } else {
        Write-Host "`n=== WordPress Action Dispatcher ===" -ForegroundColor Cyan
        Write-Host "`nAvailable Actions:" -ForegroundColor Yellow
        
        foreach ($key in $SCRIPT_REGISTRY.Keys | Sort-Object) {
            $info = $SCRIPT_REGISTRY[$key]
            Write-Host "`n  $key" -ForegroundColor Cyan
            Write-Host "    $($info.description)" -ForegroundColor Gray
        }
        
        Write-Host "`nUsage:" -ForegroundColor Yellow
        Write-Host "  .\wp-action.ps1 ACTION [arguments...]`n"
        
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\wp-action.ps1 help backup" -ForegroundColor Gray
        Write-Host "  .\wp-action.ps1 backup" -ForegroundColor Gray
        Write-Host "  .\wp-action.ps1 verify`n" -ForegroundColor Gray
    }
}

# Show deployment workflow
function Show-DeploymentWorkflow {
    Write-Host "`n=== Deployment Workflow ===" -ForegroundColor Cyan
    
    Write-Host "`n1. BACKUP (MANDATORY)" -ForegroundColor Yellow
    Write-Host "   .\wp-action.ps1 backup`n" -ForegroundColor Gray
    
    Write-Host "2. DEPLOY" -ForegroundColor Yellow
    Write-Host "   git push origin main`n" -ForegroundColor Gray
    
    Write-Host "3. VERIFY (MANDATORY)" -ForegroundColor Yellow
    Write-Host "   .\wp-action.ps1 verify`n" -ForegroundColor Gray
    
    Write-Host "4. RESTORE (if issues)" -ForegroundColor Yellow
    Write-Host "   .\wp-action.ps1 restore -BackupTimestamp latest -RestorePages `$true`n" -ForegroundColor Gray
}

# Main execution
try {
    if ($Action -eq 'help') {
        if ($RemainingArgs.Count -gt 0) {
            Show-Help -SpecificAction $RemainingArgs[0]
        } else {
            Show-Help
        }
        exit 0
    }
    
    if ($Action -eq 'deploy') {
        Show-DeploymentWorkflow
        exit 0
    }
    
    # Special handling for health-check (PHP script on production)
    if ($Action -eq 'health-check') {
        $scriptInfo = $SCRIPT_REGISTRY[$Action]
        $verbose = if ($RemainingArgs -contains '-Verbose') { '--verbose' } else { '' }
        
        Write-Host "Executing health check on production...`n" -ForegroundColor Cyan
        
        $sshCommand = "ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 `"cd domains/talendelight.com/public_html && wp eval-file ~/verify-production-health.php $verbose --allow-root`""
        
        Invoke-Expression $sshCommand
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-Host "`n✅ Health check passed" -ForegroundColor Green
        } else {
            Write-Host "`n❌ Health check failed - see details above" -ForegroundColor Red
        }
        
        exit $exitCode
    }
    
    # Get script info
    if (-not $SCRIPT_REGISTRY.ContainsKey($Action)) {
        Write-Host "Error: Unknown action: $Action" -ForegroundColor Red
        Write-Host "`nRun '.\wp-action.ps1 help' to see available actions`n" -ForegroundColor Yellow
        exit 1
    }
    
    $scriptInfo = $SCRIPT_REGISTRY[$Action]
    $scriptPath = Join-Path $PSScriptRoot $scriptInfo.script
    
    if (-not (Test-Path $scriptPath)) {
        Write-Host "Error: Script not found: $scriptPath" -ForegroundColor Red
        exit 1
    }
    
    # Execute the mapped script
    Write-Host "Executing: $Action" -ForegroundColor Cyan
    Write-Host "Script: $($scriptInfo.script)`n" -ForegroundColor Gray
    
    # Execute with arguments
    if ($RemainingArgs.Count -gt 0) {
        & $scriptPath @RemainingArgs
    } else {
        & $scriptPath
    }
    
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }
    
    if ($exitCode -eq 0) {
        Write-Host "`nAction completed successfully" -ForegroundColor Green
    } else {
        Write-Host "`nAction completed with errors (exit code: $exitCode)" -ForegroundColor Red
    }
    
    exit $exitCode
    
} catch {
    Write-Host "Error: Action failed - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
