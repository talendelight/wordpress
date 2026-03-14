# Local Development Password Viewer/Resetter
# Usage: pwsh infra/shared/scripts/view-user-password.ps1 -Email john@example.com
#
# This script is for LOCAL DEVELOPMENT ONLY
# It allows you to:
# 1. See recently created users from saved requests
# 2. Reset a user's password and display the new password
#
# Production: Users receive passwords via email, no need for this script

param(
    [Parameter(Mandatory=$false)]
    [string]$Email
)

if (-not $Email) {
    Write-Host "Usage: pwsh infra/shared/scripts/view-user-password.ps1 -Email <email>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example: pwsh infra/shared/scripts/view-user-password.ps1 -Email john@example.com" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This will reset the user's password and display the new password."
    Write-Host ""
    Write-Host "Recently saved users:" -ForegroundColor Green
    podman exec wp wp user list --role=td_candidate,td_employer,td_scout --format=table --allow-root --skip-plugins
    exit 1
}

# Check if user exists
$userId = podman exec wp wp user get $Email --field=ID --allow-root --skip-plugins 2>$null

if (-not $userId) {
    Write-Host "❌ User not found: $Email" -ForegroundColor Red
    Write-Host ""
    Write-Host "Recently saved users:" -ForegroundColor Green
    podman exec wp wp user list --role=td_candidate,td_employer,td_scout --format=table --allow-root --skip-plugins
    exit 1
}

# Generate new password
$newPassword = podman exec wp wp eval 'echo wp_generate_password(16, true, true);' --allow-root --skip-plugins

# Reset password
podman exec wp wp user update $Email --user_pass="$newPassword" --allow-root --skip-plugins | Out-Null

Write-Host "✅ Password reset successfully for: $Email" -ForegroundColor Green
Write-Host ""
Write-Host "📋 New Password: $newPassword" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Copy this password now - it will not be shown again!" -ForegroundColor Yellow
