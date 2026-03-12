<?php
/**
 * Reusable WordPress Page Update Template
 * 
 * Updates a WordPress page's content from an HTML file.
 * Used by deploy-pages.ps1 for consistent page updates across environments.
 * 
 * Usage: php update-page-template.php <page_id> <html_file_path>
 * 
 * Example:
 *   php update-page-template.php 21 /tmp/candidates-21.html
 * 
 * Exit codes:
 *   0 - Success
 *   1 - Error (missing arguments, file not found, update failed)
 */

// Validate arguments
if ($argc < 3) {
    echo "ERROR: Missing required arguments\n";
    echo "Usage: php update-page-template.php <page_id> <html_file_path>\n";
    echo "Example: php update-page-template.php 21 /tmp/candidates-21.html\n";
    exit(1);
}

$page_id = (int)$argv[1];
$html_file = $argv[2];

// Validate page ID
if ($page_id <= 0) {
    echo "ERROR: Invalid page ID: $page_id\n";
    exit(1);
}

// Validate HTML file exists
if (!file_exists($html_file)) {
    echo "ERROR: HTML file not found: $html_file\n";
    exit(1);
}

// Read HTML content
$content = file_get_contents($html_file);

if ($content === false) {
    echo "ERROR: Failed to read HTML file: $html_file\n";
    exit(1);
}

if (empty($content)) {
    echo "ERROR: HTML file is empty: $html_file\n";
    exit(1);
}

// Update page using wp_update_post
$result = wp_update_post([
    'ID' => $page_id,
    'post_content' => $content,
    'post_status' => 'publish'
], true);

// Check for errors
if (is_wp_error($result)) {
    echo "ERROR: " . $result->get_error_message() . "\n";
    exit(1);
}

if (!$result) {
    echo "ERROR: Update failed for page ID $page_id\n";
    exit(1);
}

// Get updated post to confirm
$updated_post = get_post($page_id);

if (!$updated_post) {
    echo "ERROR: Failed to retrieve updated page\n";
    exit(1);
}

$byte_count = strlen($updated_post->post_content);

// Clear caches
wp_cache_flush();

// Optional: Clear LiteSpeed cache if available
if (function_exists('litespeed_purge_all')) {
    litespeed_purge_all();
}

// Success output
echo "SUCCESS: Page $page_id updated with $byte_count bytes\n";

exit(0);
