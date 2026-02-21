-- Enable clean permalinks (post name structure)
-- This ensures URLs like /help/ instead of /?page_id=11
-- Created: 2025-01-27 16:00

INSERT INTO wp_options (option_name, option_value, autoload)
VALUES ('permalink_structure', '/%postname%/', 'yes')
ON DUPLICATE KEY UPDATE option_value = '/%postname%/', autoload = 'yes';
