-- Create core pages required for site navigation
-- These pages must exist in local dev to match menu items
-- Content will be restored separately from restore/pages/
-- Created: 2026-02-19

-- Insert core pages (IDs will auto-increment from next available)
-- Note: Production has different IDs, but slugs remain consistent
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES
-- Welcome page (homepage)
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Welcome page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Welcome', '', 'publish', 'closed', 'open', '', 'welcome', '', '', NOW(), NOW(), '', 0, 'http://localhost:8080/?page_id=6', 0, 'page', '', 0),
-- Help page
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Help page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Help', '', 'publish', 'closed', 'open', '', 'help', '', '', NOW(), NOW(), '', 0, 'http://localhost:8080/?page_id=11', 0, 'page', '', 0),
-- Log In page
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Log In page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Log In', '', 'publish', 'closed', 'open', '', 'log-in', '', '', NOW(), NOW(), '', 0, 'http://localhost:8080/?page_id=12', 0, 'page', '', 0),
-- Select Role page (used by Register menu item)
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Select Role page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Select Role', '', 'publish', 'closed', 'open', '', 'select-role', '', '', NOW(), NOW(), '', 0, 'http://localhost:8080/?page_id=13', 0, 'page', '', 0);

-- Set Welcome as homepage
UPDATE wp_options 
SET option_value = (SELECT ID FROM wp_posts WHERE post_name = 'welcome' AND post_type = 'page' LIMIT 1) 
WHERE option_name = 'page_on_front';

UPDATE wp_options 
SET option_value = 'page' 
WHERE option_name = 'show_on_front';
