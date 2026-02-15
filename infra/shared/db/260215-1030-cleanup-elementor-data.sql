-- Cleanup Elementor metadata and data from database
-- Date: 2026-02-15 10:30
-- Context: All pages migrated to Gutenberg, Elementor plugin removed
-- Safe to run: Elementor plugin deactivated and deleted

-- Remove Elementor post meta
DELETE FROM wp_postmeta WHERE meta_key LIKE '_elementor%';

-- Remove Elementor options
DELETE FROM wp_options WHERE option_name LIKE 'elementor%';

-- Remove Elementor user meta
DELETE FROM wp_usermeta WHERE meta_key LIKE 'elementor%';

-- Verify cleanup (should return 0 rows)
SELECT 'Elementor postmeta remaining:' as check_type, COUNT(*) as count FROM wp_postmeta WHERE meta_key LIKE '_elementor%'
UNION ALL
SELECT 'Elementor options remaining:', COUNT(*) FROM wp_options WHERE option_name LIKE 'elementor%'
UNION ALL
SELECT 'Elementor usermeta remaining:', COUNT(*) FROM wp_usermeta WHERE meta_key LIKE 'elementor%';
