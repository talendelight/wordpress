-- Migration: Set Select Role page template
-- Date: 2026-02-24 18:00
-- Purpose: Assign page-role-selection.php template to Select Role page
-- The page uses a custom template, not just content blocks

-- Update Select Role page to use custom template
-- Note: Page ID may differ between environments, use post_name to find it
UPDATE wp_posts 
SET post_name = 'select-role'
WHERE post_name = 'select-role' AND post_type = 'page';

-- Add template meta if not exists
-- First delete any existing template assignment to avoid duplicates
DELETE FROM wp_postmeta 
WHERE post_id IN (SELECT ID FROM wp_posts WHERE post_name = 'select-role' AND post_type = 'page')
  AND meta_key = '_wp_page_template';

-- Insert the template assignment
INSERT INTO wp_postmeta (post_id, meta_key, meta_value)
SELECT ID, '_wp_page_template', 'page-role-selection.php'
FROM wp_posts 
WHERE post_name = 'select-role' AND post_type = 'page';
