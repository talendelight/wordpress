-- Create Profile and Logout menu items for Main Navigation
-- These menu items show/hide based on user login status via login-logout-menu plugin
-- Created: 2026-02-19 23:40
-- Updated: 2026-02-19 23:50 - Adjusted Profile menu_order to 1 for correct display order
-- Prerequisites: login-logout-menu plugin must be active (see 260219-1630-activate-core-plugins.sql)

-- Menu structure when logged IN: Welcome (0), Profile (1), Help (3), Logout (6)
-- Menu structure when logged OUT: Welcome (0), Register (2), Help (3), Login (4)
-- Note: Register (2) and Login (4) are hidden when logged in

-- Insert Profile menu item
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES
(1, NOW(), NOW(), '', 'Profile', '', 'publish', 'closed', 'closed', '', '', '', '', NOW(), NOW(), '', 0, '', 1, 'nav_menu_item', '', 0);

-- Insert Logout menu item
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES
(1, NOW(), NOW(), '', 'Logout', '', 'publish', 'closed', 'closed', '', '', '', '', NOW(), NOW(), '', 0, '', 6, 'nav_menu_item', '', 0);

-- Get the IDs of the newly created menu items
SET @profile_id = (SELECT ID FROM wp_posts WHERE post_type = 'nav_menu_item' AND post_title = 'Profile' AND menu_order = 1 ORDER BY ID DESC LIMIT 1);
SET @logout_id = (SELECT ID FROM wp_posts WHERE post_type = 'nav_menu_item' AND post_title = 'Logout' AND menu_order = 6 ORDER BY ID DESC LIMIT 1);

-- Add menu item metadata for Profile
INSERT INTO wp_postmeta (post_id, meta_key, meta_value)
VALUES
(@profile_id, '_menu_item_type', 'custom'),
(@profile_id, '_menu_item_menu_item_parent', '0'),
(@profile_id, '_menu_item_object_id', '0'),
(@profile_id, '_menu_item_object', 'custom'),
(@profile_id, '_menu_item_target', ''),
(@profile_id, '_menu_item_classes', 'a:1:{i:0;s:0:"";}'),
(@profile_id, '_menu_item_xfn', ''),
(@profile_id, '_menu_item_url', '#loginpress-profile#');

-- Add menu item metadata for Logout
INSERT INTO wp_postmeta (post_id, meta_key, meta_value)
VALUES
(@logout_id, '_menu_item_type', 'custom'),
(@logout_id, '_menu_item_menu_item_parent', '0'),
(@logout_id, '_menu_item_object_id', '0'),
(@logout_id, '_menu_item_object', 'custom'),
(@logout_id, '_menu_item_target', ''),
(@logout_id, '_menu_item_classes', 'a:1:{i:0;s:0:"";}'),
(@logout_id, '_menu_item_xfn', ''),
(@logout_id, '_menu_item_url', '#loginpress-logout#');

-- Associate menu items with Main Navigation menu (term_id = 2)
-- Get the menu term taxonomy ID
SET @main_nav_term_taxonomy_id = (SELECT term_taxonomy_id FROM wp_term_taxonomy WHERE term_id = 2 AND taxonomy = 'nav_menu' LIMIT 1);

-- Link menu items to Main Navigation
INSERT INTO wp_term_relationships (object_id, term_taxonomy_id, term_order)
VALUES
(@profile_id, @main_nav_term_taxonomy_id, 1),
(@logout_id, @main_nav_term_taxonomy_id, 5);

-- Update menu count
UPDATE wp_term_taxonomy 
SET count = (SELECT COUNT(*) FROM wp_term_relationships WHERE term_taxonomy_id = @main_nav_term_taxonomy_id)
WHERE term_taxonomy_id = @main_nav_term_taxonomy_id;

-- Verification query (comment out in production)
-- SELECT p.ID, p.post_title, p.menu_order, pm.meta_key, pm.meta_value
-- FROM wp_posts p
-- LEFT JOIN wp_postmeta pm ON p.ID = pm.post_id AND pm.meta_key IN ('_menu_item_type', '_menu_item_url')
-- WHERE p.ID IN (@profile_id, @logout_id)
-- ORDER BY p.ID, pm.meta_key;
