#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Main action dispatcher for WordPress operations
.DESCRIPTION
    Central registry mapping actions to their corresponding scripts.
    Use this as the single entry point for all WordPress deployment, backup, restore, and verification operations.
.EXAMPLE
    pwsh infra/shared/scripts/wp-action.ps1 backup
    pwsh infra/shared/scripts/wp-action.ps1 verify
    pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet(
        'backup',
        'verify', 
        'restore',
        'export-elementor',
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
        description = 'Create timestamped backup of production (pages, options, theme, patterns, database)'
        usage = 'wp-action backup [-BackupDatabase $true] [-MaxBackups 10]'
        examples = @(
            'wp-action backup',
            'wp-action backup -BackupDatabase $true',
            'wp-action backup -MaxBackups 20'
        )
    }
    
    'verify' = @{
        script = 'verify-production.ps1'
        description = 'Verify production state matches expectations (pages, patterns, assets, settings, plugins)'
        usage = 'wp-action verify [-Fix]'
        examples = @(
            'wp-action verify',
            'wp-action verify -Fix'
        )
    }
    
    'restore' = @{
        script = 'restore-production.ps1'
        description = 'Restore production from timestamped backup'
        usage = 'wp-action restore -BackupTimestamp <timestamp|latest> [-RestorePages] [-RestoreOptions] [-RestoreTheme] [-RestoreDatabase] [-DryRun]'
        examples = @(
            'wp-action restore -BackupTimestamp latest -RestorePages $true',
            'wp-action restore -BackupTimestamp 20260208-1430 -RestorePages $true -RestoreOptions $true',
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
    
    'deploy' = @{
        script = $null  # Not a script, shows deployment workflow
        description = 'Show deployment workflow (backup → push → verify)'
        usage = 'wp-action deploy'
    }
}

# Color output helpers
function Write-Action {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# Help display
function Show-Help {
    param([string]$SpecificAction = $null)
    
    if ($SpecificAction -and $SCRIPT_REGISTRY.ContainsKey($SpecificAction)) {
        $info = $SCRIPT_REGISTRY[$SpecificAction]
        
        Write-Action "`n=== Action: $SpecificAction ==="
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
            Write-Host "  pwsh infra/shared/scripts/$example" -ForegroundColor Gray
        }
        
    } else {
        Write-Action "`n=== WordPress Action Dispatcher ==="
        Write-Host "`nCentral registry for all WordPress operations`n"
        
        Write-Host "Available Actions:" -ForegroundColor Yellow
        
        foreach ($key in $SCRIPT_REGISTRY.Keys | Sort-Object) {
            $info = $SCRIPT_REGISTRY[$key]
            Write-Host "`n  $key" -ForegroundColor Cyan
            Write-Host "    $($info.description)" -ForegroundColor Gray
            
            if ($info.script) {
                Write-Host "    Script: infra/shared/scripts/$($info.script)" -ForegroundColor DarkGray
            }
        }
        
        Write-Host "`nUsage:" -ForegroundColor Yellow
        Write-Host "  pwsh infra/shared/scripts/wp-action.ps1 <action> [arguments...]`n"
        
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  pwsh infra/shared/scripts/wp-action.ps1 help backup" -ForegroundColor Gray
        Write-Host "  pwsh infra/shared/scripts/wp-action.ps1 backup" -ForegroundColor Gray
        Write-Host "  pwsh infra/shared/scripts/wp-action.ps1 verify" -ForegroundColor Gray
        Write-Host "  pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages `$true`n"
        
        Write-Host "Documentation:" -ForegroundColor Yellow
        Write-Host "  docs/BACKUP-RESTORE-QUICKSTART.md - Quick start guide"
        Write-Host "  docs/DISASTER-RECOVERY-PLAN.md - Complete DR procedures"
        Write-Host "  docs/DEPLOYMENT-WORKFLOW.md - Deployment process`n"
    }
}

# Show deployment workflow
function Show-DeploymentWorkflow {
    Write-Action "`n=== Deployment Workflow ==="
    
    Write-Host "`n1. BACKUP (MANDATORY - Before deployment)" -ForegroundColor Yellow
    Write-Host "   pwsh infra/shared/scripts/wp-action.ps1 backup" -ForegroundColor Gray
    Write-Host "   Creates: restore/backups/yyyyMMdd-HHmm/`n"
    
    Write-Host "2. DEPLOY (Push to production)" -ForegroundColor Yellow
    Write-Host "   git checkout main" -ForegroundColor Gray
    Write-Host "   git merge develop --no-edit" -ForegroundColor Gray
    Write-Host "   git push origin main" -ForegroundColor Gray
    Write-Host "   (Wait 30 seconds for Hostinger auto-deployment)`n"
    
    Write-Host "3. VERIFY (MANDATORY - After deployment)" -ForegroundColor Yellow
    Write-Host "   pwsh infra/shared/scripts/wp-action.ps1 verify" -ForegroundColor Gray
    Write-Host "   Checks: pages, patterns, assets, settings, plugins`n"
    
    Write-Host "4. RESTORE (If verification fails)" -ForegroundColor Yellow
    Write-Host "   pwsh infra/shared/scripts/wp-action.ps1 restore -BackupTimestamp latest -RestorePages `$true`n"
    
    Write-Host "Documentation:" -ForegroundColor Cyan
    Write-Host "  docs/BACKUP-RESTORE-QUICKSTART.md"
    Write-Host "  docs/DEPLOYMENT-WORKFLOW.md`n"
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
    
    # Get script info
    if (-not $SCRIPT_REGISTRY.ContainsKey($Action)) {
        Write-Error "Unknown action: $Action"
        Write-Host "`nRun 'wp-action help' to see available actions`n" -ForegroundColor Yellow
        exit 1
    }
    
    $scriptInfo = $SCRIPT_REGISTRY[$Action]
    $scriptPath = Join-Path $PSScriptRoot $scriptInfo.script
    
    if (-not (Test-Path $scriptPath)) {
        Write-Error "Script not found: $scriptPath"
        exit 1
    }
    
    # Execute the mapped script with forwarded arguments
    Write-Action "Executing: $Action"
    Write-Host "Script: $($scriptInfo.script)`n" -ForegroundColor Gray
    
    # Build argument string
    $argString = ""
    if ($RemainingArgs.Count -gt 0) {
        $argString = $RemainingArgs -join " "
    }
    
    # Execute with splatting
    if ($argString) {
        $expression = "& '$scriptPath' $argString"
    } else {
        $expression = "& '$scriptPath'"
    }
    
    Invoke-Expression $expression
    
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Success "`nAction completed successfully"
    } else {
        Write-Error "`nAction completed with errors (exit code: $exitCode)"
    }
    
    exit $exitCode
    
} catch {
    Write-Error "Action failed: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
