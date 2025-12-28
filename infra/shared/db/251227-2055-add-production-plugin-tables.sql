-- ============================================================================
-- Database Delta: Production Plugin Tables (from Hostinger)
-- ============================================================================
-- File: 251227-2055-add-production-plugin-tables.sql
-- Date: December 27, 2025
-- Source: Hostinger production database export
-- Purpose: Add plugin-specific tables found in production
--
-- Tables: 13 production-only tables
--   - Action Scheduler (4 tables) - WooCommerce/plugin async tasks
--   - Hostinger Reach (3 tables) - Hostinger-specific features [OPTIONAL]
--   - LiteSpeed Cache (2 tables) - LiteSpeed caching
--   - WPForms (4 tables) - Form management
--
-- NOTE: This is a CREATE TABLE only delta (no data).
--       Apply AFTER baseline to add production plugin tables.
--
-- ============================================================================
-- OPEN ACTIONS
-- ============================================================================
-- See: docs/OPEN-ACTIONS.md for complete list of action items
--
-- Quick Reference:
--   [ ] Install WooCommerce plugin (Action Scheduler dependency)
--   [x] Install LiteSpeed Cache plugin ✅ INSTALLED (Dec 27, 2025)
--   [!] Install WPForms Lite plugin
--   [ ] Investigate wp_hostinger_reach_* table exclusion possibility
--
-- ============================================================================
-- HOSTINGER-SPECIFIC TABLES (Reference for Investigation)
-- ============================================================================
-- wp_hostinger_reach_carts
-- wp_hostinger_reach_contact_lists
-- wp_hostinger_reach_forms
--
-- See: docs/OPEN-ACTIONS.md for investigation details and decision criteria
-- ============================================================================


-- ============================================
--wp_actionscheduler_actions
-- ============================================

-- Table structure for table `wp_actionscheduler_actions`
--

