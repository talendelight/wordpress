-- Update footer copyright text to HireAccord branding
-- Date: 2026-03-08 16:00
-- Related: MKTB-030 (HireAccord Branding)
-- Strategic Decision: Project codename = "TalenDelight" (internal), Brand name = "HireAccord" (public/external)

-- ==============================================================================
-- PRODUCTION DEPLOYMENT INSTRUCTIONS (wp-cli method - RECOMMENDED)
-- ==============================================================================
-- This cannot be done via pure SQL due to serialized PHP array in theme_mods
-- Use wp-cli instead:

-- Step 1: Set copyright text in Blocksy theme customizer
-- wp theme mod set copyright_text 'Copyright &copy; {current_year} - HireAccord. A brand of Lochness Technologies LLP. All rights reserved.' --allow-root --skip-plugins

-- Step 2: Verify copyright text was set
-- wp theme mod get copyright_text --allow-root --skip-plugins
-- Expected output: "Copyright © {current_year} - HireAccord. A brand of Lochness Technologies LLP. All rights reserved."

-- Step 3: Clear WordPress cache
-- wp cache flush --allow-root --skip-plugins

-- ==============================================================================
-- LOCAL VERIFICATION (check if it was applied correctly)
-- ==============================================================================
-- Check theme_mods_blocksy contains copyright_text:
-- SELECT option_value FROM wp_options WHERE option_name = 'theme_mods_blocksy';
-- Should contain: s:14:"copyright_text";s:XXX:"Copyright &copy; {current_year} - HireAccord..."

-- ==============================================================================
-- NOTES
-- ==============================================================================
-- - The {current_year} placeholder is automatically replaced by Blocksy theme with the actual year
-- - Footer will display: "Copyright © 2026 - HireAccord. A brand of Lochness Technologies LLP. All rights reserved."
-- - The copyright text appears in the Blocksy footer builder copyright component
-- - If footer doesn't show copyright, check that copyright component is enabled in Appearance > Customize > Footer
-- - DO NOT attempt manual SQL UPDATE on serialized theme_mods - it will corrupt the data
