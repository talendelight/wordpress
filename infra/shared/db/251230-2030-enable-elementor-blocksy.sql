-- ============================================================================
-- Database Delta: Enable Elementor & Blocksy Companion
-- ============================================================================
-- File: 251230-2030-enable-elementor-blocksy.sql
-- Date: December 30, 2025 8:30 PM
-- Purpose: Activate Elementor page builder and Blocksy Companion plugins
--
-- Changes:
--   - Create wp_e_events table (Elementor event tracking)
--   - Add Elementor configuration options (14 entries)
--   - Add Blocksy Companion configuration (1 entry)
--   - Update active_plugins list
--
-- Context: Local dev has these plugins activated. This delta syncs production
--          to match development environment for consistent page building capability.
--
-- NOTE: This is a schema + configuration delta.
--       Apply AFTER 000000-0000-init-db.sql and existing deltas.
-- ============================================================================

-- ============================================
-- Elementor: Create Events Table
-- ============================================

CREATE TABLE IF NOT EXISTS `wp_e_events` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_data` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `created_at_index` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- ============================================
-- Blocksy Companion Configuration
-- ============================================
-- NOTE: Blocksy Companion already installed in production (blocksy_db_version exists).
--       Plugin activation must be done manually via WP Admin to preserve existing
--       production plugins (Hostinger suite, Akismet, WPForms, etc.)
-- ============================================

INSERT INTO `wp_options` (`option_name`, `option_value`, `autoload`) VALUES
('blocksy_db_version', '2.1.23', 'yes')
ON DUPLICATE KEY UPDATE `option_value` = '2.1.23';

-- ============================================
-- Elementor Configuration Options
-- ============================================

-- Core version and activation tracking
INSERT INTO `wp_options` (`option_name`, `option_value`, `autoload`) VALUES
('elementor_version', '3.34.0', 'yes'),
('elementor_onboarded', '1', 'yes'),
('elementor_install_history', 'a:1:{s:6:"3.34.0";i:1767082922;}', 'no'),
('elementor_events_db_version', '1.0.0', 'yes')
ON DUPLICATE KEY UPDATE 
  `option_value` = VALUES(`option_value`),
  `autoload` = VALUES(`autoload`);

-- Design system defaults
INSERT INTO `wp_options` (`option_name`, `option_value`, `autoload`) VALUES
('elementor_active_kit', '8', 'yes'),
('elementor_disable_color_schemes', 'yes', 'yes'),
('elementor_disable_typography_schemes', 'yes', 'yes'),
('elementor_font_display', 'swap', 'yes')
ON DUPLICATE KEY UPDATE 
  `option_value` = VALUES(`option_value`),
  `autoload` = VALUES(`autoload`);

-- Viewport responsive breakpoints
INSERT INTO `wp_options` (`option_name`, `option_value`, `autoload`) VALUES
('elementor_viewport_lg', '1000', 'yes'),
('elementor_viewport_md', '690', 'yes')
ON DUPLICATE KEY UPDATE 
  `option_value` = VALUES(`option_value`),
  `autoload` = VALUES(`autoload`);

-- Feature flags and settings
INSERT INTO `wp_options` (`option_name`, `option_value`, `autoload`) VALUES
('elementor_landing_pages_activation', '0', 'yes'),
('elementor_connect_site_key', 'faf683330c9f220bc310bb6a30e61708', 'no')
ON DUPLICATE KEY UPDATE 
  `option_value` = VALUES(`option_value`),
  `autoload` = VALUES(`autoload`);

-- Onboarding checklist state
INSERT INTO `wp_options` (`option_name`, `option_value`, `autoload`) VALUES
('elementor_checklist', '{"last_opened_timestamp":null,"first_closed_checklist_in_editor":false,"is_popup_minimized":false,"steps":{"add_logo":{"is_marked_completed":false,"is_immutable_completed":false},"set_fonts_and_colors":{"is_marked_completed":false,"is_immutable_completed":false},"create_pages":{"is_marked_completed":false,"is_immutable_completed":false},"setup_header":{"is_marked_completed":false,"is_immutable_completed":false},"assign_homepage":{"is_marked_completed":false,"is_immutable_completed":false}},"should_open_in_editor":false}', 'yes')
ON DUPLICATE KEY UPDATE `option_value` = VALUES(`option_value`);

-- News feed cache (long serialized data)
INSERT INTO `wp_options` (`option_name`, `option_value`, `autoload`) VALUES
('elementor_remote_info_feed_data', 'a:3:{i:0;a:5:{s:5:"title";s:79:"Introducing Elementor 3.33: Variables Manager, Custom CSS, Blend Modes, & more!";s:7:"excerpt";s:340:"Elementor 3.33 builds on the foundation of Editor V4, continuing our mission to create a faster, more scalable, and more intuitive design experience for Web Creators. With the addition of the Variables Manager, element-level Custom CSS, Background Clipping, and Blend Modes, designers have more creative precision and consistency than ever.";s:7:"created";i:1762944115;s:5:"badge";s:3:"NEW";s:3:"url";s:145:"https://elementor.com/blog/elementor-333-v4-variables-manager-custom-css/?utm_source=wp-overview-widget&utm_medium=wp-dash&utm_campaign=news-feed";}i:1;a:5:{s:5:"title";s:76:"Introducing Elementor 3.32: Transitions, Transform, Size Variables, and More";s:7:"excerpt";s:250:"Elementor 3.32 is here, accelerating Editor V4 Alpha with transform controls and layered transitions, system-wide Size Variables and streamlined class management. This release empowers you to build more consistent, dynamic, and professional websites.";s:7:"created";i:1759243152;s:5:"badge";s:3:"NEW";s:3:"url";s:138:"https://elementor.com/blog/elementor-332-v4-transform-transitions/?utm_source=wp-overview-widget&utm_medium=wp-dash&utm_campaign=news-feed";}i:2;a:5:{s:5:"title";s:70:"Introducing Elementor 3.31: New Editor V4 Variables, Filters, and More";s:7:"excerpt";s:294:"Elementor 3.31 is here, pushing Editor V4 forward with powerful design system enhancements and modern visual styling tools. From Variables and Filters to smarter editing workflows and semantic markup, this version makes it easier than ever to design beautiful, performant, and accessible sites.";s:7:"created";i:1755094220;s:5:"badge";s:3:"NEW";s:3:"url";s:140:"https://elementor.com/blog/elementor-331-v4-alpha-variables-filters/?utm_source=wp-overview-widget&utm_medium=wp-dash&utm_campaign=news-feed";}}', 'no')
ON DUPLICATE KEY UPDATE `option_value` = VALUES(`option_value`);

-- ============================================
-- DEPLOYMENT NOTES
-- ============================================
-- This delta creates database structures only. Plugin activation is MANUAL.
--
-- Post-deployment steps:
--   1. Run this SQL via phpMyAdmin or SSH (creates wp_e_events table + options)
--   2. Login to WP Admin → Plugins
--   3. MANUALLY ACTIVATE:
--      - Elementor (will show as "Installed" but inactive)
--      - Blocksy Companion (will show as "Installed" but inactive)
--   4. Verify: Create test page → "Edit with Elementor" button should appear
--
-- Why manual activation?
--   - Production has 7 active plugins (Hostinger suite, Akismet, WPForms)
--   - Modifying active_plugins via SQL risks breaking production plugins
--   - WP Admin activation safely merges new plugins into existing array
--
-- Rollback (if needed):
--   - Deactivate plugins via WP Admin
--   - DROP TABLE wp_e_events;
--   - DELETE FROM wp_options WHERE option_name LIKE 'elementor%' OR option_name = 'blocksy_db_version';
-- ============================================
