<#
.SYNOPSIS
    WordPress vulnerability scanner using WPScan

.DESCRIPTION
    Runs WPScan against your WordPress installation to check for vulnerabilities
    in WordPress core, plugins, themes, and configuration.

.PARAMETER Environment
    Target environment: 'dev' or 'prod' (default: 'dev')

.PARAMETER ApiToken
    WPScan API token for enhanced scanning (optional, free tier available at wpscan.com)

.PARAMETER Enumerate
    What to enumerate: ap (all plugins), at (all themes), u (users), etc.
    Default: ap,at,u

.PARAMETER Aggressive
    Use aggressive plugin detection (slower but more thorough)

.EXAMPLE
    .\scan-vulnerabilities.ps1
    Runs basic scan against dev environment

.EXAMPLE
    .\scan-vulnerabilities.ps1 -Environment prod -ApiToken "your_token_here"
    Runs scan against production with API token

.EXAMPLE
    .\scan-vulnerabilities.ps1 -Aggressive
    Runs aggressive scan with thorough plugin detection
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('dev', 'prod')]
    [string]$Environment = 'dev',

    [Parameter(Mandatory=$false)]
    [string]$ApiToken = $env:WPSCAN_API_TOKEN,

    [Parameter(Mandatory=$false)]
    [string]$Enumerate = 'ap,at,u',

    [Parameter(Mandatory=$false)]
    [switch]$Aggressive
)

# Set strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Configuration
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$reportsDir = Join-Path $scriptDir "reports"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportFile = "wpscan-$timestamp.txt"
$reportPath = Join-Path $reportsDir $reportFile

# Ensure reports directory exists
if (-not (Test-Path $reportsDir)) {
    New-Item -ItemType Directory -Path $reportsDir | Out-Null
    Write-Host "Created reports directory: $reportsDir" -ForegroundColor Green
}

# Determine target URL based on environment
$targetUrl = switch ($Environment) {
    'dev'  { 'http://wordpress:80' }
    'prod' { 'http://wordpress:80' }
}

Write-Host "`n=== WordPress Vulnerability Scanner ===" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Target URL: $targetUrl" -ForegroundColor Yellow
Write-Host "Report: $reportPath" -ForegroundColor Yellow
Write-Host "======================================`n" -ForegroundColor Cyan

# Check if Podman is running
try {
    podman ps | Out-Null
} catch {
    Write-Host "ERROR: Podman is not running or not accessible" -ForegroundColor Red
    Write-Host "Please start Podman and try again" -ForegroundColor Red
    exit 1
}

# Check if WordPress containers are running
$wordpressRunning = podman ps --filter "name=wordpress" --format "{{.Names}}" | Select-String -Pattern "wordpress"
if (-not $wordpressRunning) {
    Write-Host "WARNING: WordPress container does not appear to be running" -ForegroundColor Yellow
    Write-Host "Start the environment first:" -ForegroundColor Yellow
    Write-Host "  cd infra/$Environment" -ForegroundColor Yellow
    Write-Host "  podman-compose up -d" -ForegroundColor Yellow
    $continue = Read-Host "`nContinue anyway? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 0
    }
}

# Build WPScan command
$scanArgs = @(
    'run', '--rm',
    '--network', "${Environment}_default",
    '-v', "${reportsDir}:/reports",
    'wpscanteam/wpscan:latest',
    '--url', $targetUrl,
    '--enumerate', $Enumerate,
    '--random-user-agent',
    '--format', 'cli',
    '--output', "/reports/$reportFile"
)

# Add API token if provided
if ($ApiToken) {
    $scanArgs += @('--api-token', $ApiToken)
    Write-Host "Using API token for enhanced scanning" -ForegroundColor Green
} else {
    Write-Host "No API token provided (running with limited database access)" -ForegroundColor Yellow
    Write-Host "Get a free token at: https://wpscan.com/register`n" -ForegroundColor Yellow
}

# Add aggressive detection if requested
if ($Aggressive) {
    $scanArgs += @('--plugins-detection', 'aggressive')
    Write-Host "Using aggressive plugin detection (this may take longer)" -ForegroundColor Yellow
}

Write-Host "Starting WPScan...`n" -ForegroundColor Green

# Run WPScan
try {
    & podman $scanArgs
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "`n=== Scan completed successfully ===" -ForegroundColor Green
    } else {
        Write-Host "`n=== Scan completed with warnings ===" -ForegroundColor Yellow
    }

    # Create symlink to latest report
    $latestPath = Join-Path $reportsDir "wpscan-latest.txt"
    if (Test-Path $latestPath) {
        Remove-Item $latestPath -Force
    }
    Copy-Item $reportPath $latestPath

    Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
    Write-Host "Latest report: $latestPath" -ForegroundColor Cyan

    # Display summary of findings
    if (Test-Path $reportPath) {
        Write-Host "`n=== Summary ===" -ForegroundColor Cyan
        
        $content = Get-Content $reportPath -Raw
        
        # Extract key findings
        if ($content -match '\[!\]') {
            Write-Host "`nCritical findings detected! Review the full report." -ForegroundColor Red
        }
        
        # Count vulnerabilities
        $vulnCount = ([regex]::Matches($content, '\[!\]')).Count
        $infoCount = ([regex]::Matches($content, '\[\+\]')).Count
        
        Write-Host "Alerts: $vulnCount" -ForegroundColor $(if ($vulnCount -gt 0) { 'Red' } else { 'Green' })
        Write-Host "Info items: $infoCount" -ForegroundColor Yellow
        
        # Show WordPress version if found
        if ($content -match 'WordPress version ([0-9.]+)') {
            Write-Host "WordPress version: $($Matches[1])" -ForegroundColor Yellow
        }
    }

    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. Review the full report: $reportPath" -ForegroundColor White
    Write-Host "2. Update any vulnerable plugins/themes" -ForegroundColor White
    Write-Host "3. Implement security recommendations" -ForegroundColor White
    Write-Host "4. Run this scan regularly (weekly recommended)" -ForegroundColor White

} catch {
    Write-Host "`nERROR: WPScan failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Scan complete ===`n" -ForegroundColor Green
