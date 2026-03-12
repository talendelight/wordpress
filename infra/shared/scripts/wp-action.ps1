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
        'restore-pages',
        'restore-menus',
        'deploy-pages',
        'export-elementor',
        'export-users',
        'get-page-ids',
        'rebuild-menu',
        'purge-caches',
        'check-urls',
        'check-deployment',
        'verify-deployment',
        'verify-security',
        'health-check',
        'apply-sql',
        'cleanup-themes',
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
    
    'restore-pages' = @{
        script = 'deploy-pages.ps1'
        description = 'Restore WordPress page content from backups to local environment'
        usage = 'wp-action restore-pages [-PageNames <slugs>]'
        examples = @(
            'wp-action restore-pages',
            'wp-action restore-pages -PageNames "privacy-policy","cookie-policy"'
        )
        extraArgs = @('-Environment', 'Local')
    }
    
    'restore-menus' = @{
        script = 'restore-menus.ps1'
        description = 'Restore WordPress navigation menus to local environment'
        usage = 'wp-action restore-menus'
        examples = @(
            'wp-action restore-menus'
        )
    }
    
    'deploy-pages' = @{
        script = 'deploy-pages.ps1'
        description = 'Deploy WordPress pages - ALL use cases (individual updates, multiple pages, batch releases)'
        usage = 'wp-action deploy-pages [-Environment <Local|Production>] [-PageNames <slugs>] [-DryRun]'
        examples = @(
            'wp-action deploy-pages -Environment Local -PageNames "candidates" # Individual page update',
            'wp-action deploy-pages -Environment Local -PageNames "candidates","employers" # Multiple pages',
            'wp-action deploy-pages -Environment Production -PageNames "privacy-policy" # Single production deploy',
            'wp-action deploy-pages -Environment Production # Batch release (all pages)',
            'wp-action deploy-pages -Environment Production -DryRun # Preview changes'
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
    
    'export-users' = @{
        script = 'export-users.ps1'
        description = 'Export WordPress users and roles to SQL files'
        usage = 'wp-action export-users'
        examples = @(
            'wp-action export-users'
        )
    }
    
    'get-page-ids' = @{
        script = 'get-page-ids.ps1'
        description = 'Get page IDs from production by URL or slug'
        usage = 'wp-action get-page-ids [-RelativeUrl <url>] [-Slug <slug>] [-ListAll]'
        examples = @(
            'wp-action get-page-ids -RelativeUrl "/welcome/"',
            'wp-action get-page-ids -Slug "welcome"',
            'wp-action get-page-ids -ListAll'
        )
    }
    
    'rebuild-menu' = @{
        script = 'rebuild-navigation-menu.ps1'
        description = 'Rebuild WordPress navigation menu with standard items'
        usage = 'wp-action rebuild-menu [-Environment <local|production>] [-MenuSlug <slug>] [-DryRun]'
        examples = @(
            'wp-action rebuild-menu -Environment production',
            'wp-action rebuild-menu -DryRun',
            'wp-action rebuild-menu -MenuSlug "primary-menu" -ThemeLocation "primary"'
        )
    }
    
    'purge-caches' = @{
        script = 'purge-all-caches.php'
        description = 'Purge all caches (WordPress, LiteSpeed, transients)'
        usage = 'wp-action purge-caches'
        examples = @(
            'wp-action purge-caches'
        )
    }
    
    'check-urls' = @{
        script = 'check-urls.php'
        description = 'Verify WordPress URL configuration'
        usage = 'wp-action check-urls'
        examples = @(
            'wp-action check-urls'
        )
    }
    
    'check-deployment' = @{
        script = 'verify-deployment-readiness.ps1'
        description = 'Pre-commit deployment verification (analyzes git changes)'
        usage = 'wp-action check-deployment'
        examples = @(
            'wp-action check-deployment'
        )
    }
    
    'verify-deployment' = @{
        script = 'verify-deployment.ps1'
        description = 'Post-deployment verification (compares local vs production files)'
        usage = 'wp-action verify-deployment [-FilePattern <pattern>] [-Commit <hash>]'
        examples = @(
            'wp-action verify-deployment',
            'wp-action verify-deployment -FilePattern "wp-content/mu-plugins/*.php"',
            'wp-action verify-deployment -Commit c7722e8f'
        )
    }
    
    'verify-security' = @{
        script = 'verify-security.php'
        description = 'Run security configuration checks'
        usage = 'wp-action verify-security'
        examples = @(
            'wp-action verify-security'
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
    
    'cleanup-themes' = @{
        script = 'cleanup-themes.ps1'
        description = 'Remove unused WordPress default themes (twentytwenty*)'
        usage = 'wp-action cleanup-themes -Environment <local|production> [-DryRun]'
        examples = @(
            'wp-action cleanup-themes -Environment local',
            'wp-action cleanup-themes -Environment production -DryRun',
            'wp-action cleanup-themes -Environment production'
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
        
        $sshCommand = "ssh -i tmp/hostinger_deploy_key -p 65002 u909075950@45.84.205.129 `"cd domains/hireaccord.com/public_html && wp eval-file ~/verify-production-health.php $verbose --allow-root`""
        
        Invoke-Expression $sshCommand
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-Host "`nâœ… Health check passed" -ForegroundColor Green
        } else {
            Write-Host "`nâŒ Health check failed - see details above" -ForegroundColor Red
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
    
    # Merge extraArgs from registry with user-provided args
    $scriptArgs = @()
    if ($scriptInfo.extraArgs) {
        $scriptArgs += $scriptInfo.extraArgs
    }
    if ($RemainingArgs.Count -gt 0) {
        $scriptArgs += $RemainingArgs
    }
    
    # Execute with arguments
    if ($scriptArgs.Count -gt 0) {
        & $scriptPath $scriptArgs
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
