-- Fix logout menu item URL (was pointing to /logout/ which doesn't exist)
-- Menu item ID 172 should use WordPress logout URL with redirect to home
-- Date: 2026-02-14 23:30
-- Issue: Users clicking Logout get "Page not found" instead of logging out
-- Note: URL uses relative path - works in local and production
-- Note: functions.php dynamically adds security nonce via wp_logout_url()

-- Update logout menu item URL to use proper WordPress logout endpoint (relative URL)
UPDATE wp_postmeta 
SET meta_value = '/wp-login.php?action=logout'
WHERE post_id = 172 AND meta_key = '_menu_item_url';

-- Verify the update
SELECT p.ID, p.post_title, pm.meta_key, pm.meta_value
FROM wp_posts p
JOIN wp_postmeta pm ON p.ID = pm.post_id
WHERE p.ID = 172 AND pm.meta_key IN ('_menu_item_url', '_menu_item_type');