CREATE TABLE `wp_actionscheduler_actions` (
  `action_id` bigint(20) UNSIGNED NOT NULL,
  `hook` varchar(191) NOT NULL,
  `status` varchar(20) NOT NULL,
  `scheduled_date_gmt` datetime DEFAULT '0000-00-00 00:00:00',
  `scheduled_date_local` datetime DEFAULT '0000-00-00 00:00:00',
  `priority` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `args` varchar(191) DEFAULT NULL,
  `schedule` longtext DEFAULT NULL,
  `group_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `last_attempt_gmt` datetime DEFAULT '0000-00-00 00:00:00',
  `last_attempt_local` datetime DEFAULT '0000-00-00 00:00:00',
  `claim_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `extended_args` varchar(8000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

--
-- Dumping data for table `wp_actionscheduler_actions`
--

INSERT INTO `wp_actionscheduler_actions` (`action_id`, `hook`, `status`, `scheduled_date_gmt`, `scheduled_date_local`, `priority`, `args`, `schedule`, `group_id`, `attempts`, `last_attempt_gmt`, `last_attempt_local`, `claim_id`, `extended_args`) VALUES
(5, 'hostinger-reach/jobs/cleanup_carts/start', 'complete', '2025-12-26 12:34:01', '2025-12-26 12:34:01', 10, '[]', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766752441;s:18:\"\0*\0first_timestamp\";i:1766752441;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766752441;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 1, 1, '2025-12-26 12:35:06', '2025-12-26 12:35:06', 1, NULL),
(6, 'action_scheduler/migration_hook', 'complete', '2025-12-26 12:35:01', '2025-12-26 12:35:01', 10, '[]', 'O:30:\"ActionScheduler_SimpleSchedule\":2:{s:22:\"\0*\0scheduled_timestamp\";i:1766752501;s:41:\"\0ActionScheduler_SimpleSchedule\0timestamp\";i:1766752501;}', 2, 1, '2025-12-26 12:35:06', '2025-12-26 12:35:06', 1, NULL),
(7, 'hostinger-reach/jobs/cleanup_carts/start', 'complete', '2025-12-27 12:35:06', '2025-12-27 12:35:06', 10, '[]', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766838906;s:18:\"\0*\0first_timestamp\";i:1766752441;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766838906;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 1, 1, '2025-12-27 12:36:05', '2025-12-27 12:36:05', 197, NULL),
(8, 'wpforms_process_forms_locator_scan', 'complete', '2025-12-26 12:35:09', '2025-12-26 12:35:09', 10, '{\"tasks_meta_id\":1}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766752509;s:18:\"\0*\0first_timestamp\";i:1766752509;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766752509;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 3, 1, '2025-12-26 12:35:12', '2025-12-26 12:35:12', 3, NULL),
(9, 'wpforms_process_purge_spam', 'complete', '2025-12-26 12:35:09', '2025-12-26 12:35:09', 10, '{\"tasks_meta_id\":2}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766752509;s:18:\"\0*\0first_timestamp\";i:1766752509;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766752509;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 3, 1, '2025-12-26 12:35:12', '2025-12-26 12:35:12', 3, NULL),
(10, 'wpforms_email_summaries_fetch_info_blocks', 'complete', '2025-12-25 00:33:07', '2025-12-25 00:33:07', 10, '{\"tasks_meta_id\":null}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766622787;s:18:\"\0*\0first_timestamp\";i:1766622787;s:13:\"\0*\0recurrence\";i:604800;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766622787;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:604800;}', 3, 1, '2025-12-26 12:35:12', '2025-12-26 12:35:12', 3, NULL),
(11, 'wpforms_email_summaries_fetch_info_blocks', 'pending', '2026-01-02 12:35:12', '2026-01-02 12:35:12', 10, '{\"tasks_meta_id\":null}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1767357312;s:18:\"\0*\0first_timestamp\";i:1766622787;s:13:\"\0*\0recurrence\";i:604800;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1767357312;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:604800;}', 3, 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, NULL),
(12, 'wpforms_process_forms_locator_scan', 'complete', '2025-12-27 12:35:12', '2025-12-27 12:35:12', 10, '{\"tasks_meta_id\":1}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766838912;s:18:\"\0*\0first_timestamp\";i:1766752509;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766838912;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 3, 1, '2025-12-27 12:36:05', '2025-12-27 12:36:05', 197, NULL),
(13, 'wpforms_process_purge_spam', 'complete', '2025-12-27 12:35:12', '2025-12-27 12:35:12', 10, '{\"tasks_meta_id\":2}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766838912;s:18:\"\0*\0first_timestamp\";i:1766752509;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766838912;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 3, 1, '2025-12-27 12:36:05', '2025-12-27 12:36:05', 197, NULL),
(14, 'action_scheduler_run_recurring_actions_schedule_hook', 'complete', '2025-12-26 12:35:14', '2025-12-26 12:35:14', 20, '[]', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766752514;s:18:\"\0*\0first_timestamp\";i:1766752514;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766752514;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 4, 1, '2025-12-26 12:35:17', '2025-12-26 12:35:17', 5, NULL),
(15, 'wpforms_admin_notifications_update', 'complete', '2025-12-26 12:35:16', '2025-12-26 12:35:16', 10, '{\"tasks_meta_id\":3}', 'O:28:\"ActionScheduler_NullSchedule\":0:{}', 3, 1, '2025-12-26 12:35:17', '2025-12-26 12:35:17', 5, NULL),
(16, 'action_scheduler_run_recurring_actions_schedule_hook', 'complete', '2025-12-27 12:35:17', '2025-12-27 12:35:17', 20, '[]', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766838917;s:18:\"\0*\0first_timestamp\";i:1766752514;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766838917;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 4, 1, '2025-12-27 12:36:05', '2025-12-27 12:36:05', 197, NULL),
(17, 'wpforms_admin_notifications_update', 'complete', '2025-12-26 14:42:18', '2025-12-26 14:42:18', 10, '{\"tasks_meta_id\":4}', 'O:28:\"ActionScheduler_NullSchedule\":0:{}', 3, 1, '2025-12-26 14:43:20', '2025-12-26 14:43:20', 68, NULL),
(18, 'hostinger-reach/jobs/cleanup_carts/start', 'pending', '2025-12-28 12:36:05', '2025-12-28 12:36:05', 10, '[]', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766925365;s:18:\"\0*\0first_timestamp\";i:1766752441;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766925365;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 1, 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, NULL),
(19, 'wpforms_process_forms_locator_scan', 'pending', '2025-12-28 12:36:05', '2025-12-28 12:36:05', 10, '{\"tasks_meta_id\":1}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766925365;s:18:\"\0*\0first_timestamp\";i:1766752509;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766925365;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 3, 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, NULL),
(20, 'wpforms_process_purge_spam', 'pending', '2025-12-28 12:36:05', '2025-12-28 12:36:05', 10, '{\"tasks_meta_id\":2}', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766925365;s:18:\"\0*\0first_timestamp\";i:1766752509;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766925365;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 3, 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, NULL),
(21, 'action_scheduler_run_recurring_actions_schedule_hook', 'pending', '2025-12-28 12:36:05', '2025-12-28 12:36:05', 20, '[]', 'O:32:\"ActionScheduler_IntervalSchedule\":5:{s:22:\"\0*\0scheduled_timestamp\";i:1766925365;s:18:\"\0*\0first_timestamp\";i:1766752514;s:13:\"\0*\0recurrence\";i:86400;s:49:\"\0ActionScheduler_IntervalSchedule\0start_timestamp\";i:1766925365;s:53:\"\0ActionScheduler_IntervalSchedule\0interval_in_seconds\";i:86400;}', 4, 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, NULL),
(22, 'wpforms_admin_notifications_update', 'complete', '2025-12-27 16:15:52', '2025-12-27 16:15:52', 10, '{\"tasks_meta_id\":5}', 'O:28:\"ActionScheduler_NullSchedule\":0:{}', 3, 1, '2025-12-27 16:16:42', '2025-12-27 16:16:42', 238, NULL);

-- --------------------------------------------------------

--

-- ============================================
--wp_actionscheduler_claims
-- ============================================

-- Table structure for table `wp_actionscheduler_claims`
--

CREATE TABLE `wp_actionscheduler_claims` (
  `claim_id` bigint(20) UNSIGNED NOT NULL,
  `date_created_gmt` datetime DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_actionscheduler_groups
-- ============================================

-- Table structure for table `wp_actionscheduler_groups`
--

CREATE TABLE `wp_actionscheduler_groups` (
  `group_id` bigint(20) UNSIGNED NOT NULL,
  `slug` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

--
-- Dumping data for table `wp_actionscheduler_groups`
--

INSERT INTO `wp_actionscheduler_groups` (`group_id`, `slug`) VALUES
(1, 'hostinger-reach'),
(2, 'action-scheduler-migration'),
(3, 'wpforms'),
(4, 'ActionScheduler');

-- --------------------------------------------------------

--

-- ============================================
--wp_actionscheduler_logs
-- ============================================

-- Table structure for table `wp_actionscheduler_logs`
--

CREATE TABLE `wp_actionscheduler_logs` (
  `log_id` bigint(20) UNSIGNED NOT NULL,
  `action_id` bigint(20) UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `log_date_gmt` datetime DEFAULT '0000-00-00 00:00:00',
  `log_date_local` datetime DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

--
-- Dumping data for table `wp_actionscheduler_logs`
--

INSERT INTO `wp_actionscheduler_logs` (`log_id`, `action_id`, `message`, `log_date_gmt`, `log_date_local`) VALUES
(1, 5, 'action created', '2025-12-26 12:34:01', '2025-12-26 12:34:01'),
(2, 6, 'action created', '2025-12-26 12:34:01', '2025-12-26 12:34:01'),
(3, 5, 'action started via Async Request', '2025-12-26 12:35:06', '2025-12-26 12:35:06'),
(4, 5, 'action complete via Async Request', '2025-12-26 12:35:06', '2025-12-26 12:35:06'),
(5, 7, 'action created', '2025-12-26 12:35:06', '2025-12-26 12:35:06'),
(6, 6, 'action started via Async Request', '2025-12-26 12:35:06', '2025-12-26 12:35:06'),
(7, 6, 'action complete via Async Request', '2025-12-26 12:35:06', '2025-12-26 12:35:06'),
(8, 8, 'action created', '2025-12-26 12:35:09', '2025-12-26 12:35:09'),
(9, 9, 'action created', '2025-12-26 12:35:09', '2025-12-26 12:35:09'),
(10, 10, 'action created', '2025-12-26 12:35:09', '2025-12-26 12:35:09'),
(11, 10, 'action started via Async Request', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(12, 10, 'action complete via Async Request', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(13, 11, 'action created', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(14, 8, 'action started via Async Request', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(15, 8, 'action complete via Async Request', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(16, 12, 'action created', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(17, 9, 'action started via Async Request', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(18, 9, 'action complete via Async Request', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(19, 13, 'action created', '2025-12-26 12:35:12', '2025-12-26 12:35:12'),
(20, 14, 'action created', '2025-12-26 12:35:14', '2025-12-26 12:35:14'),
(21, 15, 'action created', '2025-12-26 12:35:16', '2025-12-26 12:35:16'),
(22, 15, 'action started via Async Request', '2025-12-26 12:35:17', '2025-12-26 12:35:17'),
(23, 15, 'action complete via Async Request', '2025-12-26 12:35:17', '2025-12-26 12:35:17'),
(24, 14, 'action started via Async Request', '2025-12-26 12:35:17', '2025-12-26 12:35:17'),
(25, 14, 'action complete via Async Request', '2025-12-26 12:35:17', '2025-12-26 12:35:17'),
(26, 16, 'action created', '2025-12-26 12:35:17', '2025-12-26 12:35:17'),
(27, 17, 'action created', '2025-12-26 14:42:18', '2025-12-26 14:42:18'),
(28, 17, 'action started via Async Request', '2025-12-26 14:43:20', '2025-12-26 14:43:20'),
(29, 17, 'action complete via Async Request', '2025-12-26 14:43:20', '2025-12-26 14:43:20'),
(30, 7, 'action started via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(31, 7, 'action complete via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(32, 18, 'action created', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(33, 12, 'action started via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(34, 12, 'action complete via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(35, 19, 'action created', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(36, 13, 'action started via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(37, 13, 'action complete via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(38, 20, 'action created', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(39, 16, 'action started via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(40, 16, 'action complete via WP Cron', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(41, 21, 'action created', '2025-12-27 12:36:05', '2025-12-27 12:36:05'),
(42, 22, 'action created', '2025-12-27 16:15:52', '2025-12-27 16:15:52'),
(43, 22, 'action started via Async Request', '2025-12-27 16:16:42', '2025-12-27 16:16:42'),
(44, 22, 'action complete via Async Request', '2025-12-27 16:16:42', '2025-12-27 16:16:42');

-- --------------------------------------------------------

--

-- ============================================
--wp_hostinger_reach_carts
-- ============================================

-- Table structure for table `wp_hostinger_reach_carts`
--

CREATE TABLE `wp_hostinger_reach_carts` (
  `hash` varchar(100) NOT NULL,
  `customer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `items` longtext NOT NULL,
  `totals` text NOT NULL,
  `currency` varchar(3) NOT NULL,
  `status` varchar(100) NOT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_hostinger_reach_contact_lists
-- ============================================

-- Table structure for table `wp_hostinger_reach_contact_lists`
--

CREATE TABLE `wp_hostinger_reach_contact_lists` (
  `id` mediumint(9) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_hostinger_reach_forms
-- ============================================

-- Table structure for table `wp_hostinger_reach_forms`
--

CREATE TABLE `wp_hostinger_reach_forms` (
  `id` mediumint(9) NOT NULL,
  `form_id` varchar(255) NOT NULL,
  `form_title` varchar(255) DEFAULT NULL,
  `post_id` int(11) DEFAULT NULL,
  `contact_list_id` int(11) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `submissions` int(10) UNSIGNED DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_litespeed_url
-- ============================================

-- Table structure for table `wp_litespeed_url`
--

CREATE TABLE `wp_litespeed_url` (
  `id` bigint(20) NOT NULL,
  `url` varchar(500) NOT NULL,
  `cache_tags` varchar(1000) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_litespeed_url_file
-- ============================================

-- Table structure for table `wp_litespeed_url_file`
--

CREATE TABLE `wp_litespeed_url_file` (
  `id` bigint(20) NOT NULL,
  `url_id` bigint(20) NOT NULL,
  `vary` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'md5 of final vary',
  `filename` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'md5 of file content',
  `type` tinyint(4) NOT NULL COMMENT 'css=1,js=2,ccss=3,ucss=4',
  `mobile` tinyint(4) NOT NULL COMMENT 'mobile=1',
  `webp` tinyint(4) NOT NULL COMMENT 'webp=1',
  `expired` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_wpforms_logs
-- ============================================

-- Table structure for table `wp_wpforms_logs`
--

CREATE TABLE `wp_wpforms_logs` (
  `id` bigint(20) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` longtext NOT NULL,
  `types` varchar(255) NOT NULL,
  `create_at` datetime NOT NULL,
  `form_id` bigint(20) DEFAULT NULL,
  `entry_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_wpforms_payments
-- ============================================

-- Table structure for table `wp_wpforms_payments`
--

CREATE TABLE `wp_wpforms_payments` (
  `id` bigint(20) NOT NULL,
  `form_id` bigint(20) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT '',
  `subtotal_amount` decimal(26,8) NOT NULL DEFAULT 0.00000000,
  `discount_amount` decimal(26,8) NOT NULL DEFAULT 0.00000000,
  `total_amount` decimal(26,8) NOT NULL DEFAULT 0.00000000,
  `currency` varchar(3) NOT NULL DEFAULT '',
  `entry_id` bigint(20) NOT NULL DEFAULT 0,
  `gateway` varchar(20) NOT NULL DEFAULT '',
  `type` varchar(12) NOT NULL DEFAULT '',
  `mode` varchar(4) NOT NULL DEFAULT '',
  `transaction_id` varchar(40) NOT NULL DEFAULT '',
  `customer_id` varchar(40) NOT NULL DEFAULT '',
  `subscription_id` varchar(40) NOT NULL DEFAULT '',
  `subscription_status` varchar(10) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `date_created_gmt` datetime NOT NULL,
  `date_updated_gmt` datetime NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_wpforms_payment_meta
-- ============================================

-- Table structure for table `wp_wpforms_payment_meta`
--

CREATE TABLE `wp_wpforms_payment_meta` (
  `id` bigint(20) NOT NULL,
  `payment_id` bigint(20) NOT NULL,
  `meta_key` varchar(255) DEFAULT NULL,
  `meta_value` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--

-- ============================================
--wp_wpforms_tasks_meta
-- ============================================

-- Table structure for table `wp_wpforms_tasks_meta`
--

CREATE TABLE `wp_wpforms_tasks_meta` (
  `id` bigint(20) NOT NULL,
  `action` varchar(255) NOT NULL,
  `data` longtext NOT NULL,
  `date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

--
-- Dumping data for table `wp_wpforms_tasks_meta`
--

INSERT INTO `wp_wpforms_tasks_meta` (`id`, `action`, `data`, `date`) VALUES
(1, 'wpforms_process_forms_locator_scan', 'W10=', '2025-12-26 12:35:09'),
(2, 'wpforms_process_purge_spam', 'W10=', '2025-12-26 12:35:09');

--
