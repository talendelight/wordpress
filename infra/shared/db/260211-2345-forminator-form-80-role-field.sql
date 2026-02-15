-- Forminator Form 80: Add hidden field for role parameter
-- Date: 2026-02-11 23:45
-- Description: Added hidden-1 field to capture td_user_role query parameter

-- This is a backup/documentation of the Forminator form configuration
-- The form was modified via WordPress admin UI to add a hidden field:
--   Field ID: hidden-1
--   Label: Role
--   Default Value: query parameter 'td_user_role'
--   Prefill: td_user_role

-- Form metadata is stored in wp_postmeta where post_id = 80
-- To restore: Import via WordPress admin or use wp forminator import

-- Verification query:
SELECT meta_key, LEFT(meta_value, 100) as preview 
FROM wp_postmeta 
WHERE post_id = 80 
  AND meta_key = 'forminator_form_meta'
  AND meta_value LIKE '%hidden-1%';
