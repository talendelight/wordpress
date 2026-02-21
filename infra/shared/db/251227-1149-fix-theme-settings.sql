-- ============================================================================
-- Database Delta: Fix Theme Settings
-- ============================================================================
-- File: 251227-1149-fix-theme-settings.sql
-- Date: December 27, 2025 11:49 AM (corrected February 19, 2026)
-- Purpose: Set correct active theme to Blocksy child theme
--          Fixes incorrect theme settings from previous bad export
-- 
-- Tables affected: wp_options only
-- Changes:
--   - template: twentytwentyfive → blocksy
--   - stylesheet: twentytwentyfive → blocksy-child
-- 
-- NOTE: This uses UPDATE instead of TRUNCATE to preserve other settings
-- ============================================================================

-- Set correct active theme
UPDATE `wp_options` SET `option_value` = 'blocksy' WHERE `option_name` = 'template';
UPDATE `wp_options` SET `option_value` = 'blocksy-child' WHERE `option_name` = 'stylesheet';
UPDATE `wp_options` SET `option_value` = 'Blocksy Child' WHERE `option_name` = 'current_theme';

-- Log completion
SELECT 'Theme settings corrected: blocksy-child is now active' AS Status;
