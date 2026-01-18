# PowerShell script to apply a SQL file to the local MariaDB (dev) database
# Usage: .\apply-sql-change.ps1 -SqlFilePath <path-to-sql-file>
param(
    [Parameter(Mandatory=$true)]
    [string]$SqlFilePath
)

$DbHost = "127.0.0.1"
$DbPort = 3306
$DbUser = "root"
$DbPassword = "password"
$DbName = "wordpress"

if (!(Test-Path $SqlFilePath)) {
    Write-Error "SQL file not found: $SqlFilePath"
    exit 1
}

Write-Host "Applying SQL file: $SqlFilePath to database $DbName on $DbHost:$DbPort..."

# Use podman exec to run mysql inside the db container
$containerName = "wp-db"
$cmd = "podman exec -i $containerName mysql -u $DbUser -p$DbPassword $DbName < `"$SqlFilePath`""

Invoke-Expression $cmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "SQL applied successfully."
} else {
    Write-Error "Failed to apply SQL."
    exit $LASTEXITCODE
}
