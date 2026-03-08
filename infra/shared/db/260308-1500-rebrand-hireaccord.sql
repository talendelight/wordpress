-- Rebrand WordPress site from TalenDelight to HireAccord
-- Date: 2026-03-08 15:00
-- Description: Update site title, set custom logo and favicon for HireAccord branding

-- Update site title
UPDATE wp_options SET option_value = 'HireAccord' WHERE option_name = 'blogname';

-- Set custom logo (Attachment ID 68 - HireAccord-logo-blue-big.png)
-- Note: In production, you need to import the logo first and get the attachment ID
-- Then update this ID accordingly
-- For reference: wp media import /path/to/HireAccord-logo-blue-big.png --title='HireAccord Logo' --porcelain
INSERT INTO wp_options (option_name, option_value, autoload)
VALUES ('theme_mods_blocksy', '', 'yes')
ON DUPLICATE KEY UPDATE option_value = CONCAT(
    SUBSTRING_INDEX(option_value, '"custom_logo"', 1),
    '"custom_logo";i:68;',
    SUBSTRING_INDEX(option_value, '"custom_logo"', -1)
);

-- Alternative simpler approach for custom_logo (if theme_mods doesn't exist yet)
-- This will be set via wp theme mod set custom_logo [ID] during deployment

-- Set site icon / favicon (Attachment ID 69 - apple-touch-icon.png)
-- Note: In production, import apple-touch-icon.png and update ID
-- For reference: wp media import /path/to/apple-touch-icon.png --title='HireAccord Site Icon' --porcelain
UPDATE wp_options SET option_value = '69' WHERE option_name = 'site_icon';

-- Deployment Instructions:
-- 1. Copy HireAccord-logo-blue-big.png to production wp-content/uploads/2026/
-- 2. Import: wp media import /var/www/html/wp-content/uploads/2026/HireAccord-logo-blue-big.png --title='HireAccord Logo' --porcelain
-- 3. Note the attachment ID returned (e.g., 101)
-- 4. Set logo: wp theme mod set custom_logo [ID]
-- 5. Copy apple-touch-icon.png to production wp-content/uploads/2026/
-- 6. Import: wp media import /var/www/html/wp-content/uploads/2026/apple-touch-icon.png --title='HireAccord Site Icon' --porcelain
-- 7. Note the attachment ID returned (e.g., 102)
-- 8. Set icon: wp option update site_icon [ID]
-- 9. Run this SQL to update site title
-- 10. Clear cache: wp cache flush
