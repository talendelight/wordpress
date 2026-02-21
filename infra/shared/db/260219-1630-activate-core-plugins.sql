-- Activate Core Plugins for TalenDelight Platform
-- Ensures essential plugins are active after database recreation
-- Created: 2026-02-19 16:30
-- Updated: 2026-02-19 23:30 to include login-logout-menu

-- Plugins activated:
-- 1. talendelight-roles - Custom user roles (td_candidate, td_employer, td_scout, td_operator, td_manager)
-- 2. wp-user-manager - Login/registration forms
-- 3. blocksy-companion - Theme companion plugin
-- 4. forminator - Form builder for user submissions
-- 5. login-logout-menu - Dynamic login/logout/profile menu items

-- Update active_plugins option with all core plugins
-- PHP serialized array format: a:5:{...}
UPDATE wp_options 
SET option_value = 'a:5:{i:0;s:42:"talendelight-roles/talendelight-roles.php";i:1;s:35:"wp-user-manager/wp-user-manager.php";i:2;s:39:"blocksy-companion/blocksy-companion.php";i:3;s:25:"forminator/forminator.php";i:4;s:39:"login-logout-menu/login-logout-menu.php";}' 
WHERE option_name = 'active_plugins';

-- Set flag to trigger role registration on next page load
-- The plugin checks this option and registers roles if not set
DELETE FROM wp_options WHERE option_name = 'talendelight_roles_registered';
