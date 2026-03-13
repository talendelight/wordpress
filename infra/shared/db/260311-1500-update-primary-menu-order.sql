-- Update Primary Menu order
-- Correct order: About Us, Register, Profile, Help, Login, Logout
-- Date: 2026-03-11 15:00
-- Updated: 2026-03-13 - Parameterized IDs for environment independence

-- ==============================================================================
-- INSTRUCTIONS: Get menu item IDs before running this SQL
-- ==============================================================================
-- Run this PowerShell script to get menu IDs for your environment:
--
-- For Local:
--   .\infra\shared\scripts\get-menu-ids.ps1 -Environment Local -MenuLocation "primary-menu" -OutputFormat SQL
--
-- For Production:
--   .\infra\shared\scripts\get-menu-ids.ps1 -Environment Production -MenuLocation "primary-menu" -OutputFormat SQL
--
-- The script will output SET @menu_item_* variable declarations.
-- Copy those declarations and paste them below, then run this SQL.
-- ==============================================================================

-- Set menu item ID variables (update these with actual IDs from get-menu-ids.ps1)
-- Example for Local (IDs: 40, 41, 42, 43, 44, 45):
SET @menu_item_about_us = 40;
SET @menu_item_register = 41;
SET @menu_item_profile = 42;
SET @menu_item_help = 43;
SET @menu_item_login = 44;
SET @menu_item_logout = 45;

-- Update menu order using variables
UPDATE wp_posts 
SET menu_order = CASE ID 
    WHEN @menu_item_about_us THEN 1   -- About Us
    WHEN @menu_item_register THEN 2   -- Register
    WHEN @menu_item_profile THEN 3    -- Profile
    WHEN @menu_item_help THEN 4       -- Help
    WHEN @menu_item_login THEN 5      -- Login
    WHEN @menu_item_logout THEN 6     -- Logout
END 
WHERE ID IN (@menu_item_about_us, @menu_item_register, @menu_item_profile, @menu_item_help, @menu_item_login, @menu_item_logout);
