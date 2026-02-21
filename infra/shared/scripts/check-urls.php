<?php
require '/home/u909075950/domains/talendelight.com/public_html/wp-load.php';
echo "WP_HOME constant: " . (defined('WP_HOME') ? WP_HOME : 'NOT DEFINED') . "\n";
echo "WP_SITEURL constant: " . (defined('WP_SITEURL') ? WP_SITEURL : 'NOT DEFINED') . "\n";
echo "home option: " . get_option('home') . "\n";
echo "siteurl option: " . get_option('siteurl') . "\n";
echo "site_url(): " . site_url() . "\n";
echo "home_url(): " . home_url() . "\n";
