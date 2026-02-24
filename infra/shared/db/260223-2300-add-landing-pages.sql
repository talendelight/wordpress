-- Create landing pages and role-specific pages
-- These pages exist in production but were missing from initial local setup
-- Content will be restored from restore/pages/ backups
-- Created: 2026-02-24

-- Insert missing landing pages
-- Note: IDs may differ from production, but slugs must match exactly
INSERT INTO wp_posts (post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES
-- Role-specific landing pages
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Candidates landing page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Candidates', '', 'publish', 'closed', 'open', '', 'candidates', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=candidates', 0, 'page', '', 0),
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Employers landing page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Employers', '', 'publish', 'closed', 'open', '', 'employers', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=employers', 0, 'page', '', 0),
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Scouts landing page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Scouts', '', 'publish', 'closed', 'open', '', 'scouts', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=scouts', 0, 'page', '', 0),
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Managers landing page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Managers', '', 'publish', 'closed', 'open', '', 'managers', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=managers', 0, 'page', '', 0),
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Operators landing page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Operators', '', 'publish', 'closed', 'open', '', 'operators', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=operators', 0, 'page', '', 0),

-- Manager-specific pages (slug matches production: "admin" not "manager-admin")
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Manager Admin dashboard placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Manager Admin', '', 'publish', 'closed', 'open', '', 'admin', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=admin', 0, 'page', '', 0),
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Manager Actions dashboard placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Manager Actions', '', 'publish', 'closed', 'open', '', 'actions', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=actions', 0, 'page', '', 0),

-- Registration page (main entry point)
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>Register Profile page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', 'Register Profile', '', 'publish', 'closed', 'open', '', 'register-profile', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=register-profile', 0, 'page', '', 0),

-- Error/utility pages
(1, NOW(), NOW(), '<!-- wp:paragraph --><p>403 Forbidden page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->', '403 Forbidden', '', 'publish', 'closed', 'open', '', '403-forbidden', '', '', NOW(), NOW(), '', 0, 'https://wp.local/?page_id=403-forbidden', 0, 'page', '', 0);

-- Update Privacy Policy with proper content placeholder
UPDATE wp_posts 
SET post_status = 'publish',
    post_content = '<!-- wp:paragraph --><p>Privacy Policy page placeholder. Content will be restored from backup.</p><!-- /wp:paragraph -->'
WHERE post_name = 'privacy-policy' AND post_type = 'page';

