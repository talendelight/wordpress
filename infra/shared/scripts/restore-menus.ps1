#!/usr/bin/env pwsh
# Script: restore-menus.ps1
# Purpose: Restore WordPress menus from production structure
# Usage: pwsh tmp/restore-menus.ps1

Write-Host "`nRestoring WordPress menus from production structure...`n" -ForegroundColor Cyan

# Create Primary Menu (the active one)
Write-Host "Creating Primary Menu..." -ForegroundColor Yellow
podman exec wp bash -c "wp menu create 'Primary Menu' --allow-root --skip-plugins" 2>$null

# Add menu items to Primary Menu
Write-Host "Adding menu items to Primary Menu..." -ForegroundColor Yellow

podman exec wp bash -c "wp menu item add-custom primary-menu 'Welcome' '/' --porcelain --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu item add-custom primary-menu 'Register' '/select-role/' --porcelain --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu item add-custom primary-menu 'Profile' '/profile/' --porcelain --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu item add-custom primary-menu 'Help' '/help/' --porcelain --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu item add-custom primary-menu 'Login' '/log-in/' --porcelain --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu item add-custom primary-menu 'Logout' '/wp-login.php?action=logout&redirect_to=/welcome/' --porcelain --allow-root --skip-plugins" 2>$null

# Assign Primary Menu to theme locations
Write-Host "Assigning Primary Menu to theme locations..." -ForegroundColor Yellow
podman exec wp bash -c "wp menu location assign primary-menu footer --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu location assign primary-menu menu_1 --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu location assign primary-menu menu_2 --allow-root --skip-plugins" 2>$null
podman exec wp bash -c "wp menu location assign primary-menu menu_mobile --allow-root --skip-plugins" 2>$null

# Flush cache
Write-Host "Flushing WordPress cache..." -ForegroundColor Yellow
podman exec wp bash -c "wp cache flush --allow-root --skip-plugins" 2>$null

# Verify menus
Write-Host "`nVerifying menus..." -ForegroundColor Green
podman exec wp bash -c "wp menu list --format=table --allow-root --skip-plugins"

Write-Host ""
Write-Host "Menu restoration complete!" -ForegroundColor Green
Write-Host "Primary Menu:" -ForegroundColor Cyan
Write-Host "  - 6 items: Welcome, Register, Profile, Help, Login, Logout" -ForegroundColor Gray
Write-Host "  - Assigned to: footer, menu_1, menu_2, menu_mobile" -ForegroundColor Gray
Write-Host ""
