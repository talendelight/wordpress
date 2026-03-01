<?php
require_once '/home/u909075950/domains/hireaccord.com/public_html/wp-load.php';

echo "Purging all caches...\n\n";

// WordPress object cache
wp_cache_flush();
echo "âœ“ WordPress object cache flushed\n";

// LiteSpeed Cache
if (class_exists('LiteSpeed_Cache_API')) {
    LiteSpeed_Cache_API::purge_all();
    echo "âœ“ LiteSpeed Cache purged via API\n";
} elseif (function_exists('litespeed_purge_all')) {
    litespeed_purge_all();
    echo "âœ“ LiteSpeed Cache purged via function\n";
} elseif (defined('LSCACHE_ADV_PURGE')) {
    do_action('litespeed_purge_all');
    echo "âœ“ LiteSpeed Cache purged via action\n";
} else {
    echo "âœ— LiteSpeed Cache not detected\n";
}

// Clear transients
global $wpdb;
$wpdb->query("DELETE FROM {$wpdb->options} WHERE option_name LIKE '_transient_%'");
echo "âœ“ Transients cleared\n";

// Verify page content one more time
$page = get_post(50);
echo "\nPage 50 content: " . $page->post_content . "\n";

exit(0);
