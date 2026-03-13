-- Fix logout menu item URL (was pointing to /logout/ which doesn't exist)
-- Menu item should use WordPress logout URL with redirect to home
-- Date: 2026-02-14 23:30
-- Updated: 2026-03-13 - Parameterized menu item ID for environment independence
-- Issue: Users clicking Logout get "Page not found" instead of logging out
-- Note: URL uses relative path - works in local and production
-- Note: functions.php dynamically adds security nonce via wp_logout_url()

-- ==============================================================================
-- INSTRUCTIONS: Get Logout menu item ID before running this SQL
-- ==============================================================================
-- Run this PowerShell script to get menu IDs for your environment:
--
-- For Local:
--   .\infra\shared\scripts\get-menu-ids.ps1 -Environment Local -MenuLocation "primary-menu" -Title "Logout"
--
-- For Production:
--   .\infra\shared\scripts\get-menu-ids.ps1 -Environment Production -MenuLocation "primary-menu" -Title "Logout"
--
-- Or get all menu IDs with SQL format:
--   .\infra\shared\scripts\get-menu-ids.ps1 -Environment Local -MenuLocation "primary-menu" -OutputFormat SQL
-- ==============================================================================

-- Set Logout menu item ID variable (update with actual ID from get-menu-ids.ps1)
-- Example for Local: ID = 45
SET @menu_item_logout = 45;

-- Update logout menu item URL to use proper WordPress logout endpoint (relative URL)
UPDATE wp_postmeta 
SET meta_value = '/wp-login.php?action=logout'
WHERE post_id = @menu_item_logout AND meta_key = '_menu_item_url';

-- Verify the update
SELECT p.ID, p.post_title, pm.meta_key, pm.meta_value
FROM wp_posts p
JOIN wp_postmeta pm ON p.ID = pm.post_id
WHERE p.ID = @menu_item_logout AND pm.meta_key IN ('_menu_item_url', '_menu_item_type');
