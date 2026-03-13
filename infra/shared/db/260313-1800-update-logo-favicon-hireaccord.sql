-- Update HireAccord Logo and Favicon with New Brand Assets
-- Date: 2026-03-13 18:00
-- Description: Replace old logo/favicon with new HireAccord brand assets (SVG logo, multiple favicon formats)

-- This migration assumes new media files have been imported and attachment IDs obtained
-- See deployment instructions below for the upload and import process

-- Update custom logo to use new HireAccord_logo.svg (Attachment ID TBD)
-- Note: Replace 'NEW_LOGO_ID' with actual attachment ID after import
-- UPDATE: wp theme mod set custom_logo [NEW_LOGO_ID]

-- Update site icon to use new favicon (Attachment ID TBD)  
-- Note: Replace 'NEW_ICON_ID' with actual attachment ID after import
-- UPDATE wp_options SET option_value = 'NEW_ICON_ID' WHERE option_name = 'site_icon';

-- Deployment Instructions:
-- =======================

-- Step 1: Upload new brand assets to server
-- -----------------------------------------
-- Local files location: restore/assets/images/hireaccord/
-- Files to upload:
--   - HireAccord_logo.svg (primary site logo)
--   - HireAccord_logo_original.png (fallback/alternative)
--   - favicon.ico (browser favicon)
--   - favicon-32.png (32x32 favicon)
--   - apple-touch-icon.png (iOS home screen icon)
--   - android-chrome-192.png (Android icon 192x192)
--   - android-chrome-512.png (Android icon 512x512)

-- Step 2: Copy files to production server
-- ----------------------------------------
-- scp -P 65002 -i "tmp/hostinger_deploy_key" \
--   "restore/assets/images/hireaccord/HireAccord_logo.svg" \
--   "restore/assets/images/hireaccord/favicon.ico" \
--   "restore/assets/images/hireaccord/apple-touch-icon.png" \
--   "restore/assets/images/hireaccord/android-chrome-192.png" \
--   "restore/assets/images/hireaccord/android-chrome-512.png" \
--   u909075950@45.84.205.129:/tmp/hireaccord-assets/

-- Step 3: SSH into production server
-- -----------------------------------
-- ssh -p 65002 -i "tmp/hostinger_deploy_key" u909075950@45.84.205.129

-- Step 4: Import logo as WordPress media attachment
-- --------------------------------------------------
-- cd /home/u909075950/domains/hireaccord.com/public_html
-- LOGO_ID=$(wp media import /tmp/hireaccord-assets/HireAccord_logo.svg \
--   --title='HireAccord Logo SVG' \
--   --porcelain \
--   --allow-root \
--   --skip-plugins)
-- echo "Logo Attachment ID: $LOGO_ID"

-- Step 5: Set custom logo theme mod
-- ----------------------------------
-- wp theme mod set custom_logo $LOGO_ID --allow-root --skip-plugins

-- Step 6: Import site icon/favicon
-- ---------------------------------
-- ICON_ID=$(wp media import /tmp/hireaccord-assets/apple-touch-icon.png \
--   --title='HireAccord Site Icon' \
--   --porcelain \
--   --allow-root \
--   --skip-plugins)
-- echo "Icon Attachment ID: $ICON_ID"

-- Step 7: Set site icon option
-- -----------------------------
-- wp option update site_icon $ICON_ID --allow-root --skip-plugins

-- Step 8: Import additional favicon formats (optional, for completeness)
-- ----------------------------------------------------------------------
-- wp media import /tmp/hireaccord-assets/favicon.ico \
--   --title='HireAccord Favicon ICO' \
--   --allow-root \
--   --skip-plugins

-- wp media import /tmp/hireaccord-assets/android-chrome-192.png \
--   --title='HireAccord Android Chrome 192' \
--   --allow-root \
--   --skip-plugins

-- wp media import /tmp/hireaccord-assets/android-chrome-512.png \
--   --title='HireAccord Android Chrome 512' \
--   --allow-root \
--   --skip-plugins

-- Step 9: Clean up temporary files
-- ---------------------------------
-- rm -rf /tmp/hireaccord-assets/

-- Step 10: Clear all caches
-- --------------------------
-- wp cache flush --allow-root --skip-plugins
-- wp litespeed-purge all --allow-root --skip-plugins

-- Step 11: Verify logo and favicon
-- ---------------------------------
-- Visit: https://hireaccord.com
-- Check: Site logo in header should display HireAccord SVG logo
-- Check: Browser tab should show new favicon
-- Check: Mobile home screen icon (test on iOS/Android)

-- Notes:
-- ------
-- - SVG logo provides better quality and scalability than PNG
-- - Multiple favicon formats ensure compatibility across devices/browsers
-- - apple-touch-icon.png used for iOS home screen bookmarks
-- - android-chrome-*.png used for Android home screen bookmarks
-- - favicon.ico provides fallback for older browsers

-- Rollback Instructions (if needed):
-- -----------------------------------
-- If issues occur, revert to previous logo (Attachment ID 68) and icon (Attachment ID 69):
--   wp theme mod set custom_logo 68 --allow-root --skip-plugins
--   wp option update site_icon 69 --allow-root --skip-plugins
--   wp cache flush --allow-root --skip-plugins
